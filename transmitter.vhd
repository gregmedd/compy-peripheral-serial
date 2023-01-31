----------------------------------------------------------------------------------
-- Engineer: Greg Medding
--
-- Design Name: UART Transmitter
-- Module Name: transmitter - Behavioral
-- Project Name: Serial Peripheral - COMPY-V
-- Description:
--      Transmitter for a UART serial transciever. Configurable for 7/8 data
--      bits, 1/2 stop bits, O/E/N parity, and arbitrary bit rates through a
--      clock divider value.
--
--      NOTE: The internal bit clock *toggles* every clk_div rising edges of the
--            input clk signal. Divider values should be calculated by taking
--            the frequency of the input clock, dividing by the desired bit
--            clock, then dividing by 2.
--
--      When txready is high, the transmitter is ready to start transmission.
--      During this time, txstart can be strobed high for one clk cycle. All
--      other inputs will be latched to registers and transmission will start.
--      Configuration cannot be changed until transmission of the data frame has
--      completed.
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
           -- Parity: 00=none 01=even 10=odd
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

    signal clk_counter : std_logic_vector (18 downto 0) := "0000000000000000000";
    signal bit_clk : std_logic := '0';
    signal bit_clk_en : std_logic := '0';
    signal current_clk_div : std_logic_vector (18 downto 0);

    signal state : txstate := tx_idle;

    -- Counting registers tracking bits sent in each phase
    signal start_bits_sent : std_logic := '0';
    signal tx_bits_sent : std_logic_vector (3 downto 0) := "0000";
    signal parity_bits_sent : std_logic := '0';
    signal stop_bits_sent : std_logic_vector (1 downto 0) := "00";

    -- Registers to capture current TX settings on transition from idle to transmit
    signal expected_start_bits : std_logic := '1';
    signal expected_tx_bits : std_logic_vector (3 downto 0) := "0000";
    signal expected_parity_bits : std_logic := '0';
    signal expected_stop_bits : std_logic_vector (1 downto 0) := "00";
    signal expected_tx_data : std_logic_vector (7 downto 0) := "00000000";


    signal current_tx_data : std_logic_vector (6 downto 0) := "0000000";
    signal current_tx_parity : std_logic := '0';
    signal next_tx_bit : std_logic := '0';

begin
    -- Bit clock generator
    process (clk, bit_clk_en) begin
        if rising_edge(clk) then
            if bit_clk_en = '1' and clk_counter = current_clk_div then
                clk_counter <= "0000000000000000000";
                bit_clk <= not bit_clk;
            elsif bit_clk_en = '1' then
                clk_counter <= clk_counter + 1;
            else
                bit_clk <= '0';
                clk_counter <= "0000000000000000000";
            end if;
        end if;
    end process;

    -- State machine
    process (clk) begin
        if rising_edge(clk) then
            case state is

                when tx_idle =>
                    if txstart = '1' then
                        current_clk_div <= clk_div;

                        expected_tx_data <= data;

                        -- Even parity
                        if parity = "01" then
                            current_tx_parity <= data(7) xor data(6) xor
                                                 data(5) xor data(4) xor
                                                 data(3) xor data(2) xor
                                                 data(1) xor data(0);
                        -- Odd parity
                        elsif parity = "10" then
                            current_tx_parity <= not (data(7) xor data(6)
                                                 xor data(5) xor data(4)
                                                 xor data(3) xor data(2)
                                                 xor data(1) xor data(0));
                        else
                            current_tx_parity <= '0';
                        end if;

                        expected_start_bits <= '1';

                        if eight_data = '1' then
                            expected_tx_bits <= "1000";
                        else
                            expected_tx_bits <= "0111";
                        end if;

                        if parity = "01" or parity = "10" then
                            expected_parity_bits <= '1';
                        else
                            expected_parity_bits <= '0';
                        end if;

                        if two_stop = '1' then
                            expected_stop_bits <= "10";
                        else
                            expected_stop_bits <= "01";
                        end if;

                        bit_clk_en <= '1';
                        state <= tx_start;
                    end if;

                when tx_start =>
                    if start_bits_sent = expected_start_bits then
                        state <= tx_transmit;
                    end if;

                when tx_transmit =>
                    if tx_bits_sent = expected_tx_bits then
                        if expected_parity_bits = '1' then
                            state <= tx_parity;
                        else
                            state <= tx_stop;
                        end if;
                    end if;

                when tx_parity =>
                    if parity_bits_sent = expected_parity_bits then
                        state <= tx_stop;
                    end if;

                when tx_stop =>
                    if stop_bits_sent = expected_stop_bits then
                        bit_clk_en <= '0';
                        state <= tx_idle;
                    end if;

            end case;
        end if;
    end process;

    -- TX bit counter
    process (bit_clk, bit_clk_en) begin
        if falling_edge(bit_clk) then
            case state is

                when tx_start =>
                    start_bits_sent <= '1';
                    -- Prepare for the last stage of transmit
                    stop_bits_sent <= "00";

                when tx_transmit =>
                    tx_bits_sent <= tx_bits_sent + 1;

                when tx_parity =>
                    parity_bits_sent <= '1';

                when tx_stop =>
                    stop_bits_sent <= stop_bits_sent + 1;
                    -- Cleanup while we still have a clock
                    start_bits_sent <= '0';
                    tx_bits_sent <= "0000";
                    parity_bits_sent <= '0';

                when others =>
                    -- Nothing to do here

            end case;
        end if;
    end process;

    -- TX ready signal generator
    process (state) begin
        case state is

            when tx_idle =>
                txready <= '1';

            when tx_start =>
                txready <= '0';

            when tx_transmit =>
                txready <= '0';

            when tx_parity =>
                txready <= '0';

            when tx_stop =>
                txready <= '0';

        end case;
    end process;

    -- TX data shift register
    process (bit_clk) begin
        if falling_edge(bit_clk) then
            case state is

                when tx_idle =>
                -- Nothing to do

                when tx_start =>
                    current_tx_data(6 downto 0) <= expected_tx_data(7 downto 1);
                    next_tx_bit <= expected_tx_data(0);

                when tx_transmit =>
                    current_tx_data(5 downto 0) <= current_tx_data(6 downto 1);
                    next_tx_bit <= current_tx_data(0);

                when tx_parity =>
                -- Nothing to do

                when tx_stop =>
            -- Nothing to do

            end case;
        end if;
    end process;

    -- TX data generator
    process (state, next_tx_bit, current_tx_parity) begin
        case state is

            when tx_idle =>
                txdata <= '0';

            when tx_start =>
                txdata <= '1';

            when tx_transmit =>
                txdata <= next_tx_bit;

            when tx_parity =>
                txdata <= current_tx_parity;

            when tx_stop =>
                txdata <= '0';

        end case;
    end process;

end Behavioral;

