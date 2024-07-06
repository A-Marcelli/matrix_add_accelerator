-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

entity scratchpad_memory is 
	generic (
		SPM_NUM        : natural;
    	Addr_Width     : natural;
    	SIMD           : natural

	);
	port (
	);
end scratchpad_memory;

architecture memory of scratchpad_memory is



begin




end memory;