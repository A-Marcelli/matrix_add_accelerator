library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;


entity acc_register_file is
    generic(

        
        N_RAM_ADDR      : natural := 3;     --MP, number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural := 3      --MP, number of registers that contain a local memory cell address
    );
    
    port(
        data_in     : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);
        data_out    : out std_logic_vector((ELEMENT_SIZE-1) downto 0);
    
        addr_in     : in std_logic_vector((ELEMENT_SIZE-1) downto 0);
        addr_out    : in std_logic_vector((ELEMENT_SIZE-1) downto 0);
        
        read, write : in std_logic;
        
        clk, reset  : in std_logic
    );
end entity;

architecture acc_settings of acc_register_file is

   --signals
   type CSR_reg_type is record
	   status_bits :   std_logic_vector(15 downto 0);
	   S_value     :   std_logic_vector((S_size-1) downto 0);   
	end record CSR_reg_type;
	signal CSR_reg : CSR_reg_type;
	
	type M_N_reg_type is record
	   M_value     : std_logic_vector((M_SIZE-1) downto 0);
	   N_value     : std_logic_vector((N_size-1) downto 0);
	end record M_N_reg_type;
	signal M_N_reg : M_N_reg_type;

   type ram_addr_reg_type is array ((N_RAM_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
   signal ram_addr_reg     : ram_addr_reg_type;
    
   type local_addr_reg_type is array ((N_LOCAL_ADDR-1) downto 0) of std_logic_vector(31 downto 0);
   signal local_addr_reg   : local_addr_reg_type;
    
begin

end architecture;
