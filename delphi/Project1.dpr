Program Project1;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles,
  DeveloperUnit in 'DeveloperUnit.pas' {DeveloperForm},
  StartUnit in 'StartUnit.pas' {StartMenuForm},
  PreparationUnit in 'PreparationUnit.pas' {PreparationForm},
  SeedEnterUnit in 'SeedEnterUnit.pas' {SeedEnterForm},
  ConnectUnit in 'ConnectUnit.pas' {ConnectForm},
  CardSystem in 'CardSystem.pas',
  FinalUnit in 'FinalUnit.pas' {FinalForm},
  GameTypesUnit in 'GameTypesUnit.pas',
  RuleUnit in 'RuleUnit.pas' {RuleForm};

{$R *.res}

Begin
    Application.Initialize;
    // Application.MainFormOnTaskbar := True;
    Application.CreateForm(TStartMenuForm, StartMenuForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDeveloperForm, DeveloperForm);
  Application.CreateForm(TPreparationForm, PreparationForm);
  Application.CreateForm(TSeedEnterForm, SeedEnterForm);
  Application.CreateForm(TConnectForm, ConnectForm);
  Application.CreateForm(TFinalForm, FinalForm);
  Application.CreateForm(TRuleForm, RuleForm);
  Application.Run;

End.
