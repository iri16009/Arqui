module division(input clk, input [31:0] dividendo, divisor, output [31:0] cociente, residuo);

reg [31:0] shift_register;
reg [31:0] pre_divisor = 0;
reg [31:0] cont = 0;
reg start = 1;
reg [15:0] resta, pre_cocido, res, cocido;

always @ (posedge clk) begin

  if(start) begin

    cont = 32'b0;
    shift_register = {8'b0, dividendo[15:0]};
    pre_cocido = 16'b0;
    pre_divisor = divisor;
    shift_register = shift_register << 1;
    cont = cont + 1'b1;
    start = 1'b0;

  end else begin

    if (cont < 5'd17) begin

      if(shift_register[31:16] < pre_divisor[15:0])begin

        pre_cocido = pre_cocido << 1;

      end else begin

        resta = shift_register[31:16] - pre_divisor[15:0];
        pre_cocido = pre_cocido << 1;
        pre_cocido[0] = 1'b1;
        shift_register[31:16] = resta;

      end

    shift_register = shift_register << 1;
    cont = cont + 1'b1;


    end else begin

      cocido = pre_cocido;
      res = shift_register[31:16]>>1;
      start = 1'b1;

    end

  end


end


assign cociente = {16'b0, cocido};
assign residuo = {16'b0, res};

//assign cociente = {16'b0, cocido};
//assign cuenta = cont;
//assign residuo = shift_register;



endmodule
