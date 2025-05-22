unit frmAdministrator_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, frmStandardUser_u,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, StrUtils,
  Vcl.Imaging.pngimage, System.UITypes;

type
  TfrmAdministrator = class(TForm)
    imgNightSky: TImage;
    btnDeleteUser: TButton;
    lblNumUsers: TLabel;
    btnChangeLogin: TButton;
    memLog: TMemo;
    bbnClose: TBitBtn;
    btnClearLog: TButton;
    btnDeleteAllUsers: TButton;
    lblEmails: TLabel;
    lblLog: TLabel;
    lblOtherOptions: TLabel;
    shpLine3: TShape;
    shpLine1: TShape;
    shpLine2: TShape;
    edtSearchLog: TEdit;
    lblSearch: TLabel;
    lstEmails: TListBox;
    imgLogo: TImage;
    procedure btnDeleteUserClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnChangeLoginClick(Sender: TObject);
    procedure LoadEmails;
    procedure btnClearLogClick(Sender: TObject);
    procedure btnDeleteAllUsersClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtSearchLogChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function getAdminUsername : String;
    function getAdminPassword : String;
  end;

var
  frmAdministrator: TfrmAdministrator;
  tLoginInfo, tAdminLogin, tLog : TextFile;
  sAdminUsername, sAdminPassword : String;

implementation

{$R *.dfm}

uses
frmlogin_u;

procedure TfrmAdministrator.btnChangeLoginClick(Sender: TObject);
var
sLine, sNewAdminUsername, sNewAdminPassword, sVerifyAdminPassword : String;
iCharacter : Integer;
bValid : Boolean;
begin
  sAdminUsername := getAdminUsername;
  sAdminPassword := getAdminPassword;
  bValid := true;

  //Confirm changing of login details
  if (MessageDlg('Are you sure you want to change your login details?', mtConfirmation,[mbYes, mbNo], 0, mbYes) = mrYes) then
  begin
    //Enter the old password
    if InputQuery('Verify Password','Enter your current password',sVerifyAdminPassword) = true then
    begin
      //Check if the old password is correct
      if sVerifyAdminPassword <> sAdminPassword then
      begin
        MessageDlg('Password incorrect',mtError,[mbOK],0);
      end
      else
      //If the old password is correct
      begin
        sNewAdminUsername := InputBox('Change Username','Enter your new username',sAdminUsername);
        //Validate the new username
        if (sNewAdminUsername <> '') and (Length(sNewAdminUsername) <=50) then
        begin
          for iCharacter := 1 to Length(sNewAdminUsername) do
          begin
            //Check if the character is in valid range
            if not (sNewAdminUsername[iCharacter] in ['0'..'9','A'..'Z','a'..'z','+','-','_','~','@','.']) then
              bValid := false;
          end;
          if bValid = false then
            MessageDlg('Enter a valid username',mtError,[mbOK],0);
        end
        else
        begin
           bValid := false;
           MessageDlg('Enter a valid username',mtError,[mbOK],0);
        end;

        //If the username is valid
        if bValid = true then
        begin
          sNewAdminPassword :=  InputBox('Change Password','Enter your new password',sAdminPassword);
          //Validate the newpassword
          if (sNewAdminPassword <> '') and (Length(sNewAdminPassword) <=50) then
          begin
            for iCharacter := 1 to Length(sNewAdminPassword) do
            begin
              //Check if the character is in valid range
              if not (sNewAdminPassword[iCharacter] in ['0'..'9','A'..'Z','a'..'z','+','-','_','~','@','.']) then
                bValid := false;
            end;
            if bValid = false then
              MessageDlg('Enter a valid password',mtError,[mbOK],0);
          end
          else
          begin
            bValid := false;
            MessageDlg('Enter a valid password',mtError,[mbOK],0);
          end;
        end;

        //If both the username and password are valid
        if bValid = true then
        begin
          //Read from the text file
          AssignFile(tAdminLogin,'Admin_Login.txt');
          Reset(tAdminLogin);
          Readln(tAdminLogin,sLine);
          if not (sLine = sNewAdminUsername +'#'+ sNewAdminPassword) then
          begin
            //Write to the text file
            Rewrite(tAdminLogin);
            Writeln(tAdminLogin,sNewAdminUsername+'#'+sNewAdminPassword);
            MessageDlg('Login Details Changed',mtInformation,[mbOK],0);
            frmlogin_u.frmLogin.CreateLogEntry(sAdminUsername,' changed their login details at ');
            memLog.Lines.LoadFromFile('Log.txt');
          end
          else
            MessageDlg('No changes have been made',mtInformation,[mbOK],0);
          CloseFile(tAdminLogin);
        end;
      end;
    end;
  end;
end;

procedure TfrmAdministrator.btnLogoutClick(Sender: TObject);
begin
frmAdministrator.Close;
end;

procedure TfrmAdministrator.btnClearLogClick(Sender: TObject);
begin
if ((MessageDlg('Are you sure you want to clear the log?',mtConfirmation,[mbYes,mbNo],0)) = mrYes) then
begin
  //Clear the log text file
  memLog.Lines.Clear;
  memLog.Lines.SaveToFile('Log.txt');
  MessageDlg('Log Cleared',mtInformation,[mbOK],0);
end;
end;

procedure TfrmAdministrator.btnDeleteAllUsersClick(Sender: TObject);
var
sEnteredPassword, sReenteredPassword : String;
begin
sAdminPassword := getAdminPassword;

if FileExists('Login_Info.txt') then
begin
  //Make the admin enter their password twice
  if InputQuery('Enter Password','Enter your administrator password:', sEnteredPassword) = true then
  begin
    if InputQuery('Re-Enter Password','Re-enter your administrator password: ', sReenteredPassword) = true then
    begin
      //Check if the passwords are both correct
      if (sEnteredPassword = sAdminPassword) and (sReenteredPassword = sAdminPassword) then
      begin
        if MessageDlg('Are you sure you want to erase all user accounts?', mtConfirmation,[mbYes, mbNo], 0, mbYes) = mrYes then
        begin
          //Clear the login info text file
          AssignFile(tLoginInfo,'Login_Info.txt');
          Rewrite(tLoginInfo);
          CloseFile(tLoginInfo);
          LoadEmails;
          frmlogin_u.frmLogin.CreateLogEntry(getAdminUsername,' erased all user accounts at ');
          memLog.Lines.LoadFromFile('Log.txt');
        end;
      end
      else
        MessageDlg('Incorrect Password',mtError,[mbOk],0);
    end;
  end;
end;
end;

procedure TfrmAdministrator.btnDeleteUserClick(Sender: TObject);
var
  sLoginList : tStringList;
  sEmailToDelete : String;
  iIndex : Integer;
begin
if FileExists('Login_Info.txt') = False then
begin
  MessageDlg('Login info missing',mtError,[mbOk],0);
end
else
begin
//Check if a user is selected
if lstEmails.ItemIndex <> -1 then
begin
  sEmailToDelete := lstEmails.Items[lstEmails.ItemIndex];
  if MessageDlg('Are you sure you want to delete '+sEmailToDelete+'''s account?',mtConfirmation,[mbYes, mbNo], 0, mbYes) = mrYes then
  begin
  //Find that user in the login info
  sLoginList := TStringList.Create;
  sLoginList.LoadFromFile('Login_Info.txt');
  sLoginList.NameValueSeparator := '#';
  iIndex := sLoginList.IndexOfName(sEmailToDelete);
  //Check that the user if found in the text file
   if (iIndex  <> -1) then
   begin
      //Delete that user from the login info text file
      sLoginList.Delete(iIndex);
      sLoginList.SaveToFile('Login_Info.txt');
      MessageDlg('User deleted',mtInformation,[mbOk],0);
      sLoginList.Free;
      LoadEmails;
      frmlogin_u.frmLogin.CreateLogEntry(sEmailToDelete,' was deleted by '+getAdminUsername+' at ');
      memLog.Lines.LoadFromFile('Log.txt');
   end;
  end;
end
else
  MessageDlg('Select a user',mtError,[mbOk],0)
end;

end;

procedure TfrmAdministrator.edtSearchLogChange(Sender: TObject);
var
  sLine, sSearch : String;
begin
if FileExists('Log.txt') then
begin
  AssignFile(tLog,'Log.txt');
  Reset(tLog);
  sSearch := edtSearchLog.Text;

  if sSearch <> '' then
  begin
    memLog.Clear;
    //Check if each line of the log contains the search query
    while not eof(tLog) do
    begin
      Readln(tLog,sLine);
      if ContainsText(sLine,sSearch) = True then
      begin
        //Display only the lines that contain the search query
        memLog.Lines.Add(sLine);
        memLog.Lines.Add('');
      end;
    end;
  end
  else
  begin
    memLog.Clear;
    memLog.Lines.LoadFromFile('Log.txt');
  end;
  CloseFile(tLog);
end;
end;

procedure TfrmAdministrator.FormActivate(Sender: TObject);
begin
//Update the log and list of emails
LoadEmails;
memLog.Lines.LoadFromFile('Log.txt');
end;

procedure TfrmAdministrator.FormShow(Sender: TObject);
begin
imgNightSky.Picture.LoadFromFile('Night_Sky2_Resized.jpg');
imgLogo.Picture.LoadFromFile('Skypass_Logo_Small.png');
lstEmails.Clear;
end;

function TfrmAdministrator.getAdminPassword: String;
var
  sLine : String;
begin
//Retrive the admin password from the text file
if FileExists('Admin_Login.txt') then
begin
  AssignFile(tAdminLogin,'Admin_Login.txt');
  Reset(tAdminLogin);
  Readln(tAdminLogin,sLine);
  result := Copy(sLine,pos('#',sLine)+1,length(sLine));
  CloseFile(tAdminLogin);
end
else
  MessageDlg('Admin Login Info Missing',mtError,[mbOK],0);
end;

function TfrmAdministrator.getAdminUsername: String;
var
  sLine : String;
begin
//Retrive the admin username from the text file
if FileExists('Admin_Login.txt') then
begin
  AssignFile(tAdminLogin,'Admin_Login.txt');
  Reset(tAdminLogin);
  Readln(tAdminLogin,sLine);
  result := Copy(sLine,1,Pos('#',sLine)-1);
  CloseFile(tAdminLogin);
end
else
  MessageDlg('Admin Login Info Missing',mtError,[mbOK],0);
end;

procedure TfrmAdministrator.LoadEmails;
var
  sLine, sEmail : String;
begin
sEmail := '';
if FileExists('Login_Info.txt') then
begin
  //Read from the login info text file
  AssignFile(tLoginInfo,'Login_Info.txt');
  Reset(tLoginInfo);
  lstEmails.Clear;
  //Output the email from each line to lstEmails
  while not Eof(tLoginInfo) do
  begin
    Readln(tLoginInfo,sLine);
    sEmail := Copy(sLine,1,Pos('#',sLine)-1);
    lstEmails.Items.Add(sEmail);
    sEmail := '';
  end;
  //Display the number of users
  lblNumUsers.Caption := 'Number of users: '+IntToStr(lstEmails.Count);
  CloseFile(tLoginInfo);
end
else
  MessageDlg('Login info missing',mtError,[mbOk],0);
end;

end.
