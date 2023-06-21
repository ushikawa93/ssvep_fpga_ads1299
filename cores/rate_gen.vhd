--==================================================
--	GIBIC-LEICI  
--
-- FIle: rate_gen.vhd
-- Author: Federico N. Guerrero
--	Description: Genera un clock de menor tasa a 
-- partir de otro.                 
-- Date: 11/11/2022
--================================================== 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rate_gen is
	generic(
		count		:	in integer   -- Equal to T*(1/F_clk_in)
	);
	port(
		rst		: 	in std_logic; --Reset signal
		clk_in	:	in std_logic; --Base clock input
		clk_out	:	out std_logic --Clock output at requested rate
	);
end entity;

architecture rtl of rate_gen is
	signal counter   : std_logic_vector(31 downto 0);
	signal count_val : std_logic_vector(31 downto 0);
	signal gen_clk_out : std_logic;
begin 

	clk_out <= gen_clk_out;

	divisor_clock: process(clk_in)
   begin
		if rst = '1' then 
			gen_clk_out <= '0';
			counter <= X"00000000";
			count_val <= std_logic_vector( shift_right(to_unsigned(count,32),1) );
		else 
			if rising_edge(clk_in) then		  
			
				-- Clock generation
				if counter = count_val then
					counter <= X"00000000";
					gen_clk_out <= not gen_clk_out;
				else
					counter <= counter + '1';
				end if;		
		
				
			end if;
		
		end if;
   end process;


end rtl;