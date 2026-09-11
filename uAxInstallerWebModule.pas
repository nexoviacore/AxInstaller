unit uAxInstallerWebModule;

//{
//  uAxInstallerWebModule.pas  (pure WebBroker - no DataSnap, no IPPeer)
//  ---------------------------------------------------------------------
//  Handles REST requests directly inside a TWebModule WebAction.
//
//  JSON unit:
//    XE3        -> Data.DBXJSON   (System.JSON did not exist yet)
//    XE8/10.1   -> Data.DBXJSON   (still works; System.JSON also available)
//  Using Data.DBXJSON keeps the file compatible across all three IDEs.
//
//  Endpoint (IIS ISAPI mapping):
//    POST /AxInstallerRest/ProcessCommand
//
//  Request body (JSON):
//    { "project": "myapp", "command": "install 11.3 release10", "trace": "true" }
//
//  Response body (JSON):
//    { "result": "success", "msg": "..." }
//    { "result": "fail",    "msg": "error detail" }
//
//  Compatibility: Delphi XE3, XE8, 10.1 Berlin  (Win32 / Win64)
//}

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DBXJSON,       { XE3-compatible JSON — replaces System.JSON }
  Web.HTTPApp,
  uAxInstallerRestObj;

type
  TAxInstallerWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure ActionProcessCommand(Sender: TObject;
                                   Request: TWebRequest;
                                   Response: TWebResponse;
                                   var Handled: Boolean);
  end;

var
  WebModuleClass: TComponentClass = TAxInstallerWebModule;

implementation

{$R *.dfm}

{ ------------------------------------------------------------------ }
{ Helpers                                                              }
{ ------------------------------------------------------------------ }

function SafeJSONStr(const S: string): string;
begin
  Result := StringReplace(S,      '\',  '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"',  '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
end;

function BuildJSON(const AResult, AMsg: string): string;
begin
  Result := Format('{"result":"%s","msg":"%s"}',
                   [SafeJSONStr(AResult), SafeJSONStr(AMsg)]);
end;

//function GetJSONStr(AObj: TJSONObject; const AKey: string): string;
//var
//  V: TJSONValue;
//begin
//  Result := '';
//  //V := AObj.GetValue(AKey);
//  V := AObj.Get(AKey);
//  if Assigned(V) then
//    Result := V.Value;
//end;
function GetJSONString(AObj: TJSONObject; const AKey: string): string;
var
  V: TJSONValue;
begin
  Result := '';
  if AObj.Get(AKey) <> nil then
  begin
    V := AObj.Get(AKey).JsonValue;   // ✅ FIX
    if Assigned(V) then
      Result := V.Value;
  end;
end;

{ ------------------------------------------------------------------ }
{ TAxInstallerWebModule                                                }
{ ------------------------------------------------------------------ }

procedure TAxInstallerWebModule.WebModuleCreate(Sender: TObject);
begin
  if not Assigned(GAxInstallerObj) then
    GAxInstallerObj := TAxInstallerObj.Create;
end;

procedure TAxInstallerWebModule.WebModuleDestroy(Sender: TObject);
begin
  FreeAndNil(GAxInstallerObj);
end;

procedure TAxInstallerWebModule.ActionProcessCommand(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSONVal  : TJSONValue;
  JSONBody : TJSONObject;
  AProject : string;
  ACommand : string;
  ATrace   : string;
  bTrace   : Boolean;
  CmdRes   : TAxCommandResult;
begin
  Handled := True;
  Response.ContentType := 'application/json; charset=utf-8';

  { ---- Only accept POST ---- }
//  if not SameText(Request.Method, 'POST') then
//  begin
//    Response.StatusCode := 405;
//    Response.Content    := BuildJSON('fail', 'Method not allowed. Use POST.');
//    Exit;
//  end;

     if not SameText(Request.Method, 'POST') then
    begin
      Response.StatusCode := 405;
      Response.Content :=
        '{' +
        '"result":"Fail",' +
        '"command":"",' +
        '"message":"Method not allowed. Use POST."' +
        '}';
      Exit;
    end;

  AProject := '';
  ACommand := '';
  ATrace   := 'false';
  JSONVal  := nil;
  JSONBody := nil;

try
  { ---- Parse JSON body ---- }
  if Trim(Request.Content) <> '' then
  begin
    JSONVal := TJSONObject.ParseJSONValue(Request.Content);

    if Assigned(JSONVal) and (JSONVal is TJSONObject) then
    begin
      JSONBody := TJSONObject(JSONVal);

      AProject := GetJSONString(JSONBody, 'project');
      ACommand := GetJSONString(JSONBody, 'command');
      ATrace   := GetJSONString(JSONBody, 'trace');
    end;
  end;

//  if not Assigned(JSONBody) then
//  begin
//    Response.StatusCode := 400;
//    Response.Content := BuildJSON('fail',
//      'JSONBody is nil. Content=' + Request.Content);
//    Exit;
//  end;

   if not Assigned(JSONBody) then
    begin
      Response.StatusCode := 400;
      Response.Content :=
        '{' +
        '"result":"Fail",' +
        '"command":"' + SafeJSONStr(ACommand) + '",' +
        '"message":"' +
          SafeJSONStr('JSONBody is nil. Content=' + Request.Content) + '"' +
        '}';
      Exit;
    end;


    { ---- Validate ---- }
//    if Trim(AProject) = '' then
//    begin
//      Response.StatusCode := 400;
//      Response.Content    := BuildJSON('fail', 'Missing required field: project');
//      Exit;
//    end;
//
//    if Trim(ACommand) = '' then
//    begin
//      Response.StatusCode := 400;
//      Response.Content    := BuildJSON('fail', 'Missing required field: command');
//      Exit;
//    end;

    { ---- Execute ---- }
//    bTrace := SameText(Trim(ATrace), 'true') or
//              SameText(Trim(ATrace), '1')    or
//              SameText(Trim(ATrace), 'yes');

    //CmdRes := GAxInstallerObj.ProcessCommand(AProject, ACommand, bTrace);
//
//    CmdRes := GAxInstallerObj.ProcessCommand(JSONBody);
//
//    { ---- Respond ---- }
//    Response.StatusCode := 200;
//    if CmdRes.Success then
//      Response.Content := BuildJSON('success', CmdRes.Msg)
//    else
//      Response.Content := BuildJSON('fail', CmdRes.Msg);

    CmdRes := GAxInstallerObj.ProcessCommand(JSONBody);

    { ---- Respond JSON directly ---- }
    Response.StatusCode := 200;
    //Response.ContentType := 'application/json';
    Response.Content := CmdRes.Msg;

//  except
//    on E: Exception do
//    begin
//      Response.StatusCode := 500;
//      Response.Content    := BuildJSON('fail',
//        'Server error: ' + E.ClassName + ' - ' + E.Message);
//    end;
//  end;
    except
    on E: Exception do
    begin
      Response.StatusCode := 500;
      Response.Content :=
        '{' +
        '"result":"Fail",' +
        '"command":"' + SafeJSONStr(ACommand) + '",' +
        '"message":"' +
          SafeJSONStr('Server error: ' + E.ClassName + ' - ' + E.Message) + '"' +
        '}';
      end;
    end;

  { ---- Free JSON object ---- }
  if Assigned(JSONVal) then
    FreeAndNil(JSONVal);
end;

end.
