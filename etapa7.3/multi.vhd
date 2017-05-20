library ieee;
USE ieee.std_logic_1164.all;

entity multi is
    port(       clk         : IN  STD_LOGIC;
                boot        : IN  STD_LOGIC;
                ldpc_l      : IN  STD_LOGIC;
                wrd_l       : IN  STD_LOGIC;
                wr_m_l      : IN  STD_LOGIC;
                wr_o_l      : IN  STD_LOGIC;
                w_b         : IN  STD_LOGIC;
                exception   : IN  STD_LOGIC;	-- ejecutar system
                wrdsys_l    : IN  STD_LOGIC;
                commit      : IN  STD_LOGIC;
                mem_pet_l   : IN  STD_LOGIC;
                instr_prot_l: IN  STD_LOGIC;
                ldpc        : OUT STD_LOGIC;
                wrd         : OUT STD_LOGIC;
                wr_m        : OUT STD_LOGIC;
                wr_out      : OUT STD_LOGIC;
                ldir        : OUT STD_LOGIC;
                ins_dad     : OUT STD_LOGIC;
                word_byte   : OUT STD_LOGIC;
                wrdsys      : OUT STD_LOGIC;
                c_system    : OUT STD_LOGIC; -- 1 si el ciclo actual es de system
                mem_pet     : OUT STD_LOGIC;
                instr_prot  : OUT STD_LOGIC;
                exc_ack     : OUT STD_LOGIC;
                etapa       : OUT STD_LOGIC_VECTOR(1 downto 0));
end multi;

architecture Structure of multi is
    type estado_proc is (F, DEMW, SYSTEM);
    signal state   : estado_proc;
    signal c_system_tmp : std_logic := '0';
    signal c_system_ant : std_logic := '0';
begin
    process (clk) begin
        if rising_edge(clk) then
            if boot='1' then
                state <= F;
            elsif state = F then
                state <= DEMW;
            elsif state = DEMW and exception = '1' then
                state <= SYSTEM;
            else
                state <= F;
            end if;
            
            if c_system_tmp='1' and c_system_ant='0' then
                exc_ack <= '1';
            else
                exc_ack <= '0';
            end if;
            c_system_ant <= c_system_tmp;
        end if;
    end process;
    ldpc <=	ldpc_l and commit when state = DEMW else '1' when state = SYSTEM else '0';
    
    wrd <=	wrd_l and commit when state = DEMW else '0';
    
    wr_m <=	wr_m_l and commit when state = DEMW else '0';
    
    wr_out <= wr_o_l and commit when state = DEMW else '0';
    
    word_byte <=w_b when state = DEMW else '0';
    
    --ins_dad <= '0' when state = F else '1';
    ins_dad <= '1' when state = DEMW else '0';
    
    ldir <= '1' when state = F else '0';
    
    c_system_tmp <= '1' when state = SYSTEM else '0';
    
    c_system <= c_system_tmp;
    
    wrdsys <= wrdsys_l and commit when state = DEMW else '0';	-- en ciclo system se guarda algo igual
    
    mem_pet <= '1' when state = F else mem_pet_l and commit when state = DEMW else '0';
    
    instr_prot <= instr_prot_l when state=DEMW else '0';
    
    etapa <=    "00" when state = F else 
                "01" when state = DEMW else 
                "10" when state = SYSTEM else 
                "11";
    
end Structure;
