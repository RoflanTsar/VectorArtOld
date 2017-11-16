unit TransformTools;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Tools, CoordSystems, Graphics, Dialogs, Math;

type
  TTransformTool = class(TTool)
  public
    procedure Draw(acanvas: TCanvas); virtual; abstract;
    procedure MouseMove(x, y: integer); virtual; abstract;
    procedure MouseUp(x, y: integer); virtual;
    constructor Create(x, y: integer); virtual;
  end;

  THand = class(TTransformTool)
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
    procedure MouseUp(x, y: integer); override;
  end;

  TZoom = class(TTransformTool)
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
    procedure MouseUp(x, y: integer); override;
  end;

  TZoomRect = class(TTransformTool)
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
    procedure MouseUp(x, y: integer); override;
  end;

  TTransformToolClass = class of TTransformTool;

var
  CurrentTTool: TTransformTool;

  TransformToolList: array of TTransformTool;

const
  TransformToolClassList: array [0..2] of TTransformToolClass =
    (THand, TZoom, TZoomRect);

implementation

constructor TTransformTool.Create(x, y: integer);
begin
  setlength(points, 2);
  points[0] := s2w(x, y);
  points[1] := points[0];
  ScreenCoord.x := x;
  ScreenCoord.y := y;
  WorldCoord.x := s2w(x, 0).x;
  WorldCoord.y := s2w(0, y).y;
end;

procedure TTransformTool.MouseUp(x, y: integer);
begin
end;

//HAND
procedure THand.MouseMove(x, y: integer);
begin
  points[1] := S2W(x, y);
  GlobalOffset.x := GlobalOffset.x + points[0].x - points[1].x;
  GlobalOffset.y += points[0].y - points[1].y;
end;

procedure THand.Draw(acanvas: tcanvas);
begin
end;

procedure THand.MouseUp(x, y: integer);
begin
end;
//HAND

//ZOOM
procedure TZoom.MouseMove(x, y: integer);
var
  px0, px1: integer;
begin
  px0 := W2S(points[0]).x;
  px1 := x;
  points[1] := S2W(x, y);
  GlobalScale := min(MAXSCALE, max(MINSCALE, GlobalScale - (px0 - px1) / 200));
  GlobalOffset.x -= (ScreenCoord.x - W2S(WorldCoord.x, 0).x) / GlobalScale;
  GlobalOffset.y -= (ScreenCoord.y - W2S(0, WorldCoord.y).y) / GlobalScale;
  points[0] := S2W(x, y);
end;

procedure TZoom.Draw(acanvas: tcanvas);
begin
end;

procedure TZoom.MouseUp(x, y: integer);
begin
  //ShowMessage('sthing happened');
  GlobalOffset.x -= (ScreenCoord.x - W2S(WorldCoord.x, 0).x) / GlobalScale;
  GlobalOffset.y -= (ScreenCoord.y - W2S(0, WorldCoord.y).y) / GlobalScale;
  self.Free;
  //setlength(FigureList, length(figurelist) - 1);
end;
//ZOOM

//ZOOM RECTANGLE
procedure TZoomRect.Draw(acanvas: TCanvas);
var
  w: integer;
begin
  SetScreenCoords(points);
  w := acanvas.pen.Width;
  aCanvas.Pen.Style := psDot;
  aCanvas.Brush.Style := bsClear;
  aCanvas.Pen.Mode := pmNot;
  aCanvas.Pen.Width := 2;
  acanvas.rectangle(w2s(points[0]).x, w2s(points[0]).y, w2s(points[1]).x,
    w2s(points[1]).y);
  aCanvas.Pen.Style := psSolid;
  aCanvas.Brush.Style := bsSolid;
  aCanvas.Pen.Mode := pmCopy;
  acanvas.pen.Width := w;
end;

procedure TZoomRect.MouseMove(x, y: integer);
begin
  points[1] := S2W(x, y);
  ScreenCoord.x := W2S(points[1].x, 0).x + (W2S(points[0].x, 0).x -
    W2S(points[1].x, 0).x) div 2;
  WorldCoord.x := S2W(ScreenCoord.x, 0).x;
  ScreenCoord.y := W2S(0, points[1].y).y + (W2S(0, points[0].y).y -
    W2S(0, points[1].y).y) div 2;
  WorldCoord.y := S2W(0, ScreenCoord.y).y;
end;

procedure TZoomRect.MouseUp(x, y: integer);
begin
  GlobalScale :=
    min(max((CanvasWidth / abs(points[0].x - points[1].x)), MINSCALE), MAXSCALE);
  GlobalOffset.x -= (ScreenCoord.x - W2S(WorldCoord.x, 0).x) / GlobalScale;
  GlobalOffset.y -= (ScreenCoord.y - W2S(0, WorldCoord.y).y) / GlobalScale;
  //setlength(FigureList, length(figurelist) - 1);
  self.Free;
end;
//ZOOM RECTANGLE

{procedure RegisterTransformTools(ATransformTools: array of TTransformToolClass);
var
  i: TTransformToolClass;
begin
  for i in ATransformTools do
  begin
    setlength(TransformToolClassList, length(TransformToolClassList) + 1);
    TransformToolClassList[High(TransformToolClassList)] := i;
  end;
end;


initialization
  RegisterTransformTools(TTransformToolClassList.Create(THand, TZoom, TZoomRect));
   }
end.
