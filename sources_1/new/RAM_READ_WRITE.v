`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/14 15:55:47
// Design Name: 
// Module Name: RAM_READ_WRITE
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


module RAM_READ_WRITE(
    input wire clk,
    input wire rstn
);
parameter STATE_IDLE=2'd0;
parameter STATE_WRITE=2'd1;
parameter STATE_READ=2'd2;

parameter CLK_FREQ=50000000;//input clk 50m
parameter RAM_SIZE=2048;

//always block ,1s triger onece to read write
reg [31:0]counter_reg;
always@(posedge clk or negedge rstn)begin
    if(rstn==0) 
        counter_reg <= 0;
    else
        if(counter_reg<(CLK_FREQ-1))
            counter_reg<=counter_reg+1;
        else 
            counter_reg<=0;
end


(*mark_debug="true"*)reg [3:0]system_state_reg;
reg [31:0]state_timeout_reg;
always @(posedge clk or negedge rstn) begin
    if(rstn==0)begin
        state_timeout_reg <= 0;
        system_state_reg <= 0;
    end
    else begin
        if(counter_reg==(CLK_FREQ-1))begin
            system_state_reg <=STATE_WRITE;
            state_timeout_reg<=0;
        end
        else begin
            if(system_state_reg==STATE_WRITE)begin//write fifo state
                if(state_timeout_reg<RAM_SIZE-1)state_timeout_reg<=state_timeout_reg+1;
                else begin
                    state_timeout_reg<=0;
                    system_state_reg<=STATE_READ;
                end
            end
            else if (system_state_reg==STATE_READ) begin//read fifo state
                if(state_timeout_reg<RAM_SIZE-1)state_timeout_reg<=state_timeout_reg+1;
                else begin
                    state_timeout_reg<=0;
                    system_state_reg<=STATE_IDLE;
                end
            end else begin
                state_timeout_reg<=0;
                system_state_reg<=STATE_IDLE;
            end
        end
    end
end


(*mark_debug="true"*)reg [15:0]write_data_reg;
(*mark_debug="true"*)reg [19:0]write_addr_reg;
(*mark_debug="true"*)reg       write_en_reg  ;

(*mark_debug="true"*)reg [19:0]read_addr_reg ;
(*mark_debug="true"*)reg       read_en_reg   ;

(*mark_debug="true"*)wire[15:0]read_data     ;
(*mark_debug="true"*)wire[15:0]write_data    ;

assign write_data[15:0]=write_data_reg;

always @(posedge clk or negedge rstn) begin
    if (rstn==0) begin
        write_data_reg<=0;
        write_addr_reg<=0;
        write_en_reg<=0;
        read_addr_reg<=0;
        read_en_reg<=0;
    end else begin
        if (system_state_reg==STATE_WRITE) begin
            write_data_reg<=write_data_reg+1;
            write_addr_reg<=write_addr_reg+1;
            write_en_reg<=1;
            read_addr_reg<=0;
            read_en_reg=0;
        end else if (system_state_reg==STATE_READ) begin
            write_data_reg<=0;
            write_addr_reg<=0;
            write_en_reg<=0;
            read_addr_reg<=read_addr_reg+1;
            read_en_reg<=1;
        end else if(system_state_reg==STATE_IDLE)begin
            write_data_reg<=0;
            write_addr_reg<=0;
            write_en_reg<=0;
            read_addr_reg<=0;
            read_en_reg<=0;
        end else begin
            write_data_reg<=0;
            write_addr_reg<=0;
            write_en_reg<=0;
            read_addr_reg<=0;
            read_en_reg<=0;
        end 
    end
end

wire [3:0]system_state;
(*mark_debug="true"*)wire is_write_read_flag;

assign system_state=system_state_reg;
assign is_write_read_flag=(system_state[3:0]==STATE_IDLE)?0:1;

blk_mem_gen_0 blk_mem_gen_0_inst
(
.clka(clk),
.ena(1),	
.wea(write_en_reg), 
.addra(write_addr_reg),
.dina(write_data), 
.clkb(clk), 
.enb(read_en_reg), 
.addrb(read_addr_reg),
.doutb(read_data)
);

endmodule