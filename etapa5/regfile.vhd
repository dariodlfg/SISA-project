LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile;

ARCHITECTURE Structure OF regfile IS
	type bancoreg is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal regs : bancoreg;

BEGIN
	process (clk,wrd) begin
		if rising_edge(clk) and wrd = '1' then
			regs(to_integer(unsigned(addr_d))) <= d;
		end if;
	end process;
	a <= regs(to_integer(unsigned(addr_a)));
	b <= regs(to_integer(unsigned(addr_b)));
END Structure;