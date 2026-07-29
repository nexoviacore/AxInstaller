unit uAxLog;

interface

uses
  SysUtils, Classes;

var
  bWriteEveryLogsToFile: Boolean = False;
  sAxlogFilename: string;
  LogStringList: TStringList = nil;
  MaxLength: Integer = 0;

procedure InitLogObj;
procedure UpdateLogObj;
procedure DestroyLogObj;
procedure WriteLog(const logmsg: String);
procedure WriteLogtoFile(const logmsg: string);
procedure WriteLogtoStrList(const logmsg: string);

implementation

uses uUtils;

procedure InitLogObj;
begin
  if Assigned(LogStringList) then
    LogStringList.Free;
  LogStringList := nil;
  EnableDebug:=False;
  LogStringList := TStringList.Create;
  if sAxlogFilename = '' then
    sAxlogFilename := 'AxInstaller_' + FormatDateTime('yyyy_mm_dd_hh_nn_ss', Now) + '.log';
  sAxlogFilename:={getcurrentdir()} AppDir +'\AxInstallerLogs\'+sAxlogFilename;
//  if not DirectoryExists(getcurrentdir()+'\AxInstallerLogs\') then
//  begin
    forceDirectories({getcurrentdir()} AppDir +'\AxInstallerLogs\');
//  end;
  bWriteEveryLogsToFile:=True;
end;

procedure UpdateLogObj;
begin
  if bWriteEveryLogsToFile=True then
  begin
    WriteLogtoFile(LogStringList.Text);
    LogStringList.Clear;
  end;
end;

procedure DestroyLogObj;
begin
  if Assigned(LogStringList) then
  begin
    LogStringList.Free;
    LogStringList := nil;
  end;
end;

procedure WriteLog(const logmsg: String);
begin
  if not EnableDebug then
  begin
    exit;
  end;
    if bWriteEveryLogsToFile then
      WriteLogtoFile(logmsg)
    else
      WriteLogtoStrList(logmsg);

end;

procedure WriteLogtoFile(const logmsg: string);
var
  LogFile: TextFile;
  IOResultCode: Integer;
begin


  AssignFile(LogFile, sAxlogFilename);
  {$I-} // Switch IO checking off
  if FileExists(sAxlogFilename) then
    Append(LogFile)
  else
    Rewrite(LogFile);
  IOResultCode := IOResult;
  {$I+} // Switch IO checking back on
//  if IOResultCode <> 0 then
//    raise Exception.Create('Failed to open log file: ' + SysErrorMessage(IOResultCode));

  try
    {$I-} // Switch IO checking off
    WriteLn(LogFile, logmsg);
    IOResultCode := IOResult;
    {$I+} // Switch IO checking back on
//    if IOResultCode <> 0 then
//      raise Exception.Create('Failed to write to log file: ' + SysErrorMessage(IOResultCode));
  finally
    CloseFile(LogFile);
  end;
end;

procedure WriteLogtoStrList(const logmsg: string);
begin
  LogStringList.Add(logmsg);
  if (MaxLength > 0) and (LogStringList.Count >= MaxLength) then
  begin
    UpdateLogObj;
  end;
end;

initialization
//  InitLogObj;

finalization
//  try
//    if not bWriteEveryLogsToFile then
//      UpdateLogObj;
//  except
//    on E: Exception do
//      // Handle exception if needed
//  end;
//  DestroyLogObj;

end.

