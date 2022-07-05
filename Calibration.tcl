############################################ 
#
# TCL generation of history
#
#This code was written by Nandkshor Motiram Dhawale, Jan 12nd 2009.
#This code is written to perform calibration of the Z direction movement of XPS motion stage platform
#The problem statement was given by the my MASc. studies advisor Dr. R. Wuthrich from Department of
# Mechanical and Industrial Engineering at Concordia University, Montreal, QC. Canada
# 
############################################ 
 #Display error and close procedure
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


 #Main process 
set TimeOut 150
set code 0 
puts stdout ">>> Start callibration.tcl"

# load the FindZero function
source //Admin//Public//Scripts//FindZero.tcl

 #Open TCP socket 
OpenConnection $TimeOut socketID 
if {$socketID == -1} { 
	puts stdout "OpenConnection failed => $socketID" 
	return 
} 

############################################
puts stdout "Initializing the Group..."
set code [catch "KillAll $socketID "] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "KillAll" 
	return 
} 

set code [catch "GroupInitialize $socketID XYZ"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupInitialize" 
	return 
} 

set code [catch "GroupHomeSearch $socketID XYZ"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupHomeSearch" 
	return 
} 

############################################
# move down fast
puts stdout "Moving Z axis up fast..."
set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 5 400 0.1 0.1"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
	return 
} 

set code [catch "GroupMoveRelative $socketID XYZ.Z 8"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 

########################################


FindZero $socketID Z

puts stdout "The point has been found"

puts stdout "Waiting for 5 seconds"

after 5000

puts stdout "Moving Z Axis up to get the idle condition"

set code [catch "GroupMoveRelative $socketID XYZ.Z -0.01"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 
########################################
#DATA GATHWERING
###########################################
puts stdout "waiting for 5 seconds"

after 5000

puts stdout "Start Moving down and Gather Current Position and voltage"

set code [catch "GatheringConfigurationSet $socketID XYZ.Z.CurrentPosition GPIO2.ADC1"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GatheringConfigurationSet" 
	return 
} 

set code [catch "EventExtendedConfigurationTriggerSet $socketID XYZ.Z.SGamma.MotionState 0 0 0 0"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedConfigurationTriggerSet" 
	return 
} 

set code [catch "EventExtendedConfigurationActionSet $socketID GatheringRun 50000 2 0 0"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedConfigurationActionSet" 
	return 
} 

set code [catch "EventExtendedStart $socketID arg1"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedStart" 
	return 
} 

set code [catch "GroupMoveRelative $socketID XYZ.Z 2.5"] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 

set code [catch "GatheringDataAcquire $socketID"]
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GatheringCurrentNumberGet" 
	return 
} 

set code [catch "GatheringStopAndSave $socketID "] 
if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GatheringStopAndSave" 
	return 
} 

puts stdout ">>>> This is the end of Calibration"


# Close TCP socket 
TCP_CloseSocket $socketID 
