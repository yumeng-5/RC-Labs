library ieee;
use ieee.std_logic_1164.all;

entity tb_handshake is
end tb_handshake;

architecture TB of tb_handshake is

    component handshake is
        port (
            clk_src   : in  std_logic;
            clk_dest  : in  std_logic;
            rst       : in  std_logic;
            go        : in  std_logic;
            delay_ack : in  std_logic;
            rcv       : out std_logic;
            ack       : out std_logic
        );
    end component;

    signal clk_src   : std_logic := '0';
    signal clk_dest  : std_logic := '0';
    signal rst       : std_logic := '0';
    signal go        : std_logic := '0';
    signal delay_ack : std_logic := '0';
    signal rcv       : std_logic;
    signal ack       : std_logic;

    constant clk_src_period  : time := 10 ns;
    constant clk_dest_period : time := 15 ns;

begin
    DUT: handshake
        port map(
            clk_src   => clk_src,
            clk_dest  => clk_dest,
            rst       => rst,
            go        => go,
            delay_ack => delay_ack,
            rcv       => rcv,
            ack       => ack
        );

    clk_src_process: process
    begin
        while true loop
            clk_src <= '0';
            wait for clk_src_period / 2;
            clk_src <= '1';
            wait for clk_src_period / 2;
        end loop;
    end process;

    clk_dest_process: process
    begin
        while true loop
            clk_dest <= '0';
            wait for clk_dest_period / 2;
            clk_dest <= '1';
            wait for clk_dest_period / 2;
        end loop;
    end process;

    sim_process: process
    begin
        rst <= '1';
        wait for 20 ns;

        rst <= '0';
        wait for 20 ns;

        -- Test Case 1
        go <= '1';
        delay_ack <= '0';
        wait for 40 ns;

        go <= '0';
        wait for 100 ns;

        -- Test Case 2
        go <= '1';
        delay_ack <= '0';
        wait for 40 ns;

        -- Test Case 3
        go <= '1';
        wait for 20 ns;
        go <= '0';
        wait for 80 ns;

        go <= '1';
        wait for 30 ns;
        go <= '0';
        wait for 100 ns;

        wait;
    end process;

end TB;
