LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_RAM IS
END tb_RAM;

ARCHITECTURE behavior OF tb_RAM IS 

    -- Component Declaration for the Unit Under Test (UUT)
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

    -- Inputs
    signal CK : std_logic := '0';
    signal RESET : std_logic := '0';
    signal RD : std_logic := '0';
    signal WR : std_logic := '0';
    signal Addr : std_logic_vector(31 downto 0) := (others => '0');
    signal Load : std_logic := '0';
    signal Store : std_logic := '0';
    signal Data : std_logic_vector(31 downto 0) := (others => 'Z');
    signal M_dim : natural := 2; -- 2 rows
    signal N_dim : natural := 2; -- 2 columns
    signal S_val : natural := 1;  -- stride value
    signal starting_addr_op1 : std_logic_vector(31 downto 0) := x"00000000";
    signal starting_addr_op2 : std_logic_vector(31 downto 0) := x"00000400";
    signal starting_addr_res : std_logic_vector(31 downto 0) := x"00000400";

    -- Clock period definition
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: RAM PORT MAP (
        CK => CK,
        RESET => RESET,
        RD => RD,
        WR => WR,
        Addr => Addr,
        Load => Load,
        Store => Store,
        Data => Data,
        M_dim => M_dim,
        N_dim => N_dim,
        S_val => S_val,
        starting_addr_op1 => starting_addr_op1,
        starting_addr_op2 => starting_addr_op2,
        starting_addr_res => starting_addr_res
    );

    -- Clock process
    clk_process :process
    begin
        CK <= '1';
        wait for clk_period/2;
        CK <= '0';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin

        -- Reset the RAM
        RESET <= '1';
        wait for clk_period;
        RESET <= '0';
        wait for clk_period;

        -- Load matrices from files
        Load <= '1';
        wait for clk_period;
        Load <= '0';
        wait for clk_period;

        -- Perform some read and write operations (if needed)
        WR <= '1';
        Addr <= starting_addr_op2;  -- Address for op1
        Data <= x"00000001";         -- Example data (change as needed)
        wait for clk_period;
        WR <= '0';
        Data <= (others => 'Z');
        wait for clk_period;
        RD <= '1';                   -- Read operation
        wait for clk_period*3;
        RD <= '0';
        wait for clk_period;

        -- Store results back to file
        Store <= '1';
        wait for clk_period;
        Store <= '0';
        wait for clk_period;

        -- Finish the simulation
        wait;
    end process;

END behavior;
