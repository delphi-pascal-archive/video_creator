program VideoCreator;

uses
  Forms,
  Principal in 'Principal.pas' {Main},
  UImageAndComments in 'UImageAndComments.pas',
  UTreeView in 'UTreeView.pas',
  UText in 'UText.pas' {TextForm},
  UVocals in 'UVocals.pas' {VocalForm},
  UPaint in 'UPaint.pas' {PaintForm},
  UFusion in 'UFusion.pas',
  UIniFile in 'UIniFile.pas',
  UPlayer in 'UPlayer.pas' {PlayerForm},
  UExtraction in 'UExtraction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TTextForm, TextForm);
  Application.CreateForm(TVocalForm, VocalForm);
  Application.CreateForm(TPaintForm, PaintForm);
  Application.CreateForm(TPlayerForm, PlayerForm);
  Application.Run;
end.
