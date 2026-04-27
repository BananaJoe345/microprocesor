`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 08:42:58 PM
// Design Name: 
// Module Name: Data_path
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
module Data_path(
    input clk,
    input reset,
    
    input [1:0] ALU_op_ID,
    input [1:0] ALU_src_B_ID,
    input       ALU_src_A_ID,
    input       MemRead_ID,
    input       MemWrite_ID,
    input [1:0] MemtoReg_ID,
    input       RegWrite_ID,
    input       Branch_ID,
    
    output [6:0] op_code
);
    // predeclarare a registrului de WB
    reg         RegWrite_WB;
    
    // Semnale pentru detectia hazardurilor
    
    wire [4:0] Reg_Hazard_1_ID, Reg_Hazard_2_ID;
    wire stall;
    
    // Etapa de instruction fetch
    
    reg  [31:0] PC;                 // Program counter ul
    wire [31:0] IR_IF;              // Fir pentru preluarea instructiunii din memorie
    wire [31:0] Next_PC_IF;         // Fir pentru updatarea PC ului
    wire        PC_Source_EX;       // Fir pentru a afla de unde vine PC ul 1->PC, calculat in ALU; 0->PC+4
    
    assign Next_PC_IF = (PC_Source_EX == 1) ? ALU_Result_EX : (PC+4); // Calculeaza urmatoarea valoare din PC
    

    
    assign stall = MemRead_EX && ((Dest_Addr_EX == Reg_Hazard_1_ID) || (Dest_Addr_EX == Reg_Hazard_2_ID));
    
    always@(posedge clk)            // Updatarea PC ului la fiecare ceas
        if(reset)           PC <= 32'b0;
        else if(!stall)     PC <= Next_PC_IF; 
    
    // instantierea memoirei de program
    
    Memory Instruction_Mem(.clk(clk),   
                           .mem_read(1'b1),
                           .mem_write(1'b0),
                           .addr(PC[9:0]),
                           .data_write(32'b0),
                           .mem_out(IR_IF));
   
   // primul registru de pipeline IF/ID
   
   reg [31:0] IR_ID, PC_ID, Next_PC_ID;       
   always@(posedge clk) 
        if(reset == 1 || PC_Source_EX == 1)
        begin
            IR_ID <= 32'b0;
            PC_ID <= 32'b0;
            Next_PC_ID <= 32'b0;
        end
        else if(!stall)
        begin
            IR_ID <= IR_IF;
            PC_ID <= PC;
            Next_PC_ID <= (PC + 4);
        end
    
    // Etapa de decode
    
    reg  [31:0] Register_A_ID, Register_B_ID, imm32_ID;
    wire [31:0] Register_Write_Data_WB;
    reg  [4:0]  Dest_Addr_WB;                    
    assign op_code = IR_IF[6:0];
    
    assign Reg_Hazard_1_ID = IR_ID[19:15];
    assign Reg_Hazard_2_ID = IR_ID[24:20];
    
    RegisterBank registers(.clk(clk),
                           .reset(reset),
                           .write_flag(RegWrite_WB),
                           .register_read_1(IR_ID[19:15]),
                           .register_read_2(IR_ID[24:20]),
                           .register_write(Dest_Addr_WB),
                           .data_write(Register_Write_Data_WB),
                           .register_data_1(Register_A_ID),
                           .register_data_2(Register_B_ID));
                               
   ImmediateGenerator immgen(.IR(IR_ID), .imm32(imm32_ID));
   
   // al doilea registru de pipeline ID/EX
   
   reg [31:0] Register_A_EX, Register_B_EX, imm32_EX, PC_EX, Next_PC_EX;
   reg [4:0]  Dest_Addr_EX, Reg_Hazard_1_EX, Reg_Hazard_2_EX;
   reg [2:0]  func3_EX;
   reg [6:0]  func7_EX, opcode_EX;
   reg        MemRead_EX, MemWrite_EX, RegWrite_EX, Branch_EX, ALU_src_A_EX;
   reg [1:0]  ALU_op_EX, ALU_src_B_EX, MemtoReg_EX;
   
   always@(posedge clk)
   if(reset || PC_Source_EX)
   begin
        RegWrite_EX <= 1'b0;
        MemWrite_EX <= 1'b0;
        Branch_EX   <= 1'b0;
   end
   else
   begin
            Register_A_EX   <= Register_A_ID;
            Register_B_EX   <= Register_B_ID;
            imm32_EX        <= imm32_ID;
            PC_EX           <= PC_ID;
            Next_PC_EX      <= Next_PC_ID;
            Dest_Addr_EX    <= IR_ID[11:7];
            func3_EX        <= IR_ID[14:12];
            func7_EX        <= IR_ID[31:25];
            opcode_EX       <= IR_ID[6:0];
            ALU_op_EX       <= ALU_op_ID;
            ALU_src_B_EX    <= ALU_src_B_ID;
            ALU_src_A_EX    <= ALU_src_A_ID;
            MemRead_EX      <= MemRead_ID;
            MemWrite_EX     <= MemWrite_ID;
            MemtoReg_EX     <= MemtoReg_ID;
            RegWrite_EX     <= RegWrite_ID;
            Branch_EX       <= Branch_ID;  
            Reg_Hazard_1_EX <= Reg_Hazard_1_ID;
            Reg_Hazard_2_EX <= Reg_Hazard_2_ID;
   end
   
   // Etapa de executie
   
   wire [1:0] Forward_A, Forward_B;
   wire [31:0] ALU_Mux_A, ALU_Mux_B, Operand_A, Operand_B, ALU_Result_EX;
   
   assign Forward_A = (RegWrite_MEM && (Dest_Addr_MEM != 0) && (Dest_Addr_MEM == Reg_Hazard_1_EX)) ? 2'b10 :
                      (RegWrite_WB  && (Dest_Addr_WB  != 0) && (Dest_Addr_WB  == Reg_Hazard_1_EX)) ? 2'b01 : 2'b00;

   assign Forward_B = (RegWrite_MEM && (Dest_Addr_MEM != 0) && (Dest_Addr_MEM == Reg_Hazard_2_EX)) ? 2'b10 :
                      (RegWrite_WB  && (Dest_Addr_WB  != 0) && (Dest_Addr_WB  == Reg_Hazard_2_EX)) ? 2'b01 : 2'b00;

   assign ALU_Mux_A = (Forward_A == 2'b10) ? ALU_Result_MEM :
                      (Forward_A == 2'b01) ? Register_Write_Data_WB : Register_A_EX;

   assign ALU_Mux_B = (Forward_B == 2'b10) ? ALU_Result_MEM :
                      (Forward_B == 2'b01) ? Register_Write_Data_WB : Register_B_EX;
                      
   assign Operand_A = (ALU_src_A_EX == 1'b1) ? PC_EX : ALU_Mux_A; 
   assign Operand_B = (ALU_src_B_EX == 2'b00) ? ALU_Mux_B :
                      (ALU_src_B_EX == 2'b01) ? 32'd4 :
                      (ALU_src_B_EX == 2'b10) ? imm32_EX : 32'b0;  
   
   // instanitere ALU                   
   BALU alu(.ALU_OP(ALU_op_EX),
            .func3(func3_EX),
            .func7(func7_EX),
            .opcode(opcode_EX),
            .register_data_1(Operand_A),
            .register_data_2(Operand_B),
            .register_out(ALU_Result_EX));
            
   assign PC_Source_EX = Branch_EX & ALU_Result_EX;
   
   // al treilea registru de pipeline EX/MEM
   
   reg [31:0] ALU_Result_MEM, Register_B_MEM, Next_PC_MEM;
   reg [4:0]  Dest_Addr_MEM;
   reg [1:0]  MemtoReg_MEM;
   reg        MemRead_MEM, MemWrite_MEM, RegWrite_MEM;
   
   always@(posedge clk)
   if(reset == 1)
   begin
        RegWrite_MEM <= 1'b0;
        MemWrite_MEM <= 1'b0;
        MemRead_MEM  <= 1'b0;
   end
   else
   begin
    ALU_Result_MEM <= ALU_Result_EX;
    Register_B_MEM <= Register_B_EX;
    Next_PC_MEM    <= Next_PC_EX;
    Dest_Addr_MEM  <= Dest_Addr_EX;
    MemtoReg_MEM   <= MemtoReg_EX;
    MemWrite_MEM   <= MemWrite_EX;
    MemRead_MEM    <= MemRead_EX;
    RegWrite_MEM   <= RegWrite_EX;
   end 
  
  // Etapa a patra lucru cu memoria
  
  wire[31:0] Data_Mem_Out_MEM;
  
  // instantiere memorie de date
  Memory data_mem(
        .clk(clk),
        .mem_read(MemRead_MEM),
        .mem_write(MemWrite_MEM),
        .addr(1024-ALU_Result_MEM[9:0]-4),
        .data_write(Register_B_MEM),
        .mem_out(Data_Mem_Out_MEM)           
    ); 
    
    // al patrulea registru de pipeline MEM/WB
    
    reg [31:0] ALU_Result_WB, Data_Mem_Out_WB, Next_PC_WB;
    reg [1:0]  MemtoReg_WB;
    always@(posedge clk)
    if(reset == 1)
    begin
        RegWrite_WB <= 1'b0;
    end    
    else
    begin
        ALU_Result_WB    <= ALU_Result_MEM;
        Data_Mem_Out_WB  <= Data_Mem_Out_MEM;
        Next_PC_WB       <= Next_PC_MEM;
        Dest_Addr_WB     <= Dest_Addr_MEM;
        MemtoReg_WB      <= MemtoReg_MEM;
        RegWrite_WB      <= RegWrite_MEM;
    end
    
    // Etapa 5 write back
    assign Register_Write_Data_WB = (MemtoReg_WB == 2'b00) ? ALU_Result_WB :
                                    (MemtoReg_WB == 2'b01) ? Data_Mem_Out_WB :
                                    (MemtoReg_WB == 2'b10) ? Next_PC_WB : 32'b0;
                                                                           
endmodule