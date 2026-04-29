; qKiisu Windows Installer Build Script
; requires NullSoft Installer 3.08 or later
; Reference http://kkmalar.org/WebApplication/qz-print-2.0.0-RC1/ant/windows/windows-packager.nsi.in


;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  Unicode true
  
  ;Compression algorithm used to compress files/data in the installer
  SetCompressor /solid /final lzma

  !define /ifndef NAME "qKiisu"
  !define /ifndef COMPANY "RainWalker"
  !define /ifndef ARCH_BITS 64
  !define UNINSTALL_EXE "$INSTDIR\uninstall.exe"
  !define UNINSTALL_REG_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

  ; Include File Functions Header
  !include "FileFunc.nsh"

  ; Include macros to handle installations on x64 machines
  !include "x64.nsh"

  ; Logic operators lib for calculating DPI
  !include 'LogicLib.nsh'

  ; Detect Windows Version lib
  !include 'WinVer.nsh'

  Name ${NAME}
  OutFile "build\${NAME}Setup-${ARCH_BITS}bit.exe"

  ; Get version tag from git. Will be used in titles
  !tempfile StdOut
  !echo "${StdOut}"
  !system '"git" describe --tags --abbrev=0 --exclude "*-rc*" > "${StdOut}"'
  !define /file VERSION "${StdOut}"
  !delfile "${StdOut}"
  !undef StdOut

  ; Default installation Dir. On Windows it will be C:\Program Files\qKiisu
  InstallDir "$PROGRAMFILES64\${NAME}"

  ; Installer/Uninstaller Icon
  !define MUI_ICON "installer-assets\icons\${NAME}-installer.ico"
  !define MUI_UNICON "installer-assets\icons\${NAME}-uninstaller.ico"

  ; Enable scaling for high DPI screen
  ManifestDPIAware true

  ; Version Information displayer in Properties -> Details tab
  ; Required for antivirus databases
  VIProductVersion "${VERSION}.0" ; Only exact 4 numbers allowed x.x.x.x
  VIAddVersionKey "FileDescription" "qKiisu Windows Installer"
  VIAddVersionKey "FileVersion" "${VERSION}.0"
  VIAddVersionKey "ProductName" "qKiisu"
  VIAddVersionKey "ProductVersion" "${VERSION}.0"
  VIAddVersionKey "CompanyName" "RainWalker"
  VIAddVersionKey "LegalCopyright" "(C) RainWalker"

;--------------------------------
;Installer wizard pages

  ; Global window title 
  Caption "qKiisu ${VERSION} Setup"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "installer-assets\backgrounds\windows_installer\windows_installer_header.bmp"
  !define MUI_HEADERIMAGE_UNBITMAP "installer-assets\backgrounds\windows_installer\windows_installer_header.bmp"

  ; Welcome and Finish page settings
  !define MUI_WELCOMEPAGE_TITLE  "Welcome to qKiisu ${VERSION} Setup"
  !define MUI_WELCOMEPAGE_TEXT "qKiisu is a desktop application for updating Kiisu firmware and databases, manage files on SD card, and repair corrupted device.$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\nOpen Source and Distributed under GPL v3 License$\r$\nCopyright (C) RainWalker"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "installer-assets\backgrounds\windows_installer\windows_installer_welcome.bmp"
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "installer-assets\backgrounds\windows_uninstaller\windows_uninstaller_welcome.bmp"
  !insertmacro MUI_PAGE_WELCOME

  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_COMPONENTS
  ;!define MUI_FINISHPAGE_NOAUTOCLOSE ; Debug
  !insertmacro MUI_PAGE_INSTFILES

  !define MUI_FINISHPAGE_TITLE "qKiisu ${VERSION} Setup Complete"
;  !define MUI_FINISHPAGE_RUN "$INSTDIR\${NAME}.exe"
;  !define MUI_FINISHPAGE_RUN_TEXT "Run qKiisu now"
  !define MUI_FINISHPAGE_LINK "More Info --> Kiisu Documentation"
  !define MUI_FINISHPAGE_LINK_LOCATION "https://kiisu.io"
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_COMPONENTS
  !define MUI_UNFINISHPAGE_NOAUTOCLOSE ; do not close uninstall log
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "-Main Application"

	RMDir /r $INSTDIR

    ; Use 64bit registry keys, not WOW6432Node
    SetRegView 64 

    ; Sets the context of shell folders to "All Users"
    SetShellVarContext all    
    ; Kills running qKiisu.exe processes
    DetailPrint "Looking for running qKiisu.exe..."
    nsExec::ExecToLog "wmic.exe PROCESS where $\"Name like 'qKiisu.exe'$\" CALL terminate"
    nsExec::ExecToLog "wmic.exe PROCESS where $\"Name like 'qKiisu.exe'$\" CALL terminate" ;Twice to avoid long time exiting
    SetShellVarContext current

	SetOutPath $INSTDIR

    ; Extract files
    SetOverwrite on
    File /r "build\${NAME}\*"

    ; NOTE: STM32 DFU driver and Visual C++ Redistributable are not bundled.
    ; Install them separately if needed:
    ;   - STM32 driver: use the bundled KiisuDriverTool / Zadig.
    ;   - VC++ runtime: https://aka.ms/vs/17/release/vc_redist.x64.exe

    WriteUninstaller "${UNINSTALL_EXE}"

    WriteRegStr HKLM "Software\${NAME}" "" $INSTDIR ; Save real install path for next update
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "DisplayName" "${NAME} ${VERSION}"
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "Publisher" "${COMPANY}"
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "UninstallString" "$\"${UNINSTALL_EXE}$\""
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "QuietUninstallString" "$\"${UNINSTALL_EXE}$\" /S"
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "DisplayIcon" "$\"$INSTDIR\${NAME}.exe$\""
    WriteRegStr HKLM "${UNINSTALL_REG_PATH}" "DisplayVersion" "${VERSION}"
    WriteRegDWORD HKLM "${UNINSTALL_REG_PATH}" "NoModify" 1
    WriteRegDWORD HKLM "${UNINSTALL_REG_PATH}" "NoRepair" 1
SectionEnd

Section "Start menu entry" StartMenuSection
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${NAME}.exe"
SectionEnd

Section "Desktop shortcut" DesktopShortcutSection
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${NAME}.exe"
SectionEnd

Section "-Cleanup"

    ; Use 64bit registry keys, not WOW6432Node
    SetRegView 64

	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKLM "${UNINSTALL_REG_PATH}" "EstimatedSize" "$0"
SectionEnd


;--------------------------------
;Uninstaller Section

Section "un.Uninstall qKiisu" UninstallqKiisuSection

  ; Use 64bit registry keys, not WOW6432Node
  SetRegView 64

  ; Kills running qKiisu.exe processes
  DetailPrint "Looking for running qKiisu.exe..."
  nsExec::ExecToLog "wmic.exe PROCESS where $\"Name like 'qKiisu.exe'$\" CALL terminate"
  nsExec::ExecToLog "wmic.exe PROCESS where $\"Name like 'qKiisu.exe'$\" CALL terminate" ;Twice to avoid long time exiting

  Delete "$DESKTOP\${NAME}.lnk"
  Delete "$SMPROGRAMS\${NAME}.lnk"
  Delete "$INSTDIR\uninstall.exe"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
  DeleteRegKey HKLM "Software\${NAME}"
  RMDir /r $INSTDIR
SectionEnd


;--------------------------------
; Descriptions
; A text hovers over a component on choosing components to install on MUI_PAGE_COMPONENTS
   
  ;Language strings
  LangString DESC_StartMenuSection ${LANG_ENGLISH} "Add qKiisu to Windows Start menu"
  LangString DESC_DesktopShortcutSection ${LANG_ENGLISH} "Create qKiisu shortcut on Desktop"
  LangString DESC_UninstallqKiisuSection ${LANG_ENGLISH} "Uninstall qKiisu"
  ;Assign language strings to install sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${StartMenuSection} $(DESC_StartMenuSection)
    !insertmacro MUI_DESCRIPTION_TEXT ${DesktopShortcutSection} $(DESC_DesktopShortcutSection)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
  ;Assign language strings to UNinstall sections
  !insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${UninstallqKiisuSection} $(DESC_UninstallqKiisuSection)
  !insertmacro MUI_UNFUNCTION_DESCRIPTION_END


;-------------------------------
; Function runs on every installer exe start

  Function .onInit

    ; Abort if not Windows 10 and newer
    ${IfNot} ${AtLeastWin10}
      MessageBox MB_OK|MB_ICONSTOP "Can not install qKiisu. Windows 10 and newer required"
      Abort
    ${EndIf}

    ${If} ${RunningX64}
      ${DisableX64FSRedirection} ; Disable using SysWOW64 for 32-bit files
      SetRegView 64 ; Use 64bit registry keys, not WOW6432Node
    ${Else}
      MessageBox MB_OK|MB_ICONSTOP "Error: Can't install qKiisu on 32-bit Windows. Use 64-bit version of Windows"
      Abort ; Exit installer if 32 bit windows
     ${EndIf}  

    ; Get install dir from Registry
    ReadRegStr $R0 HKLM "Software\${NAME}" ""
    ; Set $INSTDIR only if registry value not empty
    ${If} $R0 != ""  
      StrCpy $INSTDIR $R0
    ${EndIf}

    ; Enable install log, need NSIS special build https://nsis.sourceforge.io/Special_Builds
    ;LogSet on ;  Debug
  FunctionEnd

;-------------------------------
; Function runs on every UNinstaller exe start
Function un.onInit
    ${If} ${RunningX64}
      ${DisableX64FSRedirection} ; Disable using SysWOW64 for 32-bit files
      SetRegView 64 ; Use 64bit registry keys, not WOW6432Node
    ${EndIf}
FunctionEnd

