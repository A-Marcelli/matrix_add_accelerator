library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;


entity acc_registers is
    generic(

        REG_ADDR_WIDTH  : natural;     -- numero di bit usati per indirizzare il register file
        N_RAM_ADDR      : natural;     --MP, number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural      --MP, number of registers that contain a local memory cell address
    );
    
    port(
        data_cpu        : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);
        data_in_acc     : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per scrivere lo CSR
        data_out_acc    : out std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e CSR
        
        addr_cpu    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        addr_acc    : in std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
        
        write_cpu : in std_logic;
        read_acc  : in std_logic;
        
        clk, reset  : in std_logic
    );
end entity;

architecture acc_settings of acc_registers is

   --signals
--    signal CSR_reg   : std_logic_vector((ELEMENT_SIZE-1) downto 0);
	signal instr_reg : std_logic_vector((ELEMENT_SIZE-1) downto 0);
	
    type ram_addr_reg_type is array ((N_RAM_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
    signal ram_addr_reg     : ram_addr_reg_type;
    
    type local_addr_reg_type is array ((N_LOCAL_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
    signal local_addr_reg   : local_addr_reg_type;
    
begin

    reset_proc: process(reset)
    begin
        if reset = '1' then
  --          CSR_reg   <= (others => '0');
            instr_reg <= (others => '0');
            
            for i in 0 to N_RAM_ADDR-1 loop
                ram_addr_reg(i) <= (others => '0');
            end loop;
            
            for i in 0 to N_LOCAL_ADDR-1 loop
                local_addr_reg(i) <= (others => '0');
            end loop;
        end if;
    end process;
    
    -- da fare processi per la lettura e scrittura
end architecture;
