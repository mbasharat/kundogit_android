/*
 * (C) Copyright 2009
 * Stefano Babic, DENX Software Engineering, sbabic@denx.de.
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#ifndef _SYS_PROTO_H_
#define _SYS_PROTO_H_

#define MXC_CPU_MX51		0x51
#define MXC_CPU_MX53		0x53
#define MXC_CPU_MX6SL		0x60
#define MXC_CPU_MX6DL		0x61
#define MXC_CPU_MX6SOLO		0x62
#define MXC_CPU_MX6Q		0x63

#define is_soc_rev(rev)	((get_cpu_rev() & 0xFF) - rev)
u32 get_cpu_rev(void);
const char *get_imx_type(u32 imxtype);
unsigned imx_ddr_size(void);


struct mx6_register_32;

int mxs_reset_block(struct mx6_register_32 *reg);
int mxs_wait_mask_set(struct mx6_register_32 *reg,
		       uint32_t mask,
		       unsigned long timeout);
int mxs_wait_mask_clr(struct mx6_register_32 *reg,
		       uint32_t mask,
		       unsigned long timeout);

void imx_get_mac_from_fuse(int dev_id, unsigned char *mac);

/*
 * Initializes on-chip ethernet controllers.
 * to override, implement board_eth_init()
 */

int fecmxc_initialize(bd_t *bis);
u32 get_ahb_clk(void);
u32 get_periph_clk(void);
#endif
