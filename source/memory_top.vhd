library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Byte_Busters.all;



entity local_memory is
    generic(
        SIMD                : natural;
    	BANK_ADDR_WIDTH     : natural;
    	SPM_ADDR_LEN        : natural;
    	SPM_NUM             : natural
    );
    
    port(
       data_out   : out   array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);    -- da local a acceleratore
	   data_in    : in    array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);        -- da acceleratore a local
	   
	   addr_out   : in    array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0);          --operands addresses
	   addr_in    : in    std_logic_vector((SPM_ADDR_LEN-1) downto 0);              --result address
	   
	   clk        : in    std_logic;
	   
	--   read_sum, write_sum :  in  std_logic;      -- read and write for sum
	--   read_ls, write_ls   :  in  std_logic       -- read and write for load/store
	   
	   read, write : in std_logic_vector((SPM_NUM-1) downto 0)                 -- one for each SPM
        
    );
end local_memory;

architecture Behavioral of local_memory is

--  constants

--  signals
    signal data_out_int : array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0);

--  components
    component scratchpad_memory is
        generic (
    	    SIMD            : natural;
    	    BANK_ADDR_WIDTH : natural;
    	    SPM_ADDR_LEN        : natural 
	    );
	    port (
	        data_out   : out   array_2d(1 downto 0)((ELEMENT_SIZE-1) downto 0);    
	        data_in    : in    std_logic_vector((ELEMENT_SIZE-1) downto 0);        
	  
	        addr_out   : in    array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0);          
	        addr_in    : in    std_logic_vector((SPM_ADDR_LEN-1) downto 0);          
	   
	        read, write : in    std_logic;                                         
	   
	        clk        : in    std_logic                                           
	    );
    end component;

begin

    data_out <= data_out_int;  

    spm_generation: for i in 0 to SPM_NUM generate
     
        spm_instance: scratchpad_memory
            generic map(
                SIMD            => SIMD,
                BANK_ADDR_WIDTH => BANK_ADDR_WIDTH,
                SPM_ADDR_LEN    => SPM_ADDR_LEN
            )
            port map(
                data_out => data_out_int(i),
                data_in  => data_in(i),
                
                addr_out => addr_out,
                addr_in  => addr_in,
                
                read     => read(i),
                write    => write(i),
                
                clk      => clk
            );
            
    end generate spm_generation;

    
    
    
end Behavioral;
