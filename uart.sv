module UART_OKBE #(
	parameter word_size = 8
)
(
	input wire clk,
	input wire reset,
	output wire RX,
	output wire TX,
	output wire led
	
);

// Частота в герцах
parameter CLK_HZ = 50000000;
parameter BIT_RATE =   9600;
parameter PAYLOAD_BITS = 8;

wire [PAYLOAD_BITS-1:0]  uart_rx_data;
wire        uart_rx_valid;
wire        uart_rx_break;

wire        uart_tx_busy;
wire [PAYLOAD_BITS-1:0]  uart_tx_data;
wire        uart_tx_en;


assign uart_tx_data = uart_rx_data;
assign uart_tx_en   = uart_rx_valid;
assign led = uart_tx_en;
assign led2 = uart_rx_valid;



//
// Приёмник
//
uart_rx #(
	.BIT_RATE(BIT_RATE),
	.PAYLOAD_BITS(PAYLOAD_BITS),
	.CLK_HZ  (CLK_HZ  )
) i_uart_rx(
	.clk(clk), 
	.resetn(reset), 
	.uart_rxd(uart_rxd), 
	.uart_rx_en(1'b1),
	.uart_rx_break(uart_rx_break), 
	.uart_rx_valid(uart_rx_valid), 
	.uart_rx_data (uart_rx_data )  
);

//
// Передатчик
//
uart_tx #(
	.BIT_RATE(BIT_RATE),
	.PAYLOAD_BITS(PAYLOAD_BITS),
	.CLK_HZ  (CLK_HZ  )
) i_uart_tx(
	.clk          (clk),
	.resetn       (reset),
	.uart_txd     (uart_txd),
	.uart_tx_en   (uart_tx_en),
	.uart_tx_busy (uart_tx_busy),
	.uart_tx_data (uart_tx_data) 
);


endmodule