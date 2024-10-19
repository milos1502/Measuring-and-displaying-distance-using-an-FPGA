library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Read_tb is
end entity;

architecture tb of Read_tb is
    signal w_clk : std_logic := '0';
    signal i_Echo : std_logic := '0';
    signal o_Trigger : std_logic;
    signal o_Tx : std_logic;
    signal o_active : std_logic;
begin
    uut: entity work.Read_module
    port map 
    (
       i_clk => w_clk,
       i_Echo => i_Echo,
       o_Trigger => o_Trigger,
       o_Tx => o_Tx,
       o_active => o_active 
    );

    w_clk <= not w_clk after 1 ns;

    process 
    begin
        wait for 30 ns;
        i_Echo <= '1';
        wait for 9000 ns;
        i_Echo <= '0';
        wait;
    end process;
end tb;


----------------------------------------

