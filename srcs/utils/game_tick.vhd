library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_tick is
    generic (
        clk_board : integer := 100_000_000; -- 100 MHz
        tick_cycle : integer := 150 -- snake moves every 150 ms
    );
    port (
        clk : in std_logic;
        reset : in std_logic; --1
       -- enable : in std_logic;
        tick : out std_logic  -- connected to sanke control
    );
end entity game_tick;

architecture behavioral of game_tick is

    constant count_max: integer := (clk_board/1000) * tick_cycle - 1;
    signal counter:   integer range 0 to count_max   := 0;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                tick <= '0';
            elsif counter = count_max then
                counter <= 0;
                tick <= '1';
            else
                counter <= counter + 1;
                tick <= '0';
            end if;
        end if;
    end process;
end architecture behavioral;