library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity datapath is
  port (
    clk      : in std_logic;
    rst      : in std_logic;
    en       : in std_logic;
    data_in  : in std_logic_vector(31 downto 0); --slice into 4 input registers
    data_out : out std_logic_vector(16 downto 0)
  );
end datapath;

architecture Behavioral of datapath is
  -- registers for pipeline
  signal a_reg, b_reg, c_reg, d_reg : std_logic_vector(7 downto 0); --input slices 
  signal mult1_reg, mult2_reg       : std_logic_vector(15 downto 0);
  signal add_reg                    : std_logic_vector(16 downto 0);
begin
  process (clk, rst)
  begin
    if rst = '1' then
      -- reset registers in pipeline
      a_reg     <= (others => '0');
      b_reg     <= (others => '0');
      c_reg     <= (others => '0');
      d_reg     <= (others => '0');
      mult1_reg <= (others => '0');
      mult2_reg <= (others => '0');
      add_reg   <= (others => '0');
    elsif rising_edge(clk) then
      if en = '1' then
        --load inputs
        a_reg <= data_in(31 downto 24);
        b_reg <= data_in(23 downto 16);
        c_reg <= data_in(15 downto 8);
        d_reg <= data_in(7 downto 0);
        -- handle multiplication
        mult1_reg <= std_logic_vector(unsigned(a_reg) * unsigned(b_reg));
        mult2_reg <= std_logic_vector(unsigned(c_reg) * unsigned(d_reg));
        -- handle addition
        add_reg <= std_logic_vector(unsigned('0' & mult1_reg) + unsigned('0' & mult2_reg));
      end if;
    end if;
  end process;
  data_out <= add_reg;
end Behavioral;
