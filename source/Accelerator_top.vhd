-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

-- VALORI INIZIALI N,M? 2x2

entity matrix_add_accelerator is
	generic(
		SPM_NUM         : natural := 4;   -- The number of scratchpads and adders avaibles, min 2, max 255
    	BANK_ADDR_WIDTH : natural := 14;  -- address size of each BANK min: 4, max: 16 
    	SIMD            : natural := 1;    -- banks in each spm min 1, max 255
        
        N_RAM_ADDR      : natural := 3;     --number of registers that contain a RAM cell address
        N_LOCAL_ADDR    : natural := 3      --number of registers that contain a local memory cell address
        
		 );
  	port (
  		clk                : in    std_logic;
  		reset              : in    std_logic;
  		----------------------------------------------------------------------------
  		--cpu_acc_instr      : in    std_logic_vector(31 downto 0); -- to pass instructions
  		cpu_acc_data       : in    std_logic_vector(31 downto 0);                      -- input = scrittura su registri
  		cpu_acc_address    : in    std_logic_vector((2 + 
  		        integer(ceil(log2(real(N_RAM_ADDR + N_LOCAL_ADDR)))) -1) downto 0);    --CSR, instruction reg and addres registers
  		cpu_acc_write      : in    std_logic;                                          -- write  strobe
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

    

 	--components

 	begin



 end mat_acc;