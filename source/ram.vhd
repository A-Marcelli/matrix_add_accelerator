LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE ieee.numeric_std.ALL;

ENTITY RAM is
	PORT(
		CK: in std_logic;
		RESET: in std_logic;
		RD: in std_logic;
		WR: in std_logic;
		Addr: in std_logic_vector(31 downto 0);
		Load:in std_logic;    --file
		Store:in std_logic;   --file
		Data: inout std_logic_vector(31 downto 0)
		);
END RAM;

ARCHITECTURE RAM of RAM IS -- this architecture is purely behavioral, not intended for synthesis

TYPE CELLE IS ARRAY (65535 downto 0) of std_logic_vector(31 downto 0);
SIGNAL mem:CELLE;
SIGNAL appo: std_logic_vector(7 downto 0);


--OPERAND1
  PROCEDURE load_matrix(SIGNAL memo: out CELLE) IS -- this is to load the operand matrix from file to memory 
  	VARIABLE L: line;	--DA USARE UN WHILE FINO A QUANDO NON FINISCE DI CARICARE MATRICE
  	VARIABLE y: integer;
  	FILE reading: text open read_mode is "in1.txt";
  BEGIN
  	FOR index in 0 to 262143 --DA CAMBIARE
  		LOOP
  			exit when endfile(reading);
  			readline(reading,L);
  			read(L,y);
  			memo(index)<=NOT(std_logic_vector(to_unsigned(y,8)));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  		END LOOP;		
  END load_image;
--OPERAND2
  PROCEDURE load_matrix(SIGNAL memo: out CELLE) IS -- this is to load the operand matrix from file to memory 
  	VARIABLE L: line;	--DA USARE UN WHILE FINO A QUANDO NON FINISCE DI CARICARE MATRICE
  	VARIABLE y: integer;
  	FILE reading: text open read_mode is "in2.txt";
  BEGIN
  	FOR index in 0 to 262143  --DA CAMBIARE
  		LOOP
  			exit when endfile(reading);
  			readline(reading,L);
  			read(L,y);
  			memo(index)<=NOT(std_logic_vector(to_unsigned(y,8)));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  		END LOOP;		
  END load_image;
  
  --RESULT MATRIX
  PROCEDURE store_matrix(	SIGNAL memo: in CELLE )IS -- this is to store the resulting matrix from memory to file
  	VARIABLE S: line;	--DA USARE UN WHILE FINO A QUANDO NON FINISCE DI CARICARE MATRICE
  	VARIABLE x: integer; 
  	FILE written: text open write_mode is "out.txt";
  BEGIN
  	FOR index in 262144 to 524287  --DA CAMBIARE
  		LOOP
  			x:= to_integer(unsigned(not(memo(index))));
  			write(S,x);
  			writeline(written,S);
  		END LOOP;		
  END store_image;
  
BEGIN

	PROCESS(CK,RESET,WR,Load,Store) 
  	BEGIN
  	if RESET='1' then
  		clear:  FOR index in 0 to 65535
  			LOOP -- this loop is entirely executed in one delta time
  				mem(index)<="00000000";
  			END LOOP clear;	
  			Data<="ZZZZZZZZ";
  	elsif WR='1' and RD='0' then
  		Data<="ZZZZZZZZ";
  		if CK'EVENT and CK='1' then		
  			mem(to_integer(unsigned(Addr)))<= Data;
  		END if;	
  	elsif WR='0' and RD='1' then 
  		--if CK'EVENT and CK='1' then
  			Data<=mem(to_integer(unsigned(Addr)));
  		--END if;
  	END if;
  	if Load='1' then	
  		load_matrix(mem);
  	END if;
  	if Store='1' then	
  		store_matrix(mem);
  	END if;
	END PROCESS;

END RAM;