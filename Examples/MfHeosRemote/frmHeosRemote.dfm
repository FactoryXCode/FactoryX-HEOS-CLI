object frmHeosRemote: TfrmHeosRemote
  Left = 0
  Top = 0
  Caption = 'HEOS CLI Remote'
  ClientHeight = 676
  ClientWidth = 720
  Color = clBtnFace
  Constraints.MinHeight = 714
  Constraints.MinWidth = 736
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    720
    676)
  PixelsPerInch = 96
  TextHeight = 17
  object grpConnection: TGroupBox
    Left = 12
    Top = 8
    Width = 696
    Height = 120
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Connection '
    TabOrder = 0
    DesignSize = (
      696
      120)
    object lblHost: TLabel
      Left = 16
      Top = 28
      Width = 66
      Height = 17
      Caption = 'Receiver IP:'
    end
    object lblConnection: TLabel
      Left = 496
      Top = 28
      Width = 184
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Disconnected'
      EllipsisPosition = epEndEllipsis
    end
    object lblPlayer: TLabel
      Left = 16
      Top = 72
      Width = 38
      Height = 17
      Caption = 'Player:'
    end
    object edHost: TEdit
      Left = 96
      Top = 24
      Width = 172
      Height = 25
      TabOrder = 0
      TextHint = '192.168.1.100'
    end
    object btnConnect: TButton
      Left = 282
      Top = 22
      Width = 96
      Height = 30
      Caption = 'Connect'
      Default = True
      TabOrder = 1
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 384
      Top = 22
      Width = 96
      Height = 30
      Caption = 'Disconnect'
      TabOrder = 2
      OnClick = btnDisconnectClick
    end
    object cbPlayers: TComboBox
      Left = 96
      Top = 68
      Width = 384
      Height = 25
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      OnChange = cbPlayersChange
    end
    object btnRefresh: TButton
      Left = 488
      Top = 66
      Width = 92
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 4
      OnClick = btnRefreshClick
    end
    object btnFind: TButton
      Left = 584
      Top = 66
      Width = 92
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Find HEOS'
      TabOrder = 5
      OnClick = btnFindClick
    end
  end
  object grpPlayback: TGroupBox
    Left = 12
    Top = 136
    Width = 696
    Height = 136
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Playback '
    TabOrder = 1
    DesignSize = (
      696
      136)
    object lblVolume: TLabel
      Left = 16
      Top = 88
      Width = 96
      Height = 18
      AutoSize = False
      Caption = 'Volume: -'
    end
    object btnPrevious: TButton
      Left = 16
      Top = 25
      Width = 116
      Height = 30
      Caption = 'Previous'
      TabOrder = 0
      OnClick = TransportClick
    end
    object btnPlay: TButton
      Tag = 1
      Left = 144
      Top = 25
      Width = 116
      Height = 30
      Caption = 'Play'
      TabOrder = 1
      OnClick = TransportClick
    end
    object btnPause: TButton
      Tag = 2
      Left = 272
      Top = 25
      Width = 116
      Height = 30
      Caption = 'Pause'
      TabOrder = 2
      OnClick = TransportClick
    end
    object btnStop: TButton
      Tag = 3
      Left = 400
      Top = 25
      Width = 116
      Height = 30
      Caption = 'Stop'
      TabOrder = 3
      OnClick = TransportClick
    end
    object btnNext: TButton
      Tag = 4
      Left = 528
      Top = 25
      Width = 116
      Height = 30
      Caption = 'Next'
      TabOrder = 4
      OnClick = TransportClick
    end
    object tbVolume: TTrackBar
      Left = 112
      Top = 78
      Width = 432
      Height = 40
      Anchors = [akLeft, akTop, akRight]
      Max = 100
      Frequency = 10
      TabOrder = 5
      OnChange = tbVolumeChange
    end
    object chkMute: TCheckBox
      Left = 576
      Top = 91
      Width = 80
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Mute'
      TabOrder = 6
      OnClick = chkMuteClick
    end
  end
  object grpFile: TGroupBox
    Left = 12
    Top = 280
    Width = 696
    Height = 56
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Audio file '
    TabOrder = 2
    DesignSize = (
      696
      56)
    object edAudioFile: TEdit
      Left = 16
      Top = 22
      Width = 556
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 0
      TextHint = 'Choose a file, then press Play'
    end
    object btnBrowse: TButton
      Left = 584
      Top = 19
      Width = 96
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Browse...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
  end
  object grpNowPlaying: TGroupBox
    Left = 12
    Top = 344
    Width = 696
    Height = 154
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Now playing '
    TabOrder = 3
    DesignSize = (
      696
      154)
    object lblTitle: TLabel
      Left = 16
      Top = 24
      Width = 660
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Title: -'
      EllipsisPosition = epEndEllipsis
    end
    object lblArtist: TLabel
      Left = 16
      Top = 47
      Width = 660
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Artist: -'
      EllipsisPosition = epEndEllipsis
    end
    object lblAlbum: TLabel
      Left = 16
      Top = 70
      Width = 660
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Album: -'
      EllipsisPosition = epEndEllipsis
    end
    object lblState: TLabel
      Left = 16
      Top = 123
      Width = 180
      Height = 18
      AutoSize = False
      Caption = 'State: -'
    end
    object lblTime: TLabel
      Left = 440
      Top = 123
      Width = 236
      Height = 18
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '00:00:00 / 00:00:00'
    end
    object pbProgress: TProgressBar
      Left = 16
      Top = 98
      Width = 660
      Height = 14
      Anchors = [akLeft, akTop, akRight]
      Max = 1000
      TabOrder = 0
    end
  end
  object memLog: TMemo
    Left = 12
    Top = 508
    Width = 696
    Height = 120
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object btnClearLog: TButton
    Left = 612
    Top = 638
    Width = 96
    Height = 27
    Anchors = [akRight, akBottom]
    Caption = 'Clear log'
    TabOrder = 5
    OnClick = btnClearLogClick
  end
  object dlgAudioFile: TOpenDialog
    Filter = 
      'Audio files|*.mp3;*.flac;*.wav;*.aac;*.m4a;*.mp4;*.wma|All files' +
      '|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select an audio file to play on HEOS'
    Left = 152
    Top = 640
  end
  object DispatchTimer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = DispatchTimerTimer
    Left = 48
    Top = 640
  end
  object VolumeTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = VolumeTimerTimer
    Left = 96
    Top = 640
  end
end
