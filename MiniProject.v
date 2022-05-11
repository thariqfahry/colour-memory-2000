module MiniProject(
    // Global Clock/Reset
    // - Clock
    input              clock,
    input              [3:0] key,
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

    output reg [6:0]   sevenseg0
);

//
// Local Variables
//
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;

//
// LCD Display
//
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

//
// X Counter
//
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

//
// Y Counter
//
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

// Convert onehot key to numerical so we can treat it as a value in the
// range 0,1,2,3.
wire[1:0] ne_key;
OneHottoNumerical u_OneHottoNumerical(
    .onehot    (key    ),
    .numerical (ne_key )
);


//
// Pixel Write
//
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



reg [2:0] state;
reg [11:0] coloursequence = {4'd0,4'd8,4'd4,4'd1,4'd0,4'd8};     //encoded as keypresses
localparam SEQ_LENGTH = 6;
reg [2:0] seqIndex = 0;
reg [3:0] colr =0;                      //encoded as color numbers
reg gameover=0;

reg [31:0] ec;  //elapsed clocks
localparam SECOND = 5000;

localparam RESETST = 0;
localparam INITST = 1;
localparam GAMEST = 2;
localparam KEYPRESST = 3;
localparam GAMEOVERST = 4;
localparam WINST    = 5;

localparam BLACK    = 16'h0000;
localparam GREEN    = 16'h5FE8;
localparam RED      = 16'hfa28;
localparam BLUE     = 16'h12de;
localparam YELLOW   = 16'hffc6;

// localparam REDST = 2;
// localparam BLUEST = 3;
// localparam YELST = 4;

always @(posedge clock or posedge resetApp) begin
    if (resetApp) begin
        state <= RESETST;
        seqIndex <= 0;
        gameover<=0;
        colr<=0;
        sevenseg0<=0;
    end else begin
        case (state)
            RESETST: begin
                seqIndex <= 0;
                gameover<=0;
                colr<=0;
                sevenseg0<=0;
                state<=INITST;      
            end
            //display colors state
            INITST: begin
                colr = coloursequence[seqIndex*4+:4];
                if (seqIndex<SEQ_LENGTH) begin
                    if (ec<SECOND/8) begin
                        ec = ec+1;
                    end
                    else begin
                        ec=0;
                        seqIndex <= seqIndex+2'b1;  
                    end
                end else begin
                    seqIndex<=0;
                    state<=GAMEST;
                    colr<=0;
                end
            end

            // game state
            GAMEST:begin
                if (key) begin
                    colr<=key;
                    if (seqIndex<SEQ_LENGTH) begin
                        if (key == coloursequence[seqIndex*4+:4]) begin
                            seqIndex <= seqIndex+2'b1;
                            gameover<=0;
                        end else begin
                            gameover<=1;
                        end
                        state<=KEYPRESST;
                    end else begin
                        state<=WINST;
                    end
                    // colr <= coloursequence[seqIndex*4+:4];
                end else begin
                    state<=GAMEST;
                end
            end

            KEYPRESST:begin
                if (!key) begin
                    if (gameover) begin
                        state<=GAMEOVERST;
                    end else begin
                        state<=GAMEST;
                    end
                end else begin
                    state<=KEYPRESST;
                end
            end

            GAMEOVERST:begin
                sevenseg0 <= 7'b1111111;
                if(key) begin
                    state<=RESETST;
                end else begin
                    state<=GAMEOVERST;
                end
            end
            
            WINST: begin
                sevenseg0 <= 6'b1;
                if(key) begin
                    state<=RESETST;
                end else begin
                    state<=WINST;
                end
            end

            default: begin
                state<=RESETST;
            end
        endcase
    end
end

always @(*) begin
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
        default: begin
            pixelData <= BLACK;
        end
    endcase

    
end


endmodule

/*
 * N-Bit Up Counter
 * ----------------
 * By: Thomas Carpenter
 * Date: 13/03/2017 
 *
 * Short Description
 * -----------------
 * This module is a simple up-counter with a count enable.
 * The counter has parameter controlled width, increment,
 * and maximum value.
 *
 */

module UpCounterNbit #(
    parameter WIDTH = 10,               //10bit wide
    parameter INCREMENT = 1,            //Value to increment counter by each cycle
    parameter MAX_VALUE = (2**WIDTH)-1  //Maximum value default is 2^WIDTH - 1
)(   
    input                    clock,
    input                    reset,
    input                    enable,    //Increments when enable is high
    output reg [(WIDTH-1):0] countValue //Output is declared as "WIDTH" bits wide
);

always @ (posedge clock) begin
    if (reset) begin
        //When reset is high, set back to 0
        countValue <= {(WIDTH){1'b0}};
    end else if (enable) begin
        //Otherwise counter is not in reset
        if (countValue >= MAX_VALUE[WIDTH-1:0]) begin
            //If the counter value is equal or exceeds the maximum value
            countValue <= {(WIDTH){1'b0}};   //Reset back to 0
        end else begin
            //Otherwise increment
            countValue <= countValue + INCREMENT[WIDTH-1:0];
        end
    end
end

endmodule