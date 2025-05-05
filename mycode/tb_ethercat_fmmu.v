`timescale 1ns / 1ps

module tb_ethercat_fmmu();

    // 输入信号
    reg rxc;
    reg subdv;
    reg [3:0] rx_data;
    reg [7:0] sub_command;
    reg [31:0] sub_address;
    reg [15:0] sub_len;
    reg [7:0] bus_data_in;

    // 输出信号
    wire [3:0] tx_data;
    wire tx_match;
    wire [1:0] sub_wkc;
    wire [15:0] bus_address;
    wire [7:0] bus_data_out;
    wire [7:0] data_to_sm;
    wire bus_rd;
    wire bus_wr;
    wire bus_match;
    reg [15:0] fmmu_physical_address_start;
    reg [31:0] fmmu_logic_address_start;
    reg [7:0] fmmu_logic_length;
    reg RSTN;
    reg fmmu_enable;
    reg fmmu_wr_type;
    wire [7:0] wr_data;
    wire [7:0] rd_data;
    // 实例化待测模块
    ethercat_fmmu uut (
      .rxc(rxc),
      .subdv(subdv),
   
      .sub_command(sub_command),
      .sub_address(sub_address),
      .sub_len(sub_len),
      .bus_data_in(bus_data_in),

      .sub_wkc(sub_wkc),
      .bus_address(bus_address),
      .bus_data_out(bus_data_out),
      
      .bus_rd(bus_rd),
      .bus_wr(bus_wr),
      .bus_match(bus_match),
      .fmmu_logic_address_start(fmmu_logic_address_start),
      .fmmu_logic_length(fmmu_logic_length),
      .fmmu_physical_address_start(fmmu_physical_address_start),
      .fmmu_wr_type(fmmu_wr_type),
      .fmmu_enable(fmmu_enable),
      .rd_data(rd_data),
      .wr_data(wr_data)
    );

    // 时钟信号生成
    initial begin
        rxc = 0;
        forever #5 rxc = ~rxc; // 假设时钟周期为10ns
    end
    initial begin
    $monitor("time=%0t: one=%b, two=%b", $time, sub_address + {16'b0, sub_len} < fmmu_logic_address_start,
            sub_address > fmmu_logic_address_start + fmmu_logic_length);
end

    initial begin
        subdv = 0;
        forever #5 subdv = ~subdv; // 假设时钟周期为10ns
    end
    // 测试激励
    initial begin
        // 初始化输入信号
        subdv = 0;

        sub_command = 8'b00000000;
        sub_address = 32'b0;
        sub_len = 16'b1;
        bus_data_in = 8'b0;
        fmmu_logic_address_start = 32'h14141413; //reg0x0600-reg0x0603
        fmmu_logic_length = 16'h0004; //reg0x0604-reg0x0605

        fmmu_physical_address_start = 16'h3333; //reg0x0608-reg0x0609

        fmmu_enable = 8'b00000001; //reg0x060C
        fmmu_wr_type = 1;
    
        // 测试场景1：subdv = 0
        #10; 
        // 测试场景2：subdv = 1，其他信号设置不同值
            RSTN = 0;
            subdv = 1;
            sub_command = 8'd0;
            sub_address = 32'h0000_0004;
            sub_len = 16'h0001;
            bus_data_in = 8'hAA;

            #20;
            RSTN = 1;
            #10;
            subdv = 0;
           
            sub_command = 8'd10; // 测试读
            #100;
            subdv = 0;
            #50;
            subdv = 1;
            sub_address = 32'h14141414;
            #50;
            $stop;
        end

        // 测试场景3：改变sub_command为11
        //sub_command = 8'd11;
    
endmodule