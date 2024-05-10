LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pipes IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
		 COLLISION : IN STD_LOGIC;
		GAME_STARTS : IN STD_LOGIC;
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC;
		
		 pipe_onepos   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		 pipe_twopos   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		 top_p_size : OUT INTEGER range 0 to 600;
		 bottom_p_size : OUT INTEGER range 0 to 600;
		 top_pipe_y : OUT INTEGER range 0 to 600;
		 bottom_pipe_y : OUT INTEGER range 0 to 600;
		 top_p_size2 : OUT INTEGER range 0 to 600;
		 bottom_p_size2 : OUT INTEGER range 0 to 600;
		 top_pipe_y2 : OUT INTEGER range 0 to 600;
		 bottom_pipe_y2 : OUT INTEGER range 0 to 600
		 );
END pipes;

ARCHITECTURE Behavioral OF pipes IS
	CONSTANT pipe_w    : INTEGER := 40; --radius of pipe;
	SIGNAL pipe_on, pipe_on2 : STD_LOGIC;	 --determine the where pipe is color
	
	--first pipe height related stuff
	SIGNAL t_pipe_size  : INTEGER := 140; 
	SIGNAL b_pipe_size  : INTEGER := 80; 
	SIGNAL t_pipe_y  : INTEGER := 140;
	SIGNAL b_pipe_y  : INTEGER := 520; 
	
		--second pipe height related stuff
    SIGNAL t_pipe_size2  : INTEGER := 120; 
	SIGNAL b_pipe_size2  : INTEGER := 100; 
	SIGNAL t_pipe_y2  : INTEGER := 120;
	SIGNAL b_pipe_y2  : INTEGER := 500; 
	
	--x axis location
    SIGNAL pipe_onex  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11); --560
    SIGNAL pipe_twox  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(800, 11); --560	
    SIGNAL pipe_onexmotion, pipe_twoxmotion : STD_LOGIC_VECTOR(10 DOWNTO 0); --speed for both pipes

    SIGNAL CNT : STD_LOGIC := '0'; --drives the LFSR(random generator for pipe height
    SIGNAL random : STD_LOGIC_VECTOR(2 DOWNTO 0); --random inputs

	
COMPONENT LFSR 
  port (
    i_Clk       : in std_logic;
    GAME_STARTS : in std_logic;
    COLLISION   : IN STD_LOGIC;
    O_seq       : out std_logic_vector(2 downto 0)
    );
END COMPONENT;
BEGIN
	red   <= NOT(pipe_on) AND NOT(pipe_on2); -- color setup for red ball on white background
	green <= '1';
	blue  <= NOT(pipe_on) AND NOT(pipe_on2);
pipe1 : PROCESS (pixel_row, pixel_col, t_pipe_y, b_pipe_y, t_pipe_y2, b_pipe_y2) IS
	BEGIN
	 IF ((pixel_col >= pipe_onex - pipe_w) AND (pixel_col <= pipe_onex + pipe_w)) THEN
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
first_ipe : PROCESS
BEGIN    
    WAIT UNTIL rising_edge(V_sync);
        IF(GAME_STARTS = '0' or Collision = '1') THEN
              pipe_onex <= conv_std_logic_vector(500, 11);
              pipe_onexmotion <= "00000000000";   
     ELSE
        IF (pipe_onex  > pipe_w and GAME_STARTS = '1') THEN
           pipe_onex <= pipe_onex + pipe_onexmotion;
          pipe_onexmotion <= "11111111100"; -- -4 pixels   
        ELSIF (pipe_onex  <= pipe_w and GAME_STARTS = '1') THEN
                cnt <= NOT(cnt);
                pipe_onex <= CONV_STD_LOGIC_VECTOR(960,11);
                case RANDOM is
                       WHEN "000" => t_pipe_y <= 140; t_pipe_size <= 140; b_pipe_y <= 520; b_pipe_size <= 80;
        
                 WHEN "001" => t_pipe_y <= 100; t_pipe_size <= 100; b_pipe_y <= 480; b_pipe_size <= 120;
        
                 WHEN "010" => t_pipe_y <= 60; t_pipe_size <= 60; b_pipe_y <= 440; b_pipe_size <= 160;
        
                    WHEN "011" => t_pipe_y <= 20; t_pipe_size <= 20; b_pipe_y <= 400; b_pipe_size <= 200;
        
                     WHEN "100" => t_pipe_y <= 80; t_pipe_size <= 80; b_pipe_y <= 450; b_pipe_size <= 150;
        
                     WHEN "101" =>   t_pipe_y <= 150; t_pipe_size <= 150; b_pipe_y <= 540; b_pipe_size <= 60;
                     WHEN "110" =>  t_pipe_y <= 120; t_pipe_size <= 120; b_pipe_y <= 500; b_pipe_size <= 100;
        
                     WHEN "111" =>  t_pipe_y <= 180; t_pipe_size <= 180; b_pipe_y <= 520; b_pipe_size <= 80;
                END CASE;
        END IF;
      END IF;
END PROCESS;
pipe2 : PROCESS (pixel_row, pixel_col, t_pipe_y2, b_pipe_y2) IS
	BEGIN	
	 IF ((pixel_col >= pipe_twox - pipe_w) AND (pixel_col <= pipe_twox + pipe_w)) THEN
        IF ((pixel_row >= t_pipe_y2 - t_pipe_size2) AND (pixel_row <= t_pipe_y2 + t_pipe_size2)) OR
           ((pixel_row >= b_pipe_y2 - b_pipe_size2) AND (pixel_row <= b_pipe_y2 + b_pipe_size2)) THEN
            pipe_on2 <= '1';
        ELSE
            pipe_on2 <= '0';
        END IF;
    ELSE
        pipe_on2 <= '0';
    END IF;
END PROCESS;
Second_pipe : PROCESS IS
BEGIN    
    WAIT UNTIL rising_edge(V_sync);
     IF(GAME_STARTS = '0' or Collision = '1') THEN
              pipe_twox <= conv_std_logic_vector(800, 11);
               pipe_twoxmotion <= "00000000000";   

     ELSE
        IF (pipe_twox  > pipe_w and GAME_STARTS = '1') THEN
           pipe_twox <= pipe_twox + pipe_twoxmotion;
            pipe_twoxmotion <= "11111111100"; --4 speed 
        ELSIF (pipe_twox  <= pipe_w and GAME_STARTS = '1') THEN
            pipe_twox <= CONV_STD_LOGIC_VECTOR(960,11);
                      case RANDOM is
                        WHEN "000" => t_pipe_y2 <= 120; t_pipe_size2 <= 120; b_pipe_y2 <= 500; b_pipe_size2 <= 100;
                         WHEN "011" => t_pipe_y2 <= 100; t_pipe_size2 <= 100; b_pipe_y2 <= 450; b_pipe_size2 <= 150;
                         WHEN "110" => t_pipe_y2 <= 60; t_pipe_size2 <= 60; b_pipe_y2 <= 440; b_pipe_size2 <= 160;
                         WHEN OTHERS => t_pipe_y2 <= 180; t_pipe_size2 <= 180; b_pipe_y2 <= 550; b_pipe_size2 <= 50;
                     END CASE; 
        END IF;
      END IF;     
END PROCESS;
    --updating buffers to ouputs
    pipe_onepos <= pipe_onex;
    pipe_twopos   <= pipe_twox;
    top_p_size  <= t_pipe_size;
    bottom_p_size <= b_pipe_size;
    top_pipe_y <= t_pipe_y;
    bottom_pipe_y <= b_pipe_y;
    top_p_size2 <= t_pipe_size2;
    bottom_p_size2  <= b_pipe_size2;
    top_pipe_y2 <= t_pipe_y2;
    bottom_pipe_y2 <= b_pipe_y2;
    
  
   random_gen : LFSR
    PORT MAP(
    i_Clk      => CNT,
    GAME_STARTS => GAME_STARTS,
    COLLISION => COLLISION,
    O_seq       => random
    );

END Behavioral;