Unit RuleUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.Pngimage, Vcl.ExtCtrls;

Type
    TRuleForm = Class(TForm)
        Rule1: TImage;
        Rule2: TImage;
        Rule3: TImage;
        Procedure Rule1Click(Sender: TObject);
        Procedure Rule2Click(Sender: TObject);
        Procedure Rule3Click(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Function FormHelp(Command: Word; Data: THelpEventData;
            Var CallHelp: Boolean): Boolean;
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    RuleForm: TRuleForm;

Implementation

{$R *.dfm}

Procedure TRuleForm.FormCreate(Sender: TObject);
Begin
    Rule1.Visible := True;
    Rule2.Visible := False;
    Rule3.Visible := False;
End;

Function TRuleForm.FormHelp(Command: Word; Data: THelpEventData;
    Var CallHelp: Boolean): Boolean;
Begin
    CallHelp := False;
End;

Procedure TRuleForm.Rule1Click(Sender: TObject);
Begin
    Rule1.Visible := False;
    Rule2.Visible := True;
End;

Procedure TRuleForm.Rule2Click(Sender: TObject);
Begin
    Rule2.Visible := False;
    Rule3.Visible := True;
End;

Procedure TRuleForm.Rule3Click(Sender: TObject);
Begin
    Rule3.Visible := False;
    Rule1.Visible := True;
End;

End.
