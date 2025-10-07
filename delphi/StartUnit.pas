Unit StartUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
    Vcl.ExtCtrls,
    Vcl.Imaging.Pngimage, Vcl.Menus, CardSystem, MainUnit;

Const
    MAX_PLAYERS = 16;

Type
    TSaveFile = File Of TGameSave;

    TStartMenuForm = Class(TForm)
        ExitButtonLabel: TLabel;
        StartMainMenu: TMainMenu;
        AboutDeveloperMenuItem: TMenuItem;
        RulesLabel: TLabel;
        Zagolovok: TImage;
        Background: TImage;
        NewGameLabel: TLabel;
        ConnectionLabel: TLabel;
        OpenFileMenuItem: TMenuItem;

        Procedure ExitButtonLabelClick(Sender: TObject);
        Procedure AboutDeveloperMenuItemClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure LabelMouseEnter(Sender: TObject);
        Procedure LabelMouseLeave(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
        Procedure NewGameLabelClick(Sender: TObject);
        Procedure ConnectionLabelClick(Sender: TObject);
        Procedure RulesLabelClick(Sender: TObject);
        Procedure OpenFileMenuItemClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    StartMenuForm: TStartMenuForm;

Implementation

{$R *.dfm}

Uses
    SeedEnterUnit, DeveloperUnit, PreparationUnit, RuleUnit;

Procedure TStartMenuForm.AboutDeveloperMenuItemClick(Sender: TObject);
Begin
    DeveloperForm.ShowModal;
End;

Procedure TStartMenuForm.NewGameLabelClick(Sender: TObject);
Begin
    StartMenuForm.Visible := False;
    PreparationForm.ShowModal;
    StartMenuForm.Visible := True;
End;

Procedure TStartMenuForm.ConnectionLabelClick(Sender: TObject);
Begin
    StartMenuForm.Visible := False;
    SeedEnterForm.ShowModal;
    StartMenuForm.Visible := True;
End;

Procedure TStartMenuForm.ExitButtonLabelClick(Sender: TObject);
Begin
    StartMenuForm.Close;
End;

Procedure TStartMenuForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    CanClose := MessageBox(Handle, 'Вы действительно хотите выйти?',
        'Вы уверены?', MB_YESNO Or MB_ICONQUESTION) = IDYES;
End;

Function TStartMenuForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TStartMenuForm.OpenFileMenuItemClick(Sender: TObject);
Begin
    GenerateGameSetup(GameSetup, 1001, 4);
    StartMenuForm.Visible := False;
    CurrentPlayerIndex := 0;
    Try
        MainForm.ShowModal;
    Finally
        StartMenuForm.Visible := True;
    End;
End;

Procedure TStartMenuForm.RulesLabelClick(Sender: TObject);
Begin
    StartMenuForm.Visible := False;
    RuleForm.ShowModal;
    StartMenuForm.Visible := True;
End;

Procedure TStartMenuForm.LabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Size := Font.Size + 5;
        Top := Top - 8;
    End;
End;

Procedure TStartMenuForm.LabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Size := Font.Size - 5;
        Top := Top + 8;
    End;
End;

End.
