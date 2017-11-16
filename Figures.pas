unit Figures;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics, Dialogs, Math, CoordSystems,
  Forms, Controls, Tools;

type

  TFigure = class(TTool)
  public
    procedure Draw(acanvas: TCanvas); virtual; abstract;
    procedure MouseMove(x, y: integer); virtual; abstract;
    procedure MouseUp(x, y: integer); virtual;
    constructor Create(x, y: integer); virtual;
  end;

  TPen = class(TFigure)
  const
    params0: array [0..0] of string = ('width');
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
  end;

  TLine = class(TFigure)
  const
    params0: array [0..0] of string = ('width');
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
  end;

  TRectangle = class(TFigure)
  const
    params0: array [0..0] of string = ('width');
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
  end;

  TEllipse = class(TFigure)
  const
    params0: array [0..0] of string = ('width');
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
  end;

  TRoundrect = class(TFigure)
  const
    params0: array [0..0] of string = ('width');
  public
    procedure Draw(acanvas: TCanvas); override;
    procedure MouseMove(x, y: integer); override;
  end;

  TFigureClass = class of TFigure;

var
  FigureList: array of TFigure;

const
  TFigureClassList: array [0..4] of TFigureClass =
    (TPen, TLine, TRectangle, TEllipse, TRoundrect);

implementation

constructor TFigure.Create(x, y: integer);
begin
  setlength(points, 2);
  points[0] := s2w(x, y);
  points[1] := points[0];
  ScreenCoord.x := x;
  ScreenCoord.y := y;
  WorldCoord.x := s2w(x, 0).x;
  WorldCoord.y := s2w(0, y).y;
end;

procedure TFigure.MouseUp(x, y: integer);
begin
end;

//LINE
procedure TLine.Draw(acanvas: TCanvas);
begin
  acanvas.line(w2s(points[0]), w2s(points[1]));
end;

procedure TLine.MouseMove(x, y: integer);
begin
  points[1] := s2w(x, y);
end;
//LINE

//RECTANGLE
procedure TRectangle.Draw(acanvas: TCanvas);
begin
  SetScreenCoords(points);
  acanvas.rectangle(
    w2s(points[0]).x, w2s(points[0]).y, w2s(points[1]).x, w2s(points[1]).y);
end;

procedure TRectangle.MouseMove(x, y: integer);
begin
  points[1] := S2W(x, y);
end;
//RECTANGLE

//EllIPSE
procedure TEllipse.Draw(acanvas: TCanvas);
begin
  SetScreenCoords(points);
  acanvas.ellipse(w2s(points[0]).x, w2s(points[0]).y, w2s(points[1]).x,
    w2s(points[1]).y);
end;

procedure TEllipse.MouseMove(x, y: integer);
begin
  points[1] := S2W(x, y);
end;
//ELLIPSE

//PEN
procedure TPen.Draw(acanvas: TCanvas);
begin
  acanvas.Polyline(SetScreenCoords(Points));
end;

procedure TPen.MouseMove(x, y: integer);
begin
  setlength(points, length(points) + 1);
  points[high(points)] := S2W(x, y);
end;
//PEN

//ROUNDRECT
procedure TRoundrect.Draw(acanvas: TCanvas);
begin
  acanvas.roundrect(w2s(points[0]).x, w2s(points[0]).y, w2s(points[1]).x,
    w2s(points[1]).y, rx, ry);
end;

procedure TRoundrect.MouseMove(x, y: integer);
begin
  points[1] := S2W(x, y);
end;
//ROUNDRECT

{procedure RegisterFigureTools(AFigureTools: array of TFigureClass);
var
  i: TFigureClass;
begin
  for i in AFigureTools do
  begin
    setlength(TFigureClassList, length(TFigureClassList) + 1);
    TFigureClassList[High(TFigureClassList)] := i;
  end;
end;


initialization
  RegisterFigureTools(TFigureClassList.Create(
  TPen, TLine, TRectangle, TEllipse,TRoundrect)); }

end.
