
# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
# Switches
set_property PACKAGE_PIN V17 [get_ports rst]					
	set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN V16 [get_ports cnt_en]					
	set_property IOSTANDARD LVCMOS33 [get_ports cnt_en]
#set_property PACKAGE_PIN W16 [get_ports cnt_en]					
	#set_property IOSTANDARD LVCMOS33 [get_ports cnt_en]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {FinalResult[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[0]}]
set_property PACKAGE_PIN E19 [get_ports {FinalResult[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[1]}]
set_property PACKAGE_PIN U19 [get_ports {FinalResult[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[2]}]
set_property PACKAGE_PIN V19 [get_ports {FinalResult[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[3]}]
set_property PACKAGE_PIN W18 [get_ports {FinalResult[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[4]}]
set_property PACKAGE_PIN U15 [get_ports {FinalResult[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[5]}]
set_property PACKAGE_PIN U14 [get_ports {FinalResult[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[6]}]
set_property PACKAGE_PIN V14 [get_ports {FinalResult[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[7]}]
set_property PACKAGE_PIN V13 [get_ports {FinalResult[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[8]}]
set_property PACKAGE_PIN V3 [get_ports {FinalResult[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[9]}]
set_property PACKAGE_PIN W3 [get_ports {FinalResult[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[10]}]
set_property PACKAGE_PIN U3 [get_ports {FinalResult[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[11]}]
set_property PACKAGE_PIN P3 [get_ports {FinalResult[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[12]}]
set_property PACKAGE_PIN N3 [get_ports {FinalResult[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[13]}]
set_property PACKAGE_PIN P1 [get_ports {FinalResult[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[14]}]
set_property PACKAGE_PIN L1 [get_ports {FinalResult[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {FinalResult[15]}]