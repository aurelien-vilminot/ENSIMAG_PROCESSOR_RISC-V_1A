library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity CPU is
    generic (
        RESET_VECTOR     : waddr   := waddr_zero ;
        INTERRUPT_VECTOR : waddr   := waddr_zero ;
        mutant           : integer := 0
    );
    port (
        -- Clock/Reset
        clk         : in  std_logic ;
        rst         : in  std_logic ;

        -- IRQ interface
        irq         : in  std_logic ;
        meip        : in  std_logic ;
        mtip        : in  std_logic ;
        mie         : out w32 ;
        mip         : out w32 ;
        mcause      : in  w32 ;

        -- Memory Master Interface
        mem_addr    : out waddr ;
        mem_d_size  : out RF_SIZE_select;
        mem_datain  : in  w32 ;
        mem_dataout : out w32 ;
        mem_we      : out std_logic ;
        mem_ce      : out std_logic ;

        -- Debug interface
        pout        : out w32 ;
        pout_valid  : out boolean
    );
end entity;


architecture RTL of CPU is
    signal cmd    : PO_CMD;
    signal status : PO_STATUS;
begin

    PC : CPU_PC
        generic map (
            mutant => mutant
        )
        port map (
            -- Clock/Reset
            clk    => clk,
            rst    => rst,

            -- PC to PO interface
            cmd    => cmd,
            status => status
    );


    PO :  CPU_PO
        generic map (
            RESET_VECTOR     => RESET_VECTOR,
            INTERRUPT_VECTOR => INTERRUPT_VECTOR,
            mutant           => mutant
        )
        port map (
            -- Clock/Reset
            clk         => clk,
            rst         => rst,

            -- IRQ interface
            irq         => irq,
            meip        => meip,
            mtip        => mtip,
            mie         => mie,
            mip         => mip,
            mcause      => mcause,

            -- PO to PC interface
            cmd         => cmd,
            status      => status,

            -- Memory interface
            mem_addr    => mem_addr,
            mem_d_size  => mem_d_size,
            mem_datain  => mem_datain,
            mem_dataout => mem_dataout,
            mem_we      => mem_we,
            mem_ce      => mem_ce,

            -- Debug interface
            pout        => pout,
            pout_valid  => pout_valid
    );

end architecture;
