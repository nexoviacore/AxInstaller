unit AXMLibrary;
{copied from 10.1/Asb}
interface

uses Classes, SysUtils, Variants, DateUtils, System.IOUtils, DATA.DBXJSON,
      AXMConnection,INIFiles, Windows, XMLDoc, XMLIntf;

Var
  LogFlag : Boolean;
  Servicename, currentdir : string;

Const
  LOGINME_METHOD = 'loginsso';

Const
  XAXPAPP = 'axpapp';
  XUSERNAME = 'username';
  XPASSWORD = 'password';
  XSEED = 'seed';
  XSESSIONID = 's';
  XSESSIONAPPKEY = 'appsessionkey';

  procedure WriteLog(Msg : string);
  Function FindAndReplace(S:String;FindWhat:String;ReplaceWith: String):String;
  Function FormatString(Input : String):String;
  function GetJsonArrayForGetChoice(JObj: TJSONObject): TJSONArray;
  function GetJsonObject(Data: String): TJsonObject;
  function CallSevice(WebMethod: String; Parameter: TStringStream): String;
  function FileCopy(SourceFile, TargetFile : String) : Boolean;
  function GetFileSize(FileName : string) : Int64;
  Function GetJsonValue(JsonInput: TJSONObject; Class1, Class2, Class3, Class4,Class5: String): String;  overload;
  Function GetJsonValue(JsonInput: TJSONObject; PairName : string): String; overload;
  function SortJsonArrayByPairName(jArrObj : TJSONArray; PairName : string):TJsonArray;
  function CreateErrNode(errmsg : String) : String;
  function ConvertToXMLDoc(JSONObj : TJSONObject) : IXMLDocument;
  procedure WriteInToLog(msg: string);

implementation
uses
uAxLog;

function GetFileSize(FileName : string) : Int64;
var
  oFile : file of Byte;
begin
  Result := -1;
  AssignFile(oFile, FileName);
  try
    Reset(oFile);
    Result := FileSize(oFile);
  finally
    CloseFile(oFile);
  end;
end;

procedure WriteLog(Msg : string);
var
  f: TextFile;
  ASBName, FileName : String;
begin
  if not LogFlag then
    exit;
  FileName := FormatDateTime('yyyymmdd', Now);
  ASBName  := GetModuleName(HInstance);
  FileName := ExtractFilePath(ASBName)+'MobileLog\AxpertMobile\'+FileName;
  //ASBName  := ExtractFileName(ASBName);
  ASBName  := System.IOUtils.TPath.GetFileNameWithoutExtension(ASBName);
  FileName := FileName + '_'+ ASBName +'_Log.txt';
  Try
    if not DirectoryExists(ExtractFilePath(FileName)) then
       ForceDirectories(ExtractFilePath(FileName));
    AssignFile(f, FileName);
    if FileExists(FileName) then Append(f) else ReWrite(f);
    if Msg = '' then
      Msg := #13+'System DateTime: '+FormatDateTime('dd/mm/yyyy hh:mm:ss:zzz AM/PM', Now);
    Writeln(f, Msg);
    CloseFile(f);
  Except

  End;
end;

Function FindAndReplace(S:String;FindWhat:String;ReplaceWith: String):String;
var p:Integer;
begin
   Result:=s;
   p:=Pos(FindWhat,S);
   if p=0 then exit;
   Result:='';
   while p>0 do
   begin
      Result:=Result + copy(s,1,p-1) + ReplaceWith;
      Delete(s,1,p+length(FindWhat)-1);
      p:=Pos(FindWhat,S);
   end;
   Result := Result + s;
end;

Function FormatString(Input : String):String;
begin
  Input := FindAndReplace(Input, '\', '\\');
  Input := FindAndReplace(Input, '"', '\"');
  Result := Input;
end;

function GetJsonArrayForGetChoice(JObj: TJSONObject): TJSONArray;
var
  Jsonobj : TJSONObject;
  Jarray : TJSONArray;
  Jvalue : TJSONValue;
  Jpair : TJSONPair;
  StringValue : String;
begin
  try
  Result := nil;
  if Jobj.Null then
   Exit;

 jpair := JObj.Get(0);
 Jarray := jpair.JsonValue as TJSONArray;
 JsonObj := JArray.Get(0) as TJSONObject;
 jpair := JsonObj.Get(0);
 if (lowercase(jpair.JsonString.Value) = 'error')  then
 begin
   //ErrorHandler.DisplayIOError(jpair.JsonValue.Value);
   Exit;
 end;
 JsonObj := jpair.JsonValue as TJSONObject;
 jpair := JsonObj.Get(0);
 if Jpair.JsonValue is TJSONArray then
 begin
   Jarray := jpair.JsonValue as TJSONArray;
   Result := Jarray;
 end
 else
 begin
   Result := nil;
 end;
  finally
    //if Result = nil then
      //UpdateErrorLog or showmessage
  end;
end;

function GetJsonObject(Data: String): TJsonObject;
var
  JSonValue : TJsonValue;
  JSonObject : TJSONObject;
  JPair : TJSONPair;
  JArray : TJSONArray;
begin
  JSonValue := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Data),0);
  JSonObject := JSonValue as TJSONObject;
  JPair := JsonObject.Get(0);
  if JPair.JsonValue is TJSONArray then
  begin
    JArray := JPair.JsonValue as TJSONArray;
    JSonObject := JArray.Get(0) as TJSONObject;
  end;
  Result := JSonObject;
end;

function CallSevice(WebMethod: String; Parameter: TStringStream): String;
var
  URL : String;
  RawData : string;
  Connection : TAXMConnection;
  IniFile : TIniFile;
begin
  URL := '';
  Connection := TAXMConnection.Create();
  IniFile := TIniFile.Create(GetCurrentDir+'\url.ini');
  if WebMethod = LOGINME_METHOD then
    URL := IniFile.ReadString('global','login','');
  if Copy(URL, Length(Trim(URL)),1) = '/' then
    URL := Copy(URL, 1, Length(Trim(URL))-1);
  //'http://sso.rajasthan.gov.in:8888/SSOREST/SSOAuthenticationMobileJSON/CMISNEW/CMISNEW.TEST/Test@1234';
  if URL <> '' then
  begin
    //RawData := Connection.Get(URL, Parameter);
    URL := URL + Parameter.DataString;
    Try
      //Connection.Get(URL, Parameter);
      RawData := Connection.Get(URL);
    Except
      On E:Exception do
      begin
        Result := E.Message;
        Exit;
      end;
    End;
    //RawData := Parameter.DataString;
  end;
  Connection.Disconnect;
  Result := RawData;
end;

function FileCopy(SourceFile, TargetFile : String) : Boolean;
begin
  Result := CopyFile(PChar(SourceFile), PChar(TargetFile), false);;
end;

Function GetJsonValue(JsonInput: TJSONObject; Class1, Class2, Class3, Class4,Class5: String): String;
Var
  JsonObj1, JsonObj2, JsonObj3, JsonObj4, JsonObj5 : TJSONObject;
begin
  Result := '';
  Try
    JsonObj1 := JsonInput;
    if Class1 <> '' then
    begin
      if JsonObj1.Get(Class1) = nil then exit;
      if JsonObj1.Get(Class1).JsonValue is TJSONObject then
        JsonObj2 := JsonObj1.Get(Class1).JsonValue as TJSONObject;
    end
    else
      if Result = '' then begin Result := JsonInput.Value; exit; end;

    if Class2 <> '' then
    begin
      if JsonObj2.Get(Class2) = nil then exit;
      if JsonObj2.Get(Class2).JsonValue is TJSONObject then
        JsonObj3 := JsonObj2.Get(Class2).JsonValue as TJSONObject
      else if (JsonObj2.Get(Class2).JsonValue is TJSONArray) and (Class3 = '') then
        Result := JsonObj1.Get(Class1).ToString;
    end
    else
      if Result = '' then begin Result := JsonObj1.Get(Class1).JsonValue.Value; exit; end;

    if Class3 <> '' then
    begin
      if JsonObj3.Get(Class3) = nil then exit;
      if JsonObj3.Get(Class3).JsonValue is TJSONObject then
        JsonObj4 := JsonObj3.Get(Class3).JsonValue as TJSONObject;
    end
    else
      if Result = '' then begin Result := JsonObj2.Get(Class2).JsonValue.Value; exit; end;

    if Class4 <> '' then
    begin
      if JsonObj4.Get(Class4) = nil then exit;
      if JsonObj4.Get(Class4).JsonValue is TJSONObject then
        JsonObj5 := JsonObj4.Get(Class4).JsonValue as TJSONObject;
    end
    else
      if Result = '' then begin Result := JsonObj3.Get(Class3).JsonValue.Value; exit; end;

    if Class5 <> '' then
    begin
      if JsonObj5.Get(Class5) = nil then exit;
      if JsonObj5.Get(Class5).JsonValue is TJSONObject then
        Result := JsonObj5.Get(Class5).JsonValue.Value;
    end
    else
      if Result = '' then begin Result := JsonObj4.Get(Class4).JsonValue.Value; exit; end;
  Except
    Result := '';
  End;
end;

function CreateErrNode(errmsg : String) : String;
begin
  errmsg := FindAndReplace(errmsg, '\', '\\');
  errmsg := FindAndReplace(errmsg, '"', '\"');
  errmsg := FindAndReplace(errmsg, '<error>', '');
  errmsg := FindAndReplace(errmsg, '</error>', '');
  //result := '{"error":{"msg":"' + errmsg +'"}}';
  Result := '{"error":{"status":"Failed","msg":"'+errmsg+'"}}';
end;

function ConvertToXMLDoc(JSONObj : TJSONObject) : IXMLDocument;
var
  JsonMain, JsonObj1, JsonObj2 : TJSONObject;
  XMLDoc, tempxml : IXMLDocument;
  an, an1 : Array of ixmlnode;
  tmpnode : IXMLNode;
  iCnt, ichild, i, j : Integer;
  ConnectionName : string;
begin
  Try
    ConnectionName := '';
    JsonMain := JSONObj;
    JsonObj1 := JsonMain.Get(0).JsonValue as TJSONObject;
    xmldoc := LoadXMLData('<root></root>');
    SetLength(an, JsonObj1.Size+1);
    SetLength(an1, 20);
    iCnt := 0;  ichild := 0;
    for i := 0 to JsonObj1.Size-1 do
    begin
      //if i=0 then
      an[i+1] := xmldoc.DocumentElement;
      if JsonObj1.Get(i).JsonValue is TJSONObject then
      begin
        //an[i+1] := xmldoc.DocumentElement;
        JsonObj2 := JsonObj1.Get(i).JsonValue as TJSONObject;
        Inc(iCnt);
        an1[iCnt] := an[i+1].AddChild(JsonObj1.Get(i).JsonString.Value);
        for j := 0 to JsonObj2.Size-1 do
          an1[iCnt].AddChild(JsonObj2.Get(j).JsonString.Value).NodeValue := JsonObj2.Get(j).JsonValue.Value;
      end
      else if JsonObj1.Get(i).JsonValue is TJsonValue then
      begin
        if (lowercase(JsonObj1.Get(i).JsonString.Value) = XUSERNAME) or
           (lowercase(JsonObj1.Get(i).JsonString.Value) = XPASSWORD) or
           (lowercase(JsonObj1.Get(i).JsonString.Value) = XSEED) or
           (lowercase(JsonObj1.Get(i).JsonString.Value) = XAXPAPP) then
          an[i+1].Attributes[JsonObj1.Get(i).JsonString.Value] := JsonObj1.Get(i).JsonValue.Value
        else
        begin
          if JsonObj1.Get(i).JsonString.Value = ConnectionName then
          begin
            //tempxml := LoadXMLData('<'+ConnectionName+'>'+JsonObj1.Get(i).JsonValue.Value+'</'+ConnectionName+'>');
            tempxml := LoadXMLData(JsonObj1.Get(i).JsonValue.Value);
            tmpnode := tempxml.DocumentElement;
            an[i+1].ChildNodes.Add(tmpnode);
          end
          else
          begin
            inc(ichild);
            an[ichild].AddChild(JsonObj1.Get(i).JsonString.Value).NodeValue := JsonObj1.Get(i).JsonValue.Value;
          end;
        end;
        if lowercase(JsonObj1.Get(i).JsonString.Value) = XAXPAPP then
          ConnectionName := JsonObj1.Get(i).JsonValue.Value;
      end;
      //WriteLog('XML Process of '+IntToStr(i)+' ' +Xmldoc.XML.Text);
    end;
  Except
  End;
  tempxml := LoadXMLData('<axprops getfrom=" " setto=" "><skin>DarkBlue</skin><login>local</login><lastlogin>newapp</lastlogin>'+
                         '<lastusername>admin</lastusername><licenseurl>111.93.187.30/abtsscripts</licenseurl><axhelp>true</axhelp>'+
                         '</axprops>');
  tmpnode := tempxml.DocumentElement;
  xmldoc.DocumentElement.ChildNodes.Add(tmpnode);
  Result := LoadXMLData(xmldoc.XML.Text);
end;

procedure WriteInToLog(msg:string);
var f:textfile;
    fn :string;
begin
  {$IFDEF CONSOLE_APP}
  // Code
    uAxLog.WriteLog(msg);
    Exit;
  {$ELSE}
    {$IFDEF AXINSTALLER_REST_MODE}
      // Code
       uAxLog.WriteLog(msg);
       Exit;
    {$ENDIF}
  {$ENDIF}
  if currentdir = '' then
  begin
    currentdir := GetModuleName(HInstance);
    delete(currentdir,1,pos(':',currentdir)-2);
    currentdir := ExtractFileDir(currentdir);
    SetCurrentDir(currentdir) ;
  end;
  if not fileexists(currentdir+'\traceequaltotrue.txt') then exit;
  fn := 'dLog'+formatdatetime('yymmdd',now)+'.txt';
  if Servicename <> '' then fn := Servicename+'_'+fn;
  fn := currentdir +'\'+fn;
  assignfile(f, fn);
  if fileexists(fn) then append(f) else rewrite(f);
  if copy(msg,1,2)='>>' then writeln(f, '');
  writeln(f, msg);
  closefile(f);
end;

Function GetJsonValue(JsonInput: TJSONObject; PairName : string): String; overload;
begin
  Result := '';
  if JsonInput.Get(PairName) <> nil then
  begin
    if JsonInput.Get(PairName).JsonValue is TJSONValue then
      Result := JsonInput.Get(PairName).JsonValue.Value;
  end;
end;

function SortJsonArrayByPairName(jArrObj : TJSONArray; PairName : string):TJsonArray;
var
  pcnt, i, j, Idx : Integer;
  jSortedArr : TJSONArray;
  jArrPairObj : TJSONObject;
  ordno : string;
begin
  jSortedArr := TJSONArray.Create;
  Idx := 1;
  pcnt := jArrObj.Size;
  for j := 0 to pcnt-1 do
  begin
    for i := 0 to pcnt-1 do
    begin
      jArrPairObj := jArrObj.Get(i) as TJSONObject;
      ordno := trim(GetJsonValue(jArrPairObj,PairName));
      if ordno = '' then continue;
      if ordno = IntToStr(Idx) then
      begin
        jSortedArr.Add(jArrPairObj);
        Inc(Idx);
        break;
      end;
    end;
  end;
  Result := jSortedArr;
end;

end.
