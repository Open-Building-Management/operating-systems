BUILDROOT_DIR := $(abspath buildroot)
OUTPUT_DIR    := $(abspath output)
BOARDS_DIR    := $(abspath boards)

BOARD ?= $(firstword $(MAKECMDGOALS))

ifeq ($(filter $(BOARD),savedefconfig linux-update-defconfig),$(BOARD))
BOARD := $(notdir $(shell grep ^BR2_DEFCONFIG $(OUTPUT_DIR)/.config | cut -d= -f2 | tr -d '"'))
endif

# get the arch from the board name
ARCH := $(word 2,$(subst _, ,$(BOARD)))_$(word 3,$(subst _, ,$(BOARD)))
BOARD_DIR := $(BOARDS_DIR)/$(ARCH)

.PHONY: all menuconfig linux-menuconfig linux-update-defconfig savedefconfig clean

%_defconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) BR2_DEFCONFIG=$(BOARD_DIR)/$@ defconfig

all:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR)

menuconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) menuconfig

linux-menuconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) linux-menuconfig

linux-update-defconfig:
	cp $(OUTPUT_DIR)/build/linux-*/.config $(BOARD_DIR)/linux.config

savedefconfig:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) savedefconfig
	cp $(OUTPUT_DIR)/defconfig $(BOARD_DIR)/$(BOARD)

clean:
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) clean

