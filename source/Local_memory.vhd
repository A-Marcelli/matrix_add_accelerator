-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity scratchpad_memory is 
	generic (
    	SIMD           : natural;
    	ADDR_WIDTH     : natural;
    	ADDR_LEN       : natural 

	);
	port (
	   data_out   : out   array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da local a acceleratore
	   data_in    : in    std_logic_vector((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a local
	   
	   addr_out   : in    array_2d(1 downto 0)((ADDR_LEN-1) downto 0);          --MP
	   addr_in    : in    std_logic_vector((ADDR_LEN-1) downto 0);          --MP
	   
	   read, write : in    std_logic;                                          --MP
	   
	   clk        : in    std_logic                                           --MP
	);
end scratchpad_memory;

architecture memory of scratchpad_memory is

    signal mem: array_3d(SIMD-1 downto 0)((2**(ADDR_WIDTH)-1) downto 0)(ELEMENT_SIZE-1 downto 0);
begin

write_logic: process(clk)
begin
    if(rising_edge(clk)) then
        if write = '1' then
            mem( to_integer(unsigned(addr_in( (ADDR_LEN -1) downto ADDR_WIDTH))) )
                (to_integer(unsigned(addr_in(ADDR_WIDTH-1 downto 0)))) <= data_in;       
        end if;
    end if;
end process;

read_logic: process(clk)
begin
    if(rising_edge(clk)) then
        if read = '1' then
            data_out(0) <= mem( to_integer(unsigned(addr_out(0)( (ADDR_LEN -1) downto ADDR_WIDTH))) )
                (to_integer(unsigned(addr_out(0)(ADDR_WIDTH-1 downto 0))));
            
            data_out(1) <= mem( to_integer(unsigned(addr_out(1)( (ADDR_LEN -1) downto ADDR_WIDTH))) )
                (to_integer(unsigned(addr_out(1)(ADDR_WIDTH-1 downto 0))));
        end if; 
    end if;
end process;


end memory;