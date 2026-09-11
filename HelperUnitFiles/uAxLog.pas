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

// Newly added version logging functions
function GetCurrentModuleFileName: string;
function GetFileVersionProperty(const AFileName, APropertyName: string): string;
procedure LogFileVersionInfo(const AFileName: string);

implementation

uses
  Windows, uUtils;

procedure InitLogObj;
begin
  if Assigned(LogStringList) then
    LogStringList.Free;
  LogStringList := nil;
  EnableDebug := False;
  LogStringList := TStringList.Create;
  if LogFileName = '' then
    LogFileName := 'AxInstaller_' + FormatDateTime('yyyy_mm_dd_hh_nn_ss',
      Now) + '.log';
  // sAxlogFilename := 'AxInstaller_' + FormatDateTime('yyyy_mm_dd_hh_nn_ss', Now) + '.log';
  // sAxlogFilename:={getcurrentdir()} AppDir +'\AxInstallerLogs\'+sAxlogFilename;
  sAxlogFilename := { getcurrentdir() } AppDir + '\AxInstallerLogs\' +
    LogFileName;
  // if not DirectoryExists(getcurrentdir()+'\AxInstallerLogs\') then
  // begin
  forceDirectories( { getcurrentdir() } AppDir + '\AxInstallerLogs\');
  // end;
  bWriteEveryLogsToFile := True;
//{$IFDEF CONSOLE_APP}
//  LogFileVersionInfo(ParamStr(0));
//{$ELSE}
//  LogFileVersionInfo(GetCurrentModuleFileName);
//{$ENDIF}
end;

procedure UpdateLogObj;
begin
  if bWriteEveryLogsToFile = True then
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
  // if IOResultCode <> 0 then
  // raise Exception.Create('Failed to open log file: ' + SysErrorMessage(IOResultCode));

  try
{$I-} // Switch IO checking off
    WriteLn(LogFile, logmsg);
    IOResultCode := IOResult;
{$I+} // Switch IO checking back on
    // if IOResultCode <> 0 then
    // raise Exception.Create('Failed to write to log file: ' + SysErrorMessage(IOResultCode));
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


function GetCurrentModuleFileName: string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Len: DWORD;
begin
  Len := GetModuleFileName(HInstance, Buffer, MAX_PATH);
  if Len > 0 then
    SetString(Result, Buffer, Len)
  else
    Result := '';
end;

function GetFileVersionProperty(const AFileName, APropertyName: string): string;
var
  InfoSize: DWORD;
  Dummy: DWORD;
  Buffer: Pointer;
  Translation: Pointer;
  TranslationSize: UINT;
  LangID: Word;
  CodePage: Word;
  SubBlock: string;
  Value: PChar;
  ValueLen: UINT;
begin
  Result := '';

  if not FileExists(AFileName) then
    Exit;

  InfoSize := GetFileVersionInfoSize(PChar(AFileName), Dummy);
  if InfoSize = 0 then
    Exit;

  GetMem(Buffer, InfoSize);
  try
    if not GetFileVersionInfo(PChar(AFileName), 0, InfoSize, Buffer) then
      Exit;

    Translation := nil;
    TranslationSize := 0;

    if VerQueryValue(Buffer, '\VarFileInfo\Translation', Translation, TranslationSize) then
    begin
      if TranslationSize >= 4 then
      begin
        LangID := PWord(Translation)^;
        CodePage := PWord(PByte(Translation) + 2)^;

        SubBlock := Format('\StringFileInfo\%4.4x%4.4x\%s', [LangID, CodePage, APropertyName]);

        Value := nil;
        ValueLen := 0;

        if VerQueryValue(Buffer, PChar(SubBlock), Pointer(Value), ValueLen) then
        begin
          if ValueLen > 0 then
            Result := string(Value);
        end;
      end;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure LogFileVersionInfo(const AFileName: string);
begin
  WriteLog('========================================');
  WriteLog('File Information');
  WriteLog('========================================');
  WriteLog('File Name       : ' + ExtractFileName(AFileName));
  WriteLog('File Path       : ' + AFileName);

  if not FileExists(AFileName) then
  begin
    WriteLog('Status          : File not found');
    WriteLog('========================================');
    Exit;
  end;

  WriteLog('File Version    : ' + GetFileVersionProperty(AFileName, 'FileVersion'));
  WriteLog('Product Version : ' + GetFileVersionProperty(AFileName, 'ProductVersion'));
  WriteLog('File Description: ' + GetFileVersionProperty(AFileName, 'FileDescription'));
  WriteLog('Product Name    : ' + GetFileVersionProperty(AFileName, 'ProductName'));
  WriteLog('Company Name    : ' + GetFileVersionProperty(AFileName, 'CompanyName'));
  WriteLog('Original Filename: ' + GetFileVersionProperty(AFileName, 'OriginalFilename'));
  WriteLog('Internal Name   : ' + GetFileVersionProperty(AFileName, 'InternalName'));
  WriteLog('Comments        : ' + GetFileVersionProperty(AFileName, 'Comments'));
  WriteLog('Copyright       : ' + GetFileVersionProperty(AFileName, 'LegalCopyright'));
  WriteLog('Private Build   : ' + GetFileVersionProperty(AFileName, 'PrivateBuild'));
  WriteLog('Special Build   : ' + GetFileVersionProperty(AFileName, 'SpecialBuild'));
  WriteLog('========================================');
end;
initialization

// InitLogObj;

finalization

// try
// if not bWriteEveryLogsToFile then
// UpdateLogObj;
// except
// on E: Exception do
// // Handle exception if needed
// end;
// DestroyLogObj;

end.
