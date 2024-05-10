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
`set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { VGA_hsync }]; #IO_L4P_T0_15 Sch=vga_hs
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
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG7_seg[6]}]`
* The constraints above are basically the same we used for preivous labs involving displaying the vga driver and anodes on the Board
## LOGIC OF THE GAME AND MODIFICATIONS)
* 7 out of the 10 files were either from scratch or inspired from previous code
* Since we are using a buttons to control the state of the game, we avoided the problem of bouncing by creating a debounce module
![image](https://github.com/johnB-A/flappybird/assets/156035355/8e711efc-26f6-4e73-a311-09ea4ff1ffee)
* The main idea of the debouncing is to wait roughly 10 ms, because within that amount of time, bouncing of the button occurs, which means if button is '1' the next moment it's '0', even though it is being pressed. 10 ms wait time takes care of the timing issue of the bouncing
* A Shift register was added to make it more "secure". The inital value is "00000" but in every clock cycle, it gets updated. The shift register shift to the highest bit so each bit moves to the left by one, and the current state of the button becomes the LSB of the register. Once the shift register is "11111" which means it has been sampling a high value from the button for a while and polling time is met, update the status of the debounced button as high
* Since we used ieee._numeric_std.all instead of USE IEEE.STD_LOGIC_ARITH.ALL and USE IEEE.STD_LOGIC_UNSIGNED.ALL; we had to conver the counter into an unsgined then add one to it , and convert it back to std_logic_vector
* **BIRD_LOGIC**
* Bird logic is responsible for the bird's apperance and movement.
* Within the Bird_logic module it contains a draw_coord module which basically draws the shape of the bird and its wing(both are circles). Same logic as drawing the ball from lab3
* The idea is to have the bird stationary in the axis, but moving vertically. Here are the coordinates:
  `SIGNAL bird_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(180, 11);
	SIGNAL bird_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
		--Initial wing position
	SIGNAL wing_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(160, 11); -- left outer edge of bird l
	SIGNAL wing_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);`
  * The bird initally starts towards the left of the screen at the middle height. The bird is stationary horiztonally but moves vertically
    
   `birdie: draw_coord port map(
    v_sync => v_sync,
    pixel_row => pixel_row,
    pixel_col => pixel_col,
    x_size => bird_x,
    y_size => bird_y,
    b_size => bird_size,
    shape_on => bird_on   
);

wings: draw_coord port map(
    v_sync => v_sync,
    pixel_row => pixel_row,
    pixel_col => pixel_col,
    x_size => wing_x,
    y_size => wing_y,
    b_size => wing_size,
    shape_on => wing_on   
);`
bird_motion: PROCESS IS
BEGIN
    p_BTNC <= BTNC;
    GAME_STARTS <= GAME_ON;
    conditions <= COLLISION & GAME_ON; -- combines collision and game_starts
    WAIT UNTIL RISING_EDGE(V_sync);
        IF(RESET = '1' and GAME_ON = '0') THEN   ---resets for new game
            GAME_ON <= '1';
        Else
            CASE(conditions) IS
                WHEN "01" =>   --Game is on and there is no collision
                    IF(p_BTNC = '1' and BTNC = '0' AND bird_y>=0 AND bird_y<540) THEN --if button released and valid range bird moves up
                        bird_y <= bird_y -54;
                        wing_y <= wing_y -54;
                    ELSIF(bird_y < 540) THEN  --else drops 4 pixels/frame
                        bird_y <= bird_y +3;
                        wing_y <= wing_y +3;
                    ELSIF(bird_y >= 540) THEN  --game ends
                        bird_y <= CONV_STD_LOGIC_VECTOR(320, 11);
                        wing_y <= CONV_STD_LOGIC_VECTOR(320, 11);
                        GAME_ON <= '0';
                    END IF;
                WHEN OTHERS => --Collision
                    IF(conditions = "11") THEN
                        GAME_ON <= '0';
                        bird_y <= bird_y;
                        wing_y <= wing_y;
                    END IF;
            END CASE;
        END IF;          
END PROCESS;	
bird_pos <= bird_y;
wing_pos <= wing_y;		
END Behavioral;`
*The idea is that the bird moves when button is released, for this to occur the current button must be low, the previous value was high, which means there is a falling edge. That's why we have the p_BTNC signal
*The bird logic as shown above is also ressponible for the game_on signal, so when the game is off, and RESET high, game starts. This condition won't come into effect if RESET is pressed until the Bird collides, because that's when game_on becomes zero
*There is no special reason behind the numbers of the movement of the bird, besides trial and error, but the main idea is whne button is released bird moves up the screen 54 pixels, if not then bird falls at a constant 3 pixels down.
*When Bird reaches ground game ends and it resets the bird back to the default condition, but if tehre is a collision that bird stays in the coordinates of the collision and game ends
*The size of the bird is 40 diamters wide, and the wing is 20 pixels wide. The wing and bird follow the same speed logic, so that they move as one unit
  

