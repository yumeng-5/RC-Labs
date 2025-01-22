
library ieee;
use ieee.std_logic_1164.all;

entity handshake is
    port (
        clk_src   : in  std_logic;--user_clk
        clk_dest  : in  std_logic;--dram_clk
        rst       : in  std_logic;
        go        : in  std_logic;
        delay_ack : in  std_logic;
        rcv       : out std_logic;
        ack       : out std_logic
        );
end handshake;

architecture BHV of handshake is

    type state_type is (S_READY, S_WAIT_FOR_ACK, S_RESET_ACK);
    type state_type2 is (S_READY, S_SEND_ACK, S_RESET_ACK);
    signal state_src  : state_type;
    signal state_dest : state_type2;

    signal send_src_r : std_logic;
    signal ack_dest_r : std_logic;
    
    --Dual flop1 for source signal
    signal src_df1 : std_logic;
    signal src_df2 : std_logic;
    --Dual flop2 for dest signal
    signal dest_sf1 : std_logic;
    signal dest_sf2 : std_logic;
begin

    -----------------------------------------------------------------------------
    -- State machine in source domain that sends to dest domain and then waits
    -- for an ack

    process (clk_src, rst)
    begin
        if (rst = '1') then
            dest_sf1 <= '0';
            dest_sf2 <= '0';
        elsif (rising_edge(clk_src)) then
            dest_sf1 <= ack_dest_r;
            dest_sf2 <= dest_sf1;
        end if;
    end process;

    process(clk_src, rst)
    begin
        if (rst = '1') then
            state_src  <= S_READY;
            send_src_r <= '0';
            ack        <= '0';
        elsif (rising_edge(clk_src)) then

            ack <= '0';

            case state_src is
                when S_READY =>
                    if (go = '1') then
                        send_src_r <= '1';
                        state_src  <= S_WAIT_FOR_ACK;
                    end if;

                when S_WAIT_FOR_ACK =>
                    if (dest_sf2 = '1') then
                        send_src_r <= '0';
                        state_src  <= S_RESET_ACK;
                    end if;

                when S_RESET_ACK =>
                    if (dest_sf2 = '0') then
                        ack       <= '1';
                        state_src <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- State machine in dest domain that waits for source domain to send signal,
    -- which then gets acknowledged

    process (clk_dest, rst)
    begin
        if (rst = '1') then
            src_df1 <= '0';
            src_df2 <= '0';
        elsif (rising_edge(clk_dest)) then
            src_df1 <= send_src_r;
            src_df2 <= src_df1;
        end if;
    end process;

    process(clk_dest, rst)
    begin
        if (rst = '1') then
            state_dest <= S_READY;
            ack_dest_r <= '0';
            rcv        <= '0';
        elsif (rising_edge(clk_dest)) then

            rcv <= '0';

            case state_dest is
                when S_READY =>
                    -- if source is sending data, assert rcv (received)
                    if (src_df2 = '1') then
                        rcv        <= '1';
                        state_dest <= S_SEND_ACK;
                    end if;

                when S_SEND_ACK =>
                    -- send ack unless it is delayed
                    if (delay_ack = '0') then
                        ack_dest_r <= '1';
                        state_dest <= S_RESET_ACK;
                    end if;

                when S_RESET_ACK =>
                    -- send ack unless it is delayed
                    if (src_df2 = '0') then
                        ack_dest_r <= '0';
                        state_dest <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;

end BHV;

