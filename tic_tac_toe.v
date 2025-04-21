module game (
    input clk,
    input reset,
    input play,
    input pc,
    input [3:0] comp_pos,
    plyr_pos,
    output wire [1:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9,
    output wire [1:0] who
);
    wire [15:0] pc_en;
    wire [15:0] pl_en;
    wire illegal_move;
    wire win;
    wire comp_play;
    wire plyr_play;
    wire no_space;

    position_registers position_reg_unit(
        .clk(clk),
        .reset(reset),
        .illegal_move(illegal_move),
        .pc_en(pc_en[8:0]),
        .pl_en(pl_en[8:0]),
        .pos1(pos1), .pos2(pos2), .pos3(pos3),
        .pos4(pos4), .pos5(pos5), .pos6(pos6),
        .pos7(pos7), .pos8(pos8), .pos9(pos9)
    );
    
    winner_detector win_detect_unit (
        .pos1(pos1), .pos2(pos2), .pos3(pos3), .pos4(pos4), 
        .pos5(pos5), .pos6(pos6), .pos7(pos7), .pos8(pos8),
        .pos9(pos9), .win(win), .who(who)
    );
    
    position_decoder pd1(
        .in(comp_pos), .en(comp_play), .out_en(pc_en)
    );
    
    position_decoder pd2(
        .in(plyr_pos), .en(plyr_play), .out_en(pl_en)
    );
    
    illegal_move_detector imd_unit (
        .pos1(pos1), .pos2(pos2), .pos3(pos3), .pos4(pos4),
        .pos5(pos5), .pos6(pos6), .pos7(pos7), .pos8(pos8),
        .pos9(pos9), .pc_en(pc_en[8:0]), .pl_en(pl_en[8:0]),
        .illegal_move(illegal_move)
    );
    
    nospace_detector nsd_unit (
        .pos1(pos1), .pos2(pos2), .pos3(pos3), .pos4(pos4),
        .pos5(pos5), .pos6(pos6), .pos7(pos7), .pos8(pos8),
        .pos9(pos9), .no_space(no_space)
    );
    
    fsm_controller tik_tac_controller (
        .clk(clk), .reset(reset), .play(play), .pc(pc),
        .illegal_move(illegal_move), .no_space(no_space),
        .win(win), .comp_play(comp_play), .plyr_play(plyr_play)
    );
endmodule

module position_registers (
    input clk, input reset, input illegal_move,
    input [8:0] pc_en, pl_en,
    output reg [1:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pos1 <= 2'b00;
            pos2 <= 2'b00;
            pos3 <= 2'b00;
            pos4 <= 2'b00;
            pos5 <= 2'b00;
            pos6 <= 2'b00;
            pos7 <= 2'b00;
            pos8 <= 2'b00;
            pos9 <= 2'b00;
        end else begin
            // Handling positions for each cell (position 1 to 9)
            handle_position(pos1, pc_en[0], pl_en[0], illegal_move);
            handle_position(pos2, pc_en[1], pl_en[1], illegal_move);
            handle_position(pos3, pc_en[2], pl_en[2], illegal_move);
            handle_position(pos4, pc_en[3], pl_en[3], illegal_move);
            handle_position(pos5, pc_en[4], pl_en[4], illegal_move);
            handle_position(pos6, pc_en[5], pl_en[5], illegal_move);
            handle_position(pos7, pc_en[6], pl_en[6], illegal_move);
            handle_position(pos8, pc_en[7], pl_en[7], illegal_move);
            handle_position(pos9, pc_en[8], pl_en[8], illegal_move);
        end
    end
    
    task handle_position(
        output reg [1:0] pos,
        input pc_en, pl_en, illegal_move
    );
        begin
            if (illegal_move) begin
                pos <= pos;
            end else if (pc_en) begin
                pos <= 2'b10;  // Computer's move
            end else if (pl_en) begin
                pos <= 2'b01;  // Player's move
            end
        end
    endtask
endmodule

module fsm_controller (
    input clk, input reset, input play, input pc,
    input illegal_move, no_space, win,
    output reg comp_play, plyr_play
);
    parameter idle = 2'b00;
    parameter plyr = 2'b01;
    parameter comp = 2'b10;
    parameter game_over = 2'b11;
    
    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= idle;
        else current_state <= next_state;
    end
    
    always @(*) begin
        case (current_state)
            idle: begin
                if (!reset && play) next_state <= plyr;
                else next_state <= idle;
                plyr_play <= 0;
                comp_play <= 0;
            end
            plyr: begin
                plyr_play <= 1;
                comp_play <= 0;
                if (!illegal_move) next_state <= comp;
                else next_state <= idle;
            end
            comp: begin
                plyr_play <= 0;
                if (!pc) begin
                    next_state <= comp;
                    comp_play <= 0;
                end else if (!win && !no_space) begin
                    next_state <= idle;
                    comp_play <= 1;
                end else if (no_space || win) begin
                    next_state <= game_over;
                    comp_play <= 1;
                end
            end
            game_over: begin
                plyr_play <= 0;
                comp_play <= 0;
                if (!reset) next_state <= idle;
                else next_state <= game_over;
            end
            default: next_state <= idle;
        endcase
    end
endmodule

module nospace_detector (
    input [1:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9,
    output wire no_space
);
    assign no_space = (pos1[1] | pos1[0]) & (pos2[1] | pos2[0]) & (pos3[1] | pos3[0]) &
                      (pos4[1] | pos4[0]) & (pos5[1] | pos5[0]) & (pos6[1] | pos6[0]) &
                      (pos7[1] | pos7[0]) & (pos8[1] | pos8[0]) & (pos9[1] | pos9[0]);
endmodule

module illegal_move_detector (
    input [1:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9,
    input [8:0] pc_en, pl_en,
    output wire illegal_move
);
    wire temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9;
    wire temp11, temp12, temp13, temp14, temp15, temp16, temp17, temp18, temp19;
    wire temp21, temp22;

    assign temp1 = (pos1[1] | pos1[0]) & pl_en[0];
    assign temp2 = (pos2[1] | pos2[0]) & pl_en[1];
    assign temp3 = (pos3[1] | pos3[0]) & pl_en[2];
    assign temp4 = (pos4[1] | pos4[0]) & pl_en[3];
    assign temp5 = (pos5[1] | pos5[0]) & pl_en[4];
    assign temp6 = (pos6[1] | pos6[0]) & pl_en[5];
    assign temp7 = (pos7[1] | pos7[0]) & pl_en[6];
    assign temp8 = (pos8[1] | pos8[0]) & pl_en[7];
    assign temp9 = (pos9[1] | pos9[0]) & pl_en[8];

    assign temp11 = (pos1[1] | pos1[0]) & pc_en[0];
    assign temp12 = (pos2[1] | pos2[0]) & pc_en[1];
    assign temp13 = (pos3[1] | pos3[0]) & pc_en[2];
    assign temp14 = (pos4[1] | pos4[0]) & pc_en[3];
    assign temp15 = (pos5[1] | pos5[0]) & pc_en[4];
    assign temp16 = (pos6[1] | pos6[0]) & pc_en[5];
    assign temp17 = (pos7[1] | pos7[0]) & pc_en[6];
    assign temp18 = (pos8[1] | pos8[0]) & pc_en[7];
    assign temp19 = (pos9[1] | pos9[0]) & pc_en[8];

    assign temp21 = |{temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9};
    assign temp22 = |{temp11, temp12, temp13, temp14, temp15, temp16, temp17, temp18, temp19};

    assign illegal_move = temp21 | temp22;
endmodule

module position_decoder (
    input [3:0] in,
    input en,
    output wire [15:0] out_en
);
    reg [15:0] temp1;

    always @(*) begin
        case (in)
            4'd0: temp1 = 16'b0000000000000001;
            4'd1: temp1 = 16'b0000000000000010;
            4'd2: temp1 = 16'b0000000000000100;
            4'd3: temp1 = 16'b0000000000001000;
            4'd4: temp1 = 16'b0000000000010000;
            4'd5: temp1 = 16'b0000000000100000;
            4'd6: temp1 = 16'b0000000001000000;
            4'd7: temp1 = 16'b0000000010000000;
            4'd8: temp1 = 16'b0000000100000000;
            4'd9: temp1 = 16'b0000001000000000;
            default: temp1 = 16'b0000000000000000;
        endcase
    end

    assign out_en = (en) ? temp1 : 16'd0;
endmodule

module winner_detector (
    input [1:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9,
    output wire winner,
    output wire [1:0] who
);
    wire win1, win2, win3, win4, win5, win6, win7, win8;
    wire [1:0] who1, who2, who3, who4, who5, who6, who7, who8;

    winner_detect_3 u1(pos1, pos2, pos3, win1, who1);
    winner_detect_3 u2(pos4, pos5, pos6, win2, who2);
    winner_detect_3 u3(pos7, pos8, pos9, win3, who3);
    winner_detect_3 u4(pos1, pos4, pos7, win4, who4);
    winner_detect_3 u5(pos2, pos5, pos8, win5, who5);
    winner_detect_3 u6(pos3, pos6, pos9, win6, who6);
    winner_detect_3 u7(pos1, pos5, pos9, win7, who7);
    winner_detect_3 u8(pos3, pos5, pos6, win8, who8);

    assign winner = |{win1, win2, win3, win4, win5, win6, win7, win8};
    assign who = |{who1, who2, who3, who4, who5, who6, who7, who8};
endmodule

module winner_detect_3 (
    input [1:0] pos0, pos1, pos2,
    output wire winner,
    output wire [1:0] who
);
    wire [1:0] temp0, temp1, temp2;
    wire temp3;

    assign temp0 = (pos0 == pos1);
    assign temp1 = (pos2 == pos1);
    assign temp2 = (temp0 & temp1);
    assign temp3 = (pos0 != 2'b00);
    
    assign winner = temp3 & temp2;
    assign who = (temp2 == 2'b00) ? pos0 : 2'b00;
endmodule
