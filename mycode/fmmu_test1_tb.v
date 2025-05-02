`timescale 1ns / 1ps

module fmmu_test1_tb;

    // 输入信号
    reg [31:0] sub_address;
    reg [7:0] sub_len;
    reg subdv;
   // reg clk;
   // reg RSTN;
    reg [15:0] fmmu_physical_address_start;
    reg [31:0] fmmu_logic_address_start;
    reg [7:0] fmmu_logic_length;

    // 输出信号
    wire [15:0] bus_address;
    wire [7:0] fmmu_map_address_len;


    // 实例化待测模块
    fmmu_test1 uut (
        .sub_address(sub_address),
        .sub_len(sub_len),
        .subdv(subdv),
        //.clk(clk),
        //.RSTN(RSTN),
        .fmmu_physical_address_start(fmmu_physical_address_start),
        .fmmu_logic_address_start(fmmu_logic_address_start),
        .fmmu_logic_length(fmmu_logic_length)
    );

    /* 时钟信号生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 假设时钟周期为10ns
    end
    */

    // 测试激励
    initial begin
        // 初始化输入信号
        sub_address = 32'b0;
        sub_len = 16'b0;
        subdv = 0;
        fmmu_logic_address_start = 32'h14141414;
        fmmu_logic_length = 8'd2;
        fmmu_physical_address_start = 16'h1001;


        // 测试场景1：subdv = 0
        #10;
        // 测试场景2：subdv = 1，其他信号设置不同值
        #10;
        subdv = 1;
        // 测试场景3：subdv = 1，其他信号设置不同值(a)
        #20;
        sub_address = 32'h10000000; 
        sub_len = 16'h0001;
        // 测试场景3：subdv = 1，其他信号设置不同值(b)
        #20;
        sub_address = 32'h14141416; 
        sub_len = 16'h0001;
        // 测试场景4：改变sub_address地址(c)
        #20;
        sub_address = 32'h14141413; 
        sub_len = 16'h0002;
        // 测试场景5：改变sub_address地址(d)
        #20;
        sub_address = 32'h14141415; 
        sub_len = 16'h0004;
        //测试场景6：改变sub_lenc长度(e)
        #20;
        sub_address = 32'h14141414; 
        sub_len = 16'h0001;
        //测试场景7：改变sub_lenc长度(f)
        #20;
        sub_address = 32'h14141412; 
        sub_len = 16'h0008;
        #10;
        subdv = 0;
        $stop;
    end

endmodule