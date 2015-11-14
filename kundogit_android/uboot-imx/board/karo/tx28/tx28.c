/*
 * Copyright (C) 2011 Lothar Waßmann <LW@KARO-electronics.de>
 * based on: board/freesclae/mx28_evk.c (C) 2010 Freescale Semiconductor, Inc.
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

#include <common.h>
#include <errno.h>
#include <libfdt.h>
#include <fdt_support.h>
#include <lcd.h>
#include <netdev.h>
#include <mmc.h>
#include <imx_ssp_mmc.h>
#include <linux/list.h>
#include <linux/fb.h>
#include <asm/io.h>
#include <asm/gpio.h>
#include <asm/arch/iomux-mx28.h>
#include <asm/arch/clock.h>
#include <asm/arch/mxsfb.h>
#include <asm/arch/imx-regs.h>
#include <asm/arch/sys_proto.h>

#include "../common/karo.h"

DECLARE_GLOBAL_DATA_PTR;

#define MXS_GPIO_NR(p, o)      (((p) << 5) | (o))

#define TX28_LCD_PWR_GPIO	MX28_PAD_LCD_ENABLE__GPIO_1_31
#define TX28_LCD_RST_GPIO	MX28_PAD_LCD_RESET__GPIO_3_30
#define TX28_LCD_BACKLIGHT_GPIO	MX28_PAD_PWM0__GPIO_3_16

#define TX28_USBH_VBUSEN_GPIO	MX28_PAD_SPDIF__GPIO_3_27
#define TX28_USBH_OC_GPIO	MX28_PAD_JTAG_RTCK__GPIO_4_20
#define TX28_USBOTG_VBUSEN_GPIO	MX28_PAD_GPMI_CE2N__GPIO_0_18
#define TX28_USBOTG_OC_GPIO	MX28_PAD_GPMI_CE3N__GPIO_0_19
#define TX28_USBOTG_ID_GPIO	MX28_PAD_PWM2__GPIO_3_18

#define TX28_LED_GPIO		MX28_PAD_ENET0_RXD3__GPIO_4_10

static const struct gpio tx28_gpios[] = {
	{ TX28_USBH_VBUSEN_GPIO, GPIOF_OUTPUT_INIT_LOW, "USBH VBUSEN", },
	{ TX28_USBH_OC_GPIO, GPIOF_INPUT, "USBH OC", },
	{ TX28_USBOTG_VBUSEN_GPIO, GPIOF_OUTPUT_INIT_LOW, "USBOTG VBUSEN", },
	{ TX28_USBOTG_OC_GPIO, GPIOF_INPUT, "USBOTG OC", },
	{ TX28_USBOTG_ID_GPIO, GPIOF_INPUT, "USBOTG ID", },
};

static const iomux_cfg_t tx28_pads[] = {
	/* UART pads */
#if CONFIG_CONS_INDEX == 0
	MX28_PAD_AUART0_RX__DUART_CTS,
	MX28_PAD_AUART0_TX__DUART_RTS,
	MX28_PAD_AUART0_CTS__DUART_RX,
	MX28_PAD_AUART0_RTS__DUART_TX,
#elif CONFIG_CONS_INDEX == 1
	MX28_PAD_AUART1_RX__AUART1_RX,
	MX28_PAD_AUART1_TX__AUART1_TX,
	MX28_PAD_AUART1_CTS__AUART1_CTS,
	MX28_PAD_AUART1_RTS__AUART1_RTS,
#elif CONFIG_CONS_INDEX == 2
	MX28_PAD_AUART3_RX__AUART3_RX,
	MX28_PAD_AUART3_TX__AUART3_TX,
	MX28_PAD_AUART3_CTS__AUART3_CTS,
	MX28_PAD_AUART3_RTS__AUART3_RTS,
#endif
	/* I2C bus for internal DS1339, PCA9554 and on DIMM pins 40/41 */
	MX28_PAD_I2C0_SCL__I2C0_SCL,
	MX28_PAD_I2C0_SDA__I2C0_SDA,

	/* USBH VBUSEN, OC */
	MX28_PAD_SPDIF__GPIO_3_27,
	MX28_PAD_JTAG_RTCK__GPIO_4_20,

	/* USBOTG VBUSEN, OC, ID */
	MX28_PAD_GPMI_CE2N__GPIO_0_18,
	MX28_PAD_GPMI_CE3N__GPIO_0_19,
	MX28_PAD_PWM2__GPIO_3_18,
};

/*
 * Functions
 */
int board_early_init_f(void)
{
	/* IO0 clock at 480MHz */
	mx28_set_ioclk(MXC_IOCLK0, 480000);
	/* IO1 clock at 480MHz */
	mx28_set_ioclk(MXC_IOCLK1, 480000);

	/* SSP0 clock at 96MHz */
	mx28_set_sspclk(MXC_SSPCLK0, 96000, 0);
	/* SSP2 clock at 96MHz */
	mx28_set_sspclk(MXC_SSPCLK2, 96000, 0);

	gpio_request_array(tx28_gpios, ARRAY_SIZE(tx28_gpios));
	mxs_iomux_setup_multiple_pads(tx28_pads, ARRAY_SIZE(tx28_pads));
	return 0;
}

int board_init(void)
{
	/* Address of boot parameters */
	gd->bd->bi_boot_params = PHYS_SDRAM_1 + 0x1000;
	return 0;
}

int dram_init(void)
{
	return mxs_dram_init();
}

#ifdef	CONFIG_CMD_MMC
static int tx28_mmc_wp(int dev_no)
{
	return 0;
}

int board_mmc_init(bd_t *bis)
{
	return mxsmmc_initialize(bis, 0, tx28_mmc_wp);
}
#endif /* CONFIG_CMD_MMC */

#ifdef CONFIG_FEC_MXC
#ifdef CONFIG_GET_FEC_MAC_ADDR_FROM_IIM

#ifdef CONFIG_FEC_MXC_MULTI
#define FEC_MAX_IDX			1
#else
#define FEC_MAX_IDX			0
#endif

static int fec_get_mac_addr(int index)
{
	u32 val1, val2;
	int timeout = 1000;
	struct mxs_ocotp_regs *ocotp_regs =
		(struct mxs_ocotp_regs *)MXS_OCOTP_BASE;
	u32 *cust = &ocotp_regs->hw_ocotp_cust0;
	char mac[6 * 3];
	char env_name[] = "eth.addr";

	if (index < 0 || index > FEC_MAX_IDX)
		return -EINVAL;

	/* set this bit to open the OTP banks for reading */
	writel(OCOTP_CTRL_RD_BANK_OPEN,
		&ocotp_regs->hw_ocotp_ctrl_set);

	/* wait until OTP contents are readable */
	while (OCOTP_CTRL_BUSY & readl(&ocotp_regs->hw_ocotp_ctrl)) {
		if (timeout-- < 0)
			return -ETIMEDOUT;
		udelay(100);
	}

	val1 = readl(&cust[index * 8]);
	val2 = readl(&cust[index * 8 + 4]);
	if ((val1 | val2) == 0)
		return 0;
	snprintf(mac, sizeof(mac), "%02x:%02x:%02x:%02x:%02x:%02x",
		(val1 >> 24) & 0xFF, (val1 >> 16) & 0xFF,
		(val1 >> 8) & 0xFF, (val1 >> 0) & 0xFF,
		(val2 >> 24) & 0xFF, (val2 >> 16) & 0xFF);
	if (index == 0)
		snprintf(env_name, sizeof(env_name), "ethaddr");
	else
		snprintf(env_name, sizeof(env_name), "eth%daddr", index);

	setenv(env_name, mac);
	return 0;
}
#endif /* CONFIG_GET_FEC_MAC_ADDR_FROM_IIM */

static const iomux_cfg_t tx28_fec_pads[] = {
	MX28_PAD_ENET0_RX_EN__ENET0_RX_EN,
	MX28_PAD_ENET0_RXD0__ENET0_RXD0,
	MX28_PAD_ENET0_RXD1__ENET0_RXD1,
};

int board_eth_init(bd_t *bis)
{
	int ret;

	/* Reset the external phy */
	gpio_direction_output(MX28_PAD_ENET0_RX_CLK__GPIO_4_13, 0);

	/* Power on the external phy */
	gpio_direction_output(MX28_PAD_PWM4__GPIO_3_29, 1);

	/* Pull strap pins to high */
	gpio_direction_output(MX28_PAD_ENET0_RX_EN__GPIO_4_2, 1);
	gpio_direction_output(MX28_PAD_ENET0_RXD0__GPIO_4_3, 1);
	gpio_direction_output(MX28_PAD_ENET0_RXD1__GPIO_4_4, 1);
	gpio_direction_input(MX28_PAD_ENET0_TX_CLK__GPIO_4_5);

	udelay(25000);
	gpio_set_value(MX28_PAD_ENET0_RX_CLK__GPIO_4_13, 1);
	udelay(100);

	mxs_iomux_setup_multiple_pads(tx28_fec_pads, ARRAY_SIZE(tx28_fec_pads));

	ret = cpu_eth_init(bis);
	if (ret) {
		printf("cpu_eth_init() failed: %d\n", ret);
		return ret;
	}

	ret = fec_get_mac_addr(0);
	if (ret < 0) {
		printf("Failed to read FEC0 MAC address from OCOTP\n");
		return ret;
	}
#ifdef CONFIG_FEC_MXC_MULTI
	if (getenv("ethaddr")) {
		ret = fecmxc_initialize_multi(bis, 0, 0, MXS_ENET0_BASE);
		if (ret) {
			printf("FEC MXS: Unable to init FEC0\n");
			return ret;
		}
	}

	ret = fec_get_mac_addr(1);
	if (ret < 0) {
		printf("Failed to read FEC1 MAC address from OCOTP\n");
		return ret;
	}
	if (getenv("eth1addr")) {
		ret = fecmxc_initialize_multi(bis, 1, 1, MXS_ENET1_BASE);
		if (ret) {
			printf("FEC MXS: Unable to init FEC1\n");
			return ret;
		}
	}
	return 0;
#else
	if (getenv("ethaddr")) {
		ret = fecmxc_initialize(bis);
	}
	return ret;
#endif
}
#endif /* CONFIG_FEC_MXC */

enum {
	LED_STATE_INIT = -1,
	LED_STATE_OFF,
	LED_STATE_ON,
};

void show_activity(int arg)
{
	static int led_state = LED_STATE_INIT;
	static ulong last;

	if (led_state == LED_STATE_INIT) {
		last = get_timer(0);
		gpio_set_value(TX28_LED_GPIO, 1);
		led_state = LED_STATE_ON;
	} else {
		if (get_timer(last) > CONFIG_SYS_HZ) {
			last = get_timer(0);
			if (led_state == LED_STATE_ON) {
				gpio_set_value(TX28_LED_GPIO, 0);
			} else {
				gpio_set_value(TX28_LED_GPIO, 1);
			}
			led_state = 1 - led_state;
		}
	}
}

static const iomux_cfg_t stk5_pads[] = {
	/* SW controlled LED on STK5 baseboard */
	MX28_PAD_ENET0_RXD3__GPIO_4_10,
};

static const struct gpio stk5_gpios[] = {
};

#ifdef CONFIG_LCD
static struct fb_videomode tx28_fb_modes[] = {
	{
		/* Standard VGA timing */
		.name		= "VGA",
		.refresh	= 60,
		.xres		= 640,
		.yres		= 480,
		.pixclock	= KHZ2PICOS(25175),
		.left_margin	= 48,
		.hsync_len	= 96,
		.right_margin	= 16,
		.upper_margin	= 31,
		.vsync_len	= 2,
		.lower_margin	= 12,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ETV570 640 x 480 display. Syncs low active,
		 * DE high active, 115.2 mm x 86.4 mm display area
		 * VGA compatible timing
		 */
		.name		= "ETV570",
		.refresh	= 60,
		.xres		= 640,
		.yres		= 480,
		.pixclock	= KHZ2PICOS(25175),
		.left_margin	= 114,
		.hsync_len	= 30,
		.right_margin	= 16,
		.upper_margin	= 32,
		.vsync_len	= 3,
		.lower_margin	= 10,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ET0350G0DH6 320 x 240 display.
		 * 70.08 mm x 52.56 mm display area.
		 */
		.name		= "ET0350",
		.refresh	= 60,
		.xres		= 320,
		.yres		= 240,
		.pixclock	= KHZ2PICOS(6500),
		.left_margin	= 68 - 34,
		.hsync_len	= 34,
		.right_margin	= 20,
		.upper_margin	= 18 - 3,
		.vsync_len	= 3,
		.lower_margin	= 4,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ET0430G0DH6 480 x 272 display.
		 * 95.04 mm x 53.856 mm display area.
		 */
		.name		= "ET0430",
		.refresh	= 60,
		.xres		= 480,
		.yres		= 272,
		.pixclock	= KHZ2PICOS(9000),
		.left_margin	= 2,
		.hsync_len	= 41,
		.right_margin	= 2,
		.upper_margin	= 2,
		.vsync_len	= 10,
		.lower_margin	= 2,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ET0500G0DH6 800 x 480 display.
		 * 109.6 mm x 66.4 mm display area.
		 */
		.name		= "ET0500",
		.refresh	= 60,
		.xres		= 800,
		.yres		= 480,
		.pixclock	= KHZ2PICOS(33260),
		.left_margin	= 216 - 128,
		.hsync_len	= 128,
		.right_margin	= 1056 - 800 - 216,
		.upper_margin	= 35 - 2,
		.vsync_len	= 2,
		.lower_margin	= 525 - 480 - 35,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ETQ570G0DH6 320 x 240 display.
		 * 115.2 mm x 86.4 mm display area.
		 */
		.name		= "ETQ570",
		.refresh	= 60,
		.xres		= 320,
		.yres		= 240,
		.pixclock	= KHZ2PICOS(6400),
		.left_margin	= 38,
		.hsync_len	= 30,
		.right_margin	= 30,
		.upper_margin	= 16, /* 15 according to datasheet */
		.vsync_len	= 3, /* TVP -> 1>x>5 */
		.lower_margin	= 4, /* 4.5 according to datasheet */
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* Emerging ET0700G0DH6 800 x 480 display.
		 * 152.4 mm x 91.44 mm display area.
		 */
		.name		= "ET0700",
		.refresh	= 60,
		.xres		= 800,
		.yres		= 480,
		.pixclock	= KHZ2PICOS(33260),
		.left_margin	= 216 - 128,
		.hsync_len	= 128,
		.right_margin	= 1056 - 800 - 216,
		.upper_margin	= 35 - 2,
		.vsync_len	= 2,
		.lower_margin	= 525 - 480 - 35,
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
	{
		/* unnamed entry for assigning parameters parsed from 'video_mode' string */
		.sync		= FB_SYNC_DATA_ENABLE_HIGH_ACT,
		.vmode		= FB_VMODE_NONINTERLACED,
	},
};

static int lcd_enabled = 1;

void lcd_enable(void)
{
	/* HACK ALERT:
	 * global variable from common/lcd.c
	 * Set to 0 here to prevent messages from going to LCD
	 * rather than serial console
	 */
	lcd_is_enabled = 0;

	karo_load_splashimage(1);
	if (lcd_enabled) {
		debug("Switching LCD on\n");
		gpio_set_value(TX28_LCD_PWR_GPIO, 1);
		udelay(100);
		gpio_set_value(TX28_LCD_RST_GPIO, 1);
		udelay(300000);
		gpio_set_value(TX28_LCD_BACKLIGHT_GPIO, 0);
	}
}

void lcd_disable(void)
{
	mxsfb_disable();
}

void lcd_panel_disable(void)
{
	if (lcd_enabled) {
		debug("Switching LCD off\n");
		gpio_set_value(TX28_LCD_BACKLIGHT_GPIO, 1);
		gpio_set_value(TX28_LCD_RST_GPIO, 0);
		gpio_set_value(TX28_LCD_PWR_GPIO, 0);
	}
}

static const iomux_cfg_t stk5_lcd_pads[] = {
	/* LCD RESET */
	MX28_PAD_LCD_RESET__GPIO_3_30 | MXS_PAD_CTRL,
	/* LCD POWER_ENABLE */
	MX28_PAD_LCD_ENABLE__GPIO_1_31 | MXS_PAD_CTRL,
	/* LCD Backlight (PWM) */
	MX28_PAD_PWM0__GPIO_3_16 | MXS_PAD_CTRL,

	/* Display */
	MX28_PAD_LCD_D00__LCD_D0 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D01__LCD_D1 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D02__LCD_D2 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D03__LCD_D3 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D04__LCD_D4 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D05__LCD_D5 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D06__LCD_D6 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D07__LCD_D7 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D08__LCD_D8 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D09__LCD_D9 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D10__LCD_D10 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D11__LCD_D11 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D12__LCD_D12 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D13__LCD_D13 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D14__LCD_D14 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D15__LCD_D15 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D16__LCD_D16 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D17__LCD_D17 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D18__LCD_D18 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D19__LCD_D19 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D20__LCD_D20 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D21__LCD_D21 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D22__LCD_D22 | MXS_PAD_CTRL,
	MX28_PAD_LCD_D23__LCD_D23 | MXS_PAD_CTRL,
	MX28_PAD_LCD_RD_E__LCD_VSYNC | MXS_PAD_CTRL,
	MX28_PAD_LCD_WR_RWN__LCD_HSYNC | MXS_PAD_CTRL,
	MX28_PAD_LCD_RS__LCD_DOTCLK | MXS_PAD_CTRL,
	MX28_PAD_LCD_CS__LCD_CS | MXS_PAD_CTRL,
	MX28_PAD_LCD_VSYNC__LCD_VSYNC | MXS_PAD_CTRL,
	MX28_PAD_LCD_HSYNC__LCD_HSYNC | MXS_PAD_CTRL,
	MX28_PAD_LCD_DOTCLK__LCD_DOTCLK | MXS_PAD_CTRL,
};

static const struct gpio stk5_lcd_gpios[] = {
	{ TX28_LCD_RST_GPIO, GPIOF_OUTPUT_INIT_LOW, "LCD RESET", },
	{ TX28_LCD_PWR_GPIO, GPIOF_OUTPUT_INIT_LOW, "LCD POWER", },
	{ TX28_LCD_BACKLIGHT_GPIO, GPIOF_OUTPUT_INIT_HIGH, "LCD BACKLIGHT", },
};

extern void video_hw_init(void *lcdbase);

void lcd_ctrl_init(void *lcdbase)
{
	int color_depth = 24;
	char *vm;
	unsigned long val;
	int refresh = 60;
	struct fb_videomode *p = &tx28_fb_modes[0];
	int xres_set = 0, yres_set = 0, bpp_set = 0, refresh_set = 0;

	if (!lcd_enabled) {
		debug("LCD disabled\n");
		return;
	}

	if (tstc()) {
		debug("Disabling LCD\n");
		lcd_enabled = 0;
		return;
	}

	vm = getenv("video_mode");
	if (vm == NULL) {
		debug("Disabling LCD\n");
		lcd_enabled = 0;
		return;
	}
	while (p->name != NULL) {
		if (strcmp(p->name, vm) == 0) {
			printf("Using video mode: '%s'\n", p->name);
			vm += strlen(vm);
			break;
		}
		p++;
	}

	while (*vm != '\0') {
		if (*vm >= '0' && *vm <= '9') {
			char *end;

			val = simple_strtoul(vm, &end, 0);
			if (end > vm) {
				if (!xres_set) {
					if (val > panel_info.vl_col)
						val = panel_info.vl_col;
					p->xres = val;
					xres_set = 1;
				} else if (!yres_set) {
					if (val > panel_info.vl_row)
						val = panel_info.vl_row;
					p->yres = val;
					yres_set = 1;
				} else if (!bpp_set) {
					switch (val) {
					case 8:
					case 16:
					case 18:
					case 24:
						color_depth = val;
						break;

					default:
						printf("Invalid color depth: '%.*s' in video_mode; using default: '%u'\n",
							end - vm, vm, color_depth);
					}
					bpp_set = 1;
				} else if (!refresh_set) {
					refresh = val;
					refresh_set = 1;
				}
			}
			vm = end;
		}
		switch (*vm) {
		case '@':
			bpp_set = 1;
			/* fallthru */
		case '-':
			yres_set = 1;
			/* fallthru */
		case 'x':
			xres_set = 1;
			/* fallthru */
		case 'M':
		case 'R':
			vm++;
			break;

		default:
			if (*vm != '\0')
				vm++;
		}
	}
	if (p->xres == 0 || p->yres == 0) {
		printf("Invalid video mode: %s\n", getenv("video_mode"));
		lcd_enabled = 0;
		printf("Supported video modes are:");
		for (p = &tx28_fb_modes[0]; p->name != NULL; p++) {
			printf(" %s", p->name);
		}
		printf("\n");
		return;
	}
	p->pixclock = KHZ2PICOS(refresh *
		(p->xres + p->left_margin + p->right_margin + p->hsync_len) *
		(p->yres + p->upper_margin + p->lower_margin + p->vsync_len) /
				1000);
	debug("Pixel clock set to %lu.%03lu MHz\n",
		PICOS2KHZ(p->pixclock) / 1000, PICOS2KHZ(p->pixclock) % 1000);

	gpio_request_array(stk5_lcd_gpios, ARRAY_SIZE(stk5_lcd_gpios));
	mxs_iomux_setup_multiple_pads(stk5_lcd_pads,
				ARRAY_SIZE(stk5_lcd_pads));

	debug("video format: %ux%u-%u@%u\n", p->xres, p->yres,
		color_depth, refresh);

	if (karo_load_splashimage(0) == 0) {
		debug("Initializing LCD controller\n");
		mxsfb_init(p, PIX_FMT_RGB24, color_depth);
		video_hw_init(lcdbase);
	} else {
		debug("Skipping initialization of LCD controller\n");
	}
}
#else
#define lcd_enabled 0
#endif /* CONFIG_LCD */

static void stk5_board_init(void)
{
	gpio_request_array(stk5_gpios, ARRAY_SIZE(stk5_gpios));
	mxs_iomux_setup_multiple_pads(stk5_pads, ARRAY_SIZE(stk5_pads));
}

static void stk5v3_board_init(void)
{
	stk5_board_init();
}

static void stk5v5_board_init(void)
{
	stk5_board_init();

	/* init flexcan transceiver enable GPIO */
	gpio_request_one(MXS_GPIO_NR(0, 1), GPIOF_OUTPUT_INIT_HIGH,
			"Flexcan Transceiver");
	mxs_iomux_setup_pad(MX28_PAD_LCD_D00__GPIO_1_0);
}

int board_late_init(void)
{
	const char *baseboard;

	karo_fdt_move_fdt();

	baseboard = getenv("baseboard");
	if (!baseboard)
		return 0;

	if (strncmp(baseboard, "stk5", 4) == 0) {
		printf("Baseboard: %s\n", baseboard);
		if ((strlen(baseboard) == 4) ||
			strcmp(baseboard, "stk5-v3") == 0) {
			stk5v3_board_init();
		} else if (strcmp(baseboard, "stk5-v5") == 0) {
			stk5v5_board_init();
		} else {
			printf("WARNING: Unsupported STK5 board rev.: %s\n",
				baseboard + 4);
		}
	} else {
		printf("WARNING: Unsupported baseboard: '%s'\n",
			baseboard);
		return -EINVAL;
	}

	return 0;
}

int checkboard(void)
{
	printf("Board: Ka-Ro TX28-4%sxx\n", TX28_MOD_SUFFIX);
	return 0;
}

#if defined(CONFIG_OF_BOARD_SETUP)
#ifdef CONFIG_FDT_FIXUP_PARTITIONS
#include <jffs2/jffs2.h>
#include <mtd_node.h>
struct node_info tx28_nand_nodes[] = {
	{ "gpmi-nand", MTD_DEV_TYPE_NAND, },
};
#else
#define fdt_fixup_mtdparts(b,n,c) do { } while (0)
#endif

static void tx28_fixup_flexcan(void *blob)
{
	karo_fdt_del_prop(blob, "fsl,p1010-flexcan", 0x80032000, "transceiver-switch");
	karo_fdt_del_prop(blob, "fsl,p1010-flexcan", 0x80034000, "transceiver-switch");
}

static void tx28_fixup_fec(void *blob)
{
	karo_fdt_remove_node(blob, "ethernet1");
}

void ft_board_setup(void *blob, bd_t *bd)
{
	const char *baseboard = getenv("baseboard");

#ifdef CONFIG_TX28_S
	/* TX28-41xx (aka TX28S) has no external RTC
	 * and no I2C GPIO extender
	 */
	karo_fdt_remove_node(blob, "ds1339");
	karo_fdt_remove_node(blob, "pca9554");
#endif
	if (baseboard != NULL && strcmp(baseboard, "stk5-v5") == 0) {
		const char *otg_mode = getenv("otg_mode");

		if (otg_mode && strcmp(otg_mode, "host") == 0) {
			printf("otg_mode=%s incompatible with baseboard %s\n",
				otg_mode, baseboard);
			setenv(otg_mode, "none");
		}
		karo_fdt_remove_node(blob, "stk5led");
	} else {
		tx28_fixup_flexcan(blob);
		tx28_fixup_fec(blob);
	}

	if (baseboard != NULL && strcmp(baseboard, "stk5-v3") == 0) {
		const char *otg_mode = getenv("otg_mode");

		if (otg_mode && strcmp(otg_mode, "device") == 0)
			karo_fdt_remove_node(blob, "can1");
	}

	fdt_fixup_mtdparts(blob, tx28_nand_nodes, ARRAY_SIZE(tx28_nand_nodes));
	fdt_fixup_ethernet(blob);

	karo_fdt_fixup_touchpanel(blob);
	karo_fdt_fixup_usb_otg(blob, "fsl,imx28-usbphy", 0x8007c000);
}
#endif
