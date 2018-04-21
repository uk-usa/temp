Program:
proc finish {} { 
	global ns trFile namFile
	$ns flush-trace 
	close $namFile
	close $trFile
} 
set ns [new Simulator]

set trFile [open out.tr w] 
$ns trace-all $trFile
set namFile [open out.nam w] 
$ns namtrace-all $namFile

set n0 [$ns node]
set n1 [$ns node]
$ns duplex-link $n0 $n1  1Mb 50ms DropTail

set udp [new Agent/UDP]
set null [new Agent/Null]

$ns attach-agent $n0 $udp
$ns attach-agent $n1 $null
$ns connect $udp $null

set cbr [new  Application/Traffic/CBR] 
$cbr attach-agent $udp 

$ns at 0.5 "$cbr start" 	
$ns at 4.5 "$cbr stop"
$ns at 5 "finish" 

$ns run
