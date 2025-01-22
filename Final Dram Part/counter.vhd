library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	port(
		clk  : in std_logic;
		rst  : in std_logic;
		go   : in std_logic;
		size : in std_logic_vector(16 downto 0);
		done : out std_logic
	);  
end counter;

architecture BHV of counter is

    signal size_r : unsigned(16 downto 0) := (others => '0');
    signal done_r : std_logic := '0';
	
begin
    
    process(clk, rst)
    begin
        if(rst = '1') then
			done_r <= '0';
			size_r <= (others => '0');
        elsif(rising_edge(clk)) then
            if(go = '1') then
                if(size_r < unsigned(size)) then
                    done_r <= '0';
					size_r <= size_r + 1;
                else
                    done_r <= '1';
                end if;
            else
                done_r <= '0';
            end if;
        end if;
    end process;
    done <= done_r;
	
end BHV;

