library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Byte_Busters.all;

entity local_interface_tb is
end local_interface_tb;

architecture behavior of local_interface_tb is

    component local_interface
        generic(
            SPM_NUM     : natural   := 16
        );
        
        port(
            read_mem, write_mem        : out std_logic_vector((SPM_NUM-1) downto 0);     --to local_memory
            read_ls, write_ls          : in std_logic;           -- from acc
            read_sum, write_sum        : in std_logic;           -- from acc
            spm_index                  : in std_logic_vector((SPM_SEL_WIDTH-1) downto 0)  --per selezionare la SPM
        );
    end component;
    
    
    constant SPM_NUM     : natural   := 16;
    -- Signals for the UUT
    signal read_mem, write_mem        : std_logic_vector((SPM_NUM-1) downto 0);
    signal read_ls, write_ls          : std_logic;
    signal read_sum, write_sum        : std_logic;
    signal spm_index                  : std_logic_vector((SPM_SEL_WIDTH-1) downto 0); -- Example size
    
    


begin

    -- Instantiate the Unit Under Test (UUT)
    uut: local_interface
        generic map(
            SPM_NUM   => 16   -- Example value
        )
        port map(
            read_mem   => read_mem,
            write_mem  => write_mem,
            read_ls    => read_ls,
            write_ls   => write_ls,
            read_sum   => read_sum,
            write_sum  => write_sum,
            spm_index  => spm_index
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        read_ls <= '0';
        write_ls <= '0';
        read_sum <= '0';
        write_sum <= '0';
        spm_index <= (others => '0');
        
        -- Apply test vectors
        wait for 60 ns;
        spm_index <= "00000110"; -- Example index
        read_ls <= '1';
        write_ls <= '0';
        read_sum <= '0';
        write_sum <= '0';
        wait for 20 ns;
        
        wait for 60 ns;
        spm_index <= "00001011"; -- Example index
        read_ls <= '0';
        write_ls <= '1';
        read_sum <= '0';
        write_sum <= '0';
        wait for 20 ns;
        
        wait for 60 ns;
        spm_index <= "00000100"; -- Example index
        read_ls <= '0';
        write_ls <= '0';
        read_sum <= '1';
        write_sum <= '0';
        wait for 20 ns;
        
        wait for 60 ns;
        spm_index <= "00001000"; -- Example index
        read_ls <= '0';
        write_ls <= '0';
        read_sum <= '0';
        write_sum <= '1';
        wait for 20 ns;
        wait for 50 ns;
    end process;


end behavior;
