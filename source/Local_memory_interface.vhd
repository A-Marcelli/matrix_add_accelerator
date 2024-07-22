-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

--sceglie quale delle SPM andrà letta nel caso di load/store, oppure mette tuyyi i read o tutti i write a 1 nel caso di somma
entity local_interface is
    generic(
        SPM_BIT_N   : natural;
        SPM_NUM     : natural
    );
    
    port(
        read, write       : out std_logic_vector((SPM_NUM-1) downto 0);     --to local_memory
        
        read_ls, write_ls    :   in std_logic;           -- from acc
        read_sum, write_sum  :   in std_logic;           -- from acc
        
        spm_index              :   in std_logic_vector((SPM_BIT_N-1) downto 0)       --per selezionare la SPM
        
    );
end local_interface;


architecture decode of local_interface is   
begin

    read_signal:process(all)
    begin
        if read_ls = '1' then
            read(to_integer(unsigned(spm_index))) <= '1';
        elsif read_sum = '1' then
            read <= (others => '1');
        else
            read <= (others => '0');
        end if;
    end process;
             
    write_signal:process(all)
    begin
        if write_ls = '1' then
            write(to_integer(unsigned(spm_index))) <= '1';
        elsif write_sum = '1' then
            write <= (others => '1');
        else
            write <= (others => '0');
        end if;
    end process;
    
end architecture;