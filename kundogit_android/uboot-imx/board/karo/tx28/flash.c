#include <common.h>
#include <malloc.h>
#include <nand.h>
#include <errno.h>

#include <linux/err.h>

#include <asm/io.h>
#include <asm/sizes.h>
#include <asm/arch/regs-base.h>
#include <asm/arch/regs-gpmi.h>
#include <asm/arch/regs-bch.h>

#define FCB_START_BLOCK		0
#define NUM_FCB_BLOCKS		1
#define MAX_FCB_BLOCKS		32768

struct mx28_nand_timing {
	u8 data_setup;
	u8 data_hold;
	u8 address_setup;
	u8 dsample_time;
	u8 nand_timing_state;
	u8 tREA;
	u8 tRLOH;
	u8 tRHOH;
};

struct mx28_fcb {
	u32 checksum;
	u32 fingerprint;
	u32 version;
	struct mx28_nand_timing timing;
	u32 page_data_size;
	u32 total_page_size;
	u32 sectors_per_block;
	u32 number_of_nands;	/* not used by ROM code */
	u32 total_internal_die;	/* not used by ROM code */
	u32 cell_type;		/* not used by ROM code */
	u32 ecc_blockn_type;
	u32 ecc_block0_size;
	u32 ecc_blockn_size;
	u32 ecc_block0_type;
	u32 metadata_size;
	u32 ecc_blocks_per_page;
	u32 rsrvd[6];		 /* not used by ROM code */
	u32 bch_mode;
	u32 boot_patch;
	u32 patch_sectors;
	u32 fw1_start_page;
	u32 fw2_start_page;
	u32 fw1_sectors;
	u32 fw2_sectors;
	u32 dbbt_search_area;
	u32 bb_mark_byte;
	u32 bb_mark_startbit;
	u32 bb_mark_phys_offset;
};

struct mx28_dbbt_header {
	u32 checksum;
	u32 fingerprint;
	u32 version;
	u32 number_bb;
	u32 number_pages;
	u8 spare[492];
};

struct mx28_dbbt {
	u32 nand_number;
	u32 number_bb;
	u32 bb_num[2040 / 4];
};

#define BF_VAL(v, bf)		(((v) & bf##_MASK) >> bf##_OFFSET)

static nand_info_t *mtd = &nand_info[0];

extern void *_start;

#define BIT(v,n)	(((v) >> (n)) & 0x1)

static u8 calculate_parity_13_8(u8 d)
{
	u8 p = 0;

	p |= (BIT(d, 6) ^ BIT(d, 5) ^ BIT(d, 3) ^ BIT(d, 2))		 << 0;
	p |= (BIT(d, 7) ^ BIT(d, 5) ^ BIT(d, 4) ^ BIT(d, 2) ^ BIT(d, 1)) << 1;
	p |= (BIT(d, 7) ^ BIT(d, 6) ^ BIT(d, 5) ^ BIT(d, 1) ^ BIT(d, 0)) << 2;
	p |= (BIT(d, 7) ^ BIT(d, 4) ^ BIT(d, 3) ^ BIT(d, 0))		 << 3;
	p |= (BIT(d, 6) ^ BIT(d, 4) ^ BIT(d, 3) ^ BIT(d, 2) ^ BIT(d, 1) ^ BIT(d, 0)) << 4;
	return p;
}

static void encode_hamming_13_8(void *_src, void *_ecc, size_t size)
{
	int i;
	u8 *src = _src;
	u8 *ecc = _ecc;

	for (i = 0; i < size; i++)
		ecc[i] = calculate_parity_13_8(src[i]);
}

static u32 calc_chksum(void *buf, size_t size)
{
	u32 chksum = 0;
	u8 *bp = buf;
	size_t i;

	for (i = 0; i < size; i++) {
		chksum += bp[i];
	}
	return ~chksum;
}

/*
  Physical organisation of data in NAND flash:
  metadata
  payload chunk 0 (may be empty)
  ecc for metadata + payload chunk 0
  payload chunk 1
  ecc for payload chunk 1
...
  payload chunk n
  ecc for payload chunk n
 */

static int calc_bb_offset(nand_info_t *mtd, struct mx28_fcb *fcb)
{
	int bb_mark_offset;
	int chunk_data_size = fcb->ecc_blockn_size * 8;
	int chunk_ecc_size = (fcb->ecc_blockn_type << 1) * 13;
	int chunk_total_size = chunk_data_size + chunk_ecc_size;
	int bb_mark_chunk, bb_mark_chunk_offs;

	bb_mark_offset = (mtd->writesize - fcb->metadata_size) * 8;
	if (fcb->ecc_block0_size == 0)
		bb_mark_offset -= (fcb->ecc_block0_type << 1) * 13;

	bb_mark_chunk = bb_mark_offset / chunk_total_size;
	bb_mark_chunk_offs = bb_mark_offset - (bb_mark_chunk * chunk_total_size);
	if (bb_mark_chunk_offs > chunk_data_size) {
		printf("Unsupported ECC layout; BB mark resides in ECC data: %u\n",
			bb_mark_chunk_offs);
		return -EINVAL;
	}
	bb_mark_offset -= bb_mark_chunk * chunk_ecc_size;
	return bb_mark_offset;
}

static struct mx28_fcb *create_fcb(void *buf, int fw1_start_block,
				int fw2_start_block, size_t fw_size)
{
	struct gpmi_regs *gpmi_base = (void *)GPMI_BASE_ADDRESS;
	struct bch_regs *bch_base = (void *)BCH_BASE_ADDRESS;
	u32 fl0, fl1;
	u32 t0, t1;
	int metadata_size;
	int bb_mark_bit_offs;
	struct mx28_fcb *fcb;
	int fcb_offs;

	if (gpmi_base == NULL || bch_base == NULL) {
		return ERR_PTR(-ENOMEM);
	}

	fl0 = readl(&bch_base->hw_bch_flash0layout0);
	fl1 = readl(&bch_base->hw_bch_flash0layout1);
	t0 = readl(&gpmi_base->hw_gpmi_timing0);
	t1 = readl(&gpmi_base->hw_gpmi_timing1);

	metadata_size = BF_VAL(fl0, BCH_FLASHLAYOUT0_META_SIZE);

	fcb = buf + ALIGN(metadata_size, 4);
	fcb_offs = (void *)fcb - buf;

	memset(buf, 0xff, fcb_offs);
	memset(fcb, 0x00, sizeof(*fcb));
	memset(fcb + 1, 0xff, mtd->erasesize - fcb_offs - sizeof(*fcb));

	strncpy((char *)&fcb->fingerprint, "FCB ", 4);
	fcb->version = cpu_to_be32(1);

	fcb->timing.data_setup = BF_VAL(t0, GPMI_TIMING0_DATA_SETUP);
	fcb->timing.data_hold = BF_VAL(t0, GPMI_TIMING0_DATA_HOLD);
	fcb->timing.address_setup = BF_VAL(t0, GPMI_TIMING0_ADDRESS_SETUP);

	fcb->page_data_size = mtd->writesize;
	fcb->total_page_size = mtd->writesize + mtd->oobsize;
	fcb->sectors_per_block = mtd->erasesize / mtd->writesize;

	fcb->ecc_block0_type = BF_VAL(fl0, BCH_FLASHLAYOUT0_ECC0);
	fcb->ecc_block0_size = BF_VAL(fl0, BCH_FLASHLAYOUT0_DATA0_SIZE);
	fcb->ecc_blockn_type = BF_VAL(fl1, BCH_FLASHLAYOUT1_ECCN);
	fcb->ecc_blockn_size = BF_VAL(fl1, BCH_FLASHLAYOUT1_DATAN_SIZE);

	fcb->metadata_size = BF_VAL(fl0, BCH_FLASHLAYOUT0_META_SIZE);
	fcb->ecc_blocks_per_page = BF_VAL(fl0, BCH_FLASHLAYOUT0_NBLOCKS);
	fcb->bch_mode = readl(&bch_base->hw_bch_mode);
/*
	fcb->boot_patch = 0;
	fcb->patch_sectors = 0;
*/
	fcb->fw1_start_page = fw1_start_block * mtd->erasesize / mtd->writesize;
	fcb->fw1_sectors = DIV_ROUND_UP(fw_size, mtd->writesize);

	if (fw2_start_block != 0 && fw2_start_block < mtd->size / mtd->erasesize) {
		fcb->fw2_start_page = fw2_start_block * mtd->erasesize / mtd->writesize;
		fcb->fw2_sectors = fcb->fw1_sectors;
	}

	fcb->dbbt_search_area = 1;

	bb_mark_bit_offs = calc_bb_offset(mtd, fcb);
	if (bb_mark_bit_offs < 0)
		return ERR_PTR(bb_mark_bit_offs);
	fcb->bb_mark_byte = bb_mark_bit_offs / 8;
	fcb->bb_mark_startbit = bb_mark_bit_offs % 8;
	fcb->bb_mark_phys_offset = mtd->writesize;

	fcb->checksum = calc_chksum(&fcb->fingerprint, 512 - 4);
	return fcb;
}

static int find_fcb(void *ref, int page)
{
	int ret = 0;
	struct nand_chip *chip = mtd->priv;
	void *buf = malloc(mtd->erasesize);

	if (buf == NULL) {
		return -ENOMEM;
	}
	chip->select_chip(mtd, 0);
	chip->cmdfunc(mtd, NAND_CMD_READ0, 0x00, page);
	ret = chip->ecc.read_page_raw(mtd, chip, buf, page);
	if (ret) {
		printf("Failed to read FCB from page %u: %d\n", page, ret);
		return ret;
	}
	chip->select_chip(mtd, -1);
	if (memcmp(buf, ref, mtd->writesize) == 0) {
		printf("%s: Found FCB in page %u (%08x)\n", __func__,
			page, page * mtd->writesize);
		ret = 1;
	}
	free(buf);
	return ret;
}

static int write_fcb(void *buf, int block)
{
	int ret;
	struct nand_chip *chip = mtd->priv;
	int page = block * mtd->erasesize / mtd->writesize;

	ret = find_fcb(buf, page);
	if (ret > 0) {
		printf("FCB at block %d is up to date\n", block);
		return 0;
	}

	ret = nand_erase(mtd, block * mtd->erasesize, mtd->erasesize);
	if (ret) {
		printf("Failed to erase FCB block %u\n", block);
		return ret;
	}

	printf("Writing FCB to block %d @ %08x\n", block,
		block * mtd->erasesize);
	chip->select_chip(mtd, 0);
	ret = chip->write_page(mtd, chip, buf, page, 0, 1);
	if (ret) {
		printf("Failed to write FCB to block %u: %d\n", block, ret);
	}
	chip->select_chip(mtd, -1);
	return ret;
}

#define chk_overlap(a,b)				\
	((a##_start_block <= b##_end_block &&		\
		a##_end_block >= b##_start_block) ||	\
	(b##_start_block <= a##_end_block &&		\
		b##_end_block >= a##_start_block))

#define fail_if_overlap(a,b,m1,m2) do {				\
	if (chk_overlap(a, b)) {				\
		printf("%s blocks %lu..%lu overlap %s in blocks %lu..%lu!\n", \
			m1, a##_start_block, a##_end_block,	\
			m2, b##_start_block, b##_end_block);	\
		return -EINVAL;					\
	}							\
} while (0)

#ifndef CONFIG_ENV_OFFSET_REDUND
#define TOTAL_ENV_SIZE CONFIG_ENV_SIZE
#else
#define TOTAL_ENV_SIZE (CONFIG_ENV_SIZE * 2)
#endif

int do_update(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	int ret;
	int block;
	int erase_size = mtd->erasesize;
	int page_size = mtd->writesize;
	void *buf;
	char *load_addr;
	char *file_size;
	size_t size = 0;
	void *addr = NULL;
	struct mx28_fcb *fcb;
	unsigned long fcb_start_block = FCB_START_BLOCK;
	unsigned long num_fcb_blocks = NUM_FCB_BLOCKS;
	unsigned long fcb_end_block;
	unsigned long mtd_num_blocks = mtd->size / mtd->erasesize;
	unsigned long env_start_block = CONFIG_ENV_OFFSET / mtd->erasesize;
	unsigned long env_end_block = env_start_block +
		DIV_ROUND_UP(TOTAL_ENV_SIZE, mtd->erasesize) - 1;
	int optind;
	int fw1_set = 0;
	int fw2_set = 0;
	unsigned long fw1_start_block = 0, fw1_end_block;
	unsigned long fw2_start_block = 0, fw2_end_block;
	unsigned long fw_num_blocks;
	unsigned long extra_blocks = 2;
	nand_erase_options_t erase_opts = { 0, };
	int fcb_written = 0;

	load_addr = getenv("fileaddr");
	file_size = getenv("filesize");

	if (argc < 2 && load_addr == NULL) {
		printf("Load address not specified\n");
		return -EINVAL;
	}
	if (argc < 3 && file_size == NULL) {
		printf("Image size not specified\n");
		return -EINVAL;
	}

	for (optind = 1; optind < argc; optind++) {
		if (strcmp(argv[optind], "-b") == 0) {
			if (optind >= argc - 1) {
				printf("Option %s requires an argument\n", argv[optind]);
				return -EINVAL;
			}
			optind++;
			fcb_start_block = simple_strtoul(argv[optind], NULL, 0);
			if (fcb_start_block >= mtd_num_blocks) {
				printf("Block number %lu is out of range: 0..%lu\n",
					fcb_start_block, mtd_num_blocks - 1);
				return -EINVAL;
			}
		} else if (strcmp(argv[optind], "-n") == 0) {
			if (optind >= argc - 1) {
				printf("Option %s requires an argument\n", argv[optind]);
				return -EINVAL;
			}
			optind++;
			num_fcb_blocks = simple_strtoul(argv[optind], NULL, 0);
			if (num_fcb_blocks > MAX_FCB_BLOCKS) {
				printf("Extraneous number of FCB blocks; max. allowed: %u\n",
					MAX_FCB_BLOCKS);
				return -EINVAL;
			}
		} else if (strcmp(argv[optind], "-f") == 0) {
			if (optind >= argc - 1) {
				printf("Option %s requires an argument\n", argv[optind]);
				return -EINVAL;
			}
			optind++;
			fw1_start_block = simple_strtoul(argv[optind], NULL, 0);
			if (fw1_start_block >= mtd_num_blocks) {
				printf("Block number %lu is out of range: 0..%lu\n",
					fw1_start_block,
					mtd_num_blocks - 1);
				return -EINVAL;
			}
			fw1_set = 1;
		} else if (strcmp(argv[optind], "-r") == 0) {
			if (optind < argc - 1 && argv[optind + 1][0] != '-') {
				optind++;
				fw2_start_block = simple_strtoul(argv[optind], NULL, 0);
				if (fw2_start_block >= mtd_num_blocks) {
					printf("Block number %lu is out of range: 0..%lu\n",
						fw2_start_block,
						mtd_num_blocks - 1);
					return -EINVAL;
				}
			}
			fw2_set = 1;
		} else if (strcmp(argv[optind], "-e") == 0) {
			if (optind >= argc - 1) {
				printf("Option %s requires an argument\n", argv[optind]);
				return -EINVAL;
			}
			optind++;
			extra_blocks = simple_strtoul(argv[optind], NULL, 0);
			if (extra_blocks >= mtd_num_blocks) {
				printf("Extra block count %lu is out of range: 0..%lu\n",
					extra_blocks,
					mtd_num_blocks - 1);
				return -EINVAL;
			}
		} else if (argv[optind][0] == '-') {
			printf("Unrecognized option %s\n", argv[optind]);
			return -EINVAL;
		}
	}
	if (argc > optind) {
		load_addr = NULL;
		addr = (void *)simple_strtoul(argv[optind], NULL, 0);
		optind++;
	}
	if (argc > optind) {
		file_size = NULL;
		size = simple_strtoul(argv[optind], NULL, 0);
		optind++;
	}
	if (load_addr != NULL) {
		addr = (void *)simple_strtoul(load_addr, NULL, 16);
		printf("Using default load address %p\n", addr);
	}
	if (file_size != NULL) {
		size = simple_strtoul(file_size, NULL, 16);
		printf("Using default file size %08x\n", size);
	}
	fcb_end_block = fcb_start_block + num_fcb_blocks - 1;
	fw_num_blocks = DIV_ROUND_UP(size, mtd->erasesize);

	if (!fw1_set) {
		fw1_start_block = fcb_end_block + 1;
		fw1_end_block = fw1_start_block + fw_num_blocks + extra_blocks - 1;
		if (chk_overlap(fw1, env)) {
			fw1_start_block = env_end_block + 1;
			fw1_end_block = fw1_start_block + fw_num_blocks + extra_blocks - 1;
		}
	} else {
		fw1_end_block = fw1_start_block + fw_num_blocks + extra_blocks - 1;
	}

	if (fw2_set && fw2_start_block == 0) {
		fw2_start_block = fw1_end_block + 1;
		fw2_end_block = fw2_start_block + fw_num_blocks + extra_blocks - 1;
		if (chk_overlap(fw2, env)) {
			fw2_start_block = env_end_block + 1;
			fw2_end_block = fw2_start_block + fw_num_blocks + extra_blocks - 1;
		}
	} else {
		fw2_end_block = fw2_start_block + fw_num_blocks + extra_blocks - 1;
	}

	fail_if_overlap(fcb, env, "FCB", "Environment");
	fail_if_overlap(fcb, fw1, "FCB", "FW1");
	fail_if_overlap(fw1, env, "FW1", "Environment");
	if (fw2_set) {
		fail_if_overlap(fcb, fw2, "FCB", "FW2");
		fail_if_overlap(fw2, env, "FW2", "Environment");
		fail_if_overlap(fw1, fw2, "FW1", "FW2");
	}

	buf = malloc(erase_size);
	if (buf == NULL) {
		printf("Failed to allocate buffer\n");
		return -ENOMEM;
	}
	/* search for first non-bad block in FW1 block range */
	while (fw1_start_block <= fw1_end_block) {
		if (!nand_block_isbad(mtd, fw1_start_block * mtd->erasesize))
			break;
		fw1_start_block++;
	}
	if (fw1_end_block - fw1_start_block + 1 < fw_num_blocks) {
		printf("Too many bad blocks in FW1 block range: %lu..%lu\n",
			fw1_end_block + 1 - fw_num_blocks - extra_blocks,
			fw1_end_block);
		return -EINVAL;
	}

	/* search for first non-bad block in FW2 block range */
	while (fw2_set && fw2_start_block <= fw2_end_block) {
		if (!nand_block_isbad(mtd, fw2_start_block * mtd->erasesize))
			break;
		fw2_start_block++;
	}
	if (fw2_end_block - fw2_start_block + 1 < fw_num_blocks) {
		printf("Too many bad blocks in FW2 area %08lx..%08lx\n",
			fw2_end_block + 1 - fw_num_blocks - extra_blocks,
			fw2_end_block);
		return -EINVAL;
	}

	fcb = create_fcb(buf, fw1_start_block, fw2_start_block,
			(fw_num_blocks + extra_blocks) * mtd->erasesize);
	if (IS_ERR(fcb)) {
		printf("Failed to initialize FCB: %ld\n", PTR_ERR(fcb));
		return PTR_ERR(fcb);
	}
	encode_hamming_13_8(fcb, (void *)fcb + 512, 512);

	for (block = fcb_start_block; block < fcb_start_block + num_fcb_blocks;
	     block++) {
		if (nand_block_isbad(mtd, block * mtd->erasesize)) {
			if (block == fcb_start_block)
				fcb_start_block++;
			continue;
		}
		ret = write_fcb(buf, block);
		if (ret) {
			printf("Failed to write FCB to block %u\n", block);
			return ret;
		}
		fcb_written = 1;
	}

	if (!fcb_written) {
		printf("Could not write FCB to flash\n");
		return -EIO;
	}

	printf("Programming U-Boot image from %p to block %lu\n",
		addr, fw1_start_block);
	if (size & (page_size - 1)) {
		memset(addr + size, 0xff, size & (page_size - 1));
		size = ALIGN(size, page_size);
	}

	erase_opts.offset = fcb->fw1_start_page * page_size;
	erase_opts.length = ALIGN(size, erase_size) +
		extra_blocks * mtd->erasesize;
	erase_opts.quiet = 1;

	printf("Erasing flash @ %08llx..%08llx\n", erase_opts.offset,
		erase_opts.offset + erase_opts.length - 1);

	ret = nand_erase_opts(mtd, &erase_opts);
	if (ret) {
		printf("Failed to erase flash: %d\n", ret);
		return ret;
	}
	printf("Programming flash @ %08x..%08x from %p\n",
		fcb->fw1_start_page * page_size,
		fcb->fw1_start_page * page_size + size, addr);
	ret = nand_write_skip_bad(mtd, fcb->fw1_start_page * page_size,
				&size, addr, WITH_DROP_FFS);
	if (ret) {
		printf("Failed to program flash: %d\n", ret);
		return ret;
	}
	if (fw2_start_block == 0) {
		return ret;
	}

	printf("Programming redundant U-Boot image to block %lu\n",
		fw2_start_block);
	erase_opts.offset = fcb->fw2_start_page * page_size;
	printf("Erasing flash @ %08llx..%08llx\n", erase_opts.offset,
		erase_opts.offset + erase_opts.length - 1);

	ret = nand_erase_opts(mtd, &erase_opts);
	if (ret) {
		printf("Failed to erase flash: %d\n", ret);
		return ret;
	}
	printf("Programming flash @ %08x..%08x from %p\n",
		fcb->fw2_start_page * page_size,
		fcb->fw2_start_page * page_size + size, addr);
	ret = nand_write_skip_bad(mtd, fcb->fw2_start_page * page_size,
				&size, addr, WITH_DROP_FFS);
	if (ret) {
		printf("Failed to program flash: %d\n", ret);
		return ret;
	}
	return ret;
}

U_BOOT_CMD(romupdate, 11, 0, do_update,
	"Creates an FCB data structure and writes an U-Boot image to flash\n",
	"[-b #] [-n #] [-f #] [-r [#]] [<address>] [<length>]\n"
	"\t-b #\tfirst FCB block number (default 0)\n"
	"\t-n #\ttotal number of FCB blocks (default 1)\n"
	"\t-f #\twrite bootloader image at block #\n"
	"\t-r\twrite redundant bootloader image at next free block after first image\n"
	"\t-r #\twrite redundant bootloader image at block #\n"
	"\t-e #\tspecify number of redundant blocks per boot loader image\n"
	"\t<address>\tRAM address of bootloader image (default: ${fileaddr}\n"
	"\t<length>\tlength of bootloader image in RAM (default: ${filesize}"
	);
