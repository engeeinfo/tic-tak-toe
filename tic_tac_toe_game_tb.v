//Test Bench
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
 
tik_tac_toe_game uut(.clk(clk),.reset(reset),.pc(pc),.play(play),.comp_pos(comp_pos),.pos1(pos_led1),.pos2(pos_led2),.pos3(pos_led3),.pos4(pos_led4),.pos5(pos_led5),.pos6(pos_led6),.pos7(pos_led7),.pos8(pos_led8),.pos9(pos_led9),.who(who));
initial begin
clk=0;
forever #5 clk=~clk;
end
initial begin
play=0;
reset=1;
comp_pos=0;
plyr_pos=0;
#100;
reset=0;
#100;
play=1;
pc=0;
comp_pos=4;
plyr_pos=0;
#50;
pc=1;
play=0;
#100;
reset=0;
#100;
play=1;
pc=0;
comp_pos=8;
plyr_pos=1;
#50;
pc=1;
play=0;
#100;
reset=0;
play=1;
pc=0;
comp_pos=6;
plyr_pos=2;
#50;
pc=1;
play=0;
#50;
play=0;
pc=0;
end
endmodule
