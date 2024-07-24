-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity matrix_add_accelerator is
	generic(
		SPM_NUM         : natural := 2;   -- The number of scratchpads and adders avaibles, min 2, max 255
    	BANK_ADDR_WIDTH : natural := 6;  -- address size of each BANK min: 4, max: 16 
    	SIMD            : natural := 2;    -- banks in each spm min 1, max 255                     -- da errore se uguale a 1
        
        N_RAM_ADDR      : natural := 3;     --number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural := 3      --number of registers that contain a local memory cell address  --la somma dei due registri deve fare massimo 30
          
		 );
  	port (
  		clk                : in    std_logic;
  		reset              : in    std_logic;
  		----------------------------------------------------------------------------
        cpu_data_in        : in    std_logic_vector(31 downto 0);
        cpu_data_out       : out   std_logic_vector(31 downto 0);
        cpu_addr           : in    std_logic_vector((integer(ceil(log2(real(N_RAM_ADDR + N_LOCAL_ADDR + 2)))) -1) downto 0);    --CSR, instruction reg and addres registers
        cpu_write          : in    std_logic; 
        cpu_read           : in    std_logic; 
  		cpu_acc_busy       : out   std_logic; 
  		----------------------------------------------------------------------------
  		mem_acc_address    : out   std_logic_vector(31 downto 0);
  		mem_acc_data       : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
  		mem_acc_read       : out   std_logic;                     -- write strobe
  		mem_acc_write      : out   std_logic                      -- read  strobe


  	);
 
 end entity matrix_add_accelerator;

 

 architecture mat_acc of matrix_add_accelerator is 
 	--constants
    constant SPM_ADDR_LEN   : natural := BANK_ADDR_WIDTH + integer(ceil(log2(real(SIMD))));    -- bit per indirizzare la singola SPM
    constant SPM_BIT_N      : natural := integer(ceil(log2(real(SPM_NUM))));                   -- bit per identificare quale SPM
    constant REG_ADDR_WIDTH : natural := integer(ceil(log2(real(N_RAM_ADDR+N_LOCAL_ADDR+2)))); --numero di bit usati per indirizzare il register file
 	

   --signals
   signal addr_operand        : array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0);
   signal addr_result         : std_logic_vector((SPM_ADDR_LEN-1) downto 0);
   signal data_mem_in         : array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);
   signal data_mem_out        : array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);
   signal spm_index           : std_logic_vector((SPM_BIT_N-1) downto 0);
   signal read_ls             : std_logic;
   signal read_sum            : std_logic;
   signal write_ls            : std_logic;
   signal write_sum           : std_logic;
   signal data_reg_in         : std_logic_vector((ELEMENT_SIZE-1) downto 0);
   signal data_reg_out        : std_logic_vector((ELEMENT_SIZE-1) downto 0);
   signal addr_reg            : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
   signal read_reg            : std_logic;
   signal write_reg           : std_logic; 
   signal read_mem            : std_logic_vector((SPM_NUM-1) downto 0);
   signal write_mem           : std_logic_vector((SPM_NUM-1) downto 0);


 	--components

   component acc_logic is 
   generic(
      SIMD                 : natural;
      BANK_ADDR_WIDTH      : natural;
      SPM_ADDR_LEN         : natural;
      SPM_NUM              : natural;
      SPM_BIT_N            : natural;
      N_RAM_ADDR           : natural;
      N_LOCAL_ADDR         : natural;
      REG_ADDR_WIDTH       : natural
      );
      
   port(
      clk, reset          : in  std_logic;
      --local memory signals:
      addr_operand         : out array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0); --operands addresses
      addr_result       : out std_logic_vector((SPM_ADDR_LEN-1) downto 0);     --result address
      data_mem_in         : in  array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0); -- da memoria locale a acceleratore
      data_mem_out        : out array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
      spm_index           : out std_logic_vector((SPM_BIT_N-1) downto 0);  --per selezionare la SPM
      read_ls, write_ls   : out std_logic;
      read_sum, write_sum : out std_logic;
      --register signals:
      data_reg_in        : in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e istruzione        
      data_reg_out       : out std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per scrivere il CSR        
      addr_reg          : out std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
      read_reg, write_reg  : out std_logic;
      --cpu signals:
      cpu_acc_busy        : out std_logic;
      --main memory signals:
      mem_acc_address    : out   std_logic_vector(31 downto 0);
      mem_acc_data       : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
      mem_acc_read       : out   std_logic;                     -- read strobe
      mem_acc_write      : out   std_logic                      -- write  strobe
      );
   end component;

   component acc_registers is
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
   end component;

   component local_memory is
    generic(
      SIMD              : natural;
      BANK_ADDR_WIDTH     : natural;
      SPM_ADDR_LEN        : natural;
      SPM_NUM             : natural
    );
    
    port(
      data_out   : out   array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da memoria locale a acceleratore
      data_in    : in    array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a memoria locale
      
      addr_out   : in    array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0);          --operands addresses
      addr_in    : in    std_logic_vector((SPM_ADDR_LEN-1) downto 0);              --result address
      
      clk        : in    std_logic;
      
   --   read_sum, write_sum :  in  std_logic;      -- read and write for sum
   --   read_ls, write_ls   :  in  std_logic       -- read and write for load/store
      
      read_mem, write_mem : in std_logic_vector((SPM_NUM-1) downto 0)                 -- one for each SPM 
    );
   end component;


   component local_interface is
    generic(
        SPM_BIT_N   : natural;
        SPM_NUM     : natural
    );
    
    port(
        read_mem, write_mem       : out std_logic_vector((SPM_NUM-1) downto 0);     --to local_memory
        
        read_ls, write_ls    :   in std_logic;           -- from acc
        read_sum, write_sum  :   in std_logic;           -- from acc
        
        spm_index              :   in std_logic_vector((SPM_BIT_N-1) downto 0)       --per selezionare la SPM      
    );
   end component;


 	begin


   acc_body: acc_logic
   generic map(
      SIMD              => SIMD,
      BANK_ADDR_WIDTH   => BANK_ADDR_WIDTH,
      SPM_ADDR_LEN      => SPM_ADDR_LEN,
      SPM_NUM           => SPM_NUM,
      SPM_BIT_N         => SPM_BIT_N,
      N_RAM_ADDR        => N_RAM_ADDR,
      N_LOCAL_ADDR      => N_LOCAL_ADDR,
      REG_ADDR_WIDTH    => REG_ADDR_WIDTH
      )
   port map(
      clk               =>  clk,            --
      reset             =>  reset,          --
      addr_operand      =>  addr_operand,
      addr_result       =>  addr_result,
      data_mem_in       =>  data_mem_in,
      data_mem_out      =>  data_mem_out,
      spm_index         =>  spm_index,
      read_ls           =>  read_ls,
      write_ls          =>  write_ls,
      read_sum          =>  read_sum,
      write_sum         =>  write_sum,
      data_reg_in       =>  data_reg_in,
      data_reg_out      =>  data_reg_out,
      addr_reg          =>  addr_reg,
      read_reg          =>  read_reg,
      write_reg         =>  write_reg,
      cpu_acc_busy      =>  cpu_acc_busy,
      mem_acc_address   =>  mem_acc_address,
      mem_acc_data      =>  mem_acc_data,
      mem_acc_read      =>  mem_acc_read,
      mem_acc_write     =>  mem_acc_write
      );

   registers: acc_registers
   generic map(
      REG_ADDR_WIDTH    => REG_ADDR_WIDTH,
      N_RAM_ADDR        => N_RAM_ADDR,
      N_LOCAL_ADDR      => N_LOCAL_ADDR
      )
   port map(
      cpu_data_in       => cpu_data_in,--
      cpu_data_out      => cpu_data_out,--
      acc_data_in       => data_reg_out,
      acc_data_out      => data_reg_in,
      cpu_addr          => cpu_addr,--
      acc_addr          => addr_reg,
      cpu_write         => cpu_write,--
      cpu_read          => cpu_read,--
      acc_read          => read_reg,
      acc_write         => write_reg,
      clk               => clk,
      reset             => reset
      );

   memories: local_memory
   generic map(
      SIMD              => SIMD,
      BANK_ADDR_WIDTH   => BANK_ADDR_WIDTH,
      SPM_ADDR_LEN      => SPM_ADDR_LEN,
      SPM_NUM           => SPM_NUM
      )
   port map(
      data_out          => data_mem_in, 
      data_in           => data_mem_out, 
      addr_out          => addr_operand, 
      addr_in           => addr_result, 
      clk               => clk, 
      read_mem          => read_mem, 
      write_mem         => write_mem
      );

   interface_mem: local_interface
   generic map(
      SPM_BIT_N         => SPM_BIT_N,
      SPM_NUM           => SPM_NUM
      )
   port map(
      read_mem          => read_mem,
      write_mem         => write_mem,
      read_ls           => read_ls,
      write_ls          => write_ls,
      read_sum          => read_sum,
      write_sum         => write_sum,
      spm_index         => spm_index
      );

 end mat_acc;