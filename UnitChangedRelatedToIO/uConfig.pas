unit uConfig;

interface

uses
  System.SysUtils, Dialogs, System.IOUtils, windows, System.Classes, uUtils,
  uDBManager,
  Data.DBXJSON, XMLDoc, XMLIntf, uAxLog, uDbConnect,uAppIO;

type
  TConfig = class
  private
    userresp: string;
    configpath: string;
    JSONString: string;
    bUpdateConfig: boolean;
    // procedure SetPatchLocalPath;

  public
    configeditflag: boolean;
    function UserInfo(): string;
    function ReadConfig(con: string; JSONObject: TJSONObject): boolean;
    function UpdateConfig(prjname: string): boolean;
    function CreateJson(prjname: string): string;
    function createconfigfile(jtext, FilePath: string): string;
    function IsConfigFound(): boolean;
    function updateaxapps(runappnode, devappnode: IXMLNode): string;
    function FillUserInfo(): string;
    function EncryptString(): string;
    function ReadKey: char;
    function CreateConfig(): string;
    function isConnectionfound(prjctname: string): boolean;
    function readactiveconnection(): string;
    function checkaxapps(prjname: string): boolean;
    function createNode(DB, DBCon, DBUser, DBPass, schema: string): string;
    function updatecurrentpatch(version, patch: string): string;
    function readconfigfile(): string;
    function addingconToaxapps(): String;
    function readReleasePasswordandGitUrl(): string;
    function changeadminpassword(newpassword: string): string;
    function ReadInputs(ReadString: string;
      IsMandatory: boolean = True): string;
    function ExtractNumbers(str: string): string;
    procedure SetPatchLocalPath;
    constructor Create;
  end;

implementation

constructor TConfig.Create;
begin
  inherited;
  configeditflag := False;
end;

procedure EvaluateDefSchemaFlag(const AVersion: string);
var
  vList: TStringList;
  v: string;
begin
  vList := TStringList.Create;
  try
    vList.Add('11.0');
    vList.Add('11.1');
    vList.Add('11.2');
    vList.Add('11.3');

    v := LowerCase(Trim(AVersion));
    v := StringReplace(v, 'version', '', []);
    v := Trim(v);

    HasDefSchema := vList.IndexOf(v) <> -1;
  finally
    vList.Free;
  end;
end;

function TConfig.ReadInputs(ReadString: string;
  IsMandatory: boolean = True): string;
var
  output: string;
begin
  // Appwriteln;
  AppWrite(ReadString + ': ');
  appreadln(output);
  if (output = '') and IsMandatory then
  begin
    Appwriteln;
    Appwriteln(ReadString + ' is mandatory. Please enter the required details.');
    ReadInputs(ReadString)
  end
  else
    Result := output;
end;

function TConfig.changeadminpassword(newpassword: string): string;
var
  JSONText, TotalJSONText: string;
  JSONObject: TJSONObject;
  UserJsonFile: TextFile;
begin
  try
    writelog('changeadminpassword function started..');
    JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
    JSONText := Trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    JSONObject.removepair('adminpwd');
    // activeconnection:=Projectname;

    JSONObject.addpair('adminpwd', newpassword);
    AssignFile(UserJsonFile, AppDir +'appsetting.config');
    Rewrite(UserJsonFile);
    TotalJSONText := JSONObject.ToString;
    TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    Appwriteln(UserJsonFile, TotalJSONText);
    CloseFile(UserJsonFile);
    writelog('New password is updated successfully in appsetting.config');
    writelog('changeadminpassword function ends..');
  Except
    on E: Exception do
      writelog('Error in changeadminpassword :' + E.Message);
  end;
end;

function TConfig.addingconToaxapps(): String;
var
  DB, DBCon, DBUser, DBPass: string;
  axappsUpdated, axappsFound: boolean;
  strlist1, strlist2, strlist3: TStringList;
  XMLDoc1, XMLDoc2, XMLDoc3, XMLDoc4: IXMLDocument;
  // Node1, Node2, Node3, Node4: IXMLNode;
  runappnode, devappnode, AxIns_runappnode, AxIns_devappnode: IXMLNode;
  axapps: TextFile;
begin
  writelog('addingconToaxapps function started..');
  strlist1 := TStringList.Create;
  strlist2 := TStringList.Create;
  strlist3 := TStringList.Create;
  strlist1.LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchRunscript }
    runscriptpath + '\axapps.xml');
  // 11.4 and above devscript path wont be available
  if Trim(devscriptpath) <> '' then
    strlist2.LoadFromFile
      ( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
      devscriptpath + '\axapps.xml');

  if FileExists(runscriptpath + '\axapps.xml') then
  begin
    with TStringList.Create do
    begin
      LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchRunscript }
        runscriptpath + '\axapps.xml');
      XMLDoc1 := LoadXMLData(text); // runscript mdla xml
      destroy;
    end;
    runappnode := XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname);
    // runscr mdla projectname cha node
  end;
  if FileExists( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
    devscriptpath + '\axapps.xml') then
  begin
    with TStringList.Create do
    begin
      LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
        devscriptpath + '\axapps.xml');
      XMLDoc2 := LoadXMLData(text);
      destroy;
    end;
    devappnode := XMLDoc2.DocumentElement.ChildNodes.FindNode
      (projectname + 'axdef'); // devscr mdla axdef
  end;
  axappsFound := False;
  if FileExists( { 'D:\Axpert_Project\installer_Axpert  getcurrentdir() } AppDir
    + 'axapps.xml') then
  begin
    axappsFound := True;
    strlist3.LoadFromFile( { 'D:\Axpert_Project\installer_Axpert  getcurrentdir
        () } AppDir + 'axapps.xml');
  end
  else
  begin
    AssignFile(axapps,AppDir + 'axapps.xml');
    Rewrite(axapps);
    CloseFile(axapps);
    strlist3.LoadFromFile( { getcurrentdir() } AppDir + 'axapps.xml');
    axappsFound := True;
  end;
  if axappsFound then
  begin
    with TStringList.Create do
    begin
      LoadFromFile( { getcurrentdir() } AppDir + 'axapps.xml');
      XMLDoc3 := LoadXMLData(text);
      destroy;
    end;
    AxIns_runappnode := XMLDoc3.DocumentElement.ChildNodes.FindNode
      (projectname); // local projectname cha node
  end;
  // process only for 11.3
  if { (lowercase(currentversionname) = 'version 11.3') } HasDefSchema and axappsFound
  then
  begin
    with TStringList.Create do
    begin
      LoadFromFile( { getcurrentdir() } AppDir + 'axapps.xml');
      XMLDoc4 := LoadXMLData(text);
      destroy;
    end;
    AxIns_devappnode := XMLDoc4.DocumentElement.ChildNodes.FindNode
      (projectname + 'axdef'); // local axdef cha node
  end;
  axappsUpdated := False;

  //if condition may not be required,need to optimize - 03/04/2026
  if ((assigned(AxIns_runappnode)) or (assigned(AxIns_devappnode))) then
  begin
    axappsUpdated := True;
    updateaxapps(runappnode, devappnode);
  end // Assigned Node2 or  verison <> 11.3
  // for above 11.3 we will not have node2 (<project>axdef)
  else if ((assigned(runappnode)) and
    { ((assigned(devappnode) or (lowercase(currentversionname) <> 'version 11.3') )) }
    (assigned(devappnode) or not HasDefSchema)) then
  begin
    axappsUpdated := True;
    updateaxapps(runappnode, devappnode);
  end
  else
  begin
    Appwriteln('the given connection name details ' + projectname +
      ' were not found in the corresponding script folder');
    writelog(projectname + ' config details not found in axapps.xml');
    Appwriteln('please provide App schema and def schema details');
    Appwriteln;
    Appwriteln('For app schema : ');
    AppWrite(' -DB : ');
    appreadln(DB);
    AppWrite(' -DB Connection : ');
    appreadln(DBCon);
    AppWrite('-DB User : ');
    appreadln(DBUser);
    AppWrite(' -DB Password : ');
    appreadln(DBPass);
    writelog('Credentials for app schema got successfully');
    writelog('creating node with given details.');
    writelog('Creating node for run schema');
    createNode(DB, DBCon, DBUser, DBPass, 'run');
    // Prompts ONLY FOR 11.0–11.3
    if HasDefSchema then
    begin
      Appwriteln;
      Appwriteln('For Dev schema : ');
      AppWrite(' -DB : ');
      appreadln(DB);
      AppWrite(' -DB Connection : ');
      appreadln(DBCon);
      AppWrite(' -DB User : ');
      appreadln(DBUser);
      AppWrite(' -DB Password : ');
      appreadln(DBPass);
      writelog('Credentials for def schema got successfully');
      writelog('creating node with given details.');
      writelog('Creating node for dev schema');
      createNode(DB, DBCon, DBUser, DBPass, 'dev');
    end;
    // {axappsUpdated} Result:= True;              ///make it as return
    writelog('axapps.xml updated successfully.');
  end;
  // if axappsUpdated then
  // begin
  // AssignFile(UserJsonFile, 'appsetting.config');
  // Rewrite(UserJsonFile);
  // TotalJSONText := stringreplace(JSONObject.ToString, '\', '\\',
  // [rfReplaceAll, rfIgnoreCase]);
  // Appwriteln(UserJsonFile, TotalJSONText);
  // CloseFile(UserJsonFile);
  // writelog('Connection added successfully for '+projectname);
  // Appwriteln;
  // end
  // else
  // begin
  // Appwriteln('connection details not found from the given script folder');
  // Appwriteln('Please add those connection in corrosponding script folder');
  // writelog('connection details not found from the given script folder');
  // halt;
  // end;
  writelog('addingconToaxapps function ends..')
end;

function TConfig.readconfigfile(): string;
var
  JSONText: String;
begin
  writelog('readconfigfile function started..');
  writelog('DLL Path '+ GetDllPath);
  if FileExists(AppDir +'appsetting.config') then
  begin
    JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
    JSONText := Trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    Result := JSONText;
  end
  else
  begin
    Result := 'empty';
  end;
  writelog('readconfigfile function ends..');
end;

function TConfig.updatecurrentpatch(version, patch: string): string;
var
  JSONText, TotalJSONText: string;
  JSONObject, AppJSONObject, conObject: TJSONObject;
  UserJsonFile: TextFile;
  Pair: TJSONPair;
begin
  writelog('updatecurrentpatch function started..');
  JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
  JSONText := Trim(JSONText);
  JSONText := StringReplace(JSONText, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
  JSONText := StringReplace(JSONText, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
  JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
  for Pair in AppJSONObject do
  begin
    if LowerCase(Pair.JSONString.Value) = LowerCase(activeconnection) then
    begin
      conObject := AppJSONObject.Get(activeconnection).JsonValue as TJSONObject;
      // if LowerCase(schema)='axpertweb' then
      // begin
      conObject.removepair('currentversionname');
      conObject.addpair('currentversionname', version);
      conObject.removepair('currentpatchname');
      conObject.addpair('currentpatchname', patch);
      writelog('New current version : ' + version);
      writelog('New current release : ' + patch);
      // end;
      // if LowerCase(schema)='axpertdeveloper' then
      // begin
      // conObject.removepair('currentdevpatch');
      // conObject.addpair('currentdevpatch',patch);
      // end;
      // if LowerCase(schema)='axpertarm' then
      // begin
      // conObject.removepair('currentarmpatch');
      // conObject.addpair('currentarmpatch',patch);
      // end;
      // activeconnection := lowercase(setdef);
      // JSONObject.removepair('activeapp');
      // JSONObject.addpair('activeapp', activeconnection);
      AssignFile(UserJsonFile, AppDir +'appsetting.config');
      Rewrite(UserJsonFile);
      TotalJSONText := JSONObject.ToString;
      TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
      Appwriteln(UserJsonFile, TotalJSONText);
      CloseFile(UserJsonFile);
      writelog('current patch updated in config file');
    end;
  end;
  writelog('updatecurrentpatch function ends..');

end;

function TConfig.checkaxapps(prjname: string): boolean;
var
  XMLDoc1: IXMLDocument;
  appNode, DefNode: IXMLNode;
begin
  writelog('checkaxapps function started..');
  if FileExists(AppDir + 'axapps.xml') then
  begin
    with TStringList.Create do
    begin
      LoadFromFile(AppDir + 'axapps.xml');
      XMLDoc1 := LoadXMLData(text);
      destroy;
    end;
    appNode := XMLDoc1.DocumentElement.ChildNodes.FindNode(prjname);
    DefNode := XMLDoc1.DocumentElement.ChildNodes.FindNode(prjname + 'axdef');
    if (assigned(appNode)) and (assigned(DefNode)) then
      Result := True
    else
      Result := False;
  end;
  writelog('checkaxapps function ends..');
end;

function TConfig.updateaxapps(runappnode, devappnode: IXMLNode): string;
var
  tNode1, tNode2, RootNode: IXMLNode;
  XMLDoc1: IXMLDocument;
begin
  writelog('updateaxapps function started..');
  if FileExists(AppDir + 'axapps.xml') then
  begin
    with TStringList.Create do
    begin
      LoadFromFile(AppDir + 'axapps.xml');
      XMLDoc1 := LoadXMLData(text);
      destroy;
    end;
    tNode1 := XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname);
    // Commented on 02/04/2026
    // if not assigned(tNode1) then //update only for 11.3
    // XMLDoc1.DocumentElement.ChildNodes.Add(Node1.CloneNode(True));

    // If the AxInstaller directory (AxApps) already contains the connection node,
    // it will be removed and replaced by cloning the latest node from the
    // script folder (Run/Dev) to ensure updated connection details are maintained.

    // If the node exists, delete it
    if assigned(tNode1) then
      XMLDoc1.DocumentElement.ChildNodes.Remove(tNode1);

    // Clone and add the latest node (Node1 contains updated connection details)
    XMLDoc1.DocumentElement.ChildNodes.Add(runappnode.CloneNode(True));
    // above block is added on 02/04/2026

    if (LowerCase(currentversionname) = 'version 11.3') then
    begin
      tNode2 := XMLDoc1.DocumentElement.ChildNodes.FindNode
        (projectname + 'axdef');
      // if not assigned(tNode2) then
      // XMLDoc1.DocumentElement.ChildNodes.Add(Node2.CloneNode(True));

      // If the AxInstaller directory (AxApps) already contains the connection node,
      // it will be removed and replaced by cloning the latest node from the
      // script folder (Run/Dev) to ensure updated connection details are maintained.

      // If the node exists, delete it
      if assigned(tNode2) then
        XMLDoc1.DocumentElement.ChildNodes.Remove(tNode2);

      // Clone and add the latest node (Node1 contains updated connection details)
      XMLDoc1.DocumentElement.ChildNodes.Add(devappnode.CloneNode(True));
      // above block is added on 02/04/2026
    end;
    // tNode3:=XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname);
    // if not Assigned(tNode3) then
    // XMLDoc1.DocumentElement.ChildNodes.Add(Node3.CloneNode(True));
    // tNode4:=XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname+'axdef');
    // if not Assigned(tNode4)  then
    // XMLDoc1.DocumentElement.ChildNodes.Add(Node4.CloneNode(True));
    // TargetDoc.DocumentElement.ChildNodes.FindNode('node_to_copy');
    XMLDoc1.SaveToFile(AppDir + 'axapps.xml');
    writelog('New db connection noded added successfully to axapps.xml');
  end
  else
  begin
    XMLDoc1.Active := True;
    RootNode := XMLDoc1.CreateElement('connections', '');
    XMLDoc1.DocumentElement := RootNode;
    XMLDoc1.SaveToFile(AppDir + 'axapps.xml');
    writelog('connections (Root noded) added successfully');
    updateaxapps(runappnode, devappnode);
  end;
  writelog('updateaxapps function ends..');
end;

// This will set Git root dir path
Procedure TConfig.SetPatchLocalPath;
var
  GitRootDir: String;
begin
  // Appwriteln('GitPatchURL : '+GitPatchURL);
  GitRootDir := ExtractRootDirFromURL(GitPatchURL);
  // Appwriteln('GitRootDir : '+GitRootDir);
  if GitRootDir <> '' then
    patchLocalPath := { GetCurrentDir + '\' } AppDir + GitRootDir + '\';
  // Appwriteln('patchLocalPath : '+patchLocalPath);
end;

function TConfig.readReleasePasswordandGitUrl(): string;
var
  EncrptPass: string;
  FilePath, JSONText: string;
  JSONObject: TJSONObject;
begin
  try
    writelog('readReleasePasswordandGitUrl function started..');
    if FileExists(AppDir +'appsetting.config') then
    begin
      FilePath := { getcurrentdir() } AppDir + 'appsetting.config';
    end
    else
    begin
      writelog('Config file not found');
      CreateConfig();
      FilePath := { getcurrentdir() } AppDir + 'appsetting.config';
    end;
    JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
    JSONText := Trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    // JSONObject.addpair('activeapp', activeconnection);
    EncrptPass := JSONObject.Get('adminpwd').JsonValue.Value;
    writelog('Encrypted password : ' + EncrptPass);
    if not assigned(dbm) then
      dbm := TDbManager.Create;
    adminpwd := dbm.gf.DecryptFldValue(EncrptPass, 't');

    GitPatchURL := JSONObject.Get('gitpatchurl').JsonValue.Value;
    GitPatchURL := Trim(GitPatchURL);

    if assigned(JSONObject.Get('gitpluginurl')) then
      GitPluginUrl := Trim(JSONObject.Get('gitpluginurl').JsonValue.Value)
    else
      GitPluginUrl := '';

    if assigned(JSONObject.Get('gitpackageurl')) then
      GitPackageUrl := Trim(JSONObject.Get('gitpackageurl').JsonValue.Value)
    else
      GitPackageUrl := '';

    if assigned(JSONObject.Get('armsigninurl')) then
      ArmSignInUrl := Trim(JSONObject.Get('armsigninurl').JsonValue.Value)
    else
      ArmSignInUrl := '';

    if assigned(JSONObject.Get('armaxputurl')) then
      ArmAxPutUrl := Trim(JSONObject.Get('armaxputurl').JsonValue.Value)
    else
      ArmAxPutUrl := '';

    if assigned(JSONObject.Get('armbaseurl')) then
      ArmBaseUrl := Trim(JSONObject.Get('armbaseurl').JsonValue.Value)
    else
      ArmBaseUrl := '';

    SetPatchLocalPath;
    writelog('Git Url : ' + GitPatchURL);
    writelog('Git Plugin Url : ' + GitPluginUrl);
    writelog('Git Package Url : ' + GitPackageUrl);
    writelog('ARM Base Url : ' + ArmBaseUrl);
    writelog('Got password in decrypted format');
    writelog('readReleasePasswordandGitUrl function ends..');
  finally
    Freeandnil(dbm);
  end;

end;

function TConfig.readactiveconnection(): string;
var
  JSONText, TotalJSONText: string;
  JSONObject, AppJSONObject: TJSONObject;
  Pair: TJSONPair;
  UserJsonFile: TextFile;
  setdef, FilePath: string;
  FileStream: TFileStream;
  NodePresent: boolean;
begin
  writelog('readactiveconnection function started..');
  // Showmessage('Start Path '+getcurrentdir());
  if FileExists(AppDir +'appsetting.config') then
  begin
    FilePath := { getcurrentdir() } AppDir + 'appsetting.config';
  end
  else
  begin
    writelog('Config file not found');
    CreateConfig();
    FilePath := { getcurrentdir() } AppDir + 'appsetting.config';
  end;
  // Showmessage('Filestream 01');
  FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
  // Showmessage('Filestream 02');
  if FileStream.Size = 0 then
  begin
    if assigned(FileStream) then
      FileStream.Free;
    // Showmessage('Filestream 03');
    FillUserInfo();
    Appwriteln;
    Appwriteln('You have not slected any connection as defalut connection.');
    Appwriteln('Making ' + projectname + ' as a active connection.');
    writelog('Making ' + projectname + ' as a active connection.');
    Appwriteln;
    // Showmessage('JSONText ');
    writelog('reading appsetting file from appdir if block');
    JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
    JSONText := Trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    writelog('If block after json parse getting appsettings');
    AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
    for Pair in AppJSONObject do
    begin
      if LowerCase(Pair.JSONString.Value) = LowerCase(projectname) then
      begin
        activeconnection := setdef; //LowerCase(setdef);
        JSONObject.removepair('activeapp');
        activeconnection := projectname;
        JSONObject.addpair('activeapp', activeconnection);
        AssignFile(UserJsonFile, AppDir +'appsetting.config');
        Rewrite(UserJsonFile);
        TotalJSONText := JSONObject.ToString;
        TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        Appwriteln(UserJsonFile, TotalJSONText);
        CloseFile(UserJsonFile);
        writelog(projectname +
          ' updated in appsetting.config as a active connection.');
        NodePresent := checkaxapps(Pair.JSONString.Value);
        // if NodePresent then
        ReadConfig(activeconnection, JSONObject);
        if NodePresent then
          // else
          UpdateConfig(activeconnection);
        Appwriteln;
        Console_Write('Current active connection :' + activeconnection, 14);
        Appwriteln;
      end;
    end;
  end
  else
  begin
    // Showmessage('Filestream 04');
    writelog('else part');
    FileStream.Free;
    // Showmessage('FileStream free');
    writelog('reading json from app dir'+AppDir);
    JSONText := TFile.ReadAllText( { getcurrentdir() } AppDir +
      'appsetting.config');
    // Showmessage('JSONText ');
    JSONText := Trim(JSONText);
    JSONText := StringReplace(JSONText, '\\', '\',
      [rfReplaceAll, rfIgnoreCase]);
    JSONText := StringReplace(JSONText, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    writelog('after reading parsing json');
    JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    writelog('getting appsettings from json file');
    AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
    if length(JSONObject.Get('activeapp').JsonValue.ToString) > 2 then
    begin
      writelog('active connection found');
      activeconnection := JSONObject.Get('activeapp').JsonValue.Value;
      // AppWriteln;
      Console_Write('Current active connection :', 14);
      Console_Write(activeconnection, 10);
      AppWriteln;
    end;
  end;

  // AppWriteln('Current active connection :' + activeconnection);
  // AppWriteln('press enter to continue or choose connection name to set it default or enter new to add new connection');
  // for Pair in AppJSONObject do
  // begin
  // AppWriteln(Pair.JSONString.Value);
  // end;
  // AppWriteln('new');
  // AppWriteln;
  // AppWriteln('Enter your response :');
  // appreadln(setdef);
  // if lowercase(setdef) = 'new' then
  // begin
  // FillUserInfo();
  // end
  // else if setdef = '' then
  if IsConfigReload then // added this block to avoid AppWriteln (Config Reload)
  begin
    ReadConfig(activeconnection, JSONObject);
  end
  else
  begin
    AppWriteln('Initiating Application...');
    ReadConfig(activeconnection, JSONObject);
    AppWriteln('Application Ready..!');
  end;
  // exit;
  // else
  // begin
  // for Pair in AppJSONObject do
  // begin
  // if lowercase(Pair.JSONString.Value) = lowercase(setdef) then
  // begin
  //
  // activeconnection := lowercase(setdef);
  // JSONObject.removepair('activeapp');
  // JSONObject.addpair('activeapp', activeconnection);
  // AssignFile(UserJsonFile, 'appsetting.config');
  // Rewrite(UserJsonFile);
  // TotalJSONText := JSONObject.ToString;
  // TotalJSONText := stringreplace(JSONObject.ToString, '\', '\\',
  // [rfReplaceAll, rfIgnoreCase]);
  // AppWriteln(UserJsonFile, TotalJSONText);
  // CloseFile(UserJsonFile);
  // NodePresent := checkaxapps(Pair.JSONString.Value);
  // // if NodePresent then
  // ReadConfig(activeconnection, JSONObject);
  // // else
  // if not NodePresent then
  // UpdateConfig(activeconnection);
  //
  // end;
  // end;

  // else
  // // Result:='False';
  // begin
  // AppWriteln;
  // AppWriteln('You have not slected any connection as defalut connection.');
  // AppWriteln('Making '+projectname+' as a active connection.');
  // AppWriteln;
  /// /    for Pair in AppJSONObject do
  /// /    begin
  /// /      AppWriteln('Available Connections');
  /// /      AppWriteln('==================');
  /// /      AppWriteln('  -'+Pair.JSONString.Value);
  /// /    end;
  /// /    //AppWriteln('new');
  /// /    AppWriteln;
  /// /    //AppWriteln('Enter your response :');
  /// /    AppWrite('AxInstaller>');
  /// /    appreadln(setdef);
  /// /    if lowercase(setdef) = 'new' then
  /// /    begin
  /// /      FillUserInfo();
  /// /    end;
  // for Pair in AppJSONObject do
  // begin
  // if lowercase(Pair.JSONString.Value) = lowercase(setdef) then
  // begin
  // activeconnection := lowercase(setdef);
  // JSONObject.removepair('activeapp');
  // activeconnection:=Projectname;
  // JSONObject.addpair('activeapp', activeconnection);
  // AssignFile(UserJsonFile, 'appsetting.config');
  // Rewrite(UserJsonFile);
  // TotalJSONText := JSONObject.ToString;
  // TotalJSONText := stringreplace(JSONObject.ToString, '\', '\\',
  // [rfReplaceAll, rfIgnoreCase]);
  // AppWriteln(UserJsonFile, TotalJSONText);
  // CloseFile(UserJsonFile);
  // NodePresent := checkaxapps(Pair.JSONString.Value);
  // // if NodePresent then
  // ReadConfig(activeconnection, JSONObject);
  // if NodePresent then
  // // else
  // UpdateConfig(activeconnection);
  // AppWriteln;
  // Console_Write('Current active connection :' + activeconnection, 14);
  // AppWriteln;
  // end;
  // end;
  // end;
end;

function TConfig.ReadConfig(con: string; JSONObject: TJSONObject): boolean; // 2
var
  JSONText, jtext: string;
  // JSONObject: TJSONObject;
  AppJSONObject, prjObject, JObject: TJSONObject;
  Pair: TJSONPair;
  index: integer;
  UserJsonFile: TextFile;
  // Pair: TJSonPair;
  activecon: string;
  congigurationfound: boolean;
  EncrGitPass, EncrAccessToken: String;
  DecrGitPass, DecrAccessToken: String;
begin
  try
    writelog('Readconfig function started..');
    if not assigned(dbm) then
      dbm := TDbManager.Create;

    writelog('DB Manager created successfully');
    // Result := True;
    //
    // JSONText := TFile.ReadAllText('appsetting.config');
    // JSONText := Trim(JSONText);
    // JSONText := stringreplace(JSONText, '\\', '\',
    // [rfReplaceAll, rfIgnoreCase]);
    // JSONText := stringreplace(JSONText, '\', '\\',
    // [rfReplaceAll, rfIgnoreCase]);
    // JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
    // if JSONObject.Get('activeapp').JsonValue.ToString<> '' then
    // begin
    // activeconnection:= JSONObject.Get('activeapp').JsonValue.Value;
    // // readactiveconnection(activeconnection,JSONObject);
    // end;

    try
      if JSONObject.Get('appsettings').JsonValue.ToString <> '' then
      begin
        writelog('Reading appsetting.config.');
        AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
        Pair := AppJSONObject.Get(con);
        if Assigned(Pair) then
          prjObject := Pair.JsonValue as TJSONObject
        else
          raise Exception.Create('The specified project '+con+' is not available');
        // congigurationfound:=False;
        // for Pair in AppJSONObject do
        // begin
        // if(Pair.JsonString.Value=con)then
        // congigurationfound:True;
        // end;
        // if congigurationfound=False then
        // begin
        // AppWriteln('configuration not found with your connection');
        // AppWriteln('connection name may be wrong please type properly');
        // end;

        { if AppJSONObject.Get('projectname').JsonValue.Value = '' then
          begin
          FillUserInfo();
          bUpdateConfig:=False;
          end }
        // else

        projectname := prjObject.Get('projectname').JsonValue.Value;
        MultiProjConnNames := projectname;
        // assign multiple project conn names to MultiProjConnNames
        projectname := dbm.gf.GetNThstring(projectname, 1);
        // Take first project as active project

        // GITPluginURL := prjObject.Get('gitpluginurl').JsonValue.Value;
        // GITPatchURL := prjObject.Get('gitpatchurl').JsonValue.Value;
        runwebcodepath := prjObject.Get('runwebcodepath').JsonValue.Value;
        runwebcodepath := StringReplace(runwebcodepath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        devwebcodepath := prjObject.Get('devwebcodepath').JsonValue.Value;
        devwebcodepath := StringReplace(devwebcodepath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        runscriptpath := prjObject.Get('runscriptpath').JsonValue.Value;
        runscriptpath := StringReplace(runscriptpath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        devscriptpath := prjObject.Get('devscriptpath').JsonValue.Value;
        devscriptpath := StringReplace(devscriptpath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        agileconnectpath := prjObject.Get('agileconnectpath').JsonValue.Value;
        agileconnectpath := StringReplace(agileconnectpath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        armapipath := prjObject.Get('armapipath').JsonValue.Value;
        armapipath := StringReplace(armapipath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        armscriptpath := prjObject.Get('armscriptpath').JsonValue.Value;
        armscriptpath := StringReplace(armscriptpath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        armservicepath := prjObject.Get('armservicepath').JsonValue.Value;
        // r,q client
        armservicepath := StringReplace(armservicepath, '\', '\\',
          [rfReplaceAll, rfIgnoreCase]);
        apparchitecture := prjObject.Get('apparchitecture').JsonValue.Value;
        // currentwebpatch := prjObject.Get('currentwebpatch').JsonValue.Value;
        // currentwebpatch:='AxpertWeb/'+currentwebpatch; currentpatchnumber

        if Assigned(prjObject.Get('iispluginapppath')) then
          iispluginapppath := prjObject.Get('iispluginapppath').JsonValue.Value
        else
          iispluginapppath := '';

        currentversionname := prjObject.Get('currentversionname')
          .JsonValue.Value;
        if pos(#$D#$A, currentversionname) <> 0 then
          currentversionname := StringReplace(currentversionname, #$D#$A, ' ',
            [rfReplaceAll]);
        EvaluateDefSchemaFlag(currentversionname);
        currentpatchname := prjObject.Get('currentpatchname').JsonValue.Value;
        // currentdevpatch :='AxpertDeveloper/'+currentdevpatch;;
        // currentarmpatch := prjObject.Get('currentarmpatch').JsonValue.Value;
        // currentarmpatch :='ARM/'+currentarmpatch;

        DecrAccessToken := prjObject.Get('Access_Token').JsonValue.Value;
        Access_Token := dbm.gf.DecryptFldValue(DecrAccessToken, 't');

      end;
      // if bUpdateConfig then
      // begin
      // UpdateConfig(projectname);
      // end;

      // if activeconnection <> '' then
      // begin
      // // AppWriteln('Currently your default connection is '+activeconnection);
      // // AppWriteln('For changing default con please metion connection name otherwise press enter');
      // // appreadln(activecon);
      // // if activecon = '' then
      // // activeconnection:=activeconnection
      // else
      // begin
      // JText := TFile.ReadAllText('appsetting.config');
      // JText := Trim(JSONText);
      // JText := stringreplace(JSONText, '\\', '\',
      // [rfReplaceAll, rfIgnoreCase]);
      // JText := stringreplace(JSONText, '\', '\\',
      // [rfReplaceAll, rfIgnoreCase]);
      // JObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
      // ReadConfig(activecon, );
      // end;
      // end;
      writelog('Readconfig function ends..');
    Except
      on E: Exception do
      begin
        //InstallErrMsg := E.Message;
        InstallErrMsg := E.ClassName + ' : ' + E.Message;
        ReadErrorList(E.Message);
        {$IFDEF CONSOLE_APP}
        Console_Write('Error: ' + E.Message, 12);
        AppWriteln;
        writelog('Error in Readconfig : ' + E.Message);
        appreadln;
        {$ELSE}
        raise;
        {$ENDIF}

      end;
    end;
  finally
    Freeandnil(dbm);
  end;
end;

function TConfig.UpdateConfig(prjname: string): boolean;
var
  AppJSONObject, JSONObject, prjJSONObject, newObject: TJSONObject;
  UserJsonFile, axapps: TextFile;
  EncrAccessToken: String;
  strlist1, strlist2, strlist3, strlist4: TStringList;
  JSONText, TotalJSONText: string;
  newCon: boolean;
  dbm: TDbManager;
  Pair: TJSONPair;
  FileHandle: THandle;
  FilePath: string;
  FileStream: TFileStream;
  XMLDoc1, XMLDoc2, XMLDoc3, XMLDoc4: IXMLDocument;
  Node1, Node2, Node3, Node4: IXMLNode;
  RootNode: IXMLNode;
  axappsFound: boolean;
  devaxappstext, runaxappstext: string;
  axappsUpdated: boolean;
  DB, DBCon, DBUser, DBPass: string;
begin
  // if  not Assigned(dbm) then
  // begin
  // freeandnil(dbm);
  writelog('UpdateConfig function started..');
  dbm := TDbManager.Create;
  // end;
  JSONObject := TJSONObject.Create();
  AppJSONObject := TJSONObject.Create();
  prjJSONObject := TJSONObject.Create();
  newObject := TJSONObject.Create();
  try
    writelog('Reading appsetting.config');
    JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
  Except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      AppWriteln(E.Message);
      appreadln;
      writelog('Error while reading appsetting.config : ' + E.Message);
    end;

  end;
  JSONText := Trim(JSONText);
  JSONText := StringReplace(JSONText, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
  JSONText := StringReplace(JSONText, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
  JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
  newCon := True;
  writelog('Checking if connection is already exist.');
  for Pair in AppJSONObject do
  begin
    if (Pair.JSONString.Value = prjname) then
    begin
      newCon := False;
      writelog(prjname + ' Connection already exist');
      writelog('Updating configuration for ' + prjname);
      prjJSONObject := AppJSONObject.Get(prjname).JsonValue as TJSONObject;
      AppJSONObject.removepair(prjname);
      prjJSONObject.Get('projectname').JsonValue :=
        TJSONString.Create(projectname);
      // prjJSONObject.Get('gitpluginurl').JsonValue :=
      // TJSONString.Create(GITPluginURL);
      // prjJSONObject.Get('gitpatchurl').JsonValue :=
      // TJSONString.Create(GITPatchURL);
      EncrAccessToken := dbm.gf.EncryptFldValue(Access_Token, 't');
      prjJSONObject.Get('Access_Token').JsonValue :=
        TJSONString.Create(EncrAccessToken);
      prjJSONObject.Get('runwebcodepath').JsonValue :=
        TJSONString.Create(runwebcodepath);
      prjJSONObject.Get('devwebcodepath').JsonValue :=
        TJSONString.Create(devwebcodepath);
      // prjJSONObject.Get('rmqclientpath').JsonValue :=
      // TJSONString.Create(rmqclientpath);
      prjJSONObject.Get('runscriptpath').JsonValue := // scriptpath
        TJSONString.Create(runscriptpath);
      prjJSONObject.Get('devscriptpath').JsonValue :=
        TJSONString.Create(devscriptpath);
      prjJSONObject.Get('agileconnectpath').JsonValue :=
        TJSONString.Create(agileconnectpath);
      prjJSONObject.Get('armapipath').JsonValue :=
        TJSONString.Create(armapipath);
      prjJSONObject.Get('armscriptpath').JsonValue :=
        TJSONString.Create(armscriptpath);
      prjJSONObject.Get('armservicepath').JsonValue := // rmqclient
        TJSONString.Create(armservicepath);
      prjJSONObject.Get('apparchitecture').JsonValue :=
        TJSONString.Create(apparchitecture);
      prjJSONObject.Get('currentversionname').JsonValue :=
        TJSONString.Create(currentversionname);
      prjJSONObject.Get('currentpatchname').JsonValue :=
        TJSONString.Create(currentpatchname);
      prjJSONObject.Get('iispluginapppath').JsonValue :=
        TJSONString.Create(iispluginapppath);
      // prjJSONObject.Get('currentdevpatch').JsonValue :=
      // TJSONString.Create(currentdevpatch);
      // prjJSONObject.Get('currentarmpatch').JsonValue :=
      // TJSONString.Create(currentarmpatch);
      // prjJSONObject.Get('runwebcodepath').JsonValue :=
      // TJSONString.Create(runwebcodepath);

      // AppJSONObject.Get('runscriptpath').JsonValue :=
      // TJSONString.Create(runscriptpath);

      // prjJSONObject.Get('runarmscriptpath').JsonValue :=
      // TJSONString.Create(runarmscriptpath);
      // prjJSONObject.Get('devarmscriptpath').JsonValue :=
      // TJSONString.Create(devarmscriptpath);
      AppJSONObject.addpair(prjname, prjJSONObject);
      writelog('Config JSON updated for ' + prjname + ' successfully');
    end
  end;
  // newCon:=True;
  if newCon = True then
  begin
    writelog(projectname + ' new connection found');
    newObject.addpair('projectname', TJSONString.Create(projectname));
    // newObject.addpair('gitpluginurl', TJSONString.Create(GITPluginURL));
    // newObject.addpair('gitpatchurl', TJSONString.Create(GITPatchURL));
    EncrAccessToken := dbm.gf.EncryptFldValue(Access_Token, 't');
    newObject.addpair('Access_Token', TJSONString.Create(EncrAccessToken));
    newObject.addpair('runwebcodepath', TJSONString.Create(runwebcodepath));
    // webcodepath
    newObject.addpair('devwebcodepath', TJSONString.Create(devwebcodepath));
    newObject.addpair('runscriptpath', TJSONString.Create(runscriptpath));
    // scriptpath
    newObject.addpair('devscriptpath', TJSONString.Create(devscriptpath));
    newObject.addpair('agileconnectpath', TJSONString.Create(agileconnectpath));
    newObject.addpair('armapipath', TJSONString.Create(armapipath));
    newObject.addpair('armscriptpath', TJSONString.Create(armscriptpath));
    newObject.addpair('armservicepath', TJSONString.Create(armservicepath));
    // rmqclientpath
    newObject.addpair('apparchitecture', TJSONString.Create(apparchitecture));
    newObject.addpair('iispluginapppath', TJSONString.Create(iispluginapppath));
    newObject.addpair('currentversionname', TJSONString.Create(currentversionname));
    newObject.addpair('currentpatchname', TJSONString.Create(currentpatchname));
    // newObject.addpair('currentdevpatch', TJSONString.Create(currentdevpatch));
    // newObject.addpair('currentarmpatch', TJSONString.Create(currentarmpatch));
    AppJSONObject.addpair(prjname, newObject);
    writelog('Added new Connection in Config JSON successfully..');
  end;
  // strlist1 := TStringList.Create;
  // strlist2 := TStringList.Create;
  // strlist3 := TStringList.Create;
  // strlist1.LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchRunscript }
  // runscriptpath + '\axapps.xml');
  // strlist2.LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
  // devscriptpath + '\axapps.xml');
  //
  // if FileExists(runscriptpath + '\axapps.xml') then
  // begin
  // with TStringList.Create do
  // begin
  // LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchRunscript }
  // runscriptpath + '\axapps.xml');
  // XMLDoc1 := LoadXMLData(text); //runscript mdla xml
  // destroy;
  // end;
  // Node1 := XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname); //runscr mdla projectname cha node
  // end;
  // if FileExists( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
  // devscriptpath + '\axapps.xml') then
  // begin
  // with TStringList.Create do
  // begin
  // LoadFromFile( { 'C:\Users\paroksh.AGILELABS\Desktop\PatchDevscript }
  // devscriptpath + '\axapps.xml');
  // XMLDoc2 := LoadXMLData(text);
  // destroy;
  // end;
  // Node2 := XMLDoc2.DocumentElement.ChildNodes.FindNode(projectname + 'axdef');   //devscr mdla axdef
  // end;
  // axappsFound := False;
  // if FileExists( { 'D:\Axpert_Project\installer_Axpert } getcurrentdir() +
  // '\axapps.xml') then
  // begin
  // axappsFound := True;
  // strlist3.LoadFromFile( { 'D:\Axpert_Project\installer_Axpert } getcurrentdir
  // () + '\axapps.xml');
  // end
  // else
  // begin
  // AssignFile(axapps, 'axapps.xml');
  // Rewrite(axapps);
  // CloseFile(axapps);
  // strlist3.LoadFromFile(getcurrentdir() + '\axapps.xml');
  // axappsFound := True;
  // end;
  // if axappsFound then
  // begin
  // with TStringList.Create do
  // begin
  // LoadFromFile(getcurrentdir() + '\axapps.xml');
  // XMLDoc3 := LoadXMLData(text);
  // destroy;
  // end;
  // Node3 := XMLDoc3.DocumentElement.ChildNodes.FindNode(projectname);//local projectname cha node
  // end;
  // if axappsFound then
  // begin
  // with TStringList.Create do
  // begin
  // LoadFromFile(getcurrentdir() + '\axapps.xml');
  // XMLDoc4 := LoadXMLData(text);
  // destroy;
  // end;
  // Node4 := XMLDoc4.DocumentElement.ChildNodes.FindNode(projectname + 'axdef');//local axdef cha node
  // end;
  // axappsUpdated := False;
  // if ((assigned(Node3)) or (assigned(Node4))) then
  // begin
  // axappsUpdated := True;
  // end
  // else if ((assigned(Node1)) and (assigned(Node2))) then
  // begin
  // axappsUpdated := True;
  // updateaxapps(Node1, Node2);
  // end
  // else
  // begin
  // AppWriteln('the given connection name details ' + projectname +
  // ' were not found in the corresponding script folder');
  // writelog(projectname+' config details not found in axapps.xml');
  // AppWriteln('please provide App schema and def schema details');
  // AppWriteln;
  // AppWriteln('For app schema : ');
  // AppWrite(' -DB : ');
  // appreadln(DB);
  // AppWrite(' -DB Connection : ');
  // appreadln(DBCon);
  // AppWrite('-DB User : ');
  // appreadln(DBUser);
  // AppWrite(' -DB Password : ');
  // appreadln(DBPass);
  // writelog('Credentials for app schema got successfully');
  // writelog('creating node with given details.');
  // createNode(DB, DBCon, DBUser, DBPass, 'run');
  // AppWriteln;
  // AppWriteln('For Dev schema : ');
  // AppWrite(' -DB : ');
  // appreadln(DB);
  // AppWrite(' -DB Connection : ');
  // appreadln(DBCon);
  // AppWrite(' -DB User');
  // appreadln(DBUser);
  // AppWrite(' -DB Password : ');
  // appreadln(DBPass);
  // writelog('Credentials for def schema got successfully');
  // writelog('creating node with given details.');
  // createNode(DB, DBCon, DBUser, DBPass, 'dev');
  /// /    axappsUpdated := True;
  // writelog('axapps.xml supdated successfully.');
  // end;
  if Connectionstatus then
  begin
    AssignFile(UserJsonFile, AppDir +'appsetting.config');
    Rewrite(UserJsonFile);
    TotalJSONText := StringReplace(JSONObject.ToString, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
    AppWriteln(UserJsonFile, TotalJSONText);
    CloseFile(UserJsonFile);
    writelog('Connection added successfully for ' + projectname);
    AppWriteln;
  end
  else
  begin
    AppWriteln('connection details not found from the given script folder');
    AppWriteln('Please add those connection in corrosponding script folder');
    writelog('connection details not found from the given script folder');
    halt;
  end;
  writelog('UpdateConfig function ends..');
end;

function TConfig.createNode(DB, DBCon, DBUser, DBPass, schema: string): string;
var
  RootNode, conNode: IXMLNode;
  XMLDoc1, XMLDoc2: IXMLDocument;
begin
  writelog('createNode function stated..');
  XMLDoc1 := TXMLDocument.Create(nil);
  XMLDoc1.Active := True;
  if LowerCase(schema) = 'run' then
    RootNode := XMLDoc1.AddChild(projectname)
  else
    RootNode := XMLDoc1.AddChild(projectname + 'axdef');
  conNode := RootNode.AddChild('type');
  conNode.text := 'db';
  conNode := RootNode.AddChild('db');
  conNode.text := DB;
  conNode := RootNode.AddChild('Version');
  conNode.text := '';
  conNode := RootNode.AddChild('driver');
  if LowerCase(DB) = 'mssql' then
    conNode.text := 'ado'
  else
    conNode.text := 'dbx';
  conNode := RootNode.AddChild('dbcon');
  conNode.text := DBCon;
  conNode := RootNode.AddChild('dbuser');
  conNode.text := DBUser;
  conNode := RootNode.AddChild('pwd');
  conNode.text := DBPass;
  conNode := RootNode.AddChild('dataurl');
  conNode.text := '';
  conNode := RootNode.AddChild('structureurl');
  conNode.text := '';
  if FileExists(AppDir + 'axapps.xml') then
  begin
    with TStringList.Create do
    begin
      LoadFromFile(AppDir + 'axapps.xml');
      XMLDoc2 := LoadXMLData(text);
      destroy;
    end;
    XMLDoc2.DocumentElement.ChildNodes.Add
      (XMLDoc1.DocumentElement.CloneNode(True));
    XMLDoc2.SaveToFile(AppDir + 'axapps.xml');
    writelog('Node created successfully.');
  end;
  // Result:=rootnode;
  writelog('createNode function ends..');
end;

function TConfig.IsConfigFound(): boolean; // 1
var
  ConfigExists: boolean;

  Enc, Dec: string;
begin
  try
    if FileExists(AppDir +'appsetting.config') then
    begin
      Result := True;
      // readactiveconnection();
    end
    else
    begin
      CreateConfig();
      Result := True;
      // if readactiveconnection()='False' then
      // begin
      // AppWriteln;
      // AppWriteln('You have not slected any connection as defalut connection.');
      // AppWriteln('choose any connection name to set it default.Use ''Config set <appname>'' to set default cnnection');
      // AppWriteln;
      /// /    for Pair in AppJSONObject do
      /// /    begin
      /// /      AppWriteln('Available Connections');
      /// /      AppWriteln('==================');
      /// /      AppWriteln('  -'+Pair.JSONString.Value);
      /// /    end;
      // //AppWriteln('new');
      /// /  /  AppWriteln;
      // //AppWriteln('Enter your response :');
      // AppWrite('AxInstaller>');
      // appreadln(command);
      // parsecommand(command);
      // end
      // else
      // Config.readactiveconnection();
      readactiveconnection();
      readReleasePasswordandGitUrl();
    end;
    // end;
    // UserInfo();

  finally
    Freeandnil(dbm);
  end;

end;

function TConfig.CreateConfig(): string;
var
  configFile: TextFile;
  JsonData: string;

begin
  writelog('CreateConfig function started..');
  writelog('File name : '+ AppDir+'appsetting.config');
  AssignFile(configFile, AppDir +'appsetting.config');
  Rewrite(configFile);
  // JsonData := CreateJson();
  // AppWriteln(configFile, 'sample');
  CloseFile(configFile);
  writelog('appsetting.config file created');
  writelog('CreateConfig function ends..');
end;

function TConfig.createconfigfile(jtext, FilePath: string): string;
var
  configFile: TextFile;
begin
  try
    writelog('createconfigfile function started..');
    AssignFile(configFile, FilePath);
    Rewrite(configFile);
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      AppWriteln(E.Message);
      appreadln; // Wait for user input (optional)
    end;
  end;
  AppWriteln(configFile, jtext);
  CloseFile(configFile);
  writelog(AppDir +'appsetting.config file created');
  writelog('createconfigfile function ends..')
end;

function TConfig.FillUserInfo(): string;
var
  response, FilePath, TotalJSONText: string;
  // connectionstatus: boolean;
  FileStream: TFileStream;
  dbc_conf: TDbConnect;
  JsonFile: TextFile;
begin
  try
    // bDBConDuring_Install := False;
    dbc_conf := nil;
    AppWriteln;
    writelog('FillUserInfo function started..');
    AppWriteln('Configuration Settings:');
    AppWriteln('=========================');
    AppWriteln;
    Console_Write('1.', 4);
    AppWrite('Project Name: ');
    appreadln(projectname);
    // dbm.gf.GetNThstring(projectname,1);
    MultiProjConnNames := projectname;
    if FileExists(AppDir +'appsetting.config') then
    begin
      FilePath := { getcurrentdir() } AppDir + 'appsetting.config';
      FileStream := TFileStream.Create(FilePath, fmOpenRead or
        fmShareDenyWrite);
      if FileStream.Size = 0 then
      begin
        // if FileSize(FileHandle)=0 then
        // begin
        // try
        // //CloseFile(JsonFile); // Close any previous file handle
        // AssignFile(JsonFile,FilePath);
        // Rewrite(JsonFile);
        // except
        // on E: Exception do
        // begin
        // AppWriteln(E.Message);
        // appreadln; // Wait for user input (optional)
        // end;
        // end;
        try
          writelog('Creating empty JSON');
          TotalJSONText := CreateJson(projectname);
          // FileStream.Free;
        finally
          if assigned(FileStream) then
            Freeandnil(FileStream);
        end;

        // if FileStream = nil then
        // AppWriteln('File is properly closed.');
        writelog('Adding empty json in appsetting.config file');
        createconfigfile(TotalJSONText, AppDir +'appsetting.config');

        // AppWriteln(JsonFile, TotalJSONText);
        // CloseFile(JsonFile);
        // end;
      end;
      if assigned(FileStream) then
        FileStream.Free;

    end;
    // projectarray

    // Console_Write('2.', 4);
    // if GITPluginURL = '' then
    // begin
    // // gitpluginurl:='https://github.com/Paroksh11/Axpert/tree/main/AxPlugins/';
    // GITPluginURL :=
    // 'https://api.github.com/repos/Paroksh11/Axpert/contents/AxpertReleases/';
    // // 'https://api.github.com/repos/Paroksh11/Axpert/contents/AxPlugins/';
    // end;
    //
    // AppWriteln('GIT Plugin URL: ' + GITPluginURL);
    // AppWriteln('Do you want to change the GIT Plugin URL ? [y/n]');
    // appreadln(response);
    // if lowercase(response) = 'y' then
    // begin
    // AppWriteln('Enter GIT Plugin URL:');
    // appreadln(GITPluginURL);
    // end;
    // Console_Write('2.', 4);
    // if GITPatchURL = '' then
    // begin
    // // gitpluginurl:='https://github.com/Paroksh11/Axpert/tree/main/AxPlugins/';
    // GITPatchURL :=
    // 'https://api.github.com/repos/Paroksh11/Axpert/contents/AxpertReleases/';
    // end;
    // AppWriteln('GIT Patch URL: ' + GITPatchURL);
    // AppWriteln('Do you want to change the GIT Patch URL ? [y/n]');
    // appreadln(response);
    // if lowercase(response) = 'y' then
    // begin
    // AppWriteln('Enter GIT Patch URL:');
    // appreadln(GITPatchURL);
    // end;
    // appreadln(gitpluginurl);
    // Console_write('3.', 4);
    // AppWrite('GIT Username: ');
    // appreadln(gitusername);
    // Console_write('4.', 4);
    // AppWrite('GIT Password: ');
    // gitpassword := EncryptString();
    // Console_write('3.', 4);
    // AppWrite('GIT Client Id: ');
    // appreadln(client_id);
    // Console_write('4.', 4);
    // AppWrite('GIT Client Secret Id: ');
    // appreadln(client_secret);
    (* Console_Write('2.', 4);
      AppWrite('Access_Token: ');
      Access_Token := EncryptString();
      Console_Write('3.', 4);
      currentversionname:=ReadInputs('Axpert current Version name');
      currentversionname:=ExtractNumbers(currentversionname);
      currentversionname:='Version '+trim(currentversionname);
      Console_Write('4.', 4);
      AppWrite('Axpert current Release name: ');
      appreadln(currentpatchname);

      //  AppWrite('Axpert Run Webcode Path: ');
      Console_Write('5.', 4);
      runwebcodepath:=ReadInputs('Axpert Run Webcode Path');
      runwebcodepath := stringreplace(runwebcodepath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('6.', 4);
      //  AppWrite('Axpert Dev code Path: ');
      //  appreadln(devwebcodepath);
      //ToDO : ignore the following prompt based on version no
      if Pos('11.', LowerCase(currentversionname)) > 0 then
      begin
      devwebcodepath := ReadInputs('Axpert Dev code Path (applies to 11.x only)', False);
      devwebcodepath := StringReplace(devwebcodepath, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
      end
      else
      begin
      devwebcodepath := '';
      Writelog('Dev webcode path skipped (not an 11.x version)');
      end;
      Console_Write('5.', 4);
      //  AppWrite('Axpert Run Script Path: ');
      runscriptpath:=ReadInputs('Axpert Run Script Path');
      runscriptpath := stringreplace(runscriptpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('6.', 4);
      //  AppWrite('Axpert Dev script Path: ');
      //ToDO : ignore the following prompt based on version no
      {devscriptpath:=ReadInputs('Axpert Dev script Path (applies from 11.0 to 11.3 only)',False);
      devscriptpath := stringreplace(devscriptpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);}
      if HasDefSchema then
      begin
      devscriptpath := ReadInputs('Axpert Dev script Path (applies from 11.0 to 11.3 only)', False);
      devscriptpath := StringReplace(devscriptpath, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
      end
      else
      begin
      devscriptpath := '';
      Writelog('Dev script path skipped (no defschema for this version)');
      end;
      Console_Write('7.', 4);
      //  AppWrite('Axpert agileconnect Path: ');
      agileconnectpath:=ReadInputs('Axpert agileconnect Path');
      agileconnectpath := stringreplace(agileconnectpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('8.', 4);
      //  AppWrite('Axpert ARM API Path: ');
      armapipath:=ReadInputs('Axpert ARM API Path');
      armapipath := stringreplace(armapipath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('9.', 4);
      //  AppWrite('Axpert ARM Script Path: ');
      armscriptpath:=ReadInputs('Axpert ARM Script Path');
      armscriptpath := stringreplace(armscriptpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('10.', 4);
      // AppWrite('Axpert runscript Path: ');
      // appreadln(runscriptpath);
      // runscriptpath := stringreplace(runscriptpath, '\', '\\',
      // [rfReplaceAll, rfIgnoreCase]);
      // Console_write('10.', 4);
      //  AppWrite('Axpert ARM service Path: ');
      armservicepath:=ReadInputs('Axpert ARM service Path');
      armservicepath := stringreplace(armservicepath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);
      Console_Write('11.', 4);
      //  AppWrite('Axpert apparchitecture : ');
      apparchitecture:=ReadInputs('Axpert apparchitecture (32bit/64bit)');
      Console_Write('12.', 4); *)
    // AppWrite('Axpert current Version name: ');
    // currentversionname:=ReadInputs('Axpert current Version name');
    // currentversionname:=ExtractNumbers(currentversionname);
    // currentversionname:='Version '+trim(currentversionname);
    // Console_Write('13.', 4);
    // AppWrite('Axpert current Release name: ');
    // appreadln(currentpatchname);
    // Console_write('14.', 4);
    // AppWrite('Axpert current DEV Patch: ');
    // appreadln(currentdevpatch);
    // Console_write('15.', 4);
    // AppWrite('Axpert current ARM Patch : ');
    // appreadln(currentarmpatch);
    // runarmscriptpath := stringreplace(runarmscriptpath, '\', '\\',
    // [rfReplaceAll, rfIgnoreCase]);
    // Console_write('12.', 4);
    // AppWrite('Axpert devarmscript Path: ');
    // appreadln(devarmscriptpath);
    // devarmscriptpath := stringreplace(devarmscriptpath, '\', '\\',
    // [rfReplaceAll, rfIgnoreCase]);
    // AppWriteln;
    // bUpdateConfig := True;

    // connectionstatus := isConnectionfound(projectname);
    // if connectionstatus = True then
    // begin

    // end;
    Console_Write('2.', 4);
    AppWrite('Access_Token: ');
    Access_Token := EncryptString();

    Console_Write('3.', 4);
    currentversionname := ReadInputs('Axpert current Version name');
    currentversionname := ExtractNumbers(currentversionname);
    currentversionname := 'Version ' + Trim(currentversionname);

    // Evaluate HasDefSchema based on version
    EvaluateDefSchemaFlag(currentversionname);

    Console_Write('4.', 4);
    AppWrite('Axpert current Release name: ');
    appreadln(currentpatchname);

    Console_Write('5.', 4);
    runwebcodepath := ReadInputs('Axpert Run Webcode Path');
    runwebcodepath := StringReplace(runwebcodepath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    if pos('10.', LowerCase(currentversionname)) > 0 then
      writeln('Hint: AxpertDevCode is mandatory during upgradation to 11X');

    Console_Write('6.', 4);
    devwebcodepath := ReadInputs('Axpert Dev code Path');//, False);
    devwebcodepath := StringReplace(devwebcodepath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    Console_write('7.', 4);
    runscriptpath := ReadInputs('Axpert Run Script Path');
    runscriptpath := StringReplace(runscriptpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    if HasDefSchema then
    begin
      Console_write('8.', 4);
      devscriptpath :=
        ReadInputs('Axpert Dev script Path (applies to 11.0–11.3 only)', False);
      devscriptpath := StringReplace(devscriptpath, '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
    end
    else
    begin
      devscriptpath := '';
      writelog('Dev script path skipped (DefSchema not applicable for this version)');
    end;

    Console_write('9.', 4);
    agileconnectpath := ReadInputs('Axpert agileconnect Path');
    agileconnectpath := StringReplace(agileconnectpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    Console_write('10.', 4);
    armapipath := ReadInputs('Axpert ARM API Path');
    armapipath := StringReplace(armapipath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    Console_write('11.', 4);
    armscriptpath := ReadInputs('Axpert ARM Script Path');
    armscriptpath := StringReplace(armscriptpath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    Console_Write('12.', 4);
    armservicepath := ReadInputs('Axpert ARM service Path');
    armservicepath := StringReplace(armservicepath, '\', '\\',
      [rfReplaceAll, rfIgnoreCase]);

    Console_Write('13.', 4);
    apparchitecture := ReadInputs('Axpert apparchitecture (32bit/64bit)');

    Console_Write('14.', 4);
    iispluginapppath := ReadInputs('IIS Plugin Application Path ', False);
    // Normalize backslash to forward slash for consistent parsing
    iispluginapppath := StringReplace(iispluginapppath, '\', '/', [rfReplaceAll]);
    if not assigned(dbc_conf) then
      dbc_conf := TDbConnect.Create;
    try
      bDBConDuring_Install := False;
      // Allow deletion from axapps if connection fails
      addingconToaxapps();
      dbc_conf.DatabaseConnection;
    finally
      bDBConDuring_Install := True;
    end;
    // FreeAndNil(dbc);
    // dbc.TestDBConection

    if Connectionstatus then
    begin
      UpdateConfig(projectname);
      AppWriteln;
      if configeditflag = False then
        Console_Write('Connection added successfuly', 10);
    end
    else
    begin
      Console_Write('Unable to create connection', 4);
      AppWriteln;
      writelog('Unable to create connection');
    end;
    writelog('FillUserInfo function ends..');
    AppWriteln;
	//The globally used variable is being overwritten while adding a new connection.
    //As a temporary workaround, calling ReadActiveConnection resolves the issue.
    //However, this should be handled more appropriately in the code to avoid relying on this workaround.

  finally
    // dbc.Free;
    // bDBConDuring_Install := True;
  end;
end;

function TConfig.UserInfo(): string;
var
  JsonFile: TextFile;
  WebPath, devPath, RMQPath: string;
begin
  AppWriteln;
  AppWriteln('Current Configuration:');
  AppWriteln('=========================');
  Console_Write('Project Name        : ', 12);
  Console_Write(projectname, 10);
  AppWriteln;
  // Console_Write('GIT Plugin URL      : ', 12);
  // Console_Write(GITPluginURL, 10);
  // AppWriteln;
  Console_Write('GIT Release URL      : ', 12);
  Console_Write(GitPatchURL, 10);
  AppWriteln;
  // Console_write('GIT username        : ', 12);
  // Console_write(gitusername, 10);
  // AppWriteln;
  // Console_write('GIT password        : ', 12);
  // Console_write('*******', 10);
  // AppWriteln;
  // Console_write('GIT Client ID        : ', 12);
  // Console_write(client_id, 10);
  // AppWriteln;
  // Console_write('GIT Client Secret ID        : ', 12);
  // Console_write(client_secret, 10);
  // AppWriteln;
  Console_Write('Git Access Token    : ', 12);
  Console_Write('************', 10);
  AppWriteln;
  runwebcodepath := StringReplace(runwebcodepath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert run webcode Path     : ', 12);
  Console_Write(runwebcodepath, 10);
  AppWriteln;
  devwebcodepath := StringReplace(devwebcodepath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert Dev Code Path     : ', 12);
  Console_Write(devwebcodepath, 10);
  AppWriteln;
  runscriptpath := StringReplace(runscriptpath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert Scripts Path : ', 12);
  Console_Write(runscriptpath, 10);
  AppWriteln;
  armservicepath := StringReplace(armservicepath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('ARM service Path     : ', 12);
  Console_Write(armservicepath, 10);
  AppWriteln;
  // runscriptpath := stringreplace(runscriptpath, '\\', '\',
  // [rfReplaceAll, rfIgnoreCase]);
  // Console_write('Axpert runscript Path : ', 12);
  // Console_write(runscriptpath, 10);
  // AppWriteln;
  devscriptpath := StringReplace(devscriptpath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert devscript Path : ', 12);
  Console_Write(devscriptpath, 10);
  AppWriteln;
  agileconnectpath := StringReplace(agileconnectpath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert agileconnectpath Path : ', 12);
  Console_Write(agileconnectpath, 10);
  AppWriteln;
  armapipath := StringReplace(armapipath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert ARM api path Path : ', 12);
  Console_Write(armapipath, 10);
  AppWriteln;
  armscriptpath := StringReplace(armscriptpath, '\\', '\',
    [rfReplaceAll, rfIgnoreCase]);
  Console_Write('Axpert armscriptpath Path : ', 12);
  Console_Write(armscriptpath, 10);
  AppWriteln;
  // apparchitecture := stringreplace(armscriptpath, '\\', '\',
  // [rfReplaceAll, rfIgnoreCase];
  Console_Write('Axpert apparchitecture : ', 12);
  Console_Write(apparchitecture, 10);
  AppWriteln;
  Console_Write('Axpert current Version name : ', 12);
  Console_Write(currentversionname, 10);
  AppWriteln;
  Console_Write('Axpert current Release name : ', 12);
  Console_Write(currentpatchname, 10);
  AppWriteln;
  // Console_write('Axpert current Dev Patch : ', 12);
  // Console_write(currentdevpatch, 10);
  // AppWriteln;
  // Console_write('Axpert current ARM Patch : ', 12);
  // Console_write(currentarmpatch, 10);
  // AppWriteln;

  AppWriteln;

  begin
    AppWriteln('Do you want to continue with these settings?');
    AppWriteln;
    AppWriteln('Press ''M'' to Moodify');
    appreadln(userresp);
    AppWriteln;
    userresp := LowerCase(userresp);
    if userresp = 'm' then
    begin
      FillUserInfo();
      AppWriteln;
      AppWriteln('Configurations applied successfully...');
      AppWriteln;
      // AppWriteln('Configuration Settings:');
      // AppWriteln('------------------------');
      // AppWriteln('1. Project Name: ');
      // appreadln(projectname);
      // AppWriteln('2. GIT Username : ');
      // appreadln(gitusername);
      // AppWriteln('3. GIT Password: ');
      // appreadln(gitpassword);
      // AppWriteln('4. Axpert Web Path: ');
      // appreadln(runwebcodepath);
      // runwebcodepath:=StringReplace(runwebcodepath,'\','\\',[rfReplaceAll, rfIgnoreCase]);
      // AppWriteln('5. Axpert Script Path: ');
      // appreadln(runscriptpath);
      // AppWriteln;
      // AppWriteln('Your new values are submitted successfully..');
    end;
    if userresp <> 'm' then
    begin
      Exit;
    end;
    // if (userresp <> 'y') and (userresp <> 'n') then
    // begin
    // repeat
    // begin
    // AppWriteln('Give your response in y or n only');
    // AppWrite('Press [y] to continue [n] to modify..? ');
    // Console_write('[y/n]', 12);
    // AppWriteln;
    // appreadln(userresp);
    // if userresp = 'n' then
    // FillUserInfo();
    // end;
    // until (userresp = 'y') or (userresp = 'n');
    //
    // end;
  end;
end;

function TConfig.CreateJson(prjname: string): string;
var
  JSONText, EncryptedreleasePass: string;
  JSONObject: TJSONObject;
  AppJSONObject, PrjJSONObjet: TJSONObject;

  Pair: TJSONPair;
begin
  writelog('CreateJson function started..');
  Result := '';
  JSONObject := TJSONObject.Create;
  JSONObject.addpair('activeapp', TJSONString.Create(''));
  if not assigned(dbm) then
    dbm := TDbManager.Create;
  EncryptedreleasePass := dbm.gf.EncryptFldValue('agile', 't');
  JSONObject.addpair('adminpwd', TJSONString.Create(EncryptedreleasePass));
  // JSONObject.addpair('gitpatchurl', TJSONString.Create('https://api.github.com/repos/Paroksh11/Axpert/contents/AxpertReleases/'));
  JSONObject.addpair('gitpatchurl',
    TJSONString.Create
    ('https://api.github.com/repos/Agileaxpert/AxpertReleases/contents/'));

  try
    try
      AppJSONObject := TJSONObject.Create;
      PrjJSONObjet := TJSONObject.Create;
      PrjJSONObjet.addpair('projectname', TJSONString.Create(''));
      // PrjJSONObjet.addpair('gitpluginurl', TJSONString.Create(''));

      // AppJSONObject.AddPair('gitusername', TJSONString.Create(''));
      // AppJSONObject.AddPair('gitpassword', TJSONString.Create(''));
      // AppJSONObject.AddPair('client_id', TJSONString.Create(''));
      // AppJSONObject.AddPair('client_secret', TJSONString.Create(''));
      PrjJSONObjet.addpair('Access_Token', TJSONString.Create(''));
      PrjJSONObjet.addpair('runwebcodepath', TJSONString.Create(''));
      // webcodepath
      PrjJSONObjet.addpair('devwebcodepath', TJSONString.Create(''));
      PrjJSONObjet.addpair('runscriptpath', TJSONString.Create(''));
      PrjJSONObjet.addpair('devscriptpath', TJSONString.Create(''));
      PrjJSONObjet.addpair('agileconnectpath', TJSONString.Create(''));
      PrjJSONObjet.addpair('armapipath', TJSONString.Create(''));
      PrjJSONObjet.addpair('armscriptpath', TJSONString.Create(''));
      PrjJSONObjet.addpair('armservicepath', TJSONString.Create(''));
      // rmqclientpath
      // AppJSONObject.AddPair('runwebcodepath', TJSONString.Create(''));
      PrjJSONObjet.addpair('apparchitecture', TJSONString.Create(''));
      PrjJSONObjet.addpair('iispluginapppath', TJSONString.Create(''));
      PrjJSONObjet.addpair('currentpatchname', TJSONString.Create(''));
      PrjJSONObjet.addpair('currentversionname', TJSONString.Create(''));
      // PrjJSONObjet.addpair('currentdevpatch', TJSONString.Create(''));
      // PrjJSONObjet.addpair('currentarmpatch', TJSONString.Create(''));
      // AppJSONObject.AddPair('runscriptpath', TJSONString.Create(''));

      // AppJSONObject.AddPair('runarmscriptpath', TJSONString.Create(''));
      // AppJSONObject.AddPair('devarmscriptpath', TJSONString.Create(''));
      AppJSONObject.addpair(prjname, PrjJSONObjet);
      JSONObject.addpair('appsettings', AppJSONObject);
      Result := JSONObject.ToString;
    finally
      Freeandnil(AppJSONObject);
      writelog('Empty json created');
      writelog('CreateJson function ends..');
      // Freeandnil(JSONObject);
    end;

  Except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_Write('Error: ' + E.Message, 12);
      AppWriteln;
      writelog('Error while creating empty json in createjson method.');
      writelog(E.Message);
      appreadln;
    end;
  end;
end;

function TConfig.ExtractNumbers(str: string): string;
var
  I: integer;
  CurrentNumber: string;
begin
  CurrentNumber := '';
  for I := 1 to length(str) do
  begin
    if CharInSet(str[I], ['0' .. '9', '.']) then
    begin
      CurrentNumber := CurrentNumber + str[I];
    end;
  end;
  Result := CurrentNumber;
end;

function TConfig.EncryptString(): string;
var
  password: string;
  key: char;
begin
  try
    password := '';
    repeat
      key := ReadKey;
      if key <> #13 then
      begin
        if key = #8 then
        begin
          if length(password) > 0 then
          begin
            Delete(password, length(password), 1); // Delete the last character
            AppWrite(#8, ' ', #8);
            // Move cursor back, write space, move cursor back again
          end;
        end
        else
        begin
          password := password + key;
          AppWrite('*');
        end;
      end;
    until key = #13;

    AppWriteln; // Move to the next line after the loop
    Result := password;
  except
    on E: Exception do
    begin
      AppWriteln(E.ClassName, ': ', E.Message);
      ReadErrorList(E.Message);
    end;
  end;
end;



// function TConfig.EncryptString(): string;
// var
// password: string;
// key: String;
// begin
// try
// password := '';
// // AppWriteln('Enter password: ');
// repeat
// key := ReadKey;
// if key <> #13 then
// begin
// if key = #8 then
// begin
// if length(password) > 0 then
// begin
// Delete(password, length(password) - 1, 1);
// AppWrite(#8, ' ', #8);
// end;
// end
// else
// begin
// password := password + key;
// AppWrite('*');
// end;
//
// end;
//
// until key = #13;
//
// AppWriteln;
// Result := password;
// except
// on E: Exception do
// AppWriteln(E.ClassName, ': ', E.Message);
// end;
// end;

function TConfig.ReadKey: char;
var
  InputRec: TInputRecord;
  NumRead: DWORD;
begin
  repeat
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), InputRec, 1, NumRead);
    if (InputRec.EventType = KEY_EVENT) and InputRec.Event.KeyEvent.bKeyDown
    then
    begin
      if InputRec.Event.KeyEvent.UnicodeChar <> #0 then
      begin
        Result := InputRec.Event.KeyEvent.UnicodeChar;
        Exit;
      end
      else if InputRec.Event.KeyEvent.wVirtualKeyCode = VK_BACK then
      begin
        Result := #8; // Return backspace character
        Exit;
      end;
    end;
  until False;
end;


// function TConfig.ReadKey: string;
// var
// InputRec: TInputRecord;
// NumRead: DWORD;
// Buffer: string;
// Key: Char;
// begin
// Buffer := '';
// repeat
// ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), InputRec, 1, NumRead);
// if (InputRec.EventType = KEY_EVENT) and InputRec.Event.KeyEvent.bKeyDown then
// begin
// Key := Char(InputRec.Event.KeyEvent.AsciiChar);
// if Key <> #0 then // Ignore control keys
// begin
// if Key = #13 then // Enter key
// Break
// else if Key = #8 then // Backspace
// begin
// if Length(Buffer) > 0 then
// begin
// Delete(Buffer, Length(Buffer), 1);
// AppWrite(#8, ' ', #8);
// end;
// end
// else
// begin
// Buffer := Buffer + Key;
// AppWrite('*'); // Print asterisk for each character added to the buffer
// end;
// end;
// end;
// until False;
// AppWriteln; // Move to a new line after input
// Result := Buffer;
// end;

function TConfig.isConnectionfound(prjctname: string): boolean;
var
  JSONText: string;
  JSONObject, AppJSONObject: TJSONObject;
  PrjValue: string;
  Pair: TJSONPair;
begin
  JSONObject := TJSONObject.Create;
  AppJSONObject := TJSONObject.Create;
  if FileExists(AppDir +'appsetting.config') then
  begin
    try
      begin
        JSONText := TFile.ReadAllText(AppDir +'appsetting.config');
        JSONText := Trim(JSONText);
        JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
        AppJSONObject := JSONObject.Get('appsettings').JsonValue as TJSONObject;
        // AppJSONObject.Get('projectname').JsonValue := TJSONString.Create(projectname);
        // PrjValue := AppJSONObject.Get('projectname').JsonValue.Value;
        for Pair in AppJSONObject do
        begin
          if (Pair.JSONString.Value = prjctname) then
            Result := True
          else
            Result := False;
        end;
      end
    except
      on E: Exception do
      begin
        ReadErrorList(E.Message);
        AppWriteln(E.Message);
      end;

    end;
    appreadln;
  end;

end;

end.
