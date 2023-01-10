----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:32:40 01/09/2023 
-- Design Name: 
-- Module Name:    transmitter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transmitter is
    Port ( clk : in  STD_LOGIC;
           clk_div : in  STD_LOGIC_VECTOR (18 downto 0);
           parity : in  STD_LOGIC_VECTOR (1 downto 0);
           two_stop : in  STD_LOGIC;
           eight_data : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           txdata : out  STD_LOGIC;
           txready : out  STD_LOGIC;
           txstart : in  STD_LOGIC);
end transmitter;

architecture Behavioral of transmitter is

	type txstate is (
		tx_idle,
		tx_start,
		tx_transmit,
		tx_parity,
		tx_stop
		);

	signal clk_counter : std_logic_vector (18 downto 0);
	signal bit_clk : std_logic := '0';
	signal bit_clk_en : std_logic := '0';
	signal current_clk_div : std_logic_vector (18 downto 0);
	
	signal state : txstate := tx_idle;
	
	signal start_bits_remaining : std_logic;
	signal tx_bits_remaining : std_logic_vector (3 downto 0);
	signal current_tx_data : std_logic_vector (7 downto 0);
	signal parity_bits_remaining : std_logic;
	signal current_tx_parity : std_logic;
	signal stop_bits_remaining : std_logic_vector (1 downto 0);

begin

	-- Bit clock generator
	process (clk, bit_clk_en) begin
		if rising_edge(clk) and bit_clk_en = '1' then
			if clk_counter = current_clk_div then
				clk_counter <= "0000000000000000000";
				bit_clk <= not bit_clk;
			else
				clk_counter <= clk_counter + 1;
			end if;
			
		elsif bit_clk_en = '0' then
			bit_clk <= '0';
		end if;
	end process;
	
	-- State machine
	process (clk, txstart) begin
		if rising_edge(clk) then
			case state is
			
				when tx_idle =>
					if rising_edge(txstart) then
						clk_counter <= "0000000000000000000";
						current_clk_div <= clk_div;
						current_tx_data <= data;
						start_bits_remaining <= '1';
						
						if eight_data = '1' then
							tx_bits_remaining <= "1000";
						else
							tx_bits_remaining <= "0111";
						end if;

						if parity = "01" then
							parity_bits_remaining <= '1';
							current_tx_parity <= data(7) xor data(6) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1) xor data(0);
						elsif parity = "10" then
							parity_bits_remaining <= '1';
							current_tx_parity <= not (data(7) xor data(6) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1) xor data(0));
						else
							parity_bits_remaining <= '0';
						end if;
						
						if two_stop = '1' then
							stop_bits_remaining <= "10";
						else
							stop_bits_remaining <= "01";
						end if;
						
					end if;
					
				when tx_start =>
					if start_bits_remaining = '0' then
						state <= tx_transmit;
					end if;
					
				when tx_transmit =>
					if tx_bits_remaining = "0000" then
						if parity_bits_remaining = '1' then
							state <= tx_parity;
						else
							state <= tx_stop;
						end if;
					end if;
					
				when tx_parity =>
					if parity_bits_remaining = '0' then
						state <= tx_stop;
					end if;
					
				when tx_stop =>
					if stop_bits_remaining = "00" then
						state <= tx_idle;
					end if;
					
			end case;
		end if;
	end process;
	
	-- TX bit counter
	process (bit_clk) begin
		if falling_edge(bit_clk) then
			case state is
				when tx_start =>
					start_bits_remaining <= '0';
				when tx_transmit =>
					tx_bits_remaining <= tx_bits_remaining - 1;
				when tx_parity =>
					parity_bits_remaining <= '0';
				when tx_stop =>
					stop_bits_remaining <= stop_bits_remaining - 1;
				when others =>
					-- do nothing
			end case;
		end if;
	end process;
	
	-- TX data generator
	process (bit_clk, state) begin
		case state is
		
			when tx_idle =>
				txdata <= '0';
				txready <= '1';
				
			when tx_start =>
				txdata <= '1';
				txready <= '0';
				
			when tx_transmit =>
				txdata <= current_tx_data(0);
				txready <= '0';
				if falling_edge(bit_clk) then
					current_tx_data(6 downto 0) <= current_tx_data(7 downto 1);
				end if;
				
			when tx_parity =>
				txdata <= current_tx_parity;
				txready <= '0';
				
			when tx_stop =>
				txdata <= '0';
				txready <= '0';
				
		end case;
	end process;

end Behavioral;

