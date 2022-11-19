
-- A click event works normally if screen mirroring is already in main menu bar
-- but the icon may not be in the menu bar if it hasn't been placed there already.
-- So we check if the Screen Mirroring item is in the menu bar and click it there
-- if not we go through the Control Center drop down
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
		set OSVersion to get system version of (system info)
		# Skip this section if on Ventura
		
		-- first check if the Screen Mirroring item is on the menu bar and if it is click it
		if exists menu bar item "Screen Mirroring" of menu bar 1 then
			-- open Screen Mirroring drop down
			click menu bar item "Screen Mirroring" of menu bar 1
			delay 1
			
			-- interact with the Screen Mirroring drop down
			tell item 1 of window "Control Center"
				try
					-- montery
					
					if exists (checkbox airPlayDevice of scroll area 1) then
						set computerCheck to scroll area 1
						
					else
						-- big sur
						if exists (checkbox airPlayDevice of scroll area 1 of group 1) then
							set computerCheck to scroll area 1 of group 1
							
						end if
					end if
					-- click the specified device in the Screen Mirroring drop down
					if exists (checkbox airPlayDevice in computerCheck) then
						click checkbox airPlayDevice of computerCheck
						
					end if
				on error
					-- do nothing
				end try
				
			end tell
			
			-- if the screen mirroring icon isn't on menubar you need to go through the Control Center drop down
			-- the "click" action doesn't work on the Screen Mirroring item (which is a checkbox) in the Control Center drop down
			-- the Screen Mirroring item has a "action 2" or "action 1" depending on system version. 
		else
			
			-- click the Control Center menu bar item (montery/bigsur)
			if OSVersion < 13 then
				click menu bar item "Control Center" of menu bar 1
			-- click the Control Center menu bar item  (ventura)
			else if OSVersion ³ 13 then
				tell its menu bar 1
					tell (UI elements whose description is "Control Center")
						click
					end tell
				end tell
			end if

			delay 1

			tell its window "Control Center"
				-- Big Sur and Monterey 
				if OSVersion < 13 then
	            	-- click the Screen Mirroring item (checkbox) on the Control Center drop down
					if exists checkbox "Screen Mirroring" then
						tell its checkbox "Screen Mirroring"
							perform action 2
							delay 1
						end tell
					else
						-- slightly different for Big Sur
						if exists (checkbox "Screen Mirroring" of group 1 of group 1) then
							tell its checkbox "Screen Mirroring" of group 1 of group 1
								perform action 1
								delay 1
							end tell
						end if
					end if
				-- Ventura "click" screen mirroring button on the Control Center drop down
				else if OSVersion ³ 13 then
					set screenMirroringButton to button 2 of group 1
					perform action 1 of screenMirroringButton
				end if

				-- Click the Airplay Device in the Screen Mirroring drop down. 
				--set screenMirroringDropDown to UI elements of its scroll area 1
				--log screenMirroringDropDown
				
				try
					set screenMirroringDropDown to UI element 2
					set device to UI element airPlayDevice of screenMirroringDropDown
					click device
				on error
					-- do nothing
				end try
			end tell
		end if
	end tell
end tell
return


