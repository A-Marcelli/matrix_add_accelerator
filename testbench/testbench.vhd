library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb is
end tb;

architecture behavior of tb is

--Components:
-- Component Declaration for the accelerator
    component matrix_add_accelerator
    generic(
        SPM_NUM         : natural := 4;
        BANK_ADDR_WIDTH : natural := 6;
        SIMD            : natural := 10;

        N_RAM_ADDR      : natural := 3;
        N_LOCAL_ADDR    : natural := 3
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
    signal Load : std_logic := '0';
    signal Store : std_logic := '0';
    signal M_dim : natural := 2; -- 2 rows
    signal N_dim : natural := 2; -- 2 columns
    signal S_val : natural := 1;  -- stride value
    signal starting_addr_op1 : std_logic_vector(31 downto 0) := x"00000000";
    signal starting_addr_op2 : std_logic_vector(31 downto 0) := x"00000400";
    signal starting_addr_res : std_logic_vector(31 downto 0) := x"00000800";

 	-- Clock generation process
    constant clk_period : time := 10 ns;

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
        SPM_NUM         => 4,
        BANK_ADDR_WIDTH => 6,
        SIMD            => 10,
        N_RAM_ADDR      => 3,
        N_LOCAL_ADDR    => 3
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
    mra: RAM PORT MAP (
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
    begin

        -- Reset the RAM
        RESET <= '1';
        wait for clk_period*2;
        RESET <= '0';
        wait for clk_period*2;

        --Setto M, N, S nella ram.
        M_dim       <= 5;  --passo M alla ram
        N_dim       <= 2;  --passo N alla ram
        S_val       <= 1;  	--passo S alla ram

        -- Load matrices from files
        Load <= '1';
        wait for clk_period;
        Load <= '0';
        wait for clk_period;

        --Setto M, N e S
        -- Write to the CPU  --SET_M a 5 (x"0000002c") 000 0010 1|100
        cpu_data_in <= x"0000002c";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Write to the CPU  --SET_N a 2 (x"00000015") 0001 0|101
        cpu_data_in <= x"00000015";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Write to the CPU  --SET_S a 1 (x"0000000E") 0000 1|110  
        cpu_data_in <= x"0000000E";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Read from the CPU the CSR, should return 0
        cpu_addr    <= std_logic_vector(to_unsigned(1,3));
        cpu_read    <= '1';
        wait for clk_period;
        cpu_read    <= '0';
        wait for clk_period * 10;
------------------------------------------------------------------------------------
        --Load operandi da memoria centrale a local memory

        --load operando 1:
        --scrivo indirizzi nei registri:
        --scrivo indirizzo memoria ram:
        cpu_data_in <= x"00000000";                             --il primo operando sta all'indirizzo 0 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(2, 3));     --indirizzo 0 dei registri della ram (primo registro ram)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --scrivo indirizzo memoria locale  
        cpu_data_in <= x"0000003F";        						-- il primo operando lo carico all'indirizzo 0 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(5, 3));    	--indirizzo 0 dei registri della mem locale (primo registro mem locale)
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
        wait for clk_period*710;
-----------------------------------------------------------------------------------------
        --load operando 2:
        --scrivo indirizzi nei registri:
        --scrivo indirizzo memoria ram:
        cpu_data_in <= x"00000400";								--il secondo operando sta all'indirizzo x400 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(3, 3));    	--indirizzo 1 dei registri della ram (secondo registro ram)
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';

        wait for clk_period;

        --scrivo indirizzo memoria locale
        cpu_data_in <= x"0003003F";        						-- il secondo operando lo carico all'indirizzo x40 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(6, 3));		--indirizzo 1 dei registri mem locale (secondo registro mem locale)
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
        wait for clk_period*710;
---------------------------------------------------------------------------------------
        --somma operandi
        --scrivo indirizzo memoria locale risultato
        cpu_data_in <= x"0006003F";        						-- il risultato lo scrivo all'indirizzo x80 della memoria locale
        cpu_addr    <= std_logic_vector(to_unsigned(7, 3));		--indirizzo 2 dei registri mem locale (terzo registro mem locale)
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
        wait for clk_period*80;
------------------------------------------------------------------------------------
        --Store matrice risultante
        --scrivo indirizzo ram risultato
 		cpu_data_in <= x"00000800";        						-- il risultato lo scrivo all'indirizzo x500 della ram
        cpu_addr    <= std_logic_vector(to_unsigned(4, 3));		--indirizzo 2 dei registri ram (terzo registro ram)
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
        wait for clk_period*710;
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
