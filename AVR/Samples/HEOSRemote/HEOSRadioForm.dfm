object HEOSRadioForm: THEOSRadioForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  ClientHeight = 706
  ClientWidth = 812
  Color = 4865081
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  PrintScale = poNone
  Scaled = False
  OnClose = RadioClose
  OnCloseQuery = RadioCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object lblStatus: TLabel
    Left = 0
    Top = 674
    Width = 812
    Height = 32
    Align = alBottom
    Alignment = taCenter
    AutoSize = False
    Caption = 'Ready.'
    Color = 1254145
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 9889633
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
    ExplicitTop = 683
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 812
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Color = 4865081
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = pnlTopMouseDown
    object Label1: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 285
      Height = 27
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = 'HEOS Remote 1.1.11 - Internet Radio'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnMouseDown = Label1MouseDown
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 33
    end
    object btnClose: TDnButton
      Left = 768
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
      Left = 724
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
  object pnlCustomStation: TPanel
    Left = 0
    Top = 33
    Width = 812
    Height = 222
    Align = alTop
    BevelOuter = bvNone
    Color = 4865081
    ParentBackground = False
    TabOrder = 2
    TabStop = True
    object Bevel2: TBevel
      Left = 680
      Top = 54
      Width = 121
      Height = 145
    end
    object Bevel1: TBevel
      Left = 3
      Top = 47
      Width = 804
      Height = 158
      Hint = 
        'Enter a Name and direct audio stream URL, then click Add station' +
        '.'
      ParentShowHint = False
      ShowHint = True
    end
    object lblStationName: TLabel
      Left = 6
      Top = 90
      Width = 60
      Height = 17
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Name'
    end
    object lblStationUrl: TLabel
      Left = 6
      Top = 126
      Width = 60
      Height = 17
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'URL'
    end
    object lblService: TLabel
      Left = 6
      Top = 16
      Width = 60
      Height = 17
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Service'
    end
    object lblStationFeedback: TLabel
      Left = 14
      Top = 57
      Width = 639
      Height = 22
      AutoSize = False
      Caption = 
        'Enter a Name and direct audio stream URL, then click Add station' +
        '.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      WordWrap = True
    end
    object lblLogo: TLabel
      Left = 6
      Top = 164
      Width = 60
      Height = 17
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Logo'
    end
    object edStationName: TEdit
      Left = 72
      Top = 87
      Width = 475
      Height = 25
      Hint = 'Station name'
      BevelInner = bvNone
      BevelKind = bkSoft
      BorderStyle = bsNone
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      MaxLength = 128
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      TextHint = 'Station name'
    end
    object edStationUrl: TEdit
      Left = 72
      Top = 123
      Width = 475
      Height = 25
      Hint = 'http://host:port/stream (direct audio URL)'
      BevelInner = bvNone
      BevelKind = bkSoft
      BorderStyle = bsNone
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      MaxLength = 4096
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      TextHint = 'http://host:port/stream (direct audio URL)'
    end
    object btnAddStation: TDnButton
      Left = 691
      Top = 98
      Width = 100
      Height = 31
      Alignment = taCenter
      Caption = 'Add station'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      WordWrap = True
      OnClick = AddStationClick
    end
    object btnRemoveStation: TDnButton
      Left = 691
      Top = 61
      Width = 100
      Height = 31
      Alignment = taCenter
      Caption = 'Remove station'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      WordWrap = True
      OnClick = RemoveStationClick
    end
    object cbService: TComboBox
      Left = 72
      Top = 13
      Width = 475
      Height = 25
      BevelInner = bvNone
      Style = csDropDownList
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = SourceChange
    end
    object btnRefresh: TDnButton
      Left = 553
      Top = 11
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Refresh services'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = RefreshClick
    end
    object edLogoUrl: TEdit
      Left = 72
      Top = 161
      Width = 475
      Height = 25
      Hint = 'Logo path'
      BevelInner = bvNone
      BevelKind = bkSoft
      BorderStyle = bsNone
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      MaxLength = 4096
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      TextHint = 'Logo path or image URL'
      OnExit = LogoUrlExit
      OnKeyDown = LogoUrlKeyDown
    end
    object btnAddLogoPath: TDnButton
      Left = 553
      Top = 161
      Width = 100
      Height = 26
      Alignment = taCenter
      Caption = 'Logo'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      WordWrap = True
      OnClick = StationLogoFileClick
    end
  end
  object pnlBrowse: TPanel
    Left = 0
    Top = 255
    Width = 812
    Height = 419
    Align = alClient
    BevelOuter = bvNone
    Color = 4865081
    ParentBackground = False
    TabOrder = 1
    TabStop = True
    object imgStationArtwork: TImage
      Left = 558
      Top = 99
      Width = 248
      Height = 192
      ParentCustomHint = False
      Center = True
      ParentShowHint = False
      Proportional = True
      ShowHint = False
    end
    object lblLocation: TLabel
      Left = 12
      Top = 317
      Width = 537
      Height = 17
      AutoSize = False
      Caption = '-'
    end
    object lblArtworkStatus: TLabel
      Left = 555
      Top = 47
      Width = 252
      Height = 46
      Alignment = taCenter
      AutoSize = False
      Caption = 'Station logo'
      WordWrap = True
    end
    object lblSelectedStation: TLabel
      Left = 555
      Top = 310
      Width = 252
      Height = 73
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object lblPlaying: TLabel
      Left = 0
      Top = 397
      Width = 812
      Height = 22
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Caption = 'No radio station started.'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 11
      ExplicitTop = 389
      ExplicitWidth = 780
    end
    object Bevel3: TBevel
      Left = 6
      Top = 331
      Width = 543
      Height = 52
    end
    object lvStations: TListView
      Left = 6
      Top = 47
      Width = 543
      Height = 294
      Color = 4865081
      Columns = <
        item
          Caption = 'Station / category'
          Width = 440
        end
        item
          Caption = 'Type'
          Width = 140
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      PopupMenu = pmStations
      TabOrder = 3
      ViewStyle = vsReport
      OnContextPopup = StationContextPopup
      OnDblClick = OpenItem
      OnSelectItem = SelectionChange
    end
    object btnHome: TDnButton
      Left = 14
      Top = 347
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Home'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = NavigationClick
    end
    object btnBack: TDnButton
      Left = 120
      Top = 347
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Back'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = NavigationClick
    end
    object btnPreviousPage: TDnButton
      Left = 226
      Top = 347
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Previous page'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = NavigationClick
    end
    object btnNextPage: TDnButton
      Left = 332
      Top = 347
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Next page'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = NavigationClick
    end
    object cbCriteria: TComboBox
      Left = 6
      Top = 9
      Width = 166
      Height = 25
      BevelInner = bvNone
      Style = csDropDownList
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edSearch: TEdit
      Left = 178
      Top = 9
      Width = 369
      Height = 25
      BevelInner = bvNone
      BevelKind = bkSoft
      BorderStyle = bsNone
      Color = 4865081
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      MaxLength = 128
      ParentFont = False
      TabOrder = 1
    end
    object btnSearch: TDnButton
      Left = 555
      Top = 5
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Search'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
      Behavior = bbPushButton
      TabStop = True
      ShowFocusRect = False
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = SearchClick
    end
    object chkPlayStation: TDnButton
      Left = 438
      Top = 347
      Width = 100
      Height = 30
      Alignment = taCenter
      Caption = 'Play station'
      Color = 5914932
      ColorWhenDown = 11363625
      ColorWhenUp = 5914932
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
        A6000042C6000018630000186B0000187300002173000029940000319C000029
        A5000031AD000042BD000042C6000039CE000042CE000042DE00004ADE000052
        DE00005ADE000063DE00004AE7000052E700005AEF000063EF000073EF000073
        F700007BF7000084F7000094FF00009CFF0000A5FF0000ADFF0000B5FF0000C6
        FF0000CEFF0000DEFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
        0000000000000000100A191F1F1A0A100000000F131B202323201B130F000013
        1A2225272725221A1300001920242829292824201900001E2226292B2B292622
        1E00001E2226292B2B2926221E0000192024282929282420190000131A222527
        2725221A1300000F131B202323201B130F000000100A191F1F190A1000000000
        00000000000000000000}
      TabStop = True
      ShowFocusRect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      GlyphTransparentColor = clBlack
      GlyphTransparent = True
      HotTrackColor = clHighlightText
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWhite
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Segoe UI'
      HotTrackFont.Style = []
      LightColor = 12348265
      ParentColor = False
      ParentFont = False
      ShadowColor = clSkyBlue
      Style = bsModern
      OnClick = PlayStationClick
    end
  end
  object pmStations: TPopupMenu
    OnPopup = StationPopup
    Left = 742
    Top = 268
    object miRemoveStation: TMenuItem
      Caption = 'Remove custom station'
      OnClick = RemoveStationClick
    end
    object miStationLogoFile: TMenuItem
      Caption = 'Choose station logo...'
      OnClick = StationLogoFileClick
    end
    object miStationLogo: TMenuItem
      Caption = 'Station logo URL...'
      OnClick = StationLogoClick
    end
  end
  object PollTimer: TTimer
    Interval = 100
    OnTimer = PollTick
    Left = 500
    Top = 546
  end
end
