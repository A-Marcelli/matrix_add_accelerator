library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package Byte_Busters is 

    --constants
    
    constant ELEMENT_SIZE : integer := 32;     --MP     size of a element of the matrix, also the size of a memory cell
    
    constant S_size       : integer := 16;     --MP
    constant M_size       : integer := 16;     --MP
    constant N_size       : integer := 16;     --MP

	--subtypes

	type array_2d     is array (integer range<>) of std_logic_vector;
	type array_3d     is array (integer range<>) of array_2d;
	


	--opcodes

  	constant LOAD   	: std_logic_vector(2 downto 0) := "001";
  	constant STORE      : std_logic_vector(2 downto 0) := "010";
  	constant ADD    	: std_logic_vector(2 downto 0) := "011";
  	constant SET_M      : std_logic_vector(2 downto 0) := "100";
  	constant SET_N      : std_logic_vector(2 downto 0) := "101";
  	constant SET_S    	: std_logic_vector(2 downto 0) := "110";
  	
  	--addresses
  	
  	constant ROW_SEL_WIDTH   : natural   := 16;
  	constant BANK_SEL_WIDTH  : natural   := 8;
  	constant SPM_SEL_WIDTH   : natural   := 8;     
    

  	--functions

  end package;

package body Byte_Busters is

end package body;