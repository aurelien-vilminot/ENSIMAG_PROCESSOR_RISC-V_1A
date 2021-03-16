library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PKG is

    constant val_simu : integer := 0
    -- synthesis translate_off
    + 1
    -- synthesis translate_on
;
    subtype w32   is unsigned(31 downto 0);
    subtype w16   is unsigned(15 downto 0);
    subtype waddr is unsigned(31 downto 0);

    type int_vec   is array (natural range <>) of integer;
    type w32_vec   is array (natural range <>) of w32;
    type waddr_vec is array (natural range <>) of waddr;

    constant w32_zero   : w32   := (others=>'0');
    constant w16_zero   : w16   := (others=>'0');
    constant waddr_zero : waddr := (others=>'0');

    constant RF_nb    : integer := 32;
    constant RF_b     : integer := 5;

----------- Types ----------
    type ALU_op_type is (
        ALU_plus,  
        ALU_minus,
        UNDEFINED
    );
    type LOGICAL_op_type is (
        LOGICAL_and,
        LOGICAL_or,
        LOGICAL_xor,
        UNDEFINED
    );
    type ALU_Y_select is   (
        ALU_Y_immI,   
        ALU_Y_rf_rs2,
        UNDEFINED
    );

    type SHIFTER_op_type is (
        SHIFT_rl,
        SHIFT_ra,
        SHIFT_ll,
        UNDEFINED
    );
    type SHIFTER_Y_select is   (
        SHIFTER_Y_ir_sh,   
        SHIFTER_Y_rs2,
        UNDEFINED
    );

    type RF_SIZE_select is (
        RF_SIZE_word,
        RF_SIZE_half,
        RF_SIZE_byte,
        UNDEFINED
    );
    type DATA_select is (
        DATA_from_alu,
        DATA_from_logical,
        DATA_from_mem,
        DATA_from_pc,
        DATA_from_slt,
        DATA_from_shifter,
        DATA_from_csr,
        UNDEFINED
    );

    type AD_Y_select is   (
        AD_Y_immI,   
        AD_Y_immS,
        UNDEFINED
    );

    type PC_select is (
        PC_from_alu,
        PC_mtvec,
        PC_rstvec,
        PC_from_pc,
        PC_from_mepc,
        UNDEFINED
    );

    type PC_X_select is (
        PC_X_cst_x00,
        PC_X_pc,
        UNDEFINED
    );
    type PC_Y_select is (
        PC_Y_cst_x04,
        PC_Y_immU,
        UNDEFINED
    );

    type TO_PC_Y_select is  (
        TO_PC_Y_immB,
        TO_PC_Y_immJ,
        TO_PC_Y_cst_x04,
        UNDEFINED
    );
                    
    type ADDR_select is (
        ADDR_from_pc,
        ADDR_from_ad,
        UNDEFINED
    );

    type TO_CSR_select is (
        TO_CSR_from_rs1,
        TO_CSR_from_imm,
        UNDEFINED
    );

    type CSR_select is (
        CSR_from_mcause,
        CSR_from_mip,
        CSR_from_mie,
        CSR_from_mstatus,
        CSR_from_mtvec,
        CSR_from_mepc,
        UNDEFINED
    );

    type MEPC_select is (
        MEPC_from_pc,
        MEPC_from_csr,
        UNDEFINED
    );

    type CSR_WRITE_mode_type is (
        WRITE_mode_simple,
        WRITE_mode_set,
        WRITE_mode_clear,
        UNDEFINED
    );

    type CSR_write_enable is (
        CSR_none,
        CSR_mie,
        CSR_mstatus,
        CSR_mtvec,
        CSR_mepc,
        UNDEFINED
    );


    -- Commandes vers les csr
    type PO_cs_cmd is record
        CSR_we              : CSR_write_enable;

        TO_CSR_sel          : TO_CSR_select;
        CSR_sel             : CSR_select;
        MEPC_sel            : MEPC_select;

        MSTATUS_mie_set     : std_logic;
        MSTATUS_mie_reset   : std_logic;

        CSR_WRITE_mode      : CSR_WRITE_mode_type;
    end record;

    -- Commandes vers la PO globale
    type PO_cmd is record
        ALU_op              : ALU_op_type;
        LOGICAL_op          : LOGICAL_op_type;
        ALU_Y_sel           : ALU_Y_select;

        SHIFTER_op          : SHIFTER_op_type;
        SHIFTER_Y_sel       : SHIFTER_Y_select;

        RF_we               : std_logic;
        RF_SIZE_sel         : RF_SIZE_select;
        RF_SIGN_enable      : std_logic;
        DATA_sel            : DATA_select;

        PC_we               : std_logic;
        PC_sel              : PC_select;

        PC_X_sel            : PC_X_select;
        PC_Y_sel            : PC_Y_select;

        TO_PC_Y_sel         : TO_PC_Y_select;

        AD_we               : std_logic;
        AD_Y_sel            : AD_Y_select;

        IR_we               : std_logic;

        ADDR_sel            : ADDR_select;
        mem_we              : std_logic;
        mem_ce              : std_logic;

        cs                  : PO_cs_cmd;
    end record;

    -- Status
    type PO_status is record
        IR    : w32;
        JCOND : boolean;
        -- Compléter pour les interruptions :
        IT    : boolean;
    end record;


    -- RAM 32 bits
    component RAM32
        generic (
            -- Memory configuration
            MEMORY_SIZE : positive := 16#1000#;

            -- Memory initialization
            FILE_NAME   : string   := "none"
        );
        port (
            -- Clock/Reset
            clk  : in  std_logic;
            rst  : in  std_logic;

            -- Memory slave interface
            addr : in  waddr;
            size : in  RF_SIZE_select;
            do   : out w32;
            di   : in  w32;
            ce   : in  std_logic;
            we   : in  std_logic
        );
    end component;


    -- RAM 16 bits Dual Port
    component RAM16DP
        generic (
            -- Memory configuration
            MEMORY_SIZE : positive := 16#1000#;

            -- Memory initialization
            FILE_NAME   : string   := "none"
        );
        port (
            -- Clock/Reset
            clkA  : in  std_logic;
            rstA  : in  std_logic;
            clkB  : in  std_logic;
            rstB  : in  std_logic;

            -- Port A: Memory slave interface
            addrA : in  waddr;
            doA   : out w16;
            diA   : in  w16;
            ceA   : in  std_logic;
            weA   : in  std_logic;

            -- Port B: Memory slave interface
            addrB : in  waddr;
            doB   : out w16;
            diB   : in  w16;
            ceB   : in  std_logic;
            weB   : in  std_logic
        );
    end component;


    component IP_ITPush
        port (
            -- Clock/Reset
            clk  : in  std_logic;
            rst  : in  std_logic;

            -- IOs
            push : in  std_logic;
            irq  : out std_logic
        );
    end component IP_ITPush;


    component CPU
        generic (
            RESET_VECTOR     : waddr   := waddr_zero;
            INTERRUPT_VECTOR : waddr   := waddr_zero;
            mutant           : integer := 0
        );
        port (
            -- Clock/Reset
            clk         : in  std_logic;
            rst         : in  std_logic;

            -- IRQ interface
            irq         : in  std_logic;
            meip        : in  std_logic;
            mtip        : in  std_logic;
            mie         : out w32;
            mip         : out w32;
            mcause      : in  w32;

            -- Memory Master interface
            mem_addr    : out waddr;
            mem_d_size  : out RF_SIZE_select;
            mem_datain  : in  w32;
            mem_dataout : out w32;
            mem_we      : out std_logic;
            mem_ce      : out std_logic;

            -- Debug interface
            pout        : out w32;
            pout_valid  : out boolean
        );
    end component CPU;


    -- CPU Partie Controle
    component CPU_PC
        generic (
            mutant  : integer := 0
        );
        port (
            -- Clock/Reset
            clk    : in  std_logic;
            rst    : in  std_logic;

            -- PC to PC interface
            cmd    : out PO_cmd;
            status : in  PO_status
        );
    end component CPU_PC;


    -- CPU Partie Operative
    component CPU_PO
        generic (
            RESET_VECTOR     : waddr   := waddr_zero;
            INTERRUPT_VECTOR : waddr   := waddr_zero;
            mutant           : integer := 0
        );
        port (
            -- Clock/Reset
            clk         : in  std_logic;
            rst         : in  std_logic;

            -- PO to PC interface
            cmd         : in  PO_cmd;
            status      : out PO_status;

            -- IRQ interface
            irq         : in  std_logic;
            meip        : in  std_logic;
            mtip        : in  std_logic;
            mie         : out w32;
            mip         : out w32;
            mcause      : in  w32;

            -- Memory Master interface
            mem_addr    : out waddr;
            mem_d_size  : out RF_SIZE_select;
            mem_datain  : in  w32;
            mem_dataout : out w32;
            mem_we      : out std_logic;
            mem_ce      : out std_logic;

            -- Debug interface
            pout        : out w32;
            pout_valid  : out boolean
        );
    end component CPU_PO;

    component CPU_CSR is
        generic (
            INTERRUPT_VECTOR : waddr   := w32_zero;
            mutant           : integer := 0
        );
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;

            -- Interface de et vers la PO
            cmd         : in  PO_cs_cmd;
            it          : out std_logic;
            pc          : in  w32;
            rs1         : in  w32;
            imm         : in  W32;
            csr         : out w32;
            mtvec       : out w32;
            mepc        : out w32;

            -- Interface de et vers les IP d'interruption
            irq         : in  std_logic;
            meip        : in  std_logic;
            mtip        : in  std_logic;
            mie         : out w32;
            mip         : out w32;
            mcause      : in  w32
        );
    end component CPU_CSR;

    component CPU_CND is
        generic (
            mutant           : integer := 0
        );
        port (
            rs1         : in w32;
            alu_y       : in w32;
            IR          : in w32;
            slt         : out std_logic;
            jcond       : out std_logic
            );
    end component CPU_CND;

    -- Plateform Level Interrupt Controller
    component IP_PLIC
        port (
            -- Clock/Reset
            clk   : in std_logic;
            rst   : in std_logic;

            -- IRQ Interface
            meip  : out std_logic;
            uart  : in  std_logic;
            push  : in  std_logic;

            -- Memory Slave Interface
            addr  : in  waddr;
            size  : in  RF_SIZE_select;
            datai : in  w32;
            datao : out w32;
            we    : in  std_logic;
            ce    : in  std_logic 
        );
    end component IP_PLIC;

    -- Core Level Interruptor
    component IP_CLINT
        port (
            -- Clock/Reset
            clk    : in std_logic;
            rst    : in std_logic;

            -- IRQ Interface
            irq    : out std_logic;
            mtip   : out std_logic;
            mie    : in  w32;
            mip    : in  w32;
            mcause : out w32;

            -- Memory Slave Interface
            addr   : in  waddr;
            size   : in  RF_SIZE_select;
            datai  : in  w32;
            datao  : out w32;
            we     : in  std_logic;
            ce     : in  std_logic 
        );
    end component IP_CLINT;

    component PROC_bus
        generic (
            N_SLAVE   : integer;
            BASE      : waddr_vec;
            HIGH      : waddr_vec
        );
        port (
            -- Clock/Reset
            clk       : in  std_logic;
            rst       : in  std_logic;

            -- Memory Slave Interface
            cpu_addr  : in  waddr;
            cpu_size  : in  RF_SIZE_select;
            cpu_datai : out w32;
            cpu_datao : in  w32;
            cpu_ce    : in  std_logic;
            cpu_we    : in  std_logic;

            -- Memory Bus Master Interface
            datai     : in  w32_vec (0 to N_SLAVE-1);
            ce        : out unsigned(0 to N_SLAVE-1);
            we        : out unsigned(0 to N_SLAVE-1)
        );
    end component PROC_bus;


end PKG;
