library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb is
end tb;

architecture behavior of tb is

    constant c_spm_num          : integer := 4;  --max 256
    constant c_BANK_ADDR_WIDTH  : integer := 9;  --max 16
    constant c_SIMD             : integer := 3;  --max 255
    constant c_N_RAM_ADDR       : integer := 3;  --min 3
    constant c_N_LOCAL_ADDR     : integer := 3;  --min 3

    constant c_Dimensione               : integer := 100;  --Dimensione RAM
    constant c_starting_addr_op1_ram    : std_logic_vector(31 downto 0) := x"00000000";
    constant c_starting_addr_op2_ram    : std_logic_vector(31 downto 0) := x"00000020";
    constant c_starting_addr_res_ram    : std_logic_vector(31 downto 0) := x"00000040";

    constant c_M_dim    : integer := 4;  --numero di righe matrice
    constant c_N_dim    : integer := 4;  --numero di colonne matrice
    constant c_S_val    : integer := 1;  --stride

    constant c_starting_addr_op1_local_mem  : std_logic_vector(31 downto 0) := x"00000000";
    constant c_starting_addr_op2_local_mem  : std_logic_vector(31 downto 0) := x"00010000";
    constant c_starting_addr_res_local_mem  : std_logic_vector(31 downto 0) := x"00020000";


--Components:
-- Component Declaration for the accelerator
    component matrix_add_accelerator
    generic(
        spm_num         : natural := c_spm_num;
        BANK_ADDR_WIDTH : natural := c_BANK_ADDR_WIDTH;
        SIMD            : natural := c_SIMD;

        N_RAM_ADDR      : natural := c_N_RAM_ADDR;
        N_LOCAL_ADDR    : natural := c_N_LOCAL_ADDR
    );
    port(
        clk                : in    std_logic;
        reset              : in    std_logic;
        cpu_data_in        : in    std_logic_vector(31 downto 0);
        cpu_data_out       : out   std_logic_vector(31 downto 0);
        cpu_addr           : in    std_logic_vector((integer(ceil(log2(real(N_RAM_ADDR + N_LOCAL_ADDR + 2)))) - 1) downto 0);
        cpu_write          : in    std_logic;
        cpu_read           : in    std_logic;
        cpu_acc_busy       : out   std_logic;
        mem_acc_address    : out   std_logic_vector(31 downto 0);
        mem_acc_data       : inout std_logic_vector(31 downto 0);
        mem_acc_read       : out   std_logic;
        mem_acc_write      : out   std_logic
    );
    end component;

    -- Component Declaration for the Ram
    COMPONENT RAM
    generic(
        Dimensione : integer := 382500
    );
    PORT(
        CK : IN std_logic;
        RESET : IN std_logic;
        RD : IN std_logic;
        WR : IN std_logic;
        Addr : IN std_logic_vector(31 downto 0);
        Load : IN std_logic;
        Store : IN std_logic;
        Data : INOUT std_logic_vector(31 downto 0);
        M_dim : IN natural;
        N_dim : IN natural;
        S_val : IN natural;
        starting_addr_op1 : IN std_logic_vector(31 downto 0);
        starting_addr_op2 : IN std_logic_vector(31 downto 0);
        starting_addr_res : IN std_logic_vector(31 downto 0)
    );
    END COMPONENT;

    -- Testbench signals
    --acceleratore
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    signal cpu_data_in  : std_logic_vector(31 downto 0) := (others => '0') ; 
    signal cpu_data_out : std_logic_vector(31 downto 0);
    signal cpu_addr     : std_logic_vector( 2 downto 0) := (others => '0') ;
    signal cpu_write    : std_logic := '0';
    signal cpu_read     : std_logic := '0';
    signal cpu_acc_busy : std_logic;

    signal mem_acc_address : std_logic_vector(31 downto 0);
    signal mem_acc_data : std_logic_vector(31 downto 0) := (others => 'Z');
    signal mem_acc_read : std_logic;
    signal mem_acc_write : std_logic;

    --RAM
    signal Load  : std_logic := '0';
    signal Store : std_logic := '0';
    signal M_dim : natural := 2;
    signal N_dim : natural := 2;
    signal S_val : natural := 1;
    signal starting_addr_op1 : std_logic_vector(31 downto 0) := c_starting_addr_op1_ram;
    signal starting_addr_op2 : std_logic_vector(31 downto 0) := c_starting_addr_op2_ram;
    signal starting_addr_res : std_logic_vector(31 downto 0) := c_starting_addr_res_ram;

 	-- Clock generation process
    constant clk_period : time := 100 ps;

    begin
        clk_process : process
        begin
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end process;

    --Instanziamento dei componenti:
    -- Instantiate the accelerator
    acc: matrix_add_accelerator
    generic map (
        spm_num         => c_spm_num,
        BANK_ADDR_WIDTH => c_BANK_ADDR_WIDTH,
        SIMD            => c_SIMD,
        N_RAM_ADDR      => c_N_RAM_ADDR,
        N_LOCAL_ADDR    => c_N_LOCAL_ADDR
    )
    port map (
        clk             => clk,
        reset           => reset,
        cpu_data_in     => cpu_data_in,
        cpu_data_out    => cpu_data_out,
        cpu_addr        => cpu_addr,
        cpu_write       => cpu_write,
        cpu_read        => cpu_read,
        cpu_acc_busy    => cpu_acc_busy,
        mem_acc_address => mem_acc_address,
        mem_acc_data    => mem_acc_data,
        mem_acc_read    => mem_acc_read,
        mem_acc_write   => mem_acc_write
    );

    -- Instantiate the ram
    mra: RAM generic map(
        Dimensione => c_Dimensione) 
        PORT MAP (
        CK => clk,
        RESET => reset,
        RD => mem_acc_read,
        WR => mem_acc_write,
        Addr => mem_acc_address,
        Load => Load,
        Store => Store,
        Data => mem_acc_data,
        M_dim => M_dim,
        N_dim => N_dim,
        S_val => S_val,
        starting_addr_op1 => starting_addr_op1,
        starting_addr_op2 => starting_addr_op2,
        starting_addr_res => starting_addr_res
    );

    -- Stimulus process
    stim_proc: process

    variable N_INT_REG : integer := integer(ceil(log2(real(c_N_RAM_ADDR + c_N_LOCAL_ADDR + 2))));
    
    begin

        -- Reset the RAM
        RESET <= '1';
        wait for clk_period*2;
        RESET <= '0';
        wait for clk_period*2;

        --Setto M, N, S nella ram.
        M_dim       <= c_M_dim;  --passo M alla ram
        N_dim       <= c_N_dim;  --passo N alla ram
        S_val       <= c_S_val;  --passo S alla ram

        -- Load matrices from files
        Load <= '1';
        wait for clk_period;
        Load <= '0';
        wait for clk_period;

        --Setto M, N e S
        -- Write to the CPU  --SET_M -> OPCODE = 4
        cpu_data_in <= std_logic_vector(to_unsigned( c_M_dim*8 + 4 , 32));
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Write to the CPU  --SET_N -> OPCODE = 5
        cpu_data_in <= std_logic_vector(to_unsigned( c_N_dim*8 + 5 , 32));
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Write to the CPU  --SET_S a 1 (x"0000000E") 0000 1|110  
        cpu_data_in <= std_logic_vector(to_unsigned( c_S_val*8 + 6 , 32));
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

------------------------------------------------------------------------------------
        --Load operandi da memoria centrale a local memory

        --load operando 1:
        --scrivo indirizzi nei registri:
        --scrivo indirizzo memoria ram:
        cpu_data_in <= c_starting_addr_op1_ram;                             --il primo operando sta all'indirizzo 0 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(2, N_INT_REG));     --indirizzo 0 dei registri della ram (primo registro ram)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --scrivo indirizzo memoria locale  
        cpu_data_in <= c_starting_addr_op1_local_mem;        						-- il primo operando lo carico all'indirizzo 0 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(5, N_INT_REG));    	--indirizzo 0 dei registri della mem locale (primo registro mem locale)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --invio istruzione di load:      	|0 0000 |0000 0|001 = x"00000001"
        cpu_data_in <= x"00000001";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*(c_M_dim*c_N_dim + 10);
-----------------------------------------------------------------------------------------
        --load operando 2:
        --scrivo indirizzi nei registri:
        --scrivo indirizzo memoria ram:
        cpu_data_in <= c_starting_addr_op2_ram;								--il secondo operando sta all'indirizzo x400 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(3, N_INT_REG));    	--indirizzo 1 dei registri della ram (secondo registro ram)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --scrivo indirizzo memoria locale
        cpu_data_in <= c_starting_addr_op2_local_mem;        						--il secondo operando lo carico all'indirizzo x40 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(6, N_INT_REG));		--indirizzo 1 dei registri mem locale (secondo registro mem locale)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --invio istruzione di load:         |0 0001 |0000 1|001 = x"00000109"
        cpu_data_in <= x"00000109";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*(c_M_dim*c_N_dim + 10);
---------------------------------------------------------------------------------------
        --somma operandi
        --scrivo indirizzo memoria locale risultato
        cpu_data_in <= c_starting_addr_res_local_mem;        						-- il risultato lo scrivo all'indirizzo x80 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(7, N_INT_REG));		--indirizzo 2 dei registri mem locale (terzo registro mem locale)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --invio istruzione di somma:        |00 010|0 0001 |0000 0|011 = x"00004103"
        cpu_data_in <= x"00004103";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*((c_M_dim*c_N_dim)/c_spm_num + 10);
------------------------------------------------------------------------------------
        --Store matrice risultante
        --scrivo indirizzo ram risultato
 		cpu_data_in <= c_starting_addr_res_ram;        						-- il risultato lo scrivo all'indirizzo x500 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(4, N_INT_REG));		--indirizzo 2 dei registri ram (terzo registro ram)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --invio istruzione di store         |0 0010 |0001 0|010 = x"00000212"
        cpu_data_in <= x"00000212";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*(c_M_dim*c_N_dim + 10);
----------------------------------------------------------------------------------
        -- Store results back to file
        Store <= '1';
        wait for clk_period;
        Store <= '0';
        wait for clk_period;

        -- Finish the simulation
        wait;
    end process;


end behavior;
