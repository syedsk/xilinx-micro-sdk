# xilinx-micro-sdk

micro - sdk to build Linux system on zc702 and zcu102.

	Prerequisites:
	
	a. Clone this repo into $(TOP_DIR)
	b. Clone device tree repo. https://github.com/Xilinx/device-tree-xlnx into $(TOP_DIR)/device-tree-xlnx
	c. Clone kernel https://github.com/Xilinx/linux-xlnx into $(TOP_DIR)/linux-xlnx
	d. Add your design to design/$(BOARD)/design_1_wrapper.hdf
	e. To generate device tree  $make dts
	f. To compile device tree $make dtb
	g. To compile kernel $make kernel


