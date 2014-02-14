----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:10:59 02/04/2014 
-- Design Name: 
-- Module Name:    pixel_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity pixel_gen is
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
			--  ball_x   : in unsigned(10 downto 0);
         --  ball_y   : in unsigned(10 downto 0);
         --  paddle_y : in unsigned(10 downto 0);
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
end pixel_gen;


architecture Behavioral of pixel_gen is


begin

	process(row, column, blank) is
	begin 
	r <= "00000000";
	g <= "00000000";
	b <= "00000000";
	
		if (blank = '0') then
			if ((((column > 200) and (column < 215)) and ((row > 80) and (row < 300)))
			or (((column > 213) and (column < 280)) and ((row > 80) and (row < 100)))
			or (((column > 213) and (column < 280)) and ((row > 150) and (row < 170)))
			or (((column > 279) and (column < 294)) and ((row > 80) and (row < 300)))
			or (((column > 320) and (column < 335)) and ((row > 80) and (row < 300)))
			or (((column > 334) and (column < 400)) and ((row > 80) and (row < 100)))
			or (((column > 334) and (column < 400)) and ((row > 150) and (row < 170)))
			)
			then
				r <= "00010110";
				g <= "00111100";
				b <= "10111010";
				
				end if;
				
	end if;
	end process;
					
	
		


end Behavioral;

