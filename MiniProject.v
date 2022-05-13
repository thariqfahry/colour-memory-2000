/*
 * Mini-Project - ColourMemory2000
 * ----------------------------
 * By: Thariq Fahry
 * Date: 14th April 2022
 *
 * Description
 * ------------
 * TODO description
 */
module MiniProject(
    // Global Clock/Reset
    // - Clock
    input              clock,
    input              [3:0] n_key,
    // - Global Reset
    input              globalReset,
    // - Application Reset - for debug
    output             resetApp,
    
    // LT24 Interface
    output             LT24Wr_n,
    output             LT24Rd_n,
    output             LT24CS_n,
    output             LT24RS,
    output             LT24Reset_n,
    output [     15:0] LT24Data,
    output             LT24LCDOn,

    output [      6:0] n_sevenseg0,
    output [      6:0] n_sevenseg1
);

// LCD-specific wires and registers
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;

// LCD Display
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (globalReset),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

// Counters
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

// Pixel Write
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        //In this example we always set write high, and use pixelReady to detect when
        //to update the data.
        pixelWrite <= 1'b1;
        //You could also control pixelWrite and pixelData in a State Machine.
    end
end

always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        xAddr               <= 8'b0;
        yAddr               <= 9'b0;
    end else if (pixelReady) begin
        xAddr               <= xCount;
        yAddr               <= yCount;
    end
end


//
// Game-speciific wires and registers
//

// Game parameters
localparam GAMESPEED = 2;

// invert the key input to make it active-high
wire [3:0] unfilteredkey = ~n_key;

// Filter the active-high key input with the SingleKeypressFilter to make
// sure only one key is pressed at a time
wire [3:0] key;
SingleKeypressFilter u_SingleKeypressFilter(
    .key         (unfilteredkey         ),
    .filteredkey (key )
);

reg [6:0] num0 = 7'd100; //initialise to blank
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
//

// Share the ROM address among all three ROMs  because only one will ever 
// be displayed at a time
reg [16:0] romaddr;

// Intro screen
wire [15:0] imgrom1q;
imgrom1 u_imgrom1(
    .address (romaddr ),
    .clock   (clock   ),
    .q       (imgrom1q)
);

// Level complete screen
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


reg [2:0] state;
reg [2:0] nextState;
reg [2:0] seqIndex = 0;
// reg       gameover=0;
reg [3:0] colr =0;         
reg [3:0] curseq;
reg[6:0] score = 0;


reg [31:0] ec =0;  //elapsed clocks
localparam SECOND = 50000000;
// localparam SECOND = 5000;
localparam MEMRZ_FLASHTIME = SECOND/GAMESPEED;

localparam RESETST      = 0;
localparam INTROST      = 1;
localparam MEMORIZST    = 2;
localparam GAMEST       = 3;
localparam KEYPRESST    = 4;
localparam GAMEOVERST   = 5;
localparam WINST        = 6;

localparam BLACK    = 16'h0000;
localparam GREEN    = 16'h4DC4;
localparam RED      = 16'hF920;
localparam BLUE     = 16'h24F7;
localparam YELLOW   = 16'hFDA0;

always @(posedge clock or posedge resetApp) begin
    if (resetApp) begin
        seqIndex    <= 0;
        colr        <=0;
        curseq      <= 4'b0;
        score       <=0;
        num0        <=7'd100;

        state       <= INTROST;
        nextState   <= INTROST;

    end else begin
        // num0<=state;
        case (state)


            INTROST:begin
                seqIndex <= 0;
                num0<=7'd100;
                score<=0;

                colr<=9;
                if (key) begin
                    nextState<=MEMORIZST;
                    state<=KEYPRESST;
                end else begin
                    state<=INTROST;
                end
            end


            MEMORIZST: begin
                // Loop through all colours in the sequence.
                colr <= coloursequence[seqIndex*4+:4];
                if (seqIndex<SEQ_LENGTH) begin
                    if (ec<MEMRZ_FLASHTIME) begin
                        ec = ec+1;
                    end
                    else begin
                        seqIndex <= seqIndex+2'b1;  
                        ec=0;
                    end

                end else begin
                    seqIndex<=0;
                    colr<=0;
                    state<=GAMEST;
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
                if (seqIndex<SEQ_LENGTH) begin
                    curseq<= coloursequence[seqIndex*4+:4];
                    if (key) begin
                        colr<=key;
                        if (key == curseq) begin
                            seqIndex <= seqIndex+2'b1;
                            score = score+7'b1;
                            nextState <= GAMEST;
                        end else begin
                            nextState <= GAMEOVERST;
                        end
                        state<=KEYPRESST;
                    end else begin
                        state<=GAMEST;
                    end
                end else begin
                    state<=WINST;
                end
            end
            
            // WINST: Win state.
            //
            // Display the Level Complete screen, and the score on the
            // 7-segment LEDs.
            //
            // Wait for any key press. On release, reset the sequence 
            // index and transition to the MEMORIZST for the next level.
            WINST: begin
                num0<=score;
                colr<=4'd10;

                if(key) begin
                    seqIndex<=0;
                    nextState<=MEMORIZST;
                    state<=KEYPRESST;

                end else begin
                    state<=WINST;
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
                num0<=score;
                colr<=4'd11;

                if(key) begin
                    nextState<=INTROST;
                    state <=KEYPRESST;

                end else begin
                    state<=GAMEOVERST;
                end
            end


            KEYPRESST:begin
                if (!key) begin
                    state <= nextState;
                end else begin
                    state<=KEYPRESST;
                end
            end            

            default: begin
                state<=INTROST;
            end
        endcase
    end
end

reg [3:0] colr =0;       
// RGB565 colour values.
localparam BLACK    = 16'h0000;
localparam GREEN    = 16'h4DC4;
localparam RED      = 16'hF920;
localparam BLUE     = 16'h24F7;
localparam YELLOW   = 16'hFDA0;
always @(posedge clock) begin
    pixelData <= BLACK;
    case (colr)
        0:begin
            pixelData <= BLACK;
        end
        1: begin
            pixelData <= GREEN;
        end
        2: begin
            pixelData <= RED;
        end
        4: begin
            pixelData <= BLUE;
        end
        8: begin
            pixelData <= YELLOW;
        end
        9: begin
            romaddr <= yCount*17'd240 + xCount;
            pixelData <= imgrom1q;
        end
        10: begin
            romaddr <= yCount*17'd240 + xCount;
            pixelData <= imgrom2q;            
        end
        11: begin
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
