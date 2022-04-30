onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clock/Reset
add wave -noupdate -label clock -radix hexadecimal /LT24Top_tb/clock
add wave -noupdate -label reset -radix hexadecimal /LT24Top_tb/reset
add wave -noupdate -label resetApp -radix hexadecimal /LT24Top_tb/resetApp
add wave -noupdate -divider LT24
add wave -noupdate -label LT24Wr_n -radix hexadecimal /LT24Top_tb/LT24Wr_n
add wave -noupdate -label LT24Rd_n -radix hexadecimal /LT24Top_tb/LT24Rd_n
add wave -noupdate -label LT24CS_n -radix hexadecimal /LT24Top_tb/LT24CS_n
add wave -noupdate -label LT24RS -radix hexadecimal /LT24Top_tb/LT24RS
add wave -noupdate -label LT24Reset_n -radix hexadecimal /LT24Top_tb/LT24Reset_n
add wave -noupdate -label LT24Data -radix hexadecimal /LT24Top_tb/LT24Data
add wave -noupdate -label LT24LCDOn -radix hexadecimal /LT24Top_tb/LT24LCDOn
add wave -noupdate -divider {Pattern Generation}
add wave -noupdate -label xAddr -radix decimal /LT24Top_tb/LT24Top_dut/xAddr
add wave -noupdate -label yAddr -radix decimal /LT24Top_tb/LT24Top_dut/yAddr
add wave -noupdate -label pixelReady -radix hexadecimal /LT24Top_tb/LT24Top_dut/pixelReady
add wave -noupdate -label pixelWrite -radix hexadecimal /LT24Top_tb/LT24Top_dut/pixelWrite
add wave -noupdate -label pixelData -radix hexadecimal /LT24Top_tb/LT24Top_dut/pixelData
add wave -noupdate -divider {Functional Model}
add wave -noupdate -label command -radix hexadecimal /LT24Top_tb/DisplayModel/command
add wave -noupdate -label payloadCntr -radix decimal /LT24Top_tb/DisplayModel/payloadCntr
add wave -noupdate -label xPtr -radix decimal /LT24Top_tb/DisplayModel/xPtr
add wave -noupdate -label yPtr -radix decimal /LT24Top_tb/DisplayModel/yPtr
add wave -noupdate -label pixelColour -radix hexadecimal /LT24Top_tb/DisplayModel/pixelColour
add wave -noupdate -label pixelWrite -radix hexadecimal /LT24Top_tb/DisplayModel/pixelWrite
add wave -noupdate -label mAddrCtl -radix binary -childformat {{{/LT24Top_tb/DisplayModel/mAddrCtl[7]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[6]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[5]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[4]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[3]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[2]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[1]} -radix hexadecimal} {{/LT24Top_tb/DisplayModel/mAddrCtl[0]} -radix hexadecimal}} -subitemconfig {{/LT24Top_tb/DisplayModel/mAddrCtl[7]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[6]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[5]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[4]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[3]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[2]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[1]} {-height 15 -radix hexadecimal} {/LT24Top_tb/DisplayModel/mAddrCtl[0]} {-height 15 -radix hexadecimal}} /LT24Top_tb/DisplayModel/mAddrCtl
add wave -noupdate -label xMin -radix decimal /LT24Top_tb/DisplayModel/xMin
add wave -noupdate -label xMax -radix decimal /LT24Top_tb/DisplayModel/xMax
add wave -noupdate -label yMin -radix decimal /LT24Top_tb/DisplayModel/yMin
add wave -noupdate -label yMax -radix decimal /LT24Top_tb/DisplayModel/yMax
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
