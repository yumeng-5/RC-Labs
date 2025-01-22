library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_generator is
    port (
        clk       : in std_logic; -- dram_clk
        rst       : in std_logic;
        go        : in std_logic; -- from rcv_r
        ready     : in std_logic; -- from dram_ready
        size      : in std_logic_vector(14 downto 0); -- from size_r
        start_addr: in std_logic_vector(14 downto 0); -- from start_addr_r
        dram_rd_addr  : out std_logic_vector(14 downto 0); -- to dram_rd_addr
        dram_rd_en: out std_logic; -- to dram_rd_en
        stall     : in std_logic
    );
end addr_generator;

architecture Behavioral of addr_generator is
    type state_t is (START, COUNTING, DRAM_EN);
    signal state_r, next_state : state_t;
    signal count : unsigned(14 downto 0);
    signal next_count : unsigned(14 downto 0);
    signal dram_rd_addr_r : std_logic_vector(14 downto 0) := (others => '0'); -- register for output addr

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            state_r <= START;
            count <= (others => '0');
            dram_rd_addr_r <= (others => '0');
        elsif (rising_edge(clk)) then
            state_r <= next_state;
            count <= next_count;

            if state_r = DRAM_EN then
                dram_rd_addr_r <= std_logic_vector(count);
            end if;
        end if;
    end process;


    process(state_r, go, count, ready, stall, start_addr, size)
    begin

        next_state <= state_r;
        next_count <= count;
        dram_rd_en <= '0';

        case state_r is
            when START =>
                if (go = '1') then
                    next_count <= unsigned(start_addr);
                    next_state <= COUNTING;
                end if;

            when COUNTING =>
                if (count < unsigned(size)) then
                    next_count <= count + 1;
                else
                    next_state <= DRAM_EN;
                end if;

            when DRAM_EN =>
                if (ready = '1') and (stall /= '1') then
                    dram_rd_en <= '1';
                    next_state <= START;
                end if;

            when others =>
                next_state <= START;
        end case;
    end process;

    dram_rd_addr <= dram_rd_addr_r;

end Behavioral;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity addr_generator is
--     port (
--         clk       : in std_logic; -- dram_clk
--         rst       : in std_logic;
--         go        : in std_logic; -- from rcv_r
--         ready     : in std_logic; -- from dram_ready
--         size      : in std_logic_vector(14 downto 0); -- from size_r
--         start_addr: in std_logic_vector(14 downto 0); -- from start_addr_r
--         dram_rd_addr  : out std_logic_vector(14 downto 0); -- to dram_rd_addr
--         dram_rd_en: out std_logic; -- to dram_rd_en
--         stall     : in std_logic
--     );
-- end addr_generator;

-- architecture Behavioral of addr_generator is
--     type state_t is (START, COUNTING, DRAM_EN);
--     signal state_r, next_state : state_t;
--     signal count : unsigned(14 downto 0);
--     signal next_count : unsigned(14 downto 0);
-- begin

--     process(clk, rst)
--     begin
--         if (rst = '1') then
--             state_r <= START;
--             count <= (others => '0');
--         elsif (rising_edge(clk)) then
--             state_r <= next_state;
--             count <= next_count;
--         end if;
--     end process;

--     process(state_r, go, count, ready, stall, start_addr, size)
--     begin
--         -- Default Assignments
--         next_state <= state_r;
--         next_count <= count;
--         dram_rd_en <= '0';
--         dram_rd_addr <= std_logic_vector(count);

--         case state_r is
--             when START =>
--                 if (go = '1') then
--                     next_count <= unsigned(start_addr);
--                     next_state <= COUNTING;
--                 end if;

--             when COUNTING =>
--                 if (count < unsigned(size)) then
--                     next_count <= count + 1;
--                 else
--                     next_state <= DRAM_EN;
--                 end if;

--             when DRAM_EN =>
--                 if (ready = '1') and (stall /= '1') then
--                     dram_rd_en <= '1';
--                     next_state <= START;
--                 end if;

--             when others =>
--                 next_state <= START;
--         end case;
--     end process;

-- end Behavioral;

