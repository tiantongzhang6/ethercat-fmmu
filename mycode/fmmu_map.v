// 地址映射算法, 读取支持按位按字节，写入支持按字节，按位写只支持0x0F00-0x0F03
module fmmu_map(
    input [31:0] fmmu_logic_address,
    input [127:0] reg_fmmu,
    output [15:0] fmmu_physical_address
);

// 首次主站分配到各个寄存器中
wire [31:0] fmmu_logic_address_start; //reg0x0600-reg0x0603
wire [15:0] fmmu_logic_length; //reg0x0604-reg0x0605
wire [7:0] fmmu_logic_address_start_bit; //reg0x0606
wire [7:0] fmmu_logic_address_end_bit; //reg0x0607
wire [15:0] fmmu_physical_address_start; //reg0x0608-reg0x0609
wire [7:0] fmmu_physical_address_start_bit; //reg0x060A
wire [7:0] fmmu_wr_type; //reg0x060B
wire [7:0] fmmu_enable; //reg0x060C
wire [23:0] fmmu_keep; // reg保留地址

assign fmmu_logic_address_start = reg_fmmu[31:0];
assign fmmu_logic_length = reg_fmmu[47:32];
assign fmmu_logic_address_start_bit = reg_fmmu[55:48];
assign fmmu_logic_address_end_bit = reg_fmmu[63:56];
assign fmmu_physical_address_start = reg_fmmu[79:64];
assign fmmu_physical_address_start_bit = reg_fmmu[87:80];
assign fmmu_wr_type = reg_fmmu[95:88];
assign fmmu_enable = reg_fmmu[103:96];
assign fmmu_keep = reg_fmmu[127:104];

wire [31:0] byte_offset;
// wire [7:0] bit_offset;

assign byte_offset = fmmu_logic_address - fmmu_logic_address_start;
if (byte_offset < 16'b1)
    assign fmmu_physical_address = fmmu_physical_address_start + byte_offset[15:0];
else
    


// 组合逻辑实现
always@(*)begin
    if(fmmu_enable = 8'b00000001)begin
        if(fmmu_wr_type == 8'b000000001)begin
            // 物理地址字节 = 逻辑地址字节 - 逻辑地址起始字节 + 物理地址起始字节
            if(fmmu_logic_address - fmmu_logic_address_start < 16'b1)
            fmmu_physical_address = fmmu_logic_address - fmmu_logic_address_start + fmmu_physical_address_start  
        end
        else if(fmmu_wr_type == 8'b00000002)begin
            // 物理地址字节 = 逻辑地址字节 - 逻辑地址起始字节 + 物理地址起始字节
            if(fmmu_logic_address - fmmu_logic_address_start < 16'b1)
            fmmu__address = fmmu_logic_address - fmmu_logic_address_start + fmmu_physical_address_start  
        end
        else if(fmmu_wr_type == 8'b00000003)begin
            fmmu_physical_address = 
        end
        
    end
end

//  位偏移 = 逻辑地址起始位 - 物理地址起始位
//bit_offset = (fmmu_logic_address_start_bit >= fmmu_physical_address_start_bit) ? \ 
//            fmmu_logic_address_start_bit - fmmu_physical_address_start_bit : \
//            fmmu_physical_address_start_bit - fmmu_logic_address_start_bit;
endmodule