library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;


entity acc_registers is
    generic(

        REG_ADDR_WIDTH  : natural;     -- numero di bit usati per indirizzare il register file
        N_RAM_ADDR      : natural;     --MP, number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural     --MP, number of registers that contain a local memory cell address (rows)
    );
    
    port(
        cpu_data_in        : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);   -- per scrivere istruizione e indirizzi
        cpu_data_out       : out std_logic_vector((ELEMENT_SIZE-1) downto 0);   -- per leggere il CSR
        
        acc_data_in    : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      -- per scrivere il CSR
        acc_data_out   : out std_logic_vector((ELEMENT_SIZE-1) downto 0);      -- per leggere istruzione e indirizzi
        
        cpu_addr    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        acc_addr    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        
        cpu_write, cpu_read  : in std_logic;
        acc_read, acc_write  : in std_logic;
        
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
--   █           0X001           █    CSR     █
--   █           0X002           █ RAM_ADDR   █
--   █            .              █      .     █
--   █            .              █      .     █
--   █            .              █      .     █
--   █        N_RAM_ADDR+1       █ RAM_ADDR   █
--   █        N_RAM_ADDR+2       █ LOCAL_ADDR █
--   █            .              █      .     █
--   █            .              █      .     █
--   █            .              █      .     █
--   █ N_RAM_ADDR+N_LOCAL_ADDR+1 █ LOCAL_ADDR █
--   ██████████████████████████████████████████

   
--   █████████████████████████████████████████████████████████████████
--      BIT #  █     FUNZIONE                           █  DEFAULT
--   █████████████████████████████████████████████████████████████████
--       0     █     ISTRUZIONE NON VALIDA              █     0
--      BIT 1: █     INDIRIZZO RAM NON VALIDO (INTERNO) █     0
--      BIT 2: █     INDIRIZZO LOC NON VALIDO (INTERNO) █     0

--      BIT 3: █     N NON SETTATO                      █     1
--      BIT 4: █     M NON SETTATO                      █     1
--      BIT 5: █     S NON SETTATO                      █     1

--      BIT 6: █     N NON VALIDO                       █     0
--      BIT 7: █     M NON VALIDO                       █     0
--      BIT 8: █     S NON VALIDO                       █     0
   
--       9              SIMD VIOLATO                          0
--      10              SPM_N VIOLATO                         0
--      11              BANK_ADDR_WIDTH VIOLATO               0

    signal regs             :   array_2d((N_LOCAL_ADDR + N_RAM_ADDR + 1) downto 0)((ELEMENT_SIZE-1) downto 0); 
    signal acc_data_out_int :   std_logic_vector((ELEMENT_SIZE-1) downto 0);      
    signal cpu_data_out_int :   std_logic_vector((ELEMENT_SIZE-1) downto 0);      

begin
    
    acc_data_out    <=  acc_data_out_int;
    cpu_data_out    <=  cpu_data_out_int;
    
    
    write_proc: process(reset, clk)
        variable cpu_addr_value: integer;
        variable acc_addr_value: integer;
    begin
        
        if reset = '1' then
        
            for i in 0 to (N_RAM_ADDR + N_LOCAL_ADDR + 1) loop
                regs(i) <= (others => '0');
            end loop; 
            
            regs(1)     <= x"00000038";       
        
        elsif rising_edge(clk) then
            cpu_addr_value:= to_integer(unsigned(cpu_addr));
            acc_addr_value:= to_integer(unsigned(acc_addr));
            
             
            regs(0) <= (others => '0');  --TEST

            
            
            if acc_write = '1' then             -- the accelerator has priority. 

                if acc_addr_value = 1 then
                    regs(1) <= acc_data_in;
                end if;
               
            elsif cpu_write = '1' then
                
                if (cpu_addr_value /= 1) then
                    if cpu_addr_value <= (N_RAM_ADDR + N_LOCAL_ADDR + 1) then
                        regs(cpu_addr_value) <= cpu_data_in;
                    end if;
                end if;
                
            end if;
        end if;
    end process;
    
    
    read_proc: process(all)
        variable cpu_addr_value: integer;
        variable acc_addr_value: integer;
    begin
        cpu_addr_value:= to_integer(unsigned(cpu_addr));
        acc_addr_value:= to_integer(unsigned(acc_addr));
        
            acc_data_out_int    <=  (others =>  '0');
            cpu_data_out_int    <=  (others =>  '0');
            
                if acc_read = '1' then          -- the accelerator has priority,

                    if acc_addr_value <= (N_RAM_ADDR + N_LOCAL_ADDR + 1) then
                        acc_data_out_int <= regs(acc_addr_value);
                    end if;
                                    
                elsif cpu_read = '1' then
                
                    if cpu_addr_value <= (N_RAM_ADDR + N_LOCAL_ADDR + 1) then
                        cpu_data_out_int <= regs(cpu_addr_value);       
                    end if;
                    
                end if;
                
    end process;
    
    
    
end architecture;
