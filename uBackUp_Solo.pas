unit uBackUp_Solo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, iniFiles, ToolEdit,
  IdBaseComponent, IdCoder, IdCoder3to4, IdCoderMIME, ShellAPI, IdComponent, IdTCPConnection, IdTCPClient, IdFTP, Gauges, Mask,
  ExtCtrls, ComCtrls, jpeg, JvComponent, JvTrayIcon, ZipMstr;

type
  TfrmBackUp = class(TForm)
    ftpBackUp: TIdFTP;
    Timer1: TTimer;
    Decoder64: TIdDecoderMIME;
    Gauge1: TGauge;
    lblcontador: TLabel;
    Label18: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    BitBtn3: TBitBtn;
    CheckBox1: TCheckBox;
    Edit2: TEdit;
    Edit1: TEdit;
    Edit3: TEdit;
    Label2: TLabel;
    Edit4: TEdit;
    JvTrayIcon1: TJvTrayIcon;
    Panel1: TPanel;
    Image2: TImage;
    Label3: TLabel;
    ZipMaster1: TZipMaster;
    CheckBox2: TCheckBox;
    Label5: TLabel;
    Edit5: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn3Click(Sender: TObject);
    procedure ftpBackUpWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    vHora: TTime;
    STime: TDateTime;
    tamanho_arquivo: LongWord;
    tempo_medio: Double;
    function lerIni(Tabela, Campo: String): String;
    procedure gravarIni(Tabela, Campo, Valor: String);
    procedure executaBat(vArq: PChar);
    function DSiFileSize(const fileName: string): int64;
    procedure prcEnviaFtp(vArqFbk: String; vCor: Byte);
    function fncCompacta(vArqFbk: String): String;
    procedure prcCriaBat(vArqFdb, vArqFbk: String);
  public
    { Public declarations }
  end;

var
  frmBackUp: TfrmBackUp;

const
  vArqBat = 'BackUp.bat';

implementation

uses DateUtils;

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

procedure TfrmBackUp.BitBtn3Click(Sender: TObject);
var
  vArqFdb, vArqFbk, vArqZip: String;
begin
  if Tag = 1 then
  begin
    Close;
    Exit;
  end;

  vArqFbk := '.\BKP\';

  if not DirectoryExists(vArqFbk) then
  begin
    ShowMessage('Pasta ' + vArqFbk + ' não existe, back up não será criado!');
    Exit;
  end;

  vArqFdb := lerIni('SSFacil','database');
  if  trim(lerIni('BackUp','Arquivo')) = '' then
  begin
    ShowMessage('Nome do arquivo de backup não definido!');
    Exit;
  end;
  vArqFbk := vArqFbk + lerIni('BackUp','Arquivo') + '_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  prcCriaBat(vArqFdb, vArqFbk);

  executaBat('BackUp.bat');

  if not FileExists(vArqFbk) then
  begin
    ShowMessage('Arquivo de backup do banco de dados não gerado!');
    Exit;
  end;

  vArqZip := fncCompacta(vArqFbk);
  DeleteFile(vArqFbk);

  if (CheckBox1.Checked) then
  begin
    prcEnviaFtp(vArqZip,0);

    if Edit5.Text <> '' then
    begin
      if Copy(Edit5.Text,Length(Edit5.Text),1) <> '\' then
        Edit5.Text := Edit5.Text + '\';
      MoveFile(PAnsiChar(vArqZip),PAnsiChar(Edit5.Text + Copy(vArqZip,7,Length(vArqZip)-6)));
    end;

    gravarIni('BackUp','UltData',FormatDateTime('DD/MM/YYYY',Date));
    gravarIni('BackUp','UltHora',FormatDateTime('HH:NN',Now));
    gravarIni('BackUp','PastaLocal',Edit5.Text);
    case CheckBox2.Checked of
      True: gravarIni('BackUp','NFeConfig','S');
      False: gravarIni('BackUp','NFeConfig','N');
    end;
  end;

/////ABAIXO, BACKUP DO ARQUIVO DO BANCO DO NFECONFIG
  if not CheckBox2.Checked then
  begin
    ShowMessage('BackUp realizado com sucesso!');
    BitBtn3.Caption := 'Fechar';
    Tag := 1;
    Exit;
  end;

  vArqFdb := lerIni('NFeConfig','database');
  vArqFbk := '.\BKP\';
  vArqFbk := vArqFbk + lerIni('BackUp','Arquivo') + '_NfeBd_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  prcCriaBat(vArqFdb, vArqFbk);

  executaBat('BackUp.bat');

  if not FileExists(vArqFbk) then
  begin
    ShowMessage('Arquivo de backup do NFeConfig não gerado!');
    Exit;
  end;

  vArqZip := fncCompacta(vArqFbk);
  DeleteFile(vArqFbk);

  if (CheckBox1.Checked) then
  begin
    prcEnviaFtp(vArqZip,1);

    if Edit5.Text <> '' then
      MoveFile(PAnsiChar(vArqZip),PAnsiChar(Edit5.Text + Copy(vArqZip,7,Length(vArqZip)-6)));
  end;

  ShowMessage('BackUps realizados com sucesso!');
  BitBtn3.Caption := 'Fechar';
  Tag := 1;
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
  Edit1.Text := lerini('SSFacil','database');
  Edit2.Text := lerIni('BackUp','Arquivo') + '_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  Edit3.Text := lerIni('BackUp','Arquivo') + '_NfeBd_' + FormatDateTime('YYYY_MM_DD',Date) + '.fbk';
  if lerIni('BackUp','Hora') <> '' then
  begin
    vHora := StrToTime(lerIni('BackUp','Hora'));
    Edit4.Text := lerIni('BackUp','Hora');
  end
  else
  begin
    ShowMessage('Hora do back up não definida!');
    Application.Terminate;
  end;
  Edit5.Text := LerIni('BackUp','PastaLocal');
  if LerIni('BackUp','NFeConfig') = 'S' then
    CheckBox2.Checked := True
  else
    CheckBox2.Checked := False;

  if (lerIni('BackUp','UltData') <> '') and (lerIni('BackUp','UltHora') <> '') then
  begin
    //
  end
  else
  begin
    //informação de backup não disponível
  end;
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
//  testar se hora do timer = hora do backup
  if FormatDateTime('hh:nn',Now) = FormatDateTime('hh:nn',vHora) then
    BitBtn3Click(Sender);
end;

function TfrmBackUp.DSiFileSize(const fileName: string): int64;
var
  fHandle: DWORD;
begin
  fHandle := CreateFile(PChar(fileName), 0, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if fHandle = INVALID_HANDLE_VALUE then
    Result := -1
  else try
    Int64Rec(Result).Lo := GetFileSize(fHandle, @Int64Rec(Result).Hi);

  finally CloseHandle(fHandle);
  end;
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

procedure TfrmBackUp.FormCreate(Sender: TObject);
begin
//  JvTrayIcon1.Visibility := [tvVisibleTaskBar, tvVisibleTaskList, tvAutoHide, tvRestoreDbClick];
  JvTrayIcon1.Visibility := [tvVisibleTaskBar,tvVisibleTaskList,tvRestoreClick,tvRestoreDbClick];
  jvTrayIcon1.Active     := True;
  Tag := 0;
//  jvTrayIcon1.HideApplication;
end;

procedure TfrmBackUp.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
{  if MessageDlg('É recomendado não fechar este programa!' + #13 +
                'Selecione Não para minimizar e esconder!' + #13 +
                'Clique Sim para fechar!',mtConfirmation,[mbYes,mbNo],0) = mrNo then
  begin
    CanClose := False;
    frmBackUp.WindowState := wsMinimized;
  end
  else
    CanClose := True;
}
end;

procedure TfrmBackUp.prcEnviaFtp(vArqFbk: String; vCor: Byte);
begin
  case vCor of
    0: Gauge1.ForeColor   := clBlue;
    1: Gauge1.ForeColor   := clOlive;
  end;
  ftpBackUp.Host     := lerini('BackUp','FTP');
  ftpBackUp.Username := lerini('BackUp','Username');
  ftpBackUp.Password := Decoder64.DecodeString(lerini('BackUp','Password'));
  ftpBackUp.Passive  := True;
  ftpBackUp.Connect(true);

  vArqFbk := ZipMaster1.ZipFileName;
  tamanho_arquivo := DSiFileSize(vArqFbk);
  Delete(vArqFbk,1,6);
  ftpBackUp.Put('.\BKP\' + vArqFbk,'/backups/' + vArqFbk, False);
  ftpBackUp.Disconnect;
end;

function TfrmBackUp.fncCompacta(vArqFbk: String): String;
begin
  ZipMaster1.ZipFileName := Copy(vArqFbk,1,Length(vArqFbk)-4) + '.zip';
  ZipMaster1.FSpecArgs.Add(vArqFbk);
  ZipMaster1.Add();
  Result := ZipMaster1.ZipFileName;
end;

procedure TfrmBackUp.prcCriaBat(vArqFdb, vArqFbk: String);
var
  F: TextFile;
  vUser, vPass: String;
begin
  AssignFile(F,vArqBat);
  Rewrite(F);

  if  trim(lerIni('BackUp','Arquivo')) = '' then
  begin
    ShowMessage('Nome do arquivo de backup não definido!');
    Exit;
  end;
  vUser   := lerIni('SSFacil','Username');
  vPass   := Decoder64.DecodeString(lerIni('SSFacil','password'));

  WriteLn(F,Format('GBak -g -l -b -v %s %s -user %s -pas %s',[vArqFdb,vArqFbk,vUser,vPass]));
  CloseFile(F);
end;

end.
