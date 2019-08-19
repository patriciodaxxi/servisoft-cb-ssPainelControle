object frmBackUp: TfrmBackUp
  Left = 295
  Top = 260
  Width = 490
  Height = 260
  BorderIcons = [biSystemMenu]
  Caption = 'frmBackUp'
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 474
    Height = 221
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'BackUp'
      object Gauge1: TGauge
        Left = 47
        Top = 142
        Width = 380
        Height = 19
        Progress = 0
      end
      object lblcontador: TLabel
        Left = 56
        Top = 94
        Width = 3
        Height = 13
      end
      object Label18: TLabel
        Left = 36
        Top = 48
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'Arquivo BKP:'
      end
      object Label1: TLabel
        Left = 60
        Top = 24
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'Arquivo FDB:'
      end
      object Label4: TLabel
        Left = 13
        Top = 72
        Width = 86
        Height = 13
        Alignment = taRightJustify
        Caption = 'Arquivo BKP NFe:'
      end
      object Shape1: TShape
        Left = 105
        Top = 40
        Width = 20
        Height = 20
        Brush.Color = clBlue
      end
      object Shape2: TShape
        Left = 105
        Top = 64
        Width = 20
        Height = 20
        Brush.Color = clOlive
      end
      object BitBtn3: TBitBtn
        Left = 32
        Top = 169
        Width = 75
        Height = 25
        Caption = 'Back Up'
        TabOrder = 0
        OnClick = BitBtn3Click
      end
      object BitBtn4: TBitBtn
        Left = 112
        Top = 169
        Width = 75
        Height = 25
        Caption = 'Cancelar'
        TabOrder = 1
        OnClick = BitBtn4Click
      end
      object CheckBox1: TCheckBox
        Left = 119
        Top = 120
        Width = 257
        Height = 17
        TabStop = False
        Caption = 'Enviar arqruivo para servidor FTP'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object Edit2: TEdit
        Left = 127
        Top = 40
        Width = 321
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 3
      end
      object Edit1: TEdit
        Left = 127
        Top = 16
        Width = 321
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 4
      end
      object Edit3: TEdit
        Left = 127
        Top = 64
        Width = 321
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 5
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Restore'
      ImageIndex = 1
      object Label2: TLabel
        Left = 36
        Top = 40
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'Arquivo BKP:'
      end
      object Label3: TLabel
        Left = 36
        Top = 72
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'Arquivo FDB:'
      end
      object BitBtn1: TBitBtn
        Left = 360
        Top = 169
        Width = 75
        Height = 25
        Caption = 'Restore'
        TabOrder = 0
        OnClick = BitBtn1Click
      end
      object FilenameEdit1: TFilenameEdit
        Left = 104
        Top = 32
        Width = 321
        Height = 21
        Filter = 'Arquivo de BackUp|*.fbk|All files (*.*)|*.*'
        NumGlyphs = 1
        TabOrder = 1
        Text = 'c:\'
      end
      object DirectoryEdit1: TDirectoryEdit
        Left = 104
        Top = 64
        Width = 321
        Height = 21
        NumGlyphs = 1
        TabOrder = 2
        Text = 'c:\'
      end
    end
  end
  object Decoder64: TIdDecoderMIME
    FillChar = '='
    Left = 368
    Top = 8
  end
  object ftpBackUp: TIdFTP
    MaxLineAction = maException
    ReadTimeout = 0
    OnWork = ftpBackUpWork
    Passive = True
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 340
    Top = 8
  end
end
