unit uPatchInstallation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls,
  IdBaseComponent, uAxLog,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  IdAuthentication, idUri,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, IdMultipartFormData,
  StrUtils,
  System.IOUtils, System.Types, System.Generics.Collections, DBXJSON, uUtils,
  DB, DBClient, System.RegularExpressions, uDbConnect,
  SimpleDS, Provider, SqlExpr, DBXCommon, DBXOracle, uImportStructures,
  uGitManager, uInstallDbScripts, uInstallRMQClients, uImportDefinition;

type
  TPatchInstallation = class
  public
    // dbc:TDbConnect;
    // dc:TDbConnect;
    backuppath: string;

    function databaseConnectivity(Patch: String): String;
    function InstallPatch(Patch: string): string;
    function InstallPatchWebFiles(Sourcepath, destpath: string;
      isRuntime: Boolean = False): string;
    function InstallPatchScriptFiles(Sourcepath, destpath: string;
      isRuntime: Boolean = False): string;
    function InstallARMFiles(Sourcepath, destpath: string; bCleardir : boolean= False): String;
    function InstallAxpertStructureFiles(Sourcepath: string;
      isRuntime: Boolean = False): String;
    function ReadFile(Sourcepath: string; destpath: string): string;
    // function FindFolder(path: string): string;
    function FindFile(Sourcepath, destpath: string): string;
    // function findfolder(sourcepath:string;destpath:string):string;
    function pushfoldertoOr(sorceurl: string; destinationurl: string): string;
    function InstallPatchWithoutweb(Patch: string): string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TPatchInstallation.Create;
begin
  dbc := nil;
end;

destructor TPatchInstallation.Destroy;
begin
  FreeAndNil(dbc);
  inherited;
end;

function TPatchInstallation.pushfoldertoOr(sorceurl: string;
  destinationurl: string): string;
var
  IdHTTP1: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  JSONObject, JObject: TJSONObject;
  OfficialURL, DevURL, JSONGet, foldername, EditableOffRelURl: string;
  JSONValue: TJSONValue;
  JsonArray: TJSONArray;
  Jcount, I, JSONSize: Integer;
  KeyName, NameValue, FileType, FileName, FileContent, FileSha: string;
  PluginArr: TArray<string>;
  movingfilepayload, movingfilejson: string;
  movingfilejsonObject, NewObject, TestJsonObject: TJSONObject;
  EditableDevURl: string;
  jsonstr, targeturl, previoussha, TestJson: string;
  JsonPayload: TStringStream;

begin
  Writelog('pushfoldertoOr function started..');
  IdHTTP1 := TIdHTTP.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
  SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
  IdHTTP1.IOHandler := SSLIOHandler;
  IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
    'Bearer ' + Access_token);
  JSONObject := TJSONObject.Create;
  JObject := TJSONObject.Create;
  // https://api.github.com/repos/Paroksh11/Axpert/contents/AxpertReleases/
  // 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
  DevURL := sorceurl;
  OfficialURL := destinationurl;
  IdHTTP1.HandleRedirects := True;

  JSONGet := IdHTTP1.Get(TidUri.URLEncode(DevURL));
  JsonArray := TJSONObject.ParseJSONValue(JSONGet) as TJSONArray;
  jsonstr := JsonArray.ToString;
  JSONSize := JsonArray.size;

  for I := 0 to JSONSize - 1 do
  begin
    JSONObject := JsonArray.Get(I) as TJSONObject;
    FileType := JSONObject.Get('type').JSONValue.value;
    if FileType = 'dir' then
    begin
      foldername := JSONObject.Get('name').JSONValue.value;
      EditableDevURl := sorceurl + '/' + foldername;
      EditableOffRelURl := destinationurl + '/' + foldername;
      pushfoldertoOr(EditableDevURl, EditableOffRelURl);
    end;
    if FileType = 'file' then
    begin
      FileName := JSONObject.Get('name').JSONValue.value;
      EditableDevURl := DevURL + '/' + FileName;
      movingfilejson := IdHTTP1.Get(TidUri.URLEncode(EditableDevURl));
      movingfilejsonObject := TJSONObject.Create;
      movingfilejsonObject := TJSONObject.ParseJSONValue(movingfilejson)
        as TJSONObject;
      FileContent := movingfilejsonObject.Get('content').JSONValue.value;
      FileContent := StringReplace(FileContent, #10, '', [rfReplaceAll]);
      FileSha := movingfilejsonObject.Get('sha').JSONValue.value;
      FileSha := StringReplace(FileSha, #10, '', [rfReplaceAll]);
      try
        NewObject := TJSONObject.Create;
        NewObject.AddPair('message', 'Moving file');
        NewObject.AddPair('content', FileContent);

        try
          begin
            targeturl := OfficialURL + '/' + FileName;
            try
              TestJson := IdHTTP1.Get(TidUri.URLEncode(targeturl));
              TestJsonObject := TJSONObject.Create;
              TestJsonObject := TJSONObject.ParseJSONValue(movingfilejson)
                as TJSONObject;
              previoussha := TestJsonObject.Get('sha').JSONValue.value;
              previoussha := StringReplace(previoussha, #10, '',
                [rfReplaceAll]);
              FileSha := previoussha;
            Except
              on E: EIdHTTPProtocolException do
              begin
               // ReadErrorList(E.ErrorCode);
                if E.ErrorCode = 404 then
              end;
            end;
            NewObject.AddPair('sha', FileSha);
            Writelog('Json payload for ' + FileName + ' ' + NewObject.ToString);
            JsonPayload := TStringStream.Create(NewObject.ToString,
              TEncoding.UTF8);
            IdHTTP1.Put(TidUri.PathEncode(targeturl), JsonPayload);
          end;
        Except
          on E: Exception do
          begin
            ReadErrorList(E.Message);
            // showmessage(E.message);
            Writelog('Error while pushing ' + FileName + ': ' + E.Message);
          end;
        end;
      finally
        JsonPayload.Free;
      end;
    end;
  end;
  Writelog('pushfoldertoOr function ends..');
end;

function TPatchInstallation.databaseConnectivity(Patch: String): string;
begin
  try
    try
    // dbc:=nil;
      if not assigned(dbc) then
        dbc := TDbConnect.Create;
      writelog('executing dbc.DataBaseConnection');
      dbc.DataBaseConnection;
      // freeAndNil(dbc);
      if Connectionstatus and (insallstatus = 'Full') then
      begin
        writelog('executing installpatch');
        InstallPatch(Patch);
      end
      else if Connectionstatus and (insallstatus = 'Structure') then
      begin
        writelog('executing installpatchwithoutweb');
        InstallPatchWithoutweb(Patch);
      end
      else
      begin
        writelog('databaseConnectivity: connection failed');
        Console_Write('Unable to establish connection', 4);
        writeln;
      end;
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        writelog('Error in databaseConnectivity: ' + E.Message);
        raise;
      end;
    end;
  finally
    // freeAndNil(dbc);
  end;
end;

function TPatchInstallation.InstallPatchWithoutweb(Patch: string): string;
var
  dpath, srcpath, dstpath: string;
  folderArray, fileArray: TArray<string>;
  foldercount, filecount, Z, Y: Integer;
  Sourcepath: string;
  pathforstruct: string;
  spatch: string;
  commandstrlist: Tstringlist;
  patc: string;
begin
  commandstrlist := Tstringlist.Create;
  commandstrlist.Delimiter := '/';
  commandstrlist.Delimitedtext := Patch;
  spatch := commandstrlist[2];
  commandstrlist.Free;
  Writelog('InstallPatchWithoutweb function started..');
  writeln;
  Console_Write
    ('1. Starting Patch Installation by assuming you already applied web files:',
    3);
  writeln;
  // InstallPatchScriptFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // selectedVersion + '\' + spatch + '\AxpertWeb\ASB\' + apparchitecture,
  // runscriptpath );
  // InstallPatchScriptFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // selectedVersion + '\' + spatch + '\AxpertDeveloper\ASB\' +
  // apparchitecture, devscriptpath  );

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // pathforstruct:=TPath.GetFullPath(patchLocalPath+'OfficialReleases\Patches\'+selectedVersion +'\'+spatch+'\AxpertWeb\AxpertStructures');
  // InstallAxpertStructureFiles(pathforstruct);
  // pathforstruct:=TPath.GetFullPath(patchLocalPath + 'OfficialReleases\Patches\' +selectedVersion + '\' + spatch +'\AxpertDeveloper\AxpertStructures');

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)

  // pathforstruct:=TPath.GetFullPath(patchLocalPath+'Patches\'+selectedVersion +'\'+spatch+'\AxpertWeb\AxpertStructures');
  pathforstruct := TPath.GetFullPath(patchLocalPath + selectedVersion + '\' +
    spatch + '\AxpertWeb\AxpertStructures');
  InstallAxpertStructureFiles(pathforstruct, True);
  pathforstruct := TPath.GetFullPath(patchLocalPath + selectedVersion + '\' +
    spatch + '\AxpertDeveloper\AxpertStructures');
  // pathforstruct:=TPath.GetFullPath(patchLocalPath + 'Patches\' +selectedVersion + '\' + spatch +'\AxpertDeveloper\AxpertStructures');
  InstallAxpertStructureFiles(pathforstruct);
  Writelog('InstallPatchWithoutweb function ends..');
end;

function TPatchInstallation.InstallPatch(Patch: string): string;
var
  dpath, srcpath, dstpath: string;
  folderArray, fileArray: TArray<string>;
  foldercount, filecount, Z, Y: Integer;
  Sourcepath: string;
  pathforstruct: string;
  spatch: string;
  commandstrlist: Tstringlist;
  patc, sversion: string;
begin

  commandstrlist := Tstringlist.Create;
  commandstrlist.Delimiter := '/';
  commandstrlist.Delimitedtext := Patch;
  sversion := commandstrlist[1];
  sversion := 'Version ' + sversion;
  spatch := commandstrlist[2];
  commandstrlist.Free;
  Writelog('InstallPatch function started..');
  writeln;
  Console_Write('2. Starting Patch Installation:', 3);
  writeln;
  // if selectedschema = 'AxpertWeb' then
  // dpath := runwebcodepath { + '\\' + cPatches + '\\' + selectedVersion + '\\' +
  // selectedschema+'\'+selectedpatch };
  // if selectedschema = 'AxpertDeveloper' then
  // dpath := devwebcodepath { + '\\' + cPatches + '\\' + selectedVersion + '\\' +
  // selectedschema+'\'+selectedpatch };
  // if (selectedschema = 'AxpertDeveloper') or (selectedschema = 'AxpertWeb') then
  // begin
  // if not((lowercase(spatch)=lowercase(currentpatchname)) and
  // (lowercase(currentversionname)=lowercase(selectedVersion))) then
  // begin

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // InstallPatchWebFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // sversion + '\' + spatch + '\AxpertWeb\Webcodes',
  // runwebcodepath { +'\Webcodes' } );
  // // writeln;
  // InstallPatchWebFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // sversion + '\' + spatch + '\AxpertDeveloper\Webcodes',
  // devwebcodepath { +'\Webcodes' } );

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)
  //
  // InstallPatchWebFiles(patchLocalPath + 'Patches\' +
  // sversion + '\' + spatch + '\AxpertWeb\Webcodes',
  // runwebcodepath { +'\Webcodes' },True );
  // // writeln;
  // InstallPatchWebFiles(patchLocalPath + 'Patches\' +
  // sversion + '\' + spatch + '\AxpertDeveloper\Webcodes',
  // devwebcodepath { +'\Webcodes' } );

  InstallPatchWebFiles(patchLocalPath + sversion + '\' + spatch +
    '\AxpertWeb\Webcodes', runwebcodepath { +'\Webcodes' } , True);
  // writeln;
  InstallPatchWebFiles(patchLocalPath + sversion + '\' + spatch +
    '\AxpertDeveloper\Webcodes', devwebcodepath { +'\Webcodes' } );


  // end;
  // writeln;
  // end;
  // if selectedschema = 'AxpertDeveloper' then
  // dpath := stringreplace(dpath, devwebcodepath, devscriptpath,
  // [rfReplaceAll]);
  // if selectedschema = 'AxpertWeb' then
  // dpath := stringreplace(dpath, runwebcodepath, runscriptpath,
  // [rfReplaceAll]);
  // if (selectedschema = 'AxpertDeveloper') or (selectedschema = 'AxpertWeb') then
  // begin
  // if ((lowercase(spatch)=lowercase(currentpatchname)) and
  // (lowercase(currentversionname)=lowercase(selectedVersion))) then
  // begin

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // InstallPatchScriptFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // sversion + '\' + spatch + '\AxpertWeb\ASB\' + apparchitecture,
  // runscriptpath { +'\\'+apparchitecture } { +'\ASB' } );
  // InstallPatchScriptFiles(patchLocalPath + 'OfficialReleases\Patches\' +
  // sversion + '\' + spatch + '\AxpertDeveloper\ASB\' +
  // apparchitecture, devscriptpath { +'\\'+apparchitecture } { +'\ASB' } );

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)
  //
  // InstallPatchScriptFiles(patchLocalPath + 'Patches\' +
  // sversion + '\' + spatch + '\AxpertWeb\ASB\' + apparchitecture,
  // runscriptpath { +'\\'+apparchitecture } { +'\ASB' },True );
  // InstallPatchScriptFiles(patchLocalPath + 'Patches\' +
  // sversion + '\' + spatch + '\AxpertDeveloper\ASB\' +
  // apparchitecture, devscriptpath { +'\\'+apparchitecture } { +'\ASB' } );

  InstallPatchScriptFiles(patchLocalPath + sversion + '\' + spatch +
    '\AxpertWeb\ASB\' + apparchitecture,
    runscriptpath { +'\\'+apparchitecture } { +'\ASB' } , True);
  InstallPatchScriptFiles(patchLocalPath + sversion + '\' + spatch +
    '\AxpertDeveloper\ASB\' + apparchitecture,
    devscriptpath { +'\\'+apparchitecture } { +'\ASB' } );

  // end;
  // if (selectedschema = 'AxpertDeveloper') or (selectedschema = 'AxpertWeb') then
  // begin

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // pathforstruct:=TPath.GetFullPath(patchLocalPath+'OfficialReleases\Patches\'+sversion +'\'+spatch+'\AxpertWeb\AxpertStructures');
  // InstallAxpertStructureFiles(pathforstruct);
  // pathforstruct:=TPath.GetFullPath(patchLocalPath + 'OfficialReleases\Patches\' +sversion + '\' + spatch +'\AxpertDeveloper\AxpertStructures');
  // InstallAxpertStructureFiles(pathforstruct);

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)

  // pathforstruct:=TPath.GetFullPath(patchLocalPath+'Patches\'+sversion +'\'+spatch+'\AxpertWeb\AxpertStructures');
  pathforstruct := TPath.GetFullPath(patchLocalPath + sversion + '\' + spatch +
    '\AxpertWeb\AxpertStructures');
  InstallAxpertStructureFiles(pathforstruct, True);
  // pathforstruct:=TPath.GetFullPath(patchLocalPath + 'Patches\' +sversion + '\' + spatch +'\AxpertDeveloper\AxpertStructures');
  pathforstruct := TPath.GetFullPath(patchLocalPath + sversion + '\' + spatch +
    '\AxpertDeveloper\AxpertStructures');
  InstallAxpertStructureFiles(pathforstruct);

  // end;
  // end;
  // InstallPatchScriptFiles(patchLocalPath + selectedVersion + '\' +
  // selectedschema+'\'+selectedpatch+'\ASB',dpath+'\ASB');
  // if selectedschema = 'ARM' then
  // begin

  writeln;
  Console_Write('3. Starting ARM Patch Installation:', 3);
  writeln;

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // Sourcepath := patchLocalPath + 'OfficialReleases\Patches\' + sversion +
  // '\' + spatch + '\AxpertARM\';

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)

  // Sourcepath := patchLocalPath + 'Patches\' + sversion +
  // '\' + spatch + '\AxpertARM\';

  Sourcepath := patchLocalPath + sversion + '\' + spatch + '\AxpertARM\';
  if not directoryexists(Sourcepath) then
  begin
    writeln('    -No files available to process.');
    Writelog('No ARM files are available to process at ' + Sourcepath);
    // Exit;
  end
  else
  begin
    Console_Write
      ('   - Copying files to corresponding folders from the local patch directory.',
      10);
    writeln;

    folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
    foldercount := Length(folderArray);
    fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
    filecount := Length(fileArray);
    for Z := 0 to foldercount - 1 do
    begin
      if ExtractFileName(folderArray[Z]) = 'ARMAPI' then
      begin
        Writelog('Copying ARMAPI files to desired location');
        srcpath := Sourcepath + '\ARMAPI';
        dstpath := armapipath { +'\\' + cPatches + '\\'+selectedVersion +'\\'+
          selectedschema+'\'+selectedpatch+'\ARMAPI' };
        dstpath := TRegEx.Replace(dstpath, '\\+', '\');
        srcpath := TRegEx.Replace(srcpath, '\\+', '\');
        InstallARMFiles(srcpath, dstpath, True);
        Writelog('ARMAPI files copied to desired location');
      end;
      if ExtractFileName(folderArray[Z]) = 'ARMServices' then
      begin
        Writelog('Copying ARM services files to desired location');
        srcpath := Sourcepath + '\ARMServices';
        dstpath :=
          armservicepath { +'\\' + cPatches + '\\'+selectedVersion +'\\'+
          selectedschema+'\'+selectedpatch+'\ARMServices' };
        dstpath := TRegEx.Replace(dstpath, '\\+', '\');
        srcpath := TRegEx.Replace(srcpath, '\\+', '\');
        InstallARMFiles(srcpath, dstpath);
        Writelog('ARM Services files copied to desired location');
      end;
      if ExtractFileName(folderArray[Z]) = 'AgileConnect' then
      begin
        Writelog('Copying ARM agileconnect files to desired location');
        srcpath := Sourcepath + '\AgileConnect';
        dstpath :=
          agileconnectpath { +'\\' + cPatches + '\\'+selectedVersion +'\\'+
          selectedschema+'\'+selectedpatch+'\AgileConnect' };
        dstpath := TRegEx.Replace(dstpath, '\\+', '\');
        srcpath := TRegEx.Replace(srcpath, '\\+', '\');
        InstallARMFiles(srcpath, dstpath);
        Writelog('ARM agile connect files copied to desired location');
      end;
      if ExtractFileName(folderArray[Z]) = 'ASB' then
      begin
        Writelog('Copying ARm ASB files to desired location');
        srcpath := Sourcepath + '\ASB\' + apparchitecture;
        dstpath :=
          armscriptpath { +'\\' + cPatches + '\\'+selectedVersion +'\\'+
          selectedschema+'\'+selectedpatch+'\ASB' };
        dstpath := TRegEx.Replace(dstpath, '\\+', '\');
        srcpath := TRegEx.Replace(srcpath, '\\+', '\');
        InstallARMFiles(srcpath, dstpath);
        Writelog('ARM ASB files copied to desired location');
      end;
      // end;
      // for Y := 0 to filecount - 1 do
      // begin
      // if lowercase(ExtractFileExt(filearray[Y]))='sql' then
      // begin
      //
      // end
      // else
      // begin
      // srcpath:=Sourcepath+'\ASB\ARMDocs';
      // dstpath:=armscriptpath+'\\' + cPatches + '\\'+selectedVersion +'\\'+
      // selectedschema+'\'+selectedpatch+'\ASB\ARMDocs';
      // InstallARMFiles(srcpath, dstpath);
      // end;
      // end;

    end;
  end;

  Writelog('InstallPatch function ends..');
  // dpath := armscriptpath + '\\' + cPatches + '\\' + selectedVersion + '\\' +
  // selectedschema+'\'+selectedpatch;
  // InstallARMFiles(patchLocalPath + selectedVersion + '\' +
  // selectedschema+'\'+selectedpatch, dpath);

end;

function TPatchInstallation.InstallAxpertStructureFiles(Sourcepath: string;
  isRuntime: Boolean = False): String;
var
  fileArray, folderArray: TArray<string>;
  StructureArray: TArray<string>;
  filecount, structurecount, foldercount, X, Y, Z: Integer;
  fldpath, actualSourcePath: string;
  dbs: TInstallDbScripts;
  imps: TImportStructures;
  dbx: TDbConnect;
  spath, dpath, sfilename: string;
  addinstruct: Boolean;
  SourceVersionNo: string;
begin
  if {(lowercase(currentversionname) <> 'version 11.3')} (Not hasdefschema) and (Not isRuntime) then
  begin
    Writelog('InstallAxpertStructureFiles : Version 11.4 and above does not have a separate DB for Developer studio, so it is being skipped.');
    Exit;
  end;
  // if not fileexists(Sourcepath) then
  // forcedirectories(Sourcepath);
  Writelog('InstallAxpertStructureFiles function started...');
  writeln;
  if isRuntime then // Run
    Console_Write('  - Importing Runtime Axpert Structures:', 5)
  else // Dev
    Console_Write('  - Importing Developer studio Axpert Structures:', 5);
  writeln;
  if not directoryexists(Sourcepath) then
  begin
    Writelog('No structures available for import from ' + Sourcepath);
    writeln('    -No files available to process.');
    Exit;
  end;
  Console_Write('   - Importing form and report structures one by one.', 10);
  writeln;
  actualSourcePath := Sourcepath; // Storing actual source path
  if directoryexists(Sourcepath) then
  begin
    dbs := TInstallDbScripts.Create;
    // dbx := TDbConnect.create;
    Writelog('DBConnect object created');
    dbc.DataBaseConnection();

    // Process structures based on dbtype
    Sourcepath := IncludeTrailingBackslash(Sourcepath) + databasetype;
    if not directoryexists(Sourcepath) then
    begin
      writeln;
      Writelog('No structures available for import from ' + Sourcepath);
      Console_Write('   - No structures available for import.', 5);
      writeln;
      Exit; //
    end;
    // folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
    // foldercount := Length(folderArray);
    // for Y := 0 to foldercount - 1 do
    // begin
    // fldpath := folderArray[Y];
    StructureArray := TArray<string>(TDirectory.GetFiles(Sourcepath));

    structurecount := Length(StructureArray);
    for Z := 0 to structurecount - 1 do
    begin
      try
        if lowercase('Before_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z])) then
        begin
          writeln;
          Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) +
            ' script.', 5);
          writeln;
          Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
          dbs.ExecuteSQLFile(StructureArray[Z]);
        end;
      Except
        on E: Exception do
        begin
          ReadErrorList(E.Message);
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
          Writelog('Error : ' + E.Message);
        end;

      end;
    end;
    imps := TImportStructures.Create;
    for Z := 0 to structurecount - 1 do
    begin
      // writeln;

      try
        begin
          // writeln(StructureArray[Z]);
          Writelog('Importing structure ' + ExtractFileName(StructureArray[Z]));
          imps.ImportStructure(StructureArray[Z]);

        end;
      except
        on E: Exception do
        begin
          ReadErrorList(E.Message);
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
          Writelog('Error : ' + E.Message);
        end;

      end;
    end;
    addinstruct := True;
    for Z := 0 to structurecount - 1 do
    begin
      try
        spath := StructureArray[Z];
        sfilename := ExtractFileName(spath);
        (*if Pos('data_migration_', lowercase(sfilename)) = 1 then
        begin
          Writelog('processing ' + sfilename);
          dpath := Extractfilepath(spath);
          // updatedpatchstr := StringReplace(selectedpatch, '/', '\',
          // [rfReplaceAll, rfIgnoreCase]);
          dpath := dpath + 'ManualActionRequired\';
          if ForceDirectories(dpath) then
          begin
            if addinstruct then
            begin

              // writeln('  -' + dpath + ' created.');
              slUserInstructions.Add(selectedVersion + ' base is ready;' +
                'before applying the patches, please manually execute the data migration scripts '
                + '(Data_Migration_<Version>.sql) according to your current version. ');
              slUserInstructions.Add
                ('Data_Migration_<Version>.sql can be found at ' + dpath + '.');

              addinstruct := False;
            end;
            dpath := dpath + '\' + sfilename;
            // destpath := destpath + '\ManualActionRequired\' + selectedpatch + '\'+sFilename;
          end
          else
          begin
            writeln('Unable to create ' + dpath);
            dpath := dpath + '\ManualActionRequired_' + selectedpatch + '_' +
              sfilename;
          end;
          if not CopyFile(PChar(spath), PChar(dpath), False) then
            // RaiseLastOSError;
            Writelog(dpath + ' was not copied. Please refer to ' + spath)
            // Need to improvise it
          else
            Writelog(sfilename + ' file placed at ' + dpath);
        end
        else*) if lowercase('After_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z])) then
        begin
          writeln;
          Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) +
            ' script.', 5);
          writeln;
          Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
          dbs.ExecuteSQLFile(StructureArray[Z]);
        end
       { else if (extractfileext(lowercase(StructureArray[Z])) = '.sql') and
          not(lowercase('Before_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z]))) then }
        else if (extractfileext(lowercase(StructureArray[Z])) = '.sql') and
          not SameText(ExtractFileName(StructureArray[Z]), 'Before_import_Script.sql') and
          not (Pos('data_migration_', LowerCase(ExtractFileName(StructureArray[Z]))) = 1) then
        begin
          writeln;
          Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) +
            ' script.', 5);
          writeln;
          Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
          dbs.ExecuteSQLFile(StructureArray[Z]);
        end;
      Except
        on E: Exception do
        begin
          ReadErrorList(E.Message);
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
          Writelog('Error : ' + E.Message);
        end;

      end;
    end;
    Writelog('InstallAxpertStructureFiles function ends...');

    SourceVersionNo := LowerCase(Trim(currentversionname));
    if Pos('version', SourceVersionNo) = 1 then
      SourceVersionNo := Trim(StringReplace(SourceVersionNo, 'version', '', []));

    addinstruct := True;

    for Z := 0 to structurecount - 1 do
    begin
      try
        sfilename := LowerCase(ExtractFileName(StructureArray[Z]));

        if Pos('data_migration_', sfilename) = 1 then
        begin
          // 10.x Migration
          if ((Pos('10.', SourceVersionNo) = 1) and
              (LowerCase(sfilename) = 'data_migration_10x.sql')) then
          begin
            Console_Write('   - Executing 10.x migration script: ' + sfilename, 5);
            Writelog('Executing 10.x migration script: ' + sfilename);
            dbs.ExecuteSQLFile(StructureArray[Z]);

            break;
          end

          // 11.x Migration
          else if ((Pos('11.', SourceVersionNo) = 1) and
            (LowerCase(sfilename) = 'data_migration_11x.sql')) then
          begin
            Console_Write('   - Executing 11.x migration script: ' + sfilename, 5);
            Writelog('Executing 11.x migration script: ' + sfilename);
            dbs.ExecuteSQLFile(StructureArray[Z]);

            if addinstruct then
            begin
              slUserInstructions.Add(' ');
              slUserInstructions.Add('===== MANUAL DATA MIGRATION REQUIRED FOR 11.x UPGRADE =====');
              slUserInstructions.Add('The following AXDEF-related tables must be migrated manually from your 11.x environment:');
              slUserInstructions.Add('  - axvarcore');
              slUserInstructions.Add('  - axp_customdatatype');
              slUserInstructions.Add('  - axpdef_language');
              slUserInstructions.Add('  - tstructscripts');
              slUserInstructions.Add('  - iviewscripts');
              slUserInstructions.Add(' ');
              slUserInstructions.Add('Execute the following SQL scripts in the 11.4 runtime database after patch installation.');
              slUserInstructions.Add('Replace placeholders {runschema}, {defschema}, and {axdef} with appropriate schema names.');
              slUserInstructions.Add(' ');
              slUserInstructions.Add('--- Execute only if using 11.x Postgres AXDEF schema ---');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('insert into {runschema}.axvarcore select * from {defschema}.axvarcore;');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('insert into axp_customdatatype(axp_customdatatypeid,cancel,sourceid,mapname,username,modifiedon,createdby,createdon,typename,datatype,width,dwidth,isactive)');
              slUserInstructions.Add('select axp_customdatatypeid,cancel,sourceid,mapname,username,modifiedon,createdby,createdon,typename,datatype,width,dwidth,isactive');
              slUserInstructions.Add('from {axdef}.axp_customdatatype;');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('insert into {runschema}.axpdef_language select * from {defschema}.axpdef_language;');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('insert into {runschema}.tstructscripts(username,createdon,createdby,modifiedon,modifiedby,stransid,control_type,"event","type","name",caption,script)');
              slUserInstructions.Add('select createdby,createdon,createdby,modifiedon,username,stransid,control_type,"type","event",name,caption,');
              slUserInstructions.Add('case when control_type=''T'' then exp_editor_fcscript else exp_editor_script end');
              slUserInstructions.Add('from {defschema}.axpdef_script;');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('insert into {runschema}.iviewscripts(username,createdon,createdby,modifiedon,modifiedby,iname,"event","type","name",caption,script)');
              slUserInstructions.Add('select createdby,createdon,createdby,modifiedon,username,iname,"event",stype,"name",caption,exp_editor_script');
              slUserInstructions.Add('from {defschema}.dwb_iviewscripts;');
              slUserInstructions.Add(' ');

              slUserInstructions.Add('==========================================================');
              slUserInstructions.Add(' ');

              addinstruct := False;
            end;
            break;
          end;
        end;
      except
        on E: Exception do
        begin
          ReadErrorList(E.Message);
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while executing migration script ' +
            ExtractFileName(StructureArray[Z]));
          Writelog('Error : ' + E.Message);
        end;
      end;
    end;

  end

  else
  begin
    writeln;
    Console_Write('   - No structures available for import.', 5);
    writeln;
    Writelog('No structures available for import from ' + Sourcepath);
  end;

end;

(*
  commented on 04-08-2025 , backup code applied
  function TPatchInstallation.InstallAxpertStructureFiles(Sourcepath: string;
  isRuntime: Boolean = False): String;
  var
  fileArray, folderArray: TArray<string>;
  StructureArray: TStringDynArray;
  filecount, structurecount, foldercount, X, Y, Z: Integer;
  fldpath, actualSourcePath: string;
  dbs: TInstallDbScripts;
  imps: TImportStructures;
  dbx: TDbConnect;
  begin
  if (lowercase(currentversionname) <> 'version 11.3') and (Not isRuntime) then
  begin
  Writelog('InstallAxpertStructureFiles : Version 11.4 and above does not have a separate DB for Developer studio, so it is being skipped.');
  Exit;
  end;

  Writelog('InstallAxpertStructureFiles function started...');
  writeln;

  if isRuntime then
  Console_Write('  - Importing Runtime Axpert Structures:', 5)
  else
  Console_Write('  - Importing Developer studio Axpert Structures:', 5);
  writeln;

  if not DirectoryExists(Sourcepath) then
  begin
  Writelog('No structures available for import from ' + Sourcepath);
  writeln('    -No files available to process.');
  Exit;
  end;

  Console_Write('   - Importing form and report structures one by one.', 10);
  writeln;
  actualSourcePath := Sourcepath;

  if DirectoryExists(Sourcepath) then
  begin
  dbs := TInstallDbScripts.Create;
  Writelog('DBConnect object created');
  dbc.DataBaseConnection;

  Sourcepath := IncludeTrailingBackslash(Sourcepath) + databasetype;
  if not DirectoryExists(Sourcepath) then
  begin
  writeln;
  Writelog('No structures available for import from ' + Sourcepath);
  Console_Write('   - No structures available for import.', 5);
  writeln;
  Exit;
  end;

  StructureArray := TDirectory.GetFiles(Sourcepath);
  structurecount := Length(StructureArray);

  imps := TImportStructures.Create;

  for Z := 0 to structurecount - 1 do
  begin
  try
  if LowerCase(ExtractFileName(StructureArray[Z])) = 'after_import_script.sql' then
  begin
  writeln;
  Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) + ' script.', 5);
  writeln;
  Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
  dbs.ExecuteSQLFile(StructureArray[Z]);
  end
  else if (LowerCase(ExtractFileExt(StructureArray[Z])) = '.sql') and
  (LowerCase(ExtractFileName(StructureArray[Z])) <> 'before_import_script.sql') then
  begin
  writeln;
  Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) + ' script.', 5);
  writeln;
  Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
  dbs.ExecuteSQLFile(StructureArray[Z]);
  end;
  except
  on E: Exception do
  begin
  writeln('Error in ' + StructureArray[Z]);
  Writelog('Error while importing ' + ExtractFileName(StructureArray[Z]));
  Writelog('Error : ' + E.Message);
  end;
  end;
  end;

  Writelog('InstallAxpertStructureFiles function ends...');
  end
  else
  begin
  writeln;
  Console_Write('   - No structures available for import.', 5);
  writeln;
  Writelog('No structures available for import from ' + Sourcepath);
  end;
  end;

  // end;
  // fileArray := TArray<string>(TDirectory.GetFiles(sourcepath));
  // filecount:=length(fileArray);
  // writeln;
  // for X := 0 to filecount-1 do
  // begin
  //
  // if lowercase('Before_import_Script.sql')= lowercase(extractfilename(filearray[X])) then
  // begin
  // writeln;
  // Console_write('   - Executing '+extractfilename(filearray[X])+' script.', 5);
  // writeln;
  // dbs.ExecuteSQLFile(filearray[X]);
  // end;
  // end;
  //
  //
  // for X := 0 to filecount-1 do
  // begin
  // if lowercase('After_import_Script.sql')= lowercase(extractfilename(filearray[X])) then
  // begin
  // writeln;
  // Console_write('   - Executing '+extractfilename(filearray[X])+' script.', 5);
  // writeln;
  // dbs.ExecuteSQLFile(filearray[X]);
  // end
  // else
  // begin
  // writeln;
  // Console_write('   - Executing '+extractfilename(filearray[X])+' script.', 5);
  // writeln;
  // dbs.ExecuteSQLFile(filearray[X]);
  // end;
  // end;
  // end;



  // end;
*)

// As requested by QA,On 28/10/2025-Commenting this OLD ClearDirectoryContents function and replacing with NEW function to check for appsettings.json file in both Developer and ARM  Folders to handle them manually.

(* function ClearDirectoryContents(const DirPath: string): Boolean;
  var
  SearchRec: TSearchRec;
  FullPath: string;
  begin
  Result := False;

  if not DirectoryExists(DirPath) then
  raise Exception.CreateFmt('Directory not found: %s', [DirPath]);

  try
  if FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*', faAnyFile, SearchRec) = 0 then
  begin
  repeat
  if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
  begin
  FullPath := IncludeTrailingPathDelimiter(DirPath) + SearchRec.Name;

  if (SearchRec.Attr and faDirectory) = faDirectory then
  begin
  // Recursively delete subdirectory
  if not ClearDirectoryContents(FullPath) then
  raise Exception.CreateFmt('Failed to clear subdirectory: %s', [FullPath]);

  if not RemoveDirectory(PChar(FullPath)) then
  raise Exception.CreateFmt('Failed to remove subdirectory: %s', [FullPath]);
  end
  else
  begin
  // Delete file
  if not DeleteFile(PChar(FullPath)) then
  raise Exception.CreateFmt('Failed to delete file: %s', [FullPath]);
  end;
  end;
  until FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
  end;

  Result := True;
  except
  on E: Exception do
  begin
  // Log or handle exception as needed
  Console_Write('Error: ' + E.Message, 12);
  Writelog('Error in ClearDirectoryContents function :' + E.Message);
  writeln;
  Result := False;
  end;
  end;
  end; *)

function IsDirectoryEmpty(const Dir: string): Boolean;
var
  SR: TSearchRec;
begin
  Result := True;
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        Result := False;
        Break;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;
function AnySkipFileExistsInDirectory( const pSkipFileList: TStringList; const pDirectoryPath: string ): Boolean;
var
  I: Integer;
  FullFileName: string;
begin
  Result := True;

  if not DirectoryExists(pDirectoryPath) then
    Exit;

  // Skip Securedata dir | We need to confirm whether this is required
  if DirectoryExists(IncludeTrailingPathDelimiter(pDirectoryPath) + 'SecureData') then
    Exit;

  for I := 0 to pSkipFileList.Count - 1 do
  begin
    FullFileName :=
      IncludeTrailingPathDelimiter(pDirectoryPath) + pSkipFileList[I];

    if FileExists(FullFileName) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function IsSecureDataFolder(pFileName: String): Boolean;
var
  tmpFilePath: String;
  tmpFolderName: string;
begin
  Result := False;

  tmpFilePath := ExtractFilePath(pFileName);
  tmpFolderName := ExtractFileName(ExcludeTrailingPathDelimiter(tmpFilePath));

  Result := LowerCase(tmpFolderName) = 'securedata';
end;

// ClearDirectoryContents
function ClearDirectoryContents(const DirPath: string): Boolean;
var
  SearchRec: TSearchRec;
  FullPath: string;
  SkipFolder: Boolean;
begin
  Result := False;

  if not directoryexists(DirPath) then
    raise Exception.CreateFmt('Directory not found: %s', [DirPath]);

  //  If this IS ManualActionRequired, do nothing at all
  if SameText(ExtractFileName(ExcludeTrailingPathDelimiter(DirPath)), 'ManualActionRequired') then
    Exit;

  // SkipFolder := FileExists(IncludeTrailingPathDelimiter(DirPath) + 'appsettings.json');
//  SkipFolder := FileExists(IncludeTrailingPathDelimiter(DirPath) +
//    'appsettings.json') or FileExists(IncludeTrailingPathDelimiter(DirPath) +
//    'appsettings.ini') or FileExists(IncludeTrailingPathDelimiter(DirPath) +
//    'web.config') or FileExists(IncludeTrailingPathDelimiter(DirPath) +
//    'service_key.json') or directoryexists(IncludeTrailingPathDelimiter(DirPath)
//    + 'SecureData');

  SkipFolder := AnySkipFileExistsInDirectory(SkipFileList, DirPath);

  try
    if FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*', faAnyFile,
      SearchRec) = 0 then
    begin
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          FullPath := IncludeTrailingPathDelimiter(DirPath) + SearchRec.Name;

            if (SearchRec.Attr and faDirectory) = faDirectory then
            begin
              // Skip SecureData folder completely
              if IsSecureDataFolder(FullPath) then
              begin
                Writelog('Skipping SecureData folder and its contents: ' + FullPath);
                Continue;
              end;

              // Skip ManualActionRequired folder entirely
              if SameText(SearchRec.Name, 'ManualActionRequired') then
                  Continue;
              (*// HARD SKIP SecureData folder completely for ARM
               if SameText(SearchRec.Name, 'SecureData') and
                   (Pos('axpertarm', LowerCase(DirPath)) <> 0) then
                begin
                  Writelog('SecureData folder skipped: ' + FullPath);

                  slUserInstructions.Add(
                    'Manual actions required: SecureData folder was not modified automatically.');
                  slUserInstructions.Add(
                    'Please review SecureData manually at: ' + FullPath);
                  Continue;
                end; *)

            //Recursively delete subdirectory
            if not ClearDirectoryContents(FullPath) then
              raise Exception.CreateFmt('Failed to clear subdirectory: %s',
                [FullPath]);

            // Only remove the subdirectory if it's not the one to skip
            if not SkipFolder then
            begin
//              if not RemoveDirectory(PChar(FullPath)) then
//                raise Exception.CreateFmt('Failed to remove subdirectory: %s',
//                  [FullPath]);
                if IsDirectoryEmpty(FullPath) then
                begin
                  // Remove directory after clearing
                  if not RemoveDirectory(PChar(FullPath)) then
                    raise Exception.CreateFmt('Failed to remove subdirectory: %s', [FullPath]);
                end;
                // else: directory contains ManualActionRequired ->silently keep it
            end;
          end
          else
          begin
            // Delete files except appsettings.ini,web.config,appsettings.json,service_key.json
//            if not(SameText(SearchRec.Name, 'appsettings.json') or
//              SameText(SearchRec.Name, 'appsettings.ini') or
//              SameText(SearchRec.Name, 'web.config') or SameText(SearchRec.Name,
//              'service_key.json')) then
//            begin
//              if not DeleteFile(PChar(FullPath)) then
//                raise Exception.CreateFmt('Failed to delete file: %s',
//                  [FullPath]);
//            end;
              // Delete file only if it is NOT in skip list
            if not IsFileInSkipList(SearchRec.Name) and not IsSecureDataFolder(FullPath) then
            begin
              if not DeleteFile(PChar(FullPath)) then
                raise Exception.CreateFmt('Failed to delete file: %s', [FullPath]);
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;

    Result := True;
  except
    on E: Exception do
    begin
      // Log or handle exception as needed
      ReadErrorList(E.Message);
      Console_Write('Error: ' + E.Message, 12);
      Writelog('Error in ClearDirectoryContents function :' + E.Message);
      writeln;
      Result := False;
    end;
  end;
end;

function CleanupArmAndInstall(const selectedversion, selectedpatch: string): Boolean;
var
  Version: Double;
  Release: Integer;
  CleanRelease: string;
  SlashPos: Integer;
begin
  Result := True; // default behavior (full cleanup)

  try
    Version := StrToFloatDef(StringReplace(selectedversion, 'Version', '', [rfIgnoreCase]), 0);
    CleanRelease := LowerCase(selectedpatch);
    SlashPos := Pos('/', CleanRelease);
    if SlashPos > 0 then
      CleanRelease := Copy(CleanRelease, SlashPos + 1, Length(CleanRelease));
    CleanRelease := StringReplace(CleanRelease, 'release', '', [rfIgnoreCase]);
    Release := StrToIntDef(Trim(CleanRelease), 0);

    if (Version >= 11.4) and (Release >= 43) then
      Result := False; // Specified files are replaced/added newly.

  except
    Result := False; // safe fallback(Full directory is not deleted,only selective files)
  end;
end;

function TPatchInstallation.InstallARMFiles(Sourcepath,
  destpath: string; bCleardir : boolean= False): String;
var
bApplyfiles : boolean;
begin

  Writelog('InstallARMFiles function started...');
    //Old Command used to remove the specific files and installs the new one.
    //FindFile(Sourcepath, destpath);

  (* As requested by the QA Team, adding the ClearDirectoryContents function to remove
    all existing files and replace with the new files from ARM Folder,
    as Team intends to provide a single ARM Folder with all changed files.

    If anyother enhancements required,Changes should be done with the InstallARMfiles calling points *)

  //Clearing ARM files is based on the version and release.
  //(Above Release32 in 11.4,only specified files are replaced and new files are cloned ---- Other version/release, complete directory is cleaned)

  if CleanupArmAndInstall(selectedversion, selectedpatch) then
  begin
    bApplyfiles := True;

    if bCleardir then
    begin
     Console_Write
      ('   - Existing ARM files are being cleared to prepare for the new update installation.',
      10);
     writeln;
     bApplyfiles := ClearDirectoryContents(destpath);
    end;

    if bApplyfiles then
    begin
      Writelog('FindFile function started...');
      FindFile(Sourcepath, destpath);
      Result := 'Success';
    end
    else
    begin
      writeln('    - Warning: Incomplete ARM Files update.');
      Result := 'Failed';
    end;
  end
  else
  begin
    Writelog('Changed Files and New Files in ARM are being placed.(ClearDirectory is not called)');
    writeln('   - Changed Files and New Files are being placed for the new installation. ');
    FindFile(Sourcepath, destpath);
    Result := 'Success';
  end;
  Writelog('InstallARMFiles function ends...');
end;

function TPatchInstallation.InstallPatchScriptFiles(Sourcepath,
  destpath: string; isRuntime: Boolean = False): string;
begin
  if {(lowercase(currentversionname) <> 'version 11.3')} (Not hasdefschema)and (Not isRuntime) then
  begin
    Writelog('InstallPatchScriptFiles : Version 11.4 and above does not have a separate script for Developer studio, so it is being skipped.');
    Exit;
  end;
  Writelog('InstallPatchScriptFiles function started...');
  writeln;
  if isRuntime then // run
    Console_Write('  - Installing Runtime Scripts:', 5)
  else // developer
    Console_Write('  - Installing Developer studio Scripts:', 5);
  writeln;
  if not directoryexists(Sourcepath) then
  begin
    Writelog('files are not available to process at ' + Sourcepath);
    writeln('    -No files available to process.');
    Exit;
  end;
  Console_Write
    ('   - Copying files to corresponding scriptolders from the local patch directory.',
    10);
  writeln;
  writeln;
  Writelog('FindFile function started..');
  FindFile(Sourcepath, destpath);
  Writelog('InstallPatchScriptFiles function ends');
end;
// Moving the Clear Directory Contents function before InstallARMFiles function at line 791 on 21-10-2025.

function TPatchInstallation.InstallPatchWebFiles(Sourcepath, destpath: string;
  isRuntime: Boolean = False): string;
var
  webpath: string;
  destinationPath: string;
  FileName: string;
begin
  // ForceDirectories(destpath + '\' + cWebFiles + '\');
  // webpath := localpath + '\' + cWebFiles + '\';
  Writelog('InstallPatchWebFiles function started..');
  writeln;
  if isRuntime then // runweb
    Console_Write('  - Installing Runtime Webfiles:', 5)
  else // developer web
    Console_Write('  - Installing Developer studio Webfiles:', 5);
  writeln;
  if not directoryexists(Sourcepath) then
  begin
    Writelog('No files available to process in ' + Sourcepath);
    writeln('    -No files available to process.');
    Exit;
  end;
  Console_Write
    ('   - Copying files to corresponding webfolders from the local patch directory.',
    10);
  writeln;
  writeln;
  (*
    If the version is 11.3 or a runtime, use direct file copy (existing logic).
    Else, as informed by the team (QA & Rakesh), for 11.4 webcode,
    we should delete old files before copying new ones.

    Note: 11.4 DevStudio doesn't have a separate 'script' folder,
    so we can skip the dev script process.
  *)

  if {(lowercase(currentversionname) = 'version 11.3')} hasdefschema or (isRuntime) then
    FindFile(Sourcepath, destpath)
  else // 11.4 and above and Dev web
  begin
    // for 11.4
    Console_Write
      ('   - Existing Developer Studio files are being cleared to prepare for the new update installation.',
      10);
    writeln;
    if ClearDirectoryContents(destpath) then
      FindFile(Sourcepath, destpath)
    else
      writeln('    - Warning: Incomplete WebFiles update in Developer Studio.');
  end;
  Writelog('InstallPatchWebFiles function ends..');
  // FindFolder(localpath);
end;

function TPatchInstallation.FindFile(Sourcepath, destpath: string): string;
var
  fileArray: TArray<string>;
  folderArray: TArray<string>;
  SearchRec: TSearchRec;
  fulldestpath, fullsourcepath: string;
  filecount, foldercount, I, Z: Integer;
  // destpath: string;
  foldername: string;
  dbx: TDbConnect;
  dbs: TInstallDbScripts;
  sfilename: string;

begin
  try

    fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
    filecount := Length(fileArray);
    if filecount > 0 then
    begin
      if FindFirst(Sourcepath + '*.*', faAnyFile, SearchRec) = 0 then
      begin
        fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
        filecount := Length(fileArray);
        for I := 0 to filecount - 1 do
        begin
          // if FolderName = '' then
          // begin
          sfilename := ExtractFileName(fileArray[I]);
          destpath := destpath + '\' + sfilename;
          ReadFile(fileArray[I], destpath);
          if lowercase(extractfileext(destpath)) = '.sql' then
          begin
            dbs := TInstallDbScripts.Create;
            // dbx may not be required | remove this after checking
            dbx := TDbConnect.Create;
            Writelog('DBConnect object created');
            dbx.DataBaseConnection();
            Writelog('Executing ' + ExtractFileName(destpath));
            dbs.ExecuteSQLFile(destpath);
            Writelog(ExtractFileName(destpath) + ' Executed successfully..');
          end;
          destpath := ExtractFiledir(destpath);
        end;
        folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
        foldercount := Length(folderArray);
        if foldercount > 0 then
          for Z := 0 to foldercount - 1 do
          begin
            ForceDirectories(destpath + '\' + ExtractFileName(folderArray[Z]));
            fullsourcepath := Sourcepath + '\' +
              ExtractFileName(folderArray[Z]);
            fulldestpath := destpath + '\' + ExtractFileName(folderArray[Z]);
            FindFile(fullsourcepath, fulldestpath);
          end;


        // end
        // else
        // begin
        // ReadFile(fileArray[I], destpath + FolderName + '\\' +
        // extractFileName(fileArray[I]));
        // end;

        // DestPath := runwebcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
        // ForceDirectories(DestPath + '\\' + cWebFiles + '\\');
        // destpath := destpath + '\\' + cWebFiles + '\\';
        // FolderName := extractFileName(Sourcepath);

      end;
    end
    else
    begin
      folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
      foldercount := Length(folderArray);
      for I := 0 to foldercount - 1 do
      begin
        fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
        fulldestpath := TRegEx.Replace(fulldestpath + '\' +
          ExtractFileName(folderArray[I]), '\\+', '\');
        // TPath.Combine(destpath, extractFileName(folderArray[I]));
        ForceDirectories(fulldestpath);
        fullsourcepath := TRegEx.Replace(Sourcepath, '\\+', '\');
        fullsourcepath := TRegEx.Replace(fullsourcepath + '\' +
          ExtractFileName(folderArray[I]), '\\+', '\');
        FindFile(fullsourcepath, fulldestpath);
      end;
    end;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_Write('Error: ' + E.Message, 12);
      Writelog('Error in FindFile funtion while processing ' +
        ExtractFileName(Sourcepath) + ' file');
      Writelog('Error : ' + E.Message);
      writeln;
      readln;
    end;
  end;
end;

// function TPatchInstallation.FindFolder(path: string): string;
// var
// folderArray: TArray<string>;
// foldercount, I: integer;
// searchRec: TSearchRec;
// destinationPath: string;
// begin
// try
// if not DirectoryExists(path) then
// begin
// writeln;
// writeln('  - Webfiles are not available for ' + selectedPlugin);
// Exit;
// end;
//
// folderArray := TArray<string>(TDirectory.GetDirectories(path));
// destinationPath := runwebcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
// ForceDirectories(destinationPath + '\\' + cWebFiles + '\\');
// destinationPath := destinationPath + '\\' + cWebFiles + '\\';
// foldercount := Length(folderArray);
// for I := 0 to foldercount - 1 do
// begin
// ForceDirectories(destinationPath + ExtractFileName(folderArray[I]));
// // FindFile(path + extractFileName(folderArray[I]));
// end;
//
// // CopyFilesRecursively('D:\Workspace\install_plugin\Win64\Debug\Plugin\Plugin1','C:\Users\paroksh.AGILELABS\Desktop\PluginWeb\Plugin\Plugin1\Webfiles');
// // Readln;
// except
// on E: Exception do
// begin
// Console_write('Error: ' + E.Message, 12);
// writeln;
// readln;
// end;
// end;
// end;
// ReadFile - Copy file from source to destination
function TPatchInstallation.ReadFile(Sourcepath, destpath: string): string;
var
  DisplayDestPath, sfilename, sParentDirname, patc: string;
  ParentPath: string;
  backuppath: string;
  updatedpatchstr: String;
begin
  try
     writelog('ReadFile function started..');
    // Normalize destination path
    destpath := TRegEx.Replace(destpath, '\\+', '\');

    // Ensure the parent directory of the destination path exists
    ParentPath := ExtractFiledir(destpath);
    if not directoryexists(ParentPath) then
    begin
      ForceDirectories(ParentPath);
      Writelog('Creating ' + ParentPath);
    end;
    patc := StringReplace(selectedpatch, '/', '\',
      [rfReplaceAll, rfIgnoreCase]);
    // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
    // backuppath :=getcurrentdir+'\backup\patches\'+projectname+'\'+patc;
    // only for web.config  we moved file to manualactionrequired folder
    // as we cannot replace / overwrite the web.config , which leads to abnormal behaviour
    // sFilename := ExtractFileName(Sourcepath);
    sfilename := ExtractFileName(Sourcepath);

    // Check for Files is in SkipList(manual action required)
    if IsFileInSkipList(sfilename) then
    begin
      Writelog('processing ' + sfilename + ' file.');

      destpath := ExtractFilePath(destpath);

      updatedpatchstr := StringReplace(selectedpatch, '/', '\',
        [rfReplaceAll, rfIgnoreCase]);

      destpath := destpath + 'ManualActionRequired\' + updatedpatchstr;

      if ForceDirectories(destpath) then
      begin
        writeln('   - ' + destpath + ' created.');

        // Copy skipped file to ManualActionRequired
        CopyFile(
          PChar(Sourcepath),
          PChar(destpath + '\' + sfilename),
          False   // allow overwrite inside ManualActionRequired
        );

        slUserInstructions.Add(' Manual actions required:');
        slUserInstructions.Add(
          'Some files contain custom settings and were not automatically updated by the AxInstaller.'
        );
        slUserInstructions.Add(
          'Please review and apply the necessary changes manually as described in:'
        );
        slUserInstructions.Add(destpath + '\' + sfilename);

        Writelog(sfilename + ' file placed at ' + destpath + '\' + sfilename);
      end
      else
      begin
        writeln('Unable to create ' + destpath);
        Writelog('Failed to create ManualActionRequired folder for ' + sfilename);
      end;

      Exit;
    end;

    (*if (lowercase(sfilename) = 'appsettings.json') and
      ((Pos('axpertarm', lowercase(Sourcepath)) <> 0) or
      (Pos('developer', lowercase(Sourcepath)) <> 0)) then
    begin
      Writelog('processing appsettings.json file.');
      destpath := Extractfilepath(destpath);
      sParentDirname := ExtractFiledir
        (ExcludeTrailingPathDelimiter(Sourcepath));
      sParentDirname := ExtractFileName(sParentDirname);
      updatedpatchstr := StringReplace(selectedpatch, '/', '\',
        [rfReplaceAll, rfIgnoreCase]);
      destpath := destpath + 'ManualActionRequired\' +
        updatedpatchstr { +'\'+sParentDirname };
      if ForceDirectories(destpath) then
      begin
        writeln('   - ' + destpath + ' created.');
        slUserInstructions.Add('The ' + selectedpatch +
          ' includes appsettings.json changes and they must be applied manually.');
        destpath := destpath + '\' + sfilename;
        slUserInstructions.Add('appsettings.json can be found at ' +
          destpath + '.');
        Writelog('appsettings.json file placed at ' + destpath);
        // destpath := destpath + '\ManualActionRequired\' + selectedpatch + '\'+sFilename;
      end
      else
      begin
        writeln('Unable to create ' + destpath);
        destpath := destpath + '\ManualActionRequired_' + selectedpatch + '_' +
          sParentDirname + '_' + sfilename;
      end;

    end;

    if (lowercase(sfilename) = 'web.config') and
      (not(Pos('axpertarm', lowercase(Sourcepath)) <> 0) or
      not(Pos('developer', lowercase(Sourcepath)) <> 0)) then
    begin
      Writelog('processing web.config file.');
      destpath := Extractfilepath(destpath);
      updatedpatchstr := StringReplace(selectedpatch, '/', '\',
        [rfReplaceAll, rfIgnoreCase]);
      destpath := destpath + 'ManualActionRequired\' + updatedpatchstr;
      if ForceDirectories(destpath) then
      begin
        writeln('  -' + destpath + ' created.');
        slUserInstructions.Add('The ' + selectedpatch +
          ' includes web.config changes and they must be applied manually.');
        destpath := destpath + '\' + sfilename;
        slUserInstructions.Add('web.config can be found at ' + destpath + '.');
        Writelog('web.config file placed at ' + destpath);
        // destpath := destpath + '\ManualActionRequired\' + selectedpatch + '\'+sFilename;
      end
      else
      begin
        writeln('Unable to create ' + destpath);
        destpath := destpath + '\ManualActionRequired_' + selectedpatch + '_' +
          sfilename;
      end;
    end;

    if ((lowercase(sfilename) = 'appsettings.ini') or
    (lowercase(sfilename) = 'service_key.json')) and
    {not}(Pos('axpertarm', lowercase(Sourcepath)) {<>} > 0) then
    begin
        Writelog('processing ' + sfilename + 'file.');
        destpath := Extractfilepath(destpath);
        updatedpatchstr := StringReplace(selectedpatch, '/', '\',
          [rfReplaceAll, rfIgnoreCase]);
        destpath := destpath + 'ManualActionRequired\' + updatedpatchstr;
        if ForceDirectories(destpath) then
        begin
          writeln('  -' + destpath + ' created.');
          slUserInstructions.Add('The ' + selectedpatch + ' includes ' +
            sfilename + 'changes and they must be applied manually.');
          destpath := destpath + '\' + sfilename;
          slUserInstructions.Add(sfilename + ' can be found at ' +
            destpath + '.');
          Writelog(sfilename + ' file placed at ' + destpath);
          // destpath := destpath + '\ManualActionRequired\' + selectedpatch + '\'+sFilename;
        end
        else
        begin
          writeln('Unable to create ' + destpath);
          destpath := destpath + '\ManualActionRequired_' + selectedpatch + '_'
            + sfilename;
        end
      end; *)

      // Copy the file using Windows API CopyFile
      if not CopyFile(PChar(Sourcepath), PChar(destpath), False) then
        RaiseLastOSError;

      // Prepare display path for output
      DisplayDestPath := StringReplace(destpath, '\\', '\', [rfReplaceAll]);

      // The below code many not required , since we are copying last chars using GetLast80CharsWithEllipsis
      if Pos('axpertreleases', lowercase(DisplayDestPath)) <> 0 then
      begin
        DisplayDestPath := Copy(DisplayDestPath,
          Pos('axpertreleases', lowercase(DisplayDestPath)) +
          Length('axpertreleases'), Length(DisplayDestPath) -
          Pos('axpertreleases', lowercase(DisplayDestPath)) -
          Length('axpertreleases') + 1);
      end;
      // if pos('axpertdeveloper',lowercase(DisplayDestPath))<>0 then
      // begin
      // DisplayDestPath := Copy(DisplayDestPath,
      // Pos('axpertdeveloper', lowercase(DisplayDestPath)) + Length('axpertdeveloper'),
      // Length(DisplayDestPath) - Pos('axpertdeveloper', lowercase(DisplayDestPath)) -
      // Length('axpertdeveloper') + 1);
      // end;
      // if pos('axpertarm',lowercase(DisplayDestPath))<>0 then
      // begin
      // DisplayDestPath := Copy(DisplayDestPath,
      // Pos('axpertarm', lowercase(DisplayDestPath)) + Length('axpertarm'),
      // Length(DisplayDestPath) - Pos('axpertarm', lowercase(DisplayDestPath)) -
      // Length('axpertarm') + 1);
      // end;

      // GetLast80CharsWithEllipsis
      DisplayDestPath := GetLast80CharsWithEllipsis(DisplayDestPath);

      Write('   - Placing file ');
      DisplayDestPath := StringReplace(DisplayDestPath, '\\', '\',
        [rfReplaceAll]);
      Console_Write(ExtractFileName(Sourcepath) + ' ', 10);
      Write('in ...' + DisplayDestPath);
      writeln;

    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        Console_Write('Error: ' + E.Message, 12);
        Writelog('Error in Readfile function :' + E.Message);
        Writelog('Error while copying file from ' + Sourcepath + 'to ' +
          destpath);
        writeln;
        readln;
      end;
    end;
  end;

  // function TPatchInstallation.createbackup(sourcepath:string):string;
  // var
  // destpath,patc:string;
  // folderArray: TArray<string>;
  // begin
  // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
  // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc;
  // destpath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
  // folderArray := TArray<string>(TDirectory.GetDirectories(sourcepath));
  // foldercount := Length(folderArray);
  // if foldercount>0 then
  // begin
  // for I := 0 to foldercount - 1 do
  // begin
  //
  // end;
  // end;
  //
  //
  // destpath := runwebcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
  // ForceDirectories(destpath + '\\' + cWebFiles + '\\');
  // destpath := destpath + '\\' + cWebFiles + '\\';
  // foldercount := Length(folderArray);
  // for I := 0 to foldercount - 1 do
  // end;

  // function TPatchInstallation.findfolder(sourcepath:string;destpath:string):string;
  // var
  // folderArray: TArray<string>;
  //
  // outerfilearray,fileArray:TArray<string>;
  // filecount,foldercount,I:integer;
  // fulldestpath,fullsourcepath:String;
  // begin
  // outerfilearray:=TArray<string>(TDirectory.GetFiles(sourcepath));
  // filecount:= Length(outerfilearray);
  // if filecount>0 then
  // begin
  // fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
  // fulldestpath := TRegEx.Replace(fulldestpath + '\' +
  // ExtractFileName(outerfilearray[I]), '\\+', '\');
  // if not CopyFile(PChar(outerfilearray[I]), PChar(fulldestpath), False) then
  // RaiseLastOSError;
  // end;
  // folderArray := TArray<string>(TDirectory.GetDirectories(sourcepath));
  // foldercount := Length(folderArray);
  // if foldercount>0 then
  // begin
  // for I := 0 to foldercount - 1 do
  // begin
  // fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
  // fulldestpath := TRegEx.Replace(fulldestpath + '\' +
  // ExtractFileName(folderArray[I]), '\\+', '\');
  // // TPath.Combine(destpath, extractFileName(folderArray[I]));
  // if not fileexists(fulldestpath) then
  // ForceDirectories(fulldestpath);
  //
  // fullsourcepath := TRegEx.Replace(Sourcepath, '\\+', '\');
  // fullsourcepath := TRegEx.Replace(fullsourcepath + '\' +
  // ExtractFileName(folderArray[I]), '\\+', '\');
  // findfolder(fullsourcepath,fulldestpath);
  // end;
  // end;
  // if foldercount=0 then
  // begin
  // fileArray := TArray<string>(TDirectory.GetFiles(sourcepath));
  // filecount := Length(fileArray);
  // if filecount>0 then
  // begin
  // for I := 0 to filecount - 1 do
  // begin
  // fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
  // fulldestpath := TRegEx.Replace(fulldestpath + '\' +
  // ExtractFileName(Filearray[I]), '\\+', '\');
  // if not CopyFile(PChar(Filearray[I]), PChar(fulldestpath), False) then
  // RaiseLastOSError;
  // end;
  // end;
  //
  // end;
  // end;

  // ReadFile existing work code - but it was not handled with UTF8
  (*
    function TPatchInstallation.ReadFile(Sourcepath: string;
    destpath: string): string;
    var
    copiedfile: TextFile;
    FileContent: string;
    parentpath: string;
    displayDestPath: string;
    begin
    try
    FileContent := TFile.ReadAllText(Sourcepath);
    destpath := TRegEx.Replace(destpath, '\\+', '\');
    parentpath := ExtractFiledir(destpath);
    if not fileexists(parentpath) then
    ForceDirectories(parentpath);
    // destpath:=TRegEx.Replace(destpath+'\'+extractFileName(folderArray[I]), '\\+', '\');
    AssignFile(copiedfile, destpath);
    Rewrite(copiedfile);
    writeln(copiedfile, FileContent);
    CloseFile(copiedfile);
    displayDestPath := stringreplace(destpath, '\\', '\', [rfReplaceAll]);
    displayDestPath := Copy(displayDestPath,
    pos('AxpertPatches', displayDestPath) + Length('AxpertPatches'),
    Length(displayDestPath) - pos('AxpertPatches', displayDestPath) -
    Length('AxpertPatches') + 1);
    write('   - Placing file ');
    displayDestPath := stringreplace(displayDestPath, '\\', '\',
    [rfReplaceAll]);
    Console_write(ExtractFileName(Sourcepath) + ' ', 10);
    write('in ...' + displayDestPath);
    writeln;
    except
    on E: Exception do
    begin
    Console_write('Error: ' + E.Message, 12);
    writeln;
    readln;
    end;
    end;
    end;
  *)

end.
