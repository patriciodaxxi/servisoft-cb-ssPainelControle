program BackUp_Solo;

uses
  Forms, Windows,
  uBackUp_Solo in 'uBackUp_Solo.pas' {frmBackUp};

{$R *.res}
var
  ExtendedStyle: Integer;
  hWnd: THandle;
begin
  hWnd := FindWindow('TfrmBackUp','BackUp Solo');
  if hWnd = 0 then
  begin
    Application.Initialize;

    ExtendedStyle := GetWindowLong(Application.Handle, gwl_ExStyle);
    SetWindowLong(Application.Handle, gwl_ExStyle, ExtendedStyle or
    ws_Ex_ToolWindow and not ws_Ex_AppWindow);

    Application.CreateForm(TfrmBackUp, frmBackUp);
    Application.Run;
  end
  else
    SetForegroundWindow(hWnd);
end.
