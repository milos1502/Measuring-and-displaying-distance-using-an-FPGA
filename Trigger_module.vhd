library ieee;
use ieee.std_logic_1164.all;

entity Trigger_module is
    port(
        i_Trig_en: std_logic;
        o_Trig: out std_logic
    );
end entity;

architecture RTL of Trigger_module is
begin
    o_Trig <= '1' when i_Trig_en = '1' else '0';
end RTL;
                