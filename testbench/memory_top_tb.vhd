library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb_local_memory is
end tb_local_memory;

architecture testbench of tb_local_memory is

    -- Constants
    constant SIMD : natural := 2;
    constant BANK_ADDR_WIDTH : natural := 8;
    constant SPM_NUM : natural := 2;
    constant ELEMENT_SIZE : natural := 32; -- Assuming an element size of 8 bits for this example
    constant ROW_SEL_WIDTH : natural := 16; -- Assuming a row selection width of 2 bits
    constant BANK_SEL_WIDTH : natural := 8; -- Assuming a bank selection width of 2 bits

    -- Component Declaration
    component local_memory is
        generic(
            SIMD                : natural;
            BANK_ADDR_WIDTH     : natural;
            SPM_NUM             : natural
        );
        port(
            data_out   : out   array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da memoria locale a acceleratore
            data_in    : in    array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a memoria locale

            addr_out   : in    array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);          --operands addresses
            addr_in    : in    std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);              --result address

            clk        : in    std_logic;

            read_mem, write_mem : in std_logic_vector((SPM_NUM-1) downto 0)                 -- one for each SPM
        );
    end component;

    -- Signals
    signal data_out : array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);
    signal data_in : array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);
    signal addr_out : array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal addr_in : std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal clk : std_logic;
    signal read_mem, write_mem : std_logic_vector((SPM_NUM-1) downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: local_memory
        generic map (
            SIMD => SIMD,
            BANK_ADDR_WIDTH => BANK_ADDR_WIDTH,
            SPM_NUM => SPM_NUM
        )
        port map (
            data_out => data_out,
            data_in => data_in,
            addr_out => addr_out,
            addr_in => addr_in,
            clk => clk,
            read_mem => read_mem,
            write_mem => write_mem
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
        data_in <= (others => (others => '0'));
        addr_in <= (others => '0');
        addr_out(0) <= (others => '0');
        addr_out(1) <= (others => '0');
        read_mem <= (others => '0');
        write_mem <= (others => '0');

        -- Wait for global reset
        wait for clk_period * 10;

        --UNO PER VOLTA
        -- Write to memory for each SPM
        data_in(0) <= x"10101010"; -- Data to write for first SPM
        addr_in <= x"000003"; -- Address to write to (binary for 3)
        write_mem(0) <= '1'; -- Enable write for first SPM
        wait for clk_period;
        write_mem(0) <= '0'; -- Disable write for first SPM

        data_in(1) <= x"11001100"; -- Data to write for second SPM
        addr_in <= x"000005"; -- Address to write to (binary for 5)
        write_mem(1) <= '1'; -- Enable write for second SPM
        wait for clk_period;
        write_mem(1) <= '0'; -- Disable write for second SPM

        -- Wait for write to complete
        wait for clk_period * 6;

        -- Read from memory for each SPM
        addr_out(0) <= x"000003"; -- Address to read from (binary for 3) for first SPM
        read_mem(0) <= '1'; -- Enable read for first SPM
        wait for clk_period * 2;
        read_mem(0) <= '0'; -- Disable read for first SPM

        addr_out(1) <= x"000005"; -- Address to read from (binary for 5) for second SPM
        read_mem(1) <= '1'; -- Enable read for second SPM
        wait for clk_period * 2;
        read_mem(1) <= '0'; -- Disable read for second SPM

        -- Wait for read to complete
        wait for clk_period * 6;
        
        --TUTTI INSIEME
         -- Write to memory for each SPM
        data_in(0) <= x"10101010"; -- Data to write for first SPM  --operando1 spm0
        data_in(1) <= x"11001100"; -- Data to write for second SPM --operando1 spm1
        addr_in <= x"000003"; -- Address to write to (binary for 3) 
        write_mem <= (others => '1'); -- Enable write for first SPM
        wait for clk_period;
        data_in(0) <= x"11111111"; -- Data to write for first SPM  --operando2 spm0
        data_in(1) <= x"11110000"; -- Data to write for second SPM --operando2 spm1
        addr_in <= x"000005"; -- Address to write to (binary for 3)
        write_mem <= (others => '1'); -- Enable write for first SPM
        wait for clk_period;
        write_mem <= (others => '0'); -- Disable write for first SPM

       

        -- Wait for write to complete
        wait for clk_period * 6;

        -- Read from memory for each SPM
        addr_out(0) <= x"000003"; -- Address to read from (binary for 3) for first SPM
        addr_out(1) <= x"000005"; -- Address to read from (binary for 5) for second SPM
        read_mem <= (others => '1'); -- Enable read for first SPM
        wait for clk_period * 2;
        read_mem <= (others => '0'); -- Disable read for first SPM

        
        

        -- Check results
        --assert data_out(0)(0) = "10101010"
        --    report "Test failed: data_out(0)(0) /= 10101010"
        --    severity error;
        --assert data_out(1)(0) = "11001100"
        --    report "Test failed: data_out(1)(0) /= 11001100"
        --    severity error;

        -- Finish simulation
        wait;
    end process;

end testbench;
