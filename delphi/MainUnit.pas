Unit MainUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.Menus, Vcl.StdCtrls, Vcl.Grids, Vcl.Imaging.Pngimage, Vcl.ExtCtrls,
    CardSystem, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
    Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImage,
    FinalUnit;

Const
    MAX_PLAYERS = 16;

Type
    TCardCategory = (CcProfession, CcBiology, CcHealth, CcHobby,
        CcLuggage, CcFact);

    TCardCategoryHelper = Record Helper For TCardCategory
    Const
        First = CcProfession;
        Last = CcFact;
        Count = Ord(Last) + 1;
    End;

    TPlayerCardState = Record
        Revealed: Boolean;
        Kicked: Boolean;
        CardText: Array [TCardCategory] Of String;
    End;

    TPlayerCardSave = Record
        Revealed: Boolean;
        Kicked: Boolean;
        CardText: Array [TCardCategory] Of String[255];
    End;

    TGameSave = Record
        Players: Integer;
        CurrentPlayerIndex: Integer;
        ViewedPlayer: Integer;
        CurrentCategory: TCardCategory;
        CatastropheTitle: String[255];
        CatastropheDesc: String[255];
        PlayerCards: Array [1 .. MAX_PLAYERS] Of TPlayerCardSave;
    End;

    TSaveFile = File Of TGameSave;

    TMainForm = Class(TForm)
        Background: TImage;
        Left: TImage;
        Right: TImage;
        PlayerLabel: TLabel;
        Card: TImage;
        BackButtonLabel: TLabel;
        ProfLabel: TLabel;
        CardRightChange: TImage;
        CardLeftChange: TImage;
        Timer: TTimer;
        ImageCollection: TImageCollection;
        VirtualImageList: TVirtualImageList;
        HelpButton: TImage;
        RuleTable: TImage;
        Rules: TImage;
        RulesTimer: TTimer;
        CataclysmLabel: TLabel;
        CatastropheTitle: TLabel;
        KickButtonCollection: TImageCollection;
        KickButton: TImage;
        KickButtonList: TVirtualImageList;
        NextLabel: TLabel;
        MainMenu: TMainMenu;
        N1: TMenuItem;
        SaveFileMenuItem: TMenuItem;
        ExitMenuItem: TMenuItem;
        OpenFileMenuItem: TMenuItem;
        Procedure BackButtonLabelClick(Sender: TObject);
        Procedure RightClick(Sender: TObject);
        Procedure LeftClick(Sender: TObject);
        Procedure CardLeftClick(Sender: TObject);
        Procedure CardRightClick(Sender: TObject);
        Procedure FormShow(Sender: TObject);
        Procedure CardClick(Sender: TObject);
        Procedure TimerTimer(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure KickButtonClick(Sender: TObject);
        Procedure HelpButtonClick(Sender: TObject);
        Procedure FormPaint(Sender: TObject);
        Procedure RulesClick(Sender: TObject);
        Procedure RulesTimerTimer(Sender: TObject);
        Procedure CataclysmLabelOnImage(Image: TImage; ALabel: TLabel);
        Procedure NextLabelClick(Sender: TObject);
        Procedure SaveFileMenuItemClick(Sender: TObject);
        Procedure OpenFileMenuItemClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private Const
        CARD_BACK_INDEX = 6;
        MIN_PLAYERS = 1;
        ALPHA_STEP = 45;
        BETA_STEP = 10;
        MAX_ALPHA = 255;
        MIN_BETA = -340;
        MAX_BETA = 0;
        DEFAULT_IMAGE_WIDTH = 389;
        DEFAULT_IMAGE_HEIGHT = 549;
        DEFAULT_IMAGE_LEFT = 332;
    Private
        FCurrentIndex: Integer;
        FTargetIndex: Integer;
        FAlpha: Integer;
        FBeta: Integer;
        IsBack: Boolean;
        FSourceBmp: TBitmap;
        FTargetBmp: TBitmap;
        FIsDarkened: Boolean;
        Procedure UpdatePlayerNumber(IsIncrease: Boolean);
        Function GetCardType: TCardType;
        Procedure PrepareBitmaps;
        Procedure CleanupBitmap(Bmp: TBitmap);
        Function GetPlayerIndex: Integer;
        Function IsAnimationRunning: Boolean;
        Procedure StartAnimation(TargetIndex: Integer);
        Procedure SetCategory(Category: TCardCategory);
        Procedure CycleCategory(IsNext: Boolean);
        Procedure ToggleCardReveal;
        Procedure KickCardReveal;
        Function GetCategoryIndex(Category: TCardCategory): Integer;
        Procedure StartDarkenAnimation(Image: TImage; NewImageIndex: Integer);
        Function HasHeterosexualPair: Boolean;
    Public
        FViewedPlayer: Integer;
        FCurrentCategory: TCardCategory;
        FPlayersCards: Array Of TPlayerCardState;
        Function GetCardTypeFromCategory(Category: TCardCategory): TCardType;
        Procedure UpdateKickButton;
        Procedure InitializePlayersCards;
        Procedure ShowCurrentCard;
    End;

Var
    MainForm: TMainForm;
    GameSetup: TGameSetup;
    CurrentPlayerIndex: Integer;

Implementation

{$R *.dfm}
{ TMainForm }

Procedure TMainForm.BackButtonLabelClick(Sender: TObject);
Begin
    If MessageBox(Handle, 'Âû äåéñòâèòåëüíî õîòèòå âûéòè?', 'Âû óâåðåíû?',
        MB_YESNO Or MB_ICONQUESTION) = IDYES Then
    Begin
        Close;
    End;
End;

Function TMainForm.GetCardTypeFromCategory(Category: TCardCategory): TCardType;
Begin
    Case Category Of
        CcProfession:
            GetCardTypeFromCategory := CtProfession;
        CcBiology:
            GetCardTypeFromCategory := CtBiology;
        CcHealth:
            GetCardTypeFromCategory := CtHealth;
        CcHobby:
            GetCardTypeFromCategory := CtHobby;
        CcLuggage:
            GetCardTypeFromCategory := CtLuggage;
        CcFact:
            GetCardTypeFromCategory := CtFacts;
    Else
        GetCardTypeFromCategory := CtProfession;
    End;
End;

Procedure TMainForm.RulesClick(Sender: TObject);
Begin
    FIsDarkened := Not FIsDarkened;

    If FIsDarkened Then
    Begin
        CardLeftChange.OnClick := Nil;
        CardRightChange.OnClick := Nil;
        Card.OnClick := Nil;
        Left.OnClick := Nil;
        Left.OnDblClick := Nil;
        Right.OnClick := Nil;
        Right.OnDblClick := Nil;
        KickButton.OnClick := Nil;
        BackButtonLabel.OnClick := Nil;
        HelpButton.OnClick := Nil;
        IsBack := False;
        RulesTimer.Enabled := True;
    End
    Else
    Begin
        Repaint;
        CardLeftChange.OnClick := CardLeftClick;
        CardRightChange.OnClick := CardRightClick;
        Card.OnClick := CardClick;
        Left.OnClick := LeftClick;
        Left.OnDblClick := LeftClick;
        Right.OnClick := RightClick;
        Right.OnDblClick := RightClick;
        KickButton.OnClick := KickButtonClick;
        BackButtonLabel.OnClick := BackButtonLabelClick;
        HelpButton.OnClick := HelpButtonClick;
        IsBack := True;
        RulesTimer.Enabled := True;
    End;
End;

Procedure TMainForm.InitializePlayersCards;
Var
    I: Integer;
    Cat: TCardCategory;
Begin
    SetLength(FPlayersCards, GameSetup.Players);

    For I := 0 To GameSetup.Players - 1 Do
    Begin
        FPlayersCards[I].Revealed := False;
        FPlayersCards[I].Kicked := False;

        For Cat := TCardCategory.First To TCardCategory.Last Do
        Begin
            FPlayersCards[I].CardText[Cat] := '';
        End;
    End;

    If GameSetup.Players > 0 Then
    Begin
        FPlayersCards[CurrentPlayerIndex].Revealed := True;
        For Cat := TCardCategory.First To TCardCategory.Last Do
        Begin
            FPlayersCards[CurrentPlayerIndex].CardText[Cat] :=
                GameSetup.Cards[GetCardTypeFromCategory(Cat)
                ][CurrentPlayerIndex].Description;
        End;
    End;

    CataclysmLabel.Caption := GameSetup.Catastrophe.Description;
    CataclysmLabelOnImage(Rules, CataclysmLabel);

    CatastropheTitle.Caption := GameSetup.Catastrophe.Title;
    CatastropheTitle.Parent := Rules.Parent;
    CatastropheTitle.BringToFront;

    CatastropheTitle.Left := Rules.Left + 30;
    CatastropheTitle.Top := Rules.Top + 480;
    CatastropheTitle.Width := Rules.Width - 60;
    CatastropheTitle.Height := Rules.Height - 30;

    FCurrentCategory := TCardCategory.First;
End;

Function TMainForm.GetCategoryIndex(Category: TCardCategory): Integer;
Begin
    GetCategoryIndex := Ord(Category);
End;

Procedure TMainForm.StartDarkenAnimation(Image: TImage; NewImageIndex: Integer);
Var
    I: Integer;
    DarkBmp: TBitmap;
    OriginalBmp: TBitmap;
    BlendFunc: TBlendFunction;
Begin
    OriginalBmp := TBitmap.Create;
    DarkBmp := TBitmap.Create;
    Try
        OriginalBmp.Assign(Image.Picture.Graphic);
        OriginalBmp.PixelFormat := Pf32bit;
        OriginalBmp.AlphaFormat := AfPremultiplied;

        DarkBmp.SetSize(OriginalBmp.Width, OriginalBmp.Height);
        DarkBmp.PixelFormat := Pf32bit;
        DarkBmp.AlphaFormat := AfPremultiplied;

        BlendFunc.BlendOp := AC_SRC_OVER;
        BlendFunc.BlendFlags := 0;
        BlendFunc.AlphaFormat := AC_SRC_ALPHA;

        For I := 1 To 5 Do
        Begin
            DarkBmp.Canvas.Brush.Color := ClBlack;
            DarkBmp.Canvas.FillRect(Rect(0, 0, DarkBmp.Width, DarkBmp.Height));

            BlendFunc.SourceConstantAlpha := I * 50;
            Winapi.Windows.AlphaBlend(DarkBmp.Canvas.Handle, 0, 0,
                DarkBmp.Width, DarkBmp.Height, OriginalBmp.Canvas.Handle, 0, 0,
                OriginalBmp.Width, OriginalBmp.Height, BlendFunc);

            Image.Picture.Assign(DarkBmp);
            Image.Refresh;
        End;

        KickButtonList.GetBitmap(1, Image.Picture.Bitmap);

        Image.Refresh;

    Finally
        OriginalBmp.Free;
        DarkBmp.Free;
    End;
End;

Procedure TMainForm.KickButtonClick(Sender: TObject);
Var
    DarkBmp: TBitmap;
    BlendFunc: TBlendFunction;
    OriginalBmp: TBitmap;
    PlayerIndex: Integer;
Begin
    PlayerIndex := GetPlayerIndex;
    If Not FPlayersCards[PlayerIndex].Kicked Then
        If MessageBox(Handle, 'Âû äåéñòâèòåëüíî õîòèòå âûãíàòü èãðîêà?',
            'Âû óâåðåíû?', MB_YESNO Or MB_ICONQUESTION) = IDYES Then
        Begin
            If Sender Is TImage Then
            Begin
                FPlayersCards[PlayerIndex].Kicked := True;
                OriginalBmp := TBitmap.Create;
                DarkBmp := TBitmap.Create;
                Try
                    OriginalBmp.Assign(TImage(Sender).Picture.Graphic);
                    OriginalBmp.PixelFormat := Pf32bit;
                    OriginalBmp.AlphaFormat := AfPremultiplied;

                    DarkBmp.SetSize(OriginalBmp.Width, OriginalBmp.Height);
                    DarkBmp.PixelFormat := Pf32bit;
                    DarkBmp.AlphaFormat := AfPremultiplied;

                    DarkBmp.Canvas.Brush.Color := ClBlack;
                    DarkBmp.Canvas.FillRect(Rect(0, 0, DarkBmp.Width,
                        DarkBmp.Height));

                    BlendFunc.BlendOp := AC_SRC_OVER;
                    BlendFunc.BlendFlags := 0;
                    BlendFunc.SourceConstantAlpha := 128;
                    BlendFunc.AlphaFormat := AC_SRC_ALPHA;

                    Winapi.Windows.AlphaBlend(DarkBmp.Canvas.Handle, 0, 0,
                        DarkBmp.Width, DarkBmp.Height,
                        OriginalBmp.Canvas.Handle, 0, 0, OriginalBmp.Width,
                        OriginalBmp.Height, BlendFunc);

                    TImage(Sender).Picture.Assign(DarkBmp);

                    TImage(Sender).Refresh;

                    UpdateKickButton;

                    KickCardReveal;

                    StartDarkenAnimation(KickButton, 0);

                Finally
                    OriginalBmp.Free;
                    DarkBmp.Free;
                End;
            End;
        End;
End;

Procedure TMainForm.UpdatePlayerNumber(IsIncrease: Boolean);
Begin
    If IsIncrease Then
        FViewedPlayer := (FViewedPlayer Mod GameSetup.Players) + 1
    Else
        FViewedPlayer := ((FViewedPlayer + GameSetup.Players - 2)
            Mod GameSetup.Players) + 1;

    FCurrentCategory := TCardCategory.First;
    PlayerLabel.Caption := 'ÈÃÐÎÊ ' + IntToStr(FViewedPlayer);

    ShowCurrentCard;
End;

Procedure TMainForm.UpdateKickButton;
Var
    PlayerIndex: Integer;
    ActivePlayers, TotalPlayers: Integer;
    I: Integer;
Begin
    PlayerIndex := GetPlayerIndex;

    KickButton.Transparent := True;

    If FPlayersCards[PlayerIndex].Kicked Then
        KickButtonList.GetBitmap(1, KickButton.Picture.Bitmap)
    Else
        KickButtonList.GetBitmap(0, KickButton.Picture.Bitmap);

    KickButton.Picture.Bitmap.AlphaFormat := AfPremultiplied;
    KickButton.Picture.Bitmap.PixelFormat := Pf32bit;
    KickButton.Invalidate;
    TotalPlayers := GameSetup.Players;
    ActivePlayers := 0;
    For I := 0 To TotalPlayers - 1 Do
    Begin
        If Not FPlayersCards[I].Kicked Then
            Inc(ActivePlayers);
    End;

    NextLabel.Visible := (ActivePlayers <= (TotalPlayers Div 2)) And
        (TotalPlayers > 1);

    KickButton.Refresh;
End;

Procedure TMainForm.ShowCurrentCard;
Var
    PlayerIndex: Integer;
    CardTextEmpty: Boolean;
    BlendFunc: TBlendFunction;
    TempBmp: TBitmap;
Begin
    PlayerIndex := GetPlayerIndex;
    CardTextEmpty := (FPlayersCards[PlayerIndex].CardText
        [FCurrentCategory] = '');

    If (FCurrentCategory = CcProfession) And Not FPlayersCards[PlayerIndex]
        .Revealed And Not Timer.Enabled Then
    Begin
        FTargetIndex := GetCategoryIndex(FCurrentCategory);
        PrepareBitmaps;
        StartAnimation(CARD_BACK_INDEX);
        ProfLabel.Caption := '';
    End
    Else If (Not FPlayersCards[PlayerIndex].Revealed Or CardTextEmpty) And
        Not Timer.Enabled Then
    Begin
        FTargetIndex := GetCategoryIndex(FCurrentCategory);
        PrepareBitmaps;
        StartAnimation(CARD_BACK_INDEX);
        ProfLabel.Caption := '';
    End
    Else If (FCurrentCategory = CcProfession) And Not FPlayersCards[PlayerIndex]
        .Revealed And Timer.Enabled Then
    Begin
        TempBmp := TBitmap.Create;
        Try
            TempBmp.SetSize(FSourceBmp.Width, FSourceBmp.Height);
            TempBmp.PixelFormat := Pf32bit;
            TempBmp.AlphaFormat := AfPremultiplied;
            TempBmp.Canvas.Brush.Color := ClBlack;
            TempBmp.Canvas.FillRect(Rect(0, 0, TempBmp.Width, TempBmp.Height));

            BlendFunc.BlendOp := AC_SRC_OVER;
            BlendFunc.BlendFlags := 0;
            BlendFunc.AlphaFormat := AC_SRC_ALPHA;

            BlendFunc.SourceConstantAlpha := MAX_ALPHA - FAlpha;
            Winapi.Windows.AlphaBlend(TempBmp.Canvas.Handle, 0, 0,
                TempBmp.Width, TempBmp.Height, FSourceBmp.Canvas.Handle, 0, 0,
                FSourceBmp.Width, FSourceBmp.Height, BlendFunc);

            BlendFunc.SourceConstantAlpha := FAlpha;
            Winapi.Windows.AlphaBlend(TempBmp.Canvas.Handle, 0, 0,
                TempBmp.Width, TempBmp.Height, FTargetBmp.Canvas.Handle, 0, 0,
                FTargetBmp.Width, FTargetBmp.Height, BlendFunc);

            Card.Picture.Bitmap.Assign(TempBmp);
            Card.Invalidate;

            Timer.Enabled := False;
            FCurrentIndex := FTargetIndex;
            VirtualImageList.GetBitmap(FCurrentIndex, Card.Picture.Bitmap);
            CleanupBitmap(Card.Picture.Bitmap);

            Card.Width := DEFAULT_IMAGE_WIDTH;
            Card.Left := DEFAULT_IMAGE_LEFT;

            ProfLabel.Visible := (FCurrentIndex <> CARD_BACK_INDEX) And
                FPlayersCards[GetPlayerIndex].Revealed And
                (FPlayersCards[GetPlayerIndex].CardText
                [FCurrentCategory] <> '');

        Finally
            TempBmp.Free;
        End;
        VirtualImageList.GetBitmap(FCurrentIndex, FSourceBmp);
        VirtualImageList.GetBitmap(FTargetIndex, FTargetBmp);
        StartAnimation(CARD_BACK_INDEX);
        ProfLabel.Caption := '';
    End
    Else
    Begin
        StartAnimation(GetCategoryIndex(FCurrentCategory));
        ProfLabel.Caption := FPlayersCards[PlayerIndex].CardText
            [FCurrentCategory];
    End;

    UpdateKickButton
End;

Procedure TMainForm.PrepareBitmaps;
Begin
    VirtualImageList.GetBitmap(FCurrentIndex, FSourceBmp);
    VirtualImageList.GetBitmap(FTargetIndex, FTargetBmp);
    CleanupBitmap(FSourceBmp);
    CleanupBitmap(FTargetBmp);
End;

Procedure TMainForm.CleanupBitmap(Bmp: TBitmap);
Var
    X, Y: Integer;
    P: PRGBQuad;
Begin
    Bmp.PixelFormat := Pf32bit;
    Bmp.AlphaFormat := AfPremultiplied;

    For Y := 0 To Bmp.Height - 1 Do
    Begin
        P := Bmp.ScanLine[Y];
        For X := 0 To Bmp.Width - 1 Do
        Begin
            If P.RgbReserved = 0 Then
            Begin
                P.RgbBlue := 0;
                P.RgbGreen := 0;
                P.RgbRed := 0;
            End;
            Inc(P);
        End;
    End;
End;

Function Min(A, B: Integer): Integer;
Begin
    If A > B Then
        Min := B
    Else If A < B Then
        Min := A
    Else
        Min := A;
End;

Function Max(A, B: Integer): Integer;
Begin
    If A > B Then
        Max := A
    Else If A < B Then
        Max := B
    Else
        Max := A;
End;

Procedure TMainForm.RulesTimerTimer(Sender: TObject);
Begin
    If IsBack Then
    Begin
        Rules.Left := Rules.Left - BETA_STEP;
        CataclysmLabelOnImage(Rules, CataclysmLabel);
        CatastropheTitle.Parent := Rules.Parent;
        CatastropheTitle.BringToFront;

        CatastropheTitle.Left := Rules.Left + 30;
        CatastropheTitle.Top := Rules.Top + 460;
        CatastropheTitle.Width := Rules.Width - 60;
        CatastropheTitle.Height := Rules.Height - 30;

        If Rules.Left <= MIN_BETA Then
        Begin
            RulesTimer.Enabled := False;
        End;
    End
    Else
    Begin
        Rules.Left := Rules.Left + BETA_STEP;
        CataclysmLabelOnImage(Rules, CataclysmLabel);

        CatastropheTitle.Parent := Rules.Parent;
        CatastropheTitle.BringToFront;

        CatastropheTitle.Left := Rules.Left + 30;
        CatastropheTitle.Top := Rules.Top + 460;
        CatastropheTitle.Width := Rules.Width - 60;
        CatastropheTitle.Height := Rules.Height - 30;

        If Rules.Left >= MAX_BETA Then
        Begin
            RulesTimer.Enabled := False;
        End;
    End;

End;

Procedure TMainForm.TimerTimer(Sender: TObject);
Var
    BlendFunc: TBlendFunction;
    TempBmp: TBitmap;
Begin
    FAlpha := Min(FAlpha + ALPHA_STEP, MAX_ALPHA);

    If Card.Width < DEFAULT_IMAGE_WIDTH Then
    Begin
        Card.Width := Card.Width + (DEFAULT_IMAGE_WIDTH - Card.Width) Div 4 + 1;
        Card.Left := Card.Left - (DEFAULT_IMAGE_WIDTH - Card.Width) Div 8;
    End;

    TempBmp := TBitmap.Create;
    Try
        TempBmp.SetSize(FSourceBmp.Width, FSourceBmp.Height);
        TempBmp.PixelFormat := Pf32bit;
        TempBmp.AlphaFormat := AfPremultiplied;
        TempBmp.Canvas.Brush.Color := ClBlack;
        TempBmp.Canvas.FillRect(Rect(0, 0, TempBmp.Width, TempBmp.Height));

        BlendFunc.BlendOp := AC_SRC_OVER;
        BlendFunc.BlendFlags := 0;
        BlendFunc.AlphaFormat := AC_SRC_ALPHA;

        BlendFunc.SourceConstantAlpha := MAX_ALPHA - FAlpha;
        Winapi.Windows.AlphaBlend(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width,
            TempBmp.Height, FSourceBmp.Canvas.Handle, 0, 0, FSourceBmp.Width,
            FSourceBmp.Height, BlendFunc);

        BlendFunc.SourceConstantAlpha := FAlpha;
        Winapi.Windows.AlphaBlend(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width,
            TempBmp.Height, FTargetBmp.Canvas.Handle, 0, 0, FTargetBmp.Width,
            FTargetBmp.Height, BlendFunc);

        Card.Picture.Bitmap.Assign(TempBmp);
        Card.Invalidate;

        If FAlpha >= MAX_ALPHA Then
        Begin
            Timer.Enabled := False;
            FCurrentIndex := FTargetIndex;
            VirtualImageList.GetBitmap(FCurrentIndex, Card.Picture.Bitmap);
            CleanupBitmap(Card.Picture.Bitmap);

            Card.Width := DEFAULT_IMAGE_WIDTH;
            Card.Left := DEFAULT_IMAGE_LEFT;

            ProfLabel.Visible := (FCurrentIndex <> CARD_BACK_INDEX) And
                FPlayersCards[GetPlayerIndex].Revealed And
                (FPlayersCards[GetPlayerIndex].CardText
                [FCurrentCategory] <> '');
        End;
    Finally
        TempBmp.Free;
    End;
End;

Function TMainForm.GetCardType: TCardType;
Begin
    GetCardType := GetCardTypeFromCategory(FCurrentCategory);
End;

Procedure TMainForm.FormCreate(Sender: TObject);
Begin
    NextLabel.Visible := False;
    IsBack := False;
    RulesTimer.Enabled := False;
    RuleTable.Visible := False;
    FIsDarkened := False;
    Timer.Enabled := False;
    VirtualImageList.Scaled := True;
    VirtualImageList.DrawingStyle := DsTransparent;
    VirtualImageList.BkColor := ClNone;
    VirtualImageList.Width := DEFAULT_IMAGE_WIDTH;
    VirtualImageList.Height := DEFAULT_IMAGE_HEIGHT;

    KickButtonList.Scaled := True;
    KickButtonList.DrawingStyle := DsTransparent;
    KickButtonList.BkColor := ClNone;
    KickButtonList.Width := DEFAULT_IMAGE_WIDTH;
    KickButtonList.Height := DEFAULT_IMAGE_HEIGHT;

    FCurrentIndex := 0;
    FTargetIndex := 0;
    FAlpha := MAX_ALPHA;

    FSourceBmp := TBitmap.Create;
    FSourceBmp.PixelFormat := Pf32bit;
    FSourceBmp.AlphaFormat := AfPremultiplied;

    FTargetBmp := TBitmap.Create;
    FTargetBmp.PixelFormat := Pf32bit;
    FTargetBmp.AlphaFormat := AfPremultiplied;

    VirtualImageList.GetBitmap(FCurrentIndex, Card.Picture.Bitmap);
    KickButtonList.GetBitmap(0, KickButton.Picture.Bitmap);
    CleanupBitmap(Card.Picture.Bitmap);
    CleanupBitmap(KickButton.Picture.Bitmap);
    Card.Transparent := True;
    KickButton.Transparent := True;
    KickButton.ComponentIndex := 0;
End;

Function TMainForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TMainForm.FormPaint(Sender: TObject);
Var
    BlendFunc: TBlendFunction;
    Rect: TRect;
    DarkBitmap: TBitmap;
Begin
    If FIsDarkened Then
    Begin
        Rect := ClientRect;

        DarkBitmap := TBitmap.Create;
        Try
            DarkBitmap.Width := Rect.Width;
            DarkBitmap.Height := Rect.Height;
            DarkBitmap.Canvas.Brush.Color := ClBlack;
            DarkBitmap.Canvas.FillRect(Rect);

            BlendFunc.BlendOp := AC_SRC_OVER;
            BlendFunc.BlendFlags := 0;
            BlendFunc.SourceConstantAlpha := 128;
            BlendFunc.AlphaFormat := 0;

            Winapi.Windows.AlphaBlend(Canvas.Handle, Rect.Left, Rect.Top,
                Rect.Width, Rect.Height, DarkBitmap.Canvas.Handle, 0, 0,
                DarkBitmap.Width, DarkBitmap.Height, BlendFunc);
        Finally
            DarkBitmap.Free;
        End;
    End;
End;

Procedure TMainForm.FormShow(Sender: TObject);
Begin
    FViewedPlayer := 1;
    FCurrentCategory := TCardCategory.First;
    PlayerLabel.Caption := 'ÈÃÐÎÊ 1';
    Visible := True;
    InitializePlayersCards;
    Timer.Enabled := True;
    ShowCurrentCard;
End;

Procedure TMainForm.LeftClick(Sender: TObject);
Begin
    UpdatePlayerNumber(False);
End;

Function TMainForm.HasHeterosexualPair: Boolean;
Var
    I: Integer;
    HasMan, HasWoman: Boolean;
    BiologyText: String;
Begin
    HasMan := False;
    HasWoman := False;

    For I := 0 To High(FPlayersCards) Do
    Begin
        If FPlayersCards[I].Kicked Then
            Continue;

        BiologyText := FPlayersCards[I].CardText[CcBiology];

        If (Pos('ÌÓÆ×ÈÍÀ', BiologyText) > 0) And
            (Pos('ÃÎÌÎÑÅÊÑÓÀËÅÍ', BiologyText) = 0) Then
            HasMan := True;

        If (Pos('ÆÅÍÙÈÍÀ', BiologyText) > 0) And
            (Pos('ÃÎÌÎÑÅÊÑÓÀËÜÍÀ', BiologyText) = 0) Then
            HasWoman := True;

        If (Pos('ÁÈÑÅÊÑÓÀËÅÍ', BiologyText) > 0) Or
            (Pos('ÁÈÑÅÊÑÓÀËÜÍÀ', BiologyText) > 0) Then
        Begin
            If Pos('ÌÓÆ×ÈÍÀ', BiologyText) > 0 Then
                HasMan := True
            Else If Pos('ÆÅÍÙÈÍÀ', BiologyText) > 0 Then
                HasWoman := True;
        End;

        If (Pos('ÃÅÐÌÀÔÐÎÄÈÒ', BiologyText) > 0) Then
        Begin
            HasMan := True;
            HasWoman := True;
        End;
    End;

    Result := HasMan And HasWoman;
End;

Procedure TMainForm.NextLabelClick(Sender: TObject);
Begin
    FinalForm.HasPair := HasHeterosexualPair;
    FinalForm.FGameSetup := GameSetup;
    FinalForm.ShowModal;
    Close;
End;

Procedure TMainForm.OpenFileMenuItemClick(Sender: TObject);
Var
    OpenDialog: TOpenDialog;
    F: TSaveFile;
    GameSave: TGameSave;
    I: Integer;
    Cat: TCardCategory;
Begin
    OpenDialog := TOpenDialog.Create(Nil);
    Try
        OpenDialog.Filter := 'Ñîõðàíåíèå èãðû (*.sav)|*.sav';
        OpenDialog.DefaultExt := 'sav';
        OpenDialog.Title := 'Çàãðóçèòü èãðó';

        If OpenDialog.Execute Then
        Begin
            AssignFile(F, OpenDialog.FileName);
            Reset(F);

            Try
                Read(F, GameSave);
                GameSetup.Players := GameSave.Players;
                CurrentPlayerIndex := GameSave.CurrentPlayerIndex;
                FViewedPlayer := GameSave.ViewedPlayer;
                FCurrentCategory := GameSave.CurrentCategory;
                GameSetup.Catastrophe.Title := GameSave.CatastropheTitle;
                GameSetup.Catastrophe.Description := GameSave.CatastropheDesc;

                SetLength(FPlayersCards, GameSave.Players);
                For I := 1 To GameSave.Players Do
                Begin
                    FPlayersCards[I - 1].Revealed := GameSave.PlayerCards
                        [I].Revealed;
                    FPlayersCards[I - 1].Kicked := GameSave.PlayerCards
                        [I].Kicked;

                    For Cat := TCardCategory.First To TCardCategory.Last Do
                        FPlayersCards[I - 1].CardText[Cat] :=
                            GameSave.PlayerCards[I].CardText[Cat];
                End;

                PlayerLabel.Caption := 'ÈÃÐÎÊ ' + IntToStr(FViewedPlayer);
                CataclysmLabel.Caption := GameSetup.Catastrophe.Description;
                CataclysmLabelOnImage(Rules, CataclysmLabel);
                CatastropheTitle.Caption := GameSetup.Catastrophe.Title;

                ShowCurrentCard;
                UpdateKickButton;
            Finally
                CloseFile(F);
            End;
        End;
    Finally
        OpenDialog.Free;
    End;
End;

Procedure TMainForm.RightClick(Sender: TObject);
Begin
    UpdatePlayerNumber(True);
End;

Procedure TMainForm.CardClick(Sender: TObject);
Begin
    ToggleCardReveal;
End;

Procedure TMainForm.CardLeftClick(Sender: TObject);
Begin
    CycleCategory(False);
End;

Procedure TMainForm.CardRightClick(Sender: TObject);
Begin
    CycleCategory(True);
End;

Procedure AdjustLabelFontSize(ALabel: TLabel);
Var
    TextRect: TRect;
    Flags: Cardinal;
Begin
    TextRect := Rect(0, 0, ALabel.Width, ALabel.Height);
    Flags := DT_CENTER Or DT_WORDBREAK Or DT_CALCRECT Or DT_NOPREFIX;

    While True Do
    Begin
        DrawText(ALabel.Canvas.Handle, PChar(ALabel.Caption),
            Length(ALabel.Caption), TextRect, Flags);

        If (TextRect.Bottom <= ALabel.Height) Or (ALabel.Font.Size <= 6) Then
            Break;

        ALabel.Font.Size := ALabel.Font.Size - 1;
        TextRect := Rect(0, 0, ALabel.Width, ALabel.Height);
    End;
End;

Procedure TMainForm.CataclysmLabelOnImage(Image: TImage; ALabel: TLabel);
Var
    TextRect: TRect;
    Flags: Cardinal;
Begin
    ALabel.Parent := Image.Parent;
    ALabel.BringToFront;

    ALabel.Left := Image.Left + 30;
    ALabel.Top := Image.Top + 15;
    ALabel.Width := Image.Width - 60;
    ALabel.Height := Image.Height - 30;

    AdjustLabelFontSize(ALabel);
End;

Function TMainForm.GetPlayerIndex: Integer;
Begin
    GetPlayerIndex := FViewedPlayer - 1;
End;

Procedure TMainForm.HelpButtonClick(Sender: TObject);
Begin
    FIsDarkened := Not FIsDarkened;

    If FIsDarkened Then
    Begin
        CardLeftChange.OnClick := Nil;
        CardRightChange.OnClick := Nil;
        Card.OnClick := Nil;
        Left.OnClick := Nil;
        Left.OnDblClick := Nil;
        Right.OnClick := Nil;
        Right.OnDblClick := Nil;
        KickButton.OnClick := Nil;
        BackButtonLabel.OnClick := Nil;
        FormPaint(MainForm);
        RuleTable.Visible := True;
        HelpButton.Enabled := False;
        HelpButton.Enabled := True;
        Rules.OnClick := NIL;
    End
    Else
    Begin
        Repaint;
        CardLeftChange.OnClick := CardLeftClick;
        CardRightChange.OnClick := CardRightClick;
        Card.OnClick := CardClick;
        Left.OnClick := LeftClick;
        Left.OnDblClick := LeftClick;
        Right.OnClick := RightClick;
        Right.OnDblClick := RightClick;
        KickButton.OnClick := KickButtonClick;
        BackButtonLabel.OnClick := BackButtonLabelClick;
        RuleTable.Visible := False;
        Rules.OnClick := RulesClick;
    End;
End;

Function TMainForm.IsAnimationRunning: Boolean;
Begin
    IsAnimationRunning := Timer.Enabled;
End;

Procedure TMainForm.StartAnimation(TargetIndex: Integer);
Begin
    If IsAnimationRunning Then
        Exit;

    FTargetIndex := TargetIndex;
    PrepareBitmaps;
    FAlpha := 0;
    Timer.Enabled := True;

    Card.Width := Card.Width Div 2;
    Card.Left := Card.Left + Card.Width Div 2;
End;

Procedure TMainForm.SaveFileMenuItemClick(Sender: TObject);
Var
    SaveDialog: TSaveDialog;
    F: TSaveFile;
    GameSave: TGameSave;
    I: Integer;
    Cat: TCardCategory;
Begin
    SaveDialog := TSaveDialog.Create(Nil);
    Try
        SaveDialog.Filter := 'Ñîõðàíåíèå èãðû (*.sav)|*.sav';
        SaveDialog.DefaultExt := 'sav';
        SaveDialog.Title := 'Ñîõðàíèòü èãðó';

        If SaveDialog.Execute Then
        Begin
            If GameSetup.Players > MAX_PLAYERS Then
            Begin
                ShowMessage('Îøèáêà: ñëèøêîì ìíîãî èãðîêîâ äëÿ ñîõðàíåíèÿ');
                Exit;
            End;

            AssignFile(F, SaveDialog.FileName);
            Rewrite(F);

            Try
                GameSave.Players := GameSetup.Players;
                GameSave.CurrentPlayerIndex := CurrentPlayerIndex;
                GameSave.ViewedPlayer := FViewedPlayer;
                GameSave.CurrentCategory := FCurrentCategory;
                GameSave.CatastropheTitle := GameSetup.Catastrophe.Title;
                GameSave.CatastropheDesc := GameSetup.Catastrophe.Description;

                For I := 1 To GameSetup.Players Do
                Begin
                    GameSave.PlayerCards[I].Revealed :=
                        FPlayersCards[I - 1].Revealed;
                    GameSave.PlayerCards[I].Kicked :=
                        FPlayersCards[I - 1].Kicked;

                    For Cat := TCardCategory.First To TCardCategory.Last Do
                        GameSave.PlayerCards[I].CardText[Cat] :=
                            FPlayersCards[I - 1].CardText[Cat];
                End;

                Write(F, GameSave);
            Finally
                CloseFile(F);
            End;
            ShowMessage('Èãðà óñïåøíî ñîõðàíåíà!');
        End;
    Finally
        SaveDialog.Free;
    End;
End;

Procedure TMainForm.SetCategory(Category: TCardCategory);
Begin
    FCurrentCategory := Category;
End;

Procedure TMainForm.CycleCategory(IsNext: Boolean);
Var
    NewCategory: TCardCategory;
Begin
    ProfLabel.Visible := False;
    If IsNext Then
    Begin
        If FCurrentCategory = TCardCategory.Last Then
            NewCategory := TCardCategory.First
        Else
            NewCategory := Succ(FCurrentCategory);
    End
    Else
    Begin
        If FCurrentCategory = TCardCategory.First Then
            NewCategory := TCardCategory.Last
        Else
            NewCategory := Pred(FCurrentCategory);
    End;

    SetCategory(NewCategory);

    ShowCurrentCard;
End;

Procedure TMainForm.ToggleCardReveal;
Var
    PlayerIndex: Integer;
Begin
    ProfLabel.Visible := False;
    PlayerIndex := GetPlayerIndex;
    FPlayersCards[PlayerIndex].Revealed := True;
    FPlayersCards[PlayerIndex].CardText[FCurrentCategory] :=
        GameSetup.Cards[GetCardTypeFromCategory(FCurrentCategory)][PlayerIndex]
        .Description;
    ShowCurrentCard;
End;

Procedure TMainForm.KickCardReveal;
Var
    PlayerIndex: Integer;
Begin
    ProfLabel.Visible := False;
    PlayerIndex := GetPlayerIndex;
    FPlayersCards[PlayerIndex].Revealed := True;
    For Var Cat := CcProfession To CcFact Do
        FPlayersCards[PlayerIndex].CardText[Cat] :=
            GameSetup.Cards[GetCardTypeFromCategory(Cat)][PlayerIndex]
            .Description;
    ShowCurrentCard;
End;

End.
