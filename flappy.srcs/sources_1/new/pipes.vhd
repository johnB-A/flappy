LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pipes IS
--generic(
--top_pipe_height : integer;
-- bottom_pipe_height : integer;
 --t_pipe_h : integer;
-- b_pipe_h :  integer);
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
		 pipe_x   : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 t_pipe_size : IN INTEGER range 0 to 600;
		 b_pipe_size : IN INTEGER range 0 to 600;
		 t_pipe_y : IN INTEGER range 0 to 600;
		 b_pipe_y : IN INTEGER range 0 to 600;
		 
		GAME_STARTS : IN STD_LOGIC;
		BTNU        : IN STD_LOGIC;
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	   	);
END pipes;

ARCHITECTURE Behavioral OF pipes IS
	CONSTANT pipe_w    : INTEGER := 40; --radius of pipe;
	--SIGNAL pipe_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(280, 11); --560
	--SIGNAL t_pipe_size  : INTEGER := 140; --560
--	SIGNAL b_pipe_size  : INTEGER := 80; --560
--	SIGNAL t_pipe_y  : INTEGER := 140;-- left outer edge of bird l --560
--	SIGNAL b_pipe_y  : INTEGER := 520; -- left outer edge of bird l --530
--	SIGNAL pipe_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0);
	signal pipe_on : STD_LOGIC;
	
BEGIN
	red   <= NOT(pipe_on); -- color setup for red ball on white background
	green <= '1';
	blue  <= NOT(pipe_on);



pipes : PROCESS (pixel_row, pixel_col, t_pipe_y, b_pipe_y) IS
	BEGIN
	
	 IF ((pixel_col >= pipe_x - pipe_w) AND (pixel_col <= pipe_x + pipe_w)) THEN
        IF ((pixel_row >= t_pipe_y - t_pipe_size) AND (pixel_row <= t_pipe_y + t_pipe_size)) OR
           ((pixel_row >= b_pipe_y - b_pipe_size) AND (pixel_row <= b_pipe_y + b_pipe_size)) THEN
            pipe_on <= '1';
        ELSE
            pipe_on <= '0';
        END IF;
    ELSE
        pipe_on <= '0';
    END IF;
    
   
END PROCESS;
		
--firstpipe : PROCESS
--BEGIN
--    WAIT UNTIL rising_edge(v_sync);
    
--     IF(GAME_STARTS = '0') THEN
 --               pipe_x <= conv_std_logic_vector(280, 11);
 --              t_pipe_y <= 140;
 --               t_pipe_size <= 140;
 --               b_pipe_y <= 520;
 --               b_pipe_size <= 80;
  --            pipe_x_motion <= "00000000000";
  --   ELSE
   --     IF (pipe_x + pipe_w > 0 and GAME_STARTS = '1') THEN
  --      pipe_x_motion <= "11111111100"; -- -4 pixels
       
 ---       ELSIF (pipe_x + pipe_w <= 0) THEN
 --           IF (t_pipe_y > 40) THEN
  --              t_pipe_y <= t_pipe_y - 40;
   --             t_pipe_size <= t_pipe_size - 40;
    --            b_pipe_y <= b_pipe_y - 40;
    --            b_pipe_size <= b_pipe_size + 40;
     ---        ELSE
      --           t_pipe_y <= 140;
     --           t_pipe_size <= 140;
     --           b_pipe_y <= 520;
     --           b_pipe_size <= 80;
     --           END IF;
     ---       END IF;  
  -- END IF;
  --  pipe_x <= pipe_x + pipe_x_motion; 
--END PROCESS;
--top_p_size  <= t_pipe_size;
---bot_p_size  <= b_pipe_size;
--top_pipe_y  <= t_pipe_y;-b-ottom_pipe_y <= b_pipe_y;
		
		
END Behavioral;