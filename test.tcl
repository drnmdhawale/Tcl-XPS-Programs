############################################ 
#
# TCL generation of history
#
#This code was written by Nandkishor Motiram Dhawale, Dec 13th 2008.
#This code is written to check the movements of XPS motion stage platform
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
set TimeOut 200
set code 0 
puts stdout ">>> Start Test.tcl"

# load the FindZero function
source //Admin//Public//Scripts//FindZero.tcl

 #Open TCP socket 
OpenConnection $TimeOut socketID 
if {$socketID == -1} { 
	puts stdout "OpenConnection failed => $socketID" 
	return 
} 

############################################

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
#OpenConnection $TimeOut socketID 
#if {$socketID == -1} { 
#	puts stdout "OpenConnection failed => $socketID" 
#	return 
#}
# move up fast
set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 60 40 0.1 0.1"] 
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
puts stdout ">>> Try to start FindZero.tcl"

FindZero $socketID Z

puts stdout ">>>> Z = $Z"

#set Z [expr -$Z]

#set code [catch "GroupMoveRelative $socketID XYZ.Z $Z"] 
#if {$code != 0} { 
#	DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
#	return 
#} 

########################################

puts stdout ">>>> This is the end of test.tcl"


# Close TCP socket 
TCP_CloseSocket $socketID 
