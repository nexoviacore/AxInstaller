unit uAxInstallerServerMethods;

{
  uAxInstallerServerMethods.pas
  -----------------------------
  DataSnap server-methods class for AxInstallerRest.

  Exposes one published method:
      function ProcessCommand(const AProject, ACommand, ATrace: string): string;

  The method accepts JSON-encoded input, delegates to TAxInstallerObj
  (in uAxInstallerRestObj), and returns a JSON-encoded response.

  JSON contract
  -------------
  Request  (POST body, parsed by DataSnap framework):
    {
      "project": "projectname",
      "command": "install 11.3 release10",
      "trace":   "true"
    }

  //Response (DataSnap wraps the function return value automatically):
    {
      "result": "success",
      "msg":    "Installed / Upgraded / Failed message"
    }

  //Compatibility: Delphi XE3, XE8, 10.1 Berlin
//}

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  {Datasnap.DSProviderDataModuleAdapter,}
  Data.DBXJSON,
  uAxInstallerRestObj;

type
  TAxInstallerServerMethods = class(TDSServerModule)
  public
    { Single REST endpoint.
      DataSnap maps:  POST /datasnap/rest/TAxInstallerServerMethods/ProcessCommand
      The three string parameters are extracted from the JSON body by the
      DataSnap REST bridge and passed as positional arguments. }
    function ProcessCommand(const AProject : string;
                            const ACommand : string;
                            const ATrace   : string): string;
  end;

implementation

//uses
//  //System.JSON;    // TJSONObject / TJSONString – available from XE3 onward
//  Data.DBXJSON;

{$R *.dfm}

{ ------------------------------------------------------------------ }
{ Helper: build a JSON response string                                }
{ ------------------------------------------------------------------ }
function BuildResponse(const AResult, AMsg: string): string;
var
  Obj : TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('result', AResult);
    Obj.AddPair('msg',    AMsg);
    Result := Obj.ToString;
  finally
    Obj.Free;
  end;
end;

{ ------------------------------------------------------------------ }
{ TAxInstallerServerMethods.ProcessCommand                            }
{ ------------------------------------------------------------------ }
function TAxInstallerServerMethods.ProcessCommand(const AProject : string;
                                                  const ACommand : string;
                                                  const ATrace   : string): string;
var
  bTrace : Boolean;
  Res    : TAxCommandResult;
begin
  try
    { Parse trace flag (accept "true" / "1" / "yes" case-insensitively) }
    bTrace := SameText(Trim(ATrace), 'true') or
              SameText(Trim(ATrace), '1')    or
              SameText(Trim(ATrace), 'yes');

    { Validate mandatory fields }
    if Trim(AProject) = '' then
    begin
      Result := BuildResponse('fail', 'Missing required field: project');
      Exit;
    end;

    if Trim(ACommand) = '' then
    begin
      Result := BuildResponse('fail', 'Missing required field: command');
      Exit;
    end;

    { Delegate to the shared business object }
    if not Assigned(GAxInstallerObj) then
    begin
      Result := BuildResponse('fail', 'Server not initialised. GAxInstallerObj is nil.');
      Exit;
    end;

    Res := GAxInstallerObj.ProcessCommand(AProject, ACommand, bTrace);

    if Res.Success then
      Result := BuildResponse('success', Res.Msg)
    else
      Result := BuildResponse('fail', Res.Msg);

  except
    on E: Exception do
      Result := BuildResponse('fail',
        'Unhandled server error: ' + E.ClassName + ' – ' + E.Message);
  end;
end;

end.
