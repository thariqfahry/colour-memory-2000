catch {file delete {*}[glob -nocomplain *_msim_rtl_verilog.do.bak*]}
onbreak {resume}
set waveFile [file normalize "./wave.do"]
if { [file exists $waveFile] } {
    #If the saved file exists, load it
    do $waveFile
} else {
    #Otherwise simply add all signals in the testbench formatted as unsigned decimal.
    add wave -radix unsigned -position insertpoint sim:/*
}
configure wave -timelineunits ns

#.main clear
transcript file temp
del msim_transcript
transcript file msim_transcript
del temp

run -all
wave zoom full

#powershell -ExecutionPolicy ByPass -command "python render.py"