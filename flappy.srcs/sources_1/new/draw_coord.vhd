LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY draw_coord IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		x_size : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		y_size : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		b_size : IN integer;
		shape_on : out std_logic

	);
END draw_coord;

ARCHITECTURE Behavioral OF draw_coord IS

BEGIN
	draw : PROCESS (x_size, y_size, pixel_row, pixel_col) IS
		VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0);
	BEGIN
        IF pixel_col <= x_size THEN -- vx = |ball_x - pixel_col|
            vx := x_size - pixel_col;
        ELSE
            vx := pixel_col - x_size;
        END IF;
        IF pixel_row <= y_size THEN -- vy = |ball_y - pixel_row|
            vy := y_size - pixel_row;
        ELSE
            vy := pixel_row - y_size;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (b_size * b_size) THEN -- test if radial distance < bsize
            shape_on <= '1';
        ELSE
            shape_on <= '0';
        END IF;
    END PROCESS;
		

	
	 
END Behavioral;