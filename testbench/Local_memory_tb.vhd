library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity tb_scratchpad_memory is
end tb_scratchpad_memory;

architecture testbench of tb_scratchpad_memory is

    -- Constants
    constant SIMD : natural := 2;
    constant BANK_ADDR_WIDTH : natural := 8;
    constant ELEMENT_SIZE : natural := 32; -- Assuming an element size of 8 bits for this example
    constant ROW_SEL_WIDTH : natural := 16; -- Assuming a row selection width of 2 bits
    constant BANK_SEL_WIDTH : natural := 8; -- Assuming a bank selection width of 2 bits

    -- Component Declaration
    component scratchpad_memory is
        generic (
            SIMD : natural;
            BANK_ADDR_WIDTH : natural
        );
        port (
            data_out : out array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0); -- da local a acceleratore
            data_in : in std_logic_vector((ELEMENT_SIZE-1) downto 0); -- da acceleratore a local

            addr_out : in array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0); -- operands
            addr_in : in std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0); -- result

            read_sm, write_sm : in std_logic; --MP

            clk : in std_logic --MP
        );
    end component;

    -- Signals
    signal data_out : array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);
    signal data_in : std_logic_vector((ELEMENT_SIZE-1) downto 0);
    signal addr_out : array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal addr_in : std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);
    signal read_sm, write_sm : std_logic;
    signal clk : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: scratchpad_memory
        generic map (
            SIMD => SIMD,
            BANK_ADDR_WIDTH => BANK_ADDR_WIDTH
        )
        port map (
            data_out => data_out,
            data_in => data_in,
            addr_out => addr_out,
            addr_in => addr_in,
            read_sm => read_sm,
            write_sm => write_sm,
            clk => clk
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Initialize inputs
        data_in <= (others => '0');
        addr_in <= (others => '0');
        addr_out(0) <= (others => '0');
        addr_out(1) <= (others => '0');
        read_sm <= '0';
        write_sm <= '0';

        -- Wait for global reset
        wait for clk_period * 10;


        -- BANK 1
        -- Write to memory
        data_in <= x"10101010"; -- Data to write
        addr_in <= x"000003"; -- Address to write to (binary for 3)
        write_sm <= '1'; -- Enable write
        wait for clk_period;
        write_sm <= '0'; -- Disable write

        -- Wait for write to complete
        wait for clk_period * 6;

        -- Read from memory
        addr_out(0) <= x"000003"; -- Address to read from (binary for 3)
        read_sm <= '1'; -- Enable read
        wait for clk_period * 2;
        read_sm <= '0'; -- Disable read

        -- Wait for read to complete
        wait for clk_period * 6;
        
        
        ---BANK 2
        
        -- Write to memory
        data_in <= x"10101011"; -- Data to write
        addr_in <= x"010003"; -- Address to write to (binary for 3)
        write_sm <= '1'; -- Enable write
        wait for clk_period;
        write_sm <= '0'; -- Disable write

        -- Wait for write to complete
        wait for clk_period * 6;

        -- Read from memory
        addr_out(1) <= x"010003"; -- Address to read from (binary for 3)
        addr_out(0) <= x"000003"; -- Address to read from (binary for 3)
        read_sm <= '1'; -- Enable read
        wait for clk_period * 2;
        read_sm <= '0'; -- Disable read

        -- Wait for read to complete
        wait for clk_period * 6;
        
        -- SCRITTURA SU UN BANCO CHE NO NESISTE
        -- Write to memory
        data_in <= x"00001111"; -- Data to write
        addr_in <= x"0A0003"; 
        write_sm <= '1'; -- Enable write
        wait for clk_period;
        write_sm <= '0'; -- Disable write

        -- Wait for write to complete
        wait for clk_period * 6;

        -- Read from memory
        addr_out(1) <= x"000000"; -- Address to read from (binary for 3)
        addr_out(0) <= x"0A0003"; -- Address to read from (binary for 3)
        read_sm <= '1'; -- Enable read
        wait for clk_period * 2;
        read_sm <= '0'; -- Disable read

        -- Wait for read to complete
        wait for clk_period * 6;
        

        -- Check results
        --assert data_out(0) = x"10101010"
        --    report "Test failed: data_out(0) /= x10101010"
        --    severity error;

        -- Finish simulation
        wait;
    end process;

end testbench;
