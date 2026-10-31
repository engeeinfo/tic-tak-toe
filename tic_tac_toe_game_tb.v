module tb_tik_tac_toe;
    reg clk;
    reg reset;
    reg play;
    reg pc;
    reg [3:0] comp_pos;
    reg [3:0] plyr_pos;
    wire [1:0] pos_led1;
    wire [1:0] pos_led2;
    wire [1:0] pos_led3;
    wire [1:0] pos_led4;
    wire [1:0] pos_led5;
    wire [1:0] pos_led6;
    wire [1:0] pos_led7;
    wire [1:0] pos_led8;
    wire [1:0] pos_led9;
    wire [1:0] who;
    reg [1:0] diag_pos1, diag_pos2, diag_pos3;
    wire diag_winner;
    wire [1:0] diag_who;

    // Instantiate the Unit Under Test (UUT)
    tik_tac_toe_game uut(
        .clk(clk), .reset(reset), .play(play), .pc(pc),
        .comp_pos(comp_pos), .plyr_pos(plyr_pos),
        .pos1(pos_led1), .pos2(pos_led2), .pos3(pos_led3),
        .pos4(pos_led4), .pos5(pos_led5), .pos6(pos_led6),
        .pos7(pos_led7), .pos8(pos_led8), .pos9(pos_led9),
        .who(who)
    );

    winner_detect_3 diagonal_check(
        .pos0(diag_pos1), .pos1(diag_pos2), .pos2(diag_pos3),
        .winner(diag_winner), .who(diag_who)
    );

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        play = 0;
        pc = 0;
        reset = 1;
        comp_pos = 0;
        plyr_pos = 0;
        
        // Apply reset for some time
        #100;
        reset = 0;
        
        // Player makes the first move
        #100;
        play = 1;
        pc = 0;
        comp_pos = 4;  // Computer's move
        plyr_pos = 0;  // Player's move
        #50;
        
        // Computer makes its next move
        pc = 1;
        play = 0;
        #100;

        // Player makes the next move
        reset = 0;
        #100;
        play = 1;
        pc = 0;
        comp_pos = 8;  // Computer's move
        plyr_pos = 1;  // Player's move
        #50;
        
        // Computer makes its next move
        pc = 1;
        play = 0;
        #100;

        // Player makes the next move
        reset = 0;
        #100;
        play = 1;
        pc = 0;
        comp_pos = 6;  // Computer's move
        plyr_pos = 2;  // Player's move
        #50;
        
        // Computer makes its next move
        pc = 1;
        play = 0;
        #50;
        
        // Ending the test sequence
        play = 0;
        pc = 0;
    end

    initial begin
        diag_pos1 = 2'b01;
        diag_pos2 = 2'b01;
        diag_pos3 = 2'b01;
        #1;
        if (diag_winner !== 1'b1 || diag_who !== 2'b01) begin
            $display("FAIL: diagonal winner detection is incorrect");
            $finish(1);
        end
        $display("PASS: diagonal winner detection");
    end

    initial begin
        $monitor("time=%0t reset=%b play=%b pc=%b positions=%b%b%b%b%b%b%b%b%b winner=%b",
                 $time, reset, play, pc, pos_led1, pos_led2, pos_led3,
                 pos_led4, pos_led5, pos_led6, pos_led7, pos_led8, pos_led9,
                 who);
        #800;
        if (pos_led1 !== 2'b01 || pos_led2 !== 2'b01 ||
            pos_led3 !== 2'b01 || pos_led5 !== 2'b10 ||
            pos_led7 !== 2'b10 || pos_led9 !== 2'b10 ||
            who !== 2'b01) begin
            $display("FAIL: expected player and computer positions were not stored");
            $finish(1);
        end
        $display("PASS: move sequence stored expected positions");
        $finish(0);
    end
endmodule
