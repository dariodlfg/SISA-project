library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SRAMController is
    port (clk         : in    std_logic;
          -- seï¿½ales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '0';
          SRAM_OE_N   : out   std_logic := '0';
          SRAM_WE_N   : out   std_logic := '1';
          -- seï¿½ales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic);
end SRAMController;

architecture comportament of SRAMController is
signal escr : std_logic := '1';
signal lb,ub : std_logic := '0';

type estado_mem is (r, w);
	signal estado   : estado_mem := r;
begin
	
	process(clk,WR) begin
		if WR='1' then
			estado <= w;
		elsif WR='0' then
			estado <= r;
		end if;
	end process;
	process (estado,byte_m,address(0)) begin
		if estado=w then
			escr <='0';
		else
			escr <='1';
		end if;
		if byte_m='0' then
			lb <= '0';
			ub <= '0';
		elsif address(0)='0' then
			lb <= '0';
			ub <= '1';
		else
			lb <= '1';
			ub <= '0';
		end if;
	end process;
	
	SRAM_CE_N <= '0';
	SRAM_OE_N <= '0';
	SRAM_LB_N <= lb;
	SRAM_UB_N <= ub;
	SRAM_WE_N <= escr;
	
	--SRAM_DQ <= dq;
	
	--dataReaded <= dr;
	SRAM_DQ(15 downto 8) <= "ZZZZZZZZ" when estado=r else
							"ZZZZZZZZ" when byte_m='1' and address(0)='0' else
							dataToWrite(7 downto 0) when byte_m='1' else
							dataToWrite(15 downto 8);
	
	SRAM_DQ(7 downto 0) <= 	"ZZZZZZZZ" when estado=r  else
							"ZZZZZZZZ" when byte_m='1' and address(0)='1' else
							dataToWrite(7 downto 0);
	
	SRAM_ADDR <= "000"&address(15 downto 1);
	
	dataReaded(15 downto 8) <= 	SRAM_DQ(15 downto 8) when byte_m='0' else
								x"00" when address(0)='0' and SRAM_DQ(7)='0' else
								x"FF" when address(0)='0' and SRAM_DQ(7)='1' else
								x"00" when SRAM_DQ(15)='0' else
								x"FF";
	
	dataReaded(7 downto 0)	<= 	SRAM_DQ(7 downto 0) when byte_m='0' else
								SRAM_DQ(7 downto 0) when address(0)='0' else
								SRAM_DQ(15 downto 8);
end comportament;
