LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END proc;

ARCHITECTURE Structure OF proc IS
	component unidad_control
		port(	boot      : IN  STD_LOGIC;
				clk       : IN  STD_LOGIC;
				datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				wrd       : OUT STD_LOGIC;
				addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad   : OUT STD_LOGIC;
				in_d      : OUT STD_LOGIC;
				immed_x2  : OUT STD_LOGIC;
				wr_m      : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	end component;
	
	component datapath
		port(	clk      : IN  STD_LOGIC;
				op       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				wrd      : IN  STD_LOGIC;
				addr_a   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				immed_x2 : IN  STD_LOGIC;
				datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad  : IN  STD_LOGIC;
				pc       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				in_d     : IN  STD_LOGIC;
				addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component;
    
	signal immed_x2_fromuc : std_logic;
	signal in_d_fromuc : std_logic;
	signal ins_dad_fromuc : std_logic;
	signal wrd_fromuc : std_logic;
	signal op_fromuc : std_logic_vector(1 downto 0);
	signal addr_a_fromuc : std_logic_vector(2 downto 0);
	signal addr_b_fromuc : std_logic_vector(2 downto 0);
	signal addr_d_fromuc : std_logic_vector(2 downto 0);
	signal immed_fromuc : std_logic_vector(15 downto 0);
	signal pc_fromuc : std_logic_vector(15 downto 0);
	

BEGIN
	uc : unidad_control
		port map(
			boot => boot,
			clk => clk,
			datard_m => datard_m,
			op => op_fromuc,
			wrd => wrd_fromuc,
			addr_a => addr_a_fromuc,
			addr_b => addr_b_fromuc,
			addr_d => addr_d_fromuc,
			immed => immed_fromuc,
			pc => pc_fromuc,
			ins_dad => ins_dad_fromuc,
			in_d => in_d_fromuc,
			immed_x2 => immed_x2_fromuc,
			wr_m => wr_m,
			word_byte => word_byte);
	
	dp : datapath
		port map(
			clk => clk,
			op => op_fromuc,
			wrd => wrd_fromuc,
			addr_a => addr_a_fromuc,
			addr_b => addr_b_fromuc,
			addr_d => addr_d_fromuc,
			immed => immed_fromuc,
			immed_x2 => immed_x2_fromuc,
			datard_m => datard_m,
			ins_dad => ins_dad_fromuc,
			pc => pc_fromuc,
			in_d => in_d_fromuc,
			addr_m => addr_m,
			data_wr => data_wr);
    -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
    -- En los esquemas de la documentacion a la instancia del DATAPATH le hemos llamado e0 y a la de la unidad de control le hemos llamado c0

END Structure;