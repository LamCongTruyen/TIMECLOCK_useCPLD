`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:10:59 03/17/2025 
// Design Name: 
// Module Name:    top_module 
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
module top_module(clk_ht, reset, btn_select, btn_inc, btn_dec, btn_pause , seg, cathode);
input clk_ht, reset, btn_select, btn_inc, btn_dec, btn_pause;
output [6:0] seg;
output [5:0]cathode;

wire [3:0] w4, w5, w6, w7, w8, w9,w10;
wire w1, w2;
wire [2:0] sel;

CHIA_1HZ IC1 (.clk_ht(clk_ht), .clk_1hz(w1));
CHIA_1KHZ IC2 (.clk_ht(clk_ht), .clk_1khz(w2));
DEM6BIT IC3 (.clk(w2), .q(cathode), .led_select(sel));
GM7DOAN_CC IC4 (.I(w6), .Y(seg));
MUX6_1 IC5 (.I0(w4), .I1(w5), .I2(w7), .I3(w8), .I4(w9), .I5(w10), .SEL(sel), .O(w6));
DEM IC6 (.clk(w1), .reset(reset), .btn_select(btn_select), .btn_inc(btn_inc), .btn_dec(btn_dec), .btn_pause(btn_pause), .s1(w4), .s2(w5), .m1(w7), .m2(w8), .h1(w9), .h2(w10));
endmodule




//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:13:58 03/17/2025 
// Design Name: 
// Module Name:    CHIA_1HZ 
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
module CHIA_1HZ(
    input clk_ht,   // Clock vào 100kHz  ///clock tao tìm hểu trong datasheet thì ở p38 ẽ là 100khz, còn 10khz và 1khz thì t ko tìm đc thông tin nên t dùng 100khz
    output reg clk_1hz = 0  // Clock ra 1Hz
);
    reg [15:0] counter = 0;  // Bộ đếm

    always @ (posedge clk_ht) begin
        counter <= counter + 1;
        if (counter == 16'd1249) begin   ///ở đây t chỉnh tần số lên 40hz để test thời gian chạy đủ 24 giờ. 
		////Nếu muốn chính xác theo thời gian thực thì chỉnh biến "counter" thành 100.000 sẽ cho đầu ra là 1HZ. Công thức tính counter sẽ là counter = Fin/Fout
            counter <= 0;
            clk_1hz <= ~clk_1hz;
        end
    end
endmodule


//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:14:41 03/17/2025 
// Design Name: 
// Module Name:    CHIA_1KHZ 
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
module CHIA_1KHZ(clk_ht, clk_1khz);  //dùng tần số 1khz để quét led,tần số càng nhanhthif hajn chế tình trạng nhấp nháy
input clk_ht;
output reg clk_1khz = 0;
reg [5:0] counter = 0;
always @ (posedge clk_ht) begin
	counter <= counter + 1;
	if (counter == 6'd50) begin
		counter <= 0;
		clk_1khz <= ~clk_1khz;
	end
end
endmodule

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:20:22 03/17/2025 
// Design Name: 
// Module Name:    DEM4BIT 
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
module DEM6BIT(clk, q, led_select
    );//module này đếm các trường hợp bên dưới với mục đích là để chọn led nào sáng
input clk;
output reg [5:0] q;
output [2:0] led_select;
reg [2:0] led_select_reg =0 ;

assign led_select = led_select_reg;

always @(posedge clk) begin
        led_select_reg <= led_select_reg + 1;  // Tăng giá trị mỗi xung clock
    end
always @(*) begin
	 case (led_select_reg)  //ta có đèn, thì có 6 trường hợp lựa chọn đèn để sáng 6 trường hợp thì dùng biến có 3bit 
        3'b000: q <= 6'b000001;  // Chữ số 1 (giây đơn vị)
        3'b001: q <= 6'b000010;  // Chữ số 2 (giây chục)
        3'b010: q <= 6'b000100;  // Chữ số 3 (phút đơn vị)
        3'b011: q <= 6'b001000;  // Chữ số 4 (phút chục)
        3'b100: q <= 6'b010000;  // Chữ số 5 (giờ đơn vị)
        3'b101: q <= 6'b100000;  // Chữ số 6 (giờ chục)
		  default: q <= 4'b000000;
    endcase
end

endmodule

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:24:56 03/17/2025 
// Design Name: 
// Module Name:    GM7DOAN_CC 
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
module GM7DOAN_CC(I,Y 
    );
input [3:0] I;
output reg [6:0] Y; //Y6 - Y0 ==&gt; a - g

always @ (I)
	begin
	case (I)
		4'd0: Y = 7'b1000000; // 0
      4'd1: Y = 7'b1111001; // 1
      4'd2: Y = 7'b0100100; // 2
      4'd3: Y = 7'b0110000; // 3
      4'd4: Y = 7'b0011001; // 4
      4'd5: Y = 7'b0010010; // 5
      4'd6: Y = 7'b0000010; // 6
      4'd7: Y = 7'b1111000; // 7
      4'd8: Y = 7'b0000000; // 8
      4'd9: Y = 7'b0010000; // 9
      default: Y = 7'b1111111; // Tắt toàn bộ LED (OFF)
	endcase
end
endmodule

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:29:36 03/17/2025 
// Design Name: 
// Module Name:    MUX6_1 
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
module MUX6_1(I0,I1,I2,I3,I4,I5,SEL,O
    ); //này là bộ MUX6_1 dùng để lựa chọn dũ liệu nào được đưa ra ở ngõ ra
input [3:0] I0,I1,I2,I3,I4,I5;
input [2:0] SEL;
output reg [3:0] O;
always @(*) begin
   case (SEL)
            3'b000: O = I0;  // Giây đơn vị
            3'b001: O = I1;  // Giây chục
            3'b010: O = I2;  // Phút đơn vị
            3'b011: O = I3;  // Phút chục
            3'b100: O = I4;  // Giờ đơn vị
            3'b101: O = I5;  // Giờ chục
            default: O = 4'b0000;
    endcase
end

endmodule

//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:41:25 03/17/2025 
// Design Name: 
// Module Name:    DEM 
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
module DEM(clk, reset, btn_select, btn_inc , btn_dec, btn_pause, s1, s2, m1, m2, h1, h2);

input btn_pause; 			// Nút tạm dừng/tiếp tục
input btn_select;			// Nút chọn giờ/phút/giây
input btn_inc;          // Nút tăng
input btn_dec;				// Nút giảm
input clk; // Clock
input reset; // Reset về 00
output reg [3:0] s1; // Giây Hàng đơn vị
output reg [3:0] s2; // Giây Hàng chục
output reg [3:0] m1; // Phút Hàng chục
output reg [3:0] m2; // Phút Hàng chục
output reg [3:0] h1; // Giờ đơn vị
output reg [3:0] h2;  // Giờ chục

reg [1:0] mode = 2'b00;  // 00: giờ, 01: phút, 10: giây
reg prev_select = 1'b0;  // Trạng thái trước của btn_select
reg prev_inc = 1'b0;     // Trạng thái trước của btn_inc
reg prev_dec = 1'b0;     // Trạng thái trước của btn_dec
reg prev_pause = 1'b0;   // Trạng thái trước của btn_pause
reg pause = 1'b0;        // Tạm dừng đếm khi chỉnh
	 
initial begin
        s1 = 4'd0;
        s2 = 4'd0;
        m1 = 4'd0;
        m2 = 4'd0;
		  h1 = 4'd0; 
		  h2 = 4'd0;
end

always @ (posedge clk) begin
	if (reset) begin
		s1 <= 4'd0;
		s2 <= 4'd0;
		m1 <= 4'd0;
		m2 <= 4'd0;
		h1 <= 4'd0; 
		h2 <= 4'd0;
		mode <= 2'b00;  // Reset về chế độ giờ
      pause <= 1'b0;  // Bỏ tạm dừng
	end 
	else begin
		// Xử lý nút tạm dừng (btn_pause)
      if (btn_pause && !prev_pause) begin
			 pause <= ~pause;  // Đảo trạng thái tạm dừng
      end
		// Xử lý nút chọn (btn_select)
      if (btn_select && !prev_select) begin  // Phát hiện cạnh lên
          mode <= (mode == 2'b10) ? 2'b00 : mode + 2'b01;  // Chuyển: giờ -> phút -> giây -> giờ
          pause <= 1'b1;  // Tạm dừng đếm khi bắt đầu chỉnh
      end
		
		// Xử lý nút tăng (btn_inc)
      if (btn_inc && !prev_inc && pause) begin // Chỉ tăng khi đang tạm dừng
         case (mode)
             2'b00: begin  // Giờ
               if (h1 == 4'd3 && h2 == 4'd2) begin 
						h1 <= 4'd0; 
						h2 <= 4'd0; 
					end  // 23 -> 00
               else if (h1 == 4'd9) begin
						h1 <= 4'd0; 
						h2 <= h2 + 4'd1; 
					end
               else 
						h1 <= h1 + 4'd1;
				 end
				 2'b01: begin  // Phút
					if (m1 == 4'd9 && m2 == 4'd5) begin 
						m1 <= 4'd0; 
						m2 <= 4'd0; 
					end  // 59 -> 00
               else if (m1 == 4'd9) begin 
						m1 <= 4'd0; 
						m2 <= m2 + 4'd1; 
					end
               else 
						m1 <= m1 + 4'd1;
             end
			    2'b10: begin  // Giây
               if (s1 == 4'd9 && s2 == 4'd5) begin 
						s1 <= 4'd0; 
						s2 <= 4'd0; 
					end  // 59 -> 00
               else if (s1 == 4'd9) begin 
						s1 <= 4'd0; 
						s2 <= s2 + 4'd1; 
					end
               else 
						s1 <= s1 + 4'd1;
             end
         endcase
     end
	  
	  // Xử lý nút giảm (btn_dec)
            if (btn_dec && !prev_dec && pause) begin  // Chỉ giảm khi đang tạm dừng
                case (mode)
                    2'b00: begin  // Giờ
                        if (h1 == 4'd0 && h2 == 4'd0) begin 
									h1 <= 4'd3; 
									h2 <= 4'd2; 
								end  // 00 -> 23
                        else if (h1 == 4'd0) begin 
									h1 <= 4'd9; 
									h2 <= h2 - 4'd1; 
								end
                        else 
									h1 <= h1 - 4'd1;
                    end
						  2'b01: begin  // Phút
                        if (m1 == 4'd0 && m2 == 4'd0) begin 
									m1 <= 4'd9; 
									m2 <= 4'd5; 
								end  // 00 -> 59
                        else if (m1 == 4'd0) begin 
									m1 <= 4'd9; 
									m2 <= m2 - 4'd1; 
								end
                        else 
									m1 <= m1 - 4'd1;
                    end
						  2'b10: begin  // Giây
                        if (s1 == 4'd0 && s2 == 4'd0) begin 
									s1 <= 4'd9; 
									s2 <= 4'd5; 
								end  // 00 -> 59
                        else if (s1 == 4'd0) begin 
									s1 <= 4'd9; 
									s2 <= s2 - 4'd1; 
								end
                        else 
									s1 <= s1 - 4'd1;
                    end
                endcase
            end
				
		// Đếm bình thường (nếu không tạm dừng)
				if (!pause) begin
                if (s1 == 4'd9) begin
                    s1 <= 4'd0;
                    if (s2 == 4'd5) begin
                        s2 <= 4'd0; 
                        if (m1 == 4'd9) begin
                            m1 <= 4'd0;
                            if (m2 == 4'd5) begin
                                m2 <= 4'd0;
										  if (h1 == 4'd3 && h2 == 4'd2) begin
                                    h1 <= 4'd0; 
                                    h2 <= 4'd0;
                                end
                                else if (h1 == 4'd9) begin
                                    h1 <= 4'd0;
                                    h2 <= h2 + 4'd1;
                                end
                                else
                                    h1 <= h1 + 4'd1;
                            end
									 else
                                m2 <= m2 + 4'd1;
                        end
                        else
                            m1 <= m1 + 4'd1;
                    end
                    else
                        s2 <= s2 + 4'd1;
                end 
                else
                    s1 <= s1 + 4'd1;
            end
		////////////////////////
		prev_select <= btn_select;
      prev_inc <= btn_inc;
      prev_dec <= btn_dec;
		prev_pause <= btn_pause;
	end
end
endmodule

/////////////////////////////////////////////////
NET "clk_ht" LOC = "P38";

NET "reset" LOC = "P40";		# Nút reset
NET "btn_select" LOC = "P60";  # Nút chọn
NET "btn_inc" LOC = "P42";     # Nút tăng
NET "btn_dec" LOC = "P43";     # Nút giảm
NET "btn_pause" LOC = "P41";  # Nút pause

NET "seg[6]" LOC = "P104";
NET "seg[5]" LOC = "P103";
NET "seg[4]" LOC = "P102";
NET "seg[3]" LOC = "P101";
NET "seg[2]" LOC = "P100";
NET "seg[1]" LOC = "P98";
NET "seg[0]" LOC = "P97";

NET "cathode[0]" LOC = "P82";
NET "cathode[1]" LOC = "P81";
NET "cathode[2]" LOC = "P80";
NET "cathode[3]" LOC = "P79";
NET "cathode[4]" LOC = "P78";
NET "cathode[5]" LOC = "P77";
