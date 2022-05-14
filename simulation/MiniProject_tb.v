/*
 * MiniProject - ColourMemory2000 Test bech
 * ----------------------------
 * By: 201158825 Thariq Fahry
 * Date: 14th April 2022
 *
 * Description
 * ------------
 * A test bench for the Mini-Project module.
 *  
 * This is based on the code skeleton in the Unit 3 LT24Top_tb:
 * https://github.com/leeds-embedded-systems/ELEC5566M-Unit3-thariqfahry/blob/main/3-2-LT24TestProject/simulation/LT24Top_tb.v
 *
 */

`timescale 1 ns/100 ps

module MiniProject_tb;

//
// Parameter Declarations
//
localparam NUM_CYCLES = 5000000;
localparam CLOCK_FREQ = 5000;        // Clock frequency. Must be equal to the SECOND parameter in MiniProject.v.

localparam NUM_FRAMES = 3;           // Number of frames to render to write.txt before ending the simulation.


//
// Test Bench Generated Signals
//
reg  clock;
reg  reset;

reg [3:0] key = 4'b0000;
wire[3:0] n_key = ~key;

//
// DUT Output Signals
//
wire resetApp;

wire [6:0] n_sevenseg0;
wire [6:0] n_sevenseg1;
wire [6:0] sevenseg0 = ~n_sevenseg0;
wire [6:0] sevenseg1 = ~n_sevenseg1;


// LT24 Display Interface
wire        LT24Wr_n;
wire        LT24Rd_n;
wire        LT24CS_n;
wire        LT24RS;
wire        LT24Reset_n;
wire [15:0] LT24Data;
wire        LT24LCDOn;

//
// Device Under Test
//
MiniProject  dut (
   .clock       ( clock       ),
   .globalReset ( reset       ),
   .resetApp    ( resetApp    ),
   .n_key       ( n_key       ),
   
   .LT24Wr_n    ( LT24Wr_n    ),
   .LT24Rd_n    ( LT24Rd_n    ),
   .LT24CS_n    ( LT24CS_n    ),
   .LT24RS      ( LT24RS      ),
   .LT24Reset_n ( LT24Reset_n ),
   .LT24Data    ( LT24Data    ),
   .LT24LCDOn   ( LT24LCDOn   ),
   .n_sevenseg0 ( n_sevenseg0 ),
   .n_sevenseg1 ( n_sevenseg1 )
);

//
// Display Functional Model
//
wire[7:0] frame;
LT24FunctionalModel #(
    .WIDTH  ( 240 ),
    .HEIGHT ( 320 )
) DisplayModel (
    // LT24 Interface
    .LT24Wr_n    ( LT24Wr_n    ),
    .LT24Rd_n    ( LT24Rd_n    ),
    .LT24CS_n    ( LT24CS_n    ),
    .LT24RS      ( LT24RS      ),
    .LT24Reset_n ( LT24Reset_n ),
    .LT24Data    ( LT24Data    ),
    .LT24LCDOn   ( LT24LCDOn   ),
    .frame       ( frame )
);

//
// Test Bench Logic
//

// Task to press a button for hold_seconds_frac seconds, release it, and
// wait for an additional hold_seconds_frac seconds.
task pressAndRelease(input [3:0] keyval, input [4:0] hold_seconds_frac);
    begin
        key<= keyval;
        repeat(CLOCK_FREQ/hold_seconds_frac)@(posedge clock);
        key <= 4'b0000;
        repeat(CLOCK_FREQ/hold_seconds_frac)@(posedge clock);
    end
endtask


integer fd;
integer i;
localparam  SEQ_LENGTH = 6;
reg [SEQ_LENGTH*4:0] testsequence;

initial begin
    $display("%d ns\tSimulation Started",$time);      
    reset = 1'b1;                                     
    repeat(2) @(posedge clock);                       
    reset = 1'b0;                                     
    wait(resetApp === 1'b0);                          
    $display("%d ns\tInitialisation Complete",$time); 
    $display("STARTRENDER,",$time,";");
    repeat(CLOCK_FREQ*3)@(posedge clock);

    // A random test sequence.
    testsequence = {4'd1,4'd8,4'd4,4'd2,4'd1,4'd8};

    // Loop from 0 to SEQ_LENGTH, and apply that stimulus to the KEY input.
    for (i = 0; i<SEQ_LENGTH;i=i+1) begin
        pressAndRelease(testsequence[i*4+:4], 1);
    end

    // Press a button 1/20 of a second to advance modes.
    pressAndRelease(4'b0001,20);
    pressAndRelease(4'b0000,1);

    // Perform the sequence again.
    for (i = 0; i<SEQ_LENGTH;i=i+1) begin
        pressAndRelease(testsequence[i*4+:4], 1);
    end    

end


//
//Clock generator + simulation / frame number time limit.
//
initial begin
    clock = 1'b0;
end

real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

integer half_cycles = 0;
always begin
    #(HALF_CLOCK_PERIOD);         
    clock = ~clock;               
    half_cycles = half_cycles + 1;
    
    if (half_cycles == (2*NUM_CYCLES)) begin 
		half_cycles = 0;
        $display("ENDRENDER, t=%d, cyc = %d",$time, NUM_CYCLES);
        $stop;
    end

    // If NUM_FRAMES have been written, exit the simulation early.
    if (frame==NUM_FRAMES) begin
        $display("FRAME, cyc = %d", half_cycles/2);
        $stop;
    end
end

endmodule