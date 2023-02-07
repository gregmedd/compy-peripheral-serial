--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:17:47 02/03/2023
-- Design Name:   
-- Module Name:   /home/greg/git/compy-v/peripherals/serial/memory_interface_testbench.vhd
-- Project Name:  nexys-2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart_memory_io
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
 
ENTITY memory_interface_testbench IS
END memory_interface_testbench;
 
ARCHITECTURE behavior OF memory_interface_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_memory_io
    PORT(
         clk : IN  std_logic;
         pselect : IN  std_logic;
         address : INOUT  std_logic_vector(31 downto 2);
         data : INOUT  std_logic_vector(31 downto 0);
         read : IN  std_logic;
         write : IN  std_logic;
         ack_rw : OUT  std_logic;
         interrupt : OUT  std_logic;
         bitrate_valid : IN  std_logic;
         tx_ready : IN  std_logic;
         rx_idle : IN  std_logic;
         rx_parity_good : IN  std_logic;
         next_tx_data : IN  std_logic_vector(7 downto 0);
         last_rx_data : IN  std_logic_vector(7 downto 0);
         tx_done : IN  std_logic;
         rx_done : IN  std_logic;
         rx_parity_error : IN  std_logic;
         eight_data : OUT  std_logic;
         two_stop : OUT  std_logic;
         parity : OUT  std_logic_vector(1 downto 0);
         rx_enable : OUT  std_logic;
         bit_rate : OUT  std_logic_vector(10 downto 0);
         tx_start : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal pselect : std_logic := '0';
   signal read : std_logic := '0';
   signal write : std_logic := '0';
   signal bitrate_valid : std_logic := '0';
   signal tx_ready : std_logic := '0';
   signal rx_idle : std_logic := '0';
   signal rx_parity_good : std_logic := '0';
   signal next_tx_data : std_logic_vector(7 downto 0) := (others => '0');
   signal last_rx_data : std_logic_vector(7 downto 0) := (others => '0');
   signal tx_done : std_logic := '0';
   signal rx_done : std_logic := '0';
   signal rx_parity_error : std_logic := '0';

	--BiDirs
   signal address : std_logic_vector(31 downto 2) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
   signal data : std_logic_vector(31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

 	--Outputs
   signal ack_rw : std_logic;
   signal interrupt : std_logic;
   signal eight_data : std_logic;
   signal two_stop : std_logic;
   signal parity : std_logic_vector(1 downto 0);
   signal rx_enable : std_logic;
   signal bit_rate : std_logic_vector(10 downto 0);
   signal tx_start : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_memory_io PORT MAP (
          clk => clk,
          pselect => pselect,
          address => address,
          data => data,
          read => read,
          write => write,
          ack_rw => ack_rw,
          interrupt => interrupt,
          bitrate_valid => bitrate_valid,
          tx_ready => tx_ready,
          rx_idle => rx_idle,
          rx_parity_good => rx_parity_good,
          next_tx_data => next_tx_data,
          last_rx_data => last_rx_data,
          tx_done => tx_done,
          rx_done => rx_done,
          rx_parity_error => rx_parity_error,
          eight_data => eight_data,
          two_stop => two_stop,
          parity => parity,
          rx_enable => rx_enable,
          bit_rate => bit_rate,
          tx_start => tx_start
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
      wait for clk_period/2;

      -- insert stimulus here 
      pselect <= '1';
      address <= "000000000000000000000000000000";
      read <= '1';
      
      wait for clk_period;
      
      pselect <= '0';
      address <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
      read <= '0';
      
      wait for clk_period*2;
      
      pselect <= '1';
      address <= "000000000000000000000000001000";
      read <= '1';
      
      wait for clk_period;
      
      pselect <= '0';
      address <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
      read <= '0';
      
      wait for clk_period*2;
      
      pselect <= '1';
      address <= "000000000000000000000000001000";
      data <= "10101000000000000000001001000000";
      write <= '1';
      
      wait for clk_period;
      
      pselect <= '0';
      address <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
      data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
      write <= '0';

      wait;
   end process;

END;
