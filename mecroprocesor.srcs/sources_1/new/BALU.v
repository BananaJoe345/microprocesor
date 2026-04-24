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
// Create Date: 04/23/2026 08:42:58 PM
// Design Name: 
// Module Name: BALU
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


module BALU#(parameter SIZE = 32)
    (
        input clk,
        input [2:0] operation,
        input signed [SIZE-1:0] register_data_1,
        input signed [SIZE-1:0] register_data_2,
        output reg signed [SIZE-1:0] register_out
    );
    always@(posedge  clk)
    begin
        case (operation)
            `ADD : register_out <= register_data_1 + register_data_2 ;
            `SHIFT_LOGIC :
                begin
                    if(register_data_2 < 0)
                        register_out <= register_data_1 >> (-register_data_2);
                    else
                        register_out <= register_data_1 << register_data_2;
                end
            `SHIFT_ARITHMETIC:   
                begin
                    if(register_data_2 < 0)
                        register_out <= register_data_1 >>> (-register_data_2);
                    else
                        register_out <= register_data_1 <<< register_data_2;
                end 
            `AND : register_out <= register_data_1 & register_data_2;
            `OR :  register_out <= register_data_1 | register_data_2;   
        endcase
    end
endmodule
