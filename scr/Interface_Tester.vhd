
-------------------------------------------------------------------------------

-- Title       : Interface_Tester
-- Design      : Interface_Tester 
-- Author      : Monde Manzini
-- Company     : Square Kilometre Array

-------------------------------------------------------------------------------


-- DESCRIPTION


-- Tests the external interfaces of the FPGA Controller
-- RX and RX_PPS are inputs to the module
  -- If RX is high, SPI 2 control signals are high
  -- If RX_PPS is high, SPI 1 control signals are high
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


-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Interface_Tester is

port (
     rst    : in  std_logic;
     clk    : in  std_logic;
     SPI_1  : out std_logic_vector(34 downto 0);
     SPI_2  : out std_logic_vector(34 downto 0);
     tx_out : out std_logic;
     RX     : in  std_logic;
     RX_PPS : in  std_logic
     );
end Interface_Tester;

architecture Arch_Dut of Interface_Tester is

signal SPI_1_i     : std_logic_vector(34 downto 0);
signal SPI_2_i     : std_logic_vector(34 downto 0);
signal RX_i        : std_logic;
signal RX_PPS_i    : std_logic;
begin
   
  SPI_1    <= SPI_1_i;  
  SPI_2    <= SPI_2_i;  
  RX_i     <= RX;  
  RX_PPS_i <= RX_PPS;  
  
counter : process (rst, clk) 
  variable bit_count_mS  : integer range 0 to 50001;
  variable sync_count_mS : integer range 0 to 1001;
  variable tx_cnt_ms      : integer range 0 to 50000;
  variable tx_cnt_sec     : integer range 0 to 1000;
  begin
    if rst = '0' then
      sync_count_mS := 0;
      bit_count_mS  := 0;
      tx_cnt_ms     := 0;
      tx_cnt_sec    := 0;
      SPI_1_i       <= (others => '0');
      SPI_2_i       <= (others => '0');
    elsif clk'event and clk = '1' then
      
      -- TX Counter

      if tx_cnt_ms = 50000 then -- 1 ms
      tx_cnt_ms    := 0;
        tx_cnt_sec := tx_cnt_sec + 1;
      else
        tx_cnt_ms := tx_cnt_ms + 1;
      end if;

      if tx_cnt_sec = 250 then
        tx_out <= '1';
      elsif tx_cnt_sec = 500 then
        tx_out <= '0';
        tx_cnt_sec := 0;
      end if;


        if RX_i = '1' then
          SPI_2_i(31 downto 0) <= X"FFFFFFFF";
          SPI_2_i(34 downto 32) <= b"111";
        elsif RX_i = '0' then 
          SPI_2_i(31 downto 0) <= X"00000000";
          SPI_2_i(34 downto 32) <= b"000";
        end if;

        if RX_PPS_i = '1' then
          SPI_1_i(31 downto 0)  <= X"FFFFFFFF";
          SPI_1_i(34 downto 32) <= b"111";
        elsif RX_PPS_i = '0' then 
          SPI_1_i(31 downto 0)  <= X"00000000";
          SPI_1_i(34 downto 32) <= b"000";
        end if;

    end if;

end process counter;
 
end Arch_Dut;

