object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Honeycomb Image App'
  ClientHeight = 700
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 700
    Align = alLeft
    TabOrder = 0
    object btnLoadFilter: TButton
      Left = 10
      Top = 10
      Width = 180
      Height = 30
      Caption = 'Load Filter'
      TabOrder = 0
      OnClick = btnLoadFilterClick
    end
    object btnLoadImage: TButton
      Left = 10
      Top = 50
      Width = 180
      Height = 30
      Caption = 'Load Image'
      TabOrder = 1
      OnClick = btnLoadImageClick
    end
    object btnBatchLoad: TButton
      Left = 10
      Top = 90
      Width = 180
      Height = 30
      Caption = 'Batch Load'
      TabOrder = 2
      OnClick = btnBatchLoadClick
    end
    object Label1: TLabel
      Left = 10
      Top = 140
      Width = 60
      Height = 15
      Caption = 'Cell Size:'
    end
    object edtCellSize: TEdit
      Left = 10
      Top = 160
      Width = 100
      Height = 23
      TabOrder = 3
      Text = '50'
    end
    object chkUseFilter: TCheckBox
      Left = 10
      Top = 200
      Width = 150
      Height = 20
      Caption = 'Use Filter'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object btnMergeRow: TButton
      Left = 10
      Top = 240
      Width = 180
      Height = 30
      Caption = 'Merge Rows'
      TabOrder = 5
      OnClick = btnMergeRowClick
    end
    object btnMergeColumn: TButton
      Left = 10
      Top = 280
      Width = 180
      Height = 30
      Caption = 'Merge Columns'
      TabOrder = 6
      OnClick = btnMergeColumnClick
    end
    object btnSplit: TButton
      Left = 10
      Top = 320
      Width = 180
      Height = 30
      Caption = 'Split Cell'
      TabOrder = 7
      OnClick = btnSplitClick
    end
    object Label2: TLabel
      Left = 10
      Top = 370
      Width = 80
      Height = 15
      Caption = 'Image Scale:'
    end
    object edtScale: TEdit
      Left = 10
      Top = 390
      Width = 100
      Height = 23
      TabOrder = 8
      Text = '1.0'
    end
    object btnApplyScale: TButton
      Left = 10
      Top = 420
      Width = 180
      Height = 30
      Caption = 'Apply Scale'
      TabOrder = 9
      OnClick = btnApplyScaleClick
    end
    object btnSave: TButton
      Left = 10
      Top = 470
      Width = 180
      Height = 30
      Caption = 'Save Project'
      TabOrder = 10
      OnClick = btnSaveClick
    end
    object btnLoadProject: TButton
      Left = 10
      Top = 510
      Width = 180
      Height = 30
      Caption = 'Load Project'
      TabOrder = 11
      OnClick = btnLoadProjectClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 200
    Top = 0
    Width = 800
    Height = 700
    Align = alClient
    TabOrder = 1
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 1500
      Height = 1000
      Align = alClient
      OnMouseDown = PaintBox1MouseDown
      OnMouseMove = PaintBox1MouseMove
      OnMouseUp = PaintBox1MouseUp
      OnPaint = PaintBox1Paint
      ExplicitLeft = 64
      ExplicitTop = 48
      ExplicitWidth = 105
      ExplicitHeight = 65
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Bitmap Files|*.bmp;*.png;*.jpg;*.jpeg|All Files|*.*'
    Left = 240
    Top = 80
  end
  object OpenDialog2: TOpenDialog
    Filter = 'Image Files|*.bmp;*.png;*.jpg;*.jpeg|All Files|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 240
    Top = 120
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Project Files|*.hcp|All Files|*.*'
    Left = 240
    Top = 160
  end
end
