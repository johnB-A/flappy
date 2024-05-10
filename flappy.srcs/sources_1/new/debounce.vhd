library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity debounce is
	port(
		i_clk : in std_logic;
		i_btn : in std_logic;
		o_deb : out std_logic
		);
end debounce;

architecture RTL of debounce is 
	constant count    : integer := 1048575;
	constant num_bits : integer := 19; --94.3 hz 10.6 ms debounce
	signal counter    : std_logic_vector(num_bits downto 0) := (others => '0');
	signal sample     : std_logic_vector(4 downto 0) := (others => '0');
	signal r_deb      : std_logic := '0';

begin
	process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(to_integer(unsigned(counter)) < count) then --10.6 ms
				counter <= std_logic_vector(unsigned(counter) + 1);
				sample <= sample(3 downto 0) & i_btn; --keep sampling
			else  --if polling time is met
				if(sample = "11111") then  --if button is NOT bouncing
					counter <= (others => '0');  
					r_deb <= '1';
				else 
					r_deb <= '0';
					counter <= (others => '0');  
				end if;
			end if;
		end if;
	end process;			
	o_deb <= r_deb;			
end RTL;
	
	
					
			