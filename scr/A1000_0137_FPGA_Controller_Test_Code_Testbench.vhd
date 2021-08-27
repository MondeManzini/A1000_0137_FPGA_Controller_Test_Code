-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file contains  modules which make up a testbench
-- suitable for testing the "device under test".
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity A1000_0137_FPGA_Controller_Test_Code_Testbench is

end A1000_0137_FPGA_Controller_Test_Code_Testbench;

architecture Archtest_bench of A1000_0137_FPGA_Controller_Test_Code_Testbench is
	
  component test_bench_T
    generic (
      Vec_Width  : positive := 4;
      ClkPer     : time     := 20 ns;
      StimuFile  : string   := "data.txt";
      ResultFile : string   := "results.txt"
      );
    port (
      oVec : out std_logic_vector(Vec_Width-1 downto 0);
      oClk : out std_logic;
      iVec : in std_logic_vector(3 downto 0)
      );
  end component;

----------------------------------------------------------------------
-- LED Counter Signals and Component
----------------------------------------------------------------------
component LED_Counter
    port (
         rst        : in  std_logic;
         clk        : in  std_logic;
         main_start : in  std_logic;
         led        : out std_logic_vector(7 downto 0)
         );
    end component;

signal main_start_i   : std_logic;
signal led_i          : std_logic_vector(7 downto 0);
signal RST_I_i        : std_logic;
signal CLK_I_i        : std_logic;
signal Hun_mS_sStrobe : std_logic;

----------------------------------------------------------------------
-- Interface Tester Signals and Component
----------------------------------------------------------------------
component Interface_Tester
port (
     rst        : in  std_logic;
     clk        : in  std_logic;
     SPI_1      : out std_logic_vector(34 downto 0);
     SPI_2      : out std_logic_vector(34 downto 0);
     RX         : in  std_logic;
     RX_PPS     : in  std_logic
     );
end component;

signal SPI_1_i   : std_logic_vector(34 downto 0);
signal SPI_2_i   : std_logic_vector(34 downto 0);
signal RX_i      : std_logic;
signal RX_PPS_i  : std_logic;
---------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
  signal sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
  signal stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
  signal sCnt         : integer range 0 to 7 := 0;
  signal cont         : integer range 0 to 100;  
  signal oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A : std_logic;
  signal square_wave  : std_logic := '0';


  constant Baudrate : integer := 115200;
  constant bit_time_4800      : time                         := 52.08*4 us;
  constant bit_time_9600      : time                         := 52.08*2 us;    
  constant bit_time_19200     : time                         := 52.08 us;
  constant bit_time_57600     : time                         := 17.36 us;    
  constant bit_time_115200    : time                         := 8.68 us;  
  constant default_bit_time   : time                         := 52.08 us;  --19200  
  constant start_bit          : std_logic := '0';
  constant stop_bit           : std_logic := '1';
  signal   bit_time           : time;

  begin
    
RST_I_i         <= snrst;
CLK_I_i         <= sClok;

-------------------------------------------------------------------------------
-- LED Counter Instance 
-------------------------------------------------------------------------------
LEd_1: entity work.LED_Counter
port map (
  rst        => RST_I_i,
  clk        => CLK_I_i,
  main_start => Hun_mS_sStrobe,
  led        => led_i
  );       
    
-------------------------------------------------------------------------------
-- Interface Tester Instance 
-------------------------------------------------------------------------------
Interface_1: entity work.Interface_Tester
port map (
  rst    => RST_I_i,
  clk    => CLK_I_i,
  SPI_1  => SPI_1_i,
  SPI_2  => SPI_2_i,
  RX     => square_wave, -- RX_i,
  RX_PPS => RX_PPS_i
  );       

square_wave_pulse: process (RST_I_i, CLK_I_i)
    variable squ_wave_cntr: integer range 0 to 30;
  begin
    if RST_I_i = '0' then
      squ_wave_cntr := 0;
      square_wave   <= '0';
    elsif (CLK_I_i'event and CLK_I_i = '1') then  
      if Hun_mS_sStrobe = '1' then
        squ_wave_cntr := squ_wave_cntr + 1;
      end if;
      
      if squ_wave_cntr = 10 then
        square_wave   <= '1'; 
        squ_wave_cntr := squ_wave_cntr + 1;
      elsif squ_wave_cntr = 21 then
        squ_wave_cntr := 0;
        square_wave   <= '0'; 
      end if;    
    end if;

  end process square_wave_pulse;  

strobe: process
   begin
     sStrobe <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 200 us;
   end process strobe;

   strobe_SPI: process
   begin
     sStrobe_A <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 1 ms;
   end process strobe_SPI;
  
    uS_strobe: process
    begin
      OneuS_sStrobe <= '0', '1' after 1 us, '0' after 1.020 us;  
      wait for 1 us;
    end process uS_strobe;

    mS_strobe: process
    begin
      OnemS_sStrobe <= '0', '1' after 1 ms, '0' after 1.00002 ms;  
      wait for 1.0001 ms;
    end process mS_strobe;

    Hun_mS_strobe: process
    begin
      Hun_mS_sStrobe <= '0', '1' after 100 ms, '0' after 100.00002 ms;  
      wait for 100.0002 ms;
    end process Hun_mS_strobe;  

  Gen_Clock: process
  begin
    sClok <= '0', '1' after 10 ns;
    wait for 20 ns;
  end process Gen_Clock;
  
  Do_reset: process(sClok)
  begin
    if (sClok'event and sClok='1') then 
      if sCnt = 7 then
        sCnt <= sCnt;
      else 
        sCnt <= sCnt + 1;

        case sCnt is
          when 0 => snrst <= '0';
          when 1 => snrst <= '0';
          when 2 => snrst <= '0';
          when 3 => snrst <= '0';
          when 4 => snrst <= '0';
          when others => snrst <= '1';
        end case;

      end if;
   
  end if;
  end process;

end Archtest_bench;

