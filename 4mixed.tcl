//MCC4
Program:
set val(chan)           	Channel/WirelessChannel
set val(prop)           	Propagation/TwoRayGround
set val(netif)          	Phy/WirelessPhy
set val(mac)            	Mac/Simple
set val(ifq)            	Queue/DropTail/PriQueue   
set val(ll)             	LL
set val(ant)            	Antenna/OmniAntenna       
set val(ifqlen)  	      	50
set val(nn)             	5
set val(rp)          	  	DumbAgent  
set val(x)			250
set val(y)			250

set ns [new Simulator]
$ns use-newtrace
set traceFile [open out.tr w]
$ns trace-all $traceFile
set namFile [open out.nam w]
$ns namtrace-all-wireless $namFile $val(x) $val(y)
#wired 
set n10 [$ns node]
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]

$ns duplex-link $n10 $n11  1Mb 50ms DropTail
$ns duplex-link $n11 $n12  1Mb 30ms DropTail
$ns duplex-link $n12 $n13  1Mb 40ms DropTail
$ns duplex-link $n13 $n14  1Mb 60ms DropTail 

set udp [new Agent/UDP]
set null [new Agent/Null]

set udp1 [new Agent/UDP]
set null1 [new Agent/Null]

set udp2 [new Agent/UDP]
set null2 [new Agent/Null]

set udp3 [new Agent/UDP]
set null3 [new Agent/Null]

$ns attach-agent $n10 $udp
$ns attach-agent $n11 $null
$ns connect $udp $null

$ns attach-agent $n11 $udp1
$ns attach-agent $n12 $null1
$ns connect $udp1 $null1

$ns attach-agent $n12 $udp2
$ns attach-agent $n13 $null2
$ns connect $udp2 $null2

$ns attach-agent $n13 $udp3
$ns attach-agent $n14 $null3
$ns connect $udp3 $null3

set cbr [new  Application/Traffic/CBR] 
$cbr attach-agent $udp

set cbr1 [new  Application/Traffic/CBR] 
$cbr1 attach-agent $udp1

set cbr2 [new  Application/Traffic/CBR] 
$cbr2 attach-agent $udp2

set cbr3 [new  Application/Traffic/CBR] 
$cbr3 attach-agent $udp3

$ns at 0.5 "$cbr start" 	
$ns at 4.5 "$cbr stop"
$ns at 1.0 "$cbr1 start" 	
$ns at 5.0 "$cbr1 stop"
$ns at 1.5 "$cbr2 start" 	
$ns at 5.5 "$cbr2 stop"
$ns at 1.0 "$cbr3 start" 	
$ns at 5.5 "$cbr3 stop"
$ns at 6 "finish"  

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn); 
set chan_ [new $val(chan)]

$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
		-macType $val(mac)  -ifqType $val(ifq)  \
		-ifqLen $val(ifqlen) -antType $val(ant) \
		-propType $val(prop) -phyType $val(netif) \
		-topoInstance $topo a-agentTrace ON -routerTrace ON \
		-macTrace ON -movementTrace ON -channel $chan_ 

for {set i 0} {$i < $val(nn)} {incr i} {
    set n($i) [$ns node]
    $n($i) random-motion 0
    #$n($i) start
}

$n(0) set X_ 20.0
$n(0) set Y_ 100.0
$n(0) set Z_ 0.0

$n(1) set X_ 120.0
$n(1) set Y_ 100.0
$n(1) set Z_ 0.0

$n(2) set X_ 60.0
$n(2) set Y_ 50.0
$n(2) set Z_ 0.0

$n(3) set X_ 40.0
$n(3) set Y_ 80.0
$n(3) set Z_ 0.0

$n(4) set X_ 120.0
$n(4) set Y_ 20.0
$n(4) set Z_ 0.0

$ns at 0.0 "$n(0) setdest [$n(0) set X_] [$n(0) set Y_] 0.0"
$ns at 0.0 "$n(1) setdest [$n(1) set X_] [$n(1) set Y_] 0.0"
$ns at 0.0 "$n(2) setdest [$n(2) set X_] [$n(2) set Y_] 0.0"
$ns at 0.0 "$n(3) setdest [$n(3) set X_] [$n(3) set Y_] 0.0"
$ns at 0.0 "$n(4) setdest [$n(4) set X_] [$n(4) set Y_] 0.0"

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp
$ns attach-agent $n(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $n(1) $tcp1
$ns attach-agent $n(2) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
set sink2 [new Agent/TCPSink]
$ns attach-agent $n(2) $tcp2
$ns attach-agent $n(3) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

set tcp3 [new Agent/TCP]
set sink3 [new Agent/TCPSink]
$ns attach-agent $n(3) $tcp3
$ns attach-agent $n(4) $sink3
$ns connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3

proc stop {} {
    global ns traceFile namFile
    $ns flush-trace
    close $traceFile; close $namFile
    exit 0
}

$ns at 0.5 "$ftp start" 
$ns at 5.0 "$ftp stop"
$ns at 1.0 "$ftp1 start" 
$ns at 4.5 "$ftp1 stop"
$ns at 1.5 "$ftp2 start" 
$ns at 5.5 "$ftp2 stop"
$ns at 2.5 "$ftp3 start" 
$ns at 3.5 "$ftp3 stop"
$ns at 100.0 "stop"
$ns run



