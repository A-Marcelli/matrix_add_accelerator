library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb_matrix_add_accelerator is
end tb_matrix_add_accelerator;

architecture behavior of tb_matrix_add_accelerator is

    -- Component Declaration for the Unit Under Test (UUT)
    component matrix_add_accelerator
    generic(
        SPM_NUM         : natural := 2;
        BANK_ADDR_WIDTH : natural := 8;
        SIMD            : natural := 2;

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

    -- Testbench signals
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

    -- Instantiate the Unit Under Test (UUT)
    uut: matrix_add_accelerator
    generic map (
        SPM_NUM         => 2,
        BANK_ADDR_WIDTH => 8,
        SIMD            => 2,
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

    -- Stimulus process
    stimulus: process
    begin
        -- Reset the system
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';
        wait for clk_period * 2;

        -- Example stimulus
        -- Write to the CPU  --SET_M a 10 (x"a")
        cpu_data_in <= x"00000054";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Write to the CPU  --SET_N a 20 (x"14")
        cpu_data_in <= x"000000a5";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;


        -- Write to the CPU  --SET_S a 2 (x"2")
        cpu_data_in <= x"00000016";
        cpu_addr    <= (others => '0');
        cpu_write   <= '1';
        wait for clk_period;
        cpu_write   <= '0';
        wait for clk_period*10;

        -- Read from the CPU
        cpu_addr    <= std_logic_vector(to_unsigned(1,3));
        cpu_read    <= '1';
        wait for clk_period;
        cpu_read    <= '0';
        wait for clk_period * 10;

        ----------------------------------------------------------------------------
        
        ----------------------------------------------------------------------------

        -- Add more stimulus here to test various functionalities

        -- End of simulation
        wait;
    end process;

end behavior;
