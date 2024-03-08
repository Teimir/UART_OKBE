module RX 
#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RADE = 9600
)(
    input rx_line,
    input clk,
    output [7:0] data,
    output reg data_valid = 0
);

localparam start = 2'b00;
localparam read = 2'b01;
localparam stop = 2'b10;

localparam half_len_bit = (CLK_FREQ / BAUD_RADE) /2 ;
localparam len_bit      = (CLK_FREQ / BAUD_RADE) ;

reg [1:0] state = 2'b0;
reg [31:0] clock_cnt = 32'b0;
reg [4:0] bit_cnt = 4'b0;
reg prev_ss = 0;

reg [7:0] data_r = 'd0;

always @(posedge clk) begin
    prev_ss <= rx_line;
    case (state)
        start: begin
            data_valid <= 0;
            if (rx_line == 0 && prev_ss == 1) clock_cnt <= 32'd1;
            if (clock_cnt != 32'd0) clock_cnt <= clock_cnt + 32'd1;
            if (clock_cnt == half_len_bit) begin
                state <= read;
                clock_cnt <= 32'd0;
                
            end
        end
        read: begin

            if (clock_cnt == len_bit) begin
                data_r <= {rx_line, data_r[7:1]};
                bit_cnt <= bit_cnt + 4'd1;
                
                clock_cnt <= 32'd0;                
                if (bit_cnt == 4'd7) begin
                    bit_cnt <= 4'd0;
                    state <= stop;                
                end
            end
            else clock_cnt <= clock_cnt + 32'd1;
        end
        stop: begin
            if (clock_cnt == len_bit && rx_line == 1) begin
                clock_cnt <= 32'd0;
                state <= start;
                data_valid <= 1;
            end
            else clock_cnt <= clock_cnt + 32'd1;
        end
    endcase
end

assign data = (data_valid) ? data_r : 'd0;

endmodule