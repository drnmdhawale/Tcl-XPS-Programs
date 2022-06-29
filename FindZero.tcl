proc FindZero {socketID Z} {

puts "start FindZero"
  upvar $Z Zfinal 
  puts stdout "Searching for the glass surface"
 
 # Change velocity to slow one
  set code [catch "PositionerSGammaParametersSet $socketID XYZ.Z 0.2 400 0.001 0.001"] 
  if {$code != 0} { 
  	DisplayErrorAndClose $socketID $code "PositionerSGammaParametersSet" 
	return 
  } 
  
# Configure Event
  set code [catch "EventExtendedConfigurationTriggerSet $socketID GPIO2.ADC1.ADCLowLimit 4.0 0 0 0 XYZ.Z.SGamma.MotionState 0 0 0 0"] 
  if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedConfigurationTriggerSet" 
	return 
  } 

set code [catch "EventExtendedConfigurationActionSet $socketID XYZ.MoveAbort 0 0 0 0" ] 
  if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedConfigurationActionSet" 
	return 
  } 
  
# Start event
set code [catch "EventExtendedStart $socketID EvID"] 
  if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedStart" 
	return 
  } 

# Start motion to touch the glasss surface
set code [catch "GroupMoveRelative $socketID XYZ.Z 4"] 
  if {$code != 0} { 
        if {$code == -27} {
	     puts stdout "Glass surface detected"
	   } else {
	          puts stdout "ERROR Glass surface not detected"
		  DisplayErrorAndClose $socketID $code "FindZero"
		  return -1
	        }
  }

# gets the position
set code [catch "GroupPositionCurrentGet $socketID XYZ.Z  Zfinal"] 
  if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "GroupPositionCurrentGet" 
	return 
  } 
  set code [catch "EventExtendedRemove $socketID $EvID"] 
  if {$code != 0} { 
	DisplayErrorAndClose $socketID $code "EventExtendedRemove" 
	return 
  }   
  puts stdout "glass surface detected at Z=$Zfinal"
}
