unit uInstallPluginScripts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.StdCtrls,
  Data.db, XMLDoc,
  XMLIntf, uxds, uAxProvider, uGeneralFunctions, uProfitEval,
  IdBaseComponent, IdTCPConnection, IdTCPClient, IdFTP, IdComponent,
  Vcl.ComCtrls,
  Rio, SOAPHTTPClient, Vcl.buttons, Vcl.ExtCtrls, shellapi, uIviewXML, uxsmtp,
  uStoreData,
  uStructDef, uPDFPrint, xcallservice, adodb, Vcl.grids, uValidate,
  uAutoPageCreate,
  System.StrUtils, dateutils, uCreateIview, uCreateIviewStructure, uIviewTables,
  uPropsXML, idGlobal, IdSMTP, IdSSLOpenSSL, IdMessage,
  IdExplicitTLSClientServerBase,
  idreplysmtp, MessageDigest_5, uStructInTable, uCreateStructure,
  IdHTTP, uAxLog,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, uDBManager, uConnect,
  uCompress, ZLib, System.Types, System.IOUtils,
{$IF CompilerVersion > 24.0}
  JSON
{$ELSE}
  DBXJson
{$IFEND}
    ;

type
  TInstallPluginScripts = class
  private
    // procedure ExecuteSQLFile(pSQLFileName: String);
    function FindFile(Sourcepath: string): string;
    function FindFolder(path: string): string;
    function ReadFile(Sourcepath: string; DestPath: string): string;
    function ExtractSubstringFromFifthBackslash(const AString: string): string;
    // function PrepareShellScript(sitename, apppoolname, port, physicalpath: string): string;
    function PrepareShellScript(sitename, apppoolname, physicalpath, parentsite, parentvdir: string): string;
    procedure RunShellScript(shellscriptfile: string);

  public
    function InstallPluginScripts: string;
    function RemoveLastSegmentFromURL(URL: string): string;
    // procedure ConfigureIISSite(sitename, apppoolname, port, physicalpath: string);
    procedure ConfigureIISSite(sitename, apppoolname, physicalpath, iispluginapppath: string);
    end;

implementation

uses uUtils;

function TInstallPluginScripts.InstallPluginScripts: string;
var
  I: integer;
  destinationpath: string;
  LoacalDir: string;
  FolderArray: TArray<string>;
  ApiFolderName, Poolname, physicalpath: string;
begin
  writelog('InstallPluginScripts function started..');
  writeln;
  console_write('  - Installing Plugin Script:', 5);
  writeln;
  console_write
    ('   - Finding Plugin Script files to move to their corresponding directory.',
    10);
  // Console_write
  // ('   - Copying files to corresponding RMQclient folder from the local plugin directory.',
  // 10);
  // writeln;
  writelog('Copying files to corresponding Plugin Script folder from the local plugin directory.');
  pluginpath := armapipath + '\' + cPluginAPI + '\';
  // pluginpath := runwebcodepath + '\' + cPlugins + '\' + selectedPlugin + '\' + cPluginScript + '\' ;
  pluginpath := stringReplace(pluginpath, '\\', '\', [rfReplaceAll]);
  destinationpath := pluginpath; { rmqclientpath }
  // writeln;
  writeln;

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  // directly under repo\root dir   | 14/11/2024
  // LoacalDir := patchlocalpath+'OfficialReleases\Plugins\'+selectedplugin + '\' + cRMQ + '\';

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)

  // LoacalDir := patchlocalpath+'Plugins\'+selectedplugin + '\' + cRMQ + '\';

  LoacalDir := { patchlocalpath } pluginLocalPath + selectedplugin + '\' +
    cPluginScript + '\';

  if not directoryexists(LoacalDir) then
  begin
    writeln;
    writeln('    -No files available to process.');
    writelog('No ARM files are available to process at ' + LoacalDir);
    Exit;
  end;
  writeln;
  console_write
    ('   - Copying files to corresponding Plugin Script folder from the local plugin directory.',
    10);
  writeln;
  FolderArray := TArray<string>(TDirectory.GetDirectories(LoacalDir));
  for I := 0 to length(FolderArray) - 1 do
  begin
    ForceDirectories(pluginpath + '\' + extractfilename(FolderArray[I]));
    writelog('Placing all Plugin Scripts files to desired path');
    // FindFile(FolderArray[I]);
    FindFolder(FolderArray[I]);
    FindFile(FolderArray[I]);
    writelog('Install Plugin Scripts function ends..');
  end;

  if Trim(iispluginapppath) = '' then
  begin
    writelog('WARNING: IIS path not configured. Skipping IIS configuration.');
    console_write('   - IIS configuration skipped: IIS path not configured.', 12);
    writeln;
    Exit;
  end;
  for I := 0 to Length(FolderArray) - 1 do
  begin
    ApiFolderName := ExtractFileName(FolderArray[I]);
    physicalpath := pluginpath + '\' + ApiFolderName + '\';
    physicalpath := StringReplace(physicalpath, '\\', '\', [rfReplaceAll]);
    Poolname := ApiFolderName + 'pool';

    writelog('Configuring IIS for: ' + ApiFolderName);
    writelog('Physical Path: ' + physicalpath);
    writelog('Pool Name: ' + Poolname);

    ConfigureIISSite(ApiFolderName, Poolname, physicalpath, iispluginapppath);
  end;
  writeln;
end;

function TInstallPluginScripts.FindFile(Sourcepath: string): string;
var
  fileArray, FolderArray: TArray<string>;
  searchRec: TSearchRec;
  filecount, FolderCount, Count, I: integer;
  DestPath, updestinationpath: string;
  FolderName: string;
  subfolders: TStrings;
begin
  try
    // writeln('Sourcepath:='+sourcepath);
    if length(Sourcepath) > 0 then
    begin
      if FindFirst(Sourcepath + '*.*', faAnyFile, searchRec) = 0 then
      begin
        fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
        filecount := length(fileArray);
        updestinationpath := Copy(Sourcepath, pos(cPluginScript, Sourcepath) +
          length(cPluginScript), length(Sourcepath) - pos(cPluginScript,
          Sourcepath) - length(cPluginScript) + 1);
        // RemoveLastSegmentFromURL(rmqclientpath) + '\\'+updestinationpath;
        DestPath := pluginpath + '\' + updestinationpath;
        // ForceDirectories(DestPath + '\\' + cRMQ + '\\');
        // DestPath := DestPath + '\\' + cRMQ + '\\';
        // if pos(cRMQ, Sourcepath) > 0 then
        // begin
        // updestinationpath := Copy(Sourcepath, pos(cRMQ, Sourcepath) +
        // Length(cRMQ), Length(Sourcepath) - pos(cRMQ, Sourcepath) -
        // Length(cRMQ) + 1);
        // DestPath := DestPath + '\\' + updestinationpath + '\\';
        // // ForceDirectories(updestinationpath);
        // end
        // else
        // begin
        // // ForceDirectories(destinationpath + '\\' + cRMQ + '\\');
        // end;
        // FolderName := extractFileName(Sourcepath);
        for I := 0 to filecount - 1 do
        begin
          if FolderName = '' then
          begin
            // writeln('without folder name');
            ReadFile(fileArray[I], DestPath + '\' +
              extractfilename(fileArray[I]));
          end
          else
          begin
            // writeln('with folder name');
            ReadFile(fileArray[I], DestPath + FolderName + '\\' +
              extractfilename(fileArray[I]));
          end;

        end;
        // if FindFirst(Sourcepath + '\' + '*.*', faDirectory, searchRec) = 0 then
        // begin
        // repeat
        // if (searchRec.attr and faDirectory) = faDirectory then
        // begin
        // if (searchRec.Name <> '.') and (searchRec.Name <> '..') then
        // begin
        // subfolders.Add(searchRec.Name);
        // end;
        // end;
        // until FindNext(searchRec) <> 0;
        // end;
        // finally
        // FindClose(searchRec);
        // end;
        // FolderArray:=subfolders.ToStringArray;
        // SetLength(FolderArray, Count + 1);
        // FolderArray[Count] := Sourcepath+'\'+ searchRec.Name;
        // Inc(Count);
        // end;
        // until FindNext(searchRec) <> 0;
        // FindClose(searchRec);
        // ForceDirectories(Sourcepath + '\\' + cRMQ + '\\');
        // Sourcepath:=Sourcepath+ '\\' + cRMQ + '\\';
        // FolderArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
        // FolderCount := Length(fileArray);
        // DestPath := webcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
        // ForceDirectories(DestPath + '\\' + cRMQ + '\\');
        // DestPath := DestPath + '\\' + cRMQ + '\\';
        // FolderName := extractFileName(Sourcepath);
        // for I := 0 to filecount - 1 do
        // begin
        // if FolderName = '' then
        // begin
        // ReadFile(FolderArray[I], DestPath + extractFileName(FolderArray[I]));
        // end
        // else
        // begin
        // ReadFile(FolderArray[I], DestPath + FolderName + '\\' +
        // extractFileName(FolderArray[I]));
        // end;
        // end;
      end;
    end
  except
    on E: Exception do
    begin
      console_write('Error from findfile: ' + E.Message, 12);
      writeln;
      writelog('Error from find folder function: ' + E.Message);
      readln;
    end;
  end;
end;

function TInstallPluginScripts.FindFolder(path: string): string;
var
  FolderArray: TArray<string>;
  FolderCount, I: integer;
  searchRec: TSearchRec;
  destinationpath, updestinationpath: string;
begin
  try

    // if not directoryExists(path) then
    // begin
    // writeln;
    // writeln('  - RMQfiles are not available for ' + selectedPlugin);
    // exit;
    // end;
    // writeln('path :='+path );
    if length(path) > 0 then
    begin
      FolderArray := TArray<string>(TDirectory.GetDirectories(path));
      updestinationpath := Copy(path, pos(cPluginScript, path) +
        length(cPluginScript), length(path) - pos(cPluginScript, path) -
        length(cPluginScript) + 1);
      updestinationpath := RemoveLastSegmentFromURL(updestinationpath);
      // updestinationpath := destinationpath + '\\' + updestinationpath;
      // ForceDirectories(updestinationpath);
      destinationpath := RemoveLastSegmentFromURL(pluginpath) + '\\' +
        updestinationpath;
      // webcodepath + '\\' + cPlugins + '\\' + selectedPlugin +
      // '\\' + cRMQ
      // if pos(cRMQ, path) > 0 then
      // begin
      // updestinationpath := Copy(path, pos(cRMQ, path) + Length(cRMQ),
      // Length(path) - pos(cRMQ, path) - Length(cRMQ) + 1);
      // updestinationpath := destinationpath + '\\' + updestinationpath;
      // ForceDirectories(updestinationpath);
      // end
      // else
      // begin
      // ForceDirectories(destinationpath + '\\' + cRMQ + '\\');
      // end;
      // destinationpath := destinationpath + '\\' + cRMQ + '\\'+ExtractFileName(path);
      // ForceDirectories(destinationpath + '\\' + cRMQ + '\\'+ExtractFileName(path));
      FolderCount := length(FolderArray);
      for I := 0 to FolderCount - 1 do
      begin
        // writeln(extractFileName(FolderArray[I]));
        ForceDirectories(destinationpath + '\' +
          extractfilename(FolderArray[I]));
        FindFolder(FolderArray[I]);
        FindFile(FolderArray[I]);
      end;

      // CopyFilesRecursively('D:\Workspace\install_plugin\Win64\Debug\Plugin\Plugin1','C:\Users\paroksh.AGILELABS\Desktop\PluginWeb\Plugin\Plugin1\Webfiles');
      // Readln;
    end;
  except
    on E: Exception do
    begin
      console_write('Error from find folder: ' + E.Message, 12);
      writeln;
      writelog('Error from find folder function: ' + E.Message);
      readln;
    end;
  end;
end;

function TInstallPluginScripts.ReadFile(Sourcepath: string;
  DestPath: string): string;
var
  copiedfile: TextFile;
  FileContent: string;
  displayDestPath, tmpDestPath: string;
begin
  try
    FileContent := TFile.ReadAllText(Sourcepath);
    // writeln(ExtractFileName(Sourcepath)+' getting copied into '+DestPath);
    AssignFile(copiedfile, DestPath);
    Rewrite(copiedfile);
    writeln(copiedfile, FileContent);
    CloseFile(copiedfile);
    displayDestPath := stringReplace(DestPath, '\\', '\', [rfReplaceAll]);
    // displayDestPath := Copy(displayDestPath, pos('AxPlugins', displayDestPath) +
    // Length('AxPlugins'), Length(displayDestPath) - pos('AxPlugins',
    // displayDestPath) - Length('AxPlugins') + 1);
    displayDestPath := stringReplace(displayDestPath, '\\', '\',
      [rfReplaceAll]);
    tmpDestPath := ExtractSubstringFromFifthBackslash(displayDestPath);
    if Trim(tmpDestPath) <> '' then
      displayDestPath := tmpDestPath
    else if length(displayDestPath) > 100 then
    begin
      try
        displayDestPath := Copy(displayDestPath, length(displayDestPath) - 99,
          length(displayDestPath));
      except

      end;
    end;

    write('   - Placing file ');
    console_write(extractfilename(Sourcepath) + ' ', 10);
    write('in ...' + displayDestPath);
    writeln;
  except
    on E: Exception do
    begin
      console_write('Error from read file: ' + E.Message, 12);
      writeln;
      writelog('Error from read folder function : ' + E.Message);
      readln;
    end;
  end;
end;


// Old code to add Application as separate site.
(* function TInstallPluginScripts.PrepareShellScript(sitename, apppoolname, port, physicalpath: string): string;
  var
  ScriptLines: TStringList;
  FileName: string;
  TempPath: array[0..MAX_PATH] of Char;
  begin
  GetTempPath(MAX_PATH, TempPath);
  FileName := IncludeTrailingPathDelimiter(StrPas(TempPath)) + 'SetupIIS.ps1';

  ScriptLines := TStringList.Create;
  try
  writelog('Preparing PowerShell script for IIS setup...');

  ScriptLines.Add('Import-Module WebAdministration');

  // Create App Pool if missing
  ScriptLines.Add(Format('if (!(Test-Path "IIS:\AppPools\%s")) {', [apppoolname]));
  ScriptLines.Add(Format('  $pool = New-WebAppPool -Name "%s"', [apppoolname]));
  ScriptLines.Add('  $pool.managedRuntimeVersion = ""');
  ScriptLines.Add('  $pool | Set-Item');
  ScriptLines.Add('}');

  // Create Site if missing
  ScriptLines.Add(Format('if (!(Test-Path "IIS:\Sites\%s")) {', [sitename]));
  ScriptLines.Add(Format(
  '  New-Website -Name "%s" -Port %s -PhysicalPath "%s" -ApplicationPool "%s"',
  [sitename, port, physicalpath, apppoolname]));
  ScriptLines.Add('}');

  // Permissions
  ScriptLines.Add(Format('$acl = Get-Acl "%s"', [physicalpath]));
  ScriptLines.Add(Format(
  '$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS AppPool\%s", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")',
  [apppoolname]));
  ScriptLines.Add('$acl.AddAccessRule($rule)');
  ScriptLines.Add(Format('Set-Acl "%s" $acl', [physicalpath]));

  ScriptLines.SaveToFile(FileName, TEncoding.UTF8);

  writelog('PowerShell script saved successfully.');

  Result := FileName;
  finally
  ScriptLines.Free;
  end;
  end; *)

// New code to add the application inside ARM site in Default WebSite Pool.
function TInstallPluginScripts.PrepareShellScript(sitename, apppoolname, physicalpath, parentsite, parentvdir: string): string;
var
  ScriptLines: TStringList;
  FileName: string;
  TempPath: array [0 .. MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, TempPath);
  FileName := IncludeTrailingPathDelimiter(StrPas(TempPath)) + 'SetupIIS.ps1';
  ScriptLines := TStringList.Create;
  try
    writelog('Preparing PowerShell script for IIS setup...');
    ScriptLines.Add('Import-Module WebAdministration');
    ScriptLines.Add('');

    // 1. Ensure Parent Site exists
    ScriptLines.Add(Format('if (!(Test-Path "IIS:\Sites\%s")) {', [parentsite]));
    ScriptLines.Add(Format('    Write-Host "[ERROR] %s not found. Aborting."', [parentsite]));
    ScriptLines.Add('    exit 1');
    ScriptLines.Add('}');
    ScriptLines.Add(Format('Write-Host "[OK] %s found."', [parentsite]));
    ScriptLines.Add('');

    // 2. Ensure virtual directory exists under Parent Site
    ScriptLines.Add(Format('if (!(Test-Path "IIS:\Sites\%s\%s")) {', [parentsite, parentvdir]));
    ScriptLines.Add(Format('    New-WebVirtualDirectory -Site "%s" -Name "%s" -PhysicalPath "C:\inetpub\wwwroot\%s"',
      [parentsite, parentvdir, parentvdir]));
    ScriptLines.Add(Format('    Write-Host "[CREATED] Virtual Directory: %s"', [parentvdir]));
    ScriptLines.Add('} else {');
    ScriptLines.Add(Format('    Write-Host "[EXISTS] Virtual Directory: %s"', [parentvdir]));
    ScriptLines.Add('}');
    ScriptLines.Add('');

    // 3. AppPool
    ScriptLines.Add(Format('if (!(Test-Path "IIS:\AppPools\%s")) {', [apppoolname]));
    ScriptLines.Add(Format('    $pool = New-WebAppPool -Name "%s"', [apppoolname]));
    ScriptLines.Add('    $pool.managedRuntimeVersion = ""');
    ScriptLines.Add('    $pool | Set-Item');
    ScriptLines.Add(Format('    Write-Host "[CREATED] AppPool: %s"', [apppoolname]));
    ScriptLines.Add('} else {');
    ScriptLines.Add(Format('    Write-Host "[EXISTS] AppPool: %s"', [apppoolname]));
    ScriptLines.Add('}');
    ScriptLines.Add('');

    // 4. Permissions BEFORE creating application
    ScriptLines.Add(Format('$acl = Get-Acl "%s"', [physicalpath]));
    ScriptLines.Add(Format('$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(' +
      '"IIS AppPool\%s", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")',
      [apppoolname]));
    ScriptLines.Add('$acl.AddAccessRule($rule)');
    ScriptLines.Add(Format('Set-Acl "%s" $acl', [physicalpath]));
    ScriptLines.Add(Format('Write-Host "[PERMISSIONS] ACL set for %s"', [apppoolname]));
    ScriptLines.Add('');

    // 5. Create Web Application under ParentSite/ParentVDir/
    ScriptLines.Add(Format('if (!(Test-Path "IIS:\Sites\%s\%s\%s")) {',
      [parentsite, parentvdir, sitename]));
    ScriptLines.Add(Format('    New-WebApplication -Site "%s" -Name "%s/%s" ' +
      '-PhysicalPath "%s" -ApplicationPool "%s"',
      [parentsite, parentvdir, sitename, physicalpath, apppoolname]));
    ScriptLines.Add(Format('    Write-Host "[CREATED] Application: %s/%s/%s"',
      [parentsite, parentvdir, sitename]));
    ScriptLines.Add('} else {');
    ScriptLines.Add(Format('    Write-Host "[EXISTS] Application: %s/%s/%s"',
      [parentsite, parentvdir, sitename]));
    ScriptLines.Add(Format('    $existingPath = (Get-WebApplication -Site "%s" -Name "%s/%s").PhysicalPath',
      [parentsite, parentvdir, sitename]));
    ScriptLines.Add(Format('    if ($existingPath -ne "%s") {', [physicalpath]));
    ScriptLines.Add(Format('        Set-WebConfigurationProperty -Filter ' +
      '"/system.applicationHost/sites/site[@name=''%s'']' +
      '/application[@path=''/%s/%s'']" ' +
      '-Name "virtualDirectory/@physicalPath" -Value "%s"',
      [parentsite, parentvdir, sitename, physicalpath]));
    ScriptLines.Add(Format('        Write-Host "[UPDATED] Physical path corrected to: %s"', [physicalpath]));
    ScriptLines.Add('    } else {');
    ScriptLines.Add('        Write-Host "[OK] Physical path is correct."');
    ScriptLines.Add('    }');
    ScriptLines.Add('}');
    ScriptLines.Add('');

    // 6. Start AppPool
    ScriptLines.Add(Format('$poolState = (Get-WebAppPoolState -Name "%s").Value', [apppoolname]));
    ScriptLines.Add('if ($poolState -ne "Started") {');
    ScriptLines.Add(Format('    Start-WebAppPool -Name "%s"', [apppoolname]));
    ScriptLines.Add(Format('    Write-Host "[STARTED] AppPool: %s"', [apppoolname]));
    ScriptLines.Add('} else {');
    ScriptLines.Add(Format('    Write-Host "[RUNNING] AppPool: %s"', [apppoolname]));
    ScriptLines.Add('}');
    ScriptLines.Add('');

    // 7. Ensure Parent Site is started
    ScriptLines.Add(Format('$siteState = (Get-WebsiteState -Name "%s").Value', [parentsite]));
    ScriptLines.Add('if ($siteState -ne "Started") {');
    ScriptLines.Add(Format('    Start-Website -Name "%s"', [parentsite]));
    ScriptLines.Add(Format('    Write-Host "[STARTED] %s"', [parentsite]));
    ScriptLines.Add('} else {');
    ScriptLines.Add(Format('    Write-Host "[RUNNING] %s"', [parentsite]));
    ScriptLines.Add('}');
    ScriptLines.Add('');

    // 8. Final status
    ScriptLines.Add(Format('$poolState = (Get-WebAppPoolState -Name "%s").Value', [apppoolname]));
    ScriptLines.Add(Format('$siteState = (Get-WebsiteState -Name "%s").Value', [parentsite]));
    ScriptLines.Add(Format('Write-Host "[STATUS] AppPool: $poolState  |  %s: $siteState  |  App: %s/%s/%s"',
      [parentsite, parentsite, parentvdir, sitename]));

    ScriptLines.SaveToFile(FileName, TEncoding.UTF8);
    writelog('PowerShell script saved to: ' + FileName);
    Result := FileName;
  finally
    ScriptLines.Free;
  end;
end;

procedure TInstallPluginScripts.RunShellScript(shellscriptfile: string);
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.Wnd := 0;
  SEInfo.lpVerb := 'runas';
  SEInfo.lpFile := 'powershell.exe';
  SEInfo.lpParameters := PChar(Format('-NoProfile -ExecutionPolicy Bypass -File "%s"',
    [shellscriptfile]));
  SEInfo.nShow := SW_HIDE;

  writelog('Executing PowerShell script for IIS setup...');

  if ShellExecuteEx(@SEInfo) then
  begin
    WaitForSingleObject(SEInfo.hProcess, INFINITE);
    GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    CloseHandle(SEInfo.hProcess);
    if ExitCode <> 0 then
      writelog(Format('WARNING: PowerShell exited with code %d', [ExitCode]))
    else
      writelog('PowerShell execution completed successfully. Exit code: 0');
  end
  else
    writelog(Format('ERROR: Failed to launch PowerShell. WinError: %d', [GetLastError]));
end;

procedure TInstallPluginScripts.ConfigureIISSite(sitename, apppoolname,
  physicalpath, iispluginapppath: string);
var
  ScriptFile: string;
  Parts: TArray<string>;
  ParentSite, ParentVDir: string;
  LastSlash: integer;
begin
  try
    writelog('----------------------------------------');
    writelog('IIS Configuration Started');
    writelog('SiteName      : ' + sitename);
    writelog('AppPoolName   : ' + apppoolname);
    writelog('PhysicalPath  : ' + physicalpath);
    writelog('IISAppPath    : ' + iispluginapppath);

    // Normalize to backslash then split on LAST backslash
    // This handles any depth: 'Default Web Site\ARM' or 'Default Web Site\ARM\ArmAPI'
    iispluginapppath := StringReplace(iispluginapppath, '/', '\', [rfReplaceAll]);
    LastSlash := LastDelimiter('\', iispluginapppath);

    if LastSlash = 0 then
    begin
      writelog('ERROR: Invalid IISPluginAppPath format. Cannot determine parent site and vdir.');
      console_write('   - IIS configuration skipped: Invalid IIS path format.', 12);
      writeln;
      Exit;
    end;

    // Everything before last backslash = full parent path (could be nested)
    // Everything after last backslash = the immediate parent app/vdir
    ParentSite := Trim(Copy(iispluginapppath, 1, Pos('\', iispluginapppath) - 1));
    ParentVDir := Trim(Copy(iispluginapppath, Pos('\', iispluginapppath) + 1,
      Length(iispluginapppath)));

    writelog('ParentSite  : ' + ParentSite);
    writelog('ParentVDir  : ' + ParentVDir);

    console_write('  - Configuring IIS Application: ' + sitename, 5);
    writeln;

    ScriptFile := PrepareShellScript(sitename, apppoolname, physicalpath,
      ParentSite, ParentVDir);
    writelog('Shell script prepared at: ' + ScriptFile);

    RunShellScript(ScriptFile);

    writelog('IIS Configuration Completed Successfully');
    console_write('   - IIS setup completed successfully.', 10);
    writeln;
  except
    on E: Exception do
    begin
      writelog('Error in ConfigureIISSite: ' + E.Message);
      console_write('Error configuring IIS: ' + E.Message, 12);
      writeln;
    end;
  end;
end;

function TInstallPluginScripts.RemoveLastSegmentFromURL(URL: string): string;
var
  LastSlashPos: integer;
begin
  // Find the last occurrence of '/' in the URL
  LastSlashPos := LastDelimiter('/', URL);

  // If a slash is found, remove everything after it
  if LastSlashPos > 0 then
  begin
    URL := Copy(URL, 1, LastSlashPos - 1);
    LastSlashPos := LastDelimiter('/', URL);
    URL := Copy(URL, 1, LastSlashPos);
    Result := URL;
  end
  else
    Result := URL; // No slash found, return original URL
end;

function TInstallPluginScripts.ExtractSubstringFromFifthBackslash
  (const AString: string): string;
var
  Position, BackslashCount: integer;
begin
  Result := '';
  BackslashCount := 0;

  // Finding the position of the 5th backslash
  Position := 1;
  while (Position > 0) and (BackslashCount < 5) do
  begin
    Position := PosEx('\', AString, Position + 1);
    if Position > 0 then
      Inc(BackslashCount);
  end;

  // If 5th backslash is found, extract the substring from that position
  if BackslashCount = 5 then
    Result := Copy(AString, Position, length(AString) - Position + 1);
end;

end.
