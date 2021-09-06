
-------------------------------------------------------------------------------

-- Title       : A1000_0137_FPGA_Controller_Test_Code
-- Design      : A1000_0137_FPGA_Controller_Test_Code 
-- Author      : Monde Manzini
-- Company     : Square Kilometre Array

-------------------------------------------------------------------------------


-- DESCRIPTION


-- Top-level for FPGA Controller testing interfaces
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
use ieee.numeric_std.all;

entity A1000_0137_FPGA_Controller_Test_Code is

  port (
--------------------------Clock Input  ---------------------------------
    CLOCK_50                            : in    std_logic;                      --      50 MHz          
--------------------------Push Button  ---------------------------------                        
    KEY                                 : in    std_logic_vector(1 downto 0);   --      Pushbutton[1:0]                   
--------------------------DPDT Switch  ---------------------------------
    SW                                  : in    std_logic_vector(3 downto 0);   --      Toggle Switch[3:0]              
--------------------------LED    ------------------------------------
    LED                                 : out   std_logic_vector(7 downto 0);   --      LED [7:0]     
--------------------------SDRAM Interface  ---------------------------
    --DRAM_DQ                             : inout std_logic_vector(15 downto 0);  --      SDRAM Data bus 16 Bits
    --DRAM_DQM                            : out   std_logic_vector(1 downto 0);   --      SDRAM Data bus 2 Bits
    --DRAM_ADDR                           : out   std_logic_vector(12 downto 0);  --      SDRAM Address bus 13 Bits
    --DRAM_WE_N                           : out   std_logic;                      --      SDRAM Write Enable
    --DRAM_CAS_N                          : out   std_logic;                      --      SDRAM Column Address Strobe
    --DRAM_RAS_N                          : out   std_logic;                      --      SDRAM Row Address Strobe
    --DRAM_CS_N                           : out   std_logic;                      --      SDRAM Chip Select
    --DRAM_BA                             : out   std_logic_vector(1 downto 0);   --      SDRAM Bank Address 0
    --DRAM_CLK                            : out   std_logic;                      --      SDRAM Clock
    --DRAM_CKE                            : out   std_logic;                      --      SDRAM Clock Enable
 
--------------------------Accelerometer and EEPROM----------------
    --G_SENSOR_CS_N                       : out     std_logic;  
    --G_SENSOR_INT                        : in      std_logic;  
    I2C_SCLK                            : out     std_logic;  
    I2C_SDAT                            : inout   std_logic;  
--------------------------ADC--------------------------------------------------------
    --ADC_CS_N                            : out     std_logic;   
    --ADC_SADDR                           : out     std_logic; 
    --ADC_SCLK                            : out     std_logic; 
    --ADC_SDAT                            : in      std_logic;
--------------------------2x13 GPIO Header-----------------------------------------------
    GPIO_2_UP                           : inout   std_logic_vector(2 downto 0);
    GPIO_2                              : inout   std_logic_vector(8 downto 0);
    GPIO_2_IN                           : in      std_logic_vector(2 downto 0);
--------------------------GPIO_0, GPIO_0 connect to GPIO Default-----------------------
    GPIO_0                              : inout   std_logic_vector(33 downto 0);
    GPIO_0_IN                           : in      std_logic_vector(1 downto 0);
--------------------------GPIO_1, GPIO_1 connect to GPIO Default--------------------------
    GPIO_1                              : inout   std_logic_vector(33 downto 0);
    GPIO_1_IN                           : in      std_logic_vector(1 downto 0)
    );
end A1000_0137_FPGA_Controller_Test_Code;

architecture Arch_DUT of A1000_0137_FPGA_Controller_Test_Code is
  
-- Accelerometer and EEPROM
signal I2C_SCLK_i                       : std_logic;  
signal I2C_SDAT_i                       : std_logic; 

-- General Signals
signal RST_I_i                          : std_logic; 
signal CLK_I_i                          : STD_LOGIC;
signal One_uS_i                         : STD_LOGIC;     
signal One_mS_i                         : STD_LOGIC;              
signal Ten_mS_i                         : STD_LOGIC;
signal Twenty_mS_i                      : STD_LOGIC;             
signal Hunder_mS_i                      : STD_LOGIC;
signal UART_locked_i                    : STD_LOGIC;
signal One_Sec_i                        : STD_LOGIC;
signal Two_ms_i                         : STD_LOGIC;
signal One_mS_pulse_i                   : std_logic;

component LED_Counter is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    main_start : in  std_logic;
    led        : out std_logic_vector(7 downto 0)  
    );
end component LED_Counter;

----------------------------------------------------------------------
-- Interface Tester Signals and Component
----------------------------------------------------------------------
component Interface_Tester
port (
     rst        : in  std_logic;
     clk        : in  std_logic;
     SPI_1      : out std_logic_vector(34 downto 0);
     SPI_2      : out std_logic_vector(34 downto 0);
     tx_out     : out std_logic;
     RX         : in  std_logic;
     RX_PPS     : in  std_logic
     );
end component;

signal SPI_1_i   : std_logic_vector(34 downto 0);
signal SPI_2_i   : std_logic_vector(34 downto 0);
signal RX_i      : std_logic;
signal RX_PPS_i  : std_logic;
signal tx_out_i  : std_logic;

-- End of Signals and Components

-------------------------------------------------------------------------------
-- Clock for Genlock
-------------------------------------------------------------------------------  

-------------------------------------------------------------------------------
-- Code Start
-------------------------------------------------------------------------------  
  Begin
-------------------------------------------------------------------------------    
--  Wire
-------------------------------------------------------------------------------    
       CLK_I_i    <= CLOCK_50;    
-----------------------------------------------------
--              SPI Port 1 Assignments
-----------------------------------------------------       
       GPIO_0(29) <= SPI_1_i(0);     -- Pin 1  50-Way
       GPIO_0(27) <= SPI_1_i(1);     -- Pin 2  50-Way
       GPIO_0(24) <= SPI_1_i(2);     -- Pin 4  50-Way
       GPIO_0(22) <= SPI_1_i(3);     -- Pin 5  50-Way
       GPIO_0(20) <= SPI_1_i(4);     -- Pin 6  50-Way
       GPIO_0(17) <= SPI_1_i(5);     -- Pin 8  50-Way
       GPIO_0(15) <= SPI_1_i(6);     -- Pin 9  50-Way
       GPIO_0(12) <= SPI_1_i(7);     -- Pin 11 50-Way
       GPIO_0(10) <= SPI_1_i(8);     -- Pin 12 50-Way
       GPIO_0(7)  <= SPI_1_i(9);     -- Pin 14 50-Way    
       GPIO_0(5)  <= SPI_1_i(10);    -- Pin 15 50-Way  
       GPIO_0(3)  <= SPI_1_i(11);    -- Pin 16 50-Way  
       GPIO_0(28) <= SPI_1_i(12);    -- Pin 18 50-Way    
       GPIO_0(26) <= SPI_1_i(13);    -- Pin 19 50-Way     
       GPIO_0(25) <= SPI_1_i(14);    -- Pin 20 50-Way        
       GPIO_0(23) <= SPI_1_i(15);    -- Pin 21 50-Way             
       GPIO_0(21) <= SPI_1_i(16);    -- Pin 22 50-Way  
       GPIO_0(19) <= SPI_1_i(17);    -- Pin 23 50-Way  
       GPIO_0(18) <= SPI_1_i(18);    -- Pin 24 50-Way  
       GPIO_0(16) <= SPI_1_i(19);    -- Pin 25 50-Way       
       GPIO_0(14) <= SPI_1_i(20);    -- Pin 26 50-Way 
       GPIO_0(13) <= SPI_1_i(21);    -- Pin 27 50-Way 
       GPIO_0(11) <= SPI_1_i(22);    -- Pin 28 50-Way 
       GPIO_0(9)  <= SPI_1_i(23);    -- Pin 29 50-Way 
       GPIO_0(8)  <= SPI_1_i(24);    -- Pin 30 50-Way 
       GPIO_0(6)  <= SPI_1_i(25);    -- Pin 31 50-Way 
       GPIO_0(4)  <= SPI_1_i(26);    -- Pin 32 50-Way 
       GPIO_0(2)  <= SPI_1_i(27);    -- Pin 33 50-Way 
       GPIO_0(30) <= SPI_1_i(28);    -- Pin 35 50-Way 
       GPIO_0(31) <= SPI_1_i(29);    -- Pin 36 50-Way 
       GPIO_0(32) <= SPI_1_i(30);    -- Pin 39 50-Way 
       GPIO_0(33) <= SPI_1_i(31);    -- Pin 42 50-Way 
       GPIO_0(00) <= SPI_1_i(32);    -- Pin 45 50-Way 
       GPIO_2(03) <= SPI_1_i(33);    -- Pin 46 50-Way 
       GPIO_0(01) <= SPI_1_i(34);    -- Pin 49 50-Way 

-----------------------------------------------------
--              SPI Port 2 Assignments
-----------------------------------------------------       
       GPIO_1(30) <= SPI_2_i(0);     -- Pin 1  50-Way
       GPIO_1(28) <= SPI_2_i(1);     -- Pin 2  50-Way
       GPIO_1(25) <= SPI_2_i(2);     -- Pin 4  50-Way
       GPIO_1(23) <= SPI_2_i(3);     -- Pin 5  50-Way
       GPIO_1(22) <= SPI_2_i(4);     -- Pin 6  50-Way
       GPIO_1(18) <= SPI_2_i(5);     -- Pin 8  50-Way
       GPIO_1(16) <= SPI_2_i(6);     -- Pin 9  50-Way
       GPIO_1(13) <= SPI_2_i(7);     -- Pin 11 50-Way
       GPIO_1(11) <= SPI_2_i(8);     -- Pin 12 50-Way
       GPIO_1(8)  <= SPI_2_i(9);     -- Pin 14 50-Way    
       GPIO_1(6)  <= SPI_2_i(10);    -- Pin 15 50-Way  
       GPIO_1(4)  <= SPI_2_i(11);    -- Pin 16 50-Way  
       GPIO_1(29) <= SPI_2_i(12);    -- Pin 18 50-Way    
       GPIO_1(27) <= SPI_2_i(13);    -- Pin 19 50-Way     
       GPIO_1(26) <= SPI_2_i(14);    -- Pin 20 50-Way        
       GPIO_1(24) <= SPI_2_i(15);    -- Pin 21 50-Way             
       GPIO_1(22) <= SPI_2_i(16);    -- Pin 22 50-Way  
       GPIO_1(20) <= SPI_2_i(17);    -- Pin 23 50-Way  
       GPIO_1(19) <= SPI_2_i(18);    -- Pin 24 50-Way  
       GPIO_1(17) <= SPI_2_i(19);    -- Pin 25 50-Way       
       GPIO_1(15) <= SPI_2_i(20);    -- Pin 26 50-Way 
       GPIO_1(14) <= SPI_2_i(21);    -- Pin 27 50-Way 
       GPIO_1(12) <= SPI_2_i(22);    -- Pin 28 50-Way 
       GPIO_1(10) <= SPI_2_i(23);    -- Pin 29 50-Way 
       GPIO_1(9)  <= SPI_2_i(24);    -- Pin 30 50-Way 
       GPIO_1(7)  <= SPI_2_i(25);    -- Pin 31 50-Way 
       GPIO_1(5)  <= SPI_2_i(26);    -- Pin 32 50-Way 
       GPIO_1(3)  <= SPI_2_i(27);    -- Pin 33 50-Way 
       GPIO_1(31) <= SPI_2_i(28);    -- Pin 35 50-Way 
       GPIO_1(32) <= SPI_2_i(29);    -- Pin 36 50-Way 
       GPIO_1(33) <= SPI_2_i(30);    -- Pin 39 50-Way 
       GPIO_2(02) <= SPI_2_i(31);    -- Pin 42 50-Way 
       GPIO_1(00) <= Hunder_mS_i;--SPI_2_i(32);    -- Pin 45 50-Way 
       GPIO_1(01) <= SPI_2_i(33);    -- Pin 46 50-Way 
       GPIO_1(02) <= SPI_2_i(34);    -- Pin 49 50-Way        
       
       RX_i       <= GPIO_2(01);     -- RX FO
       RX_PPS_i   <= GPIO_0_IN(01);  -- RX PPS
       GPIO_2(06)  <= tx_out_i;
       
-------------------------------------------------------------------------------    
--  Instantiations of Modules
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

led_1 : entity work.LED_Counter
  port map (
    rst        => RST_I_i,
    clk        => CLK_I_i,
    main_start => KEY(0),
    led        => LED       
);

-------------------------------------------------------------------------------
-- Interface Tester Instance 
-------------------------------------------------------------------------------
Interface_1: entity work.Interface_Tester
port map (
  rst     => RST_I_i,
  clk     => CLK_I_i,
  SPI_1   => SPI_1_i,
  SPI_2   => SPI_2_i,
  tx_out  => tx_out_i,
  RX      => RX_i,
  RX_PPS  => RX_PPS_i
  );       
-------------------------------------------------------------------------------
-- Test Only
------------------------------------------------------------------------------- 
-- add switches and Leds
-------------------------------------------------------------------------------           
            
 Time_Trigger: process(RST_I_i,CLOCK_50)
    variable bit_cnt_OuS       : integer range 0 to 100;
    variable bit_cnt_OmS       : integer range 0 to 60000;
    variable bit_cnt_TmS       : integer range 0 to 600000;
    variable bit_cnt_20mS      : integer range 0 to 2000000;       
    variable bit_cnt_HmS       : integer range 0 to 6000000;
    variable Sec_Cnt           : integer range 0 to 11;
    variable Two_ms_cnt        : integer range 0 to 3;
    begin
      if RST_I_i = '0' then
         bit_cnt_OuS       := 0;
         bit_cnt_OmS       := 0;
         bit_cnt_TmS       := 0;         
         bit_cnt_HmS       := 0;
         bit_cnt_20mS      := 0;          
         One_uS_i          <= '0';
         One_mS_i          <= '0';        
         Ten_mS_i          <= '0';
         Twenty_mS_i       <= '0';
         Hunder_mS_i       <= '0';
         One_Sec_i         <= '0';
      elsif CLOCK_50'event and CLOCK_50 = '1' then       
--1uS
            if bit_cnt_OuS = 50 then
               One_uS_i         <= '1';
               bit_cnt_OuS      := 0;                      
            else
               One_uS_i        <= '0';
               bit_cnt_OuS      := bit_cnt_OuS + 1;
            end if;
--1mS            
            if bit_cnt_OmS = 50000 then
               One_mS_i         <= '1';                 
               bit_cnt_OmS      := 0;
               Two_ms_cnt       := Two_ms_cnt + 1;
            else
               One_mS_i   <= '0';
               bit_cnt_OmS      := bit_cnt_OmS + 1;
            end if;
-- 2 ms
            if Two_ms_cnt = 2 then
               Two_ms_i     <= '1';
               Two_ms_cnt   := 0;
            else
               Two_ms_i      <= '0';
            end if;   
--10mS     
--              if SYNC_Pulse_i = '1' then
--                 bit_cnt_TmS      := 0;
--                 Ten_mS_i         <= '0';
--              end if;
            
            if bit_cnt_TmS = 500000 then
               Ten_mS_i   <= '1';
               bit_cnt_TmS      := 0;                      
            else
               Ten_mS_i   <= '0';
               bit_cnt_TmS      := bit_cnt_TmS + 1;
            end if;

-- 20mS         
            if bit_cnt_20mS = 1000000 then
               Twenty_mS_i   <= '1';
               bit_cnt_20mS  := 0;                      
            else
               Twenty_mS_i   <= '0';
               bit_cnt_20mS  := bit_cnt_20mS + 1;
            end if;            
            
--100Ms
            if bit_cnt_HmS = 5000000 then
               Hunder_mS_i      <= '1';                  
               bit_cnt_HmS      := 0;
               Sec_Cnt          := Sec_Cnt + 1;
            else
               Hunder_mS_i      <= '0';
               bit_cnt_HmS      := bit_cnt_HmS + 1;
            end if;

-- 1 sec
            if Sec_Cnt = 10 then
               One_Sec_i <= '1';
               Sec_Cnt   := 0;
            else
              One_Sec_i  <= '0';
            end if;  
      end if;
 end process Time_Trigger;
                            
  Reset_gen : process(CLOCK_50)
          variable cnt : integer range 0 to 255;
        begin
          if (CLOCK_50'event) and (CLOCK_50 = '1') then            
            if cnt = 255 then
               RST_I_i <= '1';
            else
               cnt := cnt + 1;
               RST_I_i <= '0';
             end if;
          end if;
        end process Reset_gen; 
  
  end Arch_DUT;

