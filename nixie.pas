unit nixie; 

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LResources, Classes, SysUtils, Controls, ExtCtrls, Graphics, GraphType;

type

{ TNixieDisplay }

TNixieStyle = (NsTube, NsRound);
TNixieDisplay = class(TCustomControl)
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
//  class function GetControlClassDefaultSize: TPoint; override;
  procedure EraseBackground(DC: HDC); override;
  procedure Paint;override;
public
  constructor create(TheOwner:TComponent);override;
published
  property Value:integer read FValue write SetValue default 0;
  property Digits:integer read FDigits write SetDigits default 5;
  property LeadingZero:boolean read FLeadingZero write SetLeadingZero default false;
  property Style:TNixieStyle read FStyle write SetStyle default NsTube;
  property Align;
  property Anchors;
  property BorderSpacing;
  property BorderWidth;
  property BorderStyle;
  property ClientHeight;
  property ClientWidth;
  property Color;
  property Constraints;
  property DockSite;
  property DragCursor;
  property DragKind;
  property DragMode;
  property Enabled;
  property ParentColor;
  property ParentShowHint;
  property PopupMenu;
  property ShowHint;
  property TabOrder;
  property TabStop;
  property UseDockManager default True;
  property Visible;
  property OnClick;
  property OnDockDrop;
  property OnDockOver;
  property OnDblClick;
  property OnDragDrop;
  property OnDragOver;
  property OnEndDock;
  property OnEndDrag;
  property OnEnter;
  property OnExit;
  property OnGetSiteInfo;
  property OnGetDockCaption;
  property OnMouseDown;
  property OnMouseEnter;
  property OnMouseLeave;
  property OnMouseMove;
  property OnMouseUp;
  property OnResize;
  property OnStartDock;
  property OnStartDrag;
  property OnUnDock;
end;

procedure Register;

implementation

var
    FNixiePictures:array[TNixieStyle,0..11] of TPicture;

procedure LoadPictures;
const n:array[TNixieStyle] of string = ('tube','round');
var s:TNixieStyle;
    i:integer;
begin
  for s:=low(s) to high(s) do
    for i:=0 to 11 do
    begin
      FNixiePictures[s,i]:=TPicture.Create;
      FNixiePictures[s,i].LoadFromLazarusResource(n[s]+inttostr(i));
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
    c:TCanvas;
    r:trect;
    Bitmap:TBitmap;
    locdigits:array of integer;
    locnumdigits:integer;
begin
  Bitmap:=TBitmap.Create;
  try
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
    Bitmap.Height:=height;
    Bitmap.Width:=width;
    c:=bitmap.canvas;
    c.Brush.Color:=Color;
    c.FillRect(ClientRect);
    r:=FirstDigitRect;
    for i:=FDigits-1 downto 0 do
    begin
      C.StretchDraw(R, FNixiePictures[FStyle,locdigits[i]].Graphic);
      OffsetRect(r,clientwidth div fdigits,0);
    end;
    Canvas.Draw(0,0,Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TNixieDisplay.EraseBackground(DC: HDC);
begin
  //inherited EraseBackground(DC);
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

{
class function TNixieDisplay.GetControlClassDefaultSize: TPoint;
begin
  Result.X:=318;
  Result.Y:=148;
end;
}

constructor TNixieDisplay.create(TheOwner: TComponent);
begin
  inherited create(TheOwner);
  FDigits:=5;
  FValue:=0;
  FStyle:=NsTube;
  FLeadingZero:=false;
  SetInitialBounds(0, 0, 318 {GetControlClassDefaultSize.X}, 148 {GetControlClassDefaultSize.Y});
end;

procedure Register;
begin
  RegisterComponents('Misc',[TNixieDisplay]);
end;

initialization
  {$I nixie.lrs}
  {$I pictures.lrs}

  LoadPictures;

finalization

  FreePictures;

end.


