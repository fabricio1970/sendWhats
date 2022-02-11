object MainView: TMainView
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Send Whats'
  ClientHeight = 491
  ClientWidth = 811
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    811
    491)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 80
    Width = 580
    Height = 378
    Caption = '  Chat   '
    TabOrder = 2
    object Panel2: TPanel
      AlignWithMargins = True
      Left = 7
      Top = 88
      Width = 566
      Height = 159
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 10
      Align = alClient
      TabOrder = 1
      object RichEditMyChat: TRichEdit
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 554
        Height = 142
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 10
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        Zoom = 100
      end
    end
    object Panel3: TPanel
      AlignWithMargins = True
      Left = 7
      Top = 20
      Width = 566
      Height = 53
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 10
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 80
        Height = 13
        Caption = 'Adresser Phone:'
      end
      object MaskEditAdresserPhone: TMaskEdit
        Left = 8
        Top = 24
        Width = 107
        Height = 21
        EditMask = '99 (99) 9 9999-9999;0;_'
        MaxLength = 19
        TabOrder = 0
        Text = ''
      end
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 7
      Top = 262
      Width = 566
      Height = 104
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 10
      Align = alBottom
      TabOrder = 2
      object Panel4: TPanel
        AlignWithMargins = True
        Left = 417
        Top = 4
        Width = 145
        Height = 96
        Align = alRight
        TabOrder = 0
        object BotaoSendMessage: TButton
          Left = 6
          Top = 4
          Width = 135
          Height = 36
          Caption = 'Send Message'
          TabOrder = 0
          OnClick = BotaoSendMessageClick
        end
        object BotaoSendFileMessage: TButton
          Left = 6
          Top = 44
          Width = 135
          Height = 47
          Caption = 'Send Message With File (mp3, jpg, pdf, ect.)'
          TabOrder = 1
          WordWrap = True
          OnClick = BotaoSendFileMessageClick
        end
      end
      object RichEditMessage: TRichEdit
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 403
        Height = 87
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 10
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Zoom = 100
      end
    end
  end
  object GroupBox3: TGroupBox
    Left = 601
    Top = 8
    Width = 202
    Height = 227
    Anchors = [akTop, akRight]
    Caption = '  QR Code   '
    TabOrder = 1
    object Image1: TImage
      AlignWithMargins = True
      Left = 7
      Top = 20
      Width = 188
      Height = 195
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 10
      Align = alClient
      Proportional = True
      Stretch = True
      ExplicitLeft = 0
      ExplicitTop = 18
      ExplicitWidth = 201
      ExplicitHeight = 202
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 580
    Height = 66
    Caption = '  Configura'#231#245'es   '
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 20
      Width = 58
      Height = 13
      Caption = 'My Number:'
    end
    object Label3: TLabel
      Left = 142
      Top = 20
      Width = 52
      Height = 13
      Caption = 'Hostname:'
    end
    object Label4: TLabel
      Left = 269
      Top = 20
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object Label5: TLabel
      Left = 321
      Top = 20
      Width = 51
      Height = 13
      Caption = 'My secret:'
    end
    object MaskEditMyNumber: TMaskEdit
      Left = 8
      Top = 36
      Width = 111
      Height = 21
      EditMask = '99 (99) 9 9999-9999;0;_'
      MaxLength = 19
      TabOrder = 0
      Text = '5532988764864'
    end
    object EditHostname: TEdit
      Left = 142
      Top = 36
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'localhost'
    end
    object EditPort: TEdit
      Left = 269
      Top = 36
      Width = 46
      Height = 21
      NumbersOnly = True
      TabOrder = 2
      Text = '21465'
    end
    object EditSecret: TEdit
      Left = 321
      Top = 36
      Width = 250
      Height = 21
      TabOrder = 3
      Text = 'psoft'
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 472
    Width = 811
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object BotaoStartStop: TButton
    Left = 601
    Top = 241
    Width = 202
    Height = 25
    Caption = 'Start'
    TabOrder = 3
    OnClick = BotaoStartStopClick
  end
  object BotaoCloseSession: TButton
    Left = 601
    Top = 272
    Width = 202
    Height = 30
    Caption = 'Close Session'
    TabOrder = 4
    OnClick = BotaoCloseSessionClick
  end
  object Button1: TButton
    Left = 601
    Top = 308
    Width = 202
    Height = 32
    Caption = 'Get Unread Messages'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 598
    Top = 244
  end
  object OpenDialog1: TOpenDialog
    Left = 631
    Top = 244
  end
end
