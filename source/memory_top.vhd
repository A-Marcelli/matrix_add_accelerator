library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;



entity local_memory is
    generic(
        SIMD                : natural;
    	BANK_ADDR_WIDTH     : natural;
    	SPM_NUM             : natural
    );
    
    port(
       data_out   : out   array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da memoria locale a acceleratore
	   data_in    : in    array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a memoria locale
	   
	   addr_out   : in    array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);          --operands addresses
	   addr_in    : in    std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);              --result address
	   
	   clk        : in    std_logic;
	   
	   read_mem, write_mem : in std_logic_vector((SPM_NUM-1) downto 0)                 -- one for each SPM
        
    );
end local_memory;

architecture Behavioral of local_memory is

--  constants

--  signals
    signal data_out_int : array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);

--  components
    component scratchpad_memory is
        generic (
    	    SIMD            : natural  := 3;
    	    BANK_ADDR_WIDTH : natural  := 14
	    );
	    port (
	        data_out            : out   array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da local a acceleratore
	        data_in             : in    std_logic_vector((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a local
	   
	        addr_out            : in    array_2d(1 downto 0)((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);        -- operands
	        addr_in             : in    std_logic_vector((ROW_SEL_WIDTH + BANK_SEL_WIDTH - 1) downto 0);            -- result
	   
	        read_sm, write_sm : in    std_logic;                                         
	   
	        clk        : in    std_logic                                           
	    );
    end component;

begin

    data_out <= data_out_int;  

    spm_generation: for i in 0 to SPM_NUM-1 generate
     
        spm_instance: scratchpad_memory
            generic map(
                SIMD            => SIMD,
                BANK_ADDR_WIDTH => BANK_ADDR_WIDTH
            )
            port map(
                data_out => data_out_int(i),
                data_in  => data_in(i),
                
                addr_out => addr_out,
                addr_in  => addr_in,
                
                read_sm     => read_mem(i),
                write_sm    => write_mem(i),
                
                clk      => clk
            );
            
    end generate spm_generation;

    
    
    
end Behavioral;
