Unit GameTypesUnit;

Interface

Const
    MAX_PLAYERS = 16;

Type
    TCardCategory = (CcProfession, CcBiology, CcHealth, CcHobby,
        CcLuggage, CcFact);

    TCardType = (CtProfession, CtBiology, CtHealth, CtHobby, CtLuggage,
        CtFacts);

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

Implementation

End.
