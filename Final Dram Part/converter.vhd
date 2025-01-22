--size converting and storing value before goes into addr gen
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity converter is
	port(
		clk      : in  std_logic;--user_clk
		rst      : in  std_logic;
		go       : in  std_logic;--from go
		size_in  : in  std_logic_vector(16 downto 0);
		addr_in  : in  std_logic_vector(14 downto 0);
		size_out : out std_logic_vector(14 downto 0);
		addr_out : out std_logic_vector(14 downto 0)
	);
end converter;

architecture BHV of converter is
begin
	process(clk, rst)
	begin
		if(rst = '1') then
			size_out <= (others => '0');
			addr_out <= (others => '0');
		elsif (rising_edge(clk)) then
			if (go = '1') then
				size_out <= std_logic_vector(resize(unsigned(size_in), 15));
				addr_out <= addr_in;
			end if;
		end if;
	end process;
end BHV;


