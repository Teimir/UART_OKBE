module UART_OKBE(
	input clk,
	input btn,
	output led,
	output led2,
	output tx,
	input rx
);

reg [31:0] cnt = 32'd0;
reg [7:0] data = 8'haa;
reg  data_tx_valid = '0;
wire data_tx_ready;
wire data_rx_valid;
wire [7:0]data_rx;

localparam wait_data = 2'b00;
localparam write = 2'b01;

reg [1:0] state = wait_data;

always @(posedge clk) begin
	if (~btn) begin
		data <= 8'h00;
		state <= wait_data;
	end
	case(state)
		wait_data: begin
			if (data_rx_valid) begin
				data <= data_rx;
				state <= write;
			end
		end
		write: begin
			if (data_tx_ready && data_tx_valid) begin
					data_tx_valid <= 0;
					state <= wait_data;
			end
			else begin
				if (data_tx_ready) begin
				data_tx_valid <= 1;
				end
			end
		end
	endcase
end



TX 
#(
    .CLK_FREQ  (50000000),
    .BAUD_RADE (9600)
)TX_inst(
    .data_in    (data),
    .data_valid (data_tx_valid),
    .data_ready (data_tx_ready),
    .clk        (clk),
    .tx_line    (tx)
);    

RX   
#(    
    .CLK_FREQ  (50000000),
    .BAUD_RADE (9600)
)rx_inst(
    .rx_line   (rx),
    .clk       (clk),
    .data      (data_rx),
    .data_valid(data_rx_valid)
);


assign led = ~state[0];
assign led2 = ~state[1];
endmodule