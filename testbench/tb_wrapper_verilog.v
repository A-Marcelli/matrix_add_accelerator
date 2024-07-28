`timescale 1ns/10ps

module tb;
    

    
    // Parameters
    parameter spm_num         = 2;
    parameter BANK_ADDR_WIDTH = 6;
    parameter SIMD            = 2;
    parameter N_RAM_ADDR      = 3;
    parameter N_LOCAL_ADDR    = 3;
    parameter CLK_PERIOD      = 6.5;

    // Testbench signals
    reg clk;
    reg reset;
    reg [31:0] cpu_data_in;
    wire [31:0] cpu_data_out;
    reg [2:0] cpu_addr;
    reg cpu_write;
    reg cpu_read;
    wire cpu_acc_busy;
    wire [31:0] mem_acc_address;
    wire [31:0] mem_acc_data;
    wire mem_acc_read;
    wire mem_acc_write;

    // RAM signals
    reg Load;
    reg Store;
    integer M_dim;
    integer N_dim;
    integer S_val;
    reg [31:0] starting_addr_op1;
    reg [31:0] starting_addr_op2;
    reg [31:0] starting_addr_res;

    // Instantiate the accelerator
    matrix_add_accelerator #(
        .spm_num(spm_num),
        .BANK_ADDR_WIDTH(BANK_ADDR_WIDTH),
        .SIMD(SIMD),
        .N_RAM_ADDR(N_RAM_ADDR),
        .N_LOCAL_ADDR(N_LOCAL_ADDR)
    ) acc (
        .clk(clk),
        .reset(reset),
        .cpu_data_in(cpu_data_in),
        .cpu_data_out(cpu_data_out),
        .cpu_addr(cpu_addr),
        .cpu_write(cpu_write),
        .cpu_read(cpu_read),
        .cpu_acc_busy(cpu_acc_busy),
        .mem_acc_address(mem_acc_address),
        .mem_acc_data(mem_acc_data),
        .mem_acc_read(mem_acc_read),
        .mem_acc_write(mem_acc_write)
    );

    // Instantiate the RAM
    RAM mra (
        .CK(clk),
        .RESET(reset),
        .RD(mem_acc_read),
        .WR(mem_acc_write),
        .Addr(mem_acc_address),
        .Load(Load),
        .Store(Store),
        .Data(mem_acc_data),
        .M_dim(M_dim),
        .N_dim(N_dim),
        .S_val(S_val),
        .starting_addr_op1(starting_addr_op1),
        .starting_addr_op2(starting_addr_op2),
        .starting_addr_res(starting_addr_res)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Initialize signals
        reset = 0;
        cpu_data_in = 0;
        cpu_addr = 0;
        cpu_write = 0;
        cpu_read = 0;
        Load = 0;
        Store = 0;
        M_dim = 2;
        N_dim = 2;
        S_val = 1;
        starting_addr_op1 = 32'h00000000;
        starting_addr_op2 = 32'h00000400;
        starting_addr_res = 32'h00000800;

        // Reset the RAM
        reset = 1;
        #(CLK_PERIOD*2);
        reset = 0;
        #(CLK_PERIOD*2);

        // Set M, N, S in the RAM
        M_dim = 3;
        N_dim = 3;
        S_val = 1;

        // Load matrices from files
        Load = 1;
        #(CLK_PERIOD);
        Load = 0;
        #(CLK_PERIOD*3);

        // Write to the CPU
        cpu_data_in = 32'h0000001c;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD*3);
        cpu_write = 0;
        #(CLK_PERIOD*10);
        
        cpu_data_in = 32'h0000001c;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD*3);
        cpu_write = 0;
        #(CLK_PERIOD*10);

        cpu_data_in = 32'h0000001d;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*10);

        cpu_data_in = 32'h0000000E;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*10);

        // Load operands from central memory to local memory
        // Load operand 1
        cpu_data_in = 32'h00000000;
        cpu_addr = 2;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00000000;
        cpu_addr = 5;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00000001;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*20);

        // Load operand 2
        cpu_data_in = 32'h00000400;
        cpu_addr = 3;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00000010;
        cpu_addr = 6;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00000109;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*20);

        // Sum operands
        cpu_data_in = 32'h00000020;
        cpu_addr = 7;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00004103;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*15);

        // Store resulting matrix
        cpu_data_in = 32'h00000800;
        cpu_addr = 4;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD);

        cpu_data_in = 32'h00000212;
        cpu_addr = 0;
        cpu_write = 1;
        #(CLK_PERIOD);
        cpu_write = 0;
        #(CLK_PERIOD*20);

        // Store results back to file
        Store = 1;
        #(CLK_PERIOD);
        Store = 0;
        #(CLK_PERIOD);

        // Finish the simulation
        $finish;
    end

endmodule
