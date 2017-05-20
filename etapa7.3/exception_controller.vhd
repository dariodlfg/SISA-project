LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY exception_controller IS
    PORT (  clk             : IN  STD_LOGIC;
            illegal_instr   : IN  STD_LOGIC;    -- codigo 0
            al_ilegal       : IN  STD_LOGIC;    -- codigo 1
            div_zero        : IN  STD_LOGIC;    -- codigo 4
            mem_prot        : IN  STD_LOGIC;    -- codigo 11
            instr_prot      : IN  STD_LOGIC;    -- codigo 13
            es_calls        : IN  STD_LOGIC;    -- codigo 14
            intr            : IN  STD_LOGIC;    -- codigo 15 si int_hab=1
            int_hab         : IN  STD_LOGIC;
            addr_m          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            exc_ack         : IN  STD_LOGIC;
            exception       : OUT STD_LOGIC;    -- '1' si hay que ir a fase SYSTEM
            commit          : OUT STD_LOGIC;    -- Si '0', los permisos de escritura y ld_pc se ponen a 0: hay que repetir la instruccion
            t_evento        : OUT STD_LOGIC_VECTOR( 3 DOWNTO 0); 
            dir_acc         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END exception_controller;

ARCHITECTURE Structure OF exception_controller IS

signal exc_local : std_logic := '0';
signal t_ev_local : std_logic_vector(3 downto 0) := "0000";

BEGIN
    -- alguna de las señales bugea jarto
    process (clk,illegal_instr,al_ilegal,div_zero,mem_prot,instr_prot,es_calls,int_hab,intr,exc_ack) begin
        if falling_edge(clk) then
            if exc_ack='1' then
                exc_local <= '0';
                --t_ev_local <= "0101";
            elsif illegal_instr='1' then
                exc_local <= '1';
                t_ev_local <= "0000";
            elsif al_ilegal='1' then
                exc_local <= '1';
                t_ev_local <= "0001";
                dir_acc <= addr_m;
            elsif div_zero='1' then
                exc_local <= '1';
                t_ev_local <= "0100";
            elsif mem_prot='1' then
                exc_local <= '1';
                t_ev_local <= "1011";
            elsif instr_prot='1' then
                exc_local <= '1';
                t_ev_local <= "1101";
            elsif es_calls='1' then
                exc_local <= '1';
                t_ev_local <= "1110";
            elsif int_hab='1' and intr='1' then
               exc_local <= '1';
               t_ev_local <= "1111";
            end if;
        end if;
    end process;
--    exc_local <=    '0' when exc_ack='1' else
--                    '1' when illegal_instr='1' else
--                    '1' when al_ilegal='1' else
--                    '1' when div_zero='1' else
--                    '1' when mem_prot='1' else
--                    '1' when instr_prot='1' else
--                    '1' when es_calls='1' else
--                    '1' when int_hab='1' and intr='1' else
--                    '0';
    --process (exc_local) begin
    --    if rising_edge(exc_local) then
    --        if illegal_instr='1' then
    --            t_ev_local <= "0000";
    --        elsif al_ilegal='1' then
    --            t_ev_local <= "0001";
    --        elsif div_zero='1' then
    --            t_ev_local <= "0100";
    --        elsif mem_prot='1' then
    --            t_ev_local <= "1011";
    --        elsif instr_prot='1' then
    --            t_ev_local <= "1101";
    --        elsif es_calls='1' then
    --            t_ev_local <= "1110";
    --        elsif int_hab='1' and intr='1' then
    --            t_ev_local <= "1111";
    --        end if;
    --    end if;
    --t_ev_local <=   "0000" when illegal_instr='1' else
    --                "0001" when al_ilegal='1' else
    --                "0100" when div_zero='1' else
    --                "1111" when int_hab='1' and intr='1' else
    --                "1010"; -- no se usa
    
    --end process;
    
    --process (al_ilegal) begin
    --    if rising_edge(al_ilegal) then
    --        dir_acc <= addr_m;
    --    end if;
    --end process;
    process(exc_local,t_ev_local) begin
        if exc_local='0' then
            commit <= '1';
        elsif t_ev_local="0000" or t_ev_local="0001" or t_ev_local="1011" or t_ev_local="1101" then
            commit <= '0';
        else
            commit <= '1';
        end if;
    end process;
    --commit <=   '1' when exc_local='0' else
    --            '0' when t_ev_local="0000" else
    --            '0' when t_ev_local="0001" else
    --            '0' when t_ev_local="1011" else
    --            '0' when t_ev_local="1101" else
    --            '1';
    
    exception <= exc_local;
    
    t_evento <= t_ev_local;
END Structure;