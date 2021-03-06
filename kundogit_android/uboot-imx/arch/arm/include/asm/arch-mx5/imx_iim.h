/*
 * (C) Copyright 2009-2010 Freescale Semiconductor, Inc.
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

#ifndef __IMX_IIM_H__
#define __IMX_IIM_H__

/* IIM Status & Error Register bits */
#define IIM_STAT_BUSY	(1 << 7)
#define IIM_STAT_PRGD	(1 << 1)
#define IIM_STAT_SNSD	(1 << 0)

#define IIM_ERR_PRGE	(1 << 7)
#define IIM_ERR_WPE	(1 << 6)
#define IIM_ERR_OPE	(1 << 5)
#define IIM_ERR_RPE	(1 << 4)
#define IIM_ERR_WLRE	(1 << 3)
#define IIM_ERR_SNSE	(1 << 2)
#define IIM_ERR_PARITYE	(1 << 1)

#define IIM_PROD_REV_SH		3
#define IIM_PROD_REV_LEN	5
#define IIM_SREV_REV_SH		4
#define IIM_SREV_REV_LEN	4
#define PROD_SIGNATURE_MX51	0x1

#define IIM_ERR_SHIFT	8
#define POLL_FUSE_PRGD	(IIM_STAT_PRGD | (IIM_ERR_PRGE << IIM_ERR_SHIFT))
#define POLL_FUSE_SNSD	(IIM_STAT_SNSD | (IIM_ERR_SNSE << IIM_ERR_SHIFT))

#define IIM_BANK_AREA_0_OFFSET	0x800
#define IIM_BANK_AREA_1_OFFSET	0xc00
#define IIM_BANK_AREA_2_OFFSET	0x1000
#define IIM_BANK_AREA_3_OFFSET	0x1400

int iim_read(int bank, char row);
int iim_blow(int bank, int row, int val);
int iim_blow_func(char *func_name, char *func_val);

#endif
