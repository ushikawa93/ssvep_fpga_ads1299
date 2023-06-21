--==================================================
--	GIBIC-LEICI  
--
-- FIle: utilities.vhd
-- Author: Federico N. Guerrero
--	Description: Utilidades para el procesamiento
-- Date: 15/11/2022
--================================================== 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_SIGNED.ALL;


package utilidades is
	Type buf_t is array (26 downto 0) of std_logic_vector (7 downto 0) ;
end package utilidades; 
package body utilidades is
end package body utilidades;

--==================================================
--	GIBIC-LEICI  
--
-- FIle: utilities.vhd
-- Author: Federico N. Guerrero
--	Description: Buffer ping-pong
-- Date: 15/11/2022
--================================================== 


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity bpp is
port(
	clk_in : in std_logic;
	rst: in std_logic;
	data_in_1 : in std_logic_vector(31 downto 0);
	data_in_2 : in std_logic_vector(31 downto 0);
	data_in_3 : in std_logic_vector(31 downto 0);
	data_in_4 : in std_logic_vector(31 downto 0);
	data_in_en : in std_logic;	
	data_out_req : in std_logic;
	data_out : out std_logic_vector(7 downto 0);
	buf_available : out std_logic;
	debug : out std_logic_vector(2 downto 0)
);
end entity;

architecture rtl of bpp is

	constant buf_depth : integer:= 10;	
	constant N: integer:= 32;	
	constant bytes_per_word : integer := 5;
	signal word_out : std_logic_vector(4*N-1 downto 0);
	signal byte_sel: std_logic_vector(4 downto 0);
	

	-- Buffer ping pong
	type bpp_t is array (0 to buf_depth-1) of std_logic_vector(4*N-1 downto 0);
	signal bpp_memoria_1  : bpp_t; 
	signal bpp_memoria_2  : bpp_t; 
	signal bpp_idx_w: integer:= 0;
	signal signal_tx_all : std_logic:='0'; 

	-- Maquina de estados de escritura
	type state_type_bpp is (	BPP_INIT, BPP_FILL1, BPP_FILL2, 
										BPP_CHANGE_F1_to_F2, BPP_CHANGE_F2_to_F1,
										BPP_WAIT_CEF1, BPP_WAIT_CEF2,
										BPP_INC_WORD1, BPP_INC_WORD2
										);
	signal state_bpp   : state_type_bpp;
	
	-- Maquina de estados de lectura
	type state_type_bppr is (	BPPR_WAIT_AVAILABLE,
										BPPR_NEW_WORD,
										BPPR_NEXT_BYTE,
										BPPR_NEXT_WORD,
										BPPR_WAIT_REQ,
										BPPR_WAIT_CDOR,
										BPPR_END_WORD	);
	signal state_bppr   : state_type_bppr;
	signal bppr_idx_word: integer:= 0;


	
	-- Compartida
	signal signal_buf_available: std_logic;
	signal buf_to_read : std_logic;				-- MATI: ESTE ERA UN INTEGER Y SE EL COMPILADOR SE QUEJABA DE SU VALOR EN RESET. LO CAMBIE POR STD_LOGIC
															-- EL BUFFER 1 SERIA CUANDO ESTA SEÑAL ESTA EN 0, Y EL BUFFER 2 CUANDO ESTA EN 1
															
	signal data_in_1_reg : std_logic_vector(31 downto 0);
	signal data_in_2_reg : std_logic_vector(31 downto 0);
	signal data_in_3_reg : std_logic_vector(31 downto 0);
	signal data_in_4_reg : std_logic_vector(31 downto 0);
	signal data_in_en_reg : std_logic;


begin


	bpp_write: process (clk_in)
	begin
		if rst = '1' then 
			signal_buf_available <= '0';
			buf_available 			<= '0';
			buf_to_read 			<= '0';
			state_bpp 				<= BPP_INIT;	
			state_bppr 				<= BPPR_WAIT_AVAILABLE;	
			data_in_en_reg 		<= '0';
			
		else 
			if (rising_edge(clk_in)) then
				
				------------------------------------------------
				-- Registro la señal de entrada ----------------
				------------------------------------------------		
				
				data_in_1_reg <= data_in_1;
				data_in_2_reg <= data_in_2;
				data_in_3_reg <= data_in_3;
				data_in_4_reg <= data_in_4;
				data_in_en_reg <= data_in_en;
				
				------------------------------------------------
				-- Manejo de escritura -------------------------
				------------------------------------------------
				case state_bpp is
				
					when BPP_INIT =>
							signal_buf_available <= '0';
							state_bpp <= BPP_FILL1;
							bpp_idx_w <= 0;
							
					-- Llenado de buffer 1
					when BPP_FILL1 =>
							signal_buf_available <= '0';
							if data_in_en_reg = '1' then
								bpp_memoria_1(bpp_idx_w) <= data_in_4_reg & data_in_3_reg & data_in_2_reg & data_in_1_reg ;
								state_bpp <= BPP_INC_WORD1;														
							end if;
					when BPP_INC_WORD1 =>		
							bpp_idx_w <= bpp_idx_w + 1;
							state_bpp <= BPP_WAIT_CEF1;														
					when BPP_WAIT_CEF1 =>
							if data_in_en_reg = '0' then
								if bpp_idx_w = buf_depth then 
									state_bpp <= BPP_CHANGE_F1_to_F2;
								else 
									state_bpp <= BPP_FILL1;
								end if;		
							end if;
							
					
					when BPP_CHANGE_F1_to_F2 =>
							bpp_idx_w <= 0;
							signal_buf_available <= '1';
							buf_to_read <= '0';
							state_bpp <= BPP_FILL2;							
							debug(1) <= '1';
												
			
					-- Llenado de buffer 2			
					when BPP_FILL2 =>
							signal_buf_available <= '0';
							if data_in_en_reg = '1' then
								bpp_memoria_2(bpp_idx_w) <= data_in_4_reg & data_in_3_reg & data_in_2_reg & data_in_1_reg ;
								state_bpp <= BPP_INC_WORD2;
							end if;
					when BPP_INC_WORD2 =>		
							bpp_idx_w <= bpp_idx_w + 1;
							state_bpp <= BPP_WAIT_CEF2;	
					when BPP_WAIT_CEF2 =>
							if data_in_en_reg = '0' then
								if bpp_idx_w = buf_depth then 
									state_bpp <= BPP_CHANGE_F2_to_F1;
								else 
									state_bpp <= BPP_FILL2;
								end if;
							end if;
							
					when BPP_CHANGE_F2_to_F1 =>
							bpp_idx_w <= 0;
							signal_buf_available <= '1';
							buf_to_read <= '1';
							state_bpp <= BPP_FILL1;
							debug(1) <= '0';
													
							
					when others =>
							state_bpp <= BPP_INIT;
				end case;
				
				------------------------------------------------
				-- Manejo de lectura
				------------------------------------------------
				case state_bppr is
					when BPPR_WAIT_AVAILABLE =>
						
						if signal_buf_available = '1' then	
							state_bppr <= BPPR_NEW_WORD;
							bppr_idx_word <= 0;
							buf_available <= '1';
							debug(2) <= '1';	
						end if;
				
					when BPPR_NEW_WORD =>
						if buf_to_read = '0' then
							word_out <= bpp_memoria_1(bppr_idx_word);
						elsif buf_to_read = '1' then
							word_out <= bpp_memoria_2(bppr_idx_word);
						end if;
						state_bppr <= BPPR_WAIT_REQ;					
						
					when BPPR_WAIT_REQ =>
						if data_out_req = '1' then 	
							state_bppr <= BPPR_WAIT_CDOR;													
						end if;
						
					when BPPR_WAIT_CDOR =>
						if data_out_req = '0' then
							byte_sel <= byte_sel + '1';
							state_bppr <= BPPR_NEXT_BYTE;
						end if;						
								
					when BPPR_NEXT_BYTE =>
						
						if byte_sel = "10001" then 	
							byte_sel <= "00000";
							state_bppr <= BPPR_END_WORD;
						else
							state_bppr <= BPPR_WAIT_REQ;
						end if;							
				
				
					when BPPR_END_WORD =>						
						bppr_idx_word <= bppr_idx_word + 1;
						state_bppr <= BPPR_NEXT_WORD;
					
					when BPPR_NEXT_WORD =>						
						if bppr_idx_word = buf_depth then 
							state_bppr <= BPPR_WAIT_AVAILABLE;
							buf_available <= '0';
							debug(2) <= '0';	
						else
							state_bppr <= BPPR_NEW_WORD;
						end if;
						
				
					when others =>
							state_bppr <= BPPR_WAIT_AVAILABLE;
							
				end case;
				
			end if;
		end if;
	end process;
	

	data_mux: with byte_sel select
				 data_out <=  	word_out(7  downto  0) when "00000",
									word_out(15 downto  8) when "00001",
									word_out(23 downto 16) when "00010",
									word_out(31 downto 24) when "00011",
									
									word_out(39 downto  32) when "00100",
									word_out(47 downto  40) when "00101",
									word_out(55 downto 48) when "00110",
									word_out(63 downto 56) when "00111",
									
									word_out(71 downto  64) when "01000",
									word_out(79 downto  72) when "01001",
									word_out(87 downto 80) when "01010",
									word_out(95 downto 88) when "01011",
									
									word_out(103 downto  96) when "01100",
									word_out(111 downto  104) when "01101",
									word_out(119 downto 112) when "01110",
									word_out(127 downto 120) when "01111",

									X"0F"						  when "10000",
									X"00" when others;

					

end rtl;