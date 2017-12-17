library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Test_tb is
end VGA_Test_tb;

architecture behave of VGA_Test_tb is

	-- 25 MHz = 40 ns period
	constant c_CLOCK_PERIOD : time := 40 ns;

	signal r_CLOCK : std_logic := '0';
	signal r_ACTIVE : std_logic := '1';
	
	signal w_HSYNC : std_logic;
	signal w_VSYNC : std_logic;
	
	signal w_red0 : std_logic;
	signal w_red1 : std_logic;
	signal w_red2 : std_logic;
	
	signal w_grn0 : std_logic;
	signal w_grn1 : std_logic;
	signal w_grn2 : std_logic;
	
	signal w_blu0 : std_logic;
	signal w_blu1 : std_logic;
	signal w_blu2 : std_logic;

	shared variable r_ENDSIM : boolean := false;
begin

	-- Instantiate the UUT
	UUT : entity work.VGA_Test
	port map (
		i_Clk => r_CLOCK,
		o_VGA_HSync => w_HSYNC,
		o_VGA_VSync => w_VSYNC,
		o_VGA_Red_0 => w_red0,
		o_VGA_Red_1 => w_red1,
		o_VGA_Red_2 => w_red2,
		o_VGA_Grn_0 => w_grn0,
		o_VGA_Grn_1 => w_grn1,
		o_VGA_Grn_2 => w_grn2,
		o_VGA_Blu_0 => w_blu0,
		o_VGA_Blu_1 => w_blu1,
		o_VGA_Blu_2 => w_blu2
	);

	p_CLK_GEN : process is
  	begin
		if (r_ENDSIM = false) then
        	wait for c_CLOCK_PERIOD/2;
        	r_CLOCK <= not r_CLOCK;
		else
        	wait;
		end if;
	end process p_CLK_GEN;

	process
	begin
		wait for 500 ms;
		r_ENDSIM := true;
		wait;
	end process;
end behave;
