module suma_fp(input clk, input [31:0] A, B, output [31:0] Y, output  total);

reg start = 1'b1;             // Bit de inicio
reg [31:0] A_capt, B_capt;    // Capturamos los números a operar
reg [23:0] upMA, upMB;        // Guardamos 1.Mantissa
reg [7:0] eA, eB;             // Guardamos los exponentes
reg shift_listo;              // Bandera que se enciende cuando los exponentes son iguales
reg suma_lista;               // Bandera para saber si ya se realizó la suma cuando A o B es negativo
reg [31:0] cont_shift, cont_neg;
reg [7:0] veces_shift;        // Lleva la cuenta de las veces que se necesita hacer shift
reg caerle_encima;            // Si el resultado de la suma es negativo al final de hacerle 2's comp hay que caerle encima al bit de signo
reg comparador, flag;
reg normalizado;              // Bandera que indica si ya toca hacer el proceso de normalizado cuando A^B=1
reg signoA, signoB;
reg [24:0] comp2_A, comp2_B, posA, posB, res_mantissa;
reg [31:0] resultado_final;
reg dummy = 0;

always @ (posedge clk) begin

  if (start) begin
    flag = 1'b0;
    cont_neg = 32'b0;
    cont_shift = 32'b0;
    upMA = {1'b1, A[22:0]};
    upMB = {1'b1, B[22:0]};
    eA = A[30:23];
    eB = B[30:23];
    signoA = A[31];
    signoB = B[31];
    shift_listo = 1'b0;
    suma_lista = 1'b0;
    caerle_encima = 1'b0;
    dummy = 0;
    normalizado = 1'b0;
    if (eA > eB) begin
      veces_shift = eA-eB;
      comparador = 1'b0;

    end else if (eA < eB) begin
      veces_shift = eB-eA;
      comparador = 1'b1;

    end else begin
      veces_shift = 0;

    end

    start = 1'b0;

  end else begin

  if (cont_shift == veces_shift) begin
      shift_listo = 1;

  end else begin

      if(comparador)begin
         upMA = upMA >> 1;
         eA = eA + 1;
      end else begin
         upMB = upMB >> 1;
         eB = eB + 1;
      end

      cont_shift = cont_shift + 1'b1;

  end


  if (shift_listo == 1) begin        // shift listo




     if(signoA ^ signoB)begin       // signo

     if (suma_lista == 0) begin     // suma no lista?

       comp2_A = {1'b1, ~(upMA)+1'b1};
       comp2_B = {1'b1, ~(upMB)+1'b1};

       if(signoA)begin              // Identificamos cuál es el negativo
           posB = {1'b0, upMB};
           posA = comp2_A;
        end else begin
           posA = {1'b0, upMA};
           posB = comp2_B;
        end                          // end Identificamos cuál es el negativo

        res_mantissa = posA + posB;

        if (res_mantissa[24]) begin   // resultado es negativo?
          res_mantissa = ~(res_mantissa)+1'b1;
          caerle_encima = 1'b1;
        end                           // end resultado es negativo?

        suma_lista = 1'b1;

     end else begin                 // suma ya lista



        if (res_mantissa[24:23] == 2'b01) begin // casos
            normalizado = 1'b1;
        end else if (res_mantissa[24:23] == 2'b00) begin // casos
            res_mantissa = res_mantissa << 1;
            eA = eA - 1;
        end else begin        // casos
            res_mantissa = res_mantissa >> 1;
            eA = eA + 1;
            normalizado = 1'b1;
        end   // casos



        if (normalizado) begin        // normalizado


            if (caerle_encima) begin    // el resultado fue negativo
              res_mantissa[24] = 1'b1;
            end                         // end el resultado fue negativo

            resultado_final={res_mantissa[24], eA, res_mantissa[22:0]};
            start = 1'b1;


        end           // normalizado




     end                            // end suma no lista






     end else begin       // else signo XOR

          posA = {1'b0, upMA};
          posB = {1'b0, upMB};
          res_mantissa = posA + posB;

         if(res_mantissa[23]==0)begin
            dummy = 1;
             res_mantissa = res_mantissa >> 1;
             eA = eA + 1;
         end else if (res_mantissa[24]) begin

              res_mantissa = res_mantissa >> 1;
             eA = eA + 1;
             end

         res_mantissa[24] = signoA && signoB;
         resultado_final={res_mantissa[24], eA, res_mantissa[22:0]};
         start = 1'b1;
     end                  // end signo





  end // shift listo

end // end del else del if(start)

end // end del always

assign Y = resultado_final;
assign total = dummy;

endmodule
