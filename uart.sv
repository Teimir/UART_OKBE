/*
Модуль RX_word
содержит сдвиговый регистр RX_word, который может записать 1 бит всебя по такту от преобразователя
содержит счетчик RX_counter, который решает, будет ли при чтении слово полным или в процессе заполнения
загружает биты по старшему и сдвигает до младшего, поэтому должен получать сначала младшие
*/
module RX_word #(
	parameter word_size = 8;
) (
	input wire RX_clk,
	input wire RX_bit,
	output wire RX_full,
	output wire [word_size - 1:0] RX_data
);
reg [word_size - 1:0] RX_word;
reg [$clog(word_size) - 1:0] RX_counter = '0;
assign RX_full = (RX_counter == {$clog(word_size){1'b1}});
assign RX_data = RX_word;
always @(posedge RX_clk) begin
	RX_word <= RX_word >> 1;
	RX_word[word_size - 1] <= RX_bit;
	RX_counter <= RX_counter + 1;
end
endmodule
/*
Модуль TX_word
содержит сдвиговый регистр TX_word, который может быть установлен в значение при записи и выдает следущие биты после записи
TX_word не принимает в себя значение после того как счетчик указывает на то, что он не пустой
TX_word выгружает сначала младшие биты
содержит счетчик TX_counter, который решает, будет ли запись в регистр при такте или его смещение
*/
module TX_word #(
	parameter word_size = 8;
) (
	input wire [word_size - 1:0] TX_data,
	input wire TX_clk,
	output wire TX_bit,
	output wire TX_empty
);
reg [word_size - 1:0] TX_word;
reg [$clog(word_size) - 1:0] TX_counter = {$clog(word_size){1'b1}};
assign TX_empty = (TX_counter == {$clog(word_size){1'b1}});
assign TX_bit = TX_word[0];
always @(posedge TX_clk) begin
	if (TX_empty) begin
		TX_word <= TX_data;
	end
	else begin
		TX_word >> 1;
	end
	TX_counter <= TX_counter + 1;
end
endmodule
/*
Модуль UART
Содержит модули RX_word и TX_word
можно расценивать как ячейку памяти 8х с раздельными портами io (in: word_to_UART + write, out:word_from_UART + read)
выдает XX_error (например для прерываний) если текущее действие является неверным (например чтение незаполненого RX)
отдает следущие пины преобразователям:
clk_from_UART для такта передачи
bit_from_UART для бита передачи
принимает следущие пины преобразователя:
bit_to_UART для бита принятия
external_clk для такта принятия
Обладает своей скоростью работы задаваемым тактами пина internal_clk

RX работает очень просто, читать возможно всегда, но только в нужный момент мы можем не получить XX_error
TX работает сложнее, записать в него выйдет только когда он пустой
Если мы все равно будем пытаться это делать мы ничего не изменим, но получим XX_error

TX получает такты до тех пор пока не станет пустым, когда TX пустой он блокирует clk_from_UART
Поэтому с частотой internal_clk при непустом TX он будет передавать свои биты
*/
module UART #(
	parameter word_size = 8;
)
(
	input wire internal_clk,
	input wire external_clk,						
	input wire bit_to_UART,							
	input wire read,								
	input wire write,								
	input wire [word_size - 1:0] word_to_UART,		
	output wire bit_from_UART,						
	output wire clk_from_UART,						
	output wire [word_size - 1:0] word_from_UART,	
	output wire XX_error,							
);
wire RX_full;
wire [word_size - 1:0] RX_data;
wire [word_size - 1:0] TX_data;
wire TX_empty;
assign clk_from_UART = internal_clk & !TX_empty;
assign XX_error = (read & !RX_full) | (write & !TX_empty);
assign clk_from_UART = internal_clk & !TX_empty;
RX_word RX(
	.RX_clk(external_clk),
	.RX_bit(bit_to_UART),
	.RX_full,
	.RX_data
);
TX_word TX(
	.TX_data,
	.TX_clk((write | !TX_empty) & internal_clk),
	.TX_bit(bit_from_UART),
	.TX_empty
);
endmodule