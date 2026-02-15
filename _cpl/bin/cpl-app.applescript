on run
	set homePath to POSIX path of (path to home folder)

	-- Run picker UI
	try
		set pickerResult to do shell script homePath & "bin/cpl-picker"
	on error
		return
	end try

	set AppleScript's text item delimiters to tab
	set resultParts to text items of pickerResult
	set projectName to item 1 of resultParts
	set launchMode to item 2 of resultParts
	set AppleScript's text item delimiters to ""

	if projectName is "~ (Home)" then
		set projPath to homePath
		set projectName to "home"
	else if projectName is "~/projects" then
		set projPath to homePath & "projects"
		set projectName to "projects"
	else
		set projPath to homePath & "projects/" & projectName
	end if

	-- Zed only: just open Zed and done
	if launchMode is "zed" then
		do shell script "open -a 'Zed Preview' " & quoted form of projPath
		return
	end if

	-- Detect cold launch BEFORE telling iTerm anything
	set iTermWasRunning to application "iTerm" is running

	-- All other modes need a slot
	set slotResult to do shell script homePath & "bin/cpl-slot claim " & quoted form of projectName
	set slotNum to slotResult as integer

	if slotNum is 0 then
		set statusInfo to do shell script homePath & "bin/cpl-slot status"
		display dialog "All 3 slots in use:" & return & return & statusInfo buttons {"OK"} default button "OK"
		return
	end if

	-- Right monitor: 3 equal-width slots, filling right to left
	set monX to 3440
	set monW to 3440
	set sw to monW div 3
	set r to monX + monW - ((slotNum - 1) * sw)
	set l to r - sw
	if slotNum is 3 then set l to monX

	-- Build command based on mode
	if launchMode is "terminal" then
		set cmd to homePath & "bin/cpl-slot set-pid " & slotNum & " $$; trap '" & homePath & "bin/cpl-cleanup " & slotNum & " " & projectName & "' EXIT; cd " & quoted form of projPath
		set profileName to "Default"
	else
		set cmd to "cd " & quoted form of projPath & " && " & homePath & "bin/cpl-launch " & slotNum & " " & projectName & " " & launchMode & " " & quoted form of projPath
		set profileName to "CPL"
	end if

	-- Cold launch: suppress default startup window, then start iTerm
	if not iTermWasRunning then
		-- Write pref BEFORE iTerm starts so it reads the new value on init
		do shell script "defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool true"

		tell application "iTerm" to activate

		-- Wait for iTerm to be fully responsive to AppleScript
		repeat 30 times
			try
				tell application "iTerm" to count of windows
				exit repeat
			on error
				delay 0.5
			end try
		end repeat

		-- Restore default startup behavior for future normal launches
		do shell script "defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool false"

		-- Safety net: close any windows that appeared despite the pref
		try
			tell application "iTerm"
				repeat while (count of windows) > 0
					close window 1
					delay 0.2
				end repeat
			end tell
		end try
	end if

	-- Create CPL window (with retry for transient -609 on cold launch)
	repeat 5 times
		try
			tell application "iTerm"
				activate
				set newWindow to (create window with profile profileName)
				set bounds of newWindow to {l, 0, r, 1440}
				tell current session of newWindow
					set name to projectName
					write text cmd
				end tell
			end tell
			exit repeat
		on error errMsg number errNum
			if errNum is -609 then
				delay 0.5
			else
				display dialog errMsg buttons {"OK"} default button "OK"
				exit repeat
			end if
		end try
	end repeat
end run
