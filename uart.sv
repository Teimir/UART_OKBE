module RX_word #(
	parameter word_size = 8;
) (
	input wire RX_clk,
	input wire RX_bit,
	output wire RX_full,
	output wire [word_size - 1:0] RX_data
);
reg [word_size - 1:0] RX_word = '0;
reg [$clog(word_size) - 1:0] RX_counter = '0;
assign RX_full = (RX_counter == {$clog(word_size){1'b1}});
assign RX_data = RX_word;
always @(posedge RX_clk) begin
	RX_word <= RX_word >> 1;
	RX_word[word_size - 1] <= RX_bit;
	RX_counter <= RX_counter + 1;
end
endmodule
module TX_word #(
	parameter word_size = 8;
) (
	input wire [word_size - 1:0] TX_data,
	input wire TX_clk,
	output wire TX_bit,
	output wire TX_empty
);
reg [word_size - 1:0] TX_word = '0;
reg [$clog(word_size) - 1:0] TX_counter = {$clog(word_size){1'b1}};
assign TX_empty = (TX_counter == {$clog(word_size){1'b1}});
assign TX_bit = TX_word[TX_word];
always @(posedge TX_clk) begin
	if (TX_empty) begin
		TX_word <= TX_data;
	end
	TX_counter <= TX_counter + 1;
end
endmodule
module UART #(
	parameter word_size = 8;
)
(
	input wire internal_clk,
	input wire external_clk,
	input wire bit_to_UART,
	input wire [word_size - 1:0] word_to_UART,
	output wire bit_from_UART,
	output wire [word_size - 1:0] word_from_UART,
);
RX_word RX();
TX_word TX();

endmodule