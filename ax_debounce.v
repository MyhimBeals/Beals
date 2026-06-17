module ax_debounce(
    input       clk,
    input       rst_n,
    input       btn_in,
    output reg  btn_pulse
);

parameter CNT_MAX = 26'd1_000_000;

reg [25:0]  cnt;
reg         btn_reg0;
reg         btn_reg1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        btn_reg0 <= 1'b1;
        btn_reg1 <= 1'b1;
    end else begin
        btn_reg0 <= btn_in;
        btn_reg1 <= btn_reg0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 26'd0;
    end else if (btn_reg0 != btn_reg1) begin
        cnt <= 26'd0;
    end else if (cnt < CNT_MAX) begin
        cnt <= cnt + 1'b1;
    end
end

reg btn_state;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        btn_state <= 1'b1;
        btn_pulse <= 1'b0;
    end
    else if (cnt == CNT_MAX) begin

        if (!btn_reg1 && btn_state) begin
            btn_pulse <= 1'b1;
            btn_state <= 1'b0;
        end

        else if (btn_reg1) begin
            btn_state <= 1'b1;
            btn_pulse <= 1'b0;
        end
        else begin
            btn_pulse <= 1'b0;
        end
    end
    else begin
        btn_pulse <= 1'b0;
    end
end
endmodule
