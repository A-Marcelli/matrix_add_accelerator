library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;


entity acc_registers is
    generic(

        REG_ADDR_WIDTH  : natural;     -- numero di bit usati per indirizzare il register file
        N_RAM_ADDR      : natural;     --MP, number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural      --MP, number of registers that contain a local memory cell address (rows)
    );
    
    port(
        data_cpu        : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);
        
        data_out_acc    : out std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e istruzione
        
        addr_cpu    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        addr_acc    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        
        write_cpu : in std_logic;
        read_acc  : in std_logic;
        
        clk, reset  : in std_logic
    );
end entity;

architecture acc_settings of acc_registers is

   --signals    
--   ██████████████████████████████████████████
--   ████████████  REGISTER MAP  ██████████████
--   ██████████████████████████████████████████
--   ██████████████████████████████████████████
--   █           ADDR            █ FUNCTION   █
--   ██████████████████████████████████████████
--   █           0X000           █ instr_reg  █
--   █           0X001           █ RAM_ADDR   █
--   █            .              █      .     █
--   █            .              █      .     █
--   █            .              █      .     █
--   █        N_RAM_ADDR         █ RAM_ADDR   █
--   █        N_RAM_ADDR+1       █ LOCAL_ADDR █
--   █            .              █      .     █
--   █            .              █      .     █
--   █            .              █      .     █
--   █ N_RAM_ADDR + N_LOCAL_ADDR █ LOCAL_ADDR █
--   ██████████████████████████████████████████
   
    signal regs :   array_2d((N_LOCAL_ADDR + N_RAM_ADDR) downto 0);     -- the first register is the instruction register
    
begin

    reset_proc: process(reset)
    begin
        if reset = '1' then
            
            for i in 0 to N_RAM_ADDR + N_LOCAL_ADDR loop
                regs(i) <= (others => '0');
            end loop;

        end if;
    end process;
    
    
    write_proc: process(clk)
        variable addr_value: integer := to_integer(unsigned(addr_cpu));
    begin
        if reset = '0' then
            if rising_edge(clk) then
                if write_cpu = '1' then
                
                    if addr_value <= (N_RAM_ADDR + N_LOCAL_ADDR) then
                        regs(addr_value) <= data_cpu;
                    end if;
                    
                end if;
            end if;
        end if;
    end process;
    
    read_proc: process(clk)
        variable addr_value: integer := to_integer(unsigned(addr_acc));
    begin
        if reset = '0' then
            if rising_edge(clk) then
                if read_acc = '1' then
                
                    if addr_value <= (N_RAM_ADDR + N_LOCAL_ADDR) then
                        data_out_acc <= regs(addr_value);
                    end if;
                    
                    -- if the acc reads the instruction then the instr_reg is cleared so to not loop on the instr
                    if addr_value = 0 then
                        regs(0) <= x"00000000"; 
                    end if;
                    
                end if;
            end if;
        end if;
    end process;    
    
end architecture;
