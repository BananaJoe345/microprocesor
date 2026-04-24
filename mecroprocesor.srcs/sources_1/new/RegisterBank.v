`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 08:33:37 PM
// Design Name: 
// Module Name: RegisterBank
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


module RegisterBank #(parameter SIZE = 32)
    (
        input clk,
        input reset,
        input write_flag,
        input [$clog2(SIZE)-1:0] register_read_1,
        input [$clog2(SIZE)-1:0] register_read_2,
        input [$clog2(SIZE)-1:0] register_write,x
        input [SIZE-1:0] data_write,
        output [SIZE-1:0] register_data_1,
        output [SIZE-1:0] register_data_2
    );
    reg [SIZE-1:0] mem [SIZE-1:0];
    integer i;
    always@(posedge clk)
    begin
        if(reset)
        begin
            for (i = 0; i < SIZE; i = i + 1)
            begin
                mem[i] <= {SIZE{1'b0}};
            end    
        end        
        else if(write_flag)
            mem[register_write] = data_write;
    end
    assign register_data_1 = (register_read_1 == 0) ? {SIZE{1'b0}} : mem[register_read_1];
    assign register_data_2 = (register_read_2 == 0) ? {SIZE{1'b0}} : mem[register_read_2];
endmodule
