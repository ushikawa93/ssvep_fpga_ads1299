--==================================================
--	GIBIC-LEICI  
--
-- FIle: rate_gen.vhd
-- Author: Federico N. Guerrero
--	Description: Lectura de datos SPI y transmisión 
-- UART                        
-- Date: 9/11/2022
--================================================== 

use IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity rate_gen is
	generic(
		count		:	in positive;   -- Equal to T*(1/F_clk_in)
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
begin 
	divisor_clock1 process (clk_in)
   begin
		if rst = '1' then 
			clk_out <= '0';
			counter <= X"00000000";
			count_val <= (std_logic_vector(count)  SRL 1);
		else 
			if rising_edge(clk_in) then		  
			
				-- Clock generation
				if counter = count_val then
					counter <= "00000000";
					clk_out <= not clk_out;
				else
					counter <= counter + '1';
				end if;		
		
				
			end if;
		
		end if;
   end process;


end rtl;