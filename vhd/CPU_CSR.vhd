library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
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
end entity;

architecture RTL of CPU_CSR is
    signal TO_CSR : w32;
    signal TO_MEPC : w32;
    signal mstatus_d, mstatus_q : w32; 
    signal mcause_d, mcause_q : w32;
    signal mip_d, mip_q : w32;
    signal mie_d, mie_q : w32;
    signal mtvec_d, mtvec_q : w32;
    signal mepc_d, mepc_q : w32;


    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;

begin

    sync : process(clk)
    begin
        if rising_edge(clk) then
            mip_d <= mip_q;
        end if;
    end process;
    
    sync2 : process(irq)
    begin
        mcause_d <= mcause_q;
    end process;

    sync_principal : process(all)
    begin
    --     it <= mstatus_q(3) AND irq;
    --     TO_CSR <= rs1 when cmd.TO_CSR_sel = TO_CSR_from_rs1 else imm;
    --     TO_MEPC <= pc when cmd.MEPC_sel = MEPC_from_pc else TO_CSR;

    --     -- case cmd.CSR_we is
    --     --     when CSR_mepc =>
    --     --         mepc_d <= CSR_WRITE(TO_MEPC, mepc_q, cmd.CSR_WRITE_mode);
    --     --     when CSR_mie =>
    --     --         mie_d <= CSR_WRITE(TO_CSR, mie_q, cmd.CSR_WRITE_mode);
    --     --     when CSR_mstatus =>
    --     --         mstatus_d <= CSR_WRITE(TO_CSR, mstatus_q, cmd.CSR_WRITE_mode);
    --     --     when CSR_mtvec =>
    --     --         mtvec_d <= CSR_WRITE(TO_CSR, mtvec_q, cmd.CSR_WRITE_mode);
    --     -- end case;

    --     mtvec_q <= mtvec_d;
    --     mie_q <= mie_d;
    --     mstatus_q <= mstatus_d;
    --     mepc_q <= mepc_d;

    --     case cmd.CSR_sel is
    --         when CSR_from_mcause =>
    --             csr <= mcause_q;
    --         when CSR_from_mip =>
    --             csr <= mip_q;
    --         when CSR_from_mie =>
    --             csr <= mie_q;
    --         when CSR_from_mstatus =>
    --             csr <= mstatus_q;
    --         when CSR_from_mtvec =>
    --             csr <= mtvec_q;
    --         when CSR_from_mepc =>
    --             csr <= mepc_q;
    --         when others => null;
    --     end case;
    end process;

end architecture;
