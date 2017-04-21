LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY pulsadores IS
    PORT (CLOCK_50  : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          keys      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
          intr      : OUT STD_LOGIC;
          read_key  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END pulsadores;

ARCHITECTURE Structure OF pulsadores IS
    signal keys_reg : std_logic_vector(3 downto 0) := "1111"; -- por defecto a 1 porque el mundo es una mierda
BEGIN
    process (CLOCK_50) begin
        if rising_edge(CLOCK_50) then
            if boot='0' then
                if keys /= keys_reg then
                    intr <= '1';
                end if;
            end if;
            if inta='1' then
                intr <= '0';
            end if;
            keys_reg <= keys;
        end if;
    end process;
    read_key <= keys;
END Structure;