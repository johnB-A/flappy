# CPE 487 PROJECT: Flappy Bird

## INTRODUCTION
The project is about creating a version of Flappy Bird implementing Hardware Description Language - VHDL. 
**RULES**
Very similar to the standard Flappy Bird game, the bird must avoid the obstacles which change height randomly. As bird crosses an obstacle, the player's score increases by one. Unlike the tapping motion of computer screen, a buttom is used for the same function to move the bird vertically, if not bird drops at a constant speed.
**ATTACHMENTS USED**
- VGA CONNTECTOR
- NEXYS A7 100TCSG325
## HOW TO GET THE PROJECT TO WORK ON VIVADO
1.  Create a new RTL project Flappy in Vivado Quick Start
   * Create ten new source files of file type VHDL called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bird_logic, draw_coord, pipes, height_generator, leddec16, debounce and flappy
    - clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd and vga_sync.vhd are the same files as in Lab 6
     - Everthing else is a new file for Flappy Bird
   * Create a new constraint file of file type XDC called flappy
   * Choose Nexys A7-100T board for the project
   * Click 'Finish'
2. RUN Synthesis
3. Run Implementation
4. Attach VGA CONNECTOR TO THE board
5. Generate bitstream, open hardware manager, and program device
      * Click 'Generate Bitstream'
      * Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
      * Click 'Program Device' then xc7a100t_0 to download flappy.bit to the Nexys A7-100T board
      * Push BTNL to start the game and keep pressing BTNC to move the bird
## DESCRIPTION OF THE TOP LEVEL BLOCK DIAGRAM



## Description of Inputs and Outputs going from the Vivado Project to the Nexys board
`set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { RESET }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk_in}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_in}];`
* RESET and BTNC are in the inputs of the top level including the clock. RESET (BTNL) is used to start start the game. Once the game starts it this button will only be effective once the game ends.
* BTNC is used to control the vertical motion of the bird
* clk_in represents the main oscillator of the system, at 100 MHZ
'set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { VGA_hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { VGA_vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs
set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[1] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[2] }];
set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS33 } [get_ports { VGA_blue[3] }];
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { VGA_red[3] }];
set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6 IOSTANDARD LVCMOS33 } [get_ports { VGA_green[3] }];
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[0]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[1]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[3]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[4]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[5]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[6]}] '
* The constraints above are basically the same we used for preivous labs involving displaying the vga driver and anodes on the Board
##LOGIC OF THE GAME AND MODIFICATIONS)
  

