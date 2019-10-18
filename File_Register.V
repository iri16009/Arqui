// Register Memory
module regmem (clk,regwrite,raddr1,raddr2,waddr,rdata1,rdata2,wdata);

 input clk,regwrite;
 input [4:0] raddr1,raddr2,waddr;
 input [31:0] wdata;
 output [31:0] rdata1,rdata2;

 reg [31:0] mem[3:0];

 always @(posedge clk)

// Register file write on positive edge of clock.
begin
if(regwrite) mem[waddr]<=wdata;
    mem[0]<=32'b0;
// Register R0 hardwired to zero.
end

assign rdata1=mem[raddr1];
// Data read in port1 (A);
assign rdata2=mem[raddr2];
// Data read in port2 (B);

endmodule
