unit uAxInstallerRestObj;

{
  uAxInstallerRestObj.pas
  -----------------------
  Shared business-logic wrapper used by the ISAPI DLL (AxInstallerRest.dpr).

  TMain is now declared in uAxInstallerMain.pas (extracted from the DPR)
  so both the console app and the DLL can reference it as a proper unit.

  Output-capture strategy
  -----------------------
  TAxOutputCapture swaps the InOutFunc/FlushFunc pointers in Delphi's
  global Output (TTextFile) variable so all Write/WriteLn calls inside
  parseCommand are captured into a TStringList instead of going to stdout.
  A threadvar makes it per-thread — safe for concurrent IIS requests.

  Compatibility: Delphi XE3, XE8, 10.1 Berlin (Win32 / Win64)
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Data.DBXJSON,
  uAxInstallerMain;   { <-- TMain now lives here, not in the DPR }

type
  { Result record returned by ProcessCommand }
  TAxCommandResult = record
    Success : Boolean;
    Msg     : string;
  end;

  { Captures all Write/WriteLn calls into an in-memory buffer }
  TAxOutputCapture = class
  private
    FSavedOutput : TTextRec;
    FBuffer      : TStringList;
    FCurrentLine : string;
    FActive      : Boolean;
    procedure FlushCurrentLine;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Start;
    procedure Stop;
    function  CollectOutput: string;
    property  Active: Boolean read FActive;
  end;

  { Thread-safe wrapper that drives TMain through one API call }
  TAxInstallerObj = class
  private
    FCritSec : TCriticalSection;
  public
    constructor Create;
    destructor  Destroy; override;
//    function ProcessCommand(const AProject  : string;
//                            const ACommand  : string;
//                            ATrace          : Boolean): TAxCommandResult;
    function ProcessCommand(AJSONObj : TJSONObject): TAxCommandResult;
    function GetJSONString(AObj: TJSONObject; const AKey: string): string;

  end;

var
  GAxInstallerObj : TAxInstallerObj = nil;

implementation

uses
  uUtils,
  uAxLog,
  uConfig,
  uInItApp;

{ ============================================================
  Output capture — threadvar so each IIS thread is isolated
  ============================================================ }
threadvar
  _CaptureInstance: TAxOutputCapture;

function CaptureInOutFunc(var F: TTextRec): Integer;
var
  Cap : TAxOutputCapture;
  S   : string;
  I   : Integer;
begin
  Result := 0;
  Cap := _CaptureInstance;
  if Cap = nil then Exit;
  case F.Mode of
    fmOutput:
    begin
      if F.BufPos > 0 then
      begin
        //SetString(S, PAnsiChar(@F.BufPtr^[0]), F.BufPos);
        SetString(S, PAnsiChar(F.BufPtr), F.BufPos);
        for I := 1 to Length(S) do
        begin
          if S[I] = #10 then
          begin
            Cap.FBuffer.Add(Cap.FCurrentLine);
            Cap.FCurrentLine := '';
          end
          else if S[I] <> #13 then
            Cap.FCurrentLine := Cap.FCurrentLine + S[I];
        end;
        F.BufPos := 0;
      end;
    end;
  end;
end;

function CaptureFlushFunc(var F: TTextRec): Integer;
begin
  Result := CaptureInOutFunc(F);
end;

{ ============================================================
  TAxOutputCapture
  ============================================================ }
constructor TAxOutputCapture.Create;
begin
  inherited;
  FBuffer      := TStringList.Create;
  FCurrentLine := '';
  FActive      := False;
end;

destructor TAxOutputCapture.Destroy;
begin
  if FActive then Stop;
  FreeAndNil(FBuffer);
  inherited;
end;

procedure TAxOutputCapture.Start;
begin
  if FActive then Exit;
  Move(Output, FSavedOutput, SizeOf(TTextRec));
  TTextRec(Output).InOutFunc := @CaptureInOutFunc;
  TTextRec(Output).FlushFunc := @CaptureFlushFunc;
  _CaptureInstance := Self;
  FBuffer.Clear;
  FCurrentLine := '';
  FActive := True;
end;

procedure TAxOutputCapture.Stop;
begin
  if not FActive then Exit;
  FlushCurrentLine;
  Move(FSavedOutput, Output, SizeOf(TTextRec));
  _CaptureInstance := nil;
  FActive := False;
end;

procedure TAxOutputCapture.FlushCurrentLine;
begin
  if FCurrentLine <> '' then
  begin
    FBuffer.Add(FCurrentLine);
    FCurrentLine := '';
  end;
end;

function TAxOutputCapture.CollectOutput: string;
begin
  FlushCurrentLine;
  Result := FBuffer.Text;
end;

{ ============================================================
  TAxInstallerObj
  ============================================================ }
constructor TAxInstallerObj.Create;
begin
  inherited;
  FCritSec := TCriticalSection.Create;
end;

destructor TAxInstallerObj.Destroy;
begin
  FreeAndNil(FCritSec);
  inherited;
end;

//function TAxInstallerObj.ProcessCommand(const AProject  : string;
//                                        const ACommand  : string;
//                                        ATrace          : Boolean): TAxCommandResult;
function TAxInstallerObj.ProcessCommand(AJSONObj : TJSONObject): TAxCommandResult;
var
  Cap        : TAxOutputCapture;
  MainInst   : TMain;           { TMain is now in uAxInstallerMain.pas }
  CfgResult  : string;
  CmdResult  : string;
  RawOutput  : string;

  AProject   : string;
  ACommand   : string;
  ATrace     : string;
  bTrace     : Boolean;
begin
  Result.Success := False;
  Result.Msg     := '';

  AProject := GetJSONString(AJSONObj, 'project');
  ACommand := GetJSONString(AJSONObj, 'command');
  ATrace   := GetJSONString(AJSONObj, 'trace');
  AxIns_Username := GetJSONString(AJSONObj, 'username');
  AxIns_ProductID := GetJSONString(AJSONObj, 'productid');
  TempGitRepo    := GetJSONString(AJSONObj, 'gitrepo');
  TempGitAcc     := GetJSONString(AJSONObj, 'gitaccount');
  installtype    := GetJSONString(AJSONObj, 'type');
  TempGitTok     := GetJSONString(AJSONObj,'gittoken');
  ARMSessionIdFromRedis := GetJSONString(AJSONObj, 'ARMSessionId');
  IsSessionIdFromPayload := Trim(ARMSessionIdFromRedis) <> '';

  bTrace := SameText(Trim(ATrace), 'true') or
          SameText(Trim(ATrace), '1') or
          SameText(Trim(ATrace), 'yes');

  if Trim(ACommand) = '' then
  begin
    //Result.Msg := 'Command cannot be empty.';
    Result.Msg :=
    '{' +
    '"result":"Failed",' +
    '"command":"' + StringReplace(ACommand, '"', '\"', [rfReplaceAll]) + '",' +
    '"message":"' + StringReplace('Command cannot be empty.', '"', '\"', [rfReplaceAll]) + '"' +
    '}';
    Exit;
  end;

    if Trim(AxIns_Username) = '' then
  begin
    //Result.Msg := 'Username cannot be empty.';
    Result.Msg :=
    '{' +
    '"result":"Failed",' +
    '"command":"' + StringReplace(ACommand, '"', '\"', [rfReplaceAll]) + '",' +
    '"message":"' + StringReplace('Username cannot be empty.', '"', '\"', [rfReplaceAll]) + '"' +
    '}';
    Exit;
  end;

  if Trim(AxIns_ProductID) = '' then
   begin
<<<<<<< Updated upstream
    Result.Msg := 'Product_id cannot be empty.';
=======
    //Result.Msg := 'ProductVersion_id cannot be empty.';
    Result.Msg :=
    '{' +
    '"result":"Failed",' +
    '"command":"' + StringReplace(ACommand, '"', '\"', [rfReplaceAll]) + '",' +
    '"message":"' + StringReplace('ProductVersion_id cannot be empty.', '"', '\"', [rfReplaceAll]) + '"' +
    '}';
>>>>>>> Stashed changes
    Exit;
  end;

    if Trim(AProject) = '' then
  begin
    //Result.Msg := 'Project Name cannot be empty.';
       Result.Msg :=
    '{' +
    '"result":"Failed",' +
    '"command":"' + StringReplace(ACommand, '"', '\"', [rfReplaceAll]) + '",' +
    '"message":"' + StringReplace('Project Name cannot be empty.', '"', '\"', [rfReplaceAll]) + '"' +
    '}';
    Exit;
  end;

  if SameText(Trim(ACommand), 'quit') then
  begin
//    Result.Success := True;
//    Result.Msg     := 'quit is not supported in API mode.';
      Result.Msg :=
    '{' +
    '"result":"Failed",' +
    '"command":"' + StringReplace(ACommand, '"', '\"', [rfReplaceAll]) + '",' +
    '"message":"' + StringReplace('quit is not supported in API mode.', '"', '\"', [rfReplaceAll]) + '"' +
    '}';
    Exit;
  end;

  FCritSec.Enter;
  Cap      := nil;
  MainInst := nil;
  RawOutput := '';
  gResponse := '';
  InstallErrMsg := '';
  try
    try
      { 1. Set active connection }
      activeconnection := AProject;
      //EnableDebug      := ATrace;
      //EnableDebug := bTrace;
      //uUtils.PayloadCommand := ACommand;

      LogFileName := '';

      AppDir := GetDLLPath;

      InitLogObj;

      EnableDebug := bTrace;

      { 2. Create TMain (calls InIt + AppInit internally) }
      MainInst := TMain.Create;

      if not Assigned(slUserInstructions) then
        slUserInstructions := TStringList.Create;

      { Start capturing Write/WriteLn }
      Cap := TAxOutputCapture.Create;
      Cap.Start;

      InstallErrMsg := '';

      try

        MainInst.StartPlugin;

        { 3. Activate project connection }
        CfgResult := MainInst.HandleAllConfigCommand(
                       'config set ' + activeconnection, True);

        { 4. Setup application context }
        MainInst.SetApplication;

        { 5. Execute the command }
        CmdResult := MainInst.parseCommand(ACommand);
      finally
        Cap.Stop;
      end;

      //RawOutput := Cap.CollectOutput;

      if gResponse <> '' then
         RawOutput := gResponse
      else
      begin
        PrepareResponse(ACommand,nil);
        RawOutput := gResponse;
      end;

      //RawOutput := gResponse;

      if RawOutput <> '' then
        Result.Msg := TrimRight(RawOutput)
      else if CmdResult <> '' then
        Result.Msg := CmdResult
      else
        Result.Msg := 'Command executed.';

      Result.Success := True;

    except
      on E: Exception do
      begin

        //InstallErrMsg := E.Message;
        InstallErrMsg := E.ClassName + ' : ' + E.Message;
        PrepareResponse(ACommand,nil);

        if Assigned(Cap) and Cap.Active then
        begin
          Cap.Stop;
          //RawOutput := Cap.CollectOutput;
          //RawOutput := gResponse;
        end;
        RawOutput := gResponse;
        Result.Success := False;
//        Result.Msg := 'Error: ' + E.ClassName + ' - ' + E.Message;
//        if RawOutput <> '' then
//          Result.Msg := TrimRight(RawOutput);
         if RawOutput <> '' then
            Result.Msg := TrimRight(RawOutput)
         else
            Result.Msg := 'Error: ' + E.ClassName + ' - ' + E.Message;
        WriteLog('ProcessCommand exception: ' + E.Message);
      end;
    end;
  finally
    UpdateLogObj;
    DestroyLogObj;
    InstallErrMsg := '';
    gResponse := '';
    if Assigned(Cap)      then FreeAndNil(Cap);
    if Assigned(MainInst) then FreeAndNil(MainInst);
    if Assigned(slUserInstructions) then FreeAndNil(slUserInstructions);
    FCritSec.Leave;
  end;
end;


function TAxInstallerObj.GetJSONString(AObj: TJSONObject; const AKey: string): string;
var
  V: TJSONValue;
begin
  Result := '';
  if AObj.Get(AKey) <> nil then
  begin
    V := AObj.Get(AKey).JsonValue;
    if Assigned(V) then
      Result := V.Value;
  end;
end;

end.
