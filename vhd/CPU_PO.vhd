library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity CPU_PO is

    generic (
        RESET_VECTOR     : waddr   := w32_zero;
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- PO to PC interface
        cmd         : in  PO_CMD;
        status      : out PO_STATUS;

        -- IRQ Interface
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32;

        -- Memory Master Interface
        mem_addr    : out waddr;
        mem_d_size  : out RF_SIZE_select;
        mem_datain  : in  w32;
        mem_dataout : out w32;
        mem_we      : out std_logic;
        mem_ce      : out std_logic;

        -- Debug port
        pout        : out w32;
        pout_valid  : out boolean
    );

end entity;


architecture RTL of CPU_PO is
    type register_file_type is array (natural range 0 to RF_nb-1) of w32;
    constant register_file_type_zero :register_file_type := (others=>w32_zero);

    -- Registres PO
    signal RF_d, RF_q  : register_file_type; -- banc de registres
    signal PC_d, PC_q  : w32; -- Program Counter

    signal AD_d, AD_q  : w32; --
    signal IR_d, IR_q  : w32; -- Instruction Register
    signal RF_value    : w32; -- Valeur lue du banc de registres
    signal CSR_value   : w32; -- Valeur lue des registres de contrôle et d'état
    signal MTVEC_value : w32; -- Valeur du registre mtvec
    signal MEPC_value  : w32; -- Valeur du registre mepc
    signal IT_value    : std_logic; -- Interruption levée ou non, ...

    -- Chemin de donnee PO
    -- Registres sortant du banc de registre
    signal RS1_d, RS1_q : w32;
    signal RS2_d, RS2_q : w32;

    -- Signaux pour l'UAL
    signal ALU_y, ALU_res : w32;
    -- Signaux pour les opérations logiques
    signal LOGICAL_res : w32;
    -- Signaux pour le shifter
    signal SHIFTER_y      : unsigned(4 downto 0);
    signal SHIFTER_res    : w32;
    -- Signal pour l'additionneur de AD
    signal AD_y           : w32;
    -- Signaux pour l'additionneur de PC
    signal PC_x, PC_y     : w32;
    -- Signal pour l'additionneur TO_PC
    signal TO_PC_y        : w32;
    -- Signal servant de variable pour immI
    signal immI           : w32;

    signal pout_d,       pout_q       : w32;
    signal pout_valid_d, pout_valid_q : boolean;

    -- Signaux pour JCOND et SLT
    signal SLT : std_logic;
    signal JMP : std_logic;

    -- Fonction permettant de couper un registre 
    -- de manière à ce qu'il corresponde à ce que l'on veut
    impure function reg_to_load (RF_SIZE_sel    : RF_SIZE_select;
                                 RF_SIGN_enable : std_logic)
        return w32 is
        variable sign_bit  : std_logic;
        variable res       : w32;
    begin
        case RF_SIZE_sel is
            when RF_SIZE_word =>
                res := mem_datain;
            when RF_SIZE_half =>
                if AD_q(1) = '0' then
                    sign_bit := mem_datain(15) and RF_SIGN_enable;
                    res(15 downto 0)  := mem_datain(15 downto 0);
                    res(31 downto 16) := (others => sign_bit);
                else
                    sign_bit := mem_datain(31) and  RF_SIGN_enable;
                    res(15 downto 0)  := mem_datain(31 downto 16);
                    res(31 downto 16) := (others => sign_bit);
                end if;
            when RF_SIZE_byte => 
                if AD_q(1) = '0' then
                    if AD_q(0) = '0' then
                        sign_bit := mem_datain(7) and RF_SIGN_enable;
                        res(7 downto 0)  := mem_datain(7 downto 0);
                        res(31 downto 8) := (others => sign_bit);
                    else
                        sign_bit := mem_datain(15) and RF_SIGN_enable;
                        res(7 downto 0)  := mem_datain(15 downto 8);
                        res(31 downto 8) := (others => sign_bit);
                    end if;
                else
                    if AD_q(0) = '0' then
                        sign_bit := mem_datain(23) and RF_SIGN_enable;
                        res(7 downto 0)  := mem_datain(23 downto 16);
                        res(31 downto 8) := (others => sign_bit);
                    else
                        sign_bit := mem_datain(31) and RF_SIGN_enable;
                        res(7 downto 0)  := mem_datain(31 downto 24);
                        res(31 downto 8) := (others => sign_bit);
                    end if;
                end if;
            when others => null;
        end case;
        return res;
    end function reg_to_load;

begin
    -- Sortie de débug
    pout <= pout_q;
    pout_valid <= pout_valid_q;

    -- Calcul de immI
    immI <= (31 downto 11 => IR_q(31) ) & IR_q(30 downto 20);

    -- mem_dataout ne sert que pour les stores et on va tout le temps
    -- donner rs2, pour sb et sh la modification se fait dans la mémoire
    -- et non pas ici
    mem_dataout <= RS2_q;

    mem_d_size <= cmd.RF_SIZE_sel;
    status.IR <= IR_q;

    -- recopie des signaux de controle de la memoire
    mem_ce <= cmd.mem_ce;
    mem_we <= cmd.mem_we;

    -- Registres à usage général
    gpr_flip_flops : process (clk)
    begin
        if clk'event and clk='1' then
            if rst ='1' then
                PC_q   <= w32_zero;
                RF_q   <= register_file_type_zero;
                AD_q   <= w32_zero;
                IR_q   <= w32_zero;
                RS1_q  <= w32_zero;
                RS2_q  <= w32_zero;

                pout_q       <= (others=>'0');
                pout_valid_q <= false;
            else
                PC_q    <= PC_d;
                RF_q    <= RF_d;
                RF_q(0) <= w32_zero;
                AD_q    <= AD_d;
                IR_q    <= IR_d;
                RS1_q   <= RS1_d;
                RS2_q   <= RS2_d;

                pout_q       <= pout_d;
                pout_valid_q <= pout_valid_d;
            end if;
        end if;
    end process gpr_flip_flops;

    -- Calcul des entrées des registres à usage général
    gpr_input_selection : process (all)
        variable rf_dest : integer range 0 to ALU_res'length-1;
    begin
        
        -- Les registres prennent leur ancienne valeur par défaut
        PC_d  <= PC_q;
        RF_d  <= RF_q;
        AD_d  <= AD_q;
        IR_d  <= IR_q;

        pout_d <= pout_q;
        pout_valid_d <= false;

        -- Sélection des registres rs1 et rs2.
        RS1_d <= RF_q(to_integer(IR_q(19 downto 15)));
        RS2_d <= RF_q(to_integer(IR_q(24 downto 20)));

        -- mise a jour des registres par leur nouvelle valeur selon les WE
        if cmd.PC_we = '1' then
            case cmd.PC_sel is
                when PC_from_alu =>
                    PC_d <= ALU_res(31 downto 1) & '0';
                when PC_mtvec => 
                    PC_d <= MTVEC_value;
                when PC_rstvec =>
                    PC_d <= RESET_VECTOR;
                when PC_from_pc =>
                    PC_d <= PC_q + TO_PC_y;
                when PC_from_mepc =>
                    PC_d <= MEPC_value;
                when others => null;
            end case;
        end if;

        if cmd.RF_we = '1' then
            rf_dest := to_integer(IR_q(11 downto 7));
            -- Met le registre a jour en prenant en compte  si les données 
            -- proviennent de la mémoire, de l'alu, du shifter ou de slt.
            case cmd.DATA_sel is
                when DATA_from_alu => 
                    RF_value <= ALU_res;
                when DATA_from_logical =>
                    RF_value <= LOGICAL_res;
                when DATA_from_mem => 
                    -- Suivant la taille sélectionné et l'extension de signe 
                    -- on ne load pas de la même manière
                    RF_value <= reg_to_load(cmd.RF_SIZE_sel, cmd.RF_SIGN_enable);
                when DATA_from_pc => 
                    RF_value <= PC_x + PC_y;
                when DATA_from_slt =>
                    RF_value <= (31 downto 1 => '0') & SLT;
                when DATA_from_shifter =>
                    RF_value <= SHIFTER_res;
                when DATA_from_csr =>
                    RF_value <= CSR_value;
                when others => null;
            end case;

            RF_d(rf_dest) <= RF_value;

            -- sort le registre 31
            if rf_dest = 31 then
                pout_d       <= RF_value;
                pout_valid_d <= true;
            end if;
        end if;

        if cmd.AD_we = '1' then
            AD_d <= RS1_q + AD_y;
        end if;

        if cmd.IR_we = '1' then
            IR_d <= mem_datain;
        end if;

    end process gpr_input_selection;

------ Multiplexeurs ------

    -- La sélection des opérandes se fait à l'aide de types enumérés
    -- qui seront "transformés" en signaux binaires par l'outil de synthèse logique

    -- Sélection de l'entrée Y sur l'UAL
    ALU_y <= RS2_q when cmd.ALU_Y_sel = ALU_Y_rf_rs2 else 
             immI  when cmd.ALU_Y_sel = ALU_Y_immI   else 
             (others => 'U');

    -- Sélection de l'opération effectiée par l'UAL
    ALU_res <= RS1_q + ALU_y when cmd.ALU_op = ALU_plus  else
               RS1_q - ALU_y when cmd.ALU_op = ALU_minus else
               (others => 'U');


    -- Sélection de l'opération effectuée par l'opérateur logique
    LOGICAL_res <= RS1_q and ALU_y when cmd.LOGICAL_op = LOGICAL_and else
                   RS1_q or  ALU_y when cmd.LOGICAL_op = LOGICAL_or  else
                   RS1_q xor ALU_y when cmd.LOGICAL_op = LOGICAL_xor else
                   (others => 'U');
                   
    -- Sélection de l'entrée Y sur le SHIFTER
    SHIFTER_y <= RS2_q(4 downto 0)  when cmd.SHIFTER_Y_sel = SHIFTER_Y_rs2   else
                 IR_q(24 downto 20) when cmd.SHIFTER_Y_sel = SHIFTER_Y_ir_sh else
                 (others => 'U');

    -- Sélection de l'opération effectuée par le SHIFTER
    SHIFTER_res <= SHIFT_RIGHT(RS1_q, to_integer(SHIFTER_y)) 
                        when cmd.SHIFTER_op = SHIFT_rl else
                   unsigned(SHIFT_RIGHT(signed(RS1_q), to_integer(SHIFTER_y)))
                        when cmd.SHIFTER_op = SHIFT_ra else
                   SHIFT_LEFT(RS1_q, to_integer(SHIFTER_y))
                        when cmd.SHIFTER_op = SHIFT_ll else
                   (others => 'U');

    -- Sélection de l'entrée Y sur l'additionneur de AD
    AD_y <= immI 
                when cmd.AD_Y_sel = AD_Y_immI else
            (31 downto 11 => IR_q(31) ) & IR_q(30 downto 25)
                                         & IR_q(11 downto 7)
                when cmd.AD_Y_sel = AD_Y_immS else
            (others => 'U');

    -- Sélection de l'entrée X sur l'additionneur de PC
    PC_x <= x"00000000" when cmd.PC_X_sel = PC_X_cst_x00 else
            PC_q        when cmd.PC_X_sel = PC_X_pc      else
            (others => 'U');

    -- Sélection de l'entrée Y sur l'additionneur de PC
    PC_y <= x"00000004" 
                when cmd.PC_Y_sel = PC_Y_cst_x04 else
            IR_q(31 downto 12) & (11 downto 0 => '0')
                when cmd.PC_Y_sel = PC_Y_immU    else
            (others => 'U');

    -- Sélection de l'entrée Y sur TO_PC
    TO_PC_y <= (31 downto 12 => IR_q(31) ) & IR_q(7)
                                            & IR_q(30 downto 25)
                                            & IR_q(11 downto 8)
                                            & '0'
                    when cmd.TO_PC_Y_sel = TO_PC_Y_immB else
               (31 downto 20 => IR_q(31) ) & IR_q(19 downto 12)
                                            & IR_q(20)
                                            & IR_q(30 downto 21)
                                            & '0'
                    when cmd.TO_PC_Y_sel = TO_PC_Y_immJ else
               x"00000004"
                    when cmd.TO_PC_Y_sel = TO_PC_Y_cst_x04 else
               (others => 'U');

    -- Sélection de l'origine de l'adresse vers la memoire
    mem_addr <= AD_q(mem_addr'high downto 0) when cmd.ADDR_sel = ADDR_from_ad else
                PC_q(mem_addr'high downto 0) when cmd.ADDR_sel = ADDR_from_pc else
                (others => 'U');

    --
    -- Partie concernant les csr et les interruptions
    --
    status.IT <= IT_value = '1';

    CSR :  CPU_CSR
        generic map (
            INTERRUPT_VECTOR => INTERRUPT_VECTOR,
            mutant           => mutant
        )
        port map (
            clk         => clk,
            rst         => rst,
            cmd         => cmd.cs,
            it          => IT_value,
            pc          => PC_q,
            rs1         => RS1_q,
            imm         => (31 downto 5 => '0') & IR_q(19 downto 15),
            csr         => CSR_value,
            mtvec       => MTVEC_value,
            mepc        => MEPC_value,
            irq         => irq,
            meip        => meip,
            mtip        => mtip,
            mie         => mie,
            mip         => mip,
            mcause      => mcause
    );

    status.JCOND <= JMP = '1';

    CND :  CPU_CND
        generic map (
            mutant           => mutant
        )
        port map (
            rs1         => RS1_q,
            alu_y       => ALU_y,
            IR          => IR_q,
            SLT         => SLT,
            JCOND       => JMP
    );

end architecture;

