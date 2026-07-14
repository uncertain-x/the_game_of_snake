--"00" = GAME_START
--"01" = RUNNING
--"10" = PAUSED
--"11" = GAME_OVER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity game_state is

    port(
        clk: in  std_logic;
        reset: in  std_logic;
        start_btn : in  std_logic; --after debouncer
        collision : in  std_logic; --from snake_control

        state_out  : out std_logic_vector(1 downto 0); --to display
        running_en : out std_logic --to snake_control

    );
end game_state;

architecture Behavioral of game_state is

    constant game_start: std_logic_vector(1 downto 0) := "00";
    constant running : std_logic_vector(1 downto 0) := "01";
    constant paused : std_logic_vector(1 downto 0) := "10";
    constant game_over : std_logic_vector(1 downto 0) := "11";

    signal current_state : std_logic_vector(1 downto 0) := game_start;
    signal start_last : std_logic := '0';
    -- signal start_pulse : std_logic := '0'; --detect button change from 0 to 1

begin

    process(clk)
        variable start_pulse : std_logic;
    begin
        if rising_edge(clk) then

            start_pulse :=  '0';

            if reset = '1' then
                current_state <= game_start;
                start_last    <= '0';
            --avoid state changing all the time
            else
                start_last <= start_btn;

                if start_btn = '1' and start_last = '0' then
                    start_pulse := '1';
                --else
                    --start_pulse := '0';
                end if;



                case current_state is

                    when game_start =>
                        if start_pulse = '1' then
                            current_state <= running;
                        end if;

                    when running =>
                        if collision = '1' then
                            current_state <= game_over;
                        elsif start_pulse = '1' then
                            current_state <= paused;
                        end if;

                    when paused =>
                        if start_pulse = '1' then
                            current_state <= running;
                        end if;

                    when game_over =>
                        -- if start_pulse = '1' then
                        --     current_state <= game_start;
                        -- end if;
                        current_state <= game_over;

                    when others =>
                        current_state <= game_start;

                end case;
            end if;
        end if;
    end process;

    state_out <= current_state; --for display

    running_en <= '1' when current_state = running else '0';

end Behavioral;
