unit uImportStructures;

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
  IdExplicitTLSClientServerBase, System.Generics.Collections,
  idreplysmtp, MessageDigest_5, uStructInTable,
  IdHTTP, uAxLog,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, uDBManager, uConnect,
  uCompress, ZLib, {uImportDiff,} uImportStructDef, System.IOUtils,
{$IF CompilerVersion > 24.0}
  JSON
{$ELSE}
  DBXJson
{$IFEND}
    ;

type
  TImportStructures = class
  private
    // FImportDiff: TImportDiff;
    // FImportStructDef: TImportStructDef;

    Function WriteIviewDef(Fname, sDefaultPage, sStructXML: String): String;
    Function WriteTStructDef(FileName: string; sXML: String): String;
    Function MakeValidXMLString(pXMLString: String): String;
    Function UpdateStructXML(structxml: string): string;
    Function base64tostring(base64Data: String): string;
    function DecompressXMLContent(pFilename: string): IXMLDocument;
    Function ReadCompressFile(const FileName: string): String;
    Function DeCompressFile(pCompressedFile: String): String;
  public
    CoreParser: TProfitEval;
    // dbm : TDBManager;
    // axp : TAxprovider;
    // connection : pConnection;
    Function ImportStructure(FileName: string): String;
    Function ReadFile(FileName: String): String;
    constructor Create();
    // Destructor Destroy; Override;
    function InstallDataJson(ADataJsonFile: string): Boolean;

  end;

implementation

uses uCreateStructure, uUtils, uImportDiff;

var
  FImportDiff: TImportDiff;
  FImportStructDef: TImportStructDef;

constructor TImportStructures.Create;
begin
  AxStructures := Tlist<string>.Create;
  FImportDiff := TImportDiff.Create(Axprovider, True);
  FImportStructDef := TImportStructDef.Create(Axprovider, True);
  FImportDiff.FImpDir := AppDir { getcurrentdir()+'\' };
end;

Function TImportStructures.base64tostring(base64Data: String): string;
var
  Decoder: TIdDecoderMIME;
begin
  Decoder := TIdDecoderMIME.Create(nil);
  try
    Result := Decoder.DecodeString(base64Data);
  finally
    Decoder.Free;
  end;
end;

// Function TImportStructures.ReadXML(FileName : String):String;
// var
// SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
// IdHTTP1:TIdHTTP;
// GitURL:string;
// JSONObject:TJSONObject;
// JSONPair:TJSONPair;
// JSONString:String;
// JSONValue:TJSONValue;
// content:string;
// NewLineChar,EmptySpace:string;
// begin
// IdHTTP1:=TIdHTTP.Create(nil);
// Token:='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';
// Owner:='Paroksh11';
// reponame:='Axpert';
// SSLIOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP1);
// SSLIOHandler.SSLOptions.Method:=sslvTLSv1_2;
// IdHTTP1.IOHandler:=SSLIOHandler;
// IdHTTP1.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + Token);
// JSONObject:=TJSONObject.Create;
// //JObject:=TJSONObject.Create;
// GitURL:=Format('https://api.github.com/repos/%s/%s/contents/Plugin/'+selectedPlugin+'/AxpertStructure/Forms/'+FileName,[Owner,reponame]);
// IdHTTP1.HandleRedirects := True;
// try
// JSONString:=IdHTTP1.Get(GitURL);
// JSONObject:=TJSONObject.ParseJSONValue(JSONString) as TJSONObject;
// for JSONPair in JSONObject do
// begin
// if(JSONPair.JsonString.value='content') then
// begin
// NewLineChar:='\n';
// EmptySpace:='';
// content:=JSONPair.JsonValue.value;
// //StringReplace(dt,'/','_',[rfReplaceAll, rfIgnoreCase])
// content:=StringReplace(content,'/n','',[rfReplaceAll, rfIgnoreCase]);
// content:=StringReplace(content,''#$A'','',[rfReplaceAll, rfIgnoreCase]);
// Content:=base64tostring(content);
// Result:=content;
// end;
// end;
// except
// on F: Exception do
// begin
// writeln('Error during HTTP request: ' + F.Message);
// end;
// end;
// end;
procedure FileStreamToStringStream(FileStream: TFileStream;
  var StringStream: TStringStream);
begin
  // Reset the position of the file stream to the beginning
  FileStream.Position := 0;
  // Clear the existing content of the string stream
  StringStream.Clear;
  // Copy the content of the file stream to the string stream
  StringStream.CopyFrom(FileStream, FileStream.Size);
end;

Function TImportStructures.ReadCompressFile(const FileName: string): String;
var
  FileStream: TFileStream;
  DecompressedStream, CompressedStream: TStringStream;
  DecompressionBuffer: TBytes;

begin
  Result := '';

  try
    // Open the file for reading
    FileStream := TFileStream.Create(FileName, fmOpenRead);
    try
      // Create a string stream for the decompressed data
      DecompressedStream := TStringStream.Create('' { , TEncoding.Unicode } );
      //
      CompressedStream := TStringStream.Create('' { , TEncoding.Unicode } );
      try
        FileStream.Position := 0;
        FileStreamToStringStream(FileStream, CompressedStream);
        CompressedStream.Position := 0;
        // Decompress the data

        // ZDecompressStream(FileStream, DecompressedStream);
        with TCompress.Create do
        begin
          DecompressedStream := DecompressStream(CompressedStream, False);
          destroy;
        end;
        DecompressedStream.Position := 0;
        // Result := LoadXMLData(trim(DecompressedStream.DataString));
        // Reset the position of the decompressed stream to the beginning
        // DecompressedStream.Position := 0;

        // Read the decompressed data from the stream
        Result := DecompressedStream.DataString;
      finally
        // Free the decompressed stream
        DecompressedStream.Free;
      end;
    finally
      // Free the file stream
      FileStream.Free;
    end;
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      // Handle any exceptions
      Console_write('Error loading compressed Unicode file: ' + E.Message, 12);
      writeln;
    end;
  end;
end;
// var
// StreamReader: TStreamReader;
// FileStream: TFileStream;
// Stream: TStringStream;
/// /  EncryptedData: TBytes;
// begin
// // try
// // Result := TStringStream.Create('', TEncoding.UTF8);
// // StreamReader := TStreamReader.Create(FileName, TEncoding.UTF8);
// // Result.WriteString(StreamReader.ReadToEnd);
// //
// // finally
// // StreamReader.Free;
// // end;
//
// FileStream := TFileStream.Create(FileName, fmOpenRead);
// try
// Stream := TStringStream.Create('');
// try
// // Read encrypted data from the file
// Stream.CopyFrom(FileStream, FileStream.Size);
// Result := Stream.DataString;
// except
// Stream.Free;
// raise;
// end;
// finally
// FileStream.Free;
// end;
// end;

function DecryptImplementation(const CipherText: string): string;
begin
  Result := '';

  try
    writelog('DecryptImplementation started.');

    // TODO:
    // AES-256 CBC PKCS7 Decryption
    // Key : AxiDataPackageAxpertExportImport
    // IV  : AxiDataPackages1

    Result := CipherText; // Temporary

    writelog('DecryptImplementation completed.');
  except
    on E: Exception do
    begin
      writelog('DecryptImplementation Error : ' + E.Message);
      raise;
    end;
  end;
end;

Function TImportStructures.ReadFile(FileName: String): String;
var
  XMLFile: TextFile;
  Data: string;
  FileContent: Tstringlist;
  FileStream: TFileStream;
  Buffer: TStringStream;

  path: string;
begin
  try
    writelog('ReadFile function started..');
    if copy(ExtractFileName(FileName), 0, 3) = 'c__' then
    begin
      Result := ReadCompressFile(FileName);
      // Continue;

      // FileStream := TFileStream.Create(FileName, fmOpenRead);
      // FileStream.POsition := 0;
      // try
      // Buffer := TStringStream.Create('');
      // try
      // Buffer.CopyFrom(FileStream, FileStream.Size);
      // Buffer.Position := 0;
      // Result := Buffer.DataString;
      // finally
      // Buffer.Free;
      // end;
      // finally
      // FileStream.Free;
      // end;
    end
    else
    begin
      FileContent := TStringList.Create;
      try
        FileContent.LoadFromFile(FileName);
        Result := FileContent.Text;

        // Decrypt Data Package (.axidata) files
        if SameText(ExtractFileExt(FileName), '.axidata') then
        begin
          writelog('Decrypting axidata file : ' + ExtractFileName(FileName));
         // Result := DecryptImplementation(Result);   // Your helper method
          Result := FileContent.Text;
        end;
      finally
        FileContent.Free;
      end;
    end;
    // stringList := Tstringlist.Create;
    // StreamReader := TStreamReader.Create(FileName);
    // while not StreamReader.EndOfStream do
    // begin
    // Data := StreamReader.ReadLine
    // end;
    // stringList.LoadFromFile(path);
    // Data := stringList.Text;
    // Result:= TFile.ReadAllText(FileName);
    // Result := Data;
    // writeln(XMLData);
    // Exit;
    // readln;
    writelog('ReadFile function ends..');
  except
    on E: Exception do
    begin
      ReadErrorList(E.Message);
      Console_write('Error: ' + E.Message, 12);
      writeln;
      writelog('Error occured in ReadFile function : ' + E.Message);
    end;

  end;
  // readln;

  // finally
  // StringList.Free;
end;

// writeln(XMLData);
// Readln;

// trnsid var
Function TImportStructures.ImportStructure(FileName: string): String;
var
  sXML: string;
  ext: string;
  trans_id: string;
  txtfile: TextFile;
  DestinationFile, dfilename: string;
begin
  writelog('ImportStructure function started...');
  FImportDiff.SelectedTStruct := Tstringlist.Create;
  FImportDiff.SelectedPage := Tstringlist.Create;
  FImportDiff.CreateLog := False;
  FImportStructDef.CreateLog := False;
  trans_id := ChangeFileExt(ExtractFileName(FileName), '');
  ext := ExtractFileExt(FileName);
  if LowerCase(ext) = '.trn' then // forms
  begin
    if copy(ExtractFileName(FileName), 0, 3) = 'c__' then
    begin
      trans_id := copy(trans_id, 4, length(trans_id));
      FImportDiff.servicename := 'WriteTStructDef';
      sXML := DeCompressFile(FileName);
      WriteTStructDef(trans_id, sXML);
    end
    // sXML := ReadFile(FileName);
    // WriteTStructDef(trans_id, sXML);
    else
    begin
      sXML := ReadFile(FileName);
      writelog('Loaded XML Length for ' + FileName + ': ' +
        IntToStr(length(sXML)));
      FImportDiff.servicename := 'WriteTStructDef';
      WriteTStructDef(trans_id, sXML);
    end;
  end
  else if LowerCase(ext) = '.ivw' then // iviews
  begin
    if copy(ExtractFileName(FileName), 0, 3) = 'c__' then
    begin
      trans_id := copy(trans_id, 4, length(trans_id));
      sXML := DeCompressFile(FileName);
      FImportDiff.servicename := 'WriteIviewDef';
      // WriteIviewDef(trans_id, 't', sXML);
      WriteIviewDef(trans_id, 'f', sXML);
    end
    else
    begin
      sXML := ReadFile(FileName);
      writelog('Loaded XML Length for ' + FileName + ': ' +
        IntToStr(length(sXML)));
      FImportDiff.servicename := 'WriteIviewDef';
      // WriteIviewDef(trans_id, 't', sXML);
      WriteIviewDef(trans_id, 'f', sXML);
    end;
    //
    // readln;
  end
  else
  begin
    if (copy(ExtractFileName(FileName), 0, 3) = 'c__') and (ext <> '.xml') then
    begin
      dfilename := copy(ExtractFileName(FileName), 4, length(FileName));
      trans_id := copy(trans_id, 4, length(trans_id));
      sXML := DeCompressFile(FileName);
      DestinationFile := extractfilepath(FileName) + dfilename;
      try
        TFile.copy(FileName, DestinationFile, True);
      except
        on E: Exception do
        begin
          writeln(E.Message);
          writelog('Error while Copying ' + ExtractFileName(FileName) + ': ' +
            E.Message);
        end;

      end;
      // assignfile(txtfile,'D:\Axpert_Project\Axpert\AxPlugins\'+selectedplugin+'\Structures\'+trans_id+ext);
      // rewrite(txtfile);
      // writeln(txtfile,sXML);
      // closefile(txtfile);
      if (LowerCase(ExtractFileExt(FileName)) = '.tab') and
        (pos('ax_layoutdesign', LowerCase(FileName)) > 0) then
        // begin
        // FImportDiff.Transid := <Extracted_Transid_from_ax_layourdesign>;
        // end;
        writelog('Importing :' + ExtractFileName(DestinationFile));
      FImportDiff.StructureDiff(DestinationFile);
      // writelog('ImportStructure function started...');
    end
    else
    begin
      if ext <> '.xml' then
      begin
        sXML := DeCompressFile(FileName);
        writelog('Importing :' + ExtractFileName(FileName));
        FImportDiff.StructureDiff(FileName);

      end;
    end;
  end;
  if LowerCase(ext) = '.axidata' then
  begin
    writelog ('Importing axidata json file');
//    Readfile(Filename);
    InstallDataJson(FileName);
  end;

  writelog('ImportStructure function ends...');

end;

Function TImportStructures.MakeValidXMLString(pXMLString: String): String;
begin
  try
    pXMLString := trim(pXMLString);
    if pos('\\r\\n', pXMLString) > 0 then
      pXMLString := Axprovider.dbm.gf.FindAndReplace(pXMLString,
        '\\r\\n', #$D#$A);
    if pos('\\n', pXMLString) > 0 then
      pXMLString := Axprovider.dbm.gf.FindAndReplace(pXMLString, '\\n', #$A);
    if pos('\\r', pXMLString) > 0 then
      pXMLString := Axprovider.dbm.gf.FindAndReplace(pXMLString, '\\r', #$D);
    // Double slash not replaced back since it will be handled by .net json libraries automatically
    // if pos('\\',pXMLString) > 0  then  pXMLString := axp.dbm.gf.FindAndReplace(pXMLString, '\\', '\');
    if pos('^^dq', pXMLString) > 0 then
      pXMLString := Axprovider.dbm.gf.FindAndReplace(pXMLString, '^^dq', '"');
    // if pos('\"',pXMLString) > 0  then  pXMLString := axp.dbm.gf.FindAndReplace(pXMLString, '\"', '"');
    // if pos('¿',pXMLString) > 0  then  pXMLString := axp.dbm.gf.FindAndReplace(pXMLString, '¿', '"');
    // if pos('''',pXMLString) > 0  then  pXMLString := axp.dbm.gf.FindAndReplace(pXMLString, '''','\''');
  finally
    Result := pXMLString;
  end;
end;

Function TImportStructures.WriteIviewDef(Fname, sDefaultPage,
  sStructXML: String): String;
var
  vst: TCreateIviewStructure;
  fxml: IXMLDocument;
  tmnode, enode, defpageNode: IXMLNode;
  layout: string;
begin
  try

    // writeln(Fname+'.ivw Structure Importing...');
    Result := '';
    vst := nil;
    vst := TCreateIviewStructure.Create(Axprovider);
    vst.servicename := 'WriteIviewDef'; // 'CreateStruct_dwb';
    vst.TblPrefix := 'dwb_';
    fxml := LoadXMLData(sStructXML);
    enode := fxml.DocumentElement;
    tmnode := nil;
    layout := 'default';

    tmnode := enode.ChildNodes.FindNode('temp'); { AddChild('temp'); }
    if tmnode = nil then
    begin
      tmnode := enode.AddChild('temp');
    end;
    defpageNode := tmnode.ChildNodes.FindNode('defpage');
    if defpageNode = nil then
      tmnode.AddChild('defpage').NodeValue := 'f'
    else // The following may not be required as if it already exisits in structure xml
    begin
      if LowerCase(defpageNode.NodeValue) = 't' then
        tmnode.AddChild('defpage').NodeValue := 't'
      else
        tmnode.AddChild('defpage').NodeValue := 'f';
    end;

    // tmnode.AddChild('defpage').NodeValue := 'false';
    sStructXML := fxml.xml.Text;
    sStructXML := MakeValidXMLString(sStructXML);

    vst.WriteIviewDef(Fname, sDefaultPage, sStructXML);

    if vst.errormsg = '' then
    begin
      write('   - ');
      Console_write(Fname + '.ivw ', 10);
      write('Structure imported Successfully...!');
      writeln;
      AxStructures.Add(Fname + '.ivw');

    end
    else
    begin
      writeln(vst.errormsg);
      raise Exception.Create(vst.errormsg);
    end;
  finally
    tmnode := nil;
    if assigned(vst) then
    begin
      FreeAndNil(vst);
    end;
  end;
end;

Function TImportStructures.WriteTStructDef(FileName: string;
  sXML: String): String;
var
  sf: TCreateStructure;
begin
  try
    // writeln(FileName+'.trn  Structure Importing...');
    Result := '';
    sf := nil;
    sf := TCreateStructure.Create(Axprovider);

    sXML := MakeValidXMLString(sXML);

    // Call function UpdateStructXML
    sXML := UpdateStructXML(sXML);

    sf.servicename := 'WriteTStructDef';
    sf.Fname := FileName;

    sf.WriteTStructDef(FileName, sXML);

    if sf.errormsg = '' then
    begin
      write('   - ');
      Console_write(FileName + '.trn ', 10);
      write('Structure imported Successfully...!');
      AxStructures.Add(FileName + '.trn');
      writeln;

    end
    else
    begin

      writeln(sf.errormsg);
      raise Exception.Create(sf.errormsg);
    end;

  finally
    if assigned(sf) then
    begin
      FreeAndNil(sf);
    end;
  end;

end;

Function TImportStructures.UpdateStructXML(structxml: string): string;
var
  fxml: IXMLDocument;
  enode, tmnode, inode: IXMLNode;
  layout: string;
begin
  try
    fxml := LoadXMLData(structxml);
    enode := fxml.DocumentElement;
    tmnode := nil;
    layout := 'default'; // Layout can be read from xml and set if required

    // Add tempnode (ref from  uCreateStructure->ReadStructDef)
    tmnode := enode.AddChild('temp');
    // By default setting defpage to true | this needs to be handled based page visiblity
    if enode.HasAttribute('defpage') then
    begin
      if LowerCase(vartostr(enode.Attributes['defpage'])) = 'y' then
        tmnode.AddChild('defpage').NodeValue := 'true'
      else
        tmnode.AddChild('defpage').NodeValue := 'false';
    end
    else
      tmnode.AddChild('defpage').NodeValue := 'false';
    tmnode.AddChild('layout').NodeValue := layout;

    // Currently hardcoding the value but it has to fetched from the strcut xml
    tmnode.AddChild('listview').NodeValue := 'true';
    // Clearing iframaes child nodes , since it will be recreated when saving / importing the structure
    // ref uImportStructdef-CreateTStruct
    // Load ifrmaes
    inode := enode.ChildNodes.FindNode('iframes');
    // if iframes node not available then create iframes node
    if Not assigned(inode) then
    begin
      // Create ifrmaes
      inode := enode.AddChild('iframes');
      inode.Attributes['cat'] := 'iframes';
      inode.Attributes['layout'] := 'default';
    end
    else
      inode.ChildNodes.Clear; // Clear child nodes

    Result := fxml.xml.Text;
  finally
    fxml := nil;
    enode := nil;
    tmnode := nil;
    inode := nil;
  end;
end;

Function TImportStructures.DeCompressFile(pCompressedFile: String): String;
var
  sDecompressedFile: String;
begin
  Result := '';
  if pCompressedFile = '' then
    Exit;
  with TCompress.Create do
  begin
    sDecompressedFile := ChangeFileExt(pCompressedFile, '.xml');
    DeCompressFile(pCompressedFile, sDecompressedFile);
    With Tstringlist.Create do
    begin
      LoadFromFile(sDecompressedFile);
      Result := Text;
      Free;
    end;
    destroy;
  end;
end;

Function TImportStructures.DecompressXMLContent(pFilename: String)
  : IXMLDocument;
var
  stm, cstm: TStringStream;
  s: string;
begin
  stm := nil;
  cstm := nil;
  try
    s := ReadFile(pFilename);
    // writeln(s);
    // s := StringReplace(s, #0, ' ', [rfReplaceAll]);
    // writeln(s);
    stm := TStringStream.Create(s);
    // here load the content of a file into a TStringStream(stm),
    // stm:= ReadFile(pFilename);
    if stm.Size = 0 then
      Result := LoadXMLData('<root/>')
    else
    begin
      cstm := TStringStream.Create('');
      stm.Position := 0;
      // with TCompress.Create do
      // begin
      // cstm := DecompressStream(stm);
      // destroy;
      // end;
      // cstm.Position := 0;
      // Result := LoadXMLData(trim(cstm.DataString));
      FreeAndNil(cstm);
    end;
  finally
    if assigned(stm) then
      FreeAndNil(stm);
    if assigned(cstm) then
      FreeAndNil(cstm);
  end;
end;

function PrepareSignInRequest: string;
var
  JSONObject: TJSONObject;
begin
  writelog('PrepareSignInRequest function started...');
  JSONObject := TJSONObject.Create;
  try
    try
      JSONObject.AddPair('appname', ProjectName);
      JSONObject.AddPair('UserName', 'admin');
//      JSONObject.AddPair('UserName', 'dhanyaj');
      JSONObject.AddPair('password', '22723bbd4217a0abf6d3e68073c7603d');
      JSONObject.AddPair('Language', 'English');
      JSONObject.AddPair('SessionId', '12345');

      {$IF CompilerVersion > 24.0}
        JSONObject.AddPair('Globalvars', 'true');
        JSONObject.AddPair('ClearPreviousSession', 'true');
        JSONObject.AddPair('trace', 'true');
      {$ELSE}
        JSONObject.AddPair('Globalvars', TJSONTrue.Create);
        JSONObject.AddPair('ClearPreviousSession', TJSONTrue.Create);
        JSONObject.AddPair('trace', TJSONTrue.Create);
      {$IFEND}

      Result := JSONObject.ToString;
      writelog('SignIn Request : ' + Result);
    except
      on E: Exception do
      begin
        writelog('PrepareSignInRequest failed : ' + E.Message);
        raise;
      end;
    end;
  finally
    FreeAndNil(JSONObject);
  end;
  writelog('PrepareSignInRequest function ends...');
end;

procedure ParseSignInResponse(
  const Response: string;
  out ARMSessionId: string;
  out Token: string);
var
  RootObj: TJSONObject;
  ResultObj: TJSONObject;
  JsonText: string;
begin
  ARMSessionId := '';
  Token := '';
  writelog('ParseSignInResponse function started...');
  JsonText := Response;
  JsonText := StringReplace(JsonText, '\"', '"', [rfReplaceAll]);
  JsonText := StringReplace(JsonText, '\\', '\', [rfReplaceAll]);

  if (Length(JsonText) >= 2) and (JsonText[1] = '"') and (JsonText[Length(JsonText)] = '"') then
    JsonText := Copy(JsonText, 2, Length(JsonText) - 2);

  writelog('Parsed SignIn JSON : ' + JsonText);
  RootObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  if RootObj = nil then
    raise Exception.Create('Invalid SignIn response.');

  try
    if RootObj.Get('result') = nil then
      raise Exception.Create('Invalid SignIn response. "result" node not found.');
    ResultObj := RootObj.Get('result').JsonValue as TJSONObject;

    if ResultObj.Get('ARMSessionId') = nil then
      raise Exception.Create('ARMSessionId not found.');
    if ResultObj.Get('token') = nil then
      raise Exception.Create('Token not found.');

    ARMSessionId := ResultObj.Get('ARMSessionId').JsonValue.Value;
    Token := ResultObj.Get('token').JsonValue.Value;

    writelog('Authentication response parsed successfully.');
    writelog('ARMSessionId : ' + ARMSessionId);
    writelog('Token extracted successfully.');
    writelog('ParseSignInResponse completed.');
  finally
    FreeAndNil(RootObj);
  end;
  writelog('ParseSignInResponse function ends...');
end;

procedure DoSignIn(
  const SignInURL: string;
  out ARMSessionId: string;
  out Token: string);
var
  HTTP: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  RequestStream: TStringStream;
  ResponseStream: TStringStream;
  SignInRequest: string;
  Response: string;
begin
  writelog('DoSignIn function started...');
  ARMSessionId := '';
  Token := '';
  HTTP := nil;
  SSLIOHandler := nil;
  RequestStream := nil;
  ResponseStream := nil;
  try
    HTTP := TIdHTTP.Create(nil);
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    HTTP.IOHandler := SSLIOHandler;
    HTTP.HandleRedirects := True;
    HTTP.RedirectMaximum := 15;
    HTTP.HTTPOptions := [hoForceEncodeParams];
    HTTP.ProtocolVersion := pv1_1;
    HTTP.Request.CharSet := 'utf-8';
    HTTP.Request.CacheControl := 'no-cache';
    HTTP.Request.Accept := 'application/json';
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.UserAgent := 'Axpert';

    SignInRequest := PrepareSignInRequest;
    writelog('Calling SignIn URL : ' + SignInURL);
    writelog('SignIn Request : ' + SignInRequest);
    RequestStream := TStringStream.Create(SignInRequest, TEncoding.UTF8);
    ResponseStream := TStringStream.Create('', TEncoding.UTF8);

    writelog('Calling ARM SignIn API...');
    writelog('URL : ' + SignInURL);
    try
      HTTP.Post(SignInURL, RequestStream, ResponseStream);

      writelog('ARM SignIn API completed.');
      writelog('HTTP Status : ' + IntToStr(HTTP.ResponseCode));
      writelog('HTTP Description : ' + HTTP.ResponseText);

      Response := ResponseStream.DataString;
      writelog('SignIn Response : ' + Response);

      if Pos('\"success\":false', LowerCase(Response)) > 0 then
      begin
        raise Exception.Create(Response);
      end;
    except
      on E: Exception do
      begin
        writelog('ARM SignIn API failed.');
        raise;
      end;
    end;
    ParseSignInResponse(Response, ARMSessionId, Token);

    if (Trim(ARMSessionId) = '') or (Trim(Token) = '') then
      raise Exception.Create('Authentication failed.');

    writelog('Authentication completed successfully.');
  finally
    if Assigned(RequestStream) then FreeAndNil(RequestStream);
    if Assigned(ResponseStream) then FreeAndNil(ResponseStream);
    if Assigned(HTTP) then FreeAndNil(HTTP);
  end;
  writelog('DoSignIn function ends...');
end;

function BuildAxPutRequest(
  const AxDataJson: string;
  const ARMSessionId: string): string;
var
  RootObj: TJSONObject;
  ResultPayloadObj: TJSONObject;
  AxPutPayloadObj: TJSONObject;
  AxPutJsonRequest: string;
begin
  Result := '';
  RootObj := nil;

  writelog('BuildAxPutRequest function started...');

  try
    writelog('Parsing AxiData package JSON.');

    AxPutJsonRequest := AxDataJson;
    AxPutJsonRequest := StringReplace(AxPutJsonRequest, '\', '\\', [rfReplaceAll]);

    RootObj := TJSONObject.ParseJSONValue(AxPutJsonRequest) as TJSONObject;

    if RootObj = nil then
      raise Exception.Create('Invalid AxiData package JSON.');

    writelog('AxiData JSON parsed successfully.');

    if RootObj.Get('resultpayload') = nil then
      raise Exception.Create('"resultpayload" node not found.');

    ResultPayloadObj := RootObj.Get('resultpayload').JsonValue as TJSONObject;

    if ResultPayloadObj.Get('axputpayloads') = nil then
      raise Exception.Create('"axputpayloads" node not found.');

    AxPutPayloadObj := ResultPayloadObj.Get('axputpayloads').JsonValue as TJSONObject;

    if AxPutPayloadObj.Get('ARMSessionId') <> nil then
      AxPutPayloadObj.RemovePair('ARMSessionId');

    AxPutPayloadObj.AddPair('ARMSessionId', ARMSessionId);

    Result := AxPutPayloadObj.ToString;

    writelog('AxPut request JSON prepared successfully.');
    writelog(Result);

    RootObj.Free;
    RootObj := nil;

  except
    on E: Exception do
    begin
      if Assigned(RootObj) then
        RootObj.Free;

      writelog('BuildAxPutRequest failed.');
      writelog('Reason : ' + E.Message);
      raise;
    end;
  end;
  writelog('BuildAxPutRequest function completed.');
end;

procedure DoAxPut(
  const AxPutURL: string;
  const AxPutRequest: string;
  const ARMSessionId: string;
  const Token: string);
var
  HTTP: TIdHTTP;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  RequestStream: TStringStream;
  ResponseStream: TStringStream;
  RequestJSON: string;
begin
  HTTP := nil;
  SSLIOHandler := nil;
  RequestStream := nil;
  ResponseStream := nil;
  writelog('DoAxPut function started...');
  try
    writelog('Creating HTTP client.');
    HTTP := TIdHTTP.Create(nil);
    SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    SSLIOHandler.SSLOptions.Method := sslvTLSv1_2;
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    HTTP.IOHandler := SSLIOHandler;
    HTTP.HandleRedirects := True;
    HTTP.RedirectMaximum := 15;
    HTTP.HTTPOptions := [hoForceEncodeParams];
    HTTP.ProtocolVersion := pv1_1;
    HTTP.Request.CharSet := 'utf-8';
    HTTP.Request.CacheControl := 'no-cache';
    HTTP.Request.Accept := 'application/json';
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.UserAgent := 'Axpert';
    HTTP.Request.CustomHeaders.Clear;
    HTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + Token);

    RequestJSON := BuildAxPutRequest(AxPutRequest, ARMSessionId);

    RequestStream := TStringStream.Create(RequestJSON, TEncoding.UTF8);
    ResponseStream := TStringStream.Create('', TEncoding.UTF8);

    try
      writelog('Sending AxPut Request...');
      HTTP.Post(AxPutURL, RequestStream, ResponseStream);
      writelog('AxPut Response: ' + ResponseStream.DataString);
    except
      on E: Exception do
      begin
        writelog('ARM AxPut API failed.');
        writelog('Error : '+ ResponseStream.DataString);
        raise;
      end;
    end;
  finally
    if Assigned(RequestStream) then FreeAndNil(RequestStream);
    if Assigned(ResponseStream) then FreeAndNil(ResponseStream);
    if Assigned(HTTP) then FreeAndNil(HTTP);
  end;
  writelog('DoAxPut function ends...');
end;


function TImportStructures.InstallDataJson(ADataJsonFile: string): Boolean;
var
  AxPutRequest: string;
  //  SignInURL: string;
//  AxPutURL: string;
  ARMSessionId: string;
  Token: string;
  FileName: string;
begin
  Result := False;
  writelog('InstallDataJson function started.');
  try
    FileName := ExtractFileName(ADataJsonFile);
    writelog('Processing AxiData Package : ' + FileName);
    Console_write('   - Processing AxiData Json File ' + FileName + '.', 10);
    Writeln;

    writelog('Reading AxiData package.');
    AxPutRequest := ReadFile(ADataJsonFile);
    writelog('AxiData package loaded successfully.');

    // hardcoded for now, need to enhance to be read from appsettings
//    SignInURL := 'https://agileqa.agilecloud.biz/armnew/api/v1/Signin';
//    AxPutURL := 'https://agileqa.agilecloud.biz/armnew/api/v1/AxPut';
    if ArmSignInUrl = '' then
      raise Exception.Create('ARM SignIn Url is Empty');

    if ArmAxPutUrl = '' then
      raise Exception.Create('ARM AxPut Url is Empty');

    writelog('Authenticating with ARM.');
    DoSignIn(ArmSignInUrl, ARMSessionId, Token);
    writelog('Authentication completed successfully.');

    writelog('Submitting package to AxPut API.');
    DoAxPut(ArmAxPutUrl, AxPutRequest, ARMSessionId, Token);
    writelog('Package imported successfully.');
    Result := True;

    Console_write('   - AxiData Json File ' + FileName +' imported successfully.', 10);
    Writeln;
  except
    on E: Exception do
    begin
      Result := False;
      writelog('InstallDataJson failed.');
      writelog('Error : ' + E.Message);
      ReadErrorList(E.Message);
      Console_write('Error : ' + E.Message, 12);
      Writeln;
      raise;
    end;
  end;
  writelog('InstallDataJson function ends...');
end;

end.
