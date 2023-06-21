--==================================================
--	GIBIC-LEICI  
--
-- FIle: parallel_sum.vhd
-- Author: Federico N. Guerrero
--	Description: Realiza el procesamiento
-- Date: 15/11/2022
--================================================== 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;

library work;
use work.utilidades.all;

entity parallel_sum is
	port(
		rst			: 	in std_logic; --Reset signal
		clk_in		:	in std_logic; --Base clock input
		buf			:  in buf_t;
		samp_out		: 	out std_logic_vector(31 downto 0);
		sum_en		: 	in std_logic;
		sum_ready	: 	out std_logic;
		modo			:  in std_logic_vector(1 downto 0); 
		debug			:	out std_logic_vector(1 downto 0)
	);
end entity;

architecture rtl of parallel_sum is
	signal b1,b2,b3,b4,b5,b6,b7,b8 : std_logic_vector(23 downto 0);
	signal s1,s2,s3,s4,s5,s6,s7,s8 : signed(23 downto 0);
	signal e1,e2,e3,e4,e5,e6,e7,e8 : signed(31 downto 0);
	
	signal ps1,ps2 : signed(31 downto 0);
	
	signal t1 : signed(31 downto 0);
	signal sdebug: std_logic_vector(1 downto 0);
	
	signal test : std_logic_vector(7 downto 0);
	
	type state_type_sum is ( SUM_WAIT_EN, SUM_CVT_S24, SUM_CVT_S32, SUM_SUM1, SUM_SUMOUT, SUM_CVT_SUMOUT, SUM_NOTIFY );
	signal state_sum   : state_type_sum;
	
begin 

	debug <= sdebug;
	
	sum_data: process(clk_in)
	variable ch1 : signed(23 downto 0);
	variable ch_out : signed(31 downto 0);
	variable tog : std_logic;
   begin
		if rst = '1' then 
			s1 <= X"000000";
			s2 <= X"000000";
			s3 <= X"000000";
			s4 <= X"000000";
			s5 <= X"000000";
			s6 <= X"000000";
			s7<= X"000000";
			s8<= X"000000";
			t1 <= X"00000000";
			sdebug <= "00";
			test <= X"41";
			sum_ready <= '0';
			tog := '0';
		else 
			if rising_edge(clk_in) then	

				case state_sum is
				
					-- Delay
					-- Se incrementa de a 5 porque con el clock en 200 Megas cada ejecución
					-- de la máquina será con un período de 5 ns 
					when SUM_WAIT_EN =>
						sum_ready <= '0';
						if sum_en = '1' then 
							b1 <=  buf(3)&buf(4)&buf(5);
							b2 <=  buf(6)&buf(7)&buf(8);
							b3 <=  buf(9)&buf(10)&buf(11);
							b4 <=  buf(12)&buf(13)&buf(14);
							b5 <=  buf(15)&buf(16)&buf(17);
							b6 <=  buf(18)&buf(19)&buf(20);
							b7 <=  buf(21)&buf(22)&buf(23);
							b8 <=  buf(24)&buf(25)&buf(26);			
							state_sum <= SUM_CVT_S24;
						end if;
							
						
					when SUM_CVT_S24 =>
							s1 <=  signed(b1);
							s2 <=  signed(b2);
							s3 <=  signed(b3);
							s4 <=  signed(b4);
							s5 <=  signed(b5);
							s6 <=  signed(b6);
							s7 <=  signed(b7);
							s8 <=  signed(b8);
							state_sum <= SUM_CVT_S32;
				
					when SUM_CVT_S32 =>
							e1 <=  resize(s1, 32);
							e2 <=  resize(s2, 32);
							e3 <=  resize(s3, 32);
							e4 <=  resize(s4, 32);
							e5 <=  resize(s5, 32);
							e6 <=  resize(s6, 32);
							e7 <=  resize(s7, 32);
							e8 <=  resize(s8, 32);
							state_sum <= SUM_SUM1;
					
					when SUM_SUM1=>
					
							ps1 <=  e1+e2+e3+e4;
							ps2 <=  e5+e6+e7+e8;
							state_sum <= SUM_SUMOUT;
					
					when SUM_SUMOUT=>
							if modo = "01" then
								t1<= e1;
							else 
								t1 <= ps1 + ps2;
							end if;
							state_sum <= SUM_CVT_SUMOUT;
					
					when SUM_CVT_SUMOUT=>
							samp_out <= std_logic_vector(t1);
							state_sum <= SUM_NOTIFY;
							
					when SUM_NOTIFY=>
							sum_ready <= '1';
							state_sum <= SUM_WAIT_EN;
							
				when others =>
							-- LED8 debug para caso de error en FSM
							state_sum <= SUM_WAIT_EN;
							--debugA <= "11";
				end case;
				
			
			
			end if;
		
		end if;
   end process;


end rtl;