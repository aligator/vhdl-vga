library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity VGA_Sync_Gen is
	generic (
		g_Active_Count : integer;
		g_Sync_Count : integer;
		g_Back_Count : integer;
		g_Border_Count : integer;
		g_Front_Count : integer
	);
	
	port (
		i_Clk : in std_logic;
		i_Count_Clk : in std_logic;
		i_Active : in std_logic;
		o_Sync : out std_logic;
		o_Video_Active : out std_logic;
		o_Pos : out integer range 0 to g_Active_Count -1;
		o_Sync_End : out std_logic
	);
end VGA_Sync_Gen;


architecture RTL of VGA_Sync_Gen is

	signal r_Sync : std_logic := '0';
	signal r_Sync_End : std_logic := '0';
	
	CONSTANT c_Total_Count : integer := g_Sync_Count + g_Back_Count + g_Border_Count + g_Active_Count + g_Border_Count + g_Front_Count;
	-- When the Position is visible
	CONSTANT c_Active_Start_Count : integer := g_Sync_Count + g_Back_Count + g_Border_Count;

	signal r_Count : integer range 0 to c_Total_Count-1 := 0;
	
	signal r_Video_Active : std_logic := '0';
	
	signal r_Pos : integer range 0 to g_Active_Count := 0;
begin


	p_VGA_Count : process (i_Count_Clk)
	begin
        if i_Active = '1' then
        	if rising_edge(i_Count_Clk) then
        		
        		if r_Count = c_Total_Count-1 then
        			r_Count <= 0;
        			r_Sync_End <= '1';
        		else
        			r_Count <= r_Count + 1;
        			r_Sync_End <= '0';
        		end if;
        		
        	end if;
        else
        	r_Count <= 0;
        end if;
	end process p_VGA_Count;

	p_VGA_Sync_Gen : process (i_Clk)
	begin
        if i_Active = '1' then
        	
			-- Sync Time
			if r_Count < g_Sync_Count then
				r_Sync <= '0';
				r_Video_Active <= '0';

			-- Back Porch
			elsif r_Count < (g_Sync_Count + g_Back_Count) then
				r_Sync <= '1';
				r_Video_Active <= '0';

			-- ActiveFull
			elsif r_Count < (g_Sync_Count + g_Back_Count + g_Border_Count + g_Active_Count + g_Border_Count) then
				r_Sync <= '1';
				
				if r_Count >= c_Active_Start_Count then
					r_Video_Active <= '1';
				end if;				

			-- Front Porch
			elsif r_Count < c_Total_Count then
				r_Sync <= '1';
				r_Video_Active <= '0';

			end if;
	    end if;
	end process p_VGA_Sync_Gen;
			
	p_VGA_Pos : process (i_Clk)
	begin
        if i_Active = '1' then
			if r_Count >= c_Active_Start_Count AND r_Count < (c_Active_Start_Count + g_Active_Count) then
				r_Pos <= r_Count - c_Active_Start_Count;
			else
				r_Pos <= 0;
			end if;
			
		end if;
	end process p_VGA_Pos;
	    
    o_Sync <= r_Sync and i_Active;
    o_Video_Active <= r_Video_Active and i_Active;
	o_Pos <= r_Pos;
	o_Sync_End <= r_Sync_End and i_Active;
	
	
end RTL;
