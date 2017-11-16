unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, Spin, StdCtrls, EditBtn, ComCtrls, Menus, maskedit, Figures,
  Math, Types, CoordSystems, Tools, TransformTools, Parameters;

type

  { TFormMain }

  TFormMain = class(TForm)
    HorScrollBar: TScrollBar;
    MenuEdit: TMenuItem;
    MenuReset: TMenuItem;
    MenuResetScale: TMenuItem;
    MenuResetOffset: TMenuItem;
    MenuScaleToFit: TMenuItem;
    VerScrollBar: TScrollBar;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    PanelOutline2: TPanel;
    ScaleSpinEdit: TFloatSpinEdit;
    ScaleLabel: TLabel;
    PanelOutline1: TPanel;
    RYEdit: TSpinEdit;
    WidthBoxBevel: TBevel;
    ColorButton: TColorButton;
    EditWidth: TEdit;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuHelp: TMenuItem;
    MenuFileExit: TMenuItem;
    MenuHeloAbout: TMenuItem;
    MenuWindowACC: TMenuItem;
    MenuWindow: TMenuItem;
    PanelInstrument: TPanel;
    RXEdit: TSpinEdit;
    WidthLabel: TLabel;
    PaintBox: TPaintBox;
    PanelMain: TPanel;
    updownWidth: TUpDown;
    procedure ColorButtonColorChanged(Sender: TObject);
    procedure EditWidthChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HandMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure HandPopupDefPosClick(Sender: TObject);
    procedure HorScrollBarChange(Sender: TObject);
    procedure MenuResetScaleClick(Sender: TObject);
    procedure PaintBoxMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure PaintBoxMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure ScaleSpinEditEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuFileExitClick(Sender: TObject);
    procedure MenuHelpAboutClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FigureMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure RXEditEditingDone(Sender: TObject);
    procedure RYEditEditingDone(Sender: TObject);
    procedure ReselectButton(button: TObject);
    procedure VerScrollBarChange(Sender: TObject);
    procedure ZoomMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ZoomPopupDefPosClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormMain: TFormMain;
  FigureType: integer;
  Drawing, Transformed: boolean;
  FigureButtonTag, GlobalWidth, rx, ry, lastheight, lastwidth: integer;
  GlobalColor: TColor;

  LastChosenFigure: TSpeedButton;
  f2,figuretemp:TFigure;
  ttemp: TTransformTool;
  pmin, pmax: tpointdouble;
  ToolButtons: array of TSpeedButton;

implementation

{$R *.lfm}

//TFormMain

procedure TFormMain.FormCreate(Sender: TObject);
var
  i, j: integer;
  b: TSpeedButton;
  LoadedPicture: TPicture;
  s: string;
begin
  LastChosenFigure := nil;
  for i := 0 to High(TFigureClassList) do
  begin
    Transformed := False;
    b := TSpeedButton.Create(PanelMain);
    b.Parent := PanelMain;
    s := TFigureClassList[i].ClassName;
    Delete(s, 1, 1);
    b.Name := s;
    LoadedPicture := TPicture.Create;
    LoadedPicture.LoadFromFile(TFigureClassList[i].ClassName + '.png');
    b.Glyph := LoadedPicture.Bitmap;
    LoadedPicture.Free;
    b.Height := 44;
    b.Width := 44;
    b.Top := 44 * i;
    b.Flat := True;
    b.Margin := 0;
    b.Left := 2;
    b.Tag := i;
    b.OnMouseDown := @FigureMouseDown;
    setlength(toolbuttons, length(toolbuttons) + 1);
    ToolButtons[i] := b;
  end;

  for j := 0 to High(TransformToolClassList) do
  begin
    b := TSpeedButton.Create(PanelMain);
    b.Parent := PanelMain;
    s := TransformToolClassList[j].ClassName;
    Delete(s, 1, 1);
    b.Name := s;
    LoadedPicture := TPicture.Create;
    LoadedPicture.LoadFromFile(TransformToolClassList[j].ClassName + '.png');
    b.Glyph := LoadedPicture.Bitmap;
    LoadedPicture.Free;
    b.Height := 44;
    b.Width := 44;
    b.Top := 44 * (i + j + 1);
    b.Flat := True;
    b.Margin := 0;
    b.Left := 2;
    b.Tag := i + j + 1;
    b.OnMouseDown := @FigureMouseDown;
    setlength(toolbuttons, length(toolbuttons) + 1);
    ToolButtons[i + j + 1] := b;
  end;

  globalwidth := 1;
  globalcolor := clBlack;
  EditWidth.Text := '1';
  rx := 25;
  ry := 25;
  FigureButtonTag := 0;
  LastChosenFigure := ToolButtons[0];
  ReselectButton(ToolButtons[0]);
  GlobalOffset := PointDouble(0, 0);
  GlobalScale := 1;
  lastheight := PaintBox.Width;
  pmin.x := 0;
  pmin.y := 0;
  pmax.x := Width;
  pmax.y := Height;
  HorScrollBar.min := -Width div 2;
  HorScrollBar.max := Width div 2;
  VerScrollBar.min := -Height div 2;
  VerScrollBar.max := Height div 2;
  CanvasWidth := PaintBox.Width;
  CanvasHeight := PaintBox.Height;
  FormMain.DoubleBuffered := True;

end;

procedure TFormMain.ReselectButton(button: TObject);
begin
  FigureButtonTag := (button as TSpeedButton).Tag;
  LastChosenFigure.Enabled := True;
  LastChosenFigure.Margin := 0;
  LastChosenFigure := (button as TSpeedButton);
  (button as TSpeedButton).Down := True;
  (button as TSpeedButton).Margin := 0;
  (button as TSpeedButton).Enabled := False;
end;

procedure TFormMain.VerScrollBarChange(Sender: TObject);
begin
  GlobalOffset.y := VerScrollBar.position;
  paintbox.invalidate;
end;

procedure TFormMain.ZoomMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  //ZoomPopupMenu.Popup(mouse.CursorPos.x, mouse.CursorPos.y);
end;

procedure TFormMain.ZoomPopupDefPosClick(Sender: TObject);
begin
  GlobalScale := 1;
  ScaleSpinEdit.Value := 100;
end;

procedure TFormMain.RXEditEditingDone(Sender: TObject);
begin
  rx := StrToInt(Name);
end;

procedure TFormMain.RYEditEditingDone(Sender: TObject);
begin
  ry := StrToInt(Name);
end;

procedure TFormMain.ColorButtonColorChanged(Sender: TObject);
begin
  globalcolor := ColorButton.ButtonColor;
end;

procedure TFormMain.EditWidthChange(Sender: TObject);
var
  txt: string;
  i: integer;
begin
  txt := EditWidth.Text;
  for i := 1 to length(txt) do
  begin
    if (not (txt[i] in ['0'..'9'])) then
    begin
      Delete(txt, i, 1);
    end;
  end;
  if ((txt = '') or (txt = '0')) then
    txt := '1';
  if (StrToInt(txt) > 512) then
    txt := '512';
  EditWidth.Text := txt;
  globalwidth := StrToInt(EditWidth.Text);
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  CanvasWidth := paintbox.Width;
  CanvasHeight := paintbox.Height;
end;

procedure TFormMain.HandMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  //HandPopupMenu.Popup(mouse.CursorPos.x, mouse.CursorPos.y);
end;

procedure TFormMain.HandPopupDefPosClick(Sender: TObject);
begin
  GlobalOffset.x := 0;
  GlobalOffset.y := 0;
  PaintBox.Invalidate;
end;

procedure TFormMain.HorScrollBarChange(Sender: TObject);
begin
  GlobalOffset.x := HorScrollBar.position;
  paintbox.invalidate;
end;

procedure TFormMain.MenuResetScaleClick(Sender: TObject);
begin
  globalscale := 1;
  ScaleSpinEdit.Value := 100;
end;

procedure TFormMain.PaintBoxMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  GlobalScale := min(MAXSCALE, max(MINSCALE, GlobalScale - 0.05));
  ScaleSpinEdit.Value := GlobalScale * 100;
  paintbox.invalidate;
end;

procedure TFormMain.PaintBoxMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
var
  p: array[0..1] of tpointdouble;
begin
  GlobalScale := min(MAXSCALE, max(MINSCALE, GlobalScale + 0.05));
  ScaleSpinEdit.Value := GlobalScale * 100;
  paintbox.invalidate;
end;

procedure TFormMain.ScaleSpinEditEditingDone(Sender: TObject);
begin
  //ShowMessage('changed');
  GlobalScale := ScaleSpinEdit.Value / 100;
  PaintBox.Invalidate;
end;

procedure TFormMain.MenuFileExitClick(Sender: TObject);
begin
  FormMain.Close;
end;

procedure TFormMain.MenuHelpAboutClick(Sender: TObject);
begin
  ShowMessage('Vector Graphics Editor v. 0.0003 by Lesogorov Mihail (b8103a)');
end;

procedure TFormMain.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if (Button = mbLeft) then
  begin
    if (FigureButtonTag in [0..length(TFigureClassList) - 1]) then
    begin

      SetLength(FigureList, Length(FigureList) + 1);
      figuretemp := TFigureClassList[FigureButtonTag].Create(X, Y);
      f2:=(figuretemp as  TFigureClassList[FigureButtonTag]);
      f2.rx := rx;
      figuretemp.ry := ry;
      figuretemp.color := globalcolor;
      figuretemp.Width := globalwidth;
      FigureList[high(FigureList)] := figuretemp;
      PaintBox.Invalidate;
      createparameters(PanelInstrument,
        (figuretemp as TFigureClassList[FigureButtonTag]).params0);
    end
    else
    begin
      ttemp := TransformToolClassList[FigureButtonTag -
        Length(TFigureClassList)].Create(X, Y);
      //showmessage('+');
      Transformed := True;
    end;
    drawing := True;
  end;

end;

procedure TFormMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  if (Drawing = True) then
  begin
    if (FigureButtonTag in [0..length(TFigureClassList) - 1]) then
    begin
      FigureList[high(FigureList)].MouseMove(x, y);
      if (S2W(x, 0).x < pmin.x) then
        pmin.x := S2W(x, 0).x;
      if (S2W(x, 0).x > pmax.x) then
        pmax.x := S2W(x, 0).x;
      if (S2W(0, y).y < pmin.y) then
        pmin.y := S2W(0, y).y;
      if (S2W(0, y).y > pmax.y) then
        pmax.y := S2W(0, y).y;
      HorScrollBar.min := round(pmin.x) - Width div 2;
      HorScrollBar.max := round(pmax.x) - Width div 2;
      VerScrollBar.min := round(pmin.y) - Height div 2;
      VerScrollBar.max := round(pmax.y) - Height div 2;
    end
    else
    begin
      ttemp.MouseMove(x, y);
    end;
    ScaleSpinEdit.Value := GlobalScale * 100;
    PaintBox.Invalidate;
  end;
  {StaticText1.Caption := 'tag: ' + floattostr(LastChosenFigure.Tag);
  StaticText2.Caption := 'mx: ' + IntToStr(x);
  StaticText3.Caption := 'my: ' + IntToStr(y);}
  StaticText4.Caption := 'offx: ' + floattostr(GlobalOffset.x);
  StaticText5.Caption := 'offy: ' + floattostr(GlobalOffset.y);{
  StaticText6.Caption := 'pmin.x: ' + floattostr(pmin.x);
  StaticText7.Caption := 'wt.x: ' + floattostr(wt.x);   }
  StaticText8.Caption := 'tag: ' + IntToStr(FigureButtonTag);
  scaleSpinEdit.Value := GlobalScale * 100;
end;

procedure TFormMain.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i: TFigure;
begin
  if (Button = mbLeft) then
  begin
    if (FigureButtonTag in [0..length(TFigureClassList) - 1]) then
    begin
      for i in FigureList do
      begin
        i.MouseUp(x, y);
      end;
      PaintBox.Invalidate;
    end
    else
    begin
      ttemp.MouseUp(x, y);
      //ttemp.Free;
    end;
    Drawing := False;
    Transformed := False;
  end;
  paintbox.cursor := crDefault;
  PaintBox.Invalidate;
  scaleSpinEdit.Value := GlobalScale * 100;
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject);
var
  i: TFigure;
begin
  PaintBox.Canvas.Pen.Color := clWhite;
  PaintBox.Canvas.Brush.Color := clWhite;
  PaintBox.Canvas.Rectangle(0, 0, PaintBox.Width, PaintBox.Height);
  for i in FigureList do
  begin
    PaintBox.Canvas.Pen.Color := i.color;
    PaintBox.Canvas.Brush.Color := i.color;
    PaintBox.Canvas.Pen.Width := max(1, round(i.Width * GlobalScale));
    i.draw(PaintBox.Canvas);
  end;
  if (transformed) then
  begin
    ttemp.draw(PaintBox.canvas);
  end;
end;

procedure TFormMain.FigureMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  ReselectButton(Sender as TSpeedButton);
end;

end.
