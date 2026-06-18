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
  IdHTTP,uAxLog,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, uDBManager, uConnect,
  uCompress, ZLib,{uImportDiff,}uImportStructDef,system.IOUtils,
{$IF CompilerVersion > 24.0}
  JSON
{$ELSE}
  DBXJson
{$IFEND}
    ;

type
  TImportStructures = class
  private
//    FImportDiff: TImportDiff;
//    FImportStructDef: TImportStructDef;

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

  end;

implementation

uses uCreateStructure,uUtils,uImportDiff;

var
    FImportDiff: TImportDiff;
    FImportStructDef: TImportStructDef;

constructor TImportStructures.Create;
begin
  AxStructures := Tlist<string>.Create;
  FImportDiff := TImportDiff.Create(Axprovider, True);
  FImportStructDef := TImportStructDef.Create(Axprovider, True);
  FImportDiff.FImpDir := AppDir {getcurrentdir()+'\'};
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
      FileContent := Tstringlist.Create;
      FileContent.LoadFromFile(FileName);
      Result := FileContent.Text;
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
      writelog('Error occured in ReadFile function : '+E.Message);
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
  txtfile:textfile;
  DestinationFile,dfilename:string;
begin
  writelog('ImportStructure function started...');
  FImportDiff.SelectedTStruct :=TStringList.Create;
  FImportDiff.SelectedPage :=TStringList.Create;
  FImportDiff.CreateLog := False;
  FImportStructDef.CreateLog := False;
  trans_id := ChangeFileExt(ExtractFileName(FileName), '');
  ext := ExtractFileExt(FileName);
  if LowerCase(ext) = '.trn' then // forms
  begin
 if copy(ExtractFileName(FileName), 0, 3) = 'c__' then
    begin
      trans_id := copy(trans_id, 4, length(trans_id));
      FImportDiff.servicename:='WriteTStructDef';
      sXML := DeCompressFile(FileName);
      WriteTStructDef(trans_id, sXML);
    end
    // sXML := ReadFile(FileName);
    // WriteTStructDef(trans_id, sXML);
    else
    begin
      sXML := ReadFile(FileName);
      writelog('Loaded XML Length for ' + FileName + ': ' + IntToStr(Length(sXML)));
      FImportDiff.servicename:='WriteTStructDef';
      WriteTStructDef(trans_id, sXML);
    end;
  end
  else if LowerCase(ext) = '.ivw' then // iviews
  begin
    if copy(ExtractFileName(FileName), 0, 3) = 'c__' then
    begin
      trans_id := copy(trans_id, 4, length(trans_id));
      sXML := DeCompressFile(FileName);
      FImportDiff.servicename:='WriteIviewDef';
//      WriteIviewDef(trans_id, 't', sXML);
      WriteIviewDef(trans_id, 'f', sXML);
    end
    else
    begin
      sXML := ReadFile(FileName);
      writelog('Loaded XML Length for ' + FileName + ': ' + IntToStr(Length(sXML)));
      FImportDiff.servicename:='WriteIviewDef';
//      WriteIviewDef(trans_id, 't', sXML);
      WriteIviewDef(trans_id, 'f', sXML);
    end;
    //
    // readln;
  end
  else
  begin
      if (copy(ExtractFileName(FileName), 0, 3) = 'c__')and (ext <> '.xml') then
    begin
      dfilename:= copy(extractfilename(FileName), 4, length(Filename));
      trans_id := copy(trans_id, 4, length(trans_id));
      sXML := DeCompressFile(FileName);
      DestinationFile:=extractfilepath(FileName)+dfilename;
      try
      TFile.Copy(FileName, DestinationFile,True);
      except on
      E:Exception do
      begin
        writeln(E.message);
        writelog('Error while Copying '+Extractfilename(FileName)+': '+E.message);
      end;

      end;
//      assignfile(txtfile,'D:\Axpert_Project\Axpert\AxPlugins\'+selectedplugin+'\Structures\'+trans_id+ext);
//      rewrite(txtfile);
//      writeln(txtfile,sXML);
//      closefile(txtfile);
      if (lowercase(ExtractFileExt(FileName)) = '.tab') and  (pos('ax_layoutdesign',lowercase(FileName)) > 0) then
//      begin
//  FImportDiff.Transid := <Extracted_Transid_from_ax_layourdesign>;
//      end;
      writelog('Importing :'+extractfilename(DestinationFile));
      FImportDiff.StructureDiff(DestinationFile);
    //  writelog('ImportStructure function started...');
      end
      else
      begin
        if ext <> '.xml' then
        begin
          sXML := DeCompressFile(FileName);
          writelog('Importing :'+extractfilename(FileName));
          FImportDiff.StructureDiff(FileName);


        end;
      end;
    end;
    writelog('ImportStructure function ends...');
//  //

end;

Function TImportStructures.MakeValidXMLString(pXMLString: String): String;
begin
  try
    pXMLString := trim(pXMLString);
    if pos('\\r\\n', pXMLString) > 0 then
      pXMLString := axprovider.dbm.gf.FindAndReplace(pXMLString,
        '\\r\\n', #$D#$A);
    if pos('\\n', pXMLString) > 0 then
      pXMLString := axprovider.dbm.gf.FindAndReplace(pXMLString, '\\n', #$A);
    if pos('\\r', pXMLString) > 0 then
      pXMLString := axprovider.dbm.gf.FindAndReplace(pXMLString, '\\r', #$D);
    // Double slash not replaced back since it will be handled by .net json libraries automatically
    // if pos('\\',pXMLString) > 0  then  pXMLString := axp.dbm.gf.FindAndReplace(pXMLString, '\\', '\');
    if pos('^^dq', pXMLString) > 0 then
      pXMLString := axprovider.dbm.gf.FindAndReplace(pXMLString, '^^dq', '"');
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
  tmnode,enode,defpageNode : IXMLNode;
  layout: string;
begin
  try

    // writeln(Fname+'.ivw Structure Importing...');
    Result := '';
    vst := nil;
    vst := TCreateIviewStructure.Create(axprovider);
    vst.servicename := 'WriteIviewDef'; // 'CreateStruct_dwb';
    vst.TblPrefix := 'dwb_';
    fxml := LoadXMLData(sStructXML);
    enode := fxml.DocumentElement;
    tmnode := nil;
    layout := 'default';

    tmnode := enode.ChildNodes.FindNode('temp');{AddChild('temp'); }
    if tmnode = nil then
    begin
      tmnode := enode.AddChild('temp');
    end;
    defpageNode:=tmnode.ChildNodes.FindNode('defpage');
    if defpageNode = nil then
      tmnode.AddChild('defpage').NodeValue := 'f'
    else //The following may not be required as if it already exisits in structure xml
    begin
      if lowercase(defpageNode.NodeValue) = 't' then
        tmnode.AddChild('defpage').NodeValue := 't'
      else
        tmnode.AddChild('defpage').NodeValue := 'f';
    end;

//    tmnode.AddChild('defpage').NodeValue := 'false';
    sStructXML:=fxml.xml.Text;
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
    tmnode:=nil;
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
    sf := TCreateStructure.Create(axprovider);

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
    //By default setting defpage to true | this needs to be handled based page visiblity
    if enode.HasAttribute('defpage') then
    begin
      if lowercase(vartostr(enode.Attributes['defpage'])) = 'y' then
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

end.
