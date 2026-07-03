library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_controller is
  generic (
    SCAN_DIV : positive := 100000
  );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    score : in  std_logic_vector(9 downto 0);
    seg   : out std_logic_vector(6 downto 0);
    an    : out std_logic_vector(3 downto 0);
    dp    : out std_logic
  );
end entity;

architecture rtl of seven_seg_controller is
  signal scan_cnt   : integer range 0 to SCAN_DIV - 1 := 0;
  signal scan_digit : integer range 0 to 3 := 0;

  signal ones      : integer range 0 to 9 := 0;
  signal tens      : integer range 0 to 9 := 0;
  signal hundreds  : integer range 0 to 9 := 0;
  signal thousands : integer range 0 to 9 := 0;

  function to_segments(digit : integer) return std_logic_vector is
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
begin
  process(score)
    variable value : integer range 0 to 1023;
  begin
    value := to_integer(unsigned(score));
    if value > 999 then
      value := 999;
    end if;

    ones      <= value mod 10;
    tens      <= (value / 10) mod 10;
    hundreds  <= (value / 100) mod 10;
    thousands <= (value / 1000) mod 10;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        scan_cnt   <= 0;
        scan_digit <= 0;
      elsif scan_cnt = SCAN_DIV - 1 then
        scan_cnt <= 0;
        if scan_digit = 3 then
          scan_digit <= 0;
        else
          scan_digit <= scan_digit + 1;
        end if;
      else
        scan_cnt <= scan_cnt + 1;
      end if;
    end if;
  end process;

  process(scan_digit, ones, tens, hundreds, thousands)
  begin
    case scan_digit is
      when 0 =>
        an  <= "1110";
        seg <= to_segments(ones);
      when 1 =>
        an  <= "1101";
        seg <= to_segments(tens);
      when 2 =>
        an  <= "1011";
        seg <= to_segments(hundreds);
      when others =>
        an  <= "0111";
        seg <= to_segments(thousands);
    end case;
  end process;

  dp <= '1';
end architecture;
