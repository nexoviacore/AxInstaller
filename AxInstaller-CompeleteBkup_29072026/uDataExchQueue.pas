unit uDataExchQueue;
{uDataExchQueue unit}

{Copied from \Axpert9-XE3\Ver 11.2}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, db,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls,Clipbrd,uDbManager, dateutils, uXDS,
  uStructDef,uParse,XMLDoc,XMLIntf,StrUtils,uStoreData,uProfitEval,{uDBCall,uASBDataObj,}
  {uAxFastRun,}Soap.EncdDecd,uPublishToRMQ,uAutoPrint,
  // Delphi XE3 has a DBXJson object for JSON support but above that version (>XE3) DBXJson is deprecated and JSON object is used.
{$IF CompilerVersion > 24.0}
      JSON
{$ELSE}
      DBXJson
{$IFEND}
      ;

type

  TDataExchQueue = class
  private
    //axfast:TAxfastRun;
    AutoPrint : TAutoPrint;
    XMLDoc , StructXml : IXMLDocument;
    //Newly introduced , before to this itself structdef and stiredata introduced  ele it could have been avoided
    //Optimize it in the future
    //DBCall : TDBCall;
    structdef : TStructDef;
    //ASBTStructObj:TASBTStructObj;

    Parser : TProfitEval;

    //StoreDataObject,ParserObject : TObject;
    slAttachments : TStringList;

    sAttachFolder,AxpImgPath,AxpImgServer : String;
    IsAccessibleDir : Boolean;

    procedure GetAxpImgPath;
    procedure GetAxpImgServer;
    function GetFileUsingPattern(pFilePathWithPattern: String): string;
    function GetGridAttach(FldName: String; RowNo: Integer; recid: Extended;
      Imagelist: TStringList): TStringList;
    function GetNonGridImage(pImageFieldName: String): TStringList;
    procedure Init;
    procedure loadimages(FldName: String; RowNo: Integer; recid: Extended); Overload;
    procedure loadimages(FldName: String;RowNo:Integer;Oval:Boolean); Overload;
    procedure loadimages(FldName:String;
          RowNo:Integer;recid:Extended; Imagelist : TStringList); Overload;

    function PrepareDataOutJSON(pFieldNames,pFastPrints: String; pbAllFields, pbPrintForms,
      pbFileAttachments: Boolean): String;
    procedure PushFormDataToQueue(pInDataSet: TXDS);
    procedure PushSaveDataToQueue(sQueueName, sAPIPayload: String);
    Procedure PrepareFastPrint(pTransid, pReportName: string;pDataJsonObject : TJSONObject);

  Public
    StoreData : TStoreData;
    ParserObject : TObject;
    Dbm : TDbManager;
    RecrId : Extended;
    primaryfield:string;

    constructor create(pStructDef : TStructDef); virtual;
    destructor destroy; override;
    procedure ProcessDataOut;


end;

implementation

//DataExchQueue

//Create
constructor TDataExchQueue.create(pStructDef : TStructDef);
begin
  //create
  structdef := pStructDef;

  //DBCall := nil;
  Storedata := nil;
  Parser := nil;

  //StoreDataObject := nil;
  ParserObject := nil;

  AutoPrint := nil;
  //axfast := nil;
  slAttachments := nil;

  sAttachFolder := '';
  AxpImgPath := '';
  AxpImgServer := '';

  IsAccessibleDir := False;
end;

//Destroy
destructor TDataExchQueue.Destroy;
begin
  //Destroy
  if Assigned(slAttachments) then
    FreeAndNil(slAttachments);
  if Assigned(AutoPrint) then
    FreeAndNil(AutoPrint);
  //if assigned(axfast) then
    //FreeandNil(axfast);
  inherited;
end;

Procedure TDataExchQueue.Init;
begin
  if Assigned(ParserObject) then
    Parser := TProfitEval(ParserObject);
  GetAxpImgServer;
  GetAxpImgPath;
end;

//StringExistsInCSV
function StringExistsInCSV(const searchStr, csvStr: string): Boolean;
var
  csvArray: TArray<string>;
  csvItem: string;
begin
  csvArray := csvStr.Split([',']);
  for csvItem in csvArray do
  begin
    if SameText(csvItem, searchStr) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

//GetFileUsingPattern
Function TDataExchQueue.GetFileUsingPattern(pFilePathWithPattern : String) : string;
  var rfile,s,sFilePath: String;
      sr: TSearchRec;
begin
  result := '';
  structdef.axprovider.dbm.gf.DoDebug.Msg('GetFileUsingPattern starts... ');
  try
    rfile := pFilePathWithPattern;
    sFilePath := ExtractFilePath(rfile);
    sFilePath := IncludeTrailingBackslash(sFilePath);
    structdef.axprovider.dbm.gf.DoDebug.Msg('GetFileUsingPattern/ Search pattern : '+rfile);
    structdef.axprovider.dbm.gf.DoDebug.Msg('GetFileUsingPattern/ Search FilePath : '+sFilePath);
//    if FileExists('\\172.16.0.85\Attachment_QA\outboundqueue\notif\picture\1193010000000.jpg') then
//    ShowMessage('rFile is there');
    if (findfirst(rfile, faAnyFile, sr) = 0) then
    begin
      repeat
        if (sr.Name = '.') or (sr.Name = '..') then continue;
        s := sr.name;
        result := sFilePath+s;
        structdef.axprovider.dbm.gf.DoDebug.Msg('GetFileUsingPattern/result '+result);
        break;
      until FindNext(sr) <> 0;
      System.SysUtils.FindClose(sr);
    end;
  Except on E:Exception do
    structdef.axprovider.dbm.gf.DoDebug.Msg('Error in GetFileUsingPattern '+E.Message);
  end;
  structdef.axprovider.dbm.gf.DoDebug.Msg('GetFileUsingPattern ends. ');
end;

//RemoveLineBreaks
function RemoveLineBreaks(const InputStr: string): string;
begin
  Result := StringReplace(InputStr, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
end;


//FileToBase64
function FileToBase64(const fileName: string): string;
var
  stream: TMemoryStream;
begin
  stream := TMemoryStream.Create;
  try
    stream.LoadFromFile(fileName);
    stream.Position := 0;
    //Encoded data has CR LF to handle that we called RemoveLineBreaks
    Result := RemoveLineBreaks(EncodeBase64(stream.Memory, stream.Size));
  finally
    stream.Free;
  end;
end;

//StreamToBase64
function EncodeStreamToBase64(stream: TStream): string;
var
  byteArray: TBytes;
begin
  if Assigned(stream) then
  begin
    SetLength(byteArray, stream.Size);
    stream.Position := 0;
    stream.Read(byteArray[0], stream.Size);
    Result := EncodeBase64(byteArray, Length(byteArray));
  end
  else
    Result := '';
end;

//loadimages
procedure TDataExchQueue.loadimages(FldName: String;RowNo:Integer;recid: Extended);
var sfile, tfile, ImgFileList, fName : String;
    ind : integer;
begin
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages 1 starts...');
  if (structdef.axprovider.dbm.gf.sMapUserName <> '')
     and (structdef.axprovider.dbm.gf.sMapPassword <> '') then
  begin
    try
      If Not structdef.axprovider.dbm.gf.IsAccessiblePath(AxpImgServer+AxpImgPath) Then
      begin
        Raise Exception.Create('You do not have the access for specified path.');
      end;
      Except on E:Exception do
      begin
       structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uViewImage\loadimages - '+e.Message);
       Raise Exception.Create('There is a problem in network mapping connection.'+#13+'Please try again.');
      end;
    end;
  end;
  IsAccessibleDir := True;
  ImgFileList := StoreData.GetFieldValue(FldName,Rowno);//GetFieldValue(FldName,Rowno,False);

  ind := 1;
  fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
  while fName <> '' do
  begin
    tfile := sAttachFolder+'\'+fname;
    sfile := AxpImgServer+AxpImgPath+structdef.Transid+'\'+FldName+'\'+Trim(Floattostr(recid))+'-'+fname;
    if Not FileExists(tfile) then
      CopyFile(pChar(sfile),pChar(tfile),False);
    inc(ind);
    slAttachments.Add(tfile);
    fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
  end;
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages 1 ends.');
end;

//loadimages
procedure TDataExchQueue.loadimages(FldName: String;RowNo:Integer;Oval:Boolean);
var sfile, tfile, ImgFileList, fName, ImgPathFldName, ImgPath : String;
    ind : integer;
    fld : pFld;
begin
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages 2 starts...');
  fld := structdef.GetField(FldName);
  if not assigned(fld) then exit;
  ImgFileList := Trim(Storedata.GetFieldValue(FldName,Rowno));
  ImgPathFldName := 'dc'+IntToStr(fld.FrameNo)+'_imagepath';
  ImgPath := Trim(Storedata.GetFieldValue(ImgPathFldName,RowNo));
  if imgPath = '' then
  begin
    structdef.axprovider.dbm.gf.dodebug.msg(ImgPathFldName + ' value should not be left as empty.');
    exit;
  end;
  if Copy(ImgPath,Length(ImgPath),1) <> '\' then
    ImgPath := ImgPath+'\';
  ImgPath := AxpImgServer+ImgPath;

  if (structdef.axprovider.dbm.gf.sMapUserName <> '') and (structdef.axprovider.dbm.gf.sMapPassword <> '') then  begin
  try
    If Not structdef.axprovider.dbm.gf.IsAccessiblePath(AxpImgServer) Then
    begin
       raise Exception.Create('You do not have the access for specified path.');
    end;
    Except on E:Exception do
    begin
     structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uViewImage\loadimages - '+e.Message);
     raise Exception.Create('There is a problem in network mapping connection.'+#13+'Please try again.');
    end;
  end;
 end;
 IsAccessibleDir := True;

  if ImgFileList <> '' then begin
    ind := 1;
    fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
    while fName <> '' do begin
      tfile := sAttachFolder+'\'+fname;
      sfile := ImgPath+fname;
      if Not FileExists(tfile) then
        CopyFile(pChar(sfile),pChar(tfile),False);
      inc(ind);
      slAttachments.Add(tfile);
      fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
    end;
  end;
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages 2 ends.');
end;

//GetAxpImgServer
Procedure TDataExchQueue.GetAxpImgServer;
begin

  AxpImgServer := Trim(Parser.GetVarValue('AxpImageServer'));
  if (AxpImgServer <> '') then begin
    if (Copy(AxpImgServer,Length(AxpImgServer),1) <> '\') then
      AxpImgServer := AxpImgServer+'\';
  end;
end;

//GetAxpImgPath
Procedure TDataExchQueue.GetAxpImgPath;
begin
  if structdef.HasImgPath then
    AxpImgPath := ''
  else begin
    AxpImgPath := Parser.GetVarValue('AxpImagePath');
    if (AxpImgPath <> '') and (Copy(AxpImgPath,Length(AxpImgPath),1) <> '\') then
      AxpImgPath := AxpImgPath+'\';
  end;
end;


//loadimages - Main
procedure TDataExchQueue.loadimages(FldName:String;
          RowNo:Integer;recid:Extended; Imagelist : TStringList);
var
  ind : integer;
  tblName, fname, w, ImgFileList : string;
begin
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages main starts...');
  if AxpImgPath <> '' then
    Loadimages(FldName,RowNo,recid)
  else
  begin
    if structdef.HasImgPath then
      LoadImages(FldName,RowNo,False)
    else
    begin
      ImgFileList := Trim(StoreData.GetFieldValue(FldName,Rowno));
      if ImgFileList <> '' then
      begin
        tblName := structdef.transid+FldName;
        ind := 1;

        fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
        while fname <> '' do begin
          w :='filename='+quotedstr(fName)+' and recordid = '+Floattostr(recid);
          fname := sAttachFolder+'\'+fName;
          if Not FileExists(fname) then
            structdef.axprovider.dbm.ReadBlob('img',tblname,w,fname);
          inc(ind);
          slAttachments.Add(fname);
          fName := structdef.axprovider.dbm.gf.GetNthString(ImgFileList,ind);
        end;

      end;
    end;
  end;
  if IsAccessibleDir then
    structdef.AxProvider.dbm.gf.DisconnectMap(AxpImgServer+AxpImgPath);
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('loadimages main ends.');
end;

//ConvertFileListToBase64
function ConvertFileListToBase64(const fileList: TStringList): TStringList;
var
  i: Integer;
  filename,base64Data : String;
begin
  Result := nil;
  if Not Assigned(fileList) or (fileList.Count = 0) then
    Exit;
  Result := TStringList.Create;
  try
    for i := 0 to fileList.Count - 1 do
    begin
      // Extract filename without path
      filename := ExtractFileName(fileList[i]);

      // Convert file to base64
      base64Data := FileToBase64(fileList[i]);

      // Add to the result TStringList
      Result.Add(filename + ' = ' + base64Data);
    end;
  except
    raise;
  end;
end;


//GetGridAttach - Fetch grid attach and convert as json
Function TDataExchQueue.GetGridAttach(FldName:String;
          RowNo:Integer;recid:Extended; Imagelist : TStringList) : TStringList;
begin
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('GetGridAttach starts...');
  try
    Result := nil;
    Result := TStringList.Create;

    if Not Assigned(slAttachments) then
      slAttachments := TStringList.Create();
    slAttachments.clear;

    sAttachFolder := structdef.axprovider.dbm.gf.StartPath+'viewimg';
    ForceDirectories(sAttachFolder);

    loadimages(FldName,RowNo,recid,Imagelist);

    Result := ConvertFileListToBase64(slAttachments);
  except on e:exception do
  begin
    structdef.axprovider.dbm.gf.DoDebug.Msg
      ('Error in GetGridAttach : '+e.Message);
    raise;
  end;
  end;
  structdef.axprovider.dbm.gf.DoDebug.Msg
      ('GetGridAttach ends.');
end;

//SaveBlobFieldToFile
procedure SaveBlobFieldToFile(blobField: TBlobField; const filePath: string);
var
  blobStream: TStream;
  fileStream: TFileStream;
begin
  if not Assigned(blobField) or not blobField.IsBlob then
    Exit;

  // Open the blob field as a stream
  blobStream := blobField.DataSet.CreateBlobStream(blobField, bmRead);
  try
    // Create a new file stream
    fileStream := TFileStream.Create(filePath, fmCreate);
    try
      // Copy the blob stream's content to the file stream
      fileStream.CopyFrom(blobStream, 0);
    finally
      fileStream.Free;
    end;
  finally
    blobStream.Free;
  end;
end;


//GetNonGridImage
Function TDataExchQueue.GetNonGridImage(pImageFieldName : String):TStringList;
var
  sAxpImagePath,sImagePath,sImageFile : String;
  fld : pFld;
  stm : TStringStream;
  findidx,i:integer;
  ImgfilenameFromList,key,value:string;
  fileStream: TFileStream;
  searchstring,sfilename:string;
  startpath:String;

begin
  try
   // RecId:=dbCall.sRecordId;
    Result := nil;
    if Not Assigned(slAttachments) then
      slAttachments := TStringList.Create();
    slAttachments.clear;

    sAttachFolder := structdef.axprovider.dbm.gf.StartPath+'viewimg/';
    ForceDirectories(sAttachFolder);

    sAxpImagePath := parser.GetVarValue('AxpImagePath');
    // GetAxpImgPath;
    if sAxpImagePath <> '' then
      sAxpImagePath := IncludeTrailingBackslash(sAxpImagePath);
    structdef.axprovider.dbm.gf.DoDebug.Msg
      ('GetNonGridImage/ Values of AxpImagePath : ' +
      sAxpImagePath);
    structdef.axprovider.dbm.gf.DoDebug.Msg
      ('GetNonGridImage/ Values of ImageFromDB : ' +
      BoolToStr(structdef.axprovider.dbm.gf.bImageFromDB));
    (*
      if sAxpImagePath = '' then
      sAxpImagePath := Parser.GetVarValue('AxpImageServer');//GetAxpImgServer;
    *)
    //bImageFromDB := True; // to Test
    if (structdef.axprovider.dbm.gf.bImageFromDB) or (sAxpImagePath = '')
    then // read from DB
    begin
      // Read from Image Table
      structdef.axprovider.dbm.gf.DoDebug.Msg
        ('GetNonGridImage/ Loading image from Table ' +
        StoreData.TransType + pImageFieldName + '. Recordid : ' +
        floattostr(RecrId));
      With structdef.axprovider.dbm.GetXds(nil) do
      begin
        buffered := True;
        CDS.CommandText := 'select recordid,img,ftype from ' + StoreData.TransType
          + pImageFieldName + ' where recordid = ' + floattostr(RecrId);
        open;
        if CDS.RecordCount > 0 then
        begin
          stm := TStringStream.create;
          TBlobField(CDS.FieldByName('img')).SaveToStream(stm);
          if assigned(stm) and (stm.Size > 0) then
          begin
            //Convert to Byte64
            //Result := StreamToBase64(stm);
            sImageFile := sAttachFolder+CDS.FieldByName('recordid').AsString+'.'+
                          CDS.FieldByName('ftype').AsString;
            // Create a new file stream
            fileStream := nil;
            try
              fileStream := TFileStream.Create(sImageFile, fmCreate);
              // Copy the blob stream's content to the file stream
              fileStream.CopyFrom(stm, 0);
              slAttachments.Add(sImageFile);
            finally
              if Assigned(fileStream) then
                fileStream.Free;
            end;
          end;

          Free;
        end;
      end;
    end
    else // Read from Path
    begin
    //Newly added
      if StoreData.NewTrans then
      begin
        sImagePath :=structdef.axprovider.dbm.gf.StartPath+'axpert\'+
          structdef.axprovider.dbm.gf.SessionId+'\'+pImageFieldName + '\';
      end
      else
      begin
      sImagePath := sAxpImagePath + StoreData.TransType + '\' +
          pImageFieldName + '\';
      end;
      structdef.axprovider.dbm.gf.DoDebug.Msg
        ('GetNonGridImage/ Loading image from path : ' +
        sImagePath + '. Recordid : ' + floattostr(RecrId));
      if (structdef.axprovider.dbm.gf.sMapUserName <> '')
         and (structdef.axprovider.dbm.gf.sMapPassword <> '') then
      begin
        try
          If Not structdef.axprovider.dbm.gf.IsAccessiblePath(sAxpImagePath) Then
          begin
            Raise Exception.Create('You do not have the access for specified path.');
          end;
          Except on E:Exception do
          begin
           structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uViewImage\loadimages - '+e.Message);
           Raise Exception.Create('There is a problem in network mapping connection.'+#13+'Please try again.');
          end;
        end;
      end;

      //IsAccessibleDir := True;
      if StoreData.NewTrans then
      begin
       fld:=structdef.GetField(pImageFieldName);
       findidx:=-1;
       findidx:=storedata.sdImageList.IndexOfName(pImageFieldName+intTostr(fld.FrameNo));
       ImgfilenameFromList:=storedata.sdImageList.ValueFromIndex[findidx];
       if findidx <>-1 then
        sImageFile :=sImagePath +ImgfilenameFromList;
      end
      else
      begin
      sImageFile := GetFileUsingPattern
        (sImagePath + floattostr(RecrId) + '.*');
      end;
      if FileExists(sImageFile) then
        slAttachments.Add(sImageFile)
      else
        structdef.axprovider.dbm.gf.DoDebug.Msg
      ('File is not exists at '+sImageFile+' location');

//      if sImageFile <> '' then
//        //Convertto byte64
//        //Result := FileToBase64(sImageFile);
//        slAttachments.Add(sImageFile)
    end;
    Result := ConvertFileListToBase64(slAttachments);
  except
  on e: Exception do
    structdef.axprovider.dbm.gf.DoDebug.Msg
      ('GetNonGridImage/ Error while loading image/ ' +
      pImageFieldName + ' : ' + e.Message);
  end;
end;

//ConstructFileJSON
function ConstructFileJSON(files: TStringList): string;//TJSONArray
var
  jsonObject: TJSONObject;
  fileObject: TJSONObject;
  jsonArray: TJSONArray;
  i: Integer;
begin
  jsonObject := TJSONObject.Create;
  if Assigned(files) then
  Begin
    for i := 0 to files.Count - 1 do
    begin
      fileObject := TJSONObject.Create;
      fileObject.AddPair('filename', TJSONString.Create(files.Names[i]));
      fileObject.AddPair('extension', TJSONString.Create(ExtractFileExt(files.Names[i])));
      fileObject.AddPair('fileasbase64', TJSONString.Create(files.ValueFromIndex[i]));

      jsonObject.AddPair('file' + IntToStr(i + 1), fileObject);
    end;
  End;

  jsonArray := TJSONArray.Create;
  jsonArray.Add(jsonObject);

  Result := jsonArray.ToString;
end;

//AddFileToJSONObject
//procedure AddFileToJSONObject(jsonObject: TJSONObject; const filename, base64filedata: string);
//var
//  fileObject: TJSONObject;
//begin
//  fileObject := TJSONObject.Create;
//  fileObject.AddPair('filename', filename);
//  fileObject.AddPair('base64filedata', base64filedata);
//
//  if not Assigned(jsonObject.GetValue('fastprints')) then
//    jsonObject.AddPair('fastprints', TJSONArray.Create);
//
//  jsonObject.GetValue('fastprints').AsArray.Add(fileObject);
//end;

procedure AddFileToJSONObject(jsonObject: TJSONObject; const filename, base64filedata: string);
var
  fileObject: TJSONObject;
  fastprintsArray: TJSONArray;
begin
  fileObject := TJSONObject.Create;
  fileObject.AddPair('filename', TJSONString.Create(filename));
  fileObject.AddPair('base64filedata', TJSONString.Create(base64filedata));

  fastprintsArray := TJSONArray(jsonObject.Get('fastprints'));
  if not Assigned(fastprintsArray) then
  begin
    fastprintsArray := TJSONArray.Create;
    jsonObject.AddPair('fastprints', fastprintsArray);
  end;

  fastprintsArray.Add(fileObject);
end;


//PrepareFastPrint
Procedure TDataExchQueue.PrepareFastPrint(pTransid,pReportName:string;pDataJsonObject : TJsonObject);
var
  Errorstr,sOutputFileName,sFastReportName,sBase64FastPrint:string;
  iIdx,fIdx : Integer;
begin
  try
    fIdx := -1;
    iIdx := 1;
    Errorstr:='';
    sBase64FastPrint := '';
    sFastReportName := '';
    structdef.axprovider.dbm.gf.DoDebug.Msg('PrepareFastPrint starts...');
    try
      if Not Assigned(pDataJsonObject) then
        Exit;
      if Not Assigned(AutoPrint) then
      begin
        AutoPrint := TAutoPrint.Create(structdef);
        //AutoPrint.structdef := structdef;
        AutoPrint.StoreData := StoreData;
        AutoPrint.Parser := Parser;
      end;
      sFastReportName := structdef.axprovider.dbm.gf.GetNthString(pReportName,iIdx);
      while sFastReportName <> '' do
      begin
        fIdx := StoreData.AutoFastPrints.IndexOfName(sFastReportName);
        if fIdx > -1 then
          sOutputFileName := StoreData.AutoFastPrints.ValueFromIndex[fIdx]
        else  //Generate fastprint
          sOutputFileName := AutoPrint.PrepareFastReport(pTransid,sFastReportName);

        if ExtractFilePath(sOutputFileName) = '' then
        begin
          if Lowercase(ExtractFileExt(sOutputFileName)) = '.pdf' then
            sOutputFileName := structdef.axprovider.dbm.gf.startpath+'\pdf\'+sOutputFileName
          else
            sOutputFileName := structdef.axprovider.dbm.gf.startpath+'\'+sOutputFileName;
        end;


        if FileExists(sOutputFileName) then
          sBase64FastPrint := FileToBase64(sOutputFileName)
        else
          structdef.axprovider.dbm.gf.DoDebug.Msg('PrepareFastPrint/ File doesn''t exists. '+sOutputFileName);
        // Add fastprints array with files
        AddFileToJSONObject(pDataJsonObject, sFastReportName, sBase64FastPrint);
        inc(iIdx);
        sFastReportName := structdef.axprovider.dbm.gf.GetNthString(pReportName,iIdx);
      end;
    Except on E:Exception do
    begin
      Errorstr := E.Message;
      structdef.axprovider.dbm.gf.DoDebug.Msg('Error in PrepareFastPrint '+Errorstr);
    end;

    end;
    structdef.axprovider.dbm.gf.DoDebug.Msg('PrepareFastPrint ends.');
  finally

  end;
end;

//ConvertSDtoRapidSaveInputJSON
Function TDataExchQueue.PrepareDataOutJSON(pFieldNames,pFastPrints : String;pbAllFields,pbPrintForms,pbFileAttachments : Boolean):String;
var
  rapidsaveObject : TJSONObject;
  dataObject: TJSONObject;
  dataArray: TJSONObject;
  data1Object: TJSONObject;
  existingpair: TJSONpair;
  dcObject: TJSONObject;
  rowObject: TJSONObject;
  pFieldRec: Pointer; // assuming this is the type of pFieldRec
  FldRec: TFieldRec; // assuming this is the type of FldRec
  findIdx:integer;
  imgfldType,imgfldName: String;

  bIsFirstTime : Boolean;
  NewFrameNo, OldFrameNo, NewRowNo, OldRowNo : Integer;

  sFieldName,sFieldDataType,sBase64FastPrint : String;
  bIsImageField : Boolean;

  slGridAttachments : TStringList;
  Imagelist : TStringList;
begin
  result := '';
  try
  try
  structdef.axprovider.dbm.gf.DoDebug.msg('ConvertSDtoRapidSaveInputJSON starts.');
  slGridAttachments := nil;
  slGridAttachments := TStringList.Create;

  Imagelist := nil;
  Imagelist := TStringList.Create;
  Imagelist.Delimiter := ',';
  Imagelist.StrictDelimiter := true;

  // Initialize the JSON objects
  rapidsaveObject := TJSONObject.Create;
  dataObject := TJSONObject.Create;
  dataArray := TJSONObject.Create;
  data1Object := TJSONObject.Create;

  // Set the common values
  //Modified payload as like submitdata | discussed with sabarish sir
  //We will be using Submitdata for Inbound and Outbound
  dataObject.AddPair('project', structdef.axprovider.dbm.Connection.ConnectionName{ProjectName});
  dataObject.AddPair('username', structdef.axprovider.dbm.gf.Username);
  dataObject.AddPair('trace', '');
  dataObject.AddPair('name', StoreData.transtype);
  dataObject.AddPair('keyfield', primaryfield);
  dataObject.AddPair('primaryfield', primaryfield);

  bIsFirstTime := True;
  OldFrameNo := 0;
  OldRowNo := 0;

  StoreData.FieldList.Sort(SortFieldListSave);

  // Process each field record
  for pFieldRec in StoreData.fieldlist do
  begin
    bIsImageField := False;

    FldRec := TFieldRec(pFieldRec^);
    sFieldName :=  FldRec.FieldName;
    sFieldDataType :=  FldRec.DataType;

    //Check fields
    if pbAllFields then
      //Do nothing
    else
    begin
      if StringExistsInCSV(sFieldName,pFieldNames) then
        //If field exists then proceed further
      else
        continue;//skip
    end;

    NewFrameNo := FldRec.FrameNo;
    NewRowNo := FldRec.RowNo;
    // Check if the FrameNo has changed
    //if FldRec.FrameNo <> data1Object.Size then
    if NewFrameNo <> OldFrameNo then
    begin
      // Create a new dc object
      dcObject := TJSONObject.Create;
      data1Object.AddPair('dc' + IntToStr(FldRec.FrameNo), dcObject);

      OldFrameNo := NewFrameNo;
      OldRowNo := 0;//Reset rowno when new dc starts
    end;

    // Check if the rowno has changed
    //if FldRec.rowno <> dcObject.Size then
    if NewRowNo <> OldRowNo then
    begin
      // Create a new row object
      rowObject := TJSONObject.Create;
      dcObject.AddPair('row' + IntToStr(FldRec.rowno), rowObject);

      OldRowNo :=  NewRowNo;
    end;

    //Check for Nongrid image field
    if (sFieldDataType = 'i') and (pbFileAttachments) then
    begin
      //rowObject.AddPair(sFieldName, GetNonGridImage(sFieldName))
      //'i' type field wont be available in sd fieldlist, it has to be processed throug struct.flds
      slGridAttachments := GetNonGridImage(sFieldName);
      rowObject.AddPair(sFieldName,ConstructFileJSON(slGridAttachments));
    end
    else
    begin
      if (lowercase(sFieldName) = 'dc_'+InttoStr(NewFrameNo)+'_image')
         and (pbFileAttachments) then
      begin
        //Grid attach
        ImageList.Clear;
        Imagelist.CommaText := FldRec.Value;
        slGridAttachments := GetGridAttach(sFieldName,NewRowNo,FldRec.RecordId,Imagelist);
        rowObject.AddPair(sFieldName,ConstructFileJSON(slGridAttachments));
      end
      else
        // Add the fieldname and value pair to the row object
        rowObject.AddPair(sFieldName, FldRec.Value);
    end;


    if bIsFirstTime then
    begin
      // Update the mode and recordid based on the conditions
      if {FldRec.RecordId = 0} StoreData.NewTrans then
      begin
        data1Object.AddPair('mode', 'new');
        data1Object.AddPair('keyvalue', '');
        data1Object.AddPair('recordid', '0');
      end
      else
      begin
        data1Object.AddPair('mode', 'edit');
        data1Object.AddPair('keyvalue', '');
        data1Object.AddPair('recordid', FloattoStr(FldRec.RecordId));
      end;
      bIsFirstTime := False;
    end;
  end;

  //Newly added
  //d imagetype ('i') field data to data1Object

if (pbFileAttachments) and (structdef.HasImage) then
begin
  structdef.axprovider.dbm.gf.DoDebug.Msg('Processing imagetype field...');
  //Note any nogrid dc can have image field which has to be handled here
  //currently we hardcoded 'dc1' , this need to be modified
  existingPair := data1Object.Get('dc1'); // get dc1

  if Assigned(existingPair) and (existingPair.JsonValue is TJSONObject) then
  begin
    // If the pair exists and it's a TJSONObject, assign it to dcObject
    dcObject := TJSONObject(existingPair.JsonValue);
    existingPair := dcObject.Get('row1'); // get row1
    if Assigned(existingPair) and (existingPair.JsonValue is TJSONObject) then
    begin
      // If the pair exists and it's a TJSONObject, assign it to rowObject
      rowObject := TJSONObject(existingPair.JsonValue);
    end;
  end;
  if Assigned(rowObject) then
  begin
  for findIdx := 0 to structdef.ImgFldList.Count - 1 do
  begin
    imgfldType := structdef.ImgFldList.ValueFromIndex[findIdx];
    if imgfldType = 'i' then
    begin
      imgfldName := structdef.ImgFldList.Names[findIdx];
      if imgfldName <> '' then
      begin
        if (pbAllFields) or (StringExistsInCSV(imgfldName,pFieldNames)) then
        begin
          structdef.axprovider.dbm.gf.DoDebug.Msg('Processing imagetype field '+imgfldName);
          // 'i' type field wont be available in sd fieldlist, it has to beprocessed throug struct.flds
          slGridAttachments := GetNonGridImage(imgfldName);
          rowObject.AddPair(imgfldName, ConstructFileJSON(slGridAttachments));
        end;
      end
      else
        continue;
    end;
  end;
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.Msg('rowObject is not assiged.');
  structdef.axprovider.dbm.gf.DoDebug.Msg('Processing imagetype field ends.');
end;
  //AddPrintForms to data1Object
  if (pbPrintForms) and (pFastPrints <> '') then
  begin
    PrepareFastPrint(StoreData.transtype,pFastPrints,data1Object);
  end;

  // Add the data1 object to the data array
  //Since we send only single transaction data we changed keyname from data1 to data
  dataArray.AddPair('data', data1Object);

  // Add the data array to the main data object
  dataObject.AddPair('dataarray', dataArray);

  //Add dataObject to rapidsaveObject
  //We decided to use submit data inbound and ourbound so changed the 
  //Root key name to 'submitdata' from 'rapidsave' - Rapidsave will be used only for import | by RIB
  rapidsaveObject.AddPair('submitdata',dataObject);

  // Convert the data object to JSON string
  Result := rapidsaveObject.ToString;//dataObject.ToString;
  structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ConvertSDtoRapidSaveInputJSON/ result : '+Result);

  Except on E:Exception do
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ConvertSDtoRapidSaveInputJSON/ Error : '+E.Message);
  end;
  finally
    // Free the JSON objects
    //dataObject.Free;
    rapidsaveObject.Free;
    if Assigned(slGridAttachments) then
      FreeAndNil(slGridAttachments);
    if Assigned(Imagelist) then
      FreeAndNil(Imagelist);
  end;
end;



//EvaluateAndProcessPrints
procedure TDataExchQueue.PushFormDataToQueue(pInDataSet : TXDS);
var
  sTransId,sQueueName,sFastPrints,sFieldNames,sRapidSavePayload,primaryfieldvalue : String;
  bAllFields,bPrintForms,bFileAttachments : Boolean;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('PushFormDataToQueue starts...');
  try
     while Not pInDataSet.CDS.Eof do
     begin
       sFastPrints := '';
       sFieldNames := '';

       sTransId := pInDataSet.CDS.FieldByName('stransid').AsString;
       sQueueName := pInDataSet.CDS.FieldByName('axqueuename').AsString;
       primaryfield:= pInDataSet.CDS.FieldByName('primaryfield').AsString;
   //    primaryfieldvalue:=StoreData.GetFieldValue(primaryfield,1);
       structdef.axprovider.dbm.gf.DoDebug.msg('QueueName : '+sQueueName);

       bAllFields := lowercase(pInDataSet.CDS.FieldByName('allfields').AsString) = 't';
       if Not bAllFields then
        sFieldNames :=  pInDataSet.CDS.FieldByName('fieldnames').AsString;
       structdef.axprovider.dbm.gf.DoDebug.msg('AllFields : '+BoolToStr(bAllFields));
       structdef.axprovider.dbm.gf.DoDebug.msg('FieldNames : '+sFieldNames);

       bPrintForms := lowercase(pInDataSet.CDS.FieldByName('printforms').AsString) = 't';
       if bPrintForms then
        sFastPrints := pInDataSet.CDS.FieldByName('fastprints').AsString;
       structdef.axprovider.dbm.gf.DoDebug.msg('FastPrints : '+sFastPrints);

       bFileAttachments := lowercase(pInDataSet.CDS.FieldByName('fileattachments').AsString) = 't';
       structdef.axprovider.dbm.gf.DoDebug.msg('FileAttachments : '+BoolToStr(bFileAttachments));

       sRapidSavePayload := PrepareDataOutJSON(sFieldNames,sFastPrints,bAllFields,bPrintForms,bFileAttachments);
       PushSaveDataToQueue(sQueueName,sRapidSavePayload);
       pInDataSet.CDS.Next;
     end;
  Except
    on E: Exception do
    begin
      structdef.axprovider.dbm.gf.DoDebug.msg('Error in PushFormDataToQueue ' + E.Message);
      raise Exception.Create(E.Message);
    end;
  end;
  structdef.axprovider.dbm.gf.DoDebug.msg('PushFormDataToQueue ends.');
end;



//ProcessDataOut
procedure TDataExchQueue.ProcessDataOut;
var
  x1: Txds;
  whrStr, table, QryStr, OrderByStr : String;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('ProcessDataOut starts...');
  //Init
  Init;

  table := 'axoutqueues';
  whrStr := ' Where lower(active) = ''t'' and stransid = '+QuotedStr(Storedata.TransType)+
            ' and lower(axqueuesource) = ''form'' ';
  OrderByStr := ' order by createdon asc';
  QryStr := 'select * from '+table+' '+whrStr + OrderByStr;
  try
    try
      x1 := nil;
      x1 := structdef.axprovider.dbm.GetXDS(nil);
      x1.buffered := True;
      x1.cds.Commandtext := QryStr;
      structdef.axprovider.dbm.gf.DoDebug.msg('ProcessDataOut SQL Query : '+QryStr);
      x1.open;
      if not x1.isempty then
      begin
        PushFormDataToQueue(x1);
      end;
    Except
      on E: Exception do
        structdef.axprovider.dbm.gf.DoDebug.msg('Error in ProcessDataOut ' + E.Message);
    end;
  finally
    if Assigned(x1) then
    begin
      x1.free;
      x1 := nil;
    end;
  end;
  structdef.axprovider.dbm.gf.DoDebug.msg('ProcessDataOut ends.');
end;


//PushSaveDataToQueue
Procedure TDataExchQueue.PushSaveDataToQueue(sQueueName,sAPIPayload: String);
var
  PublishToRMQ : TPublishToRMQ;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('PushSaveDataToQueue starts...');
  try
    PublishToRMQ := nil;
    try
      PublishToRMQ := TPublishToRMQ.create(structdef);
      PublishToRMQ.bIsPEGV2 := True;
      PublishToRMQ.Parser := Parser;
      PublishToRMQ.SDEvaluateExpr := nil;
      if Assigned(Parser) then
      begin
        //Variables return var name when its not found/empty it has to be handled.
        PublishToRMQ.sRMQ_APIURL := Parser.GetVarValue('AxRMQAPIURL');
        PublishToRMQ.sScripts_APIURL := Parser.GetVarValue('AxRapidSaveURL');
        PublishToRMQ.sNotifyQueueName := sQueueName;
      end;
      PublishToRMQ.jsonPayloadRequest := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(sAPIPayload),
          0) as TJSONObject;
      PublishToRMQ.bScriptJobs := False;
      PublishToRMQ.PushMessageToRMQ(sAPIPayload,'0');
    Except on E:Exception do
    begin
      structdef.axprovider.dbm.gf.DoDebug.msg('Error in PushSaveDataToQueue : '+E.Message);
    end;
    end;
  finally
    if Assigned(PublishToRMQ) then
      FreeAndNil(PublishToRMQ);
  end;
  structdef.axprovider.dbm.gf.DoDebug.msg('PushSaveDataToQueue ends.');
end;

end.
