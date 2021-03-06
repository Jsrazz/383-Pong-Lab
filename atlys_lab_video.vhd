----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:46:42 02/04/2014 
-- Design Name: 
-- Module Name:    atlys_lab_video - Behavioral 
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
entity atlys_lab_video is
  port (
          clk   : in  std_logic; -- 100 MHz
          reset : in  std_logic;
          up    : in  std_logic;
          down  : in  std_logic;
          tmds  : out std_logic_vector(3 downto 0);
          tmdsb : out std_logic_vector(3 downto 0)
  );
end atlys_lab_video;
architecture razz of atlys_lab_video is
    -- TODO: Signals, as needed
	 
	 COMPONENT vga_sync
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		h_sync : OUT std_logic;
		v_sync : OUT std_logic;
		v_completed : OUT std_logic;
		blank : OUT std_logic;
		row : OUT unsigned(10 downto 0);
		column : OUT unsigned(10 downto 0)
		);
	END COMPONENT;
	
		COMPONENT pixel_gen
	PORT(
		row : IN unsigned(10 downto 0);
		column : IN unsigned(10 downto 0);
		blank : IN std_logic;
		ball_x : IN unsigned(10 downto 0);
		ball_y : IN unsigned(10 downto 0);
		paddle_y : IN unsigned(10 downto 0);          
		r : OUT std_logic_vector(7 downto 0);
		g : OUT std_logic_vector(7 downto 0);
		b : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT pong_control
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		up : IN std_logic;
		down : IN std_logic;
		v_completed : IN std_logic;          
		ball_x : OUT unsigned(10 downto 0);
		ball_y : OUT unsigned(10 downto 0);
		paddle_y : OUT unsigned(10 downto 0)
		);
	END COMPONENT;
	
	
	 signal pixel_clk, serialize_clk, serialize_clk_n, red_s, blue_s, green_s, blank, h_sync, v_sync, clock_s, v_comp_sig : std_logic;
	 signal red, blue, green : std_logic_vector(7 downto 0);
	 signal sig_row, sig_column : unsigned(10 downto 0);
	 signal ball_x_sig, ball_y_sig, paddle_y_sig : unsigned(10 downto 0);
	 
	 
begin


	Inst_pixel_gen: pixel_gen PORT MAP(
		row => sig_row ,
		column => sig_column ,
		blank => blank ,
		ball_x => ball_x_sig  ,
		ball_y => ball_y_sig ,
		paddle_y => paddle_y_sig ,
		r => red ,
		g => green ,
		b => blue
	);
	
		Inst_pong_control: pong_control PORT MAP(
		clk => clk ,
		reset => reset ,
		up => up,
		down => down ,
		v_completed => v_comp_sig,
		ball_x => ball_x_sig,
		ball_y => ball_y_sig,
		paddle_y => paddle_y_sig
	);
	 

	
	Inst_vga_sync: vga_sync PORT MAP(
		clk => pixel_clk,
		reset => reset,
		h_sync => h_sync,
		v_sync => v_sync,
		v_completed => v_comp_sig,
		blank => blank,
		row => sig_row,
		column => sig_column
	);

	 

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

    -- TODO: VGA component instantiation
    -- TODO: Pixel generator component instantiation

    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank,
                hsync     => h_sync,
                vsync     => v_sync,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end razz;