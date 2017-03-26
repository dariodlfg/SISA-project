LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
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
END control_l;


ARCHITECTURE Structure OF control_l IS
BEGIN
	op <= 	"00" when ir(15 downto 12)="0101" and ir(8)='0' else
			"01" when ir(15 downto 12)="0101" and ir(8)='1' else
			"10";
			
	ldpc <= '0' when ir=x"FFFF" else '1';
	
	wrd <= 	'1' when ir(15 downto 12)="0101" else
			'1' when ir(15 downto 12)="0011" else
			'1' when ir(15 downto 12)="1101" else
			'0';
			
	addr_a <= 	ir(11 downto 9) when ir(15 downto 12)="0101" else
				ir(8 downto 6);
	
	addr_b <=	ir(2 downto 0) when ir(15 downto 13)="000" else
				ir(11 downto 9);
	
	addr_d <= 	ir(11 downto 9);
	
	immed <= 	std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when ir(15 downto 12)="0101" else
				std_logic_vector(resize(signed(ir(5 downto 0)), immed'length));
				
	
	wr_m <= '1' when ir(15 downto 12)="0100" else
			'1' when ir(15 downto 12)="1110" else
			'0';
			
	in_d <= '1' when ir(15 downto 12)="0011" else
			'1' when ir(15 downto 12)="1101" else
			'0';
	
	immed_x2 <=	'1' when ir(15 downto 12)="0011" else
				'1' when ir(15 downto 12)="0100" else
				'0';
	
	word_byte <='1' when ir(15 downto 12)="1101" else
				'1' when ir(15 downto 12)="1110" else
				'0';

END Structure;