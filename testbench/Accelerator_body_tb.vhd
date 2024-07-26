library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb_acc_logic is
end tb_acc_logic;

architecture testbench of tb_acc_logic is

    -- Constants
    constant ELEMENT_SIZE : natural := 32;
    constant ROW_SEL_WIDTH : natural := 16;
    constant BANK_SEL_WIDTH : natural := 8;
    constant SPM_SEL_WIDTH : natural := 8;
    constant SIMD : natural := 2;
    constant BANK_ADDR_WIDTH : natural := 8;
    constant SPM_NUM : natural := 2;
    constant N_RAM_ADDR : natural := 3;
    constant N_LOCAL_ADDR : natural := 3;
    constant REG_ADDR_WIDTH : natural := 3;

    -- Component Declaration
    component acc_logic is 
        generic(
            SIMD                : natural := 2;
            BANK_ADDR_WIDTH     : natural := 8;
            SPM_NUM             : natural := 2;
            
            N_RAM_ADDR          : natural := 3;
            N_LOCAL_ADDR        : natural := 3;
            REG_ADDR_WIDTH      : natural := 3
        );
            
        port(
            clk, reset          : in  std_logic;
            --local memory signals:
            addr_operand        : out array_2d(1 downto 0)((ROW_SEL_WIDTH+BANK_SEL_WIDTH-1) downto 0); --operands addresses
            addr_result         : out std_logic_vector((ROW_SEL_WIDTH+BANK_SEL_WIDTH-1) downto 0);     --result address
            data_mem_in         : in  array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0); -- da memoria locale a acceleratore
            data_mem_out        : out array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
            spm_index           : out std_logic_vector((SPM_SEL_WIDTH-1) downto 0);  --per selezionare la SPM
            read_ls, write_ls   : out std_logic;
            read_sum, write_sum : out std_logic;
            --register signals:
            data_reg_in         : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e istruzione        
            data_reg_out        : out std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per scrivere il CSR        
            addr_reg            : out std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
            read_reg, write_reg : out std_logic;
            --cpu signals:
            cpu_acc_busy        : out std_logic;
            --main memory signals:
            mem_acc_address     : out   std_logic_vector(31 downto 0);
            mem_acc_data        : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
            mem_acc_read        : out   std_logic;                     -- read strobe
            mem_acc_write       : out   std_logic                      -- write  strobe
        );
    end component;

    -- Signals
    signal clk, reset : std_logic;
    signal addr_operand : array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal addr_result : std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal data_mem_in : array_3d((SPM_NUM - 1) downto 0)(1 downto 0)((ELEMENT_SIZE - 1) downto 0);
    signal data_mem_out : array_2d((SPM_NUM - 1) downto 0)((ELEMENT_SIZE - 1) downto 0);
    signal spm_index : std_logic_vector((SPM_SEL_WIDTH - 1) downto 0);
    signal read_ls, write_ls : std_logic;
    signal read_sum, write_sum : std_logic;
    signal data_reg_in : std_logic_vector((ELEMENT_SIZE - 1) downto 0);
    signal data_reg_out : std_logic_vector((ELEMENT_SIZE - 1) downto 0);
    signal addr_reg : std_logic_vector((REG_ADDR_WIDTH - 1) downto 0);
    signal read_reg, write_reg : std_logic;
    signal cpu_acc_busy : std_logic;
    signal mem_acc_address : std_logic_vector(31 downto 0);
    signal mem_acc_data : std_logic_vector(31 downto 0);
    signal mem_acc_read, mem_acc_write : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: acc_logic
        generic map (
            SIMD => SIMD,
            BANK_ADDR_WIDTH => BANK_ADDR_WIDTH,
            SPM_NUM => SPM_NUM,
            N_RAM_ADDR => N_RAM_ADDR,
            N_LOCAL_ADDR => N_LOCAL_ADDR,
            REG_ADDR_WIDTH => REG_ADDR_WIDTH
        )
        port map (
            clk => clk,
            reset => reset,
            addr_operand => addr_operand,
            addr_result => addr_result,
            data_mem_in => data_mem_in,
            data_mem_out => data_mem_out,
            spm_index => spm_index,
            read_ls => read_ls,
            write_ls => write_ls,
            read_sum => read_sum,
            write_sum => write_sum,
            data_reg_in => data_reg_in,
            data_reg_out => data_reg_out,
            addr_reg => addr_reg,
            read_reg => read_reg,
            write_reg => write_reg,
            cpu_acc_busy => cpu_acc_busy,
            mem_acc_address => mem_acc_address,
            mem_acc_data => mem_acc_data,
            mem_acc_read => mem_acc_read,
            mem_acc_write => mem_acc_write
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Initialize inputs
        data_reg_in <= (others => '0');
        mem_acc_data <= (others => 'Z');  -- High impedance
        reset <= '0';

        -- Apply reset
        reset <= '1';
        wait for clk_period * 5;
        reset <= '0';

        -- Wait for global reset to complete
        wait for clk_period * 10;
                                               -- 0101|0 100
        -- Example stimulus
        -- Write to a register
        data_reg_in <= x"00000054"; -- Set M a 10 (x"a")
        wait for clk_period;
        data_reg_in <= (others => '0');
        --read_reg <= '1';
        wait for clk_period*10;
                                                -- 1010|0 101
        data_reg_in <= x"000000a5"; -- Set N a 20 (x"14")
        --read_reg <= '1';
        wait for clk_period;
        data_reg_in <= (others => '0');
        wait for clk_period*10;
                                                -- 0001|0 110       
        data_reg_in <= x"00000016"; -- Set S a 2 (x"2")
        --read_reg <= '1';
        wait for clk_period;
        data_reg_in <= (others => '0');
        wait for clk_period*10;
        --read_reg <= '0';
                                               --  0010 0000 0000|0 100
         -- Write to a register
        data_reg_in <= x"00002004"; -- Set M a 10 (x"a")
        wait for clk_period;
        data_reg_in <= (others => '0');
        --read_reg <= '1';
        wait for clk_period*10;
        
        -- Add more stimulus as required to test different states and functionality
        -- For example, initiate load/store operations, perform arithmetic operations, etc.

        -- Finish simulation
        wait;
    end process;

end testbench;
