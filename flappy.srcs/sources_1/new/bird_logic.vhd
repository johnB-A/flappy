LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bird IS
	PORT (
	    clk_in    : in std_logic;
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		bird_y    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		wing_y    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		GAME_STARTS : IN STD_LOGIC;
		BTNU : IN STD_LOGIC;
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END bird;

ARCHITECTURE Behavioral OF bird IS
	CONSTANT bird_size    : INTEGER := 20; --radius;
	CONSTANT wing_size : INTEGER := 10;
	SIGNAL bird_on     : STD_LOGIC; -- indicates whether bird is over current pixel position
	SIGNAL wing_on     : STD_LOGIC; --  
	signal pipe_on    : STD_LOGIC;
	-- current bird position - intitialized left center
	SIGNAL bird_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(180, 11);
	--SIGNAL bird_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	
	SIGNAL wing_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(160, 11); -- left outer edge of bird l
	--SIGNAL wing_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	SIGNAL p_BTNC :  std_logic; --previous value of button
    SIGNAL c_BTNC : STD_LOGIC; --current value of button
	-- current ball motion - initialized to +4 pixels/frame
	--SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	

component draw_coord IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		x_size : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		y_size : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		b_size : in integer;
		shape_on : out std_logic
	);
end component;



	
BEGIN
birdie: draw_coord port map(
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
);

	red   <= '1'; -- color setup for red ball on white background
	green <= '1';
	blue  <= (NOT bird_on) and NOT wing_on;

--	red   <= '1' and NOT(pipe_on); -- color setup for red ball on white background
--	green <= '1';
--	blue  <= (NOT bird_on) and NOT wing_on and NOT(pipe_on);

END Behavioral;