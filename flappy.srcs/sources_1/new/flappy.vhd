LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY flappy IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        BTNC   : IN std_logic ;
        BTNU   : IN STD_LOGIC;
        RESET  : IN STD_LOGIC;
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    --    DISPLAY_SCORE : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    ); 
END flappy;

ARCHITECTURE Behavioral OF flappy IS
    SIGNAL random : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    Signal P_red, P_green, P_blue, B_red, B_green, B_Blue, P_red2, P_green2, P_blue2 : STD_LOGIC;
 --   SIGNAL P_red, P_green, P_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
 signal collision : std_logic := '0';
 SIGNAL TEMP    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
 SIGNAL TEMP1    : STD_LOGIC := '0';

    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL p_BTNC :  std_logic; --previous value of button
    SIGNAL c_BTNC : STD_LOGIC; --current value of button
    SIGNAL bird_pos : std_logic_vector (10 downto 0);
    SIGNAL wing_pos : STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL count    :std_logic_vector(20 downto 0) := CONV_STD_LOGIC_VECTOR(0,21);
    SIGNAL wing_speed, bird_speed : STD_LOGIC_VECTOR(10 downto 0) := CONV_STD_LOGIC_VECTOR(4,11);
    SIGNAL GAME_STARTS : std_logic := '0';--game waiting to start
    SIGNAL O_RST, c_BTNU: std_logic;
    signal toggle : std_logic := '0';
    SIGNAL conditions : std_logic_vector(1 downto 0);
    SIGNAL Display_S : std_logic_vector(15 downto 0);
    
    --pipes
    CONSTANT pipe_w    : INTEGER := 40; --radius of pipe;
	SIGNAL pipe_onex  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11); --560
   SIGNAL pipe_twox  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(800, 11); --560

	SIGNAL t_pipe_size  : INTEGER := 140; --560
	SIGNAL b_pipe_size  : INTEGER := 80; --560
	SIGNAL t_pipe_y  : INTEGER := 140;-- left outer edge of bird l --560
	SIGNAL b_pipe_y  : INTEGER := 520; -- left outer edge of bird l --530
	
    SIGNAL t_pipe_size2  : INTEGER := 120; --560
	SIGNAL b_pipe_size2  : INTEGER := 100; --560
	SIGNAL t_pipe_y2  : INTEGER := 120;-- left outer edge of bird l --560
	SIGNAL b_pipe_y2  : INTEGER := 500; -- left outer edge of bird l --530
	
	signal pipe_x_motion, motion : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL CNT : STD_LOGIC := '0';
	SIGNAL contar : STD_LOGIC_VECTOR(20 DOWNTO 0) := (others => '0');
    SIGNAL led_mpx : STD_LOGIC_VECTOR(2 downto 0); --rving led
    
    
    component debounce is
	port(
		i_clk : in std_logic;
		i_btn : in std_logic;
		o_deb : out std_logic
		);
end component;
    
  component bird IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		bird_y    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		wing_y    : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		GAME_STARTS : IN STD_LOGIC;
		BTNU       : IN STD_LOGIC;
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END component;
    
   
COMPONENT pipes IS
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
END COMPONENT;
    
 
COMPONENT LFSR 
  port (
    i_Clk       : in std_logic;
    GAME_STARTS : in std_logic;
    COLLISION   : IN STD_LOGIC;
    O_seq       : out std_logic_vector(2 downto 0)
    );
end COMPONENT;
    
  COMPONENT leddec16 IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END COMPONENT;  
    
    
 
    
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
      
BEGIN
S_RED <= P_RED AND B_RED AND P_RED2;
S_GREEN <= P_GREEN AND B_GREEN AND P_GREEN2;
S_BLUE <= P_BLUE AND B_BLUE AND P_BLUE2;
LED_MPX <= contar(19 DOWNTO 17);

    
    refresh: process(clk_in) is
    begin
    if(rising_edge(clk_in)) THEN
        contar <= contar + 1;
        if(count>=1700000)THEN
            toggle <= NOT(toggle);
            count <= (others => '0');
        else
            count <= count +1;
         end if;
     end if;
    end process;
        
    
    bird_motion: PROCESS IS
    BEGIN
        p_BTNC <= c_BTNC;
        conditions <= COLLISION & GAME_STARTS; -- combines collision and game_starts
        WAIT UNTIL RISING_EDGE(TOGGLE);
            if(c_BTNU = '1') THEN
                bird_pos <=  CONV_STD_LOGIC_VECTOR(320, 11); --initally positions     
                wing_pos <=  CONV_STD_LOGIC_VECTOR(320, 11);
            else
                if(O_RST = '1' and GAME_STARTS = '0') THEN   ---resets for new game
                GAME_STARTS <= '1';
                else
                    case(conditions) is
                        WHEN "01" =>   --Game is on and there is no collision
                            if(p_BTNC = '1' and C_BTNC = '0' AND bird_pos>=0 AND bird_pos<540) THEN --if button released and valid range bird moves up
                                bird_pos <= bird_pos -60;
                                wing_pos <= wing_pos -60;  
                            elsif(bird_pos < 540) THEN  --else drops 4 pixels/frame
                                bird_pos <= bird_pos +6;
                                wing_pos <= wing_pos +6;
                            elsif(bird_pos >= 540) THEN  --game ends
                                bird_pos <= CONV_STD_LOGIC_VECTOR(540, 11);
                                Game_Starts <= '0';
                            end if;
                       WHEN OTHERS => --Collision
                            IF(conditions = "11") then
                                GAME_STARTS <= '0';
                                bird_pos <= bird_pos;
                                wing_pos <= wing_pos;
                             END IF;
                     end case;
                 end if;
            end if;
    end process;
 
 first_ipe : PROCESS
BEGIN    
    WAIT UNTIL rising_edge(toggle);
        IF(GAME_STARTS = '0' or Collision = '1') THEN
              pipe_onex <= conv_std_logic_vector(500, 11);
              pipe_x_motion <= "00000000000";   
     ELSE
        IF (pipe_onex  > pipe_w and GAME_STARTS = '1') THEN
           pipe_onex <= pipe_onex + pipe_x_motion;
           pipe_x_motion <= "11111111000"; -- -4 pixels   
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
 
Second_pipe : PROCESS IS
BEGIN    
    WAIT UNTIL rising_edge(toggle);
     IF(GAME_STARTS = '0' or Collision = '1') THEN
              pipe_twox <= conv_std_logic_vector(800, 11);
               motion <= "00000000000";   

     ELSE
        IF (pipe_twox  > pipe_w and GAME_STARTS = '1') THEN
           pipe_twox <= pipe_twox + motion;
            motion <= "11111111000"; 
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
 
 
 
 
 
 collide : process
   BEGIN    
       WAIT UNTIL RISING_EDGE(TOGGLE); 
       --logic for first pair pipe
      IF (180+10) >= pipe_onex-pipe_w AND (180 - 10) <= (pipe_onex + pipe_w) THEN
         If ( (bird_pos +10) >= (t_pipe_y - t_pipe_size) AND (bird_pos-10) <= (t_pipe_y + t_pipe_size) ) OR
            ( (bird_pos +10) >= (b_pipe_y - b_pipe_size) AND (bird_pos-10) <= (b_pipe_y + b_pipe_size) ) THEN
            collision <= '1';
          else 
            collision <= '0'; --somehow this made the code work idk
          END IF;
       --logic for second pair pipe 
      ELSIF (180+10) >= pipe_twox-pipe_w AND (180 - 10) <= (pipe_twox + pipe_w) THEN
         If ( (bird_pos +10) >= (t_pipe_y2 - t_pipe_size2) AND (bird_pos-10) <= (t_pipe_y2 + t_pipe_size2) ) OR
            ( (bird_pos +10) >= (b_pipe_y2 - b_pipe_size2) AND (bird_pos-10) <= (b_pipe_y2 + b_pipe_size2) ) THEN
            collision <= '1';
          else 
            collision <= '0'; --somehow this made the code work idk    
         END IF;
       else
              collision <= '0';
      END IF;        
   END PROCESS;  
   
   
 SCORING : process 
    begin  
        WAIT UNTIL rising_edge(toggle);
            if(GAME_STARTS = '0' or COLLISION = '1') then 
                DISPLAY_S <= (others => '0');
                temp <= "00";
                temp1 <= '0';
            elsif(GAME_STARTS = '1' ) then
               if((pipe_onex+pipe_w <= 160) AND (temp = "00"))  then
                    DISPLAY_S <= DISPLAY_S +1;   
                    temp <= "01"; 
               elsif((pipe_twox+pipe_w <= 160) AND (temp = "01")) then
                    DISPLAY_S <= DISPLAY_S +1;   
                    temp <= "00";                 
               elsif(pipe_onex+pipe_w > 160) AND (temp /= "01") then
                    temp <= "00"; 
                    DISPLAY_S <= DISPLAY_S;
               else
                    DISPLAY_S <= DISPLAY_S;
               end if;
  --            if((pipe_twox+pipe_w <= wing_pos-10) AND (temp1 = '0')) then
 --                   DISPLAY_S <= DISPLAY_S +1;
  --                  temp1 <= '1';
   --            elsif(pipe_twox+pipe_w > wing_pos-10) then
    --                temp1 <= '0'; 
    --               DISPLAY_S <= DISPLAY_S;
    --           end if;
               
            end if;
       
    end process;
   
 Display_S <= DISPLAY_S  ; 
   
   
   
   
   
   
   
    debouncing : debounce
    PORT MAP(
        i_clk => clk_in,
        i_btn => BTNC,
        o_deb => c_BTNC
        );
    r_debouncing : debounce
      PORT MAP( 
      i_clk => clk_in,
      i_btn => RESET,
      o_deb => o_RST
      );    
      
      START : debounce
      PORT MAP( 
      i_clk => clk_in,
      i_btn => BTNU,
      o_deb => c_BTNU
      );    
    
    
    add_bird : bird
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col,
        bird_y => bird_pos, 
        wing_y => wing_pos,
        GAME_STARTS => GAME_STARTS,
        BTNU     => c_BTNU,
        red => B_RED, 
        green => B_GREEN, 
        blue => B_BLUE
    );
    
    random_gen : LFSR
    PORT MAP(
    i_Clk      => CNT,
    GAME_STARTS => GAME_STARTS,
    COLLISION => COLLISION,
    O_seq       => random
    );
    
    
  first_pipe : pipes
 port map(
    v_sync => S_vsync,
    pixel_row => S_pixel_row,
    pixel_col => S_pixel_col,
    pipe_x => pipe_onex,
    GAME_STARTS => GAME_STARTS,
    BTNU => BTNU,
     t_pipe_size =>  t_pipe_size ,
     b_pipe_size => b_pipe_size, 
     t_pipe_y =>  t_pipe_y,
     b_pipe_y =>  b_pipe_y,
    
    red      => P_red,
		green   => P_green,
		blue    => P_blue
    
);                                            
                                                 
  Second : pipes
--GENERIC MAP(
 --   top_pipe_height    => 160,
  --  bottom_pipe_height =>540,
 --   t_pipe_h           => 160,
 --   b_pipe_h           => 60)
 port map(
    v_sync => S_vsync,
    pixel_row => S_pixel_row,
    pixel_col => S_pixel_col,
    pipe_x => pipe_twox,
    GAME_STARTS => GAME_STARTS,
    BTNU => BTNU,
     t_pipe_size =>  t_pipe_size2 ,
     b_pipe_size => b_pipe_size2, 
     t_pipe_y =>  t_pipe_y2,
     b_pipe_y =>  b_pipe_y2,
    
    red      => P_red2,
		green   => P_green2,
		blue    => P_blue2
    
);  

score: leddec16 
	PORT MAP(
		dig => LED_MPX,
		data => DISPLAY_S,
		anode => SEG7_ANODE,
		seg  => SEG7_seg
		);




    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
END Behavioral;