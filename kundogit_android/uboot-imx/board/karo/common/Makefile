#
# (C) Copyright 2012 Lothar Waßmann <LW@KARO-electronics.de>
#
# See file CREDITS for list of people who contributed to this
# project.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

include $(TOPDIR)/config.mk

ifneq ($(OBJTREE),$(SRCTREE))
$(shell mkdir -p $(obj)board/$(VENDOR)/common)
endif

LIB	= $(obj)lib$(VENDOR).o

ifeq ($(CONFIG_SPL_BUILD),)
	COBJS-$(CONFIG_OF_BOARD_SETUP)	+= fdt.o
	COBJS-$(CONFIG_SPLASH_SCREEN)	+= splashimage.o
endif

COBJS   := $(COBJS-y)
SOBJS	:= 

SRCS	:= $(SOBJS:.o=.S) $(COBJS:.o=.c)
OBJS	:= $(addprefix $(obj),$(COBJS))
SOBJS	:= $(addprefix $(obj),$(SOBJS))

$(LIB):	$(obj).depend $(OBJS) $(SOBJS)
	$(call cmd_link_o_target, $(OBJS) $(SOBJS))

all:	$(LIB)

#########################################################################

include $(SRCTREE)/rules.mk

sinclude $(obj).depend

#########################################################################
