// ALU unida jamás será vencida
/*
* Gustavo Ordoñez
* Gabriela Iriarte
*/

`include "divisor_v1.v"
`include "FloatingPoint.v"
`include "multiplicador_v3.v"
`include "Sumador_RestadorV2.v"

module ALU (input clk, input [31:0] A, B, input [5:0] SR, output [31:0] Y);

wire opcomplete;
wire [31:0] residuo;
wire [31:0] multiplicacion, suma, resta, division, sumafp;
reg [31:0] pre_salida, pre_salida2;
// ------INSTANCIAS------ //
add_sub addd(A, B, 0, suma); // suma A+B
add_sub sub(A, B, 1, resta); // resta A-B
// No me recuerdo cuál era la salida real del multiplicador
//multiplicador mult(clk, A, B, output [31:0] resultado, salida,dum); multiplicación A*B
division div(clk, A, B, division, residuo); // división A/B
// No me recuerdo cuál era la salida real del FP
//suma_fp fp(clk, A, B, output [31:0] Y, output  total); // suma A+B

// ---------CASE--------- //
always @ ( posedge clk ) begin
case (SR)
  6'd0: pre_salida = suma;
  6'd1: pre_salida = resta;
  6'd2: pre_salida = multiplicacion;
  6'd3: pre_salida = division;
  6'd4: pre_salida = sumafp;
  default: pre_salida = 6'bz;
endcase

// ¿Indicador sobre operación terminada?

end

assign Y = pre_salida;

endmodule //
