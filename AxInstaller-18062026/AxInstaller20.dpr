program AxInstaller20;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Classes,
  Dialogs,
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  Data.DBXJSON,
  Winapi.Windows,
  System.RegularExpressions,
  uInItApp in 'uInItApp.pas',
  uUtils in 'uUtils.pas',
  IISManager in 'IISManager.pas',
  uConfig in 'uConfig.pas',
  uGitManager in 'uGitManager.pas',
  uInstallation in 'uInstallation.pas',
  uDbConnect in 'uDbConnect.pas',
  uGitAccessToken in 'uGitAccessToken.pas',
  uImportStructures in 'uImportStructures.pas',
  xcallservice in '\\192.168.2.6\Axpert2\Ver3.3\Desktop\xcallservice.pas',
  uTreeObj in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.5\Commonchanges for 64bit\uTreeObj.pas',
  UTprovideprintdata in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.5\Commonchanges for 64bit\UTprovideprintdata.pas',
  uTPrinterSettings in '\\192.168.2.6\Axpert2\Ver 8.6.8.2\uTPrinterSettings.pas',
  UDosPrint in '\\192.168.2.6\Axpert2\Ver 8.4.8\UDosPrint.pas',
  UDosPrintDoc in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.5\UDosPrintDoc.pas',
  UDocObject in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.5\Commonchanges for 64bit\UDocObject.pas',
  uMRPRun in '\\192.168.2.6\Axpert2\Ver 8.9.0.4\uMRPRun.pas',
  ufmASB in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.6\ufmASB.pas' {ASBModule: TWebModule},
  MessageDigest_5 in '\\192.168.2.6\ASB8.9-XE3\ASB 64 Bit for SIPF\Ver 8.9.0.7\MessageDigest_5.pas',
  uDosObject in '\\192.168.2.6\Axpert9-XE3\Ver 9.3\uDosObject.pas',
  UPrintReport in '\\192.168.2.6\Axpert9-XE3\Ver 9.3\UPrintReport.pas',
  uBOM in '\\192.168.2.6\Axpert9-XE3\Ver 9.4\uBOM.pas',
  uFillStruct in '\\192.168.2.6\Axpert9-XE3\Ver 9.4\uFillStruct.pas',
  uUpdateDependencies in '\\192.168.2.6\Axpert9-XE3\Ver 9.4\uUpdateDependencies.pas',
  uPDFPrint in '\\192.168.2.6\Axpert9-XE3\Ver 9.5\uPDFPrint.pas',
  uStructUpgrade in '\\192.168.2.6\Axpert9-XE3\Ver 9.0\ASB\uStructUpgrade.pas',
  UConvSGridToHtml in '\\192.168.2.6\Axpert9-XE3\Ver 9.7\UConvSGridToHtml.pas',
  uMSWord in '\\192.168.2.6\Axpert9-XE3\Ver 9.7\uMSWord.pas',
  uAES in '\\192.168.2.6\Axpert9-XE3\Ver 9.7\Fix2\uAES.pas',
  uElAES in '\\192.168.2.6\Axpert9-XE3\Ver 9.7\Fix2\uElAES.pas',
  uAxpertLic in '\\192.168.2.6\Axpert9-XE3\Ver 9.8\New Licensing Changes - 9.8latest\Asb\uAxpertLic.pas',
  uMDMap in '\\192.168.2.6\Axpert9-XE3\Ver 9.8\uMDMap.pas',
  uUpdateMgr in '\\192.168.2.6\Axpert9-XE3\Ver 10.2\AxpManager\uUpdateMgr.pas',
  uUpdateMgrVerDetails in '\\192.168.2.6\Axpert9-XE3\Ver 10.2\AxpManager\uUpdateMgrVerDetails.pas',
  uASBT in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uASBT.pas',
  uASBTStruct in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uASBTStruct.pas',
  uWMIHardwareID in '\\192.168.2.6\Axpert9-XE3\Ver 10.1\Fix2\uWMIHardwareID.pas',
  AXMLibrary in '\\192.168.2.6\Axpert9-XE3\Ver 10.3\asb\AXMLibrary.pas',
  AXMConnection in '\\192.168.2.6\Axpert9-XE3\Ver 10.3\asb\AXMConnection.pas',
  uCompress in '\\192.168.2.6\Axpert9-XE3\Ver 10.3\uCompress.pas',
  uViewDef in '\\192.168.2.6\Axpert9-XE3\Ver 9.4\AxpManager\uViewDef.pas',
  uStoreDependencies in '\\192.168.2.6\Axpert9-XE3\Ver 10.5\AxpManager\uStoreDependencies.pas',
  uAgileCloudObj in '\\192.168.2.6\Axpert9-XE3\Ver 9.4\Asb\uAgileCloudObj.pas',
  uListView in '\\192.168.2.6\Axpert9-XE3\Ver 9.9\New UI  Changes\uListView.pas',
  uSearchVal in '\\192.168.2.6\Axpert9-XE3\Ver 10.3\WebFix5\uSearchVal.pas',
  uFrameSQL in '\\192.168.2.6\Axpert9-XE3\Ver 10.6\uFrameSQL.pas',
  uWorkFlow in '\\192.168.2.6\Axpert9-XE3\Ver 10.8\uWorkFlow.pas',
  uTasks in '\\192.168.2.6\Axpert9-XE3\Ver 10.1\WebFix3\uTasks.pas',
  uDataExport in '\\192.168.2.6\Axpert9-XE3\Ver 10.8\Webfix2\uDataExport.pas',
  uDataImport in '\\192.168.2.6\Axpert9-XE3\Ver 10.8\Webfix2\uDataImport.pas',
  uPrintDocs in '\\192.168.2.6\Axpert9-XE3\Ver 10.9\uPrintDocs.pas',
  Redis.Client in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\Redis.Client.pas',
  Redis.Command in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\Redis.Command.pas',
  Redis.Commons in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\Redis.Commons.pas',
  Redis.NetLib.Factory in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\Redis.NetLib.Factory.pas',
  Redis.NetLib.INDY in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\Redis.NetLib.INDY.pas',
  RedisMQ.Commands in 'D:\Supporting Files\__Supporting Files\REDIS CLIENT - DELPHI XE3 Support\sources\RedisMQ.Commands.pas',
  uPropsXML in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\uPropsXML.pas',
  uCreateStructure in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\Asb\uCreateStructure.pas',
  uConnect in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\uConnect.pas',
  uWorkFlowRuntime in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uWorkFlowRuntime.pas',
  uLicMgr in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\uLicMgr.pas',
  UProfitEVal in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\UProfitEVal.pas',
  uIViewTables in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\Asb\uIViewTables.pas',
  uExecuteSQL in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\Asb\uExecuteSQL.pas',
  uCreateIviewStructure in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\Asb\uCreateIviewStructure.pas',
  UParse in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\UParse.pas',
  uASBTStructObj in 'uASBTStructObj.pas',
  uAutoPageCreate in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\Asb\uAutoPageCreate.pas',
  uXSMTP in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\uXSMTP.pas',
  uStoredata in 'uStoredata.pas',
  uASBCommonObj in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uASBCommonObj.pas',
  uAPILogging in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uAPILogging.pas',
  uAPILoggingImpl in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uAPILoggingImpl.pas',
  uAxProvider in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uAxProvider.pas',
  uDoDebug in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uDoDebug.pas',
  uGeneralFunctions in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uGeneralFunctions.pas',
  uProvidelink in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uProvidelink.pas',
  uProfitQuery in '\\192.168.2.6\Axpert9-XE3\Ver 10.9\WebFix4\uProfitQuery.pas',
  uStructInTable in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uStructInTable.pas',
  uiViewXML in '\\192.168.2.6\Axpert9-XE3\Ver 11.0\uiViewXML.pas',
  uImportDiff in 'uImportDiff.pas',
  uImportStructDef in '\\192.168.2.6\Axpert9-XE3\Ver 11.1\uImportStructDef.pas',
  uAxPEG in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\ASBPegRest_XE8\uAxPEG.pas',
  uValidate in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uValidate.pas',
  uAxAmend in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\ASBPegRest_XE8\uAxAmend.pas',
  uAxPEGActions in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\ASBPegRest_XE8\uAxPEGActions.pas',
  uImport in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uImport.pas',
  uDoCoreAction in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uDoCoreAction.pas',
  uCreateIview in '\\192.168.2.6\Axpert9-XE3\Ver 11.2\uCreateIview.pas',
  uGetDependencies in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uGetDependencies.pas',
  uAutoPrint in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uAutoPrint.pas',
  uDataExchQueue in 'uDataExchQueue.pas',
  uDbCall in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uDbCall.pas',
  uFormNotifications in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uFormNotifications.pas',
  uAxfastRun in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uAxfastRun.pas',
  uPublishToRMQ in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uPublishToRMQ.pas',
  uASBDataObj in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uASBDataObj.pas',
  uValueStock in '\\192.168.2.6\Axpert9-XE3\Ver 9.7\Fix24\uValueStock.pas',
  uDWBExport in '\\192.168.2.6\Axpert9-XE3\Ver 11.3\AsbCommonObjs\uDWBExport.pas',
  uDWBPublish in 'uDWBPublish.pas',
  uInstallDbScripts in 'uInstallDbScripts.pas',
  uInstallRMQClients in 'uInstallRMQClients.pas',
  uUnIstallation in 'uUnIstallation.pas',
  uImportDefinition in 'uImportDefinition.pas',
  uPatchInstallation in 'uPatchInstallation.pas',
  uAxLog in 'uAxLog.pas',
  uInstallPluginScripts in 'uInstallPluginScripts.pas',
  {uDBManager in 'D:\install_plugin_v1\Changed Units\uDBManager.pas',
  uStructDef in 'D:\install_plugin_v1\Changed Units\uStructDef.pas',
  uXDS in 'D:\install_plugin_v1\Changed Units\uXDS.pas';  }

 uDBManager in '\\192.168.2.6\Axpert9-XE3\Ver 11.4\CommonObjs\uDBManager.pas',
  uStructDef in '\\192.168.2.6\Axpert9-XE3\Ver 11.4\CommonObjs\uStructDef.pas',
  uXDS in '\\192.168.2.6\Axpert9-XE3\Ver 11.4\CommonObjs\uXDS.pas';

// uGitAccessToken in 'uGitAccessToken.pas';

/// \\192.168.2.6\Axpert9-XE3\Ver 11.0 Binaries\POS\uASBARS.pas

type
  TMain = class
  private
    Welcome: TInItApp;
    // Welcome:TGitAccessToken;
    Config: TConfig;
    // A: TUnIstallation;
    // B: Tinstallation;
    git: TGitManager;
    inst: Tinstallation;
    pinst: TPatchinstallation;
    unst: TUnIstallation;
    database: TDbConnect;
    cds: TDWBPublish;
    // importStructure:TImportStructures;

    procedure startplugin;
    procedure GetConfig;
    procedure ListPlugin;
    procedure ListPatch;
    // procedure InstallPlugin;
    // procedure ConnectDbOperation;
    procedure InIt;
    procedure AppInit;
    // procedure UnInstallPlugin;
    // procedure ImportAxpertStrucure;

  public

    constructor Create;
    destructor Destroy; override;
    function parseCommand(Command: string): string;
    function findindex(MyArray: TArray<string>; Mystring: string): integer;
    function SetApplication( { resp: string } ): string;
    function SearchCommand(Cmd: string): Boolean;
    function HandleListCommand(res: string): string;
    function HandleConfigCommand(): string;
    function HandleHelpCommand(): string;
    function findpatchindex(patch: string): integer;
    function HandleDebug(): string;
    function HandleInstallationCommand(Plugin: string): string;
    function HandleUnInstallationCommand(Plugin: string): string;
    function ExtractPatchNumber(str: string): integer;
    function HandleAllConfigCommand(Command: string;
      bSkipReadCmd: Boolean = False): string;
    function InitObj(): string;
    function DestroyObj(): string;
    function HandleQuitCommand(Command: string): string;
    function findLatestPatchAccordingToVersion(Version: string): integer;
    function handlereleasecommand(Command: string): string;
    function HandleStructureInstallation(patch: string): string;
    function findfolder(sourcepath: string; destpath: string): string;
    function IIsStatus(): string;
    function ReloadConfig(): string;
    // procedure PullPluginOperation;
    procedure WriteUserInstructions;
  end;

constructor TMain.Create;
begin
  Welcome := nil;
  Config := nil;
  git := nil;
  inst := nil;
  unst := nil;
  database := nil;
  cds := nil;
  slUserInstructions := nil;
  InIt;
end;

destructor TMain.Destroy;
begin
  FreeAndNil(Welcome);
  FreeAndNil(Config);
  FreeAndNil(git);
  FreeAndNil(inst);
  FreeAndNil(unst);
  FreeAndNil(database);
  FreeAndNil(cds);
  FreeAndNil(slUserInstructions);
  FreeAndNil(SkipFileList);
  inherited;
end;

function TMain.IIsStatus(): string;
var
  iisresponse: string;
begin
  if IsIISRunning then
  begin
    Write('IIS Status : ');
    Console_write('Running', 10);
    writeln;
    WriteLog('IIS Status : Running');
    writeln;
    Console_write
      ('We recommend you to stop iis for continuing further installation', 12);
    writeln;
    writeln;
    writeln('Would you like to stop IIS using AxInstaller?');
    writeln('Press ''Y'' to continue or ''N'' to skip and stop IIS or the corresponding application pools manually.');
    writeln;
    write('AxInstaller> ');
    readln(iisresponse);
    if not((lowercase(iisresponse) = 'y') or (lowercase(iisresponse) = 'n'))
    then
    begin
      writeln;
      write('AxInstaller> ');
      readln(iisresponse);
    end;

    if lowercase(iisresponse) = lowercase('Y') then
    begin
      // if IsIISRunning then
      // begin
      writeln('Stopping IIS.');
      StopIIS;
      Sleep(15000);
      if IsIISRunning then // need to improvise
      begin
        Console_write('Unable to stop IIS,Please stop and then continue', 12);
        WriteLog('Unable to stop IIS');
        writeln;
      end
      else
      begin
        writeln('IIS is stopped.');
        WriteLog('IIS Status : Stopped')
      end;

      // end;
    end
    else if lowercase(iisresponse) = lowercase('N') then
    begin
      // Writeln('we recommend you to close the application');
      writeln('Please confirm once IIS or the corresponding application pools are stopped. Press ''Y'' to continue or ''N'' to skip.');
      write('AxInstaller> ');
      readln(iisresponse);
      writeln;
      if lowercase(iisresponse) = lowercase('N') then
      begin
        Console_write
          ('we cannot procced further and abort the installation process.', 12);
        WriteLog('IIS is still running,can''t proceed further');
        halt;
      end
      else if lowercase(iisresponse) = lowercase('Y') then
      begin
        // if IsIISRunning then
        // begin
        // Writeln('IIS still running Do you want to proceed.');
        // write('AxInstaller> ');
        // readln(iisresponse);
        // Writeln;
        // if lowercase(iisresponse) = lowercase('Y') then
        // begin
        // Writeln('Stopping IIS.');
        // Sleep(5000);
        // if IsIISRunning then // need to improvise
        // Writeln('Unable to stop IIS,Please stop and then continue')
        // else
        // Writeln('IIS is stopped.');
        // end;
        // if lowercase(iisresponse) = lowercase('N') then
        // begin
        // Writeln('We are aborting the installation...');
        // Writeln;
        // halt;;
        // end;           {Block needs to be handle}

        // end;
      end;
    end;
  end;
  // 22082024
  // else
  // begin
  // Write('IIS Status : ');
  // Console_write('Stopped', 10);
  // writeln;
  // WriteLog('IIS Status : Stopped');
  // end;
end;

function TMain.findfolder(sourcepath: string; destpath: string): string;
var
  folderArray: TArray<string>;

  outerfilearray, fileArray: TArray<string>;
  filecount, foldercount, I: integer;
  fulldestpath, fullsourcepath: String;
begin
  outerfilearray := TArray<string>(TDirectory.GetFiles(sourcepath));
  filecount := Length(outerfilearray);
  if filecount > 0 then
  begin
    fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
    fulldestpath := TRegEx.Replace(fulldestpath + '\' +
      ExtractFileName(outerfilearray[I]), '\\+', '\');
    if not CopyFile(PChar(outerfilearray[I]), PChar(fulldestpath), False) then
      RaiseLastOSError;
  end;
  folderArray := TArray<string>(TDirectory.GetDirectories(sourcepath));
  foldercount := Length(folderArray);
  if foldercount > 0 then
  begin
    for I := 0 to foldercount - 1 do
    begin
      fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
      fulldestpath := TRegEx.Replace(fulldestpath + '\' +
        ExtractFileName(folderArray[I]), '\\+', '\');
      // TPath.Combine(destpath, extractFileName(folderArray[I]));
      if not fileexists(fulldestpath) then
        ForceDirectories(fulldestpath);

      fullsourcepath := TRegEx.Replace(sourcepath, '\\+', '\');
      fullsourcepath := TRegEx.Replace(fullsourcepath + '\' +
        ExtractFileName(folderArray[I]), '\\+', '\');
      findfolder(fullsourcepath, fulldestpath);
    end;
  end;
  if foldercount = 0 then
  begin
    fileArray := TArray<string>(TDirectory.GetFiles(sourcepath));
    filecount := Length(fileArray);
    if filecount > 0 then
    begin
      for I := 0 to filecount - 1 do
      begin
        fulldestpath := TRegEx.Replace(destpath, '\\+', '\');
        fulldestpath := TRegEx.Replace(fulldestpath + '\' +
          ExtractFileName(fileArray[I]), '\\+', '\');
        if not CopyFile(PChar(fileArray[I]), PChar(fulldestpath), False) then
          RaiseLastOSError;
      end;
    end;

  end;
end;

// Appinit
Procedure TMain.AppInit;
begin
  tempDBConnectionName := '';
  MultiProjConnNames := '';
  bConnectTempDB := False;
  //AppDir := IncludeTrailingBackslash(GetCurrentDir);
  AppDir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
  // Initialize skip file list (manual-action-required files)
  SkipFileList := TStringList.Create;
  SkipFileList.CaseSensitive := False;

  SkipFileList.Add('appsettings.ini');
  SkipFileList.Add('appsettings.json');
  SkipFileList.Add('web.config');
  SkipFileList.Add('service_key.json');
  SkipFileList.Add('axapps.xml');
  SkipFileList.Add('axprops.xml');

  //Need to specifically handle this on Plugin Installation
  SkipFileList.Add('Appsettings.config');
  SkipFileList.Add('axiConfig.json');

  EnableDebug := True;
end;

procedure TMain.startplugin;
begin
  // Showmessage('App starts');
  AppInit;
  Welcome := TInItApp.Create;
  Welcome.WelcomeUser();
  // Showmessage('Welcomeuser ends');

  // if not Assigned(dbm) then
  // dbm := TDBManager.Create;
  // if Assigned(axprovider) then
  // FreeAndNil(axprovider);
  // Axprovider := TAxProvider.create(dbm);
  // database:=TDbConnect.Create;
  // if database.ConnecttoDB then
  // writeln('connected');
end;

procedure TMain.GetConfig;
begin
  Config := TConfig.Create;
  // Config.FillUserInfo();
  // config.readactiveconnection();  //[02072024]
  // Config.FillUserInfo();           //[01072024]
  // Config.ReadConfig();        //   [28062024]
  Config.IsConfigFound();
  writeln('config functionality working');

  // A := TUnIstallation.Create;      IsPublicInfoFound
  // A.checkplugininfo('plugin1');

  // B := TInstallation.Create;
  // B.IsPublicInfoFound();

end;

procedure TMain.ListPatch;
begin
  // GitHubURL:='https://api.github.com/repos/Paroksh11/Axpert/contents/';
  if not assigned(git) then
    git := TGitManager.Create;
  git.listOfPatches();
end;

procedure TMain.ListPlugin;
begin
  // GitHubURL:='https://api.github.com/repos/Paroksh11/Axpert/contents/';
  git := TGitManager.Create;
  git.listOfPlugins();
end;

// procedure TMain.InstallPlugin;
// var
// inst:Tinstallation;
// begin
// inst := Tinstallation.Create;
// // spath:='D:\Workspace\install_plugin\Win64\Debug\Plugin\Plugin1\Webfiles';
// inst.InstallPlugin(selectedPlugin);
// // inst.AddPlugin();
// // inst.Readplugininfo('Task Management');
// // inst.IsPublicInfoFound();
// end;

// procedure TMain.ConnectDbOperation;
// begin
// database := TDbConnect.Create;
// if pos('uninstall', lowercase(Command)) > 0 then
// database.connecttodb
// else
// database.DatabaseConnection();
//
// end;

// procedure TMain.UnInstallPlugin;
// begin
// unst := TUnIstallation.Create;
// database := TDbConnect.Create;
// database.ConnecttoDB;
// unst.startUninstallation(selectedPlugin);
// end;

procedure TMain.InIt;
begin
//  pluginLocalPath := GetCurrentDir + '\' + cPlugins + '\';
//  patchLocalPath := GetCurrentDir + '\' + cReleases + '\';
  AppDir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
  pluginLocalPath := AppDir + cPlugins + '\';
  patchLocalPath := AppDir+ cReleases + '\';
  // uConfig - SetPatchLocalPath - patchLocalPath value updated
  ForceDirectories(pluginLocalPath);
  ForceDirectories(patchLocalPath);

  bDBConDuring_Install := True;
end;

procedure TMain.WriteUserInstructions;
var
  FolderPath, FileNameWithPath, DateTimeStr, DisplayPath: string;
  ReadMePath: string;
begin
  if assigned(slUserInstructions) and (slUserInstructions.Count > 0) then
  begin
    FolderPath := IncludeTrailingPathDelimiter(RunWebCodePath) +
      'ManualActionRequired';
    ForceDirectories(FolderPath);

    DateTimeStr := FormatDateTime('yyyyMMdd_hhnnss', Now);
    FileNameWithPath := FolderPath + '\ManualActionsRequired_' +
      DateTimeStr + '.txt';

    slUserInstructions.SaveToFile(FileNameWithPath);

    writeln;
    writeln;
    writeln('Important Instruction :- ');
    DisplayPath := FileNameWithPath;
    while Pos('\\\\', DisplayPath) > 0 do
      DisplayPath := StringReplace(DisplayPath, '\\\\', '\', [rfReplaceAll]);

    writeln;
    writeln('   Manual actions required:');
    writeln;
    writeln('   - Some files contain custom settings and were not automatically updated by the AxInstaller.');
    writeln;
    writeln('   - Please review and apply the necessary changes manually as described in:');
    writeln('     ' + DisplayPath);
    writeln;

    if patchOrPlugin = 'Plugin' then
    begin
      ReadMePath := runwebcodepath + '\' + cPlugins + '\' + selectedplugin + '\' +
              selectedplugin + '-ReadMe.md';
      while Pos('\\', ReadMePath) > 0 do
          ReadMePath := StringReplace(ReadMePath, '\\', '\', [rfReplaceAll]);

      if FileExists(ReadMePath) then
      begin
//        writeln;
//        Console_write('IMPORTANT CONFIGURATION STEP', 14);
//        writeln;
//        writeln('-----------------------------------');
        writeln('   - Please refer to the installation guide below and follow the steps carefully to complete the configuration:');
        writeln('     ' +ReadMePath);
        writeln;
      end;
    end;
  end;
end;

function TMain.InitObj(): string;
begin

end;

function TMain.DestroyObj(): string;
begin

end;

function TMain.findLatestPatchAccordingToVersion(Version: string): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Length(Patcharray) - 1 downto 0 do
  begin
    if StartsText(Version + '/', Patcharray[I]) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TMain.findindex(MyArray: TArray<string>; Mystring: string): integer;
var
  Index: integer;
  Found: Boolean;
  I: integer;
begin
  Found := False;
  for I := Low(MyArray) to High(MyArray) do
  begin
    // if (lowercase(Mystring)='axpertweb/') or (lowercase(Mystring)='axpertdeveloper/') or (lowercase(Mystring)='axpertarm/')  then
    // begin
    // Result:=-1;
    // break;
    // end;
    if lowercase(MyArray[I]) = lowercase(Mystring) then
    begin
      Index := I;
      Found := True;
      Result := Index;
      Break;
    end;
  end;
  if Found = False then
    Result := -1;

end;

function TMain.HandleQuitCommand(Command: string): string;
begin
  // 22082024
  // if not((lowercase(Command) = 'y') or (lowercase(Command) = 'n')) then
  // begin
  // writeln('Give response in ''y'' or in ''n'' only. ');
  // writeln;
  // write('AxInstaller> ');
  // readln(Command);
  // HandleQuitCommand(Command);
  // end;
  // if lowercase(Command) = 'y' then
  // begin
  // writeln('Starting IIS...');
  // StartIIS;
  // Sleep(15000);
  // If IsIISRunning then
  // writeln('IIS is running.')
  // else
  // writeln('Unable to start IIS, Please start it manaully if required.');

  // UpdateLogObj;
  // DestroyLogObj;
  // console_write('Thank''s for using axpert installer...!!!', 14);
  // writeln;
  //
  // halt;
  // end;
  // if lowercase(Command) = 'n' then
  // begin
  // UpdateLogObj;
  // DestroyLogObj;
  // console_write('Thank''s for using axpert installer...!!!', 14);
  // writeln;
  //
  // halt;
  // end;

end;

// LoadBulkInstallFile
(*
  bulkinstall install.txt
  or
  bulkinstall "C:\Agile\install.txt"
*)
function LoadBulkInstallFile(const CommandLine: string): TStringList;
var
  SpacePos: integer;
  Param: string;
  Filename: string;
  FileList: TStringList;
begin
  // Find position of first space (after command "bulkinstall")
  SpacePos := Pos(' ', CommandLine);
  if SpacePos = 0 then
  begin
    Console_write('Invalid command. Filename not found.', 12);
    writeln;
    // raise Exception.Create('Invalid command. Filename not found.');
  end;

  // Extract the second part (filename), trim leading/trailing spaces
  Param := Trim(Copy(CommandLine, SpacePos + 1, Length(CommandLine)));

  // Handle quotes if any
  if (Length(Param) >= 2) and (Param[1] = '"') and (Param[Length(Param)] = '"')
  then
    Filename := Copy(Param, 2, Length(Param) - 2)
  else
    Filename := Param;

  // Check if file exists
  if not fileexists(Filename) then
  begin
    Console_write('Error: File not found ' + Filename, 12);
    writeln;
    // raise Exception.CreateFmt('File not found: %s', [Filename]);
  end;

  // Load contents into TStringList
  FileList := TStringList.Create;
  try
    FileList.LoadFromFile(Filename);
    Result := FileList;
  except
    FileList.Free;
    raise;
  end;
end;

(*
  function InsertWebTag(const InputStr: string): string;
  var
  Words: TArray<string>;
  i: Integer;
  begin
  Words := InputStr.Split([' ']); // Split the string by space

  if Length(Words) < 3 then
  Exit(InputStr); // If less than 3 words, return as is

  // Insert '-web' after the 3rd word
  SetLength(Words, Length(Words) + 1); // Increase array size
  for i := High(Words) - 1 downto 4 do
  Words[i] := Words[i - 1]; // Shift elements to the right

  Words[3] := '-web'; // Insert at 4th position (0-based index)

  Result := String.Join(' ', Words); // Join back to a single string
  end;
*)

function InsertWebTag(const InputStr: string): string;
var
  Words: TStringList;
  I: integer;
begin
  Words := TStringList.Create;
  try
    Words.Delimiter := ' ';
    Words.StrictDelimiter := True;
    Words.DelimitedText := InputStr;

    // if Words.Count >= 3 then
    // Words.Insert(3, '-web') //Insert at position 4 (0-based index)
    //
    // else
    // Words.Add('-web');  //If fewer than 3 words, just add it at the end
    if Words.Count = 4 then
      Words.Insert(3, '-web')
    else if Words.Count = 5 then
      Words.Insert(4, '-web') // When <from> and  <to> are given
    else
      Words.Add('-web');

    Result := Words.DelimitedText.Replace(',', ' ');
    // Convert to space-separated string
  finally
    Words.Free;
  end;
end;

// RemoveWebTag
function RemoveWebTag(const InputStr: string): string;
var
  Words: TStringList;
  I: integer;
begin
  Words := TStringList.Create;
  try
    Words.Delimiter := ' ';
    Words.StrictDelimiter := True;
    Words.DelimitedText := InputStr;

    // Remove any occurrence of -web (case-insensitive)
    for I := Words.Count - 1 downto 0 do
    begin
      if SameText(Words[I], '-web') then
        Words.Delete(I);
    end;

    Result := Words.DelimitedText.Replace(',', ' ');
    // Replace commas with space
  finally
    Words.Free;
  end;
end;

function TMain.ReloadConfig(): string;
begin
  IsConfigReload := True;
  try
    writeln;
    writeln('Reloading the configuration.....');

    if not assigned(Config) then
      Config := TConfig.Create;

    Config.readactiveconnection;
    Config.readReleasePasswordandGitUrl();
    //Config.SetPatchLocalPath;
    writeln('Configuration reloaded.');
    writeln;
  finally
    IsConfigReload := False;
  end;
end;

function TMain.parseCommand(Command: string): string;
var
  idx, I, J, A, B, C, L, F, G, M, Z, T, Y, lengthListPatch: integer;
  commandPResent: Boolean;
  slashIndex, lengthList, currentpatchindexaccdoversion: integer;
  commandWord: string;
  splitedversion, splitedpatch, splitedSchema: string;
  commandstrlist: TStringList;
  curpatchindex, installpatchindex: integer;
  currentpatch, plgname, plgword, res, currentpasswordres, newpasswordres,
    backuppath: string;
  currentpatchnumber, selectedpatchnumber: integer;
  patchfound, plugininstalled, upgradeflag: Boolean;
  spatch, sversion, editablepatchname, editablepatchname1,
    editablepatchname2: string;
  fullsourceurl, fulltargeturl, editableversion: string;
  encryptedpass, decryptedpass, patc, iisresponse: string;
  webstatus, splitedpatch2, splitedpatch1: String;
  splitedpatch1found, splitedpatch2found, splitedversionfound,
    bSilentInstall: Boolean;
  splitedpatch1index, splitedpatch2index: integer;
  userconfirmation, dbconnectionname: string;
  plugname, verName, PatcName, CommandFromFile, Act_Active_Conn: string;

  BulkCommandList: TStringList;

  // New identifier for new bulkinstall
  schemaList: TStringList;

  // Already current active connection db is connected
  // This tmpDBConnect will connect to the user specified connection parallelly
  // This needs to be handled properly | Check here if there is any issue with DB rountines
  // tmpDBConnect : TDbConnect; | Not required now
  // pluginnameFlag: Boolean;
begin
  try
    try
      commandstrlist := nil;
      BulkCommandList := nil;
      plugininstalled := False;
      bSilentInstall := False;
      CommandFromFile := '';
      Act_Active_Conn := '';
      commandWord := Command;
      slUserInstructions.clear;
      if Command = '' then
      begin
        // writeln('AxInstaller> ');
        // readln(Command);

        // Command := instBeforeReadCommand;
        // parseCommand(Command);

        write('AxInstaller> ');
        readln(Command);
        parseCommand(Command);
      end
      else if (Pos('echo', lowercase(Command)) <> 0) then
      begin
        // writeln('AxInstaller> ');
        // readln(Command);
        writeln('echo command found');
        writeln(Command);
        write('AxInstaller> ');
        readln(Command);
        parseCommand(Command);
      end
      else if (Pos('debug', lowercase(Command)) <> 0) then
      begin
        if (Pos('on', lowercase(Command)) <> 0) then
        begin
          EnableDebug := True;
          writeln('Debug mode Enabled');
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          if Command = '' then
            parseCommand(Command)
          else
            parseCommand(Command);
        end
        else if (Pos('off', lowercase(Command)) <> 0) then
        begin
          EnableDebug := False;
          writeln('Debug mode Disabled');
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          if Command = '' then
            parseCommand(Command)
          else
            parseCommand(Command);
        end
        else
        begin
          writeln('Invalid Input');
          // writeln;
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end;

      end
      else if Pos('show', lowercase(commandWord)) <> 0 then
      begin
        if Pos('current', lowercase(commandWord)) <> 0 then
        begin
          if Pos('release', lowercase(commandWord)) <> 0 then
          begin
            writeln;
            write('Current Version : ');
            Console_write(currentversionname, 10);
            writeln;
            write('Current Release   : ');
            Console_write(currentPatchname, 10);
            writeln;
          end
          else
          begin
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;

          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end
        else
        begin
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end;
      end
      else if lowercase(Command) = 'quit' then
      begin
        Console_write('Thank''s for using axpert installer...!!!', 14);
        writeln;
        writeln;
        UpdateLogObj;
        DestroyLogObj;
        //Console_write('Thank''s for using axpert installer...!!!', 14);
        writeln;
        //
        halt;
        // if Not IsIISRunning then
        // begin
        // writeln('IIS is not running. Do you want to start the IIS ? Press ''Y'' to start , ''N'' to skip.');
        // // writeln;
        // write('AxInstaller> ');
        // readln(iisresponse);
        // handlequitcommand(iisresponse);
        // end;
        // if not ((lowercase(Command) = 'y') or (lowercase(Command) = 'n')) then
        // begin
        // writeln('Give response in ''y'' or in ''n'' only. ');
        // writeln;
        // write('AxInstaller> ');
        // readln(Command);
        // handlequitcommand(command);
        // end;
        // if lowercase(Command) = 'y' then
        // begin
        // writeln('Starting IIS...');
        // StartIIS;
        // Sleep(8000);
        // If IsIISRunning then
        // writeln('IIS is running.')
        // else
        // writeln('Unable to start IIS, Please start it manaully if required.');
        // end;
        // UpdateLogObj;
        // DestroyLogObj;
        // console_write('Thank''s for using axpert installer...!!!', 14);
        // writeln;
        //
        // halt;
        // end;
      end
      else if (lowercase(Command) = 'help') or (lowercase(Command) = 'h') then
      begin
        HandleHelpCommand();
      end
      // slashIndex := pos('/', Command);
      // commandWord := copy(Command, slashIndex + 1, length(Command));

      (*
        21/11/2024 -
        release used instead of patches
        so this command needs to be checked or handled accordingly
        For now commenting it
      *)

      // else if pos('release', lowercase(Command)) <> 0 then
      // begin
      //
      // writeln('Required password to use release command');
      // write(' Password : ');
      // readln(decryptedpass);
      // // decryptedpass:=dbm.gf.EncryptFldValue(decryptedpass, 't');
      // if decryptedpass = adminpwd then
      // begin
      // // writeln;
      // // writeln('Do you want to change password ?');
      // // writeln('Please give response in ''y'' or ''n'' only.');
      // // readln(res);
      // // if lowercase(res) = 'y' then
      // // begin
      // // writeln;
      // // writeln('Admin privileges are required. Please enter the current admin password to proceed.');
      // // readln(currentpasswordres);
      // // if currentpasswordres = adminpwd then
      // // begin
      // // writeln;
      // // writeln('Please enter the new password to complete the update.');
      // // WriteLog('Current password is corect.');
      // // WriteLog('Validtion successfull');
      // // readln(newpasswordres);
      // // if not assigned(Config) then
      // // Config := TConfig.Create;
      // // if not assigned(dbm) then
      // // dbm := TDbManager.Create;
      // // encryptedpass := dbm.gf.EncryptFldValue(newpasswordres, 't');
      // // Config.changeadminpassword(encryptedpass);
      // // Config.readReleasePasswordandGitUrl;
      // // writeln;
      // // Console_write('Admin password changed successfully.,10');
      // // writeln;
      // // end
      // // else
      // // begin
      // // writeln;
      // // writeln('The Admin password is incorrect. Please enter the correct password to proceed with the update.');
      // /// /            writeln;
      // /// /            write('AxInstaller> ');
      // /// /            readln(Command);
      // // Command:=instBeforeReadCommand;
      // // parseCommand(Command);
      // // end;
      // // end;
      // handlereleasecommand(Command);
      // end
      // else
      // begin
      // WriteLog('Wrong password,unable to proceed with release command.');
      // Console_write
      // ('Wrong password,unable to proceed with release command.', 12);
      // writeln;
      // // writeln;
      // // write('AxInstaller> ');
      // // readln(Command);
      // Command := instBeforeReadCommand;
      // parseCommand(Command);
      // end;
      //
      // end
      // // else if pos('listpatch', commandWord) <> 0 then
      // // begin
      // // if not assigned(git) then
      // // git := TGitManager.Create;
      // // if length(versionarray) = 0 then
      // // git.initversion();
      // // lengthListPatch := length('listpatch');
      // // patchversion := copy(commandWord, lengthListPatch + 1,
      // // length(commandWord));
      // // patchversion := 'Version ' + trim(patchversion);
      // // for M := Low(versionarray) to High(versionarray) do
      // // begin
      // // if lowercase(versionarray[M]) = lowercase(patchversion) then
      // // begin
      // // selectedversion := versionarray[M];
      // // writeln;
      // // HandleListCommand('patch');
      // // end;
      // // end;
      // // if selectedversion = '' then
      // // begin
      // // writeln;
      // // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
      // // writeln;
      // // write('AxInstaller> ');
      // // readln(Command);
      // // parseCommand(Command);
      // // end;
      // // end
      // // else if pos('listversions', lowercase(commandWord)) <> 0 then
      // // begin
      // // if not assigned(git) then
      // // git := TGitManager.Create;
      // // if length(versionarray) = 0 then
      // // git.initversion();
      // // try
      // // git.listOfVersions();
      // /// /        freeandnil(git);
      // // except
      // // on E: Exception do
      // // begin
      // // writeln;
      // // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
      // // writeln;
      // // write('AxInstaller> ');
      // // readln(Command);
      // // parseCommand(Command);
      // // end;
      // //
      // // end;
      // // end
      else if Pos('config', lowercase(Trim(commandWord))) = 1 then
      begin
        try
          HandleAllConfigCommand(commandWord);
        except
          on E: Exception do
          begin
            writeln('Error: ' + E.Message);
            readln;
          end;

        end;
      end
      else if Pos('list', lowercase(Trim(commandWord))) = 1 then
      begin
        if Pos('plugins', lowercase(commandWord)) <> 0 then
        begin
          if not assigned(git) then
            git := TGitManager.Create;
          if Length(pluginarray) = 0 then
            git.initplugin();
          if Pos('plugins', lowercase(commandWord)) <> 0 then
            HandleListCommand('plugin')
          else
          begin
            writeln;
            writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;
        end
        else if Pos('versions', lowercase(commandWord)) <> 0 then
        begin
          if not assigned(git) then
            git := TGitManager.Create;
          if Length(versionarray) = 0 then
            git.createversionarray();
          try
            git.listOfVersions();
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
            // freeandnil(git);
          except
            on E: Exception do
            begin
              writeln;
              writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
              // writeln;
              // write('AxInstaller> ');
              // readln(Command);
              Command := instBeforeReadCommand;
              parseCommand(Command);
            end;

          end;
        end
        else if Pos('release', lowercase(commandWord)) <> 0 then
        begin
          if not assigned(git) then
            git := TGitManager.Create;
          if Length(versionarray) = 0 then
            git.initversion();
          lengthListPatch := Length('listrelease');
          patchversion := Copy(commandWord, lengthListPatch + 2,
            Length(commandWord));
          patchversion := 'Version ' + Trim(patchversion);
          for M := Low(versionarray) to High(versionarray) do
          begin
            if lowercase(versionarray[M]) = lowercase(patchversion) then
            begin
              selectedversion := versionarray[M];
              writeln;
              HandleListCommand('release');
            end;
          end;
          if selectedversion = '' then
          begin
            writeln;
            writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;
        end
        else
        begin
          writeln;
          writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end;
      end
      else if Pos('-web', lowercase(Command)) <> 0 then
      begin
        if Pos('bulkinstall', lowercase(Command)) <> 0 then
        begin
          try
            // ProceedDowngrade := False
            bPullStructures := True;
            Act_Active_Conn := activeconnection;

            // bDBConDuring_Install := True;
            bSilentInstall := True;
            // bulkinstall
            BulkCommandList := TStringList.Create;
            commandWord := RemoveWebTag(Command);
            // remove -web tag from command
            commandstrlist := TStringList.Create;
            // new block of code for bulkinstall
            try
              commandstrlist.Delimiter := ' ';
              commandstrlist.StrictDelimiter := True;
              commandstrlist.QuoteChar := '"';
              commandstrlist.DelimitedText := commandWord;

              // bulkinstall <version> <release> <install.txt>
              if (commandstrlist.Count = 4) and
                (lowercase(ExtractFileExt(commandstrlist[3])) = '.txt') then
              begin
                BulkCommandList.LoadFromFile(commandstrlist[3]);

                if (BulkCommandList.Count = 1) and
                  (Pos(',', BulkCommandList[0]) > 0) then
                begin
                  // Single line with comma-separated schemas
                  schemaList := TStringList.Create;
                  try
                    schemaList.Delimiter := ',';
                    schemaList.StrictDelimiter := True;
                    schemaList.DelimitedText := BulkCommandList[0];

                    BulkCommandList.clear;
                    for idx := 0 to schemaList.Count - 1 do
                    begin
                      dbconnectionname := Trim(schemaList[idx]);
                      if IsConnExistsInAxApps(dbconnectionname) then
                      begin
                        // Build old-style command line
                        BulkCommandList.Add('Install ' + commandstrlist[1] + ' '
                          + commandstrlist[2] + ' ' + dbconnectionname);
                      end
                      else
                        Console_write('Schema ' + dbconnectionname +
                          ' does not exist. Skipping...', 4);
                    end;
                  finally
                    schemaList.Free;
                  end;
                end
                else
                begin
                  // Multi-line file
                  for idx := 0 to BulkCommandList.Count - 1 do
                  begin
                    dbconnectionname := Trim(BulkCommandList[idx]);
                    if (dbconnectionname <> '') and
                      IsConnExistsInAxApps(dbconnectionname) then
                      BulkCommandList[idx] := 'Install ' + commandstrlist[1] +
                        ' ' + commandstrlist[2] + ' ' + dbconnectionname
                    else if dbconnectionname <> '' then
                      Console_write('Schema ' + dbconnectionname +
                        ' does not exist. Skipping...', 4);
                  end;
                end;
              end
              else
              begin
                // bulkinstall <version> <from_release> <to_release> <install.txt>
                if (commandstrlist.Count >= 5) and
                  (lowercase(ExtractFileExt(commandstrlist[4])) = '.txt') then
                begin
                  BulkCommandList.LoadFromFile(commandstrlist[4]);

                  if (BulkCommandList.Count = 1) and
                    (Pos(',', BulkCommandList[0]) > 0) then
                  begin
                    // Single line with comma-separated schemas
                    schemaList := TStringList.Create;
                    try
                      schemaList.Delimiter := ',';
                      schemaList.StrictDelimiter := True;
                      schemaList.DelimitedText := BulkCommandList[0];

                      BulkCommandList.clear;
                      for idx := 0 to schemaList.Count - 1 do
                      begin
                        dbconnectionname := Trim(schemaList[idx]);
                        if IsConnExistsInAxApps(dbconnectionname) then
                        begin
                          BulkCommandList.Add('Install ' + commandstrlist[1] +
                            ' ' + commandstrlist[2] + ' ' + commandstrlist[3] +
                            ' ' + dbconnectionname);
                        end
                        else
                          Console_write('Schema ' + dbconnectionname +
                            ' does not exist. Skipping...', 4);
                      end;
                    finally
                      schemaList.Free;
                    end;
                  end
                  else
                  begin
                    // Multi-line file
                    for idx := 0 to BulkCommandList.Count - 1 do
                    begin
                      dbconnectionname := Trim(BulkCommandList[idx]);
                      if (dbconnectionname <> '') and
                        IsConnExistsInAxApps(dbconnectionname) then
                        BulkCommandList[idx] := 'Install ' + commandstrlist[1] +
                          ' ' + commandstrlist[2] + ' ' + commandstrlist[3] +
                          ' ' + dbconnectionname
                      else if dbconnectionname <> '' then
                        Console_write('Schema ' + dbconnectionname +
                          ' does not exist. Skipping...', 4);
                    end;
                  end;
                end
                else
                begin
                  // Old File handling code fallback
                  BulkCommandList := LoadBulkInstallFile(commandWord);
                end;
              end;
            finally
              commandstrlist.Free;
            end;
            // Old Code for Bulkinstall with File Validation
            // BulkCommandList := LoadBulkInstallFile(commandWord);
            if assigned(BulkCommandList) and (BulkCommandList.Count > 0) then
            begin
              for idx := 0 to BulkCommandList.Count - 1 do
              begin
                try
                  // begin
                  try
                    CommandFromFile := BulkCommandList[idx];
                    commandWord := CommandFromFile;

                    // in file -web not needed , we add it here
                    // CommandFromFile := CommandFromFile + ' -web';

                    CommandFromFile := InsertWebTag(CommandFromFile);
                    // insert -web

                    dbconnectionname := '';
                    commandstrlist := TStringList.Create;
                    commandstrlist.QuoteChar := '"';
                    commandstrlist.Delimiter := ' ';
                    commandstrlist.DelimitedText := CommandFromFile; // Command;
                    commandstrlist.StrictDelimiter := True;

                    splitedversion := commandstrlist[1]; // Version No
                    splitedpatch1 := commandstrlist[2]; // From patch
                    splitedpatch2 := commandstrlist[3]; // To pacth
                    webstatus := commandstrlist[4]; // -Web
                    if ((splitedpatch1 <> '') and (splitedpatch2 <> '')) and
                      (splitedpatch2 <> '-web') then
                    begin
                      continuousinstallation := True;
                    end;

                    if (commandstrlist.Count = 6) and
                      ( { commandstrlist[4] } webstatus = '-web') then
                    begin
                      dbconnectionname := commandstrlist[5];
                      // optional (db connection name)
                      if Not IsConnExistsInAxApps(dbconnectionname) then
                      begin
                        write('The given connection ' + dbconnectionname +
                          ' doesn''t exists.');
                        writeln;
                        // writeln;
                        // write('AxInstaller> ');
                        // readln(Command);

                        // Skip and continue
                        Continue;
                        // Command := instBeforeReadCommand;
                        // parseCommand(Command);
                      end;
                      activeconnection := dbconnectionname; // Act_Active_Conn;
                      HandleAllConfigCommand
                        ('config set ' + activeconnection, True);
                      continuousinstallation := True;
                    end;

                    // splitedversion := commandstrlist[1]; // Version No
                    // splitedpatch1 := commandstrlist[2]; // From patch
                    // splitedpatch2 := commandstrlist[3]; // To pacth
                    // webstatus := commandstrlist[3]; // -Web
                    if (commandstrlist.Count = 5) and
                      (splitedpatch2 { commandstrlist[3] } = '-web') then
                    begin
                      dbconnectionname := commandstrlist[4];
                      // optional (db connection name)
                      if Not IsConnExistsInAxApps(dbconnectionname) then
                      begin
                        write('The given connection ' + dbconnectionname +
                          ' doesn''t exists.');
                        writeln;
                        // writeln;
                        // write('AxInstaller> ');
                        // readln(Command);

                        // Skip and continue
                        Continue;
                        // Command := instBeforeReadCommand;
                        // parseCommand(Command);
                      end;
                      continuousinstallation := False;
                      // continuousinstallation := True;
                      activeconnection := dbconnectionname; // Act_Active_Conn;
                      HandleAllConfigCommand
                        ('config set ' + activeconnection, True);
                    end;

                    // end;
                  Except
                    on E: Exception do
                    begin
                      splitedversion := '';
                      splitedpatch1 := '';
                      splitedpatch2 := '';
                      continuousinstallation := False;
                      // dbconnectionname := commandstrlist[4]; // optional (db connection name)
                      // if Not IsConnExistsInAxApps(dbconnectionname) then
                      // begin
                      // write('The given connection '+dbconnectionname+' doesn''t exists.');
                      // writeln;
                      // writeln;
                      // write('AxInstaller> ');
                      // readln(Command);
                      // parseCommand(Command);
                      // end;
                    end;
                  end;
                finally
                  // splitedversion := '';
                  // splitedpatch1 := '';
                  // splitedpatch2 := '';
                  commandstrlist.Free;
                end;
                if continuousinstallation = True then
                begin
                  splitedversion := 'Version ' + splitedversion;
                  // if not assigned(git) then
                  // git := TGitManager.Create;
                  // if Length(versionarray) = 0 then
                  // git.initversion();
                  // if Length(Patcharray) = 0 then
                  // git.createpatcharray();
                  splitedversionfound := False;
                  writeln;
                  write('Current installed Version is : ');
                  Console_write(currentversionname + '/' +
                    currentPatchname, 10);
                  writeln;
                  writeln;
                  // for I := Low(versionarray) to High(versionarray) do
                  // begin
                  verName := IsVersionExists(splitedversion);
                  if verName <> '' { versionarray[I] = splitedversion } then
                  begin
                    splitedversionfound := True;
                    verName := '';
                    // for T := Low(Patcharray) to High(Patcharray) do
                    // begin
                    // if lowercase(Patcharray[T])
                    // = lowercase(versionarray[I] + '/' + splitedpatch1) then
                    PatcName :=
                      IsPatchExists
                      (lowercase(splitedversion + '/' + splitedpatch1));
                    if PatcName <> '' then
                    begin
                      splitedpatch1found := True;
                      PatcName := '';

                    end;
                    // if lowercase(Patcharray[T])
                    // = lowercase(versionarray[I] + '/' + splitedpatch2) then
                    PatcName :=
                      IsPatchExists
                      (lowercase(splitedversion + '/' + splitedpatch2));
                    if PatcName <> '' then
                    begin
                      splitedpatch2found := True;
                      PatcName := '';
                    end;
                    // if splitedpatch2found and splitedpatch1found then
                    // Break;
                  end;
                  // end;
                  // end;

                  if splitedpatch2found and splitedpatch1found then
                  begin
                    curpatchindex :=
                      findpatchindex(currentversionname + '/' +
                      currentPatchname);
                    splitedpatch1index :=
                      findpatchindex(splitedversion + '/' + splitedpatch1);
                    splitedpatch2index :=
                      findpatchindex(splitedversion + '/' + splitedpatch2);
                    // if ((curpatchindex > splitedpatch1index) and (splitedpatch2index < curpatchindex))
                    // or (splitedpatch1index > splitedpatch2index) then
                    // begin
                    /// /                      writeln;
                    /// /                      write('You have applied ');
                    /// /                      console_write(selectedpatch, 14);
                    /// /                      writeln;
                    /// /                      write(' already.');
                    // writeln;
                    // console_write('installation cannot be done.May be ''From'' and ''To'' patch are not given properly or installation is done already', 12);
                    // writeln;
                    // writeln;
                    // write('AxInstaller> ');
                    // readln(Command);
                    // parseCommand(Command);
                    // end
                    // if ((curpatchindex > splitedpatch2index) or (curpatchindex = splitedpatch2index)) or
                    // ((curpatchindex > splitedpatch1index) or (curpatchindex = splitedpatch1index)) then
                    // Commenting this condition on 18/09/2025 to allow AxInstaller to allow instllation on higher patches
                    // if (splitedpatch2index <= curpatchindex) and
                    // (splitedpatch1index <= splitedpatch2index) and
                    // (splitedpatch1index <= curpatchindex) then
                    // ((curpatchindex > splitedpatch1index) or (curpatchindex = splitedpatch1index)) then
                    // New condition added to accept the upgrade patch installation
                    if (splitedpatch2index >= curpatchindex) and
                      (splitedpatch1index <= splitedpatch2index) then
                    begin
                      writeln;
                      Console_write
                        ('You are requested to execute scripts and import structures from the "'
                        + Patcharray[splitedpatch1index] + '" to the "' +
                        Patcharray[splitedpatch2index] +
                        '" on the selected connection/schema.', 12);
                      Console_write
                        ('This will overwrite any existing changes in the selected connection/schema.',
                        12);
                      writeln;
                      // readln(userconfirmation);
                      if bSilentInstall { lowercase(userconfirmation) = 'y' }
                      then
                      begin
                        try
                          // writeln;
                          // write('Current installed Version is : ');
                          // Console_write(currentversionname + '/' + currentPatchname, 10);
                          // // nned to add selected patch
                          // writeln;
                          // writeln;

                          // Connect to given db connection if dbconnectionname <> ''
                          if dbconnectionname <> '' then
                          begin
                            bConnectTempDB := True;
                            tempDBConnectionName := dbconnectionname;
                            if assigned(dbc) then
                              FreeAndNil(dbc);
                            // dbc (database) connection will be established while calling HandleStructureInstallation
                          end;

                          for Y := splitedpatch1index to splitedpatch2index do
                          begin
                            if lowercase(splitedversion)
                              = lowercase(currentversionname) then
                            begin
                              selectedversion := splitedversion;
                              // versionarray[I];
                              selectedpatch := Patcharray[Y];
                              writeln;
                              writeln(Uppercase('Installing ' + Patcharray[Y]));
                              writeln('==============================');
                              writeln;
                              HandleStructureInstallation(Patcharray[Y]);
                              if connectionstatus then
                              begin
                                commandstrlist.QuoteChar := '"';
                                commandstrlist := TStringList.Create;
                                commandstrlist.Delimiter := '/';
                                commandstrlist.DelimitedText := selectedpatch;
                                splitedpatch := commandstrlist[2];
                                commandstrlist.Free;
                                // Config.updatecurrentpatch(splitedversion, splitedpatch);
                                // Config := TConfig.Create;
                                // currentversionname := splitedversion;
                                // currentPatchname := splitedpatch;
                                // currentPatchname := splitedpatch;
                                patchOrPlugin := '';
                                writeln;
                                writeln(' INSTALLATION SUMMARY OF ' +
                                  Uppercase(splitedversion + '/' +
                                  splitedpatch));
                                writeln('============================================');

                                write('  -');
                                Console_write(selectedpatch, 3);
                                write(' installation completed without errors.');
                                WriteLog('installation completed without errors for '
                                  + Patcharray[T]);
                                writeln;
                                writeln;
                                // break
                              end;
                            end;
                          end;
                        finally
                          bConnectTempDB := False;
                          tempDBConnectionName := '';
                          if assigned(dbc) then
                            FreeAndNil(dbc);
                        end;
                        // Break;
                      end
                      else
                      begin
                        writeln;
                        Console_write
                          ('The script and structure installation has been aborted.',
                          12);
                        writeln;
                        WriteLog('The script and structure installation has been aborted.');
                        writeln;
                        // writeln;
                        // write('AxInstaller> ');
                        // readln(Command);

                        // Skip and continue
                        Continue;
                        // Command := instBeforeReadCommand;
                        // parseCommand(Command);
                      end;
                    end
                    // Commenting this else block on 18/09/2025 to install lower patches with user confirmation
                    // else
                    // begin
                    // if splitedpatch2index > curpatchindex then
                    // begin
                    // writeln;
                    // Console_write('The "To release" (' + splitedpatch2 +
                    // ') number is greater than the current release (' +
                    // currentPatchname +
                    // ')  number. Command cannot be processed.', 12);
                    // writeln;
                    // WriteLog('The "To release" (' + splitedpatch2 +
                    // ') number is greater than the current release (' +
                    // currentPatchname +
                    // ') number. Command cannot be processed.');
                    // end
                    // else if splitedpatch1index > splitedpatch2index then
                    // begin
                    // writeln;
                    // Console_write('The "From release" (' + splitedpatch1 +
                    // ') number is greater than the "To release" (' +
                    // splitedpatch2 +
                    // ') number. Command cannot be processed.', 12);
                    // writeln;
                    // WriteLog('The "From release" (' + splitedpatch1 +
                    // ') number is greater than the "To release" (' +
                    // splitedpatch2 +
                    // ') number. Command cannot be processed.');
                    // end
                    // else if splitedpatch1index > curpatchindex then
                    // begin
                    // writeln;
                    // Console_write('The "From release" (' + splitedpatch1 +
                    // ') number is greater than the current release (' +
                    // currentPatchname +
                    // ') number. Command cannot be processed.', 12);
                    //
                    // writeln;
                    // WriteLog('The "From release" (' + splitedpatch1 +
                    // ') number is greater than the current release (' +
                    // currentPatchname +
                    // ') number. Command cannot be processed.');
                    // end;
                    else
                    begin
                      // Downgrade path: ask for user's confirmation
                      writeln;
                      Console_write
                        ('Warning: You are attempting to install an older release range ('
                        + splitedpatch1 + ' → ' + splitedpatch2 +
                        ') while current is at ' + currentPatchname + '.', 14);
                      Console_write
                        ('Downgrading may overwrite newer structures and cause issues.',
                        12);
                      write('Do you want to continue? (y/n): ');
                      readln(userconfirmation);

                      if lowercase(userconfirmation) = 'y' then
                      begin
                        // reuse the same install loop
                        for Y := splitedpatch1index to splitedpatch2index do
                        begin
                          if lowercase(splitedversion)
                            = lowercase(currentversionname) then
                          begin
                            selectedversion := splitedversion;
                            selectedpatch := Patcharray[Y];
                            writeln;
                            writeln(Uppercase('Installing ' + Patcharray[Y]));
                            writeln('==============================');
                            writeln;

                            HandleStructureInstallation(Patcharray[Y]);

                            if connectionstatus then
                            begin
                              commandstrlist := TStringList.Create;
                              commandstrlist.Delimiter := '/';
                              commandstrlist.QuoteChar := '"';
                              commandstrlist.DelimitedText := selectedpatch;
                              splitedpatch := commandstrlist[2];
                              commandstrlist.Free;

                              patchOrPlugin := '';
                              writeln;
                              writeln(' INSTALLATION SUMMARY OF ' +
                                Uppercase(splitedversion + '/' + splitedpatch));
                              writeln('============================================');
                              write('  -');
                              Console_write(selectedpatch, 3);
                              write(' installation completed without errors.');
                              WriteLog('installation completed without errors for '
                                + Patcharray[Y]);
                              writeln;
                              writeln;
                            end;
                          end;
                        end;
                      end
                      else
                      begin
                        writeln;
                        Console_write
                          ('Downgrade installation aborted by user.', 12);
                        writeln;
                        Continue;
                      end;
                      // end;
                      //
                      // end;
                      //
                      // end;


                      // else
                      // begin
                      // writeln;
                      // write('AxInstaller> ');
                      // readln(Command);
                      // parseCommand(Command);
                      // end;
                      // break;
                      // end;

                    end;
                    // Break;
                  end
                  else
                  begin
                    if not splitedpatch1found then
                    begin

                      Console_write('The requested release "' + splitedpatch1 +
                        '" not available.', 12);
                      writeln;
                    end
                    else if not splitedpatch2found then
                    begin

                      Console_write('The requested release "' + splitedpatch2 +
                        '" not available.', 12);
                      writeln;
                    end;
                  end;
                  if splitedversionfound = False then
                  begin
                    writeln;
                    Console_write
                      ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
                      12);
                    writeln;
                  end;

                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);
                  // Skip and continue
                  Continue;
                  // Command := instBeforeReadCommand;
                  // parseCommand(Command);

                end;

                if continuousinstallation = False then
                begin
                  commandstrlist := TStringList.Create;
                  commandstrlist.Delimiter := ' ';
                  commandstrlist.QuoteChar := '"';
                  commandstrlist.DelimitedText := commandWord; // Command;
                  splitedversion := commandstrlist[1];
                  splitedpatch := commandstrlist[2];
                  commandstrlist.Free;
                  // splitedpatch:='Patch'+splitedpatch;
                  splitedversion := 'Version ' + splitedversion;
                  if not assigned(git) then
                    git := TGitManager.Create;
                  if Length(versionarray) = 0 then
                    git.initversion();
                  if Length(Patcharray) = 0 then
                    git.createpatcharray();
                  for I := Low(versionarray) to High(versionarray) do
                  begin
                    if versionarray[I] = splitedversion then
                    begin
                      for T := Low(Patcharray) to High(Patcharray) do
                      begin
                        if lowercase(Patcharray[T])
                          = lowercase(versionarray[I] + '/' + splitedpatch) then
                        begin
                          curpatchindex :=
                            findpatchindex(currentversionname + '/' +
                            currentPatchname);
                          installpatchindex :=
                            findpatchindex(splitedversion + '/' + splitedpatch);
                          // if curpatchindex > installpatchindex then
                          // begin
                          // writeln;
                          // write('You have applied ');
                          // console_write(selectedpatch, 14);
                          // writeln;
                          // write(' already.');
                          // writeln;
                          // console_write('downgrade installation cannot be done', 12);
                          // writeln;
                          // writeln;
                          // write('AxInstaller> ');
                          // readln(Command);
                          // parseCommand(Command);
                          // end
                          // if curpatchindex = installpatchindex then
                          // begin
                          // if (installpatchindex <= curpatchindex) then  --> Commenting this on 18/09/2025 to make the AxInstaller to install greater patches
                          if (installpatchindex >= curpatchindex) then
                          begin
                            writeln;
                            userconfirmation := '';
                            Console_write
                              ('You are requested to execute scripts and import structures from the release "'
                              + splitedpatch +
                              '" on the selected connection/schema.', 12);
                            Console_write
                              ('This will overwrite any existing changes in the selected connection/schema. ',
                              12);
                            writeln;
                            // readln(userconfirmation);
                            if bSilentInstall { lowercase(userconfirmation) = 'y' }
                            then
                            begin
                              if lowercase(splitedversion)
                                = lowercase(currentversionname) then
                              begin
                                // selectedversion := versionarray[I];
                                // selectedpatch := Patcharray[T];
                                if dbconnectionname <> '' then
                                begin
                                  bConnectTempDB := True;
                                  tempDBConnectionName := dbconnectionname;
                                  if assigned(dbc) then
                                    FreeAndNil(dbc);
                                  // dbc (database) connection will be established while calling HandleStructureInstallation
                                end;
                                write('Current installed Version is : ');
                                Console_write(currentversionname + '/' +
                                  currentPatchname, 10);
                                writeln;
                                writeln;
                                selectedversion := splitedversion;
                                // versionarray[I];
                                selectedpatch := Patcharray[T];
                                writeln;
                                writeln(Uppercase('Installing ' +
                                  Patcharray[T]));
                                writeln('==============================');
                                writeln;
                                HandleStructureInstallation(Patcharray[T]);
                                if connectionstatus then
                                begin
                                  // commandstrlist := TStringList.Create;
                                  // commandstrlist.Delimiter := '/';
                                  // commandstrlist.Delimitedtext := patcharray[T];
                                  // spatch := commandstrlist[2];
                                  // commandstrlist.Free;
                                  // Config.updatecurrentpatch(splitedversion, splitedpatch);
                                  // currentversionname := splitedversion;
                                  // currentPatchname := splitedpatch;
                                  // if EnableBackup then
                                  // begin
                                  // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                                  // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                                  // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                                  // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                                  // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                                  // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                                  // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                                  // if not directoryexists(backuppath) then
                                  // forcedirectories(backuppath);
                                  // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                                  // end;
                                  // currentPatchname := splitedpatch;
                                  patchOrPlugin := '';
                                  writeln;
                                  writeln(' INSTALLATION SUMMARY  OF ' +
                                    Uppercase(splitedversion + '/' +
                                    splitedpatch));
                                  writeln('=======================');

                                  write('  -');
                                  Console_write(Patcharray[T], 3);
                                  write(' installation completed without errors.');
                                  WriteLog('installation completed without errors for '
                                    + Patcharray[T]);
                                  writeln;
                                  // === Update release number for this schema ===
                                  try
                                    activeconnection :=
                                      lowercase(dbconnectionname);
                                    // ensure correct schema context
                                    Config := TConfig.Create;
                                    Config.UpdateCurrentPatch(splitedversion,
                                      splitedpatch);
                                    FreeAndNil(Config);
                                    WriteLog('Updated release number for schema: '
                                      + activeconnection);
                                  except
                                    on E: Exception do
                                    begin
                                      WriteLog('Error updating release number for '
                                        + dbconnectionname + ': ' + E.Message);
                                    end;
                                  end;
                                  Break;
                                end;

                              end;
                            end
                            else
                            begin
                              writeln;
                              Console_write
                                ('The script and structure installation has been aborted.',
                                12);
                              writeln;
                              // writeln;
                              // write('AxInstaller> ');
                              // readln(Command);
                              // Skip and continue
                              Continue;
                              // Command := instBeforeReadCommand;
                              // parseCommand(Command);
                            end;
                          end
                          // Commenting this else block on 18/09/2025 to make the AxIntaller to install greater patches
                          // else
                          // begin
                          // writeln;
                          // Console_write('The "Requested release" number (' +
                          // inttostr(installpatchindex) +
                          // ') is greater than the current release number. Command cannot be processed.',
                          // 12);
                          //
                          // writeln;
                          // WriteLog('The "Requested release" number (' +
                          // inttostr(installpatchindex) +
                          // ') is greater than the current release number. Command cannot be processed.');
                          // end;
                          // this is the new else block which installs lower patches with users confirmation
                          else
                          begin
                            writeln;
                            Console_write
                              ('Warning: You are attempting to install an older release ('
                              + splitedpatch + ') than the current release (' +
                              currentPatchname + ').', 14);
                            Console_write
                              ('Downgrading may overwrite newer structures and cause issues.',
                              12);
                            write('Do you want to continue? (y/n): ');
                            readln(userconfirmation);

                            if lowercase(userconfirmation) = 'y' then
                            begin
                              // same as upgrade flow → execute HandleStructureInstallation
                              if dbconnectionname <> '' then
                              begin
                                bConnectTempDB := True;
                                tempDBConnectionName := dbconnectionname;
                                if assigned(dbc) then
                                  FreeAndNil(dbc);
                              end;

                              write('Current installed Version is : ');
                              Console_write(currentversionname + '/' +
                                currentPatchname, 10);
                              writeln;
                              writeln;
                              selectedversion := splitedversion;
                              selectedpatch := Patcharray[T];
                              writeln;
                              writeln(Uppercase('Installing ' + Patcharray[T]));
                              writeln('==============================');
                              writeln;

                              HandleStructureInstallation(Patcharray[T]);

                              if connectionstatus then
                              begin
                                patchOrPlugin := '';
                                writeln;
                                writeln(' INSTALLATION SUMMARY  OF ' +
                                  Uppercase(splitedversion + '/' +
                                  splitedpatch));
                                writeln('=======================');
                                write('  -');
                                Console_write(Patcharray[T], 3);
                                write(' installation completed without errors.');
                                WriteLog('installation completed without errors for '
                                  + Patcharray[T]);
                                writeln;
                                // Config.UpdateCurrentPatch(splitedversion, splitedpatch);
                                Break;
                              end;
                            end
                            else
                            begin
                              writeln;
                              Console_write
                                ('Downgrade installation aborted by user.', 12);
                              writeln;
                              Continue;
                            end;
                          end;
                        end;
                      end;
                      // Config.UpdateCurrentPatch(splitedversion, splitedpatch);
                      Break;
                    end;
                  end;
                end;
              end;
            end;
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            try
              Config := TConfig.Create;
              Config.UpdateCurrentPatch(splitedversion, splitedpatch);
            finally
              FreeAndNil(Config);
            end;
          finally
            // bDBConDuring_Install := False; // reset
            bSilentInstall := False;
            activeconnection := Act_Active_Conn;
            HandleAllConfigCommand('config set ' + activeconnection, True);
            Command := instBeforeReadCommand;
            parseCommand(Command);
            WriteErrorList(ExtractFilePath(ParamStr(0)));
          end;
        end
        else if Pos('install', lowercase(Command)) <> 0 then
        begin
          try
            // begin
            try
              dbconnectionname := '';
              commandstrlist := TStringList.Create;
              commandstrlist.Delimiter := ' ';
              commandstrlist.QuoteChar := '"';
              commandstrlist.StrictDelimiter := True;
              commandstrlist.DelimitedText := Command;

              plugname := '';
              if ((commandstrlist.Count = 3) and
                 (Pos('release', LowerCase(Command)) = 0)) then
              begin
                bPullStructures := True;
                plugname := commandstrlist[1];

                if plugname <> '' then
                begin
                  patchOrPlugin := 'Plugin';
                  selectedplugin := plugname;

                  // Call same handler used by release
                  HandleStructureInstallation(selectedplugin);

                  patchOrPlugin := '';
                  Command := instBeforeReadCommand;
                  parseCommand(Command);
                  Exit;
                end;
              end;
              splitedversion := commandstrlist[1]; // Version No
              splitedpatch1 := commandstrlist[2]; // From patch
              splitedpatch2 := commandstrlist[3]; // To pacth
              webstatus := commandstrlist[4]; // -Web
              if ((splitedpatch1 <> '') and (splitedpatch2 <> '')) and
                (splitedpatch2 <> '-web') then
              begin
                continuousinstallation := True;
              end;

              if (commandstrlist.Count = 6) and (commandstrlist[4] = '-web')
              then
              begin
                bPullStructures := True;
                dbconnectionname := commandstrlist[5];
                // optional (db connection name)
                if Not IsConnExistsInAxApps(dbconnectionname) then
                begin
                  write('The given connection ' + dbconnectionname +
                    ' doesn''t exists.');
                  writeln;
                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);
                  Command := instBeforeReadCommand;
                  parseCommand(Command);
                end;
                continuousinstallation := True;
              end;

              // splitedversion := commandstrlist[1]; // Version No
              // splitedpatch1 := commandstrlist[2]; // From patch
              // splitedpatch2 := commandstrlist[3]; // To pacth
              // webstatus := commandstrlist[3]; // -Web
              if (commandstrlist.Count = 5) and (commandstrlist[3] = '-web')
              then
              begin
                dbconnectionname := commandstrlist[4];
                // optional (db connection name)
                if Not IsConnExistsInAxApps(dbconnectionname) then
                begin
                  write('The given connection ' + dbconnectionname +
                    ' doesn''t exists.');
                  writeln;
                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);
                  Command := instBeforeReadCommand;
                  parseCommand(Command);
                end;
                continuousinstallation := False;
              end;

              // end;
            Except
              on E: Exception do
              begin
                splitedversion := '';
                splitedpatch1 := '';
                splitedpatch2 := '';
                continuousinstallation := False;
                // dbconnectionname := commandstrlist[4]; // optional (db connection name)
                // if Not IsConnExistsInAxApps(dbconnectionname) then
                // begin
                // write('The given connection '+dbconnectionname+' doesn''t exists.');
                // writeln;
                // writeln;
                // write('AxInstaller> ');
                // readln(Command);
                // parseCommand(Command);
                // end;
              end;
            end;
          finally
            // splitedversion := '';
            // splitedpatch1 := '';
            // splitedpatch2 := '';
            commandstrlist.Free;
          end;
          if continuousinstallation = True then
          begin
            splitedversion := 'Version ' + splitedversion;
            // if not assigned(git) then
            // git := TGitManager.Create;
            // if Length(versionarray) = 0 then
            // git.initversion();
            // if Length(Patcharray) = 0 then
            // git.createpatcharray();
            splitedversionfound := False;
            writeln;
            write('Current installed Version is : ');
            Console_write(currentversionname + '/' + currentPatchname, 10);
            writeln;
            writeln;

            // for I := Low(versionarray) to High(versionarray) do
            // begin
            verName := IsVersionExists(splitedversion);
            if verName <> '' { versionarray[I] = splitedversion } then
            begin
              splitedversionfound := True;
              verName := '';
              // for T := Low(Patcharray) to High(Patcharray) do
              // begin
              // if lowercase(Patcharray[T])
              // = lowercase(versionarray[I] + '/' + splitedpatch1) then
              PatcName :=
                IsPatchExists(lowercase(splitedversion + '/' + splitedpatch1));
              if PatcName <> '' then
              begin
                splitedpatch1found := True;
                PatcName := '';

              end;
              // if lowercase(Patcharray[T])
              // = lowercase(versionarray[I] + '/' + splitedpatch2) then
              PatcName :=
                IsPatchExists(lowercase(splitedversion + '/' + splitedpatch2));
              if PatcName <> '' then
              begin
                splitedpatch2found := True;
                PatcName := '';
              end;
              // if splitedpatch2found and splitedpatch1found then
              // Break;
            end;
            // end;
            // end;

            if splitedpatch2found and splitedpatch1found then
            begin
              curpatchindex := findpatchindex(currentversionname + '/' +
                currentPatchname);
              splitedpatch1index :=
                findpatchindex(splitedversion + '/' + splitedpatch1);
              splitedpatch2index :=
                findpatchindex(splitedversion + '/' + splitedpatch2);
              // if ((curpatchindex > splitedpatch1index) and (splitedpatch2index < curpatchindex))
              // or (splitedpatch1index > splitedpatch2index) then
              // begin
              /// /                      writeln;
              /// /                      write('You have applied ');
              /// /                      console_write(selectedpatch, 14);
              /// /                      writeln;
              /// /                      write(' already.');
              // writeln;
              // console_write('installation cannot be done.May be ''From'' and ''To'' patch are not given properly or installation is done already', 12);
              // writeln;
              // writeln;
              // write('AxInstaller> ');
              // readln(Command);
              // parseCommand(Command);
              // end
              // if ((curpatchindex > splitedpatch2index) or (curpatchindex = splitedpatch2index)) or
              // ((curpatchindex > splitedpatch1index) or (curpatchindex = splitedpatch1index)) then
              if (splitedpatch2index <= curpatchindex) and
                (splitedpatch1index <= splitedpatch2index) and
                (splitedpatch1index <= curpatchindex) then
              // ((curpatchindex > splitedpatch1index) or (curpatchindex = splitedpatch1index)) then
              begin
                writeln;
                Console_write
                  ('You are requested to execute scripts and import structures from the "'
                  + Patcharray[splitedpatch1index] + '" to the "' +
                  Patcharray[splitedpatch2index] +
                  '" on the selected connection/schema.', 12);
                Console_write
                  ('This will overwrite any existing changes in the selected connection/schema. Continue? (y to continue, n to cancel)',
                  12);
                writeln;
                readln(userconfirmation);
                if lowercase(userconfirmation) = 'y' then
                begin
                  try
                    // writeln;
                    // write('Current installed Version is : ');
                    // Console_write(currentversionname + '/' + currentPatchname, 10);
                    // // nned to add selected patch
                    // writeln;
                    // writeln;

                    // Connect to given db connection if dbconnectionname <> ''
                    if dbconnectionname <> '' then
                    begin
                      bConnectTempDB := True;
                      tempDBConnectionName := dbconnectionname;
                      if assigned(dbc) then
                        FreeAndNil(dbc);
                      // dbc (database) connection will be established while calling HandleStructureInstallation
                    end;

                    for Y := splitedpatch1index to splitedpatch2index do
                    begin
                      if lowercase(splitedversion)
                        = lowercase(currentversionname) then
                      begin
                        selectedversion := splitedversion; // versionarray[I];
                        selectedpatch := Patcharray[Y];
                        writeln;
                        writeln(Uppercase('Installing ' + Patcharray[Y]));
                        writeln('==============================');
                        writeln;
                        HandleStructureInstallation(Patcharray[Y]);
                        if connectionstatus then
                        begin
                          commandstrlist := TStringList.Create;
                          commandstrlist.Delimiter := '/';
                          commandstrlist.QuoteChar := '"';
                          commandstrlist.DelimitedText := selectedpatch;
                          splitedpatch := commandstrlist[2];
                          commandstrlist.Free;
                          // Config.updatecurrentpatch(splitedversion, splitedpatch);
                          // currentversionname := splitedversion;
                          // currentPatchname := splitedpatch;
                          // currentPatchname := splitedpatch;
                          patchOrPlugin := '';
                          writeln;
                          writeln(' INSTALLATION SUMMARY OF ' +
                            Uppercase(splitedversion + '/' + splitedpatch));
                          writeln('============================================');

                          write('  -');
                          Console_write(selectedpatch, 3);
                          write(' installation completed without errors.');
                          WriteLog('installation completed without errors for '
                            + Patcharray[T]);
                          writeln;
                          writeln;
                          // break;
                        end;
                      end;
                    end;
                  finally
                    bConnectTempDB := False;
                    tempDBConnectionName := '';
                    if assigned(dbc) then
                      FreeAndNil(dbc);
                  end;
                  // Break;
                end
                else
                begin
                  writeln;
                  Console_write
                    ('The script and structure installation has been aborted.',
                    12);
                  writeln;
                  WriteLog('The script and structure installation has been aborted.');
                  writeln;
                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);
                  Command := instBeforeReadCommand;
                  parseCommand(Command);
                end;
              end
              else
              begin
                if splitedpatch2index > curpatchindex then
                begin
                  writeln;
                  Console_write('The "To release" (' + splitedpatch2 +
                    ') number is greater than the current release (' +
                    currentPatchname +
                    ')  number. Command cannot be processed.', 12);
                  writeln;
                  WriteLog('The "To release" (' + splitedpatch2 +
                    ') number is greater than the current release (' +
                    currentPatchname +
                    ') number. Command cannot be processed.');
                end
                else if splitedpatch1index > splitedpatch2index then
                begin
                  writeln;
                  Console_write('The "From release" (' + splitedpatch1 +
                    ') number is greater than the "To release" (' +
                    splitedpatch2 +
                    ') number. Command cannot be processed.', 12);
                  writeln;
                  WriteLog('The "From release" (' + splitedpatch1 +
                    ') number is greater than the "To release" (' +
                    splitedpatch2 + ') number. Command cannot be processed.');
                end
                else if splitedpatch1index > curpatchindex then
                begin
                  writeln;
                  Console_write('The "From release" (' + splitedpatch1 +
                    ') number is greater than the current release (' +
                    currentPatchname +
                    ') number. Command cannot be processed.', 12);

                  writeln;
                  WriteLog('The "From release" (' + splitedpatch1 +
                    ') number is greater than the current release (' +
                    currentPatchname +
                    ') number. Command cannot be processed.');
                end;
                // end;
                //
                // end;
                //
                // end;


                // else
                // begin
                // writeln;
                // write('AxInstaller> ');
                // readln(Command);
                // parseCommand(Command);
                // end;
                // break;
                // end;

              end;
              // Break;
            end
            else
            begin
              if not splitedpatch1found then
              begin

                Console_write('The requested release "' + splitedpatch1 +
                  '" not available.', 12);
                writeln;
              end
              else if not splitedpatch2found then
              begin

                Console_write('The requested release "' + splitedpatch2 +
                  '" not available.', 12);
                writeln;
              end;
            end;
            if splitedversionfound = False then
            begin
              writeln;
              Console_write
                ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
                12);
              writeln;
            end;

            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);

          end;
        end;
        if continuousinstallation = False then
        begin
          commandstrlist := TStringList.Create;
          commandstrlist.Delimiter := ' ';
          commandstrlist.QuoteChar := '"';
          commandstrlist.DelimitedText := Command;
          splitedversion := commandstrlist[1];
          splitedpatch := commandstrlist[2];
          commandstrlist.Free;
          // splitedpatch:='Patch'+splitedpatch;
          splitedversion := 'Version ' + splitedversion;
          if not assigned(git) then
            git := TGitManager.Create;
          if Length(versionarray) = 0 then
            git.initversion();
          if Length(Patcharray) = 0 then
            git.createpatcharray();
          for I := Low(versionarray) to High(versionarray) do
          begin
            if versionarray[I] = splitedversion then
            begin
              for T := Low(Patcharray) to High(Patcharray) do
              begin
                if lowercase(Patcharray[T])
                  = lowercase(versionarray[I] + '/' + splitedpatch) then
                begin
                  curpatchindex :=
                    findpatchindex(currentversionname + '/' + currentPatchname);
                  installpatchindex :=
                    findpatchindex(splitedversion + '/' + splitedpatch);
                  // if curpatchindex > installpatchindex then
                  // begin
                  // writeln;
                  // write('You have applied ');
                  // console_write(selectedpatch, 14);
                  // writeln;
                  // write(' already.');
                  // writeln;
                  // console_write('downgrade installation cannot be done', 12);
                  // writeln;
                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);
                  // parseCommand(Command);
                  // end
                  // if curpatchindex = installpatchindex then
                  // begin
                  if (installpatchindex <= curpatchindex) then
                  begin
                    writeln;
                    userconfirmation := '';
                    Console_write
                      ('You are requested to execute scripts and import structures from the release "'
                      + splitedpatch +
                      '" on the selected connection/schema.', 12);
                    Console_write
                      ('This will overwrite any existing changes in the selected connection/schema. Continue? (y to continue, n to cancel)',
                      12);
                    writeln;
                    readln(userconfirmation);
                    if lowercase(userconfirmation) = 'y' then
                    begin
                      if lowercase(splitedversion)
                        = lowercase(currentversionname) then
                      begin
                        // selectedversion := versionarray[I];
                        // selectedpatch := Patcharray[T];
                        if dbconnectionname <> '' then
                        begin
                          bConnectTempDB := True;
                          tempDBConnectionName := dbconnectionname;
                          if assigned(dbc) then
                            FreeAndNil(dbc);
                          // dbc (database) connection will be established while calling HandleStructureInstallation
                        end;
                        write('Current installed Version is : ');
                        Console_write(currentversionname + '/' +
                          currentPatchname, 10);
                        writeln;
                        writeln;
                        selectedversion := splitedversion; // versionarray[I];
                        selectedpatch := Patcharray[T];
                        writeln;
                        writeln(Uppercase('Installing ' + Patcharray[T]));
                        writeln('==============================');
                        writeln;
                        HandleStructureInstallation(Patcharray[T]);
                        if connectionstatus then
                        begin
                          // commandstrlist := TStringList.Create;
                          // commandstrlist.Delimiter := '/';
                          // commandstrlist.Delimitedtext := patcharray[T];
                          // spatch := commandstrlist[2];
                          // commandstrlist.Free;
                          // Config.updatecurrentpatch(splitedversion, splitedpatch);
                          // currentversionname := splitedversion;
                          // currentPatchname := splitedpatch;
                          // if EnableBackup then
                          // begin
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                          // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                          // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                          // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                          // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                          // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                          // if not directoryexists(backuppath) then
                          // forcedirectories(backuppath);
                          // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                          // end;
                          // currentPatchname := splitedpatch;
                          patchOrPlugin := '';
                          writeln;
                          writeln(' INSTALLATION SUMMARY  OF ' +
                            Uppercase(splitedversion + '/' + splitedpatch));
                          writeln('=======================');

                          write('  -');
                          Console_write(Patcharray[T], 3);
                          write(' installation completed without errors.');
                          WriteLog('installation completed without errors for '
                            + Patcharray[T]);
                          writeln;
                          Break;
                        end;

                      end;
                    end
                    else
                    begin
                      writeln;
                      Console_write
                        ('The script and structure installation has been aborted.',
                        12);
                      writeln;
                      // writeln;
                      // write('AxInstaller> ');
                      // readln(Command);
                      Command := instBeforeReadCommand;
                      parseCommand(Command);
                    end;
                  end
                  else
                  begin
                    //
                    writeln;
                    Console_write('The "Requested release" number (' +
                      inttostr(installpatchindex) +
                      ') is greater than the current release number. Command cannot be processed.',
                      12);

                    writeln;
                    WriteLog('The "Requested release" number (' +
                      inttostr(installpatchindex) +
                      ') is greater than the current release number. Command cannot be processed.');
                    //
                  end;
                end;
              end;
              Break;
            end;
          end;
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          parseCommand(Command);
          WriteErrorList(ExtractFilePath(ParamStr(0)));
        end;
      end
      else if Pos('password', lowercase(Command)) <> 0 then
      begin
        if Pos('set', lowercase(Command)) <> 0 then
        begin
          writeln;
          writeln('Do you want to change password ?');
          writeln('Please give response in ''y'' or ''n'' only.');
          readln(res);
          if lowercase(res) = 'y' then
          begin
            writeln;
            writeln('Admin privileges are required. Please enter the current admin password to proceed.');
            readln(currentpasswordres);
            if currentpasswordres = adminpwd then
            begin
              writeln;
              writeln('Please enter the new password to complete the update.');
              WriteLog('Current password is corect.');
              WriteLog('Validtion successfull');
              readln(newpasswordres);
              if not assigned(Config) then
                Config := TConfig.Create;
              if not assigned(dbm) then
                dbm := TDbManager.Create;
              encryptedpass := dbm.gf.EncryptFldValue(newpasswordres, 't');
              Config.changeadminpassword(encryptedpass);
              Config.readReleasePasswordandGitUrl;
              writeln;
              Console_write('Admin password changed successfully..!', 10);
              writeln;
            end
            else
            begin
              writeln;
              writeln('The Admin password is incorrect. Please enter the correct password to proceed with the update.');
              // writeln;
              // write('AxInstaller> ');
              // readln(Command);
              Command := instBeforeReadCommand;
              parseCommand(Command);
            end;
          end
          else
          begin
            writeln;
            Console_write
              ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
              12);
            writeln;
          end;
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end;
      end
      else if Pos('uninstall', Command) <> 0 then
      begin
        commandWord := Copy(Command, Length('uninstall') + 1, Length(Command));
        commandWord := Trim(commandWord);
        for I := Low(pluginarray) to High(pluginarray) do
        begin

          if (lowercase(commandWord)) = (lowercase(pluginarray[I])) then
          begin
            selectedplugin := pluginarray[I];
            HandleUnInstallationCommand(selectedplugin);
          end;
        end;
      end
      (* else if Pos('upgrade', LowerCase(Trim(commandWord))) = 1 then
        begin
        try
        commandstrlist := TStringList.Create;
        commandstrlist.Delimiter := ' ';
        commandstrlist.DelimitedText := commandWord;
        splitedversion := commandstrlist[1];
        commandstrlist.Free;
        splitedversion := 'Version ' + splitedversion;
        if not assigned(git) then
        git := TGitManager.Create;
        if Length(versionarray) = 0 then
        git.initversion();
        if Length(Patcharray) = 0 then
        git.createpatcharray();
        upgradeflag := False;
        for A := Low(versionarray) to High(versionarray) do
        begin
        if lowercase(splitedversion) = lowercase(versionarray[A]) then
        begin
        curpatchindex := findpatchindex(currentversionname + '/' +
        currentPatchname);
        if Pos('latest', lowercase(commandWord)) <> 0 then
        begin
        currentpatchindexaccdoversion := findLatestPatchAccordingToVersion
        (versionarray[A]);
        selectedpatch := Patcharray[currentpatchindexaccdoversion];
        end
        else
        //selectedpatch := versionarray[A] + '/main';
        selectedpatch := versionarray[A] + '/BaseCode';
        installpatchindex := findpatchindex(selectedpatch);
        writeln;
        write('Currently installed : ');
        Console_write(currentversionname + '/' + currentPatchname, 10);
        WriteLog('Your current applied release is : ' + currentversionname +
        '/' + currentPatchname);
        writeln;
        writeln;
        //IIsStatus();
        for B := curpatchindex + 1 to installpatchindex do
        begin
        // ;
        patchOrPlugin := 'Release';
        writeln;
        Console_write('Installing ' + Patcharray[B], 14);
        writeln;
        writeln;
        HandleInstallationCommand(Patcharray[B]);
        if connectionstatus then
        begin
        commandstrlist := TStringList.Create;
        commandstrlist.Delimiter := '/';
        commandstrlist.DelimitedText := Patcharray[B];
        sversion := commandstrlist[0] + ' ' + commandstrlist[1];
        spatch := commandstrlist[2];
        commandstrlist.Free;
        Config.updatecurrentpatch(sversion, spatch);
        currentversionname := sversion;
        currentPatchname := spatch;
        // if EnableBackup then
        // begin
        // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
        // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
        // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
        // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
        // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
        // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
        // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
        // if not directoryexists(backuppath) then
        // forcedirectories(backuppath);
        // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
        // end;
        currentPatchname := spatch;
        patchOrPlugin := '';
        writeln(' INSTALLATION SUMMARY  ');
        writeln('=======================');

        write('  -');
        Console_write(Patcharray[B], 3);
        write(' installation completed without errors.');
        writeln;
        if slUserInstructions.Count > 0 then
        begin
        writeln;
        writeln('Important Instruction :-');
        for T := 0 to slUserInstructions.Count - 1 do
        begin
        writeln('    -' + slUserInstructions[T]);
        end;
        writeln;
        end;
        end;
        end;
        upgradeflag := True;
        end;
        end;
        if upgradeflag = False then
        begin
        writeln;
        writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
        // writeln;
        // write('AxInstaller> ');
        // readln(Command);
        Command := instBeforeReadCommand;
        parseCommand(Command);
        end;
        // 22082024
        // if Not IsIISRunning then
        // begin
        // writeln;
        // writeln('IIS is not running. Do you want to start the IIS ? Press ''Y'' to start , ''N'' to skip.');
        // // writeln;
        // write('AxInstaller> ');
        // readln(iisresponse);
        // HandleQuitCommand(iisresponse);
        // end;
        // writeln;
        // write('AxInstaller> ');
        // readln(Command);
        Command := instBeforeReadCommand;
        parseCommand(Command);
        Except
        on E: Exception do
        begin
        Command := instBeforeReadCommand;
        parseCommand(Command);
        end;

        end;
        end *)
      else if Pos('prepare base', lowercase(Trim(commandWord))) = 1 then
      begin
        try
          commandstrlist := TStringList.Create;
          commandstrlist.Delimiter := ' ';
          commandstrlist.DelimitedText := commandWord;
          splitedversion := commandstrlist[2];
          commandstrlist.Free;
          splitedversion := 'Version ' + splitedversion;
          if not assigned(git) then
            git := TGitManager.Create;
          if Length(versionarray) = 0 then
            git.initversion();
          if Length(Patcharray) = 0 then
            git.createpatcharray();
          upgradeflag := False;
          // for A := Low(versionarray) to High(versionarray) do
          // begin
          // if lowercase(splitedversion) = lowercase(versionarray[A]) then
          begin
            // curpatchindex := findpatchindex(currentversionname + '/' +
            // currentPatchname);
            // if Pos('latest', lowercase(commandWord)) <> 0 then
            // begin
            // currentpatchindexaccdoversion := findLatestPatchAccordingToVersion
            // (versionarray[A]);
            // selectedpatch := Patcharray[currentpatchindexaccdoversion];
            // end
            // else
            // selectedpatch := versionarray[A] + '/main';
            selectedpatch := splitedversion + '/BaseCode';
            installpatchindex := findpatchindex(selectedpatch);
            writeln;
            write('Currently installed : ');
            Console_write(currentversionname + '/' + currentPatchname, 10);
            WriteLog('Your current applied release is : ' + currentversionname +
              '/' + currentPatchname);
            writeln;
            writeln;

            // IIsStatus();
            // for B := curpatchindex + 1 to installpatchindex do
            begin
              // ;
              patchOrPlugin := 'Release';
              writeln;
              Console_write('Installing ' + selectedpatch, 14);
              writeln;
              writeln;
              HandleInstallationCommand(selectedpatch);
              if connectionstatus then
              begin
                commandstrlist := TStringList.Create;
                commandstrlist.Delimiter := '/';
                commandstrlist.DelimitedText := selectedpatch;
                sversion := commandstrlist[0] + ' ' + commandstrlist[1];
                spatch := commandstrlist[2];
                commandstrlist.Free;
                Config.UpdateCurrentPatch(sversion, spatch);
                currentversionname := sversion;
                currentPatchname := spatch;
                // if EnableBackup then
                // begin
                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                // if not directoryexists(backuppath) then
                // forcedirectories(backuppath);
                // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                // end;
                currentPatchname := spatch;
                patchOrPlugin := '';
                writeln(' INSTALLATION SUMMARY  ');
                writeln('=======================');

                write('  -');
                Console_write(selectedpatch, 3);
                write(' installation completed without errors.');
                writeln;
                // if slUserInstructions.Count > 0 then
                // begin
                // writeln;
                // writeln('Important Instruction :-');
                // for T := 0 to slUserInstructions.Count - 1 do
                // begin
                // writeln('    -' + slUserInstructions[T]);
                // end;
                // writeln;
                // end;
                WriteUserInstructions;
                WriteErrorList(ExtractFilePath(ParamStr(0)));
              end;
            end;
            upgradeflag := True;
          end;
          // end;
          if upgradeflag = False then
          begin
            writeln;
            writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;
          // 22082024
          // if Not IsIISRunning then
          // begin
          // writeln;
          // writeln('IIS is not running. Do you want to start the IIS ? Press ''Y'' to start , ''N'' to skip.');
          // // writeln;
          // write('AxInstaller> ');
          // readln(iisresponse);
          // HandleQuitCommand(iisresponse);
          // end;
          // writeln;
          // write('AxInstaller> ');
          // readln(Command);
          Command := instBeforeReadCommand;
          parseCommand(Command);
        Except
          on E: Exception do
          begin
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;

        end;
      end
      // bulkinstall
      else if Pos('bulkinstall', lowercase(commandWord)) <> 0 then
      begin

        Act_Active_Conn := activeconnection;
        try
          // bDBConDuring_Install := True;
          // bulkinstall
          BulkCommandList := TStringList.Create;
          BulkCommandList := LoadBulkInstallFile(commandWord);
          if assigned(BulkCommandList) and (BulkCommandList.Count > 0) then
          begin
            for idx := 0 to BulkCommandList.Count - 1 do
            begin
              CommandFromFile := BulkCommandList[idx];
              commandWord := CommandFromFile;
              commandWord := StringReplace(lowercase(commandWord), 'install',
                '', [rfReplaceAll, rfIgnoreCase]);
              commandWord := Trim(commandWord);
              try
                if assigned(commandstrlist) then
                begin
                  commandstrlist.clear;
                  FreeAndNil(commandstrlist);
                end;
                commandstrlist := TStringList.Create;
                commandstrlist.Delimiter := ' ';
                commandstrlist.QuoteChar := '"';
                commandstrlist.DelimitedText := CommandFromFile; // Command;
                // if comparestr(lowercase(pluginarray[A]), lowercase(commandWord)) = 0
                // then
                plugname := '';
                // Pluginname must be given inside the double quotes incase it has special chars
                if (commandstrlist.Count = 2) then
                // For plugin -  Install pluginname
                begin
                  commandWord := ExtractStringInsideQuotes(commandWord);
                  plugname := IsPluginExists(commandWord);
                end;
                if plugname <> '' then
                begin
                  patchOrPlugin := 'Plugin';
                  selectedplugin := plugname;
                  HandleInstallationCommand(selectedplugin);
                  plugininstalled := True;
                  patchOrPlugin := '';
                end;

                // end;
                if plugininstalled = False then
                begin
                  // for A := Low(versionarray) to High(versionarray) do
                  // begin

                  // commandstrlist := TStringList.Create;
                  // commandstrlist.Delimiter := ' ';
                  // commandstrlist.Delimitedtext := Command;
                  if Pos('install', { Command } lowercase(CommandFromFile)) <> 0
                  then
                  begin
                    // commandstrlist includes command install also
                    if commandstrlist.Count = 3 then
                    begin
                      try
                        splitedversion := commandstrlist[1];
                        splitedpatch := commandstrlist[2];
                        activeconnection := Act_Active_Conn;
                        // set default active connection
                      Except
                        on E: Exception do
                        begin
                          writeln;
                          Console_write
                            ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
                            12);
                          writeln;
                          // writeln;
                          // write('AxInstaller> ');
                          // readln(Cmd);
                          Command := instBeforeReadCommand;
                          parseCommand(Command);
                        end;
                      end;
                    end
                    else if commandstrlist.Count >= 4 then
                    // has active connection
                    begin
                      try
                        splitedversion := commandstrlist[1];
                        splitedpatch := commandstrlist[2];
                        activeconnection := lowercase(commandstrlist[3]);
                        // read connection from install command
                      Except
                        on E: Exception do
                        begin
                          writeln;
                          Console_write
                            ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
                            12);
                          writeln;
                          // writeln;
                          // write('AxInstaller> ');
                          // readln(Cmd);
                          Command := instBeforeReadCommand;
                          parseCommand(Command);
                          WriteErrorList(ExtractFilePath(ParamStr(0)));
                        end;
                      end;
                    end;

                    // Set Config Active App
                    HandleAllConfigCommand
                      ('config set ' + activeconnection, True);

                    // commandstrlist.Free;
                    splitedversion := 'Version ' + Trim(splitedversion);

                    // for F := Low(versionarray) to High(versionarray) do
                    // begin
                    // if lowercase(splitedversion) = lowercase(versionarray[F]) then
                    verName := IsVersionExists(splitedversion);
                    if verName <> '' then
                    begin
                      selectedversion := verName;
                      verName := '';
                      // if not assigned(git) then
                      // git := TGitManager.Create;
                      // if Length(Patcharray) = 0 then
                      // git.createpatcharray( { selectedversion } );
                      // for C := Low(Patcharray) to High(Patcharray) do
                      // begin
                      PatcName := '';
                      PatcName :=
                        IsPatchExists(splitedversion + '/' + splitedpatch);
                      // if lowercase(splitedversion + '/' + splitedpatch)
                      // = lowercase(Patcharray[C]) then
                      if PatcName <> '' then

                      begin
                        selectedpatch := PatcName;
                        PatcName := '';
                        patchfound := True;
                        currentpatch := currentversionname + '/' +
                          currentPatchname;
                        currentpatchnumber := findpatchindex(currentpatch);
                        selectedpatchnumber := findpatchindex(selectedpatch);
                        if selectedpatchnumber < currentpatchnumber then
                        begin
                          writeln;
                          write('You have applied ');
                          Console_write(selectedpatch, 14);
                          writeln;
                          write(' already.');
                          writeln;
                          Console_write
                            ('downgrade installation cannot be done', 12);
                          WriteLog(selectedpatch +
                            ' is already applied. so downgrade is not possible');
                          writeln;
                          // writeln;
                          // write('AxInstaller> ');
                          // readln(Command);

                          // Skip and conitnue for bulk install
                          (*
                            Command := instBeforeReadCommand;
                            parseCommand(Command);
                          *)
                          Continue;
                        end
                        else
                        begin
                          // if currentpatchname= then

                          curpatchindex :=
                            findpatchindex(currentversionname + '/' +
                            currentPatchname);
                          installpatchindex := findpatchindex(selectedpatch);
                          Config := TConfig.Create;
                          // if installpatchindex = 0 then
                          // G := 0
                          // else
                          // G := installpatchindex - 1;

                          // Set Config Active App
                          // HandleAllConfigCommand('config set '+activeconnection,true);

                          writeln;
                          write('Processing command : ');
                          Console_write(CommandFromFile, 10);

                          writeln;
                          write('Currently installed : ');
                          Console_write(currentversionname + '/' +
                            currentPatchname, 10);
                          WriteLog('Your current applied release is : ' +
                            currentversionname + '/' + currentPatchname);
                          writeln;
                          writeln;
                          IIsStatus();
                          if curpatchindex = -1 then
                          begin
                            for Z := 0 to installpatchindex do
                            begin
                              selectedpatch := Patcharray[Z];
                              patchOrPlugin := 'Release';
                              writeln;
                              Console_write('Installing ' + selectedpatch, 14);
                              WriteLog('Installing ' + selectedpatch);
                              writeln;
                              writeln;
                              HandleInstallationCommand(selectedpatch);
                              if connectionstatus then
                              begin
                                commandstrlist := TStringList.Create;
                                commandstrlist.Delimiter := '/';
                                commandstrlist.DelimitedText := selectedpatch;
                                sversion := commandstrlist[1];
                                sversion := 'Version ' + sversion;
                                spatch := commandstrlist[2];
                                commandstrlist.Free;
                                commandstrlist := nil;
                                Config.UpdateCurrentPatch(sversion, spatch);
                                currentversionname := sversion;
                                currentPatchname := spatch;
                                // if EnableBackup then
                                // begin
                                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                                // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                                // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                                // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                                // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                                // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                                // if not directoryexists(backuppath) then
                                // forcedirectories(backuppath);
                                // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                                // end;
                                currentPatchname := spatch;
                                patchOrPlugin := '';
                                writeln(' INSTALLATION SUMMARY  ');
                                writeln('=======================');

                                write('  -');
                                Console_write(selectedpatch, 3);
                                write(' installation completed without errors.');
                                WriteLog(' installation completed without errors for '
                                  + selectedpatch);
                                writeln;
                                // if slUserInstructions.Count > 0 then
                                // begin
                                // writeln;
                                // writeln('Important Instruction :-');
                                // for T := 0 to slUserInstructions.Count - 1 do
                                // begin
                                // writeln('    -' + slUserInstructions[T]);
                                // end;
                                // writeln;
                                // end;
                                WriteUserInstructions;
                              end;
                              patchOrPlugin := '';
                            end;
                          end
                          else
                          begin
                            if (installpatchindex - curpatchindex) > 2 then
                            begin
                              Console_write('Installing Releases from Release' +
                                currentversionname + '/' + currentPatchname +
                                ' to ' + selectedpatch, 14);
                              WriteLog('Installing Releases from Release' +
                                currentversionname + '/' + currentPatchname +
                                ' to ' + selectedpatch);
                              writeln;
                            end;
                            for Z := curpatchindex + 1 to installpatchindex do
                            begin
                              selectedpatch := Patcharray[Z];
                              patchOrPlugin := 'Release';
                              writeln;
                              Console_write('Installing ' + selectedpatch, 14);
                              writeln;
                              writeln;
                              HandleInstallationCommand(selectedpatch);
                              if connectionstatus then
                              begin
                                commandstrlist := TStringList.Create;
                                commandstrlist.Delimiter := '/';
                                commandstrlist.DelimitedText := selectedpatch;
                                sversion := commandstrlist[0] + ' ' +
                                  commandstrlist[1];;
                                spatch := commandstrlist[2];
                                commandstrlist.Free;
                                commandstrlist := nil;
                                Config.UpdateCurrentPatch(sversion, spatch);
                                currentversionname := sversion;
                                currentPatchname := spatch;
                                // if EnableBackup then
                                // begin
                                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                                // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                                // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                                // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                                // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                                // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                                // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                                // if not directoryexists(backuppath) then
                                // forcedirectories(backuppath);
                                // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                                // end;
                                currentPatchname := spatch;
                                patchOrPlugin := '';
                                writeln(' INSTALLATION SUMMARY  ');
                                writeln('=======================');

                                write('  -');
                                Console_write(selectedpatch, 3);
                                write(' installation completed without errors.');
                                writeln;
                                writeln;
                                // if slUserInstructions.Count > 0 then
                                // begin
                                // writeln;
                                // writeln('Important Instruction :-');
                                // for T := 0 to slUserInstructions.Count - 1 do
                                // begin
                                // writeln('    -' + slUserInstructions[T]);
                                // end;
                                // writeln;
                                // end;
                                WriteUserInstructions;
                              end;
                              patchOrPlugin := '';
                            end;
                          end;
                          FreeAndNil(Config);
                        end;

                        patchOrPlugin := '';
                        // Break;
                      end;
                      // else
                      // begin
                      // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
                      // writeln;
                      // write('AxInstaller> ');
                      // readln(Command);
                      // parseCommand(Command);
                      // end;
                    end;

                    // end;
                    // else
                    // begin
                    // writeln;
                    // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
                    // writeln;
                    // write('AxInstaller> ');
                    // readln(Command);
                    // Parsecommand(Command);
                    // end;

                    // end;
                    // if patchfound then
                    // Break;
                    // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
                    // writeln;
                    // write('AxInstaller> ');
                    // readln(Command);
                    // parseCommand(Command);
                  end;
                  // end;
                  // 2208204
                  // if Not IsIISRunning then
                  // begin
                  // writeln;
                  // writeln('IIS is not running. Do you want to start the IIS ? Press ''Y'' to start , ''N'' to skip.');
                  // // writeln;
                  // write('AxInstaller> ');
                  // readln(iisresponse);
                  // HandleQuitCommand(iisresponse);
                  // end;
                  // writeln;
                  // write('AxInstaller> ');
                  // readln(Command);

                  // Skipping read command in loop
                  // Command := instBeforeReadCommand;
                  // parseCommand(Command);
                end;
              finally
                if assigned(commandstrlist) then
                begin
                  commandstrlist.clear;
                  FreeAndNil(commandstrlist);
                end;
                // Set Config Active App
                activeconnection := Act_Active_Conn;
                HandleAllConfigCommand('config set ' + activeconnection, True);

                writeln('** Install command ' + inttostr(idx + 1) +
                  ' completed.');
                writeln(' ');
              end;

              // writeln('Press ''Enter'' key to exit or any command to continue');

              // Start IIS if not running

              // end
              // else
              // begin
              // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
              // writeln;
              // write('AxInstaller> ');
              // // readln(Command);
              // // parseCommand(Command);
              // readln(Command);
              // parseCommand(Command);
              // end;
            end;
          end;
        finally
          // bDBConDuring_Install := False; // reset
          activeconnection := Act_Active_Conn;
          HandleAllConfigCommand('config set ' + activeconnection, True);
          Command := instBeforeReadCommand;
          parseCommand(Command);
        end;
      end
      else if Pos('install', lowercase(commandWord)) <> 0 then
      begin
        // if not assigned(git) then
        // git := TGitManager.Create;
        // if Length(pluginarray) = 0 then
        // git.initplugin();
        // if Length(versionarray) = 0 then
        // git.initversion();
        // for A := Low(pluginarray) to High(pluginarray) do
        // begin
        commandWord := StringReplace(lowercase(commandWord), 'install', '',
          [rfReplaceAll, rfIgnoreCase]);
        commandWord := Trim(commandWord);
        try
          if assigned(commandstrlist) then
          begin
            commandstrlist.clear;
            FreeAndNil(commandstrlist);
          end;
          commandstrlist := TStringList.Create;
          commandstrlist.Delimiter := ' ';
          commandstrlist.DelimitedText := Command;
          // if comparestr(lowercase(pluginarray[A]), lowercase(commandWord)) = 0
          // then
          plugname := '';
          // Pluginname must be given inside the double quotes incase it has special chars
          if (commandstrlist.Count = 2) then // For plugin -  Install pluginname
          begin
            commandWord := ExtractStringInsideQuotes(commandWord);
            plugname := IsPluginExists(commandWord);
          end;
          if plugname <> '' then
          begin
            patchOrPlugin := 'Plugin';
            selectedplugin := plugname;
            HandleInstallationCommand(selectedplugin);
            plugininstalled := True;
            patchOrPlugin := '';
          end;

          // end;
          if plugininstalled = False then
          begin
            // for A := Low(versionarray) to High(versionarray) do
            // begin

            // commandstrlist := TStringList.Create;
            // commandstrlist.Delimiter := ' ';
            // commandstrlist.Delimitedtext := Command;
            if Pos('install', Command) <> 0 then
            begin
              if commandstrlist.Count >= 2 then
              begin
                try
                  splitedversion := commandstrlist[1];
                  splitedpatch := commandstrlist[2];
                Except
                  on E: Exception do
                  begin
                    writeln;
                    Console_write
                      ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
                      12);
                    writeln;
                    // writeln;
                    // write('AxInstaller> ');
                    // readln(Cmd);
                    Command := instBeforeReadCommand;
                    parseCommand(Command);
                  end;
                end;
              end;
              // commandstrlist.Free;
              splitedversion := 'Version ' + Trim(splitedversion);

              // for F := Low(versionarray) to High(versionarray) do
              // begin
              // if lowercase(splitedversion) = lowercase(versionarray[F]) then
              verName := IsVersionExists(splitedversion);
              if verName <> '' then
              begin
                selectedversion := verName;
                verName := '';
                // if not assigned(git) then
                // git := TGitManager.Create;
                // if Length(Patcharray) = 0 then
                // git.createpatcharray( { selectedversion } );
                // for C := Low(Patcharray) to High(Patcharray) do
                // begin
                PatcName := '';
                PatcName := IsPatchExists(splitedversion + '/' + splitedpatch);
                // if lowercase(splitedversion + '/' + splitedpatch)
                // = lowercase(Patcharray[C]) then
                if PatcName <> '' then

                begin
                  selectedpatch := PatcName;
                  PatcName := '';
                  patchfound := True;
                  currentpatch := currentversionname + '/' + currentPatchname;
                  currentpatchnumber := findpatchindex(currentpatch);
                  selectedpatchnumber := findpatchindex(selectedpatch);
                  if selectedpatchnumber < currentpatchnumber then
                  begin
                    writeln;
                    write('You have applied ');
                    Console_write(selectedpatch, 14);
                    writeln;
                    write(' already.');
                    writeln;
                    Console_write('downgrade installation cannot be done', 12);
                    WriteLog(selectedpatch +
                      ' is already applied. so downgrade is not possible');
                    writeln;
                    // writeln;
                    // write('AxInstaller> ');
                    // readln(Command);
                    Command := instBeforeReadCommand;
                    parseCommand(Command);
                  end
                  else
                  begin
                    // if currentpatchname= then

                    curpatchindex :=
                      findpatchindex(currentversionname + '/' +
                      currentPatchname);
                    installpatchindex := findpatchindex(selectedpatch);
                    Config := TConfig.Create;
                    // if installpatchindex = 0 then
                    // G := 0
                    // else
                    // G := installpatchindex - 1;
                    writeln;
                    write('Currently installed : ');
                    Console_write(currentversionname + '/' +
                      currentPatchname, 10);
                    WriteLog('Your current applied release is : ' +
                      currentversionname + '/' + currentPatchname);
                    writeln;
                    writeln;
                    IIsStatus();
                    if curpatchindex = -1 then
                    begin
                      for Z := 0 to installpatchindex do
                      begin
                        selectedpatch := Patcharray[Z];
                        patchOrPlugin := 'Release';
                        writeln;
                        Console_write('Installing ' + selectedpatch, 14);
                        WriteLog('Installing ' + selectedpatch);
                        writeln;
                        writeln;
                        HandleInstallationCommand(selectedpatch);
                        if connectionstatus then
                        begin
                          commandstrlist := TStringList.Create;
                          commandstrlist.Delimiter := '/';
                          commandstrlist.DelimitedText := selectedpatch;
                          sversion := commandstrlist[1];
                          sversion := 'Version ' + sversion;
                          spatch := commandstrlist[2];
                          commandstrlist.Free;
                          Config.UpdateCurrentPatch(sversion, spatch);
                          currentversionname := sversion;
                          currentPatchname := spatch;
                          // if EnableBackup then
                          // begin
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                          // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                          // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                          // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                          // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                          // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                          // if not directoryexists(backuppath) then
                          // forcedirectories(backuppath);
                          // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                          // end;
                          currentPatchname := spatch;
                          patchOrPlugin := '';
                          writeln(' INSTALLATION SUMMARY  ');
                          writeln('=======================');

                          write('  -');
                          Console_write(selectedpatch, 3);
                          write(' installation completed without errors.');
                          WriteLog(' installation completed without errors for '
                            + selectedpatch);
                          writeln;
                          // if slUserInstructions.Count > 0 then
                          // begin
                          // writeln;
                          // writeln('Important Instruction :-');
                          // for T := 0 to slUserInstructions.Count - 1 do
                          // begin
                          // writeln('    -' + slUserInstructions[T]);
                          // end;
                          // writeln;
                          // end;
                          WriteUserInstructions;
                        end;
                        patchOrPlugin := '';
                      end;
                    end
                    else
                    begin
                      if (installpatchindex - curpatchindex) > 2 then
                      begin
                        Console_write('Installing Releases from Release' +
                          currentversionname + '/' + currentPatchname + ' to ' +
                          selectedpatch, 14);
                        WriteLog('Installing Releases from Release' +
                          currentversionname + '/' + currentPatchname + ' to ' +
                          selectedpatch);
                        writeln;
                      end;
                      for Z := curpatchindex + 1 to installpatchindex do
                      begin
                        selectedpatch := Patcharray[Z];
                        patchOrPlugin := 'Release';
                        writeln;
                        Console_write('Installing ' + selectedpatch, 14);
                        writeln;
                        writeln;
                        HandleInstallationCommand(selectedpatch);
                        if connectionstatus then
                        begin
                          commandstrlist := TStringList.Create;
                          commandstrlist.Delimiter := '/';
                          commandstrlist.DelimitedText := selectedpatch;
                          sversion := commandstrlist[0] + ' ' +
                            commandstrlist[1];;
                          spatch := commandstrlist[2];
                          commandstrlist.Free;
                          Config.UpdateCurrentPatch(sversion, spatch);
                          currentversionname := sversion;
                          currentPatchname := spatch;
                          // if EnableBackup then
                          // begin
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname+'_temp') then
                          // TDirectory.Delete(getcurrentdir+'\backup\patches\'+projectname+'_temp',True);
                          // patc:=stringreplace(selectedpatch,'/', '\',[rfReplaceAll, rfIgnoreCase]);
                          // forcedirectories(getcurrentdir+'\backup\patches\'+projectname+'\'+patc);
                          // if directoryexists(getcurrentdir+'\backup\patches\'+projectname) then
                          // RenameFile(getcurrentdir+'\backup\patches\'+projectname,getcurrentdir+'\backup\patches\'+projectname+'_temp');
                          // backuppath:=getcurrentdir+'\backup\patches\'+projectname+'\'+patc+'\';
                          // if not directoryexists(backuppath) then
                          // forcedirectories(backuppath);
                          // findfolder(Patchlocalpath+'\OfficialReleases\Patches\'+patc+'\',backuppath);
                          // end;
                          currentPatchname := spatch;
                          patchOrPlugin := '';
                          writeln(' INSTALLATION SUMMARY  ');
                          writeln('=======================');

                          write('  -');
                          Console_write(selectedpatch, 3);
                          write(' installation completed without errors.');
                          writeln;
                          writeln;
                          // if slUserInstructions.Count > 0 then
                          // begin
                          // writeln;
                          // writeln('Important Instruction :-');
                          // for T := 0 to slUserInstructions.Count - 1 do
                          // begin
                          // writeln('    -' + slUserInstructions[T]);
                          // end;
                          // writeln;
                          // end;
                          WriteUserInstructions;
                          WriteErrorList(ExtractFilePath(ParamStr(0)));
                        end;
                        patchOrPlugin := '';
                      end;
                    end;
                    FreeAndNil(Config);
                  end;

                  patchOrPlugin := '';
                  // Break;
                end;
                // else
                // begin
                // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
                // writeln;
                // write('AxInstaller> ');
                // readln(Command);
                // parseCommand(Command);
                // end;
              end;

              // end;
              // else
              // begin
              // writeln;
              // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
              // writeln;
              // write('AxInstaller> ');
              // readln(Command);
              // Parsecommand(Command);
              // end;

              // end;
              // if patchfound then
              // Break;
              // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
              // writeln;
              // write('AxInstaller> ');
              // readln(Command);
              // parseCommand(Command);
            end;
            // end;
            // 2208204
            // if Not IsIISRunning then
            // begin
            // writeln;
            // writeln('IIS is not running. Do you want to start the IIS ? Press ''Y'' to start , ''N'' to skip.');
            // // writeln;
            // write('AxInstaller> ');
            // readln(iisresponse);
            // HandleQuitCommand(iisresponse);
            // end;
            // writeln;
            // write('AxInstaller> ');
            // readln(Command);
            Command := instBeforeReadCommand;
            parseCommand(Command);
          end;
        finally
          if assigned(commandstrlist) then
          begin
            commandstrlist.clear;
            FreeAndNil(commandstrlist);
          end;
        end;


        // writeln('Press ''Enter'' key to exit or any command to continue');

        // Start IIS if not running

        // end
        // else
        // begin
        // writeln('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.');
        // writeln;
        // write('AxInstaller> ');
        // // readln(Command);
        // // parseCommand(Command);
        // readln(Command);
        // parseCommand(Command);
        // end;
      end
      else
      begin
        writeln;
        Console_write
          ('Error: Unrecognized command. Type ''h'' or ''help'' for a list of available commands.',
          12);
        writeln;
        Command := instBeforeReadCommand;
        parseCommand(Command);
      end;
      // 15072024
      // try
      // commandPResent := False;
      // // for I := Low(cmdArray) to High(cmdArray) do
      // // begin
      // // if lowercase(cmdArray[I]) = lowercase(Command) then
      // // begin
      // // commandPResent := True;
      // // end;
      // // if pos('listpatch', Command) > 0 then
      // // begin
      // // commandPResent := True;
      // // end;
      // // end;
      // if True then
      // begin
      // // for Z := Low(PluginArray) to High(PluginArray) do
      // // begin
      // // if pos(lowercase(PluginArray[Z]), commandWord) <> 0 then
      // // patchOrPlugin := 'Plugin';
      // // end;
      // if patchOrPlugin = '' then
      // begin
      // for B := Low(VersionArray) to High(VersionArray) do
      // begin
      // commandstrlist := TStringList.Create;
      // commandstrlist.Delimiter := ' ';
      // commandstrlist.Delimitedtext := commandWord;
      // if pos('install', commandWord) <> 0 then
      // begin
      // if commandstrlist.count >= 3 then
      // begin
      // splitedversion := commandstrlist[1];
      // // splitedSchema := commandstrlist[2];
      // splitedpatch := commandstrlist[2];
      // end;
      // end;
      // // if pos('listpatch', commandWord) <> 0 then
      // // begin
      // // if commandstrlist.count >= 2 then
      // // begin
      // // splitedversion := commandstrlist[1];
      // // // git.createPatchArray(selectedVersion);
      // // // splitedSchema:=commandstrlist[1];
      // // // splitedPatch:=commandstrlist[2];
      // // end;
      // // end;
      // commandstrlist.free;
      //
      // // splitedversion:=copy(commandword,1,4);
      // // splitedpatch:=copy(commandword,length(splitedversion)+1,length(commandword));
      // //
      // begin
      // // commandstrlist := TStringList.Create;
      // splitedversion := 'Version ' + trim(splitedversion);
      // splitedpatch := trim(splitedpatch);
      // if (pos(splitedversion, VersionArray[B]) <> 0) then
      // begin
      // commandPResent := True;
      // selectedversion := splitedversion;
      // git.createPatchArray(selectedversion);
      // if pos('install', commandWord) <> 0 then
      // begin
      // for C := Low(patchArray) to High(patchArray) do
      // begin
      // // if (pos(lowercase(splitedSchema + '/' + splitedpatch),
      // // lowercase(patchArray[C])) <> 0) then
      // if (lowercase(splitedpatch) = lowercase(patchArray[C])) then
      // begin
      // // commandstrlist.Delimiter := '/';
      // // commandstrlist.Delimitedtext := patchArray[C];
      // // selectedSchema := commandstrlist[0];
      // // selectedPatch := commandstrlist[1]; { patchArray[C]; }
      // selectedpatch := patchArray[C];
      // // commandstrlist.free;
      // patchOrPlugin := 'Patch';
      // Break;
      //
      // end;
      //
      // end;
      // end;
      // // selectedPatch:='Patch1';
      // end;
      // Break;
      // // HandleUnInstallationCommand(selectedplugin);
      // end;
      // end;
      // end;
      // end;
      // if patchOrPlugin = 'Plugin' then
      // begin
      // for A := Low(PluginArray) to High(PluginArray) do
      // begin
      // commandWord := Stringreplace(lowercase(commandWord), 'install', '',
      // [rfReplaceAll, rfIgnoreCase]);
      // commandWord := trim(commandWord);
      // Command := commandWord;
      // if comparestr(lowercase(PluginArray[A]), lowercase(commandWord)) = 0
      // then
      // begin
      // commandPResent := True;
      // end;
      // end;
      // end;
      // if commandPResent = True then
      // begin
      // if commandWord = 'config' then
      // HandleConfigCommand();
      // // if commandWord = 'list' then
      // // HandleListCommand('plugin');
      // // if pos('listpatch', commandWord) <> 0 then
      // // begin
      // // selectedVersion := commandWord;
      // // Delete(selectedVersion, 1, length('listpatch'));
      // // selectedVersion := trim(selectedVersion);
      // // selectedVersion := 'Version ' + selectedVersion;
      // // HandleListCommand('patch');
      // // end;
      // // if commandWord = 'help' then
      // // HandleHelpCommand();
      // for I := Low(PluginArray) to High(PluginArray) do
      // begin
      //
      // if (comparestr(lowercase(commandWord), lowercase(PluginArray[I])) = 0)
      // and (pos('uninstall', lowercase(Command)) > 0) then
      // begin
      // selectedplugin := PluginArray[I];
      // HandleUnInstallationCommand(selectedplugin);
      // end;
      //
      // if (comparestr(lowercase(commandWord), lowercase(PluginArray[I])) = 0)
      // { and (pos('install', lowercase(Command)) > 0) } then
      // begin
      // selectedplugin := PluginArray[I];
      // patchOrPlugin := 'Plugin';
      // HandleInstallationCommand(selectedplugin);
      // patchOrPlugin := '';
      // end;
      // end;
      // // for J := Low(VersionArray) to High(VersionArray) do
      // // begin
      // // for L :=Low(PatchArray) to High(PatchArray) do
      // // begin
      // // if (comparestr(lowercase(selectedVersion), lowercase(VersionArray[J])) = 0)
      // // and (comparestr(lowercase(selectedSchema+'/'+selectedPatch), lowercase(PatchArray[L])) = 0)
      // // and (pos('install', lowercase(Command)) > 0) then
      // // begin
      // { if lowercase(selectedSchema) = 'axpertweb' then }
      // currentpatch := currentpatchname;
      // // if lowercase(selectedSchema) = 'axpertdeveloper' then
      // // currentpatch := 'AxpertDeveloper/' + currentdevpatch;
      // // if lowercase(selectedSchema) = 'axpertarm' then
      // // currentpatch := 'AxpertARM/' + currentarmpatch;
      // currentpatchnumber := ExtractPatchNumber(currentpatch);
      // // selectedpatchnumber := ExtractPatchNumber(selectedSchema + '/' +
      // // selectedPatch);
      // selectedpatchnumber := ExtractPatchNumber(selectedpatch);
      // if patchOrPlugin = 'Patch' then
      // begin
      // if selectedpatchnumber < currentpatchnumber then
      // begin
      // writeln;
      // writeln('downgrade installation cannot be done');
      // end
      // else
      // begin
      // // if lowercase(selectedSchema) = 'axpertweb' then
      //
      // curpatchindex := findindex(patchArray, currentpatchname);
      // // else if lowercase(selectedSchema) = 'axpertdeveloper' then
      // // curpatchindex := findindex(patchArray, selectedSchema + '/' +
      // // currentdevpatch)
      // // else if lowercase(selectedSchema) = 'axpertarm' then
      // // curpatchindex := findindex(patchArray, selectedSchema + '/' +
      // // currentarmpatch);
      // installpatchindex := findindex(patchArray, selectedpatch);
      // Config := TConfig.Create;
      // if curpatchindex = -1 then
      // begin
      // for Z := 0 to installpatchindex do
      // begin
      // selectedpatch := patchArray[Z];
      // HandleInstallationCommand(selectedpatch);
      // Config.updatecurrentpatch(selectedSchema, selectedpatch);
      // writeln(' INSTALLATION SUMMARY  ');
      // writeln('=======================');
      // writeln;
      // write('  -');
      // console_write(selectedversion + ' / ' + selectedpatch, 3);
      // write(' installation completed without errors.');
      // writeln;
      // writeln;
      // end;
      // end
      // else
      // begin
      // for Z := curpatchindex to installpatchindex - 1 do
      // begin
      //
      // // commandstrlist := TStringList.Create;
      // // commandstrlist.Delimiter := '/';
      // // commandstrlist.Delimitedtext := patchArray[Z];
      // // selectedSchema := commandstrlist[0];
      // // selectedPatch := commandstrlist[1];
      // selectedpatch := patchArray[Z];
      // HandleInstallationCommand(selectedpatch);
      // // HandleInstallationCommand(selectedSchema + '/' + selectedPatch);
      // // if lowercase(selectedSchema)='axpertweb' then
      // // currentwebpatch:=selectedpatch
      // // else if lowercase(selectedSchema)='axpertdeveloper' then
      // // currentdevpatch:=selectedpatch
      // // else if lowercase(selectedSchema)='axpertarm' then
      // // currentarmpatch:=selectedpatch;
      // // commandstrlist.free;
      // Config.updatecurrentpatch(selectedSchema, selectedpatch);
      // writeln(' INSTALLATION SUMMARY  ');
      // writeln('=======================');
      // writeln;
      // write('  -');
      // console_write(selectedSchema + '/' + selectedpatch, 3);
      // write(' installation completed without errors.');
      // writeln;
      // writeln;
      // end;
      // end;
      // patchOrPlugin := '';
      // Config.free;
      // writeln('Press ''Enter'' key to exit or any command to continue');
      // readln(Command);
      //
      // parseCommand(Command);
      //
      // end;
      // end;
      // // end;
      // // end;
      // //
      // //
      // // end;
      // // pluginnameFlag := False;
      // // for J := Low(PluginArray) to High(PluginArray) do
      // // begin
      // // if commandWord = lowercase(PluginArray[J]) then
      // // begin
      // // if not Assigned(git) then
      // // git := TGitManager.Create;
      // // if not Assigned(database) then
      // // database := TDbConnect.Create;
      // // pluginnameFlag := True;
      // // selectedPlugin := PluginArray[J];
      // // git.PluginInstallation(selectedPlugin);
      // // database.DatabaseConnection();
      // // writeln;
      // // writeln('Press ''Enter'' key to exit or any command to continue');
      // // readln(Command);
      // // if Command = '' then
      // // halt
      // // else
      // // parseCommand(Command);
      // // end;
      // // end;
      // // if pluginnameFlag = False then
      // // repeat
      // // begin
      // // writeln('Plugin name is wrong.Please type correct plugin name');
      // // readln(Command);
      // // parseCommand(Command);
      // // end;
      // // until SearchCommand(Command);
      // // end;
      // // readln;
      // if commandPResent = False then
      // begin
      // repeat
      // begin
      // writeln('Wrong command entered..!Write a command properly.');
      // writeln;
      // readln(Command);
      // end;
      // until comparestr(lowercase(cmdArray[I]), lowercase(Command)) = 0;
      // end;
      // end;
      // Except
      // on E: Exception do
      // writeln('Error : ' + E.Message);
      // end;
      // finally
      // selectedpatch := '';
      // selectedSchema := '';
      // end;

    Except
      on E: Exception do
      begin
        // writeln;
        // write('AxInstaller> ');
        // readln(Command);
        Command := instBeforeReadCommand;
        if Command = '' then
          parseCommand(Command)
        else
          parseCommand(Command);

        ReadErrorList(E.Message);
      end;
    end;

  finally
    // WriteErrorList(ExtractFilePath(ParamStr(0)));
    // Installer_ErrList.clear;
    FreeAndNil(Installer_ErrList);
  end;
end;

function TMain.findpatchindex(patch: string): integer;
var
  I: integer;
  Found: Boolean;
begin
  Found := False;
  for I := Low(Patcharray) to High(Patcharray) do
  begin
    if lowercase(patch) = lowercase(Patcharray[I]) then
    begin
      Result := I;
      Found := True;
      Break;
    end;
  end;
  if Found = False then
    Result := -1;

end;

function TMain.HandleDebug(): string;
begin

end;

function TMain.HandleAllConfigCommand(Command: string;
  bSkipReadCmd: Boolean = False): string;
var
  cfg: TConfig;
  JSONText, TotalJSONText, Cmd: string;
  JSONObject, AppJSONObject: TJSONObject;
  Pair: TJSONPair;
  app: string;
  Confound: Boolean;
  UserJsonFile: TextFile;
  commandstrlist: TStringList;
begin
  try
    cfg := TConfig.Create;
    JSONObject := TJSONObject.Create;
    AppJSONObject := TJSONObject.Create;
    if Pos('reload', lowercase(Command)) <> 0 then
    begin
      writeln;
      // writeln('Reloading the configuration...');
      ReloadConfig();
      // writeln('Configuration reloaded.');
      writeln;

      write('AxInstaller> ');
      readln(Cmd);

      if Cmd = '' then
        parseCommand(Cmd)
      else
        parseCommand(Cmd);
    end
    else if Pos('list', lowercase(Command)) <> 0 then
    begin
      writeln;
      writeln('Available Connections ');
      writeln('==================');
      JSONText := cfg.Readconfigfile();
      if JSONText = 'empty' then
        writeln('Connection not found need to add new connection')
      else
      begin
        JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
        AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
        for Pair in AppJSONObject do
        begin
          writeln('  -' + Pair.JSONString.Value);
        end;
        JSONObject.Free;
        // AppJSONObject.free;
      end;
      writeln;
      write('AxInstaller> ');
      readln(Cmd);
      if Cmd = '' then
        parseCommand(Cmd)
      else
        parseCommand(Cmd);

    end
    else if Pos('set', lowercase(Command)) <> 0 then
    begin
      if Pos('giturl', lowercase(Command)) <> 0 then
      begin
        writeln;
        write('Write a git url :');
        readln(gitpatchurl);
        JSONText := cfg.Readconfigfile();
        JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
        for Pair in JSONObject do
          if lowercase(Pair.JSONString.Value) = lowercase('gitpatchurl') then
          begin
            JSONObject.removepair('gitpatchurl');
            JSONObject.addpair('gitpatchurl', gitpatchurl);
            AssignFile(UserJsonFile, 'appsetting.config');
            Rewrite(UserJsonFile);
            TotalJSONText := JSONObject.ToString;
            TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
              [rfReplaceAll, rfIgnoreCase]);
            writeln(UserJsonFile, TotalJSONText);
            CloseFile(UserJsonFile);
            // Config.ReadConfig(activeconnection, JSONObject);
            JSONObject.Free;
            writeln('Git url is updated successfully..!');
            WriteLog('Git url : ' + gitpatchurl);
            WriteLog('Git url is updated successfully.');
            ReloadConfig();
            Break;
          end;
        // writeln;
        // write('AxInstaller> ');
        // readln(Command);
        Command := instBeforeReadCommand;
        if Command = '' then
          parseCommand(Command)
        else
          parseCommand(Command);
      end
      else if Pos('pluginurl', lowercase(Command)) <> 0 then
      begin
        writeln;
        write('Write plugin git url : ');
        readln(gitpluginurl);

        JSONText := cfg.Readconfigfile();
        JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;

        Confound := False;

        for Pair in JSONObject do
          if lowercase(Pair.JSONString.Value) = 'gitpluginurl' then
          begin
            JSONObject.RemovePair('gitpluginurl');
            JSONObject.AddPair('gitpluginurl', gitpluginurl);
            Confound := True;
            Break;
          end;

        // IF KEY NOT FOUND → ADD IT
        if not Confound then
          JSONObject.AddPair('gitpluginurl', gitpluginurl);

        AssignFile(UserJsonFile, 'appsetting.config');
        Rewrite(UserJsonFile);
        TotalJSONText := JSONObject.ToString;
        TotalJSONText := StringReplace(TotalJSONText, '\', '\\', [rfReplaceAll]);
        writeln(UserJsonFile, TotalJSONText);
        CloseFile(UserJsonFile);

        JSONObject.Free;

        writeln('Plugin git url updated successfully..!');
        WriteLog('Plugin git url : ' + gitpluginurl);
        WriteLog('Plugin git url updated successfully.');

        ReloadConfig();

        Command := instBeforeReadCommand;
        parseCommand(Command);
      end
      else
      begin
        try
          commandstrlist := TStringList.Create;
          commandstrlist.Delimiter := ' ';
          commandstrlist.DelimitedText := Command;
          app := commandstrlist[2];
        Except
          on E: Exception do
          begin
            writeln;
            writeln('Please check given command once again ');
            // writeln;
            // write('AxInstaller> ');
            // // readln(Cmd);
            // readln(Cmd);
            Cmd := instBeforeReadCommand;
            if Cmd = '' then
              parseCommand(Cmd)
            else
              parseCommand(Cmd);
          end;

        end;
        app := Trim(app);
        JSONText := cfg.Readconfigfile();
        if JSONText = 'empty' then
        begin
          writeln('Connection not found need to add new connection');
          writeln;
          write('AxInstaller> ');
          readln(Command);
          if Command = '' then
            parseCommand(Command)
          else
            parseCommand(Command);
        end
        else
        begin
          JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
          Confound := False;
          for Pair in JSONObject do
            if lowercase(Pair.JSONString.Value) = lowercase('activeapp') then
            begin
              activeconnection := lowercase(app);
              JSONObject.removepair('activeapp');
              JSONObject.addpair('activeapp', activeconnection);
              AssignFile(UserJsonFile, 'appsetting.config');
              Rewrite(UserJsonFile);
              TotalJSONText := JSONObject.ToString;
              TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
                [rfReplaceAll, rfIgnoreCase]);
              writeln(UserJsonFile, TotalJSONText);
              CloseFile(UserJsonFile);
              commandstrlist.Free;
              if not assigned(Config) then
                Config := TConfig.Create;
              Config.ReadConfig(activeconnection, JSONObject);
              JSONObject.Free;
              Confound := True;
              if assigned(Config) then
                FreeAndNil(Config);
              writeln;
              Console_write('Current active connection :', 14);
              Console_write(activeconnection, 10);
              writeln;
              Break;

            end;
          if Not bSkipReadCmd then
          begin
            Command := instBeforeReadCommand();
            // readln(Command);

            if Command = '' then
              parseCommand(Command)
            else
              parseCommand(Command);
          end;

        end;
        if Confound = False then
        begin
          writeln('Please check your app name ');
          write('AxInstaller> ');
          readln(Cmd);
          if Cmd = '' then
            parseCommand(Cmd)
          else
            parseCommand(Cmd);
        end;
      end;
    end
    else if Pos('new', lowercase(Command)) <> 0 then
    begin
      if not assigned(cfg) then
        cfg := TConfig.Create;
      cfg.FillUserInfo();
      // console_write('Connection added successfully :' + projectname, 14);
      writeln;
      writeln;
      write('AxInstaller> ');
      readln(Command);
      if Command = '' then
        parseCommand(Command)
      else
        parseCommand(Command);
    end
    else if Pos('edit', lowercase(Command)) <> 0 then
    begin
      // configeditflag:=true;
      if not assigned(cfg) then
        cfg := TConfig.Create;
      cfg.configeditflag := True;
      cfg.FillUserInfo();

      Console_write('Connection updated successfully..!', 14);
      writeln;
      writeln;
      write('AxInstaller> ');
      readln(Command);
      if Command = '' then
        parseCommand(Command)
      else
        parseCommand(Command)
    end
    else if Pos('delete', lowercase(Command)) <> 0 then
    begin
      JSONText := cfg.Readconfigfile();
      try
        commandstrlist := TStringList.Create;
        commandstrlist.Delimiter := ' ';
        commandstrlist.DelimitedText := Command;
        app := commandstrlist[2];
      Except
        on E: Exception do
        begin
          writeln;
          writeln('Please check given command once again ');
          writeln;
          write('AxInstaller> ');
          readln(Cmd);
          if Cmd = '' then
            parseCommand(Cmd)
          else
            parseCommand(Cmd);
        end;

      end;
      app := Trim(app);
      if JSONText = 'empty' then
        writeln('Connection not found need to add new connection')
      else
      begin
        if lowercase(app) = lowercase(activeconnection) then
        begin
          Console_write('You cannot delete active connection', 12);
          writeln;
          writeln;
          write('AxInstaller> ');
          readln(Command);
          if Command = '' then
            parseCommand(Command)
          else
            parseCommand(Command);
        end
        else
        begin
          JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
          AppJSONObject := JSONObject.Get('appsettings')
            .JsonValue as TJSONObject;
          for Pair in AppJSONObject do
            if lowercase(Pair.JSONString.Value) = lowercase(app) then
            begin
              AppJSONObject.removepair(Pair.JSONString.Value);
              AssignFile(UserJsonFile, 'appsetting.config');
              Rewrite(UserJsonFile);
              TotalJSONText := JSONObject.ToString;
              TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
                [rfReplaceAll, rfIgnoreCase]);
              writeln(UserJsonFile, TotalJSONText);
              CloseFile(UserJsonFile);
              Console_write('Connection Deleted from Appsettings successfully..! ', 14);

              //Deletes the conn details from axapps
              projectname:= app;
              database.removingconfromaxapps;
              writeln;
              Console_write('Connection Deleted from AxApps successfully..! ', 14);
            end;

          writeln;
        end;
      end;
      writeln;
      write('AxInstaller> ');
      readln(Command);
      if Command = '' then
        parseCommand(Command)
      else
        parseCommand(Command);

    end;
  finally
    FreeAndNil(cfg);
  end;
end;

function TMain.ExtractPatchNumber(str: string): integer;
var
  slashpos: integer;
begin
  // slashpos := pos('/', str);
  // str := copy(str, slashpos + 1, length(str));
  str := Copy(str, Length('release') + 1, Length(str));
  Result := strtoint(str);
end;

function TMain.SetApplication( { resp: string } ): string;
var
  I: integer;
  Cmd, allParams: string;
begin
  try

    if not assigned(Config) then
      Config := TConfig.Create;
    // Config.isConfigFound();
    // Config.ReadConfig();     [02072024]
    // if Config.readactiveconnection()='False' then
    // begin
    // writeln;
    // writeln('You have not slected any connection as defalut connection.');
    // writeln('choose any connection name to set it default.Use ''Config set <appname>'' to set default cnnection');
    // writeln;
    /// /    for Pair in AppJSONObject do
    /// /    begin
    /// /      writeln('Available Connections');
    /// /      writeln('==================');
    /// /      writeln('  -'+Pair.JSONString.Value);
    /// /    end;
    // //writeln('new');
    /// /  /  writeln;
    // //writeln('Enter your response :');
    // write('AxInstaller>');
    // readln(command);
    // parsecommand(command);
    // end
    // else
    // Showmessage('readactiveconnection starts');
    Config.ReadActiveConnection();
    // Showmessage('readReleasePasswordandGitUrl starts');
    Config.readReleasePasswordandGitUrl();
    // if lowercase(resp) = 'plugin' then
    // begin

    { //      for I := Low(cmdArray) to High(cmdArray) do
      //      begin
      //        writeln(' - ' + cmdArray[I]);            //12072024
      //      end; }
    // end;
    // if lowercase(resp) = 'patches' then
    // begin
    // for I := Low(patchescmdArray) to High(patchescmdArray) do
    // begin
    // writeln(' - ' + patchescmdArray[I]);
    // end;
    // end;
    // initpatch
    // initplugin
    // if not assigned(git) then
    // git := TGitManager.Create;
    // git.createPluginArray();
    // git.createVersionArray();
    // writeln;
    // writeln('-help');
    // write('AxInstaller> ');
    // readln(Cmd);
    // if lowercase(Cmd) = 'help' then
    // begin
    // writeln('         Command                                      Purpose');
    // writeln('---------------------------             -------------------------------------');
    // writeln('help                                     Lists available commands');
    // writeln('config new <appname>                     Allows the user to set up new configurations for AxInstaller.');
    // writeln('config edit <appname>                    Allows the user to edit existing configurations for AxInstaller.');
    // writeln('config delete <appname>                  Deletes the specified appname from the configuration file. If it''s the default or active app, deletion is not allowed.');
    // writeln('config list app                          Lists all available applications from the current machine based on the configuration.');
    // writeln('config set <appname>                     Sets the specified application as the currently active application. All install/uninstall actions will be performed on this application.');
    // writeln('list plugins                             Lists all available plugins from the GIT repository.');
    // writeln('install <plugin_name>                    Pulls the selected plugin from the GIT repository and installs it into the target application.');
    // writeln('listpatch <product_version>              Lists all available patches under the specified product version.');
    // writeln('install <product_version> <patch_name>   Pulls the selected patch from the GIT repository and installs/applies it to the target application.');
    // writeln('uninstall <plugin_name>                  Uninstalls all files related to the specified plugin from the current application.');
    // writeln('uninstall <product_version> <patch_name> Uninstalls all files related to the specified patch from the given product version of the current application.');
    // writeln('quit                                     This command exits the AxInstaller application.');
    // end;
    // Showmessage('ParamStr counnt ' + inttostr(ParamCount));
    writeln;
    write('AxInstaller> ');
    if ParamCount > 0 then
    begin
      allParams := '';
      // ParamStr(0)); // This shows the path of the executable
      for I := 1 to ParamCount do
      begin
        allParams := allParams + ParamStr(I) + ' ';
      end;
      Command := allParams;

    end
    else
      // writeln;
      readln(Command);
    // writeln;
    // Showmessage('Command' + Command);
    parseCommand(Command);

  finally
    begin
      if assigned(git) then
        FreeAndNil(git);
      if assigned(Config) then
        FreeAndNil(Config);
    end;
  end;

end;

function TMain.HandleStructureInstallation(patch: string): string;
begin
  if not assigned(git) then
    git := TGitManager.Create;
  if not assigned(database) then
    database := TDbConnect.Create;
  if not assigned(inst) then
    inst := Tinstallation.Create;
  if not assigned(pinst) then
    pinst := TPatchinstallation.Create;
  //patchOrPlugin := 'Release';
  // git.pullfromgit();
  // Call this method only when there is no Axpertstructure folder exist in the selected release
  // or set a global flag in the bulkinstall command and call this only once.
  if (patchOrPlugin = '') or (patchOrPlugin = 'Release') then
  begin
    if bPullStructures then
      git.pullStructuresfromgit();
    bPullStructures := False;
    patchOrPlugin := '';
    insallstatus := 'Structure';
    writelog('Calling databaseconnectivity from HandleStructureInstallation');
    try
      writelog('tempdbConnectionName: ' + tempDBConnectionName);
      writelog('projectname: ' + projectname);
      pinst.databaseConnectivity(patch);
       writelog('databaseConnectivity completed successfully (HandleStructureInstallation)');
    except
      on E: Exception do
      begin
        writelog('Error in databaseconnectivity from HandleStructureInstallation: ' + E.Message);
        writeln('Error during structure installation: ' + E.Message);
      end;
    end;
    end
  else //Plugin Structure Installation
  begin
    if bPullStructures then
      git.pullStructuresfromgit;

    bPullStructures := False;
    try
      Writelog('InstallPluginWithoutweb function started..');
      writeln;
      database.DatabaseConnection();
      database.installOperation();
      writelog('Plugin scripts executed successfully');
    except
      on E: Exception do
      begin
        writelog('Plugin script execution error: ' + E.Message);
        writeln('Error executing plugin scripts: ' + E.Message);
      end;
    end;
    WriteUserInstructions;
  end;
end;

function TMain.HandleInstallationCommand(Plugin: string): string;
var
  Command: String;
begin
  if not assigned(git) then
    git := TGitManager.Create;
  if not assigned(database) then
    database := TDbConnect.Create;
  if not assigned(inst) then
    inst := Tinstallation.Create;
  if not assigned(pinst) then
    pinst := TPatchinstallation.Create;
  git.pullfromgit();
  if PageNotFoundError then
  begin
    PageNotFoundError := False;
    writeln;
    Command := instBeforeReadCommand();
    readln(Command);
    parseCommand(Command)
  end;
  if patchOrPlugin = 'Release' then
  begin
    insallstatus := 'Full';
    writelog('Calling databaseconnectivity from HandleInstallationCommand');
    try
      //writelog('tempdbConnectionName: ' + tempDBConnectionName);
      writelog('projectname: ' + projectname);
      pinst.databaseConnectivity(Plugin);
      writelog('databaseConnectivity completed successfully (HandleInstallationCommand)');
    except
      on E: Exception do
      begin
        writelog('Error in databaseconnectivity from HandleInstallationCommand: ' + E.Message);
        writeln('Error during installation: ' + E.Message);
      end;
    end;
  end;
  if patchOrPlugin = 'Plugin' then
  begin
    inst.InstallPlugin(Plugin);
    database.DatabaseConnection();
    database.installOperation();
    writeln(' INSTALLATION SUMMARY  ');
    writeln('=======================');
    writeln;
    write('  -');
    Console_write(selectedplugin, 3);
    write(' installation completed without errors.');
    WriteUserInstructions;
    writeln;
    writeln;
    write('AxInstaller> ');
    readln(Command);
    if Command = '' then
      parseCommand(Command)
    else
      parseCommand(Command);
  end;
  writeln;
  // writeln('Press ''Enter'' key to exit or any command to continue');
  // readln(Command);
  // if Command = '' then
  // halt
  // else
  // parseCommand(Command);
end;

function TMain.HandleUnInstallationCommand(Plugin: string): string;
begin
  if not assigned(unst) then
  begin
    unst := TUnIstallation.Create;
  end;
  if not assigned(database) then
    database := TDbConnect.Create;
  database.connecttodb;
  unst.startUninstallation(Plugin);
  writeln;
  // writeln('Press ''Enter'' key to exit or any command to continue');
  write('AxInstaller> ');
  readln(Command);
  if Command = '' then
    halt
  else
    parseCommand(Command);

end;

function TMain.HandleConfigCommand(): string;
begin
  try
    begin
      if not assigned(Config) then
        Config := TConfig.Create;
      Config.IsConfigFound();
      writeln;
      writeln('write command for any process');
      readln(Command);
      if Length(Command) = 0 then
        halt
      else
        parseCommand(Command);

    end;
  finally
    if assigned(Config) then
      FreeAndNil(Config);
  end;
end;

function TMain.HandleHelpCommand(): string;
begin
  writeln;
  writeln('Command' + #9 + #9 + #9 + #9 + #9 + #9 + 'Purpose');
  // write(''+ #9 + #9 + #9 + #9 + #9 + #9 +'');
  // write( 'Purpose');
  writeln('-------------------------------------------------------------------------------');
  Console_write('help', 10);
  write('' + #9 + #9 + #9 + #9 + #9 + #9 + 'Lists available commands');
  writeln;
  writeln;
  Console_write('show current release', 10);
  write('' + #9 + #9 + #9 + #9 +
    'It will help to show current version and release');
  writeln;
  writeln;
  Console_write('bulkinstall <filename>.txt', 10);
  write('' + #9 + #9 + #9 +
    'Reads the specified .txt file and Pulls the selected release from the GIT repository.');
  writeln;
  writeln(#9 + #9 + #9 + #9 + #9 + #9 +
    'And installs it to all specified schemas listed in the file.');
  writeln;
  writeln;
  Console_write
    ('bulkinstall <product_version> <target_release> <filename>.txt -web', 10);
  writeln;
  write('' + #9 + #9 + #9 + #9 + #9 + #9 +
    'Reads the specified .txt file containing schema names (comma-separated or Multi-line)and Executes only scripts');
  writeln;
  writeln(#9 + #9 + #9 + #9 + #9 + #9 +
    'and import structures of the given release to each listed schema.');
  writeln;
  // writeln;

  Console_write
    ('bulkinstall <product_version> <from_release> <to_release> <filename>.txt -web',
    10);
  writeln;
  write('' + #9 + #9 + #9 + #9 + #9 + #9 +
    'Reads the specified .txt file containing schema names (comma-separated or Multi-line)and Executes only scripts');
  writeln;
  writeln(#9 + #9 + #9 + #9 + #9 + #9 +
    'and import structures of the of given release range to each listed schema.');
  writeln;

  Console_write('config new <appname>', 10);
  write('' + #9 + #9 + #9 + #9 +
    'Allows the user to set up new configurations for AxInstaller.');
  writeln;
  writeln;
  Console_write('config edit <appname>', 10);
  write('' + #9 + #9 + #9 + #9 +
    'Allows the user to edit existing configurations for AxInstaller.');
  writeln;
  writeln;
  Console_write('config delete <appname>', 10);
  write('' + #9 + #9 + #9 + #9 +
    'Deletes the specified appname from appsettings and axapps files.');
  writeln;
  writeln(#9 + #9 + #9 + #9 + #9 + #9 +
    'If its the default or active app,deletion is not allowed.');
  writeln;
  // writeln;
  Console_write('config list app', 10);
  write('' + #9 + #9 + #9 + #9 + #9 +
    'Lists all available applications from the current machine based on the configuration.');
  writeln;
  writeln;
  Console_write('config reload', 10);
  write('' + #9 + #9 + #9 + #9 + #9 + 'It will reload the configuration file.');
  writeln;
  writeln;
  Console_write('config set <appname>', 10);
  write('' + #9 + #9 + #9 + #9 +
    'Sets the specified application as the currently active application.');
  writeln;
  // writeln(#9 + #9 + #9 + #9 + #9 + #9 + #9 +
  // 'All install/uninstall actions will be performed on this application.');
  writeln;
  Console_write('config set giturl', 10);
  write('' + #9 + #9 + #9 + #9 + 'It will update git url.');
  writeln;
  writeln;
  Console_write('config set pluginurl', 10);
  write('' + #9 + #9 + #9 + #9 + 'It will add new/update git url for plugin repository.');
  writeln;
  writeln;
  Console_write('list plugins', 10);
  write('' + #9 + #9 + #9 + #9 + #9 +
    'Lists all available plugins from the GIT repository.');

  writeln;
  writeln;
  Console_write('install "<plugin_name>"', 10);
  write('' + #9 + #9 + #9 + #9 +
    'Pulls the selected plugin from the GIT repository and installs it into the target application.');

  writeln;
  writeln;
  Console_write('list versions', 10);
  write('' + #9 + #9 + #9 + #9 + #9 + 'Lists all available versions.');

  writeln;
  writeln;
  Console_write('list release <product_version>', 10);
  write('' + #9 + #9 + #9 +
    'Lists all available releases under the specified product version.');

  writeln;
  writeln;
  Console_write('install <product_version> <release_name>', 10);
  write('' + #9 +
    'Pulls the selected release from the GIT repository and installs/applies it to the target application.');

  writeln;
  writeln;
  Console_write
    ('install <product_version> <release_name> -web [ConnectionName]', 10);
  writeln;
  write('' + #9 + #9 + #9 + #9 + #9 + #9 +
    'Executes only scripts and import structures of given release for mentioned Connection.');

  writeln;
  writeln;
  Console_write
    ('install <product_version> <from_release_name> <to_release_name> -web [ConnectionName]',
    10);
  writeln;
  write('' + #9 + #9 + #9 + #9 + #9 + #9 +
    'Executes scripts and import structures of given release range for mentioned Connection.');

  writeln;
  writeln;
  Console_write('prepare base <product_version>', 10);
  write('' + #9 + #9 + #9 +
    'Command to upgrade the application to the given version’s base.');

  // writeln;
  // writeln;
  // Console_write('upgrade <product_version>', 10);
  // write('' + #9 + #9 + #9 +
  // 'Pull releases up to main folder of <product_version>.');
  //
  // writeln;
  // writeln;
  // Console_write('upgrade <product_version> latest', 10);
  // write('' + #9 + #9 + 'Pull all available releases  for <product_version>.');

  writeln;
  writeln;
  // writeln('listpatch <product_version>' + #9 + #9 + #9 +
  // 'Lists all available patches under the specified product version.');
  // writeln;
  // ('uninstall <plugin_name>    									   Uninstalls all files related to the specified plugin from the current application.');
  // writeln
  // ('uninstall <product_version> <patch_name> 			 Uninstalls all files related to the specified patch from the given product version of the current application.');
  Console_write('debug on', 10);
  write('' + #9 + #9 + #9 + #9 + #9 +
    'This command creates log for application.');

  writeln;
  writeln;
  Console_write('debug off', 10);
  write('' + #9 + #9 + #9 + #9 + #9 +
    'This command will stop creating log for application.');

  writeln;
  writeln;
  Console_write('quit', 10);
  write('' + #9 + #9 + #9 + #9 + #9 + #9 +
    'This command exits the AxInstaller application.');

  writeln;
  writeln('-------------------------------------------------------------------------------');

  writeln;
  write('AxInstaller> ');
  readln(Command);
  if Command = '' then
    parseCommand(Command)
  else
    parseCommand(Command);
end;

function TMain.handlereleasecommand(Command: string): string;
var
  commandstrlist: TStringList;
  editableversion, splitedpatch, splitedversion: string;
  editablepatchname, editablepatchname1, editablepatchname2: string;
  fullsourceurl, fulltargeturl: string;
  A: integer;
begin
  try
    commandstrlist := TStringList.Create;
    commandstrlist.Delimiter := ' ';
    commandstrlist.DelimitedText := Command;
    editableversion := commandstrlist[1];
    splitedpatch := commandstrlist[2];
    commandstrlist.Free;
    splitedversion := 'Version ' + editableversion;
    if not assigned(git) then
      git := TGitManager.Create;
    if Length(versionarray) = 0 then
      git.initversion();
    if Length(Patcharray) = 0 then
      git.createpatcharray();
    for A := Low(versionarray) to High(versionarray) do
    begin
      if lowercase(splitedversion) = lowercase(versionarray[A]) then
      begin
        splitedversion := versionarray[A];
        // if lowercase(splitedpatch) = 'main' then
        // begin
        // splitedpatch := 'Main';
        // end
        if lowercase(splitedpatch) = 'basecode' then
        begin
          splitedpatch := 'BaseCode';
        end
        else
        begin
          editablepatchname := splitedpatch;
          editablepatchname1 := Copy(editablepatchname, 0, 1);
          editablepatchname1 := Uppercase(editablepatchname1);
          editablepatchname2 := Copy(editablepatchname, 2,
            Length(editablepatchname));
          editablepatchname2 := lowercase(editablepatchname2);
          splitedpatch := editablepatchname1 + editablepatchname2;
        end;
        if not assigned(pinst) then
          pinst := TPatchinstallation.Create;
        (*
          Note : 14/11/2024  / 20/11/2024
          - need to remove DevReleases &  OfficialReleases
          as we decided to have  main name for  reportitory itself
          like QAReleases or Axpertreleases
          not like Axpert\AxpertReleases\Officialreleases
        *)
        fullsourceurl := gitpatchurl + 'DevReleases/Patches/' + splitedversion +
          '/' + splitedpatch;
        fulltargeturl := gitpatchurl + 'OfficialReleases/Patches/' +
          splitedversion + '/' + splitedpatch;

        pinst.pushfoldertoOr(fullsourceurl, fulltargeturl);
        writeln;
        Console_write
          ('Patch pushed to official release folder in Git successfully..!',
          10);
        writeln;
      end;
    end;
    if editablepatchname = '' then
    begin
      splitedversion := editableversion;
      splitedversion := 'Version ' + splitedversion;
      // if lowercase(splitedpatch) = 'main' then
      // begin
      // splitedpatch := 'Main';
      // end
      if lowercase(splitedpatch) = 'basecode' then
      begin
        splitedpatch := 'BaseCode';
      end
      else
      begin
        editablepatchname := splitedpatch;
        editablepatchname1 := Copy(editablepatchname, 0, 1);
        editablepatchname1 := Uppercase(editablepatchname1);
        editablepatchname2 := Copy(editablepatchname, 1,
          Length(editablepatchname));
        editablepatchname2 := lowercase(editablepatchname2);
        splitedpatch := editablepatchname1 + editablepatchname2;
      end;
      if not assigned(pinst) then
        pinst := TPatchinstallation.Create;
      fullsourceurl := gitpatchurl + 'DevReleases/Patches/' + splitedversion +
        '/' + splitedpatch;
      fulltargeturl := gitpatchurl + 'OfficialReleases/Patches/' +
        splitedversion + '/' + splitedpatch;

      pinst.pushfoldertoOr(fullsourceurl, fulltargeturl);
      writeln;
      Console_write
        ('Patch pushed to official release folder in Git successfully..!', 10);
      writeln;
    end;
  Except
    on E: Exception do
    begin
      WriteLog('Error While releasing ' + splitedversion + ' ' + splitedpatch +
        ' ' + E.Message);
      Console_write('Error While releasing ' + splitedversion + ' ' +
        splitedpatch, 12);
      writeln;
      Console_write
        ('Please confirm given release is avaialable in git or not', 12);
      writeln;
      writeln;
      write('AxInstaller> ');
      readln(Command);
      parseCommand(Command);
    end;

  end;
  writeln;
  write('AxInstaller> ');
  readln(Command);
  parseCommand(Command);
end;

function TMain.HandleListCommand(res: string): string;
begin
  if not assigned(Config) then
    Config := TConfig.Create;
  if not assigned(git) then
    git := TGitManager.Create;
  // Config.ReadConfig();[02072024]
  // Config.readactiveconnection();
  if res = 'plugin' then
    ListPlugin;
  if res = 'release' then
  begin
    SetLength(Patcharray, 0);
    if Length(Patcharray) = 0 then
      git.createpatcharray( { selectedversion } );
    ListPatch;
    SetLength(Patcharray, 0);
  end;
  writeln;
  write('AxInstaller> ');
  readln(Command);
  if Command = '' then
    parseCommand(Command)
  else
    parseCommand(Command);
end;

function TMain.SearchCommand(Cmd: string): Boolean;
var
  I: integer;
begin
  for I := Low(cmdArray) to High(cmdArray) do
  begin
    if comparestr(lowercase(Cmd), lowercase(cmdArray[I])) = 0 then
      Result := True;
  end;
end;

var
  MainInstance: TMain;
  response: string;

begin
  MainInstance := TMain.Create;
  slUserInstructions := TStringList.Create;
  try
    try
      // MainInstance.ConnectDbOperation;
      InitLogObj;
      MainInstance.startplugin;

      // if lowercase(userresp) = 'plugin' then
      // begin
      // MainInstance.ListOfCommand('plugin');
      // end;
      // if lowercase(userresp) = 'patches' then
      // begin
      // MainInstance.ListOfCommand('patches');
      // end;

      // writeln('CDS imported');
      // MainInstance.ListOfCommand();           //[28062024]
      // MainInstance.GetConfig;                 // [28062024]

      // Showmessage('SetApplication starts');
      MainInstance.SetApplication();
      // Showmessage('SetApplication ends');
      writeln;
      // writeln('Press ''Enter'' key to exit or any command to continue');
      // write('AxInstaller> ');
      // readln(response);
      // writeln;
      // if response = '' then
      // halt
      // else
      // MainInstance.parseCommand(response);
    Except
      on E: Exception do
      begin
        writeln('Error :' + E.Message);
        readln;
        WriteLog('Error : ' + E.Message);
        writeln;
        write('AxInstaller> ');
        readln(Command);
        if Command = '' then
          MainInstance.parseCommand(Command)
        else
          MainInstance.parseCommand(Command);
      end;

    end;
  finally
    MainInstance.Free;
    UpdateLogObj;
    DestroyLogObj;
    // if assigned(slUserInstructions) then
    // slUserInstructions.Destroy;

  end;


  // if pos('uninstall', lowercase(Command)) > 0 then
  // begin
  // MainInstance.ConnectDbOperation;
  // MainInstance.UnInstallPlugin;
  // end
  // else
  // begin
  // MainInstance.InstallPlugin;
  // MainInstance.ConnectDbOperation;
  // end;


  // readln(Command);
  /// ///    //writeln(isProceedNext);
  // if isProceedNext = True then
  // he agodr uncommented hot
  // MainInstance.ListPlugin;
  // InstallOperation


  //

  // readln; readln; finally
  // FreeAndNil(MainInstance);
  // end;

  // end ;
end.
