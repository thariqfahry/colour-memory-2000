/*
 * Hex to 7-Segment Encoder
 * ----------------------------
 * By: Thariq Fahry
 * Date: 07th March 2022
 *
 * Description
 * ------------
 * This module translates a hexadecimal number to a bit mapping for a
 * 7-segment display.
 * This was created in a previous lab task:
 * https://github.com/leeds-embedded-systems/ELEC5566M-Unit1-thariqfahry/blob/main/1-2-HexTo7Segment/HexTo7Segment.v
 */

// Declare input and output ports.
module HexTo7Segment(input  [4:0] hex,

                     output [6:0] seg);

    // Simply map each hex representation of a number to 7 contiguous bits
    // in a wire. The last 7 bits in this wire, 0x10, represent nothing being
    // lit up on the display.
    wire [118:0] digits = { 7'h3F, 7'h06, 7'h5B, 7'h4F, 7'h66, 7'h6D, 7'h7D, 7'h07,
                            7'h7F, 7'h67, 7'h77, 7'h7C, 7'h39, 7'h5E, 7'h79, 7'h71 ,7'h00 };

    assign seg = digits[7'd111-7'd7*hex-:7];

endmodule