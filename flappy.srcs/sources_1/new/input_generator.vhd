-------------------------------------------------------------------------------
-- INSPIRED BY downloaded from http://www.nandland.com
 
library ieee;
use ieee.std_logic_1164.all;
 
entity LFSR is
  port (
    i_Clk       : in STD_LOGIC;
    GAME_STARTS : in STD_LOGIC;
    COLLISION   : IN STD_LOGIC;
    O_seq       : out std_logic_vector(2 downto 0)
    );
end entity LFSR;
 
architecture RTL of LFSR is
 
  signal i_Seed_Data : std_logic_vector(2 downto 0) := (others =>'0');
  signal r_LFSR : std_logic_vector(3 downto 1) := (others => '0');
  signal w_XNOR : std_logic;
   
begin
  p_LFSR : process is
  begin
   WAIT UNTIL rising_edge(i_CLK); 
        if(GAME_STARTS = '0') then
            r_LFSR <= i_Seed_Data;
        else
            r_LFSR <= r_LFSR(r_LFSR'left-1 downto 1) & w_XNOR;
        end if ;
  end process p_LFSR; 
 
  -- Create Feedback Polynomials.  Based on Application Note:
  -- http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
     w_XNOR <= r_LFSR(3) xnor r_LFSR(2);
  
 o_seq <= r_LFSR;
end architecture RTL;