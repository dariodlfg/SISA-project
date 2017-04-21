LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY interrupt_controller IS
    PORT (clk           : IN  STD_LOGIC;
          boot          : IN  STD_LOGIC;
          inta          : IN  STD_LOGIC;
          key_intr      : IN  STD_LOGIC;
          ps2_intr      : IN  STD_LOGIC;
          switch_intr   : IN  STD_LOGIC;
          timer_intr    : IN  STD_LOGIC;
          ps2_helper    : IN  STD_LOGIC;    -- esto es para que el quartus compile
          intr          : OUT STD_LOGIC;
          key_inta      : OUT STD_LOGIC;
          ps2_inta      : OUT STD_LOGIC;
          switch_inta   : OUT STD_LOGIC;
          timer_inta    : OUT STD_LOGIC;
          iid           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END interrupt_controller;

ARCHITECTURE Structure OF interrupt_controller IS
signal inta_antes : std_logic := '0';
BEGIN
    process (clk) begin
        if rising_edge(clk) then
            if boot='1' then
                key_inta <= '0';
                ps2_inta <= '0';
                switch_inta <= '0';
                timer_inta <= '0';
            end if;
            if ps2_helper='1' then
                ps2_inta <= '0';
            end if;
            if inta='1' and inta_antes='0' then -- "rising edge"
                if timer_intr='1' then
                    timer_inta <= '1';
                    iid <= x"00";
                elsif key_intr='1' then
                    key_inta <= '1';
                    iid <= x"01";
                elsif switch_intr='1' then
                    switch_inta <= '1';
                    iid <= x"02";
                elsif ps2_intr='1' then
                    ps2_inta <= '1';
                    iid <= x"03";
                else
                    key_inta <= '0';
                    ps2_inta <= '0';
                    switch_inta <= '0';
                    timer_inta <= '0';
                end if;
            end if;
        end if;
        inta_antes <= inta;
    end process;
    intr <= '0' when boot='0' else key_intr or ps2_intr or switch_intr or timer_intr;
END Structure;