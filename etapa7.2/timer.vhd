LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY timer IS
    PORT (CLOCK_50  : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          inta      : IN  STD_LOGIC;
          intr      : OUT STD_LOGIC);
END timer;

ARCHITECTURE Structure OF timer IS
    signal ciclos : std_logic_vector(23 downto 0) := x"2625A0"; -- 50*50000
BEGIN
    process (CLOCK_50) begin
        if rising_edge(CLOCK_50) then
            if boot='1' then
                ciclos <= x"2625A0";
            elsif ciclos=x"000000" then
                intr <= '1';
                ciclos <= x"2625A0";
            else
                ciclos <= ciclos - 1;
            end if;
            if inta='1' then
                intr <= '0';
            end if;
        end if;
    end process;
END Structure;