LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '0';
          SRAM_OE_N : out   std_logic := '0';
          SRAM_WE_N : out   std_logic := '1';
          SW        : in std_logic_vector(9 downto 0);
		  KEY		: in std_logic_vector(3 downto 0);
		  HEX0 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX1 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX2		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX3 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  LEDG 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  LEDR 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END sisa;

ARCHITECTURE Structure OF sisa IS
	component proc
		port (	clk       : IN  STD_LOGIC;
				boot      : IN  STD_LOGIC;
				datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m      : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC;
				addr_io	  : out std_logic_vector(7 downto 0);
				wr_io 	  : out std_logic_vector(15 downto 0);
				rd_io 	  : in  std_logic_vector(15 downto 0);
				wr_out 	  : out std_logic;
				rd_in 	  : out std_logic);
	end component;
	
	component MemoryController
		port (clk  : in  std_logic;
	      addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;

          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic;
          SRAM_OE_N : out   std_logic;
          SRAM_WE_N : out   std_logic);
	end component;
	
	component controladores_IO
		port (	boot 		: IN STD_LOGIC;
				CLOCK_50 	: IN std_logic;
				addr_io	 	: IN std_logic_vector(7 downto 0);
				wr_io 		: in std_logic_vector(15 downto 0);
				rd_io 		: out std_logic_vector(15 downto 0);
				wr_out 		: in std_logic;
				rd_in 		: in std_logic;
				led_verdes 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				led_rojos 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				pulsadores  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				switchs		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				visor0		: OUT STD_LOGIC_VECTOR(6 downto 0);
				visor1		: OUT STD_LOGIC_VECTOR(6 downto 0);
				visor2		: OUT STD_LOGIC_VECTOR(6 downto 0);
				visor3		: OUT STD_LOGIC_VECTOR(6 downto 0));
	end component;
	
	signal datard_m_to_proc : std_logic_vector(15 downto 0);
	
	signal addr_m_from_proc : std_logic_vector(15 downto 0);
	signal data_wr_from_proc : std_logic_vector(15 downto 0);
	signal wr_m_from_proc : std_logic;
	signal word_byte_from_proc : std_logic;
	signal rd_io_from_io : std_logic_vector(15 downto 0);
	signal addr_io_from_proc : std_logic_vector(7 downto 0);
	signal wr_io_from_proc : std_logic_vector(15 downto 0);
	signal wr_out_from_proc : std_logic;
	signal rd_in_from_proc : std_logic;
	
	
	signal clock_counter : std_logic_vector(3 downto 0) := "0000";
	signal adv_instr : std_logic := '0';	-- si 1, avanza hasta el comienzo de la siguiente instruccion
	-- Si SW(8)='1', avanza una instrucción cada vez que se pulsa KEY(0) -> avanza 4 ciclos
BEGIN
	process(CLOCK_50) begin
		if rising_edge(CLOCK_50) and SW(8)='0' then
			clock_counter <= clock_counter + 1;
		elsif rising_edge(CLOCK_50) and (clock_counter(0)='1' or clock_counter(1)='1') then 
			clock_counter <= clock_counter + 1;
		elsif rising_edge(CLOCK_50) and adv_instr='0' and KEY(0)='0' then 
			clock_counter <= clock_counter + 1;
			adv_instr <= '1';
		elsif rising_edge(CLOCK_50) and adv_instr='1' and KEY(0)='1' then
			adv_instr <= '0';
		end if;
	end process;

	procesador : proc
		port map( 	clk => clock_counter(0),
					boot => SW(9),
					datard_m => datard_m_to_proc,
					addr_m => addr_m_from_proc,
					data_wr => data_wr_from_proc,
					wr_m => wr_m_from_proc,
					word_byte => word_byte_from_proc,
					addr_io => addr_io_from_proc,
					wr_io => wr_io_from_proc,
					rd_io => rd_io_from_io,
					wr_out => wr_out_from_proc,
					rd_in => rd_in_from_proc);
					
	memControl : MemoryController
		port map(	clk => CLOCK_50,
					addr => addr_m_from_proc,
					wr_data => data_wr_from_proc,
					rd_data => datard_m_to_proc,
					we => wr_m_from_proc,
					byte_m => word_byte_from_proc,
					SRAM_ADDR => SRAM_ADDR,
					SRAM_DQ => SRAM_DQ,
					SRAM_UB_N => SRAM_UB_N,
					SRAM_LB_N => SRAM_LB_N,
					SRAM_CE_N => SRAM_CE_N,
					SRAM_OE_N => SRAM_OE_N,
					SRAM_WE_N => SRAM_WE_N);
	
	controlIO : controladores_IO
		port map(	boot => SW(9),
					CLOCK_50 => CLOCK_50,
					addr_io => addr_io_from_proc,
					wr_io => wr_io_from_proc,
					rd_io => rd_io_from_io,
					wr_out => wr_out_from_proc,
					rd_in => rd_in_from_proc,
					led_verdes => LEDG,
					led_rojos => LEDR,
					pulsadores => KEY,
					switchs => SW(7 downto 0),
					visor0 => HEX0,
					visor1 => HEX1,
					visor2 => HEX2,
					visor3 => HEX3);
END Structure;