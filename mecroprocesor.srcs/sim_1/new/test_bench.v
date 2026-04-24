`timescale 1ns / 1ps
`define ADD               3'b001
`define SHIFT_LOGIC       3'b010
`define SHIFT_ARITHMETIC  3'b011
`define AND               3'b100
`define OR                3'b101

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 09:24:27 PM
// Design Name: 
// Module Name: test_bench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_bench();
    reg clk ,write,res;
    reg [2:0] op;
    wire [31:0] reg1,reg2, alu_out;
    reg [4:0] addr1, addr2, addr3;
    reg [31:0] reg3;
    reg write_from_alu;
    wire  [31:0] data_write = (write_from_alu == 1'b1) ? alu_out : reg3;
    RegisterBank rb(.clk(clk), 
                    .reset(res), 
                    .write_flag(write), 
                    .register_read_1(addr1), 
                    .register_read_2(addr2), 
                    .register_write(addr3),
                    .data_write(data_write),
                    .register_data_1(reg1),
                    .register_data_2(reg2));
    BALU alu(.clk(clk),
             .operation(op), 
             .register_data_1(reg1), 
             .register_data_2(reg2), 
             .register_out(alu_out));
    always #5 clk = ~clk;
    initial begin
    clk = 0; op = 0; res = 1; reg3 = 0;
    addr1 = 0; addr2 = 0; addr3 = 0;
    write = 0; write_from_alu = 0;

    #15 res = 0;

    // Ciclu 1 - scriem 50 în reg[1]
    addr3 = 5'd1; reg3 = 32'd50; write = 1;
    @(posedge clk);

    // Ciclu 2 - scriem 20 în reg[2]
    addr3 = 5'd2; reg3 = 32'd20; write = 1;
    @(posedge clk);

    // Ciclu 3 - citim reg[1] ?i reg[2], trimitem ADD la ALU
    write = 0; addr1 = 5'd1; addr2 = 5'd2; op = `ADD;
    @(posedge clk);

    @(posedge clk);
    
    // Ciclu 4 - ALU calculeaz? 50+20=70, a?tept?m rezultatul
    op = 3'd0;
    @(posedge clk);

    // Ciclu 5 - acum alu_out=70, scriem în reg[5]
    addr3 = 5'd5; write_from_alu = 1; write = 1;
    @(posedge clk);

    // Ciclu 6 - citim reg[5]
    write = 0; write_from_alu = 0; addr1 = 5'd5;
    @(posedge clk);

    #1;
    $display("reg[5] = %d", reg1); // a?teptat: 70

    #20 
    $finish;
    end    
endmodule
