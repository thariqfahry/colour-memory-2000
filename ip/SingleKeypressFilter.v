/*
 * Single Keypress Filter
 * ----------------------------
 * By: Thariq Fahry
 * Date: 05th May 2022
 *
 * Description
 * ------------
 * This module prevents multiple keys from being pressed at the same time 
 * by only accepting a single keypress from KEY[3-0]. If multiple keys are
 * pressed, the output is zero.
 * 
 */

// Declare input and output ports.
module SingleKeypressFilter (input  [3:0] key,

                             output reg [3:0] filteredkey);
    
    always @(key) begin
        // Only accept keypresses where one key is high.
        case (key)
            4'b0001: filteredkey <= key;
            4'b0010: filteredkey <= key;
            4'b0100: filteredkey <= key;
            4'b1000: filteredkey <= key;

            // Otherwise, make output low. This also takes care of a zero
            // input.
            default: filteredkey <= 4'b0000;
        endcase
    end
    
endmodule
