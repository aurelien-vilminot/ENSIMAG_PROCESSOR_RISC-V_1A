library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.PKG.all;


entity PROC is
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

        -- HDMI
        channel_n : out std_logic_vector(2 downto 0);
        channel_p : out std_logic_vector(2 downto 0);

        clk_p : out std_logic;
        clk_n : out std_logic;

        cec : in std_logic;
        hpd : in std_logic;
        out_en : out std_logic;
        scl : out std_logic;
        sda : out std_logic;

        -- DDR
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC
    );
end entity;


architecture structural of PROC is
    component IP_LED
        port (
            -- Clock/Reset
            clk   : in  std_logic ;
            rst   : in  std_logic ;

            -- Memory Slave Interface
            addr  : in  waddr ;
            size  : in  RF_SIZE_select ;
            datai : in  w32 ;
            datao : out w32 ;
            we    : in  std_logic ;
            ce    : in  std_logic ;

            -- IOs
            led    : out unsigned( 3 downto 0 ) ;
            switch : in  unsigned( 2 downto 0 ) ;

            -- Debug Interface
            pout : in  w32
        );
    end component IP_LED ;

    component IP_PIN
        port (
            -- Clock/Reset
            clk   : in  std_logic ;
            rst   : in  std_logic ;

            -- Memory Slave Interface
            addr  : in  waddr ;
            size  : in  RF_SIZE_select ;
            datai : in  w32 ;
            datao : out w32 ;
            we    : in  std_logic ;
            ce    : in  std_logic ;

            -- IOs
            pin   : in  w32
        );
    end component IP_PIN ;

    component PS_Link is
        port (
            DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
            DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
            DDR_cas_n : inout STD_LOGIC;
            DDR_ck_n : inout STD_LOGIC;
            DDR_ck_p : inout STD_LOGIC;
            DDR_cke : inout STD_LOGIC;
            DDR_cs_n : inout STD_LOGIC;
            DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
            DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
            DDR_odt : inout STD_LOGIC;
            DDR_ras_n : inout STD_LOGIC;
            DDR_reset_n : inout STD_LOGIC;
            DDR_we_n : inout STD_LOGIC;
            FIXED_IO_ddr_vrn : inout STD_LOGIC;
            FIXED_IO_ddr_vrp : inout STD_LOGIC;
            FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
            FIXED_IO_ps_clk : inout STD_LOGIC;
            FIXED_IO_ps_porb : inout STD_LOGIC;
            FIXED_IO_ps_srstb : inout STD_LOGIC;

            hdmi_r : out std_logic_vector(7 downto 0);
            hdmi_g : out std_logic_vector(7 downto 0);
            hdmi_b : out std_logic_vector(7 downto 0);

            axi_clk : in std_logic;
            axi_rst : in std_logic;
            hdmi_ddr_valid : out std_logic;
            hdmi_ddr_ack : in std_logic;
            hdmi_pixel_clk : in std_logic;
            hdmi_reset_mem : in std_logic;
            hdmi_reset_mem_ack : out std_logic;

            ddr_axi_addr : in std_logic_vector( 31 downto 0);
            ddr_din : in std_logic_vector(31 downto 0);
            ddr_we : in std_logic
    );
    end component PS_Link;

    component HDMI_simple is
        port (
            clk : in std_logic; -- FPGA clock
            rst : in std_logic;

            channel_n : out std_logic_vector(2 downto 0);
            channel_p : out std_logic_vector(2 downto 0);

            clk_p : out std_logic;
            clk_n : out std_logic;

            debug_button_1 : in std_logic;
            debug_button_2 : in std_logic;

            cec : in std_logic;
            hpd : in std_logic;
            out_en : out std_logic;
            scl : out std_logic;
            sda : out std_logic;

            r : in std_logic_vector(7 downto 0);
            g : in std_logic_vector(7 downto 0);
            b : in std_logic_vector(7 downto 0);

            valid : in std_logic;
            ack : out std_logic;

            out_pixel_clk : out std_logic;
            reset_mem : out std_logic;
            reset_mem_ack : in std_logic
        );
    end component;


    -- Internal signals
    signal push_tmp :  w32;
    signal push_or :  std_logic;
    signal previous_push_or :  std_logic;
    signal pppp :  std_logic;
    signal clk_gen, clk_proc, clk_fb : std_logic;
    signal dcm_lock : std_logic;
    signal rst :  std_logic;

    -- Memory Bus
    signal mem_addr    :  waddr ;
    signal mem_d_size  :  RF_SIZE_select ;
    signal mem_datain  :  w32 ;
    signal mem_dataout :  w32 ;
    signal mem_we      :  std_logic ;
    signal mem_ce      :  std_logic ;

    constant BUS_N_SLAVE : integer := 6;

    signal bus_ce, bus_we : unsigned ( 0 to BUS_N_SLAVE-1 ) ;
    signal bus_datai      : w32_vec  ( 0 to BUS_N_SLAVE-1 ) ;

    -- IRQ Bus
    signal irq    : std_logic ;
    signal meip   : std_logic ;
    signal mtip   : std_logic ;
    signal mie    : w32 ;
    signal mip    : w32 ;
    signal mcause : w32 ;
    signal uart   : std_logic := '0' ;

    -- Debug Interface
    signal pout : w32 ;

    signal hdmi_r : std_logic_vector(7 downto 0);
    signal hdmi_g : std_logic_vector(7 downto 0);
    signal hdmi_b : std_logic_vector(7 downto 0);
    signal hdmi_ddr_valid : std_logic;
    signal hdmi_ddr_ack : std_logic;
    signal hdmi_pixel_clk : std_logic;
    signal hdmi_reset_mem : std_logic;
    signal hdmi_reset_mem_ack : std_logic;
    signal ddr_we : std_logic;
    signal counter : integer;
    signal ddr_addr_s : unsigned(31 downto 0);
    signal addr : unsigned(31 downto 0);

begin

    MMCME2_BASE_inst : MMCME2_BASE
        generic map (
            CLKFBOUT_MULT_F  => 8.0,
            CLKIN1_PERIOD    => 8.0, -- horloge entrante à 125MHz
            CLKOUT0_DIVIDE_F => 10.0,
            REF_JITTER1      => 0.010
        )
        port map (
            CLKOUT0  => clk_gen,  -- horloge sortante à 125x8/20 =  50MHz
            LOCKED   => dcm_lock,
            CLKFBOUT => clk_fb,
            CLKFBIN  => clk_fb,
            CLKIN1   => clk,
            PWRDWN   => '0',
            RST      => '0'
        );

    rst <= reset or not dcm_lock;
    BUFG_proc : BUFG port map (O => clk_proc, I => clk_gen);


    --------------------
    -- RISC V processor --
    --------------------

    C_PROC: CPU
        generic map (
            RESET_VECTOR     => X"0000_1000",
            INTERRUPT_VECTOR => X"0000_2FFC",
            mutant           => mutant
        )
        port map (
            -- Clock/Reset
            clk         => clk_proc,
            rst         => rst,

            -- IRQ Interface
            irq         => irq,
            meip        => meip,
            mtip        => mtip,
            mie         => mie,
            mip         => mip,
            mcause      => mcause,

            -- Memory Master Interface
            mem_addr    => mem_addr,
            mem_d_size  => mem_d_size,
            mem_datain  => mem_datain,
            mem_dataout => mem_dataout,
            mem_we      => mem_we,
            mem_ce      => mem_ce,

            -- Debug Interface
            pout        => pout,
            pout_valid  => open
        );

    -- MEM_PROG led sw&push timer PLIC CLINT
    C_bus : PROC_bus
        generic map (
            -- Bus configuration
            N_SLAVE => BUS_N_SLAVE,
            -- A MODIFIER
            -- Slave    0             1             2             3              4             5
            -- Name     RAM prog  |   IP led    |   IP pin    |   IP PLIC   |   IP_CLINT   |   DDR
            BASE => ( X"0000_1000", X"3000_0000", X"3000_0008", X"0C00_0000", X"0200_0000", X"8000_0000"),
            HIGH => ( X"0000_8FFF", X"3000_0004", X"3000_0008", X"1000_0000", X"0200_C000", X"8FFF_FFFF")
        )
        port map (
            -- Clock/Reset
            clk       => clk_proc,
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

    C_RAM_PROG: RAM32
        generic map (
            -- Memory configuration
            MEMORY_SIZE => 32 * 1024, -- 32 Ko

            -- Memory initialization
            FILE_NAME   => FILE_PROG
        )
        port map (
            -- Clock/Reset
            clk  => clk_proc,
            rst  => '0',

            -- Memory Slave Interface
            addr => mem_addr,
            size => mem_d_size,
            di   => mem_dataout,
            do   => bus_datai(0),
            ce   => bus_ce(0),
            we   => bus_we(0)
        );

    C_LED: IP_LED
        port map (
            -- Clock/Reset
            clk   => clk_proc,
            rst   => rst,

            -- Memory Slave Interface
            addr  => mem_addr,
            size  => mem_d_size,
            datai => mem_dataout,
            datao => bus_datai(1),
            we    => bus_we(1),
            ce    => bus_ce(1),

            -- IOs
            led   => led,
            switch => switch( 2 downto 0 ),

            -- Debug Interface
            pout => pout
        );

    C_SWITCH: IP_PIN
        port map (
            -- Clock/Reset
            clk   => clk_proc,
            rst   => rst,

            -- Memory Slave Interface
            addr  => mem_addr,
            size  => mem_d_size,
            datai => mem_dataout,
            datao => bus_datai(2),
            we    => bus_we(2),
            ce    => bus_ce(2),

            -- IOs
            pin   => push_tmp
        );

    push_tmp  <= X"000" & "0" & push & X"000" & switch;
    push_or   <= push(0) or push(1) or push(2);
    previous_push_or <= bus_datai(2)(16) or bus_datai(2)(17) or bus_datai(2)(18);
    pppp <= push_or and not previous_push_or;

    C_PLIC: IP_PLIC
        port map (
            -- Clock/Reset
            clk   => clk_proc,
            rst   => rst,

            -- IRQ Interface
            meip  => meip,
            uart  => uart,
            push  => pppp,

            -- Memory Slave Interface
            addr  => mem_addr,
            size  => mem_d_size,
            datai => mem_dataout,
            datao => bus_datai(3),
            we    => bus_we(3),
            ce    => bus_ce(3)
        );

    C_CLINT: IP_CLINT
        port map (
            -- Clock/Reset
            clk    => clk_proc,
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
            datao  => bus_datai(4),
            we     => bus_we(4),
            ce     => bus_ce(4)
        );

    C_PS_Link_inst : PS_Link
        port map (
            DDR_addr => DDR_addr,
            DDR_ba => DDR_ba,
            DDR_cas_n => DDR_cas_n,
            DDR_ck_n => DDR_ck_n,
            DDR_ck_p => DDR_ck_p,
            DDR_cke => DDR_cke,
            DDR_cs_n => DDR_cs_n,
            DDR_dm => DDR_dm,
            DDR_dq => DDR_dq,
            DDR_dqs_n => DDR_dqs_n,
            DDR_dqs_p => DDR_dqs_p,
            DDR_odt => DDR_odt,
            DDR_ras_n => DDR_ras_n,
            DDR_reset_n => DDR_reset_n,
            DDR_we_n => DDR_we_n,
            FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
            FIXED_IO_mio => FIXED_IO_mio,
            FIXED_IO_ps_clk => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb => FIXED_IO_ps_porb,
            FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,

            axi_clk => clk_proc,
            axi_rst => '0',

            hdmi_r => hdmi_r,
            hdmi_g => hdmi_g,
            hdmi_b => hdmi_b,

            hdmi_ddr_valid => hdmi_ddr_valid,
            hdmi_ddr_ack => hdmi_ddr_ack,
            hdmi_pixel_clk => hdmi_pixel_clk,
            hdmi_reset_mem => hdmi_reset_mem,
            hdmi_reset_mem_ack => hdmi_reset_mem_ack,

            ddr_din => std_logic_vector(mem_dataout),
            ddr_we => bus_we(5),
            ddr_axi_addr => std_logic_vector(ddr_addr_s)
        );

    ddr_addr_s <= "0000" & mem_addr(27 downto 0);

    C_HDMI_simple : HDMI_simple
        port map(
            clk => clk, -- FPGA clock
            rst => '0',

            channel_n => channel_n,
            channel_p => channel_p,

            clk_p => clk_p,
            clk_n => clk_n,

            debug_button_1 => '0',
            debug_button_2 => '0',

            cec => cec,
            hpd => hpd,
            out_en => out_en,
            scl => scl,
            sda => sda,

            r => hdmi_r,
            g => hdmi_g,
            b => hdmi_b,

            valid => hdmi_ddr_valid,
            ack => hdmi_ddr_ack,

            out_pixel_clk => hdmi_pixel_clk,
            reset_mem => hdmi_reset_mem,
            reset_mem_ack => hdmi_reset_mem_ack
        );

end architecture;
