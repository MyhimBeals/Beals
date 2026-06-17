module top_countdown(
    input               clk50m,
    input               sw_rst,

    output              a,b,c,d,e,f,g,p,

    output              com7,com6,com5,com4,com3,com2,com1,com0,

    input               sw_h,
    input               sw_min,
    input               sw_sec,
    input               sw_ok,
    output reg          alarm,
    output [7:0]        led,
    output [5:0]        traffic_led
);

wire rst_n = sw_rst;

wire sw_h_pulse;
wire sw_min_pulse;
wire sw_sec_pulse;
wire sw_ok_pulse;

ax_debounce u_deb_h   (.clk(clk50m), .rst_n(rst_n), .btn_in(sw_h),   .btn_pulse(sw_h_pulse));
ax_debounce u_deb_min (.clk(clk50m), .rst_n(rst_n), .btn_in(sw_min), .btn_pulse(sw_min_pulse));
ax_debounce u_deb_sec (.clk(clk50m), .rst_n(rst_n), .btn_in(sw_sec), .btn_pulse(sw_sec_pulse));
ax_debounce u_deb_ok  (.clk(clk50m), .rst_n(rst_n), .btn_in(sw_ok),  .btn_pulse(sw_ok_pulse));

wire pulse_1hz;
div_1hz u_div1hz(
    .clk50m(clk50m),
    .rst_n(rst_n),
    .pulse_1hz(pulse_1hz)
);

reg blink_reg;
always @(posedge clk50m or negedge rst_n) begin
    if(!rst_n) blink_reg <= 1'b0;
    else if(pulse_1hz) blink_reg <= ~blink_reg;
end

reg work_state;

reg [4:0] hh;
reg [3:0] mm1,mm0;
reg [3:0] ss1,ss0;

always @(posedge clk50m or negedge rst_n) begin
    if(!rst_n) begin
        work_state <= 1'b0;
        hh   <= 5'd0;
        mm1  <= 4'd0;
        mm0  <= 4'd0;
        ss1  <= 4'd0;
        ss0  <= 4'd0;
        alarm<= 1'b0;
    end
    else begin
        if(alarm) begin

            if(sw_ok_pulse || sw_h_pulse || sw_min_pulse || sw_sec_pulse) begin
                alarm <= 1'b0;
            end
        end
        else begin
            if(sw_ok_pulse) begin

                if(hh != 5'd0 || mm1 != 4'd0 || mm0 != 4'd0 || ss1 != 4'd0 || ss0 != 4'd0) begin
                    work_state <= 1'b1;
                end
            end
            else if(work_state == 1'b0) begin

                if(sw_h_pulse) begin
                    hh <= (hh == 5'd23) ? 5'd0 : hh + 1'b1;
                end
                if(sw_min_pulse) begin
                    if(mm0 == 4'd9) begin
                        mm0 <= 4'd0;
                        mm1 <= (mm1 == 4'd5) ? 4'd0 : mm1 + 1'b1;
                    end
                    else mm0 <= mm0 + 1'b1;
                end
                if(sw_sec_pulse) begin
                    if(ss0 == 4'd9) begin
                        ss0 <= 4'd0;
                        ss1 <= (ss1 == 4'd5) ? 4'd0 : ss1 + 1'b1;
                    end
                    else ss0 <= ss0 + 1'b1;
                end
            end
            else begin

                if(hh == 5'd0 && mm1 == 4'd0 && mm0 == 4'd0 && ss1 == 4'd0 && ss0 == 4'd0) begin
                    work_state <= 1'b0;
                    alarm      <= 1'b1;
                end
                else if(pulse_1hz) begin
                    if(ss0 > 4'd0) begin
                        ss0 <= ss0 - 1'b1;
                    end
                    else begin
                        ss0 <= 4'd9;
                        if(ss1 > 4'd0) begin
                            ss1 <= ss1 - 1'b1;
                        end
                        else begin
                            ss1 <= 4'd5;
                            if(mm0 > 4'd0) begin
                                mm0 <= mm0 - 1'b1;
                            end
                            else begin
                                mm0 <= 4'd9;
                                if(mm1 > 4'd0) begin
                                    mm1 <= mm1 - 1'b1;
                                end
                                else begin
                                    mm1 <= 4'd5;
                                    if(hh > 5'd0) hh <= hh - 1'b1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

wire [3:0] hh1 = hh / 4'd10;
wire [3:0] hh0 = hh % 4'd10;

wire [31:0] disp_data_normal = {4'hf, 4'hf, hh1, hh0, mm1, mm0, ss1, ss0};

wire [31:0] disp_data = (alarm && blink_reg) ? 32'hffffffff : disp_data_normal;

wire [7:0] seg_wire, com_wire;
seg7_disp u_seg(
    .clk50m(clk50m),
    .rst_n(rst_n),
    .din(disp_data),
    .seg(seg_wire),
    .com(com_wire)
);

assign {p,g,f,e,d,c,b,a} = seg_wire;
assign {com7,com6,com5,com4,com3,com2,com1,com0} = com_wire;

// 倒计时结束时让 LED0 到 LED7 和交通灯闪烁 (默认高电平点亮)
// 如果开发板是低电平点亮，请将这两行注释，并使用下方的 assign 语句
// assign led = alarm && blink_reg ? 8'h00 : 8'hff;
// assign traffic_led = alarm && blink_reg ? 6'h00 : 6'h3f;
assign led = {8{alarm && blink_reg}};
assign traffic_led = {6{alarm && blink_reg}};

endmodule
