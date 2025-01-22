library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;


entity controller is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        go        : in  std_logic;
        size      : in  std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
        done      : in std_logic;
        input_addr_gen_en  : out std_logic; --control signals for addr_generators
        output_addr_gen_en : out std_logic;
        datapath_en        : out std_logic --control signal datapath
    );
end controller;

architecture Behavioral of controller is
    type state_type is (IDLE, RUN, FINISH);
    signal current_state, next_state : state_type;
    signal count                     : unsigned(C_MEM_ADDR_WIDTH downto 0); --counter
begin
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    --next state logic
    process(current_state, go, count, size)
    begin
        input_addr_gen_en  <= '0';
        output_addr_gen_en <= '0';
        datapath_en        <= '0';
        case current_state is
            when IDLE =>
                if go = '1' then
                    next_state <= RUN;
                else
                    next_state <= IDLE;
                end if;
            when RUN =>
                input_addr_gen_en  <= '1'; --enable addr gens and datapath
                output_addr_gen_en <= '1';
                datapath_en        <= '1';
                if count = unsigned(size) then
                    next_state <= FINISH;
                else
                    next_state <= RUN;
                end if;
            when FINISH =>
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    end process;


    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            if current_state = RUN then
                count <= count + 1;
            else
                count <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
