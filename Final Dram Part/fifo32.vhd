library ieee;
use ieee.std_logic_1164.all;

entity fifo is
    port (
        clk_src  : in  std_logic;--clk_user
        clk_dest : in  std_logic;--clk_dram
        rst      : in  std_logic;
        empty    : out std_logic;
        full     : out std_logic;
        prog_full: out std_logic;
        rd_en    : in  std_logic;
        wr_en    : in  std_logic;
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(15 downto 0));
end fifo;

architecture STR of fifo is

    COMPONENT fifo_generator_0
        PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
        );
    END COMPONENT;

begin  -- STR

    U_FIFO : fifo_generator_0
        PORT MAP (
            rst => rst,
            wr_clk => clk_src,
            rd_clk => clk_dest,
            din => data_in,
            wr_en => wr_en,
            rd_en => rd_en,
            dout => data_out,
            full => full,
            empty => empty,
            prog_full => prog_full,
            wr_rst_busy => open,
            rd_rst_busy => open
        );

end STR;
