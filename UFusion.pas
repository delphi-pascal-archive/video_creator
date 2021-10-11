unit UFusion;

interface

Uses Windows,ShellAPI,Forms,ComCtrls,Registry,SysUtils,Classes,dialogs,JPeg,Graphics;

Function CreateTemporyFiles : string;
procedure DeleteTempory;
Procedure BmpConversion(SourceFile,DestFile : string);
Procedure SortAndFusionFiles(ImgFile,SndFile,IniFile : string);
Procedure AddInfo(AInfo,AFinalFile : string);
Function AddFile(ASourceFile,ADestFile : String) : cardinal;
Procedure Fusion(AFile : string);

Var
FolderTemp,AFolder : String;

implementation

Uses Principal,UIniFile;

{>>CREATION D'UN DOSSIER TEMPORAIRE}

Function CreateTemporyFiles : string;
Var
  Temp : array[0..255] of char;
Begin
GetTempPath(SizeOf (Temp), Temp);
If not DirectoryExists(Temp+AFolder) then CreateDir(Temp+AFolder);
Result:=Temp+AFolder+'\';
End;

{>>SUPPESSION DU DOSSIER TEMPORAIRE}
procedure DeleteTempory;
Var
  Temp,TabFrom : array[0..255] of char;
  Folder : String;
  lpFileOp:TSHFILEOPSTRUCTA;
  i:integer;
  Handle:HWND;
begin
Handle:=0;  
GetTempPath(SizeOf (Temp), Temp);
Folder:=Temp+AFolder;
If not DirectoryExists(Folder) then Exit;
for i:=0 to length(Folder)-1 do TabFrom[i]:=Folder[i+1];
TabFrom[length(Folder)]:=#0;
TabFrom[length(Folder)+1]:=#0;
lpFileOp.Wnd:=handle;
{l'action sera un effacement}
lpFileOp.wFunc:=FO_DELETE;
{contient le ou les fichiers /dossiers à recopier}
lpFileOp.pFrom:=TabFrom;
lpFileOp.pTo:='';
lpFileOp.fFlags:=FOF_NOCONFIRMATION;
{procède à l'effacement}
SHFileOperation(lpFileOp);
end;

{>>CONVERSION D'UN BMP EN JPEG}
Procedure BmpConversion(SourceFile,DestFile : string);
var
  AJPEG : TJPEGImage;
  ABitmap : TBitmap;
begin
AJPEG := TJPEGImage.Create;
ABitmap := TBitmap.Create;
ABitmap.LoadFromFile(SourceFile);
AJPEG.GrayScale:=False;
AJPEG.Assign(ABitmap); 
AJPEG.SaveToFile(DestFile);
AJPEG.Free;
ABitMap.Free;
End;

{>>RECHERCHE ET FUSION DES FICHIERS}
Procedure SortAndFusionFiles(ImgFile,SndFile,IniFile : string);
Var
  NumNode,RealNode : LongInt;
  SizeFile : Cardinal;
  ImgName,ImgNewName : String;
Begin
With Main.ImageFiles_TreeView do
	Begin
	For NumNode:=0 to (Items.Count-1) do
		Begin
      Case Items[NumNode].ImageIndex of
				0 :	Begin
            ImgName:=Items[NumNode].Text;
            If Copy(ImgName,Length(ImgName)-2,Length(ImgName))='bmp' then
              Begin
              ImgNewName:=FolderTemp+'\'+ExtractFileName(ChangeFileExt(ImgName,'.jpg'));
              BmpConversion(ImgName,ImgNewName);
              ImgName:=ImgNewName;
              End;
					  SizeFile:=AddFile(ImgName,ImgFile);
            If NumNode=0 then RealNode:=NumNode Else RealNode:=(Items[NumNode].getPrevSibling.Index+1);
            WriteIntIni(IniFile,'Images',IntToStr(RealNode),SizeFile);
					  End;
				1 : WriteStringIni(IniFile,'Text',IntToStr(Items[NumNode].parent.Index),Items[NumNode].Text);
				2 : WriteStringIni(IniFile,'Parameters',IntToStr(Items[NumNode].parent.Index),Items[NumNode].Text);
				3 :	Begin
					  SizeFile:=AddFile(Items[NumNode].Text,SndFile);
					  WriteIntIni(IniFile,'Sounds',IntToStr(Items[NumNode].parent.Index),SizeFile);
					  End;
		 End;
		End;
	End;		
End;

{>>ADDITION D'UN FICHIER}
Function AddFile(ASourceFile,ADestFile : String) : cardinal;
Var
  SourceFS,DestFS : TFileStream;
  ASize : Cardinal;
Begin			
SourceFS:=TFileStream.Create(ASourceFile,fmOpenRead);
ASize:=SourceFS.Size;
If FileExists(ADestFile) then DestFS:=TFileStream.Create(ADestFile,fmOpenWrite)
Else DestFS:=TFileStream.Create(ADestFile,fmCreate);
	Try
	DestFS.Position:=DestFS.Size;
	DestFS.CopyFrom(SourceFS,ASize);
	Finally
	FreeAndNil(DestFS);
	FreeAndNil(SourceFS);
	End;
Result:=ASize;
End;

{>>AJOUT DES INFORMATIONS POUR L'EXTRACTION}
Procedure AddInfo(AInfo,AFinalFile : string);
Var
  FS : TFileStream;
  MS : TMemoryStream;
begin
FS := TFileStream.Create(AFinalFile,fmOpenRead);
MS := TMemoryStream.Create;
  Try
  MS.Write(PChar(AInfo)^,Length(AInfo));
  MS.Position:=MS.Size;
  MS.CopyFrom(FS,FS.Size);
  Finally
  FreeAndNil(FS);
  MS.SaveToFile(AFinalFile);
  FreeAndNil(MS);
  End;
end;

{>>PROCEDURE GENERALE POUR LA FUSION}
Procedure Fusion(AFile : string);
Var
  Info,ImgFile,SndFile,IniFile : string;
  ImgSize,SndSize,IniSize : Cardinal;
Begin
AFolder:='TemporyVideoCreator';
FolderTemp:=CreateTemporyFiles;
ImgFile:=FolderTemp+'ImagesCreator.Ima';
SndFile:=FolderTemp+'SoundsCreator.sod';
IniFile:=FolderTemp+'IniCreator.Ini';
SortAndFusionFiles(ImgFile,SndFile,IniFile);
If FileExists(ImgFile) then ImgSize:=AddFile(ImgFile,AFile) Else ImgSize:=0;
If FileExists(SndFile) then SndSize:=AddFile(SndFile,AFile) Else SndSize:=0;
If FileExists(IniFile) then IniSize:=AddFile(IniFile,AFile) Else IniSize:=0;
Info:=IntToStr(ImgSize)+'-'+IntToStr(SndSize)+'-'+IntToStr(IniSize)+'|';
AddInfo(Info,AFile);
DeleteTempory;
End;


end.
 