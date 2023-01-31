----------------------------------------------------------------------------------
-- Engineer: Greg Medding
--
-- Design Name: UART Bit Rate Decoder
-- Module Name: bitrate_decoder - Behavioral
-- Project Name: Serial Peripheral - COMPY-V
-- Description:
--      Converts bit rates to clock divider values for the transitter and receiver
--      components. This allows upstream components to set speeds like 300bps
--      or 115200bps and the correct clock dividers will be set automatically.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bitrate_decoder is
    Generic ( clkrate : integer := 50000000 );
    Port ( clk_div : out  STD_LOGIC_VECTOR (18 downto 0);
           rate_valid : out  STD_LOGIC;
           -- Format: hundreds of bits per second.
           -- 75 => 0
           -- 110 => 1
           -- 150 => 2
           -- 300 => 3
           -- 600 => 6
           -- 1200 => 12
           -- 1800 => 18
           -- 2400 => 24
           -- 4800 => 48
           -- 7200 => 72
           -- 9600 => 96
           -- 14400 => 144
           -- 19200 => 192
           -- 38400 => 384
           -- 56000 => 560
           -- 57600 => 576
           -- 115200 => 1152
           -- 128000 => 1280
           bitrate : in  STD_LOGIC_VECTOR (10 downto 0));
end bitrate_decoder;

architecture Behavioral of bitrate_decoder is

    -- TODO: Make this a generic input?
    --constant clkrate : integer := 50000000;

begin

    process (bitrate) begin
        case bitrate is

            -- 75 bps
            when "00000000000" =>
                rate_valid <= '1';
                -- NOTE: because of a quirk of how our tx/rx module clock divider
                -- works, we have to divide the result by two. This will be done at
                -- all bit rates.
                clk_div <= std_logic_vector(to_unsigned(clkrate / (75 * 2), clk_div'length));

            -- 110 bps
            when "00000000001" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (110 * 2), clk_div'length));

            -- 150 bps
            when "00000000010" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (150 * 2), clk_div'length));

            -- 300 bps
            when "00000000011" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (300 * 2), clk_div'length));

            -- 600 bps
            when "00000000110" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (600 * 2), clk_div'length));

            -- 1200 bps
            when "00000001100" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (1200 * 2), clk_div'length));

            -- 1800 bps
            when "00000010010" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (1800 * 2), clk_div'length));

            -- 2400 bps
            when "00000011000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (2400 * 2), clk_div'length));

            -- 4800 bps
            when "00000110000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (4800 * 2), clk_div'length));

            -- 7200 bps
            when "00001001000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (7200 * 2), clk_div'length));

            -- 9600 bps
            when "00001100000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (9600 * 2), clk_div'length));

            -- 14400 bps
            when "00010010000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (14400 * 2), clk_div'length));

            -- 19200 bps
            when "00011000000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (19200 * 2), clk_div'length));

            -- 38400 bps
            when "00110000000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (38400 * 2), clk_div'length));

            -- 56000 bps
            when "01000110000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (56000 * 2), clk_div'length));

            -- 57600 bps
            when "01001000000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (57600 * 2), clk_div'length));

            -- 115200 bps
            when "10010000000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (115200 * 2), clk_div'length));

            -- 128000 bps
            when "10100000000" =>
                rate_valid <= '1';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (128000 * 2), clk_div'length));

            -- INVALID RATES
            when others =>
                rate_valid <= '0';
                clk_div <= std_logic_vector(to_unsigned(clkrate / (9600 * 2), clk_div'length));

        end case;
    end process;

end Behavioral;

