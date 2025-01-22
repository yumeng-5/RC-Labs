library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_converter is
end tb_converter;

architecture TB of tb_converter is

    component converter is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            go       : in  std_logic;
            size_in  : in  std_logic_vector(16 downto 0);
            addr_in  : in  std_logic_vector(14 downto 0);
            size_out : out std_logic_vector(14 downto 0);
            addr_out : out std_logic_vector(14 downto 0)
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal go       : std_logic := '0';
    signal size_in  : std_logic_vector(16 downto 0) := (others => '0');
    signal addr_in  : std_logic_vector(14 downto 0) := (others => '0');
    signal size_out : std_logic_vector(14 downto 0);
    signal addr_out : std_logic_vector(14 downto 0);

    constant clk_period : time := 50 ns;
begin
    DUT: converter
        port map(
            clk      => clk,
            rst      => rst,
            go       => go,
            size_in  => size_in,
            addr_in  => addr_in,
            size_out => size_out,
            addr_out => addr_out
        );

    -- Clock Process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;
    -- Sim process
    sim_process: process
    begin
        -- Test Case 1: Large size_in > 15 bits
        go <= '1';
        size_in <= "00000000000111111";
        addr_in <= "000000000000001";
        wait for 1000 ns;

        go <= '0';
        wait for 200 ns;

        -- Test Case 2: Small size_in
        go <= '1';
        size_in <= "00000000000000011";
        addr_in <= "000000000000010";
        wait for 1000 ns;

        go <= '0';
        wait for 200 ns;

        -- Test Case 3: Large size_in
        go <= '1';
        size_in <= "11111111111111111";
        addr_in <= "111111111111111";
        wait for 1000 ns;

        go <= '0';
        wait for 200 ns;

        -- Test Case 4: Small size_in
        go <= '1';
        size_in <= "00000000000010001"; -- 17
        addr_in <= "000000000001000";   -- 8
        wait for 50 ns;

        wait;
    end process;

end TB;
