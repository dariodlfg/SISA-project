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
          SW        : in std_logic_vector(9 downto 8);
		  KEY		: in std_logic_vector(0 downto 0);
		  HEX0 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX1 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX2		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX3 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END sisa;

ARCHITECTURE Structure OF sisa IS
	component proc
		port (	clk       : IN  STD_LOGIC;
				boot      : IN  STD_LOGIC;
				datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m      : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	end component;
	
	component driver7segmentos
		port(input		: IN 	STD_LOGIC_VECTOR(3 downto 0);
			output		: OUT 	STD_LOGIC_VECTOR(6 downto 0));
	end component;
	
	component MemoryController
		port (clk  : in  std_logic;
	      addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- seÃ±ales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic;
          SRAM_OE_N : out   std_logic;
          SRAM_WE_N : out   std_logic);
	end component;
	signal datard_m_to_proc : std_logic_vector(15 downto 0);
	
	signal addr_m_from_proc : std_logic_vector(15 downto 0);
	signal data_wr_from_proc : std_logic_vector(15 downto 0);
	signal wr_m_from_proc : std_logic;
	signal word_byte_from_proc : std_logic;
	
	signal clock_counter : std_logic_vector(3 downto 0) := "0000";
	signal clockcutre : std_logic := '0';
BEGIN
	process (clockcutre) begin
		if rising_edge(clockcutre) then
			clock_counter <= clock_counter + 1;
		end if;
	end process;
	clockcutre <= CLOCK_50 when SW(8)='0' else KEY(0);
	h0 : driver7segmentos port map( input=>addr_m_from_proc(3 downto 0), output=>HEX0);
	h1 : driver7segmentos port map( input=>addr_m_from_proc(7 downto 4), output=>HEX1);
	h2 : driver7segmentos port map( input=>addr_m_from_proc(11 downto 8), output=>HEX2);
	h3 : driver7segmentos port map( input=>addr_m_from_proc(15 downto 12), output=>HEX3);
	
	procesador : proc
		port map( 	clk => clock_counter(0),
					boot => SW(9),
					datard_m => datard_m_to_proc,
					addr_m => addr_m_from_proc,
					data_wr => data_wr_from_proc,
					wr_m => wr_m_from_proc,
					word_byte => word_byte_from_proc);
					
	memControl : MemoryController
		port map(	clk => clockcutre,
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
END Structure;