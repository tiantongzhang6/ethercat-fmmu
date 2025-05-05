//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/03 23:22:33
// Design Name: 
// Module Name: top
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


module top(
    input rxc, 
    input subdv, 
    input RSTN,
    input [7:0] rx_data,
    input [7:0] sub_command,
    input [31:0] sub_address,
    input [7:0] sub_len,
    input [7:0] bus_data_in, 
    output reg [7:0] tx_data,
    output reg [7:0] bus_data_out,
    output reg [15:0] bus_address,
    output reg tx_match,
    output reg bus_match,
    output reg bus_rd,
    output reg bus_wr,
    output reg [1:0] sub_wkc,
    input [7:0] wdata,
    input wr,        
    input frame_en,  
    input frame_csc  
    );
reg [7:0] en_fmmu_num;
wire [31:0] reg06x0_3;
wire [15:0] reg06x4_5;
wire [2:0] reg06x6;
wire [2:0] reg06x7;
wire [15:0] reg06x8_9;
wire [2:0] reg06xA;
wire [1:0] reg06xB;
wire  reg06xC;    
reg [2:0] fmmu_enable_wr;
reg [2:0] fmmu_enable_rd;
reg [2:0] fmmu_enable_wr_rd;
integer j;
wire [31:0] fmmu_logic_start [0:7];
wire [15:0] fmmu_logic_len   [0:7];
wire [1:0] fmmu_type [0:7];
wire fmmu_enable [0:7];

// 中间信号数组：保存每个模块的输出
wire [7:0] tx_data_array [0:7];
wire [7:0] bus_data_out_array [0:7];
wire [15:0] bus_address_array [0:7];
wire tx_match_array [0:7];
wire bus_match_array [0:7];
wire bus_rd_array [0:7];
wire bus_wr_array [0:7];
wire [1:0] sub_wkc_array [0:7];
// 8个fmmu_process模块实例化
genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_modules
        fmmu_process u_fmmu_process(
            .rxc(rxc),
            .RSTN(RSTN),
            .subdv(subdv),
            .rx_data(rx_data),
            .sub_command(sub_command),
            .sub_address(sub_address),
            .sub_len(sub_len),
            .bus_data_in(bus_data_in),
            .en(en_fmmu_num[i]),
            .tx_data(tx_data_array[i]),
            .sub_wkc(sub_wkc_array[i]),
            .bus_address(bus_address_array[i]),
            .bus_data_out(bus_data_out_array[i]),
            .bus_rd(bus_rd_array[i]),
            .bus_wr(bus_wr_array[i]),
            .bus_match(bus_match_array[i]),
            .tx_match(tx_match_array[i]),           
            .wdata(wdata),
            .wr(wr),
            .frame_en(frame_en),
            .frame_crc(frame_crc),
            .reg06x0_3(fmmu_logic_start[i]),
            .reg06x4_5(fmmu_logic_len[i]),
            .reg06x6(reg06x6),
            .reg06x7(reg06x7),
            .reg06x8_9(reg06x8_9),
            .reg06xA(reg06xA),
            .reg06xB(fmmu_type[i]),
            .reg06xC(fmmu_enable[i])                
        );   
    

    end   
endgenerate


// 选择器：根据 en_fmmu_num 激活模块输出
always @(*) begin
    tx_data      = tx_data_array[0];
    bus_data_out = bus_data_out_array[0];
    bus_address  = bus_address_array[0];
    tx_match     = tx_match_array[0];
    bus_match    = bus_match_array[0];
    bus_rd       = bus_rd_array[0];
    bus_wr       = bus_wr_array[0];
    sub_wkc      = sub_wkc_array[0];

    for (j = 0; j < 8; j = j + 1) begin
        if (en_fmmu_num[j]) begin
            tx_data      = tx_data_array[j];
            bus_data_out = bus_data_out_array[j];
            bus_address  = bus_address_array[j];
            tx_match     = tx_match_array[j];
            bus_match    = bus_match_array[j];
            bus_rd       = bus_rd_array[j];
            bus_wr       = bus_wr_array[j];
            sub_wkc      = sub_wkc_array[j];
        end
    end
end

    
always @(*) begin
    // 清零
    if(!RSTN)begin
        fmmu_enable_wr = 3'd0;
        fmmu_enable_rd = 3'd0;
        fmmu_enable_wr_rd = 3'd0;
    end else begin
        for (j = 0; j < 8; j = j + 1) begin: loop_match 
            if (sub_address >= fmmu_logic_start[j] &&
                sub_address <  fmmu_logic_start[j] + fmmu_logic_len[j]) begin
                case (sub_command)
                    8'd10: fmmu_enable_wr     = j[2:0];
                    8'd11: fmmu_enable_rd     = j[2:0];
                    8'd12: fmmu_enable_wr_rd  = j[2:0];
                    default: 
                        begin
                           fmmu_enable_wr = 3'd0;
                           fmmu_enable_rd = 3'd0;
                           fmmu_enable_wr_rd = 3'd0;
                       end
                endcase
                disable loop_match;
            end
        end
    end
end

     always@(posedge rxc or negedge RSTN)begin
        if(!RSTN)begin
            en_fmmu_num <= 8'b0;
        end else begin
            case(sub_command)
                8'd10:begin
                    if(fmmu_type[fmmu_enable_rd] == 10 && fmmu_enable[fmmu_enable_rd])
                        en_fmmu_num[fmmu_enable_rd] <= 1;
                    end
                8'd11:begin
                    if(fmmu_type[fmmu_enable_wr] == 11 && fmmu_enable[fmmu_enable_wr])
                        en_fmmu_num[fmmu_enable_wr] <= 1;
                    end
                default:
                    en_fmmu_num <= 8'b0;
                 endcase
        end
    end
endmodule
