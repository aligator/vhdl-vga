library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Sync_Gen_tb is
end VGA_Sync_Gen_tb;

architecture behave of VGA_Sync_Gen_tb is

	-- 25 MHz = 40 ns period
	constant c_CLOCK_PERIOD : time := 40 ns;

	signal r_CLOCK : std_logic := '0';
	signal r_ACTIVE : std_logic := '1';
	
	signal w_HSync : std_logic;
	signal w_VSync : std_logic;
	
	signal w_H_Video_Active : std_logic;
	signal w_V_Video_Active : std_logic;
	
	signal w_Pos_X : integer;
	signal w_Pos_Y : integer;
	
	signal w_HSync_End : std_logic;


	shared variable r_ENDSIM : boolean := false;
begin

	-- Instantiate the UUT
	HSync : entity work.VGA_Sync_Gen
	generic map (
		g_Active_Count => 640,
		g_Sync_Count => 96,
		g_Back_Count => 48,
		g_Border_Count => 0,
		g_Front_Count => 16
	)
	port map (
	
        i_Clk => r_CLOCK,
		i_Count_Clk => r_CLOCK,
        i_Active => r_ACTIVE,
        o_Sync => w_HSync,
		o_Video_Active => w_H_Video_Active,
		o_Pos => w_Pos_X,
		o_Sync_End => w_HSync_End
	);
		
	VSync : entity work.VGA_Sync_Gen
	generic map (
		g_Active_Count => 480,
		g_Sync_Count => 2,
		g_Back_Count => 33,
		g_Border_Count => 0,
		g_Front_Count => 10
	)
	port map (
	
        i_Clk => i_Clk,
		i_Count_Clk => w_HSync_End,
        i_Active => r_ACTIVE,
        o_Sync => w_VSync,
		o_Video_Active => w_V_Video_Active,
		o_Pos => w_Pos_Y
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
