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
		Addr: in std_logic_vector(18 downto 0);
		Load:in std_logic;
		Store:in std_logic;
		Data: inout std_logic_vector(7 downto 0)
		);
END RAM;

ARCHITECTURE RAM of RAM IS -- this architecture is purely behavioral, not intended for synthesis

TYPE CELLE IS ARRAY (524287 downto 0) of std_logic_vector(7 downto 0);
SIGNAL mem:CELLE;
SIGNAL appo: std_logic_vector(7 downto 0);

  PROCEDURE load_image(SIGNAL memo: out CELLE) IS -- this is to load the source image from file to memory 
  	VARIABLE L: line;	
  	VARIABLE y: integer;
  	FILE reading: text open read_mode is "in.txt";
  BEGIN
  	FOR index in 0 to 262143
  		LOOP
  			exit when endfile(reading);
  			readline(reading,L);
  			read(L,y);
  			memo(index)<=NOT(std_logic_vector(to_unsigned(y,8)));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
  		END LOOP;		
  END load_image;
  
  
  PROCEDURE store_image(	SIGNAL memo: in CELLE )IS -- this is to store the resulting image from memory to file
  	VARIABLE S: line;	
  	VARIABLE x: integer; 
  	FILE written: text open write_mode is "out.txt";
  BEGIN
  	FOR index in 262144 to 524287
  		LOOP
  			x:= to_integer(unsigned(not(memo(index))));
  			write(S,x);
  			writeline(written,S);
  		END LOOP;		
  END store_image;
  
BEGIN

	PROCESS(CK,RESET,WR,Load,Store) 
  	BEGIN
  	IF RESET='1' THEN
  		clear:  FOR index in 0 to 524287
  			LOOP -- this loop is entirely executed in one delta time
  				mem(index)<="00000000";
  			END LOOP clear;	
  			Data<="ZZZZZZZZ";
  	ELSIF WR='1' and RD='0' THEN
  		Data<="ZZZZZZZZ";
  		IF CK'EVENT and CK='1' THEN		
  			mem(to_integer(unsigned(Addr)))<= Data;
  		END IF;	
  	ELSIF WR='0' and RD='1' THEN 
  		--IF CK'EVENT and CK='1' THEN
  			Data<=mem(to_integer(unsigned(Addr)));
  		--END IF;
  	END IF;
  	IF Load='1' THEN	
  		load_image(mem);
  	END IF;
  	IF Store='1' THEN	
  		store_image(mem);
  	END IF;
	END PROCESS;

END RAM;