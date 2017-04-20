library ieee;
USE ieee.std_logic_1164.all;

entity multi is
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_l    : IN  STD_LOGIC;
         wrd_l     : IN  STD_LOGIC;
         wr_m_l    : IN  STD_LOGIC;
		 wr_o_l	   : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
         wr_m      : OUT STD_LOGIC;
		 wr_out	   : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
         word_byte : OUT STD_LOGIC);
end entity;

architecture Structure of multi is
	type estado_proc is (F, DEMW);
	signal state   : estado_proc;
begin
	process (clk) begin
		if rising_edge(clk) then
			if boot='1' then
				state <= F;
			elsif state = F then
				state <= DEMW;
			else
				state <= F;
			end if;
		end if;
	end process;
    ldpc <=	ldpc_l when state = DEMW else '0';
	
	wrd <=	wrd_l when state = DEMW else '0';
	
	wr_m <=	wr_m_l when state = DEMW else '0';
	
	wr_out <= wr_o_l when state = DEMW else '0';
	
	word_byte <=w_b when state = DEMW else '0';
	
	ins_dad <= '0' when state = F else '1';
	
	ldir <= '1' when state = F else '0';
end Structure;
