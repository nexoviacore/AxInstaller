unit uDbCall;
{Copied from Axpert9-XE3\Ver 11.2}
interface

uses uStoreData, uGeneralFunctions, uValidate, uMDMap, uprovidelink, uProfitEval,
Db, Classes, SysUtils, Dialogs, Forms, uDBManager,Variants, IdGlobal,{uDataExchQueue,}
uXDS, uConnect, uStructDef, uAxProvider,XMLDoc , XMLIntf, uDoDebug,uDoCoreAction,uTreeObj,
uWorkFlowRuntime,uCompress,DateUtils, uFillStruct, uFormNotifications;

Type
  TSaveImages = procedure() of object;
  TSaveAttach = procedure() of object;
  TLoadSDValue = procedure(dnode: ixmlnode; sd: TStoreData) of object;
  TSaveTrans = function():String of object;
  TDbCall = class
  private
    WorkQuery : TXDS;
    FrameNames, fTransid, fCaption : String;
    poststr,maxrows : TStringList;
    EventList: TList;
    ActNode,ScriptNode : ixmlnode;
    AxpAttPath,AxpImgPath : String;
    MainValidate : TValidate;
    BreakOnError : Boolean;
    sHTMLPageNo , sHTMLPageCaption : String;

    procedure SetCaption(s: String);
    procedure SetTransid(s: String);
    Procedure CloseRefreshQueries;
    procedure GetTlines;
    procedure AssignParamTypes(Q: TXDS);
    function GetFieldType(fname: String): String;
    function ReplaceDynamicparams(SQLText: String): String;
    procedure ReplaceParams(Query: TXDS);
    function GetNextRow(f: String): integer;
    procedure ExecuteFillGrid(frmno:integer);
    procedure CreateEventList;
    function ExecuteAction(Event, Element: String) : String ;
    procedure CopyRecordValue(frec, trec: pFieldRec);
    procedure SaveAttachments;
    function GetSubDelimitedStr(DetFldName, Delimiter, Quoted: String;
      ParentRowNo: integer): String;
    function GetSubTotal(DetFldName: String; ParentRowNo: integer): Extended;
    function FormatNumericData(fld1: pfld; txt: String): String;
    function GetSubValue(FieldName: String; RowNo,
      ParentRowNo: integer): String;
    function GetSubRow(FieldName, FieldValue: String;
      ParentRowNo: integer): Integer;
    function SQLPost(SQLText, Target, GroupField, PrimaryField: String;SQLName:String=''): String;
    function ReSaveData: String;
    procedure WorkFlowAction;
    procedure AutoGenToDB;
    function SaveDataRows : TStringList;
    procedure RestoreDataRows(RowList: TStringList);
    procedure FillWithGroupField(fg: pFg; rcount: integer);
    procedure BeforeEventProc(RecValidate: TValidate);
    procedure AfterEventProc;
    procedure OnFill(xmlStr: String);
    procedure FillOnLoad(SQLText: String);
    procedure ValidateImageFlds;
    procedure StoreImageData;
    function GetChildNodeValue(mnode: IXMLNode; mname: string): string;
    procedure PrepareExps;
    procedure DoFillGridRefreshNew(fm : pFrm);
    procedure FillValuesNew(fg: pFg; SQLText, MapString, groupfld: String;
      sframe , tframe, rno : integer);
    procedure DeleteDataFromAppDB(Transid: AnsiString;Recid:Extended;TargetConnectionName:AnsiString='');
    procedure SaveDataToAppDB(Transid : AnsiString;Recid: Extended;TargetConnectionName:AnsiString='');
    function CreateAndSaveAppVars(act,vpname : ansistring) : Boolean;
    procedure UpdateAxpagesTableForHTMLPages(sEditType : String;bRefreshFieldValue:Boolean;targetDBM : TDBManager = nil);
    function CreateAndSaveAppProps: Boolean;
    procedure ProcessRMQMessages;
    function SDEvaluateExpr(sExpression: String): String;
    procedure SDRegVarToParser(pVarname, pVarDType, pVarValue: String);
    procedure ProcessAutoPrints;
    procedure ProcessDataExch(pStruct:TStructDef;pStoreData : TStoreData;pParser : TProfitEval);
    procedure ProcessFormNotifications(pDataMode: String);

  public
    sRecordID:extended;
    GridDependentFields,DependentFgs :String;
    attachments : String;
    struct : TStructDef;
    Dbm : TDbManager;
    StoreData : TStoreData;
    MDMap : TMDMap;
    ProvideLink : TProvideLink;
    Parser : TProfitEval;
    Validate : TValidate;
    ErrorStr, TransDetails : String;
    ErrorDisplay : String;
//    ProfitDb : TDatabase;
    axprovider : TAxProvider;
    ClearFields : Boolean;
    OptionName: String;
    WorkFlow : TWorkFlowRunTime;
    //DataExchange:TDataExchQueue;

    GenMapIds, TLines, NewMaxRows : TStringList;
    ExcludeMapIds : String;
    TableNames : String;
    AutoGenString : String;

    LastSavedId: extended;
    TreeObj : TTreeObj;
    attNode,imgNode : ixmlnode;
    SaveImages : TSaveImages;
    SaveAttach : TSaveAttach;
    ApprovalNode : ixmlnode;
    DetailData : TList;
    MasterRecord,SecondaryRecord:Extended;
    SecRecList : TStringList;
    LoadSDValue : TLoadSDValue;
    LastRowNo : Integer;
    sxml : IXMLDocument;
    fillgrid_targetdc : String;
    DoFillRefresh,RefreshInLoadDc : Boolean;
    fnames : TStringList;
    starttime : TDateTime;
    CallWorkFlowApproval,dataval : Boolean;
    SaveTrans : TSaveTrans;
    act : TDoCoreAction;
    ParentList,ActualRows : TStringList;
    FromSync : Boolean;
    CallFromSaveDataInWFAction : Boolean;
    cmdnode, sqlpostkeyfld : String;
    XMLData : IXMLDocument;
    RecordLocked : boolean; //ch1
    activerow,fg_record_count : integer;
    act_fgname , VisibleDCs : string;
    dc_image_fillgrid , imagesavetodb : boolean;
    WorkFlowProcessed : Boolean;
    bCallFromImport , EventActs : Boolean;
    FormNotify : TFormNotifications;
  //  DataExchQueue:TDataExchQueue;

    constructor create;
    destructor destroy; override;
    procedure CreateObjects; overload ;
    Procedure CreateObjects(act,transid : AnsiString; fldlist,visibleDCs,fglist,fillgriddc : string);  overload ;
    function SaveData:String;
    procedure DeleteData(ModifyRecordId: Extended);
    procedure CancelTransaction(ModifyRecordId: Extended;Rem:String);
    procedure DataValidate(context: String; DoValidation: Boolean);
    procedure DoEvalExprSet(CompName, EventName: String);
    procedure LoadData(ModifyRecordId: Extended);
    function ValidateAndSave:String;
    procedure ValidateAndMap;
    procedure Clear;
    procedure MapData;
    procedure MakeDetailStr;
    function IsFound(SearchField: String) : Boolean;
    function GetRecordId(SearchField, SearchValue, FieldTypes: String): extended;overload ;
    function GetRecordId(FieldName, FieldValue :String) : extended; overload ;
//    function PostString(s: String):String;
    function IsRecFound(RecId: Extended): boolean;
    procedure SubmitValue(FieldName: String; Value, OldValue: String; IdValue, OldIdValue, Recordid: extended);
    function PostXML(filename, wtransid: String): String;
    procedure CreateMapObjects;
    procedure SaveDetailStructs(mnode:ixmlnode);
    procedure DetailAddRow;
    procedure StoreDataToFList(RowNo: Integer);
    procedure FListToStoreData(Rowno: Integer);
    procedure SetRecordid(RowNo: Integer; Recid: Extended);
    function ValidateData: String;
    function ValidateFrame(fno: integer): String;
    procedure DoFillGridRefresh(fno: integer);
    procedure Createpkt(q: txds; pktfile: String);

    property caption : String read fcaption write setcaption;
    property transid : String read ftransid write settransid;
    procedure SaveHistory(DeletedTrans,DetailStruct : Boolean;ParentTrackList : TStringlist);
    procedure SaveHistoryTable(DeletedTrans: Boolean);
    procedure InitGrid(FrameNo: integer);
    procedure DoFillgrid(aname: String);
    procedure FillValues(SQLText, MapString, groupfld: String; sframe : integer);
    function ExecuteEventAction(Event, Element: String): String;
    procedure CopyTrans(pRecordId: Extended);
    procedure TrimExtraRows;
    function GetActualRows(popindex: integer; PList: TStringList): String;
    procedure GetParentValue(popindex, rowno: integer; sList: TStrings);
    procedure NewTrans;
    procedure CancelData(ModifyRecordId: Extended;Rem:String);
    procedure FillGrid(fg: pFg);
    function DoPopup(FrameNo, RowNo: Integer):boolean;
    procedure RefreshGridDependents(fm: pFrm);
    function RefreshField(FldName: String; RowNo: Integer) : String;
    procedure DoMultiSelectFillGrid(fg: pFg; xnode: ixmlnode);
    function PopAtThisField(fd:pFld): Integer;
    procedure RefreshFrame(FrmNo: Integer);
    procedure RegWFFields;
    function EnableApprovalBar(ModifyRecordId: Extended):Boolean;
    procedure LoadDataForWeb(ModifyRecordId: Extended);
    procedure RefreshGridRowDependents(fm: pFrm; fd: pFld);
    procedure createcmdnode(cmd, val: string);
//    function CreateFldListByOrder(fldlist: String): String;
  end;

implementation
Uses uImport,uAutoPrint,uDataExchQueue,StrUtils;

constructor TDbCall.Create;
begin
  inherited;
  WorkQuery:=nil;
  Storedata := nil;
  Mdmap := nil;
  ProvideLink := nil;
  GenMapIds := nil;
  ExcludeMapIds := '';
  Parser := nil;
  poststr:=nil;
  maxrows := nil;
  fnames := nil;
  newmaxrows := nil;
  tlines := nil;
  EventList := nil;
  DetailData := nil;
  SecRecList := nil;
  ParentList := nil;
  ActualRows := nil;
  maxrows := TStringList.create;
  fnames:=tstringlist.Create;
  newmaxrows:=TStringList.create;
  tlines := TStringList.create;
  struct:=nil;
  EventList := TList.create;
  ClearFields := True;
  attNode := nil;
  imgNode := nil;
  ApprovalNode := nil;
  FormNotify := nil;
  DetailData := TList.Create;
  SecRecList := TStringList.Create;
  Attachments:='';
  sxml := nil;
  ParentList := TStringList.Create;
  ActualRows := TStringList.Create;
  fillgrid_targetdc := '';
  DoFillRefresh := false;
  RefreshInLoadDc := false;
  dataval := true;
  FromSync := False;
  GridDependentFields:='';
  DependentFgs:=',';
  CallFromSaveDataInWFAction := False;
  RecordLocked := false;
  cmdnode := '{"command":[';
  XMLData := nil;
  sqlpostkeyfld := '';
  activerow := -1;
  fg_record_count := -1;
  act_fgname := '';
  BreakOnError := False;
  dc_image_fillgrid := false;
  WorkFlowProcessed := False;
  imagesavetodb := false;
  VisibleDCs := '';
  ScriptNode := nil;
  bCallFromImport := False;
  EventActs := False;
end;

destructor TDbCall.Destroy;
var i,j:integer;
begin
  //Freeing form notification
  if Assigned(FormNotify) then
    FreeAndNil(FormNotify);
  dbm.gf.dodebug.Msg('Freeing Store data');
  If Assigned(StoreData) Then StoreData.Destroy; StoreData := nil;
  dbm.gf.dodebug.Msg('Freeing DD Map');
  if assigned(MDMap) then MDMap.Destroy; MDMap := nil;
  dbm.gf.dodebug.Msg('Freeing Provide Link');
  If assigned(ProvideLink) Then ProvideLink.Destroy; ProvideLink := nil;
  dbm.gf.dodebug.Msg('Freeing Validate');
  if assigned(validate) then validate.destroy;validate:=nil;
  dbm.gf.dodebug.Msg('Freeing Parser');
  if assigned(parser) then parser.destroy;parser:=nil;
  dbm.gf.dodebug.Msg('Freeing Poststr');
  if assigned(poststr) then
  begin
    poststr.Clear;
    poststr.Free;
  end;
  dbm.gf.dodebug.Msg('Freeing Maxrows');
  if Assigned(Maxrows) then
  begin
    Maxrows.Clear;
    Maxrows.free;
    Maxrows := nil;
  end;
  dbm.gf.dodebug.Msg('Freeing Fnames');
  if Assigned(fnames) then
  begin
    fnames.clear;
    fnames.free;
    fnames := nil;
  end;
  dbm.gf.dodebug.Msg('Freeing NewMaxRows');
  if Assigned(NewMaxRows) then
  begin
    NewMaxRows.clear;
    NewMaxRows.free;
    NewMaxRows := nil;
  end;
  dbm.gf.dodebug.Msg('Freeing tlines');
  if Assigned(tlines) then
  begin
    tlines.clear;
    tlines.free;
    tlines := nil;
  end;
  dbm.gf.dodebug.Msg('Freeing workquery');
  if assigned(workquery) then workquery.destroy;
  dbm.gf.dodebug.Msg('Freeing Struct');
  if assigned(struct) then struct.Destroy;
  dbm.gf.dodebug.Msg('Freeing EventList');
  for i := 0 to EventList.Count-1 do
    Dispose(pEventRec(EventList[i]));
  EventList.Destroy;
  ActNode := nil;
  ScriptNode := nil;
  dbm.gf.dodebug.Msg('Freeing Tree Obj');
  if assigned(TreeObj) then TreeoBj.Free;
  dbm.gf.dodebug.Msg('Freeing Workflow Obj');
  if assigned(WorkFlow) then
  begin

    WorkFlow.destroy;
    WorkFlow := nil;
    dbm.gf.dodebug.Msg('Done - Workflow Obj');
  end;
  if assigned(SecRecList) then
  begin
    SecRecList.Clear;
    SecRecList.Free;
    SecRecList := nil;
  end;
  if assigned(DetailData) then begin
    for i := 0 to DetailData.Count-1 do begin
      for j := 0 to pDetailRec(DetailData[i]).FList.Count - 1 do
        Dispose(pFieldRec(pDetailRec(DetailData[i]).FList[j]));
      pDetailRec(DetailData[i]).FList.Free;
      pDetailRec(DetailData[i]).FList := nil;
      Dispose(pDetailRec(DetailData[i]));
    end;
    DetailData.Free;
    DetailData:=nil;
  end;
  if assigned(ParentList) then
  begin
    ParentList.Clear;
    ParentList.Free;
    ParentList := nil;
  end;
  if assigned(ActualRows) then
  begin
    ActualRows.Clear;
    ActualRows.Free;
    ActualRows := nil;
  end;
  dbm.gf.dodebug.Msg('Freeing DbCall Completed');
  inherited;
end;

Procedure TDbCall.CreateObjects;
Var  s : String;
Begin
  Parser := TProfitEval.Create(axprovider);
  Parser.WorkOnStoreData := true;
  Parser.RegisterVar('recordid','n','0');
  Parser.RegisterVar('username', 'c', dbm.gf.username);
  Parser.OnInitGrid := InitGrid;
  Parser.OnDoFillGrid := dofillgrid;
  Parser.OnCopyTrans := CopyTrans;
  Parser.OnNewTrans := newtrans;
  Parser.OnRefreshFrame := RefreshFrame;
  if sxml = nil then
     Struct := TStructDef.create(axprovider, transid, '','')
  else
     Struct := TStructDef.create(axprovider, transid, '','',sxml)  ;
  StoreData := TStoreData.Create(struct, transid);
  storedata.trackchanges := struct.track;
  storedata.TrackFieldsList := struct.TrackFieldsList;
  StoreData.ControlField := struct.savecontrol;
  StoreData.DeleteControl := struct.delcontrol;
  storedata.OptionName := OptionName;
  StoreData.UserName := parser.getvarvalue('UserName');
  storedata.PrimaryTableName:=struct.PrimaryTable;
  StoreData.CompanyName := struct.SchemaName;
  StoreData.ImgPath := dbm.gf.startpath+'\';
  Parser.RegisterVar('ApprovalNo', 'n',IntToStr(StoreData.ApprovalNo));
  Storedata.SiteNo := dbm.gf.SiteNo;
  Parser.StoreData := StoreData;
  Parser.OnFillOnLoad := FillOnLoad;

  Validate := TValidate.Create(axprovider);
  Validate.Parser.Destroy;
  Validate.freeparser := false;
  Validate.Parser := Parser;
  Validate.Parser.OnSetSequnce := Validate.ChangeSequence;
  Validate.parser.OnFireSQL:=Validate.OnFireSQL;
  Validate.parser.onSQLGet:=Validate.SQLGETValue;
  Validate.parser.OnFindRecord:=Validate.OnFindRecord;
  Validate.StoreData := StoreData;
  Validate.StoreData.RefreshAutoGen := Validate.RefreshAutoGen;
  Validate.sdef := Struct;
  Validate.ExecuteFillGrid := ExecuteFillGrid;
  Validate.Parser.OnGetSubTotal := GetSubTotal;
  Validate.Parser.OnGetSubDelimitedStr := GetSubDelimitedStr;
  Validate.Parser.OnGetSubValue := GetSubValue;
  Validate.Parser.OnGetSubRow := GetSubRow;
  Validate.Parser.OnInitGrid := InitGrid;
  Validate.Parser.OnDoFillGrid := dofillgrid;
  Validate.parser.OnRefreshField:=RefreshField;
  Validate.parser.OnNewTrans:=NewTrans;
  MainValidate := Validate;
  PrepareExps;
  {
  MDMap := TMDMap.Create;
  MDMap.LoadDef(Struct);
  StoreData.MDMap := MDMap;

  ProvideLink := TProvideLink.Create(struct) ;
  ProvideLink.ParentStoreData := StoreData;
  ProvideLink.SelectedList := GenMapids;
  ProvideLink.ExcludeMapIds := ExcludeMapids;
  ProvideLink.ShowSubForm := ','+lowercase(Parser.GetVarValue('showsubform'))+',';

  for i:=0 to ProvideLink.StoreDataList.count-1 do begin
    sdrec := pStoreDataRec(ProvideLink.StoreDataList[i]);

    flag := false;
    for j :=0 to i-1 do begin
      if pStoreDataRec(ProvideLink.StoreDataList[j]).targettransid = sdrec.targettransid then begin
        sdrec.storedata.mdmap := pStoreDataRec(ProvideLink.StoreDataList[j]).storedata.mdmap;
        flag := true;
        break;
      end;
    end;
    if flag then continue;
    MDMap.LoadDef(sdrec.Struct);
    sdrec.StoreData.MDMap := MDMap;
  end;
  }
  mdmap := nil;
  providelink := nil;
  FrameNames := struct.framenames;
  TableNames := struct.tables;
  CreateEventList;
  if struct.tree<>''  then begin
    TreeObj := TTreeObj.create;
    TreeObj.TreeTable := struct.tree+'tree';
    TreeObj.TreeLink := struct.tree+'treelink';
    TreeObj.axp := axprovider;
    TreeObj.DBM := axprovider.dbm
  end;
  WorkFlow := TWorkFlowRunTime.create(Axprovider);
  WorkFlow.WorkFlowAction := WorkFlowAction;
  workFlow.Parser := Parser;
  if struct.HasWorkFlow then
    WorkFlow.transid := ftransid  ;
  Storedata.HasWorkFlow:=WorkFlow.Active;
  WorkFlow.Schema := storedata.CompanyName;
  AxpImgPath := Parser.GetVarValue('AxpImagePath');
  AxpAttPath := Parser.GetVarValue('AxpAttachmentPath');
  Storedata.AxpImagePath := AxpImgPath;
End;

procedure TDBCall.CreateMapObjects;
  var   i,j: integer;
  sdrec : pStoreDataRec;
  flag : boolean;
begin
  if assigned(mdmap) then exit;
  MDMap := TMDMap.Create;
  MDMap.LoadDef(Struct);
  StoreData.MDMap := MDMap;
  mdmap.workflow :='';
  mdmap.SetInitOld := True;
  mdMap.HasWorkflow := workflow.active;

  ProvideLink := TProvideLink.Create(struct) ;
  ProvideLink.ParentStoreData := StoreData;
  ProvideLink.SelectedList := GenMapids;
  ProvideLink.ExcludeMapIds := ExcludeMapids;
  ProvideLink.SqlPost := SQLPost ;
  ProvideLink.BeforeEventProc := BeforeEventProc;
  ProvideLink.AfterEventProc := AfterEventProc;
  ProvideLink.ProcessDataExch := ProcessDataExch;
  ProvideLink.ShowSubForm := ','+lowercase(Parser.GetVarValue('showsubform'))+',';
  if not workflow.active then providelink.workflow:='approve';

  for i:=0 to ProvideLink.StoreDataList.count-1 do begin
    sdrec := pStoreDataRec(ProvideLink.StoreDataList[i]);

    flag := false;
    for j :=0 to i-1 do begin
      if pStoreDataRec(ProvideLink.StoreDataList[j]).targettransid = sdrec.targettransid then begin
        sdrec.storedata.mdmap := pStoreDataRec(ProvideLink.StoreDataList[j]).storedata.mdmap;
        flag := true;
        break;
      end;
    end;
    if flag then continue;
    MDMap.LoadDef(sdrec.Struct);
    sdrec.StoreData.MDMap := MDMap;
  end;
end;

procedure TDbCall.MakeDetailStr;
var i:integer;
    s,v:String;
    fld : pfld;
begin
  TransDetails := '';
  if errordisplay <> '' then begin
    i:=1;
    errordisplay:=lowercase(errordisplay);
    while true do begin
      s := dbm.gf.getnthstring(errordisplay, i);
      if s='' then break;
      if s='transid' then v := transid else v:=storedata.getfieldvalue(s, 1);
      TransDetails := TransDetails+s+'='+quotedstr(v)+', ';
      inc(i);
    end;
    if TransDetails <> '' then begin
      Delete(TransDetails, length(transdetails)-1, 2);
      TransDetails := '>>'+TransDetails;
    end;
  end else begin
    for i:=0 to struct.flds.count-1 do begin
      fld := pfld(struct.flds[i]);
      if (fld.frameno=1) and (not fld.hidden) then
          TransDetails := TransDetails + fld.FieldName +' = '+storedata.GetFieldValue(fld.FieldName, 1)+'  ';
    end;
  end;
  GetTLines;
end;

procedure TDbCall.ValidateAndMap;
begin
  TransDetails := '';
  ErrorStr := '';
  DataValidate('s', true);
  if errorstr <> '' then begin
    MakeDetailStr;
    clear;
    exit;
  end;
  MapData;
end;

function TDbCall.ValidateAndSave:String;
var
  v : string;
begin
  TransDetails := '';
  ErrorStr := '';
  result := '';
//  ExecuteFillGrid;
  TrimExtraRows;
  DataValidate('s', true);
  if errorstr <> '' then begin
    result:=errorstr;
    dbm.gf.dodebug.Msg('Validate error msg : ' + result);
    MakeDetailStr;
    dbm.gf.dodebug.Msg('Validate error msg1 : ' + result);
    v := StoreData.GetFieldValue(sqlpostkeyfld, 1);
    clear;
    dbm.gf.dodebug.Msg('Validate error msg2 : ' + result);
    sqlpostkeyfld := 'key field : ' + sqlpostkeyfld + ' = '+ v;
    exit;
  end;
  dbm.gf.DoDebug.msg('Time elapsed for validate = '+inttostr(millisecondsbetween(now(),starttime)));
  result:=SaveData;
  dbm.gf.DoDebug.msg('Time elapsed for Save = '+inttostr(millisecondsbetween(now(),starttime)));
end;

function TDbCall.SaveData:String;
var cnt,i,j,k : integer;
    status,displayfield:String;
   //Tree Variables
    pName,pfield,gori,tlevel,ptable,trid : String;
    Treeid,PTreeid,recid : extended;
    tempptreeid : String;                       //It is declared on 01-08-08 for holding the tree Treeparentid to check null value.
    fld : pfld;
    spath,s,displayfldCap,displayfldVal : String;
    cFlag, Reapprove, bDoWorkFlowProcess : Boolean;
Begin
  result:='';
//  TrimExtraRows;
  CreateMapObjects;
//  result := ExecuteAction('Before save transaction','');
  WorkFlowProcessed := False;
  if dbm.gf.timezone_diff = 0 then
  begin
    s := Parser.GetVarValue('axp_timezone');
    dbm.gf.DoDebug.msg('time zone difference '+' = '+ s);
    if s <> '' then
       StoreData.timezone_diff := strtofloat(s)
    else StoreData.timezone_diff := 0;
  end;
  if (assigned(ProvideLink)) and (providelink.StoreDataList.Count>0) then inc(dbm.gf.TransCheckCount);
  ExecuteEventAction('Before save transaction','');
  dbm.gf.ClearAutoGenData(False);
  dbm.gf.AutoMemNo := 1;
  //Execute only when the call is from import | Later it can be generalized
  if bCallFromImport then
  begin
    StoreData.SDEvaluateExpr := SDEvaluateExpr;
    StoreData.SDRegVarToParser := SDRegVarToParser;
    StoreData.Object_ASBDataObj := nil;
    StoreData.ParserObject := Parser;
  end;
  StoreData.StoreTrans;
  WorkFlow.Parser := Parser;
  dbm.gf.DoDebug.msg('Time elapsed for insert/update = '+inttostr(millisecondsbetween(now(),starttime)));
  CallWorkFlowApproval := False;
  ReApprove := False;
  bDoWorkFlowProcess := False;
  if (not StoreData.NewTrans) and (workflow.Active) then
  begin
    bDoWorkFlowProcess := workflow.DoWorkflowProcess(struct.Transid,StoreData.PrimaryTableName,FloatToStr(storedata.LastSavedRecordId));
    if workflow.Wwkid <> '' then
    begin
      workflow.CheckOptionsAfterApproval(struct.Transid,workflow.Wwkid);
      if (Workflow.AllowReApprove) and (lowercase(workflow.AppStatus) = 'approved') then
        Reapprove := Workflow.ResetWorkFlowProcess(StoreData.PrimaryTableName,struct.Transid,FloatToStr(storedata.LastSavedRecordId));
    end;
  end;
  if (not CallFromSaveDataInWFAction) and ((StoreData.NewTrans) or (bDoWorkFlowProcess) or (Reapprove))  then  begin
    WorkFlow.Parser.OnSaveTrans := WorkFlow.SaveTrans;
    RegWFFields;  // Register Workflow Fields Procedure Calling
    WorkFlow.UpdatePrimaryTable(struct.Transid,struct.PrimaryTable,FloatToStr(storedata.LastSavedRecordId));
    WorkFlow.Parser.OnSaveTrans := SaveTrans;
    WorkFlowProcessed := True;
    if ((lowercase(workflow.AppStatus) = 'approved') or (lowercase(workflow.AppStatus) = 'approve')) and (workflow.ToBeSaved) then
      CallWorkFlowApproval := True;
  end;
  if lowercase(WorkFlow.AppStatus) = 'approved' then begin
     ProvideLink.WorkFlow := 'approve';
     MDMap.WorkFlow:='approve';
     MDMap.SubmitOnApprove(StoreData.TransType, false);
  end else if lowercase(WorkFlow.AppStatus) = 'rejected' then begin
     ProvideLink.workflow := 'reject';
     MDMap.WorkFlow:='reject';
     MDMap.SubmitOnApprove(StoreData.TransType, false);
  end;
  if not StoreData.AxDataAmended then
  begin
    ProvideLink.Modify := not StoreData.NewTrans;
    ProvideLink.SaveLinkTrans(StoreData.LastSavedRecordid);
    dbm.gf.DoDebug.msg('Time elapsed for Gen Map = '+inttostr(millisecondsbetween(now(),starttime)));
    MDMap.DoUpdate;
    dbm.gf.DoDebug.msg('Time elapsed for MD Map = '+inttostr(millisecondsbetween(now(),starttime)));
  end;
//  if StoreData.NewTrans then
  if dbm.gf.PostAutoGen then
    AutoGenToDB;
  if not StoreData.AxDataAmended then DoEvalExprSet('', 'aftersave');
  if dbm.Connection.dbType<>'mysql' then
  begin
    cflag := axprovider.dbm.InTransaction;
    dbm.gf.DoDebug.msg('uDBCall\SaveData\ checking InTransaction...');
    if not cflag then
    begin
       dbm.gf.DoDebug.msg('uDBCall\SaveData\ InTransaction - False .');
       dbm.gf.DoDebug.msg('uDBCall\SaveData\ Database connection lost. Please resave the transaction.');
       dbm.gf.Db_Conn_Lost := true;
       raise EDatabaseerror.create('Error in posting data. Please resave the transaction.');
    end;
  end;
  status := parser.getvarvalue('aftersavestatus');
  if status <> '' then begin
    if status[1] = '_' then result:=copy(status, 2, length(status))
    else if lowercase(status) <> 't' then raise EDataBaseError.create(status);
  end;
  if (struct.tree <>'') and (storedata.NewTrans)  then begin
      trid := storedata.TransType;
      pfield := struct.primaryfield;
      ptable := struct.PrimaryTable;
//      pTreeid := strtofloat(storedata.GetFieldValue('treeparentid',1))
      tempptreeid := storedata.GetFieldValue('treeparentid',1);
      if tempptreeid <> '' then
        pTreeid := strtofloat(tempptreeid)
      else
        pTreeid:= 0;
      treeid := dbm.Gen_id(dbm.Connection);
      pName := storedata.GetFieldValue(pfield,1);
      recid := storedata.LastSavedRecordId;
      if TreeObj.duplicate(pname,ptreeid) then
        Raise Exception.Create('Unable to Create Node');
      TreeObj.TreeAdd(pName ,'i',trid,ptable,pfield ,PTreeid,Treeid,recid);
  end;
  if not StoreData.AxDataAmended then
  begin
    SaveHistory(false,false,nil); // Storing History Details to History Table
    SaveHistoryTable(false);
    dbm.gf.DoDebug.msg('Time elapsed for Save History = '+inttostr(millisecondsbetween(now(),starttime)));
  end;
  LastSavedId := StoreData.LastSavedRecordId ;

  Parser.RegisterVar('recordid','n',FloatToStr(LastSavedId));
  AutoGenString := '';
  displayfield:=parser.getvarvalue('displayfieldname');
  if displayfield<>'' then
  begin
    result := storedata.GetFieldValue(displayfield, 1);
    displayfldVal := result;
    fld := struct.GetField(displayfield);
    if assigned(fld) then
       displayfldCap := fld.Caption;
    AutoGenString := AutoGenString+displayfldCap+'-'+displayfldVal
  end else
  begin
    for i := 0 to struct.flds.Count - 1 do begin
      fld := pfld(struct.flds[i]);
      if fld.ModeofEntry = 'autogenerate' then
      begin
          AutoGenString := AutoGenString+fld.Caption+'-'+Storedata.GetFieldValue(fld.FieldName,1)+',';
      end;
    end;
    Delete(AutoGenString,Length(AutoGenString),1)
  end;
  if not StoreData.AxDataAmended then
  begin
    if assigned(attNode) then
      SaveAttach
    else
      SaveAttachments;
    if assigned(imgNode) then
      SaveImages;
    if struct.HasImage then
      StoreImageData;
    dbm.gf.DoDebug.msg('Time elapsed for Save Attachment = '+inttostr(millisecondsbetween(now(),starttime)));
  end;

  if not StoreData.AxDataAmended then
  begin
    if (assigned(ProvideLink)) and (providelink.StoreDataList.Count>0) then
    begin
      cflag := AxProvider.ValidateTransCheck;
      dbm.gf.DoDebug.msg('uDBCall\SaveData\ checking ValidateTransCheck.');
      if not cflag then
      begin
        dbm.gf.DoDebug.msg('uDBCall\SaveData\ ValidateTransCheck - False .');
        dbm.gf.DoDebug.msg('uDBCall\SaveData\ Database connection lost. Please resave the transaction.');
        dbm.gf.Db_Conn_Lost := true;
        raise Exception.Create('Error in posting data. Please resave the transaction.');
      end;
    end;
  end;

  if not StoreData.AxDataAmended then ExecuteEventAction('After save transaction','');
  StoreData.EndSave;
  if (CallWorkFlowApproval) or (WorkFlowProcessed and workflow.chkmailcont) then
    Storedata.SetRecid(recid);
  dbm.gf.DoDebug.msg('Time elapsed for After Save WF Exec = '+inttostr(millisecondsbetween(now(),starttime)));
  //Execute only when the call is from import | Later it can be generalized
  if bCallFromImport then
     ProcessRMQMessages;

  ProcessAutoPrints;
  ProcessDataExch(Struct,StoreData,Parser);
  ProcessFormNotifications(ifthen(StoreData.NewTrans,'n','e'));
  //  result := result + ExecuteAction('After save transaction','');
  if (ClearFields) and (not CallWorkFlowApproval)
     and (not(WorkFlowProcessed and workflow.chkmailcont)) then
    Storedata.ClearFieldList;
  MDMap.cleardatalist;
  CloseRefreshQueries;
  if assigned(dbm.gf.WebAppConXML) and ((dbm.gf.actionName = 'isave') or
     ((dbm.gf.actionName = 'nextclk') and (struct.Transid = 'ad_i'))) then SaveDataToAppDB(struct.Transid,LastSavedId)
  else if (dbm.gf.actionName = 'usave') and (struct.Transid = 'ad_pr') then
  begin
    if CreateAndSaveAppProps then
    begin
       dbm.gf.dodebug.Msg('Updating Axprops in App Schema...');
       AxProvider.SetStructure('axprops', 'app', '', dbm.gf.AppXML);
       dbm.gf.dodebug.Msg('Updating Axprops in App Schema done...');
    end;
  end;
End;

procedure TDbCall.MapData;
begin
  CreateMapObjects;
  ProvideLink.Modify := true;
  ProvideLink.SaveLinkTrans(StoreData.LastSavedRecordid);

  MDMap.GetFieldData := Storedata.GetFieldData;
  MDMap.GetRowCount := Storedata.GetRowCount;
  MDMap.NewTrans := false;
  MDMap.Submit(StoreData.TransType, false);
  MDMap.DoUpdate;
  if (ClearFields) and (not(WorkFlowProcessed and workflow.chkmailcont)) then
    clear;
end;

Procedure TDbCall.DeleteData(ModifyRecordId:Extended);
Var status :String;
Begin
{  if not workflow.DeleteTransaction(transid,FloatToStr(ModifyRecordid)) then begin
    Showmessage('Approved transaction cannot be deleted.');
    exit;
  end;}
  CreateMapObjects;
  if struct.tree <> '' then  begin
    if TreeObj.isChildExists(0,Modifyrecordid) then begin
      Raise Exception.Create('Unable to delete Node. Children Exists');
    end;
    TreeOBj.TreeDel(0,0,ModifyRecordid);
  end;
  if axprovider.CheckExistanceInTransControl(floattostr(ModifyRecordId),StoreData.transtype) then
  begin
      Raise Exception.Create('This transaction cannot be deleted,it is already opened by user - '+dbm.gf.RecordLockedBy);
  end;
  Storedata.LoadTrans(ModifyRecordid);
  Parser.RegisterVar('ChildDoc', 'c', StoreData.ChildDoc);
  Parser.RegisterVar('recordid', 'n', floattostr(ModifyRecordId));
  validate.Validation:=false;
  validate.Loading:=true;
  validate.DeleteTrans:=true;
  validate.FillAndValidate(false);
  validate.Validation:=true;
  status := Storedata.canDeleteTrans;
  if status <> '' then raise EDatabaseError.Create(status);
  if assigned(ProvideLink) and (providelink.StoreDataList.Count>0) then inc(dbm.gf.TransCheckCount);
  if lowercase(WorkFlow.AppStatus) = 'approved' then begin
     ProvideLink.WorkFlow := 'approve';
     MDMap.WorkFlow:='approve';
  end else if lowercase(WorkFlow.AppStatus) = 'rejected' then begin
     ProvideLink.workflow := 'reject';
     MDMap.WorkFlow:='reject';
  end;
  StoreData.DeleteTrans(ModifyRecordId);
  If assigned(ProvideLink) Then Begin
    ProvideLink.CancelTrans := false;
    ProvideLink.DeleteLinkTrans(ModifyRecordId);
  End;
  MDMap.DoUpdate;
  WorkFlow.DeleteWFData(StoreData.transtype,FloatToStr(ModifyRecordId));
  DoEvalExprSet('', 'afterdelete');
  status := parser.getvarvalue('afterdeletestatus');
  if status <> '' then begin
    if status[1] = '_' then //showmessage(copy(status, 2, length(status)))
    else if lowercase(status) <> 't' then raise EDataBaseError.create(status);
  end;
//  ExecuteAction('After delete transaction','');
  if StoreData.deleted then begin
     axprovider.DeleteTransControl(floattostr(ModifyRecordId),StoreData.transtype);
  end;
  ExecuteEventAction('After delete transaction','');
  SaveHistory(True,false,nil); // Storing History Details to History Table
  SaveHistoryTable(True);
  ProcessFormNotifications('d'); //on delete
  if assigned(ProvideLink) and (providelink.StoreDataList.Count>0) then
  begin
    if not AxProvider.ValidateTransCheck then
       raise Exception.Create('Database connection lost. Please delete the transaction again.');
  end;

  if assigned(dbm.gf.WebAppConXML) then DeleteDataFromAppDB(struct.Transid,ModifyRecordId);
  dbm.gf.DoDebug.msg('Completed Deletion');
End;

Procedure TDbCall.CancelTransaction(ModifyRecordId:Extended;Rem:String);
Var status : String;
Begin
  {if not workflow.DeleteTransaction(transid,FloatToStr(ModifyRecordid)) then begin
    Showmessage('Approved transaction cannot be cancelled.');
    exit;
  end;}
  CreateMapObjects;
  storedata.LoadTrans(modifyrecordid);
  if storedata.cancelled then exit;
  Parser.RegisterVar('ChildDoc', 'c', StoreData.ChildDoc);
  Parser.RegisterVar('recordid', 'n', floattostr(ModifyRecordId));
  validate.Validation:=false;
  validate.Loading:=true;
  validate.DeleteTrans:=true;
  validate.FillAndValidate(false);
  validate.Validation:=true;
  status := Storedata.canDeleteTrans;
  if status <> '' then raise EDatabaseError.Create(status);
  if assigned(ProvideLink) and (providelink.StoreDataList.Count>0) then inc(dbm.gf.TransCheckCount);
  if lowercase(WorkFlow.AppStatus) = 'approved' then begin
     ProvideLink.WorkFlow := 'approve';
     MDMap.WorkFlow:='approve';
  end else if lowercase(WorkFlow.AppStatus) = 'rejected' then begin
     ProvideLink.workflow := 'reject';
     MDMap.WorkFlow:='reject';
  end;
  StoreData.CancelTrans(Rem);
  If assigned(ProvideLink) Then Begin
    ProvideLink.CancelTrans := true;
    If Not ProvideLink.DeleteLinkTrans(ModifyRecordId) Then
      Raise EDataBaseError.Create('Could not delete link document(s)');
    ProvideLink.CancelTrans := false;
    ProvideLink.CancelRemarks := Rem;
  End;
  MDMap.DoUpdate;
  WorkFlow.UpdateCancelInAxTasks(StoreData.transtype,FloatToStr(ModifyRecordId));
  DoEvalExprSet('', 'aftercancel');
  status := parser.getvarvalue('aftercancelstatus');
  if status <> '' then begin
    if status[1] = '_' then //showmessage(copy(status, 2, length(status)))
    else if lowercase(status) <> 't' then raise EDataBaseError.create(status);
  end;

  ProcessFormNotifications('c'); //on cancel
  if assigned(ProvideLink) and (providelink.StoreDataList.Count>0) then
  begin
    if not AxProvider.ValidateTransCheck then
       raise Exception.Create('Database connection lost. Please cancel the transaction again.');
  end;

End;

procedure TDbCall.DataValidate(context:String; DoValidation:Boolean);
var flg:boolean;
begin
  doevalexprset('', 'onpostgenmap');
  Validate.Validation := DoValidation;
  validate.Parser.RegisterVar('onsave','c', context);
  validate.Loading:=context='l';
  flg:=context='s';
  Validate.FillAndValidate(flg) ;
  Errorstr := Validate.ErrorStr;
  validate.Parser.RegisterVar('onsave','c','f');
end;

procedure TDbCall.DoEvalExprSet(CompName, EventName:String);
var p:integer;
    s:String;
begin
 if struct.ExprSetList.count = 0 then exit;
 compname := lowercase(trim(compname));
 eventname := lowercase(trim(eventname));
 if eventname = 'onscroll' then compname := dbm.gf.GetNthString(FrameNames, strtoint(compname));
 if compname = '' then s := '{'+eventname+'}' else s := '{'+eventname+' '+compname+'}';
 p := struct.ExprSetList.indexof(s);
 if p = -1 then exit;
 dbm.gf.DoDebug.msg('>>Executing '+s);
 parser.exprset := struct.exprsetlist;
 parser.evalexprset(p+1);
end;

procedure TDbCall.LoadData(ModifyRecordId:Extended);
var i:integer;
    f,v,btnStr,ptable:String;
    EnableTBar : Boolean;
begin
  dbm.gf.dodebug.Msg('Transid:'+Transid);
  dbm.gf.dodebug.Msg('recordid:'+FloatToStr(ModifyRecordid));
  dbm.gf.dodebug.Msg('primarytable:'+struct.PrimaryTable);
  dbm.gf.ClearAutoGenData(True);

  if copy(lowercase(dbm.gf.username),1,6) <> 'portal' then
  begin
    RecordLocked := AxProvider.CheckExistanceInTransControl(floattostr(ModifyRecordId),StoreData.TransType); //ch1
    if not recordlocked then begin
      AxProvider.InsertIntoTransControl(StoreData.TransType,ModifyRecordid);
    end;
  end;

  StoreData.LoadTrans(ModifyRecordId);
  Parser.RegisterVar('ChildDoc', 'c', StoreData.ChildDoc);
  Parser.RegisterVar('recordid', 'n', floattostr(ModifyRecordId));
  Validate.FillOnLoadFlds.Clear;
  ExecuteAction('After DBLoad','');
  if dataval = true then DataValidate('l', false);
  EnableTBar := WorkFlow.EnableToolbar(Transid,FloatToStr(ModifyRecordid),struct.PrimaryTable);
  dbm.gf.dodebug.Msg('Assigning approval bar');
  if EnableTBar then begin
    dbm.gf.dodebug.Msg('Assigned approval bar');
    if not assigned(ApprovalNode) then
      ApprovalNode := struct.XML.CreateNode('approval',ntElement,'') ;
    if storedata.Cancelled then begin
      WorkFlow.StrStatus := '';
      WorkFlow.WActList.clear;
    end;
    btnStr := '';
    dbm.gf.dodebug.Msg('Before Constructing WActList');
    dbm.gf.dodebug.Msg('Value:'+inttostr(WorkFlow.WActList.Count));
    for i := 0 to WorkFlow.WActList.Count - 1 do begin
      dbm.gf.dodebug.Msg('ApprovalNode : ' + WorkFlow.WActList[i]);
      if lowercase(WorkFlow.WActList[i]) = 'approve' then
        btnStr := btnStr+'a' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'reject' then
        btnStr := btnStr+'r' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'return' then
        btnStr := btnStr+'t' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'review' then
        btnStr := btnStr+'v' + '~'
    end;
    ApprovalNode.Attributes['btn'] := btnStr;
    ApprovalNode.Attributes['status'] := WorkFlow.StrStatus;
    ApprovalNode.Attributes['appstatus'] := WorkFlow.AppStatus;
    ApprovalNode.Attributes['lno'] := Trim(IntToStr(WorkFlow.Wapplevel));
    ApprovalNode.Attributes['elno'] := Trim(IntToStr(WorkFlow.EnblApplevel));
    if WorkFlow.ProcessForDelegatedUser then
      ApprovalNode.Attributes['dlgusr'] := 'true'
    else
      ApprovalNode.Attributes['dlgusr'] := 'false';
    if Workflow.AllowEdit then
       ApprovalNode.Attributes['allowedit'] := 'true'
    else
       ApprovalNode.Attributes['allowedit'] := 'false';
    if Workflow.AllowCancel then
       ApprovalNode.Attributes['allowcancel'] := 'true'
    else
       ApprovalNode.Attributes['allowcancel'] := 'false';
    if (lowercase(WorkFlow.AppStatus) = 'approved') and (not Workflow.AllowEdit) then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else if not workflow.EnabledTrans then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else
      ApprovalNode.Attributes['readonlyform'] := 'false';
    dbm.gf.dodebug.Msg('ApprovalNode : ' + ApprovalNode.XML);
  end;
  Maxrows.Clear;NewMaxRows.Clear;fnames.clear;
  i := 1;
  f:=Trim(lowercase(struct.gridstring));
  for i := 1 to length(f) do begin
    v := f[i];
    if v<>'t' then begin
      Maxrows.Add('*');
      NewMaxrows.add('*');
    end else begin
      Maxrows.add(inttostr(storedata.GetRowCount(i)));
      NewMaxRows.Add('0');
    end;
  end;
  AxpImgPath := Parser.GetVarValue('AxpImagePath');
  AxpAttPath := Parser.GetVarValue('AxpAttachmentPath');
  Storedata.AxpImagePath := AxpImgPath;
  dbm.gf.dodebug.Msg('newmaxrow count='+inttostr(newmaxrows.count));
end;

procedure TDbCall.Clear;
var i:integer;
begin
  StoreData.ClearFieldList;
  StoreData.NoAutoGenStr := '';
  if assigned(MDMap) then MDMap.cleardatalist;
  Maxrows.clear;
  NewMaxRows.clear;
  fnames.Clear;
end;

procedure TDbCall.SetCaption(s:String);
begin
  if (s=fcaption) or (s='') then exit;
  fcaption := s;
  workquery := dbm.GetXDS(workquery);
  workquery.buffered := True;
  workquery.CDS.CommandText := '';
  workquery.CDS.CommandText := 'select transid from transdefmaster where '+ dbm.gf.sqllower +'(transdesc)=:s';
  workquery.AssignParam(0,lowercase(s),'c');
  workquery.open;
  if not workquery.CDS.isempty then
    transid := workquery.CDS.Fields[0].AsString;
  workquery.CDS.close;
end;


procedure TDbCall.SetTransid(s:String);
begin
  if (s=ftransid) or (s='') then exit;
  ftransid := s;
  createobjects;
end;

Procedure TDbCall.CloseRefreshQueries;
begin
//to be coded sab.
end;

function TDbCall.IsFound(SearchField:String) : boolean;
var s:String;
begin
  result := false;
  if searchfield = '' then exit;
  s := storedata.GetFieldValue(SearchField, 1);
  workquery := dbm.getxds(workquery);
  workquery.buffered := True;
  workquery.CDS.CommandText := '';
  workquery.CDS.CommandText := 'select '+searchfield+' from '+storedata.PrimaryTableName+' where '+searchfield+'='+quotedstr(s);
  workquery.Open;
  result := not workquery.CDS.isempty;
  workquery.CDS.close;
end;

function TDbCall.GetRecordId(SearchField, Searchvalue, FieldTypes:String) : extended;
var f,s,sql:String;
    i:integer;
begin
  result := 0;
  if searchfield = '' then exit;
  i:=1;
  sql := 'select '+storedata.PrimaryTableName+'id from '+storedata.CompanyName+Storedata.PrimaryTableName+' where ';
  while true do begin
    f := dbm.gf.getnthstring(searchfield,i);
    if f='' then break;
    s := dbm.gf.getnthstring(searchvalue,i,'~');
    if i>1 then sql := sql + ' and ';
    if fieldtypes[i]='c' then
       s := quotedstr(s)
    else if fieldtypes[i]='d' then begin
      s:=dbm.gf.ConvertToDBDateTime(dbm.connection.dbtype,strtodatetime(s));
      s:=dbm.gf.findandreplace(dbm.gf.dbdatestring, ':value', s)
    end;
    sql := sql + f + '=' + s;
    inc(i);
  end;
  dbm.gf.dodebug.Msg('Get Record id sql : ' + sql);
  workquery := dbm.GetXDS(workquery);
  workquery.buffered := True;
  workquery.CDS.CommandText := '';
  workquery.CDS.CommandText := sql;
  workquery.Open;
  if workquery.CDS.isempty then result := 0
  else result := workquery.CDS.fields[0].asfloat;
  workquery.close;
end;

function TDbCall.GetRecordId(FieldName, FieldValue :String) : extended;
var sql:String;
begin
  result := 0;
  if FieldName = '' then exit;
  sql := 'select '+storedata.PrimaryTableName+'id from '+storedata.CompanyName+storedata.PrimaryTableName+ ' where ' + FieldName + ' = ' + Quotedstr(FieldValue);
  dbm.gf.dodebug.Msg('Get Record id sql : ' + sql);
  workquery := dbm.GetXDS(workquery);
  workquery.buffered := True;
  workquery.CDS.CommandText := '';
  workquery.CDS.CommandText := sql;
  workquery.Open;
  if workquery.CDS.isempty then result := 0
  else result := workquery.CDS.fields[0].asfloat;
  workquery.CDS.close;
end;
{
function TDbCall.PostString(s:String):String;
var i,r:integer;
    x,f:String;
    recid,id:extended;
begin
  if not assigned(poststr) then poststr:=TStringList.create;
  poststr.clear;
  poststr.text := s;
  x := poststr[0];
  transid := dbm.gf.getnthstring(x,1);
  StoreData.UserName := dbm.gf.getnthstring(x,2);
  StoreData.siteno := dbm.gf.strtointz(dbm.gf.getnthstring(x,3));
  recid := dbm.gf.strtofloatz(dbm.gf.getnthstring(x,4));
  if recid>0 then begin
    if IsRecFound(recid) then begin
      LoadData(recid);
    end;
  end;

  i:=1;
  while i<poststr.count do begin
    f:=dbm.gf.getnthstring(poststr[i],1);
    r:=strtoint(dbm.gf.getnthstring(poststr[i],2));
    id:=strtofloat(dbm.gf.getnthstring(poststr[i],3));
    recid:=strtofloat(dbm.gf.getnthstring(poststr[i],3));
    storedata.SubmitValue(f,r,poststr[i+1],'',id,0,recid);
    i:=i+2;
  end;

  try
  profitdb.starttransaction;
  ValidateAndSave;
  if errorstr <> '' then begin
    result := TransDetails+' Error '+ErrorStr;
    if profitdb.InTransaction then profitdb.Rollback;
  end else
    profitdb.commit;
  except
    on e:exception do begin
      result:=e.message;
      if profitdb.InTransaction then profitdb.Rollback;
    end;
  end;
end;
}
function TDbCall.IsRecFound(RecId:Extended) : boolean;
var s:String;
begin
  result := false;
  if recid = 0 then exit;
  s := storedata.PrimaryTableName+'id';
  workquery := dbm.GetXDS(workquery);
  workquery.buffered := True;
  workquery.CDS.CommandText := '';
  workquery.CDS.CommandText := 'select '+s+' from '+storedata.PrimaryTableName+' where '+s+'='+floattostr(recid);
  workquery.Open;
  result := not workquery.CDS.isempty;
  workquery.CDS.close;
end;

procedure TDbCall.GetTlines;
var i:integer;
begin
  tlines.clear;
  tlines.add(StoreData.TransType+','+StoreData.UserName+','+inttostr(StoreData.siteno)+','+floattostr(storedata.LastSavedRecordId));
  for i:=0 to storedata.FieldList.count-1 do begin
    tlines.add(pFieldRec(storedata.FieldList[i]).FieldName+','+inttostr(pFieldRec(storedata.FieldList[i]).rowno)+','+floattostr(pFieldRec(storedata.FieldList[i]).IdValue)+','+floattostr(pFieldRec(storedata.FieldList[i]).RecordId));
    tlines.add(pFieldRec(storedata.FieldList[i]).Value);
  end;
end;

procedure TDbCall.PrepareExps;
var i:integer;
    fld:pFld;
begin
  for i:=0 to struct.flds.count-1 do begin
    fld:=pfld(struct.flds[i]);
    if fld.DataType[1] = 'n' then
      Parser.RegisterVar(fld.FieldName,fld.DataType[1],'0');
    if fld.cexp <> '' then
    begin
      if fld.DataType[1] <> 'n' then
        Parser.RegisterVar(fld.FieldName,fld.DataType[1],'');
      fld.Exprn:=parser.Prepare(fld.cexp);
    end;
    if fld.cvalexp<>'' then
      fld.ValExprn:=parser.Prepare(fld.cvalexp);
    if (fld.axRule_ValExprn = -1) and (fld.axRule_cvalexp<>'') then
      fld.axRule_ValExprn:=parser.Prepare(fld.axRule_cvalexp);
    if (fld.axRule_ValOnSave_ValExprn = -1) and (fld.AxRule_ValOnSave_cvalexp<>'') then
      fld.axRule_ValOnSave_ValExprn:=parser.Prepare(fld.AxRule_ValOnSave_cvalexp);
  end;
end;

procedure TDbCall.SubmitValue(FieldName: String; Value,
  OldValue: String; IdValue, OldIdValue, Recordid: extended);
var i,r:integer;
    fld : pfld;
begin
  fld:=struct.GetField(fieldname);
  if (assigned(fld)) and (not fld.AsGrid) then begin
    r:=1;
  end else begin
    r := 0;
    for i:=0 to fnames.count-1 do begin
      if fnames[i]=Fieldname then inc(r);
    end;
    inc(r);
  end;
  dbm.gf.DoDebug.msg(FieldName+'['+inttostr(r)+']='+value);
  if assigned(fld) then
  begin
     if fld.EncryptValue then value := dbm.gf.EncryptFldValue(value,fld.datatype);
     storedata.SubmitValue(fld,fieldname, r, value, oldvalue, idvalue, oldidvalue, recordid)
  end else storedata.SubmitValue(nil,fieldname, r, value, oldvalue, idvalue, oldidvalue, recordid);
  if assigned(fld) then
    parser.RegisterVar(fieldname,fld.DataType[1],value);
  fnames.Add(fieldname);
  if Newmaxrows.Count>0 then begin
    if (assigned(fld)) and (newmaxrows[fld.frameno-1]<>'*') and  (strtoint(newmaxrows[fld.FrameNo-1])<r) then
      newmaxrows[fld.frameno-1]:=inttostr(r);
  end;
  LastRowNo := r;
end;

procedure TDbCall.TrimExtraRows;
var i,j,k:integer;
begin
  if maxrows.count > 0 then begin
    dbm.gf.DoDebug.msg('Trimming extra rows');
    for i:=0 to maxrows.count-1 do begin
      if maxrows[i]='*' then continue;
      j := strtoint(newmaxrows[i]);
      dbm.gf.DoDebug.msg('Frame '+inttostr(i+1)+' No of Rows Before ='+maxrows[i]+' After = '+inttostr(j));
      if strtoint(maxrows[i]) > j then begin
        for k:=j+1 to strtoint(maxrows[i]) do
          storedata.deleterow(i+1, j+1);
      end;
    end;
    maxrows.clear;
    newmaxrows.clear;
  end;
end;

function TDbCall.PostXML(filename, wtransid:String):String;
  var i,j : integer;
  xml : IXMLDocument;
  xnode,n : IXMLNode;
  f,v : String ;
  recid : Extended;
begin
{
  //read from file into xml
  <transaction transid="">
  </transaction>

  start loop in xml
    for every transaction tag, set the transid property
    submit the field values that are as child nodes under transaction tag using the submitvalue function.
    when transaction tag ends, commit to database, if error
  end loop
}
    filename := trim(filename);
    if filename[1] = '<' then
       xml := LoadxmlData(filename)
    else if fileexists(filename) then
    begin
      with tstringlist.create do begin
        loadfromfile(filename);
        xml := Loadxmldata(text);
        Free;
      end;
    end
    else begin
      showmessage('XML Source file not found.....');
      exit;
    end;
    xnode := xml.DocumentElement ;
    dbm.gf.DoDebug.msg('Submitting data to dbcall');
    for i:=0 to xnode.ChildNodes.Count-1 do begin
      fnames.Clear;
      transid := wtransid;
      n := xnode.ChildNodes[i];
      if n.ChildNodes.Count = 0 then continue;
      //load
      for j := 0 to n.ChildNodes.Count - 1 do
      begin
        recid := 0;
        f := lowercase(n.ChildNodes[j].NodeName);
        v := n.ChildNodes[j].Text;
        if pos(f,StoreData.structdef.PrimaryFields) > 0 then
           recid := GetRecordId(f,v);
        if recid > 0 then LoadData(Recid);
        SubmitValue(f, v, '', 0, 0, 0);
      end;
      try
        dbm.gf.DoDebug.msg('Starting database transaction for validating & saving');
        dbm.StartTransaction(dbm.gf.ConnectionName);
        ValidateAndSave;
        if errorstr <> '' then begin
          dbm.RollBack(dbm.gf.ConnectionName);
          dbm.gf.DoDebug.msg('Error '+ ErrorStr);
          result := errorstr;
        end else begin
          dbm.Commit(dbm.gf.ConnectionName);
          dbm.gf.DoDebug.msg('Transaction commited');
        end;
      except
        on e:exception do begin
          if assigned(axprovider) then
            axprovider.dbm.gf.DoDebug.Log(axprovider.dbm.gf.Axp_logstr+'\uDbcall\PostXML - '+e.Message);
          result:=e.message;
          dbm.RollBack(dbm.gf.ConnectionName);
        end;
      end;
    end;
    result := 'Transactions commited';
end;

procedure TDbCall.DoFillgrid(aname:String);
var i,rc,j,k,rno : integer;
    fgname , stext,s,fname,fvalue : String;
    fld : pFld;
    invalidrow : boolean;
    fg : pfg;
begin
  dbm.gf.DoDebug.msg('Executing fillgrid for frame name '+ aname);
  fgname := aname;
  aname := lowercase(aname);
  fg := nil;
  for i:=0 to struct.fgs.Count-1 do begin
    if (lowercase(pfg(struct.fgs[i]).name) = aname) or (lowercase(pfg(struct.fgs[i]).fname) = aname) then
    begin
      fg := pfg(struct.fgs[i]);
      break;
    end;
  end;
  if fg = nil then
  begin
     fg := struct.CreateFgsInActions(fgname);
     if (assigned(fg)) then
     begin
        fg.AutoShow := true;
        VisibleDCs := VisibleDCs + ',' + quotedstr('dc' + inttostr(fg.TargetFrame));
     end;
     exit;
  end;
  rno := -1;
  for i:=0 to struct.fgs.Count-1 do begin
    if (lowercase(pfg(struct.fgs[i]).name) <> aname) and (lowercase(pfg(struct.fgs[i]).fname) <> aname) then continue;
    fillgrid_targetdc := 'dc' + inttostr(pfg(struct.fgs[i]).TargetFrame);
    dbm.gf.DoDebug.msg('Executing fillgrid - Target DC Name '+ fillgrid_targetdc);
    if pfg(struct.fgs[i]).AddRows = 3 then
    begin
       invalidrow := false;
       j := StoreData.RowCount(pfg(struct.fgs[i]).TargetFrame);
       rno := j+1;
       if (j = 1) then
       begin
          k:=1;
          while true do begin
            s:=dbm.gf.getnthstring(pfg(struct.fgs[i]).Map.CommaText,k);
            if s='' then break;
            fname:=dbm.gf.getnthstring(s,2,'=');
            fld := struct.GetField(fname);
            if assigned(fld) then
            begin
              fvalue:= StoreData.GetFieldValue(fld.FieldName,1);
              if (not fld.Empty) and ((fvalue='') or ((fld.DataType = 'n') and (dbm.gf.StrToFloatz(fvalue) = 0))) then
              begin
                 invalidrow := true;
                 break;
              end;
            end;
            inc(k);
          end;
          if invalidrow then
          begin
            dbm.gf.DoDebug.msg('Deleting invalid rows from Target DC');
            InitGrid(pfg(struct.fgs[i]).TargetFrame);
            rno := 1;
          end;
       end;
       activerow := rno;
    end else
    begin
      dbm.gf.DoDebug.msg('Deleting existing rows from Target DC');
      //to delete all submitted rows before action execution - as per Sab 02/12/2010
      rc := StoreData.GetRowCount(pfg(struct.fgs[i]).TargetFrame);
      for j := 1 to rc do
      begin
        StoreData.DeleteRow(pfg(struct.fgs[i]).TargetFrame,j);
      end;
      rno := 1;
    end;
    stext := '';
    if assigned(pfg(struct.fgs[i]).q) then
      stext := pfg(struct.fgs[i]).q.CDS.CommandText;
    FillValuesNew(pfg(struct.fgs[i]),stext,pfg(struct.fgs[i]).Map.CommaText,pfg(struct.fgs[i]).Groupfield,pfg(struct.fgs[i]).SourceFrame,pfg(struct.fgs[i]).TargetFrame,rno) ;
    act_fgname := inttostr(pfg(struct.fgs[i]).TargetFrame)+','+pfg(struct.fgs[i]).fname;
    break;
  end;
end;

procedure TDbCall.ExecuteFillGrid(frmno:integer);
var i : integer;
    stext : String;
begin
  for i := 0 to struct.fgs.Count-1 do begin
    if (pfg(struct.fgs[i]).TargetFrame = frmno) then begin
      dbm.gf.DoDebug.msg('Executing fillgrid for frameno '+inttostr(frmno));
      if (pfg(struct.fgs[i]).ExecuteOnSave) then begin
      stext := '';
      if assigned(pfg(struct.fgs[i]).q) then
        stext := pfg(struct.fgs[i]).q.CDS.CommandText;
        FillValues(stext,pfg(struct.fgs[i]).Map.CommaText,pfg(struct.fgs[i]).Groupfield,pfg(struct.fgs[i]).SourceFrame)
      end;
    end;
  end;
end;

procedure TDbCall.DoMultiSelectFillGrid(fg:pFg ; xnode : ixmlnode);
var q:TXDS;
    s, fname, fvalue,fldname,idfld:String;
    i,p,j,rc:integer;
    fm:pfrm;
    fd:pFld;
    n,idnode : ixmlnode;
    idval : extended;
begin
  dbm.gf.DoDebug.msg('Multi Select Fill grid');
  if fg.AddRows = 3 then rc := StoreData.GetRowCount(fg.TargetFrame)
  else rc := 0;
  dbm.gf.DoDebug.msg('Row count before Multi Select Fill grid : ' + inttostr(rc));
  fm:=pFrm(struct.frames[fg.TargetFrame-1]);
  for j:=0 to xnode.childnodes.count-1 do
  begin
    validate.RegRow(fm.FrameNo, rc+j+1);
    n := xnode.childnodes[j];
    for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
      fd:=pfld(struct.flds[i]);
      fldname := fd.fieldname;
      s := fg.Map.Values[fldname];
      if s<>'' then begin
        idval := 0;
        if fd.SourceKey then begin
          idfld :=s+'__id';
          idnode := n.ChildNodes.FindNode(idfld);
          if assigned(idnode) then begin
            fvalue := Trim(vartostr(idnode.ChildValues[idfld]));
            if (fvalue<>'') and (isnumeric(fvalue,-1)) then
              idval := StrToFloat(fvalue);
          end;
        end;
        //fvalue := vartostr(n.ChildValues[s]);
        fvalue := GetChildNodeValue(n,s);
        StoreData.SubmitValue(fldname, rc+j+1 , fvalue, '',idval, 0, 0);
        Parser.RegisterVar(fldname,fd.DataType[1],fvalue);
        if ((fd.SourceKey) and (idval = 0)) or (fd.Autoselect) then
          validate.RefreshField(fd, rc+j+1,struct.quickload);
//        Parser.RegisterVar(fldname,fd.DataType[1],fvalue);
        if (not dc_image_fillgrid) and (fd.FieldName = 'dc' + inttostr(fd.FrameNo) + '_image') then
        begin
           dc_image_fillgrid := true;
        end;
      end else
      begin
        validate.RefreshField(fd, rc+j+1,struct.quickload)
      end;
      p := PopAtThisField(fd);
      if p <> -1 then
         DoPopUp(p, rc+j+1);
    end;
  end;
  RefreshGridDependents(fm);
end;

function TDbCall.GetChildNodeValue(mnode : IXMLNode; mname : string): string;
Var
  j : integer;
  n : IXMLNode;
begin
  Result := '';
  n := mnode.ChildNodes.FindNode(lowercase(mname));
  if n = nil then n := mnode.ChildNodes.FindNode(uppercase(mname));
  if assigned(n) then
  begin
    Result := vartostr(n.NodeValue);
  end else
  begin
    for j := 0 to mnode.ChildNodes.Count - 1 do
    begin
      if lowercase(mnode.ChildNodes[j].NodeValue) = lowercase(mname) then
      begin
        Result := vartostr(mnode.ChildNodes[j].NodeValue);
        break;
      end;
    end;
  end;
end;

procedure TDbCall.FillGrid(fg:pFg);
var q:TXDS;
    s, fname, fvalue, idfld:String;
    i,j,p, rowno,pno,rcount:integer;
    idval : extended;
    fm,sfm:pfrm;
    fd:pFld;
begin
  dbm.gf.DoDebug.msg('Filling grid '+fg.name);
  if struct.quickload then StoreData.depCall := false;
  if assigned(fg.q) then
  begin
    q:=dbm.GetXDS(nil);
    q.buffered := true;
    q.CDS.CommandText:=fg.q.CDS.CommandText;
    Validate.DynamicSQL := fg.q.CDS.CommandText;
    Validate.QueryOpen(q,1);
    fm:=pFrm(struct.frames[fg.TargetFrame-1]);
    rowno:=1;
    while not Q.CDS.eof do begin
      validate.RegRow(fm.FrameNo, rowno);
      for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
        fd:=pfld(struct.flds[i]);
        p:=fg.Map.IndexOfName(fd.FieldName);
        if p=-1 then
          validate.RefreshField(fd, rowno,struct.quickload)
        else begin
          fname:=fg.map.Values[fd.FieldName];
          idval := 0;
          if fd.SourceKey then begin
            idfld :=fname+'__id';
            if assigned(fg.q.CDS.Fields.FindField(idfld)) then
              idval:=fg.q.CDS.fieldbyname(fname).AsFloat;
          end;
          fvalue:=q.CDS.fieldbyname(fname).asstring;
          storedata.SubmitValue(fd.FieldName, rowno, fvalue, '', idval, 0, 0);
          Parser.RegisterVar(fd.FieldName,fd.DataType[1],fvalue);
          if ((fd.SourceKey) and (idval = 0)) then
            validate.RefreshField(fd, rowno,struct.quickload);
//           Parser.RegisterVar(fd.FieldName,fd.DataType[1],fvalue);
          if (not dc_image_fillgrid) and (fd.FieldName = 'dc' + inttostr(fd.FrameNo) + '_image') then
          begin
             dc_image_fillgrid := true;
          end;
        end;
        pno := PopAtThisField(fd);
        if pno <> -1 then
          DoPopUp(pno, rowno);
      end;
      q.cds.next;
      inc(rowno);
    end;
  end else begin
    //This code is to be written. This is for grid to grid copy.
    if fg.TargetFrame = 0  then exit;
    fm:=pFrm(struct.frames[fg.TargetFrame-1]);
    if fg.SourceFrame = 0  then exit;
    sfm:=pFrm(struct.frames[fg.SourceFrame-1]);
    rcount := storedata.getrowcount(sfm.FrameNo);
    if fg.Groupfield = '' then
    begin
      for j := 1 to rcount do
      begin
        for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
          fd:=pfld(struct.flds[i]);
          p:=fg.Map.IndexOfName(fd.FieldName);
          if p=-1 then
            validate.RefreshField(fd, j)
          else begin
            fname:=fg.map.Values[fd.FieldName];
            fvalue:=storedata.GetFieldValue(fname,j);
            SubmitValue(fd.fieldname, fvalue, '', 0, 0, 0);
            if fd.SourceKey then
              validate.RefreshField(fd, j);
          end;
          pno := PopAtThisField(fd);
          if pno <> -1 then
            DoPopUp(pno, j);
        end;
      end;
    end else FillWithGroupField(fg,rcount);
  end;
  if struct.quickload then StoreData.depCall := true;
  RefreshGridDependents(fm);
end;

procedure TDbCall.FillWithGroupField(fg:pFg;rcount:integer);
  var s,ws,groupfld,fname,fvalue,gfld,mapstring,fval,fn : string;
      i,j,k,l,m : integer;
      fv : extended;
begin
    ws := '';
    groupfld := fg.Groupfield;
    mapstring := fg.Map.CommaText;
    for k := 1 to  rcount do
    begin
      fvalue:= quotedstr(StoreData.GetFieldValue(groupfld,k)) ;
      if pos(fvalue,ws) = 0 then
         ws := ws + fvalue + ',';
    end;
    dbm.gf.DoDebug.msg('Group Filed Value : '+ ws);
    l := 1;
    while True do
    begin
      gfld:=dbm.gf.getnthstring(ws,l);
      if gfld='' then break;
      inc(l);
      i:=1;
      while true do begin
        s:=dbm.gf.getnthstring(mapstring,i);
        if s='' then break;
        inc(i);
        fname:=dbm.gf.getnthstring(s,2,'=');
        fvalue := '';
        if fname = groupfld then
        begin
            fvalue:= copy(gfld,2,length(gfld)) ;
            delete(fvalue,length(gfld)-1,2);
        end;
        fv := 0;
        for k := 1 to  rcount do
        begin
          fval:= quotedstr(StoreData.GetFieldValue(groupfld,k)) ;
          if gfld = fval then
          begin
             m := StoreData.structdef.GetFieldIndex(fname);
             if pfld(Parser.StoreData.structdef.flds[m]).DataType <> 'n' then
             begin
               fv := 0.0001;
               break;
             end;
             fv := fv + strtofloat(StoreData.GetFieldValue(fname,k)) ;
          end;
        end;
        fn := fname;
        fname:=dbm.gf.getnthstring(s,1,'=');
        if fn = groupfld then
        begin
          dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
          SubmitValue(fname, fvalue, '', 0, 0, 0);
        end else begin
          if fv = 0.0001 then
             fvalue := ''
          else fvalue := floattostr(fv);
          dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
          SubmitValue(fname, fvalue, '', 0, 0, 0);
        end;
      end;
    end;
end;

function TDbCall.PopAtThisField(fd:pFld):integer;
var i:integer;
begin
  result:=-1;
  for I := 0 to struct.popgrids.count - 1 do begin
    if pPopGrid(Struct.PopGrids[i]).PopAt=fd.orderno then begin
      result:=pPopGrid(Struct.PopGrids[i]).FrameNo;
      exit;
    end;
  end;
end;

procedure TDbCall.RefreshGridDependents(fm:pFrm);
var i,j:integer;
    fd, dfd:pFld;
    fldDep : TStringList;
    s : String;
begin
  if GridDependentFields = '' then GridDependentFields:=',';
  fldDep := TStringList.Create;
  for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
    fd:=pfld(struct.flds[i]);
    if not assigned (fd.Dependents) then continue;
    s := '';
    for j := 0 to fd.Dependents.count-1 do begin
      dfd:=struct.getfield(fd.Dependents[j]);
      if not assigned(dfd) then continue;
      if (dfd.FrameNo=fd.FrameNo) then continue;
      if pos(','+dfd.FieldName+',', GridDependentFields) > 0 then continue;
      GridDependentFields:=GridDependentFields + dfd.FieldName+',';
      if dfd.PopIndex>-1 then begin
        s:=axprovider.dbm.gf.LeftPad(inttostr(fd.FrameNo), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(pPopGrid(Struct.popgrids[dfd.PopIndex]).popat), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(dfd.orderno), 4, '0');
      end else begin
        s:=axprovider.dbm.gf.LeftPad(inttostr(dfd.FrameNo), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(dfd.orderno), 4, '0')+'0000';
      end;
      s := s + dfd.FieldName;
      fldDep.Add(s);
      s := '';
    end;
  end;
  delete(GridDependentFields,1,1);
  if GridDependentFields <> '' then
  begin
    GridDependentFields := '';
    fldDep.Sort;
    for j:=0 to fldDep.count-1 do begin
      s:=fldDep[j];
      delete(s,1,12);
      fldDep[j]:=s;
    end;
    GridDependentFields := fldDep.CommaText;
  end;
  fldDep.Clear;
  FreeAndNil(fldDep);
end;
{
function TDbCall.CreateFldListByOrder(fldlist : String) : String;
var i,j:integer;
    fd :pFld;
    fldDep : TStringList;
    s,f : String;
begin
  result := fldlist;
  fldDep := TStringList.Create;
  i := 1;
  while true do
  begin
    f := axprovider.dbm.gf.GetnthString(fldlist,i);
    if f = '' then break;
    fd := struct.GetField(f);
    if assigned (fd) then
    begin
      s := '';
      if fd.PopIndex>-1 then begin
        s:=axprovider.dbm.gf.LeftPad(inttostr(fd.FrameNo), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(pPopGrid(Struct.popgrids[fd.PopIndex]).popat), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(fd.orderno), 4, '0');
      end else begin
        s:=axprovider.dbm.gf.LeftPad(inttostr(fd.FrameNo), 4, '0');
        s:=s+axprovider.dbm.gf.LeftPad(inttostr(fd.orderno), 4, '0')+'0000';
      end;
      s := s + fd.FieldName;
      fldDep.Add(s);
    end;
    inc(i);
  end;
  fldDep.Sort;
  for j:=0 to fldDep.count-1 do begin
    s:=fldDep[j];
    delete(s,1,12);
    fldDep[j]:=s;
  end;
  result := fldDep.CommaText;
  fldDep.Clear;
  FreeAndNil(fldDep);
end;
}
procedure TDbCall.RefreshGridRowDependents(fm:pFrm;fd:pFld);
var i,j:integer;
    dfd:pFld;
begin
  if GridDependentFields = '' then GridDependentFields:=',';
  for I := 0 to fd.Dependents.count-1 do begin
    dbm.gf.DoDebug.msg('Refreshing '+fd.Dependents[i]+ ' Type '+fd.DependentTypes[i+1]);
    if fd.DependentTypes[i+1]='d' then begin
      continue;
    end else if fd.DependentTypes[i+1]='g' then begin
      continue;
    end;
    dfd:=struct.GetField(fd.dependents[i]);
    if not assigned(dfd) then continue;
    if (dfd.FrameNo=fd.FrameNo) then continue;
    if pos(','+dfd.FieldName+',', GridDependentFields) > 0 then continue;
    GridDependentFields:=GridDependentFields + dfd.FieldName+',';
  end;
  delete(GridDependentFields,1,1);
  delete(GridDependentFields, length(GridDependentFields), 1);
end;

procedure TDbCall.FillValues(SQLText, MapString , groupfld : String ; sframe : integer);
var Q:TXDS;
    s, fname, fvalue,gfld,fval,fn:String;
    id:extended;
    i, j,k,l,m, fno:integer;
    ws : string;
    fv : extended;
begin
  fnames.Clear;
  dbm.gf.DoDebug.msg('Sql text : '+ sqltext);
  dbm.gf.DoDebug.msg('Map String : '+ mapstring);
  if trim(sqlText) <> '' then
  begin
    q:=dbm.GetXDS(nil);
    q.buffered := true;
    q.CDS.CommandText:=sqltext;
    Validate.DynamicSQL := sqltext;
    Validate.QueryOpen(q,1);
    fno:=0;
    while not Q.CDS.eof do begin
      i:=1;
      while true do begin
        s:=dbm.gf.getnthstring(mapstring,i);
        if s='' then break;
        fname:=dbm.gf.getnthstring(s,2,'=');
        fvalue:=q.CDS.fieldbyname(fname).asstring;
        fname:=dbm.gf.getnthstring(s,1,'=');
        SubmitValue(fname, fvalue, '', 0, 0, 0);
        if fno=0 then fno:=struct.GetField(fname).FrameNo;
        inc(i);
      end;
      Q.CDS.next;
    end;
    q.Close;
    q.Free;
    DoFillGridRefresh(fno);   //newly added
  end else begin
    dbm.gf.DoDebug.msg('Group Field : '+ groupfld);
    j := StoreData.GetRowCount(sframe);
    if groupfld = '' then
    begin
      for k := 1 to  j do
      begin
        i:=1;
        while true do begin
          s:=dbm.gf.getnthstring(mapstring,i);
          if s='' then break;
          fname:=dbm.gf.getnthstring(s,2,'=');
          fvalue:= Parser.GetValue(fname,k) ;
          fname:=dbm.gf.getnthstring(s,1,'=');
          SubmitValue(fname, fvalue, '', 0, 0, 0);
          inc(i);
        end;
        DoFillGridRefresh(sframe);   //newly added
      end;
    end else begin
      ws := '';
      for k := 1 to  j do
      begin
        fvalue:= quotedstr(Parser.GetValue(groupfld,k)) ;
        if pos(fvalue,ws) = 0 then
           ws := ws + fvalue + ',';
      end;
      dbm.gf.DoDebug.msg('Group Filed Value : '+ ws);
      l := 1;
      while True do
      begin
        gfld:=dbm.gf.getnthstring(ws,l);
        if gfld='' then break;
        inc(l);
        i:=1;
        while true do begin
          s:=dbm.gf.getnthstring(mapstring,i);
          if s='' then break;
          inc(i);
          fname:=dbm.gf.getnthstring(s,2,'=');
          fvalue := '';
          if fname = groupfld then
          begin
              fvalue:= copy(gfld,2,length(gfld)) ;
              delete(fvalue,length(gfld)-1,2);
          end;
          fv := 0;
          for k := 1 to  j do
          begin
            fval:= quotedstr(Parser.GetValue(groupfld,k)) ;
            if gfld = fval then
            begin
               m := StoreData.structdef.GetFieldIndex(fname);
               if pfld(Parser.StoreData.structdef.flds[m]).DataType <> 'n' then
               begin
                 fv := 0.0001;
                 break;
               end;
               fv := fv + strtofloat(Parser.GetValue(fname,k)) ;
            end;
          end;
          fn := fname;
          fname:=dbm.gf.getnthstring(s,1,'=');
          if fn = groupfld then
          begin
            dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
            SubmitValue(fname, fvalue, '', 0, 0, 0);
         end else begin
            if fv = 0.0001 then
               fvalue := ''
            else fvalue := floattostr(fv);
            dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
            SubmitValue(fname, fvalue, '', 0, 0, 0);
          end;
        end;
        DoFillGridRefresh(sframe);   //newly added
      end;
    end;
  end;
end;

procedure TDbCall.FillValuesNew(fg: pFg; SQLText, MapString , groupfld : String ; sframe ,tframe , rno : integer);
var Q:TXDS;
    s, fname, fvalue,gfld,fval,fn,idfld:String;
    i, j,k,l,m, fno,rowno,pno,p:integer;
    ws : string;
    fv,idval : extended;
    fm : pFrm;
    fd : pFld;
begin
  fnames.Clear;
  dbm.gf.DoDebug.msg('Sql text : '+ sqltext);
  dbm.gf.DoDebug.msg('Map String : '+ mapstring);
  if trim(sqlText) <> '' then
  begin
    q:=dbm.GetXDS(nil);
    q.buffered := true;
    q.CDS.CommandText:=sqltext;
    Validate.DynamicSQL := sqltext;
    Validate.QueryOpen(q,1);
    fno:=0;
    if rno = -1 then rowno := 1
    else rowno := rno;
    fm:=pfrm(struct.frames[tframe-1]);
    if activerow > -1 then fg_record_count := Q.CDS.RecordCount;
    while not Q.CDS.eof do begin
      validate.RegRow(fm.FrameNo, rowno);
      for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
        fd:=pfld(struct.flds[i]);
        p:=fg.Map.IndexOfName(fd.FieldName);
        if p=-1 then
          validate.RefreshField(fd, rowno,struct.QuickDataFlag)
        else begin
          fname:=fg.map.Values[fd.FieldName];
          idval := 0;
          if fd.SourceKey then begin
            idfld :=fname+'__id';
            if assigned(fg.q.CDS.Fields.FindField(idfld)) then
              idval:=fg.q.CDS.fieldbyname(fname).AsFloat;
          end;
          fvalue:=q.CDS.fieldbyname(fname).asstring;
          storedata.SubmitValue(fd.FieldName, rowno, fvalue, '', idval, 0, 0);
          Parser.RegisterVar(fd.FieldName,fd.DataType[1],fvalue);
          if ((fd.SourceKey) and (idval = 0)) then
            validate.RefreshField(fd, rowno,struct.QuickDataFlag);
        end;
        pno := PopAtThisField(fd);
        if pno <> -1 then
          DoPopUp(pno, rowno);
      end;
      inc(rowno);
      q.cds.next;
    end;
    q.Close;
    q.Free;
    DoFillGridRefreshNew(fm);
  end else begin
    dbm.gf.DoDebug.msg('Group Field : '+ groupfld);
    j := StoreData.GetRowCount(sframe);
    if groupfld = '' then
    begin
      for k := 1 to  j do
      begin
        i:=1;
        while true do begin
          s:=dbm.gf.getnthstring(mapstring,i);
          if s='' then break;
          fname:=dbm.gf.getnthstring(s,2,'=');
          fvalue:= Parser.GetValue(fname,k) ;
          fname:=dbm.gf.getnthstring(s,1,'=');
          SubmitValue(fname, fvalue, '', 0, 0, 0);
          inc(i);
        end;
        DoFillGridRefresh(sframe);   //newly added
      end;
    end else begin
      ws := '';
      for k := 1 to  j do
      begin
        fvalue:= quotedstr(Parser.GetValue(groupfld,k)) ;
        if pos(fvalue,ws) = 0 then
           ws := ws + fvalue + ',';
      end;
      dbm.gf.DoDebug.msg('Group Filed Value : '+ ws);
      l := 1;
      while True do
      begin
        gfld:=dbm.gf.getnthstring(ws,l);
        if gfld='' then break;
        inc(l);
        i:=1;
        while true do begin
          s:=dbm.gf.getnthstring(mapstring,i);
          if s='' then break;
          inc(i);
          fname:=dbm.gf.getnthstring(s,2,'=');
          fvalue := '';
          if fname = groupfld then
          begin
              fvalue:= copy(gfld,2,length(gfld)) ;
              delete(fvalue,length(gfld)-1,2);
          end;
          fv := 0;
          for k := 1 to  j do
          begin
            fval:= quotedstr(Parser.GetValue(groupfld,k)) ;
            if gfld = fval then
            begin
               m := StoreData.structdef.GetFieldIndex(fname);
               if pfld(Parser.StoreData.structdef.flds[m]).DataType <> 'n' then
               begin
                 fv := 0.0001;
                 break;
               end;
               fv := fv + strtofloat(Parser.GetValue(fname,k)) ;
            end;
          end;
          fn := fname;
          fname:=dbm.gf.getnthstring(s,1,'=');
          if fn = groupfld then
          begin
            dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
            SubmitValue(fname, fvalue, '', 0, 0, 0);
         end else begin
            if fv = 0.0001 then
               fvalue := ''
            else fvalue := floattostr(fv);
            dbm.gf.DoDebug.msg('fName : '+ fname + ' fValue : ' + fvalue);
            SubmitValue(fname, fvalue, '', 0, 0, 0);
          end;
        end;
        DoFillGridRefresh(sframe);   //newly added
      end;
    end;
  end;
end;

Procedure TDbCall.ReplaceParams(Query :TXDS);
Var
  i, p: integer;
  paramvalue, paramname, fname , paramType : String;
  paramdvalue : TDateTime;
  paramivalue : extended;
  idparam : boolean;
Begin

  ReplaceDynamicParams(Query.CDS.CommandText);
  If Query.CDS.Params.Count = 0 Then Begin
    If Not Query.CDS.Active Then begin
      Query.Open;
    end else begin
    end;
  End Else Begin
//    AssignParamTypes(Query);
    For i := 0 To Query.CDS.Params.Count - 1 Do Begin
      paramname := Query.CDS.params[i].Name;
      ParamValue := Parser.GetVarValue(paramname);
      ParamType := lowercase(GetFieldType(paramname));
      Query.AssignParam(i,ParamValue,ParamType);
      {
      if (query.CDS.params[i].DataType = ftFloat) then begin
        DoDebug.msg(Query.CDS.params[i].name + ' = ' + ParamValue + ' As float');
        if paramvalue='' then paramvalue:='0';
        try
        paramivalue := StrToFloat(Paramvalue);
        except
        paramivalue := 0;
        end;
        If Query.CDS.Params[i].AsFloat <> ParamIValue Then Begin
          Query.CDS.Params[i].AsFloat := ParamIValue;
          Query.Close;
        End;
      end else if (query.CDS.params[i].DataType = ftInteger) then begin
        DoDebug.msg(Query.CDS.params[i].name + ' = ' + ParamValue + ' As Integer');
        if paramvalue='' then paramvalue:='0';
        try
        paramivalue := StrToFloat(Paramvalue);
        except
        paramivalue := 0;
        end;
        If Query.CDS.Params[i].AsFloat <> ParamIValue Then Begin
          Query.CDS.Params[i].AsFloat := ParamIValue;
          Query.Close;
        End;
      end Else if query.CDS.params[i].DataType = ftDateTime then begin
        DoDebug.msg(Query.CDS.params[i].name + ' = ' + ParamValue + ' As DateTime');
        try
        ParamDvalue := StrToDateTime(ParamValue);
        except
        ParamDValue := StrToDateTime('01/01/1900');
        end;
        if Query.CDS.Params[i].asdatetime <> ParamDValue then begin
        {$ifdef mysql}
       //   Query.CDS.Params[i].asstring :=formatdatetime('yyyy/MM/dd',ParamDValue);
      //  {$else}
       //   Query.CDS.Params[i].asdatetime := ParamDValue;
     //   {$endif}
        {
         Query.Close;
        end;
      end Else begin
        DoDebug.msg(Query.CDS.params[i].name + ' = ' + ParamValue + ' As String');
        if Query.CDS.params[i].asstring <> paramvalue then begin
         Query.CDS.Params[i].asstring := ParamValue;
         Query.close;
        end;
      end;
      }
    End;
//    {$ifdef mysql}
//      ChangeDateParams(Query)
//    {$endif}
    if not Query.CDS.active then begin
      Query.Open;
    end else begin
    end;
  End;
end;

Function TDbCall.ReplaceDynamicparams(SQLText:String):String;
var
 paramname, paramvalue:String;
 p1,p2:integer;
begin
  Result := SQLText;
  while true do begin
  p1 := pos('{',SQLText);
  if p1>0 then begin
   p2 := pos('}', SQLText);
   if p2 = 0 then
    Raise Exception.Create('Invalid sql '+SQLText);
   ParamName := Copy(SQLText,p1+1,p2-p1-1);
   paramvalue := parser.GetVarValue(ParamName);
   Delete(SQLText, p1, p2-p1+1);
   Insert(ParamValue, SQLText, p1);
   Result := SQLText;
  end;
  if (p1=0) then break;
  end;
end;

Procedure TDbCall.AssignParamTypes(Q: TXDS);
Var
  i: integer;
  pname, LastDataType : String;
Begin
  For i := 0 To Q.CDS.params.count - 1 Do Begin
    pname := Q.CDS.Params[i].name;
    LastDataType := uppercase(GetFieldType(pname));
    If (LastDataType = 'C') and (q.CDS.Params[i].datatype <> ftstring) Then
      Q.CDS.params[i].DataType := ftString
    Else If (LastDataType = 'N') and (q.CDS.Params[i].datatype <> ftfloat) Then
      Q.CDS.params[i].DataType := ftfloat
    Else If (LastDataType = 'D') and (q.CDS.Params[i].datatype <> ftdatetime) Then
      Q.CDS.params[i].DataType := ftDateTime;
  End;
End;

Function TDbCall.GetFieldType(fname:String):String;
var kf :integer;
begin
  Result := 'c';
  kf := StoreData.GetFieldIndex(FName, 1);
  If kf >= 0 Then Begin
    Result := pFieldRec(StoreData.FieldList[kf]).DataType;
  End;
end;

function TDbCall.GetNextRow(f:String):integer;
var i:integer;
begin
  result := 0;
  for i:=0 to fnames.count-1 do begin
    if fnames[i]=f then inc(result);
  end;
end;

procedure TDbCall.CreateEventList;
var i : Integer;
    x : ixmlnode;
    eRec : pEventRec;
begin
  ActNode := struct.xml.DocumentElement.ChildNodes.FindNode('actions');
  EventList.Clear;
  if not assigned(ActNode) then
     ActNode := struct.xml.DocumentElement.ChildNodes.FindNode('scripts');
  if not assigned(ActNode) then exit;
  for i := 0 to ActNode.ChildNodes.Count-1 do begin
    x := ActNode.ChildNodes[i];
    if (vartostr(x.Attributes['apply']) = '') then continue;
    New(eRec);
    eRec.Event := vartostr(x.Attributes['apply']);
    eRec.Element := vartostr(x.Attributes['applyon']);
    eRec.Action := vartostr(x.NodeName);
    EventList.Add(eRec);
  end;

  ScriptNode := struct.xml.DocumentElement.ChildNodes.FindNode('scripts');
  if not assigned(ScriptNode) then exit;
  for i := 0 to ScriptNode.ChildNodes.Count-1 do begin
    x := ScriptNode.ChildNodes[i];
    if (vartostr(x.Attributes['apply']) = '') then continue;
    New(eRec);
    eRec.Event := vartostr(x.Attributes['apply']);
    eRec.Element := vartostr(x.Attributes['applyon']);
    eRec.Action := vartostr(x.NodeName);
    EventList.Add(eRec);
  end;

end;

function TDbCall.ExecuteAction(Event,Element:String) : String ;
var i : Integer;
    eRec : pEventRec;
    newact : boolean;
begin
  newact := false;
  if not assigned(act) then
  begin
    act:=TDoCoreAction.Create(axprovider);
    newact := true;
  end;
  act.SetParser(parser);
  act.stype := 'tstructs';
  act.sName := transid;
  act.StoreData := StoreData;
  act.RecId := FloatToStr(LastSavedId);
  dbm.gf.doDebug.Msg('Execute action from dbcall');
  for i := 0 to EventList.Count-1 do begin
    eRec := pEventRec(EventList[i]);
    if (lowercase(eRec.Event) = lowercase(Event)) then begin
      if Element <> '' then begin
        if lowercase(eRec.Element) <> lowercase(Element) then continue;
      end;
      act.root := actnode.ChildNodes.FindNode(eRec.Action);
      result := act.Execute;
      if copy(result,1,7) = '@error*' then begin
        ErrorStr := copy(result,8,Length(result));
        dbm.gf.dodebug.msg('Result from action after save : ' + ErrorStr);
      end else
       dbm.gf.dodebug.msg('Result from action after save : ' + result);
    end;
  end;
  act.ReSetParser;
  if newact then
  begin
    act.destroy;
    act:=nil;
  end;
end;

procedure TDbCall.DetailAddRow;
var drec : pDetailRec;
begin
  new(drec);
  drec.RowNo := DetailData.Count+1;
  drec.FList := TList.Create;
  drec.Recordid := 0;
  DetailData.Add(drec);
end;

procedure TDbCall.StoreDataToFList(RowNo:Integer);
var i : Integer;
    drec: pDetailRec;
    srec,trec:pFieldRec;
begin
  drec := DetailData[RowNo];
  for i := 0 to drec.FList.Count - 1 do
    Dispose(pFieldRec(drec.FList[i]));
  drec.FList.Clear;
  for i := 0 to Storedata.FieldList.Count - 1 do
  begin
    new(trec);
    srec := pFieldRec(Storedata.FieldList[i]);
    CopyRecordValue(srec,trec);
    drec.FList.Add(trec);
  end;
end;

procedure TDbCall.CopyRecordValue(frec,trec:pFieldRec);
begin
  trec.TableName := frec.TableName;
  trec.FieldName := frec.FieldName;
  trec.DataType := frec.DataType;
  trec.RowNo := frec.RowNo;
  trec.Value := frec.Value;
  trec.IdValue := frec.IdValue;
  trec.OldValue := frec.OldValue;
  trec.OldIdValue := frec.OldIdValue;
  trec.FrameNo := frec.FrameNo;
  trec.RecordId := frec.RecordId;
  trec.PrimaryTable := frec.PrimaryTable;
  trec.Orders := frec.Orders;
  trec.OldRow := frec.OldRow;
  trec.SourceKey := frec.SourceKey;
  trec.ParentRowNo := frec.ParentRowNo;
  trec.OldParentRow := frec.OldParentRow;
  trec.ZeroValue := frec.ZeroValue;
end;

procedure TDbCall.FListToStoreData(Rowno:Integer);
var i : Integer;
    drec: pDetailRec;
    srec,trec:pFieldRec;
begin
  for i := 0 to Storedata.FieldList.Count - 1 do
    Dispose(pFieldRec(Storedata.FieldList[i]));
  Storedata.FieldList.Clear;
  drec := DetailData[RowNo];
  for i := 0 to drec.FList.Count - 1 do
  begin
    new(trec);
    srec := pFieldRec(drec.FList[i]);
    CopyRecordValue(srec,trec);
    Storedata.FieldList.Add(trec);
  end;
end;

procedure TDbCall.SaveDetailStructs(mnode:ixmlnode);
var i : integer;
    drec : pDetailRec;
    mrecid : Extended;
    rnode : ixmlnode;
begin
  dbm.gf.DoDebug.msg('Executing dbcall SaveDetailStructs');
  for i := 0 to DetailData.Count - 1 do
  begin
    drec := pDetailRec(DetailData[i]);
    if (drec.FList.Count = 0) or (drec.RowNo = -1) then begin
      if drec.Recordid > 0 then begin
        FListToStoreData(i);
        mrecid := pDetailRec(DetailData[i]).Recordid;
        StoreData.SetRecid(mrecid);
        DeleteData(mrecid);
      end;
      continue;
    end;
    rnode := mnode.AddChild('row');
    rnode.Attributes['num'] := IntToStr(drec.RowNo);
    FlistToStoreData(i);
    StoreData.MasterRecord := MasterRecord;
    StoreData.SecondaryRecord := StrToFloat(SecRecList[drec.RowNo-1]);
    StoreData.SetRecid(drec.Recordid);
    ValidateAndSave;
    if ErrorStr <> '' then exit;
    StoreDataToFlist(i);
    StoreData.SetRecid(LastSavedid);
    LoadSDValue(rnode,StoreData);
    rnode.Attributes['recordid'] := FloatToStr(Storedata.GetParentDocId(1,1));
  end;
  dbm.gf.DoDebug.msg('Executed dbcall SaveDetailStructs');
end;

procedure TDbCall.SetRecordid(RowNo:Integer;Recid:Extended);
var i : Integer;
    drec: pDetailRec;
begin
  drec := DetailData[RowNo];
  drec.Recordid := RecId;
end;

procedure TDbCall.SaveAttachments;
var i : integer;
    fname,recid , tid :String;
begin
  if attachments <> '' then begin
    dbm.gf.dodebug.msg('Saving attachments');
    recid := FloatToStr(LastSavedid);
    i:=1;
    while true do begin
      fname:=dbm.gf.getnthstring(attachments,i);
      if fname='' then break;
      if struct.SchemaName <> '' then
         tid := struct.SchemaName + '.' +transid
         else tid := transid;
      Axprovider.SetAttachments(tid,recid,fname);
//      Axprovider.SetAttachments(struct.SchemaName+transid,recid,fname);
      inc(i);
    end;
  end;
end;

procedure TDBCall.SaveHistory(DeletedTrans,DetailStruct : Boolean;ParentTrackList : TStringlist);
begin
  Storedata.DetailStruct := DetailStruct;
  if DetailStruct then begin
    Storedata.SetChildTrackListToParent(ParentTrackList);
  end;
  StoreData.MakeList(DeletedTrans);
end;

procedure TDBCall.SaveHistoryTable(DeletedTrans : Boolean);              //ch1
begin
  StoreData.tracklist.Clear;
  if struct.track_chng then begin       // changed due to view history store on db   save
    Storedata.PrepareHistoryDetails(DeletedTrans)
  end
  else  begin
    StoreData.MakeList(DeletedTrans);
    Storedata.SaveHistoryToTable(DeletedTrans);
  end;
end;

function TDBCall.GetSubTotal(DetFldName:String;ParentRowNo:integer):Extended;
var tfld : pFld;
    popindex,i,ActualInd : integer;
    popgrid : pPopGrid;
begin
  result := 0;
  tfld := struct.GetField(DetFldName);
  if (tfld = nil) or (pfrm(struct.frames[tfld.Frameno-1]).PopIndex=-1) then exit;
  popindex := pfrm(struct.frames[tfld.Frameno-1]).PopIndex;
  popgrid := pPopgrid(struct.popgrids[popindex]);
  GetParentValue(PopIndex,ParentRowNo,ParentList);
  ActualRows.CommaText := GetActualRows(Popindex,ParentList);
  if ActualRows.Count = 0 then exit;
  DetFldName := lowercase(DetFldName);
  for i := 0 to StoreData.FieldList.Count - 1 do begin
    if (pFieldRec(StoreData.FieldList[i]).FrameNo <> popgrid.FrameNo) or
      (pFieldRec(StoreData.FieldList[i]).RowNo = -1) then continue;
    if DetFldName <> lowercase(pFieldRec(StoreData.FieldList[i]).FieldName) then continue;
    ActualInd := Actualrows.IndexOf(Trim(inttostr(pFieldRec(StoreData.FieldList[i]).RowNo)));
   	If ActualInd >= 0 then
      result := result + dbm.gf.strtofloatz(pFieldRec(StoreData.Fieldlist[i]).value);
  end;
end;

function TDBCall.GetSubDelimitedStr(DetFldName,Delimiter,Quoted:String;ParentRowNo:integer):String;
var tfld : pFld;
    popindex,i,ActualInd : integer;
    popgrid : pPopGrid;
begin
  result := '';
  tfld := struct.GetField(DetFldName);
  if (tfld = nil) or (pfrm(struct.frames[tfld.Frameno-1]).PopIndex=-1) then exit;
  popindex := pfrm(struct.frames[tfld.Frameno-1]).PopIndex;
  popgrid := pPopgrid(struct.popgrids[popindex]);
  GetParentValue(PopIndex,ParentRowNo,ParentList);
  ActualRows.CommaText := GetActualRows(Popindex,ParentList);
  if ActualRows.Count = 0 then exit;
  DetFldName := lowercase(DetFldName);
  Quoted := lowercase(quoted);
  if delimiter = '' then delimiter := ',';
  for i:=0 to StoreData.fieldlist.count-1 do begin
    if (pFieldRec(StoreData.FieldList[i]).FrameNo <> popgrid.FrameNo) or
     (pFieldRec(StoreData.FieldList[i]).RowNo = -1) then continue;
    if DetFldName <> lowercase(pFieldRec(StoreData.FieldList[i]).FieldName) then continue;
    ActualInd := Actualrows.IndexOf(Trim(inttostr(pFieldRec(StoreData.FieldList[i]).RowNo)));
   	If ActualInd >= 0 then begin
      if Quoted = 't' then
         result := result + quotedstr(pFieldRec(StoreData.Fieldlist[i]).value)+delimiter
      else
         result := result + pFieldRec(StoreData.Fieldlist[i]).value+delimiter;
    end;
  end;
  if result <> '' then begin
    result := copy(result,1, length(result)-length(delimiter));
    if Quoted = 't' then
      axprovider.dbm.gf.UsedQuotedStr := True;
  end;
end;

Procedure TDBCall.GetParentValue(popindex,rowno:integer;sList:TStrings);
var pFields,pField,val,fno,fname:String;
    i : Integer;
    tfld : pfld;
begin
  dbm.gf.DoDebug.msg('Getting values of parent fields');
  sList.Clear;
  i := 1;
  pFields := pPopGrid(struct.popgrids[popindex]).ParentField;
  pField := Trim(dbm.gf.GetNthString(pFields,i));
  fno := Trim(IntToStr(pPopGrid(struct.popgrids[popindex]).FrameNo));
  while pField <> '' do begin
    fname := 'sub'+fno+'_'+pField;
    tfld := struct.GetField(fname);
    if tfld <> nil then
      fname := tfld.FieldName;
    val := Storedata.GetFieldValue(pField,RowNo);
    if tfld.DataType = 'n' then
      val := FormatNumericdata(tfld,val);
    sList.Add(fname+'='+val);
    dbm.gf.DoDebug.msg('Gettin parent value - '+fname+'='+val);
    inc(i);
    pField := Trim(dbm.gf.GetNthString(pFields,i));
  end;
end;

Function TDBCall.GetActualRows(popindex:integer;PList:TStringList):String;
var rc : Integer;
    i,j : integer;
    ValidRow : Boolean;
    tfld : pFld;
    val : String;
begin
  dbm.gf.DoDebug.msg('Getting acutalrows of popupform');
  rc := StoreData.GetRowCount(pPopGrid(struct.popgrids[popindex]).FrameNo);
  result := '';
  for i := 1 to rc do begin
    ValidRow := False;
    for j := 0 to PList.Count - 1 do begin
      tfld := struct.GetField(PList.Names[j]);
      if tfld.DataType = 'n' then begin
        if strtofloat(Storedata.GetFieldValue(PList.Names[j],i)) <> strtofloat(PList.ValueFromIndex[j]) then begin
          ValidRow := False;
          Break;
        end else ValidRow := True;
      end else begin
        if Storedata.GetFieldValue(PList.Names[j],i) <> PList.ValueFromIndex[j] then begin
          ValidRow := False;
          Break;
        end else ValidRow := True;
      end;
    end;
    if ValidRow then result := Result+','+Trim(IntToStr(i));
  end;
  Delete(result,1,1);
end;

function TDBCall.FormatNumericData(fld1:pfld;txt:String):String;
var s,s1 : String;
    cpos,i,l : Integer;
begin
  s := Trim(txt);
  if (s = '') then s := '0';
  if (fld1.Dec = 0) then begin
    result := s;
    exit;
  end;
  cpos := pos('.',s);
  if ( cpos = 0) then begin
    s1 := '.';
    for i := 1 to fld1.Dec do
      s1 := s1+'0';
  end else begin
    s1 := copy(s,cpos+1,100);
    s := copy(s,1,cpos);
    l := Length(s1)+1;
    for i := l to fld1.Dec do
      s1 := s1+'0';
  end;
  s := s+s1;
  result := s;
end;

function TDBCall.GetSubValue(FieldName:String;RowNo,ParentRowNo:integer):String;
var  rno,popindex : Integer;
     tfld : pFld;
begin
  result := '';
  tfld := struct.GetField(FieldName);
  if (tfld = nil) or (pfrm(struct.frames[tfld.Frameno-1]).PopIndex=-1) then exit;
  popindex := pfrm(struct.frames[tfld.Frameno-1]).PopIndex;
  GetParentValue(PopIndex,ParentRowNo,ParentList);
  ActualRows.CommaText := GetActualRows(Popindex,ParentList);
  if (ActualRows.Count = 0) or (ActualRows.Count < RowNo) then exit;
  rno := StrToInt(ActualRows[RowNo-1]);
  result := StoreData.GetFieldValue(FieldName,rno);
end;

function TDBCall.GetSubRow(FieldName,FieldValue:String;ParentRowNo:integer):Integer;
var  i,ActualInd,popindex : Integer;
    popgrid : pPopGrid;
    tfld : pFld;
begin
  result := -1;
  tfld := struct.GetField(FieldName);
  if (tfld = nil) or (pfrm(struct.frames[tfld.Frameno-1]).PopIndex=-1) then exit;
  popindex := pfrm(struct.frames[tfld.Frameno-1]).PopIndex;
  popgrid := pPopgrid(struct.popgrids[popindex]);
  GetParentValue(popindex,ParentRowNo,ParentList);
  ActualRows.CommaText := GetActualRows(popindex,ParentList);
  if (ActualRows.Count = 0) then exit;
  FieldName := lowercase(FieldName);
  for i := 0 to StoreData.FieldList.Count - 1 do begin
    if (pFieldRec(StoreData.FieldList[i]).FrameNo <> popgrid.FrameNo) or
      (pFieldRec(StoreData.FieldList[i]).RowNo = -1) then continue;
    if FieldName <> lowercase(pFieldRec(StoreData.FieldList[i]).FieldName) then continue;
    ActualInd := Actualrows.IndexOf(Trim(inttostr(pFieldRec(StoreData.FieldList[i]).RowNo)));
   	If ActualInd >= 0 then begin
      if pFieldRec(StoreData.FieldList[i]).DataType = 'n' then begin
        if dbm.gf.strtofloatz(FieldValue) =  dbm.gf.strtofloatz(pFieldRec(StoreData.Fieldlist[i]).value) then begin
          //Result := ActualInd+1;
          result:=pFieldRec(StoreData.FieldList[i]).RowNo;
          Break;
        end;
      end else begin
        if FieldValue =  pFieldRec(StoreData.Fieldlist[i]).value then begin
          //Result := ActualInd+1;
          result:=pFieldRec(StoreData.FieldList[i]).RowNo;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TDBCall.InitGrid(FrameNo:integer);
var i,r:integer;
    init : boolean;
begin
  dbm.gf.DoDebug.msg('Executing Initgrid' );
  if (frameno > struct.frames.count) or (frameno < 1) then exit;
  If (not pfrm(struct.frames[FrameNo-1]).AsGrid) Then exit;
  if struct.quickload then StoreData.depCall := false;
  r := storedata.GetRowCount(frameno);
  if r =0 then r := 1;
  init := true;
  for i:=1 to r do
  begin
    StoreData.DeleteRow(frameno,1,init);
    if not init then continue;
    init := false;
  end;
  if dbm.gf.IsService then
  begin
    For i := storedata.RecordIdList.Count - 1 downto 0 do
    begin
    If (StrToInt(trim(Copy(storedata.RecordIdList[i], 1, 3))) = FrameNo) Then
       storedata.RecordIdList.Delete(i);
    end;
  end;
  if struct.quickload then StoreData.depCall := true;
end;

function TDbCall.ValidateData:String;
begin
  TransDetails := '';
  ErrorStr := '';
  result := '';
//  ExecuteFillGrid;
  TrimExtraRows;
  DataValidate('s', true);
  if errorstr = '' then ValidateImageFlds;
  if errorstr <> '' then begin
    result:=errorstr;
    dbm.gf.dodebug.Msg('Validate error msg : ' + result);
    MakeDetailStr;
    dbm.gf.dodebug.Msg('Validate error msg1 : ' + result);
    clear;
    dbm.gf.dodebug.Msg('Validate error msg2 : ' + result);
  end else
  begin
    if not FromSync then
      StoreData.UpdateNonGridRecordId; //used for web to update recordid for nonsubmitted fields from client.
  end;

end;

function TDbCall.ValidateFrame(fno:integer):String;
var rcount,r,c,k : integer;
    tfld : pfld;
    v : String;
begin
  if not pfrm(struct.frames[fno-1]).AsGrid then exit;
  rcount:=storedata.GetRowCount(fno);
  for r:=1 to rcount do begin
    validate.RegRow(fno, r);
    validate.ActualRowNo := r;
    for c:=0 to struct.flds.count-1 do begin
      tfld := pfld(struct.flds[c]);
      if tfld.FrameNo < fno then continue;
      if tfld.FrameNo > fno then break;
      validate.EnterField(tfld.FieldName, r);
      v := storedata.GetFieldValue(tfld.FieldName, r);
      validate.ExitField(tfld.FieldName, r, v, 0);
      k:=storedata.GetFieldIndex(tfld.FieldName, r);
      if pfieldrec(storedata.FieldList[k]).DataType = 'n' then begin
        if (strtofloat(pfieldrec(storedata.FieldList[k]).Value)=0) then
          storedata.FieldList.Delete(k);
      end;
    end;
  end;
end;

Procedure TDbCall.DoFillGridRefresh(fno:integer);
var c,i,r,k,j:integer;
    fd,tfd : pfld;
begin
  dbm.gf.dodebug.Msg('DoFillGridRefresh');
  if RefreshInLoadDc then exit;
  dbm.gf.dodebug.Msg('Refreshing frame '+inttostr(fno));
  r:=storedata.getrowcount(fno);
  for k := 1 to r do begin
    dbm.gf.dodebug.Msg('Refreshing row '+inttostr(k));
    validate.regrow(fno, k);
    for j := 0 to struct.flds.count - 1 do begin
      if pfld(struct.flds[j]).frameno<>fno then continue;
      dbm.gf.dodebug.Msg('Field '+pfld(struct.flds[j]).fieldname);
      validate.RefreshField(pfld(struct.flds[j]), k);
    end;
  end;
  GridDependentFields := '';
  for c:=0 to struct.flds.count-1 do begin
    fd := pfld(struct.flds[c]);
    if fd.FrameNo < fno then continue;
    if fd.FrameNo > fno then break;
    if (not assigned(fd.deps))then continue;
    for i := 0 to fd.deps.Count - 1 do begin
      tfd:=struct.GetField(fd.deps[i]);
      if tfd = nil then continue;
      if tfd.FrameNo = fd.FrameNo then continue;
      if pos(','+tfd.FieldName+',', GridDependentFields) > 0 then continue;
      GridDependentFields:=GridDependentFields + tfd.FieldName+',';
      if tfd.AsGrid then
      begin
         k := StoreData.RowCount(tfd.FrameNo);
         for r := 1 to k do
         begin
           if pfrm(struct.frames[tfd.FrameNo-1]).popup then
              Validate.GetParentActiveRow(r,pfrm(struct.frames[tfd.FrameNo-1]).popindex)
           else
              Validate.Parser.Registervar('activeprow', Char('n'), inttostr(r));
           Validate.RegRow(tfd.FrameNo , r);
           Validate.RefreshField(tfd,r,true);
         end;
      end else Validate.RefreshField(tfd,1);
    end;
  end;
  GridDependentFields := '';
  dbm.gf.dodebug.Msg('DoFillGridRefresh Completed');
end;

Procedure TDbCall.DoFillGridRefreshNew(fm : pFrm);
  var i,j,k,r : integer;
      s : string;
      fd,dfd : pFld;
begin
  dbm.gf.dodebug.Msg('DoFillGridRefresh');
  GridDependentFields := '';
  for i := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
    fd:=pfld(struct.flds[i]);
    if not assigned (fd.Dependents) then continue;
    for j := 0 to fd.Dependents.count-1 do begin
      dfd:=struct.getfield(fd.Dependents[j]);
      if (not assigned(dfd) or (dfd.FrameNo=fd.FrameNo)) then continue;
      if pos(','+dfd.FieldName+',', GridDependentFields) > 0 then continue;
      GridDependentFields:=GridDependentFields + dfd.FieldName+',';
      if dfd.AsGrid then
      begin
         k := StoreData.RowCount(dfd.FrameNo);
         for r := 1 to k do
         begin
           if fm.Popup then
              Validate.GetParentActiveRow(r,fm.popindex)
           else
              Validate.Parser.Registervar('activeprow', Char('n'), inttostr(r));
           Validate.RegRow(dfd.FrameNo , r);
           Validate.RefreshField(dfd,r,true);
         end;
      end else Validate.RefreshField(dfd,1,true);
    end;
  end;
  GridDependentFields := '';
  dbm.gf.dodebug.Msg('DoFillGridRefresh Completed');
end;

procedure TDBCall.Createpkt(q:txds; pktfile:String);
var xml:ixmldocument;
    n,x:ixmlnode;
    cname, fname, op:String;
    i,k:integer;
    recid : extended;
begin
  //creating data XML
  xml:=LoadXMLData('<root></root>');
  xml.documentelement.attributes['transid']:=q.cds.fieldbyname('totransid').asstring;
  xml.documentelement.attributes['user']:=q.cds.fieldbyname('username').asstring;
  xml.documentelement.Attributes['sessionid']:=inttostr(dbm.gf.siteno);
  xml.documentelement.Attributes['recordid']:=q.cds.fieldbyname('recordid').asstring;
  xml.documentelement.Attributes['siteno']:=inttostr(dbm.gf.siteno);
  xml.documentelement.Attributes['pktid']:=q.cds.fieldbyname('pktid').asstring;
  xml.documentelement.Attributes['detstruct']:='f';
  xml.documentelement.Attributes['dettname']:='';
  xml.documentelement.Attributes['mastrec']:='0';
  xml.documentelement.Attributes['secrec']:='0';
  op:=q.cds.fieldbyname('action').asstring;
  recid:=q.cds.fieldbyname('recordid').asfloat;
  if op = 'd' then
    xml.documentelement.Attributes['deltrans'] := 'true'
  else if op = 'c' then
    xml.documentelement.Attributes['cancel'] := 'true'
  else begin
    Clear;
    xml.documentelement.Attributes['deltrans'] := '';
    xml.documentelement.Attributes['cancel'] := '';
    storedata.LoadTrans(recid);
    for i:=0 to storedata.fieldlist.count-1 do begin
      k := struct.GetFieldIndex(pfieldrec(storedata.fieldlist[i]).FieldName);
      if (k=-1)  then continue;
      x := xml.DocumentElement.AddChild(pfieldrec(storedata.fieldlist[i]).FieldName);
      if (pfieldrec(storedata.fieldlist[i]).DataType='d') and (pfieldrec(storedata.fieldlist[i]).value<>'') then
        x.NodeValue:= dbm.gf.ConvertToDBDateTime(dbm.connection.dbtype,strtodatetime(pfieldrec(storedata.fieldlist[i]).value))
      else
        x.NodeValue := pfieldrec(storedata.fieldlist[i]).value;
      x.Attributes['recordid'] := pfieldrec(storedata.fieldlist[i]).RecordId;
      x.Attributes['rowno'] := pfieldrec(storedata.fieldlist[i]).RowNo;
      x.Attributes['idvalue'] := pfieldrec(storedata.fieldlist[i]).IdValue;
      x.Attributes['fno'] := pfieldrec(storedata.fieldlist[i]).FrameNo;
      x.Attributes['tname'] := pfieldrec(storedata.fieldlist[i]).TableName;
      x.Attributes['oval'] := pfieldrec(storedata.fieldlist[i]).OldValue;
      x.Attributes['oidval'] := pfieldrec(storedata.fieldlist[i]).OldIdValue;
      x.Attributes['orowno'] := pfieldrec(storedata.fieldlist[i]).OldRow;
    end;
    x := xml.DocumentElement.AddChild('rec___ids');
    for i := 0 to storedata.recordidlist.Count-1 do begin
      n := x.AddChild('l');
      n.Attributes['fno'] := trim(Copy(storedata.RecordIdList[i], 1, 3));
      n.Attributes['rno'] := trim(Copy(storedata.RecordIdList[i], 4, 5));
      n.Attributes['recid'] := trim(Copy(storedata.RecordIdList[i], 9, dbm.gf.MaxRecid));
      n.Attributes['tn'] := trim(Copy(storedata.RecordIdList[i], dbm.gf.MaxRecid+9, 100));
    end;
    x := xml.DocumentElement.AddChild('def___flds');
    n := x.AddChild('l');
    n.Attributes['createdby'] := storedata.CreatedBy;
    n.Attributes['createdon'] := storedata.CreatedOn;
    n.Attributes['username'] := storedata.SUserName;
    n.Attributes['modifiedon'] := storedata.SModifiedOn;
    n.Attributes['siteno'] := storedata.SSiteNo;
  end;

  fname:=dbm.gf.startpath+q.CDS.fieldbyname('pktdate').asstring+'.xml';
  if not xml.IsEmptyDoc then begin
    xml.SaveToFile(fname);
    with TCompress.create do begin
      compressfile(fname, pktfile);
      destroy;
    end;
    deletefile(fname);
  end;
end;

function TDbCall.ExecuteEventAction(Event,Element:String) : String ;
var i,j : Integer;
    eRec : pEventRec;
    anode,pnode : ixmlnode;
    sl : TStringList;
    s : string;
begin
  result := '';
  anode := nil;
  for i := 0 to EventList.Count-1 do begin
    eRec := pEventRec(EventList[i]);
    if (lowercase(eRec.Event) = lowercase(Event)) then begin
      if Element <> '' then begin
        if lowercase(eRec.Element) <> lowercase(Element) then continue;
      end;
       if assigned(actnode) then anode := actnode.ChildNodes.FindNode(eRec.Action);
      if (anode = nil) then 
         if assigned(ScriptNode) then anode := ScriptNode.ChildNodes.FindNode(eRec.Action); 
      if (anode = nil) or (anode.childnodes.count = 0) then break;
      pnode := anode.ChildNodes[0];
      if pnode.ChildNodes.count = 0 then break;
      if ((vartostr(pnode.Attributes['op']) = '5')) and
      ((lowercase(vartostr(pnode.Attributes['task'])) = 'user defined task') or
        (lowercase(vartostr(pnode.Attributes['task'])) = 'scripts'))then begin
        pnode := pnode.childNodes[0];
        if pnode.ChildNodes.count = 0 then break;
        BreakOnError := (vartostr(anode.Attributes['breakonerror'])= 'yes');
        pnode := pnode.ChildNodes[0];
        try
          EventActs := true;
          sl := TStringList.Create;
          for j := 0 to pnode.ChildNodes.Count-1 do
            sl.Add(vartostr(pnode.ChildNodes[j].NodeValue));
          Parser.OnSQLPost := SQLPost;
          Parser.OnFill := OnFill;
          if assigned(act) then Parser.OnNotify := act.Notify;
          Parser.ExprSet := sl;
          Parser.EvalExprSet(0);
          if (Parser.ExpSqlFileName <> '') or (Parser.FilesGeneratedByFunctions <> '') then
          begin
           if Parser.ExpSqlFileName <> '' then s := Parser.ExpSqlFileName + ',' + Parser.FilesGeneratedByFunctions
           else s := Parser.FilesGeneratedByFunctions;
           delete(s,length(s),1);
           createcmdnode('openfile',s);
           cmdnode := cmdnode + '},';
          end;
        finally
          if assigned(sl) then
          begin
            sl.clear;
            FreeAndNil(sl);
            EventActs := false;
          end;
        end;
        break;
      end else break;
    end;
  end;
  anode := nil;
end;

procedure TDbCall.createcmdnode(cmd,val : string);
  var i : integer;
begin
  cmdnode := cmdnode + '{"cmd":"'+cmd+'","cmdval":"'+val+'"';
end;
function TDbCall.SQLPost(SQLText, Target, GroupField, PrimaryField: String;SQLName:String=''): String;
var imp : TImport;
    f:TextFile;
    s,s2 : String;
begin
  result := '' ;
  if Trim(SQLText) = '' then exit;
  try
    imp:=TImport.create(axprovider);
    imp.csflist.clear;
    imp.AsUserDefinedTask := True;
    imp.EventActs := EventActs;
    imp.MainValidate := Validate;
    imp.PrimaryId := Validate.StoreData.LastSavedRecordId;
    imp.SQLName := SQLName;
    imp.actSqlpost := True;
    imp.breakonerror := BreakOnError;
    imp.ReadFromSqlResult(SQLText, Target, GroupField, PrimaryField,'');
  except
     on e:exception do begin
        if assigned(axprovider) then
            axprovider.dbm.gf.DoDebug.Log(axprovider.dbm.gf.Axp_logstr+'\uDbcall\SQLPost - '+e.Message);
        if Assigned(imp.TempXDS) then
        begin
          imp.TempXDS.close;
          imp.TempXDS.Free;
          imp.TempXDS := nil;
        End;
        if assigned(imp) then begin
          imp.Destroy;
          imp := nil;
        end;
        result := '@error*'+e.Message+' in '+Target;
        exit;
     end;
  end;
  if assigned(imp) then begin
    imp.Destroy;
    imp := nil;
  end;
  result := '';
end;

Procedure TDbCall.CopyTrans(pRecordId:Extended);
var CopySD : TStoreData;
    CopyValidate : TValidate;
    tRec : pFieldRec;
    slist:TStringList;
    i : integer;
begin
  try
    dbm.gf.dodebug.msg('Copying record');
    CopySD := TStoreData.Create(struct, transid);
    CopyValidate := TValidate.Create(axprovider);
    CopyValidate.Parser.Destroy;
    CopyValidate.freeparser := false;
    CopyValidate.Parser := Parser;
    CopyValidate.sdef := Struct;
    CopyValidate.StoreData := CopySD;
    CopyValidate.Loading := true;
    CopySD.LoadTrans(pRecordId);
    CopyValidate.Validation := false;
    CopyValidate.FillAndValidate(true);
    if CopyValidate.ErrorStr <> '' then begin
      dbm.gf.dodebug.Msg('Copy Trans Validate error msg : ' + CopyValidate.ErrorStr);
//      exit;
      dbm.gf.ErrorInActionExecution := CopyValidate.ErrorStr;
    end;

    for i := 0 to CopySD.FieldList.Count - 1 do begin
      trec := pFieldRec(CopySD.FieldList[i]);
      storedata.SubmitValue(trec.FieldName,trec.RowNo,trec.Value,'',trec.IdValue,0,0);
    end;
    StoreData.ins_del_rows.Text := CopySD.ins_del_rows.Text;
    CopySD.ins_del_rows.Clear;
    slist:=SaveDataRows;
    if assigned(CopySD) then begin
      CopySD.Destroy; CopySD:=nil;
    end;
    if assigned(CopyValidate) then begin
      CopyValidate.Destroy; CopyValidate:=nil;
    end;
    Dbm.gf.CopyTrans := true;
  except on e:Exception do
    begin
      if assigned(axprovider) then
          axprovider.dbm.gf.DoDebug.Log(axprovider.dbm.gf.Axp_logstr+'\uDbcall\CopyTrans - '+e.Message);
      if assigned(CopySD) then begin
        CopySD.Destroy; CopySD:=nil;
      end;
      if assigned(CopyValidate) then begin
        CopyValidate.Destroy; CopyValidate:=nil;
      end;
    end;
  end;
  RestoreDataRows(slist);
  slist.free;
end;

function TDbCall.ReSaveData():String;
begin
  dbm.StartTransaction(dbm.gf.connectionname);
  result:=ValidateAndSave;
  if errorstr <> '' then begin
    result := errorstr;
    dbm.RollBack(dbm.gf.connectionname);
  end else begin
    dbm.Commit(dbm.gf.connectionname);
  end;
end;

Procedure TDbCall.WorkFlowAction;
begin
  dbm.gf.dodebug.Msg('Workflow status : ' + WorkFlow.AppStatus);
  if WorkFlow.AppStatus = 'Approved' then begin
    ProvideLink.WorkFlow := 'approve';
    MDMap.WorkFlow:='approve';
    ExecuteEventAction('On Approve','');
  end else if (WorkFlow.AppStatus = 'Created') or (WorkFlow.AppStatus = 'Modified') then begin
    ExecuteEventAction('On Create','')
  end else if WorkFlow.AppStatus = 'Approve' then begin
    ExecuteEventAction('On Every Approve','');
  end else if WorkFlow.AppStatus = 'Rejected' then begin
    ProvideLink.workflow := 'reject';
    MDMap.WorkFlow:='reject';
    ExecuteEventAction('On Reject','');
  end else if WorkFlow.AppStatus = 'Return' then begin
    ExecuteEventAction('On Return','');
  end;
end;

procedure TDbCall.NewTrans;
begin
  if not assigned(storedata) then exit;
  parser.RegisterVar('recordid','n','0');
  Validate.parser.RegisterVar('recordid','n','0');
  StoreData.ClearFieldList;
  StoreData.RecordIdList.Clear;
  StoreData.ins_del_rows.Clear;
  Dbm.gf.NewTrans := true;
end;

Procedure TDbCall.CancelData(ModifyRecordId:Extended;Rem:String);
Var status : String;
Begin
  validate.Validation:=true;
  status := Storedata.canDeleteTrans;
  if status <> '' then EDatabaseError.Create(status);
  if assigned(ProvideLink) and (providelink.StoreDataList.Count>0) then inc(dbm.gf.TransCheckCount);
  Storedata.SetRecid(ModifyRecordid);
  StoreData.CancelTrans(Rem);
  If assigned(ProvideLink) Then Begin
    ProvideLink.CancelTrans := true;
    If Not ProvideLink.DeleteLinkTrans(ModifyRecordId) Then
      Raise EDataBaseError.Create('Could not delete link document(s)');
    ProvideLink.CancelTrans := false;
  End;
  MDMap.DoUpdate;
  DoEvalExprSet('', 'aftercancel');
  status := parser.getvarvalue('aftercancelstatus');
  if status <> '' then begin
    if status[1] = '_' then //showmessage(copy(status, 2, length(status)))
    else if lowercase(status) <> 't' then raise EDataBaseError.create(status);
  end;
  ExecuteAction('After cancel transaction','');

  if (assigned(ProvideLink)) and (providelink.StoreDataList.Count>0) then
  begin
    if not AxProvider.ValidateTransCheck then
       raise Exception.Create('Database connection lost. Please cancel the transaction again.');
  end;

  dbm.gf.DoDebug.msg('Completed Cancellation');
End;

function TDbCall.DoPopup(FrameNo, RowNo:Integer):boolean;
var popgrid:pPopGrid;
    i:integer;
begin
  result := false;
  popgrid:=nil;
  for i := 0 to struct.popgrids.count-1 do begin
    if pPopGrid(struct.popgrids[i]).FrameNo=FrameNo then begin
      popgrid:=pPopGrid(struct.popgrids[i]);
      break;
    end;
  end;
  if (not assigned(popgrid)) then exit;
  dbm.gf.DoDebug.msg('Refresh popup '+IntTostr(PopGrid.FrameNo)+' Parent row '+IntToStr(RowNo));

  if popgrid.FirmBind then
  begin
    result:=Validate.FillPopupAll(popgrid.FrameNo,rowno);
    pFrm(struct.frames[FrameNo-1]).HasDataRows := true;
  end else begin
    if Validate.IsParentFieldsBound(popgrid.FrameNo,rowno) then begin
      result := Validate.PopupAutoFill(popgrid,rowno);
      pFrm(struct.frames[FrameNo-1]).HasDataRows := result;
    end;
  end;
end;

function TDbCall.RefreshField(FldName:String;RowNo:Integer) : String;
var i,rc : integer;
    fld : pfld;
begin
  result := '';
  if RowNo < 0 then exit;
  fld := StoreData.Structdef.GetField(FldName);
  if assigned(fld) then
  begin
    if (fld.AsGrid) then
    begin
      if RowNo = 0 then
      begin
        rc := Storedata.GetRowCount(fld.FrameNo);
        for i := 1 to rc do
        begin
          Validate.RegRow(fld.FrameNo,i);
          Validate.RefreshField(fld,i)
        end;
      end else Validate.RefreshField(fld,RowNo);
    end else
    begin
      if (Rowno = 0) or (RowNo = 1) then
        Validate.RefreshField(fld,1);
    end;
  end;
end;

procedure TDbCall.OnFill(xmlStr:String);
var fxml : ixmldocument;
    fs : TFillStruct;
begin
  TRY
    fxml := LoadXMLData(xmlStr);
    fs := TFillStruct.Create;
    fs.axp := axprovider;
    fs.validate := Validate;
    fs.StoreData := StoreData;
    fs.NewTrans := StoreData.NewTrans;
    fs.ActionNode := fxml.DocumentElement;
    fs.Fill;
    fs.Destroy;
    fs := nil;
    fxml := nil;
  except on e:exception do
    begin
      fs.Destroy;
      fs := nil;
      fxml := nil;
      raise exception.Create(e.message);
    end;
  end;
end;

Procedure TDbCall.AutoGenToDB;
var i : integer;
    arec : pAutoGenRec;
    s : String;
    ModTable : TXDS;
begin
  for i := 0 to Axprovider.dbm.gf.AutoGenData.Count - 1 do
  begin
    arec := pAutoGenRec(Axprovider.dbm.gf.AutoGenData[i]);
    if arec.RType = 'mod' then continue;    
    Parser.AutoGenPost(arec,Axprovider);
    if (arec.transid = storedata.transtype) then
    begin
      Storedata.SubmitValue(arec.FieldName,arec.Rowno,arec.Value,'',0,0,arec.RecordId);
      ModTable := Axprovider.dbm.GetXDS(nil);
      Modtable.Edit(arec.Schema+arec.TableName,arec.TableName+'id='+FloatToStr(arec.RecordId));
      s := Validate.RefreshAutoGen(ModTable,arec.Fieldname, arec.value);
      if s<>'' then begin
        Modtable.Destroy;
        Raise EDataBaseError.Create(s);
      end;
      ModTable.Post;
      ModTable.Destroy;
    end;
  end;
end;

function TDbCall.SaveDataRows:TStringList;
var i:integer;
begin
  Result:=TStringList.create;
  for i := 0 to struct.flds.Count - 1 do
    Result.add(pFld(struct.flds[i]).datarows.commatext);
end;

Procedure TDbCall.RestoreDataRows(RowList:TStringList);
var i:integer;
begin
  for i := 0 to struct.flds.Count - 1 do
    pFld(struct.flds[i]).datarows.CommaText:=RowList[i];
end;

procedure TDbCall.RefreshFrame(FrmNo:Integer);
var j,r,rcount : integer;
    fd : pfld;
    fm : pFrm;
begin
  dbm.gf.dodebug.msg('Refresh frame : '+Inttostr(FrmNo));
  fm:=pFrm(Struct.Frames[FrmNo-1]);
  rcount:=StoreData.RowCount(fm.FrameNo);
  for r := 1 to rcount do begin
    validate.RegRow(FrmNo, r);
    for j := fm.StartIndex to fm.StartIndex+fm.FieldCount - 1 do begin
      fd:=pFld(struct.flds[j]);
      validate.RegRow(fd.FrameNo,r);
      if (fd.ModeofEntry = 'autogenerate') then begin
        if storedata.LastSavedRecordId = 0 then
          validate.RefreshField(fd,r);
      end else
          validate.RefreshField(fd,r);
    end;
  end;
end;


//Added on 13/06/2013
Procedure TDbCall.RegWFFields;
var
  Tfld : pFld;
  WFStr,Str,LFld,RFld,FldVal: String;
  I,StrPos : Integer;
Begin
   Tfld := struct.GetField('Axp_WorkFlowFields');
   if not  assigned(tfld) then exit;
   I := 1;
   WFStr := Storedata.GetFieldValue('Axp_WorkFlowFields',1);
   Str := AxProvider.dbm.gf.GetNthString(WFStr,I);
   While (Str <> '') do
   begin
    StrPos := Pos('=',Str);
    LFld := Trim(Copy(Str,1,StrPos-1));
    RFld := Trim(Copy(Str,StrPos+1,Length(Str)));
    if (Trim(LFld)<> '') and (Trim(RFld) <> '' )then
    begin
      Tfld := struct.GetField(RFld);
      if assigned(tfld) then begin
        FldVal := Storedata.GetFieldvalue(RFld,1);
        Parser.RegisterVar(LFld,Tfld.Datatype[1],FldVal);
      end;
    end;
    inc(I);
    Str := AxProvider.dbm.gf.GetNthString(WFStr,I);
   end;
End;

Procedure TDbCall.BeforeEventProc(RecValidate:TValidate);
Begin
  Validate := RecValidate;
End;

Procedure TDbCall.AfterEventProc;
begin
  Validate := MainValidate;
end;

function TDbCall.EnableApprovalBar(ModifyRecordId:Extended):Boolean;
var EnableTBar : Boolean;
    btnStr : String;
    i : integer;
begin
  result := false;
  EnableTBar := WorkFlow.EnableToolbar(Transid,FloatToStr(ModifyRecordid),struct.PrimaryTable);
  dbm.gf.dodebug.Msg('Assigning approval bar');
  if EnableTBar then begin
    dbm.gf.dodebug.Msg('Assigned approval bar');
    if not assigned(ApprovalNode) then
      ApprovalNode := struct.XML.CreateNode('approval',ntElement,'') ;
    btnStr := '';
    dbm.gf.dodebug.Msg('Before Constructing WActList');
    dbm.gf.dodebug.Msg('Value:'+inttostr(WorkFlow.WActList.Count));
    for i := 0 to WorkFlow.WActList.Count - 1 do begin
      dbm.gf.dodebug.Msg('ApprovalNode : ' + WorkFlow.WActList[i]);
      if lowercase(WorkFlow.WActList[i]) = 'approve' then
        btnStr := btnStr+'a' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'reject' then
        btnStr := btnStr+'r' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'return' then
        btnStr := btnStr+'t' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'review' then
        btnStr := btnStr+'v' + '~'
    end;
    ApprovalNode.Attributes['btn'] := btnStr;
    ApprovalNode.Attributes['status'] := WorkFlow.StrStatus;
    ApprovalNode.Attributes['appstatus'] := WorkFlow.AppStatus;
    ApprovalNode.Attributes['lno'] := Trim(IntToStr(WorkFlow.Wapplevel));
    ApprovalNode.Attributes['elno'] := Trim(IntToStr(WorkFlow.EnblApplevel));
    if Workflow.AllowEdit then
       ApprovalNode.Attributes['allowedit'] := 'true'
    else
       ApprovalNode.Attributes['allowedit'] := 'false';
    if Workflow.AllowCancel then
       ApprovalNode.Attributes['allowcancel'] := 'true'
    else
       ApprovalNode.Attributes['allowcancel'] := 'false';
    if (lowercase(WorkFlow.AppStatus) = 'approved') and (not Workflow.AllowEdit) then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else if not workflow.EnabledTrans then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else
      ApprovalNode.Attributes['readonlyform'] := 'false';
    dbm.gf.dodebug.Msg('ApprovalNode : ' + ApprovalNode.XML);
  end;
  result := EnableTBar;
end;

Procedure TDbCall.FillOnLoad(SQLText:String);
var lxds : TXDS;
    i,j,rno : integer;
    ErrMsg,val : String;
begin
  AxProvider.dbm.gf.dodebug.msg('Executing FillOnLoad');
  try
  lxds := Axprovider.dbm.GetXds(nil);
  lxds.buffered := True;
  lxds.cds.commandtext := SQLText;
  Validate.DynamicSQL := lxds.cds.commandtext;
  Validate.QueryOpen(lxds,1);
  for i := 0 to lxds.CDS.Params.Count-1 do  begin
    val := Parser.GetVarValue(lxds.CDS.Params[i].Name);
    lxds.AssignParam(i,val,parser.LastVarType);
  end;
  lxds.open;
  if lxds.cds.recordcount > 0 then begin
    lxds.cds.first;
    rno := 1;
    while not lxds.cds.eof do begin
      for j := 0 to lxds.cds.Fields.count-1 do begin
        storedata.SubmitValue(lxds.cds.Fields[j].FieldName, rno, lxds.cds.Fields[j].AsString, '', 0, 0, 0);
        if rno = 1 then
          Validate.FillOnLoadFlds.Add(lxds.cds.Fields[j].FieldName);
      end;
      lxds.cds.next;
      inc(rno);
    end;
  end;
  except
    On E:Exception do
      ErrMsg := E.Message;
  end;
  lxds.close;
  FreeAndNil(lxds);
  if ErrMsg <> '' then
    raise Exception.Create(ErrMsg);
  AxProvider.dbm.gf.dodebug.msg('FillOnLoad completed');
end;

procedure TDbCall.ValidateImageFlds;
var i : integer;
    ImgFld, FldVal : String;
    xnode, n : IXMLNode;
begin
  if not Assigned(XMLData) then Exit;
  if struct.HasImage then begin
    i := 1;
    ImgFld := dbm.gf.GetNthString(struct.NoEmptyImgFlds,i);
    while ImgFld <> '' do begin
      xnode := XMLData.DocumentElement.ChildNodes.FindNode('data');
      if xnode = nil then
      begin
        xnode := XMLData.DocumentElement.ChildNodes.FindNode('varlist');
        xnode := xnode.ChildNodes.FindNode('row');
      end;//<varlist><row>
      if xnode <> nil then n := xnode.ChildNodes.FindNode(ImgFld) ;
      if assigned(n) then FldVal := vartostr(n.NodeValue);
      if (FldVal = '') then
        raise Exception.Create('Image field '+ImgFld+' can not be left empty.');
      inc(i);
      ImgFld := dbm.gf.GetNthString(struct.NoEmptyImgFlds,i)
    end;
  end;
end;

procedure TDbCall.StoreImageData;
var f, v, tname, iname, s  : String;
    xnode, n : IXMLNode;
    i : integer;
    recid : Extended;
    fld : PFld;
begin
  if (Storedata.AxpImagePath  = '') or (imagesavetodb) then
  begin
    axprovider.savedimages := ',';
    f := storedata.primarytablename+'id';
    v := floattostr(LastSavedId);
    recid := GetRecordId(f,v);
    for i := 0 to struct.flds.count-1 do begin
      fld := pfld(struct.flds[i]);
      tname := '';
      iname := '';
      if (fld.DataType = 'i') and (fld.Tablename<>'') then
      begin
        if trim(struct.SchemaName) <> '' then
          tname := struct.SchemaName + '.' + transid+trim(fld.FieldName)
        else
          tname := transid+trim(fld.FieldName);
        f := fld.FieldName;
        if Assigned(XMLData) then
        begin
          xnode := XMLData.DocumentElement.ChildNodes.FindNode('data');
          if xnode = nil then
          begin
            xnode := XMLData.DocumentElement.ChildNodes.FindNode('varlist');
            xnode := xnode.ChildNodes.FindNode('row');
          end;
          if xnode <> nil then
            n := xnode.ChildNodes.FindNode(f) ;
        end;
        if assigned(n) then iname := vartostr(n.NodeValue);
        if (tname <> '') and (iname <> '') then
        begin
          if not axprovider.SaveImage(tname,iname,recid) then
          begin
             raise exception.Create('Could not save image...');
          end;
        end else begin
          s := 'delete from '+tname+' where recordid ='+FloatToStr(recid);
          Axprovider.ExecSQL(s,'','',False);
        end;
      end;
    end;
    delete(axprovider.savedimages,1,1);
    if axprovider.savedimages <> '' then
    begin
      i := 1;
      while true do
      begin
        f := dbm.gf.GetnthString(axprovider.savedimages,i);
        if f = '' then break;
        if FileExists(f) then deletefile(f);
        inc(i);
      end;
    end;
  end;
end;

Procedure TDbCall.CreateObjects(act,transid : AnsiString ; fldlist,visibleDCs,fglist,fillgriddc : string);
Var  s : String;
Begin
  ftransid := transid;
  Parser := TProfitEval.Create(axprovider);
  Parser.WorkOnStoreData := true;
  Parser.RegisterVar('recordid','n','0');
  Parser.RegisterVar('username', 'c', dbm.gf.username);
  Parser.OnInitGrid := InitGrid;
  Parser.OnDoFillGrid := dofillgrid;
  Parser.OnCopyTrans := CopyTrans;
  Parser.OnNewTrans := newtrans;
  Parser.OnRefreshFrame := RefreshFrame;
  Struct := TStructDef.create(axprovider, transid,sxml);
  Struct.Parser := Parser;
  struct.CreateSelectedFlds(act,transid,fldlist,visibleDCs,fglist,fillgriddc);
  StoreData := TStoreData.Create(struct, transid);
  storedata.trackchanges := struct.track;
  storedata.TrackFieldsList := struct.TrackFieldsList;
  StoreData.ControlField := struct.savecontrol;
  StoreData.DeleteControl := struct.delcontrol;
  storedata.OptionName := OptionName;
  StoreData.UserName := parser.getvarvalue('UserName');
  storedata.PrimaryTableName:=struct.PrimaryTable;
  StoreData.CompanyName := struct.SchemaName;
  StoreData.ImgPath := dbm.gf.startpath+'\';
  StoreData.Parser := Parser;
  Parser.RegisterVar('ApprovalNo', 'n',IntToStr(StoreData.ApprovalNo));
  Storedata.SiteNo := dbm.gf.SiteNo;
  Parser.StoreData := StoreData;
  Parser.OnFillOnLoad := FillOnLoad;

  Validate := TValidate.Create(axprovider);
  Validate.Parser.Destroy;
  Validate.freeparser := false;
  Validate.Parser := Parser;
  Validate.Parser.OnSetSequnce := Validate.ChangeSequence;
  Validate.parser.OnFireSQL:=Validate.OnFireSQL;
  Validate.parser.onSQLGet:=Validate.SQLGETValue;
  Validate.parser.OnFindRecord:=Validate.OnFindRecord;
  Validate.StoreData := StoreData;
  Validate.StoreData.RefreshAutoGen := Validate.RefreshAutoGen;
  Validate.sdef := Struct;
  Validate.ExecuteFillGrid := ExecuteFillGrid;
  Validate.Parser.OnGetSubTotal := GetSubTotal;
  Validate.Parser.OnGetSubDelimitedStr := GetSubDelimitedStr;
  Validate.Parser.OnGetSubValue := GetSubValue;
  Validate.Parser.OnGetSubRow := GetSubRow;
  Validate.Parser.OnInitGrid := InitGrid;
  Validate.Parser.OnDoFillGrid := dofillgrid;
  Validate.parser.OnRefreshField:=RefreshField;
  Validate.parser.OnNewTrans:=NewTrans;
  MainValidate := Validate;
//  PrepareExps;
  mdmap := nil;
  providelink := nil;
  FrameNames := struct.framenames;
  TableNames := struct.tables;
  CreateEventList;

  WorkFlow := TWorkFlowRunTime.create(Axprovider);
  WorkFlow.WorkFlowAction := WorkFlowAction;
  workFlow.Parser := Parser;
  if struct.HasWorkFlow then
    WorkFlow.transid := ftransid  ;
  Storedata.HasWorkFlow:=WorkFlow.Active;
  WorkFlow.Schema := storedata.CompanyName;
  AxpImgPath := Parser.GetVarValue('AxpImagePath');
  AxpAttPath := Parser.GetVarValue('AxpAttachmentPath');
  Storedata.AxpImagePath := AxpImgPath;
End;


procedure TDbCall.LoadDataForWeb(ModifyRecordId:Extended);
var i:integer;
    f,v,btnStr,ptable:String;
    EnableTBar : Boolean;
begin
  dbm.gf.dodebug.Msg('Transid:'+Transid);
  dbm.gf.dodebug.Msg('recordid:'+FloatToStr(ModifyRecordid));
  dbm.gf.dodebug.Msg('primarytable:'+struct.PrimaryTable);
  dbm.gf.ClearAutoGenData(True);

  if copy(lowercase(dbm.gf.username),1,6) <> 'portal' then
  begin
    RecordLocked := AxProvider.CheckExistanceInTransControl(floattostr(ModifyRecordId),StoreData.TransType); //ch1
    if not recordlocked then begin
      AxProvider.InsertIntoTransControl(StoreData.TransType,ModifyRecordid);
    end;
  end;

  StoreData.LoadTransForWeb(ModifyRecordId);
  Parser.RegisterVar('ChildDoc', 'c', StoreData.ChildDoc);
  Parser.RegisterVar('recordid', 'n', floattostr(ModifyRecordId));
  validate.Loading:=true;
  Validate.FillOnLoadFlds.Clear;
  ExecuteAction('After DBLoad','');
  if dataval = true then DataValidate('l', false);
  EnableTBar := WorkFlow.EnableToolbar(Transid,FloatToStr(ModifyRecordid),struct.PrimaryTable);
  dbm.gf.dodebug.Msg('Assigning approval bar');
  if EnableTBar then begin
    dbm.gf.dodebug.Msg('Assigned approval bar');
    if not assigned(ApprovalNode) then
      ApprovalNode := struct.XML.CreateNode('approval',ntElement,'') ;
    if storedata.Cancelled then begin
      WorkFlow.StrStatus := '';
      WorkFlow.WActList.clear;
    end;
    btnStr := '';
    dbm.gf.dodebug.Msg('Before Constructing WActList');
    dbm.gf.dodebug.Msg('Value:'+inttostr(WorkFlow.WActList.Count));
    for i := 0 to WorkFlow.WActList.Count - 1 do begin
      dbm.gf.dodebug.Msg('ApprovalNode : ' + WorkFlow.WActList[i]);
      if lowercase(WorkFlow.WActList[i]) = 'approve' then
        btnStr := btnStr+'a' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'reject' then
        btnStr := btnStr+'r' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'return' then
        btnStr := btnStr+'t' + '~'
      else if lowercase(WorkFlow.WActList[i]) = 'review' then
        btnStr := btnStr+'v' + '~'
    end;
    ApprovalNode.Attributes['btn'] := btnStr;
    ApprovalNode.Attributes['status'] := WorkFlow.StrStatus;
    ApprovalNode.Attributes['appstatus'] := WorkFlow.AppStatus;
    ApprovalNode.Attributes['lno'] := Trim(IntToStr(WorkFlow.Wapplevel));
    ApprovalNode.Attributes['elno'] := Trim(IntToStr(WorkFlow.EnblApplevel));
    if WorkFlow.ProcessForDelegatedUser then
      ApprovalNode.Attributes['dlgusr'] := 'true'
    else
      ApprovalNode.Attributes['dlgusr'] := 'false';
    if Workflow.AllowEdit then
       ApprovalNode.Attributes['allowedit'] := 'true'
    else
       ApprovalNode.Attributes['allowedit'] := 'false';
    if Workflow.AllowCancel then
       ApprovalNode.Attributes['allowcancel'] := 'true'
    else
       ApprovalNode.Attributes['allowcancel'] := 'false';
    if (lowercase(WorkFlow.AppStatus) = 'approved') and (not Workflow.AllowEdit) then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else if not workflow.EnabledTrans then
      ApprovalNode.Attributes['readonlyform'] := 'true'
    else
      ApprovalNode.Attributes['readonlyform'] := 'false';
    dbm.gf.dodebug.Msg('ApprovalNode : ' + ApprovalNode.XML);
  end;
  Maxrows.Clear;NewMaxRows.Clear;fnames.clear;
  i := 1;
  f:=Trim(lowercase(struct.gridstring));
  for i := 1 to length(f) do begin
    v := f[i];
    if v<>'t' then begin
      Maxrows.Add('*');
      NewMaxrows.add('*');
    end else begin
      Maxrows.add(inttostr(storedata.GetRowCount(i)));
      NewMaxRows.Add('0');
    end;
  end;
  AxpImgPath := Parser.GetVarValue('AxpImagePath');
  AxpAttPath := Parser.GetVarValue('AxpAttachmentPath');
  Storedata.AxpImagePath := AxpImgPath;
  dbm.gf.dodebug.Msg('newmaxrow count='+inttostr(newmaxrows.count));
end;

Procedure TDbCall.SaveDataToAppDB(Transid: AnsiString;Recid:Extended;TargetConnectionName:AnsiString='');
var appdbm :TDbManager;
    appAxp : TAxprovider;
    appxds,sxds : TXDS;
    tblList : TStringList;
    i,j : integer;
    tblidCol,s,wcond,dtype,twcond,val,fname : String;
    axProps_Changed : Boolean;
begin
  axProps_Changed := False;
  if struct.Transid = 'axvar' then
  begin
    if Validate.Parser.GetVarValue('isparam') = 'F' then
       axProps_Changed := CreateAndSaveAppVars('save',Validate.Parser.GetVarValue('vpname'))
    else //if isparam T - then update axglo
    begin
       if assigned(act) then //dbcall.act wil be assigned from savedata ws
       begin
         act.ReadAxGloDef; //To Update axglo tstruct
         //Exit;
       end;
    end;
  end else if (struct.Transid = 'sect') or (struct.Transid = 'ad_sp') then
  begin
    //update AxPages for HTMLPages
    UpdateAxpagesTableForHTMLPages('a',true,dbm);
  end;
  dbm.gf.dodebug.Msg('SaveDataToAppDB method starts.');
  if TargetConnectionName = '' then TargetConnectionName := dbm.webAppCon;
  dbm.gf.dodebug.Msg('TargetConnectionName='+TargetConnectionName);
  if (Transid = '') or (Recid = 0) or (TargetConnectionName = '') then
  begin
     dbm.gf.dodebug.Msg('Invalid param values.');
     dbm.gf.dodebug.Msg('TargetConnectionName='+TargetConnectionName);
     dbm.gf.dodebug.Msg('Transid='+Transid);
     dbm.gf.dodebug.Msg('Recid='+FloatToStr(Recid));
    exit;
  end;
  appAxp:=nil; sxds := nil; appdbm := nil; appxds := nil; tblList := nil;
  try
    try
      tblList := TStringList.Create;
      tblidcol := struct.PrimaryTable+'id';
      wcond := tblidcol+'='+FloatToStr(Recid);
      sxds := dbm.GetXDS(nil);
      sxds.buffered := True;
      appdbm := TDbManager.Create;
      appdbm.gf.username := dbm.gf.username;
      appdbm.gf.connectionname := TargetConnectionName;
      appdbm.gf.LocalProps := dbm.gf.LocalProps.CloneNode(True);
      appdbm.conXML := dbm.gf.WebAppConXML;
      appdbm.remoteOpen := False;
      appdbm.SetDefaultValues := false;
      appdbm.ConnectToDatabase(TargetConnectionName);
      appAxp := TAxprovider.create(appdbm);
      appxds := appdbm.GetXDS(nil);
      if struct.Transid = 'ad_nf' then tblList.Add('axpdef_tstruct')
      else if struct.Transid = 'ad_i' then tblList.Add('dwb_iviews')
      else
      begin
        for i := 0 to struct.frames.Count-1 do begin
          if tblList.IndexOf(pfrm(struct.frames[i]).TableName) = -1 then
            tblList.Add(pfrm(struct.frames[i]).TableName);
        end;
      end;
      appdbm.StartTransaction(TargetConnectionName);
      for i := tblList.Count-1 downto 0 do begin
        try
          s := 'delete from '+tblList[i]+' where '+wcond;
          dbm.gf.dodebug.Msg('Executing SQL in App Schema : ' + s);
          appAxp.ExecSQL(s,'','',False);
        Except
        end;
      end;
      if appdbm.Connection.DbType = 'ms sql' then
      begin
        for i := 0 to tblList.Count-1 do begin
          sxds.close;
          sxds.buffered := True;
          sxds.CDS.CommandText := 'select * from '+tblList[i]+' where '+wcond;
          sxds.open;
          while not sxds.CDS.Eof do begin
            appxds.close;
            appxds.ClearEdit;
            twcond := tblList[i]+'id'+'='+sxds.CDS.FieldByName(tblList[i]+'id').AsString;
            for j := 0 to sxds.CDS.Fields.Count-1 do begin
              dtype := lowercase(Copy(dbm.gf.GetDataType(sxds.CDS.Fields[j].DataType),1,1));
              if sxds.CDS.Fields[j].IsNull then
                 val := ''
              else val := sxds.CDS.Fields[j].AsString;
              if lowercase(sxds.CDS.Fields[j].FieldName) = 'schema' then
                 fname := '"' + sxds.CDS.Fields[j].FieldName + '"'
              else fname := sxds.CDS.Fields[j].FieldName;
              appxds.Submit(fname,val,dtype);
            end;
            appxds.AddOrEdit(tblList[i],twcond);
            sxds.CDS.Next;
          end;
        end;
      end else
      begin
        for i := 0 to tblList.Count-1 do begin
          sxds.close;
          sxds.buffered := True;
          sxds.CDS.CommandText := 'select * from '+tblList[i]+' where '+wcond;
          sxds.open;
          while not sxds.CDS.Eof do begin
            appxds.close;
            appxds.ClearEdit;
            twcond := tblList[i]+'id'+'='+sxds.CDS.FieldByName(tblList[i]+'id').AsString;
            for j := 0 to sxds.CDS.Fields.Count-1 do begin
              dtype := lowercase(Copy(dbm.gf.GetDataType(sxds.CDS.Fields[j].DataType),1,1));
              if sxds.CDS.Fields[j].IsNull then
                 val := ''
              else val := sxds.CDS.Fields[j].AsString;
              appxds.Submit(sxds.CDS.Fields[j].FieldName,val,dtype);
            end;
            appxds.AddOrEdit(tblList[i],twcond);
            sxds.CDS.Next;
          end;
        end;
      end;
      if axProps_Changed then
      begin
         dbm.gf.dodebug.Msg('Updating Axprops in App Schema...');
         appAxp.SetStructure('axprops', 'app', '', dbm.gf.AppXML);
         dbm.gf.dodebug.Msg('Updating Axprops in App Schema done...');
      end;
      //update AxPages for HTMLPages
      UpdateAxpagesTableForHTMLPages('a',false,appdbm);
      appdbm.Commit(TargetConnectionName);
    except On E:Exception do
      begin
        dbm.gf.dodebug.Msg('Error in SaveDataToAppDB :'+E.Message);
        dbm.gf.DoDebug.Log(dbm.gf.Axp_logstr+'\uProfitEval\'+
                  'SaveDataToAppDB - '+e.Message);
        if assigned(appdbm) then appdbm.Rollback(TargetConnectionName);
        raise Exception.Create('Error in SaveDataToAppDB.'+e.Message);
      end;
    end;
  finally
    if assigned(sxds) then begin
      sxds.destroy; sxds := nil;
    end;
    if assigned(appxds) then begin
      appxds.close; appxds.destroy; appxds := nil;
    end;
    if assigned(appAxp) then begin
      appAxp.Destroy; appAxp := nil;
    end;
    if assigned(appdbm) then begin
      appdbm.destroy; appdbm := nil;
    end;
    if assigned(TblList) then
    begin
      TblList.Clear;
      FreeAndNil(TblList);
    end;
  end;
  dbm.gf.dodebug.Msg('SaveDataToAppDB method ends.');
end;

Procedure TDbCall.DeleteDataFromAppDB(Transid: AnsiString;Recid:Extended;TargetConnectionName:AnsiString='');
var appdbm :TDbManager;
    appAxp : TAxprovider;
    tblList : TStringList;
    i : integer;
    tblidCol,s,wcond : String;
    axProps_Changed : Boolean;
begin
  axProps_Changed := False;
  if struct.Transid = 'axvar' then
  begin
    i := StoreData.GetFieldIndex('isparam', 1);
    if i <> -1 then
    begin
      if lowercase(pFieldRec(StoreData.FieldList[i]).Value) = 'f' then
      begin
         i := StoreData.GetFieldIndex('vpname', 1);
         if i <> -1 then
            axProps_Changed := CreateAndSaveAppVars('delete',pFieldRec(StoreData.FieldList[i]).Value);;
      end
      else //if isparam true - then update axglo
      begin
         if assigned(act) then //dbcall.act wil be assigned from Deletedata ws
         begin
           act.ReadAxGloDef; //To Update axglo tstruct
         end;
      end;
    end;
  end else if (struct.Transid = 'sect') or (struct.Transid = 'ad_sp') then
  begin
    //delete page from AxPages for HTMLPages
    UpdateAxpagesTableForHTMLPages('d',true,dbm);
  end;
  dbm.gf.dodebug.Msg('DeleteDataFromAppDB method starts.');
  if TargetConnectionName = '' then TargetConnectionName := dbm.webAppCon;
  dbm.gf.dodebug.Msg('TargetConnectionName='+TargetConnectionName);
  if (Transid = '') or (Recid = 0) or (TargetConnectionName = '') then
  begin
     dbm.gf.dodebug.Msg('Invalid param values.');
     dbm.gf.dodebug.Msg('TargetConnectionName='+TargetConnectionName);
     dbm.gf.dodebug.Msg('Transid='+Transid);
     dbm.gf.dodebug.Msg('Recid='+FloatToStr(Recid));
    exit;
  end;
  appdbm := nil; tblList := nil; appAxp:=nil;
  try
    try
      tblList := TStringList.Create;
      tblidcol := struct.PrimaryTable+'id';
      wcond := tblidcol+'='+FloatToStr(Recid);
      appdbm := TDbManager.Create;
      appdbm.gf.username := dbm.gf.username;
      appdbm.gf.connectionname := TargetConnectionName;
      appdbm.gf.LocalProps := dbm.gf.LocalProps.CloneNode(True);
      appdbm.conXML := dbm.gf.WebAppConXML;
      appdbm.remoteOpen := False;
      appdbm.SetDefaultValues := false;
      appdbm.ConnectToDatabase(TargetConnectionName);
      appAxp := TAxprovider.create(appdbm);
      for i := 0 to struct.frames.Count-1 do begin
        if tblList.IndexOf(pfrm(struct.frames[i]).TableName) = -1 then
          tblList.Add(pfrm(struct.frames[i]).TableName);
      end;
      appdbm.StartTransaction(TargetConnectionName);
      for i := tblList.Count-1 downto 0 do begin
        try
          s := 'delete from '+tblList[i]+' where '+wcond;
          appAxp.ExecSQL(s,'','',False);
        Except
        end;
      end;
      if axProps_Changed then appAxp.SetStructure('axprops', 'app', '', dbm.gf.AppXML);
      //delete page from AxPages for HTMLPages
      UpdateAxpagesTableForHTMLPages('d',false,appdbm);
      appdbm.Commit(TargetConnectionName);
    except On E:Exception do
      begin
        dbm.gf.dodebug.Msg('Error in DeleteDataFromAppDB :'+E.Message);
        dbm.gf.DoDebug.Log(dbm.gf.Axp_logstr+'\uProfitEval\'+
                  'DeleteDataFromAppDB - '+e.Message);
        if assigned(appAxp) then appdbm.Rollback(TargetConnectionName);
        raise Exception.Create('Error in DeleteDataFromAppDB.'+e.Message);
      end;
    end;
  finally
    if assigned(appAxp) then begin
      appAxp.Destroy; appAxp := nil;
    end;
    if assigned(appdbm) then begin
      appdbm.destroy; appdbm := nil;
    end;
    if assigned(TblList) then
    begin
      TblList.Clear;
      FreeAndNil(TblList);
    end;
  end;
  dbm.gf.dodebug.Msg('DeleteDataFromAppDB method ends.');
end;

Function TDbCall.CreateAndSaveAppVars(act,vpname : ansistring) : Boolean;
var
  xQry : TXDS;
  s : string;
  vnode , pnode , tnode : ixmlnode;
  i : integer;
  sl : TStringList;
begin
  result := False;
  sl := nil;
  dbm.gf.dodebug.Msg('CreateAndSaveAppVars method starts...');
  dbm.gf.dodebug.Msg('Act : ' + act);
  dbm.gf.dodebug.Msg('Variable Name : ' +vpname);
  xQry := dbm.GetXDS(nil);
  xQry.buffered := True;
  try
   xQry.CDS.CommandText := 'select vpname,vpvalue,vscript from axp_vp where vpname = ' + quotedstr(vpname);
   xQry.open;
   dbm.gf.dodebug.Msg('Variable Count : ' + inttostr(xQry.CDS.RecordCount));
   if act = 'save' then
   begin
     pnode := dbm.gf.AppXML.DocumentElement;
     pnode:=pnode.ChildNodes[0];
     vnode := pnode.ChildNodes.FindNode('appvars');
     if not assigned(vnode) then vnode := pnode.AddChild('appvars');
     dbm.gf.dodebug.Msg('Variable Name : ' + xQry.CDS.Fields[0].AsString);
     tnode := vnode.ChildNodes.FindNode(xQry.CDS.Fields[0].AsString);
     if not assigned(tnode) then
     begin
        tnode := vnode.AddChild(xQry.CDS.Fields[0].AsString);
        tnode.Attributes['value'] := xQry.CDS.Fields[1].AsString;
        tnode.Attributes['param'] := 'f';
        tnode.Attributes['dtype'] := null;
        tnode.Attributes['moe'] := null;
        tnode.Attributes['caption'] := null;
        tnode.Attributes['hidden'] := 'false';
     end else tnode.Attributes['value'] := xQry.CDS.Fields[1].AsString;
     s := trim(xQry.CDS.Fields[2].AsString);
     if s <> '' then
     begin
       for i := 0 to tnode.ChildNodes.Count-1 do
          tnode.ChildNodes.Delete(0);
      if assigned(sl) then sl.Clear
      else   sl := TStringList.Create;
      sl.Text := s; 
      for i := 0 to sl.Count-1 do
        tnode.AddChild('l').NodeValue := sl.Strings[i];
     end;
   end else
   begin
    pnode := dbm.gf.AppXML.DocumentElement;
    pnode:=pnode.ChildNodes[0];
    vnode := pnode.ChildNodes.FindNode('appvars');
    if assigned(vnode) then vnode.ChildNodes.Delete(vpname);
   end;
   axprovider.SetStructure('axprops', 'app', '', dbm.gf.AppXML);
   Result := True;
   Except on e:exception do
      begin
        dbm.gf.dodebug.Msg('Error in CreateAndSaveAppVars :'+E.Message);
      end;
   end;
   xQry.close;
   if assigned(sl) then
   begin
     sl.Clear;
     FreeAndNil(sl);
   end;
end;

Function TDbCall.CreateAndSaveAppProps : Boolean;
var
  s : string;
  vnode , pnode , tnode : ixmlnode;
  i : integer;
begin
  result := False;
  dbm.gf.dodebug.Msg('CreateAndSaveAppProps method starts...');
  try
   pnode := dbm.gf.AppXML.DocumentElement;
   pnode:=pnode.ChildNodes[0];
   vnode := pnode.ChildNodes.FindNode('mail');
   if not assigned(vnode) then
   begin
     s := Validate.Parser.GetVarValue('smtphost');
     if s <> ''  then
     begin
       vnode := pnode.AddChild('mail');
       vnode.AddChild('host').NodeValue := s;
       vnode.AddChild('port').NodeValue := Validate.Parser.GetVarValue('smtpport');
       vnode.AddChild('userid').NodeValue := Validate.Parser.GetVarValue('smtpuser');
       vnode.AddChild('password').NodeValue := Validate.Parser.GetVarValue('smtppwd');
       result := true;
     end;
   end else
   begin
     tnode := vnode.ChildNodes.FindNode('host');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('smtphost'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('port');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('smtpport'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('userid');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('smtpuser'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('password');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('smtppwd'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
   end;
   vnode := pnode.ChildNodes.FindNode('pwdsetting');
   if not assigned(vnode) then
   begin
     vnode := pnode.AddChild('pwdsetting');
     vnode.AddChild('maxlogintry').NodeValue := trim(Validate.Parser.GetVarValue('loginattempt'));
     vnode.AddChild('pwdexpdays').NodeValue := trim(Validate.Parser.GetVarValue('pwdexp'));
     vnode.AddChild('pwdalertdays').NodeValue := trim(Validate.Parser.GetVarValue('pwdchange'));
     vnode.AddChild('pwdminchars').NodeValue := trim(Validate.Parser.GetVarValue('pwdminchar'));
     vnode.AddChild('pwdprevnos').NodeValue := trim(Validate.Parser.GetVarValue('pwdreuse'));
     vnode.AddChild('ispwdalphanum').NodeValue := trim(Validate.Parser.GetVarValue('pwdalphanum'));
     vnode.AddChild('pwdaes').NodeValue := trim(Validate.Parser.GetVarValue('pwdencrypt'));
     result := true;
   end else
   begin
     tnode := vnode.ChildNodes.FindNode('maxlogintry');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('loginattempt'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('pwdexpdays');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdexp'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('pwdalertdays');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdchange'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('pwdminchars');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdminchar'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('pwdprevnos');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdreuse'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('ispwdalphanum');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdalphanum'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('pwdaes');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('pwdencrypt'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
   end;
   vnode := pnode.ChildNodes.FindNode('envvar');
   if not assigned(vnode) then
   begin
     vnode := pnode.AddChild('envvar');
     vnode.AddChild('siteno').NodeValue := trim(Validate.Parser.GetVarValue('siteno'));
     vnode.AddChild('millions').NodeValue := trim(Validate.Parser.GetVarValue('amtinmillions'));
     vnode.AddChild('cursep').NodeValue := trim(Validate.Parser.GetVarValue('currseperator'));
     vnode.AddChild('postauto').NodeValue := trim(Validate.Parser.GetVarValue('autogen'));
     vnode.AddChild('oraerrfrom').NodeValue := trim(Validate.Parser.GetVarValue('customfrom'));
     vnode.AddChild('oraerrto').NodeValue := trim(Validate.Parser.GetVarValue('customto'));
     result := true;
   end else
   begin
     tnode := vnode.ChildNodes.FindNode('siteno');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('siteno'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('millions');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('amtinmillions'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('cursep');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('currseperator'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('postauto');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('autogen'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('oraerrfrom');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('customfrom'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
     tnode := vnode.ChildNodes.FindNode('oraerrto');
     if assigned(tnode) then
     begin
       s := trim(Validate.Parser.GetVarValue('customto'));
       if tnode.NodeValue <> s then
       begin
         tnode.NodeValue := s;
         result := true;
       end;
     end;
   end;
  Except on e:exception do
    begin
      dbm.gf.dodebug.Msg('Error in CreateAndSaveAppProps :'+E.Message);
    end;
  end;
end;



//UpdateAxpagesTableForHTMLPages
(*
 Procedure to update Apxages table for HTMLPages
 when targetDBM is nil then current dbm will be considered as targetDBM (This is handled in axprovider.UpdateAxpagesTableforHTMLPage)
 sEditType can be 'a' or 'd'
 'a' - add / update
 'd' - delete

*)
Procedure TDbCall.UpdateAxpagesTableForHTMLPages(sEditType : String;bRefreshFieldValue:Boolean;targetDBM : TDBManager = nil);
var
  sDelSQLQuery : String;
const
    sHTMLpageTransID = 'sect,ad_sp';  //HTML Pages Tstruct Transid
begin
  //If current transtype is not HTMLPageTransid then exit.
  if pos(lowercase(storedata.TransType),sHTMLpageTransID) <=0 then Exit;
  //When bRefreshFieldValue is true , then only get value from SD else use the value what exists in that variable.
  // bRefreshFieldValue will be true when the call is from defschema and false when the call is from appschema
  if bRefreshFieldValue then
  begin
    //If current Tstruct is HTMLPages Tstruct then get PageName and PageCaption to update AxPages
    sHTMLPageNo := Storedata.GetFieldValue('pageno',1);//pageno field - HTML Pages(sect)
    sHTMLPageCaption := Storedata.GetFieldValue('caption',1);//caption field - HTML Pages(sect)
  end;
  if sEditType = 'a' then //'a' - add or update
    axprovider.UpdateAxpagesTableforHTMLPage(sHTMLPageNo,sHTMLPageCaption,lowercase(storedata.TransType),StoreData.NewTrans,targetDBM)
  else //'d' - delete
  begin
    if lowercase(storedata.TransType) = 'sect' then
       sDelSQLQuery := 'delete from axpages where name = '+QuotedStr('HP'+sHTMLPageNo)
    else sDelSQLQuery := 'delete from axpages where name = '+QuotedStr('SP'+sHTMLPageNo);
    axprovider.ExecuteSQL(sDelSQLQuery,targetDBM);
  end;

end;

(*
As of now we added below methods into ASBUtils/uDBCALL , if it works same can be
implemented in other ASBProjects (ASBTStruct,ASBScript..)
*)


//SDEvaluateExpr
Function TDbCall.SDEvaluateExpr(sExpression : String):String;
begin
  result := '';
  dbm.gf.dodebug.msg('SDEvaluateExpr starts...');
  if Assigned(Parser) then
  begin
     dbm.gf.dodebug.msg('Evaluating Expression :'+sExpression);
     Parser.Evaluate(sExpression);
     result := Parser.Value;
     dbm.gf.dodebug.msg('Result of Expression :'+result);
  end
  else
    dbm.gf.dodebug.msg('dbcall/Parser is not assigned.');
  dbm.gf.dodebug.msg('SDEvaluateExpr ends.');
end;

//SDRegVarToParser
Procedure TDbCall.SDRegVarToParser(pVarname,pVarDType,pVarValue : String);
begin
  dbm.gf.dodebug.msg('SDRegVarToParser starts...');
  if Assigned(Parser) then
  begin
     dbm.gf.dodebug.msg('Variablename :'+pVarname);
     dbm.gf.dodebug.msg('Variablevalue :'+pVarValue);
     Parser.RegisterVar(pVarname, pVarDType[1], pVarValue);
  end
  else
    dbm.gf.dodebug.msg('dbcall/Parser is not assigned.');
  dbm.gf.dodebug.msg('SDRegVarToParser ends.');
end;

//ProcessRMQMessages | process RMQ messages After commit
Procedure TDbCall.ProcessRMQMessages;
begin
  dbm.gf.dodebug.msg('DbCall/ProcessRMQMessages starts...');
  try
    if Assigned(StoreData) and Assigned(StoreData.AxPEG) then
    begin
      StoreData.AxPEG.PushMessagesToRMQ;
    end;
  Except on E:Exception do
    dbm.gf.dodebug.msg('Error in DbCall/ProcessRMQMessages : '+E.Message);
  end;
  dbm.gf.dodebug.msg('DbCall/ProcessRMQMessages ends.');
end;


//AutoPrints
Procedure TDbCall.ProcessAutoPrints;
var
  AutoPrint :TAutoPrint;
begin
  dbm.gf.DoDebug.msg('DbCall/Executing ProcessAutoPrints...');
  try
    AutoPrint := nil;
    try
    AutoPrint := TAutoPrint.Create(Struct);

    AutoPrint.DbCall := self;
    AutoPrint.StoreData := StoreData;
    //AutoPrint.ParserObject := Parser;
    AutoPrint.Parser := Parser;

    AutoPrint.ProcessAutoPrints;
    finally
      if Assigned(AutoPrint) then
        FreeAndNil(AutoPrint);
    end;
  except on e:exception do
  begin
    dbm.gf.DoDebug.msg('Storedata/Error in ProcessAutoPrints '+e.Message);
  end;
  end;

  dbm.gf.DoDebug.msg('Storedata/ProcessAutoPrints ends.');
end;

//ProcessDataExch
Procedure TDbCall.ProcessDataExch(pStruct:TStructDef;pStoreData : TStoreData;pParser : TProfitEval);
var
  DataExch :TDataExchQueue;
begin
  dbm.gf.DoDebug.msg('DbCall/Executing ProcessDataExch...');
  try
    DataExch := nil;
    try
    DataExch := TDataExchQueue.Create(pStruct);
    DataExch.RecrId:= LastSavedId;
    DataExch.StoreData := pStoreData;
    DataExch.ParserObject := pParser;
    //Need to think of avoiding SQLs and keep this values in Structures
    DataExch.ProcessDataOut;
    finally
      if Assigned(DataExch) then
        FreeAndNil(DataExch);
    end;
  except on e:exception do
  begin
    dbm.gf.DoDebug.msg('Storedata/Error in ProcessDataExch '+e.Message);
  end;
  end;
  dbm.gf.DoDebug.msg('Storedata/ProcessDataExch ends.');
end;

//ProcessFormNotifications
//pDataMode - Transaction mode - n-new/e-edit/d-delete/c-cancel
Procedure TDbCall.ProcessFormNotifications(pDataMode : String);
begin
  dbm.gf.DoDebug.msg('DbCall/Executing ProcessFormNotifications...');
  try
    try
    FormNotify := TFormNotifications.Create(Struct);

    FormNotify.StoreData := StoreData;
    FormNotify.ParserObject := Parser;
    FormNotify.sAxDataMode := pDataMode;
    //For new trans recordid reset to 0 on SD endsave.
    //To handle that we have taken Recid from LastSavedId
    FormNotify.RecId := LastSavedId;

    FormNotify.ProcessFormNotify;
    finally
    end;
  except on e:exception do
  begin
    dbm.gf.DoDebug.msg('Storedata/Error in ProcessFormNotifications '+e.Message);
  end;
  end;
  dbm.gf.DoDebug.msg('Storedata/ProcessFormNotifications ends.');
end;


end.
