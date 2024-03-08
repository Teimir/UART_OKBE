module UART_OKBE(
	input clk,
	input btn,
	output led,
	output led2,
	output tx,
	input rx
);


// Регистры
reg [7:0] data = 8'haa; //Данные
reg  data_tx_valid = '0; //Сигнал к отправке на ТХ
wire data_tx_ready; //Сигнал, что готовы к отправке
wire data_rx_valid; //Сигнал, что получение завершено
wire [7:0]data_rx; //Данные с рх


//Параметры конечного автомата
localparam wait_data = 2'b00; 
localparam write = 2'b01;

//Регистр конечного автомата
reg [1:0] state = wait_data; 

always @(posedge clk) begin
	if (~btn) begin //Сброс?
		data <= 8'h00;
		state <= write;
		//data_rx_valid <= 1;
	end
	case(state) //Конечный автомат
		wait_data: begin //Описание состояния ожидания
			if (data_rx_valid) begin //Если данные получены - переносим в буфер и отправляем
				data <= data_rx;
				state <= write;
			end
		end
		write: begin //Описание состояния отправки
			if (data_tx_ready && data_tx_valid) begin //Если данные готовы к отправке и корректны, сбрасываем корректность и переходим к ожиданию
					data_tx_valid <= 0;
					state <= wait_data;
			end
			else begin
				if (data_tx_ready) begin //Готовы к отправке
				data_tx_valid <= 1;
				end
			end
		end
	endcase
end


//Подключение модуля ТХ
TX 
#(
    .CLK_FREQ  (50000000),
    .BAUD_RADE (115200)
)TX_inst(
    .data_in    (data),
    .data_valid (data_tx_valid),
    .data_ready (data_tx_ready),
    .clk        (clk),
    .tx_line    (tx)
);    


//Подключение модуля РХ
RX   
#(    
    .CLK_FREQ  (50000000),
    .BAUD_RADE (115200)
)rx_inst(
    .rx_line   (rx),
    .clk       (clk),
    .data      (data_rx),
    .data_valid(data_rx_valid)
);

//Вывод состояния на диоды
assign led = ~state[0];
assign led2 = ~state[1];
endmodule