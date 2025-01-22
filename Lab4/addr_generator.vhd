library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity addr_generator is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        en        : in  std_logic;
        size      : in  std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
        addr_out  : out std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
        valid_out : out std_logic;
        done      : out std_logic
    );
end addr_generator;

architecture Behavioral of addr_generator is
    signal count : unsigned(C_MEM_ADDR_WIDTH downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
            valid_out <= '0';
            done <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                if count < unsigned(size) then
                    valid_out <= '1';
                    count <= count + 1;
                else
                    valid_out <= '0';
                    done <= '1';
                end if;
            -- else
            --     count <= (others => '0');
            --     valid_out <= '0';
            --     done <= '0';
            end if;
        end if;
    end process;

    addr_out <= std_logic_vector(count(C_MEM_ADDR_WIDTH-1 downto 0));

end Behavioral;