unit uDbConnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Data.DB, DBClient, XmlDoc, XMLIntf, uXDS,
  uinstallation,
  uDBManager, uAxprovider, {uDWBPublish,} uAxLog;

type
  TDbConnect = class
  private
   // x: TXDS;
    inst: Tinstallation;

    function ReadAxprops(): String;
    procedure DestroyDBobj;
  public
    constructor Create;
    destructor Destroy; override;
    function TestDBConection(): string;
    function DatabaseConnection(): string;
    function ConnecttoDB: Boolean;
    function installOperation(): string;
    function removingconfromaxapps():string;
    function init(): string;

  end;

implementation

uses uUtils;

constructor TDbConnect.create;
begin
  inherited Create;
  init;
end;

destructor TDbConnect.Destroy;
begin
   DestroyDBobj;
end;

function TDbConnect.removingconfromaxapps():string;
var
  Node1, Node2,ParentNode1,ParentNode2 :IXMLNode;
  XMLDoc1, XMLDoc2:IXMLDocument;
begin
if FileExists({getcurrentdir()} AppDir + 'axapps.xml') then
  begin
   with TStringList.Create do
    begin
      LoadFromFile({getcurrentdir()} AppDir + 'axapps.xml');
      XMLDoc1 := LoadXMLData(text);
      destroy;
    end;
    Node1 := XMLDoc1.DocumentElement.ChildNodes.FindNode(projectname);
  end;
    if Assigned(Node1) then
  begin
    ParentNode1 := Node1.ParentNode;
    if Assigned(ParentNode1) then
      ParentNode1.ChildNodes.Remove(Node1);
  end;
      XMLDoc1.SaveToFile({GetCurrentDir} AppDir + 'axapps.xml');
  if FileExists({getcurrentdir()} AppDir + 'axapps.xml') then
  begin
  with TStringList.Create do
    begin
      LoadFromFile({getcurrentdir()} AppDir + 'axapps.xml');
      XMLDoc2 := LoadXMLData(text);
      destroy;
    end;
    Node2 := XMLDoc2.DocumentElement.ChildNodes.FindNode(projectname + 'axdef');
  end;


//       (Node1.ParentNode as IXMLNodeAccess).RemoveChild(Node1);


 if Assigned(Node2) then
 begin
     ParentNode2 := Node2.ParentNode;
    if Assigned(ParentNode2) then
      ParentNode2.ChildNodes.Remove(Node2);
 end;
//      Node1.ParentNode.RemoveChild(Node2);

    XMLDoc2.SaveToFile({GetCurrentDir} AppDir + 'axapps.xml');

end;



function TDbConnect.init(): string;
begin
//  if Assigned(x) then
//   x := dbm.getxds(nil);
end;

function TDbConnect.DatabaseConnection(): string;

begin
  writelog('DatabaseConnection function started..');
  TestDBConection();
  writelog('DatabaseConnection function ends..');
  // Readln;
end;

function TDbConnect.TestDBConection(): string;
var
  //cds: TDWBPublish;
  Errstr: String;
begin
  // try
  writelog('TestDBConection function started..');
  connectionstatus := ConnecttoDB;
  // Except on
  // E:Exception do
  // begin
  // Errstr:=E.Message;
  // end;
  // end;

  if connectionstatus then
    writelog('Database is connected successfully..');
  // if Errstr<>'' then
  // begin
  // writeln('Error while connecting to db : '+Errstr);
  // writelog('Invalid connection');
  // writelog('Error while connecting to db : '+Errstr);
  // end;

  databasetype := dbm.connection.DbType;
  writelog('Current application DataBase Type : ' + databasetype);
  writelog('TestDBConection function ends..');
end;

function TDbConnect.installOperation(): string;
begin
  try
    if connectionstatus = True then
    begin
      // cds := TDWBPublish.Create(Axprovider);

      // cds.ReadCDSFileandPushtoDB('C:\Users\paroksh.AGILELABS\Desktop\CDSFile\fastr1_20240412130704000100000.cds');

      inst := Tinstallation.Create;
      // Writeln('Connected to db.');
      if patchorPlugin = 'Plugin' then
      begin
        inst.InstallAxpertStructures();
        //inst.InstallAxpertStructureFiles(); //used patch installation functionality
        inst.ExecuteDBScripts();
        //This can be enabled when required
       // inst.InstallRMQClient();
        //Plugin Scripts functionality need to be optimized
        inst.InstallPluginScripts();
        // inst.IsPublicInfoFound();//pluginUpdate();

        // Writeln(selectedPlugin+' installation completed.');
        writeln('');
        Console_write('Plugin Installation Completed Successfully!', 3);
        writeln('');
        writeln('');
      end;
      // if patchorPlugin='Patch' then
      // begin
      // //inst.InstallAxpertStructures();
      //
      // inst.ExecuteSQLFile();
      // // inst.InstallRMQClient();
      // // inst.IsPublicInfoFound();//pluginUpdate();
      //
      // //  Writeln(selectedPlugin+' installation completed.');
      //
      // Console_write('3. Patch Installation Completed Successfully!',3);
      // writeln('');
      // writeln('');
      // end;
      // inst.CompletionStatus();
      // readln;
    end;
  finally
    freeandnil(inst);
  end;
end;

function TDbConnect.ConnecttoDB: Boolean;
var
  cnode: IXMLNode;
  Errorstr, ConDbtype, MsDbverno, ConDriver, ConHost, ConDbusernm,
    ConPwd: String;
  ConXML: IXMLDocument;
//  conf:TConfig;
begin
  axprovider:=nil;
  dbm:=nil;
  writelog('ConnectToDb Function started..');
  result := false;
  if not Assigned(dbm) then
  begin
    writelog('Creating TDBManager instance...');
    dbm := TDBManager.Create;
    writelog('TDBManager instance created');
  end;

  try
    ReadAxprops;
    writelog('After ReadAxprops. bConnectTempDB=' + BoolToStr(bConnectTempDB, True) + ', tempDBConnectionName=' + tempDBConnectionName + ', projectname=' + projectname);
    if (bConnectTempDB) and (tempDBConnectionName <> '') then
      ConDbusernm := Trim(tempDBConnectionName)
    else
      ConDbusernm := lowercase(Trim(projectname));
    writelog('DB ConnectionName : ' + ConDbusernm);
    dbm.gf.dbmflag := '';
    dbm.gf.startpath:=AppDir {getcurrentdir()};

    dbm.gf.connectionname := ConDbusernm;
    dbm.gf.AppName := ConDbusernm;
    writelog('GF.connectionname=' + dbm.gf.connectionname + ', GF.AppName=' + dbm.gf.AppName);
    writelog('AppDir Path= ' +dbm.gf.startpath);
    dbm.ConnectToDatabase(ConDbusernm);
    writelog('dbm.ConnectToDatabase completed for : ' + ConDbusernm);
    result := True;
    // writeln('Connected');
    if not Assigned(axprovider) then
//      freeandnil(axprovider);
    begin
      writelog('Creating TAxProvider instance...');
      axprovider := TAxProvider.Create(dbm);
      writelog('TAxProvider instance created successfully');
    end;
    axprovider.dbm.gf.IsService := True;
    writelog('AxProvider service mode enabled');
//    if Assigned(x) then
//    begin
//      if x.Active then
//        x.close;
//      freeandnil(x);
//    end;
//    x := dbm.getxds(nil);
    Errorstr := '';

  Except
    on E: Exception do
    begin
      Errorstr := E.Message;
//      writeln(Errorstr);
      ReadErrorList(Errorstr);

    end;
  end;
  if Errorstr <> '' then
  begin
    result := false;
    dbm.gf.DoDebug.Log(dbm.gf.Axp_logstr + 'uAxpmanger\ConnecttoDB :' +
      Errorstr);
    writeln;
    connectionstatus:=False;
    console_write('Connection Error.',4);
    writeln;
    console_write('Unable to connect to the project due to incorrect connection settings or network issues. Check your settings and network connection.',4);
    writeln;
    writeln;
    Console_write('Connection Name : ', 4);
    writeln(ConDbusernm);
    writeln;
    Console_write('Error while connecting to database : ',4);
    writeln(Errorstr);
    writeln;
    writelog('Connection Error.');
    writelog('The connection to the project could not be established. This might be due to incorrect connection settings or network issues. Please ensure that your connection details are correct and that you have a stable network connection');
    writelog('Error while connecting to database : ' + Errorstr);
    ReadErrorList(Errorstr);
    //during install if db connection issue then do not delete entry from axapps
    //but when making first connection during adding new conneciton any error then remove axapps
    if Not bDBConDuring_Install then
      removingconfromaxapps();
//    freeandnil(conf);
//    DestroyDBobj; // *******
    // raise Exception.Create(Errorstr);
    Errorstr := '';
  end
  else
  begin
    Writelog('Connection successful for : ' + ConDbusernm);
  end;
  writelog('ConnectToDb Function ends..');
end;

function TDbConnect.ReadAxprops(): String;
var
  pt: AnsiString;
  axml: IXMLDocument;
begin
  writelog('ReadAxprops function started');
  if not FileExists('Axprops.xml') then
  begin
    writelog('Axprops.xml not found. Creating default file.');
    axml := LoadXMLData
      ('<Axprops getfrom="" setto=""><lastlogin>mainikya</lastlogin><oradatestring>dd/mm/yyyy hh24:mi:ss</oradatestring><crlocation></crlocation><lastusername>profit</lastusername><login>local</login><ipaddress>192.168.1.65</ipaddress></Axprops>');
    axml.SaveToFile('Axprops.xml');
    writelog('Default Axprops.xml created successfully');
  end;
  with TStringList.Create do
  begin
    pt := ExtractFilepath(Application.ExeName);
    writelog('Loading from path: ' + pt + 'Axprops.xml');
    LoadFromFile(pt + 'Axprops.xml');
    if Text = '' then
    begin
      writelog('File empty. Using fallback XML.');
      dbm.gf.Axprops := LoadXMLData('<root/>');
    end
    else
    begin
      dbm.gf.Axprops := LoadXMLData(Text);
      writelog('XML parsed successfully');
    end;

    free;
  end;
  dbm.gf.localprops := dbm.gf.Axprops.DocumentElement;
  writelog('Root node assigned');
  if dbm.gf.localprops.HasAttribute('getfrom') then
    dbm.gf.structGetFrom := VartoStr(dbm.gf.localprops.Attributes['getfrom']);
  if dbm.gf.localprops.HasAttribute('setto') then
    dbm.gf.structSetTo := VartoStr(dbm.gf.localprops.Attributes['setto']);
  writelog('ReadAxprops function compeleted');
end;

procedure TDbConnect.DestroyDBobj;
begin
//  if Assigned(x) then
//  begin
    // x := dbm.getxds(nil);
//    if x.Active then
//      x.close;
//    if Assigned(dbm) and Assigned(dbm.Connection) then
//      freeandnil(x);
//  end;
  if Assigned(axprovider) then
    freeandnil(axprovider);
  if Assigned(dbm) then
  begin
    dbm.Destroy;
    dbm := nil;
  end;
end;

end.
