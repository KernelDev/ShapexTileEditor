unit CellUnit;

interface

uses
  System.Classes, Vcl.Graphics, System.Types, System.SysUtils;

type
  TCell = class(TPersistent)
  private
    FRect: TRect;
    FImage: TPicture;
    FImageScale: Double;
    FImageOffsetX: Integer;
    FImageOffsetY: Integer;
    FVisible: Boolean;
    FOwner: TPersistent;
    procedure SetImage(const Value: TPicture);
    procedure SetRect(const Value: TRect);
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Draw(ACanvas: TCanvas);
    function ContainsPoint(X, Y: Integer): Boolean;
    property Rect: TRect read FRect write SetRect;
    property Image: TPicture read FImage write SetImage;
    property ImageScale: Double read FImageScale write FImageScale;
    property ImageOffsetX: Integer read FImageOffsetX write FImageOffsetX;
    property ImageOffsetY: Integer read FImageOffsetY write FImageOffsetY;
    property Visible: Boolean read FVisible write FVisible;
  end;

implementation

{ TCell }

constructor TCell.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FImage := TPicture.Create;
  FImageScale := 1.0;
  FImageOffsetX := 0;
  FImageOffsetY := 0;
  FVisible := True;
  FRect := Rect(0, 0, 50, 50);
end;

destructor TCell.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TCell.Assign(Source: TPersistent);
var
  SrcCell: TCell;
begin
  if Source is TCell then
  begin
    SrcCell := TCell(Source);
    FRect := SrcCell.FRect;
    FImage.Assign(SrcCell.FImage);
    FImageScale := SrcCell.FImageScale;
    FImageOffsetX := SrcCell.FImageOffsetX;
    FImageOffsetY := SrcCell.FImageOffsetY;
    FVisible := SrcCell.FVisible;
  end
  else
    inherited Assign(Source);
end;

procedure TCell.SetImage(const Value: TPicture);
begin
  FImage.Assign(Value);
end;

procedure TCell.SetRect(const Value: TRect);
begin
  FRect := Value;
end;

function TCell.ContainsPoint(X, Y: Integer): Boolean;
begin
  Result := (X >= FRect.Left) and (X <= FRect.Right) and
            (Y >= FRect.Top) and (Y <= FRect.Bottom);
end;

procedure TCell.Draw(ACanvas: TCanvas);
var
  DestRect: TRect;
  SrcRect: TRect;
  ImgWidth, ImgHeight: Integer;
  DrawLeft, DrawTop, DrawWidth, DrawHeight: Integer;
begin
  if not FVisible then Exit;
  
  // Draw cell border
  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Color := clGray;
  ACanvas.Pen.Width := 1;
  ACanvas.Rectangle(FRect);
  
  // Draw image if exists
  if not FImage.Empty then
  begin
    ImgWidth := FImage.Width;
    ImgHeight := FImage.Height;
    
    // Calculate scaled dimensions
    DrawWidth := Round(ImgWidth * FImageScale);
    DrawHeight := Round(ImgHeight * FImageScale);
    
    // Calculate position with offset
    DrawLeft := FRect.Left + FImageOffsetX;
    DrawTop := FRect.Top + FImageOffsetY;
    
    // Source rectangle
    SrcRect := Rect(0, 0, ImgWidth, ImgHeight);
    
    // Destination rectangle
    DestRect := Rect(DrawLeft, DrawTop, DrawLeft + DrawWidth, DrawTop + DrawHeight);
    
    // Draw the image
    ACanvas.StretchDraw(DestRect, FImage.Graphic);
  end;
end;

end.
