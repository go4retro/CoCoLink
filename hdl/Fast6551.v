`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:10:21 02/08/2016 
// Design Name: 
// Module Name:    Fast6551 
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
module Fast6551(
						input _reset,
						input ce,
						input clock,
						input r_w,
						output _acia_ce,
						input [1:0]address,
						input [7:0]data_in,
						output [7:0]data_out,
						input [7:0]acia_data_in,
						output [7:0]acia_data_out,
						input acia_clock_in,
						output acia_clock_out
						);

wire [1:0] counter;
wire [4:0] cmd_data;
wire [7:0] fake_cmd_data;
wire [7:0] mux_data;
reg div_clock;
wire fast_flag;
wire lock_flag;

wire cmd_reg_ce;
wire cmd_reg_we;

assign cmd_reg_ce =        ce & (address[1:0] == 3);
assign cmd_reg_we =			cmd_reg_ce & !r_w;
assign status_reg_ce =     ce & (address[1:0] == 1);
assign status_reg_we =		status_reg_ce & !r_w;

assign fast_flag =         !cmd_data[4];

assign _acia_ce =           !(lock_flag & (cmd_reg_we | status_reg_we) ? 0 : ce);  // we are locked, trying to write to cmd reg and 

assign acia_data_out =  	(cmd_reg_we & !data_in[4] ? {data_in[7:5], 'b10000} : data_in);  // if reg = cmd reg and data 4 is low, send xxx10000, else send data
assign data_out =          (lock_flag & cmd_reg_ce ? fake_cmd_data : mux_data);
assign mux_data =  			(cmd_reg_ce & fast_flag ? {acia_data_in[7:5],cmd_data[4:0]} : acia_data_in);
register #(.WIDTH(5))		cmd_reg(clock, !_reset, cmd_reg_we & !lock_flag, data_in[4:0], cmd_data);
register #(.WIDTH(8))		fake_reg(clock, !_reset, cmd_reg_we, data_in, fake_cmd_data);

up_counter #(.WIDTH(2))		bps_divisor(acia_clock_in, 0, counter);

fsm          					fsm1(clock & status_reg_we, _reset, data_in, lock_flag);

assign acia_clock_out =    (fast_flag ? div_clock : counter[0]);  // default is 3.6864MHz/2 (1.8432MHz)
 
always @ (*)
begin
		case (cmd_data[3:0])
			'b1101: div_clock = counter[1];  // 13 /4 =  57.6kbps
			'b1110: div_clock = counter[0] ; //14 /2 = 115kbps
			'b1111: div_clock = acia_clock_in;  // 15 /1  = 230kbps
			default: div_clock = 0;
		endcase
end

endmodule

module fsm(
			  input clock, 
			  input _reset, 
			  input [7:0]data, 
			  output reg lock_flag
			 );

reg[1:0] state;

always @(negedge clock, negedge _reset)
begin
  if(!_reset)
		begin
			state <= 0;
			lock_flag <= 0;
	   end
  else
  begin
		case(state)
			0:
				if(data == 8'h55)
					state <= 1;
			1:
				if(data == 8'haa)
					state <= 2;
				else
					state <= 0;
			2:
				if(data == 8'h01)
					state <= 3;
				else
					state <= 0;
			3:
				if(data == 8'h01)
				   begin
						lock_flag <= 1;
						state <= 0;
					end
				else if(data == 8'h00)
				   begin
						lock_flag <= 0;
						state <= 0;
					end
				else
					state <= 0;
			default:
				state <= 0;
		endcase
	end
end

endmodule
