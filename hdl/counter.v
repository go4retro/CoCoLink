`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:27 12/10/2013 
// Design Name: 
// Module Name:    counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module up_counter(clock, reset, out);

parameter WIDTH = 8;

input clock;
input reset;
output [WIDTH-1:0] out;

reg [WIDTH-1:0] out;

always @(posedge clock)
if (reset)
  out <= 0;
else
  out <= out + 1;
endmodule 