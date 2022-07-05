############################################ 
#
# TCL generation of history
#
#This code was written by Nandkishor Motiram Dhawale, Feb 12th 2009.
#This code is written to record and control the voltage and current signal to the power supply via the XPS motion stage platform
#The problem statement was given by the my MASc. studies advisor Dr. R. Wuthrich from Department of
# Mechanical and Industrial Engineering at Concordia University, Montreal, QC. Canada
# 
############################################ 

# Display error and close procedure
proc DisplayErrorAndClose {socketID code APIName} {
	global tcl_argv
	if {$code != -2 && $code != -108} {
		set code2 [catch "ErrorStringGet $socketID $code strError"]
		if {$code2 != 0} {
			puts stdout "$APIName ERROR => $code - ErrorStringGet ERROR => $code2"
			set tcl_argv(0) "$APIName ERROR => $code"
		} else {
			puts stdout "$APIName $strError"
			set tcl_argv(0) "$APIName $strError"
		}
	} else {
		if {$code == -2} {
			puts stdout "$APIName ERROR => $code : TCP timeout"
			set tcl_argv(0) "$APIName ERROR => $code : TCP timeout"
		} 
		if {$code == -108} {
			puts stdout "$APIName ERROR => $code : The TCP/IP connection was closed by an administrator"
			set tcl_argv(0) "$APIName ERROR => $code :  The TCP/IP connection was closed by an administrator"
		} 
	}
	set code2 [catch "TCP_CloseSocket $socketID"] 
	return
}

# Main process 
set TimeOut 100
set code 0 


# Open TCP socket 
OpenConnection $TimeOut socketID 
if {$socketID == -1} { 
	puts stdout "OpenConnection failed => $socketID" 
	return 
} 

set path //Admin//Public//Current

set p [open $path "a+"]

set k 0

puts $p "Voltage(V)   Current(A)"

for {set i 1} {$i<1001} {incr i} {

		set k [expr {$k + 0.002564}]
		
		puts stdout "k = $k"
				
		set code [catch "GPIOAnalogSet $socketID GPIO2.DAC4 $k"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogSet" 
		return 
	} 
	
 		set code [catch "GatheringConfigurationSet $socketID GPIO2.ADC2"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GatheringConfigurationSet" 
		return 
	} 
	
		set code [catch "GPIOAnalogGet $socketID GPIO2.ADC2 arg1"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogGet" 
		return 
	} 
	
	set v [expr {$k * 15.6}]

	puts $p "$v    $arg1"
	
	after 1

}


puts $p "Here we have reached 40 voltes and will start to go back from 40 voltes to zero"

for {set j 1} {$j<1001} {incr j} {

		puts stdout "k = $k"

		set k [expr {$k - 0.002564}]
		
				
		set code [catch "GPIOAnalogSet $socketID GPIO2.DAC4 $k"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogSet" 
		return 
	} 
	
 		set code [catch "GatheringConfigurationSet $socketID GPIO2.ADC2"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GatheringConfigurationSet" 
		return 
	} 
	
		set code [catch "GPIOAnalogGet $socketID GPIO2.ADC2 arg1"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogGet" 
		return 
	} 
	
	set v [expr {$k * 15.6}]

	puts $p "$v    $arg1"
	
	after 1
}



close $p

# Close TCP socket 
TCP_CloseSocket $socketID 
