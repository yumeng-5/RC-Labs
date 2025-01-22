library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_counter is
end tb_counter;

architecture TB of tb_counter is

    component counter is
        port(
            clk  : in std_logic;
            rst  : in std_logic;
            go   : in std_logic;
            size : in std_logic_vector(16 downto 0);
            done : out std_logic
        );
    end component;

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '0';
    signal go   : std_logic := '0';
    signal size : std_logic_vector(16 downto 0) := (others => '0');
    signal done : std_logic;

    constant clk_period : time := 50 ns;

begin
    DUT: counter
        port map(
            clk  => clk,
            rst  => rst,
            go   => go,
            size => size,
            done => done
        );


    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    sim_process: process
    begin

        rst <= '1';
        go <= '0';
        size <= (others => '0');
        wait for 200 ns;

        rst <= '0';
        wait for 20 ns;

        -- Test Case 1: Small size
        go <= '1';
        size <= "00000000000000111";
        wait for 500 ns;

        go <= '0';
        wait for 20 ns;

        -- Test Case 2: Larger size
        go <= '1';
        size <= "00000000000011111";
        wait for 2000 ns;

        go <= '0';
        wait for 20 ns;


        wait;
    end process;

end TB;
