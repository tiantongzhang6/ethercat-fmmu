module ethercat_fmmu(
    input rxc,
    input subdv,
    input [3:0] rx_data,
    input [7:0] sub_command,
    input [31:0] sub_address,
    input [15:0] sub_len,
    input [7:0] bus_data_in, 
    output [3:0] tx_data,
    output tx_match,
    output reg [1:0] sub_wkc,
    output reg [15:0] bus_address,
    output reg [7:0] bus_data_out,
    inout reg [7:0] data_to_sm,
    output bus_rd,
    output bus_wr,
    output bus_match
);

wire [31:0] fmmu_logic_address_start; //reg0x0600-reg0x0603
wire [15:0] fmmu_logic_length; //reg0x0604-reg0x0605
wire [7:0] fmmu_logic_address_start_bit; //reg0x0606
wire [7:0] fmmu_logic_address_end_bit; //reg0x0607
wire [15:0] fmmu_physical_address_start; //reg0x0608-reg0x0609
wire [7:0] fmmu_physical_address_start_bit; //reg0x060A
wire [7:0] fmmu_wr_type; //reg0x060B
wire [7:0] fmmu_enable; //reg0x060C

/*
assign fmmu_logic_address_start = {reg06x0, reg06x1, reg06x2, reg06x3};
assign fmmu_logic_length = {reg06x4, reg06x5};
assign fmmu_logic_address_start_bit = reg06x6;
assign fmmu_logic_address_end_bit = reg06x7;
assign fmmu_physical_address_start = {reg06x8,reg06x9};
assign fmmu_physical_address_start_bit = reg06xA;
assign fmmu_wr_type = reg06xB;
assign fmmu_enable = reg06xC;
*/
reg [31:0] fmmu_map_address_start;
reg [4:0] fmmu_map_address_len;

always@(*)begin
    if(subdv)
        // 判断子报文逻辑地址区与fmmu逻辑地址区的交接
        if(sub_address + {16'b0, sub_len} < fmmu_logic_address_start || 
            sub_address > fmmu_logic_address_start)
            // 不fmmu映射
            bus_address = 16'b0;
        else if((sub_address > fmmu_logic_address_start) && 
                (sub_address + {16'b0, sub_len} < fmmu_logic_address_start + fmmu_logic_length))
            // 全部映射 (注意位数)
            begin
                bus_address =  sub_address - fmmu_logic_address_start + fmmu_physical_address_start;
                fmmu_map_address_len = sub_len;
            end
        else if(sub_address + {16'b0, sub_len} > fmmu_logic_address_start &&
                sub_address + {16'b0, sub_len} < fmmu_logic_address_start + fmmu_logic_length && 
                sub_address < fmmu_logic_address_start)
            // 部分映射
            begin
                bus_address = fmmu_physical_address_start;
                fmmu_map_address_len = sub_address + {16'b0, sub_len} - fmmu_logic_address_start;
            end
        else if(sub_address > fmmu_logic_address_start && 
                sub_address < fmmu_logic_address_start + fmmu_logic_length &&
                sub_address + {16'b0, sub_len} > fmmu_logic_address_start + fmmu_logic_length)
            // 部分映射
            begin
                bus_address = sub_address - fmmu_logic_address_start + fmmu_physical_address_start;
                fmmu_map_address_len = fmmu_logic_address_start + fmmu_logic_length - sub_address;
            end 
        else if(sub_address < fmmu_logic_address_start && 
                sub_address + {16'b0, sub_len} > fmmu_logic_address_start + fmmu_logic_length)
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

reg [7:0] rd_data;
reg [7:0] wr_data;
reg data_finish;
reg [7:0] cnt;
reg [15:0] addr;

always @(posedge rxc)begin
    // 读
    if (fmmu_enable == 8'b0) begin
        rd_data <= 8'b0;
		wr_data <= 8'b0;
        addr <= bus_address;
    end
    else begin
        if (data_finish == 1) begin
            
        end
        else begin
            if(sub_command == 10) begin
                rd_data <= bus_data_in;
            end  
            else if(sub_command == 11) begin
                bus_data_out <= wr_data;           
            end
            addr <= addr + 1;
            cnt <= cnt + 1;
        end
        if(cnt + 1 >= fmmu_map_address_len)begin
            data_finish <= 1;
            if (sub_command == 10) begin
                sub_wkc <= sub_wkc + 1;
            end
            else if(sub_command == 11) begin
                sub_wkc <= sub_wkc + 2;
            end
        end      
    end
end


/*
always @(posedge rxc)begin
    // 读写
    if (fmmu_enable == 8'b0) begin
        data <= 8'b0;
    end
    else begin
        if(sub_command == 12) begin
            for (i=0;i<=fmmu_map_address_len ; i=i+1 ) begin
                data_to_sm <= wr_data;
                bus_address <= bus_address + 1;              
            end
            sub_wkc = sub_wkc + 2;
        end
    end
end
  
*/
endmodule
