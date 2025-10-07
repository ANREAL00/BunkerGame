Unit FinalUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.Pngimage, Vcl.ExtCtrls,
    Vcl.StdCtrls, Vcl.ComCtrls, CardSystem, Vcl.Imaging.Jpeg;

Type
    PBunkerSituationNode = ^TBunkerSituationNode;

    TBunkerSituationNode = Record
        Situation: TBunkerSituation;
        Next: PBunkerSituationNode;
    End;

    TBunkerSituationList = Record
        First: PBunkerSituationNode;
        Last: PBunkerSituationNode;
        Count: Integer;
    End;

    TFinalForm = Class(TForm)
        Background: TImage;
        BackButtonLabel: TLabel;
        Zagolovok: TImage;
        NoButton: TImage;
        YesButton: TImage;
        QuestionImage: TImage;
        AnimationTimer: TTimer;
        BunkerSituationImage: TImage;
        SituationTitle: TLabel;
        BunkerSituation: TLabel;
        InfoLabel: TLabel;
        Win: TImage;
        Lose: TImage;
        Procedure BackButtonLabelClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure FormDestroy(Sender: TObject);
        Procedure AnimationTimerTimer(Sender: TObject);
        Procedure NoButtonClick(Sender: TObject);
        Procedure YesButtonClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        FadeAlpha: Integer;
        SituationIndex: Integer;
        Chance: Integer;
        AnimationStep: Integer;
        BlinkCounter: Integer;
        Percent: Integer;
        CurrentTextPos: Integer;
        FullMessage: String;
        FSituations: TBunkerSituationList; // Наш список ситуаций
        CurrentSituation: PBunkerSituationNode; // Текущая ситуация
        Procedure ShowNextImage;
        Procedure FadeInImage(Img: TImage);
        Procedure BlinkImage(Img: TImage);
        Procedure InitializeSituation(SituationNode: PBunkerSituationNode);
        Function IsAllSituation: Boolean;
        Procedure CountTheChance;
        Procedure LoadSituationsFromGameSetup;
        Procedure ClearSituations;
    Public
        FGameSetup: TGameSetup;
        HasPair: Boolean;
    End;

Var
    FinalForm: TFinalForm;

Implementation

{$R *.dfm}

Procedure RestartApplication;
Var
    AppPath: Array [0 .. MAX_PATH] Of Char;
    ProcessInfo: TProcessInformation;
    StartupInfo: TStartupInfo;
Begin
    GetModuleFileName(0, AppPath, SizeOf(AppPath));

    FillChar(StartupInfo, SizeOf(StartupInfo), 0);
    StartupInfo.Cb := SizeOf(StartupInfo);

    If CreateProcess(Nil, AppPath, Nil, Nil, False, 0, Nil, Nil, StartupInfo,
        ProcessInfo) Then
    Begin
        CloseHandle(ProcessInfo.HThread);
        CloseHandle(ProcessInfo.HProcess);

        Application.Terminate;
    End;
End;

Procedure TFinalForm.ClearSituations;
Var
    Current, Next: PBunkerSituationNode;
Begin
    Current := FSituations.First;
    While Current <> Nil Do
    Begin
        Next := Current^.Next;
        Dispose(Current);
        Current := Next;
    End;
    FSituations.First := Nil;
    FSituations.Last := Nil;
    FSituations.Count := 0;
End;

Procedure TFinalForm.LoadSituationsFromGameSetup;
Var
    I: Integer;
    NewNode: PBunkerSituationNode;
Begin
    ClearSituations;

    For I := 0 To High(FGameSetup.BunkerSituations) Do
    Begin
        New(NewNode);
        NewNode^.Situation := FGameSetup.BunkerSituations[I];
        NewNode^.Next := Nil;

        If FSituations.First = Nil Then
        Begin
            FSituations.First := NewNode;
            FSituations.Last := NewNode;
        End
        Else
        Begin
            FSituations.Last^.Next := NewNode;
            FSituations.Last := NewNode;
        End;
        Inc(FSituations.Count);
    End;
End;

Procedure TFinalForm.BackButtonLabelClick(Sender: TObject);
Begin
    If MessageBox(Handle, 'Вы действительно хотите выйти?', 'Подтверждение',
        MB_YESNO Or MB_ICONQUESTION) = IDYES Then
    Begin
        RestartApplication;
    End;
End;

Procedure TFinalForm.FormCreate(Sender: TObject);
Begin
    FSituations.First := Nil;
    FSituations.Last := Nil;
    FSituations.Count := 0;
    CurrentSituation := Nil;

    Win.Visible := False;
    Lose.Visible := False;
    InfoLabel.Visible := False;
    CurrentTextPos := 0;
    FullMessage := '';
    SituationIndex := 0;
    BunkerSituation.Visible := False;
    SituationTitle.Visible := False;
    BunkerSituationImage.Visible := False;

    QuestionImage.Visible := False;
    YesButton.Visible := False;
    YesButton.Top := 544;
    YesButton.Left := 688;
    NoButton.Visible := False;
    NoButton.Top := 544;
    NoButton.Left := 240;
    NoButton.OnClick := Nil;
    YesButton.OnClick := Nil;

    AnimationTimer.Interval := 50;
    AnimationTimer.Enabled := False;
    AnimationStep := 0;
    BlinkCounter := 0;

    DoubleBuffered := True;
    QuestionImage.Transparent := True;
    YesButton.Transparent := True;
    NoButton.Transparent := True;
End;

Procedure TFinalForm.FormDestroy(Sender: TObject);
Begin
    ClearSituations;
End;

Function TFinalForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TFinalForm.FadeInImage(Img: TImage);
Begin
    Img.Visible := True;
End;

Procedure TFinalForm.BlinkImage(Img: TImage);
Begin
    Inc(BlinkCounter);
    If BlinkCounter Mod 3 < 2 Then
        Img.Visible := True
    Else
        Img.Visible := False;
End;

Procedure TFinalForm.InitializeSituation(SituationNode: PBunkerSituationNode);
Begin
    If SituationNode <> Nil Then
    Begin
        SituationTitle.Caption := SituationNode^.Situation.Title;
        BunkerSituation.Caption := SituationNode^.Situation.Description;
        CurrentSituation := SituationNode;
    End;
End;

Procedure TFinalForm.CountTheChance;
Begin
    If HasPair Then
        Inc(Chance);
    SituationTitle.Visible := False;
    BunkerSituation.Visible := False;
    BunkerSituationImage.Visible := False;
    NoButton.Visible := False;
    Yesbutton.Visible := False;
    Randomize;
    AnimationStep := 200;
    AnimationTimer.Enabled := True;
End;

Procedure TFinalForm.NoButtonClick(Sender: TObject);
Begin
    If Not IsAllSituation Then
    Begin
        SituationIndex := SituationIndex + 1;
        If CurrentSituation <> Nil Then
            InitializeSituation(CurrentSituation^.Next)
    End
    Else
        CountTheChance;
End;

Procedure TFinalForm.ShowNextImage;
Var
    FadeAlpha: Integer;
    FadeBitmap: TBitmap;
    MaxChance: Integer;
    TheEnd: Integer;
Begin
    Case AnimationStep Of
        0:
            Begin
                FadeInImage(QuestionImage);
                AnimationTimer.Interval := 600;
                Inc(AnimationStep);
            End;
        1:
            Begin
                If HasPair Then
                Begin
                    YesButton.Left := 464;
                    FadeInImage(YesButton);
                End
                Else
                Begin
                    NoButton.Left := 464;
                    FadeInImage(NoButton);
                End;
                AnimationTimer.Interval := 200;
                Inc(AnimationStep);
            End;
        2 .. 19:
            Begin
                If HasPair Then
                    BlinkImage(YesButton)
                Else
                    BlinkImage(NoButton);
                Inc(AnimationStep);
            End;
        20:
            Begin
                QuestionImage.Visible := False;
                YesButton.Visible := False;
                NoButton.Visible := False;

                InfoLabel.Caption := '';
                InfoLabel.Visible := True;

                FullMessage :=
                    'Сейчас вам будет предложено несколько ситуаций, определите, смогут ли ваши герои с ними справиться';
                CurrentTextPos := 0;
                AnimationTimer.Interval := 50;
                Inc(AnimationStep);
            End;
        21 .. 120:
            Begin
                If CurrentTextPos < Length(FullMessage) Then
                Begin
                    Inc(CurrentTextPos);
                    InfoLabel.Caption := Copy(FullMessage, 1, CurrentTextPos);
                End
                Else If AnimationStep = 120 Then
                Begin
                    AnimationTimer.Interval := 4000;
                End;
                Inc(AnimationStep);
            End;
        121:
            Begin
                InfoLabel.Visible := False;
                BunkerSituationImage.Visible := True;
                BunkerSituation.Visible := True;
                SituationTitle.Visible := True;
                LoadSituationsFromGameSetup;
                InitializeSituation(FSituations.First);
                YesButton.Visible := True;
                NoButton.Visible := True;
                YesButton.Top := 360;
                YesButton.Left := 832;
                NoButton.Top := 360;
                NoButton.Left := 96;
                YesButton.OnClick := YesButtonClick;
                NoButton.OnClick := NoButtonClick;
                AnimationTimer.Interval := 1000;
                Inc(AnimationStep);
            End;

        200:
            Begin
                InfoLabel.Caption := '';
                InfoLabel.Visible := True;
                MaxChance := (FGameSetup.Players Div 2) + 1;
                If MaxChance = 0 Then
                    MaxChance := 1;

                Percent := Round((Chance / MaxChance) * 100);
                FullMessage := 'Ваши шансы победить: ' +
                    IntToStr(Percent) + '%';
                CurrentTextPos := 0;
                AnimationTimer.Interval := 20;
                Inc(AnimationStep);
            End;
        201 .. 250:
            Begin
                If CurrentTextPos < Length(FullMessage) Then
                Begin
                    Inc(CurrentTextPos);
                    InfoLabel.Caption := Copy(FullMessage, 1, CurrentTextPos);
                End
                Else If AnimationStep = 250 Then
                Begin
                    AnimationTimer.Interval := 2000;
                End;
                Inc(AnimationStep);
            End;
        251:
            Begin
                InfoLabel.Visible := False;
                BunkerSituationImage.Visible := False;
                SituationTitle.Visible := False;
                BunkerSituation.Visible := False;
                YesButton.Visible := False;
                NoButton.Visible := False;
                QuestionImage.Visible := False;
                Zagolovok.Visible := False;
                BackButtonLabel.Visible := False;

                AnimationTimer.Interval := 150;
                Inc(AnimationStep);
            End;
        252 .. 280:
            Begin
                FadeAlpha := (AnimationStep - 251) * 10;
                If FadeAlpha > 255 Then
                    FadeAlpha := 255;

                FadeBitmap := TBitmap.Create;
                Try
                    FadeBitmap.Width := ClientWidth;
                    FadeBitmap.Height := ClientHeight;
                    FadeBitmap.Canvas.Brush.Color :=
                        RGB(FadeAlpha, FadeAlpha, FadeAlpha);
                    FadeBitmap.Canvas.FillRect(Rect(0, 0, ClientWidth,
                        ClientHeight));
                    Canvas.Draw(0, 0, FadeBitmap);
                Finally
                    FadeBitmap.Free;
                End;

                If AnimationStep = 280 Then
                Begin
                    If Random(100) < Percent Then
                        TheEnd := 1
                    Else
                        TheEnd := 0;

                    If TheEnd = 1 Then
                        Win.Visible := True
                    Else
                        Lose.Visible := True;

                    BunkerSituationImage.Visible := False;
                    SituationTitle.Visible := False;
                    BunkerSituation.Visible := False;
                    YesButton.Visible := False;
                    NoButton.Visible := False;
                    InfoLabel.Visible := False;
                    AnimationTimer.Enabled := False;
                End;
                Inc(AnimationStep);
            End;
    End;
End;

Procedure TFinalForm.YesButtonClick(Sender: TObject);
Begin
    If Not IsAllSituation Then
    Begin
        SituationIndex := SituationIndex + 1;
        Inc(Chance);
        If CurrentSituation <> Nil Then
            InitializeSituation(CurrentSituation^.Next)
    End
    Else
    Begin
        Inc(Chance);
        CountTheChance;
    End;
End;

Function TFinalForm.IsAllSituation: Boolean;
Begin
    If SituationIndex = (FGameSetup.Players Div 2) - 1 Then
        IsAllSituation := True
    Else
        IsAllSituation := False;
End;

Procedure TFinalForm.FormShow(Sender: TObject);
Begin
    AnimationStep := 0;
    BlinkCounter := 0;
    AnimationTimer.Enabled := True;
    ShowNextImage;
End;

Procedure TFinalForm.AnimationTimerTimer(Sender: TObject);
Begin
    ShowNextImage;
End;

End.
