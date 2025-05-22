unit frmCreateAccount_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, strutils,
  Vcl.Imaging.jpeg, math, Vcl.Mask, System.Actions, Vcl.ActnList, Vcl.ExtActns, frmStandardUser_u,
  Vcl.Imaging.pngimage,System.UITypes;

type
  TfrmCreateAccount = class(TForm)
    lblCreatePassword: TLabel;
    edtCreatePassword: TEdit;
    edtEmail: TEdit;
    lblEnterEmail: TLabel;
    btnCreateAccount: TButton;
    lblVerifyPassword: TLabel;
    edtVerifyPassword: TEdit;
    bbnHidePassword: TBitBtn;
    bbnShowPassword: TBitBtn;
    bbnHideVerifyPassword: TBitBtn;
    bbnShowVerifyPassword: TBitBtn;
    bbnClose: TBitBtn;
    imgNightSky: TImage;
    lblCreateAccount: TLabel;
    imgCaptcha: TImage;
    lblCaptcha: TLabel;
    edtCaptcha: TEdit;
    bbnRefresh: TBitBtn;
    lblEmailValid: TLabel;
    lblPasswordValid: TLabel;
    imgLogo: TImage;
    procedure btnCreateAccountClick(Sender: TObject);
    procedure bbnShowPasswordClick(Sender: TObject);
    procedure bbnHidePasswordClick(Sender: TObject);
    procedure bbnCloseClick(Sender: TObject);
    procedure bbnRefreshClick(Sender: TObject);
    procedure bbnHideVerifyPasswordClick(Sender: TObject);
    procedure bbnShowVerifyPasswordClick(Sender: TObject);
    procedure GenerateCaptcha;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmCreateAccount: TfrmCreateAccount;
  tLoginInfo, tLog : TextFile;

const
  sCaptchaCharacters : String = 'abcdefghkmnpqrstuvwxyzABCDEFGHMNPRSTUVWXYZ23456789';

implementation

{$R *.dfm}

uses frmLogin_u;

procedure TfrmCreateAccount.bbnHidePasswordClick(Sender: TObject);
begin
//Hide the password
edtCreatePassword.PasswordChar := '*';
bbnShowPassword.Visible := true;
bbnHidePassword.Visible := false;
end;

procedure TfrmCreateAccount.bbnHideVerifyPasswordClick(Sender: TObject);
begin
//Hide the verified password
edtVerifyPassword.PasswordChar := '*';
bbnShowVerifyPassword.Visible := True;
bbnHideVerifyPassword.Visible := false;
end;

procedure TfrmCreateAccount.bbnRefreshClick(Sender: TObject);
begin
GenerateCaptcha;
end;

procedure TfrmCreateAccount.bbnShowPasswordClick(Sender: TObject);
begin
//Show the password
edtCreatePassword.PasswordChar := #0;
bbnShowPassword.Visible := false;
bbnHidePassword.Visible := true;
end;

procedure TfrmCreateAccount.bbnShowVerifyPasswordClick(Sender: TObject);
begin
//Show the verified password
edtVerifyPassword.PasswordChar := #0;
bbnShowVerifyPassword.Visible := false;
bbnHideVerifyPassword.Visible := true;
end;

procedure TfrmCreateAccount.bbnCloseClick(Sender: TObject);
begin
frmCreateAccount.Close;
end;

procedure TfrmCreateAccount.btnCreateAccountClick(Sender: TObject);
var
  sLine, sCreateEmail, sCreatePassword, sInputtedAnswer : String;
  bValid, bDot : Boolean;
  iPosAt, iCharacter, iInvalid, iNumAt : Integer;
begin
sCreateEmail := edtEmail.Text;
sInputtedAnswer := edtCaptcha.Text;
bValid := True;
bDot := False;
iInvalid := 0;
iNumAt := 0;
lblEmailValid.Caption := '';
lblPasswordValid.Caption := '';

//Validate Password
if (edtCreatePassword.Text = '') or (length(edtCreatePassword.Text) > 50) then
begin
  lblPasswordValid.Caption := 'Enter a valid password';
  bValid := False;
end
else if ContainsStr(edtCreatePassword.Text,'#') then
begin
  lblPasswordValid.Caption := 'Password cannot contain a #';
  bValid := False;
end
else if not (edtCreatePassword.Text = edtVerifyPassword.Text) then
begin
  lblPasswordValid.Caption := 'Passwords do not match';
  bValid := False;
end
else
begin
  sCreatePassword := edtCreatePassword.Text;
end;

//Validate Email
if (sCreateEmail = '') or (Length(sCreateEmail) > 50) then
begin
  lblEmailValid.Caption := 'Enter a valid email address';
  bValid := false
end
else
begin
iPosAt := pos('@',sCreateEmail);
if iPosAt > 0 then   //If @ is found
begin
    for iCharacter := iPosAt to length(sCreateEmail) do
    begin
      //Check if there is another @
      if sCreateEmail[iCharacter] = '@' then
      begin
        iNumAt := iNumAt + 1;
      end;
      //Check that there is a . after the @
      if sCreateEmail[iCharacter] = '.' then
      begin
        bDot := True;
      end;
    end;
  //If there is not a . after @
  if bDot = false then
  begin
    lblEmailValid.Caption := 'Enter a valid email address';
    bValid := false
  end;
  //If there are too many @'s
  if iNumAt > 1 then
  begin
    lblEmailValid.Caption := 'Enter a valid email address';
    bValid := false
  end;
  for iCharacter := 1 to Length(sCreateEmail) do
  begin
    //Check if the character is in valid range
    if not (sCreateEmail[iCharacter] in ['0'..'9','A'..'Z','a'..'z','+','-','_','~','@','.']) then
    begin
      iInvalid := iInvalid + 1;
    end;
  end;
  //If there are any invalid characters
  if iInvalid > 0 then
  begin
    lblEmailValid.Caption := 'Enter a valid email address';
    bValid := false
  end;
end
else
begin
  lblEmailValid.Caption := 'Enter a valid email address';
  bValid := false
end;
end;

if not FileExists('Login_Info.txt') then
begin
  MessageDlg('Login info missing',mtError,[mbOk],0);
end
else
begin
  //Check if email is already registered
  AssignFile(tLoginInfo,'Login_Info.txt');
  Reset(tLoginInfo);
  while not Eof(tLoginInfo) do
  begin
    ReadLn(tLoginInfo,sLine);
    if ContainsStr(sLine,sCreateEmail+'#') = True then
    begin
      lblEmailValid.Caption := 'Email already registered';
      bValid := False;
    end;
  end;

  if bValid = True then
  begin
    //Check if CAPTCHA is correct
    if not (sInputtedAnswer = sCaptchaAnswer) then
    begin
      MessageDlg('Please retry CAPTCHA',mtError,[mbOk],0);
      GenerateCaptcha;
      bValid := False;
    end;
  end;

  //If email is valid, does not already exist, password is valid and CAPTCHA is correct
  if bValid = True then
  begin
    //Add account to list of accounts
    Append(tLoginInfo);
    Writeln(tLoginInfo, sCreateEmail+'#'+sCreatePassword);
    MessageDlg('Account Created, Welcome to SkyPass!',mtInformation,[mbOK], 0);
    frmLogin_u.frmLogin.CreateLogEntry(sCreateEmail,' created an account at ');
    //Open the password generator
    frmStandardUser.Show;
    edtCreatePassword.Clear;
    edtEmail.Clear;
    edtVerifyPassword.Clear;
    GenerateCaptcha;
    frmCreateAccount.Close;
  end
  else
    GenerateCaptcha;
  CloseFile(tLoginInfo);
end;
end;


procedure TfrmCreateAccount.FormShow(Sender: TObject);
begin
GenerateCaptcha;
edtEmail.SetFocus;
imgNightSky.Picture.LoadFromFile('Night_Sky1_Resized.jpg');
imgLogo.Picture.LoadFromFile('Skypass_Logo_XL.png');
end;

procedure TfrmCreateAccount.GenerateCaptcha;
var
  iCP : Integer;
begin
imgCaptcha.Picture := nil;
edtCaptcha.Clear;

//Set the font for the CAPTCHA
with imgCaptcha.Canvas.Font do
begin
  Name := 'Tempus Sans ITC';
  Style := [fsBold];
  Color := clBlack;
  Size := 20;
  Orientation := 50;
end;

sCaptchaAnswer := '';
Randomize;

//Generate the text for the CAPTCHA
for iCP := 1 to 6 do
begin
  sCaptchaAnswer := sCaptchaAnswer + sCaptchaCharacters[randomrange(1, length(sCaptchaCharacters)+1)];
end;

imgCaptcha.Canvas.TextOut(20, 15, sCaptchaAnswer);

//Create random lines over the CAPTCHA text
for iCP := 0 to 15 do
begin
  imgCaptcha.Canvas.Pen.Color := Random(100000);
  imgCaptcha.Canvas.MoveTo(random(imgCaptcha.Width), random(imgCaptcha.Height));
  imgCaptcha.Canvas.LineTo(random(imgCaptcha.Width), random(imgCaptcha.Height));
end;
end;

end.
