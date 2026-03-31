`timescale 1ns / 1ps

module fsm_counter(
    input clk,
    input rst,
    input [15:0] sw_val,
    output reg [15:0] count_reg
);
    /* state encoding */
    localparam ST_IDLE  = 2'b00;
    localparam ST_LOAD  = 2'b01;
    localparam ST_COUNT = 2'b10;

    reg [1:0] cur_state;

    /* 1-second tick for 100 MHz clock */
    reg  [26:0] tick_ctr;
    wire        tick_1hz = (tick_ctr == 27'd99_999_999);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cur_state <= ST_IDLE;
            count_reg <= 16'd0;
            tick_ctr  <= 27'd0;
        end
        else begin
            case (cur_state)

                ST_IDLE: begin
                    count_reg <= 16'd0;
                    tick_ctr  <= 27'd0;
                    if (sw_val != 16'd0)
                        cur_state <= ST_LOAD;
                end

                ST_LOAD: begin
                    tick_ctr  <= 27'd0;
                    cur_state <= ST_COUNT;
                    case (1'b1)
                        sw_val[0]:  count_reg <= 16'd0;
                        sw_val[1]:  count_reg <= 16'd1;
                        sw_val[2]:  count_reg <= 16'd2;
                        sw_val[3]:  count_reg <= 16'd3;
                        sw_val[4]:  count_reg <= 16'd4;
                        sw_val[5]:  count_reg <= 16'd5;
                        sw_val[6]:  count_reg <= 16'd6;
                        sw_val[7]:  count_reg <= 16'd7;
                        sw_val[8]:  count_reg <= 16'd8;
                        sw_val[9]:  count_reg <= 16'd9;
                        sw_val[10]: count_reg <= 16'd10;
                        sw_val[11]: count_reg <= 16'd11;
                        sw_val[12]: count_reg <= 16'd12;
                        sw_val[13]: count_reg <= 16'd13;
                        sw_val[14]: count_reg <= 16'd14;
                        sw_val[15]: count_reg <= 16'd15;
                        default:    count_reg <= 16'd0;
                    endcase
                end

                ST_COUNT: begin
                    if (tick_1hz) begin
                        tick_ctr <= 27'd0;
                        if (count_reg > 16'd0)
                            count_reg <= count_reg - 16'd1;
                        else
                            cur_state <= ST_IDLE;
                    end
                    else
                        tick_ctr <= tick_ctr + 27'd1;
                end

            endcase
        end
    end
endmodule