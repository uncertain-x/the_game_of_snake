library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer is
    generic(
        clk_freq : integer := 100_000_000; -- 100 MHz
        stable_time : integer := 5            -- 5 ms
    );
    port(
        clk : in  std_logic;
        reset : in  std_logic;
        button : in  std_logic;
        result : out std_logic
    );
end Debouncer;

architecture Behavioral of Debouncer is

    constant count_max : integer := clk_freq / 1000 * stable_time;
    --simplify: stabletime_ms/((1/freq_s)*1000)
    signal flipflops : std_logic_vector(1 downto 0) := "00";
    signal counter : integer range 0 to count_max := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                flipflops <= "00";
                counter <= 0;
                result <= '0';

            else
                flipflops(0) <= button;
                flipflops(1) <= flipflops(0);

                if flipflops(0) /= flipflops(1) then
                    counter <= 0;

                elsif counter < count_max then
                    counter <= counter + 1;

                else
                    result <= flipflops(1);
                end if;
            end if;

        end if;
    end process;

end Behavioral;