----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.06.2026 13:53:16
-- Design Name: 
-- Module Name: display_control - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library work;
use work.snake_body.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_control is
--  Port ( );
    Port (
        clk : in std_logic;
        reset : in std_logic;
        
        -- snake
        snake_x : in snake_x_array;
        snake_y : in snake_y_array;
        snake_len : in integer range 1 to MAX_SNAKE_LENGTH;
        
        -- food
        food_x : in std_logic_vector(4 downto 0);
        food_y : in std_logic_vector(3 downto 0);
        
        
        -- VGA physical interface
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        VGA_H_SYNC : out std_logic;
        VGA_V_SYNC : out std_logic
    );
end display_control;

architecture Behavioral of display_control is

    --add the vga component to verify whether it works.
    component vga_control is
        Port (
            clk : in std_logic;
            reset : in std_logic;
            h_sync : out std_logic;
            v_sync : out std_logic;
            video_on : out std_logic;
            v_blank : out std_logic;
            pixel_x : out integer range 0 to 639;
            pixel_y : out integer range 0 to 479
        );
    end component;
    
    --add the precise clock from wiz
    component clk_wiz_0 is
        Port (
            clk_out1_25 : out std_logic;
            reset : in std_logic;
            locked : out std_logic;
            clk_in1 : in std_logic
        );
    end component;
    
    --the total size of vga(640 x 480) divides into 20 x 15 grids,
    --which each grid has 32 x 32 pixels.
    constant grid_width : integer := 20;
    constant grid_height : integer := 15;
    constant single_grid_size : integer := 32;
    
    -- color definitions
    -- the color of wall sets gray
    -- the color of background sets black
    -- the color of snake head sets yellow
    -- the color of snake sets green
    -- the color of food sets red
    constant wall_color : std_logic_vector(11 downto 0) := x"888";
    constant background_color : std_logic_vector(11 downto 0) := x"000";
    constant snake_head_color : std_logic_vector(11 downto 0) := x"ff0";
    constant snake_color : std_logic_vector(11 downto 0) := x"0f0";
    constant food_color : std_logic_vector(11 downto 0) := x"f00";
    
    --connect with VGA
    -- clk 25MHz for VGA display 25 x 640 x 480 = 60 Hz
    signal vga_clk : std_logic := '0';
    signal locked_sig : std_logic := '0';
    signal vga_reset : std_logic := '0';
    --signal clk_div_cnt : unsigned(1 downto 0) := "00";
    --signal clk_div : std_logic := '0';
    -- enable the output
    signal w_video_on : std_logic;
    signal w_v_blank : std_logic;
    -- pixel coordinate. Should it be start from 640 x 480 or 20 x 15?
    signal w_pixel_x : integer range 0 to 639;
    signal w_pixel_y : integer range 0 to 479;
    -- grid coordinate.
    --signal grid_x : integer range 0 to 19;
    --signal grid_y : integer range 0 to 14;
    
    -- adapting to the read delay
    signal video_on_delay : std_logic := '0';
    -- prepare for next RGB display to avoid glitches(unstable noise)
    signal next_rgb : std_logic_vector(11 downto 0) := (others => '0');

begin
    
    -- clock from precise clock_wiz
    clk_wiz : clk_wiz_0
        Port map (
            clk_out1_25 => vga_clk,
            reset => reset,
            locked => locked_sig,
            clk_in1 => clk
        );

    vga_reset <= reset or (not locked_sig);
    
    -- VGA timing
    vga_ctrl_timing : vga_control
        Port map (
            clk => vga_clk,
            reset => vga_reset,
            h_sync => vga_h_sync,
            v_sync => vga_v_sync,
            video_on => w_video_on,
            v_blank => w_v_blank,
            pixel_x => w_pixel_x,
            pixel_y => w_pixel_y  
        );
        
        -- drawing logic
        process(vga_clk)
            -- variables for snake and food
            variable snake_head_x, snake_head_y : integer;
            variable snake_body_x, snake_body_y : integer;
            variable grid_x, grid_y : integer;

        begin
            if rising_edge(vga_clk) then
                video_on_delay <= w_video_on;
                
                grid_x := w_pixel_x /single_grid_size;
                grid_y := w_pixel_y / single_grid_size;
                
                -- display the wall
                if (grid_x = 0) or (grid_x = 19) or (grid_y = 0) or (grid_y = 14) then
                    next_rgb <= wall_color;
                -- display the inside wall, game area
                -- scan the coordinate and display the snake and food
                elsif (grid_x = to_integer(unsigned(food_x))) and (grid_y = to_integer(unsigned(food_y))) then
                    next_rgb <= food_color;
                else
                    next_rgb <= background_color;
                    
                    for i in snake_x'range loop
                        if i >= snake_len then
                            exit;
                        end if;

                        if (grid_x = snake_x(i)) and (grid_y = snake_y(i)) then
                            -- the snake head and body
                            if i = 0 then
                                next_rgb <= snake_head_color;
                            else
                                next_rgb <= snake_color;
                            end if;
                            exit;
                        end if;
                    end loop;
                end if;
            end if;
        end process;

        -- vga output mapping
        VGA_R <= next_rgb(11 downto 8) when video_on_delay = '1' else "0000";
        VGA_G <= next_rgb(7 downto 4) when video_on_delay = '1' else "0000";
        VGA_B <= next_rgb(3 downto 0) when video_on_delay = '1' else "0000";
 
end Behavioral;
