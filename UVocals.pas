unit UVocals;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, Buttons,MMSystem;

type
  TVocalForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Sound_Ed: TEdit;
    Sound_Bt: TSpeedButton;
    ImageFilesAdd_Bt: TSpeedButton;
    procedure Sound_BtMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Sound_BtMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageFilesAdd_BtClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VocalForm: TVocalForm;

implementation

uses Principal,UTreeView;

{$R *.dfm}

{>>DEMARRAGE DE L'ENREGISTREMENT}
procedure TVocalForm.Sound_BtMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
Label1.Caption:='Capture en cours';
mciSendString('open new type waveaudio alias capture', nil, 0, 0);
mciSendString('seek capture to start', nil, 0, 0);
mciSendString('set capture samplespersec 44100', nil, 0, 0);
mciSendString('set capture channels 2', nil, 0, 0);
mciSendString('record capture', nil, 0, 0);
end;

{>>FIN DE L'ENREGISTREMENT}
procedure TVocalForm.Sound_BtMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  NameOfFile : string;
begin
mciSendString(PChar('save capture "'+ExtractFilePath(ParamStr(0))+'AudioCreator.Wav"'), nil, 0, 0);
mciSendString('stop capture', nil, 0, 0);
mciSendString('close capture', nil, 0, 0);
mciSendString('close all', nil, 0, 0);
Label1.Caption:='Commencer la capture';
ShowMessage('Sauvegarder l''enregistrement');
With Main.SaveDialog1 do
  Begin
  Filter:='Fichier Son|*.wav';
  If Execute then
    Begin
    If ExtractFileExt(FileName)='' then NameOfFile:=FileName+'.wav' Else NameOfFile:=FileName;
    CopyFile(PChar(ExtractFilePath(ParamStr(0))+'AudioCreator.Wav'),PChar(NameOfFile),False);
    AddCommentInTreeView(NameOfFile,3);
    End;
  End;
end;

{>>AJOUT DU SON DANS LE TREENODE}
procedure TVocalForm.ImageFilesAdd_BtClick(Sender: TObject);
begin
{Si la sélection est non vide}
If (Main.ImageFiles_TreeView.selected<>nil) then
  Begin
  {avec l'opendialog}
  With Main.OpenDialog1 do
    Begin
    {on définit le filtre}
    Filter:='Fichier Son|*.wav';
    {On l'execute}
    Execute;
    Sound_Ed.Text:=FileName;
    {On ajoute le nom du fichier wav dans le TreeView}
    AddCommentInTreeView(FileName,3);
    end;
  End;
end;

end.
