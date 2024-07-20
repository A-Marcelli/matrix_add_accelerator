-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

entity acc_logic is 
	generic(
		SIMD                : natural;
    	BANK_ADDR_WIDTH     : natural;
    	SPM_ADDR_LEN        : natural;
    	SPM_NUM             : natural;
    	N_RAM_ADDR      	: natural;
        N_LOCAL_ADDR    	: natural;
    	REG_ADDR_WIDTH      : natural
		);
		
	port(
		clk, reset          : in  std_logic;
		--local memory signals:
		addr_operand   		: out array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0); --operands addresses
	   	addr_result   		: out std_logic_vector((SPM_ADDR_LEN-1) downto 0);     --result address
		data_mem_in         : in  array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0); -- da memoria locale a acceleratore
		data_mem_out        : out array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
		spm_num             : out std_logic_vector((SPM_BIT_N-1) downto 0);  --per selezionare la SPM
		read_ls, write_ls   : out std_logic;
        read_sum, write_sum : out std_logic;
        --register signals:
        data_reg_in   		: in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e istruzione        
		addr_reg    		: out std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
		read_reg  			: out std_logic;
        --cpu signals:
        cpu_acc_busy        : out std_logic;
        --main memory signals:
        mem_acc_address    : out   std_logic_vector(31 downto 0);
  		mem_acc_data       : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
  		mem_acc_read       : out   std_logic;                     -- write strobe
  		mem_acc_write      : out   std_logic                      -- read  strobe
		);
end acc_logic;


architecture logic of acc_logic is

--SEGNALI INTERNI
--local memory signals:
signal addr_operand_int   			: array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0); --operands addresses
signal addr_result_int   			: std_logic_vector((SPM_ADDR_LEN-1) downto 0);     --result address
signal data_mem_out_int         	: array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
signal spm_num_int              	: std_logic_vector((SPM_BIT_N-1) downto 0);  --per selezionare la SPM
signal read_ls_int, write_ls_int   	: std_logic;
signal read_sum_int, write_sum_int 	: std_logic;
--register signals:
signal addr_reg_int    				: std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
signal read_reg_int  				: std_logic;
--cpu signals:
signal cpu_acc_busy_int        		: std_logic;
--main memory signals:
signal mem_acc_address_int    		: std_logic_vector(31 downto 0);
signal mem_acc_data_int       		: std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
signal mem_acc_read_int       		: std_logic;                     -- write strobe
signal mem_acc_write_int      		: std_logic;                     -- read  strobe

begin

addr_operand	<= addr_operand_int;
addr_result		<= addr_result_int;
data_mem_out	<= data_mem_out_int;
spm_num			<= spm_num_int;
read_ls			<= read_ls_int;
read_sum		<= read_sum_int;
write_ls		<= write_ls_int;
write_sum		<= write_sum_int;
addr_reg		<= addr_reg_int;
read_reg		<= read_reg_int;
cpu_acc_busy	<= cpu_acc_busy_int;
mem_acc_address	<= mem_acc_address_int; 
mem_acc_data	<= mem_acc_data_int;
mem_acc_read	<= mem_acc_read_int;
mem_acc_write	<= mem_acc_write_int;

reset_proc: process(reset)
begin
	if reset = '1' then
		addr_operand_int 	<= (others => '0');
		addr_result_int 	<= (others => '0');
		data_mem_out_int 	<= (others => '0');
		spm_num_int 		<= (others => '0');
		read_ls_int 		<= (others => '0');
		read_sum_int 		<= (others => '0');
		write_ls_int 		<= (others => '0');
		write_sum_int 		<= (others => '0');
		addr_reg_int 		<= (others => '0');
		read_reg_int 		<= (others => '0');
		cpu_acc_busy_int 	<= (others => '0');
		mem_acc_address_int <= (others => '0');
		mem_acc_data_int 	<= (others => '0');
		mem_acc_read_int 	<= (others => '0');
		mem_acc_write_int 	<= (others => '0');
	end if;
end process;


end logic;