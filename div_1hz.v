module div_1hz #(
    parameter CNT_MAX = 26'd50_000_000
)(
    input           clk50m,
    input           rst_n,
    output reg      pulse_1hz
);
reg [25:0] cnt;
always @(posedge clk50m or negedge rst_n) begin
    if(!rst_n) begin
        cnt       <= 26'd0;
        pulse_1hz <= 1'b0;
    end
    else if(cnt == CNT_MAX - 1'b1) begin
        cnt       <= 26'd0;
        pulse_1hz <= 1'b1;
    end
    else begin
        cnt       <= cnt + 1'b1;
        pulse_1hz <= 1'b0;
    end
end
endmodule
