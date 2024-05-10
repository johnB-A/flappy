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
    ); 
END flappy;

ARCHITECTURE Behavioral OF flappy IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals for vga display
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL P_red, P_green, P_blue, B_red, B_green, B_Blue : STD_LOGIC;
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL collision : std_logic := '0';
    SIGNAL TEMP    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";

    SIGNAL p_BTNC :  std_logic; --previous value of button
   SIGNAL c_BTNC : STD_LOGIC; --current value of button
    SIGNAL bird_pos : std_logic_vector (10 downto 0);
    SIGNAL wing_pos : STD_LOGIC_VECTOR(10 downto 0);
    SIGNAL count    :std_logic_vector(20 downto 0) := CONV_STD_LOGIC_VECTOR(0,21);
    SIGNAL GAME_STARTS : std_logic;--game waiting to start
    SIGNAL O_RST, c_BTNU: std_logic;
    SIGNAL Display_S : std_logic_vector(15 downto 0);
    
    --pipes
    CONSTANT pipe_w    : INTEGER := 40; --pipe_width;
    --pipe 1 
	SIGNAL pipe_onex  : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL t_pipe_size  : INTEGER; 
	SIGNAL b_pipe_size  : INTEGER;
	SIGNAL t_pipe_y  : INTEGER ;
	SIGNAL b_pipe_y  : INTEGER ;	
	--pipe2
	SIGNAL pipe_twox  : STD_LOGIC_VECTOR(10 DOWNTO 0) ;
    SIGNAL t_pipe_size2  : INTEGER;
	SIGNAL b_pipe_size2  : INTEGER;
	SIGNAL t_pipe_y2  : INTEGER ;
	SIGNAL b_pipe_y2  : INTEGER ;
	SIGNAL cnt : STD_LOGIC_VECTOR(20 DOWNTO 0) := (others => '0');
	SIGNAL led_mpx : STD_LOGIC_VECTOR(2 downto 0); --drives the mpx refresh rate
	
    component debounce is
	port(
		i_clk : in std_logic;
		i_btn : in std_logic;
		o_deb : out std_logic
		);
end component;

COMPONENT bird IS
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
END COMPONENT;

 COMPONENT pipes IS
	PORT (
		v_sync        : IN STD_LOGIC;
		pixel_row     : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col     : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
		COLLISION     : IN STD_LOGIC;
		GAME_STARTS   : IN STD_LOGIC;
		red           : OUT STD_LOGIC;
		green         : OUT STD_LOGIC;
		blue          : OUT STD_LOGIC;
		pipe_onepos   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		pipe_twopos   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		top_p_size    : OUT INTEGER range 0 to 600;
		bottom_p_size : OUT INTEGER range 0 to 600;
		top_pipe_y    : OUT INTEGER range 0 to 600;
		bottom_pipe_y : OUT INTEGER range 0 to 600;
		top_p_size2   : OUT INTEGER range 0 to 600;
		bottom_p_size2 : OUT INTEGER range 0 to 600;
		top_pipe_y2   : OUT INTEGER range 0 to 600;
		bottom_pipe_y2  : OUT INTEGER range 0 to 600
		 );
END COMPONENT;   

COMPONENT leddec16 IS
	PORT (
		dig : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit (4-digit) data
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
        hsync     : OUT STD_LOGIC;
        vsync     : OUT STD_LOGIC;
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
S_RED <= P_RED AND B_RED;
S_GREEN <= P_GREEN AND B_GREEN;
S_BLUE <= P_BLUE AND B_BLUE;
LED_MPX <= cnt(19 DOWNTO 17);

mpx_refrsh: PROCESS(clk_in) is
begin
    if(rising_edge(clk_in)) THEN
        cnt <= cnt + 1;
     end if;
 END PROCESS;
 collide : PROCESS
 BEGIN    
      WAIT UNTIL RISING_EDGE(S_vsync); 
       --logic for first pair pipe
      IF (180+10) >= pipe_onex-pipe_w AND (180 - 10) <= (pipe_onex + pipe_w) THEN
         IF ( (bird_pos +10) >= (t_pipe_y - t_pipe_size) AND (bird_pos-10) <= (t_pipe_y + t_pipe_size) ) OR
            ( (bird_pos +10) >= (b_pipe_y - b_pipe_size) AND (bird_pos-10) <= (b_pipe_y + b_pipe_size) ) THEN
            collision <= '1';
          ELSE 
            collision <= '0'; --somehow this made the code work idk
          END IF;
       --logic for second pair pipe 
      ELSIF (180+10) >= pipe_twox-pipe_w AND (180 - 10) <= (pipe_twox + pipe_w) THEN
         IF ( (bird_pos +10) >= (t_pipe_y2 - t_pipe_size2) AND (bird_pos-10) <= (t_pipe_y2 + t_pipe_size2) ) OR
            ( (bird_pos +10) >= (b_pipe_y2 - b_pipe_size2) AND (bird_pos-10) <= (b_pipe_y2 + b_pipe_size2) ) THEN
            collision <= '1';
          ELSE 
            collision <= '0'; --somehow this made the code work idk    
         END IF;
       ELSE
              collision <= '0';
      END IF;        
 END PROCESS;    
 SCORING : PROCESS 
    BEGIN  
        WAIT UNTIL rising_edge(S_vsync);
            IF(GAME_STARTS = '0' or COLLISION = '1') THEN 
                DISPLAY_S <= (others => '0');
                temp <= "00";
            ELSIF(GAME_STARTS = '1' ) then
               IF((pipe_onex+pipe_w <= 160) AND (temp = "00"))  then
                    DISPLAY_S <= DISPLAY_S +1;   
                    temp <= "01"; 
               ELSIF((pipe_twox+pipe_w <= 160) AND (temp = "01")) then
                    DISPLAY_S <= DISPLAY_S +1;   
                    temp <= "00";                 
               ELSIF(pipe_onex+pipe_w > 160) AND (temp /= "01") then
                    temp <= "00"; 
                    DISPLAY_S <= DISPLAY_S;
               ELSE
                    DISPLAY_S <= DISPLAY_S;
               END IF;
            END IF;    
END PROCESS;   
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
    
add_bird : bird
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col,
        RESET  => O_RST,
        COLLISION => COLLISION,
        BTNC => c_BTNC,
        bird_pos => bird_pos, 
        wing_pos => wing_pos,
        GAME_STARTS => GAME_STARTS,
        red => B_RED, 
        green => B_GREEN, 
        blue => B_BLUE
    );
 pipe_logic : pipes
 port map(
    v_sync => S_vsync,
    pixel_row => S_pixel_row,
    pixel_col => S_pixel_col,
    COLLISION => COLLISION,
    GAME_STARTS => GAME_STARTS,
     red      => P_red,
	green   => P_green,
	blue    => P_blue,
    pipe_onepos => pipe_onex,
    pipe_twopos => pipe_twox,
     top_p_size =>  t_pipe_size ,
     bottom_p_size => b_pipe_size, 
     top_pipe_y =>  t_pipe_y,
     bottom_pipe_y =>  b_pipe_y,
      top_p_size2 =>  t_pipe_size2 ,
     bottom_p_size2 => b_pipe_size2, 
     top_pipe_y2 =>  t_pipe_y2,
    bottom_pipe_y2 =>  b_pipe_y2
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