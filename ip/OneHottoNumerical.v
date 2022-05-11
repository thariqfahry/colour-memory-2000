/*
 * One-hot to numerical decoder
 * ----------------------------
 * By: Thariq Fahry
 * Date: 07th March 2022
 *
 * Description
 * ------------
 * This module translates a 4-bit One-hot encoded number in the range 0-3 to its
 * corresponding 2-bit numerical representation.
 *
 */

 // Declare input and output ports.
module OneHottoNumerical(input  [3:0] onehot,

                         output reg [1:0] numerical);
    
    // Use a case-switch to map the one-hot encoding of the input to
    // its numerical representation.
    always @(*) begin
        case (onehot)
            4'b0001:numerical = 2'd0;
            4'b0010:numerical = 2'd1;
            4'b0100:numerical = 2'd2;
            4'b1000:numerical = 2'd3;
            
            default:numerical = 2'd0;
        endcase
    end

endmodule