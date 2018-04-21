Program:
set val(chan)           	Channel/WirelessChannel
set val(prop)           	Propagation/TwoRayGround
set val(netif)          	Phy/WirelessPhy
set val(mac)            	Mac/Simple
set val(ifq)            	Queue/DropTail/PriQueue   
set val(ll)             	LL
set val(ant)            	Antenna/OmniAntenna       
set val(ifqlen)  	      	50
set val(nn)             	2
set val(rp)          	  	DumbAgent  
set val(x)			250
set val(y)			250

set ns [new Simulator]
$ns use-newtrace
set traceFile [open out.tr w]
$ns trace-all $traceFile
set namFile [open out.nam w]
$ns namtrace-all-wireless $namFile $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn);    # :P
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

$ns at 0.0 "$n(0) setdest [$n(0) set X_] [$n(0) set Y_] 0.0"
$ns at 0.0 "$n(1) setdest [$n(1) set X_] [$n(1) set Y_] 0.0"

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp
$ns attach-agent $n(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

proc stop {} {
    global ns traceFile namFile
    $ns flush-trace
    close $traceFile; close $namFile
    exit 0
}

$ns at 0.5 "$ftp start" 
$ns at 5.0 "$ftp stop"
$ns at 100.0 "stop"
$ns run



