program ZuneKeys;

{$R 'ZuneKeys.res' 'ZuneKeys.rc'}

uses
  Messages,
  Windows,
  ShellAPI,
  uAppCommands in 'uAppCommands.pas';

const
  // application name
  APPNAME = 'ZuneKeys';

  // tray related
  TRAY_NOTIFYICON = WM_USER + 2001;
  ID_TRAY	= 5000;

  // right-click menu commands
  SWM_SHOW  = WM_APP + 1; //	show the window
  SWM_HIDE  = WM_APP + 2; //	hide the window
  SWM_ABOUT = WM_APP + 3; //  show about message
  SWM_EXIT  = WM_APP + 4; //	close the window

  // hotkeys
  HK_PLAY        = $0000;
  HK_PAUSE       = $0001;
  HK_STOP        = $0002;
  HK_PREVIOUS    = $0003;
  HK_NEXT        = $0004;
  HK_VOLUME_UP   = $0005;
  HK_VOLUME_DOWN = $0006;
  HK_FORWARD     = $0007;
  HK_REWIND      = $0008;

  // help
  HOTKEY_HELP =
    'Play'#13#10 +
    'Pause'#13#10 +
    'Stop'#13#10 +
    'Previous Track'#13#10 +
    'Next Track'#13#10 +
    'Volume Up'#13#10 +
    'Volume Down'#13#10 +
    'Fast Forward'#13#10 +
    'Rewind';

  HOTKEY_HELP_KEYS =
    'Ctrl + Alt + Insert'#13#10 +
    'Ctrl + Alt + Home'#13#10 +
    'Ctrl + Alt + End'#13#10 +
    'Ctrl + Alt + Page Up'#13#10 +
    'Ctrl + Alt + Page Down'#13#10 +
    'Ctrl + Alt + Up'#13#10 +
    'Ctrl + Alt + Down'#13#10 +
    'Ctrl + Alt + Right'#13#10 +
    'Ctrl + Alt + Left';

  HELP_ABOUT =
    'ZuneKey by Shawn Oster'#13#10#13#10 +
    'E-Mail: shawn.oster@gmail.com'#13#10 +
    'Blog: a-simian-mind.blogspot.com'#13#10 +
    'Icon: www.iconbuffet.com';

var
  wClass: TWndClassEx;
  hAppHandle: HWND;
  Msg: TMsg;  

{$I ZuneKeys.inc} {Resource constants}

procedure ShowContextMenu(Wnd: HWND);
var
  pt: TPoint;
  Menu: HMENU;
begin
	GetCursorPos(pt);
	Menu := CreatePopupMenu();
	if(Menu <> 0) then
	begin
		if( IsWindowVisible(Wnd) ) then
			InsertMenu(Menu, 0, MF_BYPOSITION, SWM_HIDE, 'Hide')
		else
			InsertMenu(Menu, 0, MF_BYPOSITION, SWM_SHOW, 'Show');

    InsertMenu(Menu, 1, MF_BYPOSITION, SWM_ABOUT, 'About...');
    InsertMenu(Menu, 2, MF_BYPOSITION, SWM_EXIT, 'Exit');

    // note:	must set window to the foreground or the menu won't disappear when it should
    SetForegroundWindow(Wnd);
    TrackPopupMenu(Menu, TPM_BOTTOMALIGN, pt.x, pt.y, 0, Wnd, nil );
    DestroyMenu(Menu);
  end;
end;

// Tray Icons and Notification -------------------------------------------------

{$REGION 'Tray Icon Methods'}
  function TrayMessage(Wnd: HWND; dwMessage: DWORD; uID: UINT; hIcon: HICON; pszTip: string): Boolean;
  var
    IconData: TNotifyIconData;
  begin
  	IconData.cbSize := sizeof(NOTIFYICONDATA);
  	IconData.Wnd := Wnd;
  	IconData.uID := uID;
  	IconData.uFlags := NIF_MESSAGE or NIF_ICON;
  	IconData.uCallbackMessage := TRAY_NOTIFYICON;
  	IconData.hIcon := hIcon;
  	IconData.szTip := '';
  
  	Result := Shell_NotifyIcon(dwMessage, @IconData);
  end;
  
  procedure TrayIconDelete(Wnd: HWND; Id: UINT);
  begin
  	TrayMessage(Wnd, NIM_DELETE, ID, 0, '');
  end;
  
  procedure TrayIconModify(Wnd: HWND; Id: UINT; Icon: HICON; Tip: string);
  begin
  	TrayMessage(Wnd, NIM_MODIFY, ID, Icon, '');
  end;
  
  procedure TrayIconAdd(Wnd: HWND; Id: UINT; Icon: HICON; Tip: string);
  begin
    TrayMessage(Wnd, NIM_ADD, Id, Icon, '');
  end;
{$ENDREGION}

// Hotkey Support

{$REGION 'Hotkey Methods'}
  procedure RegisterHotkeys(Wnd: HWND);
  begin
    RegisterHotKey(Wnd, HK_PLAY, MOD_CONTROL or MOD_ALT, VK_INSERT);
    RegisterHotKey(Wnd, HK_PAUSE, MOD_CONTROL or MOD_ALT, VK_HOME);
    RegisterHotKey(Wnd, HK_STOP, MOD_CONTROL or MOD_ALT, VK_END);
    RegisterHotKey(Wnd, HK_PREVIOUS, MOD_CONTROL or MOD_ALT, VK_PRIOR);
    RegisterHotKey(Wnd, HK_NEXT, MOD_CONTROL or MOD_ALT, VK_NEXT);
    RegisterHotKey(Wnd, HK_VOLUME_UP, MOD_CONTROL or MOD_ALT, VK_UP);
    RegisterHotKey(Wnd, HK_VOLUME_DOWN, MOD_CONTROL or MOD_ALT, VK_DOWN);
    RegisterHotKey(Wnd, HK_FORWARD, MOD_CONTROL or MOD_ALT, VK_RIGHT);
    RegisterHotKey(Wnd, HK_REWIND, MOD_CONTROL or MOD_ALT, VK_LEFT);
  end;
  
  procedure UnregisterHotkeys(Wnd: HWND);
  begin
    UnregisterHotkey(Wnd, HK_PLAY);
    UnregisterHotkey(Wnd, HK_PAUSE);
    UnregisterHotkey(Wnd, HK_STOP);
    UnregisterHotkey(Wnd, HK_PREVIOUS);
    UnregisterHotkey(Wnd, HK_NEXT);
    UnregisterHotKey(Wnd, HK_VOLUME_UP);
    UnregisterHotKey(Wnd, HK_VOLUME_DOWN);
    UnregisterHotKey(Wnd, HK_FORWARD);
    UnregisterHotKey(Wnd, HK_REWIND);
  end;

  procedure SendAppCommand(Cmd: Integer);
  var
    PlayerHandle: Cardinal;
  begin
    PlayerHandle := FindWindow('WMPlayerAppZune', 'Zune');
    if (PlayerHandle <> 0) then
    begin
      SendMessage(PlayerHandle, WM_APPCOMMAND, 0, Cmd Shl 16);
    end;
  end;
{$ENDREGION}

// Main Window Handler ---------------------------------------------------------

function WindowProc(Wnd: HWND; iMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result:= 0;

  case iMsg of
    WM_CREATE:
      begin
        RegisterHotkeys(Wnd);
        TrayIconAdd(Wnd, ID_TRAY, LoadIcon(HInstance, MAKEINTRESOURCE(IDI_TRAY)), '');
      end;

    WM_SYSCOMMAND:
      begin
        if ((wParam and $FFF0) = SC_MINIMIZE) then
          ShowWindow(Wnd, SW_HIDE)
        else
          Result := DefWindowProc(Wnd, iMsg, wParam, lParam);
      end;

    WM_COMMAND:
      case LOWORD(wParam) of
        SWM_SHOW:
          ShowWindow(Wnd, SW_RESTORE);
        SWM_HIDE:
          ShowWindow(Wnd, SW_HIDE);
        SWM_ABOUT:
          MessageBox(hAppHandle, HELP_ABOUT, 'About', MB_OK or MB_ICONINFORMATION);
        SWM_EXIT:
          DestroyWindow(Wnd);
      end;

    TRAY_NOTIFYICON:
      case lParam of
        WM_LBUTTONDBLCLK:
            ShowWindow(Wnd, SW_RESTORE);

          WM_RBUTTONDOWN,
          WM_CONTEXTMENU:
            ShowContextMenu(Wnd);
      end;

    WM_HOTKEY:
      case wParam of
        HK_PLAY        : SendAppCommand(APPCOMMAND_MEDIA_PLAY);
        HK_PAUSE       : SendAppCommand(APPCOMMAND_MEDIA_PLAY_PAUSE);
        HK_STOP        : SendAppCommand(APPCOMMAND_MEDIA_STOP);
        HK_PREVIOUS    : SendAppCommand(APPCOMMAND_MEDIA_PREVIOUSTRACK);
        HK_NEXT        : SendAppCommand(APPCOMMAND_MEDIA_NEXTTRACK);
        HK_VOLUME_UP   : SendAppCommand(APPCOMMAND_VOLUME_UP);
        HK_VOLUME_DOWN : SendAppCommand(APPCOMMAND_VOLUME_DOWN);
        HK_FORWARD     : SendAppCommand(APPCOMMAND_MEDIA_FAST_FORWARD);
        HK_REWIND      : SendAppCommand(APPCOMMAND_MEDIA_REWIND);
      end;

    WM_DESTROY:
      begin
        TrayIconDelete(Wnd, ID_TRAY);
        UnregisterHotkeys(Wnd);
        PostQuitMessage(0);
      end;
  else
    Result := DefWindowProc(Wnd, iMsg, wParam, lParam);
  end;
end;

procedure WinMain;
var
  hFontDlg: HFONT;
  hTitle: HWND;
  hHotkeyHelp: HWND;
  hFontHotkey: HFONT;
  hHotkeyHelpKeys: HWND;
begin
  wClass.cbSize := SizeOf(wClass);
  wClass.lpszClassName := APPNAME;
  wClass.lpfnWndProc := @WindowProc;
  wClass.hInstance := HInstance;
  wClass.hIcon := LoadIcon(HInstance, MAKEINTRESOURCE(IDI_MAIN));
  wClass.hCursor := LoadCursor(0, IDC_ARROW);
  wClass.hbrBackground := COLOR_BTNFACE + 1;
  wClass.style := CS_HREDRAW or CS_VREDRAW;
  RegisterClassEx(wClass);

  hAppHandle := CreateWindow(wClass.lpszClassName, 'ZuneKeys', WS_OVERLAPPEDWINDOW, Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT), 340, 220, 0, 0, HInstance, nil);
  hTitle := CreateWindow('Static', 'Zune Global Hotkeys', WS_VISIBLE or WS_CHILD, 16, 16, 300, 32, hAppHandle, 0, HInstance, nil);
  hHotkeyHelp := CreateWindow('Static', HOTKEY_HELP, WS_VISIBLE or WS_CHILD, 16, 48, 80, 120, hAppHandle, 0, HInstance, nil);
  hHotkeyHelpKeys := CreateWindow('Static', HOTKEY_HELP_KEYS, WS_VISIBLE or WS_CHILD, 96, 48, 120, 120, hAppHandle, 0, HInstance, nil);

  hFontDlg := CreateFont(-12, 0, 0, 0, FW_BOLD, 0, 0, 0, 0, 0, 0, 0, VARIABLE_PITCH or FF_SWISS, 'Tahoma');
  hFontHotkey := CreateFont(-10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, VARIABLE_PITCH or FF_SWISS, 'Tahoma');

  SendMessage(hTitle, WM_SETFONT, hFontDlg, 1);
  SendMessage(hHotkeyHelp, WM_SETFONT, hFontHotkey, 1);
  SendMessage(hHotkeyHelpKeys, WM_SETFONT, hFontHotkey, 1);

  while GetMessage(Msg, 0, 0, 0) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  DeleteObject(hFontDlg);
  DeleteObject(hFontHotkey);
end;

begin
  WinMain
end.