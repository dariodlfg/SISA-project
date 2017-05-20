LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY datapath IS
    PORT (  clk         : IN  STD_LOGIC;
            boot        : IN  STD_LOGIC;
            op          : IN  STD_LOGIC_VECTOR( 6 DOWNTO 0);
            wrd         : IN  STD_LOGIC;
            addr_a      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            addr_b      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            addr_d      : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            immed       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            immed_x2    : IN  STD_LOGIC;
            datard_m    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            ins_dad     : IN  STD_LOGIC;
            pc          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in_d        : IN  STD_LOGIC_VECTOR( 1 DOWNTO 0);
            rb_n        : IN  STD_LOGIC;
            rd_in       : IN  STD_LOGIC;
            rd_io       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            a_sys       : IN  STD_LOGIC;
            wrd_sys     : IN  STD_LOGIC;
            c_system    : IN  STD_LOGIC;
            es_reti     : IN  STD_LOGIC;
            t_evento    : IN  STD_LOGIC_VECTOR( 3 DOWNTO 0);
            dir_acc     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            addr_m      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            data_wr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            z           : OUT STD_LOGIC;
            aluout      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            int_hab     : OUT STD_LOGIC;
            div_zero    : OUT STD_LOGIC;
            modo_sist   : OUT STD_LOGIC);
END datapath;


ARCHITECTURE Structure OF datapath IS

    -- Aqui iria la declaracion de las entidades que vamos a usar
    -- Usaremos la palabra reservada COMPONENT ...
    -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
    component regfile
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
    end component;
    
    component alu
        port (  x       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
                y       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
                op      : IN  STD_LOGIC_VECTOR( 6 DOWNTO 0);
                w       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                z       : OUT STD_LOGIC;
                div_zero: OUT STD_LOGIC);
    end component;
    
    signal d_toreg : std_logic_vector(15 downto 0);
    signal b_fromreg : std_logic_vector(15 downto 0);
    signal x_toalu : std_logic_vector(15 downto 0);
    signal y_toalu : std_logic_vector(15 downto 0);
    signal w_fromalu : std_logic_vector(15 downto 0);
    signal pc_inc : std_logic_vector(15 downto 0);
BEGIN
    y_toalu <=  b_fromreg when rb_n='1' else
                immed when immed_x2='0' else
                immed(14 downto 0)&'0';
    
    addr_m  <= 	w_fromalu when ins_dad='1' else
                pc;
    --process (clk) begin            
    --    if falling_edge(clk) then
    pc_inc <= pc+2;
    --    end if;
    --end process;
    d_toreg <=  pc when in_d="11" else
                rd_io when rd_in='1' else
                datard_m when in_d="01" else
                w_fromalu when in_d="00" else
                pc_inc;
                
    regs : regfile
        port map(
            clk => clk,
            boot => boot,
            wrd => wrd,
            d => d_toreg,
            addr_a => addr_a,
            addr_b => addr_b,
            addr_d => addr_d,
            a => x_toalu,
            b => b_fromreg,
            a_sys => a_sys,
            wrd_sys => wrd_sys,
            int_hab => int_hab,
            c_system => c_system,
            t_evento => t_evento,
            es_reti => es_reti,
            dir_inv => dir_acc,
            modo_sist => modo_sist);
    alu0 : alu
        port map(
            x => x_toalu,
            y => y_toalu,
            op => op,
            w => w_fromalu,
            z => z,
            div_zero => div_zero);
    data_wr <= b_fromreg;
    aluout <= w_fromalu;
END Structure;