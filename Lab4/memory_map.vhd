-- Greg Stitt
-- University of Florida

-- Entity: memory_map
-- This entity establishes connections with user-defined addresses and
-- internal FPGA components (e.g. registers and blockRAMs).
--
-- Note: Make sure to add any new addresses to user_pkg. Also, in your C code,
-- make sure to use the same constants.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity memory_map is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;
        wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        rd_en   : in  std_logic;
        rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- app-specific signals
        go              : out std_logic;
        size            : out std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
        done            : in  std_logic;
        mem_in_wr_data  : out std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
        mem_in_wr_addr  : out std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
        mem_in_wr_en    : out std_logic;
        mem_out_rd_data : in  std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
        mem_out_rd_addr : out std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0)
        );
end memory_map;

architecture BHV of memory_map is

    signal go_r        : std_logic;
    signal size_r      : std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
    signal rd_data_r   : std_logic_vector(C_MMAP_DATA_WIDTH-1 downto 0);
    signal rd_data_sel : std_logic;

    constant C_RD_DATA_SEL_REG     : std_logic := '0';
    constant C_RD_DATA_SEL_MEM_OUT : std_logic := '1';
begin

    mem_in_wr_data <= wr_data(mem_in_wr_data'range);
    mem_in_wr_addr <= wr_addr(mem_in_wr_addr'range);
    mem_in_wr_en   <= '1' when wr_en = '1' and unsigned(wr_addr) >= unsigned(C_MEM_START_ADDR) and unsigned(wr_addr) <= unsigned(C_MEM_END_ADDR) else '0';

    mem_out_rd_addr <= rd_addr(mem_out_rd_addr'range);

    process(clk, rst)
    begin
        if (rst = '1') then
            go_r        <= '0';
            size_r      <= (others => '0');
            rd_data_sel <= '0';
            rd_data_r   <= (others => '0');

        elsif (rising_edge(clk)) then

            go_r <= '0';

            if (wr_en = '1') then

                case wr_addr is
                    when C_GO_ADDR =>
                        go_r <= wr_data(0);
                    when C_SIZE_ADDR =>
                        size_r <= wr_data(size_r'range);
                    when others => null;
                end case;
            end if;

            if (rd_en = '1') then

                rd_data_sel <= C_RD_DATA_SEL_REG;
                rd_data_r   <= (others => '0');

                -- check if rd_addr corresponds to memory or registers
                if (unsigned(rd_addr) > unsigned(C_MEM_END_ADDR)) then
                    rd_data_sel <= C_RD_DATA_SEL_REG;
                else
                    rd_data_sel <= C_RD_DATA_SEL_MEM_OUT;
                end if;

                -- select the appropriate register for a read
                case rd_addr is
                    when C_GO_ADDR =>
                        rd_data_r <= std_logic_vector(to_unsigned(0, C_MMAP_DATA_WIDTH-1)) & go_r;
                    when C_SIZE_ADDR =>
                        rd_data_r               <= (others => '0');
                        rd_data_r(size_r'range) <= size_r;
                    when C_DONE_ADDR =>
                        rd_data_r <= std_logic_vector(to_unsigned(0, C_MMAP_DATA_WIDTH-1)) & done;
                    when others => null;
                end case;
            end if;

        end if;
    end process;

    go   <= go_r;
    size <= size_r;

    -- mux that defines dout based on where the read data come from
    process(rd_data_sel, rd_data_r, mem_out_rd_data)
    begin
        rd_data <= (others => '0');

        case rd_data_sel is
            when C_RD_DATA_SEL_MEM_OUT =>
                rd_data(mem_out_rd_data'range) <= mem_out_rd_data;
            when C_RD_DATA_SEL_REG =>
                rd_data <= rd_data_r;
            when others => null;
        end case;
    end process;

end BHV;
