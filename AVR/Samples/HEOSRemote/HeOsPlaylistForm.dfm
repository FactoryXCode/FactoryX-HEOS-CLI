object HEOSPlaylistEditor: THEOSPlaylistEditor
  Left = 0
  Top = 0
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Playlist Composer'
  ClientHeight = 721
  ClientWidth = 1264
  Color = 5850948
  Constraints.MinHeight = 760
  Constraints.MinWidth = 1280
  DefaultMonitor = dmDesktop
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  StyleElements = [seFont, seClient]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object pnlClient: TPanel
    Left = 0
    Top = 143
    Width = 1264
    Height = 549
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object splLeft: TSplitter
      Left = 520
      Top = 0
      Width = 5
      Height = 549
      Color = clGray
      MinSize = 5
      ParentColor = False
      ExplicitHeight = 643
    end
    object pnlLibrary: TPanel
      Left = 0
      Top = 0
      Width = 520
      Height = 549
      Align = alLeft
      TabOrder = 0
      object grdLibrary: TStringGrid
        Left = 1
        Top = 1
        Width = 518
        Height = 547
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alClient
        Color = 5850948
        DefaultRowHeight = 20
        DoubleBuffered = False
        DrawingStyle = gdsGradient
        FixedColor = 5850948
        FixedCols = 0
        RowCount = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        GradientEndColor = clGray
        GradientStartColor = 5850948
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goRowSelect]
        ParentDoubleBuffered = False
        ParentFont = False
        TabOrder = 0
        OnDblClick = grdLibraryDblClick
        OnMouseDown = grdLibraryMouseDown
        OnSelectCell = grdLibrarySelectCell
        OnSetEditText = grdLibrarySetEditText
      end
    end
    object pnlActions: TPanel
      Left = 525
      Top = 0
      Width = 119
      Height = 549
      Align = alLeft
      Color = 5850948
      ParentBackground = False
      TabOrder = 1
      ExplicitLeft = 526
      object btnTagEditor: TDnButton
        Left = 9
        Top = 12
        Width = 100
        Height = 41
        Hint = 'Search for an audiofile.'
        Alignment = taCenter
        Caption = 'Tag Editor'
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
        OnClick = btnTagEditorClick
      end
      object btnAddToPlaylist: TDnButton
        Left = 9
        Top = 73
        Width = 100
        Height = 41
        Hint = 'Add to playlist.'
        Alignment = taCenter
        Caption = 'Add'
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
        OnClick = btnAddToPlaylistClick
      end
      object btnRemoveFromPlaylist: TDnButton
        Left = 9
        Top = 120
        Width = 100
        Height = 41
        Hint = 'Remove from playlist.'
        Alignment = taCenter
        Caption = 'Remove'
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
        OnClick = btnRemoveFromPlaylistClick
      end
      object btnMoveUp: TDnButton
        Left = 9
        Top = 176
        Width = 100
        Height = 41
        Hint = 'Move up.'
        Alignment = taCenter
        Caption = 'Move Up'
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
          00000000000000000000000000000000000000000000FFFFF0000000FFFFF000
          00000FFFFF00000FFFFF0000000000FFFFF000FFFFF000000000000FFFFF0FFF
          FF00000000000000FFFFFFFFF0000000000000000FFFFFFF0000000000000000
          00FFFFF00000000000000000000FFF0000000000000000000000F00000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000}
        GlyphTransparentColor = clBlack
        GlyphTransparent = True
        HotTrackFont.Charset = DEFAULT_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Segoe UI'
        HotTrackFont.Style = []
        Layout = blGlyphTop
        LightColor = 12348265
        NumGlyphs = 1
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShadowColor = clSkyBlue
        ShowHint = True
        Style = bsModern
        Transparent = True
        OnClick = btnMoveUpClick
      end
      object btnMoveDown: TDnButton
        Left = 9
        Top = 222
        Width = 100
        Height = 41
        Hint = 'Move down.'
        Alignment = taCenter
        Caption = 'Move Down'
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
          0000F0000000000000000000000FFF00000000000000000000FFFFF000000000
          000000000FFFFFFF0000000000000000FFFFFFFFF00000000000000FFFFF0FFF
          FF000000000000FFFFF000FFFFF0000000000FFFFF00000FFFFF00000000FFFF
          F0000000FFFFF000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000}
        GlyphTransparentColor = clBlack
        GlyphTransparent = True
        HotTrackFont.Charset = DEFAULT_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Segoe UI'
        HotTrackFont.Style = []
        Layout = blGlyphBottom
        LightColor = 12348265
        NumGlyphs = 1
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShadowColor = clSkyBlue
        ShowHint = True
        Style = bsModern
        Transparent = True
        OnClick = btnMoveDownClick
      end
      object btnScanFolder: TDnButton
        Left = 11
        Top = 298
        Width = 100
        Height = 41
        Hint = 
          'Scan folder inc. subfolders. Note: The database will be preserve' +
          'd, new items will be added.'
        Alignment = taCenter
        Caption = 'Scan Folder...'
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
        OnClick = btnScanFolderClick
      end
      object btnCancelScan: TDnButton
        Left = 11
        Top = 345
        Width = 100
        Height = 41
        Hint = 
          'Scan folder inc. subfolders. Note: The database will be preserve' +
          'd, new items will be added.'
        Alignment = taCenter
        Caption = 'Cancel Scan'
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
        OnClick = btnCancelScanClick
      end
      object btnClearLibrary: TDnButton
        Left = 11
        Top = 401
        Width = 100
        Height = 41
        Hint = 
          'Scan folder inc. subfolders. Note: The database will be preserve' +
          'd, new items will be added.'
        Alignment = taCenter
        Caption = 'Clear Library'
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
        OnClick = btnClearLibraryClick
      end
      object btnClearMissingTracks: TDnButton
        Left = 11
        Top = 448
        Width = 100
        Height = 41
        Hint = 'Clear missing tracks in the database.'
        Alignment = taCenter
        Caption = 'Clear Missing Tracks'
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
        WordWrap = True
        OnClick = btnClearMissingTracksClick
      end
      object btnImportRDJProPlaylist: TDnButton
        Left = 11
        Top = 503
        Width = 100
        Height = 41
        Hint = 'Import a RDJ Pro playlist.'
        Alignment = taCenter
        Caption = ' Import  Playlist'
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
        WordWrap = True
        OnClick = btnImportRDJProPlaylistClick
      end
    end
    object grdPlaylist: TStringGrid
      Left = 644
      Top = 0
      Width = 620
      Height = 549
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Color = 5850948
      DefaultRowHeight = 20
      DrawingStyle = gdsGradient
      FixedColor = 5850948
      FixedCols = 0
      RowCount = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      GradientEndColor = clGray
      GradientStartColor = 5850948
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goRowSelect]
      ParentFont = False
      TabOrder = 2
      OnMouseDown = grdPlaylistMouseDown
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 37
    Width = 1264
    Height = 106
    Align = alTop
    BevelOuter = bvNone
    Color = 5850948
    ParentBackground = False
    TabOrder = 0
    object lblSearch: TLabel
      Left = 15
      Top = 21
      Width = 81
      Height = 21
      Hint = 'Search for a name, title etc.'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Search for:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object Label1: TLabel
      Left = 15
      Top = 71
      Width = 81
      Height = 21
      Hint = 'Search for a name, title etc.'
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'File:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object edtSearch: TEdit
      Left = 102
      Top = 18
      Width = 320
      Height = 27
      Hint = 'Search for a name, title etc.'
      Alignment = taCenter
      AutoSize = False
      Color = 9216
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object pnlPlaylist: TPanel
      Left = 640
      Top = 2
      Width = 622
      Height = 108
      Color = 5850948
      ParentBackground = False
      TabOrder = 1
      object lblPlaylist: TLabel
        Left = 4
        Top = 19
        Width = 62
        Height = 23
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Playlist:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object lblPlayListDuration: TLabel
        Left = 15
        Top = 72
        Width = 123
        Height = 16
        Caption = 'Playlist Duration: 0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clAqua
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object cbPlaylists: TComboBox
        Left = 72
        Top = 19
        Width = 321
        Height = 22
        Hint = 'Select a playlist'
        Style = csOwnerDrawFixed
        Color = 9216
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clAqua
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = cbPlaylistsChange
        OnDblClick = cbPlaylistsDblClick
      end
      object btnNewPlaylist: TDnButton
        Left = 399
        Top = 13
        Width = 100
        Height = 33
        Hint = 'Add a new playlist.'
        Alignment = taCenter
        Caption = 'New'
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
        OnClick = btnNewPlaylistClick
      end
      object btnDeletePlaylist: TDnButton
        Left = 505
        Top = 13
        Width = 100
        Height = 33
        Hint = 'Delete current playlist'
        Alignment = taCenter
        Caption = 'Delete'
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
        OnClick = btnDeletePlaylistClick
      end
    end
    object edFileName: TEdit
      Left = 101
      Top = 68
      Width = 427
      Height = 26
      Hint = 'Search for an audiofile'
      Alignment = taCenter
      AutoSize = False
      Color = 9216
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 2
      OnMouseDown = edFileNameMouseDown
    end
    object btnSearch: TDnButton
      Left = 428
      Top = 15
      Width = 100
      Height = 33
      Hint = 'Search in the database for an artist, title etc.'
      Alignment = taCenter
      Caption = 'Search'
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
      OnClick = btnSearchClick
    end
    object btnClearSearch: TDnButton
      Left = 534
      Top = 15
      Width = 100
      Height = 33
      Hint = 'Settings'
      Alignment = taCenter
      Caption = 'Clear'
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
      OnClick = btnClearSearchClick
    end
    object btnOpenFile: TDnButton
      Left = 534
      Top = 64
      Width = 100
      Height = 33
      Hint = 'Search for an audiofile.'
      Alignment = taCenter
      Caption = 'Open File'
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
      OnClick = btnOpenFileClick
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 692
    Width = 1264
    Height = 29
    Align = alBottom
    BevelOuter = bvLowered
    Color = 5850948
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clAqua
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    object lblStatus: TLabel
      Left = 8
      Top = 7
      Width = 35
      Height = 16
      Caption = 'Ready'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAqua
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlCaption: TPanel
    Left = 0
    Top = 0
    Width = 1264
    Height = 37
    Align = alTop
    Color = 4865081
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
    OnMouseDown = pnlCaptionMouseDown
    object lblCaption: TLabel
      Left = 8
      Top = 11
      Width = 114
      Height = 16
      Hint = 'Channel number'
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Playlist Composer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Layout = tlCenter
      OnMouseDown = pnlCaptionMouseDown
    end
    object btnExit: TDnButton
      Left = 1216
      Top = 1
      Width = 47
      Height = 35
      Hint = 'Close'
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
      OnClick = btnExitClick
    end
    object btnMinimize: TDnButton
      Left = 1122
      Top = 1
      Width = 47
      Height = 35
      Hint = 'Minimize'
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
    object btnMaxNormal: TDnButton
      Left = 1169
      Top = 1
      Width = 47
      Height = 35
      Hint = 'Maximize/Normal'
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
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000FFFFFFFFFFF
        FFFF00000000FFFFFFFFFFFFFFFFF0000000FF8888888888888FF0000000FF80
        00000000008FF0000000FF8000000000008FF0000000FF8000000000008FF000
        0000FF8000000000008FF0000000FF8000000000008FF0000000FF8000000000
        008FF0000000FF8000000000008FF0000000FF8000000000008FF0000000FF80
        00000000008FF0000000FF8000000000008FF0000000FF8000000000008FF000
        0000FF8888888888888FF0000000FFFFFFFFFFFFFFFFF00000000FFFFFFFFFFF
        FFFF00000000}
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
      OnClick = btnMaxNormalClick
    end
  end
  object dlgImportRDJProPlaylist: TOpenDialog
    DefaultExt = 'db'
    Filter = 'RDJ Pro database (*.db;*.sqlite;*.sqlite3)|*.db;*.sqlite;*.sqlite3|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = 'Select the RDJ Pro playlist database (RDJLibrary.db)'
    Left = 1120
    Top = 624
  end
  object pmImportRDJProPlaylist: TPopupMenu
    AutoHotkeys = maManual
    Left = 1160
    Top = 624
  end
end
