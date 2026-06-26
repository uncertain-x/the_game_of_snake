library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity direction_control is
    port (
        clk: in  std_logic;
        reset : in  std_logic;

        btn_up : in  std_logic;
        btn_down : in  std_logic;
        btn_left : in  std_logic;
        btn_right : in  std_logic;

        direction : out std_logic_vector(1 downto 0) --00 01 10 11 for snake control
    );
end direction_control;

architecture Behavioral of direction_control is

    constant dir_up : std_logic_vector(1 downto 0) := "00";
    constant dir_down : std_logic_vector(1 downto 0) := "01";
    constant dir_left : std_logic_vector(1 downto 0) := "10";
    constant dir_right : std_logic_vector(1 downto 0) := "11";

    signal current_dir: std_logic_vector(1 downto 0) := dir_right;

begin
    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                current_dir <= dir_right; -- initial direction

            else
                if btn_up = '1' and current_dir /= dir_down then
                    current_dir <= dir_up;
                elsif btn_down = '1' and current_dir /= dir_up then
                    current_dir <= dir_down;
                elsif btn_left = '1' and current_dir /= dir_right then
                    current_dir <= dir_left;
                elsif btn_right = '1' and current_dir /= dir_left then
                    current_dir <= dir_right;
                else
                    current_dir <= current_dir;
                end if;
            end if;
        end if;
    end process;

    direction <= current_dir;

end Behavioral;