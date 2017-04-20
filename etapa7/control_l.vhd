LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  z			: IN  STD_LOGIC;
		  es_system	: IN  STD_LOGIC;
          op        : OUT STD_LOGIC_VECTOR( 6 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
		  rb_n		: OUT STD_LOGIC;
		  tknbr		: OUT STD_LOGIC_VECTOR( 1 DOWNTO 0);
		  rd_in		: OUT STD_LOGIC;
		  wr_out	: OUT STD_LOGIC;
		  wrd_sys	: OUT STD_LOGIC;
		  a_sys		: OUT STD_LOGIC;
		  es_reti   : OUT STD_LOGIC);
END control_l;


ARCHITECTURE Structure OF control_l IS
BEGIN
	op <= 	"1010000"	when es_system='1' else											-- w <= x cuando es la etapa system
			ir(15 downto 12) & ir(8) & "00" when ir(15 downto 12)="0101" else
			"1010000"	when ir(15 downto 12)="1111" and ir(5 downto 0)="101100" else	-- w <= x para RDS
			"1010000"	when ir(15 downto 12)="1111" and ir(5 downto 0)="110000" else	-- w <= x para WRS
			"1111000"	when ir(15 downto 12)="1111" and ir(5 downto 0)="100000" else	-- EI
			"1111001"	when ir(15 downto 12)="1111" and ir(5 downto 0)="100001" else	-- DI
			"1010000"	when ir(15 downto 12)="1111" and ir(5 downto 0)="101100" else	-- w <= x para RETI
			"1111111"	when ir(15 downto 12)="1111" else				-- otro
			ir(15 downto 12) & ir(5 downto 3);
			
	ldpc <= '0' when ir=x"FFFF" else '1';
	
	wrd <= 	'1' when ir(15 downto 14)="00" else
			'1' when ir(15 downto 12)="1000" else
			'1' when ir(15 downto 12)="0101" else
			'1' when ir(15 downto 12)="0011" else
			'1' when ir(15 downto 12)="1101" else
			'1' when ir(15 downto 12)="1010" and ir(2)='1' else -- JAL
			'1' when ir(15 downto 12)="0111" and ir(8)='0' else -- IN
			'1' when ir(15 downto 12)="1111" and ir(5 downto 0)="101100" else  -- RDS
			'0';
			
	addr_a <= 	"111" when ir(15 downto 12)="1111" and ir(5 downto 1)="10000" else -- EI, DI
				"001" when ir(15 downto 12)="1111" and ir(5 downto 0)="100100" else -- RETI
				ir(11 downto 9) when ir(15 downto 12)="0101" else
				ir(8 downto 6);
	
	addr_b <=	ir(2 downto 0) when ir(15 downto 13)="000" else
				ir(2 downto 0) when ir(15 downto 12)="1000" else
				ir(11 downto 9);
	
	addr_d <= 	"111" when ir(15 downto 12)="1111" and ir(5 downto 1)="10000" else -- EI, DI
				ir(11 downto 9);
	
	immed <= 	std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when ir(15 downto 12)="0101" else
				std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when ir(15 downto 12)="0110" else
				std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when ir(15 downto 12)="0111" else
				std_logic_vector(resize(signed(ir(5 downto 0)), immed'length));
				
	
	wr_m <= '1' when ir(15 downto 12)="0100" else
			'1' when ir(15 downto 12)="1110" else
			'0';
			
	in_d <= "10" when es_system='1' else
			"01" when ir(15 downto 12)="0011" else
			"01" when ir(15 downto 12)="1101" else
			"10" when ir(15 downto 12)="1010" and ir(2)='1' else
			"00";
	
	immed_x2 <=	'1' when ir(15 downto 12)="0011" else
				'1' when ir(15 downto 12)="0100" else
				'0';
	
	word_byte <='1' when ir(15 downto 12)="1101" else
				'1' when ir(15 downto 12)="1110" else
				'0';
	
	rb_n <= '1' when ir(15 downto 13)="000" else
			'1' when ir(15 downto 12)="1000" else
			'1' when ir(15 downto 12)="0110" else
			'1' when ir(15 downto 12)="1010" else
			'1' when ir(15 downto 12)="0111" else
			'0';
			
	tknbr <="11" when ir=x"FFFF" else
			"10" when es_system='1' else
			"01" when ir(15 downto 12)="0110" and (z xor ir(8))='1' else
			"10" when ir(15 downto 12)="1010" and ir(2 downto 1)="00" and (z xor ir(0))='1' else
			"10" when ir(15 downto 12)="1010" and ir(2 downto 1)/="00" else
			"10" when ir(15 downto 12)="1111" and ir(5 downto 0)="100100" else
			"00";
			
	rd_in <= '1' when ir(15 downto 12)="0111" and ir(8)='0' else '0';
	
	wr_out <= '1' when ir(15 downto 12)="0111" and ir(8)='1' else '0';
	
	wrd_sys <= 	'1' when ir(15 downto 12)="1111" and ir(5 downto 0)="110000" else -- WRS
				'1' when ir(15 downto 12)="1111" and ir(5 downto 1)="10000" else -- EI, DI
				'0';
	
	a_sys <= '1' when es_system='1' else
			 '1' when ir(15 downto 12)="1111" and ir(5 downto 0)="101100" else  -- RDS
			 '1' when ir(15 downto 12)="1111" and ir(5 downto 1)="10000" else -- EI, DI
			 '1' when ir(15 downto 12)="1111" and ir(5 downto 0)="100100" else -- RETI
			 '0';
	
	es_reti <= '1' when ir(15 downto 12)="1111" and ir(5 downto 0)="100100" else '0';
	
END Structure;
