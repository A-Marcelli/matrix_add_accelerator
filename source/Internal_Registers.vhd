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
        
        --data_in_acc     : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per scrivere lo CSR
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
   -- signal CSR_reg   : std_logic_vector((ELEMENT_SIZE-1) downto 0);
	signal instr_reg : std_logic_vector((ELEMENT_SIZE-1) downto 0);
	
    type ram_addr_reg_type is array ((N_RAM_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
    signal ram_addr_reg     : ram_addr_reg_type;
    
    type local_addr_reg_type is array ((N_LOCAL_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
    signal local_addr_reg   : local_addr_reg_type;
    
begin

    reset_proc: process(reset)
    begin
        if reset = '1' then
   --         CSR_reg   <= (others => '0');
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
    
    write_proc: process(clk)
        variable addr_value: integer := to_integer(unsigned(addr_cpu));
    begin
        if reset = '0' then
            if rising_edge(clk) then
                if write_cpu = '1' then
                    if addr_value = 0 then
                        instr_reg <= data_cpu;
                    elsif (addr_value > 0 and addr_value <= N_RAM_ADDR) then
                        ram_addr_reg(addr_value) <= data_cpu;
                    elsif (addr_value > N_RAM_ADDR and addr_value <= N_RAM_ADDR + N_LOCAL_ADDR) then
                        local_addr_reg(addr_value) <= data_cpu;
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
                    if addr_value = 0 then
                        data_out_acc <=  instr_reg;
                    elsif (addr_value > 0 and addr_value <= N_RAM_ADDR) then
                        data_out_acc <= ram_addr_reg(addr_value);
                    elsif (addr_value > N_RAM_ADDR and addr_value <= N_RAM_ADDR + N_LOCAL_ADDR) then
                        data_out_acc <= local_addr_reg(addr_value);
                    end if;
                end if;
            end if;
        end if;
    end process;    
    
end architecture;
