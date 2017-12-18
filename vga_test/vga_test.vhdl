library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Unsigned

entity vga_test is
	port (
		i_Clk : in std_logic;
		o_VGA_HSync : out std_logic;
		o_VGA_VSync : out std_logic;
		o_VGA_Red_0 : out std_logic;
		o_VGA_Red_1 : out std_logic;
		o_VGA_Red_2 : out std_logic;
		o_VGA_Grn_0 : out std_logic;
		o_VGA_Grn_1 : out std_logic;
		o_VGA_Grn_2 : out std_logic;
		o_VGA_Blu_0 : out std_logic;
		o_VGA_Blu_1 : out std_logic;
		o_VGA_Blu_2 : out std_logic
		
	);
end vga_test;

architecture rtl of vga_test is
	signal w_HSync : std_logic;
	signal w_VSync : std_logic;
	signal w_H_Video_Active : std_logic;
	signal w_V_Video_Active : std_logic;
	signal w_Pos_X : integer;
	signal w_Pos_Y : integer;
    
	signal w_HSync_End : std_logic;


	signal w_red : std_logic := '0';
	signal w_grn : std_logic := '0';
	signal w_blu : std_logic := '0';

begin
	e_HSync : entity work.VGA_Sync_Gen
	generic map (
		g_Active_Count => 640,
		g_Sync_Count => 96,
		g_Back_Count => 48,
		g_Border_Count => 0,
		g_Front_Count => 16
	)
	port map (
        i_Clk => i_Clk,
		i_Count_Clk => i_Clk,
        i_Active => '1',
        o_Sync => w_HSync,
		o_Video_Active => w_H_Video_Active,
		o_Pos => w_Pos_X,
		o_Sync_End => w_HSync_End
	);
		
	e_VSync : entity work.VGA_Sync_Gen
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
        i_Active => '1',
        o_Sync => w_VSync,
		o_Video_Active => w_V_Video_Active,
		o_Pos => w_Pos_Y
	);
	
	p_draw : process(i_Clk) 
  	begin
		if (w_Pos_Y >= 50 AND w_Pos_Y <= 80) OR (w_Pos_Y >= 400 AND w_Pos_Y <= 430) then
			w_red <= '1';
		else
			w_red <= '0';
		end if;
			
		if (w_Pos_X >= 50 AND w_Pos_X <= 80) OR (w_Pos_X >= 580 AND w_Pos_X <= 610) then
			w_blu <= '1';
		else
			w_blu <= '0';
		end if;
			
		if (w_Pos_Y = 0 OR w_Pos_Y = 479) OR (w_Pos_x = 0 OR w_Pos_x = 639) then
			w_grn <= '1';
		else
			w_grn <= '0';
		end if;
		
	end process p_draw;
	
	o_VGA_Red_0 <= w_H_Video_Active AND w_V_Video_Active AND w_red;
	o_VGA_Red_1 <= w_H_Video_Active AND w_V_Video_Active AND w_red;
	o_VGA_Red_2 <= w_H_Video_Active AND w_V_Video_Active AND w_red;
	
	o_VGA_Grn_0 <= w_H_Video_Active AND w_V_Video_Active AND w_grn;
	o_VGA_Grn_1 <= w_H_Video_Active AND w_V_Video_Active AND w_grn;
	o_VGA_Grn_2 <= w_H_Video_Active AND w_V_Video_Active AND w_grn;
	
	o_VGA_Blu_0 <= w_H_Video_Active AND w_V_Video_Active AND w_blu;
	o_VGA_Blu_1 <= w_H_Video_Active AND w_V_Video_Active AND w_blu;
	o_VGA_Blu_2 <= w_H_Video_Active AND w_V_Video_Active AND w_blu;
	
	o_VGA_HSync <= w_HSync;
	o_VGA_VSync <= w_VSync;


end rtl;