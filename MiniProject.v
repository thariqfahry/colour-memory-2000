/*
 * MiniProject - ColourMemory2000
 * ----------------------------
 * By: 201158825 Thariq Fahry
 * Date: 14th April 2022
 *
 * Description
 * ------------
 * A memory game for the DE1-SoC for the ELEC5566M Mini-Project.
 *
 */

module MiniProject(
    // Global clock, global reset, and application reset.
    input              clock,
    input              globalReset,
    output             resetApp,

    // Active-low key input for the 3 keys on the DE1-SoC.
    input  [      3:0] n_key,
    
    // Interface for the LT24 display driver.
    output             LT24Wr_n,
    output             LT24Rd_n,
    output             LT24CS_n,
    output             LT24RS,
    output             LT24Reset_n,
    output [     15:0] LT24Data,
    output             LT24LCDOn,

    // Active-low seven-segment LED outputs.
    output [      6:0] n_sevenseg0,
    output [      6:0] n_sevenseg1
);

// LCD-specific wires and registers.
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;

// LT24 LCD display driver.
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    .clock       (clock      ),
    .globalReset (globalReset),
    .resetApp    (resetApp   ),
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    .pixelRawMode(1'b0       ),
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

// Counters for the LT24 display.
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(LCD_WIDTH-1)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);

wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
UpCounterNbit #(
    .WIDTH    (           9),
    .MAX_VALUE(LCD_HEIGHT-1)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);

// Pixel Write for the LT24 display.
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        pixelWrite <= 1'b1;
    end
end

// Main display drawing loop.
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        xAddr               <= 8'b0;
        yAddr               <= 9'b0;
    end else if (pixelReady) begin
        xAddr               <= xCount;
        yAddr               <= yCount;
    end
end


//************************************************************************
// ColourMemory2000
//************************************************************************

//
// Game parameters
//

// GAMESPEED: fraction of a second that each color will flash for during
// memorisation mode.
localparam GAMESPEED            = 2;

// MAX_SEQ_LENGTH: how long the sequence of flashed colours can increase
// up to with each level.
localparam MAX_SEQ_LENGTH       = 5'd31;

// INITIAL_SEQ_LENGTH: how long the sequence of flashed colours can 
// is at level 1.
localparam INITIAL_SEQ_LENGTH   = 5'd3;


//
// Game-speciific wires and registers
//

// Invert the key input to make it active-high.
wire [3:0] unfilteredkey = ~n_key;

// Filter the active-high key input with the SingleKeypressFilter to make
// sure only one key is pressed at a time
wire [3:0] key;
SingleKeypressFilter u_SingleKeypressFilter(
    .key         (unfilteredkey         ),
    .filteredkey (key )
);

// 7-segment display
// Initialise the 7-segment displays to show a blank value by setting a
// number above 7'd99.
reg [6:0] num0 = 7'd100;

// Instantiate the Hexto7Segment module, which will drive two seven segment
// displays and display a decimal number from 0 to 99.
// Set the INVERT_OUTPUT parameter to 1 since the DE1-SoC's 7-segment 
// display pins are active-low.
HexTo7Segment 
#(
    .INVERT_OUTPUT (1)
)
u_HexTo7Segment(
    .hex (num0 ),
    .seg0 (n_sevenseg0),
    .seg1 (n_sevenseg1)
);

//
// Image ROMs 
// These contain the background images displayed during various stages of 
// the game. They are ROMs because they are never written to; they are 
// initialised using Python-generated .mif files and read from.
//

// Share the ROM address among all three ROMs  because only one will ever 
// be displayed at a time.
reg [16:0] romaddr;

// imgrom1: Intro screen.
wire [15:0] imgrom1q;
imgrom1 u_imgrom1(
    .address (romaddr ),
    .clock   (clock   ),
    .q       (imgrom1q)
);

// imgrom2: Level complete screen.
wire [15:0] imgrom2q;
imgrom2 u_imgrom2(
    .address (romaddr ),
    .clock   (clock   ),
    .q       (imgrom2q)
);

// imgrom3: Game over screen (ROM only covers the part of the display that is not 
// black).
wire [15:0] imgrom3q;
imgrom3 u_imgrom3(
    .address (romaddr[12:0]),
    .clock   (clock   ),
    .q       (imgrom3q)
);


// State register for state machine, and next state in state machine in 
// order to implement KEYPRESS_S debounce functionality.
reg [2:0] state;
reg [2:0] nextState;

// Encode the states using numerical encoding so that we only need 3 bits
// to store 8 states.
localparam RESETST      = 3'd0;
localparam INTROST      = 3'd1;
localparam SEQGENST     = 3'd2;
localparam MEMORIZST    = 3'd3;
localparam GAMEST       = 3'd4;
localparam KEYPRESST    = 3'd5;
localparam GAMEOVERST   = 3'd6;
localparam WINST        = 3'd7;

// ec = elapsed clocks. The first register is resettable and is used for 
// timing putposes.
reg [31:0] ec =0;

// The second register is used to count total number of clock cycles elapsed
// since program start. It is used for random number generation, since it will
// be sufficiently random. It is 64-bit to prevent overflow.
reg [63:0] tec=0;

// Number of clock cycles in one second, assuming a 50MHz clock supplied
// by the DE-1 SoC is connected to this module's clock input.
// Used for timing purposes.`
localparam SECOND = 50000000;

// Unused alternative definition of second used during simulation: the test
// bench's clock is only 5KHz to reduce the amount of time it takes to simulate
// a design.
// localparam SECOND = 5000;

// Amount of time each colour will flash during memorisation mode.
localparam MEMRZ_FLASHTIME = SECOND/GAMESPEED;

// The sequence of colours that will flash during memorisation mode. Randomly
// generated at the start of each level.
reg [(MAX_SEQ_LENGTH+1)*4:0] coloursequence;

// The current sequence length, representing difficulty. Increases by 1 
// with each level.
reg [4:0] seqLength;

// The current index of the colour being flashed/inputted.
reg [4:0] seqIndex = 0;


// Temporary variables used in random number generation.
reg [1:0] temp;
reg [3:0] temp2;
integer i;
reg even = 0;

// Register containing the current score.
reg [6:0] score = 0;


// Main program loop. Implemented as a state machine with 8 states.
always @(posedge clock or posedge resetApp) begin
    
    // If resetApp is high, reset all variables to their original values.
    if (resetApp) begin
    
        tec <= 0;
        seqIndex    <= 0;
        colr        <= 0;
        score       <= 0;
        num0        <= 7'd100;
        seqLength   <= INITIAL_SEQ_LENGTH;
        state       <= INTROST;
        nextState   <= INTROST;
    
    end else begin
        // Always increment the total elapsed clock variable by 1.
        tec = tec + 1;

        // Main case-switch statement for state machine.
        case (state)

            // INTROST: Intro state. 
            //
            // Display the main menu screen and wait for a keypress.
            // Reset score, seqLength and seqIndex, effectively starting a
            // new game. Clear the 7-segment displays.
            //
            // Transition to SEQGENST on any keypress.
            INTROST:begin
                seqLength   <= INITIAL_SEQ_LENGTH;
                seqIndex    <= 0;
                num0        <= 7'd100;
                score       <= 0;

                // Display the main menu graphic by setting color to 9.
                colr        <= 9;

                // If a key is pressed, transition to the KEYPRESS state 
                // and prepare to transition to SEQGENST after.
                if (key) begin
                    nextState   <= SEQGENST;
                    state       <= KEYPRESST;

                // If no key is pressed, stay in this state.
                end else begin
                    state       <= INTROST;
                end
            end

            // SEQGENST: Sequence Generator State.
            //
            // Generate a series of colours to be flashed during the
            // memorisation state. The sequence is seqLength long.
            //
            // Transition to MEMORIZST after completion.
            SEQGENST: begin
                if (seqIndex < seqLength) begin

                    // Use the two LSBs of the tec (total elapsed clocks)
                    // variable, which will be effectively random, to generate
                    // a random number from 0 to 3 and map it to a one-hot 
                    // encded number from 0001 to 1000.
                    temp <= tec >> seqIndex;
                    case (temp)
                        2'd0:temp2      = 4'b0001;
                        2'd1:temp2      = 4'b0010;
                        2'd2:temp2      = 4'b0100;
                        2'd3:temp2      = 4'b1000;
                        default:temp2   = 4'b0001;
                    endcase

                    // Add the random number to the colour sequence and 
                    // advance the sequence index.
                    coloursequence[seqIndex*4+:4] <= temp2;
                    seqIndex    <= seqIndex + 5'b1;

                end else begin
                    seqIndex    <= 0;
                    state       <= MEMORIZST;
                end
            end

            // MEMORIZST: Memorization state.
            //
            // Runs at the start of a level. Flashes the colour sequence 
            // generated in SEQGENST.
            //
            // Transition to GAMEST after completion.
            MEMORIZST: begin

                // Loop through all colours in the sequence. Flash a colour
                // every MEMRZ_FLASHTIME, using ec (elapsed clocks) as a timer.
                if (seqIndex <= seqLength) begin
                    if ( ec < MEMRZ_FLASHTIME ) begin
                        ec <= ec+1;
                    end
                    else begin

                        // The even variable alternates between flashing 
                        // the colour black and the colour in colorSequeence
                        // so that the player can distinguish between two
                        // consecutive colours if they are identiacal.
                        if (even) begin
                            
                            // <= used here due to use of the even variable,
                            // otherwise the final colour in the sequence will
                            // not be flashed for an an odd-length sequence.
                            colr        <= coloursequence[seqIndex*4+:4];
                            seqIndex    <= seqIndex+2'b1;  
                        end else begin
                            colr        <= 0;
                        end
                        ec  = 0;

                        // Toggle the even variable.
                        even <= ~even;
                    end

                end else begin
                    seqIndex    <= 0;
                    colr        <= 0;
                    state       <= GAMEST;
                end
            end

            // GAMEST: Game state. 
            //
            // Wait for keypresses. If incorrect, exit the state
            // and transition to GAMEOVERST. If valid, advance the sequence.
            //
            // If the end of the sequence has been reached, transition to 
            // WINST to advance to the next level.
            GAMEST:begin
                if (seqIndex < seqLength) begin
                    if (key) begin
                        colr    <= key;

                        // If the key matches the one in colourSequence,
                        // add 1 to the score and set the next state to be
                        // GAMEST and continue the current level.
                        if (key == coloursequence[seqIndex*4+:4]) begin
                            seqIndex    <= seqIndex+2'b1;
                            score       <= score+7'b1;
                            nextState   <= GAMEST;

                        // If the key does not match, end the game.
                        end else begin
                            nextState <= GAMEOVERST;
                        end
                        state<=KEYPRESST;
                    end else begin
                        state<=GAMEST;
                    end
                
                // If the player has successfully advanced to the end of 
                // the sequence, they have completed the level.
                end else begin
                    state   <= WINST;
                end
            end
            
            // WINST: Win state.
            //
            // Display the Level Complete screen, and the score on the
            // 7-segment LEDs.
            //
            // Wait for any key press. On release transition to SEQGENST
            // to generate the next level.
            WINST: begin

                // Display the score on the pair of 7-segment LEDs, and 
                // display the Level Complete graphic stored in imagerom2.
                // The score value is not reset.
                num0    <= score;
                colr    <= 4'd10;
                
                if(key) begin

                    // If we have not yet reached max difficulty (sequence
                    // length), advance the current sequence length for the
                    // next level.
                    if (seqLength   <= MAX_SEQ_LENGTH) begin
                        seqLength   <= seqLength + 5'b1;    
                    end

                    // Reset seqIndex to prepare for the next level.
                    seqIndex    <= 0;
                    nextState   <= SEQGENST;
                    state       <= KEYPRESST;

                end else begin
                    state   <= WINST;
                end
            end

            // GAMEOVERST: Game Over state.
            //
            // Display the Game Over screen, and the score on the
            // 7-segment LEDs.
            //
            // Wait fot any key press. On release, transition to the 
            // INTROST, which will reset everything.
            GAMEOVERST:begin

                // Display the score on the pair of 7-segment LEDs, and 
                // display the Game Over graphic stored in imagerom2.
                num0    <= score;
                colr    <= 4'd11;

                // On keypress, set the next state to INTROST, which will
                // reset everything, including seqIndex and score, which
                // is why we don't have to reset it here.
                if(key) begin
                    nextState   <= INTROST;
                    state       <= KEYPRESST;

                end else begin
                    state       <= GAMEOVERST;
                end
            end

            // KEYPRESST: Keypress state.
            //
            // Transition state when a key is being held down, but not
            // released yet. Used for debouncing.
            // 
            // Advances to nextState after the hey is released.
            KEYPRESST:begin
                if (!key) begin
                    state   <= nextState;
                end else begin
                    state   <= KEYPRESST;
                end
            end          

            // Default case statement if none of the above states are
            // matched. Should be normally unreachable.
            default: begin
                state <= INTROST;
            end
        endcase
    end
end


// Colour register to indicate which colour of pixel to fill the display
// with. 
reg [3:0] colr = 0;       

// RGB565 colour values.
localparam BLACK    = 16'h0000;
localparam GREEN    = 16'h4DC4;
localparam RED      = 16'hF920;
localparam BLUE     = 16'h24F7;
localparam YELLOW   = 16'hFDA0;

// Always block to select which pixel to pass to pixelData based on the 
// value in the colr register. Sensitive to clock instead of colr since if
// we are reading pixel data from a ROM, the pixel value to be written will
// change each clock cycle.
always @(posedge clock) begin
    pixelData <= BLACK;

    // If colr is in 0, 1, 2, 3, or 8, draw the corresponding solid colour
    // on the display/
    case (colr)
        0:begin
            pixelData   <= BLACK;
        end
        1: begin
            pixelData   <= GREEN;
        end
        2: begin
            pixelData   <= RED;
        end
        4: begin
            pixelData   <= BLUE;
        end
        8: begin
            pixelData   <= YELLOW;
        end

        // For colr=  9, 10, or 11, draw pixels from the ROMs containing
        // one of the Intro, Level Complete and Game Over backgrounds.
        9: begin
            romaddr     <= yCount*17'd240 + xCount;
            pixelData   <= imgrom1q;
        end
        10: begin
            romaddr     <= yCount*17'd240 + xCount;
            pixelData   <= imgrom2q;            
        end
        11: begin

            // The ROM containing the Game Over background is sized to only
            // contain the Game Over ROI, since the rest of the pixels are 
            // black and a LCD-sized TOM just to store all those pixels is
            // unnecessary.
            //
            // This code will draw from the ROM only if the x and y pointers
            // are within the ROI; otherwise, it will draw black.
            if (yAddr > 9'd142 && yAddr<= 9'd178 && xAddr > 8'd23 && xAddr<= 8'd218) begin
                romaddr <= (yCount - 9'd142)*8'd195 + (xCount- 8'd23);
                pixelData <= imgrom3q;
            end else begin
                pixelData <= BLACK;
            end
        end

        // Invalid colour if none of the above match:
        // Just display black.
        default: begin
            pixelData <= BLACK;
        end
    endcase

end

endmodule
