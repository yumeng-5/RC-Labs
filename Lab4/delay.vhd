library ieee;
use ieee.std_logic_1164.all;

entity delay is
    generic (
        CYCLES      : natural;             -- Number of cycles to delay
        WIDTH       : positive;            -- Width of the input signal
        RESET_VALUE : std_logic_vector := ""  -- Optional reset value
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic := '0';
        en     : in  std_logic := '1';
        input  : in  std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity delay;

architecture Behavioral of delay is
begin

    -- Handle the special case of delaying by 0 cycles.
    U_CYCLES_EQ_0 : if CYCLES = 0 generate
        output <= input;
    end generate U_CYCLES_EQ_0;

    -- Handle delays greater than 0 cycles.
    U_CYCLES_GT_0 : if CYCLES > 0 generate

        type reg_array_t is array (0 to CYCLES-1) of std_logic_vector(WIDTH-1 downto 0);
        signal regs : reg_array_t;

    begin
        process(clk, rst)
        begin
            if rst = '1' then
                if (RESET_VALUE /= "") then
                    for i in 0 to CYCLES-1 loop
                        regs(i) <= RESET_VALUE;
                    end loop;
                else
                    for i in 0 to CYCLES-1 loop
                        regs(i) <= (others => '0');
                    end loop;
                end if;
            elsif rising_edge(clk) then
                if en = '1' then
                    regs(0) <= input;
                    if (CYCLES > 1) then
                        for i in 0 to CYCLES-2 loop
                            regs(i+1) <= regs(i);
                        end loop;
                    end if;
                end if;
            end if;
        end process;

        output <= regs(CYCLES-1);

    end generate U_CYCLES_GT_0;

end architecture Behavioral;
