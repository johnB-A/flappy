LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bird IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		RESET  : IN STD_LOGIC;
		COLLISION : IN STD_LOGIC;
		BTNC : IN STD_LOGIC;
		bird_pos : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		wing_pos : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		GAME_STARTS : OUT STD_LOGIC;
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
    SIGNAL conditions : std_logic_vector(1 downto 0);
    SIGNAL GAME_ON : STD_LOGIC := '0';
		--Initial bird position
	SIGNAL bird_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(180, 11);
	SIGNAL bird_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
		--Initial wing position
	SIGNAL wing_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(160, 11); -- left outer edge of bird l
	SIGNAL wing_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	SIGNAL p_BTNC :  std_logic; --previous value of button
component draw_coord IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		x_size    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		y_size    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		b_size    : in integer;
		shape_on  : out std_logic
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
END Behavioral;