#!/usr/bin/osascript

tell application "Terminal"
    set ProfilesNames to name of every settings set
    repeat with ProfileName in ProfilesNames
        set font name of settings set ProfileName to "JetBrainsMonoNL-Regular"
        set font size of settings set ProfileName to 14
    end repeat
end tell
