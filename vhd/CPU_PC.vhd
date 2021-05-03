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
        -- Basic state
        S_Error, S_Init, S_Pre_Fetch, S_Fetch, S_Decode,
        -- Load immediate
        S_LUI,
        -- ALU Without IMM
        S_ADD, S_SUB, S_AND, S_OR, S_XOR,
        -- ALU With IMM
        S_ORI, S_XORI, S_ANDI, S_ADDI,
        -- Shifts
        S_SLL, S_SLLI, S_SRL, S_SRLI, S_SRA, S_SRAI,
        -- Connection and jump
        S_BEQ, S_BNE, S_BLT, S_BGE, S_BLTU, S_BGEU,
        S_AUIPC, S_JAL, S_JALR,
        -- Comparisons
        S_SLT, S_SLTI, S_SLTIU, S_SLTU,
        -- Memory Access 
        S_LW_0, S_LW_1, S_LW_2, S_SW_0, S_SW_1, S_SW_2,
        -- Interruptions
        S_CSR, S_mret
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

        -- Default values
        cmd.ALU_op            <= UNDEFINED;
        cmd.LOGICAL_op        <= UNDEFINED;
        cmd.ALU_Y_sel         <= UNDEFINED;

        cmd.SHIFTER_op        <= UNDEFINED;
        cmd.SHIFTER_Y_sel     <= UNDEFINED;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= UNDEFINED;
        cmd.RF_SIGN_enable    <= '0';            

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


        case state_q is
            when S_Error =>
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
                if status.IT then
                    -- Save pc in mepc
                    cmd.cs.MEPC_sel <= MEPC_from_pc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    -- Mask other interruptions
                    cmd.cs.MSTATUS_mie_reset <= '1';
                    cmd.cs.MSTATUS_mie_set <= '0';
                    -- Other
                    cmd.PC_sel <= PC_mtvec;
                    cmd.PC_we <= '1';
                    -- Load vector of interruption
                    state_d <= S_Pre_Fetch;
                else
                    state_d <= S_Decode;
                end if;

            when S_Decode =>
                if status.IR(6 downto 0) = "0110111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                -------------------------------------------------------------------
                -------------------Arithm, logic, shits without IMM----------------
                -------------------------------------------------------------------
                elsif status.IR(6 downto 0) = "0110011"  then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(31 downto 25) = "0000000" then
                        if status.IR(14 downto 12) = "100" then
                            state_d <= S_XOR;
                        elsif status.IR(14 downto 12) = "110" then
                            state_d <= S_OR;
                        elsif status.IR(14 downto 12) = "111" then
                            state_d <= S_AND;
                        elsif status.IR(14 downto 12) = "000" then
                            state_d <= S_ADD;
                        elsif status.IR(14 downto 12) = "001" then
                            state_d <= S_SLL;
                        elsif status.IR(14 downto 12) = "010" then
                            state_d <= S_SLT;
                        elsif status.IR(14 downto 12) = "011" then
                            state_d <= S_SLTU;
                        elsif status.IR(14 downto 12) = "101" then
                            state_d <= S_SRL;
                        end if;
                    elsif status.IR(31 downto 25) = "0100000" then
                        if status.IR(14 downto 12) = "101" then
                            state_d <= S_SRA;
                        elsif status.IR(14 downto 12) = "000" then
                            state_d <= S_SUB;
                        end if;
                    end if;
                -------------------------------------------------------------------
                ------------------Arithm, logic, shifts with IMMèè-----------------
                -------------------------------------------------------------------
                elsif status.IR(6 downto 0) = "0010011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "000" then
                        state_d <= S_ADDI;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_ORI;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_ANDI;
                    elsif status.IR(14 downto 12) = "100" then
                        state_d <= S_XORI;
                    elsif status.IR(14 downto 12) = "010" then
                        state_d <= S_SLTI;
                    elsif status.IR(14 downto 12) = "011" then
                        state_d <= S_SLTIU;
                    elsif status.IR(31 downto 25) = "0000000" then
                        if status.IR(14 downto 12) = "001" then
                            state_d <= S_SLLI;
                        elsif status.IR(14 downto 12) = "101" then
                            state_d <= S_SRLI;
                        end if;
                    elsif status.IR(31 downto 25) = "0100000" then
                        if status.IR(14 downto 12) = "101" then
                            state_d <= S_SRAI;
                        end if;
                    end if;
                -------------------------------------------------------------------
                ------------------------------- Jump ------------------------------
                -------------------------------------------------------------------
                elsif status.IR(6 downto 0) = "0010111" then
                    state_d <= S_AUIPC;
                elsif status.IR(6 downto 0) = "1100011" then
                    if status.IR(14 downto 12) = "000" then
                        state_d <= S_BEQ;
                    elsif status.IR(14 downto 12) = "001" then
                        state_d <= S_BNE;
                    elsif status.IR(14 downto 12) = "100" then
                        state_d <= S_BLT;
                    elsif status.IR(14 downto 12) = "101" then
                        state_d <= S_BGE;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_BLTU;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_BGEU;
                    end if; 
                elsif status.IR(6 downto 0) = "1101111" then
                    state_d <= S_JAL;
                elsif status.IR(6 downto 0) = "1100111" then
                    state_d <= S_JALR;
                -------------------------------------------------------------------
                ------------------------Memory Access------------------------------
                -------------------------------------------------------------------
                elsif status.IR(6 downto 0) = "0000011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LW_0;
                elsif status.IR(6 downto 0) = "0100011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SW_0;
                -------------------------------------------------------------------
                -------------------------------------------------------------------   
                elsif status.IR(6 downto 0) = "1110011" then
                        state_d <= S_CSR;
                else
                    state_d <= S_Error;
                end if;

---------- Instructions with immediat of type U ----------

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
---------- Arithmetic/Logic Instructions ----------

            when S_ADDI =>
                --rd <- rs1 + imm
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';

                -- mem[PC] reading
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

                -- mem[PC] reading
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
        
                -- mem[PC] reading
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

                -- mem[PC] reading
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

                -- mem[PC] reading
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

                -- mem[PC] reading
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

                -- mem[PC] reading
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

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                -- next state
                state_d <= S_Fetch;

            when S_SLL =>
                --left shifting, rd <- rs1 << rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;
            
            when S_SLLI =>
                --left shifting, rd <- rs1 << imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRL =>
                -- right shifting, rd <- rs1 >> rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRLI =>
                -- right shifting, rd <- rs1 >> imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_SRA =>
                -- right arithmetic shifting rd <- rs1 >>rs2
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;
            
            when S_SRAI =>
                -- right arithmetic shifting, rd <- rs1 >> imm
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';

                -- mem[PC] reading
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                
                --next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                
                -- mem[PC] reading
                state_d <= S_Pre_Fetch;

                --Don't forget to increase pc
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

            when S_SLT|S_SLTU =>
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;

                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                state_d <= S_Fetch;      
            
            when S_SLTI|S_SLTIU =>
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_immI;

                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';

                state_d <= S_Fetch;
                

---------- Jump Instructions ----------

            when S_BEQ|S_BNE|S_BLT|S_BGE|S_BLTU|S_BGEU =>
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

            when S_JAL =>
                -- rd <= pc + 4
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                -- pc <= pc + immJ
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                state_d <= S_Pre_Fetch;

            when S_JALR =>
                -- rd <= pc + 4
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                -- pc <= pc + immJ
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_sel <= PC_from_alu;
                cmd.PC_we <= '1';
                state_d <= S_Pre_Fetch;



---------- Loads in memory ----------

            when S_LW_0 =>
            -- Charge memory address
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LW_1;

            when S_LW_1 =>
            -- Access memory
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                state_d <= S_LW_2;

            when S_LW_2 =>
            -- Write in register
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';
                -- LW
                if status.IR(14 downto 12) = "010" then
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                -- LB
                elsif status.IR(14 downto 12) = "000" then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                    cmd.RF_SIGN_ENABLE <= '1';
                -- LBU
                elsif status.IR(14 downto 12) = "100" then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                -- LH
                elsif status.IR(14 downto 12) = "001" then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                    cmd.RF_SIGN_ENABLE <= '1';
                -- LHU
                elsif status.IR(14 downto 12) = "101" then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                state_d <= S_Pre_Fetch;

---------- Stores in memory ----------

            when S_SW_0 =>
            -- Charge address
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                state_d <= S_SW_1;

            when S_SW_1 =>
            -- Write the content of rs2
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';

                -- SW
                if status.IR(14 downto 12) = "010" then
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                -- SB
                elsif status.IR(14 downto 12) = "000" then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                -- SH
                elsif status.IR(14 downto 12) = "001" then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                state_d <= S_Pre_Fetch;

---------- SCR Access Instructions  ----------

            when S_CSR =>
                if status.IR(14) = '1' then
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                else 
                    cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;       
                end if;

                if status.IR(13 downto 12) = "01" then
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                elsif status.IR(13 downto 12) = "10" then
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                elsif status.IR(13 downto 12) = "11" then
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                end if;

                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                    cmd.cs.CSR_we <= CSR_mepc;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                end if;
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1'; 
                state_d <= S_mret;

            when S_mret =>
                -- PC r<- mepc
                cmd.PC_sel <= PC_from_mepc;
                cmd.PC_we <= '1';
                
                cmd.cs.MSTATUS_mie_reset <= '0';
                cmd.cs.MSTATUS_mie_set <= '1';
                state_d <= S_Pre_Fetch; 

            when others => null;

        end case;
    end process FSM_comb;
end architecture;
