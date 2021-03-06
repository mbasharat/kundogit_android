#include <config.h>
#include <configs/tx53.h>
#include <asm/arch/imx-regs.h>

#define DEBUG_LED_BIT		20
#define LED_GPIO_BASE		GPIO2_BASE_ADDR
#define LED_MUX_OFFSET		0x174
#define LED_MUX_MODE		0x11

#define SDRAM_CLK		CONFIG_SYS_SDRAM_CLK

#ifdef PHYS_SDRAM_2_SIZE
#define SDRAM_SIZE		(PHYS_SDRAM_1_SIZE + PHYS_SDRAM_2_SIZE)
#else
#define SDRAM_SIZE		PHYS_SDRAM_1_SIZE
#endif

#define REG_ESDCTL0		0x00
#define REG_ESDCFG0		0x04
#define REG_ESDCTL1		0x08
#define REG_ESDCFG1		0x0c
#define REG_ESDMISC		0x10
#define REG_ESDSCR		0x14
#define REG_ESDGPR		0x34

#define REG_CCGR0		0x68
#define REG_CCGR1		0x6c
#define REG_CCGR2		0x70
#define REG_CCGR3		0x74
#define REG_CCGR4		0x78
#define REG_CCGR5		0x7c
#define REG_CCGR6		0x80
#define REG_CCGR7		0x84
#define REG_CMEOR		0x88

#define CPU_2_BE_32(l)			\
	((((l) << 24) & 0xFF000000) |	\
	(((l) << 8) & 0x00FF0000) |	\
	(((l) >> 8) & 0x0000FF00) |	\
	(((l) >> 24) & 0x000000FF))

#define MXC_DCD_ITEM(addr, val)		\
	.word	CPU_2_BE_32(addr), CPU_2_BE_32(val)

#define MXC_DCD_CMD_SZ_BYTE		1
#define MXC_DCD_CMD_SZ_SHORT		2
#define MXC_DCD_CMD_SZ_WORD		4
#define MXC_DCD_CMD_FLAG_WRITE		0x0
#define MXC_DCD_CMD_FLAG_CLR		0x1
#define MXC_DCD_CMD_FLAG_SET		0x3
#define MXC_DCD_CMD_FLAG_CHK_ANY	(1 << 0)
#define MXC_DCD_CMD_FLAG_CHK_SET	(1 << 1)
#define MXC_DCD_CMD_FLAG_CHK_CLR	(0 << 1)

#define MXC_DCD_CMD_WRT(type, flags, next)					\
	.word	CPU_2_BE_32((0xcc << 24) | (((next) - .) << 8) | ((flags) << 3) | (type))

#define MXC_DCD_CMD_CHK(type, flags, addr, mask)				\
	.word	CPU_2_BE_32((0xcf << 24) | (12 << 8) | ((flags) << 3) | (type)),\
		CPU_2_BE_32(addr), CPU_2_BE_32(mask)

#define MXC_DCD_CMD_CHK_CNT(type, flags, addr, mask, count)			\
	.word	CPU_2_BE_32((0xcf << 24) | (16 << 8) | ((flags) << 3) | (type)),\
		CPU_2_BE_32(addr), CPU_2_BE_32(mask), CPU_2_BE_32(count)

#define MXC_DCD_CMD_NOP()							\
	.word	CPU_2_BE_32((0xc0 << 24) | (4 << 8))

#define CK_TO_NS(ck)	(((ck) * 1000 + SDRAM_CLK / 2) / SDRAM_CLK)
#define NS_TO_CK(ns)	(((ns) * SDRAM_CLK + 999) / 1000)

	.macro		CK_VAL,	name, clks, offs, max
	.iflt		\clks - \offs
	.set		\name, 0
	.else
	.ifle		\clks - \offs - \max
	.set		\name, \clks - \offs
	.endif
	.endif
	.endm

	.macro		NS_VAL,	name, ns, offs, max
	.iflt		\ns - \offs
	.set		\name, 0
	.else
	CK_VAL		\name, NS_TO_CK(\ns), \offs, \max
	.endif
	.endm

	.macro		CK_MAX, name, ck1, ck2, offs, max
	.ifgt		\ck1 - \ck2
	CK_VAL		\name, \ck1, \offs, \max
	.else
	CK_VAL		\name, \ck2, \offs, \max
	.endif
	.endm

#define ESDMISC_DDR_TYPE_DDR3		0
#define ESDMISC_DDR_TYPE_LPDDR2		1
#define ESDMISC_DDR_TYPE_DDR2		2

#define DIV_ROUND_UP(m,d)		(((m) + (d) - 1) / (d))

#define CKIL_FREQ_Hz			32768
#define ESDOR_CLK_PERIOD_ns		(1000000000 / CKIL_FREQ_Hz / 2)	/* base clock for ESDOR values */

/* DDR3 SDRAM */
#if SDRAM_SIZE > PHYS_SDRAM_1_SIZE
#define BANK_ADDR_BITS			2
#else
#define BANK_ADDR_BITS			1
#endif
#define SDRAM_BURST_LENGTH		8
#define RALAT				5
#define WALAT				1
#define ADDR_MIRROR			0
#define DDR_TYPE			ESDMISC_DDR_TYPE_DDR3

/* 512/1024MiB SDRAM: NT5CB128M16P-CG */
/* ESDCFG0 0x0c */
NS_VAL	tRFC,	160, 1, 255		/* clks - 1 (0..255) */
CK_MAX	tXS,	tRFC + 1 + NS_TO_CK(10), 5, 1, 255 /* clks - 1 (0..255) tRFC + 10 */
CK_MAX	tXP,	3, NS_TO_CK(6), 1, 7	/* clks - 1 (0..7) */ /* max(6ns, 3*CK) */
CK_MAX	tXPDLL, NS_TO_CK(24), 2, 1, 15	/* clks - 1 (0..15) */
NS_VAL	tFAW,	45, 1, 31		/* clks - 1 (0..31) */
CK_VAL	tCL,	9, 3, 8			/* clks - 3 (0..8) CAS Latency */

/* ESDCFG1 0x10 */
NS_VAL	tRCD,	14, 1, 7		/* clks - 1 (0..7) */
NS_VAL	tRP,	14, 1, 7		/* clks - 1 (0..7) */
NS_VAL	tRC,	50, 1, 31		/* clks - 1 (0..31) */
NS_VAL	tRAS,	36, 1, 31		/* clks - 1 (0..31) */
CK_VAL	tRPA,	0, 0, 1			/* clks     (0..1) */
NS_VAL	tWR,	15, 1, 15		/* clks - 1 (0..15) */
CK_VAL	tMRD,	4, 1, 15		/* clks - 1 (0..15) */
CK_VAL	tCWL,	5, 2, 6			/* clks - 2 (0..6) */

/* ESDCFG2 0x14 */
CK_VAL	tDLLK,	512, 1, 511		/* clks - 1 (0..511) */
CK_MAX	tRTP,	4, NS_TO_CK(8), 1, 7	/* clks - 1 (0..7) */
CK_MAX	tWTR,	4, NS_TO_CK(8), 1, 7	/* clks - 1 (0..7) */
CK_MAX	tRRD,	4, NS_TO_CK(8), 1, 7	/* clks - 1 (0..7) */

/* ESDOR 0x30 */
CK_MAX	tXPR,	NS_TO_CK(CK_TO_NS(tRFC + 1) + 10), 5, 1, 255 /* clks - 1 (0..255) max(tRFC + 10, 5CK) */

/* ESDOTC 0x08 */
NS_VAL	tAOFPD,	9, 1, 7			/* clks - 1 (0..7) */
NS_VAL	tAONPD,	9, 1, 7			/* clks - 1 (0..7) */
CK_VAL	tANPD,	tCWL, 1, 15		/* clks - 1 (0..15) */
CK_VAL	tAXPD,	tCWL, 1, 15		/* clks - 1 (0..15) */
CK_VAL	tODTLon	tCWL - 1, 1, 7		/* clks - 1 (0..7) */
CK_VAL	tODTLoff tCWL - 1, 1, 31	/* clks - 1 (0..31) */

#define tSDE_RST			(DIV_ROUND_UP(200000, ESDOR_CLK_PERIOD_ns) + 1)

					/* Add an extra (or two?) ESDOR_CLK_PERIOD_ns according to
					 * erroneous Erratum Engcm12377
					 */
#define tRST_CKE			(DIV_ROUND_UP(500000 + 2 * ESDOR_CLK_PERIOD_ns, ESDOR_CLK_PERIOD_ns) + 1)

#define ROW_ADDR_BITS			14
#define COL_ADDR_BITS			10

	.iflt	tWR - 7
	.set	mrs_val, (0x8080 | \
			(3 << 4) /* MRS command */ | \
			((1 << 8) /* DLL Reset */ | \
			((tWR + 1 - 4) << 9) | \
			(((tCL + 3) - 4) << 4)) << 16)
	.else
	.set	mrs_val, (0x8080 | \
			(3 << 4) /* MRS command */ | \
			((1 << 8) /* DLL Reset */ | \
			(((tWR + 1) / 2) << 9) | \
			(((tCL + 3) - 4) << 4)) << 16)
	.endif
#define ESDSCR_MRS_VAL(cs)	(mrs_val | ((cs) << 3))

#define ESDCFG0_VAL	(		\
	(tRFC << 24) |			\
	(tXS << 16) |			\
	(tXP << 13) |			\
	(tXPDLL << 9) |			\
	(tFAW << 4) |			\
	(tCL << 0))			\

#define ESDCFG1_VAL	(		\
	(tRCD << 29) |			\
	(tRP << 26) |			\
	(tRC << 21) |			\
	(tRAS << 16) |			\
	(tRPA << 15) |			\
	(tWR << 9) |			\
	(tMRD << 5) |			\
	(tCWL << 0))			\

#define ESDCFG2_VAL	(		\
	(tDLLK << 16) |			\
	(tRTP << 6) |			\
	(tWTR << 3) |			\
	(tRRD << 0))

#define BURST_LEN			(SDRAM_BURST_LENGTH / 8) /* 0: 4 byte 1: 8 byte */
#define ESDCTL_VAL			(((ROW_ADDR_BITS - 11) << 24) | \
					((COL_ADDR_BITS - 9) << 20) | \
					(BURST_LEN << 19) | \
					(1 << 16) | /* SDRAM bus width */ \
					((-1) << (32 - BANK_ADDR_BITS)))

#define ESDMISC_VAL			((1 << 12) | \
					(0x3 << 9) | \
					(RALAT << 6) | \
					(WALAT << 16) | \
					(ADDR_MIRROR << 19) | \
					(DDR_TYPE << 3))

#define ESDOR_VAL		((tXPR << 16) | (tSDE_RST << 8) | (tRST_CKE << 0))

#define ESDOTC_VAL		((tAOFPD << 27) |	\
				(tAONPD << 24) |	\
				(tANPD << 20) |		\
				(tAXPD << 16) |		\
				(tODTLon << 12) |	\
				(tODTLoff << 4))

fcb_start:
	b	_start
	.word	0x20424346	/* "FCB " marker */
	.word	0x01	/* FCB version number */
	.org	0x68
	.word	0x0	/* primary image starting page number */
	.word	0x0	/* secondary image starting page number */
	.word	0x6b
	.word	0x6b
	.word	0x0	/* DBBT start page (0 == NO DBBT) */
	.word	0	/* Bad block marker offset in main area (unused) */
	.org	0xac
	.word	0	/* BI Swap disabled */
	.word	0	/* Bad Block marker offset in spare area */
fcb_end:

	.org	0x400
ivt_header:
	.word	CPU_2_BE_32((0xd1 << 24) | (32 << 8) | 0x40)
app_start_addr:
	.long	_start
	.long	0x0
dcd_ptr:
	.long	dcd_hdr
boot_data_ptr:
	.word	boot_data
self_ptr:
	.word	ivt_header
app_code_csf:
	.word	0x0
	.word	0x0
boot_data:
	.long	fcb_start
image_len:
	.long	CONFIG_U_BOOT_IMG_SIZE
plugin:
	.word	0
ivt_end:
#define DCD_VERSION	0x40

dcd_hdr:
	.word	CPU_2_BE_32((0xd2 << 24) | ((dcd_end - .) << 8) | DCD_VERSION)
dcd_start:
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, zq_calib)
	/* disable all irrelevant clocks */
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR0, 0xffcf0fff)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR1, 0x000fffc3)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR2, 0x033c0000)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR3, 0x000000ff)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR4, 0x00000000)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR5, 0x00fff033)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR6, 0x0f00030f)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CCGR7, 0xfff00000)
	MXC_DCD_ITEM(CCM_BASE_ADDR + REG_CMEOR, 0x00000000)

	MXC_DCD_ITEM(IOMUXC_BASE_ADDR + 0x340, 0x11)	/* GPIO_17 => RESET_OUT */

	MXC_DCD_ITEM(0x63fd800c, 0x00000000)	/* M4IF: MUX NFC signals on WEIM */
#if SDRAM_CLK > 333
	MXC_DCD_ITEM(0x53fd4014, 0x00888944)	/* CBCDR */
#else
	MXC_DCD_ITEM(0x53fd4014, 0x00888644)	/* CBCDR */
#endif
	MXC_DCD_ITEM(0x53fd4018, 0x00016154)	/* CBCMR */

	MXC_DCD_ITEM(0x53fd401c, 0xa6a2a020)	/* CSCMR1 */
	MXC_DCD_ITEM(0x53fd4020, 0xb6b12f0a)	/* CSCMR2 */
	MXC_DCD_ITEM(0x53fd4024, 0x00080b18)	/* CSCDR1 */

#define DDR_SEL_VAL	2
#define DSE_VAL		5
#define ODT_VAL		2

#define DDR_SEL_SHIFT	25
#define ODT_SHIFT	22
#define DSE_SHIFT	19
#define DDR_INPUT_SHIFT	9
#define HYS_SHIFT	8
#define PKE_SHIFT	7
#define PUE_SHIFT	6
#define PUS_SHIFT	4

#define DDR_SEL_MASK	(DDR_SEL_VAL << DDR_SEL_SHIFT)
#define DSE_MASK	(DSE_VAL << DSE_SHIFT)
#define ODT_MASK	(ODT_VAL << ODT_SHIFT)

#define DQM_VAL		DSE_MASK
#define SDQS_VAL	(ODT_MASK | DSE_MASK | (1 << PUE_SHIFT))
#define SDODT_VAL	(DSE_MASK | (0 << PKE_SHIFT) | (1 << PUE_SHIFT) | (0 << PUS_SHIFT))
#define SDCLK_VAL	DSE_MASK
#define SDCKE_VAL	((1 << PKE_SHIFT) | (1 << PUE_SHIFT) | (0 << PUS_SHIFT))

	MXC_DCD_ITEM(0x53fa8724, DDR_SEL_MASK) /* DDR_TYPE: DDR3 */
	MXC_DCD_ITEM(0x53fa86f4, 0 << DDR_INPUT_SHIFT) /* DDRMODE_CTL */
	MXC_DCD_ITEM(0x53fa8714, 0 << DDR_INPUT_SHIFT) /* GRP_DDRMODE */
	MXC_DCD_ITEM(0x53fa86fc, 1 << PKE_SHIFT) /* GRP_DDRPKE */
	MXC_DCD_ITEM(0x53fa8710, 0 << HYS_SHIFT) /* GRP_DDRHYS */
	MXC_DCD_ITEM(0x53fa8708, 1 << PUE_SHIFT) /* GRP_DDRPK */

	MXC_DCD_ITEM(0x53fa8584, DQM_VAL) /* DQM0 */
	MXC_DCD_ITEM(0x53fa8594, DQM_VAL) /* DQM1 */
	MXC_DCD_ITEM(0x53fa8560, DQM_VAL) /* DQM2 */
	MXC_DCD_ITEM(0x53fa8554, DQM_VAL) /* DQM3 */

	MXC_DCD_ITEM(0x53fa857c, SDQS_VAL) /* SDQS0 */
	MXC_DCD_ITEM(0x53fa8590, SDQS_VAL) /* SDQS1 */
	MXC_DCD_ITEM(0x53fa8568, SDQS_VAL) /* SDQS2 */
	MXC_DCD_ITEM(0x53fa8558, SDQS_VAL) /* SDQS3 */

	MXC_DCD_ITEM(0x53fa8580, SDODT_VAL) /* SDODT0 */
	MXC_DCD_ITEM(0x53fa8578, SDCLK_VAL) /* SDCLK0 */

	MXC_DCD_ITEM(0x53fa8564, SDODT_VAL) /* SDODT1 */
	MXC_DCD_ITEM(0x53fa8570, SDCLK_VAL) /* SDCLK1 */

	MXC_DCD_ITEM(0x53fa858c, SDCKE_VAL) /* SDCKE0 */
	MXC_DCD_ITEM(0x53fa855c, SDCKE_VAL) /* SDCKE1 */

	MXC_DCD_ITEM(0x53fa8574, DSE_MASK) /* DRAM_CAS */
	MXC_DCD_ITEM(0x53fa8588, DSE_MASK) /* DRAM_RAS */

	MXC_DCD_ITEM(0x53fa86f0, DSE_MASK) /* GRP_ADDDS */
	MXC_DCD_ITEM(0x53fa8720, DSE_MASK) /* GRP_CTLDS */
	MXC_DCD_ITEM(0x53fa8718, DSE_MASK) /* GRP_B0DS */
	MXC_DCD_ITEM(0x53fa871c, DSE_MASK) /* GRP_B1DS */
	MXC_DCD_ITEM(0x53fa8728, DSE_MASK) /* GRP_B2DS */
	MXC_DCD_ITEM(0x53fa872c, DSE_MASK) /* GRP_B3DS */

	/* calibration defaults */
	MXC_DCD_ITEM(0x63fd904c, 0x001f001f)
	MXC_DCD_ITEM(0x63fd9050, 0x001f001f)
	MXC_DCD_ITEM(0x63fd907c, 0x011e011e)
	MXC_DCD_ITEM(0x63fd9080, 0x011f0120)
	MXC_DCD_ITEM(0x63fd9088, 0x3a393d3b)
	MXC_DCD_ITEM(0x63fd9090, 0x3f3f3f3f)

	MXC_DCD_ITEM(0x63fd9018, ESDMISC_VAL)
	MXC_DCD_ITEM(0x63fd9000, ESDCTL_VAL)
	MXC_DCD_ITEM(0x63fd900c, ESDCFG0_VAL)
	MXC_DCD_ITEM(0x63fd9010, ESDCFG1_VAL)
	MXC_DCD_ITEM(0x63fd9014, ESDCFG2_VAL)

	MXC_DCD_ITEM(0x63fd902c, 0x000026d2)
	MXC_DCD_ITEM(0x63fd9030, ESDOR_VAL)
	MXC_DCD_ITEM(0x63fd9008, ESDOTC_VAL)
	MXC_DCD_ITEM(0x63fd9004, 0x00030012)

	/* MR0 - CS0 */
	MXC_DCD_ITEM(0x63fd901c, 0x00008032) /* MRS: MR2 */
	MXC_DCD_ITEM(0x63fd901c, 0x00008033) /* MRS: MR3 */
	MXC_DCD_ITEM(0x63fd901c, 0x00408031) /* MRS: MR1 */
	MXC_DCD_ITEM(0x63fd901c, ESDSCR_MRS_VAL(0)) /* MRS: MR0 */
	/* MR0 - CS1 */
#if BANK_ADDR_BITS > 1
	MXC_DCD_ITEM(0x63fd901c, 0x0000803a) /* MRS: MR2 */
	MXC_DCD_ITEM(0x63fd901c, 0x0000803b) /* MRS: MR3 */
	MXC_DCD_ITEM(0x63fd901c, 0x00408039) /* MRS: MR1 */
	MXC_DCD_ITEM(0x63fd901c, ESDSCR_MRS_VAL(1)) /* MRS: MR0 */
#endif
	MXC_DCD_ITEM(0x63fd9020, 0x00005800) /* refresh interval */
	MXC_DCD_ITEM(0x63fd9058, 0x00011112)

	MXC_DCD_ITEM(0x63fd90d0, 0x00000003) /* select default compare pattern for calibration */

	/* ZQ calibration */
	MXC_DCD_ITEM(0x63fd901c, 0x04008010) /* precharge all */
	MXC_DCD_ITEM(0x63fd901c, 0x00008040) /* MRS: ZQ calibration */
	MXC_DCD_ITEM(0x63fd9040, 0x0539002b) /* Force ZQ calibration */
zq_calib:
	MXC_DCD_CMD_CHK(MXC_DCD_CMD_SZ_WORD, 0, 0x63fd9040, 0x00010000)
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, wl_calib)

	/* Write Leveling */
	MXC_DCD_ITEM(0x63fd901c, 0x00048033) /* MRS: select MPR */
	MXC_DCD_ITEM(0x63fd901c, 0x00848231) /* MRS: start write leveling */
	MXC_DCD_ITEM(0x63fd901c, 0x00000000)
	MXC_DCD_ITEM(0x63fd9048, 0x00000001)
wl_calib:
	MXC_DCD_CMD_CHK(MXC_DCD_CMD_SZ_WORD, 0, 0x63fd9048, 0x00000001)
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, dqs_calib)
	MXC_DCD_ITEM(0x63fd901c, 0x00048031) /* MRS: end write leveling */
	MXC_DCD_ITEM(0x63fd901c, 0x00008033) /* MRS: select normal data path */

	/* DQS calibration */
	MXC_DCD_ITEM(0x63fd901c, 0x04008010) /* precharge all */
	MXC_DCD_ITEM(0x63fd901c, 0x00048033) /* MRS: select MPR */
	MXC_DCD_ITEM(0x63fd907c, 0x90000000) /* reset RD fifo and start DQS calib. */
dqs_calib:
	MXC_DCD_CMD_CHK(MXC_DCD_CMD_SZ_WORD, 0, 0x63fd907c, 0x90000000)
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, wr_dl_calib)
	MXC_DCD_ITEM(0x63fd901c, 0x00008033) /* MRS: select normal data path */

	/* WR DL calibration */
	MXC_DCD_ITEM(0x63fd901c, 0x00000000)
	MXC_DCD_ITEM(0x63fd901c, 0x04008010) /* precharge all */
	MXC_DCD_ITEM(0x63fd901c, 0x00048033) /* MRS: select MPR */
	MXC_DCD_ITEM(0x63fd90a4, 0x00000010)
wr_dl_calib: /* 6c4 */
	MXC_DCD_CMD_CHK(MXC_DCD_CMD_SZ_WORD, 0, 0x63fd90a4, 0x00000010)
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, rd_dl_calib)
	MXC_DCD_ITEM(0x63fd901c, 0x00008033) /* MRS: select normal data path */

	/* RD DL calibration */
	MXC_DCD_ITEM(0x63fd901c, 0x04008010) /* precharge all */
	MXC_DCD_ITEM(0x63fd901c, 0x00048033) /* MRS: select MPR */
	MXC_DCD_ITEM(0x63fd90a0, 0x00000010)
rd_dl_calib: /* 70c */
	MXC_DCD_CMD_CHK(MXC_DCD_CMD_SZ_WORD, 0, 0x63fd90a0, 0x00000010)
	MXC_DCD_CMD_WRT(MXC_DCD_CMD_SZ_WORD, MXC_DCD_CMD_FLAG_WRITE, dcd_end)
	MXC_DCD_ITEM(0x63fd901c, 0x00008033) /* MRS: select normal data path */

	MXC_DCD_ITEM(0x63fd901c, 0x00000000)

	MXC_DCD_ITEM(0x53fa8004, 0x00194005)	@ set LDO to 1.3V

	/* setup NFC pads */
	/* MUX_SEL */
	MXC_DCD_ITEM(0x53fa819c, 0x00000000)	@ EIM_DA0
	MXC_DCD_ITEM(0x53fa81a0, 0x00000000)	@ EIM_DA1
	MXC_DCD_ITEM(0x53fa81a4, 0x00000000)	@ EIM_DA2
	MXC_DCD_ITEM(0x53fa81a8, 0x00000000)	@ EIM_DA3
	MXC_DCD_ITEM(0x53fa81ac, 0x00000000)	@ EIM_DA4
	MXC_DCD_ITEM(0x53fa81b0, 0x00000000)	@ EIM_DA5
	MXC_DCD_ITEM(0x53fa81b4, 0x00000000)	@ EIM_DA6
	MXC_DCD_ITEM(0x53fa81b8, 0x00000000)	@ EIM_DA7
	MXC_DCD_ITEM(0x53fa81dc, 0x00000000)	@ WE_B
	MXC_DCD_ITEM(0x53fa81e0, 0x00000000)	@ RE_B
	MXC_DCD_ITEM(0x53fa8228, 0x00000000)	@ CLE
	MXC_DCD_ITEM(0x53fa822c, 0x00000000)	@ ALE
	MXC_DCD_ITEM(0x53fa8230, 0x00000000)	@ WP_B
	MXC_DCD_ITEM(0x53fa8234, 0x00000000)	@ RB0
	MXC_DCD_ITEM(0x53fa8238, 0x00000000)	@ CS0
	/* PAD_CTL */
	MXC_DCD_ITEM(0x53fa84ec, 0x000000e4)	@ EIM_DA0
	MXC_DCD_ITEM(0x53fa84f0, 0x000000e4)	@ EIM_DA1
	MXC_DCD_ITEM(0x53fa84f4, 0x000000e4)	@ EIM_DA2
	MXC_DCD_ITEM(0x53fa84f8, 0x000000e4)	@ EIM_DA3
	MXC_DCD_ITEM(0x53fa84fc, 0x000000e4)	@ EIM_DA4
	MXC_DCD_ITEM(0x53fa8500, 0x000000e4)	@ EIM_DA5
	MXC_DCD_ITEM(0x53fa8504, 0x000000e4)	@ EIM_DA6
	MXC_DCD_ITEM(0x53fa8508, 0x000000e4)	@ EIM_DA7
	MXC_DCD_ITEM(0x53fa852c, 0x00000004)	@ NANDF_WE_B
	MXC_DCD_ITEM(0x53fa8530, 0x00000004)	@ NANDF_RE_B
	MXC_DCD_ITEM(0x53fa85a0, 0x00000004)	@ NANDF_CLE_B
	MXC_DCD_ITEM(0x53fa85a4, 0x00000004)	@ NANDF_ALE_B
	MXC_DCD_ITEM(0x53fa85a8, 0x000000e4)	@ NANDF_WE_B
	MXC_DCD_ITEM(0x53fa85ac, 0x000000e4)	@ NANDF_RB0
	MXC_DCD_ITEM(0x53fa85b0, 0x00000004)	@ NANDF_CS0
dcd_end:
	.ifgt	dcd_end - dcd_start - 1768
	DCD too large!
	.endif
