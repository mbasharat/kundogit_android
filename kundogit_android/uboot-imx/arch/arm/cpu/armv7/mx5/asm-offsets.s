	.arch armv7-a
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 18, 4
	.file	"asm-offsets.c"
	.section	.debug_abbrev,"",%progbits
.Ldebug_abbrev0:
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.align	2
	.global	main
	.type	main, %function
main:
.LFB100:
	.file 1 "arch/arm/cpu/armv7/mx5/asm-offsets.c"
	.loc 1 24 0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 27 0
#APP
@ 27 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCMR #0 offsetof(struct clkctl, ccr)
@ 0 "" 2
	.loc 1 28 0
@ 28 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCDR #4 offsetof(struct clkctl, ccdr)
@ 0 "" 2
	.loc 1 29 0
@ 29 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSR #8 offsetof(struct clkctl, csr)
@ 0 "" 2
	.loc 1 30 0
@ 30 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCSR #12 offsetof(struct clkctl, ccsr)
@ 0 "" 2
	.loc 1 31 0
@ 31 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CACRR #16 offsetof(struct clkctl, cacrr)
@ 0 "" 2
	.loc 1 32 0
@ 32 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CBCDR #20 offsetof(struct clkctl, cbcdr)
@ 0 "" 2
	.loc 1 33 0
@ 33 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CBCMR #24 offsetof(struct clkctl, cbcmr)
@ 0 "" 2
	.loc 1 34 0
@ 34 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCMR1 #28 offsetof(struct clkctl, cscmr1)
@ 0 "" 2
	.loc 1 35 0
@ 35 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCMR2 #32 offsetof(struct clkctl, cscmr2)
@ 0 "" 2
	.loc 1 36 0
@ 36 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCDR1 #36 offsetof(struct clkctl, cscdr1)
@ 0 "" 2
	.loc 1 37 0
@ 37 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CS1CDR #40 offsetof(struct clkctl, cs1cdr)
@ 0 "" 2
	.loc 1 38 0
@ 38 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CS2CDR #44 offsetof(struct clkctl, cs2cdr)
@ 0 "" 2
	.loc 1 39 0
@ 39 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CDCDR #48 offsetof(struct clkctl, cdcdr)
@ 0 "" 2
	.loc 1 40 0
@ 40 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CHSCCDR #52 offsetof(struct clkctl, chsccdr)
@ 0 "" 2
	.loc 1 41 0
@ 41 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCDR2 #56 offsetof(struct clkctl, cscdr2)
@ 0 "" 2
	.loc 1 42 0
@ 42 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCDR3 #60 offsetof(struct clkctl, cscdr3)
@ 0 "" 2
	.loc 1 43 0
@ 43 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CSCDR4 #64 offsetof(struct clkctl, cscdr4)
@ 0 "" 2
	.loc 1 44 0
@ 44 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CWDR #68 offsetof(struct clkctl, cwdr)
@ 0 "" 2
	.loc 1 45 0
@ 45 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CDHIPR #72 offsetof(struct clkctl, cdhipr)
@ 0 "" 2
	.loc 1 46 0
@ 46 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CDCR #76 offsetof(struct clkctl, cdcr)
@ 0 "" 2
	.loc 1 47 0
@ 47 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CTOR #80 offsetof(struct clkctl, ctor)
@ 0 "" 2
	.loc 1 48 0
@ 48 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CLPCR #84 offsetof(struct clkctl, clpcr)
@ 0 "" 2
	.loc 1 49 0
@ 49 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CISR #88 offsetof(struct clkctl, cisr)
@ 0 "" 2
	.loc 1 50 0
@ 50 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CIMR #92 offsetof(struct clkctl, cimr)
@ 0 "" 2
	.loc 1 51 0
@ 51 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCOSR #96 offsetof(struct clkctl, ccosr)
@ 0 "" 2
	.loc 1 52 0
@ 52 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CGPR #100 offsetof(struct clkctl, cgpr)
@ 0 "" 2
	.loc 1 53 0
@ 53 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR0 #104 offsetof(struct clkctl, ccgr0)
@ 0 "" 2
	.loc 1 54 0
@ 54 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR1 #108 offsetof(struct clkctl, ccgr1)
@ 0 "" 2
	.loc 1 55 0
@ 55 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR2 #112 offsetof(struct clkctl, ccgr2)
@ 0 "" 2
	.loc 1 56 0
@ 56 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR3 #116 offsetof(struct clkctl, ccgr3)
@ 0 "" 2
	.loc 1 57 0
@ 57 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR4 #120 offsetof(struct clkctl, ccgr4)
@ 0 "" 2
	.loc 1 58 0
@ 58 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR5 #124 offsetof(struct clkctl, ccgr5)
@ 0 "" 2
	.loc 1 59 0
@ 59 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CCGR6 #128 offsetof(struct clkctl, ccgr6)
@ 0 "" 2
	.loc 1 60 0
@ 60 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->CLKCTL_CMEOR #132 offsetof(struct clkctl, cmeor)
@ 0 "" 2
	.loc 1 66 0
@ 66 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_CTL #0 offsetof(struct dpll, dp_ctl)
@ 0 "" 2
	.loc 1 67 0
@ 67 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_CONFIG #4 offsetof(struct dpll, dp_config)
@ 0 "" 2
	.loc 1 68 0
@ 68 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_OP #8 offsetof(struct dpll, dp_op)
@ 0 "" 2
	.loc 1 69 0
@ 69 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_MFD #12 offsetof(struct dpll, dp_mfd)
@ 0 "" 2
	.loc 1 70 0
@ 70 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_MFN #16 offsetof(struct dpll, dp_mfn)
@ 0 "" 2
	.loc 1 71 0
@ 71 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_HFS_OP #28 offsetof(struct dpll, dp_hfs_op)
@ 0 "" 2
	.loc 1 72 0
@ 72 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_HFS_MFD #32 offsetof(struct dpll, dp_hfs_mfd)
@ 0 "" 2
	.loc 1 73 0
@ 73 "arch/arm/cpu/armv7/mx5/asm-offsets.c" 1
	
->PLL_DP_HFS_MFN #36 offsetof(struct dpll, dp_hfs_mfn)
@ 0 "" 2
	.loc 1 76 0
	mov	r0, #0
	bx	lr
	.cfi_endproc
.LFE100:
	.size	main, .-main
.Letext0:
	.file 2 "/media/projekte/130405-tx6-Android-bsp/work/kc/myandroid/bootable/bootloader/uboot-imx/include/asm/u-boot.h"
	.file 3 "/media/projekte/130405-tx6-Android-bsp/work/kc/myandroid/bootable/bootloader/uboot-imx/include/linux/types.h"
	.file 4 "/media/projekte/130405-tx6-Android-bsp/work/kc/myandroid/bootable/bootloader/uboot-imx/include/net.h"
	.section	.debug_info
	.4byte	0x2e3
	.2byte	0x2
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF41
	.byte	0x1
	.4byte	.LASF42
	.4byte	.LASF43
	.4byte	.Ltext0
	.4byte	.Letext0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF0
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.4byte	.LASF2
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.4byte	.LASF3
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF5
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.4byte	.LASF6
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.4byte	.LASF7
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.4byte	.LASF8
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF9
	.uleb128 0x4
	.4byte	.LASF19
	.byte	0x3
	.byte	0x5c
	.4byte	0x2c
	.uleb128 0x5
	.byte	0x4
	.uleb128 0x6
	.byte	0x8
	.byte	0x2
	.byte	0x2e
	.4byte	0xa4
	.uleb128 0x7
	.4byte	.LASF10
	.byte	0x2
	.byte	0x30
	.4byte	0x72
	.byte	0x2
	.byte	0x23
	.uleb128 0x0
	.uleb128 0x7
	.4byte	.LASF11
	.byte	0x2
	.byte	0x31
	.4byte	0x72
	.byte	0x2
	.byte	0x23
	.uleb128 0x4
	.byte	0x0
	.uleb128 0x8
	.4byte	.LASF21
	.byte	0x28
	.byte	0x2
	.byte	0x27
	.4byte	0x113
	.uleb128 0x7
	.4byte	.LASF12
	.byte	0x2
	.byte	0x28
	.4byte	0x4f
	.byte	0x2
	.byte	0x23
	.uleb128 0x0
	.uleb128 0x7
	.4byte	.LASF13
	.byte	0x2
	.byte	0x29
	.4byte	0x72
	.byte	0x2
	.byte	0x23
	.uleb128 0x4
	.uleb128 0x7
	.4byte	.LASF14
	.byte	0x2
	.byte	0x2a
	.4byte	0x72
	.byte	0x2
	.byte	0x23
	.uleb128 0x8
	.uleb128 0x7
	.4byte	.LASF15
	.byte	0x2
	.byte	0x2b
	.4byte	0x2c
	.byte	0x2
	.byte	0x23
	.uleb128 0xc
	.uleb128 0x7
	.4byte	.LASF16
	.byte	0x2
	.byte	0x2c
	.4byte	0x2c
	.byte	0x2
	.byte	0x23
	.uleb128 0x10
	.uleb128 0x7
	.4byte	.LASF17
	.byte	0x2
	.byte	0x2d
	.4byte	0x2c
	.byte	0x2
	.byte	0x23
	.uleb128 0x14
	.uleb128 0x7
	.4byte	.LASF18
	.byte	0x2
	.byte	0x32
	.4byte	0x113
	.byte	0x2
	.byte	0x23
	.uleb128 0x18
	.byte	0x0
	.uleb128 0x9
	.4byte	0x7f
	.4byte	0x123
	.uleb128 0xa
	.4byte	0x4f
	.byte	0x1
	.byte	0x0
	.uleb128 0x4
	.4byte	.LASF20
	.byte	0x2
	.byte	0x33
	.4byte	0xa4
	.uleb128 0xb
	.byte	0x4
	.4byte	0x123
	.uleb128 0x8
	.4byte	.LASF22
	.byte	0x40
	.byte	0x4
	.byte	0x51
	.4byte	0x1e9
	.uleb128 0x7
	.4byte	.LASF23
	.byte	0x4
	.byte	0x52
	.4byte	0x1e9
	.byte	0x2
	.byte	0x23
	.uleb128 0x0
	.uleb128 0x7
	.4byte	.LASF24
	.byte	0x4
	.byte	0x53
	.4byte	0x1f9
	.byte	0x2
	.byte	0x23
	.uleb128 0x10
	.uleb128 0x7
	.4byte	.LASF25
	.byte	0x4
	.byte	0x54
	.4byte	0x48
	.byte	0x2
	.byte	0x23
	.uleb128 0x18
	.uleb128 0x7
	.4byte	.LASF26
	.byte	0x4
	.byte	0x55
	.4byte	0x48
	.byte	0x2
	.byte	0x23
	.uleb128 0x1c
	.uleb128 0x7
	.4byte	.LASF27
	.byte	0x4
	.byte	0x57
	.4byte	0x224
	.byte	0x2
	.byte	0x23
	.uleb128 0x20
	.uleb128 0x7
	.4byte	.LASF28
	.byte	0x4
	.byte	0x58
	.4byte	0x244
	.byte	0x2
	.byte	0x23
	.uleb128 0x24
	.uleb128 0x7
	.4byte	.LASF29
	.byte	0x4
	.byte	0x59
	.4byte	0x25a
	.byte	0x2
	.byte	0x23
	.uleb128 0x28
	.uleb128 0x7
	.4byte	.LASF30
	.byte	0x4
	.byte	0x5a
	.4byte	0x26c
	.byte	0x2
	.byte	0x23
	.uleb128 0x2c
	.uleb128 0x7
	.4byte	.LASF31
	.byte	0x4
	.byte	0x5e
	.4byte	0x25a
	.byte	0x2
	.byte	0x23
	.uleb128 0x30
	.uleb128 0x7
	.4byte	.LASF32
	.byte	0x4
	.byte	0x5f
	.4byte	0x21e
	.byte	0x2
	.byte	0x23
	.uleb128 0x34
	.uleb128 0x7
	.4byte	.LASF33
	.byte	0x4
	.byte	0x60
	.4byte	0x48
	.byte	0x2
	.byte	0x23
	.uleb128 0x38
	.uleb128 0x7
	.4byte	.LASF34
	.byte	0x4
	.byte	0x61
	.4byte	0x7d
	.byte	0x2
	.byte	0x23
	.uleb128 0x3c
	.byte	0x0
	.uleb128 0x9
	.4byte	0x6b
	.4byte	0x1f9
	.uleb128 0xa
	.4byte	0x4f
	.byte	0xf
	.byte	0x0
	.uleb128 0x9
	.4byte	0x25
	.4byte	0x209
	.uleb128 0xa
	.4byte	0x4f
	.byte	0x5
	.byte	0x0
	.uleb128 0xc
	.byte	0x1
	.4byte	0x48
	.4byte	0x21e
	.uleb128 0xd
	.4byte	0x21e
	.uleb128 0xd
	.4byte	0x12e
	.byte	0x0
	.uleb128 0xb
	.byte	0x4
	.4byte	0x134
	.uleb128 0xb
	.byte	0x4
	.4byte	0x209
	.uleb128 0xc
	.byte	0x1
	.4byte	0x48
	.4byte	0x244
	.uleb128 0xd
	.4byte	0x21e
	.uleb128 0xd
	.4byte	0x7d
	.uleb128 0xd
	.4byte	0x48
	.byte	0x0
	.uleb128 0xb
	.byte	0x4
	.4byte	0x22a
	.uleb128 0xc
	.byte	0x1
	.4byte	0x48
	.4byte	0x25a
	.uleb128 0xd
	.4byte	0x21e
	.byte	0x0
	.uleb128 0xb
	.byte	0x4
	.4byte	0x24a
	.uleb128 0xe
	.byte	0x1
	.4byte	0x26c
	.uleb128 0xd
	.4byte	0x21e
	.byte	0x0
	.uleb128 0xb
	.byte	0x4
	.4byte	0x260
	.uleb128 0xf
	.4byte	.LASF44
	.byte	0x4
	.byte	0x4
	.2byte	0x203
	.4byte	0x298
	.uleb128 0x10
	.4byte	.LASF35
	.sleb128 0
	.uleb128 0x10
	.4byte	.LASF36
	.sleb128 1
	.uleb128 0x10
	.4byte	.LASF37
	.sleb128 2
	.uleb128 0x10
	.4byte	.LASF38
	.sleb128 3
	.byte	0x0
	.uleb128 0x11
	.byte	0x1
	.4byte	.LASF45
	.byte	0x1
	.byte	0x17
	.byte	0x1
	.4byte	0x48
	.4byte	.LFB100
	.4byte	.LFE100
	.byte	0x2
	.byte	0x7d
	.sleb128 0
	.uleb128 0x12
	.4byte	.LASF39
	.byte	0x4
	.byte	0x6b
	.4byte	0x21e
	.byte	0x1
	.byte	0x1
	.uleb128 0x13
	.4byte	.LASF40
	.byte	0x4
	.2byte	0x209
	.4byte	0x272
	.byte	0x1
	.byte	0x1
	.uleb128 0x12
	.4byte	.LASF39
	.byte	0x4
	.byte	0x6b
	.4byte	0x21e
	.byte	0x1
	.byte	0x1
	.uleb128 0x13
	.4byte	.LASF40
	.byte	0x4
	.2byte	0x209
	.4byte	0x272
	.byte	0x1
	.byte	0x1
	.byte	0x0
	.section	.debug_abbrev
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x6
	.byte	0x0
	.byte	0x0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0x0
	.byte	0x0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0x0
	.byte	0x0
	.uleb128 0x4
	.uleb128 0x16
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0x0
	.byte	0x0
	.uleb128 0x6
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0x7
	.uleb128 0xd
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xa
	.byte	0x0
	.byte	0x0
	.uleb128 0x8
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0x9
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0xa
	.uleb128 0x21
	.byte	0x0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0x0
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xf
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0xc
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0xd
	.uleb128 0x5
	.byte	0x0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0xe
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0xf
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0x10
	.uleb128 0x28
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xd
	.byte	0x0
	.byte	0x0
	.uleb128 0x11
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0xa
	.byte	0x0
	.byte	0x0
	.uleb128 0x12
	.uleb128 0x34
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3c
	.uleb128 0xc
	.byte	0x0
	.byte	0x0
	.uleb128 0x13
	.uleb128 0x34
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3c
	.uleb128 0xc
	.byte	0x0
	.byte	0x0
	.byte	0x0
	.section	.debug_pubnames,"",%progbits
	.4byte	0x17
	.2byte	0x2
	.4byte	.Ldebug_info0
	.4byte	0x2e7
	.4byte	0x298
	.ascii	"main\000"
	.4byte	0x0
	.section	.debug_pubtypes,"",%progbits
	.4byte	0x4f
	.2byte	0x2
	.4byte	.Ldebug_info0
	.4byte	0x2e7
	.4byte	0x72
	.ascii	"ulong\000"
	.4byte	0xa4
	.ascii	"bd_info\000"
	.4byte	0x123
	.ascii	"bd_t\000"
	.4byte	0x134
	.ascii	"eth_device\000"
	.4byte	0x272
	.ascii	"net_loop_state\000"
	.4byte	0x0
	.section	.debug_aranges,"",%progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0x0
	.2byte	0x0
	.2byte	0x0
	.4byte	.Ltext0
	.4byte	.Letext0-.Ltext0
	.4byte	0x0
	.4byte	0x0
	.section	.debug_str,"MS",%progbits,1
.LASF39:
	.ascii	"eth_current\000"
.LASF15:
	.ascii	"bi_arm_freq\000"
.LASF42:
	.ascii	"arch/arm/cpu/armv7/mx5/asm-offsets.c\000"
.LASF32:
	.ascii	"next\000"
.LASF30:
	.ascii	"halt\000"
.LASF26:
	.ascii	"state\000"
.LASF34:
	.ascii	"priv\000"
.LASF43:
	.ascii	"/media/projekte/130405-tx6-Android-bsp/work/kc/myan"
	.ascii	"droid/bootable/bootloader/uboot-imx\000"
.LASF13:
	.ascii	"bi_arch_number\000"
.LASF41:
	.ascii	"GNU C 4.5.2 20101204 (prerelease)\000"
.LASF10:
	.ascii	"start\000"
.LASF27:
	.ascii	"init\000"
.LASF31:
	.ascii	"write_hwaddr\000"
.LASF40:
	.ascii	"net_state\000"
.LASF37:
	.ascii	"NETLOOP_SUCCESS\000"
.LASF24:
	.ascii	"enetaddr\000"
.LASF25:
	.ascii	"iobase\000"
.LASF38:
	.ascii	"NETLOOP_FAIL\000"
.LASF1:
	.ascii	"long unsigned int\000"
.LASF2:
	.ascii	"short unsigned int\000"
.LASF16:
	.ascii	"bi_dsp_freq\000"
.LASF0:
	.ascii	"unsigned char\000"
.LASF45:
	.ascii	"main\000"
.LASF12:
	.ascii	"bi_baudrate\000"
.LASF18:
	.ascii	"bi_dram\000"
.LASF19:
	.ascii	"ulong\000"
.LASF5:
	.ascii	"unsigned int\000"
.LASF28:
	.ascii	"send\000"
.LASF21:
	.ascii	"bd_info\000"
.LASF7:
	.ascii	"long long unsigned int\000"
.LASF29:
	.ascii	"recv\000"
.LASF6:
	.ascii	"long long int\000"
.LASF36:
	.ascii	"NETLOOP_RESTART\000"
.LASF33:
	.ascii	"index\000"
.LASF44:
	.ascii	"net_loop_state\000"
.LASF4:
	.ascii	"short int\000"
.LASF17:
	.ascii	"bi_ddr_freq\000"
.LASF22:
	.ascii	"eth_device\000"
.LASF35:
	.ascii	"NETLOOP_CONTINUE\000"
.LASF8:
	.ascii	"long int\000"
.LASF9:
	.ascii	"char\000"
.LASF14:
	.ascii	"bi_boot_params\000"
.LASF3:
	.ascii	"signed char\000"
.LASF11:
	.ascii	"size\000"
.LASF20:
	.ascii	"bd_t\000"
.LASF23:
	.ascii	"name\000"
	.ident	"GCC: (GNU) 4.5.2 20101204 (prerelease)"
	.section	.note.GNU-stack,"",%progbits
