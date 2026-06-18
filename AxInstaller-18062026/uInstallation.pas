unit uInstallation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  IdAuthentication,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, IdMultipartFormData,
  StrUtils, System.RegularExpressions,
  System.IOUtils, System.Types, System.Generics.Collections, DBXJSON,
  DB, DBClient, uAxLog,
  SimpleDS, Provider, SqlExpr, DBXCommon, DBXOracle, uImportStructures,
  uGitManager, uInstallDbScripts, uInstallRMQClients, uImportDefinition, uInstallPluginScripts;

type
  TInstallation = class
  private
    function FindFileNew(Sourcepath, destpath: string): string;
    function InstallWebFilesNew(webfilepath, dstPath: string): string;

  public
    function InstallPlugin(Plugin: string): string;
    function InstallWebFiles(webfilepath: string; dstPath: string): string;
//    function InstallAxpertStructureFiles: String;
    function InstallAxpertStructures(): string;
    function ExecuteDBScripts(): string;
    function InstallRMQClient(): string;
    function ReadFile(Sourcepath: string; destpath: string): string;
    function FindFile(Sourcepath: string): string;
    function FindFolder(path: string): string;
    Function CompletionStatus(): string;
    function IsPublicInfoFound(): String;
    function createpluginjson(): String;
    function Readplugininfo(nameofplugin: string): String;
    function AddPlugin(): TJSONObject;
    function pluginUpdate(): String;
    function InstallPluginScripts(): string;
//    function InstallAxpertStructureFiles(Sourcepath: string; isRuntime: Boolean = False): String;

  end;

implementation

uses uUtils{,uDBConnect};

function TInstallation.InstallPlugin(Plugin: string): string;
// plugin=selectedplugin
var
  dpath: string;
begin
  // pluginLocalPath:=curdir+'\Plugin\';
  writeln;
  Console_write('2. Starting Plugin Installation:', 3);
  writeln;
  // ForceDirectories(dpath+selectedPlugin);
  dpath := runwebcodepath { + '\\' + selectedPlugin };
  // InstallWebFiles(patchLocalPath +'OfficialReleases\Plugins\'+ selectedPlugin, dpath);

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024

  // InstallWebFilesNew(patchLocalPath +'OfficialReleases\Plugins\'+ selectedPlugin, dpath);

  (*
    21/11/2024 - As discussed with sab sir, we are follwoing the below structure as
    git structure  for plugins
    Repo/PluginName<Version optional>

    Accordingly changing the code here.
  *)
  // InstallWebFilesNew(patchLocalPath +'Plugins\'+ selectedPlugin, dpath);

  InstallWebFilesNew({patchLocalPath}pluginLocalPath + selectedPlugin, dpath);
  writeln;
  // selectedPlugin;
  // pluginLocalPath;//C:\Users\paroksh.AGILELABS\Desktop\Git_plugin\Plugin\
end;

// FindFileNew
function TInstallation.FindFileNew(Sourcepath, destpath: string): string;
var
  fileArray: TArray<string>;
  folderArray: TArray<string>;
  searchRec: TSearchRec;
  fulldestpath, fullsourcepath: string;
  filecount, foldercount, I, Z: integer;
  //destpath: string;
  FolderName: string;
begin
  try
    fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
    filecount := Length(fileArray);
    if filecount > 0 then
    begin
      if FindFirst(Sourcepath + '*.*', faAnyFile, searchRec) = 0 then
      begin
        fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
        filecount := Length(fileArray);
        for I := 0 to filecount - 1 do
        begin
          // if FolderName = '' then
          // begin
          destpath := destpath + '\' + ExtractFileName(fileArray[I]);
          ReadFile(fileArray[I], destpath);
          destpath := ExtractFiledir(destpath);
        end;
        folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
        foldercount := Length(folderArray);
        if foldercount > 0 then
          for Z := 0 to foldercount - 1 do
          begin
            // CustomPages routed directly to runwebcodepath\CustomPages\
            if ExtractFileName(folderArray[Z]) = cCustomPages then
            begin
              writelog('CustomPages is placed in : ' + runwebcodepath + '\' + cCustomPages);
              fulldestpath := TRegEx.Replace(runwebcodepath + '\' + cCustomPages, '\\+', '\');
              ForceDirectories(fulldestpath);
              fullsourcepath := Sourcepath + '\' + ExtractFileName(folderArray[Z]);
              FindFileNew(fullsourcepath, fulldestpath);
            end
            else
            begin
              ForceDirectories(destpath + '\' + ExtractFileName(folderArray[Z]));
              fullsourcepath := Sourcepath + '\' + ExtractFileName(folderArray[Z]);
              fulldestpath := destpath + '\' + ExtractFileName(folderArray[Z]);
              FindFileNew(fullsourcepath, fulldestpath);
            end;
          end;
      end;
    end
    else
    begin
      folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
      foldercount := Length(folderArray);
      for I := 0 to foldercount - 1 do
      begin
        // CustomPages routed directly to runwebcodepath\CustomPages\
        if ExtractFileName(folderArray[I]) = cCustomPages then
        begin
          writelog('CustomPages is placed in: ' + runwebcodepath + '\' + cCustomPages);
          fulldestpath := TRegEx.Replace(runwebcodepath + '\' + cCustomPages, '\\+', '\');
          ForceDirectories(fulldestpath);
          fullsourcepath := TRegEx.Replace(Sourcepath + '\' + ExtractFileName(folderArray[I]), '\\+', '\');
          FindFileNew(fullsourcepath, fulldestpath);
        end
        else
        begin
        fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
        fulldestpath := TRegEx.Replace(fulldestpath + '\' +
          ExtractFileName(folderArray[I]), '\\+', '\');
        // TPath.Combine(destpath, extractFileName(folderArray[I]));
        ForceDirectories(fulldestpath);
        fullsourcepath := TRegEx.Replace(Sourcepath, '\\+', '\');
        fullsourcepath := TRegEx.Replace(fullsourcepath + '\' +
          ExtractFileName(folderArray[I]), '\\+', '\');
        FindFileNew(fullsourcepath, fulldestpath);
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writelog('Error in FindFileNew funtion while processing ' +
        ExtractFileName(Sourcepath) + ' file');
      writelog('Error : ' + E.Message);
      writeln;
      readln;
    end;
  end;
end;

function TInstallation.InstallWebFilesNew(webfilepath: string;
  dstPath: string): string;
var
  webpath: string;
  destinationPath: string;
  Filename: string;
begin
  // ForceDirectories(dstPath + '\\' + cWebFiles + '\\');
  webpath := webfilepath + '\' { + cWebFiles + '\\' };
  // GETCURRENTDIRECTORY OR EXELOCATION
  Console_write('  - Installing Plugin: ' +selectedplugin, 5);
  writeln;
  Console_write
    ('   - Copying files to corresponding Plugin folders from the GIT download directory.',
    10);
  writeln;
  writeln;

  destinationPath := runwebcodepath + '\' + cPlugins + '\' + selectedPlugin;
  // destinationPath := destinationPath + '\' + cWebFiles + '\';
  destinationPath := TRegEx.Replace(destinationPath, '\\+', '\');
  ForceDirectories(destinationPath);
  destinationPath := IncludeTrailingBackslash(destinationPath);

  FindFileNew(webpath, destinationPath);

end;

function TInstallation.InstallWebFiles(webfilepath: string;
  dstPath: string): string;
var
  webpath: string;
  destinationPath: string;
  Filename: string;
begin
  // ForceDirectories(dstPath + '\\' + cWebFiles + '\\');
  webpath := webfilepath + '\\' { + cWebFiles + '\\' };
  // GETCURRENTDIRECTORY OR EXELOCATION
  Console_write('  - Installing Webfiles:', 5);
  writeln;
  Console_write
    ('   - Copying files to corresponding webfolders from the local plugin directory.',
    10);
  writeln;
  writeln;
  FindFile(webpath);
  FindFolder(webpath);
end;


(*
function TInstallation.InstallAxpertStructureFiles(): String;
var
  fileArray, folderArray: TArray<string>;
  StructureArray: TArray<string>;
  filecount, structurecount, foldercount, X, Y, Z: Integer;
  fldpath, actualSourcePath, AxStruPath: string;
  dbs: TInstallDbScripts;
  imps: TImportStructures;
  dbx: TDbConnect;
begin
  // if not fileexists(Sourcepath) then
  // forcedirectories(Sourcepath);

  Writelog('InstallAxpertStructureFiles function started...');
  writeln;

  AxStruPath := patchLocalPath +  selectedPlugin + '\' +
      cAxpertStructures + '\';

  Console_write('  - Importing Axpert Structures:', 5);
  writeln;
  Console_write
    ('   - Finding form and report-related structure files for import.', 10);
  if not directoryexists(AxStruPath) then
  begin
    Writelog('No structures available for import from ' + AxStruPath);
    writeln('    -No files available to process.');
    Exit;
  end;
  Console_Write('   - Importing form and report structures one by one.', 10);
  writeln;
  actualSourcePath := AxStruPath; // Storing actual source path
  if directoryexists(AxStruPath) then
  begin
    dbs := TInstallDbScripts.Create;
    // dbx := TDbConnect.create;
    Writelog('DBConnect object created');
    dbc.DataBaseConnection();

    // Process structures based on dbtype
    AxStruPath := IncludeTrailingBackslash(AxStruPath) + databasetype;
    if not directoryexists(AxStruPath) then
    begin
      writeln;
      Writelog('No structures available for import from ' + AxStruPath);
      Console_Write('   - No structures available for import.', 5);
      writeln;
      Exit; //
    end;
    // folderArray := TArray<string>(TDirectory.GetDirectories(Sourcepath));
    // foldercount := Length(folderArray);
    // for Y := 0 to foldercount - 1 do
    // begin
    // fldpath := folderArray[Y];
    StructureArray := TArray<string>(TDirectory.GetFiles(AxStruPath));

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
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
          Writelog('Error : ' + E.Message);
        end;

      end;
    end;

    for Z := 0 to structurecount - 1 do
    begin
      try
        if lowercase('After_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z])) then
        begin
          writeln;
          Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) +
            ' script.', 5);
          writeln;
          Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
          dbs.ExecuteSQLFile(StructureArray[Z]);
        end
        else if (extractfileext(lowercase(StructureArray[Z])) = '.sql') and
          not(lowercase('Before_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z]))) then
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
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
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
    Writelog('No structures available for import from ' + AxStruPath);
  end;

end;
*)

function TInstallation.InstallAxpertStructures(): string;
var
  AxStruPath: string;
  path: string;
  FolderList: TStringDynArray;
  FileList: TStringDynArray;
  I, filecount, Count: integer;
  FolderName: string;
  fileArray: TArray<string>;
  searchRec: TSearchRec;
  ext: string;
  imps: TImportStructures;
  imdf: TImportDefinition;
  DefaultFolderName: string;
begin
  Console_write('  - Importing Axpert Structures:', 5);
  writeln;
  Console_write
    ('   - Finding form and report-related structure files for import.', 10);
  // Console_write('   - Importing form and report structures one by one.', 10);
  writelog('InstallAxpertStructures function started..');
  writelog('Importing form and report structures one by one.');
  // writeln;
  writeln;
  writeln;
  try
    // Decided to removed OfficialReleases , so plugin and patches will be palced
    // directly under repo\root dir   | 14/11/2024
    // AxStruPath := patchLocalPath+'OfficialReleases\Plugins\' + selectedPlugin + '\' +
    // cAxpertStructures + '\';

//25-11-2024 | As per new GIT structyre and design we removed in between plugins

//    AxStruPath := patchLocalPath + 'Plugins\' + selectedPlugin + '\' +
//      cAxpertStructures + '\';

//    AxStruPath := patchLocalPath +  selectedPlugin + '\' +
//      cAxpertStructures + '\';

    AxStruPath := {patchLocalPath} pluginLocalPath +  selectedPlugin + '\' +
      cAxpertStructures + '\' + databasetype + '\';

    if not directoryexists(AxStruPath) then
    begin
      writelog('No structures available for import from ' + AxStruPath);
      writeln;
      writeln;
      writeln('    -No files available to process.');
      writeln;
      Exit;
    end;
    Console_write('   - Importing form and report structures one by one.', 10);
    writeln;
    //FolderList := TDirectory.GetDirectories(AxStruPath);
    //Count := Length(FolderList);
    imps := TImportStructures.create;
    imdf := TImportDefinition.create;
    // FolderName:=FolderName+'\'+cAxExport;
    try
      //for FolderName in FolderList do
      begin
        // AxStruPath:=AxStruPath+FolderName+'\';
        //DefaultFolderName := FolderName + '\' + cAxExport;

       // DefaultFolderName := FolderName;
        DefaultFolderName := AxStruPath;
        if FindFirst(DefaultFolderName + '*.*', faAnyFile, searchRec) = 0 then
        begin
          fileArray := TArray<string>(TDirectory.GetFiles(DefaultFolderName));
          filecount := Length(fileArray);
          // if filecount > 0 then
          // Console_write('   - Importing form and report structures one by one.', 10)
          // else
          // Console_write('   - No structures available for import.', 10);
          for I := 0 to filecount - 1 do
          begin
            // ext:=ExtractFileExt(fileArray[I]);
            if ExtractFileExt(fileArray[I]) = '.cds' then
            begin
              imdf.importCDS(fileArray[I]);
            end
            else
              imps.ImportStructure(fileArray[I]);
            // AxStruPath:=pluginLocalPath+selectedplugin+'\AxpertStructure\';

          end;
          // writeln;

        end;
      end;
      writeln;
      writelog('InstallAxpertStructures function ends..');
    finally
      if assigned(imps) then
        freeandnil(imps);
      if assigned(imdf) then
        freeandnil(imdf);
    end;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writeln;
      writeln;
      writelog('Error occured in InstallAxpertStructures : ' + E.Message);
      // readln;
    end;
    // path:=pluginLocalPath+selectedplugin+'\AxpertStructure\'+filetype+'\'+FileName;
  end;
end;

function TInstallation.ExecuteDBScripts(): string;
var
  indbs: TInstallDbScripts;
begin
  try
    indbs := nil;
    try
      indbs := TInstallDbScripts.create;
      indbs.ExecuteDBScripts();
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        Console_write('Error: ' + E.Message, 12);
        writeln;
        readln;
      end;

    end;
  finally
    if assigned(indbs) then
      freeandnil(indbs);
  end;
end;

function TInstallation.InstallRMQClient(): string;
var
  inrmq: TInstallRMQClients;
begin
  try
    inrmq := nil;
    try
      inrmq := TInstallRMQClients.create;
      inrmq.InstallRMQClients();
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        Console_write('Error from installation: ' + E.Message, 12);
        writeln;
        readln;
      end;
    end;
  finally
    if assigned(inrmq) then
      freeandnil(inrmq);
  end;
end;

function TInstallation.InstallPluginScripts(): string;
var
  inpluginscripts: TInstallPluginScripts;
begin
  try
    inpluginscripts := nil;
    try
      inpluginscripts := TInstallPluginScripts.create;
      inpluginscripts.InstallPluginScripts();
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        Console_write('Error from installation: ' + E.Message, 12);
        writeln;
        readln;
      end;
    end;
  finally
    if assigned(inpluginscripts) then
      freeandnil(inpluginscripts);
  end;
end;

function TInstallation.ReadFile(Sourcepath: string; destpath: string): string;
var
  copiedfile: TextFile;
  FileContent: string;
  displayDestPath: string;
  sfilename: string;
  updatedPluginPath: string;
  ParentPath: string;
  FileOpened: Boolean;
begin
  try
    Sourcepath := TRegEx.Replace(Sourcepath, '\\+', '\');
    //destPath := TRegEx.Replace(destPath, '\\+', '\');
    // DestPath := AnsiQuotedStr(DestPath, '"');

    ParentPath := ExtractFiledir(destpath);
    if not directoryexists(ParentPath) then
    begin
      ForceDirectories(ParentPath);
      Writelog('Creating ' + ParentPath);
    end;
    FileOpened := False;
    sfilename := ExtractFileName(Sourcepath);
 // Check for Files is in SkipList(manual action required)
    if IsFileInSkipList(sfilename) then
    begin
      Writelog('processing ' + sfilename + ' file.');
      destpath := ExtractFilePath(destpath);
      updatedPluginPath := StringReplace(selectedplugin, '/', '\',
        [rfReplaceAll, rfIgnoreCase]);
      destpath := destpath + 'ManualActionRequired\' + updatedPluginPath;
      if ForceDirectories(destpath) then
      begin
        writeln('   - ' + destpath + ' created.');
        // Copy skipped file to ManualActionRequired
        CopyFile( PChar(Sourcepath), PChar(destpath + '\' + sfilename), False );   // allow overwrite inside ManualActionRequired

        slUserInstructions.Add(' Manual actions required:');
        slUserInstructions.Add('Some files contain custom settings and were not automatically updated by the AxInstaller.' );
        slUserInstructions.Add('Please review and apply the necessary changes manually as described in:' );
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

    FileContent := TFile.ReadAllText(Sourcepath);
    // DestPath:=StringReplace(DestPath, ' ', '%20', [rfReplaceAll]);
    try
      AssignFile(copiedfile, destpath);
      Rewrite(copiedfile);
      FileOpened := True;
      writeln(copiedfile, FileContent);

      displayDestPath := StringReplace(destpath, '\\', '\', [rfReplaceAll]);
      displayDestPath := Copy(displayDestPath, pos('AxpertPlugins', displayDestPath)
        + Length('AxpertPlugins'), Length(displayDestPath) - pos('AxpertPlugins',
        displayDestPath) - Length('AxpertPlugins') + 1);
      write('   - Placing file ');
      displayDestPath := StringReplace(displayDestPath, '\\', '\',
        [rfReplaceAll]);

      // GetLast80CharsWithEllipsis
      //DisplayDestPath := GetLast80CharsWithEllipsis(DisplayDestPath);

      //GetLastNCharsWithEllipsis
      DisplayDestPath := GetLastNCharsWithEllipsis(DisplayDestPath);

      Console_write(ExtractFileName(Sourcepath) + ' ', 10);
      write('in ' + displayDestPath);
      writeln;
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        Console_write('Error: ' + E.Message, 12);
        writeln;
        readln;
      end;
    end;
  finally
    if FileOpened then
      CloseFile(copiedfile);
  end;
end;

function TInstallation.FindFile(Sourcepath: string): string;
var
  fileArray: TArray<string>;
  searchRec: TSearchRec;
  filecount, I: integer;
  destpath: string;
  FolderName: string;
begin
  try
    if FindFirst(Sourcepath + '*.*', faAnyFile, searchRec) = 0 then
    begin
      fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
      filecount := Length(fileArray);
      destpath := runwebcodepath +
        '\\' { + cWebFiles }{ cPlugins + '\\' + selectedPlugin };
      ForceDirectories(destpath { + '\\' + cWebFiles + '\\' } );
      destpath := destpath { + '\\' + cWebFiles + '\\' };
      FolderName := ExtractFileName(Sourcepath);
      for I := 0 to filecount - 1 do
      begin
        if FolderName = '' then
        begin
          ReadFile(fileArray[I], destpath + '\\' +
            ExtractFileName(fileArray[I]));
        end
        else
        begin
          // Destpath:= DestPath+'\\'+ FolderName + '\\'+extractFileName(fileArray[I]);
          // Destpath:= AnsiQuotedStr(DestPath, '"');
          if not directoryexists(destpath + '\\' + FolderName) then
            ForceDirectories(destpath + '\\' + FolderName);
          ReadFile(fileArray[I], destpath + '\\' + FolderName + '\\' +
            ExtractFileName(fileArray[I]));
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writeln;
      readln;
    end;
  end;
end;

Function TInstallation.CompletionStatus(): string;
var
  Response: string;
  Git: TGitManager;
begin
  try
    writeln(' INSTALLATION SUMMARY  ');
    writeln('=======================');
    writeln;
    write('  -');
    Console_write(selectedPlugin, 3);
    write(' installation completed without errors.');
    writeln;
    writeln;
    // write('Would you like to continue installation? ');
    // Console_write('[y/n]', 12);
    // writeln;
    // readln(Response);
    // if LowerCase(Response) = 'y' then
    // begin
    // Git := TGitManager.create;
    // Git.listOfPlugins();
    // end;
    // if LowerCase(Response) = 'n' then
    // begin
    // halt;
    // end;
    // if (Response <> 'y') and (Response <> 'n') then
    // begin
    // repeat
    // begin
    // writeln('Give your response in y or n only');
    // write('Press [y] to continue [n] to abort..? ');
    // Console_write('[y/n]', 12);
    // writeln;
    // readln(Response);
    // if Response = 'n' then
    // halt;
    // end;
    // until (Response = 'y') or (Response = 'n');

  Except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writeln;
      readln;
    end;
  end;
end;

function TInstallation.FindFolder(path: string): string;
var
  folderArray: TArray<string>;
  foldercount, I: integer;
  searchRec: TSearchRec;
  destinationPath: string;
begin
  try
    path := IncludeTrailingBackslash(path);
    if not directoryexists(path) then
    begin
      writeln;
      writeln('  - Webfiles are not available for ' + selectedPlugin);
      Exit;
    end;

    folderArray := TArray<string>(TDirectory.GetDirectories(path));

    (*
      destinationPath := runwebcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
      ForceDirectories(destinationPath + '\\' + cWebFiles + '\\');
      destinationPath := destinationPath + '\\' + cWebFiles + '\\';
    *)

    // The below code needs to be modified to optimize
    // This is being used only for plugins for patches we use uPathcInstallation
    // Where we handled in better way but still there alos optimization is required
    destinationPath := runwebcodepath + '\' + cPlugins + '\' + selectedPlugin;
    destinationPath := destinationPath + '\' + cWebFiles + '\';
    destinationPath := TRegEx.Replace(destinationPath, '\\+', '\');
    ForceDirectories(destinationPath);
    destinationPath := IncludeTrailingBackslash(destinationPath);

    foldercount := Length(folderArray);
    for I := 0 to foldercount - 1 do
    begin
      ForceDirectories(destinationPath + ExtractFileName(folderArray[I]));
      FindFile(path + ExtractFileName(folderArray[I]));
      // Newly added for finding WebFiles sub directories | 07112024
      // FindFolder(path + extractFileName(folderArray[I]));
    end;

    // CopyFilesRecursively('D:\Workspace\install_plugin\Win64\Debug\Plugin\Plugin1','C:\Users\paroksh.AGILELABS\Desktop\PluginWeb\Plugin\Plugin1\Webfiles');
    // Readln;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writeln;
      readln;
    end;
  end;
end;

function TInstallation.IsPublicInfoFound(): String;
var
  publicinfo: TextFile;
  path: string;
  pluginjsondata: string;
begin
  path := {GetCurrentDir() + '\'} AppDir+ 'plugininfo.dat';
  if FileExists(path) then
  begin
    pluginUpdate();
  end
  else
  begin
    AssignFile(publicinfo, path);
    Rewrite(publicinfo);
    pluginjsondata := createpluginjson();

    writeln(publicinfo, pluginjsondata);
    CloseFile(publicinfo);
    pluginUpdate();
  end;
end;

function TInstallation.Readplugininfo(nameofplugin: string): String;
var
  JSONText: string;
  TotalPluginObject, oPluginJSONObject, iPluginJSONObject: TJSONObject;
  pluginArray: TJSONArray;
  jsonPair: TJSONPair;
  webfilesJSONArray: TJSONArray;
  webfilesList: TList<string>;
  rmqclientsJSONArray: TJSONArray;
  rmqclientsList: TList<string>;
  axpertstructures: TJSONArray;
  axpertstrList: TList<string>;
  JSONValue: TJSONValue;
  AxStructuresJSONArray: TJSONArray;
  I, J, K, L: integer;
begin
  try
    JSONText := TFile.ReadAllText('plugininfo.dat');
    TotalPluginObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    if TotalPluginObject.Get('plugininfo').JSONValue.ToString <> '' then
    begin
      pluginArray := TotalPluginObject.Get('plugininfo')
        .JSONValue as TJSONArray;
      for I := 0 to pluginArray.Size - 1 do
      begin
        oPluginJSONObject := pluginArray.Get(I) as TJSONObject;
        jsonPair := oPluginJSONObject.Get('name');
        if jsonPair.JSONValue.value = lowercase(nameofplugin) then
        begin
          iPluginJSONObject := oPluginJSONObject.Get(nameofplugin)
            .JSONValue as TJSONObject;
        end;
        webfilesJSONArray := iPluginJSONObject.Get('webfiles')
          .JSONValue as TJSONArray;
        for J := 0 to webfilesJSONArray.Size - 1 do
        begin
          webfilesList := TList<string>.create;
          webfilesList.Add(webfilesJSONArray.Get(J).value);
        end;
        rmqclientsJSONArray := iPluginJSONObject.Get('rmqclients')
          .JSONValue as TJSONArray;
        for K := 0 to rmqclientsJSONArray.Size - 1 do
        begin
          rmqclientsList := TList<string>.create;
          rmqclientsList.Add(rmqclientsJSONArray.Get(K).ToString);
        end;
        axpertstructures := iPluginJSONObject.Get('axpertstructures')
          .JSONValue as TJSONArray;
        // AxStructures.Add(AxStructuresJSONArray.ToString);
        for L := 0 to axpertstructures.Size - 1 do
        begin
          axpertstrList := TList<string>.create;
          axpertstrList.Add(axpertstructures.Get(L).ToString);
        end;
      end;
    end;
  finally
    // Freeandnil(webfilesList);
    // Freeandnil(rmqclientsList);
    // Freeandnil(axpertstrList);
  end;
end;

function TInstallation.AddPlugin(): TJSONObject;
var
  webfile: TArray<string>;
  rmqclient: TArray<string>;
  rmqclientstr: string;
  webfilestr: string;
  // rmqclientpath:string;
  structuresArray: TArray<string>;
  axpertstructuresstr: string;
  I, J: integer;
  plugininfopath: string;
  JSONText: string;
  JSONObject, TotalPluginObject: TJSONObject;
  PluginJSONArray: TJSONArray;
  opluginjsonboject, ipluginjsonboject: TJSONObject;
  webfileJSONarray, rmqclientJSONarray, axpertstructures: TJSONArray;
  plugininfoarray: TJSONArray;
  jsonPair: TJSONPair;
  pfile: TextFile;
  FileContent: string;

begin
  try
    JSONObject := TJSONObject.create;
    TotalPluginObject := TJSONObject.create;
    plugininfoarray := TJSONArray.create;
    if FileExists('plugininfo.dat') then
    begin
      // JSONText := TFile.ReadAllText('plugininfo.dat');
      JSONText := TFile.ReadAllText('plugininfo.dat');
      JSONText := trim(JSONText);
      JSONText := StringReplace(JSONText, '\\', '\',
        [rfReplaceAll, rfIgnoreCase]);
      JSONText := StringReplace(JSONText, '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
      JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
      plugininfoarray := JSONObject.Get('plugininfo').JSONValue as TJSONArray;
    end;
    webfile := TArray<string>(TDirectory.GetDirectories(runwebcodepath + 'HTML'
      { 'OfficialReleases\Plugins\' + selectedPlugin } ));
    for I := 0 to Length(webfile) - 1 do
    begin
      webfile[I] := StringReplace(webfile[I], '\\', '\',
        [rfReplaceAll, rfIgnoreCase]);
      webfile[I] := StringReplace(webfile[I], '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
    end;
    rmqclient := TArray<string>(TDirectory.GetDirectories(rmqclientpath));
    for J := 0 to Length(rmqclient) - 1 do
    begin
      rmqclient[J] := StringReplace(rmqclient[J], '\\', '\',
        [rfReplaceAll, rfIgnoreCase]);
      rmqclient[J] := StringReplace(rmqclient[J], '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
    end;
    if not assigned(AxStructures) then
      AxStructures := TList<string>.create;

    SetLength(structuresArray, AxStructures.Count);
    for I := 0 to Length(structuresArray) - 1 do
    begin
      structuresArray[I] := AxStructures[I];
    end;

    ipluginjsonboject := TJSONObject.create;
    opluginjsonboject := TJSONObject.create;
    // ipluginjsonboject.AddPair('webfiles', webfile);
    webfileJSONarray := TJSONArray.create;
    for webfilestr in webfile do
      webfileJSONarray.Add(webfilestr);
    ipluginjsonboject.AddPair('webfiles', webfileJSONarray);
    rmqclientJSONarray := TJSONArray.create;
    for rmqclientstr in rmqclient do
      rmqclientJSONarray.Add(rmqclientstr);
    ipluginjsonboject.AddPair('rmqclients', rmqclientJSONarray);
    axpertstructures := TJSONArray.create;
    for axpertstructuresstr in AxStructures do
      axpertstructures.Add(axpertstructuresstr);
    ipluginjsonboject.AddPair('axpertstructures', axpertstructures);
    opluginjsonboject.AddPair('name', selectedPlugin);
    opluginjsonboject.AddPair(selectedPlugin, ipluginjsonboject);
    plugininfoarray.AddElement(opluginjsonboject);
    TotalPluginObject.AddPair('plugininfo', plugininfoarray);
    FileContent := trim(TotalPluginObject.ToString);
    AssignFile(pfile, 'plugininfo.dat');
    Rewrite(pfile);
    writeln(pfile, FileContent);
    CloseFile(pfile);
  finally
    // Freeandnil(JSONObject);
    // Freeandnil(TotalPluginObject);
    // Freeandnil(plugininfoarray);
    // Freeandnil(ipluginjsonboject);
    // Freeandnil(opluginjsonboject);
    // Freeandnil(webfileJSONarray);
    // Freeandnil(rmqclientJSONarray);
  end;
end;

function TInstallation.createpluginjson(): String;
var
  JSONText: string;
  JSONObject: TJSONObject;
  ipluginjsonboject, opluginjsonboject, TotalPluginObject: TJSONObject;
  webfilearray, rmqclientarray, axpertstructures: TJSONArray;
  PluginJSONArray: TJSONArray;
begin
  try
    JSONObject := TJSONObject.create;
    ipluginjsonboject := TJSONObject.create;
    opluginjsonboject := TJSONObject.create;
    TotalPluginObject := TJSONObject.create;
    webfilearray := TJSONArray.create;
    rmqclientarray := TJSONArray.create;
    axpertstructures := TJSONArray.create;
    PluginJSONArray := TJSONArray.create;

    ipluginjsonboject.AddPair('webfiles', webfilearray);
    ipluginjsonboject.AddPair('rmqclients', rmqclientarray);
    ipluginjsonboject.AddPair('axpertstructures', axpertstructures);
    opluginjsonboject.AddPair('name', selectedPlugin);
    opluginjsonboject.AddPair(selectedPlugin, ipluginjsonboject);
    PluginJSONArray.AddElement(opluginjsonboject);
    TotalPluginObject.AddPair('plugininfo', PluginJSONArray);
    Result := TotalPluginObject.ToString;
  finally
    // Freeandnil(JSONObject);
    // Freeandnil(ipluginjsonboject);
    // Freeandnil(opluginjsonboject);
    // Freeandnil(TotalPluginObject);
    // Freeandnil(webfilearray);
    // Freeandnil(rmqclientarray);
    // Freeandnil(PluginJSONArray);
    // Freeandnil(axpertstructures);
  end;
end;

function TInstallation.pluginUpdate(): String;
var
  JSONText: string;
  plugininfoarray: TJSONArray;
  totatJSONObject: TJSONObject;
  jsonPair: TJSONPair;
  I: integer;
  pluginpresent: boolean;
  JSONObject, opluginobject, pluginObj: TJSONObject;
  pfile: TextFile;
  plFile: TextFile;
  FileContent: string;
  Content: string;
begin
  try
    pluginpresent := False;
    JSONObject := TJSONObject.create;
    totatJSONObject := TJSONObject.create;
    plugininfoarray := TJSONArray.create;
    JSONText := TFile.ReadAllText('plugininfo.dat');
    JSONText := trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    if Length(JSONText) < 10 then
    begin
      Content := createpluginjson();
      AssignFile(plFile, 'plugininfo.dat');
      Rewrite(plFile);
      writeln(plFile, Content);
      CloseFile(plFile);
      JSONText := TFile.ReadAllText('plugininfo.dat');
    end;
    JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    plugininfoarray := JSONObject.Get('plugininfo').JSONValue as TJSONArray;

    for I := 0 to plugininfoarray.Size - 1 do
    begin
      opluginobject := plugininfoarray.Get(I) as TJSONObject;
      jsonPair := opluginobject.Get('name');
      if lowercase(jsonPair.JSONValue.value) = lowercase(selectedPlugin) then
      begin
        pluginpresent := True;
        plugininfoarray.Remove(I);
        totatJSONObject.AddPair('plugininfo', plugininfoarray);
        AssignFile(pfile, 'plugininfo.dat');
        Rewrite(pfile);
        FileContent := totatJSONObject.ToString;
        FileContent := StringReplace(FileContent, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        writeln(pfile, totatJSONObject.ToString);
        CloseFile(pfile);
        AddPlugin();
      end;
    end;

    if not pluginpresent then
    begin
      AddPlugin();
      // pluginupdate();
    end;
  finally
    // freeandnil(JSONObject);
    // freeandnil(totatJSONObject);
    // freeandnil(plugininfoarray);
  end;

end;

(*
//Not in use
function TInstallation.InstallAxpertStructureFiles(Sourcepath: string;
  isRuntime: Boolean = False): String;
var
  fileArray, folderArray: TArray<string>;
  StructureArray: TArray<string>;
  filecount, structurecount, foldercount, X, Y, Z: Integer;
  fldpath, actualSourcePath: string;
  dbs: TInstallDbScripts;
  imps: TImportStructures;
  //dbx: TDbConnect;
  spath, dpath, sfilename: string;
  addinstruct: Boolean;
begin
  if (lowercase(currentversionname) <> 'version 11.3') and (Not isRuntime) then
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
//    dbs := TInstallDbScripts.Create;
    // dbx := TDbConnect.create;
//    Writelog('DBConnect object created');
//    dbc.DataBaseConnection();

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
        if Pos('data_migration_', lowercase(sfilename)) = 1 then
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
        else if lowercase('After_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z])) then
        begin
          writeln;
          Console_Write('   - Executing ' + ExtractFileName(StructureArray[Z]) +
            ' script.', 5);
          writeln;
          Writelog('Executing ' + ExtractFileName(StructureArray[Z]));
          dbs.ExecuteSQLFile(StructureArray[Z]);
        end
        else if (extractfileext(lowercase(StructureArray[Z])) = '.sql') and
          not(lowercase('Before_import_Script.sql')
          = lowercase(ExtractFileName(StructureArray[Z]))) then
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
          writeln('Error in ' + StructureArray[Z]);
          Writelog('Error while importing ' +
            ExtractFileName(StructureArray[Z]));
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

end; *)


end.
