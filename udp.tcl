set ns [new Simulator]

$ns color 1 Blue

set f [open "out.tr" w]
$ns trace-all $f
set fr [open "out.nam" w]
$ns namtrace-all $fr

set n0 [$ns node]
set n1 [$ns node]
$ns duplex-link $n0 $n1 2Mb 2ms DropTail
$ns duplex-link-op $n0 $n1 orient right-down

set tcp0 [new Agent/UDP]
$tcp0 set fid_ 1
set tcp1 [new Agent/Null]

$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $tcp1

$ns connect $tcp0 $tcp1

set ftp [new Application/Traffic/CBR]
$ftp attach-agent $tcp0

proc finish { } { 
	global ns f fr
	$ns flush-trace
	close $f
	close $fr
	exec nam out.nam &
	exit
}



$ns at .1 "$ftp start"
$ns at 2 "$ftp stop"
$ns at 2.1 "finish"

$ns run
 


