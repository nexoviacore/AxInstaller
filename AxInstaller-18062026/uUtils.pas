unit uUtils;

interface

uses
  uDBManager, uAxProvider, uGeneralFunctions, uStructDef, System.SysUtils,
  System.IOUtils, windows, System.Classes, System.Generics.Collections, uXDS,
  XMLDoc, XMLIntf, uDBConnect, uGitManager, System.RegularExpressions;

var
  userresp: string;
  gitm: TGitManager;
  projectname, tempDBConnectionName, MultiProjConnNames: string;
  scriptpath, AppDir: string;
  Access_Token: string;
  Owner: string;
  reponame: string;
  connectionstatus, bConnectTempDB, bDBConDuring_Install: boolean;
  patchOrPlugin: string;
  slUserInstructions: TStringlist;
  gitpluginurl, GitPatchURL: string;
  PluginArray, VersionArray, projectarray: Array of String;
  gitusername, gitpassword, webcodepath, rmqclientpath, pluginpath: string;
  patchversion, activeconnection: string;
  runwebcodepath, devwebcodepath, runscriptpath, devscriptpath,
    runarmscriptpath, armservicepath, armscriptpath: string;
  agileconnectpath, armapipath, apparchitecture, databasetype, cSchema, iispluginapppath: string;
  PatchArray: TArray<string>;
  currentarmpatch, currentwebpatch, currentdevpatch: string;
  client_id, client_secret: string;
  isProceedNext: boolean;
  selectedPlugin, selectedversion, selectedpatch, selectedSchema: string;
  pluginLocalPath, patchLocalPath, patchtobeinstall, currentpatchname,
    currentversionname: string;
  curdir, logCreation, adminpwd: string;
  continuousinstallation: boolean;
  dbm: TDBManager;
  dbc: TDbConnect;
  axprovider: TAxProvider;
  gf: TGeneralFunctions;
  StuctDef: TStructDef;
  command, insallstatus: string;
  AxStructures: TList<string>;
  cmdArray: array [0 .. 3] of string = (
    'AxInstaller/help',
    'AxInstaller/list',
    'AxInstaller/listpatch <version>',
    'AxInstaller/config'
  );
  patchescmdArray: array [0 .. 2] of string = (
    'AxPatches/help',
    'AxPatches/list',
    'Axpatches/config'
  );
  EnableDebug: boolean;{ = False;}
  PageNotFoundError: boolean = False;
  EnableBackup: boolean = True;
  bPullStructures  : Boolean;
  ProceedDowngrade : Boolean = False;
  IsConfigReload: Boolean;
  SkipFileList: TStringList;
  Installer_ErrList: TStringList;
  HasDefSchema: Boolean;

const
  // plugin structure
  cPlugins = 'AxpertPlugins';
  cPatches = 'AxpertPatches';
  cReleases = 'AxpertReleases';
  cPat = 'Patches';
  // cPatches = 'AxpertPatches';
  cWebFiles = 'HTML';
  cRMQClients = 'ARM Services';
  cAxExport = 'Export';
  cAxpertStructures = 'Structures';
  cDBScripts = 'Scripts';
  cRMQ = 'ARM Services';
  cKey = 'abcdefgh';
  cPluginScript = 'PluginScripts';
  cPluginAPI = 'AxPlugins';
  cCustomPages = 'CustomPages';

procedure Console_Write(const sMessage: string = ''; iColor: Integer = 15);
procedure Console_Writeln(const sMessage: string = ''; iColor: Integer = 15);
procedure ReadErrorList(const Msg: string);
procedure WriteErrorList(const BasePath: string);

function resetValue(): string;
// function DecodeDBID(dtid, encDBID: String): String;
// function EncodeDBID(dtid, dbid: String): String;
// Function EncryptPwd(pwd: string): String;
// function DecryptPwd(encryptedPwd: String): String;
// function GetTimeId(): string;
function AESDecrypt(const EncryptedText, Key: AnsiString): AnsiString;
function AESEncrypt(const InputText, Key: AnsiString): AnsiString;
function IsConnExistsInAxApps(pConnectionName: string): boolean;
function IsVersionExists(pVersionName: string): string;
function IsPatchExists(pPatchName: string): string;
function IsPluginExists(pPluginName: string): string;
function instBeforeReadCommand(): string;
function ExtractRootDirFromURL(const URL: string): string;
function ExtractStringInsideQuotes(const Input: string): string;
function GetLast80CharsWithEllipsis(const S: string): string;
function GetLastNCharsWithEllipsis(const S: string;  MaxLength : Integer = 80): string;
function IsFileInSkipList(const AFileName: string): Boolean;

implementation

// uses
// Windows;

const

  // colour code for console text
  Black = 0;
  Blue = 1;
  Green = 2;
  Cyan = 3;
  Red = 4;
  Magenta = 5;
  Brown = 6;
  LightGray = 7;
  DarkGray = 8;
  LightBlue = 9;
  LightGreen = 10;
  LightCyan = 11;
  LightRed = 12;
  LightMagenta = 13;
  Yellow = 14;
  White = 15;

procedure Console_Writeln(const sMessage: string = ''; iColor: Integer = 15);
var
  hConsoleOutput: THandle;
  dwWritten: DWORD;
begin
  hConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleTextAttribute(hConsoleOutput, iColor);
  WriteLn('  ' + sMessage);
  SetConsoleTextAttribute(hConsoleOutput, White);
  // Reset color to default (white)
end;

procedure Console_Write(const sMessage: string = ''; iColor: Integer = 15);
var
  hConsoleOutput: THandle;
  dwWritten: DWORD;
begin
  hConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleTextAttribute(hConsoleOutput, iColor);
  Write(sMessage);
  SetConsoleTextAttribute(hConsoleOutput, White);
  // Reset color to default (white)
end;

procedure ReadErrorList(const Msg: string);
begin
  if Installer_ErrList = nil then
    Installer_ErrList := TStringList.Create;

  Installer_ErrList.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + Msg);
end;

procedure WriteErrorList(const BasePath: string);
var
  LogDir, FileName: string;
begin
  if (Installer_ErrList = nil) or (Installer_ErrList.Count = 0) then
    Exit;

  LogDir := IncludeTrailingPathDelimiter(BasePath) + 'AxInstallerErrorLog';
  ForceDirectories(LogDir);

  FileName := LogDir + '\InstallationError_' +
              FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt';

  Installer_ErrList.SaveToFile(FileName);
  Installer_ErrList.clear;
end;

function resetValue(): string;
begin
  isProceedNext := False;
  projectname := '';
  scriptpath := '';
  webcodepath := '';
  gitpassword := '';
  gitusername := '';
end;

// function GetTimeId(): string;
// var
// dtime, s, s1: string;
// i: Integer;
// begin
// dtime := '01020345060708';
// i := strtoint(copy(dtime, 1, 2));
// s := inttostr(i + 31);
// s := s + inttostr(strtoint(copy(dtime, 3, 2)) + i + 13);
// s := s + inttostr(strtoint(copy(dtime, 5, 4)) * i);
// s := s + copy(dtime, 9, 2) + copy(dtime, 11, 2) + copy(dtime, 13, 2);
// i := length(s);
// s1 := format('%.4d', [i]);
// result := s + s1;
// end;
//
// function EncodeDBID(dtid, dbid: String): String;
// var
// l, l1, i: Integer;
// s, s1: String;
// begin
// result := '';
// l := length(dbid);
// l1 := length(dtid);
// if l1 < l then
// begin
// for i := l1 to l do
// dtid := dtid + '0';
// end;
// for i := 1 to l do
// begin
// s := s + Chr(ord(dtid[i]) + ord(dbid[i]));
// end;
// l := length(s);
// for i := 1 to l do
// begin
// s1 := s1 + format('%.4d', [ord(s[i])]);
// end;
// i := length(dbid);
// s := format('%.4d', [i]);
// result := s + s1;
// end;
//
//
//
// function DecodeDBID(dtid, encDBID: String): String;
// var
// l, i: Integer;
// s, s1: String;
// begin
// result := '';
// l := length(dtid);
// s := '';
// for i := 1 to length(encDBID) div 4 do
// begin
// s1 := copy(encDBID, (i - 1) * 4 + 1, 4);
// s := s + Chr(strtoint(s1));
// end;
// result := '';
// for i := 1 to length(s) do
// begin
// result := result + Chr(ord(s[i]) - ord(dtid[i]));
// end;
// end;
//
// Function EncryptPwd(pwd: string): String;
// var
// sfile, insid, dtid, s, dbn, dbuser: string;
// i: Integer;
// begin
// result := '';
// insid := pwd;
// dtid := GetTimeId();
// i := length(dtid);
// s := dtid;
// delete(s, i - 3, i);
// insid := EncodeDBID(s, insid);
// insid := insid + dtid;
// result := insid;
// end;
//
// function DecryptPwd(encryptedPwd: String): String;
// var
// dtid, dbid: String;
// dbidLength, i: Integer;
// begin
// result := '';
// dtid := copy(encryptedPwd, length(encryptedPwd) - 6, 12);
// dbidLength := strtoint(copy(encryptedPwd, length(encryptedPwd) - 12, 4));
// dbid := copy(encryptedPwd, length(encryptedPwd) - 12 - dbidLength * 4,
// dbidLength * 4);
// result := DecodeDBID(copy(dtid, 1, length(dtid) - 4), dbid);
// end;
//

function instBeforeReadCommand(): string;
var
  command: string;
begin
  WriteLn;
  write('AxInstaller> ');
  readln(command);
  Result := command;
end;

// to check Plugin exist or not
function IsPluginExists(pPluginName: string): string;
var
  I: Integer;
begin
  try
    if not assigned(gitm) then
      gitm := TGitManager.Create;
    if length(PluginArray) = 0 then
    begin
      gitm.initplugin();
    end;
    // Result:=False;
    for I := Low(PluginArray) to High(PluginArray) do
    begin
      if lowercase(pPluginName) = lowercase(PluginArray[I]) then
      begin
        Result := PluginArray[I];
        break;
      end;
    end;
  finally
    Freeandnil(gitm);
  end;
end;

// to check Patch exist or not
function IsPatchExists(pPatchName: string): string;
var
  I: Integer;
begin
  try
    if not assigned(gitm) then
      gitm := TGitManager.Create;
    if length(PatchArray) = 0 then
    begin
      gitm.createpatcharray();
    end;
    // Result:=False;
    for I := Low(PatchArray) to High(PatchArray) do
    begin
      if lowercase(pPatchName) = lowercase(PatchArray[I]) then
      begin
        Result := PatchArray[I];
        break;
      end;
    end;
  finally
    Freeandnil(gitm);
  end;
end;

// to check version exist or not
function IsVersionExists(pVersionName: string): string;
var
  I: Integer;
begin
  try
    if not assigned(gitm) then
      gitm := TGitManager.Create;
    if length(VersionArray) = 0 then
    begin
      gitm.initversion();
    end;
    // Result:=False;
    for I := Low(VersionArray) to High(VersionArray) do
    begin
      if lowercase(pVersionName) = lowercase(VersionArray[I]) then
      begin
        Result := VersionArray[I];
        break;
      end;
    end;
  finally
    Freeandnil(gitm);
  end;
end;

function IsFileInSkipList(const AFileName: string): Boolean;
begin
  Result := False;

  if not Assigned(SkipFileList) then
    Exit;

  Result := SkipFileList.IndexOf(LowerCase(ExtractFileName(AFileName))) <> -1;
end;

function AESEncrypt(const InputText, Key: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := InputText;
  for I := 1 to length(Result) do
    Result[I] := AnsiChar(Ord(Result[I]) xor Ord(Key[I mod length(Key) + 1]));
end;

function AESDecrypt(const EncryptedText, Key: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := EncryptedText;
  for I := 1 to length(Result) do
    Result[I] := AnsiChar(Ord(Result[I]) xor Ord(Key[I mod length(Key) + 1]));
end;

// IsConnExistsInAxApps
function IsConnExistsInAxApps(pConnectionName: string): boolean;
var
  XMLDoc1: IXMLDocument;
  appNode: IXMLNode;
begin
  Result := False;
  if FileExists(AppDir + 'axapps.xml') then
  begin
    with TStringlist.Create do
    begin
      LoadFromFile(AppDir + 'axapps.xml');
      XMLDoc1 := LoadXMLData(text);
      destroy;
    end;
    appNode := XMLDoc1.DocumentElement.ChildNodes.FindNode(pConnectionName);
    if assigned(appNode) then
      Result := True;
  end;
end;

(*
  function ExtractRootDirFromURL(const URL: string): string;
  var
  LastSlashPos, EndPos: Integer;
  begin
  // Find the position of the last '/' in the URL
  LastSlashPos := LastDelimiter('/', URL);

  if LastSlashPos > 0 then
  begin
  // Extract the part of the URL after the last '/'
  EndPos := LastDelimiter('/', URL + '/'); // Add trailing '/' to handle cases where URL already ends with '/'
  Result := Copy(URL, LastSlashPos + 1, EndPos - LastSlashPos - 1);
  end
  else
  Result := ''; // Return empty if no '/' is found
  end;
*)

function ExtractRootDirFromURL(const URL: string): string;
var
  TempURL: string;
  LastSlashPos: Integer;
begin
  // Remove any trailing slash if it exists
  TempURL := URL;
  if TempURL.EndsWith('/') then
    Delete(TempURL, length(TempURL), 1);

  // Find the position of the last '/' in the modified URL
  LastSlashPos := LastDelimiter('/', TempURL);

  //21-11-2024 | Extract repo as per new git structure
  //Delete contents dir from URL and Extract Repo name
  if LastSlashPos > 0 then
    Delete(TempURL, LastSlashPos + 1, length(TempURL) - LastSlashPos);

  //Extract Repo
  if TempURL.EndsWith('/') then
    Delete(TempURL, length(TempURL), 1);

  // Find the position of the last '/' in the modified URL
  LastSlashPos := LastDelimiter('/', TempURL);

  // Extract the part of the URL after the last '/'
  if LastSlashPos > 0 then
    Result := Copy(TempURL, LastSlashPos + 1, length(TempURL) - LastSlashPos)
  else
    Result := ''; // Return empty if no '/' is found
end;


function ExtractStringInsideQuotes(const Input: string): string;
var
  Match: TMatch;
begin
  // Regular expression to match text inside double quotes
  Match := TRegEx.Match(Input, '^"([^"]*)"$');
  if Match.Success then
    Result := Match.Groups[1].Value // Group[1] contains the content inside quotes
  else
    Result := ''; // Return an empty string if no match is found
end;


// GetLast80CharsWithEllipsis
function GetLast80CharsWithEllipsis(const S: string): string;
const
  MaxLength = 90;
begin
  if Length(S) > MaxLength then
    Result := '...' + Copy(S, Length(S) - MaxLength + 1, MaxLength)
  else
    Result := S;
end;

// GetLast80CharsWithEllipsis
function GetLastNCharsWithEllipsis(const S: string;  MaxLength : Integer = 80): string;
begin
  if Length(S) > MaxLength then
    Result := '...' + Copy(S, Length(S) - MaxLength + 1, MaxLength)
  else
    Result := S;
end;


end.
