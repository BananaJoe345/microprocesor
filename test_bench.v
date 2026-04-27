    `timescale 1ns / 1ps
    
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
    
        reg clk;
        reg reset;
    
        // Fire pentru semnalele de control generate de Control_path
        wire PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA;
        wire [1:0] ALUSrcB;
        wire [1:0] ALUOp;
        wire PCSource;
    
        // Fir pentru opcode-ul extras din Data_path
        wire [6:0] op_code;
    
        // 1. Instantierea Unitatii de Control (Control_path)
        Control_path control_unit (
            .clk(clk),
            .reset(reset),
            .PCWriteCond(PCWriteCond),
            .PCWrite(PCWrite),
            .IorD(IorD),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .MemtoReg(MemtoReg),
            .IRWrite(IRWrite),
            .RegWrite(RegWrite),
            .ALUSrcA(ALUSrcA),
            .ALUSrcB(ALUSrcB),
            .ALUOp(ALUOp),
            .PCSource(PCSource),
            .op_code(op_code)
        );
    
        // 2. Instantierea Caii de Date (Data_path)
        Data_path datapath (
            .clk(clk),
            .reset(reset),
            .PCWriteCond(PCWriteCond),
            .PCWrite(PCWrite),
            .IorD(IorD),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .MemtoReg(MemtoReg),
            .IRWrite(IRWrite),
            .RegWrite(RegWrite),
            .ALUSrcA(ALUSrcA),
            .ALUSrcB(ALUSrcB),
            .ALUOp(ALUOp),
            .PCSource(PCSource),
            .op_code(op_code)
        );
    
        // Generarea ceasului
        always #5 clk = ~clk;
    
        integer fib_expected [0:7];
        integer failed;
        integer k;
        integer addr;
        integer val;
    
        initial begin
            fib_expected[0] = 0;
            fib_expected[1] = 1;
            fib_expected[2] = 1;
            fib_expected[3] = 2;
            fib_expected[4] = 3;
            fib_expected[5] = 5;
            fib_expected[6] = 8;
            fib_expected[7] = 13;
            failed = 0;
            k = 0;
            val = 0;
            addr = 0;
            clk   = 0;
            reset = 1;
            #20 reset = 0;
    
            // Asteptam suficient pentru executie
            // ~8 iteratii × ~10 cicli × 10ns = 800ns + marja
            #1100;
            
            // -------------------------------------------------------
            // Verificare rezultate din memorie
            // Rezultatele sunt stocate de la adresa 256 (byte 256)
            // fib(n) la adresa 256 + n*4
            // -------------------------------------------------------
            $display("========================================");
            $display("        TEST FIBONACCI");
            $display("========================================");
            failed = 0;
    
            // Inlocuieste intreg blocul for cu asta:
    
    for (k = 0; k < 8; k = k + 1) begin
    addr = 256 + k * 4;
    val = ({datapath.mem_unit.mem[addr+3],
            datapath.mem_unit.mem[addr+2],
            datapath.mem_unit.mem[addr+1],
            datapath.mem_unit.mem[addr]});
    $display("fib(%0d) = %0d | expected = %0d | %s",
             k, val, fib_expected[k],
             (val == fib_expected[k]) ? "OK" : "FAIL");
    if (val != fib_expected[k]) failed = failed + 1;
end
    
            $display("========================================");
            if (failed == 0)
                $display("TOATE TESTELE TRECUTE!");
            else
                $display("%0d TESTE PICATE!", failed);
            $display("========================================");
    
            $finish;
        end
    
        initial begin
            $monitor("Time: %0t | State: %d | PC: %h | IR: %h | branch: %b | PCWriteEnable: %b | nextPC: %h | branch_target: %h | alu_out: %h",
         $time, control_unit.cs, datapath.PC, datapath.IR,
         datapath.branch,
         datapath.PCWriteEnable,
         datapath.nextPC,
         datapath.branch_target,
         datapath.alu_out);
         
         $monitor("Time: %0t | State: %d | PC: %h | IR: %h | MemWrite: %b | addr: %h | data: %h",
     $time, control_unit.cs, datapath.PC, datapath.IR,
     datapath.MemWrite,
     datapath.mem_address,
     datapath.B);
        end
        
    endmodule
