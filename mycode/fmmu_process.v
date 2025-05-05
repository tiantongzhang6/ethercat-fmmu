module fmmu_process(
    input rxc,
    input subdv,
    input RSTN,
    input [7:0] rx_data,
    input [7:0] sub_command,
    input [31:0] sub_address,
    input [15:0] sub_len,
    input [7:0] bus_data_in, 
    input en,
    output reg [7:0] tx_data,   
    output reg [15:0] sub_wkc,
    output reg [15:0] bus_address,
    output reg [7:0] bus_data_out,
    output reg bus_rd,
    output reg bus_wr,
    output reg bus_match,
    output reg tx_match,      
    input [7:0] wdata,
    input wr,
    input frame_en,
    input frame_crc,
    output [31:0] reg06x0_3,
    output [15:0] reg06x4_5,
    output [2:0] reg06x6,
    output [2:0] reg06x7,
    output [15:0] reg06x8_9,
    output [2:0] reg06xA,
    output [1:0] reg06xB,
    output  reg06xC    
);

// �����Ĵ����ռ�
    reg_write #(8,8'b0)reg06x_0(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x0_3[7:0])
    );
    
    reg_write #(8,8'b0)reg06x_1(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x0_3[15:8])
    );
    reg_write #(8,8'b0)reg06x_2(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
       .reg_data(reg06x0_3[23:16])
    );
    reg_write #(8,8'b0)reg06x_3(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x0_3[31:24])
    );
    reg_write #(8,8'b0)reg06x_4(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x4_5[7:0])
    );
    reg_write #(8,8'b0)reg06x_5(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x4_5[15:8])
    );                 

    reg_write #(3,8'b0)reg06x_6(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x6[2:0])
    );
        reg_write #(3,8'b0)reg06x_7(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x7[2:0])
    );
    reg_write #(8,8'b0)reg06x_8(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x8_9[7:0])
    );  
    reg_write #(8,8'b0)reg06x_9(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06x8_9[15:8])
    ); 
    reg_write #(3,8'b0)reg06x_A(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06xA[2:0])
    );                   
    reg_write #(2,8'b0)reg06x_B(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06xB[1:0])
    );
    reg_write #(1,8'b0)reg06x_C(
        .clk(clk),
        .RSTN(RSTN),
        .wdata(wdata[7:0]),
        .wr(wr),
        .frame_en(frame_en),
        .frame_crc(frame_crc),
        .en(1'b1),
        .reg_data(reg06xC)
    );

reg [31:0] fmmu_map_address_start;
reg [4:0] fmmu_map_address_len;
wire [31:0] fmmu_logic_address_start; //reg0x0600-reg0x0603   
wire [15:0] fmmu_logic_length; //reg0x0604-reg0x0605          
wire [15:0] fmmu_physical_address_start; //reg0x0608-reg0x0609

assign fmmu_logic_address_start = reg06x0_3;
assign fmmu_logic_length = reg06x4_5;
assign fmmu_physical_address = reg06x8_9;

always@(sub_address or subdv or sub_len or fmmu_logic_address_start or fmmu_logic_length or fmmu_physical_address_start)begin

    bus_address = 16'b0;
    fmmu_map_address_len = 16'b0;
    if(subdv)
        // 判断子报文�?�辑地址区与fmmu逻辑地址区的交接
        if(sub_address + {16'b0, sub_len} <= fmmu_logic_address_start || 
            sub_address >=  fmmu_logic_address_start + fmmu_logic_length )
            // 不fmmu映射
            bus_address = 16'b0;
        else if((sub_address >= fmmu_logic_address_start) && 
                (sub_address + {16'b0, sub_len} <= fmmu_logic_address_start + fmmu_logic_length))
            // 全部映射 (注意位数)
            begin
                bus_address =  sub_address - fmmu_logic_address_start + fmmu_physical_address_start;
                fmmu_map_address_len = sub_len;
            end
        else if(sub_address + {16'b0, sub_len} > fmmu_logic_address_start &&
                sub_address + {16'b0, sub_len} <= fmmu_logic_address_start + fmmu_logic_length && 
                sub_address < fmmu_logic_address_start)
            // 部分映射
            begin
                bus_address = fmmu_physical_address_start;
                fmmu_map_address_len = sub_address + {16'b0, sub_len} - fmmu_logic_address_start;
            end
        else if(sub_address >= fmmu_logic_address_start && 
                sub_address < fmmu_logic_address_start + fmmu_logic_length &&
                sub_address + {16'b0, sub_len} > fmmu_logic_address_start + fmmu_logic_length)
            // 部分映射
            begin
                bus_address = sub_address - fmmu_logic_address_start + fmmu_physical_address_start;
                fmmu_map_address_len = fmmu_logic_address_start + fmmu_logic_length - sub_address;
            end 
        else if(sub_address <= fmmu_logic_address_start && 
                sub_address + {16'b0, sub_len} >= fmmu_logic_address_start + fmmu_logic_length)
            // 部分映射
            begin
                bus_address = fmmu_physical_address_start;
                fmmu_map_address_len = fmmu_logic_length;
            end
    else
        begin
            bus_address = 16'b0;
            fmmu_map_address_len = 16'b0;
        end
end


reg data_finish;
reg [7:0] cnt;
reg [15:0] addr;

// read 
always @(posedge rxc or negedge RSTN)begin
    if(!RSTN)begin
        tx_data <= 0;
        tx_match <= 0;
     end else begin
        if(bus_rd) begin
            tx_data <= bus_data_in;
            tx_match <= 1;
        end else begin
            tx_data <= 0;
            tx_match <= 0;
         end
     end
end

// write 
always @(negedge rxc or negedge RSTN)begin
    if(!RSTN)begin
        bus_data_out <= 0;
        bus_match <= 0;
     end else begin
         if(bus_wr)begin
            bus_data_out <= rx_data;
            bus_match <= 1;
         end else begin
            bus_data_out <= 0;
            bus_match <= 0;
         end
     end         
end

always @(sub_command) begin
    case(sub_command)
        8'd10:begin
            bus_rd = 1;
            bus_wr = 0;
            sub_wkc = 1;
        end
        8'd11:begin
            bus_wr = 1;
            bus_rd = 0;
            sub_wkc = 2;
        end
        8'd12:begin
            bus_wr = 1;
            bus_rd = 1;
            sub_wkc = 3;
        end
        default:begin
            bus_wr = 0;
            bus_rd = 0;
            sub_wkc = 0;
        end
    endcase
end


//
//always @(posedge rxc or negedge RSTN)begin
//    if(!RSTN)begin
//        data_finish <= 0;
//    end else begin
//        if(cnt + 1 >= fmmu_map_address_len)begin
//            data_finish <= 1;
//        end     
//    end 
//end


endmodule
