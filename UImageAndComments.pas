unit UImageAndComments;

interface

Uses ExtCtrls,JPeg,Graphics,SysUtils,StdCtrls,Classes,MMSystem;

Procedure ShowImage(AFileName : String);
Procedure ExtractInfo(AInfo : string; Var AColor,Asize : integer;Var AFontName : string);
Procedure ShowTextInMain(AInfo, AText : String);
Procedure ExtractAndShowImage(BegImg,EndImg : Cardinal);
Procedure ShowTextInPlayer(AInfo, AText : String);
Procedure ExtractSound(BegSnd,EndSnd : Cardinal);

implementation

Uses Principal,UPlayer;

{>>AFFICHAGE D'UNE IMAGE DANS MAIN}
Procedure ShowImage(AFileName : String);
Var
  JPeg : TJPegImage;
  ABitMap : TBitMap;
Begin
With Main.VisualImage do
Begin
  AutoSize:=False;   {Pas de taille automatique}
  Proportional:=false; {Nne garde pas de proportions}
  stretch:=true;
  If ExtractFileExt(AFileName)='.bmp' then Picture.BitMap.LoadFromFile(AFileName); {Methode pour un fichier image du type Bmp}
  If ExtractFileExt(AFileName)='.jpg' then {Si on a un fichier JPeg, on réalise cette procédure}
    Begin
    JPEG := TJPEGImage.Create;
    JPEG.LoadFromFile(AFileName);
    ABitmap := TBitmap.Create;
      Try
      ABitmap.Width := JPEG.Width;
      ABitmap.Height := JPEG.Height;
      {Similaire sur le principe à la copie d'un bmp}
      ABitmap.Canvas.Draw(0,0,JPEG);
      Picture.BitMap.Assign(ABitMap);
      Finally
      ABitmap.Free;
      JPEG.Free;
      End;
    End;
End;
End;

{>>EXTRACTION DES INFOS POUR LES COMMENTAIRES TEXTUELS}
Procedure ExtractInfo(AInfo : string; Var AColor,Asize : integer;Var AFontName : string);
Begin
AColor:=StrToInt(Copy(AInfo,Pos('Couleur: ',AInfo)+9,Length(AInfo)-length('Couleur: ')-length(Copy(AInfo,Pos(',',AInfo),length(AInfo))))); { Copy(String,Positionnement,nb de caractères copiés)}
delete(AInfo,1,Pos(',',AInfo)); {Delete(String,Positionnement, nb de caractères supprimés)}
ASize:=StrToInt(Copy(AInfo,Pos('Taille: ',AInfo)+8,Length(AInfo)-length('Taille: ')-length(Copy(AInfo,Pos(',',AInfo),length(AInfo)))));
delete(AInfo,1,Pos(',',AInfo));
AFontName:=Copy(AInfo,Pos('Police: ',AInfo)+8,Length(AInfo)-length('Police: '));
End;

{>>AFFICHAGE DES COMMENTAIRES TEXTUELS DANS MAIN}
Procedure ShowTextInMain(AInfo, AText : String);
Var
  AFontName : String;
  AColor,Asize : integer;
Begin
ExtractInfo(AInfo,AColor,Asize,AFontName);
With Main.TexteImage_Lab do
  Begin
  {Le Label n'est pas transparent}
  Transparent:=True;
  {Couleur du Label}
  Font.Color:=AColor;
  {Style de la police}
  Font.Name:=AFontName;
  {Taille de la police}
  Font.Size:=ASize;
  {Contenu du Label}
  Caption:=AText;
  {On place le Label au milieu de l'image}
  Left:=(2*Main.VisualImage.Left+Main.VisualImage.Width-Width)div 2;
  Top:=Main.VisualImage.Top;
  {On rend le Label Visible}
  Visible:=True;
  End;
End;

{>>AFFICHAGE A LA VOLEE DANS PLAYERFORM}
Procedure ExtractAndShowImage(BegImg,EndImg : Cardinal);
Var
  MSI : TMemoryStream;
  FSI : TFileStream;
  JPeg : TJPegImage;
Begin
JPeg:=TJpegImage.Create;
FSI:=TFileStream.Create(ImgPlayer,fmOpenRead);
MSI:=TMemoryStream.Create;
FSI.Position:=BegImg;
  Try
  MSI.CopyFrom(FSI,EndImg);
  MSI.Position:=0;
  Jpeg.LoadFromStream(MSI);
  PlayerForm.Player_Image.Picture.BitMap.Assign(Jpeg);
  Finally
  FreeAndNil(JPeg);
  FreeAndNil(FSI);
  FreeAndNil(MSI);
  End;
End;

{>>AFFICHAGE DES COMMENTAIRES TEXTUELS DANS PLAYERFORM}
Procedure ShowTextInPlayer(AInfo, AText : String);
Var
  AFontName : String;
  AColor,Asize : integer;
Begin
ExtractInfo(AInfo,AColor,Asize,AFontName);
With PlayerForm.Label_Player_Lb do
  Begin
  {Le Label n'est pas transparent}
  Transparent:=True;
  {Couleur du Label}
  Font.Color:=AColor;
  {Style de la police}
  Font.Name:=AFontName;
  {Taille de la police}
  Font.Size:=ASize;
  {Contenu du Label}
  Caption:=AText;
  {On place le Label au milieu de l'image}
  Left:=(2*PlayerForm.Player_Image.Left+PlayerForm.Player_Image.Width-Width)div 2;
  Top:=Main.VisualImage.Top;
  {On rend le Label Visible}
  Visible:=True;
  End;
End;

{>>LECTURE DU SON  A LA VOLEE DANS PLAYERFORM}
Procedure ExtractSound(BegSnd,EndSnd : Cardinal);
Var
  MSA : TMemoryStream;
  FSA : TFileStream;
Begin
FSA:=TFileStream.Create(SndPlayer,fmOpenRead);
MSA:=TMemoryStream.Create;
FSA.Position:=BegSnd;
  Try
  MSA.CopyFrom(FSA,EndSnd);
  MSA.Position:=0;
  SndPlaySound(MSA.Memory,SND_MEMORY or SND_ASYNC);
  Finally
  FreeAndNil(FSA);
  FreeAndNil(MSA);
  End;
End;


end.
 