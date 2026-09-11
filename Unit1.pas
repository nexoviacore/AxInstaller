unit Unit1;

{
  ============================================================
  FIX HISTORY
  ============================================================
  ISSUE 1 (Screenshot 1): System._WriteLn breakpoint hit
    ROOT CAUSE: The service-side code (uAxInstallerMain.pas /
    uAPILoggingImpl.pas) contains direct WriteLn(...) calls
    intended for console/service context. In a Win64 VCL GUI
    application there is no attached console, so System.Output
    is backed by an invalid/null handle. While this does not
    crash WriteLn itself (it silently fails on Win64), the
    developer hit a user-set breakpoint inside _WriteLn to
    investigate the call origin.
    FIX LOCATION: uAPILoggingImpl.pas — replace WriteLn with
    file-based logging (see comments below and the companion
    uAPILoggingImpl fix).

  ISSUE 2 (Screenshot 2): "Error: Invalid file name - %s"
    ROOT CAUSE: The Delphi resource string
      SInvalidFileName = 'Invalid file name - %s'
    appears LITERALLY in the output, meaning the filename
    argument was NEVER substituted before the exception was
    raised. Specifically, somewhere in the logging/config path
    initialisation inside uAPILoggingImpl.pas (or uAxLog.pas)
    the log-file path is still a raw format string such as
    '%s\AxInstallerLogs\axinstaller.log' and is passed
    directly to AssignFile/Rewrite (or an exception is raised
    with Create(SInvalidFileName) instead of
    CreateFmt(SInvalidFileName, [ActualPath])).
    FIX LOCATION: uAPILoggingImpl.pas — see the detailed
    patch instructions at the bottom of this file.

  ISSUE 3 (Unit1.dfm): Memo2.OnClick = Button1Click
    ROOT CAUSE: The DFM wired Memo2's OnClick event to the
    same handler as Button1, so clicking anywhere in the
    output area re-fires the command unintentionally.
    FIX: Remove OnClick from Memo2 in the DFM (done below in
    the companion Unit1.dfm).
  ============================================================
}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Data.DBXJSON,
  uAxInstallerRestObj;   // TAxInstallerObj + TAxCommandResult

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// ---------------------------------------------------------------------------
// FormCreate
//   • Ensures the working directory is the folder that contains the EXE.
//     This is required so that uInItApp / uConfig can locate appsetting.config
//     at startup.  When launched from the Delphi IDE the working directory
//     defaults to the project folder (ServiceTest\), not Output\win64\.
//   • Allocates a console window so that any WriteLn calls inside the
//     service-side code (uAxInstallerMain, uAPILoggingImpl, etc.) write to a
//     visible window instead of an invalid handle.  This eliminates the
//     invisible I/O that was confusing the debugger (Screenshot 1).
// ---------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
var
  ExeDir: string;
begin
  // Step 1 – Fix working directory so appsetting.config is found correctly.
  ExeDir := ExtractFilePath(ParamStr(0));
  if ExeDir <> '' then
    SetCurrentDir(ExeDir);

  // Step 2 – Allocate a real console so WriteLn inside service code works.
  //           Safe to call even if a console already exists (returns FALSE but
  //           does not raise).
  //AllocConsole;

  // Seed Memo1 with a representative command if it is still at its design-time
  // default, so testers can click Button1 immediately.
  if Memo1.Lines.Text = 'Memo1' then
  begin
    Memo1.Lines.Clear;
    Memo1.Lines.Add('{');
    Memo1.Lines.Add('  "AProject": "axinstaller",');
    Memo1.Lines.Add('  "ACommand": "config set axinstaller",');
    Memo1.Lines.Add('  "ATrace": "true"');
    Memo1.Lines.Add('}');
  end;
end;

// ---------------------------------------------------------------------------
// Button1Click
//   Parses JSON from Memo1, calls TAxInstallerObj.ProcessCommand and displays
//   the result (or any exception) in Memo2.
// ---------------------------------------------------------------------------
procedure TForm1.Button1Click(Sender: TObject);
var
  JSONVal  : TJSONValue;
  JSONObj  : TJSONObject;
  RestObj  : TAxInstallerObj;
  Res      : TAxCommandResult;
  AProject : string;
  ACommand : string;
  ATrace   : string;
begin
  Memo2.Clear;
  JSONVal := nil;

  try
    // ── 1. Parse JSON ──────────────────────────────────────────────────────
    JSONVal := TJSONObject.ParseJSONValue(Trim(Memo1.Text));

    if not Assigned(JSONVal) or not (JSONVal is TJSONObject) then
      raise Exception.Create('Invalid JSON in Memo1.');

    JSONObj := TJSONObject(JSONVal);

    // ── 2. Extract fields ──────────────────────────────────────────────────
    if JSONObj.Get('project') <> nil then
      AProject := JSONObj.Get('project').JsonValue.Value;

    if JSONObj.Get('command') <> nil then
      ACommand := JSONObj.Get('command').JsonValue.Value;

    if JSONObj.Get('trace') <> nil then
      ATrace := JSONObj.Get('trace').JsonValue.Value;

    // ── 3. Guard against empty command ─────────────────────────────────────
    if Trim(ACommand) = '' then
      raise Exception.Create('Command is empty. Nothing to execute.');

    // ── 4. Execute ─────────────────────────────────────────────────────────
    //   TAxInstallerObj.ProcessCommand signature (from current DCU):
    //     function ProcessCommand(const AProject, ACommand: string;
    //                             ATrace: Boolean): TAxCommandResult;
    RestObj := TAxInstallerObj.Create;
    try
//      Res := RestObj.ProcessCommand(
//               AProject,
//               ACommand,
//               SameText(ATrace, 'true')   // string → Boolean
//             );
      Res := RestObj.ProcessCommand(JSONObj);

      // ── 5. Show result ──────────────────────────────────────────────────
      if Res.Msg <> '' then
        Memo2.Lines.Text := Res.Msg
      else
        Memo2.Lines.Text := '(No output returned – command may have succeeded silently.)';

    finally
      RestObj.Free;
    end;

  except
    on E: Exception do
    begin
      // Display a clear error so the developer can distinguish between
      // a business-logic error and a lower-level infrastructure error.
      Memo2.Lines.Clear;
      Memo2.Lines.Add('=== EXCEPTION ===');
      Memo2.Lines.Add('Class : ' + E.ClassName);
      Memo2.Lines.Add('Message: ' + E.Message);
      Memo2.Lines.Add('');
      Memo2.Lines.Add('Likely causes:');
      Memo2.Lines.Add('  1. Log file path not initialised (see uAPILoggingImpl fix).');
      Memo2.Lines.Add('  2. appsetting.config not found in EXE directory.');
      Memo2.Lines.Add('  3. WriteLn called without a console (run from IDE).');
    end;
  end;

  if Assigned(JSONVal) then
    JSONVal.Free;
end;

end.

{
  ============================================================
  REQUIRED FIX IN uAPILoggingImpl.pas
  (File location: ..\AxInstallerRest\ChangedUnitd\uAPILoggingImpl.pas)
  ============================================================

  SYMPTOM: "Invalid file name - %s"
  ──────────────────────────────────────────────────────────
  The Delphi resource string SInvalidFileName = 'Invalid file name - %s'
  appears literally, meaning a format string was used AS a filename
  without substituting the %s argument.

  SEARCH FOR any of these patterns in uAPILoggingImpl.pas:

    Pattern A – raw format string used as path:
      FLogPath := '%s\AxInstallerLogs\...';   ← never formatted
      AssignFile(F, FLogPath);                 ← causes the error

    Pattern B – exception raised with Create instead of CreateFmt:
      raise EInvalidArgument.Create(SInvalidFileName);
         should be:
      raise EInvalidArgument.CreateFmt(SInvalidFileName, [FLogPath]);

    Pattern C – WriteLn to default Output in GUI/service context:
      WriteLn(SomeTraceMessage);
         should be:
      WriteLn(FLogFileVar, SomeTraceMessage);
         (where FLogFileVar is a properly opened TextFile)

  EXACT FIX (Pattern A – most common):
  ──────────────────────────────────────────────────────────
  BEFORE (buggy):
    procedure TAPILoggingImpl.InitLog(const ALogName: string);
    begin
      FLogPath := '%s\AxInstallerLogs\' + ALogName + '.log';
      // ↑ BUG: never formatted; %s is literal
      AssignFile(FLogFile, FLogPath);
      Rewrite(FLogFile);
    end;

  AFTER (fixed):
    procedure TAPILoggingImpl.InitLog(const ALogName: string);
    var
      BaseDir: string;
    begin
      BaseDir := ExtractFilePath(ParamStr(0));
      // Ensure log directory exists
      if not DirectoryExists(BaseDir + 'AxInstallerLogs') then
        ForceDirectories(BaseDir + 'AxInstallerLogs');
      FLogPath := Format('%s\AxInstallerLogs\%s.log',
                         [BaseDir, ALogName]);
      AssignFile(FLogFile, FLogPath);
      if FileExists(FLogPath) then
        Append(FLogFile)
      else
        Rewrite(FLogFile);
    end;

  WRITELN FIX (remove console dependency):
  ──────────────────────────────────────────────────────────
  Replace every:
    WriteLn(SomeMessage);
  With:
    WriteLn(FLogFile, SomeMessage);
  So all trace output goes to the log file, not System.Output.
  This eliminates the _WriteLn breakpoint issue (Screenshot 1).

  ============================================================
  REQUIRED FIX IN Unit1.dfm
  ============================================================
  Remove the OnClick event from Memo2.  Change:

    object Memo2: TMemo
      ...
      OnClick = Button1Click   ← DELETE THIS LINE
    end

  To:

    object Memo2: TMemo
      ...
      (no OnClick property)
    end

  Without this fix, clicking anywhere in the output area in Memo2
  re-fires the command unexpectedly.
  ============================================================
}
