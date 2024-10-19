library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Read_module is
    port (
        i_clk : in std_logic;
        i_Echo : in std_logic;
        o_Trigger : out std_logic;
        o_Tx : out std_logic;
        o_active : out std_logic
    );
end entity;

architecture RTL of Read_module is
    -- FSM:
    type stanje is (Trigger, Echo, Cifre, ASCII, Transmit);
    signal trenutno : stanje := Trigger;
    signal r_counter : integer := 0;
    signal r_reset : std_logic := '0';
    -- Trigger:
    signal r_Trig_en : std_logic := '0'; --?
    -- Echo:
    signal r_distance : integer := 0;
    -- ASCII:
    signal r_stotina : integer range 0 to 9 := 0;
    signal r_desetica : integer range 0 to 9 := 0;
    signal r_jedinica : integer range 0 to 9 := 0;
    signal r_ascii_data_buff : std_logic_vector (23 downto 0) := (others => '0');
    signal r_ascii_data: std_logic_vector (7 downto 0) := (others => '0');
    -- Transmit:
    signal r_data_avail : std_logic := '0';
    signal r_done_count : integer range 0 to 20 := 0;
    signal r_done : std_logic := '0';

begin
    process (i_clk) 
    begin
        if (rising_edge(i_clk)) then
            case trenutno is
                when Trigger =>  
                    r_data_avail <= '0'; -- redundandno
                    r_reset <= '0';
                    if (r_counter < 2) then -- Mozda nepotrebno
                        r_Trig_en <= '0';
                        r_counter <= r_counter + 1;
                        trenutno <= Trigger;
                    elsif (r_counter < 12) then
                        r_Trig_en <= '1';
                        r_counter <= r_counter + 1;
                        trenutno <= Trigger;
                    elsif (r_counter < 15) then
                        r_Trig_en <= '0';
                        r_counter <= r_counter + 1;
                        trenutno <= Trigger;
                    elsif (i_Echo = '1') then
                        r_Trig_en <= '0';
                        r_counter <= 0;
                        trenutno <= Echo;
                    end if;
                when Echo =>
                    if (i_Echo = '0') then
                        r_distance <= r_counter/58;
                        r_counter <= 0;
                        trenutno <= Cifre;
                    else
                        r_counter <= r_counter + 1;
                        trenutno <= Echo;
                    end if;
                when Cifre =>
                    case r_distance is
                        when 0 to 9 =>
                            r_stotina <= 0;
                            r_desetica <= 0;
                            r_jedinica <= r_distance;
                        when 10 to 99 =>
                            r_stotina <= 0;
                            r_desetica <= r_distance/10; 
                            r_jedinica <= r_distance rem 10;
                        when others =>
                            r_stotina <= r_distance /100;
                            r_desetica <= (r_distance/10) rem 10;
                            r_jedinica <= r_distance rem 10;
                    end case;
                    if (r_counter < 100) then -- Mozda nepotrebno
                        trenutno <= Cifre;
                        r_counter <= r_counter + 1;
                    else
                        r_counter <= 0;
                        trenutno <= ASCII;
                    end if;
                when ASCII =>
                    case r_jedinica is
                        when 0 =>
                            r_ascii_data_buff (7 downto 0) <= x"30";     
                        when 1 =>
                            r_ascii_data_buff (7 downto 0) <= x"31";
                        when 2 =>
                            r_ascii_data_buff (7 downto 0) <= x"32";
                        when 3 =>
                            r_ascii_data_buff (7 downto 0) <= x"33";
                        when 4 =>
                            r_ascii_data_buff (7 downto 0) <= x"34";
                        when 5 =>
                            r_ascii_data_buff (7 downto 0) <= x"35";
                        when 6 =>
                            r_ascii_data_buff (7 downto 0) <= x"36";
                        when 7 =>
                            r_ascii_data_buff (7 downto 0) <= x"37";
                        when 8 =>
                            r_ascii_data_buff (7 downto 0) <= x"38";
                        when others =>
                            r_ascii_data_buff (7 downto 0) <= x"39";
                    end case;

                    case r_desetica is
                        when 0 =>
                            r_ascii_data_buff (15 downto 8) <= x"00"; -- x"30" da si posten     
                        when 1 =>
                            r_ascii_data_buff (15 downto 8) <= x"31";
                        when 2 =>
                            r_ascii_data_buff (15 downto 8) <= x"32";
                        when 3 =>
                            r_ascii_data_buff (15 downto 8) <= x"33";
                        when 4 =>
                            r_ascii_data_buff (15 downto 8) <= x"34";
                        when 5 =>
                            r_ascii_data_buff (15 downto 8) <= x"35";
                        when 6 =>
                            r_ascii_data_buff (15 downto 8) <= x"36";
                        when 7 =>
                            r_ascii_data_buff (15 downto 8) <= x"37";
                        when 8 =>
                            r_ascii_data_buff (15 downto 8) <= x"38";
                        when others =>
                            r_ascii_data_buff (15 downto 8) <= x"39";
                    end case;

                    case r_stotina is
                        when 0 =>
                            r_ascii_data_buff (23 downto 16) <= x"00";     
                        when 1 =>
                            r_ascii_data_buff (23 downto 16) <= x"31";
                        when 2 =>
                            r_ascii_data_buff (23 downto 16) <= x"32";
                        when 3 =>
                            r_ascii_data_buff (23 downto 16) <= x"33";
                        when 4 =>
                            r_ascii_data_buff (23 downto 16) <= x"34";
                        when 5 =>
                            r_ascii_data_buff (23 downto 16) <= x"35";
                        when 6 =>
                            r_ascii_data_buff (23 downto 16) <= x"36";
                        when 7 =>
                            r_ascii_data_buff (23 downto 16) <= x"37";
                        when 8 =>
                            r_ascii_data_buff (23 downto 16) <= x"38";
                        when others =>
                            r_ascii_data_buff (23 downto 16) <= x"39";
                    end case;

                    if (r_counter < 100) then -- Mozda nepotrebno
                        trenutno <= ASCII;
                        r_counter <= r_counter + 1;
                    else
                        r_counter <= 0;
                        trenutno <= Transmit;
                        r_ascii_data <= x"52"; -- R
                        r_data_avail <= '1';
                    end if;
                when Transmit =>
                    if (r_reset = '1') then
                        trenutno <= Trigger;
                        r_counter <= 0;
                        r_data_avail <= '0'; -- redundantno? 
                    else
                        trenutno <= Transmit;
                        -- Ovde ga vrati u 1, ne valja
                    end if;
                    
                    if (r_done = '1') then
                        if (r_done_count = 0) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"61"; -- a
                        elsif (r_done_count = 1) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"7A"; -- z
                        elsif (r_done_count = 2) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"64"; -- d
                        elsif (r_done_count = 3) then 
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"61"; -- a
                        elsif (r_done_count = 4) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"6C"; -- l
                        elsif (r_done_count = 5) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"6A"; -- j
                        elsif (r_done_count = 6) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"69"; -- i
                        elsif (r_done_count = 7) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"6E"; -- n
                        elsif (r_done_count = 8) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"61"; -- a
                        elsif (r_done_count = 9) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"20"; -- space
                        elsif (r_done_count = 10) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"28"; -- (
                        elsif (r_done_count = 11) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"63"; -- c
                        elsif (r_done_count = 12) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"6D"; -- m          
                        elsif (r_done_count = 13) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"29"; -- )
                        elsif (r_done_count = 14) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"3A"; -- :
                        elsif (r_done_count = 15) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"20"; -- space
                        elsif (r_done_count = 16) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= r_ascii_data_buff (23 downto 16); -- cifra stotina
                        elsif (r_done_count = 17) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= r_ascii_data_buff (15 downto 8); -- cifra desetica
                        elsif (r_done_count = 18) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= r_ascii_data_buff (7 downto 0); -- cifra jedinica
                        elsif (r_done_count = 19) then
                            r_done_count <= r_done_count + 1;
                            r_ascii_data <= x"0D"; -- Novi red
                            r_data_avail <= '0';
                        else
                            r_done_count <= 0;
                            r_reset <= '1';
                            r_ascii_data <= (others => '0'); -- NULL
                        end if;
                    end if;
                -- when Reset => 
                -- when Novi_red =>
            end case;
        end if;
    end process;
    
    --Instanciranje komponenata:
    Trig: entity work.Trigger_module
    port map
    (
        i_Trig_en => r_Trig_en,
        o_Trig => o_Trigger
    );

    UART: entity work.UART_TX
    generic map (clks_per_bit => 104) -- 1MHz/9600
    port map
    (
        i_clk => i_clk,
        i_data_byte => r_ascii_data,
        i_data_avail => r_data_avail,
        o_active => o_active,
        o_done => r_done,
        o_Tx => o_Tx
    );
end RTL;

----------------------------------------------------------------------------------------





                    
                    



                    
                    

