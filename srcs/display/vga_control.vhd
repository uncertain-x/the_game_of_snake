----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.06.2026 17:26:49
-- Design Name: 
-- Module Name: vga_control - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_control is
--  Port ( );
    Port(
        clk : in std_logic;
        reset : in std_logic;

        h_sync : out std_logic;
        v_sync : out std_logic;
        video_on : out std_logic;
        v_blank : out std_logic;

        pixel_x : out integer range 0 to 639;
        pixel_y : out integer range 0 to 479
    );
end vga_control;

architecture Behavioral of vga_control is
    --specific parameter from datasheet of vga
    constant H_DISPLAY : integer := 640;
    constant H_FRONT_PORCH : integer := 16;
    constant H_BACK_PORCH : integer := 48;
    constant H_PULSE_WIDTH : integer := 96;
    constant H_SYNC_PULSE : integer := 800;

    constant V_DISPLAY : integer := 480;
    constant V_FRONT_PORCH : integer := 10;
    constant V_BACK_PORCH : integer := 29;
    constant V_PULSE_WIDTH : integer := 2;
    constant V_SYNC_PULSE : integer := 521;

    signal H_CNT : integer range 0 to H_SYNC_PULSE - 1 := 0;
    signal V_CNT : integer range 0 to V_SYNC_PULSE - 1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                H_CNT <= 0;
                V_CNT <= 0;
             else
                if  H_CNT = H_SYNC_PULSE - 1 then
                    H_CNT <= 0;
                    if V_CNT = V_SYNC_PULSE - 1 then
                        V_CNT <= 0;
                    else
                        V_CNT <= V_CNT + 1;
                    end if;
                else
                    H_CNT <= H_CNT + 1;
                end if;
            end if;
        end if;
    end process;

    -- generate synchronous signal
    h_sync <= '0' when (H_CNT >= H_DISPLAY + H_FRONT_PORCH) and (H_CNT < H_DISPLAY + H_FRONT_PORCH + H_PULSE_WIDTH) else '1';
    v_sync <= '0' when (V_CNT >= V_DISPLAY + V_FRONT_PORCH) and (V_CNT < V_DISPLAY + V_FRONT_PORCH + V_PULSE_WIDTH) else '1';

    -- output signal condition
    video_on <= '1' when (H_CNT < H_DISPLAY) and (V_CNT < V_DISPLAY) else '0';
    v_blank <= '1' when (V_CNT >= V_DISPLAY) else '0';

    -- output pixel coordinate
    pixel_x <= H_CNT when (H_CNT < H_DISPLAY) else 0;
    pixel_y <= V_CNT when (V_CNT < V_DISPLAY) else 0;


end Behavioral;
