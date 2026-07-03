library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity seven_seg_controller_tb is
end entity;

architecture sim of seven_seg_controller_tb is
  constant CLK_PERIOD : time := 10 ns;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal score : std_logic_vector(9 downto 0) := (others => '0');
  signal seg   : std_logic_vector(6 downto 0);
  signal an    : std_logic_vector(3 downto 0);
  signal dp    : std_logic;

  function digit_pattern(digit : natural) return std_logic_vector is
  begin
    case digit is
      when 0 => return "1000000"; -- gfedcba, active-low
      when 1 => return "1111001";
      when 2 => return "0100100";
      when 3 => return "0110000";
      when 4 => return "0011001";
      when 5 => return "0010010";
      when 6 => return "0000010";
      when 7 => return "1111000";
      when 8 => return "0000000";
      when 9 => return "0010000";
      when others => return "1111111";
    end case;
  end function;

  procedure check_digit(
    constant expected_an    : in std_logic_vector(3 downto 0);
    constant expected_digit : in natural;
    constant tag            : in string
  ) is
  begin
    assert an = expected_an
      report tag & ": wrong anode select"
      severity failure;
    assert seg = digit_pattern(expected_digit)
      report tag & ": wrong segment pattern"
      severity failure;
    assert dp = '1'
      report tag & ": decimal point should stay off"
      severity failure;
  end procedure;
begin
  clk <= not clk after CLK_PERIOD / 2;

  dut : entity work.seven_seg_controller
    generic map (
      SCAN_DIV => 2
    )
    port map (
      clk   => clk,
      reset => reset,
      score => score,
      seg   => seg,
      an    => an,
      dp    => dp
    );

  stim : process
  begin
    wait for 5 * CLK_PERIOD;
    reset <= '0';
    score <= std_logic_vector(to_unsigned(123, score'length));

    wait until rising_edge(clk);
    wait for 1 ns;
    check_digit("1110", 3, "ones digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("1101", 2, "tens digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("1011", 1, "hundreds digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("0111", 0, "thousands digit");

    score <= std_logic_vector(to_unsigned(1000, score'length));
    wait for 1 ns;
    check_digit("0111", 0, "clamped thousands digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("1110", 9, "clamped ones digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("1101", 9, "clamped tens digit");

    wait for 2 * CLK_PERIOD;
    wait for 1 ns;
    check_digit("1011", 9, "clamped hundreds digit");

    assert false
      report "TB PASS: seven_seg_controller displays decimal score and scans digits"
      severity note;
    stop;
  end process;
end architecture;
