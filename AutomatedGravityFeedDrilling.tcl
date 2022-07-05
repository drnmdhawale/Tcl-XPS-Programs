############################################ 
#
# TCL generation of history
#
#This code was written by Nandkshor Motiram Dhawale, PhD On June 22nd 2016.
#This code is written to perform gravity feed drilling on the SACE Machine using the XPS motion stage platform
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
set TimeOut 3000
set code 0 
puts stdout ">>> constant feed drilling  process"

# load the FindZero function
source //Admin//Public//Scripts//FindZero.tcl

 #Open TCP socket 
OpenConnection $TimeOut socketID 
if {$socketID == -1} { 
	puts stdout "OpenConnection failed => $socketID" 
	return 
} 

############################################
# Initialization and Homing for all three  axis
puts stdout "Have you Initialized before?"
 
############################################


puts stdout "Move Y axis up to start..."

puts stdout "Move Z axis up to start..."
	
# Move Y`axis  
	
set code [catch "PositionerSGammaParametersSet $socketID XYZ.Y 2 400 0.001 0.001"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
	return 
} 

set code [catch "GroupMoveRelative $socketID XYZ.Y -4"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 

# Move Z`axis up 
	
set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 2 400 0.001 0.001"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
	return 
} 

set code [catch "GroupMoveRelative $socketID XYZ.Z 8"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 

# Move X`axis 

set code [catch "PositionerSGammaParametersSet $socketID XYZ.X 2 400 0.001 0.001"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
	return 
} 

set code [catch "GroupMoveRelative $socketID XYZ.X 7"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
} 

####################################################




####################################################
# Start the For Loop
for {set i 1} {$i<10} {incr i} {

puts stdout "##################################################"
	
	puts stdout "Starting Fabrication of the $i hole"
		
	########################################
		# Finds the first point
		
		puts stdout ">>> Finding location of the $i th hole"

		FindZero $socketID Z

		
		set Z1 [expr {-0.06 + $Z}]
		
		after 2000

	#############################################
# Move up the Z axis
		
#puts stdout "Find the IDLE condition"
		
#set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 0.2 400 0.001 0.001"] 
		#if {$code != 0} { 
		#	DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
		#return 
	#} 

	#	set code [catch "GroupMoveRelative $socketID XYZ.Z -0.3 "] 
	#	if {$code != 0} { 
	#		DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	#	return 
	#} 
	
		puts stdout "Z1=$Z1"	
		
		after 2000
		
	##################################################
			

	
		# Move down Z Axis
		
		puts stdout "Move 1 mm down "
		
		set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 0.1 400 0.001 0.001"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
		return 
	} 
	
	
		set code [catch "GroupMoveRelative $socketID XYZ.Z -0.05"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
		return 
	} 
	
	set code [catch "GroupMoveRelative $socketID XYZ.Z 1.0"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
		return 
	} 
	
	#####################################################
	# Find the Hole depth
		
		set code [catch "GroupPositionCurrentGet $socketID XYZ.Z  Z2"] 
				if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GroupPositionCurrentGet" 
		return 
		} 
	
		set DeltaZ [expr {$Z2 - $Z1}]
		
		puts stdout "Z2=$Z2"	
		
		puts stdout "Estimated hole depth = $DeltaZ"
		
		################################################
		
		set code [catch "GPIOAnalogSet $socketID GPIO2.DAC4 2.24"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogSet" 
		return 
	} 
		
				
	after 90000
	
	puts stdout "It will take 60 seconds"
	
	
		
		
		set code [catch "GPIOAnalogSet $socketID GPIO2.DAC4 0"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GPIOAnalogSet" 
		return 
	} 
		
	after 10000
		
		
	######################################################
	#Move up the Z axis
	
	set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 1 400 0.001 0.001"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
		return 
	} 

		set code [catch "GroupMoveRelative $socketID XYZ.Z -3"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
		return 
	} 
		
	puts stdout "The $i th hole has been finished"
	######################################################
	#Move X axis left for the next channel
	
		puts stdout "Move X axis to drill the next hole"
		
		set code [catch "PositionerSGammaParametersSet $socketID XYZ.X 1 400 0.001 0.001"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
		return 
	} 

		set code [catch "GroupMoveRelative $socketID XYZ.X 3"] 
		if {$code != 0} { 
			DisplayErrorAndClose $socketID $code "GroupMoveRelative" 
	return 
	} 
	##########################################################
}
########################################
puts stdout ">>>> Gravity Feed Drilling for 10 holes, using SACE technology has  been successfully finished"

# Close TCP socket 
TCP_CloseSocket $socketID 
###### The Value for Z axis to come up to zero position is around 0.15 to 0.13
