LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
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
END unidad_control;


ARCHITECTURE Structure OF unidad_control IS
	component control_l
		port(	ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				ldpc      : OUT STD_LOGIC;
				wrd       : OUT STD_LOGIC;
				addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m      : OUT STD_LOGIC;
				in_d      : OUT STD_LOGIC;
				immed_x2  : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	end component;
	
	component multi
		port(	clk       : IN  STD_LOGIC;
				boot      : IN  STD_LOGIC;
				ldpc_l    : IN  STD_LOGIC;
				wrd_l     : IN  STD_LOGIC;
				wr_m_l    : IN  STD_LOGIC;
				w_b       : IN  STD_LOGIC;
				ldpc      : OUT STD_LOGIC;
				wrd       : OUT STD_LOGIC;
				wr_m      : OUT STD_LOGIC;
				ldir      : OUT STD_LOGIC;
				ins_dad   : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	end component;
	
	signal new_pc : std_logic_vector(15 downto 0) := x"C000";
	
	signal ir_tocontrol : std_logic_vector(15 downto 0);
    signal ldpc_fromcontrol : std_logic;
    signal w_b_fromcontrol : std_logic;
    signal wr_m_fromcontrol : std_logic;
    signal wrd_fromcontrol : std_logic;
    signal ldir_frommulti : std_logic;
    signal ldpc_frommulti : std_logic;
    
	
	-- Aqui iria la declaracion de las entidades que vamos a usar
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
    -- Aqui iria la definicion del program counter y del registro IR

BEGIN
	process (clk) begin
		if rising_edge(clk) then
			if boot = '1' then
				new_pc <= x"C000";
			elsif ldpc_frommulti = '1' then
				new_pc <= new_pc + 2;
			end if;
			if boot = '1' then
				ir_tocontrol <= x"0000";
			elsif ldir_frommulti = '1' then
				ir_tocontrol <= datard_m;
			end if;
		end if;
	end process;
	
	control : control_l
		port map(
			ir => ir_tocontrol,
			op => op,
			ldpc => ldpc_fromcontrol,
			wrd => wrd_fromcontrol,
			addr_a => addr_a,
			addr_b => addr_b,
			addr_d => addr_d,
			immed => immed,
			wr_m => wr_m_fromcontrol,
			in_d => in_d,
			immed_x2 => immed_x2,
			word_byte => w_b_fromcontrol);
	mult : multi
		port map(
			clk => clk,
			boot => boot,
			ldpc_l => ldpc_fromcontrol,
			wrd_l => wrd_fromcontrol,
			wr_m_l => wr_m_fromcontrol,
			w_b => w_b_fromcontrol,
			ldpc => ldpc_frommulti,
			wrd => wrd,
			wr_m => wr_m,
			ldir => ldir_frommulti,
			ins_dad => ins_dad,
			word_byte => word_byte);
	pc <= new_pc;
END Structure;