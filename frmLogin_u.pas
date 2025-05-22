unit frmLogin_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, frmAdministrator_u, frmStandardUser_u,
  Vcl.ExtCtrls, Vcl.Buttons, Math, frmCreateAccount_u, Vcl.Imaging.jpeg,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, strUtils, Vcl.Imaging.pngimage,System.UITypes;

type
  TfrmLogin = class(TForm)
    edtEmail: TEdit;
    imgCaptcha: TImage;
    edtCaptcha: TEdit;
    btnLogin: TButton;
    bbnClose: TBitBtn;
    lblEmail: TLabel;
    lblPassword: TLabel;
    lblCaptcha: TLabel;
    lblNoAccount: TLabel;
    lblCreateAccount: TLabel;
    bbnRefresh: TBitBtn;
    bbnShowPassword: TBitBtn;
    bbnHidePassword: TBitBtn;
    imgNightSky: TImage;
    lblLogin: TLabel;
    edtPassword: TEdit;
    lblEmailCorrect: TLabel;
    lblPasswordCorrect: TLabel;
    imgLogo: TImage;
    procedure lblCreateAccountClick(Sender: TObject);
    procedure bbnShowPasswordClick(Sender: TObject);
    procedure bbnHidePasswordClick(Sender: TObject);
    procedure bbnCloseClick(Sender: TObject);
    procedure bbnRefreshClick(Sender: TObject);
    procedure GenerateCaptcha;
    procedure btnLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CreateLogEntry(sEmail,sEntry : String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmLogin: TfrmLogin;
  sCaptchaAnswer, sEmail : String;
  tLog, tLoginInfo, tAdminLogin : TextFile;

const
  sCaptchaCharacters : String = 'abcdefghkmnpqrstuvwxyzABCDEFGHMNPRSTUVWXYZ23456789';

implementation

{$R *.dfm}
procedure TfrmLogin.bbnCloseClick(Sender: TObject);
begin
//Close all the forms
frmCreateAccount.Close;
frmAdministrator.Close;
frmStandardUser.Close;
frmLogin.Close;
end;

procedure TfrmLogin.bbnHidePasswordClick(Sender: TObject);
begin
//Hide the password
edtPassword.PasswordChar := '*';
bbnShowPassword.Visible := true;
bbnHidePassword.Visible := false;
end;

procedure TfrmLogin.bbnRefreshClick(Sender: TObject);
begin
GenerateCaptcha;
end;

procedure TfrmLogin.bbnShowPasswordClick(Sender: TObject);
begin
//Show the password
edtPassword.PasswordChar := #0;
bbnShowPassword.Visible := false;
bbnHidePassword.Visible := true;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  sPassword, sLine, sInputtedAnswer : String;
begin
sEmail := edtEmail.Text;
sPassword := edtPassword.Text;
sInputtedAnswer := edtCaptcha.Text;

lblEmailCorrect.Caption := '';
lblPasswordCorrect.Caption := '';

if FileExists('Admin_Login.txt') then
begin
  //Reads the first (and only) line of the administrator login text file
  AssignFile(tAdminLogin,'Admin_Login.txt');
  Reset(tAdminLogin);
  Readln(tAdminLogin,sLine);
  if (sLine = sEmail+'#'+sPassword) then
  begin
    if (sInputtedAnswer = sCaptchaAnswer) then
    begin
      //Open to the admin console
       CreateLogEntry(sEmail,' logged on using their administrator login at ');
       frmAdministrator.Show;
       edtEmail.Clear;
       edtPassword.Clear;
       lblEmailCorrect.Caption := '';
       lblPasswordCorrect.Caption := '';
       GenerateCaptcha;
       exit
    end
    else
    begin
      //If CAPTCHA is incorrect
      MessageDlg('Please retry CAPTCHA',mtError,[mbOk],0);
      GenerateCaptcha;
      exit
    end;
  end;
end;

  if sEmail = '' then
  begin
    lblEmailCorrect.Caption := 'Enter your email';
  end;
  if sPassword = '' then
  begin
    lblPasswordCorrect.Caption := 'Enter your password';
  end;

if (sEmail <> '') and (sPassword <> '') then
begin
//Open the login info text file for reading
  if FileExists('Login_Info.txt') = true then
  begin
    AssignFile(tLoginInfo,'Login_Info.txt');
    Reset(tLoginInfo);
    while not Eof(tLoginInfo) do
    begin
      Readln(tLoginInfo,sLine);
      //Check if email and password are both correct
      if (sLine = sEmail+'#'+sPassword) then
      begin
        //If login detail were correct, check if CAPTCHA answer was correct
        if (sInputtedAnswer = sCaptchaAnswer) then
        begin
          //Open the password generator
          CreateLogEntry(sEmail,' logged on at ');
          edtEmail.Clear;
          edtPassword.Clear;
          GenerateCaptcha;
          lblEmailCorrect.Caption := '';
          lblPasswordCorrect.Caption := '';
          frmStandardUser.Show;
          exit
        end
        else
        begin
          //If CAPTCHA is incorrect
           MessageDlg('Please retry CAPTCHA',mtError,[mbOk],0);
           GenerateCaptcha;
           exit
        end;
      end
      else if ContainsStr(sLine,sEmail+'#') = true then
      begin
        //If email has been registered, but password is incorrect
        lblPasswordCorrect.Caption := 'Password Incorrect';
        GenerateCaptcha;
        exit
      end;
    end; //Once the whole text file has been checked
    //If email has not been registered
    lblEmailCorrect.Caption := 'Email Incorrect';
    GenerateCaptcha;
  end
  else
  begin
    //If login info is missing
    MessageDlg('Login info missing',mtError,[mbOk],0);
  end;
end;
end;

procedure TfrmLogin.Button1Click(Sender: TObject);
begin
frmAdministrator.show;
end;

procedure TfrmLogin.Button2Click(Sender: TObject);
begin
frmStandardUser.Show;
end;

procedure TfrmLogin.CreateLogEntry(sEmail: String; sEntry: String);
begin
  //Create an entry in the log according to the inputted information
  if FileExists('Log.txt') = true then
  begin
    AssignFile(tLog, 'Log.txt');
    Append(tLog);
    Writeln(tLog,sEmail+sEntry+DateToStr(Date)+' '+TimeToStr(Now)+#13);
    CloseFile(tLog);
  end
  else
  begin
    MessageDlg('Log file missing',mtError,[mbOk],0);
  end;  
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Create a log entry saying the user has closed the program
  if sEmail <>'' then
  begin
    CreateLogEntry(sEmail,' closed the program at ');
  end
  else
    CreateLogEntry('Unknown user',' closed the program at ');
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
edtEmail.SetFocus;
imgNightSky.Picture.LoadFromFile('Night_Sky1_Resized.jpg');
imgLogo.Picture.LoadFromFile('Skypass_Logo_XL.png');
edtEmail.Clear;
edtPassword.Clear;
GenerateCaptcha;
end;

procedure TfrmLogin.GenerateCaptcha;
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

procedure TfrmLogin.lblCreateAccountClick(Sender: TObject);
begin
frmCreateAccount.Show;
end;

end.
