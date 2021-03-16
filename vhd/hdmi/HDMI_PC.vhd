library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

entity HDMI_PC is
	port (
		pixel_clk : in std_logic;
		rst : in std_logic;
		debug_button_1 : in std_logic;
		debug_button_2 : in std_logic;

		cmd	: out	HDMI_PO_cmd;
		status : in HDMI_PO_status;
		reset_mem : out std_logic;
		reset_mem_ack : in std_logic

	);
end entity;

architecture fsm of HDMI_PC is
	type State_HDMI is (
		S_Init,
		S_HDMI_Start_blank,
		S_HDMI_AVI_Preamble,
		S_HDMI_AVI_Guard,
		S_HDMI_AVI_infoframe,
		S_HDMI_AVI_Guard_end,
		S_HDMI_Head_blank,
		S_HDMI_Line_blank,
		S_HDMI_Line_Preamble,
		S_HDMI_Line_Guard,
		S_HDMI_Line_video_data
	);
	
	signal state_d, state_q : State_HDMI;
	signal x, y : signed(12 downto 0);	
	
	signal rst_real : std_logic;

	procedure change_state_on_countdown(
			signal state_d : out State_HDMI;
			signal cmd : out HDMI_PO_cmd;
			constant next_state : in State_HDMI;
			constant duration : in COUNTDOWN_TYPE
		) is
	begin
		if status.countdown = 1 then

			state_d <= next_state;
			cmd.countdown_max_we <= true;
			cmd.countdown_max_sel <= duration;
		end if;
	end procedure;
begin
	rst_real <= rst or debug_button_1 or debug_button_2;
	reset_mem <= rst_real;
	FSM_synchrone : process(pixel_clk)
	begin
		if pixel_clk'event and pixel_clk='1' then
			state_q <= state_d;
			if rst_real='1' then
				state_q <= S_Init;
				x <= status.screen.max_x;
				y <= status.screen.max_y;
			elsif state_q /= S_Init then
				if x >= status.screen.max_x then
					x <= status.screen.min_x;
					if y >= status.screen.max_y then
						y <= status.screen.min_y;
					else
						y <= y + 1;
					end if;
				else
					x <= x + 1;
				end if;	
			end if;
		end if;
	end process FSM_synchrone;

	FSM_comb : process (state_q,
				debug_button_1,
				debug_button_2,
				x,
				y,
				status,
				status.countdown,
				reset_mem_ack)
	begin
		state_d <= state_q;
		cmd <= HDMI_PO_cmd_zero; 
		
		if debug_button_1 = '1' then 
			cmd.avi_info.VIC <= "0100000";
			cmd.avi_we <= true;
		elsif debug_button_2 = '1' then 
			cmd.avi_info.VIC <= "0100010";
			cmd.avi_we <= true;
		end if;
		cmd.x <= x;
		cmd.y <= y;
				
		if x >= status.screen.min_hsync_x and x <= status.screen.max_hsync_x then
			cmd.hsync <= '1';
		else
			cmd.hsync <= '0';
		end if;
	
		if y >= status.screen.min_vsync_y and y <= status.screen.max_vsync_y then
			cmd.vsync <= '1';
		else
			cmd.vsync <= '0';
		end if;

		case state_q is
			when S_Init =>
			     state_d <= S_Init;
				if reset_mem_ack = '1' then
					state_d <= S_HDMI_Start_blank;
				
					cmd.countdown_max_we <= true;
					cmd.countdown_max_sel <= CNTD_H_BLANK_MINUS_10;
				end if;		
			when S_HDMI_Start_blank =>
				cmd.data_type_sel <= DATA_BLANK;

				change_state_on_countdown(state_d, cmd, S_HDMI_AVI_Preamble, CNTD_8);
			when S_HDMI_AVI_Preamble =>
				
				cmd.data_type_sel <= DATA_CONTROL;
				cmd.ctl <= "0101";
		
				change_state_on_countdown(state_d, cmd, S_HDMI_AVI_Guard, CNTD_2);
				
			when S_HDMI_AVI_Guard =>
				cmd.data_type_sel <= DATA_GUARD_AUX;

				change_state_on_countdown(state_d, cmd, S_HDMI_AVI_InfoFrame, CNTD_32);

			when S_HDMI_AVI_infoframe =>
				cmd.data_type_sel <= DATA_AVI;
				
				change_state_on_countdown(state_d, cmd, S_HDMI_AVI_Guard_end, CNTD_2);
				
			when S_HDMI_AVI_Guard_end =>
				cmd.data_type_sel <= DATA_GUARD_AUX;
				
				change_state_on_countdown(state_d, cmd, S_HDMI_Head_blank, CNTD_UNTIL_FIRST_LINE);
			
			when S_HDMI_Head_blank =>
				change_state_on_countdown(state_d, cmd, S_HDMI_Line_blank, CNTD_H_BLANK_MINUS_10);
			
			when S_HDMI_Line_blank =>
				change_state_on_countdown(state_d, cmd, S_HDMI_Line_Preamble, CNTD_8);

			when S_HDMI_Line_Preamble =>
				
				cmd.data_type_sel <= DATA_CONTROL;
				cmd.ctl <= "0001";
				
				change_state_on_countdown(state_d, cmd, S_HDMI_Line_Guard, CNTD_2);

			when S_HDMI_Line_Guard =>

				cmd.data_type_sel <= DATA_GUARD_VIDEO;
				
				change_state_on_countdown(state_d, cmd, S_HDMI_Line_video_data, CNTD_SCREEN_WIDTH);

			when S_HDMI_Line_video_data =>

				cmd.data_type_sel <= DATA_VIDEO;
				
				if y = status.screen.max_y then
					change_state_on_countdown(state_d, cmd, S_HDMI_Start_blank, CNTD_H_BLANK_MINUS_10);
				else
					change_state_on_countdown(state_d, cmd, S_HDMI_Line_blank, CNTD_H_BLANK_MINUS_10);
				end if;
		end case;
	end process FSM_Comb;
end architecture fsm;
