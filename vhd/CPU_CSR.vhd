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
    signal mstatus : w32;
    signal mcause_r : w32;

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
    -- mip <= "0";
    -- Registre : process (irq)
    -- begin
    --     if irq='1' then
    --         mtvec <= CSR_write(TO_CSR, mtvec, cmd.CSR_WRITE_mode);
    --         mtvec(1 downto 0) <= "00";
            
    --         mepc <= CSR_write(TO_MEPC, mepc, cmd.CSR_WRITE_mode);
    --         mepc (1 downto 0) <= "00";
            
    --         mie <= CSR_write(TO_CSR, mie, cmd.CSR_WRITE_mode);

    --         mcause_r <= mcause;
    --         mcause_r(31) <= '1';

    --         mstatus <= CSR_write(TO_CSR, mstatus, cmd.CSR_WRITE_mode);
    --         mstatus(3) <= '0' when cmd.MSTATUS_mie_reset = '1';
    --         mstatus(3) <= '1' when cmd.MSTATUS_mie_set = '1';

    --     end if;
    -- end process;

    -- mip_register : process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         mip(7) <= mtip;
--             mip(11) <= meip;
--         end if;
--     end process; 

-- TO_CSR <= rs1 when cmd.TO_CSR_sel = TO_CSR_from_rs1 else imm;
-- TO_MEPC <= pc when cmd.MEPC_sel = MEPC_from_pc else TO_CSR;

-- selection_csr:process(cmd.CSR_sel)
-- begin
--     case cmd.CSR_sel is
--         when CSR_from_mcause =>
--             csr <= mcause_r;
--         when CSR_from_mip =>
--             csr <= mip;
--         when CSR_from_mie =>
--             csr <= mie;
--         when CSR_from_mstatus =>
--             csr <= mstatus;
--         when CSR_from_mtvec =>
--             csr <= mtvec;
--         when CSR_from_mepc =>
--             csr <= mepc;
--         when others => null;
--     end case;
-- end process selection_csr;
    
-- it <= mstatus(3) AND irq; -- A passer par un registre d'abord sinon violation du temps de propa

end architecture;
