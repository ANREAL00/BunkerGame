Unit ConnectUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.StdCtrls, Vcl.Grids, Vcl.Imaging.Pngimage, Vcl.ExtCtrls, CardSystem,
    MainUnit;

Type
    TConnectForm = Class(TForm)
        Background: TImage;
        BackButtonLabel: TLabel;
        Zagolovok: TImage;
        RulesLabel: TLabel;
        Left: TImage;
        ColPlayersLabel: TLabel;
        Right: TImage;
        PlayersCol: TImage;
        CodeLabel: TLabel;
        Seed: TLabel;
        NextLabel: TLabel;
        Procedure BackButtonLabelClick(Sender: TObject);
        Procedure LeftClick(Sender: TObject);
        Procedure RightClick(Sender: TObject);
        Procedure RightDblClick(Sender: TObject);
        Procedure LeftDblClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure NextLabelClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
        Procedure UpdatePlayerCount(Increase: Boolean);
    Public
        { Public declarations }
    End;

Const
    DelColomn = 5;
    EditColomn = 6;
    KBACKSPACE = #8;
    KMINUS = #45;
    KCOMMA = #44;
    KDOWN = 40;
    KUP = 38;
    KENTER = 13;
    KINSERT = 45;
    MIN_PLAYERS = 1;

Var
    ConnectForm: TConnectForm;
    IntSeed: Integer;
    ColPlayers: Integer;

Implementation

{$R *.dfm}

Procedure TConnectForm.BackButtonLabelClick(Sender: TObject);
Begin
    Close;
End;

Function TConnectForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TConnectForm.FormShow(Sender: TObject);
Begin
    Seed.Caption := IntToStr(IntSeed);
    ColPlayersLabel.Caption := IntToStr(MIN_PLAYERS);
End;

Procedure TConnectForm.UpdatePlayerCount(Increase: Boolean);
Var
    CurrentCount: Integer;
Begin
    CurrentCount := StrToInt(ColPlayersLabel.Caption);

    If Increase Then
    Begin
        If CurrentCount = ColPlayers Then
            CurrentCount := MIN_PLAYERS
        Else
            Inc(CurrentCount);
    End
    Else
    Begin
        If CurrentCount = MIN_PLAYERS Then
            CurrentCount := ColPlayers
        Else
            Dec(CurrentCount);
    End;

    ColPlayersLabel.Caption := IntToStr(CurrentCount);
End;

Procedure TConnectForm.LeftClick(Sender: TObject);
Begin
    UpdatePlayerCount(False);
End;

Procedure TConnectForm.LeftDblClick(Sender: TObject);
Begin
    UpdatePlayerCount(False);
End;

Procedure TConnectForm.NextLabelClick(Sender: TObject);
Begin
    GenerateGameSetup(GameSetup, IntSeed, ColPlayers);
    ConnectForm.Visible := False;
    CurrentPlayerIndex := StrToInt(ColPlayersLabel.Caption) - 1;
    Try
        MainForm.FormCreate(Self);
        MainForm.ShowModal;
    Finally
        ConnectForm.Visible := True;
    End;
End;

Procedure TConnectForm.RightClick(Sender: TObject);
Begin
    UpdatePlayerCount(True);
End;

Procedure TConnectForm.RightDblClick(Sender: TObject);
Begin
    UpdatePlayerCount(True);
End;

End.
