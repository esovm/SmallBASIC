;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI
!include "MUI.nsh"

;--------------------------------
;General
  ;Name and file
  Name "SmallBASIC (FLTK/MingW32)"
  OutFile "sbasic.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\SBW32\FLTK_0.9.7"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\SmallBASIC\FLTK_0.9.7" ""

;--------------------------------
;Interface Settings
  !define MUI_ABORTWARNING

;--------------------------------
;Pages
  !insertmacro MUI_PAGE_LICENSE "..\..\doc\LICENSE"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

; Optional section (can be disabled by the user)
Section "Start Menu Shortcut"
  CreateDirectory "$SMPROGRAMS\SmallBASIC 0.9.7"
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\SmallBASIC 0.9.7\SmallBASIC.lnk" "$INSTDIR\sbfltk.exe" "-r welcome.bas"
  CreateShortCut "$SMPROGRAMS\SmallBASIC 0.9.7\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section "Quick Launch Shortcut"
  SetOutPath $INSTDIR
  CreateShortCut "$QUICKLAUNCH\SmallBASIC.lnk" "$INSTDIR\sbfltk.exe" "" "$INSTDIR\sbfltk.exe" 0
SectionEnd

Section "Desktop Shortcut"
  SetOutPath $INSTDIR
  CreateShortCut "$DESKTOP\SmallBASIC.lnk" "$INSTDIR\sbfltk.exe" "" "$INSTDIR\sbfltk.exe" 0
SectionEnd

Section "Create .BAS file association"
  WriteRegStr HKCR ".bas" "" "SmallBASIC"
  WriteRegStr HKCR "SmallBASIC" "" "SmallBASIC"
  WriteRegStr HKCR "SmallBASIC\DefaultIcon" "" "$INSTDIR\sbfltk.exe,0"
  WriteRegStr HKCR "SmallBASIC\shell" "" "open"
  WriteRegStr HKCR "SmallBASIC\shell\open\command" "" '"$INSTDIR\sbfltk.exe" -e "%1"'
  WriteRegStr HKCR "SmallBASIC\shell" "" "run"
  WriteRegStr HKCR "SmallBASIC\shell\run\command" "" '"$INSTDIR\sbfltk.exe" -r "%1"'
SectionEnd

Section "SmallBASIC (FLTK/MingW32)" SecMain
  SetOutPath "$INSTDIR"
  File sbfltk.exe
  File readme.html
  File welcome.bas
  SetOutPath $INSTDIR\Help
  File "help\*.*"
  SetOutPath $INSTDIR\Bas-Home
  File "Bas-Home\*.*"

  ;Store installation folder
  WriteRegStr HKCU "Software\SmallBASIC\FLTK_0.9.7" "" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Descriptions
  ;Language strings
  LangString DESC_SecMain ${LANG_ENGLISH} "Program executable and required DLL file."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ; Remove registry keys
  DeleteRegKey /ifempty HKCU "Software\SmallBASIC\FLTK_0.9.7"

  ; Remove files and uninstaller
  Delete $INSTDIR\sbfltk.exe
  Delete $INSTDIR\readme.html
  Delete $INSTDIR\welcome.bas
  Delete $INSTDIR\Uninstall.exe
  Delete $INSTDIR\Help\*.*
  Delete $INSTDIR\Bas-Home\*.*

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\SmallBASIC 0.9.7\*.*"
  Delete "$QUICKLAUNCH\SmallBASIC.lnk"
  Delete "$DESKTOP\SmallBASIC.lnk"

  ; Remove directories used
  RMDir "$SMPROGRAMS\SmallBASIC 0.9.7"
  RMDir "$INSTDIR\Help"
  RMDir "$INSTDIR\Bas-Home"
  RMDir "$INSTDIR"

SectionEnd
