--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:11:44 01/09/2023
-- Design Name:   
-- Module Name:   /home/greg/git/compy-v/peripherals/serial/transmitter_testbench.vhd
-- Project Name:  nexys-2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transmitter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY transmitter_testbench IS
END transmitter_testbench;
 
ARCHITECTURE behavior OF transmitter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transmitter
    PORT(
         clk : IN  std_logic;
         clk_div : IN  std_logic_vector(18 downto 0);
         parity : IN  std_logic_vector(1 downto 0);
         two_stop : IN  std_logic;
         eight_data : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         txdata : OUT  std_logic;
         txready : OUT  std_logic;
         txstart : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk_div : std_logic_vector(18 downto 0) := (others => '0');
   signal parity : std_logic_vector(1 downto 0) := (others => '0');
   signal two_stop : std_logic := '0';
   signal eight_data : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal txstart : std_logic := '0';

 	--Outputs
   signal txdata : std_logic;
   signal txready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: transmitter PORT MAP (
          clk => clk,
          clk_div => clk_div,
          parity => parity,
          two_stop => two_stop,
          eight_data => eight_data,
          data => data,
          txdata => txdata,
          txready => txready,
          txstart => txstart
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		clk_div <= "0000000000110110010";
		eight_data <= '1';
		data <= "01000001";
		wait for clk_period;
		txstart <= '1';
		wait for clk_period;
		txstart <= '0';

      wait;
   end process;

END;
