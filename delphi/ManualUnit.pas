Unit ManualUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

Type
    TManualForm = Class(TForm)
        LbPunktOne: TLabel;
        BtnClose: TButton;
        LbPunktTwo: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
        Procedure BtnCloseClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    ManualForm: TManualForm;

Implementation

{$R *.dfm}

Procedure TManualForm.BtnCloseClick(Sender: TObject);
Begin
    ManualForm.Close;
End;

Function TManualForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
