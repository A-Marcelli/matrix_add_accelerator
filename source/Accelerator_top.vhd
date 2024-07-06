-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;


entity matrix_add_accelerator is
	generic(
		SPM_NUM        : natural := 4;   -- The number of scratchpads available "Minimum allowed is two"
    	Addr_Width     : natural := 14;  -- This address is for scratchpads. Setting this will make the size of the spm to be: "2^Addr_Width -1"
    	SPM_STRT_ADDR  : std_logic_vector(31 downto 0) := x"1000_0000";  -- This is starting address of the spms, it shouldn't overlap any sections in the memory map
    	SIMD           : natural := 1    -- Changing the SIMD, would change the number of the functional units in the dsp, and the number of banks in the spms (can be power of 2 only e.g. 1,2,4,8)


		 );
  port (


  	);
 
 end entity matrix_add_accelerator;

 

 architecture mat_acc of matrix_add_accelerator is 
 	--constants


 	--signals


 	--components

 	begin



 end mat_acc;