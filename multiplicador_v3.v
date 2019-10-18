/*
* El módulo control_multiplicand toma el lsb y si es 0 entonces suma 0
* si es 1 entonces suma el multiplicando.
*/

module multiplicador (input clk, input [31:0] A, B, output [31:0] resultado, salida,dum, output [4:0] cuenta, output lsb);

reg [31:0] mcand, mplier, aux_out, shift_out, shift_in, aux_in, final_reg;
reg [3:0] count2;
reg [4:0] count;
wire [31:0] dummy_wire;
wire b;
wire [31:0] Shift_reg;

reg ini = 1'b1;

always @ ( negedge clk) begin
  if (ini) begin
//  aux_out <= {8'b0, B[15:0]};
  shift_out <= {8'b0, B[15:0]};
  mcand <= A;
  count <= 5'b0000;
  count2 <= 4'b0000;
  aux_in <= {8'b0, B[15:0]};
  ini <= 1'b0;
  end else begin

  if (count2 == 4'b0000) begin
    count2 = count2 + 1;
  end else begin

  if (count < 5'd16) begin
  aux_in = Shift_reg;
  shift_out = Shift_reg;
  count = count + 1;
  end else if (count == 5'd16) begin
  aux_in = Shift_reg;
  shift_out = Shift_reg;
  final_reg = Shift_reg;
  ini = 1;
  end //else begin

  //end


    end
  end

end
controlador c(clk, count, aux_in, mcand, dummy_wire,dum, b);
//always @ ( posedge clk ) begin
//if (~init) begin
  //if (clk) begin
    //assign aux_out = dummy_wire;
  //end
//end
//end


assign Shift_reg[30:0] = dummy_wire[31:1];
assign Shift_reg[31] = 1'b0;

assign resultado = final_reg;
assign salida = dummy_wire;
assign cuenta = count;
assign lsb = b;

endmodule //multiplicador

module controlador (input clk, input [4:0] cuenta, input [31:0] shift_out, mcand, output [31:0] resultado,dum, output lsb);
reg [31:0] ceros, carga, concatenation1, pre_result;
wire [31:0] suma_0, suma_mcand, load_mcand, load_0, dummy;


//concatenation1 <= {ceros[15:0],shift_out[31:16]};
add_sub alu2( {16'b0,shift_out[31:16]} , 32'b0, 0, suma_0);
add_sub alu(mcand,  {16'b0,shift_out[31:16]}, 0, suma_mcand);

//shift_reg sr1( {suma_mcand[15:0], shift_out[15:0]} , clk, 1, load_mcand);
//shift_reg sr2( {suma_0[15:0], shift_out[15:0]} , clk, 1, load_0);

  always @ ( posedge clk ) begin

if (cuenta != 5'd16) begin
case (shift_out[0])
  1'b0: carga <= {suma_0[15:0], shift_out[15:0]};
  1'b1: carga <= {suma_mcand[15:0], shift_out[15:0]};
  default: carga <= 32'bz;
endcase
end



  end
/*
  always @ ( negedge clk ) begin
    pre_result = Shift_reg;
  end*/

  //shift_reg_s sh(pre_result, clk, 0, resultado);
 assign resultado = carga;
 assign lsb = shift_out[0];
 assign dum = carga;
endmodule // controlador

/*
* PISO Shift register
* Parallel input - Serial output
* Queremos que deje pasar
*/

module shift_reg(input [31:0] entrada, input clk, S, output [31:0] Z);

  reg [31:0] X;
  reg b;
  wire [31:0] Shift_reg;
  wire [31:0] Shift_Parallel;

  assign Shift_reg[30:0] = entrada[31:1];
  assign Shift_reg[31] = 0;

  always @(posedge clk)
      begin
        case(S)
          1'b0: X = Shift_reg;  // si es 0 entonces hacer shift (entrada a salida cruzada)
          1'b1: X = entrada;    // si es 1 entonces conectar entrada a salida
          default: X = 32'dz;
        endcase
      end
assign Z = X;
endmodule

module shift_reg_s(input [31:0] entrada, input clk, S, output [31:0] Z);

  reg [31:0] X;
  reg b;
  wire [31:0] Shift_reg;
  wire [31:0] Shift_Parallel;

  assign Shift_reg[30:0] = entrada[31:1];
  assign Shift_reg[31] = 0;

  always @(negedge clk)
      begin
        case(S)
          1'b0: X = Shift_reg;  // si es 0 entonces hacer shift (entrada a salida cruzada)
          1'b1: X = entrada;    // si es 1 entonces conectar entrada a salida
          default: X = 32'dz;
        endcase
      end
assign Z = X;
endmodule


/*Mux salvador*/

module mux_init( input [4:0] contador, input [31:0] ent , output [31:0] sal );
reg[31:0] X;
  always @(contador, ent)
    begin
      case(contador)
        5'b00000: X = 32'd0;
        default: X = ent;//; // ent
      endcase
    end
    assign sal = X;
endmodule


/*
* El módulo control_multplier deja pasar una entrada si el contador termina
* y si no, deja pasar lo mismo siempre. Sirve para que en el inicio, este
* deje pasar el multiplier y el resto del tiempo se pase a sí mismo.
* El contador de este módulo funciona en los flancos de reloj positivos y es de
* 5 bits.
*/

module control_multplier(input [31:0] A, B, input clk, output [31:0] Y, output [4:0] Cuenta);

  reg[31:0] X;
  reg[4:0] contador = 5'b11111;

  always @(posedge clk)
    begin
      contador = contador + 5'b00001;
    end

  always @(contador)
    begin
      case(contador)
        5'b00000: X = A;
        default: X = B;
      endcase
    end

  assign Y = X;
  assign Cuenta = contador;

endmodule

/*
* El módulo control_multiplicand toma el lsb y si es 0 entonces suma 0
* si es 1 entonces suma el multiplicando.
*/

module control_multiplicand (input clk, S, input [31:0] E, output [31:0] Y);

  reg[31:0] X;

  always @(clk or E or S)
    case(S)
      1'b0: X = 32'd0;
      1'b1: X = E;
      default: X = 32'd0;
    endcase

  assign Y = X;


endmodule

/*
 * El módulo add_sub es el sumador restador
*/

module add_sub(input [31:0] A, B, input SR, output [31:0] Y);

wire [32:0] C_outb;
wire [31:0] K, S, C_out;
reg[31:0] C;
wire[31:0] cable_a, cable_b, cable_c;
wire[31:0] ca, cb, cc;

assign K=~B;


//    INICIO DE LAS INSTANCIAS DEL FULL ADDER
// ---------------- COMPLEMENTO A2 -----------------

// INSTANCIA 0
and and_a_i0 (cable_a[0], K[0], 1);
and and_b_i0 (cable_b[0], 1, 0);
and and_c_i0 (cable_c[0], K[0], 0);

xor xor_i0   (S[0], K[0], 1,0);
or  or_i0    (C_out[0], cable_a[0], cable_b[0], cable_c[0]);

// INSTANCIA 1
and and_a_i1 (cable_a[1], K[1], 0);
and and_b_i1 (cable_b[1], 0, C_out[0]);
and and_c_i1 (cable_c[1], K[1], C_out[0]);

xor xor_i1   (S[1], K[1], 0, C_out[0]);
or  or_i1    (C_out[1], cable_a[1], cable_b[1], cable_c[1]);

// INSTANCIA 2
and and_a_i2 (cable_a[2], K[2], 0);
and and_b_i2 (cable_b[2], 0, C_out[1]);
and and_c_i2 (cable_c[2], K[2], C_out[1]);

xor xor_i2   (S[2], K[2], 0, C_out[1]);
or  or_i2    (C_out[2], cable_a[2], cable_b[2], cable_c[2]);

// INSTANCIA 3
and and_a_i3 (cable_a[3], K[3], 0);
and and_b_i3 (cable_b[3], 0, C_out[2]);
and and_c_i3 (cable_c[3], K[3], C_out[2]);

xor xor_i3   (S[3], K[3], 0, C_out[2]);
or  or_i3    (C_out[3], cable_a[3], cable_b[3], cable_c[3]);

// INSTANCIA 4
and and_a_i4 (cable_a[4], K[4], 0);
and and_b_i4 (cable_b[4], 0, C_out[3]);
and and_c_i4 (cable_c[4], K[4], C_out[3]);

xor xor_i4   (S[4], K[4], 0, C_out[3]);
or  or_i4    (C_out[4], cable_a[4], cable_b[4], cable_c[4]);

// INSTANCIA 5
and and_a_i5 (cable_a[5], K[5], 0);
and and_b_i5 (cable_b[5], 0, C_out[4]);
and and_c_i5 (cable_c[5], K[5], C_out[4]);

xor xor_i5   (S[5], K[5], 0, C_out[4]);
or  or_i5    (C_out[5], cable_a[5], cable_b[5], cable_c[5]);

// INSTANCIA 6
and and_a_i6 (cable_a[6], K[6], 0);
and and_b_i6 (cable_b[6], 0, C_out[5]);
and and_c_i6 (cable_c[6], K[6], C_out[5]);

xor xor_i6   (S[6], K[6], 0, C_out[5]);
or  or_i6    (C_out[6], cable_a[6], cable_b[6], cable_c[6]);

// INSTANCIA 7
and and_a_i7 (cable_a[7], K[7], 0);
and and_b_i7 (cable_b[7], 0, C_out[6]);
and and_c_i7 (cable_c[7], K[7], C_out[6]);

xor xor_i7   (S[7], K[7], 0, C_out[6]);
or  or_i7    (C_out[7], cable_a[7], cable_b[7], cable_c[7]);

// INSTANCIA 8
and and_a_i8 (cable_a[8], K[8], 0);
and and_b_i8 (cable_b[8], 0, C_out[7]);
and and_c_i8 (cable_c[8], K[8], C_out[7]);

xor xor_i8   (S[8], K[8], 0, C_out[7]);
or  or_i8    (C_out[8], cable_a[8], cable_b[8], cable_c[8]);

// INSTANCIA 9
and and_a_i9 (cable_a[9], K[9], 0);
and and_b_i9 (cable_b[9], 0, C_out[8]);
and and_c_i9 (cable_c[9], K[9], C_out[8]);

xor xor_i9   (S[9], K[9], 0, C_out[8]);
or  or_i9    (C_out[9], cable_a[9], cable_b[9], cable_c[9]);

// INSTANCIA 10
and and_a_i10 (cable_a[10], K[10], 0);
and and_b_i10 (cable_b[10], 0, C_out[9]);
and and_c_i10 (cable_c[10], K[10], C_out[9]);

xor xor_i10   (S[10], K[10], 0, C_out[9]);
or  or_i10    (C_out[10], cable_a[10], cable_b[10], cable_c[10]);

// INSTANCIA 11
and and_a_i11 (cable_a[11], K[11], 0);
and and_b_i11 (cable_b[11], 0, C_out[10]);
and and_c_i11 (cable_c[11], K[11], C_out[10]);

xor xor_i11   (S[11], K[11], 0, C_out[10]);
or  or_i11    (C_out[11], cable_a[11], cable_b[11], cable_c[11]);

// INSTANCIA 12
and and_a_i12 (cable_a[12], K[12], 0);
and and_b_i12 (cable_b[12], 0, C_out[11]);
and and_c_i12 (cable_c[12], K[12], C_out[11]);

xor xor_i12   (S[12], K[12], 0, C_out[11]);
or  or_i12    (C_out[12], cable_a[12], cable_b[12], cable_c[12]);

// INSTANCIA 13
and and_a_i13 (cable_a[13], K[13], 0);
and and_b_i13 (cable_b[13], 0, C_out[12]);
and and_c_i13 (cable_c[13], K[13], C_out[12]);

xor xor_i13   (S[13], K[13], 0, C_out[12]);
or  or_i13    (C_out[13], cable_a[13], cable_b[13], cable_c[13]);

// INSTANCIA 14
and and_a_i14 (cable_a[14], K[14], 0);
and and_b_i14 (cable_b[14], 0, C_out[13]);
and and_c_i14 (cable_c[14], K[14], C_out[13]);

xor xor_i14   (S[14], K[14], 0, C_out[13]);
or  or_i14    (C_out[14], cable_a[14], cable_b[14], cable_c[14]);

// INSTANCIA 15
and and_a_i15 (cable_a[15], K[15], 0);
and and_b_i15 (cable_b[15], 0, C_out[14]);
and and_c_i15 (cable_c[15], K[15], C_out[14]);

xor xor_i15   (S[15], K[15], 0, C_out[14]);
or  or_i15    (C_out[15], cable_a[15], cable_b[15], cable_c[15]);

// INSTANCIA 16
and and_a_i16 (cable_a[16], K[16], 0);
and and_b_i16 (cable_b[16], 0, C_out[15]);
and and_c_i16 (cable_c[16], K[16], C_out[15]);

xor xor_i16   (S[16], K[16], 0, C_out[15]);
or  or_i16    (C_out[16], cable_a[16], cable_b[16], cable_c[16]);

// INSTANCIA 17
and and_a_i17 (cable_a[17], K[17], 0);
and and_b_i17 (cable_b[17], 0, C_out[16]);
and and_c_i17 (cable_c[17], K[17], C_out[16]);

xor xor_i17   (S[17], K[17], 0, C_out[16]);
or  or_i17    (C_out[17], cable_a[17], cable_b[17], cable_c[17]);

// INSTANCIA 18
and and_a_i18 (cable_a[18], K[18], 0);
and and_b_i18 (cable_b[18], 0, C_out[17]);
and and_c_i18 (cable_c[18], K[18], C_out[17]);

xor xor_i18   (S[18], K[18], 0, C_out[17]);
or  or_i18    (C_out[18], cable_a[18], cable_b[18], cable_c[18]);

// INSTANCIA 19
and and_a_i19 (cable_a[19], K[19], 0);
and and_b_i19 (cable_b[19], 0, C_out[18]);
and and_c_i19 (cable_c[19], K[19], C_out[18]);

xor xor_i19   (S[19], K[19], 0, C_out[18]);
or  or_i19    (C_out[19], cable_a[19], cable_b[19], cable_c[19]);

// INSTANCIA 20
and and_a_i20 (cable_a[20], K[20], 0);
and and_b_i20 (cable_b[20], 0, C_out[19]);
and and_c_i20 (cable_c[20], K[20], C_out[19]);

xor xor_i20   (S[20], K[20], 0, C_out[19]);
or  or_i20    (C_out[20], cable_a[20], cable_b[20], cable_c[20]);

// INSTANCIA 21
and and_a_i21 (cable_a[21], K[21], 0);
and and_b_i21 (cable_b[21], 0, C_out[20]);
and and_c_i21 (cable_c[21], K[21], C_out[20]);

xor xor_i21   (S[21], K[21], 0, C_out[20]);
or  or_i21    (C_out[21], cable_a[21], cable_b[21], cable_c[21]);

// INSTANCIA 22
and and_a_i22 (cable_a[22], K[22], 0);
and and_b_i22 (cable_b[22], 0, C_out[21]);
and and_c_i22 (cable_c[22], K[22], C_out[21]);

xor xor_i22   (S[22], K[22], 0, C_out[21]);
or  or_i22    (C_out[22], cable_a[22], cable_b[22], cable_c[22]);

// INSTANCIA 23
and and_a_i23 (cable_a[23], K[23], 0);
and and_b_i23 (cable_b[23], 0, C_out[22]);
and and_c_i23 (cable_c[23], K[23], C_out[22]);

xor xor_i23   (S[23], K[23], 0, C_out[22]);
or  or_i23    (C_out[23], cable_a[23], cable_b[23], cable_c[23]);

// INSTANCIA 24
and and_a_i24 (cable_a[24], K[24], 0);
and and_b_i24 (cable_b[24], 0, C_out[23]);
and and_c_i24 (cable_c[24], K[24], C_out[23]);

xor xor_i24   (S[24], K[24], 0, C_out[23]);
or  or_i24    (C_out[24], cable_a[24], cable_b[24], cable_c[24]);

// INSTANCIA 25
and and_a_i25 (cable_a[25], K[25], 0);
and and_b_i25 (cable_b[25], 0, C_out[24]);
and and_c_i25 (cable_c[25], K[25], C_out[24]);

xor xor_i25   (S[25], K[25], 0, C_out[24]);
or  or_i25    (C_out[25], cable_a[25], cable_b[25], cable_c[25]);

// INSTANCIA 26
and and_a_i26 (cable_a[26], K[26], 0);
and and_b_i26 (cable_b[26], 0, C_out[25]);
and and_c_i26 (cable_c[26], K[26], C_out[25]);

xor xor_i26   (S[26], K[26], 0, C_out[25]);
or  or_i26    (C_out[26], cable_a[26], cable_b[26], cable_c[26]);

// INSTANCIA 27
and and_a_i27 (cable_a[27], K[27], 0);
and and_b_i27 (cable_b[27], 0, C_out[26]);
and and_c_i27 (cable_c[27], K[27], C_out[26]);

xor xor_i27   (S[27], K[27], 0, C_out[26]);
or  or_i27    (C_out[27], cable_a[27], cable_b[27], cable_c[27]);

// INSTANCIA 28
and and_a_i28 (cable_a[28], K[28], 0);
and and_b_i28 (cable_b[28], 0, C_out[27]);
and and_c_i28 (cable_c[28], K[28], C_out[27]);

xor xor_i28   (S[28], K[28], 0, C_out[27]);
or  or_i28    (C_out[28], cable_a[28], cable_b[28], cable_c[28]);

// INSTANCIA 29
and and_a_i29 (cable_a[29], K[29], 0);
and and_b_i29 (cable_b[29], 0, C_out[28]);
and and_c_i29 (cable_c[29], K[29], C_out[28]);

xor xor_i29   (S[29], K[29], 0, C_out[28]);
or  or_i29    (C_out[29], cable_a[29], cable_b[29], cable_c[29]);

// INSTANCIA 30
and and_a_i30 (cable_a[30], K[30], 0);
and and_b_i30 (cable_b[30], 0, C_out[29]);
and and_c_i30 (cable_c[30], K[30], C_out[29]);

xor xor_i30   (S[30], K[30], 0, C_out[29]);
or  or_i30    (C_out[30], cable_a[30], cable_b[30], cable_c[30]);

// INSTANCIA 31
and and_a_i31 (cable_a[31], K[31], 0);
and and_b_i31 (cable_b[31], 0, C_out[30]);
and and_c_i31 (cable_c[31], K[31], C_out[30]);

xor xor_i31   (S[31], K[31], 0, C_out[30]);
or  or_i31    (C_out[31], cable_a[31], cable_b[31], cable_c[31]);


always @(SR or A or B)
  case(SR)
    1'b0: C = B;
    1'b1: C = S;
    default: C = 0;
endcase

// ----------------- Conectar los full adder --------------------

// INSTANCIA 0
and and_a_j0(ca[0], A[0], C[0]);
and and_b_j0(cb[0], C[0], 0);
and and_c_j0(cc[0], A[0], 0);
xor xor_a_j0(Y[0], A[0], C[0], 0);
or  or_a_j0(C_outb[1], ca[0], cb[0], cc[0]);

// INSTANCIA 1
and and_a_j1(ca[1], A[1], C[1]);
and and_b_j1(cb[1], C[1], C_outb[1]);
and and_c_j1(cc[1], A[1], C_outb[1]);
xor xor_a_j1(Y[1], A[1], C[1], C_outb[1]);
or  or_a_j1(C_outb[2], ca[1], cb[1], cc[1]);

// INSTANCIA 2
and and_a_j2(ca[2], A[2], C[2]);
and and_b_j2(cb[2], C[2], C_outb[2]);
and and_c_j2(cc[2], A[2], C_outb[2]);
xor xor_a_j2(Y[2], A[2], C[2], C_outb[2]);
or  or_a_j2(C_outb[3], ca[2], cb[2], cc[2]);

// INSTANCIA 3
and and_a_j3(ca[3], A[3], C[3]);
and and_b_j3(cb[3], C[3], C_outb[3]);
and and_c_j3(cc[3], A[3], C_outb[3]);
xor xor_a_j3(Y[3], A[3], C[3], C_outb[3]);
or  or_a_j3(C_outb[4], ca[3], cb[3], cc[3]);

// INSTANCIA 4
and and_a_j4(ca[4], A[4], C[4]);
and and_b_j4(cb[4], C[4], C_outb[4]);
and and_c_j4(cc[4], A[4], C_outb[4]);
xor xor_a_j4(Y[4], A[4], C[4], C_outb[4]);
or  or_a_j4(C_outb[5], ca[4], cb[4], cc[4]);

// INSTANCIA 5
and and_a_j5(ca[5], A[5], C[5]);
and and_b_j5(cb[5], C[5], C_outb[5]);
and and_c_j5(cc[5], A[5], C_outb[5]);
xor xor_a_j5(Y[5], A[5], C[5], C_outb[5]);
or  or_a_j5(C_outb[6], ca[5], cb[5], cc[5]);

// INSTANCIA 6
and and_a_j6(ca[6], A[6], C[6]);
and and_b_j6(cb[6], C[6], C_outb[6]);
and and_c_j6(cc[6], A[6], C_outb[6]);
xor xor_a_j6(Y[6], A[6], C[6], C_outb[6]);
or  or_a_j6(C_outb[7], ca[6], cb[6], cc[6]);

// INSTANCIA 7
and and_a_j7(ca[7], A[7], C[7]);
and and_b_j7(cb[7], C[7], C_outb[7]);
and and_c_j7(cc[7], A[7], C_outb[7]);
xor xor_a_j7(Y[7], A[7], C[7], C_outb[7]);
or  or_a_j7(C_outb[8], ca[7], cb[7], cc[7]);

// INSTANCIA 8
and and_a_j8(ca[8], A[8], C[8]);
and and_b_j8(cb[8], C[8], C_outb[8]);
and and_c_j8(cc[8], A[8], C_outb[8]);
xor xor_a_j8(Y[8], A[8], C[8], C_outb[8]);
or  or_a_j8(C_outb[9], ca[8], cb[8], cc[8]);

// INSTANCIA 9
and and_a_j9(ca[9], A[9], C[9]);
and and_b_j9(cb[9], C[9], C_outb[9]);
and and_c_j9(cc[9], A[9], C_outb[9]);
xor xor_a_j9(Y[9], A[9], C[9], C_outb[9]);
or  or_a_j9(C_outb[10], ca[9], cb[9], cc[9]);

// INSTANCIA 10
and and_a_j10(ca[10], A[10], C[10]);
and and_b_j10(cb[10], C[10], C_outb[10]);
and and_c_j10(cc[10], A[10], C_outb[10]);
xor xor_a_j10(Y[10], A[10], C[10], C_outb[10]);
or  or_a_j10(C_outb[11], ca[10], cb[10], cc[10]);

// INSTANCIA 11
and and_a_j11(ca[11], A[11], C[11]);
and and_b_j11(cb[11], C[11], C_outb[11]);
and and_c_j11(cc[11], A[11], C_outb[11]);
xor xor_a_j11(Y[11], A[11], C[11], C_outb[11]);
or  or_a_j11(C_outb[12], ca[11], cb[11], cc[11]);

// INSTANCIA 12
and and_a_j12(ca[12], A[12], C[12]);
and and_b_j12(cb[12], C[12], C_outb[12]);
and and_c_j12(cc[12], A[12], C_outb[12]);
xor xor_a_j12(Y[12], A[12], C[12], C_outb[12]);
or  or_a_j12(C_outb[13], ca[12], cb[12], cc[12]);

// INSTANCIA 13
and and_a_j13(ca[13], A[13], C[13]);
and and_b_j13(cb[13], C[13], C_outb[13]);
and and_c_j13(cc[13], A[13], C_outb[13]);
xor xor_a_j13(Y[13], A[13], C[13], C_outb[13]);
or  or_a_j13(C_outb[14], ca[13], cb[13], cc[13]);

// INSTANCIA 14
and and_a_j14(ca[14], A[14], C[14]);
and and_b_j14(cb[14], C[14], C_outb[14]);
and and_c_j14(cc[14], A[14], C_outb[14]);
xor xor_a_j14(Y[14], A[14], C[14], C_outb[14]);
or  or_a_j14(C_outb[15], ca[14], cb[14], cc[14]);

// INSTANCIA 15
and and_a_j15(ca[15], A[15], C[15]);
and and_b_j15(cb[15], C[15], C_outb[15]);
and and_c_j15(cc[15], A[15], C_outb[15]);
xor xor_a_j15(Y[15], A[15], C[15], C_outb[15]);
or  or_a_j15(C_outb[16], ca[15], cb[15], cc[15]);

// INSTANCIA 16
and and_a_j16(ca[16], A[16], C[16]);
and and_b_j16(cb[16], C[16], C_outb[16]);
and and_c_j16(cc[16], A[16], C_outb[16]);
xor xor_a_j16(Y[16], A[16], C[16], C_outb[16]);
or  or_a_j16(C_outb[17], ca[16], cb[16], cc[16]);

// INSTANCIA 17
and and_a_j17(ca[17], A[17], C[17]);
and and_b_j17(cb[17], C[17], C_outb[17]);
and and_c_j17(cc[17], A[17], C_outb[17]);
xor xor_a_j17(Y[17], A[17], C[17], C_outb[17]);
or  or_a_j17(C_outb[18], ca[17], cb[17], cc[17]);

// INSTANCIA 18
and and_a_j18(ca[18], A[18], C[18]);
and and_b_j18(cb[18], C[18], C_outb[18]);
and and_c_j18(cc[18], A[18], C_outb[18]);
xor xor_a_j18(Y[18], A[18], C[18], C_outb[18]);
or  or_a_j18(C_outb[19], ca[18], cb[18], cc[18]);

// INSTANCIA 19
and and_a_j19(ca[19], A[19], C[19]);
and and_b_j19(cb[19], C[19], C_outb[19]);
and and_c_j19(cc[19], A[19], C_outb[19]);
xor xor_a_j19(Y[19], A[19], C[19], C_outb[19]);
or  or_a_j19(C_outb[20], ca[19], cb[19], cc[19]);

// INSTANCIA 20
and and_a_j20(ca[20], A[20], C[20]);
and and_b_j20(cb[20], C[20], C_outb[20]);
and and_c_j20(cc[20], A[20], C_outb[20]);
xor xor_a_j20(Y[20], A[20], C[20], C_outb[20]);
or  or_a_j20(C_outb[21], ca[20], cb[20], cc[20]);

// INSTANCIA 21
and and_a_j21(ca[21], A[21], C[21]);
and and_b_j21(cb[21], C[21], C_outb[21]);
and and_c_j21(cc[21], A[21], C_outb[21]);
xor xor_a_j21(Y[21], A[21], C[21], C_outb[21]);
or  or_a_j21(C_outb[22], ca[21], cb[21], cc[21]);

// INSTANCIA 22
and and_a_j22(ca[22], A[22], C[22]);
and and_b_j22(cb[22], C[22], C_outb[22]);
and and_c_j22(cc[22], A[22], C_outb[22]);
xor xor_a_j22(Y[22], A[22], C[22], C_outb[22]);
or  or_a_j22(C_outb[23], ca[22], cb[22], cc[22]);

// INSTANCIA 23
and and_a_j23(ca[23], A[23], C[23]);
and and_b_j23(cb[23], C[23], C_outb[23]);
and and_c_j23(cc[23], A[23], C_outb[23]);
xor xor_a_j23(Y[23], A[23], C[23], C_outb[23]);
or  or_a_j23(C_outb[24], ca[23], cb[23], cc[23]);

// INSTANCIA 24
and and_a_j24(ca[24], A[24], C[24]);
and and_b_j24(cb[24], C[24], C_outb[24]);
and and_c_j24(cc[24], A[24], C_outb[24]);
xor xor_a_j24(Y[24], A[24], C[24], C_outb[24]);
or  or_a_j24(C_outb[25], ca[24], cb[24], cc[24]);

// INSTANCIA 25
and and_a_j25(ca[25], A[25], C[25]);
and and_b_j25(cb[25], C[25], C_outb[25]);
and and_c_j25(cc[25], A[25], C_outb[25]);
xor xor_a_j25(Y[25], A[25], C[25], C_outb[25]);
or  or_a_j25(C_outb[26], ca[25], cb[25], cc[25]);

// INSTANCIA 26
and and_a_j26(ca[26], A[26], C[26]);
and and_b_j26(cb[26], C[26], C_outb[26]);
and and_c_j26(cc[26], A[26], C_outb[26]);
xor xor_a_j26(Y[26], A[26], C[26], C_outb[26]);
or  or_a_j26(C_outb[27], ca[26], cb[26], cc[26]);

// INSTANCIA 27
and and_a_j27(ca[27], A[27], C[27]);
and and_b_j27(cb[27], C[27], C_outb[27]);
and and_c_j27(cc[27], A[27], C_outb[27]);
xor xor_a_j27(Y[27], A[27], C[27], C_outb[27]);
or  or_a_j27(C_outb[28], ca[27], cb[27], cc[27]);

// INSTANCIA 28
and and_a_j28(ca[28], A[28], C[28]);
and and_b_j28(cb[28], C[28], C_outb[28]);
and and_c_j28(cc[28], A[28], C_outb[28]);
xor xor_a_j28(Y[28], A[28], C[28], C_outb[28]);
or  or_a_j28(C_outb[29], ca[28], cb[28], cc[28]);

// INSTANCIA 29
and and_a_j29(ca[29], A[29], C[29]);
and and_b_j29(cb[29], C[29], C_outb[29]);
and and_c_j29(cc[29], A[29], C_outb[29]);
xor xor_a_j29(Y[29], A[29], C[29], C_outb[29]);
or  or_a_j29(C_outb[30], ca[29], cb[29], cc[29]);

// INSTANCIA 30
and and_a_j30(ca[30], A[30], C[30]);
and and_b_j30(cb[30], C[30], C_outb[30]);
and and_c_j30(cc[30], A[30], C_outb[30]);
xor xor_a_j30(Y[30], A[30], C[30], C_outb[30]);
or  or_a_j30(C_outb[31], ca[30], cb[30], cc[30]);

// INSTANCIA 31
and and_a_j31(ca[31], A[31], C[31]);
and and_b_j31(cb[31], C[31], C_outb[31]);
and and_c_j31(cc[31], A[31], C_outb[31]);
xor xor_a_j31(Y[31], A[31], C[31], C_outb[31]);
or  or_a_j31(C_outb[32], ca[31], cb[31], cc[31]);

endmodule

//// Stimulus Block
//
//module Stimulus;
//
//reg clk;
//wire [31:0] Y,Z;
//wire [31:0] so;
//wire [31:0] entrada;
//reg [31:0] A,B, prueba;
//reg [31:0] C;
//wire [4:0] cc, c2;
//wire [4:0] kk;
//reg [4:0] contador = 5'd0;
//wire S;
//reg bb, init;
//wire b;
//wire [15:0] ou;
//
// multiplicador m(clk, A, B, Y, Z,so, kk, b,S);
//
//
//initial
//  clk = 0;                                   // Set clock to 0
//always
//begin
//  #5 clk = ~clk;                                // Toggle every 5 time units
//
//end
//
//always @ ( posedge clk ) begin
//  contador = contador + 1;
//end
//
//initial
//begin
//  //init = 1'd1;
//  A =  32'd5;
//  B =  32'd9;
//  #150 B =  32'd11;
//  #300 A =  32'd90;
////  #7 init = 1'd0;
//  //entrada = 32'd6;
//  #400 $finish;                                // terminate simulation
//end
//
//// Monitor the outputs
//
//initial
//
// $monitor($time, " clk:%b init:%b aux_in = %b aux_out:%b c:%d b:%b sum: %b", clk, S, Y, Z, kk, b,so);
////$monitor($time, " %d x %d = %d ", A, B, Y);
//endmodule

/*
module Stimulus;

reg clk;
wire [31:0] Y,Z;
wire [31:0] so;
wire [31:0] entrada;
reg [31:0] A,B, prueba;
reg [31:0] C;
wire [4:0] cc, c2;
reg [4:0] contador = 5'd0;
reg S;
reg bb, init;
wire b;
wire [15:0] ou;

 controlador c(clk, C, 32'd5, Y);

initial
  clk = 0;                                   // Set clock to 0
always
begin
  #5 clk = ~clk;                                // Toggle every 5 time units

end

always @ ( posedge clk ) begin
  contador = contador + 1;
end

initial
begin
  C = 32'b00000000000000000000000000000100;
#10 A = Y;
 C = A;
  #15 init = 1'd0;
  #5 init = 1'd1;
  #5 init = 1'd0;
  //entrada = 32'd6;
  #200 $finish;                                // terminate simulation
end

// Monitor the outputs

initial
  //$monitor("clk:%d shift_in = %b  shift_out = %b cuenta = %b", clk, so, Y, cc);
  $monitor($time, " clk:%b out = %b ", clk,Y);

endmodule
*/
