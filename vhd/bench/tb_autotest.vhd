library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

library work;
use work.PKG.all;
use work.txt_util.all;


entity tb_autotest is
    generic (
        autotest : string  := "test_default";
        mutant   : integer := 0
    );
end entity;


architecture behavior of tb_autotest is

    -- Memory content
    constant mem_file : string := autotest & ".mem" ;

    -- Signals: Memory bus
    signal mem_addr    : waddr ;
    signal mem_d_size  : RF_SIZE_select ;
    signal mem_datain  : w32 ;
    signal mem_dataout : w32 ;
    signal mem_we      : std_logic ;
    signal mem_ce      : std_logic ;

    -- Signals: Clock, Reset
    signal clk      : std_logic := '0' ;
    signal rst      : std_logic ;

    -- Signals: IRQ Interface
    signal irq      : std_logic ;
    signal irq_push : std_logic ;
    signal push     : std_logic ;
    signal uart     : std_logic ;
    signal meip     : std_logic ;
    signal mtip     : std_logic ;
    signal mie      : w32 ;
    signal mip      : w32 ;
    signal mcause   : w32 ;

    -- Signals: BUS Interface
    constant BUS_N_SLAVE : integer := 3;

    signal bus_ce, bus_we : unsigned ( 0 to BUS_N_SLAVE-1 ) ;
    signal bus_datai      : w32_vec  ( 0 to BUS_N_SLAVE-1 ) ;

    -- Signals: Debug bus
    signal pout_value : w32 ;
    signal pout_valid : boolean ;

    -- Simulation parameter
    signal max_cycle : integer := 500 ;
    signal gen_irq   : boolean := false ;

begin

    -- Generate clock & clock count
    process
        variable c : integer := 0;
        variable ligne_texte : line ;
        file file_res : text ;
    begin
        -- Clock
        clk <= '1' ;
        wait for 5 ns ;
        clk <= '0' ;
        wait for 5 ns ;

        -- Clock count
        c := c+1 ;
        if (c = max_cycle) then
            file_open(file_res, autotest & ".res", write_mode) ;
            write(ligne_texte, string'("TIMEOUT"));
            writeline(file_res, ligne_texte);
            file_close(file_res);
            report "Timeout : " & str(c) & " cycles" severity failure ;
        end if;
    end process;


    -- Setup simulation (max cycle and IRQ?)
    tb_setup : process
        file file_setup : text ;
        variable ligne_texte : line ;
        variable setup_ok, gi : boolean := false ;
        variable var_max_cycle : integer ;
    begin
        rst <= '1' ;

        if not setup_ok then
            file_open(file_setup, autotest & ".setup", read_mode) ;
            if not endfile(file_setup) then
                -- Read max cycle
                readline(file_setup, ligne_texte) ;
                read(ligne_texte, var_max_cycle) ;
                max_cycle <= var_max_cycle ;
                -- Read IRQ enable ?
                readline(file_setup, ligne_texte) ;
                read(ligne_texte, gi)  ;
                gen_irq <= gi ;
            end if ;
            -- Setup finish
            setup_ok := true ;
            file_close(file_setup) ;
        end if;

        wait until rising_edge(clk) ;
        rst <= '0' ; -- Start simulation

        wait; -- will wait forever
    end process tb_setup;


    tb_pout : process
        file file_pout : text ;
        file file_pout_test : text ;
        file file_res  : text ;
        variable ligne_texte : line ;
        variable myline : line ;
        variable ligne_texte_test : line ;
        variable pout_expected : std_logic_vector(31 downto 0) ;
        variable ok : boolean;
        variable empty : boolean;
        variable repeat_ok, pout_prev_valid, test : boolean;
        -- The read function seems not to eat spaces, unlike expected
        variable repeat : string(1 to 2);
        variable pout, pout_prev :  w32;
    begin
        wait until rising_edge(clk) and rst='0';
        empty := true;
        ok := true;
        pout_prev_valid := false; -- no previous value

        file_open(file_pout, autotest & ".out", read_mode) ;
        file_open(file_pout_test, autotest & ".test", write_mode) ;
        while ok and not endfile(file_pout) loop
            empty := false; -- to make sure we are really doing something
            readline(file_pout, ligne_texte);
            hread(ligne_texte, pout_expected);
            repeat_ok := false;
            read(ligne_texte, repeat, repeat_ok);
            write(myline, repeat);
            writeline(output, myline);
            if repeat_ok then
                repeat_ok := (repeat(2) = 'x');
                if repeat_ok then
                     report "repeat * " & hstr(pout_expected) severity note;
                else
                     report "repeat char '" & repeat & "' unknown for value " & hstr(pout_expected) severity warning;
                end if;
            end if;
            test := true;

            while test loop
                wait until rising_edge(clk) and pout_valid;
                pout := pout_value;
                
                if w32(pout_expected) = pout then
                    -- Si c'est la valeur attendue
                    -- Ok next value
                    test := false; -- finish without error
                    pout_prev := pout;
                    pout_prev_valid := repeat_ok;
                    report "pout expect   : 0x" & hstr(pout_expected) & "  get : 0x"& hstr(std_logic_vector(pout)) severity note;
                    write(ligne_texte_test, string'("pout expect : 0x" & hstr(pout_expected) & "  get : 0x"& hstr(std_logic_vector(pout))));
                    writeline(file_pout_test, ligne_texte_test);
                elsif (pout = pout_prev) and pout_prev_valid then
                    -- si le motif precedent se repete
                    -- wait next value
                    report "pout previous : 0x" & hstr(std_logic_vector(pout_prev)) & "  get : 0x"& hstr(std_logic_vector(pout)) severity note;
                    write(ligne_texte_test, string'("pout expect : 0x" & hstr(std_logic_vector(pout_prev)) & "  get : 0x"& hstr(std_logic_vector(pout))));
                    writeline(file_pout_test, ligne_texte_test);
                else
                    test := false; -- finish
                    ok   := false; -- with error
                end if;
            end loop;
        end loop;
        file_close(file_pout);
        file_close(file_pout_test);

        file_open(file_res, autotest & ".res", write_mode) ;
        -- Write result
        if not ok or empty then
            report "FAILED " severity note;
            write(ligne_texte, string'("FAILED"));
            writeline(file_res, ligne_texte);
        else
            report "PASSED " severity note;
            write(ligne_texte, string'("PASSED"));
            writeline(file_res, ligne_texte);
        end if;
        file_close(file_res);

        assert false severity failure; -- Stop
    end process tb_pout;


    -- IRQ generator
    tb_irq : process
        file file_irq : text ;
        variable ligne_texte : line;
        variable nc : integer;
    begin
        push <= '0';
        wait until rising_edge(clk) and rst='0';
        if gen_irq then
            -- IRQ enable
            file_open(file_irq, autotest & ".irq", read_mode) ;
            while not endfile(file_irq) loop
                readline(file_irq, ligne_texte);
                read(ligne_texte, nc);
                -- wait nc cycles
                for  i  in  0 to nc-1  loop
                    wait until rising_edge(clk);
                end loop;  -- i

                --Generate IRQ with push button
                push <= '1';
                wait until rising_edge(clk);
                push <= '0';
            end loop;
            file_close(file_irq);
        else
            push <= '0';
        end if;
        wait; -- will wait forever
    end process tb_irq;


    -- Design ----------------------------------------------

    C_PROC: CPU
        generic map (
            RESET_VECTOR     => X"0000_1000",
            INTERRUPT_VECTOR => X"0000_2FFC",
            mutant           => mutant
        )
        port map (
            -- Clock/Reset
            clk         => clk,
            rst         => rst,

            --IRQ interface
            irq         => irq,
            meip        => meip,
            mtip        => mtip,
            mie         => mie,
            mip         => mip,
            mcause      => mcause,

            -- Memory master interface
            mem_addr    => mem_addr,
            mem_d_size  => mem_d_size,
            mem_datain  => mem_datain,
            mem_dataout => mem_dataout,
            mem_we      => mem_we,
            mem_ce      => mem_ce,

            -- Debug interface
            pout        => pout_value,
            pout_valid  => pout_valid
        );

    -- MEM_PROG led sw&push timer PLIC CLINT
    C_bus : PROC_bus
        generic map (
            -- Bus configuration
            N_SLAVE => BUS_N_SLAVE,
            -- A MODIFIER
            -- Slave    0             1              2
            -- Name     RAM prog  |   IP PLIC   |   IP_CLINT
            BASE => ( X"0000_1000", X"0C00_0000", X"0200_0000"),
            HIGH => ( X"0000_2FFF", X"1000_0000", X"0200_C000")
        )
        port map (
            -- Clock/Reset
            clk       => clk,
            rst       => rst,

            -- Memory slave interface
            cpu_addr  => mem_addr,
            cpu_size  => mem_d_size,
            cpu_datai => mem_datain,
            cpu_datao => mem_dataout,
            cpu_ce    => mem_ce,
            cpu_we    => mem_we,

            -- Memory Bus: memory master interface
            datai     => bus_datai,
            ce        => bus_ce,
            we        => bus_we
        );


    C_RAM: RAM32
        generic map (
            -- Memory configuration
            MEMORY_SIZE => 32 * 1024, -- 32 Ko

            -- Memory initialization
            file_name   => mem_file
        )
        port map (
            -- Clock/Reset
            clk  => clk,
            rst  => '0', -- /!\ Do not reset program memory

            -- Memory slave interface
            addr => mem_addr,
            size => mem_d_size,
            di   => mem_dataout,
            do   => bus_datai(0),
            ce   => bus_ce(0),
            we   => bus_we(0)
        );

    C_ITPush : IP_ITPush
        port map (
            -- Clock/Reset
            clk  => clk,
            rst  => rst,

            -- IO
            push => push,
            irq  => irq_push
        );

    C_PLIC: IP_PLIC
        port map (
            -- Clock/Reset
            clk   => clk,
            rst   => rst,

            -- IRQ Interface
            meip  => meip,
            uart  => uart,
            push  => irq_push,

            -- Memory Slave Interface
            addr  => mem_addr,
            size  => mem_d_size,
            datai => mem_dataout,
            datao => bus_datai(1),
            we    => bus_we(1),
            ce    => bus_ce(1)
        );

    C_CLINT: IP_CLINT
        port map (
            -- Clock/Reset
            clk    => clk,
            rst    => rst,

            -- IRQ Interface
            irq    => irq,
            mtip   => mtip,
            mie    => mie,
            mip    => mip,
            mcause => mcause,
             
            -- Memory Slave Interface
            addr   => mem_addr,
            size   => mem_d_size,
            datai  => mem_dataout,
            datao  => bus_datai(2),
            we     => bus_we(2),
            ce     => bus_ce(2)
        );

end architecture;
