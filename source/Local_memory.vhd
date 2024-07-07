-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

entity scratchpad_memory is 
	generic (
--    	SIMD           : natural;
		SPM_NUM        : natural;
    	ADDR_WIDTH     : natural

	);
	port (
	   data_in     : in    std_logic_vector((ELEMENT_SIZE-1) downto 0);        --MP
	   data_out    : out   std_logic_vector((ELEMENT_SIZE-1) downto 0);        --MP
	   
	   addr_in     : in    std_logic_vector((ADDR_WIDTH-1) downto 0);          --MP
	   addr_out    : in    std_logic_vector((ADDR_WIDTH-1) downto 0);          --MP
	   
	   read, write : in    std_logic;                                          --MP
	   
	   clk, reset  : in    std_logic                                           --MP
	);
end scratchpad_memory;

architecture memory of scratchpad_memory is



begin




end memory;