LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER


ENTITY controladores_IO IS
	PORT (	boot 		: IN STD_LOGIC;
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
END controladores_IO;
ARCHITECTURE Structure OF controladores_IO IS
	
	component driver7segmentos
		port(input		: IN 	STD_LOGIC_VECTOR(3 downto 0);
			output		: OUT 	STD_LOGIC_VECTOR(6 downto 0));
	end component;
	
	--type memIO is array(255 downto 0) of std_logic_vector(15 downto 0);
	type memIO is array(0 to 29) of std_logic_vector(15 downto 0); -- para que compile en tiempo finito
	signal IO : memIO;
	signal v0 : std_logic_vector(6 downto 0);
	signal v1 : std_logic_vector(6 downto 0);
	signal v2 : std_logic_vector(6 downto 0);
	signal v3 : std_logic_vector(6 downto 0);
BEGIN
	
	process (CLOCK_50,wr_out,boot) begin
		if rising_edge(CLOCK_50) then
			IO(7)(3 downto 0) <= pulsadores;
			IO(8)(7 downto 0) <= switchs;
		end if;
		if rising_edge(CLOCK_50) then
			if boot='1' then
				IO <= (others => (others =>'0'));	-- reset
			elsif wr_out='1' and addr_io /= x"07" and addr_io /= x"08" then	-- no se puede escribir el valor de los pulsadores y los interruptores
				IO(to_integer(unsigned(addr_io))) <= wr_io;
			end if;
		end if;
	end process;
	rd_io <= IO(to_integer(unsigned(addr_io))) when rd_in='1' else x"0000";
	led_verdes <= IO(5)(7 downto 0);
	led_rojos <= IO(6)(7 downto 0);
	
	h0 : driver7segmentos port map( input=>IO(10)(3 downto 0), output=>v0);
	h1 : driver7segmentos port map( input=>IO(10)(7 downto 4), output=>v1);
	h2 : driver7segmentos port map( input=>IO(10)(11 downto 8), output=>v2);
	h3 : driver7segmentos port map( input=>IO(10)(15 downto 12), output=>v3);
	visor0 <= v0 when IO(9)(0)='1' else "1111111";
	visor1 <= v1 when IO(9)(1)='1' else "1111111";
	visor2 <= v2 when IO(9)(2)='1' else "1111111";
	visor3 <= v3 when IO(9)(3)='1' else "1111111";
	
END Structure;