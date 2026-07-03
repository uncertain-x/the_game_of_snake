library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity food_control_tb is
end entity;

architecture sim of food_control_tb is
  constant CLK_PERIOD : time := 10 ns;

  signal clk    : std_logic := '0';
  signal reset  : std_logic := '1';
  signal eat    : std_logic := '0';
  signal food_x : std_logic_vector(4 downto 0);
  signal food_y : std_logic_vector(3 downto 0);

  procedure assert_inside_play_area(
    constant x_value : in std_logic_vector(4 downto 0);
    constant y_value : in std_logic_vector(3 downto 0);
    constant tag     : in string
  ) is
    variable x_int : natural;
    variable y_int : natural;
  begin
    x_int := to_integer(unsigned(x_value));
    y_int := to_integer(unsigned(y_value));
    assert x_int >= 1 and x_int <= 18
      report tag & ": x outside playable area"
      severity failure;
    assert y_int >= 1 and y_int <= 13
      report tag & ": y outside playable area"
      severity failure;
  end procedure;
begin
  clk <= not clk after CLK_PERIOD / 2;

  dut : entity work.food_control
    port map (
      clk    => clk,
      reset  => reset,
      eat    => eat,
      food_x => food_x,
      food_y => food_y
    );

  stim : process
    variable first_x  : std_logic_vector(4 downto 0);
    variable first_y  : std_logic_vector(3 downto 0);
    variable second_x : std_logic_vector(4 downto 0);
    variable second_y : std_logic_vector(3 downto 0);
  begin
    wait for 5 * CLK_PERIOD;
    reset <= '0';
    wait until rising_edge(clk);

    first_x := food_x;
    first_y := food_y;
    assert_inside_play_area(food_x, food_y, "initial food");

    wait for 5 * CLK_PERIOD;
    assert food_x = first_x and food_y = first_y
      report "food changed without eat pulse"
      severity failure;

    eat <= '1';
    wait until rising_edge(clk);
    eat <= '0';
    wait until rising_edge(clk);

    second_x := food_x;
    second_y := food_y;
    assert_inside_play_area(food_x, food_y, "food after eat");
    assert second_x /= first_x or second_y /= first_y
      report "food did not move after eat pulse"
      severity failure;

    wait for 5 * CLK_PERIOD;
    assert food_x = second_x and food_y = second_y
      report "food changed after eat pulse was removed"
      severity failure;

    assert false
      report "TB PASS: food_control keeps and refreshes playable food coordinates"
      severity note;
    stop;
  end process;
end architecture;
