LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER


ENTITY controladores_IO IS
	PORT (	boot 		: IN STD_LOGIC;
			debug		: IN STD_LOGIC;
			addr_m		: IN std_logic_vector(15 downto 0);
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
			visor3		: OUT STD_LOGIC_VECTOR(6 downto 0);
			ps2_clk 	: inout std_logic;
			ps2_data 	: inout std_logic;
			vga_cursor 	: out std_logic_vector(15 downto 0);
			vga_cursor_enable	: out std_logic);
END controladores_IO;
ARCHITECTURE Structure OF controladores_IO IS
	
	component driver7segmentos
		port(input		: IN 	STD_LOGIC_VECTOR(3 downto 0);
			output		: OUT 	STD_LOGIC_VECTOR(6 downto 0));
	end component;
	
	component keyboard_controller
		port(	clk        : in    STD_LOGIC;
				reset      : in    STD_LOGIC;
				ps2_clk    : inout STD_LOGIC;
				ps2_data   : inout STD_LOGIC;
				read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
				clear_char : in    STD_LOGIC;
				data_ready : out   STD_LOGIC);
	end component;
	
	--type memIO is array(255 downto 0) of std_logic_vector(15 downto 0);
	type memIO is array(31 downto 0) of std_logic_vector(15 downto 0); -- para que compile en tiempo finito
	signal IO : memIO;
	
	-- 1111  1111  1111  1111  0000  0000  0000  0000      -- 16^1
	-- FEDC  BA98  7654  3210  FEDC  BA98  7654  3210      -- 16^0

	-- 0000  0000  0011  0001  1000  0111  1110  0000	   -- usados
	-- 1111  1111  1100  1110  0111  1110  0111  1111      -- permiso de escritura
	--|  F  |  F  |  C  |  E  |  7  |  E  |  7  |  F  |
	constant wr_perm : std_logic_vector(31 downto 0) := x"FFCE7E7F"; -- permisos de escritura
	-- consideraremos que se puede escribir siempre cuando addr_io>31
	signal v0 : std_logic_vector(6 downto 0);
	signal v1 : std_logic_vector(6 downto 0);
	signal v2 : std_logic_vector(6 downto 0);
	signal v3 : std_logic_vector(6 downto 0);
	
	signal mostrar_pantalla: std_logic_vector(15 downto 0);
	
	signal rd_char : std_logic_vector(7 downto 0);
	signal d_ready : std_logic;
	
	signal clr_char : std_logic := '0';
	signal contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	signal contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000"; 
BEGIN
	
	keyboard_c : keyboard_controller
		port map(
			clk => CLOCK_50,
			reset => boot,
			ps2_clk => ps2_clk,
			ps2_data => ps2_data,
			read_char => rd_char,
			clear_char => clr_char,
			data_ready => d_ready);
	
	process (CLOCK_50,wr_out,boot) begin
		if rising_edge(CLOCK_50) then
			IO(7)(3 downto 0) <= pulsadores;
			IO(8)(7 downto 0) <= switchs;
			IO(15)(7 downto 0) <= rd_char;
			IO(16)(0) <= d_ready;
		end if;
		if rising_edge(CLOCK_50) then
			if boot='1' then
				IO <= (others => (others =>'0'));	-- reset
			elsif wr_out='1' and wr_perm(to_integer(unsigned(addr_io)))='1' then
				IO(to_integer(unsigned(addr_io))) <= wr_io;
			end if;
			if wr_out='1' and boot='0' and addr_io = x"10" then
				clr_char <= '1';
			else
				clr_char <= '0';
			end if;
			if wr_out='1' and addr_io = x"15" then
				contador_milisegundos <= wr_io;
			end if;
		end if;
		if rising_edge(CLOCK_50) then
			if contador_ciclos=0 then
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				if contador_milisegundos>0 then
					contador_milisegundos <= contador_milisegundos-1;
				end if;
			else--if contador_milisegundos>0 then	-- esta condición para que al poner un valor en el puerto 21 empiece a contar un ms entero
				contador_ciclos <= contador_ciclos-1;
			end if;
			IO(20) <= contador_ciclos;
			IO(21) <= contador_milisegundos;
		end if; 

	end process;
	rd_io <= IO(to_integer(unsigned(addr_io)));-- when rd_in='1' else x"0000";
	led_verdes <= IO(5)(7 downto 0);
	led_rojos <= IO(6)(7 downto 0);
	
	mostrar_pantalla <= IO(10) when debug='0' else addr_m;
	
	h0 : driver7segmentos port map( input=>mostrar_pantalla(3 downto 0), output=>v0);
	h1 : driver7segmentos port map( input=>mostrar_pantalla(7 downto 4), output=>v1);
	h2 : driver7segmentos port map( input=>mostrar_pantalla(11 downto 8), output=>v2);
	h3 : driver7segmentos port map( input=>mostrar_pantalla(15 downto 12), output=>v3);
	visor0 <= v0 when IO(9)(0)='1' or debug='1' else "1111111";
	visor1 <= v1 when IO(9)(1)='1' or debug='1' else "1111111";
	visor2 <= v2 when IO(9)(2)='1' or debug='1' else "1111111";
	visor3 <= v3 when IO(9)(3)='1' or debug='1' else "1111111";
	
	vga_cursor <= x"0000"; 		-- no implementado en VGA1
	vga_cursor_enable <= '0';	-- no implementado en VGA1
END Structure;