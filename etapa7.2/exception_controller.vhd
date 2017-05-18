LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY exception_controller IS
    PORT (  int_hab         : IN  STD_LOGIC;
            intr            : IN  STD_LOGIC;    -- codigo 15 si int_hab=1
            div_zero        : IN  STD_LOGIC;    -- codigo 4
            illegal_instr   : IN  STD_LOGIC;    -- codigo 0
            al_ilegal       : IN  STD_LOGIC;    -- codigo 1
            addr_m          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            exception       : OUT STD_LOGIC;    -- '1' si hay que ir a fase SYSTEM
            commit          : OUT STD_LOGIC;    -- Si '0', los permisos de escritura y ld_pc se ponen a 0: hay que repetir la instruccion
            t_evento        : OUT STD_LOGIC_VECTOR( 3 DOWNTO 0); 
            dir_acc         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END exception_controller;

ARCHITECTURE Structure OF exception_controller IS

signal exc_local : std_logic := '0';
signal t_ev_local : std_logic_vector(3 downto 0);

BEGIN
    exc_local <=    '1' when illegal_instr='1' else
                    '1' when al_ilegal='1' else
                    '1' when div_zero='1' else
                    '1' when int_hab='1' and intr='1' else
                    '0';
    process (exc_local) begin
        if exc_local='1' then
            if illegal_instr='1' then
                t_ev_local <= "0000";
            elsif al_ilegal='1' then
                t_ev_local <= "0001";
            elsif div_zero='1' then
                t_ev_local <= "0100";
            elsif int_hab='1' and intr='1' then
                t_ev_local <= "1111";
            end if;
        
        end if;
    --t_ev_local <=   "0000" when illegal_instr='1' else
    --                "0001" when al_ilegal='1' else
    --                "0100" when div_zero='1' else
    --                "1111" when int_hab='1' and intr='1' else
    --                "1010"; -- no se usa
    
    end process;
    process (al_ilegal) begin
        if rising_edge(al_ilegal) then
            dir_acc <= addr_m;
        end if;
    end process;
    commit <=   '1' when exc_local='0' else
                '0' when t_ev_local="0000" else
                '0' when t_ev_local="0001" else
                '1';
    
    exception <= exc_local;
    
    t_evento <= t_ev_local;
END Structure;