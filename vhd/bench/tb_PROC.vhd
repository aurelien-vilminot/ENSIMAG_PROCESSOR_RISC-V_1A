library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_PROC is
        generic (
            mutant     : integer := 0
        );
end entity;


architecture bench of tb_PROC is

    component PROC
        generic (
            FILE_PROG  : string  := "../mem/prog.mem" ;
            mutant     : integer := 0
        );
        port (
            -- Clock/Reset
            clk    : in  std_logic ;
            reset  : in  std_logic ;

            -- IOs
            switch : in  unsigned ( 3 downto 0 ) ;
            push   : in  unsigned ( 2 downto 0 ) ;
            led    : out unsigned ( 3 downto 0 ) ;
            cec    : in std_logic ;
            hpd    : in std_logic
        );
    end component;

    -- Signals
    signal clk    : std_logic := '0' ;
    signal reset  : std_logic ;
    signal switch : unsigned ( 3 downto 0 ) ;
    signal push   : unsigned ( 2 downto 0 ) ;
    signal led    : unsigned ( 3 downto 0 ) ;
    signal hpd    : std_logic := '0';
    signal cec    : std_logic := '0';

begin


    C_PROC_IO : PROC
        port map(
            clk    => clk,
            reset  => reset,
            switch => switch,
            push   => push,
            led    => led,
            hpd    => hpd,
            cec    => cec

        );


    gen_horloge: process
    begin
        clk <= '1';
        wait for 4 ns;
        clk <= '0';
        wait for 4 ns;
    end process;


    tb : process
    begin
        reset <= '1';
        switch <= x"3";
        push <= "010";

        for i in 1 to 6 loop
            wait until rising_edge(clk);
        end loop;

        reset <= '0';
        switch <= x"6";
        push <= "111";

        for i in 0 to 9 loop
            wait until rising_edge(clk);
            switch <= switch + 1 ;
        end loop;

        -- place stimulus here

        wait; -- will wait forever
    end process;


end architecture;
