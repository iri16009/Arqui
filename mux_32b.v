/*
* Gustavo Ordoñez
* Gabriela Iriarte
* Código extraído de la presentación sinclecyclev2
*/

// Multiplexor de 32 bits
module mux32(input [31:0] a, b, input select, output [31:0] y);

assign y = (select) ? a: b;

endmodule


// Multiplexor de 5 bits
module mux5(input [4:0] a, b, input select, output [4:0] y);

assign y = (select) ? a: b;

endmodule
