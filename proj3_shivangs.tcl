#Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Header: /cvsroot/nsnam/ns-2/tcl/ex/wireless-simple-mac.tcl,v 1.2 2003/07/07 18:21:15 xuanc Exp $
#
# Use simple mac rather than 802.11
#   
#     --Xuan Chen, USC/ISI, July 3, 2003
#
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/Simple                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq



set var_node [lindex $argv 1]

set val(nn)             $var_node                  ;# number of mobilenodes

# routing protocol
set val(rp)              DumbAgent  
#set val(rp)             DSDV                     
#set val(rp)             DSR                      
#set val(rp)             AODV                     
set var [lindex $argv 0]

$val(mac) set num_packet $var
set val(x)		50
set val(y)		50

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open wireless-simple-mac.tr w]
$ns_ trace-all $tracefd

#set namtrace [open wireless-simple-mac.nam w]
#$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel
set chan_ [new $val(chan)]

# Create node(0) and node(1)

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace ON \
		-channel $chan_


#set xn 0
#set yn 0

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    #$node_($i) random-motion 0
	#if {$xn > 48}{
	#set yn [expr $yn + 1]
	#set xn 0
	#}

	#if{$yn > 48}{
        #set yn 0
        #}

    	$ns_ initial_node_pos $node_($i) 20
	$node_($i) set X_ 10.0
	$node_($i) set Y_ 20.0
	$node_($i) set Z_ 0.0
	
	#set xn [expr $xn + 1]

}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#


#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
#$ns_ at 0.0 "$node_(0) setdest 50.0 50.0 5.0"
#$ns_ at 0.0 "$node_(1) setdest 60.0 40.0 10.0"


# Node_(1) then starts to move away from node_(0)
#$ns_ at 3.0 "$node_(1) setdest 240.0 240.0 30.0" 

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)

#set tcp [new Agent/TCP]
#$tcp set class_ 2
#set sink [new Agent/TCPSink]
#$ns_ attach-agent $node_(0) $tcp
#$ns_ attach-agent $node_(1) $sink
#$ns_ connect $tcp $sink
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#$ns_ at 0.5 "$ftp start" 

for {set i 0} {$i < $val(nn)} {incr i} {
set udp($i) [new Agent/UDP]
$ns_ attach-agent $node_($i) $udp($i)
set cbr($i) [new Application/Traffic/CBR]
$cbr($i) set packetSize_ 16
$cbr($i) set interval_  0.02
$cbr($i) attach-agent $udp($i)
}

#set udp(1) [new Agent/UDP]
#$ns_ attach-agent $node_(1) $udp(1)
#set cbr(1) [new Application/Traffic/CBR]
#$cbr(1) set packetSize_ 16
#$cbr(1) set interval_  1
#$cbr(1) attach-agent $udp(1)


	set node_($val(nn)) [$ns_ node]
    #$node_($i) random-motion 0
    #$ns_ initial_node_pos $node_($i) 20
	$node_($val(nn)) set X_ 25.0
	$node_($val(nn)) set Y_ 25.0
	$node_($val(nn)) set Z_ 0.0

set null0 [new Agent/Null]
$ns_ attach-agent $node_($val(nn)) $null0

for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ connect $udp($i) $null0
#$ns_ connect $udp(1) $null0
}
for {set i 0} {$i < $val(nn)} {incr i} {

$ns_ at 0.0 "$cbr($i) start"

$ns_ at 100.0 "$cbr($i) stop"

}
#$ns_ at 0 "$cbr(1) start"
#$ns_ at 4.0 "$cbr(1) stop"
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 100.1 "$node_($i) reset";
}
$ns_ at 100.2 "stop"
$ns_ at 100.3 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
