;MinecraftServerToTray

;Credit to ThunderTray for the simple starting point:
;https://github.com/cryptogeek/ThunderTray/blob/master/ThunderTray.ahk
;Credit also to Min2Tray:
;http://junyx.breadfan.de/Min2Tray

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance ignore

;title must contain
SetTitleMatchMode, 2

Menu,Tray,NoStandard 
Menu,Tray,DeleteAll 
Menu,Tray,Add,&Quit,ExitSub

IconSet = 0

OnExit, ExitSub

OnMessage(0x404, "AHK_NOTIFYICON")
 
AHK_NOTIFYICON(wParam, lParam)
{
    if (lParam = 0x202) ; WM_LBUTTONUP
	{
		WinShow, Minecraft server console window
		WinRestore, Minecraft server console window
	}
}

Loop
{
	WinGet MMX, MinMax, Minecraft server console window
	If MMX = -1		;-1 means its minimized
	{
		WinHide, Minecraft server console window
	}

	sleep 500
}

ExitSub:
	WinShow, Minecraft server console window
	WinRestore, Minecraft server console window
ExitApp
