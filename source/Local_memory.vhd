-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;

entity scratchpad_memory is 
	generic (
    	SIMD            : natural;
    	BANK_ADDR_WIDTH : natural

	);
	port (
	   data_out            : out   array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da local a acceleratore
	   data_in             : in    std_logic_vector((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a local
	   
	   addr_out            : in    array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);        -- operands
	   addr_in             : in    std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);            -- result
	   
	   read_sm, write_sm   : in    std_logic;                                          --MP
	   
	   clk                 : in    std_logic                                           --MP
	);
end scratchpad_memory;

architecture memory of scratchpad_memory is

    signal mem              :   array_3d(SIMD-1 downto 0)((2**(BANK_ADDR_WIDTH)-1) downto 0)(ELEMENT_SIZE-1 downto 0);
    --signal mem              :   array_2d((2**(BANK_ADDR_WIDTH)-1) downto 0)(ELEMENT_SIZE-1 downto 0);
    signal data_out_int     :   array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);
    

begin

data_out    <=  data_out_int;

write_logic: process(clk)
begin
    if(rising_edge(clk)) then
        if write_sm = '1' then
            mem( to_integer(unsigned(addr_in( (ROW_SEL_WIDTH+BANK_SEL_WIDTH-1) downto ROW_SEL_WIDTH))) )
                (to_integer(unsigned(addr_in( ROW_SEL_WIDTH-1 downto 0)))) <= data_in; 
--            mem(to_integer(unsigned(addr_in( ROW_SEL_WIDTH-1 downto 0)))) <= data_in;       
        end if;
    end if;
end process;

read_logic: process(all)
begin
--    if(rising_edge(clk)) then
        if read_sm = '1' then
            data_out_int(0) <= mem( to_integer(unsigned(addr_out(0)( (ROW_SEL_WIDTH+BANK_SEL_WIDTH-1) downto ROW_SEL_WIDTH ))) )
               (to_integer(unsigned(addr_out(0)( ROW_SEL_WIDTH-1 downto 0))));
            
            data_out_int(1) <= mem( to_integer(unsigned(addr_out(1)( (ROW_SEL_WIDTH+BANK_SEL_WIDTH-1) downto ROW_SEL_WIDTH))) )
                (to_integer(unsigned(addr_out(1)( ROW_SEL_WIDTH-1 downto 0))));    

        
 --           data_out_int(0) <= mem(to_integer(unsigned(addr_out(0)( ROW_SEL_WIDTH-1 downto 0))));
            
  --          data_out_int(1) <= mem(to_integer(unsigned(addr_out(1)( ROW_SEL_WIDTH-1 downto 0))));
        else
            data_out_int    <=  (others =>  (others =>  '0'));
        end if; 
--    end if;
end process;


end memory;