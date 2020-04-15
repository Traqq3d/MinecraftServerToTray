;MinVivaldiToTray

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

;Run, thunderbird.exe
;WinWait, ahk_exe vivaldi.exe
;WinHide


h_activeWinID := WinExist(" - Vivaldi")

; get module full path (owner.exe)
Win_Get(h_activeWinID, "M", tmpOwner )
SplitPath, tmpOwner, , tmpDir, , tmpNameNoEx

; use first icon from owner.exe of window
h_appExeIcon = 1
h_appExe = %tmpOwner%

f_ShowTrayIcon( h_appExe, h_appExeIcon )



OnExit, ExitSub

OnMessage(0x404, "AHK_NOTIFYICON")
 
AHK_NOTIFYICON(wParam, lParam)
{
    if (lParam = 0x202) ; WM_LBUTTONUP
	{
		WinShow, - Vivaldi
		WinRestore, - Vivaldi
	}
}

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

Loop
{
	If !ProcessExist("vivaldi.exe")
	{
		;ExitApp
	}
	
	WinGet, winState, MinMax, ahk_exe vivaldi.exe
	if (winState = -1) {
		WinHide, - Vivaldi
	}
   
	sleep 500
}

ExitSub:
ExitApp


















;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; general -- functions
;

Win_Get(Hwnd, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="", ByRef o9="") {
   /*
   (c) by majkinetor
   see: <http://code.google.com/p/mm-autohotkey/>
   Parameters:
   		pQ			- List of query parameters.
   		o1 .. o9	- Reference to output variables. R,L,B & N query parameters can return multiple outputs.
   Query:
   		C,I		- Class, pId.
   		R,L,B,N	- One of the window rectangles: R (window Rectangle), L (cLient rectangle screen coordinates), B (ver/hor Border), N (captioN rect).
   					  N returns the size of the caption regardless of the window style or theme. These coordinates include all title-bar elements except the window menu.
   					  The function returns x, y, w & h separated by space. 
   					  For all 4 query parameters you can additionaly specify x,y,w,h arguments in any order (except Border which can have only x(hor) and y(ver) arguments) to
   					  extract desired number into output variable.
   		S,E		- Style, Extended style.
   	   P,A,O		- Parents handle, Ancestors handle, Owners handle.
   		M			- Module full path (owner exe), unlike WinGet,,ProcessName which returns only name without path.
   		T			- Title for a top level window or text for a child window.
   		D			- DC.
   		#			- Non-negative integer. If present must be first option in the query string. Function will return window information
   					  not for passed window but for its ancestor. 1 is imidiate parent, 2 is parent's parent etc... 0 represents root window.
   Returns:
   		o1       - first output is returned as function result
   */ 
	c := SubStr(pQ, 1, 1)
	if c is integer 
	{
		if (c = 0)
			Hwnd := DllCall("GetAncestor", "uint", Hwnd, "uint", 2, "UInt")
		else loop, %c%
			Hwnd := DllCall("GetParent", "uint", Hwnd, "UInt")

		pQ := SubStr(pQ, 2)
	}
		
	if pQ contains R,B,L
		VarSetCapacity(WI, 60, 0), NumPut(60, WI),  DllCall("GetWindowInfo", "uint", Hwnd, "uint", &WI)
	
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on
	
	k := i := 0
	loop
	{
		i++, k++
		if (_ := SubStr(pQ, k, 1)) = ""
			break

		if !IsLabel("Win_Get_" _ )
			return A_ThisFunc "> Invalid query parameter: " _
		Goto %A_ThisFunc%_%_%

		Win_Get_C:
				WinGetClass, o%i%, ahk_id %hwnd%		
		continue

		Win_Get_I:
				WinGet, o%i%, PID, ahk_id %hwnd%		
		continue

		Win_Get_N:
				rect := "title"
				VarSetCapacity(TBI, 44, 0), NumPut(44, TBI, 0), DllCall("GetTitleBarInfo", "uint", Hwnd, "str", TBI)
				title_x := NumGet(TBI, 4, "Int"), title_y := NumGet(TBI, 8, "Int"), title_w := NumGet(TBI, 12) - title_x, title_h := NumGet(TBI, 16) - title_y 
				WinGet, style, style, ahk_id %Hwnd%				
				title_h :=  style & 0xC00000 ? title_h : 0			  ; if no WS_CAPTION style, set 0 as win sets randoms otherwise...
				goto Win_Get_Rect
		Win_Get_B:
				rect := "border"
				border_x := NumGet(WI, 48, "UInt"),  border_y := NumGet(WI, 52, "UInt")	
				goto Win_Get_Rect
		Win_Get_R:
				rect := "window"
				window_x := NumGet(WI, 4,  "Int"),  window_y := NumGet(WI, 8,  "Int"),  window_w := NumGet(WI, 12, "Int") - window_x,  window_h := NumGet(WI, 16, "Int") - window_y
				goto Win_Get_Rect
		Win_Get_L: 
				client_x := NumGet(WI, 20, "Int"),  client_y := NumGet(WI, 24, "Int"),  client_w := NumGet(WI, 28, "Int") - client_x,  client_h := NumGet(WI, 32, "Int") - client_y
				rect := "client"
		Win_Get_Rect:
				k++, arg := SubStr(pQ, k, 1)
				if arg in x,y,w,h
				{
					o%i% := %rect%_%arg%, j := i++
					goto Win_Get_Rect
				}
				else if !j
						  o%i% := %rect%_x " " %rect%_y  (_ = "B" ? "" : " " %rect%_w " " %rect%_h)
				
		rect := "", k--, i--, j := 0
		continue
		Win_Get_S:
			WinGet, o%i%, Style, ahk_id %Hwnd%
		continue
		Win_Get_E: 
			WinGet, o%i%, ExStyle, ahk_id %Hwnd%
		continue
		Win_Get_P: 
			o%i% := DllCall("GetParent", "uint", Hwnd, "UInt")
		continue
		Win_Get_A: 
			o%i% := DllCall("GetAncestor", "uint", Hwnd, "uint", 2, "UInt") ; GA_ROOT
		continue
		Win_Get_O: 
			o%i% := DllCall("GetWindowLong", "uint", Hwnd, "int", -8, "UInt") ; GWL_HWNDPARENT
		continue
		Win_Get_T:
			if DllCall("IsChild", "uint", Hwnd)
				 WinGetText, o%i%, ahk_id %hwnd%
			else WinGetTitle, o%i%, ahk_id %hwnd%
		continue
		Win_Get_M: 
			WinGet, _, PID, ahk_id %hwnd%
			hp := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", _ ) 
			if (ErrorLevel or !hp) 
				continue
			VarSetCapacity(buf, 512, 0), DllCall( "psapi.dll\GetModuleFileNameEx" (A_IsUnicode ? "W" : "A"), "uint", hp, "uint", 0, "str", buf, "uint", 512),  DllCall( "CloseHandle", hp ) 
			o%i% := buf 
		continue
		Win_Get_D:
			o%i% := DllCall("GetDC", "uint", Hwnd, "UInt")
		continue
	}	
	DetectHiddenWindows, %oldDetect%
	return o1
}

f_GetOwnerOrSelf( winID ) {
   ; class substitution [former f_SubstEvilClass()]
   ; winID must be passed to this function
   ; returns winID (either of owner, if any, or passed one) 

   ; find the owner of the window
   If Win_Get(winID, "O", owner)
      Return owner
   
   Return winID
}

f_ShowTrayIcon( file, number ) {
   Global h_RegSubkey, h_StarterIcon, h_StarterIcon#

   Menu, TRAY, UseErrorLevel
	RegRead, stealth, HKCU, %h_RegSubkey%\Misc, StealthMode	; are we in StealthMode?
	If ( Not ErrorLevel ) {
		If ( stealth ) {
			If ( Not A_IconHidden )
				Menu, TRAY, NoIcon
			Return
		}
   }

	If ( Not A_IconHidden )	; coming from hidden icon: ALWAYS renew icon!
		If ( A_IconFile = file AND A_IconNumber = number )	; icon props not changed
			Return

   IfExist, %file%
   {
      Menu, TRAY, Icon, %file%, %number%, 1  ; 1=freeze icon
      If ( Not ErrorLevel )	; if ErrorLevel was NOT raised -> allright
         Goto, OKout
   }

   ; if ErrorLevel or not existing file -> set default icon
   Menu, TRAY, Icon, %h_StarterIcon%, %h_StarterIcon#%, 1 ; 1=freeze icon

   OKout:
      Menu, TRAY, Icon	; show icon
      Menu, TRAY, UseErrorLevel, Off
   Return
}