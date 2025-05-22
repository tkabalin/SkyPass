unit frmStandardUser_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Samples.Spin, math, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Imaging.jpeg, StrUtils, Vcl.Imaging.pngimage,System.UITypes;

type
  TfrmStandardUser = class(TForm)
    tbrLength: TTrackBar;
    spnLength: TSpinEdit;
    redOutput: TRichEdit;
    cbxLowerCase: TCheckBox;
    cbxUpperCase: TCheckBox;
    cbxNumbers: TCheckBox;
    cbxSymbols: TCheckBox;
    pnlPassword: TPanel;
    rgpPasswordType: TRadioGroup;
    imgNightSky: TImage;
    bbnGeneratePassword: TBitBtn;
    shpStrength: TShape;
    bbnCopy: TBitBtn;
    lblLength: TLabel;
    pnlOutput: TPanel;
    lblCustomize: TLabel;
    shpLine: TShape;
    bbnClose: TBitBtn;
    cbxUniqueCharacters: TCheckBox;
    cbxEnteredCharacters: TCheckBox;
    pnlAdvanced: TPanel;
    redEnterCharacters: TRichEdit;
    lblEnterCharacters: TLabel;
    pnlCharacters: TPanel;
    imgLogo: TImage;
    procedure tbrLengthChange(Sender: TObject);
    procedure spnLengthChange(Sender: TObject);
    procedure rgpPasswordTypeClick(Sender: TObject);
    procedure bbnCopyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GenerateCode;
    procedure bbnGeneratePasswordClick(Sender: TObject);
    procedure cbxLowerCaseClick(Sender: TObject);
    procedure cbxUpperCaseClick(Sender: TObject);
    procedure cbxNumbersClick(Sender: TObject);
    procedure cbxSymbolsClick(Sender: TObject);
    procedure CountTypes;
    procedure cbxUniqueCharactersClick(Sender: TObject);
    procedure cbxEnteredCharactersClick(Sender: TObject);
    procedure edtCustomCharactersChange(Sender: TObject);
    procedure redEnterCharactersChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmStandardUser: TfrmStandardUser;
  iNumTypes : Integer;

const
  sLowerCase : String = 'abcdefghijklmnopqrstuvwxyz';
  sUpperCase : String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  sNumbers : String = '0123456789';
  sSymbols : String = '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
  sValidCharacters : String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';

implementation

{$R *.dfm}

procedure TfrmStandardUser.bbnCopyClick(Sender: TObject);
begin
//Copy the generated password
redOutput.SelStart  :=  0;
redOutput.SelLength :=  length(redOutput.Lines[0]);
redOutput.CopyToClipboard;
end;

procedure TfrmStandardUser.bbnGeneratePasswordClick(Sender: TObject);
begin
GenerateCode;
end;

procedure TfrmStandardUser.cbxEnteredCharactersClick(Sender: TObject);
begin
if cbxEnteredCharacters.Checked = true then
begin
  //Alow the user to enter characters
  pnlPassword.Hide;
  redEnterCharacters.Lines.Clear;
  pnlCharacters.show;
end
else if cbxEnteredCharacters.Checked = false then
begin
  //Prevent the user from entering characters
  pnlPassword.Show;
  pnlCharacters.Hide;
end;
GenerateCode;
end;

procedure TfrmStandardUser.cbxLowerCaseClick(Sender: TObject);
begin
GenerateCode;
//Prevent the user from deselecting all types of characters
CountTypes;
if (iNumTypes = 0) and (cbxEnteredCharacters.Checked = false) then
  cbxLowerCase.Checked := true;
end;

procedure TfrmStandardUser.cbxNumbersClick(Sender: TObject);
begin
GenerateCode;
//Prevent the user from deselecting all types of characters
CountTypes;
if (iNumTypes = 0) and (cbxEnteredCharacters.Checked = false) then
  cbxNumbers.Checked := true
end;

procedure TfrmStandardUser.cbxSymbolsClick(Sender: TObject);
begin
GenerateCode;
//Prevent the user from deselecting all types of characters
CountTypes;
if (iNumTypes = 0) and (cbxEnteredCharacters.Checked = false) then
  cbxSymbols.Checked := true;
end;

procedure TfrmStandardUser.cbxUniqueCharactersClick(Sender: TObject);
begin
GenerateCode;
end;

procedure TfrmStandardUser.cbxUpperCaseClick(Sender: TObject);
begin
GenerateCode;
//Prevent the user from deselecting all types of characters
CountTypes;
if iNumTypes = 0 then
  cbxUpperCase.Checked := true;
end;

procedure TfrmStandardUser.CountTypes;
begin
//Count the number of types of character selected by the user
iNumTypes := 0;
if cbxLowerCase.Checked = true then
   iNumTypes := iNumTypes + 1;
if cbxUpperCase.Checked = true then
  iNumTypes := iNumTypes + 1;
if cbxNumbers.Checked = true then
  iNumTypes := iNumTypes + 1;
if cbxSymbols.Checked = true then
  iNumTypes := iNumTypes + 1;
end;

procedure TfrmStandardUser.edtCustomCharactersChange(Sender: TObject);
begin
GenerateCode;
end;

procedure TfrmStandardUser.FormShow(Sender: TObject);
begin
redOutput.Lines.Clear;
imgNightSky.Picture.LoadFromFile('Night_Sky2_Resized.jpg');
imgLogo.Picture.LoadFromFile('Skypass_Logo_Small.png');
rgpPasswordType.ItemIndex := 0;
cbxLowerCase.Checked := True;
cbxUpperCase.Checked := True;
cbxNumbers.Checked := True;
cbxSymbols.Checked := True;
cbxEnteredCharacters.Checked := false;
cbxUniqueCharacters.Checked := false;
pnlCharacters.Hide;
tbrLength.Position := 16;
GenerateCode;
end;

procedure TfrmStandardUser.GenerateCode;
var
sPossibleCharacters, sCode, sUniqueCharacters : String;
iRandom,iLength, iCharacter : Integer;
cRandomCharacter : Char;
begin
  iLength := spnLength.Value;
  sPossibleCharacters := '';
  sCode := '';
  sUniqueCharacters := '';
  shpStrength.Brush.Color := clWhite;
  Randomize;
  CountTypes;
  //If password is selected
  if rgpPasswordType.ItemIndex = 0 then
  begin
    //Create a variable with the possible characters
    if cbxLowerCase.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sLowerCase;
    if cbxUpperCase.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sUpperCase;
    if cbxNumbers.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sNumbers;
    if cbxSymbols.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sSymbols;

    if sPossibleCharacters <> '' then
    begin
      //Generate the password
      for iRandom := 1 to iLength do
      begin
        sCode := sCode + sPossibleCharacters[RandomRange(1,Length(sPossibleCharacters)+1)];
      end;
      redOutput.Clear;
      redOutput.Lines.Add(sCode);
    end;

    //Check password strength
    case iLength of
      1..5 : shpStrength.Brush.Color := clRed;
      6..9 : shpStrength.Brush.Color := clYellow;
      10..15  : shpStrength.Brush.Color := clLime;
      16..50: shpStrength.Brush.Color := clGreen;
    end
  end
  //If passcode is selected
  else if rgpPasswordType.ItemIndex = 1 then
  begin
    //Generate a passcode
    for iRandom := 1 to iLength do
    begin
      sCode := sCode + IntToStr(RandomRange(0,10));
    end;
    redOutput.Clear;
    redOutput.Lines.Add(sCode);

    //Check passcode strength
    case iLength of
    1..5 : shpStrength.Brush.Color := clRed;
    6..9 : shpStrength.Brush.Color := clYellow;
    10..15  : shpStrength.Brush.Color := clLime;
    16..50: shpStrength.Brush.Color := clGreen;
    end
  end
  //If advanced password is selected
  else if rgpPasswordType.ItemIndex = 2 then
  begin
    //Increase the max characters
    tbrLength.Max := 512;
    spnLength.MaxValue := 512;
    iLength := spnLength.Value;

    //Create a variable with the possible characters
    if cbxLowerCase.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sLowerCase;
    if cbxUpperCase.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sUpperCase;
    if cbxNumbers.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sNumbers;
    if cbxSymbols.Checked = true then
      sPossibleCharacters := sPossibleCharacters + sSymbols;
    if cbxEnteredCharacters.Checked = true then
      sPossibleCharacters := redEnterCharacters.Text;

    if sPossibleCharacters <> '' then
    begin
      if cbxUniqueCharacters.Checked = false then
      begin
        //Generate a password WITH duplicate characters
        for iRandom := 1 to iLength do
        begin
          sCode := sCode + sPossibleCharacters[RandomRange(1,Length(sPossibleCharacters)+1)];
        end;
      end
      else if cbxUniqueCharacters.Checked = true then
      begin
        if (Length(sPossibleCharacters) < 512) then
        begin
          for iCharacter := 1 to length(sPossibleCharacters) do
          begin
            //Create a string with the unique characters
            if ContainsStr(sUniqueCharacters,sPossibleCharacters[iCharacter]) = false then
              sUniqueCharacters := sUniqueCharacters + sPossibleCharacters[iCharacter];
          end;
          //Set the max length to the number of unique characters
          spnLength.MaxValue := Length(sUniqueCharacters);
          tbrLength.Max := Length(sUniqueCharacters);
          iLength := spnLength.Value;
        end;
        //Generate a password WITHOUT duplicate characters
        while Length(sCode) < iLength do
        begin
          cRandomCharacter := sPossibleCharacters[RandomRange(1,Length(sPossibleCharacters)+1)];
            if ContainsStr(sCode,cRandomCharacter) = false then
              sCode := sCode + cRandomCharacter;
        end;
      end;
      redOutput.Clear;
      redOutput.Lines.Add(sCode);
    end;
    //Check password strength
    case iLength of
      1..5 : shpStrength.Brush.Color := clRed;
      6..9 : shpStrength.Brush.Color := clYellow;
      10..15  : shpStrength.Brush.Color := clLime;
      16..512: shpStrength.Brush.Color := clGreen;
    end
  end;
end;


procedure TfrmStandardUser.redEnterCharactersChange(Sender: TObject);
var
  iCharacter : Integer;
  bValid : Boolean;
begin
  bValid := true;
  //Check that there are no line breaks
  if ContainsStr(redEnterCharacters.Text,#13) then
  begin
      MessageDlg('Character Invalid',mtError,[mbOK],0);
      redEnterCharacters.Lines.Clear;
      bValid := false;
  end;
  //Check that each character is in the valid character range
  for iCharacter := 1 to Length(redEnterCharacters.Text) do
  begin
    if ContainsStr(sValidCharacters,redEnterCharacters.Text[iCharacter]) = false then
    begin
        MessageDlg('Character Invalid',mtError,[mbOK],0);
        redEnterCharacters.Lines.Clear;
        bValid := false;
    end;
  end;
  if bValid = true then
    GenerateCode;
end;

procedure TfrmStandardUser.rgpPasswordTypeClick(Sender: TObject);
begin
if rgpPasswordType.ItemIndex = 0 then
begin
  //Allow the user to generate a password
  pnlPassword.Show;
  spnLength.MaxValue := 50;
  tbrLength.Max := 50;
  pnlAdvanced.hide;
  pnlCharacters.Hide;
  cbxEnteredCharacters.Checked := false;
  cbxUniqueCharacters.Checked := false;
end
else if rgpPasswordType.ItemIndex = 1 then
begin
  //Allow the user to generate a passcode
  pnlPassword.Hide;
  spnLength.MaxValue := 50;
  tbrLength.Max := 50;
  pnlAdvanced.hide;
  pnlCharacters.Hide;
end
else if rgpPasswordType.ItemIndex = 2 then
begin
  //Allow the user to generate an advanced password
  pnlPassword.Show;
  spnLength.MaxValue := 512;
  tbrLength.Max := 512;
  pnlAdvanced.show;
  cbxEnteredCharacters.Checked := false;
end;
GenerateCode;
end;

procedure TfrmStandardUser.spnLengthChange(Sender: TObject);
begin
tbrLength.Position := spnLength.Value;
end;

procedure TfrmStandardUser.tbrLengthChange(Sender: TObject);
begin
spnLength.value := tbrLength.position;
GenerateCode;
end;

end.
