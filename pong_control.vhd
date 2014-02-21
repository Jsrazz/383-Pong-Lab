----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:29:32 02/14/2014 
-- Design Name: 
-- Module Name:    pong_control - Behavioral 
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

entity pong_control is
  port (
          clk         : in std_logic;
          reset       : in std_logic;
          up          : in std_logic;
          down        : in std_logic;
          v_completed : in std_logic;
          ball_x      : out unsigned(10 downto 0);
          ball_y      : out unsigned(10 downto 0);
          paddle_y    : out unsigned(10 downto 0)
  );
end pong_control;


architecture Behavioral of pong_control is


	COMPONENT Button_Logic
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		button_in : IN std_logic;          
		button_out : OUT std_logic
		);
	END COMPONENT;

signal x_dir, y_dir, x_dir_reg, y_dir_reg, sig_up, sig_down, up_pulse, down_pulse, game_over_next,game_over, x_next, y_next : std_logic;
signal counter_reg, counter_next : unsigned(10 downto 0);
signal ball_x_reg, ball_x_next, ball_y_reg, ball_y_next, paddle_next, paddle_reg : unsigned(10 downto 0);


type state_type is (moving, right, top, bottom, game_over_state, paddle_hit);
signal state_reg, next_state : state_type;


constant b_width : integer := 5;
constant screen_height : integer := 480;
constant screen_width : integer := 640;
constant paddle_height : integer := 50;
constant paddle_width : integer := 15;
constant ball_speed : integer := 15;


begin

  Inst_up_Button_Logic: Button_Logic PORT MAP(
		clk =>clk ,
		reset => reset,
		button_in => up,
		button_out => up_pulse
	);
	
	Inst_dwn_Button_Logic: Button_Logic PORT MAP(
		clk =>clk ,
		reset =>reset ,
		button_in =>down ,
		button_out =>down_pulse 
	);

		process(clk, reset) 
		begin

			if(reset = '1') then
				paddle_reg <= "00010010000";
			elsif(rising_edge(clk)) then
				paddle_reg <= paddle_next;
			end if;
		end process;


		process(up_pulse, down_pulse, paddle_reg, paddle_next)
		begin

		paddle_next <= paddle_reg;

			if(up_pulse = '1' and paddle_reg > 55) then		
				paddle_next <= paddle_reg - 10;	
			elsif(down_pulse = '1' and paddle_reg < 430) then		
				paddle_next <= paddle_reg + 10;	
			end if;

		end process;




	counter_next <= (others=>'0') when counter_reg >= ball_speed else
				  counter_reg + 1 when v_completed = '1' else
				  counter_reg;
					    

	process(clk, reset)
	begin
		if reset = '1' then
			counter_reg <= (others => '0');
		elsif rising_edge(clk) then
			counter_reg <= counter_next;
		end if;
	end process;

process (clk,reset) is
begin


		if ( reset = '1' ) then
		 ball_x_reg <= "00101000000";
		 ball_y_reg <= "00011110000";
		 elsif (rising_edge(clk)) then
		 ball_x_reg <= ball_x_next;
		 ball_y_reg <= ball_y_next;	 
		end if; 
	end process;
	
	process(clk, reset)
begin

		if(reset = '1')then	
			x_dir <= '1';
			y_dir <= '1';
			game_over <= '0';
		elsif(rising_edge(clk))then
			x_dir <= x_next;
			y_dir <= y_next;
			game_over <= game_over_next;
		end if;

end process;
		 
		 process (clk,reset)
		 begin
		 if (reset = '1') then
			state_reg <= moving;
			elsif (rising_edge(clk)) then
			state_reg <= next_state;
		end if;
		end process;
		
		
		
		
		
		process (state_reg, next_state, ball_x_reg, ball_y_reg,counter_next,paddle_reg) is
		begin 
		next_state <= state_reg;
		if (counter_reg >= ball_speed) then
			case state_reg is 
				when moving =>
						if (ball_x_reg > (screen_width - 5)) then
								next_state <= right;
						elsif (ball_x_reg < 2) then
								next_state <= game_over_state;
						end if;
						
						if (ball_y_reg > (screen_height - 5)) then
								next_state <= bottom;
						elsif (ball_y_reg < 2) then
								next_state <= top;
						end if;
						
						
						
				when right=>
					next_state <= moving;
				when bottom=>
					next_state <= moving;
				when top=>
					next_state <= moving;
				when paddle_hit=>
					next_state <= moving;	
				when game_over_state =>
				
			end case;
		end if;
		end process;
		 
		 process (counter_next)
		 begin 
		 
		 ball_x_next <= ball_x_reg;
		 ball_y_next <= ball_y_reg;
		 
		 if (counter_next = 0 and v_completed = '1' and game_over = '0') then
				if (x_dir = '1') then
					ball_x_next <= ball_x_reg +1;
					else 
					ball_x_next <= ball_x_reg -1;
				end if;
				
				if (y_dir = '1') then
					ball_y_next <= ball_y_reg +1;
					else 
					ball_y_next <= ball_y_reg -1;
				end if; 
			end if;
			
		end process;
		
		
		process( state_reg, ball_x_reg, ball_y_reg, next_state, counter_next, game_over )
		begin

			x_next <= x_dir;
			y_next <= y_dir;
			game_over_next <= game_over;

		if(counter_next = 0) then

		case state_reg is 
			when moving =>
				x_next <= x_dir;
				y_next <= y_dir;	
			when top =>
				y_next <= '0';

			when right =>
				x_next <= '0';

			when bottom =>
				y_next <= '1';

			when paddle_hit =>
				y_next <= '1';
				x_next <= '1';	
			when game_over_state=>
				game_over_next <= '1';
				x_next <= '1';

		end case;	
		end if;

		end process;
		
		paddle_y <= paddle_reg;
		ball_x <= ball_x_reg;
		ball_y <= ball_y_reg;

		end Behavioral;

