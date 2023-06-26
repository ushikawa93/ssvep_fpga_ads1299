--==================================================
--	GIBIC-LEICI  
--
-- FIle: ads131.vhd
-- Author: Federico N. Guerrero
--	Description: Librería de defines para el ADS131
-- Date: 11/11/2022
--==================================================  
library ieee;
use ieee.std_logic_1164.all;

package ADS1299 is
        CONSTANT WAKEUP: std_LOGIC_VECTOR(7 downto 0) := X"02";
		  CONSTANT STANDBY: std_LOGIC_VECTOR(7 downto 0) := X"04";
		  CONSTANT RESET: std_LOGIC_VECTOR(7 downto 0) := X"06";
		  CONSTANT START: std_LOGIC_VECTOR(7 downto 0) := X"08";
		  CONSTANT STOP: std_LOGIC_VECTOR(7 downto 0) := X"0A";
		  CONSTANT RDATAC: std_LOGIC_VECTOR(7 downto 0) := X"10";
		  CONSTANT SDATAC: std_LOGIC_VECTOR(7 downto 0) := X"11";
        CONSTANT RDATA: std_LOGIC_VECTOR(7 downto 0) := X"12";
		  CONSTANT RREG: std_LOGIC_VECTOR(7 downto 0) := X"20";
		  CONSTANT WREG: std_LOGIC_VECTOR(7 downto 0) := X"40";
		  
		  -- CONFIG1 : 
		  -- -- bit 7		: 1 Reserved
		  -- -- bit 6		: 1 daisy-chain disabled 
		  -- -- bit 5		: 0 clk-output disabled
		  -- -- bit 4		: 1 Reserved
		  -- -- bit 3		: 0 Reserved
		  -- -- bit [2:0]	: DR 000=64kHz a 110 250 Hz 
		  CONSTANT CONFIG1: std_LOGIC_VECTOR(7 downto 0) := "11010110";
		  
		  -- CONFIG2 : 
		  -- -- bit [7:5]	: 110 Reserved 
		  -- -- bit 4		: 1 test-signal generated internally
		  -- -- bit 3		: 0 Reserved
		  -- -- bit 2		: 0 Test amplitude 
		  -- -- bit [1:0]	: 00 Test Freq: 00, 01, 10=Not used, 11 DC 
		  CONSTANT CONFIG2: std_LOGIC_VECTOR(7 downto 0) := "11000000";
		  
		  -- CONFIG3 : 
		  -- -- bit 7		: 1 Enable internal reference buffer
		  -- -- bit 6		: 1 Reserved
		  -- -- bit 5		: 1 Reserved
		  -- -- bit 4		: 0 Bias measurement disabled
		  -- -- bit 3		: Bias ref internal
		  -- -- bit 2		: 1 Enable Op-amp
		  -- -- bit [1:0]	: 00 Bias sense disabled
		  CONSTANT CONFIG3: std_LOGIC_VECTOR(7 downto 0) := "11101100";
		  
		  CONSTANT LOFF: std_LOGIC_VECTOR(7 downto 0) := "00000000";
		  
		   -- CHnSET : 
		  -- -- bit 7		: 0 Normal operation (not powered down)
		  -- -- bit [6:4]	: 000 Gain 1 Valid all but 111
		  -- -- bit 3		: 0 SRB open
		  -- -- bit [2:0]	: 101 MUX 000 normal, 001 short, 101 test
		  CONSTANT CHnSET: std_LOGIC_VECTOR(7 downto 0) := "00010001";
		  
		  CONSTANT DIR_ID: std_LOGIC_VECTOR(7 downto 0) := X"00";
		  CONSTANT DIR_CONFIG1: std_LOGIC_VECTOR(7 downto 0) := X"01";
		  CONSTANT DIR_CONFIG2: std_LOGIC_VECTOR(7 downto 0) := X"02";
		  CONSTANT DIR_CONFIG3: std_LOGIC_VECTOR(7 downto 0) := X"03";
		  CONSTANT DIR_LOFF: std_LOGIC_VECTOR(7 downto 0) := X"04";
		  CONSTANT DIR_CH1SET: std_LOGIC_VECTOR(7 downto 0) := X"05";
		  CONSTANT DIR_CH2SET: std_LOGIC_VECTOR(7 downto 0) := X"06";
		  CONSTANT DIR_CH3SET: std_LOGIC_VECTOR(7 downto 0) := X"07";
		  CONSTANT DIR_CH4SET: std_LOGIC_VECTOR(7 downto 0) := X"08";
		  CONSTANT DIR_CH5SET: std_LOGIC_VECTOR(7 downto 0) := X"09";
		  CONSTANT DIR_CH6SET: std_LOGIC_VECTOR(7 downto 0) := X"0A";
		  CONSTANT DIR_CH7SET: std_LOGIC_VECTOR(7 downto 0) := X"0B";
		  CONSTANT DIR_CH8SET: std_LOGIC_VECTOR(7 downto 0) := X"0C";
		  
end package ADS1299;

package body ADS1299 is
      
end package body ADS1299;