unit UExtraction;

interface

Uses Dialogs,SysUtils,Classes,ExtCtrls,StdCtrls;

Procedure ExtractFilmParts(AFile : string);
Procedure ExtractFile(ASourceFile,ADestFile : string; BeginSize,EndSize : Cardinal);
Procedure VideoPlaying(SoundTag,TextTag : integer);
Procedure FilePositions(ASection : string;Var BegFile,EndFile : Cardinal );

implementation

Uses UFusion,UPlayer,UIniFile,UImageAndComments;

{>>EXCTRATION DES FICHIERS CONSTITUTIFS}
Procedure ExtractFilmParts(AFile : string);
Var
  Info : String;
  LenghtInfo,ImagesSize,SoundsSize,IniSize : Cardinal;
  FS : TFileStream;
  ALine:array[0..255] of char;
Begin
FS:=TFileStream.Create(AFile,fmOpenRead);
  Try
  FS.Read(ALine,Length(ALine));
  Finally
  FreeAndNil(FS);
  End;
Info:=string(ALine);
LenghtInfo:=Length(Copy(Info,1,Pos('|',Info)));
ImagesSize:=StrToInt(Copy(Info,1,Pos('-',Info)-1));
Delete(Info,1,Pos('-',Info));
SoundsSize:=StrToInt(Copy(Info,1,Pos('-',Info)-1));
Delete(Info,1,Pos('-',Info));
IniSize:=StrToInt(Copy(Info,1,Pos('|',Info)-1));
ExtractFile(AFile,ImgPlayer,LenghtInfo,ImagesSize);
If SoundsSize<>0 then ExtractFile(AFile,SndPlayer,LenghtInfo+ImagesSize,SoundsSize);
ExtractFile(AFile,IniPlayer,LenghtInfo+ImagesSize+SoundsSize,IniSize);
End;

{>>EXCTRACTION D'UN FICHIER}
Procedure ExtractFile(ASourceFile,ADestFile : string; BeginSize,EndSize : Cardinal);
Var
  SourceFS,DestFS: TFileStream;
Begin
SourceFS:=TFileStream.Create(ASourceFile,fmOpenRead);
DestFS:=TFileStream.Create(ADestFile,fmCreate);
SourceFS.Position:=BeginSize;
  Try
  DestFS.CopyFrom(SourceFS,EndSize);
  Finally
  FreeAndNil(DestFS);
  FreeAndNil(SourceFS);
  End;
End;

{>>LECTURE D'UNE VIDEO}
Procedure VideoPlaying(SoundTag,TextTag : integer);
Var 
  BegImg,EndImg,BegSnd,EndSnd : Cardinal;
  AText,Parameters,AFontName : String;
  AColor,Asize : integer;
Begin
PlayerForm.Label_Player_Lb.Visible:=False;
FilePositions('Images',BegImg,EndImg);
FilePositions('Sounds',BegSnd,EndSnd);
AText:=StringReadIni(IniPlayer,'Text',IntToStr(VideoIndex));
Parameters:=StringReadIni(IniPlayer,'Parameters',IntToStr(VideoIndex)); 
If EndImg=0 then
  Begin
  PlayerForm.Player_Image.Picture.Bitmap:=nil;
  PlayerForm.PlayerTimer.Enabled:=False;
  End
Else ExtractAndShowImage(BegImg,EndImg);
If (AText<>'') and (Parameters<>'') and (TextTag=1) then
  Begin
  ExtractInfo(Parameters,AColor,Asize,AFontName);
  ShowTextInPlayer(Parameters, AText);
  End;
If (EndSnd<>0) and (SoundTag=1) then
ExtractSound(BegSnd,EndSnd);
End;

{>>DETERMINATION DES EXTREMUMS D'UN FICHIER}
Procedure FilePositions(ASection : string;Var BegFile,EndFile : Cardinal );
Var
  NumVideo : LongInt;
Begin
BegFile:=0;
EndFile:=0;
If VideoIndex=0 then BegFile:=0 Else
  Begin
  For NumVideo:=1 to VideoIndex do
  BegFile:=BegFile+IntReadIni(IniPlayer,ASection,IntToStr(NumVideo-1));
  End;
EndFile:=IntReadIni(IniPlayer,ASection,IntToStr( VideoIndex));
End;

end.
