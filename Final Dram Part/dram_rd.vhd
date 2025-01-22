library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity dram_rd is
	port(
		dram_clk     : in  std_logic;
		user_clk     : in  std_logic;
		dram_rst     : in  std_logic;
		user_rst     : in  std_logic;
		go           : in  std_logic;
		start_addr   : in  std_logic_vector(14 downto 0);
		size         : in  std_logic_vector(16 downto 0);
		rd_en        : in  std_logic; 
		dram_ready   : in  std_logic;
		dram_rd_en   : out std_logic;
		dram_rd_addr : out std_logic_vector(14 downto 0);
		dram_rd_data : in  std_logic_vector(31 downto 0);
		dram_rd_valid: in  std_logic;
		valid        : out std_logic;
		data         : out std_logic_vector(15 downto 0);
		done         : out std_logic
	);
end dram_rd;

architecture Behavioral of dram_rd is

	signal rst_fifo  : std_logic;
	signal data_in_r : std_logic_vector(31 downto 0);--necessary?
	signal empty_r   : std_logic;--necessary?
	signal stall     : std_logic;
	signal rcv_r      : std_logic;
    signal size_r       : std_logic_vector(14 downto 0);--temp store size out of converter
    signal start_addr_r : std_logic_vector(14 downto 0);--temp store addr out of converter
	signal delay : std_logic := '0';--not in use
	signal done_r    : std_logic;
begin  
    
    --------- addr_generator --------------------------------
	U_ADDR_GEN: entity work.addr_generator
		port map(
			clk          => dram_clk, 
			rst          => dram_rst,
			go           => rcv_r,
			ready        => dram_ready,
			size         => size_r,--14-0
			start_addr   => start_addr_r,--14-0
			dram_rd_addr => dram_rd_addr,--14-0
			dram_rd_en   => dram_rd_en,
			stall        => stall
		);
	
    --------- handshake ----------------------------------------------
    U_HANDSHAKE : entity work.handshake
        port map (
            clk_src   => user_clk,
            clk_dest  => dram_clk,
            rst       => user_rst,
            go        => go,
            delay_ack => delay,
            rcv       => rcv_r,--assert go in addr gen
            ack       => open
		);

	--------- size converter -----------------------------------------------
	U_SIZE_CONVERTER: entity work.converter
		port map(
			clk      => user_clk,
			rst	     => user_rst,
			go	     => go,
			size_in  => size,--16-0
			addr_in  => start_addr,--14-0
			size_out => size_r,--14-0
			addr_out => start_addr_r--14-0
		);

	---------- counter ------------------------------------------------
    U_COUNTER: entity work.counter
		port map(
			clk  => user_clk,
			rst  => user_rst,
			go   => rd_en,
			size => size,--16_0
			done => done_r
		);
		done <= done_r;

	---------- fifo ---------------------------------------------------
	U_FIFO32: entity work.fifo
		port map(
			clk_src   => user_clk,
            clk_dest  => dram_clk,
			rst       => rst_fifo,
			empty     => empty_r,
			full      => open,
			prog_full => stall,
			rd_en     => rd_en,
			wr_en     => dram_rd_valid,
			data_in   => data_in_r,--31-0
			data_out  => data--15-0
		);
		
		valid    <= not empty_r;
	
		data_in_r <= dram_rd_data;
		rst_fifo <= done_r;

end Behavioral;