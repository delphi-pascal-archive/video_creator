unit UPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls,Math,MMSystem;

type
  TPlayerForm = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Panel3: TPanel;
    Image2: TImage;
    Stop_Off: TImage;
    Bk_Off: TImage;
    FF_Off: TImage;
    Sound_Off: TImage;
    Text_Off: TImage;
    Text_On: TImage;
    During_Lb: TLabel;
    Time_Lb: TLabel;
    Open_Off: TImage;
    Play_Off: TImage;
    Open_On: TImage;
    Play_On: TImage;
    Stop_On: TImage;
    Bk_On: TImage;
    FF_On: TImage;
    Sound_On: TImage;
    Image3: TImage;
    Title_Ed: TEdit;
    State_Ed: TEdit;
    speed_TrBr: TTrackBar;
    Panel2: TPanel;
    Player_Image: TImage;
    Label_Player_Lb: TLabel;
    PlayerTimer: TTimer;
    Luminosity_CB: TCheckBox;
    Procedure ChangeSlowlyLuminosity(Action : integer);
    Procedure ChangeLuminosity(Brightness: integer);
    Function FindActualGamma : integer;
    Function GetWaveVolume : DWord;
    procedure SetWaveVolume(Volume: DWord);
    Function DuringOfFilm(AInterval : Integer) : string;
    Function FormatADuring(During : LongInt) : string;
    procedure Open_OnClick(Sender: TObject);
    procedure Play_OnClick(Sender: TObject);
    procedure PlayerTimerTimer(Sender: TObject);
    procedure Stop_OffClick(Sender: TObject);
    procedure Bk_OnClick(Sender: TObject);
    procedure FF_OnClick(Sender: TObject);
    procedure Sound_OnClick(Sender: TObject);
    procedure Sound_OffClick(Sender: TObject);
    procedure Text_OnClick(Sender: TObject);
    procedure Text_OffClick(Sender: TObject);
    procedure speed_TrBrChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Stop_OnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PlayerForm: TPlayerForm;
  IniPlayer,ImgPlayer,SndPlayer : String;
  Pas : integer;
  VideoIndex: LongInt;
  LevelSound : DWord;

implementation

uses Principal,UExtraction,UFusion,UIniFile;

{$R *.dfm}

{>>DETERMINATION DE LA LUMINOSITE ACTUELLE}
Function TPlayerForm.FindActualGamma : integer;
var
  hGammaDC : HDC;
  GammaArray: array[0..2,0..255] of word;
begin
hGammaDC := GetDC(0);
GetDeviceGammaRamp(hGammaDC, GammaArray);
ReleaseDC(0, hGammaDC);
result:=GammaArray[0,1]-128;
end;

{>>ACTUALISATION DE LA LUMINOSITE ACTUELLE}
Procedure TPlayerForm.ChangeLuminosity(Brightness: integer);
var
  hGammaDC : HDC;
  GammaArray: array[0..2] of array [0..255] of word;
  Index, ArrayValue: integer;
begin
hGammaDC := GetDC(0);
for Index := 0 to 255 do
  begin
  ArrayValue := Index * (Brightness + 128);
  if (ArrayValue > 65535) then ArrayValue := 65535;
  GammaArray[0,Index] := WORD(ArrayValue);
  GammaArray[1,Index] := WORD(ArrayValue);
  GammaArray[2,Index] := WORD(ArrayValue);
  end;
SetDeviceGammaRamp(hGammaDC, GammaArray);
ReleaseDC(0, hGammaDC);
end;

Procedure TPlayerForm.ChangeSlowlyLuminosity(Action : integer);
Var 
  i,ActualGamma : integer;
Begin
ActualGamma:=FindActualGamma;
  Case Action of
  0 : For i:=ActualGamma downto 64 do ChangeLuminosity(i);
  1 : For i:=ActualGamma to 128 do ChangeLuminosity(i);
  End;
End;

{>>Volume du son}
procedure TPlayerForm.SetWaveVolume(Volume: DWord);
var
  Caps : TWAVEOUTCAPS;
begin
if WaveOutGetDevCaps(WAVE_MAPPER, @Caps, sizeof(Caps)) =MMSYSERR_NOERROR then
if Caps.dwSupport and WAVECAPS_VOLUME = WAVECAPS_VOLUME then
WaveOutSetVolume(Integer(WAVE_MAPPER),Volume);
end;

Function TPlayerForm.GetWaveVolume : DWord;
var
  Caps : TWAVEOUTCAPS;
  Volume : DWord;
begin
if WaveOutGetDevCaps(WAVE_MAPPER, @Caps, sizeof(Caps)) =MMSYSERR_NOERROR then
if Caps.dwSupport and WAVECAPS_VOLUME = WAVECAPS_VOLUME then
WaveOutGetVolume(Integer(WAVE_MAPPER), @Volume);
Result:=Volume;
end;

Function TPlayerForm.DuringOfFilm(AInterval : Integer) : string;
Var
  NbImage,During : LongInt;
begin
{On récupère le contenu de la section Image dans AListKeys}
NbImage:=ReadASection(IniPlayer,'Images');
{On définit la durée en seconde}
During:=(NbImage) * AInterval div 1000;
{On définit le résultat}
Result:=FormatADuring(During);
End;

Function TPlayerForm.FormatADuring(During : LongInt) : string;
Var
Hour,Min,Sec : integer;
begin
{Floor arrondi à l'entier inférieur}
If During<0 then Hour:=0 Else Hour:= floor(During div 3600);
If During<0 then Min:=0 Else Min:= floor((During-Hour*3600)div 60);
If During<0 then Sec:=0 Else sec:= floor(During-Hour*3600-Min*60);
{Résultat sous la forme Hrs:Min:Sec}
Result:=format('%.2d:%.2d:%.2d',[Hour,Min,Sec]);
End;

procedure TPlayerForm.Open_OnClick(Sender: TObject);
Begin
State_Ed.Text:='Wait Please';
With Main.OpenDialog1 do
  Begin
  Filter:='Fichier Video Creator|*.fvc';
  If not Execute then Exit;
  Title_Ed.Text:=FileName;
  AFolder:='TemporyPlayerVideoCreator';
  FolderTemp:=CreateTemporyFiles;
  ImgPlayer:=FolderTemp+'Images.ima';
  SndPlayer:=FolderTemp+'Sounds.sod';
  IniPlayer:=FolderTemp+'Player.ini';
  ExtractFilmParts(FileName);
  During_Lb.Caption:=DuringOfFilm(speed_TrBr.Position);
  VideoIndex:=0;
end;
PLay_On.Visible:= True;
Open_Off.Visible:= True;
State_Ed.Text:='Go';
Time_Lb.Caption:='00:00:00';
If Luminosity_CB.Checked then ChangeSlowlyLuminosity(0);
end;

procedure TPlayerForm.Play_OnClick(Sender: TObject);
begin
Play_On.Visible:=False;
Open_On.Visible:=False;
Stop_On.Visible:=True;
Bk_On.Visible:=True;
FF_On.Visible:=True;
PlayerTimer.Interval:=speed_TrBr.Position;
Pas:=1;
PlayerTimer.Enabled:=True;
end;

procedure TPlayerForm.PlayerTimerTimer(Sender: TObject);
Var
SoundTag,TextTag : Integer;
begin
If SOund_On.Visible=True then SoundTag:=1 Else SoundTag:=0;
If Text_On.Visible=True then TextTag:=1 Else TextTag:=0;  
VideoPlaying(SoundTag,TextTag);
Time_Lb.Caption:=FormatADuring(VideoIndex*(speed_TrBr.Position) div 1000);
VideoIndex:=VideoIndex+Pas;
end;

procedure TPlayerForm.Stop_OffClick(Sender: TObject);
begin
PlayerTimer.Enabled:=False;
Stop_On.Visible:=False;
Play_On.Visible:=True;
Bk_On.Visible:= False;
FF_On.Visible:= False;
Open_On.Visible:=True;
end;

procedure TPlayerForm.Bk_OnClick(Sender: TObject);
begin
FF_On.Visible:=True;
Bk_On.Visible:=False;
Stop_On.Visible:=True;
PlayerTimer.Interval:=speed_TrBr.Position div 10;
Pas:=-1;
PlayerTimer.Enabled:=True;
end;

procedure TPlayerForm.FF_OnClick(Sender: TObject);
begin
FF_On.Visible:=False;
Bk_On.Visible:=True;
Stop_On.Visible:=True;
PlayerTimer.Interval:=speed_TrBr.Position div 10;
Pas:=1;
PlayerTimer.Enabled:=True;
end;

procedure TPlayerForm.Sound_OnClick(Sender: TObject);
begin
Sound_On.Visible:=False;
LevelSound:=GetWaveVolume;
SetWaveVolume(0);
end;

procedure TPlayerForm.Sound_OffClick(Sender: TObject);
begin
Sound_On.Visible:=True;
SetWaveVolume(LevelSound);
end;

procedure TPlayerForm.Text_OnClick(Sender: TObject);
begin
Text_On.Visible:=False;
end;

procedure TPlayerForm.Text_OffClick(Sender: TObject);
begin
Text_On.Visible:=True;
end;

procedure TPlayerForm.speed_TrBrChange(Sender: TObject);
begin
During_Lb.Caption:=DuringOfFilm(speed_TrBr.Position);
end;

procedure TPlayerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
{On revient à une luminosité maximum}
ChangeSlowlyLuminosity(1);
halt(0);
end;

procedure TPlayerForm.Stop_OnClick(Sender: TObject);
begin
PlayerTimer.Enabled:=False;
Stop_On.Visible:=False;
Play_On.Visible:=True;
Bk_On.Visible:= False;
FF_On.Visible:= False;
Open_On.Visible:=True;
end;

end.
