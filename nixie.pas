unit nixie; 

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, Classes, SysUtils, Controls, ExtCtrls, Graphics, types, GraphType;

type

{ TNixieDisplay }

TNixieStyle = (NsTube, NsRound, NsHalfTube);
TNixieDisplay = class(TGraphicControl)
private
  FValue:integer;
  FDigits:integer;
  FStyle:TNixieStyle;
  FLeadingZero:boolean;
  procedure SetValue(NewValue:integer);
  procedure SetDigits(NewValue:integer);
  procedure SetLeadingZero(NewValue:boolean);
  procedure SetStyle(NewValue:TNixieStyle);
  function FirstDigitRect:TRect;
protected
  class function GetControlClassDefaultSize: TSize; override;
  procedure Paint;override;
  procedure SetColor(NewColor: TColor); override;
public
  constructor create(TheOwner:TComponent);override;
published
  property Value:integer read FValue write SetValue default 0;
  property Digits:integer read FDigits write SetDigits default 5;
  property LeadingZero:boolean read FLeadingZero write SetLeadingZero default false;
  property Style:TNixieStyle read FStyle write SetStyle default NsTube;
  property Align;
  property Anchors;
  property AutoSize;
  property BorderSpacing;
  property Color;
  property Constraints;
  property DragCursor;
  property DragKind;
  property DragMode;
  property ParentColor;
  property ParentShowHint;
  property PopupMenu;
  property ShowHint;
  property Visible;
  property OnChangeBounds;
  property OnClick;
  property OnContextPopup;
  property OnDblClick;
  property OnDragDrop;
  property OnDragOver;
  property OnEndDrag;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
  property OnMouseWheel;
  property OnMouseWheelDown;
  property OnMouseWheelUp;
  property OnResize;
  property OnStartDrag;
end;

procedure Register;

implementation

var
    FNixiePictures:array[TNixieStyle,0..11] of TPortableNetworkGraphic;

procedure LoadPictures;
const n:array[TNixieStyle] of string = ('tube','round','halftube');
var s:TNixieStyle;
    i:integer;
    r:TResourceStream;
begin
  for s:=low(s) to high(s) do
    for i:=0 to 11 do
    begin
      r:=TResourceStream.Create(HINSTANCE, n[s]+inttostr(i), RT_RCDATA);
      FNixiePictures[s,i]:=TPortableNetworkGraphic.Create;
      FNixiePictures[s,i].LoadFromStream(r);
      r.free;
    end;
end;

procedure FreePictures;
var i:integer;
    s:TNixieStyle;
begin
  for s:=low(s) to high(s) do
    for i:=0 to 11 do
      FNixiePictures[s,i].free;
end;


{ TNixieDisplay }

procedure TNixieDisplay.SetValue(NewValue: integer);
begin
  if NewValue<>FValue then
  begin
    FValue:=NewValue;
    invalidate;
  end;
end;

procedure TNixieDisplay.SetDigits(NewValue: integer);
begin
  if NewValue<>FDigits then
  begin
    FDigits:=NewValue;
    Invalidate;
  end;
end;

procedure TNixieDisplay.SetLeadingZero(NewValue: boolean);
begin
  if NewValue<>FLeadingZero then
  begin
    FLeadingZero:=NewValue;
    Invalidate;
  end;
end;

procedure TNixieDisplay.SetStyle(NewValue: TNixieStyle);
begin
  if NewValue<>FStyle then
  begin
    FStyle:=NewValue;
    Invalidate;
  end;
end;

procedure TNixieDisplay.Paint;
var i:integer;
    locvalue:integer;
    r:trect;
    locdigits:array of integer;
    locnumdigits:integer;
begin
    setlength(locdigits,FDigits);
    if FValue<0 then
    begin
      locvalue:=-FValue;
      locnumdigits:=FDigits-1;
    end else
    begin
      locvalue:=FValue;
      locnumdigits:=FDigits;
    end;
    for i:=0 to locnumdigits-1 do
    begin
      locdigits[i]:=locvalue mod 10;
      locvalue:=locvalue div 10;
    end;
    if locvalue>0 then //overflow
    begin
      for i:=0 to FDigits-1 do
        locdigits[i]:=11;
    end else
    begin
      i:=FDigits-1;
      if FValue<0 then
        i:=i-1;
      if not FLeadingZero then
      begin
        i:=FDigits-1;
        while (i>=1) and (LocDigits[i]=0) do
        begin
          LocDigits[i]:=10;
          i:=i-1;
        end;
      end;
      if FValue<0 then
        LocDigits[i+1]:=11;
    end;
    canvas.Brush.Color:=Color;
    if color<>clNone then
    begin
      canvas.Brush.Style:=bsSolid;
      canvas.FillRect(ClientRect);
    end;
    canvas.Brush.Style:=bsClear;
    r:=FirstDigitRect;
    for i:=FDigits-1 downto 0 do
    begin
      Canvas.StretchDraw(R,FNixiePictures[FStyle,locdigits[i]]);
      OffsetRect(r,clientwidth div fdigits,0);
    end;
end;

procedure TNixieDisplay.SetColor(NewColor: TColor);
begin
  inherited;
  // if color = clnone then transparent, so not opaque
  if NewColor = clNone then
    ControlStyle := ControlStyle - [csOpaque]
  else
    ControlStyle := ControlStyle + [csOpaque];
end;

function TNixieDisplay.FirstDigitRect: TRect;
var
  PicWidth: Integer;
  PicHeight: Integer;
  ImgWidth: Integer;
  ImgHeight: Integer;
  w: Integer;
  h: Integer;
begin
  PicWidth := FNixiePictures[fStyle,0].Width;
  PicHeight := FNixiePictures[fStyle,0].Height;
  ImgWidth := ClientWidth div FDigits;
  ImgHeight := ClientHeight;
  if (PicWidth > 0) and (PicHeight > 0) then begin
    w:=ImgWidth;
    h:=(PicHeight*w) div PicWidth;
    if h>ImgHeight then begin
      h:=ImgHeight;
      w:=(PicWidth*h) div PicHeight;
    end;
    PicWidth:=w;
    PicHeight:=h;
  end
  else begin
    PicWidth := ImgWidth;
    PicHeight := ImgHeight;
  end;
  Result:=Rect(0,0,PicWidth,PicHeight);
  OffsetRect(Result,(ImgWidth-PicWidth) div 2,(ImgHeight-PicHeight) div 2);
end;

class function TNixieDisplay.GetControlClassDefaultSize: TSize;
begin
  Result.CX:=318;
  Result.CY:=148;
end;

constructor TNixieDisplay.create(TheOwner: TComponent);
begin
  inherited create(TheOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csReplicatable];
  FDigits:=5;
  FValue:=0;
  FStyle:=NsTube;
  FLeadingZero:=false;
  SetInitialBounds(0, 0, GetControlClassDefaultSize.Cx, GetControlClassDefaultSize.CY);
  Color:=clNone;
end;

procedure Register;
begin
  RegisterComponents('Misc',[TNixieDisplay]);
end;

{$R pictures/pictures.res}
{$R icon.res}

initialization

  LoadPictures;

finalization

  FreePictures;

end.


