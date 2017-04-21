LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  z		    : IN  STD_LOGIC;
		  aluout	: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  int_hab	: IN  STD_LOGIC;
          intr      : IN  STD_LOGIC;
          op        : OUT STD_LOGIC_VECTOR( 6 DOWNTO 0);
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
		  rb_n		: OUT STD_LOGIC;
		  rd_in		: OUT STD_LOGIC;
		  wr_out    : OUT STD_LOGIC;
		  addr_io   : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0);
		  wr_io 	: OUT STD_LOGIC_VECTOR(15 downto 0);
		  wrd_sys	: OUT STD_LOGIC;
		  a_sys		: OUT STD_LOGIC;
		  es_reti	: OUT STD_LOGIC;
		  c_system	: OUT STD_LOGIC;
		  etapa     : OUT STD_LOGIC_VECTOR( 1 downto 0);
          inta      : OUT STD_LOGIC);
END unidad_control;


ARCHITECTURE Structure OF unidad_control IS
	component control_l
		port (	ir        	: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				z			: IN  STD_LOGIC;
				es_system	: IN  STD_LOGIC;
				op        	: OUT STD_LOGIC_VECTOR( 6 DOWNTO 0);
				ldpc     	: OUT STD_LOGIC;
				wrd      	: OUT STD_LOGIC;
				addr_a    	: OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
				addr_b    	: OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
				addr_d    	: OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
				immed     	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m      	: OUT STD_LOGIC;
				in_d      	: OUT STD_LOGIC_VECTOR( 1 DOWNTO 0);
				immed_x2  	: OUT STD_LOGIC;
				word_byte 	: OUT STD_LOGIC;
				rb_n		: OUT STD_LOGIC;
				tknbr		: OUT STD_LOGIC_VECTOR( 1 DOWNTO 0);
				rd_in		: OUT STD_LOGIC;
				wr_out		: OUT STD_LOGIC;
				wrd_sys		: OUT STD_LOGIC;
				a_sys		: OUT STD_LOGIC;
				es_reti		: OUT STD_LOGIC;
                inta        : OUT STD_LOGIC);
	end component;
	
	component multi
		port(	clk			: IN  STD_LOGIC;
				boot		: IN  STD_LOGIC;
				ldpc_l		: IN  STD_LOGIC;
				wrd_l		: IN  STD_LOGIC;
				wr_m_l		: IN  STD_LOGIC;
				wr_o_l		: IN  STD_LOGIC;
				w_b			: IN  STD_LOGIC;
				ej_system	: IN  STD_LOGIC;	-- ejecutar system
				wrdsys_l	: IN  STD_LOGIC;
				ldpc		: OUT STD_LOGIC;
				wrd			: OUT STD_LOGIC;
				wr_m		: OUT STD_LOGIC;
				wr_out		: OUT STD_LOGIC;
				ldir		: OUT STD_LOGIC;
				ins_dad		: OUT STD_LOGIC;
				word_byte	: OUT STD_LOGIC;
				wrdsys		: OUT STD_LOGIC;
				c_system	: OUT STD_LOGIC;     -- 1 si el ciclo actual es de system
				etapa       : OUT STD_LOGIC_VECTOR(1 downto 0)); -- para debug
	end component;
	
	signal new_pc : std_logic_vector(15 downto 0) := x"C000";
	
	signal ir_tocontrol : std_logic_vector(15 downto 0);
    signal ldpc_fromcontrol : std_logic;
    signal w_b_fromcontrol : std_logic;
    signal wr_m_fromcontrol : std_logic;
	signal wr_out_fromcontrol : std_logic;
    signal wrd_fromcontrol : std_logic;
	signal wrd_sys_fromcontrol : std_logic;
    signal ldir_frommulti : std_logic;
    signal ldpc_frommulti : std_logic;
    signal tknbr_fromcontrol : std_logic_vector(1 downto 0);
	signal immed_fromcontrol : std_logic_vector(15 downto 0);
	
	signal ej_system_tomulti : std_logic;
	signal c_system_frommulti : std_logic;
	-- Aqui iria la declaracion de las entidades que vamos a usar
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
    -- Aqui iria la definicion del program counter y del registro IR

BEGIN
	process (clk) begin
		if rising_edge(clk) then
			if boot = '1' then
				new_pc <= x"C000";
			elsif ldpc_frommulti = '1' then
				if tknbr_fromcontrol="00" then 
					new_pc <= new_pc + 2;
				elsif tknbr_fromcontrol="01" then
					new_pc <= new_pc + 2 + (immed_fromcontrol(14 downto 0)&'0');
				elsif tknbr_fromcontrol="10" and aluout>=x"C000" then
					new_pc <= aluout;
				end if;
			end if;
			if boot = '1' then
				ir_tocontrol <= x"0000";
			elsif ldir_frommulti = '1' then
				ir_tocontrol <= datard_m;
			end if;
		end if;
	end process;
	pc <= new_pc;
	ej_system_tomulti <= int_hab and intr;
	control : control_l
		port map(
			ir => ir_tocontrol,
			z => z,
			es_system => c_system_frommulti,
			op => op,
			ldpc => ldpc_fromcontrol,
			wrd => wrd_fromcontrol,
			addr_a => addr_a,
			addr_b => addr_b,
			addr_d => addr_d,
			immed => immed_fromcontrol,
			wr_m => wr_m_fromcontrol,
			in_d => in_d,
			immed_x2 => immed_x2,
			word_byte => w_b_fromcontrol,
			rb_n => rb_n,
			tknbr => tknbr_fromcontrol,
			rd_in => rd_in,
			wr_out => wr_out_fromcontrol,
			wrd_sys => wrd_sys_fromcontrol,
			a_sys => a_sys,
			es_reti => es_reti,
            inta => inta);
	mult : multi
		port map(
			clk => clk,
			boot => boot,
			ldpc_l => ldpc_fromcontrol,
			wrd_l => wrd_fromcontrol,
			wr_m_l => wr_m_fromcontrol,
			wr_o_l => wr_out_fromcontrol,
			wrdsys_l => wrd_sys_fromcontrol,
			w_b => w_b_fromcontrol,
			ldpc => ldpc_frommulti,
			wrd => wrd,
			wr_m => wr_m,
			wr_out => wr_out,
			wrdsys => wrd_sys,
			ldir => ldir_frommulti,
			ins_dad => ins_dad,
			word_byte => word_byte,
			c_system => c_system_frommulti,
			ej_system => ej_system_tomulti,
			etapa => etapa);
	
	immed <= immed_fromcontrol;
	addr_io <= immed_fromcontrol(7 downto 0);
	wr_io <= aluout;
	c_system <= c_system_frommulti;
END Structure;
