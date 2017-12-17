library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity VGA_Sync_Gen is
	generic (
		g_H_Active_Count : integer := 640;
		g_H_Sync_Count : integer := 96;
		g_H_Back_Count : integer := 48;
		g_H_Border_Count : integer := 0;
		g_H_Front_Count : integer := 16;
		
		
		g_V_Active_Count : integer := 480;
		g_V_Sync_Count : integer := 2;
		g_V_Back_Count : integer := 33;
		g_V_Border_Count : integer := 0;
		g_V_Front_Count : integer := 10		
	);
	
	port (
		i_Clk : in std_logic;
		i_Active : in std_logic;
		o_HSync : out std_logic;
		o_VSync : out std_logic;
		o_H_Video_Active : out std_logic;
		o_V_Video_Active : out std_logic;
		o_Pos_X : out integer range 0 to g_H_Active_Count -1;
		o_Pos_Y : out integer range 0 to g_V_Active_Count -1
	);
end VGA_Sync_Gen;


architecture RTL of VGA_Sync_Gen is

	signal r_HSync : std_logic := '0';
	signal r_VSync : std_logic := '0';
	
	signal r_HSync_End : std_logic := '0';
	
	CONSTANT c_H_Total_Count : integer := g_H_Sync_Count + g_H_Back_Count + g_H_Border_Count + g_H_Active_Count + g_H_Border_Count + g_H_Front_Count;
	-- When the Position is visible
	CONSTANT c_H_Active_Start_Count : integer := g_H_Sync_Count + g_H_Back_Count + g_H_Border_Count;

	CONSTANT c_V_Total_Count : integer := g_V_Sync_Count + g_V_Back_Count + g_V_Border_Count + g_V_Active_Count + g_V_Border_Count + g_V_Front_Count;
	-- When the Position is visible
	CONSTANT c_V_Active_Start_Count : integer := g_V_Sync_Count + g_V_Back_Count + g_V_Border_Count;

	signal r_H_Count : integer range 0 to c_H_Total_Count-1 := 0;
	signal r_V_Count : integer range 0 to c_V_Total_Count-1 := 0;
	
	signal r_H_Video_Active : std_logic := '0';
	signal r_V_Video_Active : std_logic := '0';
	
	signal r_Pos_X : integer range 0 to g_H_Active_Count := 0;
	signal r_Pos_Y : integer range 0 to g_V_Active_Count-1 := 0;
begin


	p_VGA_HCount : process (i_Clk)
	begin
        if i_Active = '1' then
        	if rising_edge(i_Clk) then
        		
        		if r_H_Count = c_H_Total_Count-1 then
        			r_H_Count <= 0;
        			r_HSync_End <= '1';
        		else
        			r_H_Count <= r_H_Count + 1;
        			r_HSync_End <= '0';
        		end if;
        		
        	end if;
        else
        	-- r_SM_HSync <= s_Idle;
        	r_H_Count <= 0;
        	--r_H_Video_Active <= '0';
        end if;
	end process p_VGA_HCount;

	
	p_VGA_VCount : process (r_HSync_End)
	begin
        if i_Active = '1' then
        	if rising_edge(r_HSync_End) then
        		
        		if r_V_Count = c_V_Total_Count-1 then
        			r_V_Count <= 0;
        		else
        			r_V_Count <= r_V_Count + 1;
        		end if;
        		
        	end if;
        else
        	-- r_SM_HSync <= s_Idle;
        	r_V_Count <= 0;
        	--r_V_Video_Active <= '0';
        end if;
	end process p_VGA_VCount;


	p_VGA_HSync_Gen : process (i_Clk)
	begin
        if i_Active = '1' then
        	
			-- Sync Time
			if r_H_Count < g_H_Sync_Count then
				r_HSync <= '0';
				r_H_Video_Active <= '0';

			-- Back Porch
			elsif r_H_Count < (g_H_Sync_Count + g_H_Back_Count) then
				r_HSync <= '1';
				r_H_Video_Active <= '0';

			-- ActiveFull
			elsif r_H_Count < (g_H_Sync_Count + g_H_Back_Count + g_H_Border_Count + g_H_Active_Count + g_H_Border_Count) then
				r_HSync <= '1';
				
				if r_H_Count >= c_H_Active_Start_Count then
					r_H_Video_Active <= '1';
				end if;				

			-- Front Porch
			elsif r_H_Count < c_H_Total_Count then
				r_HSync <= '1';
				r_H_Video_Active <= '0';

			end if;
	    end if;
	end process p_VGA_HSync_Gen;

	p_VGA_VSync_Gen : process (i_Clk)
	begin
		if i_Active = '1' then
			-- Sync Time
			if r_V_Count < g_V_Sync_Count then
				r_VSync <= '0';
				r_V_Video_Active <= '0';

			-- Back Porch
			elsif r_V_Count < (g_V_Sync_Count + g_V_Back_Count) then
				r_VSync <= '1';
				r_V_Video_Active <= '0';

			-- Active
			elsif r_V_Count < (g_V_Sync_Count + g_V_Back_Count + g_V_Border_Count + g_V_Active_Count + g_V_Border_Count) then
				r_VSync <= '1';
				if r_V_Count >= c_V_Active_Start_Count then
					r_V_Video_Active <= '1';
				end if;	

			-- Front Porch
			elsif r_V_Count < c_V_Total_Count then
				r_VSync <= '1';
				r_V_Video_Active <= '0';

			end if;
	    end if;
	end process p_VGA_VSync_Gen;

			
	p_VGA_Pos : process (i_Clk)
	begin
        if i_Active = '1' then
			if r_H_Count >= c_H_Active_Start_Count AND r_H_Count < (c_H_Active_Start_Count + g_H_Active_Count) then
				r_Pos_X <= r_H_Count - c_H_Active_Start_Count;
			else
				r_Pos_X	<= 0;
			end if;
			
			if r_V_Count >= c_V_Active_Start_Count AND r_V_Count < (c_V_Active_Start_Count + g_V_Active_Count) then
				r_Pos_Y <= r_V_Count - c_V_Active_Start_Count;
			else
				r_Pos_Y	<= 0;
			end if;
		end if;
	end process p_VGA_Pos;
	
	--p_VGA_Reset_Y : process (r_V_Video_Active)
	--begin
	--	if rising_edge(r_V_Video_Active) then
	--		r_Pos_Y <= 0;
	--	end if;
	--end process p_VGA_Reset_Y;

    
    o_HSync <= r_HSync and i_Active;
    o_VSync <= r_VSync and i_Active;
    o_H_Video_Active <= r_H_Video_Active and i_Active;
    o_V_Video_Active <= r_V_Video_Active and i_Active;
	
	
    o_Pos_X <= r_Pos_X;
    o_Pos_Y <= r_Pos_Y;
	-- Create a signal for simulation purposes (allows waveform display)
	--w_SM_Main <= "000" when r_SM_Main = s_Idle else
	--						 "001" when r_SM_Main = s_TX_Start_Bit else
	--						 "010" when r_SM_Main = s_TX_Data_Bits else
	--						 "011" when r_SM_Main = s_TX_Stop_Bit else
	--						 "100" when r_SM_Main = s_Cleanup else
	--						 "101"; -- should never get here
	
end RTL;
