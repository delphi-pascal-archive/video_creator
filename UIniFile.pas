unit UIniFile;

interface

Uses IniFiles,Classes,SysUtils,dialogs;

Procedure WriteStringIni(AIniFile,ASection,AKey,AValue : String);
Procedure WriteIntIni(AIniFile,ASection,AKey : String; AValue : Integer);
Function ReadASection(AIniFile,ASection : String) : LongInt;
Function StringReadIni(AIniFile,ASection,AKey : String): String;
Function IntReadIni(AIniFile,ASection,AKey : String): Cardinal;
Function WindowsVersion: string;

implementation

{>>ULTRA BASIQUE : DONC NON COMMENTÉ}

{>>ECRIRE UN STRING DANS UN FICHIER INI}
Procedure WriteStringIni(AIniFile,ASection,AKey,AValue : String);
Var
  FileIni : TIniFile;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  FileIni.WriteString(ASection,AKey,AValue);
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='95') then FileIni.UpdateFile;
End;

{>>ECRIRE UN INTEGER DANS UN FICHIER INI}
Procedure WriteIntIni(AIniFile,ASection,AKey : String; AValue : Integer);
Var
  FileIni : TIniFile;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  FileIni.WriteInteger(ASection,AKey,AValue);
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='95') then FileIni.UpdateFile;
End;

{>>LIRE UNE SECTION D'UN FICHIER INI}
Function ReadASection(AIniFile,ASection : String) : LongInt;
var
  FileIni: TiniFile;
  i : LongInt;
begin
FileIni:=TIniFile.Create(AIniFile);
i:=0;
while FileIni.ValueExists(ASection,IntToStr(i)) do
  Begin
  inc(i);
  If (WindowsVersion='95') or (WindowsVersion='95') then FileIni.UpdateFile;
  End;
FileIni.Free;
Result:=i;
End;

{>>LIRE UN STRING D'UNE SECTION D'UN FICHIER INI}
Function StringReadIni(AIniFile,ASection,AKey : String): String;
Var
  FileIni : TIniFile;
  AValue : String;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  AValue:='';
  AValue:=FileIni.ReadString(ASection,AKey,'');
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='95') then FileIni.UpdateFile;
Result:=AValue;
End;

{>>LIRE UN INTEGER D'UNE SECTION D'UN FICHIER INI}
Function IntReadIni(AIniFile,ASection,AKey : String): Cardinal;
Var
  FileIni : TIniFile;
  AValue : Cardinal;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  AValue:=FileIni.ReadInteger(ASection,AKey,0);
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='95') then FileIni.UpdateFile;  
Result:=AValue;
End;

Function WindowsVersion: string;
begin
  case Win32MajorVersion of
    3: Result:='NT 3.51';
    4: case Win32MinorVersion of
         0:  case Win32Platform of
               1: Result:='95';
               2: Result:='NT 4.0'
             else
               Result:='Inconnue';
             end;
         10: Result:='98';
         90: Result:='Millennium';
       else
         Result:='Inconnue';
       end;
    5: case Win32MinorVersion of
         0:  Result:='2000';
         1:  Result:='XP';
         2:  Result:='Server 2003';
       else
         Result:='Inconnue';
       end;
  else
    Result:='Inconnue';
  end;
end;


end.
