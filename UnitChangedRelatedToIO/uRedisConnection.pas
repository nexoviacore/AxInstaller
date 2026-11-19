
unit uRedisConnection;

interface

uses
  System.SysUtils,
  Data.DBXJSON,
  Redis.Client,
  Redis.Commons,
  uAxLog;

type
  TRedisConnection = class
  private
    FRedisClient: IRedisClient;

  public
    function ConnectToRedis(
      ProjectRedisDetails: TJSONObject
    ): Boolean;

    function GetRedisCredentials(
      ARMSessionIdFromRedis: string;
      ProjectRedisDetails: TJSONObject;
      out ARMSessionId: string;
      out Token: string
    ): Boolean;

    function GetRedisDetailsFromAppSettingsIni(
      InputAppSettingsIniPath: string;
      InputProjectName: string;
      out ProjectRedisDetails: TJSONObject
    ): Boolean;

    destructor Destroy; override;
  end;

implementation

uses
  Classes;

destructor TRedisConnection.Destroy;
begin
  if FRedisClient <> nil then
  begin
    try
      FRedisClient.Disconnect;
    except
      on E: Exception do
        WriteLog('Redis disconnect error: ' + E.Message);
    end;

    FRedisClient := nil;
  end;

  inherited Destroy;
end;

function TRedisConnection.ConnectToRedis(
  ProjectRedisDetails: TJSONObject
): Boolean;
var
  RedisHost: string;
  RedisPort: Integer;
  RedisPassword: string;
  Pair: TJSONPair;
begin
  Result := False;

  try
    WriteLog('Starting Redis connection.');

    if ProjectRedisDetails = nil then
      raise Exception.Create('ProjectRedisDetails is nil.');

    Pair := ProjectRedisDetails.Get('host');
    if Pair = nil then
      raise Exception.Create('Redis host is missing.');

    RedisHost := Trim(Pair.JsonValue.Value);

    Pair := ProjectRedisDetails.Get('port');
    if Pair = nil then
      raise Exception.Create('Redis port is missing.');

    RedisPort := StrToInt(Trim(Pair.JsonValue.Value));

    if (RedisPort < 1) or (RedisPort > 65535) then
      raise Exception.Create('Invalid Redis port: ' + IntToStr(RedisPort));

    Pair := ProjectRedisDetails.Get('pwd');
    if Pair = nil then
      raise Exception.Create('Redis password property is missing.');

    RedisPassword := Pair.JsonValue.Value;

    WriteLog('Redis host: ' + RedisHost);
    WriteLog('Redis port: ' + IntToStr(RedisPort));

    FRedisClient := NewRedisClient(
      RedisHost,
      Word(RedisPort),
      False,
      REDIS_NETLIB_INDY
    );

    WriteLog('Redis connection established.');

    if RedisPassword <> '' then
    begin
      WriteLog('Authenticating Redis connection.');
      FRedisClient.AUTH(RedisPassword);
      WriteLog('Redis authentication successful.');
    end;

    Result := True;

  except
    on E: Exception do
    begin
      WriteLog('Redis connection failed: ' + E.Message);
      raise;
    end;
  end;
end;

function TRedisConnection.GetRedisCredentials(
  ARMSessionIdFromRedis: string;
  ProjectRedisDetails: TJSONObject;
  out ARMSessionId: string;
  out Token: string
): Boolean;
var
  GlobalVarsJson: string;
  GlobalVarsObj: TJSONObject;
  Pair: TJSONPair;
begin

  Result := False;

  ARMSessionId := '';
  Token := '';

  GlobalVarsJson := '';
  GlobalVarsObj := nil;

  try
    try
      WriteLog(
        'ARMSessionId found in payload. Retrieving credentials from Redis.'
      );

      if not ConnectToRedis(ProjectRedisDetails) then
        raise Exception.Create('Redis connection could not be established.');

      WriteLog(
        'Retrieving GLOBALVARS for Redis key: ' + ARMSessionIdFromRedis
      );

      if not FRedisClient.HGET(
        ARMSessionIdFromRedis,
        'GLOBALVARS',
        GlobalVarsJson
      ) then
      begin
        WriteLog('GLOBALVARS not found in Redis for the given session key.');
        Exit;
      end;

      if Trim(GlobalVarsJson) = '' then
      begin
        WriteLog('GLOBALVARS value is empty in Redis.');
        Exit;
      end;

      WriteLog('GLOBALVARS retrieved successfully from Redis.');

      GlobalVarsObj :=
        TJSONObject.ParseJSONValue(GlobalVarsJson) as TJSONObject;

      if GlobalVarsObj = nil then
        raise Exception.Create('Unable to parse GLOBALVARS JSON.');

      Pair := GlobalVarsObj.Get('ARM_SessionId');
      if Pair <> nil then
        ARMSessionId := Pair.JsonValue.Value;

      Pair := GlobalVarsObj.Get('ARM_Token');
      if Pair <> nil then
        Token := Pair.JsonValue.Value;

      if (Trim(ARMSessionId) = '') or (Trim(Token) = '') then
      begin
        WriteLog('ARM_SessionId or ARM_Token is missing in GLOBALVARS.');
        ARMSessionId := '';
        Token := '';
        Exit;
      end;

      WriteLog('ARM_SessionId and ARM_Token retrieved successfully.');
      Result := True;

    except
      on E: Exception do
      begin
        WriteLog(
          'Error while retrieving Redis credentials: ' + E.Message
        );

        ARMSessionId := '';
        Token := '';

        raise Exception.Create(
          'Redis credential retrieval failed. ' + E.Message
        );
      end;
    end;

  finally
    if GlobalVarsObj <> nil then
      GlobalVarsObj.Free;

    if FRedisClient <> nil then
    begin
      try
        WriteLog('Disconnecting Redis connection.');
        FRedisClient.Disconnect;
        WriteLog('Redis connection disconnected.');
      except
        on E: Exception do
          WriteLog('Redis disconnect error: ' + E.Message);
      end;

      FRedisClient := nil;
    end;
  end;
end;



function TRedisConnection.GetRedisDetailsFromAppSettingsIni(
  InputAppSettingsIniPath: string;
  InputProjectName: string;
  out ProjectRedisDetails: TJSONObject
): Boolean;
var
  AppSettingsFile: string;
  FileContent: TStringList;
  RootObj: TJSONObject;
  AppSettingsObj: TJSONObject;
  ProjectObj: TJSONObject;
  RedisObj: TJSONObject;
  Pair: TJSONPair;
begin
  Result := False;
  ProjectRedisDetails := nil;
  FileContent := nil;
  RootObj := nil;

  try
    try
      WriteLog('Retrieving Redis details from AppSettings.ini.');

      if Trim(InputAppSettingsIniPath) = '' then
        raise Exception.Create('AppSettings.ini path is empty.');

      if Trim(InputProjectName) = '' then
        raise Exception.Create('Project name is empty.');

      if SameText(ExtractFileName(InputAppSettingsIniPath),
        'AppSettings.ini') then
        AppSettingsFile := InputAppSettingsIniPath
      else
        AppSettingsFile :=
          IncludeTrailingPathDelimiter(InputAppSettingsIniPath) +
          'AppSettings.ini';

      WriteLog('AppSettings.ini path: ' + AppSettingsFile);

      if not FileExists(AppSettingsFile) then
        raise Exception.Create(
          'AppSettings.ini not found: ' + AppSettingsFile
        );

      FileContent := TStringList.Create;
      FileContent.LoadFromFile(AppSettingsFile);

      WriteLog('AppSettings.ini loaded successfully.');

      RootObj :=
        TJSONObject.ParseJSONValue(FileContent.Text) as TJSONObject;

      if RootObj = nil then
        raise Exception.Create('Invalid JSON in AppSettings.ini.');

      Pair := RootObj.Get('appsettings');

      if (Pair = nil) or not (Pair.JsonValue is TJSONObject) then
        raise Exception.Create('appsettings section not found.');

      AppSettingsObj := Pair.JsonValue as TJSONObject;

      Pair := AppSettingsObj.Get(InputProjectName);

      if (Pair = nil) or not (Pair.JsonValue is TJSONObject) then
        raise Exception.Create(
          'Project configuration not found: ' + InputProjectName
        );

      ProjectObj := Pair.JsonValue as TJSONObject;

      Pair := ProjectObj.Get('Redis');

      if (Pair = nil) or not (Pair.JsonValue is TJSONObject) then
        raise Exception.Create(
          'Redis configuration not found for project: ' +
          InputProjectName
        );

      RedisObj := Pair.JsonValue as TJSONObject;

      ProjectRedisDetails :=
        TJSONObject.ParseJSONValue(RedisObj.ToString) as TJSONObject;

      if ProjectRedisDetails = nil then
        raise Exception.Create('Unable to extract Redis configuration.');

      WriteLog(
        'Redis details retrieved successfully for project: ' +
        InputProjectName
      );

      Result := True;

    except
      on E: Exception do
      begin
        WriteLog(
          'Error retrieving Redis details from AppSettings.ini: ' +
          E.Message
        );

        FreeAndNil(ProjectRedisDetails);

        raise Exception.Create(
          'GetRedisDetailsFromAppSettingsIni failed: ' + E.Message
        );
      end;
    end;
  finally
    RootObj.Free;
    FileContent.Free;
  end;
end;


end.

