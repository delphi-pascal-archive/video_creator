unit UText;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ColorGrd, Buttons;

type
  TTextForm = class(TForm)
    Image1: TImage;
    Text_Ed: TEdit;
    ColorText_CG: TColorGrid;
    ColorSelected_Pn: TPanel;
    SaveText_Bt: TSpeedButton;
    FontName_LB: TListBox;
    SizeText_LB: TListBox;
    procedure SaveText_BtClick(Sender: TObject);
    procedure ColorText_CGClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TextForm: TTextForm;

implementation

Uses Principal,UImageAndComments,UTreeView;

{$R *.dfm}

{>>AJOUT D'UN COMMENTAIRE TEXTUEL DANS LE TREEVIEW}
procedure TTextForm.SaveText_BtClick(Sender: TObject);
Var
  Info,AFontName : String;
  AColor,ASize : integer;
begin
{Si on a sélectionné un TreeNode dans le TreeView et que l'Edit est non vide}
If Main.ImageFiles_TreeView.selected<>nil then
  Begin
  { On définit la couleur sélectionnée}
  AColor:=ColorText_CG.ForegroundColor;
  { On définit la police sélectionnée}
  If FontName_LB.ItemIndex=-1 then AFontName:='Arial' Else AFontName:=FontName_LB.Items[FontName_LB.ItemIndex];
  { On définit la taille de la police sélectionnée}
  If SizeText_LB.ItemIndex=-1 then ASize:=12 Else ASize:=StrToInt(SizeText_LB.Items[SizeText_LB.ItemIndex]);
  { On définit une information à partir de ses caractéristiques => Utilisation pour rajout d'un TreeNode spécifique dans le TreeView}
  Info:='Couleur: '+IntToStr(AColor)+',Taille: '+ IntToStr(ASize)+',Police: '+AFontName; 
  { On ajoute le texte dans le TreeView}
  AddCommentInTreeView(Text_Ed.Text,1);
  { On ajoute les infos du texte dans le TreeView}
  AddCommentInTreeView(Info,2);
  { On met le texte dans l'Image}
  ShowTextInMain(Info,Text_Ed.Text);
  End;
end;

{>>COULEUR DU TEXTE}
procedure TTextForm.ColorText_CGClick(Sender: TObject);
begin
ColorSelected_Pn.Color:=ColorText_CG.ForegroundColor;
end;

end.
