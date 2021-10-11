unit Principal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, ComCtrls, Buttons, ImgList, MMSystem,ShellApi;

type
  TMain = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    VisualImage: TImage;
    TexteImage_Lab: TLabel;
    ImageFiles_TreeView: TTreeView;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    ImageFilesAdd_Bt: TSpeedButton;
    Label2: TLabel;
    ImageFilesDel_Bt: TSpeedButton;
    Label3: TLabel;
    Label1: TLabel;
    Image_Ed: TEdit;
    ImageFilesView_Bt: TSpeedButton;
    Label4: TLabel;
    Text_Bt: TSpeedButton;
    Label5: TLabel;
    Sound_Bt: TSpeedButton;
    Label7: TLabel;
    Drawing_Bt: TSpeedButton;
    Label6: TLabel;
    FusionFiles_Bt: TSpeedButton;
    Label8: TLabel;
    StateFusion_Ed: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    SaveDialog1: TSaveDialog;
    Procedure Move1FormPrincipal(AForm : TForm);
    procedure ImageFilesView_BtClick(Sender: TObject);
    procedure ImageFilesAdd_BtClick(Sender: TObject);
    procedure Text_BtClick(Sender: TObject);
    procedure Sound_BtClick(Sender: TObject);
    procedure ImageFilesDel_BtClick(Sender: TObject);
    procedure ImageFiles_TreeViewDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ImageFiles_TreeViewDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure ImageFiles_TreeViewClick(Sender: TObject);
    procedure ImageFiles_TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure Drawing_BtClick(Sender: TObject);
    procedure VisualImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VisualImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VisualImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FusionFiles_BtClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    CNode : TTreeNode;
  public
    { Public declarations }
  end;

var
  Main: TMain;
  AEffect : cardinal;

implementation

Uses UImageAndComments,UTreeView,UText,UVocals,UPaint,UFusion, UPlayer;

{$R *.dfm}
{$R icone.res}

{>>DEPLACEMENT ET APPARITION DES FORMS}
Procedure TMain.Move1FormPrincipal(AForm : TForm);
Begin
VocalForm.Hide;
PaintForm.Hide;
TextForm.Hide;
Main.Left:=(Screen.Width-Main.Width-AForm.width) div 2;
AForm.Top:=Main.Top;
AForm.Left:=Main.Left+Main.Width;
AForm.Show;
End;

procedure TMain.Text_BtClick(Sender: TObject);
begin
Move1FormPrincipal(TextForm);
end;

procedure TMain.Sound_BtClick(Sender: TObject);
begin
Move1FormPrincipal(VocalForm);
end;

procedure TMain.Drawing_BtClick(Sender: TObject);
begin
Move1FormPrincipal(PaintForm);
end;

procedure TMain.SpeedButton1Click(Sender: TObject);
begin
PlayerForm.Show;
PlayerForm.speed_TrBr.Position:=PlayerForm.speed_TrBr.Max;
end;

{>>VISUALISATION D'UNE IMAGE}
procedure TMain.ImageFilesView_BtClick(Sender: TObject);
begin
{Avec l'OpenDialog}
With OpenDialog1 do
  Begin
  {On définit les filtres}
  Filter:='Fichier images|*.bmp;*.jpg;*.jpeg';
  {S'il est executé}
    If Execute then
    Begin
      {On montre l'image}
      ShowImage(FileName);
      {On place le nom du fichier Image dans l'Edit}
      Image_Ed.Text:=FileName;
    End;
  End;
end;

{>>AJOUT D'IMAGES}
procedure TMain.ImageFilesAdd_BtClick(Sender: TObject);
begin
{On vide l'Edit}
Image_Ed.Text:='';
{Avec l'OpenDialog}
With OpenDialog1 do
  Begin
  {On définit les filtres}
  Filter:='Fichier images|*.bmp;*.jpg;*.jpeg';
  {On se met en multisélection}
  Options:=[OfAllowMultiSelect];
  If Execute then
  {S'il executé on place le nom des fichiers images dans le TreeView}
  AddFileInTreeView(OpenDialog1.Files);
  End;
end;

{>>PARTIE DE SUPPRESSION D'UNE SELECTION}
procedure TMain.ImageFilesDel_BtClick(Sender: TObject);
begin
{Si on a sélectionné un TreeNode, on l'efface}
If ImageFiles_TreeView.selected<>nil then DelInTreeView;
end;

{>>PARTIE DRAP&DROP AVEC LE TREEVIEW}
procedure TMain.ImageFiles_TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
{La source pour le drap&drop est le TreeView}
Accept:=(Source=ImageFiles_TreeView);
{On définit la sélection comme un TreeNode de référence}
CNode:=ImageFiles_TreeView.selected;
end;

procedure TMain.ImageFiles_TreeViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
{Si le TreeNode précédent est relatif à une image, on réalise le déplacement}
If CNode.ImageIndex=0 then MoveFileInTreeView (CNode,X,Y);
end;

{>>SELECTION D'UN TREENODE}
procedure TMain.ImageFiles_TreeViewClick(Sender: TObject);
Var
  NumChildren : Integer;
begin
{Si le TreeNode sélectionné n'est pas une image, on s'arrete}
If (ImageFiles_TreeView.SelectionCount=0) or (ImageFiles_TreeView.Selected.ImageIndex<>0) then Exit;
{(Sinon) on affiche Image et Commentaires}
With ImageFiles_TreeView do
  Begin
    Image_Ed.Text:=Selected.Text;
    {On montre l'image sélectionnée}
    ShowImage(Selected.Text);
    {On définit un texte par défaut du commentaire textuel}
    With TexteImage_Lab do
      Begin
      Left:=103;
      Font.Color:=ClRed;
      Font.Name:='MS Sans Serif';
      Font.Size:=8;
      Caption:='Video Creator';
      End;
    If Selected.HasChildren then
    {On fait une boucle}
    For NumChildren:=0 to (Selected.Count-1) do
    Begin
    {si l'enfant est un fichier wav, on le joue}
    If Selected.Item[NumChildren].ImageIndex=3 then SndPlaySound(PChar(Selected.Item[NumChildren].Text),SND_ASYNC);
    {Si l'enfant est un commentaire textuel}
    If Selected.Item[NumChildren].ImageIndex=1 then
    {On affiche le texte en utilisant ses paramètres}
     ShowTextInMain(Selected.Item[NumChildren+1].Text,Selected.Item[NumChildren].Text);
    End;
 End;
end;

{>>CHANGEMENT DE TREENODES}
procedure TMain.ImageFiles_TreeViewChange(Sender: TObject;
  Node: TTreeNode);
begin
{Changement : meme chose qu'un clique.}
ImageFiles_TreeView.OnClick(Sender);
end;

{>>RETOUCHER UNE IMAGE}
procedure TMain.VisualImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{Si le bouton gauche de la souris est cliqué}
If (SSLeft in Shift) then 
  Begin
  {On crée une copie de l'image}
  PaintForm.CreateACopy;
  { On affiche la copie}
  PaintForm.ViewACopy;
  { On place le point sur le canvas}
  VisualImage.Canvas.MoveTo(X,Y); 
  {Position horizontale initiale}
  Xi:=X; 
  {Position verticale initiale}
  Yi:=Y; 
  end;     
end;

procedure TMain.VisualImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
{Si le bouton gauche de la souris est cliqué}
If (SSLeft in Shift) then  
  Begin
  {On affiche la copie}
  PaintForm.ViewACopy;   
  {On réalise ActionOfPainting(x,y)}
  PaintForm.ActionOfPainting(x,y);  
  end;
end;

procedure TMain.VisualImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{Si le bouton gauche de la souris est cliqué on réalise ActionOfPainting(x,y)}
If (SSLeft in Shift) then PaintForm.ActionOfPainting(x,y); 
end;

{>>CREATION DU FILM}
procedure TMain.FusionFiles_BtClick(Sender: TObject);
Var
  NameOfFile : string;
Begin
If ImageFiles_TreeView.selected=nil then Exit;
With SaveDialog1 do
	Begin
  StateFusion_Ed.Text:='En cours';
	Filter:='Fichier fvc|*.fvc';
	{Fusion des fichiers}
 	If Execute then
    Begin
    If ExtractFileExt(FileName)='' then NameOfFile:=FileName+'.fvc' Else NameOfFile:=FileName;
    Fusion(NameOfFile);
    End;
  StateFusion_Ed.Text:=NameOfFile;
	End;
end;

end.
