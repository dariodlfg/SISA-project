
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER

ENTITY regfile IS
    PORT (  clk         : IN  STD_LOGIC;
            boot        : IN  STD_LOGIC;
            wrd         : IN  STD_LOGIC;
            d           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            addr_a      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            addr_b      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            addr_d      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            a_sys       : IN  STD_LOGIC;
            wrd_sys     : IN  STD_LOGIC;
            c_system    : IN  STD_LOGIC; 
            t_evento    : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
            dir_inv     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            es_reti     : IN  STD_LOGIC;
            a           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            b           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            int_hab     : OUT STD_LOGIC;        -- interrupciones habilitadas
            modo_sist   : OUT STD_LOGIC);       -- modo sistema
END regfile;

ARCHITECTURE Structure OF regfile IS
    type bancoreg is array(7 downto 0) of std_logic_vector(15 downto 0);
    signal regs : bancoreg;
    signal regsistema : bancoreg;

BEGIN
    process (clk,boot,wrd,wrd_sys, c_system) begin
        if rising_edge(clk) then
            if boot='1' then
                regs <= (others => (others => '0'));
            elsif wrd='1' then
                regs(to_integer(unsigned(addr_d))) <= d;
            end if;
        end if;
        if rising_edge(clk) then
            if boot='1' then
                regsistema(7) <= x"0001";           -- empezamos en modo sistema
                --regsistema <= (others => x"0000");
            elsif c_system='1' then 
                regsistema(0) <= regsistema(7);
                regsistema(1) <= d;
                regsistema(2) <= x"000"&t_evento;
                if t_evento="0001" then
                    regsistema(3) <= dir_inv;
                end if;
                regsistema(7)(1) <= '0';
                regsistema(7)(0) <= '1';
            elsif es_reti='1' then 
                regsistema(7) <= regsistema(0);
            elsif wrd_sys='1' then
                regsistema(to_integer(unsigned(addr_d))) <= d;
            end if;
        end if;
    end process;
    a <=    regsistema(5) when c_system='1' else
            regsistema(1) when es_reti='1' else
            regs(to_integer(unsigned(addr_a))) when a_sys='0' else
            regsistema(to_integer(unsigned(addr_a)));
    b <= regs(to_integer(unsigned(addr_b)));
    
    int_hab <= regsistema(7)(1);
    modo_sist <= regsistema(7)(0);
END Structure;