library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX is
    generic(
        clks_per_bit: integer
    );
    port(
        i_clk: in std_logic;
        i_data_byte: in std_logic_vector(7 downto 0);
        i_data_avail: in std_logic;
        --indikatorski izlazli:
        o_active: out std_logic; --LED na plocici
        o_done: out std_logic; --LED na plocici
        -- izlazni podatak:
        o_Tx: out std_logic
    );
end entity;

architecture RTL of UART_TX is
    type state is (idle, start, send, stop_bit);
    
    signal state_tx: state:= idle;
    signal bit_index: integer:= 0;
    signal r_counter: integer range 0 to clks_per_bit:= 0;
    --signal r_data_byte: std_logic_vector(7 downto 0);
    signal r_Tx : std_logic;

begin
    process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            case state_tx is
                when idle =>
                    r_Tx <= '1';
                    o_done <= '0';
                    r_counter <= 0;
                    bit_index <= 0;
                    -- check if data available
                    if (i_data_avail = '1') then
                        state_tx <= start; 
                        o_active <= '1';
                        --r_data_byte <= i_data_byte;
                    else
                        state_tx <= idle;
                        o_active <= '0';
                    end if;
                when start =>
                    r_Tx <= '0';
                    if (r_counter = clks_per_bit - 1) then
                        r_counter <= 0;
                        state_tx <= send;
                    else
                        r_counter <= r_counter + 1;
                        state_tx <= start;
                    end if;
                when send =>
                    r_Tx <= i_data_byte (bit_index);
                    if (r_counter = clks_per_bit - 1) then
                        r_counter <= 0;
                        if (bit_index < 7) then
                            bit_index <= bit_index + 1;
                            state_tx <= send;
                        else 
                            bit_index <= 0;
                            state_tx <= stop_bit;
                        end if;
                    else
                        r_counter <= r_counter + 1;
                        state_tx <= send;
                    end if;
                when stop_bit =>
                    r_Tx <= '1';
                    if (r_counter = clks_per_bit - 1) then
                        state_tx <= idle;
                        o_done <= '1'; -- potrebno je brojiti koliko puta je 
                        -- zavrsio transmisiju
                        o_active <= '0';
                    else
                        r_counter <= r_counter + 1;
                        state_tx <= stop_bit;
                    end if;
            end case;
        end if;
    end process;
    o_Tx <= r_Tx;
   -- send_data <= '1' when 
end RTL;    
                    
                
-- upon receving the byte from i_data_byte the data_avail goes HIGH
-- we wait for the falling edge of the data_avail, indicating the data is to be ignored
-- as a result, the active pin goes HIGH
-- active meaning that the valid data is being forwoarded to the o_Tx
-- o_active <= not o_done