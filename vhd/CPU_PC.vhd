library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_SUB,
        S_AND,
        S_OR,
        S_ORI,
        S_XOR,
        S_XORI,
        S_SLL,
        S_SLLI,
        S_SRL,
        S_SRLI,
        S_SRA,
        S_SRAI,
        S_AUIPC,
        S_ANDI,
        S_BEQ,
        S_SLT,
        S_SLTI
    );

    signal state_d, state_q : State_type;


begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.ALU_op            <= UNDEFINED;
        cmd.LOGICAL_op        <= UNDEFINED;
        cmd.ALU_Y_sel         <= UNDEFINED;

        cmd.SHIFTER_op        <= UNDEFINED;
        cmd.SHIFTER_Y_sel     <= UNDEFINED;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= UNDEFINED;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= UNDEFINED;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= UNDEFINED;

        cmd.PC_X_sel          <= UNDEFINED;
        cmd.PC_Y_sel          <= UNDEFINED;

        cmd.TO_PC_Y_sel       <= UNDEFINED;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= UNDEFINED;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= UNDEFINED;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd.cs.CSR_we            <= UNDEFINED;

        cmd.cs.TO_CSR_sel        <= UNDEFINED;
        cmd.cs.CSR_sel           <= UNDEFINED;
        cmd.cs.MEPC_sel          <= UNDEFINED;

        cmd.cs.MSTATUS_mie_set   <= '0';
        cmd.cs.MSTATUS_mie_reset <= '0';

        cmd.cs.CSR_WRITE_mode    <= UNDEFINED;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                if status.IR(6 downto 0) = "0110111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADDI; 
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "000" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADD;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "000" AND status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SUB;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "111" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_AND;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ANDI;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "110" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_OR;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "110" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ORI;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "100" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XOR;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "001" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLL;
                elsif status.IR(6 downto 0) = "0010111" then
                    state_d <= S_AUIPC;
                elsif status.IR(6 downto 0) = "1100011" AND status.IR(14 downto 12) = "000" then
                    state_d <= S_BEQ;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "010" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLT;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "101" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRL;
                elsif status.IR(6 downto 0) = "0110011" AND status.IR(14 downto 12) = "101" AND status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRA;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "100" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XORI;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "101" AND status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRAI;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "001" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLLI;
                elsif status.IR(6 downto 0) = "0010011" AND status.IR(14 downto 12) = "101" AND status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRLI;
                else
                    state_d <= S_Error;
                end if;

                -- Décodage effectif des instructions,
                -- à compléter par vos soins

---------- Instructions avec immediat de type U ----------

            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;
---------- Instructions arithmétiques et logiques ----------

            when S_ADDI =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_ADD =>
                --rd <- rs1 + rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_plus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_SUB =>
                --rd <- rs1 - rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_minus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';
        
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
        
                -- next state
                state_d <= S_Fetch;

            when S_AND =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_ANDI =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_OR =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;
            when S_ORI =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;


            when S_XOR =>
                --rd <- rs1 xor imm
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;
            
            when S_XORI =>
                --rd <- rs1 xor imm
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_SLL =>
                --decalage à gauche, rd reçoit rs1 << rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;
            
            when S_SLLI =>
                --decalage à gauche, rd reçoit rs1 << imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRL =>
                --decalage à droite, rd reçoit rs1 >> rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRLI =>
                --decalage à droite, rd reçoit rs1 >> imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRA =>
                --decalage à droite arithmétique, rd reçoit rs1 >> rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;
            
            when S_SRAI =>
                --decalage à droite arithmétique, rd reçoit rs1 >> imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                --decalage à gauche, rd reçoit rs1 << rs2
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                
                --next state
                state_d <= S_Pre_Fetch;

                --On oublie pas d'incrémenter PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

            when S_BEQ =>
                if status.jcond then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                state_d <= S_Pre_Fetch;

            when S_SLT =>
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                state_d <= S_Fetch;            

---------- Instructions de saut ----------

---------- Instructions de chargement à partir de la mémoire ----------

---------- Instructions de sauvegarde en mémoire ----------

---------- Instructions d'accès aux CSR ----------

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
