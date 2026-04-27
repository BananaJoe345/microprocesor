`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 06:42:11 PM
// Design Name: 
// Module Name: ImmediateGenerator
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


module ImmediateGenerator(
    input [31:0] IR,
    output reg [31:0] imm32
    );
    always @(*) begin
        case(IR[6:0])
            // I-Type (Load, Addi, Jalr etc.)
            7'b0000011, 7'b0010011, 7'b1100111: 
                imm32 = {{20{IR[31]}}, IR[31:20]};

            // S-Type (Store)
            7'b0100011: 
                imm32 = {{20{IR[31]}}, IR[31:25], IR[11:7]};

            // B-Type (Branches) - REPARAT AICI
            7'b1100011: 
                imm32 = {{19{IR[31]}}, IR[31], IR[7], IR[30:25], IR[11:8], 1'b0};

            // J-Type (Jal) - REPARAT AICI (pentru consistență)
            7'b1101111: 
                imm32 = {{11{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21], 1'b0};

            // U-Type (Lui, Auipc)
            7'b0110111, 7'b0010111: 
                imm32 = {IR[31:12], 12'b0};

            default: 
                imm32 = 32'h0000_0000;
        endcase
    end	
endmodule
