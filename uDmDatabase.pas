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
begin
   // verifica se alguém está atualizando
  {sds := TSQLDataSet.Create(nil);
  sds.SQLConnection := dmDatabase.scoDados;
  sds.NoMetadata    := True;
  sds.GetMetadata   := False;
  vFlag2 := 1;
  while vFlag2 = 1 do
  begin
  	sds.Close;
  	sds.CommandText   := 'SELECT FLAG  FROM TABELALOC WHERE TABELA = ' + QuotedStr('INICIO');
  	sds.Open;
  	vFlag2 := sds.FieldByName('FLAG').AsInteger;
  end;}
  //

  sqVersaoAtual.Open;
  sdsVersao.CommandText := sdsVersao.CommandText + ' AND ID > ' + sqVersaoAtualVERSAO_BANCO.AsString + ' AND PROGRAMA_ID = 1 ';
  cdsVersao.Open;
  if not cdsVersao.IsEmpty then
  begin
    try
      arqLog := '';
      sds := TSQLDataSet.Create(nil);
      sds.SQLConnection := dmDatabase.scoDados;
      sds.NoMetadata    := True;
      sds.GetMetadata   := False;
      vFlag2 := 1;
      //19/08/2019   Tirado o Flag Inicio, pois aqui no painel não vai ter vários usuários entrando ao mesmo tempo nele.
      {while vFlag2 = 1 do
      begin
        sds.Close;
        sds.CommandText   := 'SELECT FLAG  FROM TABELALOC WHERE TABELA = ' + QuotedStr('INICIO');
        sds.Open;
        vFlag2 := sds.FieldByName('FLAG').AsInteger;
      end;}
      sqVersaoAtual.Close;
      sqVersaoAtual.Open;
      cdsVersao.Close;
      sdsVersao.CommandText := sdsVersao.CommandText + ' AND ID > ' + sqVersaoAtualVERSAO_BANCO.AsString + ' AND PROGRAMA_ID = 1 ';
      cdsVersao.Open;
      if cdsVersao.IsEmpty then
        exit;

      //19/08/2019   Tirado o Flag Inicio, pois aqui no painel não vai ter vários usuários entrando ao mesmo tempo nele.
      {sds.Close;
      sds.NoMetadata    := True;
      sds.GetMetadata   := False;
      sds.CommandText   := ' UPDATE TABELALOC SET FLAG = 1 WHERE TABELA = ' + QuotedStr('INICIO');
      sds.ExecSQL();}

      vErro  := False;
      arqLog := 'FDBUpdate_' + FormatDateTime('YYYYMMDD',Date) +  '_' + FormatDateTime('HHMMSS',Time) +  '.log';
      AssignFile(F,arqLog);
      ReWrite(F);

      while not cdsVersao.Eof do
      begin
        S := cdsVersaoSCRIPT.AsString; // ScriptFile: String - your whole script
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
          //SQLQuery1.ParamCheck := False;
          //SQLQuery1.SQL.Text := command;
          //SQLQuery1.SQL.SaveToFile('C:\a\testeedson.txt');
          if trim(sdsExec.CommandText) <> '' then
          begin
            ID.TransactionID  := 99;
            ID.IsolationLevel := xilREADCOMMITTED;
            dmDatabase.scoDados.StartTransaction(ID);
            try
              sdsExec.ExecSQL(True);
              //SQLQuery1.ExecSQL(True);
              dmDatabase.scoDados.Commit(ID);
            except
              WriteLn(F,'----------------------------');
              WriteLn(F,'Versão: ' + cdsVersaoID.AsString + ' = ' + vSQL_Ant);
              vErro := True;
              dmDatabase.scoDados.Rollback(ID);
            end;
          end;
          //sdsExec.CommandText := ('UPDATE PARAMETROS SET VERSAO_BANCO = ' + cdsVersaoID.AsString);
          //sdsExec.ExecSQL(True);
          Delete(S, 1, DelimiterPos);
          if Length(S) = 0 then
            vFlag := False;
        end;
        sdsExec.CommandText := ('UPDATE PARAMETROS SET VERSAO_BANCO = ' + cdsVersaoID.AsString);
        sdsExec.ExecSQL(True);

        cdsVersao.Next;
      end;
    finally
      if trim(arqLog) <> '' then
        CloseFile(F);
      if not(vErro) then
        DeleteFile(arqLog);
      sds.Close;
      sds.NoMetadata    := True;
      sds.GetMetadata   := False;
      sds.CommandText   := ' UPDATE TABELALOC SET FLAG = 0 WHERE TABELA = ' + QuotedStr('INICIO');
      sds.ExecSQL();

      FreeAndNil(sds);
    end;
  end;
  cdsVersao.Close;
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
