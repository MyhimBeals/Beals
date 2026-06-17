module seg7_disp(
    input               clk50m,
    input               rst_n,
    input [31:0]        din,
    output reg [7:0]    seg,
    output reg [7:0]    com
);
reg [14:0] scan_cnt;
wire [2:0]  sel;
reg [3:0]  data;

always @(posedge clk50m or negedge rst_n) begin
    if(!rst_n) scan_cnt <= 15'd0;
    else scan_cnt <= scan_cnt + 1'b1;
end

assign sel = scan_cnt[14:12];

always @(*) begin
    case(sel)
        3'd0: data = din[3:0];
        3'd1: data = din[7:4];
        3'd2: data = din[11:8];
        3'd3: data = din[15:12];
        3'd4: data = din[19:16];
        3'd5: data = din[23:20];
        3'd6: data = din[27:24];
        3'd7: data = din[31:28];
        default: data = 4'hf;
    endcase
end

always @(*) begin
    com = 8'b00000000;
    com[sel] = 1'b1;
end

always @(*) begin
    case(data)
        4'd0: seg = 8'b00111111;
        4'd1: seg = 8'b00000110;
        4'd2: seg = 8'b01011011;
        4'd3: seg = 8'b01001111;
        4'd4: seg = 8'b01100110;
        4'd5: seg = 8'b01101101;
        4'd6: seg = 8'b01111101;
        4'd7: seg = 8'b00000111;
        4'd8: seg = 8'b01111111;
        4'd9: seg = 8'b01101111;
        default:seg = 8'b00000000;
    endcase
end
endmodule
