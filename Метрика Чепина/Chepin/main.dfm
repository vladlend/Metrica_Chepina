object frmMain: TfrmMain
  Left = 227
  Top = 107
  Caption = #1040#1085#1072#1083#1080#1079' '#1087#1086' '#1084#1077#1090#1088#1080#1082#1077' '#1063#1077#1087#1080#1085#1072
  ClientHeight = 551
  ClientWidth = 650
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 249
    Width = 650
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 658
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 417
    Width = 650
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 658
  end
  object mmoSource: TMemo
    Left = 0
    Top = 41
    Width = 650
    Height = 208
    Align = alTop
    TabOrder = 0
  end
  object mmoAnswer: TMemo
    Left = 0
    Top = 252
    Width = 650
    Height = 165
    Align = alTop
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 41
    Align = alTop
    TabOrder = 2
    object lblResult: TLabel
      Left = 240
      Top = 12
      Width = 30
      Height = 13
      Caption = 'Result'
    end
    object btnOpenFile: TButton
      Left = 8
      Top = 8
      Width = 113
      Height = 25
      Caption = 'Open File'
      TabOrder = 0
      OnClick = btnOpenFileClick
    end
    object btnDecount: TButton
      Left = 136
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Process'
      TabOrder = 1
      OnClick = btnDecountClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 420
    Width = 650
    Height = 131
    Align = alClient
    TabOrder = 3
    object Splitter3: TSplitter
      Left = 537
      Top = 1
      Height = 129
      ExplicitHeight = 141
    end
    object meUnused: TMemo
      Left = 540
      Top = 1
      Width = 109
      Height = 129
      Align = alClient
      TabOrder = 0
    end
    object meControl: TMemo
      Left = 401
      Top = 1
      Width = 136
      Height = 129
      Align = alLeft
      TabOrder = 1
    end
    object meMod: TMemo
      Left = 265
      Top = 1
      Width = 136
      Height = 129
      Align = alLeft
      TabOrder = 2
    end
    object meInfo: TMemo
      Left = 129
      Top = 1
      Width = 136
      Height = 129
      Align = alLeft
      TabOrder = 3
    end
    object meVars: TMemo
      Left = 1
      Top = 1
      Width = 128
      Height = 129
      Align = alLeft
      TabOrder = 4
    end
  end
  object dlgOpen_File: TOpenDialog
    Left = 16
    Top = 32
  end
end
