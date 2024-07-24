library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

entity tb_acc_registers is
end entity tb_acc_registers;

architecture behavior of tb_acc_registers is
    -- Constants
    constant REG_ADDR_WIDTH  : natural := 3;
    constant N_RAM_ADDR      : natural := 3;
    constant N_LOCAL_ADDR    : natural := 3;
    constant ELEMENT_SIZE    : natural := 32;  -- Supponiamo che ELEMENT_SIZE sia 8

    -- Signals
    signal cpu_data_in        : std_logic_vector(ELEMENT_SIZE-1 downto 0);
    signal cpu_data_out       : std_logic_vector(ELEMENT_SIZE-1 downto 0);
    signal acc_data_in        : std_logic_vector(ELEMENT_SIZE-1 downto 0);
    signal acc_data_out       : std_logic_vector(ELEMENT_SIZE-1 downto 0);
    signal cpu_addr           : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
    signal acc_addr           : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
    signal cpu_write          : std_logic;
    signal cpu_read           : std_logic;
    signal acc_read           : std_logic;
    signal acc_write          : std_logic;
    signal clk                : std_logic;
    signal reset              : std_logic;

    -- Unit Under Test (UUT)
    component acc_registers is
        generic(
            REG_ADDR_WIDTH  : natural := 3;
            N_RAM_ADDR      : natural := 3;
            N_LOCAL_ADDR    : natural := 3
        );
        port(
            cpu_data_in    : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);
            cpu_data_out   : out std_logic_vector((ELEMENT_SIZE-1) downto 0);
            acc_data_in    : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);
            acc_data_out   : out std_logic_vector((ELEMENT_SIZE-1) downto 0);
            cpu_addr       : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
            acc_addr       : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
            cpu_write      : in std_logic;
            cpu_read       : in std_logic;
            acc_read       : in std_logic;
            acc_write      : in std_logic;
            clk            : in std_logic;
            reset          : in std_logic
        );
    end component;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: acc_registers
        generic map(
            REG_ADDR_WIDTH => REG_ADDR_WIDTH,
            N_RAM_ADDR => N_RAM_ADDR,
            N_LOCAL_ADDR => N_LOCAL_ADDR
        )
        port map(
            cpu_data_in => cpu_data_in,
            cpu_data_out => cpu_data_out,
            acc_data_in => acc_data_in,
            acc_data_out => acc_data_out,
            cpu_addr => cpu_addr,
            acc_addr => acc_addr,
            cpu_write => cpu_write,
            cpu_read => cpu_read,
            acc_read => acc_read,
            acc_write => acc_write,
            clk => clk,
            reset => reset
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        cpu_data_in <= (others => '0');
        acc_data_in <= (others => '0');
        cpu_addr <= (others => '0');
        acc_addr <= (others => '0');
        cpu_write <= '0';
        cpu_read <= '0';
        acc_write <= '0';
        acc_read <= '0';

        wait for 60 ns;
        reset <= '0';
        wait for 60 ns;

        -- verifico che non può scrivere nel CSR la cpu
        
        cpu_data_in <= x"000000AA";  -- Some data
        cpu_addr <= "001";     -- Address
        cpu_write <= '1';
        wait for 60 ns;
        cpu_write <= '0';
        wait for 60 ns;

        cpu_read <= '1';
        wait for 60 ns;
        cpu_read <= '0';

        -- cpu write & read
        cpu_data_in <= x"00000087";  -- Some data
        cpu_addr <= "101";     -- Address
        cpu_write <= '1';
        wait for 60 ns;
        cpu_write <= '0';
        wait for 60 ns;

        cpu_read <= '1';
        wait for 20 ns;
        cpu_read <= '0';

        -- acc write & read su CSR
        acc_data_in <= x"00000055";  -- Some data
        acc_addr <= "001";     -- Address
        acc_write <= '1';
        wait for 60 ns;
        acc_write <= '0';
        wait for 60 ns;

        acc_read <= '1';
        wait for 60 ns;
        acc_read <= '0';

        -- verifico che l'acc non può scrivere gli altri registri
        acc_data_in <= x"00FFFFFF";  -- Some data
        acc_addr <= "101";      -- Address
        acc_write <= '1';
        wait for 60 ns;
        acc_write <= '0';
        wait for 60 ns;

        acc_read <= '1';
        wait for 60 ns;
        acc_read <= '0';
        
        
        -- Finish simulation
        wait for 100 ns;
        wait;
    end process;

end architecture behavior;