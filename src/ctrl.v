`include "defines.v"
module ctrl(
           input wire rst,
           wire stallreq_from_id,
           wire stallreq_from_ex,
           // 来自 MEM
           wire[31:0]   excepttype_i,
           wire[`RegBus]    cp0_epc_i,

           output
           reg[`RegBus]     new_pc,
           reg               flush,
           reg[5:0] stall
       );
always @(*) begin
    if(rst == `RstEnable)begin
        stall <= 6'b0;
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
    end else begin
        stall <= 6'b0;
    end
end

always @(*) begin
    if(rst == `RstEnable) begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZeroWord; 
    end else if(excepttype_i != `ZeroWord) begin
        // 发生异常
        flush <= 1'b1;
        stall <= 6'b000000;
        case (excepttype_i)
            32'h0000_0001:begin
                // 中断
                new_pc <= 32'h0000_0020;
            end
            32'h000_0008: begin
                // 系统调用异常 syscall
                new_pc <= 32'h0000_0040;
            end
            32'h0000_000a: begin
                // 无效指令异常
                new_pc <= 32'h0000_0040;
            end
            32'h0000_000d: begin
                // 自陷异常
                new_pc <= 32'h0000_0040;
            end
            32'h0000_000c: begin
                // 溢出异常
                new_pc <= 32'h0000_0040;
            end
            32'h0000_000e: begin
                // 异常返回指令 eret 
                new_pc <= cp0_epc_i;
            end
            default: begin
            end
        endcase
    end else if(stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
        flush <= 1'b0;
    end else if(stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
        flush <= 1'b0;
    end else begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZeroWord;
    end
end

endmodule // ctrl