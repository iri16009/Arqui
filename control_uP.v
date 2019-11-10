// ALU unida jamás será vencida
/*
* Gustavo Ordoñez
* Gabriela Iriarte
*/


module control (input [5:0] op, output reg_dst, alu_src, we, w_src, reg_wr, output [5:0] alu_ctr);

reg reg_dstx, alu_srcx, wex, w_srcx, reg_wrx;
reg [5:0] alu_ctrx;

always @ ( * ) begin

  if (op[5] == 1'b0) begin // usar la alu

  // R[rd] <-- R[rs] op R[rt]

  alu_srcx = 1'b1;        // deja pasar busB
  reg_dstx = 1'b1;        // deja pasar Rd
  alu_ctrx = op;          // pasa el op
  wex = 1'b0;             // MemWr = 0 (lectura) RAM
  w_srcx = 1'b1;          // deja pasar ALU
  reg_wrx = 1'b1;         // creo que aqui deberia ser 1

  end else if (op[5:4] == 2'b10) begin // load

  // R[rt] <-- RAM[ R[rs] + imm16 ]

  alu_srcx = 1'b0;        // deja pasar extender
  reg_dstx = 1'b0;        // deja pasar Rt
  alu_ctrx = 6'b000000;   // suma
  wex = 1'b0;             // MemWr = 0 (lectura) RAM
  w_srcx = 1'b0;          // deja pasar mem data
  reg_wrx = 1'b1;         // creo que debería de ser 1

  end else if (op[5:4] == 2'b11) begin // store

  alu_srcx = 1'b0;        // deja pasar extender
  reg_dstx = 1'b0;        // deja pasar Rt
  alu_ctrx = 6'b000000;   // suma
  wex = 1'b1;             // MemWr = 1 (escritura) RAM
  w_srcx = 1'b0;          // deja pasar mem data
  reg_wrx = 1'b0;         // creo que debería de ser 0

  end else if (op[5:3] == 3'b111) begin // op con imm16

  // R[rt] <-- R[rs] op imm16

  alu_srcx = 1'b0;                // deja pasar extender
  reg_dstx = 1'b0;                // deja pasar Rt
  alu_ctrx = {3'b000, op[2:0]};   // extraemos la operación y la extendemos
  wex = 1'b0;                     // MemWr = 0 (lectura) RAM
  w_srcx = 1'b1;                  // deja pasar ALU
  reg_wrx = 1'b1;                 // creo que debería de ser 1

  end

end // always

assign reg_dst = reg_dstx;
assign alu_src = alu_srcx;
assign we = wex;
assign w_src = w_srcx;
assign reg_wr = reg_wrx;
assign alu_ctr = alu_ctrx;

endmodule // control
