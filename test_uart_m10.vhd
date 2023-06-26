--==================================================
--	GIBIC-LEICI  
--
-- FIle: test_uart_m10.vhd
-- Author: Federico N. Guerrero
--	Description: Lectura de datos SPI y transmisión 
-- UART                        
-- Date: 9/11/2022
--==================================================                       


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library work;
use work.ads1299.all;
use work.utilidades.all;


entity DE10_LITE is
	port 
	(	
		KEY 			: IN STD_LOGIC_VECTOR(1 DOWNTO 0);					-- Pulsadores 
		LEDR 			: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);		-- Leds 
		SW 			: IN STD_LOGIC_VECTOR(9 DOWNTO 0);		-- Switches
		ARDUINO_IO 	: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);	-- Header de conexión compatible arduino
		MAX10_CLK1_50: in std_logic;								-- Oscilador de 50 MHz
		GPIO		: INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		
		HEX0		: OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX1		: OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX2		: OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX3		: OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX4		: OUT STD_LOGIC_VECTOR(0 TO 6);
		HEX5		: OUT STD_LOGIC_VECTOR(0 TO 6)
	
	);
end entity;


architecture rtl of DE10_LITE is
	
	signal mclock : std_logic;
	signal master_reset : std_logic; 
	
	-- Datos procesados
	signal processed_data : std_LOGIC_VECTOR(31 downto 0);
	signal sumador_data_en : std_logic := '0';
	signal sum_ready:			std_logic := '0';
	signal txpc_data_en: std_logic := '0';
	
	signal debugA : std_logic_vector(1 downto 0);
	signal debugB : std_logic_vector(1 downto 0);
	signal debugC : std_logic_vector(3 downto 0);
	
	-- Bus SPI de conexion al ADS
	signal ads_rp		: std_logic; 
	signal ads_clk 	: std_logic; 
	signal ads_start 	: std_logic; 
	signal ads_drdy 	: std_logic; 
	
	signal ads_mosi	: std_logic; 
	signal ads_cs 		: std_logic:='0'; 
	signal ads_sclk 	: std_logic;
	signal ads_miso 	: std_logic; 
	
	signal data_spi_tx : std_logic_vector(7 downto 0);
	signal data_spi_rx : std_logic_vector(7 downto 0);
	signal ads_spi_tx_en: std_logic;
	signal ads_tx_en_ctrl: std_logic;
	signal ads_tx_en_state: std_logic;	
	signal ads_spi_tx_ak: std_logic;

	
	-- Control del adquisidor
	signal ads_init_en: std_logic;
	signal ads_delay_counter: integer := 0;
	signal ads_delay_count: integer := 0;
	signal ads_byte_counter: integer := 0;
	signal ads_byte_to_send : std_lOGIC_VECTOR(7 downto 0);
	signal ads_wreg_reg : std_lOGIC_VECTOR(7 downto 0);
	signal ads_wreg_val : std_lOGIC_VECTOR(7 downto 0);
	
	signal ads_aux_chset : std_lOGIC_VECTOR(7 downto 0);
	
	-- Programacion con switches
	signal prog_config1 	: std_logic_vector(7 downto 0);
	signal prog_aux_dr	: std_logic_vector(2 downto 0);
	signal SWDR : std_logic_vector(2 downto 0);
	
	signal prog_chset   	: std_logic_vector(7 downto 0);
	signal prog_aux_mux	: std_logic_vector(2 downto 0);
	signal SWMU				: std_logic_vector(1 downto 0);
	signal prog_aux_gain : std_logic_vector(2 downto 0);
	signal SWGA : std_logic_vector(2 downto 0);
	
	signal prog_modo_prom: std_logic_vector(1 downto 0);
	signal SWPR : std_logic_vector(1 downto 0);
	
	
	-- Maquina de estados
	type state_type_ads is (	ads_off, 
										ADS_DELAY, ADS_DELAY_IN_PROGRESS,
										ADS_TRANSMIT_START, ADS_TRANSMIT_CLRFLAG, ADS_TRANSMIT_END, ADS_READ_START, ADS_READ_CLRFLAG, ADS_READ_END, ADS_WAIT_SUM,
										ADS_WREG_START, ADS_WREG_NREG, ADS_WREG_WRITEVAL, 
										ADS_WREG_VERIFY_START, ADS_WREG_VERIFY_NREG, ADS_WREG_VERIFY_READ, ADS_WREG_VERIFY_CHECK, ADS_WREG_VERIFY_OK, ADS_WREG_VERIFY_FAIL,
										READING_BYTES_START, READING_BYTES_END, READING_BYTES_INC, READING_BYTES_STORING, READING_BYTES_TX,
										WAIT_FOR_DRDY, ADS_DRDY_PRE, READING_BYTES,
										ads_c1, ads_c2, ads_c3, ads_c4, ads_c5, ads_c6, ads_c7, ads_c8, ads_c9, 
										ads_c10, ads_c11, ads_c12, ads_c13, ads_c14, ads_c15, ads_c16, ads_c17, ads_c18, ads_c19, 
										ads_c20, ads_c21, ads_c22, ads_c23, ads_c24, ads_c25, ads_c26, ads_c27, ads_c28, ads_c29,
										ads_pch1, ads_pch2, ads_pch3, ads_pch4, ads_pch5, ads_pch6, ads_pch7, ads_pch8);
	signal state_ads   : state_type_ads;
	signal ads_next_state   : state_type_ads;
	signal ads_return_delay   : state_type_ads;
	signal ads_return_transmit: state_type_ads;
	signal ads_return_read   : state_type_ads;
	signal ads_return_wreg   : state_type_ads;
	
	-- Memoria 
	--type t_memoria is array (0 to 30) of std_logic_vector(7 downto 0);
	signal memoria  : buf_t; -- definido en utilities
	signal indice_lectura : integer:=0; 
	signal indice_escritura : integer:=0; 
	
	signal pin_spi_mosi: std_logic := '0';
	signal pin_spi_sclk: std_logic := '0';
	signal pin_spi_cs: std_logic := '0';
	
	
	--=============================================
	-- Deteccion de SSVEPS
	--=============================================
	
	-- Señales de salida para deteccion de SSVEPS
	signal amplitud_lockin_1 : std_logic_vector (31 downto 0);
	signal amplitud_lockin_2 : std_logic_vector (31 downto 0);
	signal amplitud_lockin_3 : std_logic_vector (31 downto 0);
	
	signal output_estimulo_1 :std_logic;
	signal output_estimulo_2 : std_logic;
	signal output_estimulo_3 : std_logic;
	
	signal acond_signal : std_logic_vector (31 downto 0);
	
	constant N_LOCKIN : integer := 16;
	constant fs : integer := 250;
	
	constant f_lockin_1 :integer := 16;
	constant f_lockin_2 :integer := 10;
	constant f_lockin_3 :integer := 20;
	
	component lockin_wrapper is
			generic(
				Q_in : integer := 32;
				N_lockin : integer := N_LOCKIN;
				fs : integer := fs;
				f_lockin : integer := 16
			);
			port(
				
				clk : in std_logic;
				reset_n : in std_logic;
				
				x : in std_logic_vector (Q_in-1 downto 0);
				x_valid : in std_logic;
				
				display_0 : out std_logic_vector(0 TO 6);
				display_1 : out std_logic_vector(0 TO 6);
				display_2 : out std_logic_vector(0 TO 6);
				display_3 : out std_logic_vector(0 TO 6);
				display_4 : out std_logic_vector(0 TO 6);
				display_5 : out std_logic_vector(0 TO 6);
				
				signal_out : out std_logic_vector(31 downto 0);
				
				amplitud_salida : out std_logic_vector (31 downto 0);
				estimulo_signal : out std_logic
				
			);
				
	end component lockin_wrapper;

	
begin

	GPIO(1 downto 0) <= debugA;
	--GPIO(3 downto 2) <= debugB;
	--GPIO(3 downto 0) <= debugC;


	--=============================================
	-- Master Reset
	--=============================================
	 master_reset_proc: process (mclock)
	 variable master_reset_count : std_logic_vector(7 downto 0) := X"00";
    begin
        if rising_edge(mclock) then
				if master_reset_count < X"FE" then
					master_reset <= '1';
					master_reset_count := master_reset_count + '1';
				elsif master_reset_count = X"FE" then
					master_reset <= '0';				
				else
					master_reset_count := master_reset_count + '1';
				end if;
        end if;
    end process;
	
	
	
	--=============================================
	-- Generación de clocks 
	--=============================================
	
	master_clock_gen: 
		entity work.master_pll(syn) 
		port map(	inclk0 => MAX10_CLK1_50,
						c0		 => mclock);


						
	--=============================================
	--=============================================
	--=========	SECCIÓN DATOS =====================
	--=============================================
	--=============================================
	
	--========================================
	-- Tansmisión a PC
	--========================================
		
	txpc:	
	entity work.fsm_txpc(rtl) 
		port map(	clk_in => mclock,
						rst => master_reset,
						
						data_in_1 => processed_data, 
						data_en => txpc_data_en,
						
						data_in_2 => amplitud_lockin_1,
						
						data_in_3 => amplitud_lockin_2,
						
						data_in_4 => acond_signal,
						
						pin_tx => ARDUINO_IO(0),
						pin_rx => ARDUINO_IO(1),
						pin_spi_mosi => pin_spi_mosi,
						pin_spi_sclk => pin_spi_sclk,	
						pin_cs => pin_spi_cs,
						debug => debugC);
						
	
	
	--========================================
	-- Suma
	--========================================
	
	sumador:
	entity work.parallel_sum(rtl)
		port map(	rst		=>		master_reset,
						clk_in	=>		mclock,
						buf		=> 	memoria,
						samp_out	=>		processed_data,
						sum_en	=> 	sumador_data_en,
						sum_ready =>	sum_ready,
						modo		=>		prog_modo_prom,
						debug => open
						);	

				
	--=============================================
	--=============================================
	--=========	SECCIÓN SPI ADS ===================
	--=============================================
	--=============================================
	
	
	--=============================================
	-- Asignación de pines
	--=============================================	
	GPIO(11) <= ads_rp;
	ads_clk <= GPIO(13);
	GPIO(15) <= ads_start;
	ads_drdy <= GPIO(17) when rising_edge(mclock);

	GPIO(19) <= ads_mosi;	
	GPIO(21) <= ads_cs; 	
	GPIO(23) <= ads_sclk; 
	ads_miso <= GPIO(25); 
	
	
	-- Transmisión a PC
	GPIO(27) <= pin_spi_mosi;
	GPIO(26) <= pin_spi_sclk;	
	GPIO(28) <= pin_spi_cs;	

   -- Switch de configuración
	---- SW[9] SW[8] SW[7]  
   ---- v[2]  v[1]  v[0]  
	--------------------------
	---- SW[6] SW[5] SW[4] 
	---- g[2]  g[1]  g[0]  
	--------------------------
	---- SW[3] SW[2] 
	---- mx[1] mx[0]
	--------------------------
	---- SW[1] SW[0]
	---- pr[1] pr[0]
	
	-- CONFIG1 : 
   -- -- bit [2:0]	: DR 000=64kHz a 110 1kHz 
	SWDR <= (SW(9)&SW(8)&SW(7));
	with  SWDR select
	prog_aux_dr <= "001" when "001", "010" when "010",
						"011" when "011", "100" when "100",
						"101" when "101", "110" when others; -- 1kHz cuando es 110 y en caso inválido 111
	prog_config1 <= CONFIG1(7 downto 3)&prog_aux_dr;
	
	
	SWGA <= (SW(6)&SW(5)&SW(4));
	with  SWGA select
	prog_aux_gain <=  "001" when "001", "010" when "010",
							"011" when "011", "100" when "100",
							"101" when "101", "110" when "110",
							"000" when others; -- 1 cuando es 001 y en casos inválidos
	
	SWMU	<= (SW(3)&SW(2));
	with  SWMU select
	prog_aux_mux <= 	"000" when "00", 
							"001" when "01",
							"101" when "10", 
							"000" when others; 
	prog_chset <= '0'&prog_aux_gain&'0'&prog_aux_mux;
	
	SWPR	<= (SW(1)&SW(0));
	with  SWPR select
	prog_modo_prom <= "00" when "00", 
							"01" when "01",
							"00" when others; 
	--=============================================
	-- Inicialización de ADS
	--=============================================	
	 
	fsm_ads_init: process (mclock)
	begin
		if master_reset = '1' or KEY(0) = '0' then 
			state_ads <= ads_off;
			ads_tx_en_ctrl<='0';		
			GPIO(8) <= '1';
			LEDR(0) <= '1';
			debugA <= "11";
		else 
			LEDR(0) <= '0';
			if (rising_edge(mclock)) then
				case state_ads is
				
					-- Delay
					-- Se incrementa de a 5 porque con el clock en 200 Megas cada ejecución
					-- de la máquina será con un período de 5 ns 
					when ADS_DELAY =>
						ads_delay_counter <= 0;
						state_ads <= ADS_DELAY_IN_PROGRESS;
					when ADS_DELAY_IN_PROGRESS =>
						if ads_delay_counter = ads_delay_count then 
							state_ads <= ads_return_delay;
						else
							ads_delay_counter <= ads_delay_counter + 10;
						end if;		
						
					-- Transmision para escritura de datos
					when ADS_TRANSMIT_START=>
							data_spi_tx <= ads_byte_to_send;
							ads_spi_tx_en <= '1';
							state_ads <= ADS_TRANSMIT_CLRFLAG;							
					when ADS_TRANSMIT_CLRFLAG=>
							ads_spi_tx_en <= '0';
							ads_return_delay <= ADS_TRANSMIT_END;	
							ads_delay_count <= 3_000;
							state_ads <= ADS_DELAY;							
					when ADS_TRANSMIT_END=>
							state_ads <= ads_return_transmit;
					
					-- Transmision para lectura de datos
					when ADS_READ_START=>
							data_spi_tx <= X"00";
							ads_spi_tx_en <= '1';
							state_ads <= ADS_READ_CLRFLAG;							
					when ADS_READ_CLRFLAG=>
							ads_spi_tx_en <= '0';
							ads_return_delay <= ADS_READ_END;	
							ads_delay_count <= 700;  -- Delay para que termine la transmisión  1_100 para 10 MHz (conf 5)
							state_ads <= ADS_DELAY;							 
					when ADS_READ_END=>
							ads_tx_en_ctrl <= '0';
							state_ads <= ads_return_read;
							
					
					-- Escritura y verificación de registro
					when ADS_WREG_START=>
						
							ads_byte_to_send <= ( X"40" or ads_wreg_reg ); 
							ads_return_transmit <= ADS_WREG_NREG;	
							state_ads <= ADS_TRANSMIT_START;	
					when ADS_WREG_NREG=>
							ads_byte_to_send <= X"00"; 
							ads_return_transmit <= ADS_WREG_WRITEVAL;	
							state_ads <= ADS_TRANSMIT_START;						
					when ADS_WREG_WRITEVAL=>
							ads_byte_to_send <= ads_wreg_val;
							ads_return_transmit <= ADS_WREG_VERIFY_START;	
							state_ads <= ADS_TRANSMIT_START;							
					when ADS_WREG_VERIFY_START=>
							-- RREG 010r rrrr  r_rrrr addr
							ads_byte_to_send <= X"20" or ads_wreg_reg; 
							ads_return_transmit <= ADS_WREG_VERIFY_NREG;	
							state_ads <= ADS_TRANSMIT_START;	
					when ADS_WREG_VERIFY_NREG=>
							ads_byte_to_send <=  X"00";
							ads_return_transmit <= ADS_WREG_VERIFY_READ;	
							state_ads <= ADS_TRANSMIT_START;						
					when ADS_WREG_VERIFY_READ =>
							-- Si bien es lectura uso transmit por el delay 
							ads_byte_to_send <=  X"00";
							ads_return_transmit <= ADS_WREG_VERIFY_CHECK;
							state_ads <= ADS_TRANSMIT_START;
					when ADS_WREG_VERIFY_CHECK=>
							if data_spi_rx = ads_wreg_val then 
								state_ads <= ADS_WREG_VERIFY_OK;
							else
								state_ads <= ADS_WREG_VERIFY_FAIL;
							end if;							
					when ADS_WREG_VERIFY_OK=>
							-- Se apaga si todo está OK
							LEDR(9) <= '0';							
							state_ads <= ads_return_wreg;
					when ADS_WREG_VERIFY_FAIL=>
							-- Sigue prendido si fracasó
							LEDR(9) <= '1';
							state_ads <= ads_off;					
							
			
					-- Apagado 
					when ads_off=>
							-- LED 9 ON CUANDO NO SE CONFIGURÓ
							LEDR(9) <= '1';
							-- Pines a 0
							ads_start <= '0';
							ads_cs <= '0';
							ads_rp <= '0';
							-- Delay						
							ads_return_delay <= ads_c1;	
							ads_delay_count <= 1_000_000; 
							state_ads <= ADS_DELAY;											
					
					-- Enciende pwdn-rst
					when ads_c1=>
							ads_start <= '1';
							ads_rp <= '1';
							ads_return_delay <= ads_c2;
							ads_delay_count <= 200_000_000;
							state_ads <= ADS_DELAY;
					when ads_c2=>
							ads_byte_to_send <= SDATAC;
							ads_return_transmit <= ads_c3;
							state_ads <= ADS_TRANSMIT_START;	
					when ads_c3=>
							ads_byte_to_send <= STOP;
							ads_return_transmit <= ads_c20;
							state_ads <= ADS_TRANSMIT_START;	
					when ads_c20=>
							ads_rp <= '0';
							ads_byte_to_send <= RESET;
							ads_return_transmit <= ads_c21;
							state_ads <= ADS_TRANSMIT_START;	
					when ads_c21=>
							ads_rp <= '1';
							ads_delay_count <= 200_000_000;
							ads_return_delay <= ads_c22;
							state_ads <= ADS_DELAY;
					when ads_c22=>
							ads_byte_to_send <= SDATAC;
							ads_return_transmit <= ads_c23;
							state_ads <= ADS_TRANSMIT_START;	
					when ads_c23=>
							ads_byte_to_send <= STOP;
							ads_return_transmit <= ads_c4;
							state_ads <= ADS_TRANSMIT_START;	
					when ads_c4 =>
							ads_wreg_reg <= DIR_CONFIG1;
							ads_wreg_val <= prog_config1;
							ads_return_wreg <= ads_c5;					
							state_ads <= ADS_WREG_START;
					when ads_c24=>
							ads_delay_count <= 200_000_000;
							ads_return_delay <= ads_c5;
							state_ads <= ADS_DELAY;
					when ads_c5=>
							ads_wreg_reg <= DIR_CONFIG2;
							ads_wreg_val <= CONFIG2;
							ads_return_wreg <= ads_c6;					
							state_ads <= ADS_WREG_START;
					when ads_c6=>
							ads_wreg_reg <= DIR_CONFIG3;
							ads_wreg_val <= CONFIG3;
							ads_return_wreg <= ads_c7;					
							state_ads <= ADS_WREG_START;
					when ads_c7=>
							ads_wreg_reg <= DIR_LOFF;
							ads_wreg_val <= LOFF;
							ads_return_wreg <= ads_c10;					
							state_ads <= ADS_WREG_START;
					when ads_c10=>
							state_ads <= ads_pch1;	
							
					when ads_pch1=>
							ads_wreg_reg <= DIR_CH1SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch2;					
							state_ads <= ADS_WREG_START;
					when ads_pch2=>
							ads_wreg_reg <= DIR_CH2SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch3;					
							state_ads <= ADS_WREG_START;
					when ads_pch3=>
							ads_wreg_reg <= DIR_CH3SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch4;					
							state_ads <= ADS_WREG_START;
					when ads_pch4=>
							ads_wreg_reg <= DIR_CH4SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch5;					
							state_ads <= ADS_WREG_START;
					when ads_pch5=>
							ads_wreg_reg <= DIR_CH5SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch6;					
							state_ads <= ADS_WREG_START;
					when ads_pch6=>
							ads_wreg_reg <= DIR_CH6SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch7;					
							state_ads <= ADS_WREG_START;
					when ads_pch7=>
							ads_wreg_reg <= DIR_CH7SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_pch8;					
							state_ads <= ADS_WREG_START;
					when ads_pch8=>
							ads_wreg_reg <= DIR_CH8SET;
							ads_wreg_val <= prog_chset;
							ads_return_wreg <= ads_c12;					
							state_ads <= ADS_WREG_START;
							
					when ads_c12=>
							ads_byte_to_send <= START;
							ads_return_transmit <= ads_c13;
							state_ads <= ADS_TRANSMIT_START;
					when ads_c13=>
							ads_byte_to_send <= RDATAC;
							ads_return_transmit <= WAIT_FOR_DRDY;
							GPIO(8) <= '0';
							state_ads <= ADS_TRANSMIT_START;
					
					-- Esperando al DRDY
					when WAIT_FOR_DRDY =>
							debugA <= "00";
							sumador_data_en <= '0';
							txpc_data_en <= '0';
							if ads_drdy = '1' then 
								state_ads <= ADS_DRDY_PRE;
							end if;
					when ADS_DRDY_PRE =>
							debugA <= "00";
							if ads_drdy = '0' then 
								state_ads <= READING_BYTES_START;
							end if;
							
					-- Llegó el DRDY, debe leerse
					when READING_BYTES_START =>
							debugA <= "01";
							ads_byte_counter <= 0;
							indice_escritura <= 0;
							state_ads <= READING_BYTES;							
					when READING_BYTES=>
							ads_return_read <= READING_BYTES_STORING;
							state_ads <= ADS_READ_START;
					when READING_BYTES_STORING=>
							memoria(indice_escritura) <= data_spi_rx;
							if ads_byte_counter = 27 then 
								state_ads <= READING_BYTES_END;								
							else								
								state_ads <= READING_BYTES_INC;
							end if;
					when READING_BYTES_INC=>
							ads_byte_counter <= ads_byte_counter + 1;
							indice_escritura <= indice_escritura +1;					
							state_ads <= READING_BYTES;
					when READING_BYTES_END =>
								debugA <= "00";
								sumador_data_en <= '1';
								txpc_data_en <= '0';
								state_ads <= ADS_WAIT_SUM;
					when ADS_WAIT_SUM =>
								sumador_data_en <= '0';
								if sum_ready = '1' then 
									state_ads <= READING_BYTES_TX;
								end if;
					when READING_BYTES_TX =>								
								txpc_data_en <= '1';
								state_ads <= WAIT_FOR_DRDY;								
								
					when others =>
							-- LED8 debug para caso de error en FSM
							state_ads <= ads_off;

				end case;
			end if;
		end if;
	end process;
	
	titilar: process(mclock)
	variable contador : integer :=0;
	variable tog : std_logic :='0';
	begin 
		if(rising_edge(mclock)) then
			if(contador = 100_000_000) then 
				if tog = '1' then
					LEDR(8) <= '1';
				else
					LEDR(8) <= '0';
				end if;
				contador:= 0;
				tog := not tog;
			else 
				contador:= contador+1;
			end if;
			
		end if;
	end process;
	
		

	
	--=============================================
	-- Instancia de SPI master para el ADS
	--=============================================	
	spi1: entity work.spi_master(rtl) 
    Generic map(   
        N => 8,					-- 32bit serial word length is default
        CPOL => '0',     		-- SPI mode selection (mode 0 default)
        CPHA => '1',          -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH => 2,        -- prefetch lookahead cycles
        SPI_2X_CLK_DIV => 3) 	-- for a 100MHz sclk_i, yields a 10MHz SCK
    Port map (  
        sclk_i 		=> mclock, 		-- high-speed serial interface system clock
        pclk_i 		=> mclock, 		-- high-speed parallel interface system clock
        rst_i			=> master_reset,
        ---- serial interface ----
        spi_ssel_o 	=> open,
        spi_sck_o 	=> ads_sclk,
        spi_mosi_o 	=> ads_mosi,
        spi_miso_i 	=> ads_miso,
        ---- parallel interface ----
        di_req_o		=> open,            -- preload lookahead data request line
        di_i 			=> data_spi_tx,         -- parallel data in (clocked on rising spi_clk after last bit)
        wren_i 		=> ads_spi_tx_en,     -- user data write enable, starts transmission when interface is idle
        wr_ack_o  	=> ads_spi_tx_ak,  -- write acknowledge
        do_valid_o 	=> open,			 -- do_o data valid signal, valid during one spi_clk rising edge.
        do_o 			=> data_spi_rx          -- parallel output (clocked on rising spi_clk after last bit)
		);
		
	
	--=============================================
	-- Modulos para deteccion de SSVEPS
	--=============================================		
				
	lockin_1: lockin_wrapper
	Generic map(
	
		f_lockin => f_lockin_1
	
	)
	Port map( 
		clk => mclock,
	   reset_n => (not(master_reset) and KEY(0)),
	
	   x => processed_data,
	   x_valid=> sum_ready,
		
		display_0 => HEX0,
		display_1 => HEX1,
		display_2 => HEX2,
		display_3 => HEX3,
		display_4 => HEX4,
		display_5 => HEX5,
		
		signal_out => acond_signal,
		
	   amplitud_salida => amplitud_lockin_1,
		estimulo_signal => output_estimulo_1
	);
	

	lockin_2: lockin_wrapper
	Generic map(
	
		f_lockin => f_lockin_2
	
	)
	Port map( 
	
		clk => mclock,
	   reset_n => (not(master_reset) and KEY(0)),
	
	   x => processed_data,
	   x_valid=> sum_ready,
		
		display_0 => open,
		display_1 => open,
		display_2 => open,
		display_3 => open,
		display_4 => open,
		display_5 => open,
		
	   amplitud_salida => amplitud_lockin_2,
		estimulo_signal => output_estimulo_2
	);
	
--		
--		
--	lockin_3: lockin_wrapper
--	Generic map(
--	
--		f_lockin => f_lockin_3
--	
--	)
--	Port map( 
--		clk => mclock,
--	   reset_n => (not(master_reset) and KEY(0)),
--	
--	   x => processed_data,
--	   x_valid=> sum_ready,
--		
--		display_0 => open,
--		display_1 => open,
--		display_2 => open,
--		display_3 => open,
--		display_4 => open,
--		display_5 => open,
--		
--	   amplitud_salida => amplitud_lockin_3,
--		estimulo_signal => output_estimulo_3
--	);

	GPIO(31) <= output_estimulo_1;
	GPIO(33) <= output_estimulo_2;
	GPIO(35) <= output_estimulo_3;

end rtl;




