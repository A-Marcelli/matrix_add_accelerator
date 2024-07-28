LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE ieee.numeric_std.ALL;

entity RAM is
	port(
		CK: in std_logic;
		RESET: in std_logic;
		RD: in std_logic;
		WR: in std_logic;
		Addr: in std_logic_vector(31 downto 0);
		Load:in std_logic;    --file
		Store:in std_logic;   --file
		Data: inout std_logic_vector(31 downto 0);
		M_dim : in integer; 	--per passare M, N e S
		N_dim : in integer; 	--per passare M, N e S
		S_val : in integer;  	--per passare M, N e S
		starting_addr_op1 : in std_logic_vector(31 downto 0); -- per passare indirizzo iniziale matrice op1 per salvarla  da file
		starting_addr_op2 : in std_logic_vector(31 downto 0); -- per passare indirizzo iniziale matrice op2 per salvarla  da file
		starting_addr_res : in std_logic_vector(31 downto 0)  -- per passare indirizzo iniziale matrice res per scriverla su file
		);
end RAM;

architecture RAM of RAM is -- this architecture is purely behavioral, not intended for synthesis

type CELLE is array (382500 downto 0) of std_logic_vector(31 downto 0);
signal mem 		: CELLE;
signal num_el : natural := 0;


--OPERAND1
  procedure load_op1(signal memo: out CELLE) is -- this is to load the operand1 matrix from file to memory 
  	variable L: line;
  	variable y: integer;
  	FILE reading: text open read_mode is "in1.txt";
  begin
  	for index in 0 to num_el-1
  		loop
  			exit when endfile(reading);
  			readline(reading,L);
  			read(L,y);
  			memo(to_integer(unsigned(starting_addr_op1)) + index*S_val) <= std_logic_vector(to_unsigned(y,32));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  		end loop;		
  end load_op1;

--OPERAND2
  procedure load_op2(signal memo: out CELLE) is -- this is to load the operand2 matrix from file to memory 
  	variable L: line;
  	variable y: integer;
  	FILE reading: text open read_mode is "in2.txt";
  begin
  	for index in 0 to num_el-1
  		loop
  			exit when endfile(reading);
  			readline(reading,L);
  			read(L,y);
  			memo(to_integer(unsigned(starting_addr_op2)) + index*S_val) <= std_logic_vector(to_unsigned(y,32));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  		end loop;		
  end load_op2;
  
  --RESULT MATRIX
  procedure store_matrix(signal memo: in CELLE ) is -- this is to store the resulting matrix from memory to file
  	variable S: line;
  	variable x: integer; 
  	FILE written: text open write_mode is "out.txt";
 
  begin
    
  	for index in 0 to num_el-1
  		loop
  			x:= to_integer(unsigned(memo(to_integer(unsigned(starting_addr_res)) + index*S_val)));
  			
  			-- Debug output
            --report "Storing value: " & integer'image(x);
            
  			write(S,x);
  			writeline(written,S);
  		end loop;		
  		--close written;
  end store_matrix;
  
begin

num_el <= M_dim * N_dim;

	process(CK,RESET,WR,Load,Store) 
  	begin
  	if RESET='1' then
  		clear:  FOR index in 0 to 4095
  			loop -- this loop is entirely executed in one delta time
  				mem(index)<=x"00000000";
  			end loop clear;	
  			Data <= (others => 'Z');
  	elsif WR='1' and RD='0' then
  		Data <= (others => 'Z');
  		if CK'EVENT and CK='1' then		
  			mem(to_integer(unsigned(Addr)))<= Data;
  		end if;	
  	elsif WR='0' and RD='1' then 
  		--if CK'EVENT and CK='1' then
  			Data<=mem(to_integer(unsigned(Addr)));
  		--end if;
  	end if;

  	-- loading e storing delle matrici in memoria centrale
  	if Load='1' then	
  		load_op1(mem);
  		load_op2(mem);
  	end if;
  	if Store='1' then	
  	    --report "Store signal asserted. Executing store_matrix.";
  		store_matrix(mem);
  	end if;
	end process;

end RAM;