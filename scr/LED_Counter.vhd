
-------------------------------------------------------------------------------

-- Title       : A1000_0137_FPGA_Controller_Test_Code
-- Design      : A1000_0137_FPGA_Controller_Test_Code 
-- Author      : Monde Manzini
-- Company     : Square Kilometre Array

-------------------------------------------------------------------------------


-- DESCRIPTION


-- Tests the FPGA Programming operation 
-- Counts up in binary and display counts in Leds
--
-- Last update          : 19/10/2017 - Monde Manzini
--                      - 
--                      - 
--                      - 
--                      - 
--                      - 
-- Version              : 0.1 
-- Change Note          : None
-- Tested               : 10/01/2017
-- Test Bench file Name : None
-- Test Bench Location  : (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/ScrCommon)
-- Test do file         : None.do
-- located at            (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/Modelsim)
-- Outstanding          : None


-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LED_Counter is

port (
     rst        : in  std_logic;
     clk        : in  std_logic;
     main_start : in  std_logic;
     led        : out std_logic_vector(7 downto 0)
     );
end LED_Counter;

architecture Arch_Dut of LED_Counter is

type led_states is (idle, count_state, stop_state);
signal led_state : led_states;

signal led_i       : std_logic_vector(7 downto 0);
signal start       : std_logic;
signal start_latch : std_logic;
signal count       : integer range 0 to 255;

begin
   
  led <= led_i;  

counter : process (rst, clk) 
  variable bit_count_mS  : integer range 0 to 50001;
  variable sync_count_mS : integer range 0 to 1001;
  begin
    if rst = '0' then
      led_i         <= (others => '0');
      sync_count_mS := 0;
      bit_count_mS  := 0;
      start_latch   <= '0';
    elsif clk'event and clk = '1' then
      
      case led_state is 
        when idle =>
            if main_start = '1' then
               led_state   <= Idle;
            else
               led_state   <= idle;
            end if;   
                  
        when count_state =>          
          if bit_count_mS = 50000 then
            bit_count_mS  := 0;
            sync_count_mS := sync_count_mS + 1;
          else
            bit_count_mS := bit_count_mS + 1;  
          end if;

          if sync_count_mS = 10 then
            sync_count_mS := 0;
            count         <= count + 1;
          end if;

          led_i <= std_logic_vector(to_unsigned(count, led_i'length));

          if count = 255 then
             count     <= 0;
             led_state <= stop_state;
          end if;   

        when stop_state =>  
          led_i     <= x"00";        
          led_state <= idle;

        when others =>
          led_state <= idle;

        end case;

    end if;

end process counter;
 
end Arch_Dut;

