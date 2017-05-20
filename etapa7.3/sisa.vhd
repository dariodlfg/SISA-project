LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (  CLOCK_50        : IN    STD_LOGIC;
            SRAM_ADDR       : out   std_logic_vector(17 downto 0);
            SRAM_DQ         : inout std_logic_vector(15 downto 0);
            SRAM_UB_N       : out   std_logic;
            SRAM_LB_N       : out   std_logic;
            SRAM_CE_N       : out   std_logic := '1';
            SRAM_OE_N       : out   std_logic := '1';
            SRAM_WE_N       : out   std_logic := '1';
            SW              : in    std_logic_vector(9 downto 0);
            KEY             : in    std_logic_vector(3 downto 0);
            HEX0            : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
            HEX1            : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
            HEX2            : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
            HEX3            : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
            LEDG            : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            LEDR            : OUT   STD_LOGIC_VECTOR(9 DOWNTO 0);
            PS2_CLK         : INOUT STD_LOGIC;
            PS2_DAT         : INOUT STD_LOGIC;
            VGA_HS          : OUT   STD_LOGIC;
            VGA_VS          : OUT   STD_LOGIC;
            VGA_R           : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_G           : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_B           : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0));
END sisa;

ARCHITECTURE Structure OF sisa IS
    component proc
        port (  clk         : IN  STD_LOGIC;
                boot        : IN  STD_LOGIC;
                datard_m    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
                addr_m      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                data_wr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                wr_m        : OUT STD_LOGIC;
                word_byte   : OUT STD_LOGIC;
                addr_io     : out std_logic_vector( 7 downto 0);
                wr_io       : out std_logic_vector(15 downto 0);
                rd_io       : in  std_logic_vector(15 downto 0);
                wr_out      : out std_logic;
                rd_in       : out std_logic;
                etapa       : out std_logic_vector( 1 downto 0);
                al_ilegal   : IN  STD_LOGIC;    -- lo calculamos en el controlador de memoria
                intr        : in  std_logic;
                inta        : out std_logic;
                exc         : OUT STD_LOGIC);
    end component;
    
    component MemoryController
        port (  clk         : in  std_logic;
            addr        : in  std_logic_vector(15 downto 0);
            wr_data     : in  std_logic_vector(15 downto 0);
            rd_data     : out std_logic_vector(15 downto 0);
            we          : in  std_logic;
            byte_m      : in  std_logic;
            -- señales para la placa de desarrollo
            SRAM_ADDR   : out   std_logic_vector(17 downto 0);
            SRAM_DQ     : inout std_logic_vector(15 downto 0);
            SRAM_UB_N   : out   std_logic;
            SRAM_LB_N   : out   std_logic;
            SRAM_CE_N   : out   std_logic := '1';
            SRAM_OE_N   : out   std_logic := '1';
            SRAM_WE_N   : out   std_logic := '1';
            -- señales vga
            vga_addr    : out   std_logic_vector(12 downto 0);
            vga_we      : out   std_logic;
            vga_wr_data : out   std_logic_vector(15 downto 0);
            vga_rd_data : in    std_logic_vector(15 downto 0);
            al_ilegal   : out   std_logic);
    end component;
    
    component controladores_IO
        port (  boot        : IN STD_LOGIC;
                debug       : IN STD_LOGIC;
                addr_m      : IN std_logic_vector(15 downto 0);
                CLOCK_50    : IN std_logic;
                addr_io     : IN std_logic_vector(7 downto 0);
                wr_io       : in std_logic_vector(15 downto 0);
                rd_io       : out std_logic_vector(15 downto 0);
                wr_out      : in std_logic;
                rd_in       : in std_logic;
                led_verdes  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                led_rojos   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                keys        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
                switchs     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                visor0      : OUT STD_LOGIC_VECTOR(6 downto 0);
                visor1      : OUT STD_LOGIC_VECTOR(6 downto 0);
                visor2      : OUT STD_LOGIC_VECTOR(6 downto 0);
                visor3      : OUT STD_LOGIC_VECTOR(6 downto 0);
                ps2_clk     : inout std_logic;
                ps2_data    : inout std_logic;
                vga_cursor  : out std_logic_vector(15 downto 0);
                vga_cursor_enable   : out std_logic;
                inta        : IN  STD_LOGIC;
                intr        : OUT STD_LOGIC);
    end component;
    
    component vga_controller    -- necesitamos cosas de MemoryController y de controladores_IO, asÃƒÆ’Ã‚Â­ que lo dejamos aquÃƒÆ’Ã‚Â­
        port(   clk_50mhz       : in  std_logic; -- system clock signal
                reset           : in  std_logic; -- system reset
                blank_out       : out std_logic; -- vga control signal
                csync_out       : out std_logic; -- vga control signal
                red_out         : out std_logic_vector(7 downto 0); -- vga red pixel value
                green_out       : out std_logic_vector(7 downto 0); -- vga green pixel value
                blue_out        : out std_logic_vector(7 downto 0); -- vga blue pixel value
                horiz_sync_out  : out std_logic; -- vga control signal
                vert_sync_out   : out std_logic; -- vga control signal
                --
                addr_vga        : in std_logic_vector(12 downto 0);
                we              : in std_logic;
                wr_data         : in std_logic_vector(15 downto 0);
                rd_data         : out std_logic_vector(15 downto 0);
                byte_m          : in std_logic;
                vga_cursor      : in std_logic_vector(15 downto 0);
                vga_cursor_enable   : in std_logic);
    end component;
    
    signal datard_m_to_proc : std_logic_vector(15 downto 0);
    
    signal addr_m_from_proc : std_logic_vector(15 downto 0);
    signal data_wr_from_proc : std_logic_vector(15 downto 0);
    signal wr_m_from_proc : std_logic;
    signal word_byte_from_proc : std_logic;
    signal rd_io_from_io : std_logic_vector(15 downto 0);
    signal addr_io_from_proc : std_logic_vector(7 downto 0);
    signal wr_io_from_proc : std_logic_vector(15 downto 0);
    signal wr_out_from_proc : std_logic;
    signal rd_in_from_proc : std_logic;
    
    signal vga_red : std_logic_vector(7 downto 0);
    signal vga_green : std_logic_vector(7 downto 0);
    signal vga_blue : std_logic_vector(7 downto 0);
    
    signal relleno_blank_out : std_logic;
    signal relleno_csync_out : std_logic;
    
    signal addr_vga_frommem : std_logic_vector(12 downto 0);
    signal we_frommem : std_logic;
    signal wr_data_frommem : std_logic_vector(15 downto 0);
    signal rd_data_frommem : std_logic_vector(15 downto 0);
    signal byte_m_frommem : std_logic;
    signal vga_cursor_fromio : std_logic_vector(15 downto 0);
    signal vga_c_e_fromio : std_logic;
    
    signal pc_fromproc : std_logic_vector(15 downto 0);
    
    signal intr_fromio : std_logic := '0';
    signal inta_toio   : std_logic := '0';
    
    signal al_ilegal_frommem : std_logic := '0';
    
    signal mem_pet_tomem : std_logic := '0';
    
    signal modo_sist_tomem : std_logic := '1';
    
    signal mem_prot_frommem : std_logic := '0';
    
    signal clock_counter : std_logic_vector(4 downto 0) := "00000";
    signal adv_instr : std_logic := '0';    -- si 1, avanza hasta el comienzo de la siguiente instruccion
    -- Si SW(8)='1', avanza una instrucciÃƒÆ’Ã‚Â³n cada vez que se pulsa KEY(0) -> avanza 4 ciclos
BEGIN
    process(CLOCK_50) begin
        if rising_edge(CLOCK_50) and SW(8)='0' then
            clock_counter <= clock_counter + 1;
        elsif rising_edge(CLOCK_50) and (clock_counter(0)='1' or clock_counter(1)='1' or clock_counter(2)='1' or clock_counter(3)='1') then 
            clock_counter <= clock_counter + 1;
        elsif rising_edge(CLOCK_50) and adv_instr='0' and KEY(0)='0' then 
            clock_counter <= clock_counter + 1;
            adv_instr <= '1';
        elsif rising_edge(CLOCK_50) and adv_instr='1' and KEY(0)='1' then
            adv_instr <= '0';
        end if;
    end process;
    --LEDR(9) <= intr_fromio;
    --LEDR(8) <= inta_toio;
    LEDR(8) <= al_ilegal_frommem;             
    
    procesador : proc
        port map(   clk => clock_counter(3),
                    boot => SW(9),
                    datard_m => datard_m_to_proc,
                    addr_m => addr_m_from_proc,
                    data_wr => data_wr_from_proc,
                    wr_m => wr_m_from_proc,
                    word_byte => word_byte_from_proc,
                    addr_io => addr_io_from_proc,
                    wr_io => wr_io_from_proc,
                    rd_io => rd_io_from_io,
                    wr_out => wr_out_from_proc,
                    rd_in => rd_in_from_proc,
                    --etapa => LEDR(9 downto 8),
                    intr => intr_fromio,
                    inta => inta_toio,
                    al_ilegal => al_ilegal_frommem,
                    exc => LEDR(9));
                    --instr_prot => LEDR(9));
    
    memControl : MemoryController
        port map(   clk => CLOCK_50,
                    addr => addr_m_from_proc,
                    wr_data => data_wr_from_proc,
                    rd_data => datard_m_to_proc,
                    we => wr_m_from_proc,
                    byte_m => word_byte_from_proc,
                    SRAM_ADDR => SRAM_ADDR,
                    SRAM_DQ => SRAM_DQ,
                    SRAM_UB_N => SRAM_UB_N,
                    SRAM_LB_N => SRAM_LB_N,
                    SRAM_CE_N => SRAM_CE_N,
                    SRAM_OE_N => SRAM_OE_N,
                    SRAM_WE_N => SRAM_WE_N,
                    vga_addr => addr_vga_frommem,
                    vga_we => we_frommem,
                    vga_wr_data => wr_data_frommem,
                    vga_rd_data => rd_data_frommem,
                    al_ilegal => al_ilegal_frommem);
    
    controlIO : controladores_IO
        port map(   boot => SW(9),
                    debug => SW(8),
                    addr_m => addr_m_from_proc,
                    CLOCK_50 => CLOCK_50,
                    addr_io => addr_io_from_proc,
                    wr_io => wr_io_from_proc,
                    rd_io => rd_io_from_io,
                    wr_out => wr_out_from_proc,
                    rd_in => rd_in_from_proc,
                    led_verdes => LEDG,
                    led_rojos => LEDR(7 downto 0),
                    keys => KEY,
                    switchs => SW(7 downto 0),
                    visor0 => HEX0,
                    visor1 => HEX1,
                    visor2 => HEX2,
                    visor3 => HEX3,
                    ps2_clk => PS2_CLK,
                    ps2_data => PS2_DAT,
                    vga_cursor => vga_cursor_fromio,
                    vga_cursor_enable => vga_c_e_fromio,
                    intr => intr_fromio,
                    inta => inta_toio);
    

    vga_c : vga_controller
        port map(
            clk_50mhz => CLOCK_50,
            reset => SW(9),
            blank_out => relleno_blank_out,
            csync_out => relleno_csync_out,
            red_out => vga_red,
            green_out => vga_green,
            blue_out => vga_blue,
            horiz_sync_out => VGA_HS,
            vert_sync_out => VGA_VS,
            --
            addr_vga => addr_vga_frommem,
            we => we_frommem,
            wr_data => wr_data_frommem,
            rd_data => rd_data_frommem,
            byte_m => word_byte_from_proc,
            vga_cursor => vga_cursor_fromio,
            vga_cursor_enable => vga_c_e_fromio);
            VGA_R <= vga_red(3 downto 0);
            VGA_G <= vga_green(3 downto 0);
            VGA_B <= vga_blue(3 downto 0);
END Structure;

