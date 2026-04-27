`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 11:36:32 AM
// Design Name: 
// Module Name: Control_path
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


module Control_path(
    input clk,
	input reset,
	
	output reg ALU_srcA,
	output reg [1:0] ALU_op,
	output reg [1:0] ALU_srcB,
	output reg MemRead,
	output reg MemWrite,
	output reg Branch,
	output reg [1:0] MemToReg,
	output reg RegWrite,
	
	input [6:0] op_code
    );
    always@(*)
    begin
    // default
    ALU_srcA = 1'b0;           // Operandul A = registru  
    ALU_op = 2'b0;             // Operatie de load/store
    ALU_srcB = 2'b0;           // Operandul B = registru 
    MemRead = 1'b0;            // Nu citeste din memorie 
    MemWrite = 1'b0;           // Nu scrie din memorie 
    Branch = 1'b0;             // Nu face branch uri
    MemToReg = 2'b00;          // Scrie rezultatul ALU
    RegWrite = 1'b0;           // Nu scrie in registru 
        case(op_code)
            
            7'b0110011 :        // R-type 
            begin
            ALU_op   = 2'b10;   // R-Type operation
            RegWrite = 1'b1;    // Scrie in registru
            end    
            7'b0000011 :        // load
            begin
            ALU_srcB = 2'b01;   // Operandul B = valoare imadiata (offset)
            MemRead  = 1'b1;    // Citeste din memorie
            MemToReg = 2'b01;   // Scrie din memorie in registru
            RegWrite = 1'b1;    // Scrie in registru        
            end
            7'b0010011 :        // I-Type
            begin
            ALU_op   = 2'b11;   // I-Type operation
            ALU_srcB = 2'b01;   // Operandul B = valoare imediata
            RegWrite = 1'b1;    // Scrie in registru
            end
            7'b0100011:         // store
            begin
            ALU_srcB = 2'b01;   // Operandul B = valoare imedita (offset)
            MemWrite = 1'b1;    // Scrie in memorie    
            end
            7'b1100011 :        // branches
            begin
            ALU_op   = 2'b01;   // branch operation
            Branch   = 1'b1;    // branch spotted
            end
            7'b0010111 :        // AUIPC
            begin
            ALU_op   = 2'b11;   // instructiune auipc
            ALU_srcA = 1'b1;    // Operandul A = PC
            ALU_srcB = 2'b01;   // Operandul B = valoare imediata
            RegWrite = 1'b1;    // Scrie in registru                
            end
            7'b0110111 :        // LUI
            begin
            ALU_op   = 2'b11;   // instructiune auipc
            ALU_srcB = 2'b01;   // Operandul B = valoare imediata
            RegWrite = 1'b1;    // Scrie in registru            
            end
            7'b1100111:         // JALR
            begin
            ALU_srcB = 2'b01; // Operand B = valoare imediata
            RegWrite = 1'b1;  // Scrie in registru
            Branch   = 1'b1;  // branch spotted
            MemToReg = 2'b10; // Scrie PC+4 in registru
            RegWrite = 1'b1;  // Scrie in registru
            end
            7'b1101111:         // JAL
            begin
            ALU_srcA = 1'b1;  // Operand A = PC
            ALU_srcB = 2'b01; // Operand B = valoare imediata
            RegWrite = 1'b1;  // Scrie in registru
            Branch   = 1'b1;  // branch spotted
            MemToReg = 2'b10; // Scrie PC+4 din memorie in registru
            RegWrite = 1'b1;  // Scrie in registru
            end
    endcase  
    end         
endmodule
