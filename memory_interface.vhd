----------------------------------------------------------------------------------
-- Engineer: Greg Medding
--
-- Design Name: UART Memory Interface
-- Module Name: uart_memory_io - Behavioral
-- Project Name: Serial Peripheral - COMPY-V
-- Description:
--      (TODO)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_memory_io is
    Port ( clk : in  STD_LOGIC;

           -------- Memory Bus Side --------

           -- Peripheral select signal - peripheral slot sets which address
           -- asserts this signal. Peripherals can conditionally ignore this
           -- signal when operating in MMIO mode (unsupported by UART).
           pselect : in STD_LOGIC;

           -- Memory Bus - 32bits, 4-byte aligned
           address : inout STD_LOGIC_VECTOR (31 downto 2);
           data : inout STD_LOGIC_VECTOR (31 downto 0);

           -- Memory Bus Control Signals
           read : in STD_LOGIC;
           write : in STD_LOGIC;
           ack_rw : out STD_LOGIC;

           -- Memory Bus DMA Control Signals (NOTE: Currently unused)
           --request_read : out STD_LOGIC;
           --request_write : out STD_LOGIC;
           --ack_request : in STD_LOGIC;

           -- Interrupt Controller Signals
           interrupt : out STD_LOGIC;

           -------- UART Module Side --------

           -- Status input signals
           bitrate_valid : in STD_LOGIC;
           tx_ready : in STD_LOGIC;
           rx_idle : in STD_LOGIC;
           rx_parity_good : in STD_LOGIC;
           next_tx_data : in STD_LOGIC_VECTOR(7 downto 0);
           last_rx_data : in STD_LOGIC_VECTOR(7 downto 0);

           -- Interrupt signals
           tx_done : in STD_LOGIC;
           rx_done : in STD_LOGIC;
           rx_parity_error : in STD_LOGIC;
           -- rx_dma_high_water : in STD_LOGIC;
           -- rx_dma_full : in STD_LOGIC;
           -- rx_overflow : in STD_LOGIC;

           -- Configuration Signals from registers
           eight_data : out STD_LOGIC;
           two_stop : out STD_LOGIC;
           parity  : out STD_LOGIC_VECTOR(1 downto 0);
           rx_enable : out STD_LOGIC;
           bit_rate  : out STD_LOGIC_VECTOR(10 downto 0);

    -----------------------------------------------------------
           -- Strobes to request transmit of data
           tx_start : out  STD_LOGIC);
end uart_memory_io;

architecture Behavioral of uart_memory_io is

    signal reg_eight_data : STD_LOGIC := '0';
    signal reg_two_stop : STD_LOGIC := '0';
    signal reg_parity  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal reg_rx_enable : STD_LOGIC := '0';
    signal reg_bit_rate  : STD_LOGIC_VECTOR(10 downto 0) := "00000000011";

begin
    -- Inbound memory requests
    process (clk) begin
        if rising_edge(clk) then
            if read = '1' and pselect = '1' then
                case address(7 downto 2) is

                    -- ID (0) 0x00
                    when "000000" =>
                        data(31 downto 24) <= x"A3";
                        data(23 downto 16) <= x"10";
                        -- TODO set this with a generic input
                        data(15 downto 0) <= x"0000";

                    -- Config (8) 0x20
                    when "001000" =>
                        data(31) <= reg_eight_data;
                        data(30) <= reg_two_stop;
                        data(29 downto 28) <= reg_parity;
                        data(27) <= reg_rx_enable;
                        data(26 downto 11) <= "0000000000000000";
                        data(10 downto 0) <= reg_bit_rate;

                    when others =>
                        data <= x"00000000";

                end case;

            elsif write = '1' and pselect = '1' then
                case address(7 downto 2) is

                    -- Config (8) 0x20
                    when "001000" =>
                        reg_eight_data <= data(31);
                        reg_two_stop <= data(30);
                        reg_parity <= data(29 downto 28);
                        reg_rx_enable <= data(27);
                        reg_bit_rate <= data(10 downto 0);

                    when others =>
                        -- Nothing yet

                end case;

            -- DMA has been approved
            --elsif req_ack = '1' then

            -- Idle state
            else
                address <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

            end if;
        end if;
    end process;

    eight_data <= reg_eight_data;
    two_stop <= reg_two_stop;
    parity <= reg_parity;
    rx_enable <= reg_rx_enable;
    bit_rate <= reg_bit_rate;

end Behavioral;

