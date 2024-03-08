module TX
#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RADE = 9600
)(
    input [7:0] data_in,
    input data_valid,
    input clk,
    output data_ready,
    output tx_line
);

//Параметры конечного автомата
localparam wait_data = 0;
localparam write = 1;

//Регистр конечного автомата
reg state = wait_data;

//Параметр длинны бита
localparam len_bit      = (CLK_FREQ / BAUD_RADE) ;

//Регистр данных
reg [9:0] data = 10'd0;
reg [31:0] clock_cnt = 32'b0;
reg [3:0] bit_cnt = 4'd0;

always @(posedge clk) begin
    case(state)
        wait_data: begin
            if(data_valid) begin
                data <= {1'd1, data_in, 1'd0};
                state <= write;
            end
        end
        write: begin
            if (clock_cnt == len_bit) begin
                clock_cnt <= 32'd0;
                if(bit_cnt == 4'd9) begin 
                    state <= wait_data;
                    bit_cnt <= 4'd0;
                end
                else bit_cnt <= bit_cnt +  4'd1;
            end
            else clock_cnt <= clock_cnt + 32'd1;
        end
    endcase
end

assign data_ready = (state == wait_data) ? 1 : 0;
assign tx_line = (state != write) ? 1 : data[bit_cnt];

endmodule