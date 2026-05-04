unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Generics.Collections,
  CellUnit, System.Types, Vcl.Grids, System.Math;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnLoadFilter: TButton;
    btnLoadImage: TButton;
    btnBatchLoad: TButton;
    btnMergeRow: TButton;
    btnMergeColumn: TButton;
    btnSplit: TButton;
    edtCellSize: TEdit;
    Label1: TLabel;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    chkUseFilter: TCheckBox;
    Label2: TLabel;
    edtScale: TEdit;
    btnApplyScale: TButton;
    btnSave: TButton;
    btnLoadProject: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadFilterClick(Sender: TObject);
    procedure btnLoadImageClick(Sender: TObject);
    procedure btnBatchLoadClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnMergeRowClick(Sender: TObject);
    procedure btnMergeColumnClick(Sender: TObject);
    procedure btnSplitClick(Sender: TObject);
    procedure btnApplyScaleClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadProjectClick(Sender: TObject);
  private
    FFilterBitmap: TBitmap;
    FCells: TObjectList<TCell>;
    FSelectedCell: TCell;
    FDraggedCell: TCell;
    FDragging: Boolean;
    FDragStartX, FDragStartY: Integer;
    FCellSize: Integer;
    FCurrentImage: TPicture;
    FImagesToBatch: TStringList;
    FBatchIndex: Integer;
    FLastMouseX, FLastMouseY: Integer;
    procedure CreateGrid;
    function IsCellVisibleThroughFilter(const ARect: TRect): Boolean;
    procedure UpdateCellPositions;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize on form create
  PaintBox1.Width := 1500;
  PaintBox1.Height := 1000;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFilterBitmap := TBitmap.Create;
  FCells := TObjectList<TCell>.Create;
  FCurrentImage := TPicture.Create;
  FImagesToBatch := TStringList.Create;
  FCellSize := 50;
  FDragging := False;
  FSelectedCell := nil;
  FDraggedCell := nil;
end;

destructor TForm1.Destroy;
begin
  FImagesToBatch.Free;
  FCurrentImage.Free;
  FCells.Free;
  FFilterBitmap.Free;
  inherited Destroy;
end;

procedure TForm1.CreateGrid;
var
  X, Y, Col, Row: Integer;
  Cell: TCell;
  CellRect: TRect;
begin
  FCells.Clear;
  
  FCellSize := StrToIntDef(edtCellSize.Text, 50);
  
  for Y := 0 to (PaintBox1.Height div FCellSize) do
  begin
    for X := 0 to (PaintBox1.Width div FCellSize) do
    begin
      CellRect := System.Types.Rect(X * FCellSize, Y * FCellSize, 
                       (X + 1) * FCellSize, (Y + 1) * FCellSize);
      
      // Check if cell is visible through filter
      if chkUseFilter.Checked and (FFilterBitmap.Width > 0) then
      begin
        if not IsCellVisibleThroughFilter(CellRect) then
          Continue;
      end;
      
      Cell := TCell.Create(FCells);
      Cell.Rect := CellRect;
      Cell.Visible := True;
      FCells.Add(Cell);
    end;
  end;
  
  PaintBox1.Repaint;
end;

function TForm1.IsCellVisibleThroughFilter(const ARect: TRect): Boolean;
var
  X, Y: Integer;
  PixelColor: TColor;
  GrayValue: Integer;
  VisibleCount, TotalCount: Integer;
begin
  if (FFilterBitmap.Width = 0) or (FFilterBitmap.Height = 0) then
  begin
    Result := True;
    Exit;
  end;
  
  VisibleCount := 0;
  TotalCount := 0;
  
  // Sample points in the cell to determine visibility
  for Y := ARect.Top to ARect.Bottom - 1 do
  begin
    for X := ARect.Left to ARect.Right - 1 do
    begin
      if (X < FFilterBitmap.Width) and (Y < FFilterBitmap.Height) then
      begin
        PixelColor := FFilterBitmap.Canvas.Pixels[X, Y];
        GrayValue := (GetRValue(PixelColor) + GetGValue(PixelColor) + GetBValue(PixelColor)) div 3;
        
        // Black (0) passes, white (255) blocks
        // We consider a cell visible if enough of it is black/dark
        if GrayValue < 128 then
          Inc(VisibleCount);
        Inc(TotalCount);
      end;
    end;
  end;
  
  // Cell is visible if more than 10% of it passes through filter
  if TotalCount > 0 then
    Result := (VisibleCount / TotalCount) > 0.1
  else
    Result := True;
end;

procedure TForm1.UpdateCellPositions;
var
  I: Integer;
begin
  // Recalculate all cell positions based on grid
  // This is called after merge/split operations
  PaintBox1.Repaint;
end;

procedure TForm1.btnLoadFilterClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FFilterBitmap.LoadFromFile(OpenDialog1.FileName);
    ShowMessage('Фильтр загружен. Черные области пропускают ячейки, белые - блокируют.');
    CreateGrid;
  end;
end;

procedure TForm1.btnLoadImageClick(Sender: TObject);
begin
  if OpenDialog2.Execute then
  begin
    FCurrentImage.LoadFromFile(OpenDialog2.FileName);
    ShowMessage('Изображение загружено. Кликните на ячейку чтобы установить изображение.');
  end;
end;

procedure TForm1.btnBatchLoadClick(Sender: TObject);
var
  I: Integer;
begin
  if OpenDialog2.Execute then
  begin
    FImagesToBatch.Clear;
    // Add selected file
    FImagesToBatch.Add(OpenDialog2.FileName);
    
    // Allow multiple selection
    for I := 0 to OpenDialog2.Files.Count - 1 do
    begin
      FImagesToBatch.Add(OpenDialog2.Files[I]);
    end;
    
    FBatchIndex := 0;
    ShowMessage(Format('Загружено %d изображений для замощения.', [FImagesToBatch.Count]));
    
    // Auto-fill cells with images
    if FCells.Count > 0 then
    begin
      for I := 0 to System.Math.Min(FCells.Count - 1, FImagesToBatch.Count - 1) do
      begin
        FCells[I].Image.LoadFromFile(FImagesToBatch[I]);
      end;
      PaintBox1.Repaint;
    end;
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  I: Integer;
begin
  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);
  
  // Draw filter overlay if loaded (semi-transparent)
  if (FFilterBitmap.Width > 0) and chkUseFilter.Checked then
  begin
    PaintBox1.Canvas.Draw(0, 0, FFilterBitmap);
  end;
  
  // Draw all cells
  for I := 0 to FCells.Count - 1 do
  begin
    FCells[I].Draw(PaintBox1.Canvas);
  end;
  
  // Highlight selected cell
  if Assigned(FSelectedCell) then
  begin
    PaintBox1.Canvas.Brush.Style := bsClear;
    PaintBox1.Canvas.Pen.Color := clRed;
    PaintBox1.Canvas.Pen.Width := 2;
    PaintBox1.Canvas.Rectangle(FSelectedCell.Rect);
  end;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  FLastMouseX := X;
  FLastMouseY := Y;
  
  if Button = mbLeft then
  begin
    // Find clicked cell
    for I := FCells.Count - 1 downto 0 do
    begin
      if FCells[I].ContainsPoint(X, Y) then
      begin
        FSelectedCell := FCells[I];
        FDraggedCell := FCells[I];
        FDragging := True;
        FDragStartX := X - FSelectedCell.Rect.Left;
        FDragStartY := Y - FSelectedCell.Rect.Top;
        PaintBox1.Repaint;
        Break;
      end;
    end;
    
    // If no cell clicked but we have current image, set it to new cell position
    if (not Assigned(FSelectedCell)) and (Assigned(FCurrentImage) and (FCurrentImage.Graphic <> nil)) then
    begin
      // Create new cell at click position
      FSelectedCell := TCell.Create(FCells);
      FSelectedCell.Rect := System.Types.Rect(X, Y, X + FCellSize, Y + FCellSize);
      FSelectedCell.Image.Assign(FCurrentImage);
      FCells.Add(FSelectedCell);
      FDraggedCell := FSelectedCell;
      FDragging := True;
      FDragStartX := X - FSelectedCell.Rect.Left;
      FDragStartY := Y - FSelectedCell.Rect.Top;
      PaintBox1.Repaint;
    end;
  end;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  DX, DY: Integer;
begin
  if FDragging and Assigned(FDraggedCell) then
  begin
    DX := X - FLastMouseX;
    DY := Y - FLastMouseY;
    
    // Move the cell
    FDraggedCell.Rect := System.Types.Rect(
      FDraggedCell.Rect.Left + DX,
      FDraggedCell.Rect.Top + DY,
      FDraggedCell.Rect.Right + DX,
      FDraggedCell.Rect.Bottom + DY
    );
    
    FLastMouseX := X;
    FLastMouseY := Y;
    
    PaintBox1.Repaint;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  FDraggedCell := nil;
end;

procedure TForm1.btnMergeRowClick(Sender: TObject);
var
  I, J: Integer;
  MergedRect: TRect;
  CellsToRemove: TList<Integer>;
begin
  if not Assigned(FSelectedCell) then
  begin
    ShowMessage('Выберите ячейку для объединения с соседями в строке.');
    Exit;
  end;
  
  CellsToRemove := TList<Integer>.Create;
  try
    MergedRect := FSelectedCell.Rect;
    
    // Find all cells in the same row (similar Y position)
    for I := 0 to FCells.Count - 1 do
    begin
      if (I <> FCells.IndexOf(FSelectedCell)) and
         (Abs(FCells[I].Rect.Top - FSelectedCell.Rect.Top) < FCellSize div 2) then
      begin
        // Check if adjacent horizontally
        if (Abs(FCells[I].Rect.Left - FSelectedCell.Rect.Right) < FCellSize div 2) or
           (Abs(FCells[I].Rect.Right - FSelectedCell.Rect.Left) < FCellSize div 2) then
        begin
          // Expand merged rect
          if FCells[I].Rect.Left < MergedRect.Left then
            MergedRect.Left := FCells[I].Rect.Left;
          if FCells[I].Rect.Right > MergedRect.Right then
            MergedRect.Right := FCells[I].Rect.Right;
          
          // Copy image if target cell doesn't have one
          if (FSelectedCell.Image.Graphic = nil) and (FCells[I].Image.Graphic <> nil) then
            FSelectedCell.Image.Assign(FCells[I].Image);
          
          CellsToRemove.Add(I);
        end;
      end;
    end;
    
    // Update selected cell rect
    FSelectedCell.Rect := MergedRect;
    
    // Remove merged cells (in reverse order)
    for I := CellsToRemove.Count - 1 downto 0 do
    begin
      FCells.Delete(CellsToRemove[I]);
    end;
    
    PaintBox1.Repaint;
    ShowMessage('Ячейки объединены по строке.');
  finally
    CellsToRemove.Free;
  end;
end;

procedure TForm1.btnMergeColumnClick(Sender: TObject);
var
  I, J: Integer;
  MergedRect: TRect;
  CellsToRemove: TList<Integer>;
begin
  if not Assigned(FSelectedCell) then
  begin
    ShowMessage('Выберите ячейку для объединения с соседями в столбце.');
    Exit;
  end;
  
  CellsToRemove := TList<Integer>.Create;
  try
    MergedRect := FSelectedCell.Rect;
    
    // Find all cells in the same column (similar X position)
    for I := 0 to FCells.Count - 1 do
    begin
      if (I <> FCells.IndexOf(FSelectedCell)) and
         (Abs(FCells[I].Rect.Left - FSelectedCell.Rect.Left) < FCellSize div 2) then
      begin
        // Check if adjacent vertically
        if (Abs(FCells[I].Rect.Top - FSelectedCell.Rect.Bottom) < FCellSize div 2) or
           (Abs(FCells[I].Rect.Bottom - FSelectedCell.Rect.Top) < FCellSize div 2) then
        begin
          // Expand merged rect
          if FCells[I].Rect.Top < MergedRect.Top then
            MergedRect.Top := FCells[I].Rect.Top;
          if FCells[I].Rect.Bottom > MergedRect.Bottom then
            MergedRect.Bottom := FCells[I].Rect.Bottom;
          
          // Copy image if target cell doesn't have one
          if (FSelectedCell.Image.Graphic = nil) and (FCells[I].Image.Graphic <> nil) then
            FSelectedCell.Image.Assign(FCells[I].Image);
          
          CellsToRemove.Add(I);
        end;
      end;
    end;
    
    // Update selected cell rect
    FSelectedCell.Rect := MergedRect;
    
    // Remove merged cells (in reverse order)
    for I := CellsToRemove.Count - 1 downto 0 do
    begin
      FCells.Delete(CellsToRemove[I]);
    end;
    
    PaintBox1.Repaint;
    ShowMessage('Ячейки объединены по столбцу.');
  finally
    CellsToRemove.Free;
  end;
end;

procedure TForm1.btnSplitClick(Sender: TObject);
var
  NewCell: TCell;
  HalfWidth, HalfHeight: Integer;
begin
  if not Assigned(FSelectedCell) then
  begin
    ShowMessage('Выберите ячейку для разделения.');
    Exit;
  end;
  
  // Split into 4 smaller cells
  HalfWidth := FSelectedCell.Rect.Width div 2;
  HalfHeight := FSelectedCell.Rect.Height div 2;
  
  // Create 3 new cells (keeping original as first quadrant)
  NewCell := TCell.Create(FCells);
  NewCell.Rect := System.Types.Rect(
    FSelectedCell.Rect.Left + HalfWidth,
    FSelectedCell.Rect.Top,
    FSelectedCell.Rect.Right,
    FSelectedCell.Rect.Top + HalfHeight
  );
  NewCell.Image.Assign(FSelectedCell.Image);
  FCells.Add(NewCell);
  
  NewCell := TCell.Create(FCells);
  NewCell.Rect := System.Types.Rect(
    FSelectedCell.Rect.Left,
    FSelectedCell.Rect.Top + HalfHeight,
    FSelectedCell.Rect.Left + HalfWidth,
    FSelectedCell.Rect.Bottom
  );
  NewCell.Image.Assign(FSelectedCell.Image);
  FCells.Add(NewCell);
  
  NewCell := TCell.Create(FCells);
  NewCell.Rect := System.Types.Rect(
    FSelectedCell.Rect.Left + HalfWidth,
    FSelectedCell.Rect.Top + HalfHeight,
    FSelectedCell.Rect.Right,
    FSelectedCell.Rect.Bottom
  );
  NewCell.Image.Assign(FSelectedCell.Image);
  FCells.Add(NewCell);
  
  // Resize original
  FSelectedCell.Rect := System.Types.Rect(
    FSelectedCell.Rect.Left,
    FSelectedCell.Rect.Top,
    FSelectedCell.Rect.Left + HalfWidth,
    FSelectedCell.Rect.Top + HalfHeight
  );
  
  PaintBox1.Repaint;
  ShowMessage('Ячейка разделена на 4 части.');
end;

procedure TForm1.btnApplyScaleClick(Sender: TObject);
var
  Scale: Double;
begin
  if not Assigned(FSelectedCell) then
  begin
    ShowMessage('Выберите ячейку для масштабирования изображения.');
    Exit;
  end;
  
  Scale := StrToFloatDef(edtScale.Text, 1.0);
  FSelectedCell.ImageScale := Scale;
  PaintBox1.Repaint;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  FileStream: TFileStream;
  I: Integer;
  CellData: record
    Left, Top, Right, Bottom: Integer;
    ImageScale: Double;
    OffsetX, OffsetY: Integer;
    HasImage: Boolean;
  end;
begin
  if SaveDialog1.Execute then
  begin
    FileStream := TFileStream.Create(SaveDialog1.FileName, fmCreate);
    try
      // Save cell count
      FileStream.WriteBuffer(FCells.Count, SizeOf(Integer));
      
      // Save each cell
      for I := 0 to FCells.Count - 1 do
      begin
        // Save rect
        CellData.Left := FCells[I].Rect.Left;
        CellData.Top := FCells[I].Rect.Top;
        CellData.Right := FCells[I].Rect.Right;
        CellData.Bottom := FCells[I].Rect.Bottom;
        CellData.ImageScale := FCells[I].ImageScale;
        CellData.OffsetX := FCells[I].ImageOffsetX;
        CellData.OffsetY := FCells[I].ImageOffsetY;
        CellData.HasImage := (FCells[I].Image.Graphic <> nil);
        
        FileStream.WriteBuffer(CellData, SizeOf(CellData));
        
        // Save image if exists
        if CellData.HasImage then
        begin
          FCells[I].Image.SaveToStream(FileStream);
        end;
      end;
      
      ShowMessage('Проект сохранен.');
    finally
      FileStream.Free;
    end;
  end;
end;

procedure TForm1.btnLoadProjectClick(Sender: TObject);
var
  FileStream: TFileStream;
  CellCount, I: Integer;
  CellData: record
    Left, Top, Right, Bottom: Integer;
    ImageScale: Double;
    OffsetX, OffsetY: Integer;
    HasImage: Boolean;
  end;
  Cell: TCell;
begin
  if OpenDialog1.Execute then
  begin
    FCells.Clear;
    
    FileStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
    try
      // Read cell count
      FileStream.ReadBuffer(CellCount, SizeOf(Integer));
      
      // Read each cell
      for I := 0 to CellCount - 1 do
      begin
        Cell := TCell.Create(FCells);
        
        FileStream.ReadBuffer(CellData, SizeOf(CellData));
        
        Cell.Rect := System.Types.Rect(CellData.Left, CellData.Top, CellData.Right, CellData.Bottom);
        Cell.ImageScale := CellData.ImageScale;
        Cell.ImageOffsetX := CellData.OffsetX;
        Cell.ImageOffsetY := CellData.OffsetY;
        
        if CellData.HasImage then
        begin
          Cell.Image.LoadFromStream(FileStream);
        end;
        
        FCells.Add(Cell);
      end;
      
      PaintBox1.Repaint;
      ShowMessage('Проект загружен.');
    finally
      FileStream.Free;
    end;
  end;
end;

end.
