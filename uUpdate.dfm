object frmUpdate: TfrmUpdate
  Left = 333
  Top = 161
  Width = 511
  Height = 428
  Caption = 'frmUpdate'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 503
    Height = 62
    Align = alTop
    Color = clWhite
    TabOrder = 1
    object Label2: TLabel
      Left = 63
      Top = 20
      Width = 363
      Height = 40
      Alignment = taCenter
      Caption = 
        'O programa ir'#225' atualizar os softwares selecionados abaixo. '#13#10'A v' +
        'ers'#227'o anterior ser'#225' salva com a extens'#227'o DataDoDia.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 501
      Height = 13
      Align = alTop
      Alignment = taRightJustify
      Caption = 'Vers'#227'o 07/11/2019'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 344
    Width = 503
    Height = 53
    Align = alBottom
    TabOrder = 0
    object StatusBar1: TStatusBar
      Left = 1
      Top = 33
      Width = 501
      Height = 19
      Panels = <
        item
          Width = 100
        end
        item
          Width = 175
        end
        item
          Width = 50
        end>
    end
    object btnAtualizar: TBitBtn
      Left = 89
      Top = 3
      Width = 100
      Height = 27
      Caption = '&Atualizar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnAtualizarClick
    end
    object BitBtn2: TBitBtn
      Left = 189
      Top = 4
      Width = 109
      Height = 27
      Caption = 'Ca&ncelar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = BitBtn2Click
    end
    object BitBtn1: TBitBtn
      Left = 299
      Top = 4
      Width = 100
      Height = 27
      Caption = 'Banco'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = BitBtn1Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 62
    Width = 503
    Height = 150
    Align = alClient
    TabOrder = 2
    object CheckListBox1: TCheckListBox
      Left = 8
      Top = 16
      Width = 465
      Height = 125
      Columns = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ItemHeight = 20
      Items.Strings = (
        'SSF'#225'cil'
        'SSPar'#226'metros'
        'SSCupomFiscal'
        'SSF'#225'cil_OS'
        'SSF'#225'cil_Prod'
        'SSF'#225'cil_MDFE'
        'SSUtilit'#225'rios'
        'BackUp'
        'BuscaIBPT'
        'SSNFCe')
      ParentFont = False
      TabOrder = 0
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 212
    Width = 503
    Height = 132
    Align = alBottom
    Color = clBtnShadow
    TabOrder = 3
    object Gauge1: TGauge
      Left = 50
      Top = 6
      Width = 380
      Height = 19
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Progress = 0
    end
    object Shape1: TShape
      Left = 50
      Top = 30
      Width = 13
      Height = 13
      Brush.Color = 8404992
    end
    object Label3: TLabel
      Left = 66
      Top = 30
      Width = 53
      Height = 13
      Caption = 'Programa'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI Light'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVersaoNFEBD: TLabel
      Left = 1
      Top = 111
      Width = 501
      Height = 20
      Align = alBottom
      Alignment = taCenter
      Caption = 'Vers'#227'o do NFeBD: 00000 / Vers'#227'o do NFeBD de atualiza'#231#227'o: 00000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Light'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object Label4: TLabel
      Left = 128
      Top = 62
      Width = 147
      Height = 16
      Caption = 'Vers'#227'o Banco Local:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVersaoLocal: TLabel
      Left = 280
      Top = 61
      Width = 45
      Height = 16
      Caption = '00000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 37
      Top = 79
      Width = 238
      Height = 16
      Caption = 'Vers'#227'o do Banco de Atualiza'#231#227'o:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVersaoAtualizacao: TLabel
      Left = 280
      Top = 79
      Width = 45
      Height = 16
      Caption = '00000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object ftpUpdate: TIdFTP
    OnStatus = ftpUpdateStatus
    MaxLineAction = maException
    ReadTimeout = 0
    OnDisconnected = ftpUpdateDisconnected
    OnWork = ftpUpdateWork
    OnWorkBegin = ftpUpdateWorkBegin
    Host = 'ftp.ssfacil.inf.br'
    Passive = True
    Password = 'cliente'
    Username = 'ssfacil01'
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 312
    Top = 4
  end
  object Decoder64: TIdDecoderMIME
    FillChar = '='
    Left = 344
    Top = 4
  end
  object ZipMaster1: TZipMaster
    AddOptions = []
    AddStoreSuffixes = [assGIF, assPNG, assZ, assZIP, assZOO, assARC, assLZH, assARJ, assTAZ, assTGZ, assLHA, assRAR, assACE, assCAB, assGZ, assGZIP, assJAR, assJPG, assJPEG, ass7Zp, assMP3, assWMV, assWMA, assDVR, assAVI]
    ConfirmErase = False
    DLL_Load = False
    ExtrOptions = []
    KeepFreeOnAllDisks = 0
    KeepFreeOnDisk1 = 0
    LanguageID = 0
    MaxVolumeSizeKb = 0
    NoReadAux = False
    SFXOptions = []
    SFXOverwriteMode = ovrAlways
    SpanOptions = []
    Trace = False
    Unattended = False
    UseUTF8 = False
    Verbose = False
    Version = '1.9.1.0012'
    WriteOptions = []
    Left = 281
    Top = 4
  end
end
