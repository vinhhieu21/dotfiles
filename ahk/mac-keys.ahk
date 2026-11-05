; Mac-style shortcuts for Windows: the counterpart of karabiner/.
; Left Alt acts as Cmd and the Win key as Option, matching their physical positions on a Mac.
; Fully suspended (keyboard/mouse hooks removed) while Dota 2 or any app in
; the ExcludedApps group is the active window, so game input is untouched.
#Requires AutoHotkey v2.0
#SingleInstance Force
A_MenuMaskKey := "vkE8"   ; stop a lone Alt release from opening app menus

GroupAdd "ExcludedApps", "ahk_exe dota2.exe"
; Add more games here, e.g.:  GroupAdd "ExcludedApps", "ahk_exe cs2.exe"

SetCapsLockState "AlwaysOff"
SetTimer CheckExcluded, 250
CheckExcluded() {
    excluded := WinActive("ahk_group ExcludedApps") ? true : false
    if (A_IsSuspended != excluded) {
        Suspend excluded
        SetCapsLockState excluded ? "Off" : "AlwaysOff"  ; give games a normal Caps Lock
    }
}

; --- Terminal: Cmd maps to Ctrl+Shift, because Ctrl+C must stay SIGINT (see wezterm/wezterm.lua) ---
#HotIf WinActive("ahk_exe wezterm-gui.exe")
<!c::Send "^+c"
<!v::Send "^+v"
<!t::Send "^+t"
<!w::Send "^+w"
<!f::Send "^+f"
<!d::Send "^+d"
<!+d::Send "^!+d"
<!+Enter::Send "^+z"
<!=::Send "^+{=}"
<!-::Send "^+{-}"
<!0::Send "^+0"

#HotIf !WinActive("ahk_group ExcludedApps")

; --- Caps Lock: tap = Escape, hold + F-row = media (karabiner/karabiner.json) ---
; Brightness and keyboard-backlight keys (F1, F2, F5, F6) have no Windows equivalent here.
CapsLock::Send "{Esc}"
; Launched directly: GlazeWM owns Win+Tab (glazewm/config.yaml).
CapsLock & F3::Run "explorer.exe shell:::{3080F90E-D7AD-11D9-BD98-0010B5A5E8D4}"  ; Mission Control -> Task View
CapsLock & F4::Send "{LWin}"          ; Launchpad -> Start
CapsLock & F7::Send "{Media_Prev}"
CapsLock & F8::Send "{Media_Play_Pause}"
CapsLock & F9::Send "{Media_Next}"
CapsLock & F10::Send "{Volume_Mute}"
CapsLock & F11::Send "{Volume_Down}"
CapsLock & F12::Send "{Volume_Up}"

; --- Clipboard / editing ---
<!c::Send "^c"
<!x::Send "^x"
<!v::Send "^v"
<!+v::Send "^+v"
<!z::Send "^z"
<!+z::Send "^y"
<!a::Send "^a"
<!s::Send "^s"
<!+s::Send "^+s"
<!f::Send "^f"
<!p::Send "^p"
<!o::Send "^o"

; --- Tabs / windows ---
<!t::Send "^t"
<!+t::Send "^+t"
<!w::Send "^w"
<!n::Send "^n"
<!+n::Send "^+n"
<!r::Send "^r"
<!l::Send "^l"
<!q::Send "!{F4}"
<!m::WinMinimize "A"
<!,::Send "^,"

; --- Zoom ---
<!=::Send "^{=}"
<!-::Send "^{-}"
<!0::Send "^0"

; --- Word navigation (Win key acts as Option) ---
#Left::Send "^{Left}"
#Right::Send "^{Right}"
#+Left::Send "^+{Left}"
#+Right::Send "^+{Right}"
#BackSpace::Send "^{BackSpace}"
#Delete::Send "^{Delete}"

; --- Text navigation (Left Alt acts as Cmd) ---
<!Left::Send "{Home}"
<!Right::Send "{End}"
<!Up::Send "^{Home}"
<!Down::Send "^{End}"
<!+Left::Send "+{Home}"
<!+Right::Send "+{End}"
<!+Up::Send "^+{Home}"
<!+Down::Send "^+{End}"
<!BackSpace::Send "+{Home}{Delete}"

; --- Screenshots (Cmd+Shift+3 / 4) ---
<!+3::Send "{PrintScreen}"
<!+4::Run "ms-screenclip:"  ; not Win+Shift+S: GlazeWM binds that to "move to workspace S"
#HotIf
