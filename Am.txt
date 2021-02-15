library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.std_logic_unsigned.all;

entity AudioMixer is
port (
    clk_in : in std_logic;                              -- clock variable
    clk_out : in std_logic;
    enable : in std_logic;                           -- start of serial transmission
    sr_in : in std_logic; 
    sr_ou : out std_logic;                           -- serial bit data
    gain_A1 : in unsigned(9 downto 0);       -- gain 1 (10 bt data) for multiplication with seril data 1
    gain_A2 : in unsigned(9 downto 0);       -- gain 2 (10 bt data) for multiplication with seril data 1
    gain_B1 : in unsigned(9 downto 0);       -- gain 3 (10 bt data) for multiplication with seril data 2 
    gain_B2 : in unsigned(9 downto 0);       -- gain 4 (10 bt data) for multiplication with seril data 2 
    gain_C1 : in unsigned(9 downto 0);       -- gain 5 
    gain_C2 : in unsigned(9 downto 0);       -- gain 6
    gain_D1 : in unsigned(9 downto 0);       -- gain 7
    gain_D2 : in unsigned(9 downto 0);       -- gain 8
    gain_1 : in unsigned(9 downto 0);        -- gain 9 
    gain_2 : in unsigned(9 downto 0));       -- gain 10
end AudioMixer;


architecture  mixer of AudioMixer is

signal output : signed(47 downto 0) := (others => '0');
signal ch4 : signed(79 downto 0) := (others => '0');         -- output channe (64 bit data)
signal chout : signed(47 downto 0) := (others => '0');       -- out put data (32 bit data)
signal chanA1 : signed(15 downto 0) := (others => '0');
signal chanB2 : signed(15 downto 0) := (others => '0');
signal chanC3 : signed(15 downto 0) := (others => '0');
signal chanD4 : signed(15 downto 0) := (others => '0');
signal chAG1 : signed(26 downto 0) := (others => '0');
signal chAG2 : signed(26 downto 0) := (others => '0');
signal chAG3 : signed(26 downto 0) := (others => '0');
signal chAG4 : signed(26 downto 0) := (others => '0');
signal chBG1 : signed(26 downto 0) := (others => '0');
signal chBG2 : signed(26 downto 0) := (others => '0');
signal chBG3 : signed(26 downto 0) := (others => '0');
signal chBG4 : signed(26 downto 0) := (others => '0');
signal chAdd : signed(28 downto 0) := (others => '0');
signal chA1 : signed(39 downto 0) := (others => '0');
signal chB1 : signed(39 downto 0) := (others => '0');     -- temporary channel to store the data
--signal chB : signed(63 downto 0) := (others => '0');     -- temporary channel to store the data
signal sr_out : signed(15 downto 0) := (others => '0');  -- for troubleshooting purposes
signal rst_counter : integer range 0 to 17;                         -- counter
signal cnt : integer range 0 to 4;                                 -- counter for 4 cycles
signal tem : integer range 0 to 5 := 1;
signal temp1 : signed(10 downto 0) := (others => '0');   -- variables for converting 10 bit gain into 16 bit gain
signal temp2 : signed(10 downto 0) := (others => '0');
signal temp3 : signed(10 downto 0) := (others => '0');
signal temp4 : signed(10 downto 0) := (others => '0');
signal temp5 : signed(10 downto 0) := (others => '0');
signal temp6 : signed(10 downto 0) := (others => '0');
signal temp7 : signed(10 downto 0) := (others => '0');
signal temp8 : signed(10 downto 0) := (others => '0');
signal temp9 : signed(10 downto 0) := (others => '0');
signal temp10 : signed(10 downto 0) := (others => '0');
signal MA : signed(31 downto 0) := (others => '0');
signal MB : signed(31 downto 0) := (others => '0');
signal flush : std_logic := '0';                   -- variable to act as signals for process in the sensitivity list 
signal act : integer range 0 to 5 := 0;
signal join : integer range 0 to 10 := 0;
signal serial_counter : integer range 0 to 16 := 0;
signal counter :integer range 0 to 47 := 0;
signal sr : std_logic;
signal single_bit : std_logic;

begin 
  process(clk_in, sr_in)
  begin
  if enable = '1'  then
	rst_counter <= 0;
	cnt <= 0;
    act <= 0;
    
  elsif (rising_edge(clk_in)) then
    temp1 <= '0' & signed(gain_A1);   -- 10 bit gain is converted into 11 bit signed value
    temp2 <= '0' & signed(gain_A2);   -- 10 bit gain is converted into 11 bit signed value
    temp3 <= '0' & signed(gain_B1);   -- converting all the 10 bit data into signed 11 bit data
    temp4 <= '0' & signed(gain_B2);
    temp5 <= '0' & signed(gain_C1);
    temp6 <= '0' & signed(gain_C2);
    temp7 <= '0' & signed(gain_D1);
    temp8 <= '0' & signed(gain_D2);
    temp9 <= '0' & signed(gain_1);
    temp10 <= '0' & signed(gain_2);
  
    rst_counter <= rst_counter + 1;
    sr_out (15 downto 1) <= sr_out(14 downto 0);
    sr_out(0) <= sr_in;                  -- temporary storage of 16 bit data in sr_out signal which will be stored into 4 registers      
    act <= 1;
    if(rst_counter = 16) then
	  if(cnt = 0) then               -- for register 1
		chanA1 <= sr_out;
		cnt <= cnt+1;
	  elsif(cnt = 1) then            -- for register 2
		chanB2 <= sr_out;
		cnt <= cnt+1;
	  elsif(cnt = 2) then            -- for register 3
		chanC3 <= sr_out;
		cnt <= cnt+1;
	  elsif(cnt = 3) then            -- for register 4
		chanD4 <= sr_out;
		cnt <=0;
      --  flush <= '1';
	  end if;
	rst_counter <= 0;
    end if;
      --flush <= '0';
   end if;
end process;
   chBG1 <= chanA1 * temp2;          -- individual multiplication of the 4 channels 
   chBG2 <= chanB2 * temp4;          -- 4 channels 8 gains. each channel multiplied with two gains and added
   chBG3 <= chanC3 * temp6;
   chBG4 <= chanD4 * temp8;
   chAG1 <= chanA1 * temp1;
   chAG2 <= chanB2 * temp3;
   chAG3 <= chanC3 * temp5; 
   chAG4 <= chanD4 * temp7;

  process(cnt)
   begin
     if(cnt = 0) then                 --  when the multiplication is complete
      chAdd <= ("00"&chAG1) + ("00"&chAG2) + ("00"&chAG3) + ("00"&chAG4);  -- for capturing over flow
      chA1 <= chAdd * temp9;               -- channel A with final gain
      chB1 <= chAdd * temp10;              -- channel B with final gain
      ch4 <= chA1 & chB1;
     end if;
  end process;

 output(47 downto 24) <= chA1(39 downto 16);   -- truncation
 output(23 downto 0) <= chB1(39 downto 16);    -- truncation
 chout(47 downto 24) <= chA1(39 downto 16); -- 37 bit reduction into 24 bit , removing unwanted LSBs
 chout(23 downto 0) <= chB1(39 downto 16);  -- truncation
 
process(clk_out)                              -- process which is in sync with the output clock
  begin
   if (rising_edge(clk_out)) then
    if (counter < 47) then
      counter <= counter + 1;
    else
      counter <= 0;
    end if; 
    sr_ou <= output(counter);
  end if;
 --single_bit <= output(counter);
 end process;
end architecture mixer;

