module fmmu_test1(
    input [31:0] sub_address,
    input [7:0] sub_len,
    input subdv,
   // input clk,
   // input RSTN,
    input [15:0] fmmu_physical_address_start,
    input [31:0] fmmu_logic_address_start,
    input [7:0] fmmu_logic_length,
    output reg [15:0] bus_address,
    output reg [7:0] fmmu_map_address_len
);
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
endmodule