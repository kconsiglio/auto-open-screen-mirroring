
-- A click event works normally if screen mirroring is already in main menu bar
-- but the icon may not be in the menu bar if it hasn't been placed there already.
-- So we check if the Screen Mirroring item is in the menu bar and click it there
-- if not we go through the Control Center drop down.
-- pass name of airplay device with commandline argument to autoselect that device. 
-- if nothing is passed it'll just open the Screen Mirroring menu without selecting a device
use framework "Foundation"
use scripting additions



-- passing commandline argument 
-- https://stackoverflow.com/questions/57690558/compile-applescript-into-application-with-parameters
set arguments to (current application's NSProcessInfo's processInfo's arguments) as list
if first item of arguments contains "osascript" then set arguments to rest of arguments -- skip osascript path
if (count arguments) is 1 then set end of arguments to "no arguments"
repeat with anItem in rest of arguments -- skip the main executable path
	set airPlayDevice to anItem
end repeat
# osascript still returns the last result



tell application "System Events"
	tell its application process "ControlCenter"
		set osVersion to get system version of (system info)
		-- log osVersion
		set status to ""
		-- click on Screen Mirroring dropdown if it's on the menu bar
		if exists (first UI element of menu bar 1 whose value of attribute "AXIdentifier" contains "screen-mirroring") then
			set screenMirroringDropDownButton to first UI element of menu bar 1 whose value of attribute "AXIdentifier" contains "screen-mirroring"
			click screenMirroringDropDownButton
			delay 1
			set window_ to title of its window as string
			-- click on the Control Center drop down on menu bar
		else
			set controlCenter to first UI element of menu bar 1 whose value of attribute "AXIdentifier" contains "controlcenter"
			click controlCenter
			delay 1
			set window_ to title of its window as string
			set status to controlCenterDropDown(osVersion, window_) of me as string
			
		end if
		
		if status is not "failed" then
			getScreenMirroringDropDown(osVersion, airPlayDevice, window_) of me
		end if
		
	end tell
end tell
return

-- "click" on screen mirroring on the Control Center drop down
on controlCenterDropDown(osVersion, window_)
	tell application "System Events"
		tell its application process "ControlCenter"
			tell its window window_
				
				-- clicking doesn't actually work on the screen mirroring button(checkbox) 
				-- in the Control Center dropdown so it's click action is "perform action 1" or "perform action 2" depending on system version
				-- we will also find the Screen Mirroring by using AXIdentifier or title
				try
					-- ventura
					if osVersion ³ 13 then
						set controlCenterElements to UI elements of group 1
						set myattribute to "AXIdentifier"
						set myaction to 1
						
						-- Monterey 
					else if osVersion < 13 and osVersion ³ 12 then
						set controlCenterElements to UI elements
						set myattribute to "AXIdentifier"
						set myaction to 2
						
						-- big sur
					else
						set controlCenterElements to UI elements of group 1 of group 1
						set myattribute to "AXTitle"
						set myaction to 1
					end if
				on error
					log "Error getting screen mirroring button"
					return "failed"
				end try
				-- go through the UI elements of Control Center drop down and "click" on the screen mirroring button
				repeat with anItem in controlCenterElements
					try
						if exists attribute myattribute of anItem then
							if value of attribute myattribute of anItem contains "screen-mirroring" or value of attribute myattribute of anItem contains "Screen Mirroring" then
								perform action myaction of anItem
								exit repeat
							end if
						end if
					on error
						log "error clicking screen mirroring"
						return "failed"
					end try
				end repeat
				delay 1
			end tell
		end tell
	end tell
	return
end controlCenterDropDown

on getScreenMirroringDropDown(osVersion, airPlayDevice, window_)
	tell application "System Events"
		tell its application process "ControlCenter"
			tell its window window_
				set screenMirroringDropDown to ""
				try
					-- get ui elements of screen mirroring drop down
					-- Monterey and Ventura
					if osVersion ³ 12 then
						set x to UI elements --?? if in menu bar this is needed ??
						set screenMirroringDropDown to UI elements
						-- big sur
					else
						set screenMirroringDropDown to UI elements of group 1
						
					end if
				on error
					log "Error getting UI elements of screen mirroring drop down."
					return
				end try
				
				
				repeat with anItem in screenMirroringDropDown
					try
						
						set itemsOfScreenMirroringMenu to value of attribute "AXChildren" of anItem
						-- find screen mirroring device and click
						repeat with childItem in itemsOfScreenMirroringMenu
							
							if (exists attribute "AXIdentifier" of childItem) then
								set aScreenMirroringItem to value of attribute "AXIdentifier" of childItem
								--	log aScreenMirroringItem
							else
								set aScreenMirroringItem to title of childItem
								--	log aScreenMirroringItem
							end if
							if aScreenMirroringItem ends with airPlayDevice then
								click childItem
								exit repeat
							end if
						end repeat
					on error
						log "error clicking on or setting device in Screen Mirroring drop down "
					end try
				end repeat
				
			end tell
		end tell
	end tell
	return
end getScreenMirroringDropDown

