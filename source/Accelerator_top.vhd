-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;


entity matrix_add_accelerator is
	generic(
		SPM_NUM        : natural := 4;   -- The number of scratchpads and adders avaibles, "Minimum allowed is two" "MAX 255"
    	Addr_Width     : natural := 14;  -- This address is for scratchpads banks. min: 4, max: 16 
    	SIMD           : natural := 1;    -- Changing the SIMD, changes the number of banks in the spms. min 1, max 255
        
        N_RAM_ADDR     : natural := 3;     --MP, number of registers that contain a RAM cell address
        N_LOCAL_ADDR   : natural := 3      --MP, number of registers that contain a local memory cell address
        
		 );
  	port (
  		clk                : in    std_logic;
  		rst_in             : in    std_logic;
  		----------------------------------------------------------------------------
  		cpu_acc_data       : inout std_logic_vector(31 downto 0); -- input = comandi e scrittura su registri, output = lettura da parte della cpu
  		cpu_acc_address    : in    std_logic_vector(31 downto 0);
  		cpu_acc_read       : in    std_logic;                     -- write strobe
  		cpu_acc_write      : in    std_logic;                     -- read  strobe
  		----------------------------------------------------------------------------
  		mem_acc_address    : out   std_logic_vector(31 downto 0);
  		mem_acc_data       : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
  		mem_acc_read       : out   std_logic;                     -- write strobe
  		mem_acc_write      : out   std_logic                      -- read  strobe


  	);
 
 end entity matrix_add_accelerator;

 

 architecture mat_acc of matrix_add_accelerator is 
 	--constants
    constant SPM_ADDR_LEN: natural := ADDR_WIDTH + integer(ceil(log2(real(SIMD))));


 	--signals


 	--components

 	begin



 end mat_acc;