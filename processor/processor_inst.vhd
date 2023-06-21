	component processor is
		port (
			clk_clk                    : in  std_logic                     := 'X';             -- clk
			datos_muestreados_in_valid : in  std_logic                     := 'X';             -- valid
			datos_muestreados_in_data  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			datos_muestreados_in_ready : out std_logic;                                        -- ready
			fifo_1_in_valid            : in  std_logic                     := 'X';             -- valid
			fifo_1_in_data             : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo_1_in_ready            : out std_logic;                                        -- ready
			fifo_2_in_valid            : in  std_logic                     := 'X';             -- valid
			fifo_2_in_data             : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo_2_in_ready            : out std_logic;                                        -- ready
			fifo_3_in_valid            : in  std_logic                     := 'X';             -- valid
			fifo_3_in_data             : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo_3_in_ready            : out std_logic;                                        -- ready
			reset_reset_n              : in  std_logic                     := 'X';             -- reset_n
			fifo_4_in_valid            : in  std_logic                     := 'X';             -- valid
			fifo_4_in_data             : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo_4_in_ready            : out std_logic                                         -- ready
		);
	end component processor;

	u0 : component processor
		port map (
			clk_clk                    => CONNECTED_TO_clk_clk,                    --                  clk.clk
			datos_muestreados_in_valid => CONNECTED_TO_datos_muestreados_in_valid, -- datos_muestreados_in.valid
			datos_muestreados_in_data  => CONNECTED_TO_datos_muestreados_in_data,  --                     .data
			datos_muestreados_in_ready => CONNECTED_TO_datos_muestreados_in_ready, --                     .ready
			fifo_1_in_valid            => CONNECTED_TO_fifo_1_in_valid,            --            fifo_1_in.valid
			fifo_1_in_data             => CONNECTED_TO_fifo_1_in_data,             --                     .data
			fifo_1_in_ready            => CONNECTED_TO_fifo_1_in_ready,            --                     .ready
			fifo_2_in_valid            => CONNECTED_TO_fifo_2_in_valid,            --            fifo_2_in.valid
			fifo_2_in_data             => CONNECTED_TO_fifo_2_in_data,             --                     .data
			fifo_2_in_ready            => CONNECTED_TO_fifo_2_in_ready,            --                     .ready
			fifo_3_in_valid            => CONNECTED_TO_fifo_3_in_valid,            --            fifo_3_in.valid
			fifo_3_in_data             => CONNECTED_TO_fifo_3_in_data,             --                     .data
			fifo_3_in_ready            => CONNECTED_TO_fifo_3_in_ready,            --                     .ready
			reset_reset_n              => CONNECTED_TO_reset_reset_n,              --                reset.reset_n
			fifo_4_in_valid            => CONNECTED_TO_fifo_4_in_valid,            --            fifo_4_in.valid
			fifo_4_in_data             => CONNECTED_TO_fifo_4_in_data,             --                     .data
			fifo_4_in_ready            => CONNECTED_TO_fifo_4_in_ready             --                     .ready
		);

