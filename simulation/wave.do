onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clock/Reset
add wave -noupdate -label clock -radix hexadecimal /MiniProject_tb/clock
add wave -noupdate -label reset -radix hexadecimal /MiniProject_tb/reset
add wave -noupdate -label resetApp -radix hexadecimal /MiniProject_tb/resetApp
#add wave -noupdate -divider LT24
#add wave -noupdate -label LT24Wr_n -radix hexadecimal /MiniProject_tb/LT24Wr_n
#add wave -noupdate -label LT24Rd_n -radix hexadecimal /MiniProject_tb/LT24Rd_n
#add wave -noupdate -label LT24CS_n -radix hexadecimal /MiniProject_tb/LT24CS_n
#add wave -noupdate -label LT24RS -radix hexadecimal /MiniProject_tb/LT24RS
#add wave -noupdate -label LT24Reset_n -radix hexadecimal /MiniProject_tb/LT24Reset_n
#add wave -noupdate -label LT24Data -radix hexadecimal /MiniProject_tb/LT24Data
#add wave -noupdate -label LT24LCDOn -radix hexadecimal /MiniProject_tb/LT24LCDOn
#add wave -noupdate -divider {Pattern Generation}
#add wave -noupdate -label xAddr -radix decimal /MiniProject_tb/LT24Top_dut/xAddr
#add wave -noupdate -label yAddr -radix decimal /MiniProject_tb/LT24Top_dut/yAddr
#add wave -noupdate -label pixelReady -radix hexadecimal /MiniProject_tb/LT24Top_dut/pixelReady
#add wave -noupdate -label pixelWrite -radix hexadecimal /MiniProject_tb/LT24Top_dut/pixelWrite
#add wave -noupdate -label pixelData -radix hexadecimal /MiniProject_tb/LT24Top_dut/pixelData
#add wave -noupdate -divider {Functional Model}
#add wave -noupdate -label command -radix hexadecimal /MiniProject_tb/DisplayModel/command
#add wave -noupdate -label payloadCntr -radix decimal /MiniProject_tb/DisplayModel/payloadCntr
#add wave -noupdate -label xPtr -radix decimal /MiniProject_tb/DisplayModel/xPtr
#add wave -noupdate -label yPtr -radix decimal /MiniProject_tb/DisplayModel/yPtr
#add wave -noupdate -label pixelColour -radix hexadecimal /MiniProject_tb/DisplayModel/pixelColour
#add wave -noupdate -label pixelWrite -radix hexadecimal /MiniProject_tb/DisplayModel/pixelWrite
#add wave -noupdate -label mAddrCtl -radix binary -childformat {{{/MiniProject_tb/DisplayModel/mAddrCtl[7]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[6]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[5]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[4]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[3]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[2]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[1]} -radix hexadecimal} {{/MiniProject_tb/DisplayModel/mAddrCtl[0]} -radix hexadecimal}} -subitemconfig {{/MiniProject_tb/DisplayModel/mAddrCtl[7]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[6]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[5]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[4]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[3]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[2]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[1]} {-height 15 -radix hexadecimal} {/MiniProject_tb/DisplayModel/mAddrCtl[0]} {-height 15 -radix hexadecimal}} /MiniProject_tb/DisplayModel/mAddrCtl
#add wave -noupdate -label xMin -radix decimal /MiniProject_tb/DisplayModel/xMin
#add wave -noupdate -label xMax -radix decimal /MiniProject_tb/DisplayModel/xMax
#add wave -noupdate -label yMin -radix decimal /MiniProject_tb/DisplayModel/yMin
#add wave -noupdate -label yMax -radix decimal /MiniProject_tb/DisplayModel/yMax

radix define states {
4'd0 "RESETST",
4'd1 "INITST",
4'd2 "GAMEST",
4'd3 "KEYPRESST",
4'd4 "GAMEOVERST",
4'd5 "WINST",
-default unsigned
}

radix define colours {
4'd0 "BLACK ",
4'd1 "GREEN ",
4'd2 "RED   ",
4'd4 "BLUE  ",
4'd8 "YELLOW",
-default hex
}

proc rr {} {
   restart -force
   run -all
}
proc wz {} { wave zoom full }

add wave -noupdate -divider {Game}
add wave -position end -label state  -radix states sim:/MiniProject_tb/dut/state
add wave -position end -label colour -radix colours sim:/MiniProject_tb/dut/colr
add wave -position end -label elaclk -radix unsigned sim:/MiniProject_tb/dut/ec
add wave -position end -label 1sec   -radix unsigned sim:/MiniProject_tb/dut/SECOND

add wave -position end -label key                            sim:/MiniProject_tb/dut/key
add wave -position end -label seqIndex  -radix unsigned      sim:/MiniProject_tb/dut/seqIndex
add wave -position end -label curseq                         sim:/MiniProject_tb/dut/curseq

add wave -position end -label hex       -radix hex           sim:/MiniProject_tb/dut/u_HexTo7Segment/hex
add wave -position end -label seg (inv) -radix hex           sim:/MiniProject_tb/dut/u_HexTo7Segment/seg
add wave -position end -label 7seg0     -radix hex           sim:/MiniProject_tb/sevenseg0

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19650000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {21 us}
