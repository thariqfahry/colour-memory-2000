/*
 * Hex to 7-Segment Encoder
 * ----------------------------
 * By: Thariq Fahry
 * Date: 07th March 2022
 *
 * Description
 * ------------
 * This module translates a decimal number to a bit mapping for a
 * 7-segment display.
 * This is based on IP created in a previous lab task:
 * https://github.com/leeds-embedded-systems/ELEC5566M-Unit1-thariqfahry/blob/main/1-2-HexTo7Segment/HexTo7Segment.v
 */

// Declare input and output ports.
module HexTo7Segment #(parameter INVERT_OUTPUT = 0)

                      (input  [6:0] hex,

                       output [6:0] seg0,
                       output [6:0] seg1);
    
    // Simply map each hex representation of a number to 7 contiguous bits
    // in a wire. The last 7 bits in this wire, digits[5'h10], represent
    // nothing being lit up on the display.
    wire [118:0] digits = { 7'h3F, 7'h06, 7'h5B, 7'h4F, 7'h66, 7'h6D, 7'h7D, 7'h07,
                            7'h7F, 7'h67, 7'h77, 7'h7C, 7'h39, 7'h5E, 7'h79, 7'h71 ,7'h00 };
    
    
    reg [4:0] seg0_val;     // The trailing digit.
    reg [4:0] seg1_val;     // The leading digit.
    
    integer i;
    reg [6:0] hexcopy = 0;
    
    // Sensitive to whenever hex changes.
    always @(hex) begin
        i=0;
        hexcopy = hex;

        // If the input value is over 99, display nothing on both 7-seg displays.
        if (hex>99) begin
            seg0_val = 5'h10;
            seg1_val = 5'h10;
        end else begin

            // If the input value is less than 99 but greater than 9 (i.e.)
            // a two-digit number, calculate leading and trailing digit.
            if (hex>9) begin

                // Calculate the trailing digit via modulo.
                seg0_val = hex % 7'd10;

                // We need to do a floor division to calculate the leading
                // digit. Since we can't divide in FPGA, we have to do division
                // iteratively using repeated subtraction.
                seg1_val = 5'h0;
                for (i = 0;i<10;i = i+1) begin
                    if (hexcopy > 9) begin
                        hexcopy  = hexcopy-7'd10;
                        seg1_val = seg1_val + 5'h1;
                    end
                end
            
            // If the input value is below 9, it is a single-digit number.
            end else begin

                // Simply assign hex to seg0_val. The truncation will
                // be valid, since we already know hex < d9.
                seg0_val = hex;

                // Make the leading digit 7-seg display nothing.
                seg1_val = 5'h10;
            end
        end
    end
    
    // Assign either the value of the digits mapping, or its inverse
    // based on the INVERT_OUTPUT parameter.
    generate
    if (INVERT_OUTPUT) begin
        assign seg0 = ~(digits[7'd118-7'd7*seg0_val-:7]);
        assign seg1 = ~(digits[7'd118-7'd7*seg1_val-:7]);
        end else begin
        assign seg0 = digits[7'd118-7'd7*seg0_val-:7];
        assign seg1 = digits[7'd118-7'd7*seg1_val-:7];
    end
    
    endgenerate
    
endmodule
