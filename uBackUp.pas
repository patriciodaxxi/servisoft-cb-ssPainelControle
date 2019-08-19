unit uBackUp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, iniFiles, IdCoder, 
  IdBaseComponent, IdCoder3to4, IdCoderMIME, ShellAPI, IdComponent, IdTCPConnection, IdTCPClient, IdFTP, Gauges, ToolEdit,
  Mask, ExtCtrls, ComCtrls;

type
  TfrmBackUp = class(TForm)
    Decoder64: TIdDecoderMIME;
    ftpBackUp: TIdFTP;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Gauge1: TGauge;
    lblcontador: TLabel;
    Label18: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    CheckBox1: TCheckBox;
    Edit2: TEdit;
    Edit1: TEdit;
    Edit3: TEdit;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    FilenameEdit1: TFilenameEdit;
    DirectoryEdit1: TDirectoryEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure ftpBackUpWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    vHora: TTime;
    function lerIni(Tabela, Campo: String): String;
    procedure gravarIni(Tabela, Campo, Valor: String);
    procedure executaBat(vArq: PChar);
  public
    { Public declarations }
  end;

var
  frmBackUp: TfrmBackUp;

implementation

uses DateUtils, uMenu;

{$R *.dfm}

function TfrmBackUp.lerIni(Tabela, Campo: String): String;
var
  ServerIni: TIniFile;
begin
  ServerIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  result    := ServerIni.ReadString(Tabela,Campo,'');
  ServerIni.Free;
end;

procedure TfrmBackUp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmBackUp.BitBtn1Click(Sender: TObject);
var
  vArqFdb, vArqFbk: String;
  vUser, vPass: String;
  vArqBat: String;
  f: TextFile;
begin
  vArqBat := 'Restore.bat';
  AssignFile(F,vArqBat);
  Rewrite(F);

  vArqFbk := FilenameEdit1.Text;
  vArqFdb := copy(FilenameEdit1.Text,1,Length(FilenameEdit1.Text)-4) + '.fdb';

  vUser   := lerIni('SSFacil','Username');
  vPass   := Decoder64.DecodeString(lerIni('SSFacil','password'));

//  gbak -c -V -REP -FIX_FSS_D WIN1252 -FIX_FSS_M WIN1252 -P 8192 -user SYSDBA -password masterkey SSFacil.fbk SSFacil.fdb
  WriteLn(F,Format('gbak -c -V -REP -FIX_FSS_D WIN1252 -FIX_FSS_M WIN1252 -P 8192 -user %s -password %s %s %s',[vUser,vPass,vArqFbk,vArqFdb]));

  CloseFile(F);

  executaBat('Restore.bat');
end;

procedure TfrmBackUp.BitBtn3Click(Sender: TObject);
var
  vArqFdb, vArqFbk: String;
  vUser, vPass: String;
  vArqBat: String;
  f: TextFile;
begin
  vArqBat := 'BackUp.bat';

  vArqFbk := '.\BKP\';

  if not DirectoryExists(vArqFbk) then
  begin
    ShowMessage('Pasta BKP não existe, back up não será criado!');
    Exit;
  end;

  AssignFile(F,vArqBat);
  Rewrite(F);

  vArqFdb := lerIni('SSFacil','database');
  if  trim(lerIni('BackUp','Arquivo')) = '' then
  begin
    ShowMessage('Nome do arquivo de back up não definido!');
    Exit;
  end;
  vArqFbk := vArqFbk + lerIni('BackUp','Arquivo') + '_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  vUser   := lerIni('SSFacil','Username');
  vPass   := Decoder64.DecodeString(lerIni('SSFacil','password'));
  WriteLn(F,Format('GBak -g -l -b -v %s %s -user %s -pas %s',[vArqFdb,vArqFbk,vUser,vPass]));

  CloseFile(F);

//  ShellExecute(handle,'Open',PChar('BackUp.bat'), '','',SW_ShowNormal);
  executaBat('BackUp.bat');

  tamanho_arquivo := fMenu.DSiFileSize(vArqFbk);

  if not FileExists(vArqFbk) then
  begin
    ShowMessage('Arquivo de backup do banco de dados não gerado!');
    Exit;
  end;
  if (CheckBox1.Checked) then
  begin
    Gauge1.ForeColor   := clBlue;
    ftpBackUp.Host     := lerini('BackUp','FTP');
    ftpBackUp.Username := lerini('BackUp','Username');
    ftpBackUp.Password := Decoder64.DecodeString(lerini('BackUp','Password'));
    ftpBackUp.Passive  := True;
    ftpBackUp.Connect(true);

    Delete(vArqFbk,1,6);
    ftpBackUp.Put('.\BKP\' + vArqFbk,'/backups/' + vArqFbk,False);

    ftpBackUp.Disconnect;
  end;

/////ABAIXO, BACKUP DO ARQUIVO DO BANCO DO NFECONFIG
  AssignFile(F,vArqBat);
  Rewrite(F);
  vArqFdb := lerIni('NFeConfig','database');
  vArqFbk := '.\BKP\';
  vArqFbk := vArqFbk + lerIni('BackUp','Arquivo') + '_NfeBd_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  vUser   := lerIni('NFeConfig','Username');
  vPass   := Decoder64.DecodeString(lerIni('NFeConfig','password'));
  WriteLn(F,Format('GBak -g -l -b -v %s %s -user %s -pas %s',[vArqFdb,vArqFbk,vUser,vPass]));

  CloseFile(F);
//  ShellExecute(handle,'Open',PChar('BackUp.bat'), '','',SW_ShowNormal);
  executaBat('BackUp.bat');

  tamanho_arquivo := fMenu.DSiFileSize(vArqFbk);

  if not FileExists(vArqFbk) then
  begin
    ShowMessage('Arquivo de backup do NFeConfig não gerado!');
    Exit;
  end;
  if (CheckBox1.Checked) then
  begin
    Gauge1.ForeColor   := clOlive;
    ftpBackUp.Host     := lerini('BackUp','FTP');
    ftpBackUp.Username := lerini('BackUp','Username');
    ftpBackUp.Password := Decoder64.DecodeString(lerini('BackUp','Password'));
    ftpBackUp.Passive  := True;
    ftpBackUp.Connect(true);

    Delete(vArqFbk,1,6);
    ftpBackUp.Put('.\BKP\' + vArqFbk,'/backups/'+vArqFbk,False);

    ftpBackUp.Disconnect;
  end;
  gravarIni('BackUp','UltData',FormatDateTime('DD/MM/YYYY',Date));
  gravarIni('BackUp','UltHora',FormatDateTime('HH:NN',Now));

  ShowMessage('BackUps realizados com sucesso!');
  BitBtn4.Caption := 'Fechar';
  BitBtn4.SetFocus;
end;

procedure TfrmBackUp.BitBtn4Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackUp.ftpBackUpWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
var
  contador, kbTotal, kbTransmitidos: Integer;
  Status_trans: String;
  Totaltempo: TDateTime;
  H, M, sec, MS: Word;
  DLTime, media: Double;
begin
  kbTotal    := tamanho_arquivo div 1024;
  Totaltempo := Now - STime;
  DecodeTime(Totaltempo, H, M, Sec, MS);
  Sec    := Sec + M * 60 + H * 3600;
  DLTime := Sec + MS / 1000;
  KbTransmitidos := AWorkCount div 1024;
//  kbFaltantes    := kbTotal - kbTransmitidos;
  lblcontador.Caption := 'Transferidos: '+ formatfloat('##,###,##0', kbTransmitidos ) +
                         ' Kb de ' + formatfloat('##,###,##0', kbTotal) + ' Kb';
  media := (100/tamanho_arquivo) * AWorkCount;
  if DLTime > 0 then
  begin
    tempo_medio  := (AWorkCount / 1024) / DLTime;
    Status_trans := Format('%2d:%2d:%2d', [Sec div 3600, (Sec div 60) mod 60, Sec mod 60]);
    Status_trans := 'Tempo de download ' + Status_trans;
  end;
  Status_trans := 'Taxa de Transferência: '+FormatFloat('0.00 KB/s', tempo_medio) + '; ' + Status_trans;
  Application.ProcessMessages;
  contador        := trunc(media);
  gauge1.Progress := (contador);
end;

procedure TfrmBackUp.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  Edit1.Text := lerini('SSFacil','database');
  Edit2.Text := lerIni('BackUp','Arquivo') + '_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  Edit3.Text := lerIni('BackUp','Arquivo') + '_NfeBd_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
end;

procedure TfrmBackUp.executaBat(vArq: PChar);
var
  proc_info: TProcessInformation;
  startinfo: TStartupInfo;
  ExitCode: longword;
begin
// Initialize the structures
  FillChar(proc_info, sizeof(TProcessInformation), 0);
  FillChar(startinfo, sizeof(TStartupInfo), 0);
  startinfo.cb := sizeof(TStartupInfo);

// Attempts to create the process
  if CreateProcess(vArq, nil, nil,nil, false, NORMAL_PRIORITY_CLASS, nil, nil, startinfo, proc_info) <> false then
  begin
// The process has been successfully created
// No let´s wait till it ends...
    WaitForSingleObject(proc_info.hProcess, INFINITE);
// Process has finished. Now we should close it.
    GetExitCodeProcess(proc_info.hProcess, ExitCode); // Optional
    CloseHandle(proc_info.hThread);
    CloseHandle(proc_info.hProcess);
//    Application.MessageBox(PChar(Format('Notepad finished!', [ExitCode])),'Info', MB_ICONINFORMATION);
  end
  else
  begin
// Failure creating the process
    Application.MessageBox('Não pôde executar '+ 'Application', 'Error', MB_ICONEXCLAMATION);
  end;
end;

procedure TfrmBackUp.Timer1Timer(Sender: TObject);
begin
//  sdsAvisoEscala.ParamByName('H1').AsTime := IncMinute(Frac(Now),5);
//  sdsAvisoEscala.ParamByName('H2').AsTime := IncMinute(Frac(Now),6);
//  testar se hora do timer = hora do backup
  ShowMessage(FormatDateTime('hh:nn',Now) + #13 +
              FormatDateTime('hh:nn',vHora));

  if FormatDateTime('hh:nn',Now) = FormatDateTime('hh:nn',vHora) then
    BitBtn3Click(Sender);
end;

procedure TfrmBackUp.gravarIni(Tabela, Campo, Valor: String);
var
  ServerIni: TIniFile;
begin
  ServerIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  ServerIni.WriteString(Tabela,Campo,Valor);
  ServerIni.UpdateFile;
  ServerIni.Free;
end;

end.
