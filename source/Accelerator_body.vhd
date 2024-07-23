-- ieee packages ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Byte_Busters.all;

entity acc_logic is 
	generic(
		SIMD                : natural;
    	BANK_ADDR_WIDTH     : natural;
    	SPM_ADDR_LEN        : natural;
    	SPM_NUM             : natural;
    	SPM_BIT_N           : natural;
    	N_RAM_ADDR      	: natural;
        N_LOCAL_ADDR    	: natural;
    	REG_ADDR_WIDTH      : natural
		);
		
	port(
		clk, reset          : in  std_logic;
		--local memory signals:
		addr_operand   		: out array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0); --operands addresses
	   	addr_result   		: out std_logic_vector((SPM_ADDR_LEN-1) downto 0);     --result address
		data_mem_in         : in  array_3d((SPM_NUM-1) downto 0)(1 downto 0)((ELEMENT_SIZE-1) downto 0); -- da memoria locale a acceleratore
		data_mem_out        : out array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
		spm_index           : out std_logic_vector((SPM_BIT_N-1) downto 0);  --per selezionare la SPM
		read_ls, write_ls   : out std_logic;
        read_sum, write_sum : out std_logic;
        --register signals:
        data_reg_in   		: in  std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per leggere indirizzi e istruzione        
        data_reg_out   		: out std_logic_vector((ELEMENT_SIZE-1) downto 0);      --per scrivere il CSR        
		addr_reg    		: out std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
		read_reg, write_reg	: out std_logic;
        --cpu signals:
        cpu_acc_busy        : out std_logic;
        --main memory signals:
        mem_acc_address    : out   std_logic_vector(31 downto 0);
  		mem_acc_data       : inout std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
  		mem_acc_read       : out   std_logic;                     -- read strobe
  		mem_acc_write      : out   std_logic                      -- write  strobe
		);
end acc_logic;


architecture logic of acc_logic is

--SEGNALI INTERNI
--local memory signals:
signal addr_operand_int   			: array_2d(1 downto 0)((SPM_ADDR_LEN-1) downto 0); --operands addresses
signal addr_result_int   			: std_logic_vector((SPM_ADDR_LEN-1) downto 0);     --result address
signal data_mem_out_int         	: array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0);  -- da acceleratore a memoria locale (memory top)
signal spm_num_int              	: std_logic_vector((SPM_BIT_N-1) downto 0);  --per selezionare la SPM
signal read_ls_int, write_ls_int   	: std_logic;
signal read_sum_int, write_sum_int 	: std_logic;

--register signals:
signal addr_reg_int    				: std_logic_vector((REG_ADDR_WIDTH-1) downto 0);     
signal read_reg_int  				: std_logic;

--cpu signals:
--signal cpu_acc_busy_int        		: std_logic;

--main memory signals:
signal mem_acc_address_int    		: std_logic_vector(31 downto 0);
signal mem_acc_data_int       		: std_logic_vector(31 downto 0); -- input = lettura da memoria, output = scrittura in memoria
signal mem_acc_read_int       		: std_logic;                     -- write strobe
signal mem_acc_write_int      		: std_logic;                     -- read  strobe

-- body signals
signal status_reg                   : std_logic_vector(31 downto 0); -- contiene busy, errori?. Struttura da definire. Busy bit 0
type M_N_S_reg_type is record
    M_value     : std_logic_vector((M_SIZE-1) downto 0);
    N_value     : std_logic_vector((N_SIZE-1) downto 0);
    S_value     : std_logic_vector((S_SIZE-1) downto 0); 
end record M_N_S_reg_type;
signal M_N_S_reg                    : M_N_S_reg_type;                -- contiene M, N, S
signal state, next_state            : std_logic_vector(4 downto 0);

--mancano segnali per contare e dove appoggiare i vari elementi:
signal op1, op2, result             : array_2d((SPM_NUM-1) downto 0)((ELEMENT_SIZE-1) downto 0); --tutti gli operandi ed i risultati. Se lettura o scrittura uso op1(0)
signal count                        : integer; --solo per contare, può essere trasformata in variabile nei processi
signal istruzione                   : std_logic_vector(31 downto 0); --contiene l'istruzione letta dai registri interni
signal prima_iterazione             : std_logic;
signal indirizzo_local_ls           : std_logic_vector(31 downto 0);
signal indirizzo_mem_ls             : std_logic_vector(31 downto 0);
signal ultimo_elemento              : integer;
signal offset_indirizzo             : integer;

begin

addr_operand	<= addr_operand_int;
addr_result		<= addr_result_int;
data_mem_out	<= data_mem_out_int;
spm_index		<= spm_num_int;
read_ls			<= read_ls_int;
read_sum		<= read_sum_int;
write_ls		<= write_ls_int;
write_sum		<= write_sum_int;
addr_reg		<= addr_reg_int;
read_reg		<= read_reg_int;
cpu_acc_busy	<= status_reg(0);
mem_acc_address	<= mem_acc_address_int; 
mem_acc_data	<= mem_acc_data_int;
mem_acc_read	<= mem_acc_read_int;
mem_acc_write	<= mem_acc_write_int;
ultimo_elemento <= to_integer(unsigned(M_N_S_reg.M_value)) * to_integer(unsigned(M_N_S_reg.N_value));

reset_proc: process(reset)
begin
	if reset = '1' then                             --state e next_state resettati nei loro processi
		addr_operand_int 	<= (others => '0');
		addr_result_int 	<= (others => '0');
		data_mem_out_int 	<= (others => '0');
		spm_num_int 		<= (others => '0');
		read_ls_int 		<= (others => '0');
		read_sum_int 		<= (others => '0');
		write_ls_int 		<= (others => '0');
		write_sum_int 		<= (others => '0');
		addr_reg_int 		<= (others => '0');
		read_reg_int 		<= (others => '0');
		cpu_acc_busy_int 	<= (others => '0');
		mem_acc_address_int <= (others => '0');
		mem_acc_data_int 	<= (others => 'z');                  --high impedence
		mem_acc_read_int 	<= (others => '0');
		mem_acc_write_int 	<= (others => '0');
		status_reg          <= (others => '0');
		M_N_S_reg.M_value   <= std_logic_vector(to_unsigned(2)); --valori di reset: M = 2, N = 2, S = 1;
		M_N_S_reg.N_value   <= std_logic_vector(to_unsigned(2));
		M_N_S_reg.S_value   <= std_logic_vector(to_unsigned(1));
		istruzione          <= (others => '0');
		count               <= 0; 
		op1                 <= (others => '0'); 
		op2                 <= (others => '0');
		result              <= (others => '0');
		prima_iterazione    <= '1';                              -- 1 = è la prima iterazione.
		indirizzo_local_ls  <= (others => '0');
		indirizzo_mem_ls    <= (others => '0');
		ultimo_elemento     <= 0;
		offset_indirizzo    <= 0;
	end if;
end process;

state_reg_proc: process(clk, reset)
begin
	if reset = '1' then
		state <= (others => '0');
	elsif rising_edge(clk) then
		state <= next_state;	
	end if;
end process;

next_state_proc: process(all) --alzo e abbasso qui busy. fine_somma pure come variabile qua dentro
begin
	if reset = '1' then
		next_state	<= (others => '0');
	else
		case state is 
		when "00000" => 
			if istruzione /= x"00000000" then
				next_state 		<= "00001";
				status_reg(0) 	<= '1';     --metto busy a 1
			else
				next_state <= "00000";
			end if;
		when "00001" =>
			case istruzione(2 downto 0) is --leggo opcode
			when LOAD =>
				next_state <= "00010";
				
			when STORE =>
				next_state <= "00011";
				
			when ADD =>
				next_state <= "00100";
				
			when SET_M =>
				next_state <= "00101";
				
			when SET_N =>
				next_state <= "00110";
				
			when SET_S =>
				next_state <= "00111";
				
			when others => --errore
				next_state <= "00000";
				
			end case;
			
		when "00101" =>                 --set_m
			next_state 		<= "00000";
			status_reg(0) 	<= '0';     --metto busy a 0
			
		when "00110" =>                 --set_n
			next_state 		<= "00000";
			status_reg(0) 	<= '0';     --metto busy a 0
			
		when "00111" =>                 --set_s
			next_state 		<= "00000";
			status_reg(0) 	<= '0';     --metto busy a 0
			
		when "00010" =>                 --load
			next_state <= "01000";
			
		when "01000" =>
			next_state <= "01001";
			
		when "01001" =>
			if count = (ultimo_elemento-2) then    --l'ultimo elemento viene letto allo stato successivo
				next_state <= "01010";
			else 
				next_state <= "01001";
			end if;
			
		when "01010" => 
			next_state 		<= "00000";
			status_reg(0) 	<= '0';   --metto busy a 0
			
		when "00011" =>               --store
			next_state <= "01011";
			
		when "01011" => 
			next_state <= "01100";
			
		when "01100" =>
			if count = (ultimo_elemento-2) then
				next_state <= "01101";
			else 
				next_state <= "01100";
			end if;
			
		when "01101" =>
			next_state 		<= "00000";
			status_reg(0) 	<= '0';   --metto busy a 0
			
		when "00100" =>               --add
			next_state <= "01110";
			
		when "01110" => 
			next_state <= "01111";
			
		when "01111" => 
			next_state <= "10000";
			
		when "10000" =>               --DA COMPLETARE
			--if count = (ultimo_elemento-2) then
			--	next_state <= "10001";
			--else 
			--	next_state <= "10000";
			--end if;
			
		when "10001" =>
			next_state 		<= "00000";
			status_reg(0) 	<= '0';   --metto busy a 0
			
		when others =>
			next_state 		<= "00000";
			status_reg(0) 	<= '0';   --metto busy a 0
			
		end case;

	end if;
end process;


data_path_proc: process(clk, reset)

variable offset_locale : integer := 0;

begin
	if reset = '0' and rising_edge(clk) then
		case state is 

		when "00000" => 
			write_ls            	<= '0';
			mem_acc_write           <= '0';
			mem_acc_data            <= (others => 'z');

			if prima_iterazione = '1' then
				addr_reg_int 		<= std_logic_vector(to_unsigned(0, REG_ADDR_WIDTH));
				read_reg_int		<= '1';
				prima_iterazione 	<= '0';
			elsif istruzione = x"00000000" then       --sennò la sovrascrive
				istruzione 			<= data_reg_in;
			end if;

		when "00001" =>
			read_reg_int			<= '0';
			prima_iterazione 		<= '1';

		when "00101" =>              --set_m
			M_N_S_reg.M_value       <= istruzione(18 downto 3);

		when "00110" =>              --set_n
			M_N_S_reg.N_value       <= istruzione(18 downto 3);

		when "00111" =>              --set_s
			M_N_S_reg.S_value       <= istruzione(18 downto 3);

		when "00010" =>              --load, leggo indirizzo matrice memoria main
			read_reg_int 			<= '1';
			addr_reg_int            <= istruzione((8 + (REG_ADDR_WIDTH-1)) downto 8);  -- non avendo una dimensione fissa, nell'istruzione sono 5 bit (8-12), ma devo leggere solo quelli necessari

		when "01000" =>              --salvo elemento letto ciclo prima e leggo indirizzo memoria locale
			indirizzo_mem_ls        <= data_reg_in;
			read_reg_int 			<= '1';
			addr_reg_int            <= istruzione((3 + (REG_ADDR_WIDTH-1)) downto 3);  -- non avendo una dimensione fissa, nell'istruzione sono 5 bit (3-7), ma devo leggere solo quelli necessari
			count                   <= 0;
			offset_indirizzo        <= 0;

		when "01001" =>              --leggo elemento dalla main memory e salvo elemento letto ciclo precedente
			count 					<= count + 1;
			offset_indirizzo        <= offset_indirizzo + to_integer(unsigned(M_N_S_reg.S_value));

			--registri interni:
			if count = 0 then
				indirizzo_local_ls      <= data_reg_in;
				read_reg_int            <= '0';
				offset_locale           := 0;
			end if;

			--main memory:
			mem_acc_read            <= '1';
			mem_acc_address         <= std_logic_vector(unsigned(indirizzo_mem_ls) + to_unsigned(offset_indirizzo, 32));

			--memoria locale:
			if count /= 0 then
				if count mod SPM_NUM = 0 then
					offset_locale   := offset_locale + 4; --+4 o +1?????
				end if;
				write_ls            <= '1';
				spm_index           <= std_logic_vector(to_unsigned(count mod SPM_NUM, SPM_BIT_N));
				data_mem_out        <= mem_acc_data;
				addr_result         <= std_logic_vector(unsigned(indirizzo_local_ls) + to_unsigned(offset_locale, 32)); --aumenta di 1 ogni spm_num cicli. Per evitare una divisione conto a "mano" con offset_locale
			end if;

		when "01010" =>   --load ultimo elemento
			--main memory:
			mem_acc_read            <= '0';

			--memoria locale:
			write_ls            	<= '1';
			spm_index           	<= std_logic_vector(to_unsigned(count mod SPM_NUM, SPM_BIT_N));
			data_mem_out        	<= mem_acc_data;
			addr_result         	<= std_logic_vector(unsigned(indirizzo_local_ls) + to_unsigned(offset_locale, 32));

		when "00011" =>               --store
			read_reg_int 			<= '1';
			addr_reg_int            <= istruzione((3 + (REG_ADDR_WIDTH-1)) downto 3);  -- non avendo una dimensione fissa, nell'istruzione sono 5 bit (8-12), ma devo leggere solo quelli necessari


		when "01011" => 
			indirizzo_local_ls      <= data_reg_in;
			read_reg_int 			<= '1';
			addr_reg_int            <= istruzione((8 + (REG_ADDR_WIDTH-1)) downto 8);  -- non avendo una dimensione fissa, nell'istruzione sono 5 bit (3-7), ma devo leggere solo quelli necessari
			count                   <= 0;
			offset_indirizzo        <= 0;

		when "01100" =>
			count 					<= count + 1;
			offset_indirizzo        <= offset_indirizzo + to_integer(unsigned(M_N_S_reg.S_value));

			--registri interni:
			if count = 0 then
				indirizzo_mem_ls    <= data_reg_in;
				read_reg_int        <= '0';
				offset_locale       := 0;
			end if;

			--memoria locale:
			read_ls           	 	<= '1';
			if count mod SPM_NUM = 0 and count /= 0 then
				offset_locale   	:= offset_locale + 4; --+4 o +1?????
			end if;
			addr_operand(0)      	<= std_logic_vector(unsigned(indirizzo_local_ls) + to_unsigned(offset_locale, 32));
			spm_index            	<= count mod SPM_NUM;

			--memoria centrale:
			if count /= 0 then
				mem_acc_write    	<= '1';
				mem_acc_data        <= data_mem_in(spm_index)(0);
				mem_acc_address     <= std_logic_vector(unsigned(indirizzo_mem_ls) + to_unsigned(offset_indirizzo, 32));
			end if;

		when "01101" =>
			--memoria locale:
			read_ls             	<= '0';

			--memoria centrale:
			mem_acc_write    		<= '1';
			mem_acc_data        	<= data_mem_in(spm_index)(0);
			mem_acc_address     	<= std_logic_vector(unsigned(indirizzo_mem_ls) + to_unsigned(offset_indirizzo, 32));

		when "00100" =>               --add
			
		when "01110" => 
			--
		when "01111" => 
			--
		when "10000" =>
			--
		when "10001" =>
			--
		when others =>
			null;
		end case;
	end if;
end process;

end logic;