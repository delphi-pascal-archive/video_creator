unit UPaint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, Buttons, ColorGrd;

type
  TPaintForm = class(TForm)
    Image1: TImage;
    Color_Bt: TSpeedButton;
    Circle_Bt: TSpeedButton;
    Rectangle_Bt: TSpeedButton;
    Line_Bt: TSpeedButton;
    Pen_Bt: TSpeedButton;
    SizePen_LB: TListBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Paint_CG: TColorGrid;
    Save_Image_Bt: TBitBtn;
    Procedure ActionOfPainting(x,y : integer);
    Procedure DrawingAPixel(x,y : integer);
    Procedure DrawingALine(x,y : integer);
    Procedure DrawingARectangle(x,y : integer);
    procedure DrawingACircle(x,y : integer);
    Procedure ColorOfPixel(Xi,Yi : integer);
    Procedure CreateACopy;
    Procedure ViewACopy;
    procedure Paint_CGClick(Sender: TObject);
    procedure SizePen_LBClick(Sender: TObject);
    procedure Color_BtClick(Sender: TObject);
    procedure Circle_BtClick(Sender: TObject);
    procedure Rectangle_BtClick(Sender: TObject);
    procedure Line_BtClick(Sender: TObject);
    procedure Pen_BtClick(Sender: TObject);
    procedure Save_Image_BtClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PaintForm: TPaintForm;
  NumAction : integer;
  Xi,Yi : integer;
  CopyBmp: TBitMap;
  
Const
       ASelectColor = 0;
       ARectangle = 1;
       ALine = 2;
       ACircle = 3;
       APainting = 4;

implementation

uses Principal;

{$R *.dfm}

{>>DEFINITION DES ACTIONS DE RETOUCHE D'IMAGE}
Procedure TPaintForm.ActionOfPainting(x,y : integer);
Begin
{Le fameux case of pour déclencher l'action à réaliser suivant notre choix précédent : un case of est plus rapide qu'un while do, begin until, if then, for do}
Case NumAction Of
  ASelectColor : ColorOfPixel(xi,yi);
  ARectangle : DrawingARectangle(x,y);
  ALine : DrawingALine(x,y);
  ACircle : DrawingACircle(x,y);
  APainting : DrawingAPixel(x,y);
End;
End;

{>>DESSINER UN PIXEL}
Procedure TPaintForm.DrawingAPixel(x,y : integer);
Begin
Main.VisualImage.Canvas.Rectangle(xi,yi,xi+2,yi+2);
xi:=x;
yi:=y;
End;

{>>DESSINER UN TRAIT}
Procedure TPaintForm.DrawingALine(x,y : integer);
Begin
Main.VisualImage.Canvas.MoveTo(Xi,Yi);
{Pour dessiner un trait}
Main.VisualImage.canvas.lineTo(x,y);
end;

{>>DESSINER UN RECTANGLE}
Procedure TPaintForm.DrawingARectangle(x,y : integer);
Begin
Main.VisualImage.Canvas.brush.Style:=bsclear;
{On dessine un rectangle}
Main.VisualImage.Canvas.Rectangle(xi,yi,x,y);
end;

{>>DESSINER UN CERCLE}
procedure TPaintForm.DrawingACircle(x,y : integer);
Begin
Main.VisualImage.Canvas.brush.Style:=bsclear;
{On dessine une ellipse/Cercle}
Main.VisualImage.canvas.ellipse(xi,yi,x,y);
end;

{>>SELECTIONNE LA COULEUR D'UN PIXEL}
Procedure TPaintForm.ColorOfPixel(Xi,Yi : integer);
Var
  AColor : TColor;
Begin
If not assigned(Main.VisualImage) then exit;
AColor:=Main.VisualImage.Canvas.Pixels[Xi,Yi];
Panel2.Color:=AColor;
{On sélectionne la couleur d'un pixel}
Main.VisualImage.Canvas.Pen.Color:=AColor;
End;

{>>COPIE D'UNE IMAGE}
Procedure TPaintForm.CreateACopy;
Begin
{Si CopyBmp existe deja, on le détruit}
IF CopyBmp<>nil then FreeAndNil(CopyBmp);
{On le crée}
CopyBmp:=TBitMap.Create;
{Sa largeur est celle de l'image}
CopyBmp.Width:=Main.VisualImage.Width;
{Sa hauteur est celle de l'image}
CopyBmp.Height:=Main.VisualImage.Height;
{On copie l'image dans CopyBmp}
CopyBmp.Canvas.StretchDraw(CopyBmp.Canvas.ClipRect, Main.VisualImage.Picture.Bitmap);
End;

{>>AFFICHAGE DE LA COPIE}
Procedure TPaintForm.ViewACopy;
Begin
{Si CopyBmp existe}
If CopyBmp<>nil then
{On l'affiche}
Main.VisualImage.Picture.Bitmap.Assign(CopyBmp);
End;

{>>SELECTION DES COULEURS}
procedure TPaintForm.Paint_CGClick(Sender: TObject);
begin
With Paint_CG do
  Begin
  {On définit la couleur du stylo}
  Main.VisualImage.Canvas.Pen.Color:=ForegroundColor;
  {On définit la couleur du pinceau}
  Main.VisualImage.Canvas.brush.Color:=BackgroundColor;
  {On affiche ses couleurs dans un panel : c'est plus joli}
  Panel2.Color:=ForegroundColor;
  Panel3.Color:=BackgroundColor;
  End;
end;

{>>TAILLE DU STYLO}
procedure TPaintForm.SizePen_LBClick(Sender: TObject);
begin
{On définit la taille du stylo}
Main.VisualImage.Canvas.Pen.width:=StrToInt(SizePen_LB.Items.Strings[SizePen_LB.ItemIndex]);
end;

procedure TPaintForm.Color_BtClick(Sender: TObject);
begin
NumAction:=ASelectColor;
end;

procedure TPaintForm.Circle_BtClick(Sender: TObject);
begin
NumAction:=ACircle;
end;

procedure TPaintForm.Rectangle_BtClick(Sender: TObject);
begin
NumAction:= ARectangle;
end;

procedure TPaintForm.Line_BtClick(Sender: TObject);
begin
NumAction:= ALine;
end;

procedure TPaintForm.Pen_BtClick(Sender: TObject);
begin
NumAction:=APainting;
end;

procedure TPaintForm.Save_Image_BtClick(Sender: TObject);
Var
  JPeg : TJPegImage;
begin
If Main.Image_Ed.Text<>'' then
If ExtractFileExt(Main.Image_Ed.Text)='.bmp' then
Main.VisualImage.picture.graphic.SaveToFile(Main.Image_Ed.text)
Else
  Begin
  JPeg:=TJPegImage.Create;
  JPeg.Assign(Main.VisualImage.Picture.Graphic);
  JPeg.SaveToFile(Main.Image_Ed.Text);
  End;
end;

end.
