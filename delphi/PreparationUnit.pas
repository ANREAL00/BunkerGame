Unit PreparationUnit;

Interface

Uses
    System.DateUtils, Winapi.Windows, Winapi.Messages, System.SysUtils,
    System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
    Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.Menus, Clipbrd, MainUnit,
    Vcl.Imaging.Pngimage, Vcl.ExtCtrls;

Type
    TPreparationForm = Class(TForm)
        Background: TImage;
        PlayersCol: TImage;
        BackButtonLabel: TLabel;
        Left: TImage;
        Right: TImage;
        ColPlayersLabel: TLabel;
        Zagolovok: TImage;
        RulesLabel: TLabel;
        NextLabel: TLabel;
        Procedure BackButtonLabelClick(Sender: TObject);
        Procedure LeftClick(Sender: TObject);
        Procedure RightClick(Sender: TObject);
        Procedure NextLabelClick(Sender: TObject);
        Procedure RightDblClick(Sender: TObject);
        Procedure LeftDblClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    PreparationForm: TPreparationForm;

Implementation

{$R *.dfm}

Uses
    ConnectUnit;

Const
    KBACKSPACE = #8;
    KINSERT = 45;
    MIN_SEED = 1000;
    MAX_SEED = 9999;
    PLAYER_RANGES = 13;
    MIN_PLAYERS = 4;
    MAX_PLAYERS = 16;

Function GenerateRandomSeed(PlayerCount: Integer): Integer;
Var
    SystemTime: TSystemTime;
    TickCount: DWORD;
    ProcessID: DWORD;
    CombinedValue: Int64;
    RangeSize, RangeStart, RangeEnd: Integer;
Begin
    GetSystemTime(SystemTime);
    TickCount := GetTickCount;
    ProcessID := GetCurrentProcessId;

    CombinedValue := (Int64(SystemTime.WSecond) Shl 56) Or
        (Int64(SystemTime.WMilliseconds) Shl 44) Or (Int64(TickCount) Shl 32) Or
        (Int64(ProcessID) Shl 16) Or (Int64(Random(65536)));

    RangeSize := (MAX_SEED - MIN_SEED + 1) Div PLAYER_RANGES;
    RangeStart := MIN_SEED + ((PlayerCount - MIN_PLAYERS) Mod PLAYER_RANGES) *
        RangeSize;
    RangeEnd := RangeStart + RangeSize - 1;

    If (PlayerCount - MIN_PLAYERS) Mod PLAYER_RANGES = PLAYER_RANGES - 1 Then
        RangeEnd := MAX_SEED;

    GenerateRandomSeed := RangeStart +
        (Abs(CombinedValue) Mod (RangeEnd - RangeStart + 1));
End;

Procedure TPreparationForm.BackButtonLabelClick(Sender: TObject);
Begin
    Close;
End;

Function TPreparationForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TPreparationForm.LeftClick(Sender: TObject);
Begin
    If StrToInt(ColPlayersLabel.Caption) = MIN_PLAYERS Then
        ColPlayersLabel.Caption := IntToStr(MAX_PLAYERS)
    Else
        ColPlayersLabel.Caption :=
            IntToStr(StrToInt(ColPlayersLabel.Caption) - 1);
End;

Procedure TPreparationForm.LeftDblClick(Sender: TObject);
Begin
    LeftClick(Sender);
End;

Procedure TPreparationForm.NextLabelClick(Sender: TObject);
Begin
    ColPlayers := StrToInt(ColPlayersLabel.Caption);
    IntSeed := GenerateRandomSeed(ColPlayers);
    PreparationForm.Visible := False;
    Try
        ConnectForm.ShowModal;
    Finally
        PreparationForm.Visible := True;
    End;
End;

Procedure TPreparationForm.RightClick(Sender: TObject);
Begin
    If StrToInt(ColPlayersLabel.Caption) = MAX_PLAYERS Then
        ColPlayersLabel.Caption := IntToStr(MIN_PLAYERS)
    Else
        ColPlayersLabel.Caption :=
            IntToStr(StrToInt(ColPlayersLabel.Caption) + 1);
End;

Procedure TPreparationForm.RightDblClick(Sender: TObject);
Begin
    RightClick(Sender);
End;

End.
