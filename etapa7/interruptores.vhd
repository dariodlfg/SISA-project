LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY interruptores IS
    PORT (CLOCK_50  : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          switches  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
          intr      : OUT STD_LOGIC;
          rd_switch : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END interruptores;

ARCHITECTURE Structure OF interruptores IS
    signal switch_reg : std_logic_vector(7 downto 0) := x"00"; 
BEGIN
    process (CLOCK_50) begin
        if rising_edge(CLOCK_50) then
            if boot='0' then
                if switches /= switch_reg then
                    intr <= '1';
                end if;
            end if;
            if inta='1' then
                intr <= '0';
            end if;
            switch_reg <= switches;
        end if;
    end process;
    rd_switch <= switches;
END Structure;