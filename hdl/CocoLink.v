`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:23:22 03/31/2016 
// Design Name: 
// Module Name:    CocoLink 
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

// TODO Add base address override....

module CocoLink(
                input _reset,
					 input e,
					 //input q,
					 input r_w,
					 input [15:0]address,
					 inout [7:0]data,
					 output _slenb,
					 output _acia_ce,
					 output acia_phi2,
					 inout [7:0]acia_data,
					 input acia_clock_in,
					 output acia_clock_out,
					 input acia_txd,
					 input acia_rxd,
                input acia_rts,
                output rs_rts,
					 output led_txd,
					 output led_rxd,
					 input [1:0]cfg
					);

wire [7:0]data_out;
wire [7:0]acia_data_out;

assign led_txd =              !acia_txd;
assign led_rxd =              !acia_rxd;
assign acia_phi2 =            e;
assign rs_rts =               acia_rts;

wire active =                 (address[15:8] == 'hff) & (address[7:5] == 'b011) & (address[4] == cfg[1]) & (address[3] == 1) & (address[2] == cfg[0]) ; // $ff68,9,a,b/c,d,e,f/$ff78,9,a,b/c,d,e,f

assign acia_data =            (!r_w ? acia_data_out : 'bz);
assign data =                 (active & r_w & e ? data_out : 'bz); // if ce and read, send data_out, else hi-Z
assign _slenb =               'bz;

Fast6551								f6551(_reset,
                                    active,
												e,
												r_w,
												_acia_ce,
												address[1:0],
												data,
												data_out,
												acia_data,
												acia_data_out,
												acia_clock_in, 
												acia_clock_out
											  );


endmodule
