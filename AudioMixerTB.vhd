library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity AudioMixertb is 
end AudioMixertb;

architecture testbench of AudioMixertb is
component AudioMixer
Port(
        clk_in : in std_logic;                              -- clock variable
        clk_out : in std_logic;
        enable : in std_logic;                           -- start of serial transmission
        sr_in : in std_logic;                            -- serial bit data
        sr_ou : out std_logic;  
        gain_A1 : in unsigned(9 downto 0);       -- gain 1 (10 bt data) for multiplication with seril data 1
        gain_A2 : in unsigned(9 downto 0);       -- gain 2 (10 bt data) for multiplication with seril data 1
        gain_B1 : in unsigned(9 downto 0);       -- gain 3 (10 bt data) for multiplication with seril data 2 
        gain_B2 : in unsigned(9 downto 0);       -- gain 4 (10 bt data) for multiplication with seril data 2 
        gain_C1 : in unsigned(9 downto 0);
        gain_C2 : in unsigned(9 downto 0);
        gain_D1 : in unsigned(9 downto 0);
        gain_D2 : in unsigned(9 downto 0);
        gain_1 : in unsigned(9 downto 0);
        gain_2 : in unsigned(9 downto 0)        

	--CLK_IN, SDATA, FSYNC, RESET,clock_out : in std_logic;
	--GCA0,GCA1,GCB0,GCB1,GCC0,GCC1,GCD0,GCD1 : in unsigned(9 downto 0);
	--GA,GB : in unsigned(9 downto 0);
	--clk_out, DataOut: out std_logic;
	--counter_up_test: out std_logic_vector(1 downto 0);
	--DR1,DR2 : out std_logic_vector(23 downto 0)
);
end component;
        signal clk_in : std_logic;                              -- clock variable
        signal clk_out : std_logic;
        signal enable : std_logic;                           -- start of serial transmission
        signal sr_in : std_logic;                            -- serial bit data
        signal sr_ou : std_logic;   
        signal ch4 : signed(79 downto 0);         -- output channe (64 bit data)
        signal chout : signed(47 downto 0);       -- out put data (32 bit data)
        signal gain_A1 : unsigned(9 downto 0);       -- gain 1 (10 bt data) for multiplication with seril data 1
        signal gain_A2 : unsigned(9 downto 0);       -- gain 2 (10 bt data) for multiplication with seril data 1
        signal gain_B1 : unsigned(9 downto 0);       -- gain 3 (10 bt data) for multiplication with seril data 2 
        signal gain_B2 : unsigned(9 downto 0);       -- gain 4 (10 bt data) for multiplication with seril data 2 
        signal gain_C1 : unsigned(9 downto 0);
        signal gain_C2 : unsigned(9 downto 0);
        signal gain_D1 : unsigned(9 downto 0);
        signal gain_D2 : unsigned(9 downto 0);
        signal gain_1 : unsigned(9 downto 0);
        signal gain_2 : unsigned(9 downto 0);
        signal EOF : std_logic; 

	--signal clk_in, SDATA, FSYNC, RESET,clock_out : std_logic := '0';
	--signal GCA0,GCA1,GCB0,GCB1,GCC0,GCC1,GCD0,GCD1 : unsigned(9 downto 0);
	--signal GA,GB : unsigned(9 downto 0);
	--signal clk_out : std_logic;
	--signal DataOut : std_logic;
	--signal counter_up_test: std_logic_vector(1 downto 0);
	--signal DR1 :  std_logic_vector(23 downto 0);
	--signal DR2 :  std_logic_vector(23 downto 0);
	--signal DR3 :  std_logic_vector(26 downto 0);
	--signal DR4 :  std_logic_vector(26 downto 0);
	--signal sdt : std_logic_vector(15 downto 0);
	constant clk_in_period: time := 162 ns;
	constant clk_out_period: time := 216 ns;

begin
DUT:  AudioMixer port map (
        clk_in => clk_in,
        clk_out => clk_out,
	enable => enable,
	sr_in => sr_in,
        sr_ou => sr_ou,
        gain_A1 => gain_A1,
        gain_A2 => gain_A2,
        gain_B1 => gain_B1, 
        gain_B2 => gain_B2, 
        gain_C1 => gain_C1,
        gain_C2 => gain_C2,
        gain_D1 => gain_D1,
        gain_D2 => gain_D2,
        gain_1 => gain_1,
        gain_2 => gain_2);


clkin_process:process
		begin
		clk_in <= '0';
		wait for clk_in_period / 2;
		clk_in <= '1';
		wait for clk_in_period / 2;
end process;

clock_out_process:process
        	   begin
       		   clk_out <= '0';
		   wait for clk_out_period / 2;
		   clk_out <= '1';
 		   wait for clk_out_period / 2;
end process;


stimuli: process
		--variable v_ILINE     : line;
		--variable temp: std_logic_vector(15 downto 0);
		--variable v_SPACE : character ;
                 variable line_v : line;       
                 file read_file : text;
                 variable slv_v : std_logic; 
                 variable slv_o : std_logic_vector(23 downto 0);
                 
	  begin
		
		EOF <= '0';
		enable <= '1'; -- Initial conditions.
		wait for 1 ns;
		enable <= '0'; -- Down to work!
		wait for 1 ns;
		--Fsync <= '1';
		--wait for 100 ns;
		--Fsync <= '0';
                --variable line_v : line;
                --file read_file : text;
                file_open(read_file, "myfile.txt", read_mode);
                
                --file_open(write_file, "target.txt", write_mode);
                gain_A1 <= "0000000001";
		gain_A2 <= "0000000011";
		gain_B1 <= "0000000111";
		gain_B2 <= "0000001111";
		gain_C1 <= "0000011111";
		gain_C2 <= "0000111111";
		gain_D1 <= "0001111111";
		gain_D2 <= "0011111111";	
		gain_1 <= "0111111111";
		gain_2 <= "1111111111";
                while not endfile(read_file) loop
                 readline(read_file, line_v);
                 read(line_v, slv_v);
                 sr_in <= slv_v;
                --file_close(read_file);
                --file_close(write_file);
                --report "slv_v: " & to_hstring(slv_v);
                --slv_o <= chout;
                wait for 162 ns;
                
                --writeline(write_file, line_v);
                end loop;
            EOF <= '1';    
           file_close(read_file); 			
        wait;
	end process;
writeProcess: process(clk_out)
                 variable line_o : line;
                 file write_file : text;
               begin
                 if(rising_edge(clk_out)) then
                   file_open(write_file, "output.txt",write_mode);
                   if(EOF = '0') then
                      write(line_o, sr_ou);
                      writeline(write_file, line_o);
                   else
                    file_close(write_file);
                  end if;
                 end if;
              end process;
end architecture;