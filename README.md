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
   *Create ten new source files of file type VHDL called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bird_logic, draw_coord, pipes, height_generator, leddec16, debounce and flappy
    -clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd and vga_sync.vhd are the same files as in Lab 6
     -Everthing else is a new file for Flappy Bird
   *Create a new constraint file of file type XDC called pong
   *Choose Nexys A7-100T board for the project
   *Click 'Finish'

5. Work on and edit code with the following modifications (depending on when you do this, it will be your Fourth, Fifth, or Sixth Lab Extension/Submission!)
