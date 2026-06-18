unit uGitManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  IdAuthentication, uAxLog,
  {Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME,} IdMultipartFormData,
  StrUtils,
  System.IOUtils, System.Types, System.Generics.Collections, DBXJSON,
  idUri, System.RegularExpressions, System.Generics.Defaults, System.Math;

type
  TGitManager = class
  private
    pluginstrlist: TstringList;
    patchstrlist: TstringList;
    pluginName: string;
    httpretry: Integer;

    // directorypath:String;
    // function getAuthURL(ClientID: string): string;
    // function getAuthCode():string;
    // function getAccessToken(): string;

  public
    ptArray: TArray<Integer>;
    ptcArray: TArray<Integer>;
    patarray: TArray<string>;
    function listOfPlugins(): string;
    function initConnection(): string;
    function SelectPlugin(PluginCount: Integer): String;
    function CreateFolderStructure(GURL: String; Fpath: String): string;
    function pullfromgit(): string;
    function DownloadFile(const URL, FileName: string): string;
    function pullcompressfile(FileName: string;
      var Response: TStringStream): string;
    function createPluginArray(): string;
    function createVersionArray(): string;
    function createPatchArray(): string;
    function listOfPatches(): string;
    function NaturalCompare(const Left, Right: string): Integer;
    function sortarray(Arr: TArray<string>; arrsize: Integer;
      version: string): string;
    procedure SortPatchArray(var Arr: TArray<string>);
    function extractprefix(patchname: string): string;
    function findindex(MyArray: TArray<string>; Mystring: string): Integer;
    function initversion(): String;
    function initplugin(): string;
    function listOfVersions(): string;
    function findpatchindex(patch: string): Integer;
    // function ExtractPatchNumber(const Patch: string): Integer;
    // function ComparePatchNames(List: TStringList; Index1, Index2: Integer): Integer;
    // function RemoveLastSegmentFromPath(path: string): string;
    function pullStructuresfromgit: string;

  end;

implementation

uses uUtils;

function TGitManager.initversion(): String;
// var
// git:TgitManager;
begin
  try
    // if not assigned(git) then
    // git:=TgitManager.Create;
    if length(versionarray) = 0 then
    begin
      createVersionArray();
    end;
  finally
    // freeandnil(git);
  end;
end;

function TGitManager.initplugin(): String;
// var
// gitm:TgitManager;
begin
  try
    // if not assigned(gitm) then
    // gitm:=TgitManager.Create;
    if length(pluginarray) = 0 then
    begin
      createPluginArray();
    end;
  finally
    // freeandnil(gitm);
  end;
end;

function TGitManager.createPluginArray(): string;
var
  IdHTTP1: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  JSONObject, JObject: TJSONObject;
  GitURL, JSONGet: string;
  JSONValue: TJSONValue;
  JsonArray: TJSONArray;
  Jcount, I: Integer;
  KeyName, NameValue: string;
  PluginArr: TArray<string>;
begin
  try
    writelog('createPluginArray function started..');
    IdHTTP1 := TIdHTTP.Create(nil);
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
    // SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    SSLIOHandler.SSLOptions.SSLVersions :=
      [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    // SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
    IdHTTP1.IOHandler := SSLIOHandler;
    IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
      'Bearer ' + Access_Token);
    JSONObject := TJSONObject.Create;
    JObject := TJSONObject.Create;
    // GitURL:=Format('https://api.github.com/repos/%s/%s/contents/%s/',[Owner,reponame,'AxPlugins']);
    GitURL := gitpluginurl; {GitPatchURL;}
    IdHTTP1.HandleRedirects := True;
    try
      // Decided to removed OfficialReleases , so plugin and patches will be palced
      // directly under repo\root dir   | 14/11/2024
      // writelog('Used Git URL : '+GitURL + 'OfficialReleases/Plugins');
      // JSONGet := IdHTTP1.Get(TidUri.URLEncode(GitURL + 'OfficialReleases/Plugins'));

      // writelog('Used Git URL : '+GitURL + 'Plugins');

      writelog('Used Git URL : ' + GitURL);

      // 25-11-2024 | As per new GIT structure Plugins will be published in new repos
      // and the structure also modified according to that we are modiying the code.

      // JSONGet := IdHTTP1.Get(TidUri.URLEncode(GitURL + 'Plugins'));

      JSONGet := IdHTTP1.Get(TidUri.URLEncode(GitURL));

      // TidUri.URLEncode(
      JSONValue := TJSONObject.ParseJSONValue(JSONGet);
    except
      on F: Exception do
      begin
        ReadErrorList(F.Message);
        console_write('    -  Error during HTTP request for plugin listing: ' +
          F.Message, 12);
        writeln;
        writelog('Error during HTTP request for plugin listing: ' + F.Message);
        readln;
      end;
    end;
    JsonArray := TJSONObject.ParseJSONValue(JSONGet) as TJSONArray;
    Jcount := JsonArray.size;
    SetLength(pluginarray, Jcount);
    for I := 0 to Jcount - 1 do
    begin
      KeyName := 'name';
      JObject := JsonArray.Get(I) as TJSONObject;
      NameValue := JObject.Get(KeyName).JSONValue.value;
      pluginarray[I] := NameValue;
//       Skip .gitattributes (add more files if needed)
      if lowercase(NameValue) = '.gitattributes' then
        Continue;
      // writeln(PluginArray[I]);
    end;
    writelog('Plugin array created.');
    writelog('createPluginArray function ends..');
  finally
    freeandnil(IdHTTP1);
    freeandnil(JSONObject);
    freeandnil(JObject);
  end;

end;

function TGitManager.createVersionArray(): string;
var
  IdHTTP1: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  JSONObject, JObject: TJSONObject;
  GitURL: string;
  JSONGet: string;
  JSONValue: TJSONValue;
  JsonArray: TJSONArray;
  Jcount, I, ActualCount: Integer;
  KeyName, NameValue: string;
  PluginArr: TArray<string>;
begin
  try
    writelog('createVersionArray function started..');
    IdHTTP1 := TIdHTTP.Create(nil);
    // initConnection();
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    // SSLIOHandler.SSLOptions.CipherList:='TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA';
    SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
    IdHTTP1.IOHandler := SSLIOHandler;
    IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
      'Bearer ' + Access_Token);
    JSONObject := TJSONObject.Create;
    JObject := TJSONObject.Create;
    // GitURL:=Format('https://api.github.com/repos/%s/%s/contents/%s/',[Owner,reponame,'Plugin']);

    // Decided to removed OfficialReleases , so plugin and patches will be palced
    // directly under repo\root dir   | 14/11/2024

    // GitURL := TidUri.URLEncode(GitPatchURL + 'OfficialReleases/Patches/');

    (* As discussed with sab sir, we removed patches folder,
      so diretcly under release folder we will be having version folders.
    *)
    // GitURL := TidUri.URLEncode(GitPatchURL + 'Patches/');

    GitURL := TidUri.URLEncode(GitPatchURL);

    // writeln('Invoking URL :' + GitURL);
    IdHTTP1.HandleRedirects := True;
    try
      if patchversion = '' then
      begin
        writelog('Used Git URL : ' + GitURL);
        JSONGet := IdHTTP1.Get(GitURL); // TidUri.URLEncode(

      end
      else
      begin
        GitURL := TidUri.URLEncode(GitURL + patchversion);
        writelog('Used Git URL : ' + GitURL);
      end;
      JSONGet := IdHTTP1.Get(GitURL);
      JSONValue := TJSONObject.ParseJSONValue(JSONGet);
    except
      on F: Exception do
      begin
        ReadErrorList(F.Message);
        console_write('    -  Error during HTTP request for plugin listing: ' +
          F.Message, 12);
        writeln;
        writelog('Error during HTTP request for plugin listing: ' + F.Message);
        readln;
      end;
    end;
    JsonArray := TJSONObject.ParseJSONValue(JSONGet) as TJSONArray;
    Jcount := JsonArray.size;
    SetLength(versionarray, Jcount);

    ActualCount := 0; // Track valid entries

    for I := 0 to Jcount - 1 do
    begin
      KeyName := 'name';
      JObject := JsonArray.Get(I) as TJSONObject;
      NameValue := JObject.Get(KeyName).JSONValue.value;
      // VersionArray[I] := NameValue;
      // writeln(PluginArray[I]);

      // Skip .gitattributes (add more files if needed)
      // if lowercase(NameValue) = '.gitattributes' then
      // Continue;

      // we can also check starts with 'Version ' and skip if not
      // Only include items that start with 'Version '
      if not StartsText('Version ', NameValue) then
        Continue;

      versionarray[ActualCount] := NameValue;
      Inc(ActualCount);
    end;
    // Resize array to actual size
    SetLength(versionarray, ActualCount);

    writelog('Version array created.');
    writelog('createVersionArray function ends..');
  finally
    freeandnil(IdHTTP1);
    freeandnil(JSONObject);
    freeandnil(JObject);
  end;

end;

function TGitManager.createPatchArray(): string;
var
  IdHTTP1: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  JSONObject, JObject, PJObject: TJSONObject;
  GitURL, GithubUrl: string;
  JSONGet, PJSONGet: string;
  JSONValue, PJSONValue: TJSONValue;
  JsonArray, PJsonArray: TJSONArray;
  Jcount, PJcount, I, J, Patchcount, patchloc: Integer;
  KeyName, folderName, NameValue: string;
  Arr: TArray<string>;
  ArrCount, ActualCount: Integer;
  pcount, P, L, V, Z: Integer;
  gitfolderurl: string;
  versionnumber: string;

begin
  try
    writelog('createPatchArray function started..');
    IdHTTP1 := TIdHTTP.Create(nil);
    // initConnection();
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    // SSLIOHandler.SSLOptions.CipherList:='TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA';
    SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
    IdHTTP1.IOHandler := SSLIOHandler;
    IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
      'Bearer ' + Access_Token);
    JSONObject := TJSONObject.Create;
    JObject := TJSONObject.Create;
    // GitURL:=Format('https://api.github.com/repos/%s/%s/contents/%s/',[Owner,reponame,'Plugin']);

    // Decided to removed OfficialReleases , so plugin and patches will be palced
    // directly under repo\root dir   | 14/11/2024
    // GitURL := GitPatchURL + 'OfficialReleases/Patches/';

    // (21/11/2024) | We will be using Repo\VersionsXX\releasesXX
    // So accordingly updating the URL here,

    // GitURL := GitPatchURL + 'Patches/';

    GitURL := GitPatchURL;

    // writeln('Invoking URL :' + GitURL);
    IdHTTP1.HandleRedirects := True;
    versionnumber := trim(currentversionname);
    for Z := Low(versionarray) to High(versionarray) do
    begin
      if lowercase(versionarray[Z]) = lowercase(versionnumber) then
      begin
        try
          GithubUrl := TidUri.URLEncode(GitURL + versionarray[Z] { version } );
          writelog('Used Git URL : ' + GithubUrl);
          JSONGet := IdHTTP1.Get(GithubUrl);
          JSONValue := TJSONObject.ParseJSONValue(JSONGet);
        except
          on F: Exception do
          begin
            ReadErrorList(F.Message);
            console_write
              ('    -  Error during HTTP request for plugin listing: ' +
              F.Message, 12);
            writelog(' Error during HTTP request for plugin listing: ' +
              F.Message);
            writeln;
            readln;
          end;
        end;
        JsonArray := TJSONObject.ParseJSONValue(JSONGet) as TJSONArray;
        Jcount := JsonArray.size;
        SetLength(Arr, Jcount);
        ActualCount := 0; // Track valid entries

        for I := 0 to Jcount - 1 do
        begin
          KeyName := 'name';
          JObject := JsonArray.Get(I) as TJSONObject;
          NameValue := JObject.Get(KeyName).JSONValue.value;
          // if not pos('main',lowercase(NameValue))<>0 then
          // Arr[I] := NameValue;

          // writeln(PluginArray[I]);

          // we can also check starts with 'Version ' and skip if not
          // Only include items that start with 'Version '
          if (not StartsText('Release', NameValue)) and (LowerCase(NameValue) <> 'basecode') then
            Continue;
          Arr[ActualCount] := NameValue;
          Inc(ActualCount);
        end;
        // Resize array to actual size
        SetLength(Arr, ActualCount);
        try
          sortarray(Arr, length(Arr), versionarray[Z]);
        except
          on e: Exception do
          begin
            ReadErrorList(e.Message);
            console_write('    -  Error in create release array : ' +
              e.Message, 12);
            writeln;
            writelog('Error in create release array : ' + e.Message);
          end;
        end;
      end;
      if Z + 1 < length(versionarray) then
        versionnumber := versionarray[Z + 1];
    end; // PatchArray;
    SetLength(patcharray, length(patarray));
    for I := Low(patarray) to High(patarray) do
      patcharray[I] := patarray[I];

    writelog('PatchArray created..');
    SetLength(patarray, 0);

    { JsonArray := TJSONObject.ParseJSONValue(JSONGet) as TJSONArray;
      Jcount := JsonArray.size;
      //SetLength(PatchArray, Jcount);
      for I := 0 to Jcount - 1 do
      begin
      PJObject:=TJsonObject.create;
      KeyName := 'name';
      PJObject := JsonArray.Get(I) as TJSONObject;
      folderName := PJObject.Get(KeyName).JSONValue.value;
      gitfolderurl:=TIdURI.URLEncode(GitURL+'/'+folderName);
      PJSONGet := IdHTTP1.Get(gitfolderurl);
      PJSONValue := TJSONObject.ParseJSONValue(JSONGet);
      PJsonArray := TJSONObject.ParseJSONValue(PJSONGet) as TJSONArray;
      PJcount := PJsonArray.size;
      SetLength(Arr, PJcount);
      // Patchcount :=length(PatchArray);
      //  SetLength(PatchArray, Patchcount+PJcount);
      for J := 0 to PJcount - 1 do
      begin
      KeyName := 'name';
      PJObject := PJsonArray.Get(J-Patchcount) as TJSONObject;
      NameValue := PJObject.Get(KeyName).JSONValue.value;
      //         Arr[J]:=folderName+'/'+NameValue;
      end;
      //      for J := 0 to length(Arr) - 1 do
      //      begin
      SetLength(ptcarray, 0);
      sortarray(Arr,length(Arr));
      //end;
      TArray.Sort<Integer>(ptcarray);
      //      for P :=0 to length(ptcarray)-1 do
      //      begin
      pcount:=length(ptcarray);
      if length(patcharray)=0 then
      begin
      setlength(patcharray,pcount);
      for L :=0 to pcount-1 do
      begin
      patcharray[L]:=folderName+'/'+'Patch'+inttostr(ptcarray[L]);
      end;
      writeln;
      end
      else
      begin
      setlength(patcharray,length(patcharray)+pcount);
      for L :=length(patcharray)-pcount to length(patcharray)-1 do
      begin
      patcharray[L]:=folderName+'/'+'Patch';
      end;
      for V := 0 to length(ptcarray)-1 do
      patcharray[length(patcharray)-pcount+V]:=patcharray[length(patcharray)-pcount+V]+inttostr(ptcarray[V]);
      end;
      // end;
    }

    {
      //      for J := Patchcount to PJcount+Patchcount - 1 do
      //      begin
      //         KeyName := 'name';
      //         PJObject := PJsonArray.Get(J-Patchcount) as TJSONObject;
      //         NameValue := PJObject.Get(KeyName).JSONValue.value;
      //        // patchloc:=patchcount-1;
      //         PatchArray[J] := folderName+'/'+NameValue;
      //        // patchloc:=patchloc+1;
      //      end; }
    // SortPatchArray(PatchArray);

    // writeln(PluginArray[I]);
    // end;
    // SortArray(PatchArray);
    // readln;
    // TArray.Sort<string>(PatchArray, TComparer<string>.Construct(
    // function(const Left, Right: string): Integer
    // begin
    // Result := CompareText(Left, Right);
    // end
    // ));
    // for I := 0 to length(PatchArray)-1 do
    // writeln(PatchArray[I])
    writelog('createPatchArray function ends..');
  finally
    freeandnil(IdHTTP1);
    freeandnil(JSONObject);
    freeandnil(JObject);
  end;

end;

function TGitManager.sortarray(Arr: TArray<string>; arrsize: Integer;
  version: string): string;
var
  I: Integer;
  PatArraysize: Integer;
  ptArraySize: Integer;

begin
  writelog('sortarray function started..');
  for I := 0 to arrsize - 1 do
  begin
    extractprefix(Arr[I]);
  end;
  TArray.Sort<Integer>(ptcArray);
  ptArraySize := length(ptArray);
  SetLength(ptArray, ptArraySize + length(ptcArray));
  for I := Low(ptcArray) to High(ptcArray) do
  begin
    ptArray[I + ptArraySize] := ptcArray[I];
  end;
  PatArraysize := length(patarray);
  SetLength(patarray, PatArraysize + length(ptcArray));
  for I := 0 to length(ptcArray) - 1 do
  begin
    if ptcArray[I] = 0 then
      patarray[I + PatArraysize] := version + '/' + 'BaseCode' //'main'
    else
      patarray[I + PatArraysize] := version + '/' + 'Release' +
        inttostr(ptcArray[I]);
  end;
  SetLength(ptcArray, 0);
  writelog('sortarray function ends..');
end;

function TGitManager.extractprefix(patchname: string): string;
var
  refIndex, ArrCount, patchnum: Integer;
  afterschremove, afterpatchremove, Patchstr: string;
  commandstrlist: TstringList;
begin
  // commandstrlist := TStringList.Create;
  // commandstrlist.Delimiter := ' ';
  // commandstrlist.Delimitedtext := patchname;
  // Patchstr:=commandstrlist[1];
  // freeandnil(commandstrlist);
  if lowercase (patchname)= 'basecode' then
    Patchstr := ''
  else
  begin
    Patchstr := copy(patchname, length('Release') + 1, length(patchname));
    Patchstr := trim(Patchstr);
  end;
  // /patchstr:=trim(patchstr);
  if Patchstr = '' then
    patchnum := 0
  else
    patchnum := strtoint(Patchstr);
  // patchnum:=trim(patchnum);
  // refIndex := Pos('/', patchname);
  // if refIndex > 0 then
  // afterschremove := copy(patchname, refIndex, length(patchname));
  // afterpatchremove := copy(afterschremove, 7, length(afterschremove));
  ArrCount := length(ptcArray);
  SetLength(ptcArray, ArrCount + 1);
  // arrcount:=length(ptcarray);
  if ArrCount = 0 then
    ptcArray[ArrCount] := patchnum;
  if ArrCount <> 0 then
  begin
    ptcArray[ArrCount] := patchnum;
  end;
  // Delete(patchname, refIndex, Length(AReference));

end;

function ExtractPatchNumber(const patch: string): Integer;
var
  SlashPos: Integer;
  PatchNumberStr: string;
begin
  // Find the position of the last '/'
  SlashPos := LastDelimiter('/', patch);

  // Extract the substring after the last '/'
  if SlashPos > 0 then
    PatchNumberStr := copy(patch, SlashPos + 1, length(patch) - SlashPos)
  else
    PatchNumberStr := patch; // If no '/', take the whole string as the number

  // Convert the substring to integer
  Result := StrToIntDef(PatchNumberStr, 0);
end;
{ var
  PrefixPos, SlashPos: Integer;
  PatchNumberStr: string;
  begin
  // Find the position of the prefix and the slash
  PrefixPos := Pos('/', Patch);
  if PrefixPos = 0 then
  Exit(0); // Slash not found, return 0

  // Find the position of the number part
  SlashPos := PosEx('/', Patch, PrefixPos + 1);
  if SlashPos = 0 then
  SlashPos := Length(Patch) + 1; // If no second slash, consider until end of string

  // Extract the substring between slashes
  PatchNumberStr := Copy(Patch, PrefixPos + 1, SlashPos - PrefixPos - 1);

  // Convert the substring to integer
  Result := StrToIntDef(PatchNumberStr, 0);
  end; }

{ function ComparePatchNames(List: TStringList; Index1, Index2: Integer): Integer;
  var
  Patch1, Patch2: string;
  Prefix1, Prefix2: string;
  Num1, Num2: Integer;
  SlashPos1, SlashPos2: Integer;
  begin
  // Extract full patch strings
  Patch1 := List[Index1];
  Patch2 := List[Index2];

  // Find the position of the first slash
  SlashPos1 := Pos('/', Patch1);
  SlashPos2 := Pos('/', Patch2);

  // Extract prefixes (everything before the first '/')
  if SlashPos1 > 0 then
  Prefix1 := Copy(Patch1, 1, SlashPos1 - 1)
  else
  Prefix1 := Patch1; // If no '/', take the whole string as prefix

  if SlashPos2 > 0 then
  Prefix2 := Copy(Patch2, 1, SlashPos2 - 1)
  else
  Prefix2 := Patch2; // If no '/', take the whole string as prefix

  // Compare prefixes first
  Result := CompareStr(Prefix1, Prefix2);
  if Result <> 0 then
  Exit;

  // If prefixes are the same, compare the numeric part after the '/'
  Num1 := StrToIntDef(Copy(Patch1, SlashPos1 + 1, Length(Patch1) - SlashPos1), 0);
  Num2 := StrToIntDef(Copy(Patch2, SlashPos2 + 1, Length(Patch2) - SlashPos2), 0);

  if Num1 < Num2 then
  Result := -1
  else if Num1 > Num2 then
  Result := 1
  else
  Result := 0;
  end; }

function ComparePatches(const Left, Right: string): Integer;
var
  PrefixLeft, PrefixRight: string;
  NumLeft, NumRight: Integer;
  SlashPosLeft, SlashPosRight: Integer;
begin
  // Find the position of the first slash
  SlashPosLeft := Pos('/', Left);
  SlashPosRight := Pos('/', Right);

  // Extract prefixes (everything before the first '/')
  if SlashPosLeft > 0 then
    PrefixLeft := copy(Left, 1, SlashPosLeft - 1)
  else
    PrefixLeft := Left; // If no '/', take the whole string as prefix

  if SlashPosRight > 0 then
    PrefixRight := copy(Right, 1, SlashPosRight - 1)
  else
    PrefixRight := Right; // If no '/', take the whole string as prefix

  // Compare prefixes first
  Result := CompareStr(PrefixLeft, PrefixRight);
  if Result <> 0 then
    Exit;

  // If prefixes are the same, compare the numeric part after the '/'
  NumLeft := ExtractPatchNumber(Left);
  NumRight := ExtractPatchNumber(Right);

  Result := NumLeft - NumRight;
end;

procedure TGitManager.SortPatchArray(var Arr: TArray<string>);
begin
  TArray.Sort<string>(Arr, TComparer<string>.Construct(
    function(const Left, Right: string): Integer
    begin
      Result := ComparePatches(Left, Right);
    end));
end;

{ procedure TGitManager.SortPatchArray(var Arr: TArray<string>);
  var
  PatchList: TStringList;
  i: Integer;
  begin
  PatchList := TStringList.Create;
  try
  // Add items to the list
  for i := 0 to High(Arr) do
  PatchList.Add(Arr[i]);

  // Sort with custom comparison function
  PatchList.CustomSort(ComparePatchNames);

  // Copy back to array
  SetLength(Arr, PatchList.Count);
  for i := 0 to PatchList.Count - 1 do
  Arr[i] := PatchList[i];
  finally
  PatchList.Free;
  end;
  end; }
function TGitManager.listOfVersions(): string;
var
  currentindex, I: Integer;
begin
  try
    writeln;
    writelog('listOfVersions  function started..');
    // writeln('Available Versions');
    // writeln('==================');
    write('Currently installed : ');
    console_write(currentversionname + '/' + currentpatchname, 10);
    writelog('Your current applied Version is : ' + currentversionname);
    writeln;
    writeln;
    // writeln;
    writeln('Available Version are');
    writeln('======================');
    writelog('listing available versions to install');
    for I := Low(versionarray) to High(versionarray) do
    begin
      if lowercase(currentversionname) = lowercase(versionarray[I]) then
      begin
        currentindex := I;
        break;
      end;
    end;
    if currentindex = High(versionarray) then
    begin
      console_write('Your application version is Up to date', 10);
      writeln;
      console_write('No versions ara available to install', 10);
      writeln;
      writelog('Your application version is Up to date');
      writelog('No versions ara available to install');
    end
    else
    begin
      for I := currentindex + 1 to High(versionarray) do
      begin
        writeln('  -' + versionarray[I]);
      end;
    end;
    writelog('listOfVersions  function ends..');
  finally

  end;

end;

function TGitManager.listOfPatches(): string;
var
  patchname, key: string;
  curwebpatch, curdevpatch, curarmpatch: string;
  webcount, devcount, armcount: Integer;
  webindex, devindex, armindex: Integer;
  JVALUE: TJSONValue;
  versionwisearraylength: Integer;
  I, J, patchindex: Integer;
  NameValue: string;
  patchJvalue: TJSONValue;
  webarr, devarr, armarr, versionwisearray: TArray<string>;
  KeyName: string;
  JSONGet: String;
  P, X: Integer;
  currentPatchinfo: string;
  // giving username password we will get token
begin
  try
    try
      writelog('listOfPatches  function started..');
      // writeln('Available Patches');
      // writeln('==================');
      write('Currently installed : ');
      console_write(currentversionname + '/' + currentpatchname, 10);
      writelog('Your current applied patch is : ' + currentversionname + '/' +
        currentpatchname);
      writeln;
      writeln;
      // writeln;
      writeln('Available Releases for ' + selectedversion);
      writeln('=================================');
      patchstrlist := TstringList.Create;
      // curwebpatch:='AxpertWeb/'+currentwebpatch;
      // curdevpatch:='AxpertDeveloper/'+currentdevpatch;
      // curarmpatch:='AxpertARM/'+currentarmpatch;

      for I := 0 to length(patcharray) - 1 do
      begin
        // keyName := 'name';
        // JObject := JsonArray.Get(I) as TJSONObject;
        // NameValue := JObject.Get(keyName).JSONValue.value;
        // PluginArray[I] := NameValue;
        // if pos('AxpertWeb/',PatchArray[I])<>0 then
        // begin
        // inc(length(webarr));
        // setlength(webarr,length(webarr)+1);
        // webcount:=length(webarr);
        // webarr[webcount-1]:=PatchArray[I];
        // end;
        // if pos('AxpertDeveloper/',PatchArray[I])<>0 then
        // begin
        // //inc(length(devarr));
        // setlength(devarr,length(devarr)+1);
        // devcount:=length(devarr);
        // devarr[devcount-1]:=PatchArray[I];
        // end;
        // if pos('AxpertARM/',PatchArray[I])<>0 then
        // begin
        // //inc(length(armarr));
        // setlength(armarr,length(armarr)+1);
        // armcount:=length(armarr);
        // armarr[armcount-1]:=PatchArray[I];
        // end;
        //
        //
        //
        /// /      console_write(IntToStr(I + 1) + '. ', 12);
        /// /      writeln(PatchArray[I]); // pluginarray[I]
        // // SetConsoleTextAttribute(inttostr(I+1)+'. ', 4);
        patchstrlist.Add(inttostr(I + 1) + '=' + patcharray[I]);
        // pluginarray[I]
      end;
      writelog('listing available releases to install');

      if length(versionwisearray) = 0 then
      begin
        for I := Low(patcharray) to High(patcharray) do
        begin
          if Pos(selectedversion, patcharray[I]) <> 0 then
          begin
            versionwisearraylength := length(versionwisearray);
            SetLength(versionwisearray, versionwisearraylength + 1);
            if versionwisearraylength = 0 then
              versionwisearray[0] := patcharray[I]
            else
              versionwisearray[versionwisearraylength] := patcharray[I];
          end;

        end;
      end;
      if selectedversion = currentversionname then
        patchindex := findindex(versionwisearray, currentversionname + '/' +
          currentpatchname)
      else
        patchindex := findindex(versionwisearray, selectedversion + '/'
          + 'basecode'{'main'});

      if not(lowercase(selectedversion) = lowercase(currentversionname)) then
      begin
        for I := Low(versionwisearray) to High(versionwisearray) do
        begin
          writeln('  -' + versionwisearray[I]);
        end;
      end
      else
      begin
        // if patchindex=0 then
        // begin
        // for I := patchindex  to high(versionwisearray) do
        // begin
        // writeln('  -' + versionwisearray[I]);
        // end;
        // end
        // else
        // begin
        if selectedversion = currentversionname then
          patchindex := findpatchindex(currentversionname + '/' +
            currentpatchname)
        else
          patchindex := findpatchindex(selectedversion + '/' + 'basecode'{'main'});
        if patchindex = -1 then
        begin
          for I := patchindex + 1 to high(versionwisearray) do
          begin
            writeln('  -' + versionwisearray[I]);
          end;
        end
        else
        begin
          for I := patchindex + 1 to high(versionwisearray) do
          begin
            writeln('  -' + versionwisearray[I]);
          end;
        end;
      end;
      // end;

      // devindex:= findindex(devarr,curdevpatch);
      // //   TArray.IndexOf<String>(lowercase(devarr),lowercase(curdevpatch));
      // armindex:= findindex(armarr,curarmpatch);

      // if webindex = -1 then
      // begin
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT WEB---');
      // writeln;
      // for P := Low(webarr) to High(webarr) do
      // begin
      // console_write(IntToStr(P + 1) + '. ', 12);
      // writeln(webarr[P]);
      // end;
      // end
      // else
      // begin
      // X:=1;
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT WEB---');
      // writeln;
      // for P := webindex+1 to High(webarr) do
      // begin
      // console_write(IntToStr(X) + '. ', 12);
      // writeln(webarr[P]);
      // inc(X);
      // end;
      // end;
      //
      // if devindex = -1 then
      // begin
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT DEVELOPER---');
      // writeln;
      // for P := Low(devarr) to High(devarr) do
      // begin
      // console_write(IntToStr(P + 1) + '. ', 12);
      // writeln(devarr[P]);
      // end;
      // end
      // else
      // begin
      // X:=1;
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT DEVELOPER---');
      // writeln;
      // for P := devindex+1 to High(devarr) do
      // begin
      // console_write(IntToStr(X) + '. ', 12);
      // writeln(devarr[P]);
      // inc(X);
      // end;
      // end;
      //
      // if armindex = -1 then
      // begin
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT ARM---');
      // writeln;
      // for P := Low(armarr) to High(armarr) do
      // begin
      // console_write(IntToStr(P + 1) + '. ', 12);
      // writeln(armarr[P]);
      // end;
      // end
      // else
      // begin
      // X:=1;
      // writeln;
      // writeln('---AVAILABLE PATCHES FOR AEXPERT ARM---');
      // writeln;
      // for P := armindex+1 to High(armarr) do
      // begin
      // console_write(IntToStr(X) + '. ', 12);
      // writeln(armarr[P]);
      // inc(X);
      // end;
      // end;

      // TArray.IndexOf<String>(lowercase(armarr),lowercase(curarmpatch));

      // writeln;
      // writeln('Select patch you want to apply');
      // writeln('-------------------------------');
      // writeln;
      // readln(selectedpatch);
      // writeln;
      // writeln('You selected '+selectedpatch);
      // writeln;
      writelog('listOfPatches  function ends..');
    finally
      freeandnil(patchstrlist);
    end;
    // SelectPlugin(length(PluginArray));
  except
    on e: Exception do
    begin
      ReadErrorList(e.Message);
      console_write('    - Error while listing plugins: ' + e.Message, 12);
      writeln;
      writelog('Error while listing plugins: ' + e.Message);
      readln;
    end;
  end;
end;

function TGitManager.findindex(MyArray: TArray<string>;
Mystring: string): Integer;
var
  Index: Integer;
  Found: Boolean;
  I: Integer;
begin
  Found := False;
  for I := Low(MyArray) to High(MyArray) do
  begin
    if (lowercase(Mystring) = 'patch0') or (lowercase(Mystring) = '') then
    begin
      Result := -1;
      break;
    end
    else if lowercase(MyArray[I]) = lowercase(Mystring) then
    begin
      Index := I;
      Found := True;
      Result := Index;
      break;
    end;
  end;

  // if not Found then
  // Index := -1;
end;

function TGitManager.listOfPlugins(): string; // 001
var

  pluginName, key: string;

  JVALUE: TJSONValue;

  I, J: Integer;
  NameValue: string;
  plugJvalue: TJSONValue;
  KeyName: string;
  JSONGet: String;
  // giving username password we will get token
begin
  try
    try
      writelog('listOfPlugins function started..');
      writeln;
      writeln('Available plugins');
      writeln('==================');
      pluginstrlist := TstringList.Create;
      for I := 0 to length(pluginarray) - 1 do // jcount la bdlaychy
      begin
        // keyName := 'name';
        // JObject := JsonArray.Get(I) as TJSONObject;
        // NameValue := JObject.Get(keyName).JSONValue.value;
        // PluginArray[I] := NameValue;
        console_write(inttostr(I + 1) + '. ', 12);
        writeln(pluginarray[I]); // pluginarray[I]
        // SetConsoleTextAttribute(inttostr(I+1)+'. ', 4);
        pluginstrlist.Add(inttostr(I + 1) + '=' + pluginarray[I]);
        // pluginarray[I]
      end;
      writelog('PluginArray displayed..');
      writelog('listOfPlugins function ends..');
    finally
      freeandnil(pluginstrlist);
    end;
    // SelectPlugin(length(PluginArray));
  except
    on e: Exception do
    begin
      ReadErrorList(e.Message);
      console_write('    - Error while listing plugins: ' + e.Message, 12);
      writeln;
      writelog('Error while listing plugins: ' + e.Message);
      readln;
    end;
  end;
end;

function TGitManager.initConnection(): string;
begin
  // Access_Token := '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'; //'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';//
  // Owner := 'Paroksh11';
  // reponame := 'Axpert';
  httpretry := 0;

end;

function TGitManager.SelectPlugin(PluginCount: Integer): String; // 2
var
  I, J, IDX, PluginIdx: Integer;
  ISFound: Boolean;
  Response: string;
begin
  try
    writelog('SelectPlugin function started...');
    curdir := AppDir{GetCurrentDir()};
    writeln;
    // writeln(curdir);  //C:\Users\paroksh.AGILELABS\Desktop\Git_plugin
    ForceDirectories(pluginLocalPath);
    // pluginLocalPath := curdir + '\Plugin\';
    writeln('Choose the plugin number you want to install..');
    readln(pluginName);
    if ((strtoint(pluginName) <= 0) or (strtoint(pluginName) > PluginCount))
    then
    begin
      repeat
      begin
        writeln('Give Plugin number within range..');
        readln(pluginName);
        writeln;
      end;
      until ((strtoint(pluginName) > 0) and
        (strtoint(pluginName) <= PluginCount));
    end;

    writeln;
    // Before to the below line , validate whether the given input is valid number
    // and plugin available for that selected no
    PluginIdx := strtoint(pluginName);
    // PluginIdx := PluginIdx - 1;//-1 added since stringlist starts from 0
    ISFound := False;
    writeln('Selected plugins for Installations:');
    writeln('=====================================');
    IDX := 0;
    (*
      //Old code //commented on 13/03/2024 - This code can be reused when handling multiple plugins
      for I := 0 to Length(PluginArray)-1 do
      begin
      //writeln(pluginstrlist.ValueFromIndex[I]);                               //
      if LowerCase(pluginName)=LowerCase(pluginstrlist.ValueFromIndex[I]) then //PluginArray[I]
      begin
      inc(IDX);
      writeln(IntToStr(IDX)+'.'+pluginstrlist.ValueFromIndex[I]);
      //writeln('-----------------------------');
      writeln;
      selectedPlugin:=pluginstrlist.ValueFromIndex[I];
      ForceDirectories(pluginLocalPath+selectedPlugin);
      CreateFolderStructure('https://api.github.com/repos/Paroksh11/Axpert/contents/','Plugin/'+selectedPlugin);
      Result:=pluginstrlist.ValueFromIndex[I];
      ISFound:=True;
      break;
      end;
      for J :=0 to pluginstrlist.count do
      begin
      if pluginName=intToStr(J) then
      begin
      pluginName:=pluginstrlist.ValueFromIndex[J-1];
      selectedPlugin:=pluginName;
      ISFound:=True;
      break;
      end;
      end;

      end;
    *)

    // New code for checking plugin
    IDX := 0;
    if (pluginstrlist.IndexOfName(inttostr(PluginIdx))) >= 0 then
    begin
      Inc(IDX);
      selectedPlugin := pluginstrlist.ValueFromIndex[PluginIdx - 1];
      // strlist starts index from 0
      console_write(inttostr(IDX) + '. ', 12);
      write(selectedPlugin);
      writeln;
      writeln;
      console_write
        ('Note: If the selected plugin already exists, continuing will overwrite the existing plugin files.',
        14);
      writeln;
      writeln;
      write('Do you want to continue with this installation? ');
      console_write('[y/n]', 12);
      writeln;
      readln(Response);
      writeln;
      if lowercase(Response) = 'y' then
      begin
        // ISFound:=True;
        // writeln('PLUGIN INSTALLATION PROCESS');
        // writeln('=============================');
        // writeln;
        // ForceDirectories(pluginLocalPath+selectedPlugin);
        // writeln;
        // Console_write('1. Pulling Plugin Files from GIT:',3);
        // writeln;
        // writeln('  - '+selectedPlugin+' selected.');
        // writeln('  - Pulling '+selectedPlugin+' files from GIT one by one:');
        // writeln;
        // CreateFolderStructure('https://api.github.com/repos/Paroksh11/Axpert/contents/','Plugin/'+selectedPlugin);
        // writeln;
        // writeln('   - All '+selectedplugin+' files pulled successfully.');
        // writeln;
        // Result:=pluginstrlist.ValueFromIndex[I];
        pullfromgit();
      end;
      if lowercase(Response) = 'n' then
      begin
        writeln('Installation aborted...');
        writelog('Plugin installation aborted...');
        writeln;
        listOfPlugins();
      end
    end;
    if (lowercase(Response) <> 'y') and (lowercase(Response) <> 'n') then
    begin
      repeat
      begin
        writeln('Give response in y or n only ');
        readln(Response);
      end;
      until (lowercase(Response) = 'y') or (lowercase(Response) = 'n');
      if lowercase(Response) = 'y' then
      begin
        pullfromgit();
      end;
      if lowercase(Response) = 'n' then
      begin
        listOfPlugins();
      end;

    end;

    // if response='n' then






    // Give correct Plugin name or serial number. Plugin may not be available,Please check spelling

    // Choose the plugin number you want to install..
    // if ISFound=False then
    // if (lowercase(response)<>'n') and (lowercase(response)<>'y') then
    // begin
    // WriteLn('Give response in y or n only ');
    // if response='y' then
    // begin
    //
    // end;
    //
    // selectplugin();
    // end;+
    writelog('SelectPlugin function ends...');
  except
    on e: Exception do
    begin
      ReadErrorList(e.Message);
      console_write('    - Error: ' + e.Message, 12);
      writeln;
      writelog('Error while executing selectePlugin : ' + e.Message);
      readln;
    end;
  end;

end;

function TGitManager.pullStructuresfromgit(): string;
var
  CheckExistancePath: string;
  commandstrlist: TstringList;
  patch: string;
begin
  try
    writelog('pullStructuresfromgit function started..');
    if patchOrPlugin = 'Release' then
    begin

      commandstrlist := TstringList.Create;
      commandstrlist.Delimiter := '/';
      commandstrlist.Delimitedtext := selectedPatch;
      selectedversion := commandstrlist[0] + ' ' + commandstrlist[1];
      patch := commandstrlist[2];
      commandstrlist.free;

      writelog('Pulling AxpertStructures for Patch from GIT');
      writeln('PATCH INSTALLATION PROCESS');
      writeln('=============================');
      writeln;

      writeln;
      console_write('1. Pulling Patch Files from GIT:', 3);
      writeln;
      // writeln('  - ' + selectedVersion +' '+selectedschema+'/'+'selectedpatch'+' selected.');
      writeln('  - ' + selectedversion + ' ' + patch + ' selected.');
      writelog(selectedversion + ' ' + patch + ' start pulling from git');
      // writeln('  - Pulling ' + selectedVersion+'/'+selectedpatch + ' files from GIT one by one:');
      writeln('  - Pulling ' + selectedversion + '/' + patch +
        ' files from GIT one by one:');

      // Pull Axpert Web - AxperStructures
      // CheckExistancePath:=patchLocalPath + selectedVersion+'\'+selectedschema+'\'+selectedPatch;
      CheckExistancePath := patchLocalPath + selectedversion + '\' + patch +
        '\AxpertWeb\AxpertStructures'; // check for axpertweb structures
      writelog('Path recevied in CheckExistancePath : ' +CheckExistancePath);
      if DirectoryExists(CheckExistancePath) then
      begin
        Writelog('Requested Local Directory Exists !');
        TDirectory.Delete(CheckExistancePath, True);
        CreateDir(CheckExistancePath)
      end;
      writelog('CreateFolderStructure function started..');
      // CreateFolderStructure((GitPatchURL +
      // selectedVersion + '/' + patch+ '/AxpertWeb/AxpertStructures'),'');

      CreateFolderStructure((GitPatchURL + selectedversion + '/' + patch),
        'AxpertWeb/AxpertStructures');

      if (lowercase(selectedversion) = 'version 11.3') then
      // for 11.3 version (Axpert Dev)
      begin
        // Pull Axpert Dev - AxperStructures
        // CheckExistancePath:=patchLocalPath + selectedVersion+'\'+selectedschema+'\'+selectedPatch;
        CheckExistancePath := patchLocalPath + selectedversion + '\' + patch +
          '\AxpertDeveloper\AxpertStructures';
        // check for axpert dev structures
        if DirectoryExists(CheckExistancePath) then
        begin
          TDirectory.Delete(CheckExistancePath, True);
          CreateDir(CheckExistancePath)
        end;
        // CreateFolderStructure((GitPatchURL +
        // selectedVersion + '/' + patch+'/AxpertDeveloper/AxpertStructures'),'');
        CreateFolderStructure((GitPatchURL + selectedversion + '/' + patch),
          'AxpertDeveloper/AxpertStructures');
      end;

      if pageNotFoundError then
      begin
        writelog('Error : Page not Found');
        Exit;
      end;
      writelog('CreateFolderStructure function ends..');
      writelog('All files pulled successfully from git');
      console_write('    - All ', 10);
      write(patch);
      console_write(' files pulled successfully.', 10);
      writelog('All files pulled successfully from git for ' + patch);
      writeln;
      writeln;
    end
    else if patchOrPlugin = 'Plugin' then
      begin
        writelog('Pulling Plugin Structures from Git');
        console_write('1. Pulling Plugin Structure Files from GIT:', 3);
        writeln;
        writeln('  - ' + selectedplugin + ' selected.');
        writelog(selectedplugin + ' start pulling from git');

        CheckExistancePath := pluginLocalPath + selectedplugin + '\Structures';
        writelog('Path recevied in CheckExistancePath : ' +CheckExistancePath);
        if DirectoryExists(CheckExistancePath) then
        begin
          Writelog('Requested Local Directory Exists !');
          TDirectory.Delete(CheckExistancePath, True);
          CreateDir(CheckExistancePath);
        end;

        CreateFolderStructure(GitPluginURL + selectedplugin, 'Structures');
 //       CreateFolderStructure(GitPluginURL + selectedplugin, 'PluginScripts');

        if pageNotFoundError then
          Exit;

        console_write('    - Plugin Structures pulled successfully.', 10);
        writeln;

        writelog('Plugin structures pulled successfully for ' + selectedplugin);
      end;
    writelog('pullStructuresfromgit function ends..');
  finally

  end;

end;

function TGitManager.pullfromgit(): string;
var
  CheckExistancePath: string;
  commandstrlist: TstringList;
  patch: string;
begin
  try
    // commandstrlist := TStringList.Create;
    // commandstrlist.Delimiter := '/';
    // commandstrlist.Delimitedtext := selectedPatch;
    // selectedVersion:=commandstrlist[0]+' '+commandstrlist[1];
    // patch:=commandstrlist[2];
    // commandstrlist.free;
    writelog('pullfromgit function started..');
    if patchOrPlugin = 'Release' then
    begin

      commandstrlist := TstringList.Create;
      commandstrlist.Delimiter := '/';
      commandstrlist.Delimitedtext := selectedPatch;
      selectedversion := commandstrlist[0] + ' ' + commandstrlist[1];
      patch := commandstrlist[2];
      commandstrlist.free;

      writelog('Pulling for Patch');
      writeln('PATCH INSTALLATION PROCESS');
      writeln('=============================');
      writeln;
      // ForceDirectories(patchLocalPath + selectedVersion+'\'+selectedschema+'\'+selectedPatch);
      // ForceDirectories(patchLocalPath + selectedVersion+'\'+patchtobeinstall);
      writeln;
      console_write('1. Pulling Patch Files from GIT:', 3);
      writeln;
      // writeln('  - ' + selectedVersion +' '+selectedschema+'/'+'selectedpatch'+' selected.');
      writeln('  - ' + selectedversion + ' ' + patch + ' selected.');
      writelog(selectedversion + ' ' + patch + ' start pulling from git');
      // writeln('  - Pulling ' + selectedVersion+'/'+selectedpatch + ' files from GIT one by one:');
      writeln('  - Pulling ' + selectedversion + '/' + patch +
        ' files from GIT one by one:');
      // CheckExistancePath:=patchLocalPath + selectedVersion+'\'+selectedschema+'\'+selectedPatch;
      CheckExistancePath := patchLocalPath + selectedversion + '\' + patch;
      if DirectoryExists(CheckExistancePath) then
      begin
        TDirectory.Delete(CheckExistancePath, True);
        CreateDir(CheckExistancePath)
      end;
      // CreateFolderStructure((GitPatchURL+selectedversion+'/'), selectedschema+'/'+selectedPatch);   //ithe patch1 aivaji web/patch1
      writelog('CreateFolderStructure function started..');

      // Decided to removed OfficialReleases , so plugin and patches will be palced
      // directly under repo\root dir   | 14/11/2024
      // CreateFolderStructure((GitPatchURL + 'OfficialReleases/Patches/' +
      // selectedVersion + '/' + patch),
      // { selectedschema+'/'+selectedPatch } '');

      (*
        21/11/2024 - As discussed with sab sir, we are following git structure as follows
        Repo/versionXX/ReleaseXX

        Accordingly changing the code here.
      *)
      // CreateFolderStructure((GitPatchURL + 'Patches/' +
      // selectedVersion + '/' + patch),'');

      CreateFolderStructure((GitPatchURL + selectedversion + '/' + patch), '');

      if pageNotFoundError then
        Exit;
      writelog('CreateFolderStructure function ends..');
      writelog('All files pulled successfully from git');
      console_write('    - All ', 10);
      write(patch);
      console_write(' files pulled successfully.', 10);
      writelog('All files pulled successfully from git for patch ' + patch);
      writeln;
      writeln;
    end;
    if patchOrPlugin = 'Plugin' then
    begin
      writelog('Pulling for Plugin');
      writeln;
      writeln('PLUGIN INSTALLATION PROCESS');
      writeln('=============================');
      writeln;
      // Decided to removed OfficialReleases , so plugin and patches will be palced
      // directly under repo\root dir   | 14/11/2024
      // ForceDirectories(patchLocalPath +
      // 'OfficialReleases\Plugins' { selectedPlugin } );

      // 25-11-2024 | keeping main repo as dir in local folder
      // ForceDirectories(patchLocalPath +
      // 'Plugins');

     // ForceDirectories(patchLocalPath);
      ForceDirectories(pluginLocalPath);

      // writeln;
      console_write('1. Pulling Plugin Files from GIT:', 3);
      writeln;
      writeln('  - ' + selectedPlugin + ' selected.');
      writeln('  - Pulling ' + selectedPlugin + ' files from GIT one by one:');

      // Decided to removed OfficialReleases , so plugin and patches will be palced
      // directly under repo\root dir   | 14/11/2024
      // CheckExistancePath := patchLocalPath + 'OfficialReleases\Plugins\' +
      // selectedPlugin;

      // 25-11-2024 | keeping main repo as dir+selectedplugin as sub dir in local folder
      CheckExistancePath := {patchLocalPath} pluginLocalPath + selectedPlugin;
      if DirectoryExists(CheckExistancePath) then
      begin
        TDirectory.Delete(CheckExistancePath, True);
        CreateDir(CheckExistancePath)
      end;
      writelog('CreateFolderStructure function started..');

      // Decided to removed OfficialReleases , so plugin and patches will be palced
      // directly under repo\root dir   | 14/11/2024
      // CreateFolderStructure(GitPatchURL + 'OfficialReleases/Plugins/' +
      // selectedPlugin, '' { selectedPlugin } );

      // 25-11-2024 | keeping main repo as dir+selectedplugin as sub dir in local folder
      //CreateFolderStructure(GitPatchURL + selectedPlugin, '');
      CreateFolderStructure(gitpluginurl + selectedPlugin, '');
      console_write('    - All ', 10);
      write(selectedPlugin);
      console_write(' files pulled successfully.', 10);
      writeln;
      writelog('files pulled successfully for ' + selectedPlugin);
      writeln;
    end;
    writelog('pullfromgit function ends..');
  finally

  end;

end;

function ExtractLastSegmentFromURL(const URL: string): string;
var
  URLSegments: TStringDynArray;
  I: Integer;
begin
  // Split the URL by '\' delimiter
  URLSegments := SplitString(URL, '\');

  // Return the last segment
  Result := URLSegments[High(URLSegments)];

end;

function RemoveLastSegmentFromURL(URL: string): string;
var
  LastSlashPos: Integer;
begin
  // Find the last occurrence of '/' in the URL
  LastSlashPos := LastDelimiter('/', URL);

  // If a slash is found, remove everything after it
  if LastSlashPos > 0 then
  begin
    URL := copy(URL, 1, LastSlashPos - 1);
    LastSlashPos := LastDelimiter('/', URL);
    URL := copy(URL, 1, LastSlashPos);
    Result := URL;
  end
  else
    Result := URL; // No slash found, return original URL
end;

function RemoveLastSegmentFromPath(path: string): string;
var
  LastSlashPos: Integer;
begin
  // Find the last occurrence of '/' in the URL
  LastSlashPos := LastDelimiter('\', path);

  // If a slash is found, remove everything after it
  if LastSlashPos > 0 then
  begin
    path := copy(path, 1, LastSlashPos - 1);
    LastSlashPos := LastDelimiter('\', path);
    path := copy(path, 1, LastSlashPos);
    Result := path;
  end
  else
    Result := path; // No slash found, return original URL
end;

function RemoveFirstSegmentFromURLPath(const URLPath: string): string;
var
  FirstSlashPos: Integer;
  firstBackSlash: Integer;
begin
  // Find the first occurrence of '/' in the URL path
  FirstSlashPos := Pos('/', URLPath);
  firstBackSlash := Pos('\', URLPath);

  // If a slash is found, remove everything before it including the slash
  if FirstSlashPos > 0 then
    Result := copy(URLPath, FirstSlashPos + 1, length(URLPath) - FirstSlashPos)
  else if firstBackSlash > 0 then
    Result := copy(URLPath, firstBackSlash + 1,
      length(URLPath) - firstBackSlash)
  else
    Result := URLPath; // No slash found, return original URL path
end;

function TGitManager.CreateFolderStructure(GURL, Fpath: string): string;
var
  IdHTTP1: TIdHTTP;
  Compressedpath: string;
  CompressedFileSavingpath: string;
  Response: TStringStream;
  OutJson: String;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  JsonArray: TJSONArray;
  JSONObject, JObject: TJSONObject;
  JSONSize, I: Integer;
  JSONText, JText: string;
  FolderPath, UpFolderPath, FilePath, FileType, FileContent,
    download_url: String;
  TxtFile, txfile: TextFile;
  aftfirstseg: string;
  downloadPath: string;
  filecnt: string;
  errmsg: string;
  nfilename, nFilePath, DisplayDestPath: string;
begin
  try
    try
      writelog('CreateFolderStructure starts');
      // writeln(selectedplugin);
      writelog('Creating IdHTTP instance');
      IdHTTP1 := TIdHTTP.Create(nil);
      // initConnection();
      writelog('Creating SSL IOHandler');
      SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
      // SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      writelog('Setting SSL versions: TLSv1, TLSv1.1, TLSv1.2');
      SSLIOHandler.SSLOptions.SSLVersions :=
        [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      // SSLIOHandler.SSLOptions.CipherList:='TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA';
      // SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
      writelog('Assigning IOHandler to IdHTTP');
      IdHTTP1.IOHandler := SSLIOHandler;
      writelog('Enabling HandleRedirects');
      IdHTTP1.HandleRedirects := True;
      writelog('Adding Authorization header');
      IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
        'Bearer ' + Access_Token);
      // writeln('Invoking URL : '+TidUri.URLEncode(GURL + Fpath));
      // writeln;
      writelog('CreateFolderStructure GURL: ' + GURL);
      writelog('CreateFolderStructure Fpath: ' + Fpath);
      writelog('CreateFolderStructure Fpath: ' + Fpath);
      if Fpath = '' then
      begin
        try
          writelog('IdHTTP1.Get starts, GURL: ' + GURL);
          JSONText := IdHTTP1.Get(TidUri.URLEncode(GURL + '/'));
          writelog('IdHTTP1.Get ends, GURL: ' + GURL);
        Except
          on e: Exception do
          begin
            console_write
              ('Git library not properly updated.please confirm once.', 12);
            console_write('IdHTTP1.Get error: ' + E.Message);
            WriteLog('IdHTTP1.Get error: ' + E.Message);
            ReadErrorList(e.Message);
            pageNotFoundError := True;
            Exit;
          end;

        end;
      end
      else
      begin
        try
          writelog('IdHTTP1.Get starts, GURL: ' + GURL + '/' + FPath);
          JSONText := IdHTTP1.Get(TidUri.URLEncode(GURL + '/' + Fpath));
          writelog('IdHTTP1.Get ends, GURL: ' + GURL + '/' + FPath);
        Except
          on e: Exception do
          begin
            console_write
              ('Git library with Folder is not properly updated.please confirm once.', 12);
            console_write('IdHTTP1.Get error: ' + E.Message);
            WriteLog('IdHTTP1.Get error: ' + E.Message);
            ReadErrorList(e.Message);
            pageNotFoundError := True;
            Exit;
          end;
        end;
      end;
      // writeln(GURL + '/' + Fpath);
      JsonArray := TJSONObject.ParseJSONValue(JSONText) as TJSONArray;
      JSONSize := JsonArray.size;

      for I := 0 to JSONSize - 1 do
      begin
        JSONObject := JsonArray.Get(I) as TJSONObject;
        FileType := JSONObject.Get('type').JSONValue.value;
        if FileType = 'dir' then
        begin
          FolderPath := JSONObject.Get('path').JSONValue.value;
          UpFolderPath := StringReplace(FolderPath, '/', '\', [rfReplaceAll]);
          writelog('UpFolderPath: ' + UpFolderPath);

          // 22-11-2024 | use local path and the create GIT DIR Structures
          ForceDirectories(patchLocalPath + '\' + UpFolderPath);

          // Use upfolder directory
          // ForceDirectories(GetCurrentDir() + '\' + UpFolderPath);

          // RemoveLastSegmentFromURL is callled to remove last segment of url(Plugin folder name)
          // sience plugin folder was already there in our url

          (*
            **RemoveFirstSegmentFromURLPath  NOTE **:
            Called everytime to remove paths dirpaths till we get last new path
            but this methods is not advisable ,need to be optimized.

            Currentl we changed Git structure (root dir strcuture)
            so we are commenting one call of RemoveFirstSegmentFromURLPath here.
            Similarly we may need to handle on other places as well but , its better to
            optimize the functionality to get the desire output at single call.
          *)
          if patchOrPlugin = 'Release' then
          begin
            aftfirstseg := RemoveFirstSegmentFromURLPath(FolderPath);
            aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
          end
          else
          begin
            aftfirstseg := RemoveFirstSegmentFromURLPath(FolderPath);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
            // aftfirstseg := RemoveFirstSegmentFromURLPath(aftfirstseg);
          end;
          writelog('Calling CreateFolderStructure...');
          writelog('GURL: ' + GURL);
          writelog('aftfirstseg: ' + aftfirstseg);
          CreateFolderStructure(GURL, aftfirstseg);
        end
        else
        begin
          FilePath := JSONObject.Get('path').JSONValue.value;
          FilePath := StringReplace(FilePath, '/', '\', [rfReplaceAll]);
          download_url := JSONObject.Get('download_url').JSONValue.value;
          // 22-11-2024 | As per new git structure
          //downloadPath := patchLocalPath + '\' + FilePath;
          if patchOrPlugin = 'Plugin' then
            downloadPath := pluginLocalPath + '\' + FilePath
          else
            downloadPath := patchLocalPath + '\' + FilePath;
          // downloadPath := GetCurrentDir + '\' + FilePath;
          // FilePath:=RemoveFirstSegmentFromURLPath(FilePath);
          // FilePath:=RemoveFirstSegmentFromURLPath(FilePath);
          // FilePath:=RemoveFirstSegmentFromURLPath(FilePath);
          // 25-11-2024 | GIT Structure modigied so accordingly use of  RemoveFirstSegmentFromURLPath modified.
          FilePath := RemoveFirstSegmentFromURLPath(FilePath);
          Writelog('DownloadPath: ' +downloadPath);
          Writelog('FilePath: ' +FilePath);
          // This call also not needed, as  explained in **RemoveFirstSegmentFromURLPath  NOTE **:
          if patchOrPlugin = 'Release' then
            FilePath := RemoveFirstSegmentFromURLPath(FilePath);
          Fpath := ExtractLastSegmentFromURL(GURL) + '/' + Fpath;
          Fpath := StringReplace(Fpath, '/', '\', [rfReplaceAll]);

          // GetLastNCharsWithEllipsis
          DisplayDestPath := GetLastNCharsWithEllipsis(FilePath);

          writeln('    - Cloning ' + ExtractFileName(FilePath) + ' from ' +
          { FilePath } DisplayDestPath);
          // if Copy(ExtractFileName(FilePath), 0, 3) = 'c__' then
          begin
            try
              //Check for .zip extention in the files to download.
              if LowerCase(ExtractFileExt(FilePath)) = '.zip' then
              begin
                writelog('Zip File Found');
                console_write('Zip File Found');
                writeln('    - Skipping ZIP file: ' + ExtractFileName(FilePath));
                writelog('ZIP skipped: ' + FilePath);
                slUserInstructions.Add('Manual download required for ZIP file:');
                slUserInstructions.Add('Download and extract the following file manually:');
                slUserInstructions.Add(download_url);
                //slUserInstructions.Add('Extract it to: ' + patchLocalPath);
                slUserInstructions.Add('--------------------------------------------------');

                if not Assigned(slUserInstructions) then
                  writelog('slUserInstructions not created.');

                if slUserInstructions = nil then
                  writelog('slUserInstructions not created.');
                Continue;  //Move to next file in loop
              end;
            ForceDirectories(ExtractFileDir(downloadPath));
            writelog('Ensured directory exists: ' + ExtractFileDir(downloadPath));
            console_write('    - Downloading file....');
            writelog('Downloading file....');
            DownloadFile(download_url, downloadPath);
           // console_write('File Downloaded successfully');
            writelog('File Downloaded successfully');
            Except
              on e: Exception do
              begin
                errmsg := e.Message;
                console_write(errmsg);
                writelog(errmsg);
                ReadErrorList(errmsg);
                httpretry := 0;
                while (httpretry < 5) or (errmsg = '') do
                begin
                  if (Pos('ssl routines', lowercase(errmsg)) > 0)or (lowerCase(errmsg) = 'zero size file found.') then
                  begin
                    try
                      errmsg := '';
                      Inc(httpretry);
                      writeln('Retrying..(' + inttostr(httpretry) + ')');
                     // Sleep(5000);
                      DownloadFile(download_url, downloadPath);
                    Except
                      on e: Exception do
                      begin
                        errmsg := e.Message;
                        console_write(errmsg);
                        writelog('Error occured during createfolderstructure : '
                          + errmsg);
                        ReadErrorList(errmsg);
                      end;
                    end;
                  end
                  else if errmsg = '' then
                    break
                  else
                  begin
                    raise Exception.Create(errmsg);
                    ReadErrorList(errmsg);
                  end;
                end;
              end;

            end;

            /// /          FileContent:=pullcompressfile(ExtractFileName(FilePath),Response);
            // //   CompressedFileSavingpath:='D:\Axpert_Project\Axpert\AxPlugins\Task Management\Structures\Iview\Export\'+ExtractFileName(FilePath);
            // //   FileStream := TFileStream.Create(CompressedFileSavingpath, fmCreate);
            // //   IdHTTP1.Request.ContentEncoding := 'utf-8';
            // //  Compressedpath:=RemoveLastSegmentFromURL(GURL)+FilePath;
            // //  Compressedpath := StringReplace(Compressedpath, '/', '\', [rfReplaceAll]);
            // //  JText:=IdHTTP1.Get(Compressedpath);
            // //  JObject:=TJSONObject.ParseJSONValue(JText) as TJSONObject;
            // //  download_url := JSONObject.Get('download_url').JSONValue.value;
            // //  IdHTTP1.Get(download_url,FileStream);
            // // download_url := JSONObject.Get('download_url').JSONValue.value;
            // // HandleResponse(IdHTTP1.ResponseCode);
            Writeln;
            write('    -');
            console_write(' ' + ExtractFileName(FilePath), 10);
            write(' cloned successfully.');
            writeln;
            writelog(ExtractFileName(FilePath)+ 'cloned successfully.');
          end;

          /// if (Copy(ExtractFileName(getcurrentdir()+'\'+FilePath), 0, 3) = 'c__') and
          /// (ExtractFileExt(getcurrentdir()+'\'+FilePath)<>'.trn') and
          /// (ExtractFileExt(getcurrentdir()+'\'+FilePath)<>'.ivw') then
          /// begin
          /// nfilename:=copy(ExtractFileName(FilePath),4,length(ExtractFileName(FilePath)));
          /// nFilePath:=RemoveLastSegmentFromPath(FilePath);
          /// filecnt:=TFile.ReadAllText(getcurrentdir()+'\'+FilePath);
          /// assignfile(txfile,getcurrentdir()+'\'+nFilePath+'\Export\'+nfilename);
          /// rewrite(txfile);
          /// writeln(txfile,filecnt);
          /// closefile(txfile);
          /// end;
          // if not (Copy(ExtractFileName(getcurrentdir()+'\'+FilePath), 0, 3) = 'c__') then
          // begin
          // FileContent := IdHTTP1.Get(TidUri.URLEncode(download_url));
          //
          // // Fpath:=StringReplace(FPath,'/','\',[rfReplaceAll]);
          //
          // // if Copy(ExtractFileName(FilePath),0,3)='c__' then
          // // begin
          // // FileStream := TFileStream.Create(FilePath, fmCreate);
          // // try
          // // IdHTTP1.Request.ContentEncoding := 'utf-8';
          // // IdHTTP1.Get('http://example.com/file-to-download.txt', FileStream);
          // // finally
          // //
          // // end;
          // // end
          // // else
          // // begin
          // AssignFile(TxtFile, (GetCurrentDir() + '\' + trim(FilePath)));
          // // end;
          // Rewrite(TxtFile);
          // write(TxtFile, trim(FileContent));
          // Flush(TxtFile);
          // CloseFile(TxtFile);
          // end;

          // end;
        end;
      end;
      // writelog('Createfolderstrucure function ends..');
    finally
      freeandnil(IdHTTP1);
    end;
  except
    on e: Exception do
    begin
      console_write('    - Error: ' + e.Message, 12);
      writeln;
      writelog('Error in Createfolderstrucure : ' + e.Message);
      readln;
      ReadErrorList(e.Message);
    end;
  end;
  writelog('Createfolderstrucure function ends..')
end;

function TGitManager.pullcompressfile(FileName: string;
var Response: TStringStream): String;
const
  GitHubUsername = 'Paroksh11';
  GitHubRepository = 'Axpert';
  GitHubRawURL = 'https://raw.githubusercontent.com/' + GitHubUsername + '/' +
    GitHubRepository + '/main/';
var
  IdHTTP: TIdHTTP;
  SFileContent: String;
  BFileContent: TBytes;
  Stream: TMemoryStream;
  Encoding: TEncoding;
  FullURL: string;
  I: Integer;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  StringList: TstringList;
begin
  // Result := False;
  FullURL := GitHubRawURL +
    'AxpertPlugins/Task%20Management/Structures/Iview/Export/' +
    ExtractFileName(FileName);
  IdHTTP := TIdHTTP.Create(nil);
  Stream := TMemoryStream.Create;
  StringList := TstringList.Create;
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
  SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  // SSLIOHandler.SSLOptions.CipherList:='TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA';
  SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;

  try
    IdHTTP.IOHandler := SSLIOHandler;

    // IdHTTP.Request.Accept := 'text/plain; charset=utf-8';
    // IdHTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';

    SFileContent := IdHTTP.Get(FullURL);
    Encoding := TEncoding.UTF8;
    BFileContent := Encoding.GetBytes(SFileContent);
    Result := Encoding.GetString(BFileContent);
    /// ///////////////////////////////////////////////////////////////////////
    // IdHTTP.Get(FullURL,Stream);
    // stream.Position:=0;
    // SetLength(BFileContent,stream.Size);
    // stream.ReadBuffer(BFileContent[0],stream.Size);
    // for I:=Low(BFileContent) to High(BFileContent) do
    // begin
    // StringList:=StringList.Add(chr(BFileContent[I]));
    // end;
    // Result:=StringList.ToString;

    // Stream.Position := 0;
    // SetLength(Result, Stream.Size);
    // FileContent:=Trim(FileContent);
    // Stream.ReadBuffer(Result[0], Stream.Size);
    // Result := TEncoding.UTF8.GetString(FileContent);
    // Result:=TStringStream.Create('', TEncoding.UTF8).ReadString(MemoryStream.Size, MemoryStream);
  finally
    IdHTTP.free;
    freeandnil(Stream);
    freeandnil(StringList);
    // SSLIOHandler.Free;
  end;
end;

// UTF8 download     - requires change in the functionality - verify it and then use this function
(*
  function TGitManager.DownloadFile(const URL, FileName: string): string;
  var
  HTTP: TIdHTTP;
  MemoryStream: TMemoryStream;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  FileStream: TFileStream;
  UTF8String: string;
  UTF8Bytes: TBytes;
  begin
  result := '';
  HTTP := TIdHTTP.Create(nil);
  MemoryStream := TMemoryStream.Create;
  try
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create();
  SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
  SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  // SSLIOHandler
  // To handle redirects
  HTTP.HandleRedirects := True;
  // it starts automatically handling redirects
  HTTP.RedirectMaximum := 15;
  // is used to set how many successive redirects should be handled
  HTTP.IOHandler := SSLIOHandler;
  HTTP.HTTPOptions := [hoForceEncodeParams];
  HTTP.ProtocolVersion := pv1_1;
  HTTP.Request.CharSet := 'utf-8';
  HTTP.Request.CacheControl := 'no-cache'; // this force use no-cache
  HTTP.Request.Accept := '*/*';
  HTTP.Request.CustomHeaders.Delimiter := ';';
  HTTP.Request.CustomHeaders.AddValue('Content-Type', 'application/json');
  HTTP.Request.UserAgent := 'Axpert';
  // Download the content to a memory stream
  HTTP.Get(URL, MemoryStream);

  // Convert the downloaded content to a string
  MemoryStream.Position := 0;
  SetLength(UTF8String, MemoryStream.size div SizeOf(Char));
  MemoryStream.ReadBuffer(Pointer(UTF8String)^, MemoryStream.size);

  // Convert the string to UTF-8 bytes
  UTF8Bytes := TEncoding.UTF8.GetBytes(UTF8String);

  // Create the file stream to write the UTF-8 bytes
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
  FileStream.WriteBuffer(UTF8Bytes[0], length(UTF8Bytes));
  finally
  FileStream.Free;
  end;
  finally
  MemoryStream.Free;
  HTTP.Free;
  end;
  end;

*)
function TGitManager.DownloadFile(const URL, FileName: string): string;
var
  HTTP: TIdHTTP;
  errmsg: string;
  filestream: TFileStream;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  HTTP:= nil;
  filestream:= nil;
  try
    HTTP := TIdHTTP.Create(nil);
    try
      writelog('Creating IdHTTP instance in DownloadFile Function');
      writelog('Download File function started');
      // HTTP := TIdHttp.Create();
      writelog('Creating SSL IOHandler');
      SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create();

      writelog('Setting SSL Method TLSv1_2');
      SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;

      writelog('Setting SSL Versions TLSv1_2');
      SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      // SSLIOHandler
      // To handle redirects
      writelog('Setting HTTP redirect options');
      HTTP.HandleRedirects := True;
      // it starts automatically handling redirects
      HTTP.RedirectMaximum := 15;
      // is used to set how many successive redirects should be handled
      writelog('Assigning IOHandler to HTTP');
      HTTP.IOHandler := SSLIOHandler;

      writelog('Setting HTTP protocol and options');
      HTTP.HTTPOptions := [hoForceEncodeParams];
      HTTP.ProtocolVersion := pv1_1;

      writelog('Setting request headers');
      HTTP.Request.CharSet := 'utf-8';
      HTTP.Request.CacheControl := 'no-cache'; // this force use no-cache
      HTTP.Request.Accept := '*/*';
      HTTP.Request.CustomHeaders.Delimiter := ';';
      HTTP.Request.CustomHeaders.AddValue('Content-Type', 'application/json');
      HTTP.Request.UserAgent := 'Axpert';

      // HTTP.Request.UserAgent :=
      // 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36';
      // SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
      // // HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      // SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      // // SSLIOHandler.SSLOptions.CipherList:='TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA';
      // SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
      // SSLIOHandler.SSLOptions.Mode := sslmClient;
      // SSLIOHandler.SSLOptions.VerifyMode := [];
      // // SSLIOHandler.SSLOptions.VerifyDepth := 0;
      // HTTP.IOHandler := SSLIOHandler;
      writelog('Creating filestream for file : ' + FileName);
      filestream := TFileStream.Create(FileName, fmCreate);

      writelog('Starting HTTP GET download');
      writelog('Download URL : ' + URL);
      HTTP.Get(URL, filestream);
      writelog('HTTP GET completed');
     // writelog ('Filestream : ' + filestream);

      filestream.Size;
      writelog('Downloaded file size : ' + IntToStr(filestream.Size));
      if filestream.Size = 0 then
        raise Exception.Create('Zero size file found.');
      writelog('File download successful');
    Except
      on e: Exception do
      begin
        console_write( e.Message+ ' while downloading file from :' + URL);
        ReadErrorList(e.Message);
        writelog( e.Message+ ' while downloading file from :' + URL);
        raise;
      end;
    end;

  finally
    writelog('Cleaning up HTTP resources');

    if assigned(filestream) then
      freeandnil(filestream);
    freeandnil(HTTP);
  end;
  writelog('Download File Function ends');
end;

function TGitManager.NaturalCompare(const Left, Right: string): Integer;
var
  Regex: TRegEx;
  LeftMatch, RightMatch: TMatch;
  LeftNumber, RightNumber: Integer;
begin
  Regex := TRegEx.Create('\d+');

  // Find numeric parts of the strings
  LeftMatch := Regex.Match(Left);
  RightMatch := Regex.Match(Right);

  // If both strings have numeric parts
  if LeftMatch.Success and RightMatch.Success then
  begin
    // Convert numeric parts to integers
    LeftNumber := strtoint(LeftMatch.value);
    RightNumber := strtoint(RightMatch.value);

    // Compare numeric parts
    Result := CompareValue(LeftNumber, RightNumber);

    // If numeric parts are equal, compare the rest of the strings
    if Result = 0 then
      Result := CompareText(Left, Right);
  end
  // If only the left string has a numeric part
  else if LeftMatch.Success then
    Result := 1
    // If only the right string has a numeric part
  else if RightMatch.Success then
    Result := -1
    // If neither string has a numeric part, compare normally
  else
    Result := CompareText(Left, Right);
end;

function TGitManager.findpatchindex(patch: string): Integer;
var
  I: Integer;
  Found: Boolean;
begin
  writelog('findpatchindex function started..');
  Found := False;
  for I := Low(patcharray) to High(patcharray) do
  begin
    if lowercase(patch) = lowercase(patcharray[I]) then
    begin
      Result := I;
      Found := True;
      break;
    end;
  end;
  if Found = False then
    Result := -1;
  writelog('findpatchindex function ends..');

end;


// function GetAuthorizationURL(const ClientID: string): string;
// begin
// Result := 'https://github.com/login/oauth/authorize?';
// Result := Result + 'client_id=' + Client_id;
// Result := Result + '&scope= repo';
// Result := Result + '&redirect_uri=http://localhost:8080/callback';
// end;
//
// function getAuthCode():string;
// var
// AuthURL:String;
// begin
//
// end;

end.
