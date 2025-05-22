program SkyPass_p;

uses
  Vcl.Forms,
  frmLogin_u in 'frmLogin_u.pas' {frmLogin},
  frmStandardUser_u in 'frmStandardUser_u.pas' {frmStandardUser},
  frmAdministrator_u in 'frmAdministrator_u.pas' {frmAdministrator},
  frmCreateAccount_u in 'frmCreateAccount_u.pas' {frmCreateAccount},
  Vcl.Themes,
  Vcl.Styles,
  frmSplashScreen_u in 'frmSplashScreen_u.pas' {frmSplashScreen};

{$R *.res}

begin
  Application.Initialize;
  frmSplashScreen := TfrmSplashScreen.Create(nil);
  frmSplashScreen.ShowModal;
  frmSplashScreen.Free;
  frmSplashScreen := nil;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmStandardUser, frmStandardUser);
  Application.CreateForm(TfrmAdministrator, frmAdministrator);
  Application.CreateForm(TfrmCreateAccount, frmCreateAccount);
  Application.Run;
end.
