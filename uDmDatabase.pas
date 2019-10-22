unit uDmDatabase;

interface

uses
  SysUtils, Classes, DBXpress, FMTBcd, DB, SqlExpr, IdCoder, IdCoder3to4, IdCoderMIME, IdBaseComponent, iniFiles, Dialogs, Forms,
  DBClient, Provider, MidasLib;

type
  TdmDatabase = class(TDataModule)
    scoDados: TSQLConnection;
    Decoder64: TIdDecoderMIME;
    Encoder64: TIdEncoderMIME;
    sdsExec: TSQLDataSet;
    scoAtualiza: TSQLConnection;
    sqVersaoAtual: TSQLQuery;
    sqVersaoAtualVERSAO_BANCO: TIntegerField;
    sdsVersao: TSQLDataSet;
    sdsVersaoID: TIntegerField;
    sdsVersaoSCRIPT: TBlobField;
    dspVersao: TDataSetProvider;
    cdsVersao: TClientDataSet;
    cdsVersaoID: TIntegerField;
    cdsVersaoSCRIPT: TBlobField;
    qMax: TSQLQuery;
    qMaxID: TIntegerField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function Fnc_ArquivoConfiguracao: string;
  public
    { Public declarations }
    function fncVersoDoAtualiza: Integer;
    procedure prcAtualizaBanco;
  end;

var
  dmDatabase: TdmDatabase;

const
  cArquivoConfiguracao = 'Config.ini';

implementation

{$R *.dfm}

procedure TdmDatabase.prcAtualizaBanco;
var
  DelimiterPos: Integer;
  S: WideString;
  Command: WideString;
  vFlag, vErro: Boolean;
  F: TextFile;
  arqLog: String;
  vID_Versao: Integer;
  vSQL_Ant: WideString;
  ID, ID2: TTransactionDesc;
  sds: TSQLDataSet;
  vFlag2: Integer;
  vMicroAtual: Boolean;
  i : Integer;
  i2 : Integer;
  ctVersao : String;
begin
  arqLog := '';
  vErro  := False;
  arqLog := 'FDBUpdate_' + FormatDateTime('YYYYMMDD',Date) +  '_' + FormatDateTime('HHMMSS',Time) +  '.log';
  AssignFile(F,arqLog);
  ReWrite(F);

  ctVersao := sdsVersao.CommandText;
  sqVersaoAtual.Close;
  sqVersaoAtual.Open;
  i := sqVersaoAtualVERSAO_BANCO.AsInteger;
  qMax.Close;
  qMax.Open;
  i2 := qMaxID.AsInteger;
  i  := i + 1;
  while i <= i2 do
  begin
    cdsVersao.close;
    sdsVersao.CommandText := ctVersao + ' AND ID = ' + IntToStr(i) + ' AND PROGRAMA_ID = 1 ';
    cdsVersao.Open;
    if not cdsVersao.IsEmpty then
    begin
      try
        sds := TSQLDataSet.Create(nil);
        sds.SQLConnection := dmDatabase.scoDados;
        sds.NoMetadata    := True;
        sds.GetMetadata   := False;
        vFlag2 := 1;

        S := cdsVersaoSCRIPT.AsString;
        vFlag := True;
        while vFlag do
        begin
          DelimiterPos := Pos('}', S);
          if DelimiterPos = 0 then
            DelimiterPos := Length(S);
          Command:= Copy(S, 1, DelimiterPos - 1);
          if pos('COMMIT',UpperCase(Command)) <= 0 then
            vSQL_Ant := Command;

          sdsExec.CommandText := (Command);
          if trim(sdsExec.CommandText) <> '' then
          begin
            ID.TransactionID  := 99;
            ID.IsolationLevel := xilREADCOMMITTED;
            dmDatabase.scoDados.StartTransaction(ID);
            try
              sdsExec.ExecSQL(True);
              dmDatabase.scoDados.Commit(ID);
            except
              WriteLn(F,'----------------------------');
              WriteLn(F,'Versão: ' + cdsVersaoID.AsString + ' = ' + vSQL_Ant);
              vErro := True;
              dmDatabase.scoDados.Rollback(ID);
            end;
          end;
          Delete(S, 1, DelimiterPos);
          if Length(S) = 0 then
            vFlag := False;
        end;
        sdsExec.CommandText := ('UPDATE PARAMETROS SET VERSAO_BANCO = ' + cdsVersaoID.AsString);
        sdsExec.ExecSQL(True);

      finally
        //if trim(arqLog) <> '' then
        //  CloseFile(F);
        //if not(vErro) then
        //  DeleteFile(arqLog);
        sds.Close;
        sds.NoMetadata    := True;
        sds.GetMetadata   := False;
        sds.CommandText   := ' UPDATE TABELALOC SET FLAG = 0 WHERE TABELA = ' + QuotedStr('INICIO');
        sds.ExecSQL();

        FreeAndNil(sds);
      end;
    end;

    i := i + 1;
    if i <= i2 then
    begin
      scoDados.Connected := False;
      scoDados.Connected := True;
    end;
  end;

  if trim(arqLog) <> '' then
    CloseFile(F);
  if not(vErro) then
    DeleteFile(arqLog);

  cdsVersao.Close;
  scoDados.Connected := False;
  sqVersaoAtual.Close;
  scoAtualiza.Connected := False;
end;

procedure TdmDatabase.DataModuleCreate(Sender: TObject);
var
  Config: TIniFile;
  vTexto: String;
begin
  scoDados.Connected := False;

  vTexto := Fnc_ArquivoConfiguracao;
  if not FileExists(Fnc_ArquivoConfiguracao) then
  begin
    MessageDlg(' Arquivo Config.ini não encontrado!',mtInformation,[mbOk],0);
    Exit;
  end;

  Config := TIniFile.Create(Fnc_ArquivoConfiguracao);
  scoDados.LoadParamsFromIniFile(Fnc_ArquivoConfiguracao);


  try
//////////////////CONECTA AO BANCO DE DADOS DA APLICAÇÃO
    try
      scoDados.Params.Values['DRIVERNAME'] := 'INTERBASE';
      scoDados.Params.Values['SQLDIALECT'] := '3';
      scoDados.Params.Values['DATABASE']   := Config.ReadString('SSFacil', 'DATABASE', '');
      scoDados.Params.Values['USER_NAME']  := Config.ReadString('SSFacil', 'USERNAME', '');
      scoDados.Params.Values['PASSWORD']   := Decoder64.DecodeString(Config.ReadString('SSFacil', 'PASSWORD', ''));
      scoDados.Connected := True;
    except
      on E: exception do
      begin
        raise Exception.Create('Erro ao conectar ao banco de dados:' + #13 +
                               'Mensagem: ' + E.Message + #13 +
                               'Classe: ' + E.ClassName + #13 + #13 +
                               'Dados da Conexao SSFacil' + #13 +
                               'Banco de Dados: '  + scoDados.Params.Values['Database'] + #13 +
                               'Usuário: '         + scoDados.Params.Values['User_Name']);
      end;
    end;
  finally
    FreeAndNil(Config);
  end;

  scoAtualiza.Connected := False;

  if not FileExists(Fnc_ArquivoConfiguracao) then
  begin
    MessageDlg(' Arquivo Config.ini não encontrado!',mtInformation,[mbOk],0);
    Exit;
  end;
end;

function TdmDatabase.Fnc_ArquivoConfiguracao: string;
begin
  Result := ExtractFilePath(Application.ExeName) + cArquivoConfiguracao;
end;

function TdmDatabase.fncVersoDoAtualiza: Integer;
var
  sds: TSQLDataSet;
begin
  try
    scoAtualiza.Connected := True;

    sds := TSQLDataSet.Create(nil);
    sds.SQLConnection := scoAtualiza;
    sds.NoMetadata  := True;
    sds.GetMetadata := False;
    sds.CommandText := 'SELECT MAX(ID) ULTVERSAO FROM VERSAO WHERE PROGRAMA_ID = 1 AND IMPLANTADA = ''S''';
    sds.Open;
    Result := sds.FieldByName('ULTVERSAO').AsInteger;
  finally
    FreeAndNil(sds);
  end;
end;

end.
