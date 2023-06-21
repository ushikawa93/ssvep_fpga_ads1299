--	Registro SIPO
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sipo_register is
	generic
	(
		bits : integer := 8  -- Parallel Data Bit Width
	);
	port 
	(
		-- Input Ports
		reset       		: in std_logic;
		serial_in        	: in std_logic;
		clk_in	        	: in std_logic;
		
		-- Output Ports
		parallel_out	   : out std_logic_vector((bits-1) downto 0)
	);

end entity sipo_register;

architecture rtl of sipo_register is

signal data : unsigned((bits-1) downto 0);

begin

SIPO: process (reset, clk_in)
begin
	if(reset = '0') then
		data <= (others=>'0');
		parallel_out <= (others =>'0');
	elsif (rising_edge(clk_in)) then
		data <= shift_left(data, 1);
		data(0) <= serial_in;
		parallel_out <= std_logic_vector(data);	
	end if;
end process;


end rtl;