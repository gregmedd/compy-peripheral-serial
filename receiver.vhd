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

entity receiver is
    Port ( clk : in  STD_LOGIC;
           clk_div : in  STD_LOGIC_VECTOR (18 downto 0);
           rx_enable : in  STD_LOGIC;
           -- Parity: 00=none 01=even 10=odd
           parity : in  STD_LOGIC_VECTOR (1 downto 0);
           two_stop : in  STD_LOGIC;
           eight_data : in  STD_LOGIC;

           -- UART signal in
           rxdata : in STD_LOGIC;

           data : out  STD_LOGIC_VECTOR (7 downto 0);
           parity_good : out STD_LOGIC;
           rxidle : out  STD_LOGIC;
           -- Strobes at the end of a received frame
           rxdone : out  STD_LOGIC);
end receiver;

architecture Behavioral of receiver is

    type rxstate is (
        rx_idle,
        rx_start,
        rx_data,
        rx_parity,
        rx_stop
    );

    signal clk_counter : std_logic_vector (18 downto 0) := "0000000000000000000";
    signal bit_clk : std_logic := '0';
    signal bit_clk_en : std_logic := '0';
    signal current_clk_div : std_logic_vector (18 downto 0);

    signal state : rxstate := rx_idle;

    -- Counting registers tracking bits sent in each phase
    signal start_bits_seen : std_logic := '0';
    signal data_bits_seen : std_logic_vector (3 downto 0) := "0000";
    signal parity_bits_seen : std_logic := '0';
    signal stop_bits_seen : std_logic_vector (1 downto 0) := "00";

    -- Registers to capture current TX settings on transition from idle to transmit
    signal expected_start_bits : std_logic := '1';
    signal expected_data_bits : std_logic_vector (3 downto 0) := "0000";
    signal expected_parity_bits : std_logic := '0';
    signal expected_stop_bits : std_logic_vector (1 downto 0) := "00";
    signal current_parity_mode : std_logic_vector (1 downto 0) := "00";

    -- Intermediate parity calculation
    signal expected_parity_bit : std_logic := '0';

    signal rx_data_buffer : std_logic_vector (7 downto 0) := "00000000";
    signal rx_parity_bit : std_logic := '0';

    -- Signals connected directly to outputs so default values can be set
    signal data_out : std_logic_vector (7 downto 0) := "00000000";
    signal parity_good_out : std_logic := '1';

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

                when rx_idle =>
                    rxdone <= '0';
                    if rx_enable = '1' and rxdata = '1' then
                        current_clk_div <= clk_div;

                        expected_start_bits <= '1';

                        if eight_data = '1' then
                            expected_data_bits <= "1000";
                        else
                            expected_data_bits <= "0111";
                        end if;

                        current_parity_mode <= parity;
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
                        state <= rx_start;
                    end if;

                when rx_start =>
                    if start_bits_seen = expected_start_bits then
                        state <= rx_data;
                    end if;

                when rx_data =>
                    if data_bits_seen = expected_data_bits then
                        if expected_parity_bits = '1' then
                            state <= rx_parity;
                        else
                            data_out <= rx_data_buffer;
                            parity_good_out <= '1';

                            state <= rx_stop;
                        end if;
                    end if;

                when rx_parity =>
                    if parity_bits_seen = expected_parity_bits then
                        data_out <= rx_data_buffer;
                        parity_good_out <= not (rx_parity_bit xor expected_parity_bit);

                        state <= rx_stop;
                    end if;

                when rx_stop =>
                    if stop_bits_seen = expected_stop_bits then
                        bit_clk_en <= '0';
                        state <= rx_idle;
                        rxdone <= '1';
                    end if;

            end case;
        end if;
    end process;

    data <= data_out;
    parity_good <= parity_good_out;

    -- RX bit counter
    process (bit_clk) begin
        if falling_edge(bit_clk) then
            case state is

                when rx_start =>
                    start_bits_seen <= '1';
                    -- Prepare for the last stage of transmit
                    stop_bits_seen <= "00";

                when rx_data =>
                    data_bits_seen <= data_bits_seen + 1;

                when rx_parity =>
                    parity_bits_seen <= '1';

                when rx_stop =>
                    stop_bits_seen <= stop_bits_seen + 1;
                    -- Cleanup while we still have a clock
                    start_bits_seen <= '0';
                    data_bits_seen <= "0000";
                    parity_bits_seen <= '0';

                when others =>
                    -- Nothing to do here

            end case;
        end if;
    end process;

    -- RX idle/done signal generator
    process (state) begin
        case state is

            when rx_idle =>
                rxidle <= '1';

            when others =>
                rxidle <= '0';

        end case;
    end process;

    -- RX data shift register
    process (bit_clk) begin
        if rising_edge(bit_clk) then
            case state is

                when rx_data =>
                    rx_data_buffer(6 downto 0) <= rx_data_buffer(7 downto 1);
                    rx_data_buffer(7) <= rxdata;

                    -- Even parity
                    if current_parity_mode = "01" then
                        expected_parity_bit <= rx_data_buffer(7) xor rx_data_buffer(6) xor
                                               rx_data_buffer(5) xor rx_data_buffer(4) xor
                                               rx_data_buffer(3) xor rx_data_buffer(2) xor
                                               rx_data_buffer(1) xor rx_data_buffer(0);
                    -- Odd parity
                    elsif current_parity_mode = "10" then
                        expected_parity_bit <= not (rx_data_buffer(7) xor rx_data_buffer(6)
                                               xor rx_data_buffer(5) xor rx_data_buffer(4)
                                               xor rx_data_buffer(3) xor rx_data_buffer(2)
                                               xor rx_data_buffer(1) xor rx_data_buffer(0));
                    end if;

                when rx_parity =>
                    rx_parity_bit <= rxdata;

                when others =>
                    -- Nothing to do

            end case;
        end if;
    end process;

end Behavioral;

