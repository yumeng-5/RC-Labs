-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity user_app is
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- memory-map interface
    mmap_wr_en   : in std_logic;
    mmap_wr_addr : in std_logic_vector(MMAP_ADDR_RANGE);
    mmap_wr_data : in std_logic_vector(MMAP_DATA_RANGE);
    mmap_rd_en   : in std_logic;
    mmap_rd_addr : in std_logic_vector(MMAP_ADDR_RANGE);
    mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE)
  );
end user_app;

architecture default of user_app is

  signal go   : std_logic;
  signal size : std_logic_vector(C_MEM_ADDR_WIDTH downto 0);
  signal done : std_logic;

  signal mem_in_wr_data       : std_logic_vector(C_MEM_IN_WIDTH - 1 downto 0);
  signal mem_in_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
  signal mem_in_rd_data       : std_logic_vector(C_MEM_IN_WIDTH - 1 downto 0);
  signal mem_in_rd_addr       : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
  signal mem_in_wr_en         : std_logic;
  signal mem_in_rd_addr_valid : std_logic;

  signal mem_out_wr_data       : std_logic_vector(C_MEM_OUT_WIDTH - 1 downto 0);
  signal mem_out_wr_addr       : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
  signal mem_out_rd_data       : std_logic_vector(C_MEM_OUT_WIDTH - 1 downto 0);
  signal mem_out_rd_addr       : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
  signal mem_out_wr_en         : std_logic;
  signal mem_out_wr_data_valid : std_logic;
  signal mem_out_done          : std_logic;

  signal input_addr_gen_en  : std_logic; --control signals 
  signal output_addr_gen_en : std_logic;
  signal datapath_en        : std_logic;

  signal datapath_out          : std_logic_vector(16 downto 0); --pipeline output 
  signal datapath_valid_vector : std_logic_vector(0 downto 0); --casting 
  signal datapath_en_vector    : std_logic_vector(0 downto 0); --casting 
  signal datapath_valid        : std_logic; --for delay logic
  signal en_signal : std_logic := '1'; --casting to std_logic, Vivado errors when hardcoding '1'
begin

  ------------------------------------------------------------------------------
  U_MMAP : entity work.memory_map
    port map
    (
      clk     => clk,
      rst     => rst,
      wr_en   => mmap_wr_en,
      wr_addr => mmap_wr_addr,
      wr_data => mmap_wr_data,
      rd_en   => mmap_rd_en,
      rd_addr => mmap_rd_addr,
      rd_data => mmap_rd_data,

      -- TODO: connect to appropriate logic
      go   => go,
      size => size,
      done => done,

      -- already connected to block RAMs
      -- the memory map functionality writes to the input ram
      -- and reads from the output ram
      mem_in_wr_data  => mem_in_wr_data,
      mem_in_wr_addr  => mem_in_wr_addr,
      mem_in_wr_en    => mem_in_wr_en,
      mem_out_rd_data => mem_out_rd_data,
      mem_out_rd_addr => mem_out_rd_addr
    );
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- input memory
  -- written to by memory map
  -- read from by controller+datapath
  --(to pipeline)
  -- 32 bits wide
  U_MEM_IN : entity work.ram(SYNC_READ)
    generic map(
      num_words  => 2 ** C_MEM_ADDR_WIDTH,
      word_width => C_MEM_IN_WIDTH,
      addr_width => C_MEM_ADDR_WIDTH)
    port map
    (
      clk   => clk,
      wen   => mem_in_wr_en,
      waddr => mem_in_wr_addr,
      wdata => mem_in_wr_data,
      raddr => mem_in_rd_addr, -- TODO: connect to input address generator
      rdata => mem_in_rd_data); -- TODO: connect to pipeline input
  --slice mem_in_rd_data into 4 different 8 bit chunks 
  --which become the inputs to the pipeline
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- output memory
  -- written to by controller+datapath
  -- read from by memory map
  --(from pipeline)
  -- 17 bits wide
  U_MEM_OUT : entity work.ram(SYNC_READ)
    generic map(
      num_words  => 2 ** C_MEM_ADDR_WIDTH,
      word_width => C_MEM_OUT_WIDTH,
      addr_width => C_MEM_ADDR_WIDTH)
    port map
    (
      clk   => clk,
      wen   => mem_out_wr_en, --either from output add gen or valid out signal
      waddr => mem_out_wr_addr, -- TODO: connect to output address generator
      wdata => mem_out_wr_data, -- TODO: connect to pipeline output
      raddr => mem_out_rd_addr,
      rdata => mem_out_rd_data);
  ------------------------------------------------------------------------------
  -- TODO: instatiate controller datapath/pipeline, address generators, 
  -- and any other necessary logic
  ----------------------------------------------------------------------------------
  -- controller instantiation
  ----------------------------------------------------------------------------------
  U_CONTROLLER : entity work.controller
    port map
    (
      clk                => clk,
      rst                => rst,
      go                 => go,
      size               => size,
      done               => done,
      input_addr_gen_en  => input_addr_gen_en,
      output_addr_gen_en => output_addr_gen_en,
      datapath_en        => datapath_en
    );
  ----------------------------------------------------------------------------------
  -- datapath
  ----------------------------------------------------------------------------------
  U_DATAPATH : entity work.datapath
    port map
    (
      clk      => clk,
      rst      => rst,
      --en       => datapath_en,
      en       => en_signal,
      data_in  => mem_in_rd_data,
      data_out => datapath_out

    );
  mem_out_wr_data       <= datapath_out; --connection to output RAM
  -- Datapath Enable Signal
  datapath_en_vector(0) <= datapath_en; --enable 
  --datapath_en_vector(0) <= en_signal;
  ----------------------------------------------------------------------------------
  --input address generator 
  ----------------------------------------------------------------------------------
  -- Input Address Generator Instantiation
  U_INPUT_ADDR_GEN : entity work.addr_generator
    port map
    (
      clk      => clk,
      rst      => rst,
      en       => en_signal, --hardcode enable high
      size     => size,
      addr_out => mem_in_rd_addr,
      valid_out => open, --meant to indicate when input ram is valid
      done => open ---------potential issue for timing out board, come back to this
    );
  ----------------------------------------------------------------------------------
  --delay 
  ----------------------------------------------------------------------------------
  U_VALID_DELAY : entity work.delay
    generic map(
      CYCLES => 3, -- 3 cycles between dp and output address gen for pipeline latency
      WIDTH  => 1
    )
    port map
    (
      clk    => clk,
      rst    => rst,
      en     => en_signal, -- always enabled
      input  => datapath_en_vector,
      output => datapath_valid_vector
    );

  datapath_valid <= datapath_valid_vector(0);
  mem_out_wr_en <= datapath_valid;
  ----------------------------------------------------------------------------------
  --output address generator 
  ----------------------------------------------------------------------------------

  U_OUTPUT_ADDR_GEN : entity work.addr_generator
    port map
    (
      clk       => clk,
      rst       => rst,
      en        => datapath_valid, --enable when dp_output is valid
      size      => size,
      addr_out  => mem_out_wr_addr,
      valid_out => mem_out_wr_data_valid,
      done      => mem_out_done
    );

  ---------------------------------------------------------------------------------

  done <= mem_out_done; --update done signal from output addr gen
  --mem_out_wr_en <= datapath_valid and mem_out_wr_data_valid;

end default;
