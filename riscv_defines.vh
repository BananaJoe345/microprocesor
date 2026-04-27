// riscv_defines.vh
`ifndef RISCV_DEFINES_VH
`define RISCV_DEFINES_VH

// ==========================================
// OPERATII ALU
// ==========================================
`define ADDRESS         2'b00 
`define BRENCH          2'b01
`define R_TYPE          2'b10
`define I_TYPE          3'b11

// ==========================================
// REGISTRII RISC-V (ABI Names - Lowercase)
// ==========================================
`define zero 5'd0   // Constant zero
`define ra   5'd1   // Return address
`define sp   5'd2   // Stack pointer
`define gp   5'd3   // Global pointer
`define tp   5'd4   // Thread pointer
`define t0   5'd5   // Temporary 0
`define t1   5'd6   // Temporary 1
`define t2   5'd7   // Temporary 2
`define s0   5'd8   // Saved register 0 / Frame pointer
`define s1   5'd9   // Saved register 1
`define a0   5'd10  // Function argument 0 / Return value 0
`define a1   5'd11  // Function argument 1 / Return value 1
`define a2   5'd12  // Function argument 2
`define a3   5'd13  // Function argument 3
`define a4   5'd14  // Function argument 4
`define a5   5'd15  // Function argument 5
`define a6   5'd16  // Function argument 6
`define a7   5'd17  // Function argument 7
`define s2   5'd18  // Saved register 2
`define s3   5'd19  // Saved register 3
`define s4   5'd20  // Saved register 4
`define s5   5'd21  // Saved register 5
`define s6   5'd22  // Saved register 6
`define s7   5'd23  // Saved register 7
`define s8   5'd24  // Saved register 8
`define s9   5'd25  // Saved register 9
`define s10  5'd26  // Saved register 10
`define s11  5'd27  // Saved register 11
`define t3   5'd28  // Temporary 3
`define t4   5'd29  // Temporary 4
`define t5   5'd30  // Temporary 5
`define t6   5'd31  // Temporary 6

`endif