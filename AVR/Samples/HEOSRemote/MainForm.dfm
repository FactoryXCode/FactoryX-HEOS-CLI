object HEOSForm: THEOSForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'HEOS Remote 1.1.11'
  ClientHeight = 620
  ClientWidth = 810
  Color = clBlack
  Constraints.MinWidth = 806
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = MainCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object pnlSettings: TPanel
    Left = 0
    Top = 33
    Width = 810
    Height = 587
    Align = alClient
    Color = 5850948
    ParentBackground = False
    TabOrder = 0
    ExplicitLeft = 1
    object AddressLabel: TLabel
      Left = 54
      Top = 31
      Width = 97
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Receiver IPv4:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object FStatus: TLabel
      Left = 1
      Top = 384
      Width = 808
      Height = 36
      Align = alBottom
      AutoSize = False
      Caption = 
        'Ready. Click Read status to connect. Status values are snapshots' +
        '; they do not update automatically.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitLeft = 7
      ExplicitTop = 277
      ExplicitWidth = 788
    end
    object PcAddressLabel: TLabel
      Left = 30
      Top = 251
      Width = 118
      Height = 17
      Caption = 'PC IP (blank = auto):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object PortLabel: TLabel
      Left = 364
      Top = 251
      Width = 62
      Height = 17
      Caption = 'HTTP port:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 54
      Top = 68
      Width = 97
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Select Source'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object edHost: TEdit
      Left = 157
      Top = 29
      Width = 190
      Height = 25
      Hint = 'Find the HEOS receiver'#39's IP in the receiver'
      BevelInner = bvNone
      BevelKind = bkSoft
      BevelOuter = bvRaised
      BorderStyle = bsNone
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object cbxHEOSDevices: TComboBox
      Left = 353
      Top = 28
      Width = 290
      Height = 25
      Style = csDropDownList
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = HEOSDeviceChange
    end
    object PcAddressEdit: TEdit
      Left = 157
      Top = 251
      Width = 185
      Height = 25
      BevelInner = bvNone
      BevelKind = bkSoft
      BevelOuter = bvRaised
      BorderStyle = bsNone
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      TextHint = '0.0.0.0'
    end
    object StreamPortEdit: TEdit
      Left = 432
      Top = 251
      Width = 90
      Height = 25
      BevelInner = bvNone
      BevelKind = bkSoft
      BevelOuter = bvRaised
      BorderStyle = bsNone
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      NumbersOnly = True
      ParentFont = False
      TabOrder = 3
      Text = '8890'
      TextHint = '8890'
    end
    object btnFindHEOSDevice: TDnButton
      Left = 649
      Top = 26
      Width = 122
      Height = 30
      Alignment = taCenter
      Caption = 'Find HEOS Device'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = FindHEOSDeviceClick
    end
    object FSource: TComboBox
      Left = 157
      Top = 65
      Width = 285
      Height = 25
      Style = csDropDownList
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 5
      Text = 'TV Audio'
      Items.Strings = (
        'TV Audio'
        'Blu-ray'
        'Game'
        'Media Player'
        'CBL/SAT'
        'CD'
        'Tuner (DAB/FM)'
        'HEOS / Network')
    end
    object chkAutoNextCheck: TCheckBox
      AlignWithMargins = True
      Left = 30
      Top = 211
      Width = 140
      Height = 27
      Alignment = taLeftJustify
      Caption = 'Auto-next in playlist:'
      Checked = True
      Color = 5850948
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      State = cbChecked
      TabOrder = 6
      StyleElements = [seClient, seBorder]
    end
    object memFLog: TMemo
      Left = 1
      Top = 420
      Width = 808
      Height = 166
      Align = alBottom
      Color = 4410626
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 9889633
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      Lines.Strings = (
        
          'Native Windows sockets. AVR port 23; HEOS port 1255. No capture ' +
          'on startup.')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 7
    end
    object btnSelectInput: TDnButton
      Tag = 7
      Left = 157
      Top = 101
      Width = 104
      Height = 25
      Alignment = taCenter
      Caption = 'Select input'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = ActionClick
    end
    object btnWebInterface: TDnButton
      Left = 157
      Top = 142
      Width = 104
      Height = 25
      Alignment = taCenter
      Caption = 'Web interface'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = BrowserClick
    end
    object btnReadStatus: TDnButton
      Left = 157
      Top = 180
      Width = 104
      Height = 25
      Alignment = taCenter
      Caption = 'Read status'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = ActionClick
    end
  end
  object pnlPlay: TPanel
    Left = 0
    Top = 33
    Width = 810
    Height = 587
    Align = alClient
    Color = 4865081
    ParentBackground = False
    TabOrder = 1
    ExplicitLeft = 1
    object Bevel8: TBevel
      Left = 579
      Top = 38
      Width = 215
      Height = 61
    end
    object Bevel6: TBevel
      Left = 12
      Top = 31
      Width = 127
      Height = 510
    end
    object Bevel7: TBevel
      Left = 145
      Top = 31
      Width = 278
      Height = 510
    end
    object Bevel5: TBevel
      Left = 429
      Top = 505
      Width = 370
      Height = 36
    end
    object Bevel1: TBevel
      Left = 429
      Top = 114
      Width = 370
      Height = 71
    end
    object lblStreamInfo: TLabel
      Left = 1
      Top = 546
      Width = 808
      Height = 40
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Caption = 'Choose an audio file, start Windows sound or play a playlist. '
      Color = 4410626
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      WordWrap = True
      ExplicitLeft = 0
      ExplicitTop = 571
    end
    object lblDuration: TLabel
      Left = 439
      Top = 516
      Width = 105
      Height = 17
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Duration: 00:00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblPlayed: TLabel
      Left = 563
      Top = 516
      Width = 93
      Height = 17
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Played: 00:00:00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblVolumePerc: TLabel
      Left = 47
      Top = 44
      Width = 50
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = '0%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblVol: TLabel
      Left = 21
      Top = 23
      Width = 58
      Height = 16
      Hint = 'Channel volume'
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Volume'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      Layout = tlCenter
    end
    object Bevel2: TBevel
      Left = 429
      Top = 282
      Width = 370
      Height = 71
    end
    object lblZones: TLabel
      Left = 439
      Top = 273
      Width = 51
      Height = 13
      Hint = 'Zone'#39's'
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Zone'#39's'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Transparent = False
      Layout = tlCenter
    end
    object Bevel3: TBevel
      Left = 429
      Top = 31
      Width = 370
      Height = 71
    end
    object lblBalance: TLabel
      Left = 234
      Top = 513
      Width = 101
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'Balance: Centre'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 153
      Top = 516
      Width = 47
      Height = 13
      Hint = 'Channel volume'
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Left'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Layout = tlCenter
    end
    object Label3: TLabel
      Left = 367
      Top = 516
      Width = 47
      Height = 13
      Hint = 'Channel volume'
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Right'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Layout = tlCenter
    end
    object lblBass: TLabel
      Left = 203
      Top = 45
      Width = 59
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = '0 dB'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lblTreble: TLabel
      Left = 305
      Top = 45
      Width = 51
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = '0 dB'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lblToneStatus: TLabel
      Left = 153
      Top = 303
      Width = 261
      Height = 46
      Alignment = taCenter
      AutoSize = False
      Caption = 'Receiver tone settings ...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Bevel4: TBevel
      Left = 429
      Top = 197
      Width = 370
      Height = 71
    end
    object Label4: TLabel
      Left = 147
      Top = 23
      Width = 112
      Height = 16
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Tone and balance'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      Layout = tlCenter
    end
    object Label5: TLabel
      Left = 439
      Top = 23
      Width = 42
      Height = 16
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Play'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      Layout = tlCenter
    end
    object lblSeekTime: TLabel
      Left = 12
      Top = 1
      Width = 58
      Height = 17
      Caption = ' 00:00:00 '
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clInfoText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Visible = False
    end
    object Label6: TLabel
      Left = 439
      Top = 106
      Width = 56
      Height = 16
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Playlist'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      Layout = tlCenter
    end
    object Label7: TLabel
      Left = 439
      Top = 190
      Width = 56
      Height = 16
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Alignment = taCenter
      AutoSize = False
      Caption = 'Overall'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      Layout = tlCenter
    end
    object Label8: TLabel
      Left = 208
      Top = 273
      Width = 49
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'Bass'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Label9: TLabel
      Left = 307
      Top = 273
      Width = 49
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'Treble'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object tbBalance: TDnTrackBar
      Left = 148
      Top = 467
      Width = 271
      Height = 40
      Hint = 
        'Left / Centre / Right. Double-click to restore the original chan' +
        'nel levels.'
      TabOrder = 5
      Color = 4865081
      ParentColor = False
      Minimum = -24
      Maximum = 24
      ThumbWidth = 60
      ThumbHeight = 40
      TransparentColor = clBlack
      ThumbPictureHorz.Data = {
        07544269746D617012010000424D120100000000000076000000280000001300
        00000D00000001000400000000009C000000330B0000330B0000100000001000
        000000000000959595009B9B9B00A2A2A200B9B9B900C4C4C400FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00055555554445555555000000531425454045452413500000531425454045
        4524135000005314254540454524135000005314254540454524135000005314
        2545404545241350000053142545404545241350000053142545404545241350
        0000531425454045452413500000531425454045452413500000531425454045
        452413500000531425454045452413500000055555554445555555000000}
      ShowTicks = True
      TickCount = 25
      DbFloor = -50.000000000000000000
      DbCeil = 6.000000000000000000
      TickColor = clAqua
      TickLabelsVisible = False
      TickPlacementH = tphBoth
      OnChange = BalanceChange
      OnDblClick = BalanceDblClick
    end
    object tbBass: TDnTrackBar
      Left = 200
      Top = 68
      Width = 62
      Height = 208
      Hint = 'Bass -6 to +6 dB. Double-click to reset to 0 dB.'
      TabOrder = 1
      Color = 4865081
      ParentColor = False
      Minimum = -6
      Maximum = 6
      Orientation = soVertical
      IncreaseToward = itUp
      ThumbWidth = 40
      ThumbHeight = 60
      TransparentColor = clBlack
      ThumbPictureVert.Data = {
        07544269746D61700E010000424D0E0100000000000076000000280000000D00
        000013000000010004000000000098000000330B0000330B0000100000001000
        000000000000959595009B9B9B00A2A2A200B9B9B900BFBFBF00C4C4C400C9C9
        C900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00044444444444000048888888888840004777777777774000455555555555
        4000477777777777400045555555555540004777777777774000455555555555
        4000477777777777500050000000000050005444444444445000555555555555
        5000544444444444500055555555555550005222222222225000544444444444
        5000511111111111500053333333333350000555555555550000}
      ShowTicks = True
      TickCount = 50
      DbFloor = -50.000000000000000000
      DbCeil = 6.000000000000000000
      TickColor = clAqua
      TickLabelsVisible = False
      TickPlacementH = tphBoth
      TickPlacementV = tpvBoth
      OnChange = ToneChange
      OnDblClick = ToneDblClick
    end
    object tbTreble: TDnTrackBar
      Left = 297
      Top = 68
      Width = 71
      Height = 206
      Hint = 'Treble -6 to +6 dB. Double-click to reset to 0 dB.'
      TabOrder = 2
      Color = 4865081
      ParentColor = False
      Minimum = -6
      Maximum = 6
      Orientation = soVertical
      IncreaseToward = itUp
      ThumbWidth = 40
      ThumbHeight = 60
      TransparentColor = clBlack
      ThumbPictureVert.Data = {
        07544269746D61700E010000424D0E0100000000000076000000280000000D00
        000013000000010004000000000098000000330B0000330B0000100000001000
        000000000000959595009B9B9B00A2A2A200B9B9B900BFBFBF00C4C4C400C9C9
        C900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00044444444444000048888888888840004777777777774000455555555555
        4000477777777777400045555555555540004777777777774000455555555555
        4000477777777777500050000000000050005444444444445000555555555555
        5000544444444444500055555555555550005222222222225000544444444444
        5000511111111111500053333333333350000555555555550000}
      ShowTicks = True
      TickCount = 50
      DbFloor = -50.000000000000000000
      DbCeil = 6.000000000000000000
      TickColor = clAqua
      TickLabelsVisible = False
      TickPlacementH = tphBoth
      TickPlacementV = tpvBoth
      OnChange = ToneChange
      OnDblClick = ToneDblClick
    end
    object btnTone: TDnButton
      Left = 439
      Top = 211
      Width = 64
      Height = 50
      Hint = 'Enable Bass/Treble'
      Alignment = taCenter
      Caption = 'Tone'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clAqua
      ShowHint = True
      OnClick = ToneClick
    end
    object btnStop: TDnButton
      Tag = 4
      Left = 726
      Top = 44
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Stop'
      Color = clRed
      ColorWhenDown = clMaroon
      ColorWhenUp = clRed
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMoneyGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = StreamClick
    end
    object btnPlayPause: TDnButton
      Left = 656
      Top = 44
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Play'
      Color = clGreen
      ColorWhenDown = 20480
      ColorWhenUp = clGreen
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMoneyGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = PlayPauseClick
    end
    object btnLoadFile: TDnButton
      Left = 586
      Top = 44
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = ' Load File'
      Color = 15368203
      ColorWhenDown = 8931846
      ColorWhenUp = 15368203
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMoneyGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      WordWrap = True
      OnClick = BrowseMusicClick
    end
    object btnPlayList: TDnButton
      Left = 439
      Top = 127
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Playlist'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = PlaylistClick
      OnMouseEnter = PlaylistHover
      OnMouseExit = btnPlayListMouseExit
    end
    object btnPrevious: TDnButton
      Tag = -1
      Left = 509
      Top = 127
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Previous'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        000000000000000000FF0000000F00000000000000FF000000FF000000000000
        00FF00000FFF00000000000000FF0000FFFF00000000000000FF000FFFFF0000
        0000000000FF00FFFFFF00000000000000FF0FFFFFFF00000000000000FFFFFF
        FFFF00000000000000FF0FFFFFFF00000000000000FF00FFFFFF000000000000
        00FF000FFFFF00000000000000FF0000FFFF00000000000000FF00000FFF0000
        0000000000FF000000FF00000000000000FF0000000F00000000000000000000
        000000000000}
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      NumGlyphs = 1
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = TrackClick
    end
    object btnNext: TDnButton
      Tag = 1
      Left = 579
      Top = 127
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Next'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        0000000000000F0000000FF00000000000000FF000000FF00000000000000FFF
        00000FF00000000000000FFFF0000FF00000000000000FFFFF000FF000000000
        00000FFFFFF00FF00000000000000FFFFFFF0FF00000000000000FFFFFFFFFF0
        0000000000000FFFFFFF0FF00000000000000FFFFFF00FF00000000000000FFF
        FF000FF00000000000000FFFF0000FF00000000000000FFF00000FF000000000
        00000FF000000FF00000000000000F0000000FF0000000000000000000000000
        000000000000}
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      NumGlyphs = 1
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = TrackClick
    end
    object btnShuffle: TDnButton
      Left = 649
      Top = 127
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Shuffle'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = QueueModeClick
    end
    object btnLoop: TDnButton
      Left = 649
      Top = 210
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Loop'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = QueueModeClick
    end
    object btnStreamWinAudio: TDnButton
      Left = 439
      Top = 44
      Width = 64
      Height = 50
      Hint = 'Stream Windows audio from this device.'
      Alignment = taCenter
      Caption = 'Stream Windows'
      Color = 7086848
      ColorWhenDown = 8931846
      ColorWhenUp = 7086848
      Behavior = bbCheckBox
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMoneyGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clAqua
      ShowHint = True
      WordWrap = True
      OnClick = btnStreamWinAudioClick
    end
    object tbVolume: TDnTrackBar
      Left = 50
      Top = 68
      Width = 47
      Height = 403
      Hint = 'Main volume: receiver scale 0.0 to 98.0, in steps of 0.5'
      TabOrder = 0
      Color = 4865081
      ParentColor = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      Maximum = 196
      Orientation = soVertical
      IncreaseToward = itUp
      ThumbWidth = 50
      ThumbHeight = 60
      TransparentColor = clBlack
      AutoDefaultThumb = False
      ThumbPictureVert.Data = {
        07544269746D61700E010000424D0E0100000000000076000000280000000D00
        000013000000010004000000000098000000330B0000330B0000100000001000
        000000000000959595009B9B9B00A2A2A200B9B9B900BFBFBF00C4C4C400C9C9
        C900CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00044444444444000048888888888840004777777777774000455555555555
        4000477777777777400045555555555540004777777777774000455555555555
        4000477777777777500050000000000050005444444444445000555555555555
        5000544444444444500055555555555550005222222222225000544444444444
        5000511111111111500053333333333350000555555555550000}
      ShowTicks = True
      TickCount = 50
      DbFloor = -50.000000000000000000
      DbCeil = 6.000000000000000000
      TickColor = clAqua
      TickTextColor = clAqua
      TickLabelBackColor = 4865081
      TickLabelsVisible = False
      TickPlacementV = tpvBoth
      OnChange = VolumeChange
      OnDblClick = tbVolumeDblClick
    end
    object pbProgress: TDnLevelProgressBar
      Left = 1
      Top = 1
      Width = 808
      Height = 24
      Align = alTop
      Color = 4865081
      ParentColor = False
      BorderColor = 4865081
      BackgroundColor = 4865081
      ForegroundPicture.Data = {
        0A544A504547496D6167654B060000FFD8FFE000104A46494600010101004800
        480000FFDB0043000A07070807060A0808080B0A0A0B0E18100E0D0D0E1D1516
        1118231F2524221F2221262B372F26293429212230413134393B3E3E3E252E44
        49433C48373D3E3BFFDB0043010A0B0B0E0D0E1C10101C3B2822283B3B3B3B3B
        3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B
        3B3B3B3B3B3B3B3B3B3B3B3B3BFFC0001108000A012003012200021101031101
        FFC4001F0000010501010101010100000000000000000102030405060708090A
        0BFFC400B5100002010303020403050504040000017D01020300041105122131
        410613516107227114328191A1082342B1C11552D1F02433627282090A161718
        191A25262728292A3435363738393A434445464748494A535455565758595A63
        6465666768696A737475767778797A838485868788898A92939495969798999A
        A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
        D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
        01010101010101010000000000000102030405060708090A0BFFC400B5110002
        0102040403040705040400010277000102031104052131061241510761711322
        328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
        292A35363738393A434445464748494A535455565758595A636465666768696A
        737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
        A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
        E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00EC1A
        242CC723EF49FA8E685890329C8FBD1FE838AA8EC7CC7E4FDF9FFF0041A118F9
        89C9FBF07FE835E87B395BE2E9FA9E3DFDCF97EA58F263F2B1918F2F1FF8F669
        ED12166391F7A4FD473543737D9BA9FF0051EBFF004D2A4763E63F27EFCFFF00
        A0D53A72BFC5DCD1BD5FACBF22DAC48194E47DE8FF0041C533C98FCAC6463CBC
        7FE3D9AAE8C7CC4E4FDF83FF0041A8F737D9BA9FF51EBFF4D2854E57F8BB027A
        AF58FE45F6890B31C8FBD27EA39A16240CA723EF47FA0E2AA3B1F31F93F7E7FF
        00D068463E62727EFC1FFA0D4FB395BE2E9FA99DFDCF97EA58F263F2B1918F2F
        1FF8F669ED12166391F7A4FD473543737D9BA9FF0051EBFF004D2A4763E63F27
        EFCFFF00A0D53A72BFC5DCD1BD5FACBF22DAC48194E47DE8FF0041C533C98FCA
        C6463CBC7FE3D9AAE8C7CC4E4FDF83FF0041A8F737D9BA9FF51EBFF4D2854E57
        F8BB027AAF58FE45F6890B31C8FBD27EA39A16240CA723EF47FA0E2AA3B1F31F
        93F7E7FF00D068463E62727EFC1FFA0D4FB395BE2E9FA99DFDCF97EA58F263F2
        B1918F2F1FF8F669ED12166391F7A4FD473543737D9BA9FF0051EBFF004D2A47
        63E63F27EFCFFF00A0D53A72BFC5DCD1BD5FACBF22DAC48194E47DE8FF0041C5
        33C98FCAC6463CBC7FE3D9AAE8C7CC4E4FDF83FF0041A8F737D9BA9FF51EBFF4
        D2854E57F8BB027AAF58FE45F6890B31C8FBD27EA39A16240CA723EF47FA0E2A
        A3B1F31F93F7E7FF00D068463E62727EFC1FFA0D4FB395BE2E9FA99DFDCF97EA
        58F263F2B1918F2F1FF8F669ED12166391F7A4FD473543737D9BA9FF0051EBFF
        004D2A4763E63F27EFCFFF00A0D53A72BFC5DCD1BD5FACBF22DAC48194E47DE8
        FF0041C533C98FCAC6463CBC7FE3D9AAE8C7CC4E4FDF83FF0041A8F737D9BA9F
        F51EBFF4D2854E57F8BB027AAF58FE45F6890B31C8FBD27EA39A16240CA723EF
        47FA0E2AA3B1F31F93F7E7FF00D068463E62727EFC1FFA0D4FB395BE2E9FA99D
        FDCF97EA58F263F2B1918F2F1FF8F669ED12166391F7A4FD473543737D9BA9FF
        0051EBFF004D2A4763E63F27EFCFFF00A0D53A72BFC5DCD1BD5FACBF22DAC481
        94E47DE8FF0041C533C98FCAC6463CBC7FE3D9AAE8C7CC4E4FDF83FF0041A8F7
        37D9BA9FF51EBFF4D2854E57F8BB027AAF58FE45F6890B31C8FBD27EA39A1624
        0CA723EF47FA0E2AA3B1F31F93F7E7FF00D068463E62727EFC1FFA0D4FB395BE
        2E9FA99DFDCF97EA58F263F2B1918F2F1FF8F669ED12166391F7A4FD47354373
        7D9BA9FF0051EBFF004D2A4763E63F27EFCFFF00A0D53A72BFC5DCD1BD5FACBF
        22DAC48194E47DE8FF0041C533C98FCAC6463CBC7FE3D9AAE8C7CC4E4FDF83FF
        0041A8F737D9BA9FF51EBFF4D2854E57F8BB027AAF58FE47FFD9}
      ForegroundPictureEnabled = True
      OnMouseMove = pbProgressMouseMove
      OnMouseUp = pbProgressMouseUp
    end
    object btnMainZone: TDnButton
      Left = 439
      Top = 295
      Width = 67
      Height = 50
      Alignment = taCenter
      Caption = 'Main zone'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      WordWrap = True
      OnClick = ZoneClick
    end
    object btnZone2: TDnButton
      Left = 512
      Top = 295
      Width = 67
      Height = 50
      Alignment = taCenter
      Caption = 'Zone 2'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      WordWrap = True
      OnClick = ZoneClick
    end
    object btnMute: TDnButton
      Tag = 5
      Left = 41
      Top = 480
      Width = 64
      Height = 50
      Alignment = taCenter
      Caption = 'Mute'
      Color = 6899524
      ColorWhenDown = 10045252
      ColorWhenUp = 6899524
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        1900001900000019190019000000190019001919000060606000607E6000956B
        430000005C002F0000001D00000002000000020002000000130000002F000200
        2F00000042000000420000005C0000005C0000025C0000026F00001D7800132F
        7800002F8B001D5393002F5393002F669C0042669C005C789C007893A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
        A500A5A5A500A5A5A500A5A5A500A5A5A50095A1A500413C3C00191919000000
        A50000A5000000A5A500A5000000A500A500A5A50000A5A5A500000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600004ABD0094081800841839006B184A006B296B0042297B00524A94006B4A
        94001839A5001842A500004ABD00315ABD005A6BBD00296BCE005A84D6007B94
        D6005A94E70084B5EF0094B5EF0094C6F700A5C6F700BDD6F700D6EFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        00000000000000000010151717151000000000001116181A1A18161100000010
        16191C1E1E1C191610000015181B1F20201F1B18150000171A1D202121201D1A
        170000171A1D202121201D1A17000015181B1F20201F1B181500001016191C1E
        1E1C1916100000001116181A1A18161100000000001015171715100000000000
        00000000000000000000}
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ShadowColor = clAqua
      OnClick = ActionClick
    end
    object btnRadio: TDnButton
      Left = 509
      Top = 45
      Width = 64
      Height = 50
      Hint = 'Stream Windows audio from this device.'
      Alignment = taCenter
      Caption = 'Radio'
      Color = 7086848
      ColorWhenDown = 8931846
      ColorWhenUp = 7086848
      Behavior = bbCheckBox
      GlyphUnchecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000330B0000330B00000001000000010000000000000000
        0C00000C0000000C0C000C0000000C000C000C0C000055555500557555008C61
        3800000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000060000006E00000078000000940000000000
        0000060000001A000000230000002C0000004000000049000000520000005C00
        0000650000006E0000007800000000000000060000001A000000230000003600
        00008B00000094000000400000009D0000009D0000009D0000009D0000009D00
        00009D0000009D0000009D1100009D1A00009D6E00009D5C00009D6500009D78
        00009D7800009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D9D009D9D
        9D009D9D9D009D9D9D009D9D9D009D9D9D008C999D00353131000C0C0C000000
        9D00009D0000009D9D009D0000009D009D009D9D00009D9D9D00000000000000
        00000000000000000016161616161600000000001616242B2B24161600000016
        16242F33332F241616000016172D343737342D17160000162A30383A3A38302A
        160000162A2D383939382D2A16000016172D343737342D171600001616172D2D
        2D2D171616000000161617181817161600000000001616161616160000000000
        00000000000000000000}
      GlyphChecked.Data = {
        C6040000424DC60400000000000036040000280000000C0000000C0000000100
        08000000000090000000230B0000230B00000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600DE8C42004242390052423900634A42007B524200945A4200B56B4200BD6B
        4200C6734200CE7B4200DE8C4200AD634A00AD6B4A00C6734A00D67B4A00D684
        4A00DE8C4A00C6735200DEA55200E7A55200DEAD5200DEC66300DECE6B00E7D6
        7300EFEF9400FFFFB500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        0000000000000000001013191913100000000000121A1C1E1E1C1A1200000010
        1A1C1F20201F1C1A100000181C1F212222211F1C180000191E2022232322201E
        190000191E2022232322201E190000181C1F212222211F1C180000101A1C1F20
        201F1C1A10000000121A1C1E1E1C1A1200000000001013191913100000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMoneyGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      Layout = blGlyphTop
      LightColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clAqua
      ShowHint = True
      WordWrap = True
      OnClick = RadioClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 810
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Color = 4865081
    ParentBackground = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnMouseDown = Panel3MouseDown
    object imgLogo: TImage
      Left = 0
      Top = 0
      Width = 105
      Height = 33
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      Picture.Data = {
        0A544A504547496D6167651C040000FFD8FFE000104A46494600010101012C01
        2C0000FFDB0043000A07070807060A0808080B0A0A0B0E18100E0D0D0E1D1516
        1118231F2524221F2221262B372F26293429212230413134393B3E3E3E252E44
        49433C48373D3E3BFFDB0043010A0B0B0E0D0E1C10101C3B2822283B3B3B3B3B
        3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B
        3B3B3B3B3B3B3B3B3B3B3B3B3BFFC00011080020007803012200021101031101
        FFC4001F0000010501010101010100000000000000000102030405060708090A
        0BFFC400B5100002010303020403050504040000017D01020300041105122131
        410613516107227114328191A1082342B1C11552D1F02433627282090A161718
        191A25262728292A3435363738393A434445464748494A535455565758595A63
        6465666768696A737475767778797A838485868788898A92939495969798999A
        A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
        D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
        01010101010101010000000000000102030405060708090A0BFFC400B5110002
        0102040403040705040400010277000102031104052131061241510761711322
        328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
        292A35363738393A434445464748494A535455565758595A636465666768696A
        737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
        A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
        E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00F30A
        2AD7D89BD68FB0B7A9AC7991DBECA7D8AB456C2E8B07960BCF267BED0294E8F6
        A7A4D28FA8151ED62752CBB10FA7E263515A371A5792E02CBBC119E98A87EC0D
        EA6A94E2CC2586A917668A9455BFB037A9A3EC0DEA68E644FB09F62A5156CD8B
        0EE693EC4DEA68E642F633EC55A2ADFD81BD4D1F606F5347321FB19F62A5156F
        EC2DEA693EC2DEA68E642F633EC564FBEBF5A2ACFD89BD4D149B4CD69A9C15AC
        6E2DBA93CF4A25F2225E1413EF59EDAA6785C7D335035DB48D96E9FEF0AE6B33
        DE8FB28EC8B8D72D9EBF85396EBD4567194F6FFD0850B29CF38C7FBC28E53555
        8DA4293E31C9A90DB606702B1A3BA68DC329008FF6AAFA6AC98F9BAFA022A754
        3B529BBB2CFD9D7D29CD3C4871B47E554A4D4908F93BFB8AA8D72492723FEFA1
        459BDC69D3A7F09AE6486552BF283F4A6790BE95942E718391FF007D0AB09A82
        8032C3F31459AD8997B39BBC8D0DD1C29820139A05C4478217F2ACA96F779CEE
        1FF7D0A8C5C7B8FF00BE851CA5FB48AD11AE614624AE08A416E0939200AA115F
        0418247FDF429EFA8C7B701C7E629FBC62E14B7B16CDBAFF000F345678D45579
        DFFAD155EF19B8D267FFD9}
      Stretch = True
      Transparent = True
      OnMouseDown = imgLogoMouseDown
      ExplicitLeft = 2
      ExplicitHeight = 51
    end
    object lblFrmCaption: TLabel
      Left = 1
      Top = 0
      Width = 104
      Height = 15
      ParentCustomHint = False
      Alignment = taCenter
      AutoSize = False
      Caption = 'HEOS Remote'
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object btnSettings: TDnButton
      Left = 339
      Top = 0
      Width = 111
      Height = 33
      Hint = 'Settings'
      Alignment = taCenter
      Caption = 'Settings'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = SettingsClick
    end
    object btnPlayer: TDnButton
      Left = 105
      Top = 0
      Width = 111
      Height = 33
      Align = alLeft
      Alignment = taCenter
      Caption = 'Play Console'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = PlayerClick
    end
    object DnButton2: TDnButton
      Left = 222
      Top = 0
      Width = 111
      Height = 33
      Hint = 'Playlist editor'
      Alignment = taCenter
      Caption = 'Playlist'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      GlyphTransparentColor = clFuchsia
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = PlaylistClick
    end
    object btnClose: TDnButton
      Left = 766
      Top = 0
      Width = 44
      Height = 33
      Align = alRight
      Alignment = taCenter
      Caption = ''
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00099900000000
        0999000000009999900000009999900000009999990000099999900000009999
        9990009999999000000009999999099999990000000000999999999999900000
        0000000999999999990000000000000099999999900000000000000009999999
        0000000000000000999999999000000000000009999999999900000000000099
        9999999999900000000009999999099999990000000099999990009999999000
        0000999999000009999990000000999990000000999990000000099900000000
        099900000000}
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      NumGlyphs = 1
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = btnCloseClick
    end
    object btnMinimize: TDnButton
      Left = 722
      Top = 0
      Width = 44
      Height = 33
      Align = alRight
      Alignment = taCenter
      Caption = ''
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      Glyph.Data = {
        42010000424D4201000000000000760000002800000011000000110000000100
        040000000000CC000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000777777777777777770000000FFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFF
        FFFFF0000000FFFFFFFFFFFFFFFFF00000007777777777777777700000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000}
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      NumGlyphs = 1
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShadowColor = clSkyBlue
      ShowHint = True
      Style = bsModern
      Transparent = True
      OnClick = btnMinimizeClick
    end
  end
  object VolumeTimer: TTimer
    Enabled = False
    Interval = 150
    OnTimer = VolumeTick
    Left = 694
    Top = 396
  end
  object StreamTimer: TTimer
    Interval = 500
    OnTimer = StreamTick
    Left = 760
    Top = 396
  end
  object pmPlaylists: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PlaylistPopup
    Left = 530
    Top = 396
  end
  object StreamActionTimer: TTimer
    Enabled = False
    Interval = 25
    OnTimer = StreamActionTick
    Left = 608
    Top = 396
  end
  object SeekHintTimer: TTimer
    Enabled = False
    Interval = 75
    OnTimer = SeekHintTick
    Left = 456
    Top = 396
  end
end
