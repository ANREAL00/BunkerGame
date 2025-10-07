Unit SeedEnterUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.StdCtrls, Vcl.Menus, Clipbrd, Vcl.Imaging.Pngimage, Vcl.ExtCtrls;

Type
    TSeedEnterForm = Class(TForm)
        Background: TImage;
        Zagolovok: TImage;
        BackButtonLabel: TLabel;
        NextLabel: TLabel;
        FirstField: TImage;
        SecondField: TImage;
        ThirdField: TImage;
        FourthField: TImage;
        El1: TImage;
        El2: TImage;
        El3: TImage;
        El4: TImage;
        El5: TImage;
        El6: TImage;
        El7: TImage;
        El8: TImage;
        El9: TImage;
        El0: TImage;
        ElBack: TImage;
        RulesLabel: TLabel;
        FirstNum: TLabel;
        SecondNum: TLabel;
        ThirdNum: TLabel;
        FourthNum: TLabel;
        Procedure BackButtonLabelClick(Sender: TObject);
        Procedure NextLabelClick(Sender: TObject);
        Procedure NumberClick(Sender: TObject);
        Procedure NumberDblClick(Sender: TObject);
        Procedure ShowSeed(Sender: TObject; Const Seed: String);
        Procedure ElBackClick(Sender: TObject);
        Procedure ElBackDblClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    SeedEnterForm: TSeedEnterForm;
    Seed: String;

Const
    KBACKSPACE = #8;
    KMINUS = #45;
    KCOMMA = #44;
    KDOWN = 40;
    KUP = 38;
    KENTER = 13;
    KINSERT = 45;

Implementation

{$R *.dfm}

Uses
    ConnectUnit;

Procedure TSeedEnterForm.ShowSeed(Sender: TObject; Const Seed: String);
Var
    IntSeed: Integer;
    I: Integer;
Begin
    FirstNum.Caption := '';
    SecondNum.Caption := '';
    ThirdNum.Caption := '';
    FourthNum.Caption := '';

    If TryStrToInt(Seed, IntSeed) Then
    Begin
        Case Length(Seed) Of
            1:
                FirstNum.Caption := Seed;
            2:
                Begin
                    FirstNum.Caption := IntToStr(IntSeed Div 10);
                    SecondNum.Caption := IntToStr(IntSeed Mod 10);
                End;
            3:
                Begin
                    FirstNum.Caption := IntToStr(IntSeed Div 100);
                    SecondNum.Caption := IntToStr(IntSeed Div 10 Mod 10);
                    ThirdNum.Caption := IntToStr(IntSeed Mod 10);
                End;
            4:
                Begin
                    FirstNum.Caption := IntToStr(IntSeed Div 1000);
                    SecondNum.Caption := IntToStr(IntSeed Div 100 Mod 10);
                    ThirdNum.Caption := IntToStr(IntSeed Div 10 Mod 10);
                    FourthNum.Caption := IntToStr(IntSeed Mod 10);
                End;
        End;
    End;
End;

Procedure TSeedEnterForm.BackButtonLabelClick(Sender: TObject);
Begin
    Close;
End;

Procedure TSeedEnterForm.NumberClick(Sender: TObject);
Begin
    If (Sender Is TImage) And (Length(Seed) < 1) Then
    Begin
        Seed := Seed + Copy(TImage(Sender).Name, 3, 1);
        If Seed = '0' Then
        Begin
            Seed := '';
        End;
        ShowSeed(Self, Seed);
    End
    Else If (Sender Is TImage) And (Length(Seed) < 4) Then
    Begin
        Seed := Seed + Copy(TImage(Sender).Name, 3, 1);
        ShowSeed(Self, Seed);
    End;
End;

Procedure TSeedEnterForm.NumberDblClick(Sender: TObject);
Begin
    NumberClick(Sender);
End;

Procedure TSeedEnterForm.ElBackClick(Sender: TObject);
Begin
    If Length(Seed) > 0 Then
    Begin
        Delete(Seed, Length(Seed), 1);
        ShowSeed(Self, Seed);
    End;
End;

Procedure TSeedEnterForm.ElBackDblClick(Sender: TObject);
Begin
    ElBackClick(Sender);
End;

Function TSeedEnterForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Function GetPlayerCountFromSeed(Seed: Integer): Integer;
Const
    TOTAL_SEEDS = 9000;
    PLAYER_RANGES = 13;
    SEEDS_PER_PLAYER = TOTAL_SEEDS Div PLAYER_RANGES;
Begin
    Result := 4 + ((Seed - 1000) Div SEEDS_PER_PLAYER);
    If Seed >= 1000 + (SEEDS_PER_PLAYER * 12) Then
        Result := 16;
End;

Procedure TSeedEnterForm.NextLabelClick(Sender: TObject);
Begin
    If Length(Seed) = 4 Then
    Begin
        Visible := False;
        IntSeed := StrToInt(Seed);
        ColPlayers := GetPlayerCountFromSeed(IntSeed);
        Try
            ConnectForm.ShowModal;
        Finally
            Visible := True;
        End;
    End;
End;

End.
