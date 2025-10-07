Unit DeveloperUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

Type
    TDeveloperForm = Class(TForm)
        LbDeveloper: TLabel;
        LbGroup: TLabel;
        LbTg: TLabel;
        BtnClose: TButton;
    Background: TImage;
        Procedure BtnCloseClick(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    DeveloperForm: TDeveloperForm;

Implementation

{$R *.dfm}

Procedure TDeveloperForm.BtnCloseClick(Sender: TObject);
Begin
    DeveloperForm.Close;
End;

Function TDeveloperForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

End.
