
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity fsm_txpc is
port(
		clk_in: in std_logic;
		rst : in std_logic;
		data_in_1: in std_logic_vector(31 downto 0);
		data_in_2 : in std_logic_vector(31 downto 0);
		data_in_3 : in std_logic_vector(31 downto 0);
		data_in_4 : in std_logic_vector(31 downto 0);
		data_en: in std_logic;
		pin_tx: out std_logic;
		pin_rx: in std_logic;
		pin_spi_mosi: out std_logic;
		pin_spi_sclk: out std_logic;
		pin_cs		: out std_logic;
		debug: out std_logic_vector(3 downto 0)
);
end entity;

architecture rtl of fsm_txpc is

	-- Señales para UART
--	signal dout: std_logic_vector(7 downto 0);
--	signal dtx: std_logic_vector(7 downto 0);
--	signal uart_txbusy: std_logic;
--	signal uart_rxbusy: std_logic;
--	signal uart_txenable: std_logic;

	-- Maquina de estados
	type state_type_txpc is (	TXPC_IDLE, TXPC_DELAY, TXPC_DELAY_IN_PROGRESS,
										TXPC_TRANSMIT_START, TXPC_TRANSMIT_CLRFLAG, TXPC_TRANSMIT_WAITBUSY, TXPC_TRANSMIT_END, 
										TXPC_BUFFER_SEND_START, TXPC_BUFFER_SENDING, TXPC_BUFFER_SEND_END, 
										TXPC_BUFFER_SENDING_DATA_REQ,
										TXPC_E1, TXPC_E2, TXPC_E3, TXPC_E4, TXPC_E5, TXPCEc6
										);
	signal state_txpc   : state_type_txpc;
	signal txpc_next_state   : state_type_txpc;
	signal txpc_return_delay   : state_type_txpc;
	signal txpc_return_transmit: state_type_txpc;
	
	signal txpc_delay_counter: integer:=0;
	signal txpc_delay_count: integer:=0;
	
	signal txpc_byte_to_send : std_logic_vector(7 downto 0);
	signal txpc_byte_counter : integer;
	signal txpc_byte_count	 : integer;
	
	signal byte_from_buf: std_logic_vector(7 downto 0);
	signal data_req : std_logic;
	signal buf_available : std_logic;
	
	signal sdebug : std_logic_vector(3 downto 0);
	
	
	-- Transmisión por SPI
	signal pc_mosi : std_logic;
	signal pc_sclk : std_logic;
	
	signal pc_spi_data : std_logic_vector(7 downto 0);
   signal pc_spi_data_en: std_logic;
	signal pc_spi_wack: std_logic;
	 
	
begin

	--=============================================
	-- Instanciación de buffer
	--=============================================
	buf: entity work.bpp(rtl)
	port map(
		clk_in 				  => clk_in,
		rst					  => rst,
		
		data_in_en 			  => data_en,
		
		data_in_1			  => data_in_1,		
		data_in_2			  => data_in_2,
		data_in_3			  => data_in_3,
		data_in_4			  => data_in_4,
		
		data_out_req 		  => data_req,
		data_out  			  => byte_from_buf,
		buf_available 		  => buf_available,
		debug 				  => sdebug(2 downto 0)
);
	debug <= sdebug;

	--=============================================
	-- Instanciación de módulo TX/RX UART
	--=============================================
--	uart1: entity work.uart(logic)
--	GENERIC map(100_000_000, 	-- Clock de entrada
--					115_200, 		-- Baud rate
--					2, 				-- Oversampling
--					8, 				-- Ancho de palabra
--					1, 				-- Bits de stop
--					'0'				-- Chequeo de paridad
--					)        
--	PORT map( 	clk 		=> clk_in, 			-- Señal de clock
--					reset_n 	=> not rst,			-- Reset (configurado manual)
--					tx_ena 	=> uart_txenable, --initiate transmission
--					tx_data 	=> dtx, 				--data to transmit
--					rx 		=> pin_rx, 			--ARDUINO_IO(1), --receive pin
--					rx_busy 	=> uart_rxbusy,   --data reception in progress
--					rx_error => open, 			--start, parity, or stop bit error detected
--					rx_data 	=> dout, 			--data received
--					tx_busy 	=> uart_txbusy, 	--transmission in progress
--					tx 		=> pin_tx			--ARDUINO_IO(0)	--transmit pin
--					);
					
	--=============================================
	-- Instanciación de módulo SPI para comm PC
	--=============================================

	 spipc: entity work.spi_master(rtl) 
    Generic map(   
        N => 8,					-- 32bit serial word length is default
        CPOL => '0',     		-- SPI mode selection (mode 0 default)
        CPHA => '0',          -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH => 2,        -- prefetch lookahead cycles
        SPI_2X_CLK_DIV => 3) 	-- for a 100MHz sclk_i, yields a 10MHz SCK
    Port map (  
        sclk_i 		=> clk_in, 		-- high-speed serial interface system clock
        pclk_i 		=> clk_in, 		-- high-speed parallel interface system clock
        rst_i			=> rst,
        ---- serial interface ----
        spi_ssel_o 	=> pin_cs,
        spi_sck_o 	=> pc_sclk,
        spi_mosi_o 	=> pc_mosi,
        spi_miso_i 	=> open,
        ---- parallel interface ----
        di_req_o		=> open,            -- preload lookahead data request line
        di_i 			=> pc_spi_data,         -- parallel data in (clocked on rising spi_clk after last bit)
        wren_i 		=> pc_spi_data_en,     -- user data write enable, starts transmission when interface is idle
        wr_ack_o  	=> pc_spi_wack,
        do_valid_o 	=> open,			 -- do_o data valid signal, valid during one spi_clk rising edge.
        do_o 			=> open          -- parallel output (clocked on rising spi_clk after last bit)
		);
		
		pin_spi_mosi <= pc_mosi;
		pin_spi_sclk <= pc_sclk;
	
		


	--=============================================
	-- Máquina de estados de control
	--=============================================

	fsm_txpc_init: process (clk_in)
	begin
		if rst = '1' then 
			state_txpc <= TXPC_IDLE;	
		else 
			if (rising_edge(clk_in)) then
				case state_txpc is
				
					when TXPC_DELAY =>
						txpc_delay_counter <= 0;
						state_txpc <= TXPC_DELAY_IN_PROGRESS;
					when TXPC_DELAY_IN_PROGRESS =>
						if txpc_delay_counter = txpc_delay_count then 
							state_txpc <= txpc_return_delay;
						else
							txpc_delay_counter <= txpc_delay_counter + 10;
						end if;		
						
					-- Transmision 
					when TXPC_TRANSMIT_START=>
							pc_spi_data <= txpc_byte_to_send;  -- POR SPI
							pc_spi_data_en <= '1';
							--dtx <= txpc_byte_to_send;			  -- POR UART
							--uart_txenable <= '1';
							state_txpc <= TXPC_TRANSMIT_CLRFLAG;							
					when TXPC_TRANSMIT_CLRFLAG=>
							pc_spi_data_en <= '0';
							--uart_txenable <= '0';
							--state_txpc <= TXPC_TRANSMIT_WAITBUSY;							
							state_txpc <= TXPC_TRANSMIT_END;
					
--					when TXPC_TRANSMIT_WAITBUSY=>
--							if uart_txbusy = '0' then
--								state_txpc <= TXPC_TRANSMIT_END;
--							end if;
--					when TXPC_TRANSMIT_END=>
--							txpc_return_delay <= txpc_return_transmit;	
--							txpc_delay_count <= 10000;
--							state_txpc <= TXPC_DELAY;							

					when TXPC_TRANSMIT_END=>
							txpc_return_delay <= txpc_return_transmit;	
							txpc_delay_count <= 1_100;		--2000 para 10 MHz
							state_txpc <= TXPC_DELAY;							
					
					
					-- Inicio 
					when TXPC_IDLE =>
							sdebug(3) <= '0';
							if buf_available = '1' then
								state_txpc <= TXPC_BUFFER_SEND_START;
							end if;
					
					when TXPC_BUFFER_SEND_START =>
							txpc_byte_counter <= 0;
							state_txpc <= TXPC_BUFFER_SENDING_DATA_REQ;
					when TXPC_BUFFER_SENDING_DATA_REQ =>
							data_req <= '1';
							state_txpc <= TXPC_BUFFER_SENDING;
					when TXPC_BUFFER_SENDING =>
							sdebug(3) <= '1';
							if buf_available = '0' then 
								state_txpc <= TXPC_BUFFER_SEND_END;
							else
								txpc_byte_to_send <= byte_from_buf;
								data_req <= '0';
								txpc_return_transmit <= TXPC_BUFFER_SENDING_DATA_REQ;
								state_txpc <= TXPC_TRANSMIT_START;
							end if;
					when TXPC_BUFFER_SEND_END =>
							state_txpc <= TXPC_IDLE;
							
					when others =>
							state_txpc <= TXPC_IDLE;
				end case;
			end if;
		end if;
	end process;
	
end rtl;
	