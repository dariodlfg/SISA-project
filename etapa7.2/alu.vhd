LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


ENTITY alu IS
    PORT (  x       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            y       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            op      : IN  STD_LOGIC_VECTOR( 6 DOWNTO 0);
            w       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            z       : OUT STD_LOGIC;
            div_zero: OUT STD_LOGIC);
END alu;


ARCHITECTURE Structure OF alu IS
signal wmuls : std_logic_vector(31 downto 0);
signal wmulu : std_logic_vector(31 downto 0);
signal yext : std_logic_vector(15 downto 0);
signal noty : std_logic_vector(15 downto 0);
BEGIN
    wmuls <= std_logic_vector(signed(x)*signed(y));
    wmulu <= std_logic_vector(unsigned(x)*unsigned(y));
    yext <= std_logic_vector(resize(signed(y(4 downto 0)), y'length));
    noty <= 0-yext;
            -- aritmetico
    w <=    x and y     when op = "0000000" else
            x or  y     when op = "0000001" else
            x xor y     when op = "0000010" else
            not x       when op = "0000011" else
            x + y       when op = "0000100" else
            x - y       when op = "0000101" else
            std_logic_vector(shift_left(signed(x),to_integer(signed(y(4 downto 0)))))    when op = "0000110" and y(4)='0' else
            std_logic_vector(shift_right(signed(x),to_integer(-signed(y(4 downto 0)))))   when op = "0000110" and y(4)='1' else
            std_logic_vector(shift_left(unsigned(x),to_integer(signed(y(4 downto 0)))))  when op = "0000111" and y(4)='0' else
            std_logic_vector(shift_right(unsigned(x),to_integer(-signed(y(4 downto 0))))) when op = "0000111" and y(4)='1' else
            
            -- comparacion
            x"0001"     when op = "0001000" and signed(x) < signed(y) else
            x"0000"     when op = "0001000" and signed(x) >= signed(y) else
            x"0001"     when op = "0001001" and signed(x) <= signed(y) else
            x"0000"     when op = "0001001" and signed(x) > signed(y) else
            x"0001"     when op = "0001011" and x = y else
            x"0000"     when op = "0001011" and x /= y else
            x"0001"     when op = "0001100" and unsigned(x) < unsigned(y) else
            x"0000"     when op = "0001100" and unsigned(x) >= unsigned(y) else
            x"0001"     when op = "0001101" and unsigned(x) <= unsigned(y) else
            x"0000"     when op = "0001101" and unsigned(x) > unsigned(y) else
            -- addi
            x + y       when op(6 downto 3) = "0010" else
            -- mult, div
            wmulu(15 downto 0)  when op = "1000000" else
            wmuls(31 downto 16) when op = "1000001" else
            wmulu(31 downto 16) when op = "1000010" else
            std_logic_vector(signed(x)/signed(y))       when op = "1000100" else
            std_logic_vector(unsigned(x)/unsigned(y))   when op = "1000101" else
            -- movi, movhi
            y           when op(6 downto 2) = "01010" else
            y(7 downto 0)&x(7 downto 0) when op(6 downto 2) = "01011" else
            -- I/O
            y           when op(6 downto 3) = "0111" else
            -- saltos absolutos
            x           when op(6 downto 3) = "1010" else
            -- EI, DI
            x(15 downto 2)&'1'&x(0)     when op="1111000" else
            x(15 downto 2)&'0'&x(0)     when op="1111001" else
            -- acc. memoria
            x+y;
    z <= '1' when y=x"0000" else '0';
    
    div_zero <= '1' when op(6 downto 1)="100010" and y=x"0000" else '0';
END Structure;