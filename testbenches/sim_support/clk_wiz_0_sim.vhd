-- Simulation-only replacement for the Xilinx clk_wiz_0 IP.
-- Divides clk_in1 by 4 and asserts locked. Keep this file OUT of the Vivado
-- project (the real IP is used there); it exists so GHDL/nvc can elaborate
-- display_control.
library ieee;
use ieee.std_logic_1164.all;

entity clk_wiz_0 is
  port (
    clk_out1_25 : out std_logic;
    reset       : in  std_logic;
    locked      : out std_logic;
    clk_in1     : in  std_logic
  );
end entity;

architecture sim of clk_wiz_0 is
  signal div : integer range 0 to 3 := 0;
  signal q   : std_logic := '0';
begin
  process(clk_in1)
  begin
    if rising_edge(clk_in1) then
      if reset = '1' then
        div <= 0;
        q   <= '0';
      elsif div = 1 then
        div <= 0;
        q   <= not q;
      else
        div <= div + 1;
      end if;
    end if;
  end process;

  clk_out1_25 <= q;
  locked      <= not reset;
end architecture;
