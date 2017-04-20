LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY datapath IS
    PORT (clk      : IN  STD_LOGIC;
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
END datapath;


ARCHITECTURE Structure OF datapath IS

    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
	component regfile
		port(	clk    : IN  STD_LOGIC;
				wrd    : IN  STD_LOGIC;
				d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component;
	
	component alu
		port(	x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component;
	
	signal d_toreg : std_logic_vector(15 downto 0);
	signal x_toalu : std_logic_vector(15 downto 0);
	signal y_toalu : std_logic_vector(15 downto 0);
	signal w_fromalu : std_logic_vector(15 downto 0);
BEGIN
	y_toalu <= 	immed when immed_x2='0' else
				immed(14 downto 0)&'0';
	
	addr_m  <= 	w_fromalu when ins_dad='1' else
				pc;
				
	d_toreg <=  datard_m when in_d='1' else
				w_fromalu;
	regs : regfile
		port map(
			clk => clk,
			wrd => wrd,
			d => d_toreg,
			addr_a => addr_a,
			addr_b => addr_b,
			addr_d => addr_d,
			a => x_toalu,
			b => data_wr);
	alu0 : alu
		port map(
			x => x_toalu,
			y => y_toalu,
			op => op,
			w => w_fromalu);
	
END Structure;