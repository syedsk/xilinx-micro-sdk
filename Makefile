
export TOP_DIR = $(shell pwd)

# for zynq7000
#export ARCH = arm
#BOARD_NAME := zc702

# for zynqmp ultrascale
BOARD_NAME := zcu102
export ARCH = arm64

VIVADO_VER := 2018.1
#VIVADO_VER := 2016.4

XSCT := /proj/xbuilds/$(VIVADO_VER)_daily_latest/installs/lin64/SDK/$(VIVADO_VER)/bin/xsct

PETALINUX_HOME = /proj/petalinux/petalinux-v$(VIVADO_VER)_daily_latest
ifeq ($(ARCH), arm64)
	export GCC_PREFIX = $(PETALINUX_HOME)/petalinux-v$(VIVADO_VER)-final/tools/linux-i386/aarch64-linux-gnu/bin/aarch64-linux-gnu-
else
	export GCC_PREFIX = $(PETALINUX_HOME)/petalinux-v$(VIVADO_VER)-final/tools/linux-i386/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-
endif

export KERNEL_SOURCE := $(TOP_DIR)/linux-xlnx

export OUTPUT_DIR := $(TOP_DIR)/output

export HOST_BIN := $(TOP_DIR)/host_bin

export PATH := $(PATH):$(TOP_DIR)/host_bin

export KERNEL_OUTPUT := $(OUTPUT_DIR)/linux-xlnx-$(ARCH)

all: kernel_headers dtb kernel

ifeq ($(ARCH), arm)
kernel:
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make -C $(KERNEL_SOURCE) xilinx_zynq_defconfig O=$(KERNEL_OUTPUT)
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make -j 40 -C $(KERNEL_SOURCE)	O=$(KERNEL_OUTPUT) Image
	install $(KERNEL_OUTPUT)/arch/$(ARCH)/boot/Image $(TOP_DIR)/images/$(BOARD_NAME)
	cd $(TOP_DIR)/images/$(BOARD_NAME) && $(HOST_BIN)/mkimage -f fit.its fit.itb
else
kernel:
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make -C $(KERNEL_SOURCE) xilinx_zynqmp_defconfig O=$(KERNEL_OUTPUT)
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make  -j 40 -C $(KERNEL_SOURCE)	O=$(KERNEL_OUTPUT) Image
	install $(KERNEL_OUTPUT)/arch/$(ARCH)/boot/Image $(TOP_DIR)/images/$(BOARD_NAME)
	cd $(TOP_DIR)/images/$(BOARD_NAME) && $(HOST_BIN)/mkimage -f fit.its fit.itb
endif

menuconfig:
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make -C $(KERNEL_SOURCE) menuconfig O=$(KERNEL_OUTPUT)

kernel_headers:
	ARCH=$(ARCH) CROSS_COMPILE=$(GCC_PREFIX) make  -C $(KERNEL_SOURCE) O=$(KERNEL_OUTPUT) headers_install

dts:
ifeq ($(ARCH), arm64)
	$(XSCT) $(TOP_DIR)/host_bin/gen_dtsi.tcl $(TOP_DIR)/design/$(BOARD_NAME)/design_1_wrapper.hdf \
	$(TOP_DIR)/device-tree-xlnx psu_cortexa53_0 $(TOP_DIR)/device-tree/$(BOARD_NAME)
else
	$(XSCT) $(TOP_DIR)/host_bin/gen_dtsi.tcl $(TOP_DIR)/design/$(BOARD_NAME)/design_1_wrapper.hdf \
	$(TOP_DIR)/device-tree-xlnx ps7_cortexa9_0 $(TOP_DIR)/device-tree/$(BOARD_NAME)
endif

dtb: dts
	$(KERNEL_OUTPUT)/scripts/dtc/dtc -I dts -O dtb -o $(OUTPUT_DIR)/system.dtb \
	$(TOP_DIR)/device-tree/$(BOARD_NAME)/system-top.dts
	install $(OUTPUT_DIR)/system.dtb $(TOP_DIR)/images/$(BOARD_NAME)

clean:
	rm -rf $(OUTPUT_DIR)

