Unit uStoreData;
{Copied from Axpert9-XE3\Ver 11.1}
Interface
Uses db, classes, Vcl.forms, sysutils, uGeneralFunctions, Vcl.Extctrls, Vcl.dialogs, Vcl.controls, Variants,
uMDMap,uXDS, uConnect, uStructDef, XMLintf,XMLDoc, idGlobal, uDoDebug, uCompress,uParse,DateUtils,
System.StrUtils,uAxPEG,
// Delphi XE3 has a DBXJson object for JSON support but above that version (>XE3) DBXJson is deprecated and JSON object is used.
{$IF CompilerVersion > 24.0}
      JSON
{$ELSE}
      DBXJson
{$IFEND}
      ;


Type
  TSDEvaluateExpr = function(sExpression : String):String of object;
  TSDRegVarToParser = Procedure(pVarname, pVarDType, pVarValue: String) of object;
  TRefreshAutoGen = function(ModTable:TXDS;FieldName, NewValue: String):String of object;
  TRefreshCurrencyFld = procedure(cFld:pFld) of object;
  PFieldRec = ^TFieldRec;
  TFieldRec = Record
    TableName: String;
    FieldName: String;
    DataType: String;
    RowNo: integer;
    Value: String;
    IdValue: extended;
    OldValue: String;
    OldIdValue: extended;
    FrameNo: Integer;
    RecordId: extended;
    PrimaryTable: char;
    Orders: Integer;
    OldRow: Integer;
    SourceKey: Boolean;
    ParentRowNo: Integer;
    OldParentRow : Integer;
    ZeroValue : Boolean;
    AutoValue : Boolean;
    ClientNotify : Boolean;
    fld : PFld ;
    webvalue : String; //to use data comparison for making chaged json strings
  End;

  pRowRec = ^TRowRec;
  TRowRec = Record
    FrmNo, SgRow, PgRow, SdRow, PPgRow : Integer;
  End;

  TStoreData = Class
  Private
    FirstTableName: String;
    first: boolean;
    MasterTableName: String;
    DQLoad, DQLoadQualified, DQTrackFields, QSeq, QLockSeq, work, historytable, Qupdseq, xtemp, tlink, tparents,qpkt : TXDS;
    RecId: extended;
    fTransType: String;
    RowCountList: TStringList;
    fCompanyName: String;
    fTrackChanges : boolean;
    fPrimaryTableName: String;
    SourcePrimaryId : Extended;
    Autogentransid : TStringList;
    fsiteno, newvaluesize, oldvaluesize: integer;
    ParentRowDefined : String;
    HasSendToSite : Boolean;
    IsCreatedOnDefined,IsModifiedOnDefined,IsUserNameDefined,IsSiteNoDefined, IsMapNameDefined: Boolean;
    IsInsertToOutbound : Boolean;
    bCallFromStoreTrans : Boolean;

    Function GetIndex(FieldName, TableName: String; RowNo: integer): integer;
    Procedure LoadIntoDataSet(i:integer);
    Procedure LoadFields;
    Function ISDateEmpty(D: String): Boolean;
    Function GetValueFromTable(RowNo: integer): String;
    Procedure LoadNotSavedFields;
    Procedure closecursors;
    Procedure SetCompanyName(CompanyName: String);
    Function GetFrameNo(TableName: String): integer;
    Procedure StoreParentRecordId(i: integer);
    procedure LoadTrackDetails;
    function GetPRow(FrameNo, RowNo: integer): integer;
    procedure SetAutoGenList;
    function IsExported: boolean;
    procedure CheckAutoGen(sender:Tobject);
    procedure SaveToHistory(i, modno: integer; TransDeleted:Boolean);
    procedure SaveHistoryToDB(i, modno: integer; TransDeleted:Boolean);
    procedure SetSiteNo(sno: integer);
    function IsTransRecord(tname:String; r: Extended): boolean;
    procedure SetParentFrames;
    procedure AddTreeLink(LinkTable: String; recid, parentid: extended);
    procedure DelTreelink(Linktable: String; recid: extended);
    procedure UpdateTreelink(cmd: String);
    procedure DoSend;
    procedure Writepkt(psiteno: integer);
    function GetPrefixFieldValue(fieldname, sval,transid: String;OnlyGet:Boolean;digits:Integer): String;
    procedure InsertinOutboundTable(transid : String; rid : Extended);
    function CheckInsertToOutbound(transid : String) : Boolean;
    function GetRowIndex(FrmNo, SgRow: Integer): integer;
    procedure InsertedRowNoInfo(frameno, RowNo: Integer);
    procedure SaveImages(i: integer);
    function CountNumberOfAt(FieldValue: String): integer;
    function GetString(ImageNames: String): String;
    procedure UpdateRecIdInAutoGenData(Rowno: Integer);
    procedure ClearDatarows;
    function GetTableId(TblName: String): Extended;
    procedure SaveCancelRemarksToHistotyTable(crem:Boolean;rem:String);
    procedure RemoveImagesForDeletedRows;
    procedure DeleteAllImages;
    procedure DeletedSubgridRedids(recid,fno: String);
    procedure SetCurrencyDec(CurStr: String; RowNo: Integer);
    procedure LoadIntoDataSetForWeb(frm : pFrm);
    //PEG
    procedure InitPEG;
    procedure CheckAxProcessDef;
    function IsPegTaskInitiated: Boolean;
    procedure CancelPEGActiveTasks(pCancelRemarks, pCancelledBy,
      pCancelledOn: String);
    function ConvertSDtoRapidSaveInputJSON: String;
    procedure PushSaveDataToQueue;
    function CanCancelTransaction: Boolean;
    function IsProcessOnHold: Boolean;
    procedure RegisterFieldList;

    procedure SaveAmend;
    procedure FetchAmendForLoadData;
    procedure CallPEGApproveUsingTaskId(pTaskId: String);
    function HasPegActiveTasks: Boolean;
  Protected
    TableName: String;
    ModTable: TXDS;
    NewRecId : extended;
    PrimaryTableId: extended;
    fld : pfld;
    RowRec : pRowRec;

    Procedure AddRow; Virtual;
    Procedure SaveRow(i: integer); Virtual;
    Procedure SetTransType(TransType: String); Virtual;
    procedure SetPrimaryTablename(ptname:String); virtual;
    function GetNoofTimesModified(Primarytableid: Extended): Integer;

  Public
    tracklist : TStringlist ; // for track changes
    Parent_Row_Field_Caption,Attachment_files : String;
    GridDc_Attach,HasWorkFlow:boolean;
    tosites,SendTransid,SyncAction : String;
    xml : IXMLDocument;
    connection : pConnection;
    databasename : String;
    FieldList: TList;
    LastSavedRecordId: extended;
    RecordIdList: TStringList;
    UserId: Integer;
    OldCompanyName: String;
    MapName: String;
    SourceId, PublicSourceId: Extended;
    ChildTrans: Boolean;
    EntryDocLoaded: Boolean;
    ProgressBar: TPanel;
    ControlField: String;
    Approval: integer;
    ApprovalNo: Integer;
    ApprovalStatus: String;
    MaxApproved: Integer;
    ApprovalDefined: Boolean;
    UserName: String;
    SubFrames, SubFramesParent : TStringList;
    ChildDoc: String;
    DeleteControl : String;
    IsTransidDefined : Boolean;
    Cancelled,Deleted : Boolean;
    CancelRemarks : String;
    IsCancelDefined : Boolean;
    StatusidFieldList : Tstringlist;
    StatusflagFieldList : Tstringlist;
    StatusidValuelist   : Tstringlist;
    FieldOrder: Integer;
    OptionName, ModifiedOn, CreatedOn, CreatedBy, SUserName, SSiteNo,SModifiedOn : String;
    MapParentRecordId : Extended;
    AutogenFields, Prefixes, PrefixFields, AutoGenVals : TStringList;
    NoAutoGenStr : String;
    NoChange : String;
    LastIdValue : Extended;
    NewTrans, UndoAmendment, DataValidate : Boolean;
    AutoFields : TStringList;
    MDMap : TMDMap;
    DataClosed : Boolean;
    tables : String;
    sdImageList :TstringList;
    TrackFieldsList :TstringList;
    DetailStruct:Boolean;
    MasterRecord,SecondaryRecord:Extended;
    DetailTableName :String;
    structdef:TStructDef;
    RefreshAutoGen : TRefreshAutoGen;
    RowList : TList;
    ins_del_rows,subgrid_del_recid_list : TStringList;
    ImgPath : String;
    IsFromAdx : boolean;
    timezone_diff : extended;
    data_exchange : String;
    AxpImagePath : String;
    webdata : boolean;
    ClientNotify : Boolean;
    ParentControl : integer;
    RefreshCurrencyFld : TRefreshCurrencyFld;
    CancelledTrans : Boolean;
    Parser : TEval;
    depCall : boolean;
    NoSaveFldDcs : TStringList;
    SDEvaluateExpr : TSDEvaluateExpr;
    SDRegVarToParser : TSDRegVarToParser;
    delrowsnode : IXMLNode;
    //Will be set to true when calling from PEG Actions (AxApprove,AxCheck..)
	//from the below bool vars either bDoNotInitPEGorAmendment or bDoNotInitPEG,bDoNotInitAmendment will be used.
    bDoNotInitPEG,bDoNotInitAmendment,bDoNotInitPEGorAmendment,AxDataAmended : Boolean;
    Object_ASBDataObj : TObject;
    AxPEG : TAxPEG; //Moved to public to access from outside
	  ParserObject : TObject;
    DoPEGApprovalOnSave,IsPegEdit : Boolean;
    sPEGTaskID : String;
    AutoFastPrints : TStringList;
    bCallFromAcceptAmend : Boolean;

    procedure AfterSort;
    function RowCount(FrameNo: Integer): Integer;
    procedure GetFieldData(FieldName: String; RowNo: integer;
      FieldData: pFieldData);
    Procedure StoreTrans; Virtual;
    Procedure SetFieldValue(FieldName, DataType, TableName, Value, OldValue:
      String; RowNo :integer; IdValue, OldIdValue:extended; FrameNo: integer; Recordid: extended ; SourceKey:
      Boolean); overload;
    Procedure DirectSubmitValue(fld : pFld ; Value,  OldValue: String;
           RowNo:integer; IdValue, OldIdValue,RecordId:Extended) ; overload;
    Procedure LoadTrans(RecordId: Extended);
    Procedure DeleteRow(FrameNo, Row: Integer);  overload;
    Procedure DeleteRow(FrameNo, Row: Integer;init : boolean); overload;
    Procedure ClearFieldList;
    Procedure DeleteTrans(RecordId: Extended); Virtual;
    Constructor Create(Sdef:TStructDef; pTransid:String);Virtual;
    Destructor Destroy; Override;
    Function GetFieldIndex(FieldName: String; RowNo: integer): Integer;
    Procedure EndSave;
    Procedure CancelTrans(Rem:String); virtual;
    Function GetOldValue(FieldName: String; RowNo: Integer): String;
    Procedure StoreChildTrans(pMapName:String; pSourceId, pSrcPrimaryId: Extended );
    Procedure LoadChildTrans(pMapName:String; pSourceId: Extended);
    Function GetParentDocId(FrameNo, RowNo: integer): Extended;
    Function GetParentRowNo(FrameNo:integer; RecordId: Extended): integer;
    Procedure ShowProgress(CStr: String);
    Function GetRowCount(FrameNo: integer): integer;
    Procedure SetParentRowNo(FieldName: String; RowNo, ParentRowNo: integer);
    Procedure InsertRow(FrameNo, RowNo: integer);
    Function GetSubFormLastRow(FrameNo, ParentRowNo: integer): integer;
    Function GetSubFormRowCount(FrameNo, ParentRowNo: integer): integer;
    Function GetFieldValue(FieldName: String; RowNo: integer): String;
    Procedure DeleteSubFormRow(FrameNo, ParentRow, Row: Integer);
    procedure AddGridRow(FrameNo: Integer);

    Property TransType: String Read fTransType Write SetTransType;
    Property CompanyName: String Read fCompanyName Write SetCompanyName;
    property TrackChanges : boolean Read fTrackChanges Write fTrackChanges;
    property PrimaryTableName : String read fPrimaryTableName Write SetPrimarytableName;
    property siteno : integer read fsiteno write setsiteno;
    //gou
    Function GetBreakupCumilation(Frameno,ParentRowno :integer;Fieldname : String):Currency;
    Procedure AddSubFormIdElement(Fieldname,DataType, Value: String; IdValue:extended; FrameNo ,Rowno : integer; SourceKey: Boolean);
    Function CheckIdFieldChanged(idField,value : String;FrameNo,Rowno:integer;idvalue : extended; Sourcekey : Boolean):Boolean;
    Procedure DeleteSubFormBreakup(FrameNo,ParentRowNo : integer);

    Function GetFieldFirstIndex(FieldName: String): Integer;
    function CanDeleteTrans: String;
    function GetRecIndex(FieldName, TableName: String; RecordId: extended): integer;
    procedure SetRecFieldValue(FieldName, DataType, TableName,
      Value, OldValue: String; RowNo: integer; IdValue,
      OldIdValue: extended; FrameNo: integer; RecordId: Extended;
      SourceKey: Boolean);
    procedure InitRecordIds;
    Procedure SubmitValue(FieldName:String; RowNo:integer;  Value, OldValue: String; IdValue, OldIdValue, Recordid :extended); overload ;
    Procedure SubmitValue(fp : pFld;FieldName:String; RowNo:integer;  Value, OldValue: String; IdValue, OldIdValue, Recordid :extended); overload;
    function GetLastNo(FieldName: String; OnlyGet: Boolean): String;
    procedure SetPrefix(Transid, FieldName, Prefix: String);
    procedure NoAutoGen(FieldName: String);
    procedure InsertFrameRow(FrameNo, Row: Integer);
    function IsTransChanged: boolean;
    procedure SetRecid(rid: Extended);
    procedure RemoveNoAutoGen(FieldName: String);
    Procedure SetParentDocId(TableName:String; FrameNo:integer);
    procedure SaveHistoryToTable(TransDeleted : Boolean);
    procedure PrepareHistoryDetails(TransDeleted : Boolean);
    procedure SetChildTrackListToParent(cTrackList: TStringlist);
    Procedure MakeList(TransDeleted:boolean);
    Procedure RemoveDeletedRows;
    function GetUserActivePrefix(transid, fieldname: String): String;
    function GetActivePrefix(transid, fieldname: String): String;
    procedure SendToSites(op:TSend);
    procedure SaveList(source:String);
    procedure AddRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow: integer);
    procedure SetRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow: integer);
    procedure InsertRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow: integer);
    procedure DeleteRowRec(FrmNo, SgRow: integer);
    function Sg2Pg(FrmNo, SgRow: Integer): Integer;
    function Pg2Sg(FrmNo, PgRow: Integer): Integer;
    function Sg2Sd(FrmNo, SgRow: Integer): Integer;
    function Sd2Sg(FrmNo, SdRow: Integer): Integer;
    function PrPg2Sd(FrmNo, PPgRow, PgRow: Integer): Integer;
    procedure DelRowRecWithSdRow(FrmNo, SdRow: integer);
    function Pg2Sd(FrmNo, PgRow: Integer): Integer;
    function Sd2Pg(FrmNo, SdRow: Integer): Integer;
    function GetSubRowCount(FrmNo, PPgRow: Integer): Integer;
    procedure ClearRowList;
    procedure DeleteRowList(FrmNo: Integer);
    procedure InsertStaticRowRec(FrmNo, SgRow: integer);
    procedure AddStaticRowRec(FrmNo, SgRow: integer);
    procedure DeleteImages;
    function GetFieldRec(FieldName: String; RowNo: integer): Pointer; overload;
    procedure UpdateNonGridRecordId;
    function GetFieldRec(fld: pFld; RowNo: integer): Pointer; overload;
    function RowCountForWeb(FrameNo: Integer): Integer;
    procedure LoadTransForWeb(RecordId: Extended);
    function GetRecordId(FrameNo, Rowno:integer):extended;

  End;

Function SortFieldListSave(Item1, Item2: Pointer): Integer;
Function SortFieldListLoad(Item1, Item2: Pointer): Integer;

Implementation

Constructor TStoreData.Create(Sdef:TStructDef; pTransid:String);
Begin
  Inherited Create;
  FieldList := nil;
  RowCountList := nil;
  RecordIdList := nil;
  SubFrames := nil;
  SubFramesParent := nil;
  StatusidFieldList:=nil;
  StatusflagFieldList:= nil;
  StatusidValuelist:=nil;
  AutoGenFields := nil;
  Prefixes := nil;
  PrefixFields:=nil;
  Autogentransid := nil;
  AutoFields := nil;
  AutoGenVals := nil;
  RowList := nil;
  ins_del_rows := nil;
  subgrid_del_recid_list := nil;
  SDEvaluateExpr := nil;
  SDRegVarToParser := nil;
  AxPEG := nil;
  ParserObject := nil;
  FieldList := TList.Create;
  sdImageList := TStringList.Create;
  RowCountList := TStringList.Create;
  RecordIdList := TStringList.Create;
  SubFrames := TStringList.create;
  SubFramesParent := TStringList.Create;
  StatusidFieldList:=Tstringlist.Create;
  StatusflagFieldList:= Tstringlist.Create;
  StatusidValuelist:=Tstringlist.Create;
  AutoGenFields := TStringList.create;
  Prefixes := TStringList.create;
  PrefixFields:=TStringList.create;
  Autogentransid := TStringList.create;
  AutoFields := TStringList.create;
  AutoGenVals := TStringList.create;
  RowList := TList.Create;
  ins_del_rows := TStringList.Create;
  subgrid_del_recid_list := TStringList.Create;

  LastSavedRecordId := 0;
  FieldOrder := 0;
  CompanyName := '';
  OldCompanyName := '';
  ChildTrans := false;
  EntryDocLoaded := false;
  ProgressBar := Nil;
  ControlField := '';
  DeleteControl := '';
  fTransType := '';
  Approval := 0;
  ApprovalStatus := '';
  MaxApproved := 0;
  ApprovalDefined := false;
  ApprovalNo := 0;
  PrimaryTableId := 0;
  ChildDoc := 'F';
  Cancelled := false;
  CancelRemarks := '';
  Deleted := False;
  IsCancelDefined := false;
  IsTransidDefined := false;
  OptionName := '';
  ModifiedOn := '';
  MapParentRecordId := 0;
  SourceId := 0;
  PublicSourceId := 0;
  SourcePrimaryId := 0;
  NoAutoGenStr := '';
  UndoAmendment := false;
  DataValidate := True;
  IsInsertToOutbound := False;
  IsFromAdx := false;
  ParentRowDefined := '';
  dqload:=nil;dqloadqualified:=nil;work:=nil;DQTrackFields:=nil;
  QSeq:=nil;QLockseq:=nil;historytable:=nil;qpkt:=nil;
  modtable:=nil;qupdseq:=nil;xtemp:=nil;tlink:=nil;tparents:=nil;
  StructDef := sdef;
  connection := structdef.axprovider.dbm.connection;
  CompanyName := structdef.SchemaName;
  transtype := pTransid;
  DetailStruct := False;
  HasWorkFlow:=false;
  tracklist := nil;
  tracklist := TStringlist.Create; // for track changes
  HasSendToSite := false;
  tosites:='';
  IsCreatedOnDefined := False;
  IsModifiedOnDefined := False;
  IsUserNameDefined := False;
  IsSiteNoDefined := False;
  IsMapNameDefined := False;
  timezone_diff := 0;
  ImgPath := '';
  AxpImagePath := '';
  webdata := false;
  ClientNotify:=false;
  parentcontrol := 0;
  Attachment_files := '';
  GridDc_Attach := false;
  RefreshCurrencyFld := nil;
  CancelledTrans := False;
  depCall := false;
  NoSaveFldDcs := nil;
  bDoNotInitPEG := False;
  bDoNotInitAmendment := False;
  bDoNotInitPEGorAmendment := False;
  Object_ASBDataObj := nil;
  DoPEGApprovalOnSave := False;
  sPEGTaskID := '';
  delrowsnode := nil;
  IsPegEdit := False;
  AxDataAmended := false;
  bCallFromStoreTrans := False;
  bCallFromAcceptAmend := False;
  
  AutoFastPrints := nil;
  AutoFastPrints := TStringList.Create;
End;

Destructor TStoreData.Destroy;
Begin
  closecursors;
  ClearFieldList;
  if Assigned(AxPEG) then
    FreeAndNil(AxPEG);
  if Assigned(FieldList) then
  begin
    FieldList.Clear;
    FreeandNil(FieldList);
  end;
  ClearRowList;
  if Assigned(RowCountList) then
  begin
    RowCountList.Clear;
    FreeandNil(RowCountList);
  end;
  if Assigned(sdImageList) then
  begin
    sdImageList.Clear;
    FreeAndNil(sdImageList);
  end;

  if Assigned(RecordIdList) then
  begin
    RecordIdList.Clear;
    RecordIdList.Free;
    RecordIdList := nil;
  end;
  if Assigned(subframes) then
  begin
    Subframes.clear;
    FreeandNil(subframes);
  end;
  if Assigned(RowList) then
  begin
    RowList.clear;
    FreeandNil(RowList);
  end;
  if Assigned(subframesparent) then
  begin
    subframesparent.clear;
    FreeandNil(subframesparent);
  end;
  if Assigned(AutoGenFields) then
  begin
    AutoGenFields.Clear;
    FreeandNil(AutoGenFields);
  end;
  if Assigned(Prefixes) then
  begin
    Prefixes.Clear;
    FreeandNil(Prefixes);
  end;
  if Assigned(PrefixFields) then
  begin
    PrefixFields.Clear;
    FreeandNil(PrefixFields);
  end;
  if Assigned(Autogentransid) then
  begin
    Autogentransid.Clear;
    FreeandNil(Autogentransid);
  end;
  if Assigned(AutoFields) then
  begin
    AutoFields.Clear;
    FreeandNil(AutoFields);
  end;
  if Assigned(AutoGenVals) then
  begin
    AutoGenVals.Clear;
    FreeandNil(AutoGenVals);
  end;
  if Assigned(StatusidFieldList) then
  begin
    StatusidFieldList.Clear;
    FreeandNil(StatusidFieldList);
  end;
  if Assigned(StatusflagFieldList) then
  begin
    StatusflagFieldList.Clear;
    FreeAndNil(StatusflagFieldList);
  end;
  if Assigned(StatusidValuelist) then
  begin
    StatusidValuelist.Clear;
    FreeAndNil(StatusidValuelist);
  end;
  if Assigned(ins_del_rows) then
  begin
    ins_del_rows.Clear;
    FreeAndNil(ins_del_rows);
  end;
  if Assigned(subgrid_del_recid_list) then
  begin
    subgrid_del_recid_list.Clear;
    FreeAndNil(subgrid_del_recid_list);
  end;
  if not DetailStruct then
  begin
    if Assigned(tracklist) then
    begin
      tracklist.Clear;
      FreeAndNil(tracklist); // for track changes
    end;
  end;
  if assigned(NoSaveFldDcs) then
  begin
    NoSaveFldDcs.Clear;
    FreeAndNil(NoSaveFldDcs);
  end;
  if Assigned(AutoFastPrints) then
  begin 
    AutoFastPrints.Clear;
    FreeAndNil(AutoFastPrints);
  end;
  Inherited Destroy;
End;

Procedure TStoreData.StoreTrans;
Var i, row, kf, k: integer;
    fp : pfld;
    fldname,imgfldname : String;
    rid : extended;
Begin
  //if not new trans or if PEGApprovalOnsave(For partial edit) is true then DoNotInitPEG or Amendment
  if (LastSavedRecordId > 0) then
  begin
    (*
    When the PEG transaction is returned to the previous level or initiator,
    and the same transaction is modified and saved for further PEG processing,
    we need to enable the PEG process while ensuring that the amendment is not enabled.
    Previously, by default, we did not initiate the PEG transaction for modified records.

    Note:
    - Normal PEG flow records will be loaded in readonly mode if they are in progress or completed (approved).
    - Returned PEG flow records will be loaded in edit mode. This flow is now handled appropriately.
    *)
    (*
    HasPegActiveTasks checks the AxActiveTasks and AxActiveTaskStatus tables to determine if there are any active
    PEG tasks for the current user and the current form

    Modified on 15-11-2023 :
    HasPegActiveTasks   - return / withdrawn found

    If any active task found then then do not init peg, else Init PEG.
    This function si required or not need to be confirmed on going frther.
    
    The below condition can be shortened. 

   *)
    if (bCallFromAcceptAmend and (structdef.isPegAttached)) or ((structdef.isPegAttached) and ((Not structdef.IsAmendmentEnabled) and (HasPegActiveTasks))) then
    begin
      bDoNotInitPEG := False; //Means , PEG will be initiated / resumed
      bDoNotInitAmendment := True;
    end
    else
    begin
      bDoNotInitPEG := True;

      //Partial field edits | will be for existing records
      if (DoPEGApprovalOnSave) then   //This can be brought inside the  (LastSavedRecordId > 0)
      begin
        bDoNotInitPEG := True;
        bDoNotInitAmendment := True;
      end;
    end;
  end;

  (*
  return true if process kept on hold, else false | default false
  when process is on hold the do not init peg

  By default process will be on hold for edittrans or when Axp_ProcessHold form var is set to 1
  by default process will be on unhold for new trans or when Axp_ProcessHold form var is set to 2

  Can DoPEGApprovalOnSave (partial edit) can override Axp_ProcessHold / not to be discussed.
  *)
  bCallFromStoreTrans := True;
  if IsProcessOnHold then
    bDoNotInitPEG := True
  else
    bDoNotInitPEG := False;
  bCallFromStoreTrans := False;

  //Is Amendment enabled
  if  (Not bDoNotInitAmendment) and ({not NewTrans}LastSavedRecordId > 0) and (structdef.IsAmendmentEnabled) then
  begin
    structdef.axprovider.dbm.gf.DoDebug.msg('StoreTrans/ calling SaveAmend.');
    SaveAmend;
    AxDataAmended := true;
    structdef.axprovider.dbm.gf.DoDebug.msg('StoreTrans/ SaveAmend completed.');
    Exit;
  end;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Writing to tables '+TransType);
  SetAutoGenList;

  if DataValidate then begin
    If (Approval > ApprovalNo) and (lowercase(approvalstatus)<>'e') Then
      Raise EDataBaseError.create('Transaction has been approved by higher authority. Cannot change');
    If ControlField <> '' Then Begin
      structdef.axprovider.dbm.gf.DoDebug.msg('Evaluating save control ' + Controlfield);
      kf := GetFieldIndex(ControlField, 1);
      If kf = -1 Then Raise EDataBaseError.Create('Invalid control field');
      If lowercase(pFieldRec(FieldList[kf]).Value) <> 't' Then
        Raise EDataBaseError.Create(pFieldRec(FieldList[kf]).Value);
//        Raise EDataBaseError.Create('Saving this document is not allowed. May be due to insufficiant details.');
    End;

    kf := GetFieldIndex('axp_parentcontrol', 1);
    If kf > -1 Then ParentControl := StrToInt(pFieldRec(FieldList[kf]).Value);
    if (PrimaryTableId > 0) and (ParentControl > 0) and (not NewTrans) and (not childtrans) then begin
      Raise EDataBaseError.Create('Transaction has been exported. Cannot change');
    end;

  end;

  tosites:='';
  first := true;
  FieldList.Sort(SortFieldListSave);
  AfterSort;
  TableName := '';
  MasterTableName := '';
  row := 0;
  RecordIdList.Clear;
  RemoveDeletedRows;
  DeleteImages;
  CreatedOn := ''; CreatedBy:='';SUserName := ''; SSiteNo:='';SModifiedOn := '';
  For i := 0 To FieldList.count - 1 Do Begin
    If PFieldRec(FieldList[i]).TableName = ''  Then continue;
    If pFieldRec(FieldList[i]).RowNo < 0 Then continue;
    If lowercase(TableName) <> lowercase(PFieldRec(FieldList[i]).TableName) Then
    Begin
      If TableName <> '' Then begin
        if (Lowercase(tablename) <>  lowercase(primarytablename)) then begin
          fld := Structdef.GetField(fldname);
          if (fld.AsGrid) then begin
            structdef.axprovider.dbm.gf.DoDebug.msg(tablename+'row'+' = '+inttostr(row));
            modtable.submit(tablename+'row', IntToStr(row), 'n');
          end;
        end;
        If (modtable.Editing) or (modtable.Inserting) Then begin
          structdef.axprovider.dbm.gf.DoDebug.msg('Posting record');
          ModTable.BeforePost := CheckAutoGen;
          modtable.post;
        end;
      end;
      TableName := PFieldRec(FieldList[i]).TableName;
      structdef.axprovider.dbm.gf.DoDebug.msg('Saving to table '+ Tablename);
      row := PFieldRec(FieldList[i]).RowNo;
      SaveRow(i);
      first := false;
    End Else If (row <> PFieldRec(FieldList[i]).RowNo) Then Begin
      if (Lowercase(tablename) <>  lowercase(primarytablename)) then begin
        fld := Structdef.GetField(fldname);
        if (fld.AsGrid) then begin
          structdef.axprovider.dbm.gf.DoDebug.msg(tablename+'row'+' = '+inttostr(row));
          modtable.submit(tablename+'row', IntToStr(row), 'n');
        end;
      end;
      If (modtable.Inserting) Or (modtable.Editing) Then begin
        structdef.axprovider.dbm.gf.DoDebug.msg('Posting record');
        ModTable.BeforePost := CheckAutoGen;
        modtable.post;
      end;
      Row := PFieldRec(FieldList[i]).RowNo;
      ShowProgress('Storing row no. ' + IntToStr(Row));
      SaveRow(i);
    End;
    fldname := pFieldRec(FieldList[i]).FieldName;

    if (autogenfields.indexof(pFieldRec(FieldList[i]).FieldName) <> -1) then begin
      if (pFieldRec(FieldList[i]).recordid > 0) or (pos(';'+pFieldRec(FieldList[i]).FieldName+';', NoAutoGenStr) > 0) then
       ModTable.submit(PFieldRec(fieldlist[i]).fieldname, pFieldRec(FieldList[i]).Value, 'c')
      else begin
       pFieldRec(FieldList[i]).Value := GetLastNo(PFieldRec(fieldlist[i]).fieldname, false);
       ModTable.submit(PFieldRec(fieldlist[i]).fieldname, pFieldRec(FieldList[i]).Value, 'c');
      end;
      structdef.axprovider.dbm.gf.DoDebug.msg(pFieldRec(FieldList[i]).FieldName+' = '+pFieldRec(FieldList[i]).Value);
    end else if (PFieldRec(fieldlist[i]).value = 'primaryrecordid') then begin
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, floattostr(SourcePrimaryId), 'n');
      if PFieldRec(fieldlist[i]).Sourcekey then
       PFieldRec(fieldlist[i]).idvalue := SourcePrimaryId
      else
       PFieldRec(fieldlist[i]).value := FloatTostr(SourcePrimaryId);
    end else if (PFieldRec(fieldlist[i]).value = 'sourcerecordid') then begin
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, floattostr(SourceId), 'n');
      if PFieldRec(fieldlist[i]).Sourcekey then
        PFieldRec(fieldlist[i]).idvalue := SourceId
      else
        PFieldRec(fieldlist[i]).value := floattostr(SourceId);
    end else if (PFieldRec(fieldlist[i]).value = 'parentrecordid') then
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, floattostr(mapparentrecordid), 'n')
    Else If PFieldRec(fieldlist[i]).SourceKey Then begin
      structdef.axprovider.dbm.gf.DoDebug.msg(pFieldRec(FieldList[i]).FieldName+' = '+FloatToStr(pFieldRec(FieldList[i]).IdValue));
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, floattostr(PFieldRec(fieldlist[i]).IdValue), 'n');
    end Else If lowercase(PFieldRec(fieldlist[i]).fieldname) = lowercase(tablename)+ 'row' Then begin
      structdef.axprovider.dbm.gf.DoDebug.msg(pFieldRec(FieldList[i]).FieldName+' = '+IntToStr(PFieldRec(fieldlist[i]).RowNo));
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, IntToStr(PFieldRec(fieldlist[i]).RowNo), 'n');
    end Else begin
      structdef.axprovider.dbm.gf.DoDebug.msg(pFieldRec(FieldList[i]).FieldName+' = '+pFieldRec(FieldList[i]).Value);
      modtable.submit(PFieldRec(fieldlist[i]).fieldname, PFieldRec(fieldlist[i]).Value, PFieldRec(fieldlist[i]).datatype);
      imgfldname := 'dc'+Trim(IntTostr(PFieldRec(fieldlist[i]).FrameNo))+'_image';
      if lowercase(PFieldRec(fieldlist[i]).fieldname) = imgfldname then
        SaveImages(i);
    end;
    if GetParentDocid(PFieldRec(fieldlist[i]).FrameNo, PFieldRec(fieldlist[i]).RowNo) = 0 then
     SetParentDocId(PFieldRec(fieldlist[i]).TableName, PFieldRec(fieldlist[i]).FrameNo)
  End;
  If (modtable.Editing) Or (modtable.Inserting) Then begin
    if (Lowercase(tablename) <>  lowercase(primarytablename)) then begin
      fld := Structdef.GetField(fldname);
      if (fld.AsGrid) then begin
        structdef.axprovider.dbm.gf.DoDebug.msg(tablename+'row'+' = '+inttostr(row));
        modtable.submit(tablename+'row', IntToStr(row), 'n');
      end;
    end;
    structdef.axprovider.dbm.gf.DoDebug.msg('Posting record');
    ModTable.BeforePost := CheckAutoGen;
    modtable.post;
  end;

  for i := 0 to structdef.frames.Count-1 do begin
    rid := GetParentDocid(pFrm(structdef.frames[i]).FrameNo,1);
    if rid = 0 then begin
      rid := GetRecordId(pFrm(structdef.frames[i]).FrameNo,1);
      if rid = 0 then
      begin
        rid := GetTableId(pFrm(structdef.frames[i]).TableName);
      end;

      RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(pFrm(structdef.frames[i]).FrameNo), 3, ' ') + structdef.axprovider.dbm.gf.Pad('1', 5, ' ') + structdef.axprovider.dbm.gf.pad(FloatToStr(rid), structdef.axprovider.dbm.gf.MaxRecid, ' ') + pFrm(structdef.frames[i]).TableName);
    end;
  end;

//  saveHistory(false);  // Commeted on 13052009
  if (assigned(MDMap)) and (not cancelled) then begin
//    MDMap.CompanyName := CompanyName;
    MDMap.GetFieldData := GetFieldData;
    MDMap.GetRowCount := GetRowCount;
    MDMap.NewTrans := NewTrans;
    MDMap.Submit(TransType, false);
  end;
  if hassendtosite then sendtosites(NewTran);
  if (IsInsertToOutbound) and (not IsFromAdx) then
    InsertinOutboundTable(transtype, PrimaryTableId);
  ParentControl := 0;

  //Process AxProcesDef
  if structdef.isPegAttached then CheckAxProcessDef;
  if DoPEGApprovalOnSave then
    CallPEGApproveUsingTaskId(sPEGTaskID);


  //PushSaveDataToQueue
  //Reverted now, since there are some definition changes planned.
  //PushSaveDataToQueue;
End;


Procedure TStoreData.SaveRow(i: integer);
var k:integer;
    s:String;
Begin
  xtemp:=structdef.axprovider.dbm.GetXDS(xtemp);
  xtemp.buffered:=true;
  xtemp.cds.CommandText:='select * from '+companyname+tablename+' where '+tablename+'id='+floattostr(pFieldRec(FieldList[i]).recordid);
  xtemp.open;
  If PFieldRec(fieldlist[i]).RecordId <> 0 Then Begin
    structdef.axprovider.dbm.gf.DoDebug.msg('Modifying Record '+ FloatToStr(PFieldRec(fieldlist[i]).RecordId)+ 'To store data from Frame '+IntToStr(PFieldRec(fieldlist[i]).Frameno)+', Row '+IntToStr(PFieldRec(fieldlist[i]).Rowno)+' Parent Row '+IntToStr(PFieldRec(fieldlist[i]).ParentRowNo));
    ModTable.Edit(companyname+tablename, tablename+'id='+FloatToStr(PFieldRec(fieldlist[i]).RecordId));
    If (first) and (assigned(xtemp.cds.FindField('Approval'))) Then
      Modtable.Submit('approval', inttostr(approvalno), 'n');
    NewRecid := PFieldRec(fieldlist[i]).RecordId;
    if Lowercase(tablename) =  lowercase(primarytablename) then NewTrans := false;
  End Else begin
    k := getfieldindex(tablename+'id', PFieldRec(fieldlist[i]).rowno);
    if k=-1 then newrecid :=0 else newrecid := strtofloat(pfieldrec(fieldlist[k]).value);
    structdef.axprovider.dbm.gf.DoDebug.msg('Adding new record to store data from Frame '+IntToStr(PFieldRec(fieldlist[i]).Frameno)+', Row '+IntToStr(PFieldRec(fieldlist[i]).Rowno)+' Parent Row '+IntToStr(PFieldRec(fieldlist[i]).ParentRowNo));
    AddRow;
    if Lowercase(tablename) =  lowercase(primarytablename) then NewTrans := true;
  end;

//  if (not StructDef.axprovider.dbm.gf.IsService) and (not StructDef.axprovider.dbm.gf.FromAdr) then
//  begin
    if not StructDef.axprovider.dbm.gf.evalCopy then
    begin
      if (NewTrans) and (Lowercase(tablename) =  lowercase(primarytablename)) then
      begin
        if assigned(StructDef.axprovider.lm) then
        begin
          s := StructDef.axprovider.lm.GetNoOfTrans(transtype,companyname+primarytablename,tablename+'id');
          if s <> '' then Raise EDataBaseError.create(s);
        end;
      end;
    end;
//  end;

  If lowercase(TableName) = lowercase(PrimaryTableName) Then begin
    PrimaryTableId := NewRecid;
    Recid := NewRecid;
    LastSavedRecordid:=NewRecid;
    if structdef.treetables<>'' then updatetreelink('add');
  end;

  if (mapname <> '') and (structdef.axprovider.dbm.gf.PostAutoGen) then
  begin
    UpdateRecIdInAutoGenData(PFieldRec(fieldlist[i]).RowNo);
  end;

  RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(PFieldRec(fieldlist[i]).FrameNo), 3, ' ') + structdef.axprovider.dbm.gf.Pad(IntToStr(PFieldRec(fieldlist[i]).RowNo), 5, ' ') + structdef.axprovider.dbm.gf.pad(FloatToStr(NewRecid), structdef.axprovider.dbm.gf.MaxRecid, ' ') + PFieldRec(fieldlist[i]).TableName);

  If (first) And (ApprovalDefined) Then Begin
    if lowercase(approvalstatus)='e' then approvalstatus:='W';
    modtable.Submit('ApprovalStatus', approvalstatus, 'c');
    modtable.submit('maxapproved', inttostr(maxapproved), 'n');
  End;

  if (assigned(xtemp.CDS.FindField('CreatedBy'))) Then begin
    If (NewTrans) then begin
      k := getfieldindex('createdby', PFieldRec(fieldlist[i]).rowno);
      if (k<>-1) and (pfieldrec(fieldlist[k]).Value <> '') then begin
        modtable.submit('createdby', pfieldrec(fieldlist[k]).Value, 'c');
        CreatedBy := pfieldrec(fieldlist[k]).Value;
      end else begin
        modtable.submit('createdby', username, 'c');
        CreatedBy := username;
      end;
    end else
      CreatedBy := xtemp.CDS.fieldbyname('CreatedBy').AsString;
  end;

  if (assigned(xtemp.CDS.FindField('CreatedOn'))) then begin
    If (NewTrans) Then begin
      k := getfieldindex('CreatedOn', PFieldRec(fieldlist[i]).rowno);
      if (k<>-1) and (pfieldrec(fieldlist[k]).Value <> '') then begin
        if timezone_diff <> 0 then
           modtable.submit('CreatedOn', datetimetostr(strtodatetime(pfieldrec(fieldlist[k]).Value) + timezone_diff), 'd')
        else modtable.submit('CreatedOn',pfieldrec(fieldlist[k]).Value , 'd');
        CreatedOn := pfieldrec(fieldlist[k]).Value;
      end else begin
        if timezone_diff <> 0 then
           s:=datetimetostr(structdef.axprovider.dbm.getserverdatetime+timezone_diff)
        else s:=datetimetostr(structdef.axprovider.dbm.getserverdatetime);
        modtable.Submit('createdon', s, 'd');
        CreatedOn := s;
      end;
    end else
      CreatedOn := xtemp.CDS.fieldbyname('CreatedOn').AsString;
  end;
  k := getfieldindex('UserName', PFieldRec(fieldlist[i]).rowno);
  if k<>-1 then
    s := pfieldrec(fieldlist[k]).Value
  else
    s := username;
  If assigned(xtemp.CDS.FindField('UserName')) Then begin
    modtable.submit('username', s, 'c');
    SUserName := s;
  end;

  k := getfieldindex('ModifiedOn', PFieldRec(fieldlist[i]).rowno);
  if k<>-1 then
  begin
    if timezone_diff <> 0 then
       s := datetimetostr((strtodatetime(pfieldrec(fieldlist[k]).Value) + timezone_diff))
    else s:=pfieldrec(fieldlist[k]).Value;
  end else begin
    if timezone_diff <> 0 then
       s:=datetimetostr(structdef.axprovider.dbm.getserverdatetime+timezone_diff)
    else s:=datetimetostr(structdef.axprovider.dbm.getserverdatetime);
  end;
  If assigned(xtemp.CDS.FindField('ModifiedOn')) Then begin
  if ModifiedOn <> '' then
      if timezone_diff <> 0 then
      s:=datetimetostr((strtodate(modifiedon)+timezone_diff))
      else s:=modifiedon;
    modtable.Submit('modifiedon', s, 'd');
    SModifiedOn := s;
  end;

  if (DetailStruct) and (Lowercase(tablename) =  lowercase(DetailTableName)) then
  begin
    if assigned(xtemp.cds.FindField('masterrecord')) then
      modtable.Submit('masterrecord', floattostr(MasterRecord),'n');
    if assigned(xtemp.cds.FindField('secondaryrecord')) then
      modtable.Submit('secondaryrecord', floattostr(secondaryRecord),'n');
  end;
  if assigned(xtemp.cds.findfield('app_desc')) and (not hasworkflow) then begin
    modtable.submit('app_desc', '1', 'c');
    modtable.submit('app_level', '1', 'c');
  end;
  If PFieldRec(fieldlist[i]).ParentRowNo <> 0 Then
    StoreParentRecordId(i);
  k := getfieldindex('parentrecordid', PFieldRec(fieldlist[i]).rowno);
  if (subframes.indexof(inttostr(PFieldRec(fieldlist[i]).frameno)) <> -1) and (k <> -1) and (pfieldrec(fieldlist[k]).Value <> '') then
    modtable.Submit('parentrecordid', pfieldrec(fieldlist[k]).value, 'n');
  if assigned(xtemp.cds.FindField('parentrow')) then
    modtable.Submit('parentrow', inttostr(pFieldRec(FieldList[i]).ParentRowNo),'n');
  k := getfieldindex('Siteno', PFieldRec(fieldlist[i]).rowno);
  if k<>-1 then
    s := pfieldrec(fieldlist[k]).Value
  else
    s := IntToStr(SiteNo);
  if assigned(xtemp.CDS.FindField('SiteNo')) then begin
    modtable.Submit('siteno', s, 'n');
    structdef.axprovider.dbm.gf.DoDebug.msg('SiteNo '+s);
    SSiteNo := s;
  end;
  xtemp.close;
End;

Procedure TStoreData.AddRow;
Var
  i: integer;
  Temp: TField;
  f : String;
Begin
  ModTable.Append(companyname+tablename);
  For i := 0 To xtemp.cds.fields.Count - 1 Do Begin
    f := xtemp.cds.Fields[i].FieldName;
    If (xtemp.cds.Fields[i].DataType = ftInteger) or (xtemp.cds.fields[i].datatype=ftFloat) Then
      modtable.submit(f, '0', 'n');
  End;

  if newrecid = 0 then
   NewRecId := structdef.axprovider.dbm.Gen_id(structdef.axprovider.dbm.connection);
  modtable.submit(tablename+'id', floattostr(newrecid), 'n');
  structdef.axprovider.dbm.gf.DoDebug.msg('RecordId = '+FloatToStr(NewRecid));

  If (first) and (assigned(xtemp.cds.FindField('Approval'))) Then
    modtable.submit('Approval', inttostr(approvalno), 'n');

  If lowercase(TableName) <> lowercase(PrimaryTableName) Then
    modtable.Submit(primarytablename+'id', floattostr(primarytableid), 'n');
  If assigned(xtemp.cds.FindField('mapname')) Then Begin
    modtable.Submit('mapname', mapname, 'c');
    modtable.Submit('sourceid', Floattostr(SourceId), 'n');
    structdef.axprovider.dbm.gf.DoDebug.msg('MapName '+mapname);
    structdef.axprovider.dbm.gf.DoDebug.msg('SourceId '+FloatToStr(SourceId));
  End;
  if assigned(xtemp.cds.FindField('cancel')) then
   modtable.Submit('cancel','F','c');
End;

Procedure TStoreData.RemoveDeletedRows;
Var i, newrow: integer;
Begin
  Recid := 0;
  i := 0;
  TableName := '';
  NewRow := 0;
  While (i < fieldlist.count) Do Begin
    If (PFieldRec(FieldList[i]).RowNo = -1) Then Begin
      If (Recid <> PFieldRec(fieldlist[i]).Recordid) And
        (PFieldRec(fieldlist[i]).Recordid <> 0) And
        (PFieldRec(FieldList[i]).TableName <> '') Then Begin
        If lowercase(TableName) <> lowercase(PFieldRec(FieldList[i]).TableName) Then
          TableName := PFieldRec(FieldList[i]).TableName;
        structdef.axprovider.dbm.gf.DoDebug.msg('Deleting from '+TableName+', Record '+FloatToStr(PFieldRec(fieldlist[i]).RecordId)+', Frame No '+IntToStr(PFieldRec(fieldlist[i]).FrameNo)+', Row No '+IntToStr(PFieldRec(fieldlist[i]).RowNo));
        modtable.DeleteRecord(companyname+tablename, tablename+'id='+FloatToStr(PFieldRec(fieldlist[i]).RecordId));
        Recid := PFieldRec(fieldlist[i]).Recordid;
        dec(newrow);
      End;
      if pFieldRec(FieldList[i]).RowNo > 0 then
        PFieldRec(FieldList[i]).RowNo := NewRow;
      inc(i);
    End Else
      inc(i);
  End;
  Recid := 0;
  TableName := '';
End;

Function SortFieldListSave(Item1, Item2: Pointer): Integer;
Begin
  result := 0;
  If PFieldRec(Item1).PrimaryTable < PFieldRec(Item2).PrimaryTable Then
    result := -1
  Else If PFieldRec(Item1).PrimaryTable > PFieldRec(Item2).PrimaryTable Then
    result := 1
  Else Begin
    If PFieldRec(Item1).TableName < PfieldRec(Item2).Tablename Then result := -1
    Else If PFieldRec(Item1).TableName > PfieldRec(Item2).Tablename Then
      result := 1
    Else If PFieldRec(Item1).TableName = PfieldRec(Item2).Tablename Then Begin
      If PFieldRec(Item1).RowNo < PfieldRec(Item2).RowNo Then result := -1
      Else If PFieldRec(Item1).RowNo > PfieldRec(Item2).RowNo Then result := 1
      Else If PFieldRec(Item1).RowNo = PfieldRec(Item2).RowNo Then Begin
        If PFieldRec(Item1).RecordId < PfieldRec(Item2).Recordid Then
          result := -1
        Else If PFieldRec(Item1).RecordId > PfieldRec(Item2).Recordid Then
          result := 1
        Else result := 0
      End;
    End;
  End;
End;

Procedure TStoreData.SetFieldValue(FieldName, DataType, TableName, Value,
  OldValue: String; RowNo:integer; IdValue, OldIdValue :extended; FrameNo: integer; RecordId:Extended ;
  SourceKey: Boolean);
Var
  frec: pFieldRec;
  p: integer;
  ov: String;
  y,m,d : word ;
  fp : pFld;
Begin
  datatype := lowercase(datatype);
  if datatype = 'd' then
  begin
     if value <> '' then
     begin
       DecodeDate(strtodatetime(value),y,m,d);
       if y <= 1900 then value := '';
     end;
  end;
//stringlist obj(stImageList.add())//index value //fldname+framenum(dc number) =value(fldvalue)
//picture1='abc.png'
  if Datatype = 'i' then
  begin
    sdImageList.Add(fieldname + intTostr(frameno) + '=' + value);
  end;
  if DataType = 'i' then exit;
  if (rowno = -1) then
    p := -1
  else
    p := GetIndex(FieldName, TableName, RowNo);
  If p = -1 Then Begin
    new(frec);
    frec.DataType := DataType;
    frec.FrameNo := FrameNo;
    frec.RecordId := RecordId;
    frec.FieldName := Fieldname;
    frec.TableName := UpperCase(TableName);
    frec.RowNo := RowNo;
    frec.SourceKey := SourceKey;
    frec.AutoValue:=false;
    If lowercase(TableName) = lowercase(PrimaryTableName) Then
      frec.PrimaryTable := 'a'
    Else begin
      if subframes.indexof(Inttostr(FrameNo)) = -1 then
       frec.PrimaryTable := 'b'
      else
       frec.PrimaryTable := 'x';
    end;
    If (DataType = 'n') And (OldValue = '') Then
      frec.OldValue := '0'
    Else
      frec.OldValue := OldValue;
    frec.OldIdValue := OldIdValue;
    frec.ParentRowNo := 0;
    frec.ZeroValue := true;
    fp:=structdef.GetField(fieldname);
    frec.fld := fp;
    if assigned(fp) then
      frec.Orders := fp.orderno
    else frec.Orders := 0;
    FieldList.Add(frec);
    p:=FieldList.Count-1;
    if (structdef.quickload) then
    begin
       if assigned(fp) and (fp.AsGrid) then
          if (value <> '') or ((datatype = 'n') and (value <> '0') and (value <> '0.00')) then
             InsertedRowNoInfo(fp.FrameNo,rowno);
    end else if assigned(fp) and (fp.AsGrid) then InsertedRowNoInfo(fp.FrameNo,rowno);
  End Else
    frec := FieldList.Items[p];

  ov := frec.Value;

  If (DataType = 'd') And (IsDateEmpty(Value)) Then
    frec.Value := ''
  Else If (datatype = 'n') Then Begin
    If (value = '') Then begin
      frec.value := '0';
      frec.ZeroValue := false;
    end Else begin

      frec.value := structdef.axprovider.dbm.gf.RemoveCommas(Value) ;
      frec.ZeroValue := True;
    end;
  End Else
    frec.Value := Value;
  if (frec.AutoValue) and (ov <> frec.value) then
    frec.AutoValue:=false;
  if webdata then frec.webvalue := value;
  frec.ClientNotify:=ClientNotify;
  frec.IdValue := IdValue;
  frec.OldRow := 0;
  if assigned(frec.fld) and (frec.fld.DataRows.indexof(inttostr(p))=-1) then
    frec.fld.DataRows.Add(inttostr(p));
  if (Trim(value) <> '') and (RowNo>0) and (lowercase(fieldname) = 'axpcurrencydec') then
     SetCurrencyDec(value,RowNo);
End;

Procedure TStoreData.DirectSubmitValue(fld:pFld; Value, OldValue: String; RowNo:integer; IdValue, OldIdValue, RecordId:Extended);
Var
  frec: pFieldRec;
  p: integer;
  ov: String;
  y,m,d : word ;
Begin
  if fld.datatype = 'd' then
  begin
     if value <> '' then
     begin
       DecodeDate(strtodatetime(value),y,m,d);
       if y <= 1900 then value := '';
     end;
  end;
  //Newly Added
  ///////////////////
   if fld.datatype = 'i' then
  begin
    sdImageList.Add(fld.fieldname + intTostr(fld.frameno) + '=' + value);
  end;
  if fld.DataType = 'i' then exit;
  p:=-1;
  If p = -1 Then Begin
    new(frec);
    frec.DataType := fld.DataType;
    frec.FrameNo := fld.FrameNo;
    frec.RecordId := RecordId;
    frec.FieldName := fld.Fieldname;
    frec.TableName := UpperCase(fld.Tablename);
    frec.RowNo := RowNo;
    frec.SourceKey := fld.SourceKey;
    frec.AutoValue:=false;
    If lowercase(fld.TableName) = lowercase(PrimaryTableName) Then
      frec.PrimaryTable := 'a'
    Else begin
      if subframes.indexof(Inttostr(fld.FrameNo)) = -1 then
       frec.PrimaryTable := 'b'
      else
       frec.PrimaryTable := 'x';
    end;
    If (fld.DataType = 'n') And (OldValue = '') Then
      frec.OldValue := '0'
    Else
      frec.OldValue := OldValue;
    frec.OldIdValue := OldIdValue;
    frec.ParentRowNo := 0;
    frec.ZeroValue := true;
    frec.fld := fld;
    frec.Orders := fld.orderno;
    FieldList.Add(frec);
    p:=FieldList.Count-1;
  End Else
    frec := FieldList.Items[p];

  ov := frec.Value;
  if fld.EncryptValue then value := structdef.axprovider.dbm.gf.EncryptFldValue(value,fld.datatype);
  If (fld.DataType = 'd') And (IsDateEmpty(Value)) Then
    frec.Value := ''
  Else If (fld.datatype = 'n') Then Begin
    If (value = '') Then begin
      frec.value := '0';
      frec.ZeroValue := false;
    end Else begin
      frec.value := structdef.axprovider.dbm.gf.RemoveCommas(Value);
      frec.ZeroValue := True;
    end;
  End Else
    frec.Value := Value;
  if (frec.AutoValue) and (ov <> frec.value) then
    frec.AutoValue:=false;
  if webdata then frec.webvalue := value;
  frec.ClientNotify:=ClientNotify;
  frec.IdValue := IdValue;
  frec.OldRow := 0;
  if frec.fld.DataRows.indexof(inttostr(p))=-1 then
    frec.fld.DataRows.Add(inttostr(p));
End;

Function TStoreData.GetIndex(FieldName, TableName: String; RowNo: Integer):
  integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (lowercase(pFieldRec(fieldlist[i]).FieldName) = lowercase(fieldname)) And
      (pFieldRec(FieldList[i]).RowNo = RowNo) And
      (lowercase(pFieldRec(fieldlist[i]).TableName) = lowercase(tablename)) Then
      Begin
      result := i;
      break;
    End;
  End;
End;

Procedure TStoreData.SetRecFieldValue(FieldName, DataType, TableName, Value,
  OldValue: String; RowNo:integer; IdValue, OldIdValue :extended; FrameNo: integer; RecordId:Extended ;
  SourceKey: Boolean);
Var
  frec: pFieldRec;
  p: integer;
Begin
  datatype := lowercase(datatype);
  p := GetRecIndex(FieldName, TableName, RecordId);
  If p = -1 Then Begin
    new(frec);
    frec.DataType := DataType;
    frec.FrameNo := FrameNo;
    //frec.RecordId := RecordId;
    frec.RecordId := 0;
    frec.FieldName := Fieldname;
    frec.TableName := UpperCase(TableName);
    frec.RowNo := RowNo;
    frec.Orders := FieldOrder;
    frec.SourceKey := SourceKey;
    frec.ZeroValue := true;
    If lowercase(TableName) = lowercase(PrimaryTableName) Then
      frec.PrimaryTable := 'a'
    Else begin
      if subframes.indexof(Inttostr(FrameNo)) = -1 then
       frec.PrimaryTable := 'b'
      else
       frec.PrimaryTable := 'x';
    end;
    If (DataType = 'n') And (OldValue = '') Then
      frec.OldValue := '0'
    Else
      frec.OldValue := OldValue;
    frec.OldIdValue := OldIdValue;
    frec.ParentRowNo := 0;
    FieldList.Add(frec);
  End Else
    frec := FieldList.Items[p];

  If (DataType = 'd') And (IsDateEmpty(Value)) Then
    frec.Value := ''
  Else If (datatype = 'n') Then Begin
    If (value = '') Then
      frec.value := '0'
    Else
      frec.value := structdef.axprovider.dbm.gf.RemoveCommas(Value);
  End Else
    frec.Value := Value;
  frec.IdValue := IdValue;
  frec.OldRow := 0;
  frec.RowNo := rowno;
End;

Function TStoreData.GetRecIndex(FieldName, TableName: String; RecordId: extended):
  integer;
Var
  i: integer;
Begin
  result := -1;
  if recordid = 0 then exit;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (lowercase(pFieldRec(fieldlist[i]).FieldName) = lowercase(fieldname)) And
      (pFieldRec(FieldList[i]).RecordId = Recordid) And
      (lowercase(pFieldRec(fieldlist[i]).TableName) = lowercase(tablename)) Then
      Begin
      result := i;
      break;
    End;
  End;
End;

Procedure TStoreData.LoadTrans(RecordId: Extended);
Var
  bk, RowNo, rcount, k, pr, priorpr, f, i, x : integer;
  value: String;
  id : extended;
  PRowDefined : Boolean;
Begin
  Attachment_files := '';
  GridDc_Attach := false;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Loading transaction '+ftranstype+ ' record '+floattostr(recordid));
  ClearFieldList;
  RowCountList.clear;
  ParentControl := 0;
  for x := 0 to structdef.framecount-1 do
    rowcountlist.add('0');
  PrimaryTableId := RecordId;
  RecId := RecordId;
  TableName := '';
  FirstTableName := '';
  RecordIdList.Clear;
  EntryDocLoaded := false;
  Cancelled := false;
  CancelledTrans := false;
  CancelRemarks := '';
  Deleted := False;
  structdef.flds.sort(sortfldsload);
  i:=0;
  while i<structdef.flds.count do begin
    if (pfld(structdef.flds[i]).tablename='') or (pfld(structdef.flds[i]).Datatype = 'i') then begin
      inc(i);
      continue;
    end;
    fld := pfld(structdef.flds[i]);
    TableName := fld.tablename;
    If FirstTableName = '' Then FirstTableName := TableName;
    bk := i;
    LoadIntoDataSet(i);
    PriorPR := 0;
    EntryDocLoaded := (EntryDocLoaded) Or (Not DQLoad.CDS.IsEmpty);
    If (ChildTrans) And (TableName = FirstTableName) Then
      Recid := DQLoad.cds.FieldByName(TableName + 'Id').AsFloat;
    fld := pfld(structdef.flds[i]);
    If (TableName = FirstTableName) Then Begin
      If ApprovalDefined Then Begin
        Self.Approval := DQLoad.cds.FieldByName('Approval').AsInteger;
        Self.ApprovalStatus := DQLoad.cds.FieldByName('ApprovalStatus').AsString;
        Self.MaxApproved := DQLoad.cds.FieldByName('MaxApproved').AsInteger;
      End;
      If DQLoad.CDS.Fieldbyname('SourceId').asFloat > 0 Then
        Self.ChildDoc := 'T'
      Else
        Self.ChildDoc := 'F';
    End;
    RowNo := 1;

    If DQLoad.CDS.Eof Then Begin
      While (i<structdef.flds.count) And (pfld(structdef.flds[i]).tablename = tablename) and (pfld(structdef.flds[i]).Datatype <> 'i') Do Begin
        fld := pfld(structdef.flds[i]);
        If RowCountList.Count < fld.frameno Then
          RowCountList.Add('0')
        Else If StrToInt(RowCountList[fld.frameno - 1])<0 Then
          RowCountList[fld.frameno - 1] := '0';
        inc(i);
      End;
    End;
    RCount := 0;
    PRowDefined := assigned(DQLoad.CDS.FindField('parentrow'));
    While Not DQLoad.cds.Eof Do Begin
      i:=bk;
      fld := pfld(structdef.flds[i]);
      RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(fld.frameno), 3, ' ')
        + structdef.axprovider.dbm.gf.Pad(IntToStr(RowNo), 5, ' ') + structdef.axprovider.dbm.gf.pad(DQLoad.cds.FieldByName(TableName +'id').asstring,structdef.axprovider.dbm.gf.MaxRecid,' ')+Tablename);
      inc(RCount);
      structdef.axprovider.dbm.gf.DoDebug.msg('Loading from '+ DQLoad.cds.FieldByName(TableName +'id').asstring +' into frame '+inttostr(fld.frameno)+', row '+inttostr(rowno));
      While (i<structdef.flds.count) And (pfld(structdef.flds[i]).tablename = tablename) and (pfld(structdef.flds[i]).Datatype <> 'i') Do Begin
        fld := pfld(structdef.flds[i]);
        If RowCountList.Count < fld.frameno Then
          RowCountList.Add(IntToStr(RCount))
        Else If StrToInt(RowCountList[fld.frameno - 1]) < RCount Then
          RowCountList[fld.frameno - 1] := IntToStr(RCount);
        If fld.sourcekey Then Begin
          Value := GetValueFromTable(Rowno);
          id := DQload.cds.fieldbyname(fld.fieldname).asfloat;
        End Else Begin
          if fld.DataType = 'n' then begin
            if fld.Dec = 0 then
              value := floattostr(DQload.cds.fieldbyname(fld.fieldname).asfloat)
            else
              value := FormatFloat('0.######################',DQload.cds.fieldbyname(fld.fieldname).asfloat)
          end else
            value := DQload.cds.fieldbyname(fld.fieldname).asstring;
          id := 0;
        End;
        if fld.EncryptValue then value := structdef.axprovider.dbm.gf.DecryptFldValue(value,fld.datatype);
        Fieldorder := fld.orderno;
        structdef.axprovider.dbm.gf.DoDebug.msg(fld.fieldname + ' = '+Value);
        if Id > 0 then structdef.axprovider.dbm.gf.DoDebug.msg('IdValue = '+FloatTostr(id));
        if (lowercase(fld.fieldname) = 'axp_attach') and (value <> '') then
        begin
            GridDc_Attach := true;
            Attachment_files := 'trans data loaded';
        end;

        SetFieldValue(fld.fieldname,
          fld.datatype,
          fld.tablename,
          value,
          value,
          RowNo,
          id,
          id,
          fld.frameno,
          DQLoad.cds.fieldbyname(TableName + 'id').asfloat,
          fld.sourcekey);

        if PRowDefined then begin
          k := getfieldindex(fld.fieldname, rowno);
          pFieldRec(Self.FieldList[k]).ParentRowNo := DQLoad.cds.Fieldbyname('parentrow').asinteger;
        end else begin
          f := SubFrames.Indexof(inttostr(fld.frameno));
          If (f <> -1) Then begin
            pr := GetParentRowNo(StrToInt(trim(SubFramesParent[f])), DQLoad.cds.fieldbyname('ParentRecordid').asFloat);
            if pr < PriorPr then
              Raise EDataBaseError.Create('Improper RowOrder in Sub form, Frame No '+subframes[f]);
            SetParentRowNo(fld.fieldname, RowNo, pr);
            PriorPr := pr;
          end;
        end;
        inc(i);
      End;
      DQLoad.cds.next;
      inc(RowNo);
    End;
  End;
  for i := 0 to structdef.frames.Count-1 do begin
    id := GetParentDocid(pFrm(structdef.frames[i]).FrameNo,1);
    if id = 0 then begin
      id := GetRecordId(pFrm(structdef.frames[i]).FrameNo,1);
      if id = 0 then
      begin
        id := GetTableId(pFrm(structdef.frames[i]).TableName);
      end;
      RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(pFrm(structdef.frames[i]).FrameNo), 3, ' ') + structdef.axprovider.dbm.gf.Pad('1', 5, ' ') + structdef.axprovider.dbm.gf.pad(FloatToStr(id), structdef.axprovider.dbm.gf.MaxRecid, ' ') + pFrm(structdef.frames[i]).TableName);
    end;
    if RowCount(pFrm(structdef.frames[i]).FrameNo) > 0 then pFrm(structdef.frames[i]).HasDataRows := True;
  end;

  structdef.flds.sort(sortfldsDefault);

  structdef.axprovider.dbm.gf.DoDebug.msg('Loading no-save fields');
  LoadNotSavedFields;
  dqload.close;
  dqloadqualified.close;
  FieldList.Sort(SortFieldListLoad);
  AfterSort;
  FieldOrder := 0;
  LastSavedRecordId := RecId;
  PrimaryTableid := RecId;
  //Is Amendment enabled  | AMENDMENT check  | If not new trans
  //transations can have Amendment and PEG both paralelly
  if  (LastSavedRecordId > 0) and (structdef.IsAmendmentEnabled) then
  begin
    structdef.axprovider.dbm.gf.DoDebug.msg('LoadTrans/ LoadAmendment data starts');
    FetchAmendForLoadData;
    structdef.axprovider.dbm.gf.DoDebug.msg('LoadTrans/ LoadAmendment data ends.');
  end;
  //PEG check
  //Make transaction readonly if its PEG transaction. //axpegreadonlytrans pair will be added with Loaddatajson
  if (structdef.isPegAttached) then
    structdef.axprovider.dbm.gf.bAxPegReadOnlyTrans := IsPegTaskInitiated;
End;


Procedure TStoreData.LoadIntoDataSet(i:integer);
Var
  SelectText, FromText, WhereText, OrderText, fno: String;
  Alias: char;
  p, sfn: integer;
  Asgrid : Boolean;
Begin
  Alias := 'a';
  OrderText := '';
  MasterTableName := PrimaryTableName;
  fno := inttostr(fld.frameno);
  sfn := SubFrames.Indexof(fno);
  If TableName = FirstTableName Then Begin
    Selecttext := 'Select a.' + TableName + 'id, a.SourceId ';
    if IsMapNameDefined then
      SelectText := SelectText + ', a.mapname ';
    if IsCancelDefined then
     SelectText := SelectText + ', a.cancel, a.cancelremarks ';
    If ApprovalDefined Then
      SelectText := SelectText + ', a.Approval, a.ApprovalStatus, a.MaxApproved';
    if IsCreatedOnDefined then
      SelectText := SelectText +', a.CreatedOn, a.CreatedBy ';
    if IsModifiedOnDefined then
      SelectText := SelectText+', a.ModifiedOn ';
    if IsUserNameDefined then
      SelectText := SelectText+', a.UserName ';
    if IsSiteNoDefined then
      SelectText := SelectText+', a.SiteNo ';
  End Else
    Selecttext := 'Select a.' + TableName + 'id';
  If (sfn <> -1) Then Begin
    if ParentRowDefined[sfn+1] = 't' then begin
      SelectText := SelectText + ', a.ParentRow';
      OrderText := ' order by a.ParentRow';
    end else
      SelectText := SelectText +', a.ParentRecordId';
  End;
  If (MasterTableName = '') Or (MasterTableName = FirstTableName) Then Begin
    if connection.dbtype='access' then
       FromText := ' from ' + UpperCase(fCompanyName + '"'+TableName+'"') + ' as ' + Alias
    else
      FromText := ' from ' + UpperCase(fCompanyName + TableName) + ' ' + Alias;
    If (ChildTrans) And (TableName = FirstTableName) Then
      WhereText := ' where a.SourceId = ' + FloatTostr(PrimaryTableid) +
       ' and a.mapname = ' + quotedstr(mapname)
    Else
      WhereText := ' where a.' + FirstTableName + 'id = ' + FloatTostr(Recid);
  End Else Begin
    if connection.dbtype='access' then
       FromText := ' from ' + UpperCase(fCompanyName + '"' + TableName + '"') + ' as ' + Alias + ', '
    else
      FromText := ' from ' + UpperCase(fCompanyName + TableName) + ' ' + Alias + ', ';
    inc(alias);
    FromText := FromText + UpperCase(fCompanyName + MasterTableName) + ' ' + Alias;
    WhereText := ' where b.' + FirstTableName + 'id = ' + FloatTostr(Recid) +
      ' and a.' + MasterTableName + 'id = b.' + MasterTableName + 'id';
  End;
  inc(alias);
  While (i<structdef.flds.count) And (pfld(structdef.flds[i]).tablename = tablename) And (pfld(structdef.flds[i]).DataType <> 'i')  Do Begin
    if (Connection.MsDBverno ='Above 2012') and (pfld(structdef.flds[i]).DataType = 't') then
        SelectText := SelectText + ', cast(a.' + pfld(structdef.flds[i]).fieldname + ' as text) as ' +  pfld(structdef.flds[i]).fieldname
    else SelectText := SelectText + ', a.' + pfld(structdef.flds[i]).fieldname;
    AsGrid := pfld(structdef.flds[i]).AsGrid;
    inc(i);
  End;
  if AsGrid then begin
    p := pos(lowercase(TableName) + 'row', lowercase(SelectText));
    if (p = 0) then begin
      if lowercase(tablename) <> lowercase(primarytablename) then
        SelectText := SelectText + ',a.'+tablename+'row';
    end;
  end;
  p := pos(lowercase(TableName) + 'row', lowercase(SelectText));
  If p > 0 Then Begin
    If ordertext = '' Then
      OrderText := ' Order by ' + lowercase(TableName) + 'row'
    Else
      OrderText := OrderText + ', ' + lowercase(TableName) + 'row';
  end;
  With DQLoad Do Begin
    Close;
    buffered := True;
    cds.CommandText := selecttext + fromtext + wheretext + OrderText;
    Try
      open;
      if Tablename=FirstTableName then begin
        if (Iscanceldefined) and (TableName=FirstTableName) then begin
          Cancelled := cds.Fieldbyname('cancel').asboolean;
          CancelRemarks := cds.Fieldbyname('cancelremarks').asstring;
          CancelledTrans := Cancelled;
        end;
        if IsMapNameDefined then
          MapName := cds.Fieldbyname('MapName').asstring;
        Sourceid :=  cds.Fieldbyname('Sourceid').AsExtended;
        if (IsCreatedOnDefined) then begin
          CreatedOn:= datetimetostr(cds.Fieldbyname('CreatedOn').asdatetime);
          CreatedBy := cds.Fieldbyname('CreatedBy').asstring;
        end;
        if (IsUserNameDefined) then
          SUserName := cds.Fieldbyname('UserName').asstring;
        if (IsSiteNoDefined) then
          SSiteNo   := cds.Fieldbyname('SiteNo').asstring;
        if (IsModifiedOnDefined) then begin
          SModifiedOn:= datetimetostr(cds.Fieldbyname('ModifiedOn').AsDateTime);
        end;
      end;
      if (ParentControl = 0) and (assigned(cds.Fields.FindField('axp_parentcontrol'))) then
        ParentControl := cds.FieldByName('axp_parentcontrol').AsInteger;

    Except on e:Exception do
      begin
        if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\LoadIntoDataSet - '+e.Message);
        Raise EDataBaseError.Create('Unable to load. SQL : ' + SelectText +
        FromText + WhereText + OrderText);
      end;
    End;
  End;
  if (lowercase(TableName) = lowercase(PrimaryTableName)) and (DQLoad.CDS.IsEmpty) and (not childtrans) then
    raise EDataBaseError.Create('Data stored in '+ TableName + ' is improper. Cannot load transaction');
End;

Function TStoreData.GetValueFromTable(RowNo: integer): String;
Var
  SF, ST, EST,TST: String;
  k: integer;
  i,cPos:Integer;
  Fl:TList;
  xdoc : ixmldocument;
Begin
  result := '';
  fl:=FieldList;
  With DQLoadQualified Do Begin
    close;
    buffered := True;
    SF := uppercase(fld.sourcefield);
    ST := uppercase(fld.sourcetable);
    cPos := Pos('.',ST);
    if cPos > 0 then
      TST := Copy(ST,cPos+1,Length(ST))
    else
      TST := ST;

    k := GetFieldIndex(fld.cfield, rowno);
    if k = -1 then
     k := GetFieldIndex(fld.cfield, 1);

    If k = -1 Then
      EST := ST
    Else
      EST := trim(pFieldRec(Fl[k]).value) + '.' + ST;

    if connection.dbtype='access' then
        cds.CommandText := 'Select ' + SF + ' from "' + EST + '" Where ' + TST + 'id = ' +
            DQload.cds.fieldbyname(fld.fieldname).asstring
    else
        cds.CommandText := 'Select ' + SF + ' from ' + EST + ' Where ' + TST + 'id = ' +
            DQload.cds.fieldbyname(fld.fieldname).asstring;
    Try
      xdoc:=structdef.axprovider.GetOneRecord(cds.CommandText, '', '');
      //Open;
    Except on e:Exception do
      begin
        if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\GetValueFromTable - '+e.Message);
        Raise EDataBaseError.Create('Unable to load. SQL : Select ' + SF + ' from '
          + EST + ' Where ' + TST + 'id = ' +
          DQload.CDS.fieldbyname(fld.fieldname).asstring);
      end;
    End;
    {If Not cds.isempty Then
      result := cds.fields[0].asstring;}
    if xdoc.DocumentElement.childnodes.count>0 then
      result:= vartostr(xdoc.DocumentElement.ChildNodes[0].ChildNodes[0].NodeValue);
  End;
End;

Procedure TStoreData.LoadNotSavedFields;
Var
  i, kf, f, pr, x: integer;
  fname, Fieldvalue: String;
Begin
    x:=0;
    While x < structdef.flds.count Do Begin
      If trim(pfld(structdef.flds[x]).tablename) <> '' Then Begin
        inc(x);
        continue;
      End;
      fld := pfld(structdef.flds[x]);
      Fieldorder := fld.orderno;
      For i := 1 To StrToInt(RowCountList[fld.frameno - 1])
        Do Begin
        fname := fld.fieldname;
        FieldValue := '';
        If lowercase(copy(fname, 1, 3)) = 'old' Then Begin
          FieldValue := GetFieldValue(copy(fname, 4, length(fname)), i);
          structdef.axprovider.dbm.gf.DoDebug.msg(fname+ ' row = '+inttostr(i)+' Value = '+FieldValue);
        End;
        SetFieldValue(fname,
          fld.datatype,
          fld.tablename,
          FieldValue,
          FieldValue,
          i,
          0,
          0,
          fld.frameno,
          0,
          fld.sourcekey);

          f := SubFrames.Indexof(inttostr(fld.frameno));
          If (f <> -1) Then begin
            pr := GetPRow(fld.frameno,i);
            SetParentRowNo(fld.fieldname, i, pr);
            structdef.axprovider.dbm.gf.DoDebug.msg('Parent row = '+ inttostr(pr));
          end;
      End;
      inc(x);
    End;
End;

Function TStoreData.GetPRow(FrameNo, RowNo:integer) : integer;
var i:integer;
begin
  for i:=0 to fieldlist.count-1 do begin
    if (pFieldRec(FieldList[i]).FrameNo = FrameNo) and (pFieldRec(FieldList[i]).RowNo = RowNo) and (pFieldRec(FieldList[i]).TableName <> '') then begin
      Result := pFieldRec(FieldList[i]).ParentRowNo;
      exit;
    end;
  end;
end;

Procedure TStoreData.SetTransType(TransType: String);
Begin
  If fTransType = TransType Then exit;
  fTransType := TransType;
  closecursors;
  work:=structdef.axprovider.dbm.GetXDS(work);
  dqload:=structdef.axprovider.dbm.GetXDS(dqload);
  dqloadqualified:=structdef.axprovider.dbm.GetXDS(dqloadqualified);
  dqTrackfields:=structdef.axprovider.dbm.GetXDS(dqTrackfields);
  qseq:=structdef.axprovider.dbm.GetXDS(qseq);
  qlockseq:=structdef.axprovider.dbm.GetXDS(qlockseq);
  qupdseq:=structdef.axprovider.dbm.GetXDS(qupdseq);
  historytable:=structdef.axprovider.dbm.GetXDS(historytable);
  qpkt:=structdef.axprovider.dbm.GetXDS(qpkt);
  modtable:=structdef.axprovider.dbm.GetXDS(modtable);
  LoadFields;
  IsInsertToOutbound := CheckInsertToOutbound(transtype);
//  LoadTrackDetails;
//  SetParentFrames;
End;

Procedure TStoredata.SetParentFrames;
var i:integer;
Begin
  for i:=0 to structdef.frames.Count-1 do begin
    if pfrm(structdef.frames[i]).Popup then begin
      SubFrames.add(inttostr(pfrm(structdef.frames[i]).frameno));
      subframesparent.add(inttostr(pfrm(structdef.frames[i]).popparent));
    end;
  End;
End;

procedure TStoreData.SetPrimaryTableName(ptname:String);
var sxds : TXDS;
begin
  fPrimarytablename := PtName;
  IsCancelDefined := true;
  HasSendToSite := (structdef.GetFieldIndex('sendtosite') > -1);
  if (structdef.axprovider.dbm.gf.MobileWSFlag) or (structdef.quickload) then exit;
  sxds := structdef.axprovider.dbm.GetXDS(nil);
  sxds.buffered := True;
  sxds.cds.CommandText := 'select * from '+companyname+ptname+' where '+ptname+'id=0';
  sxds.open;
  IsCreatedOnDefined := (assigned(sxds.cds.FindField('CreatedOn')));
  IsModifiedOnDefined := (assigned(sxds.cds.FindField('ModifiedOn')));
  IsUserNameDefined := (assigned(sxds.cds.FindField('UserName')));
  IsSiteNoDefined := (assigned(sxds.cds.FindField('SiteNo')));
  IsTransIdDefined := (assigned(sxds.cds.FindField('transid')));
  IsMapNameDefined := (assigned(sxds.cds.FindField('mapname')));
  sxds.close; sxds.Free; sxds := nil;
end;

Procedure TStoreData.LoadFields;
Begin
  //SetAutoGenList;
  NoChange:=structdef.NoChange;
  DeleteControl := structdef.delcontrol;
  tables := ','+lowercase(structdef.tables)+',';
End;

procedure TStoreData.SetSiteNo(sno:integer);
begin
  if fsiteno = sno then exit;
  fsiteno := sno;
  DataClosed := false;
end;

Function SortFieldListLoad(Item1, Item2: Pointer): Integer;
Begin
  result := 0;
  If PFieldRec(Item1).FrameNo < PFieldRec(Item2).FrameNo Then result := -1
  Else If PFieldRec(Item1).FrameNo > PFieldRec(Item2).FrameNo Then result := 1
  Else Begin
    If PFieldRec(Item1).RowNo < PfieldRec(Item2).RowNo Then result := -1
    Else If PFieldRec(Item1).RowNo > PfieldRec(Item2).RowNo Then result := 1
    Else If PFieldRec(Item1).RowNo = PfieldRec(Item2).RowNo Then Begin
      If PFieldRec(Item1).Orders < PfieldRec(Item2).Orders Then result := -1
      Else If PFieldRec(Item1).Orders > PfieldRec(Item2).Orders Then result := 1
      Else result := 0
    End;
  End;
End;

Procedure TStoreData.clearFieldList;
Var
  i: integer;
Begin
  For i := 0 To fieldlist.count - 1 Do begin
    Dispose(pfieldrec(fieldlist[i]));
  end;
  FieldList.Clear;
  Approval := 0;
  ApprovalStatus := '';
  MaxApproved := 0;
  PrimaryTableId := 0;
  LastSavedRecordId := 0;
  RecId := 0;
  ChildDoc := 'F';
  Cancelled := false;
  CancelledTrans := false;
  CancelRemarks := '';
  Deleted := false;
  RecordIdList.Clear;
  ClearDataRows;
End;

Procedure TStoreData.ClearRowList;
Var
  i: integer;
Begin
  For i := 0 To RowList.count - 1 Do
    Dispose(pRowRec(RowList[i]));
  RowList.Clear;
End;

Procedure TStoreData.DeleteRow(FrameNo, Row: Integer);
Var
  i, k, p, parentframeno, subrow: integer;
  delrows,subdc,subdrows : String;
Begin
  if assigned(MDMap) then begin
//    MDMap.CompanyName := CompanyName;
    MDMap.GetFieldData := GetFieldData;
    MDMap.GetRowCount := GetRowCount;
    MDMap.NewTrans := NewTrans;
    if GetRecordId(FrameNo, Row) > 0 then
      MDMap.DeleteRow(ftranstype, frameno, row);
  end;
  FieldList.Sort(SortFieldListLoad);
  AfterSort;
  k := 0;
  subrow := -1;
  delrows := '';
  subdc := '';
  subdrows := '';
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(FieldList[i]).RowNo = Row) And (pFieldRec(FieldList[i]).FrameNo = FrameNo) Then Begin
      pFieldRec(FieldList[i]).OldRow := pFieldRec(FieldList[i]).RowNo;
      pFieldRec(FieldList[i]).RowNo := -1;
      DeletedSubgridRedids(floattostr(pFieldRec(FieldList[i]).recordid), inttostr(pFieldRec(FieldList[i]).frameno));
    End;

    If (pFieldRec(FieldList[i]).RowNo > Row) And (pFieldRec(FieldList[i]).FrameNo = FrameNo) Then
      pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo - 1;

    p := SubFrames.IndexOf(IntToStr(pFieldRec(FieldList[i]).FrameNo));
    If p <> -1 Then ParentFrameNo := StrToInt(SubFramesParent[p]) Else ParentFrameNo := 0;
    If (ParentFrameNo > 0) And (ParentFrameNo = FrameNo) Then Begin
      If (pFieldRec(FieldList[i]).ParentRowNo = Row) Then Begin
        If k = 0 Then
          k := GetSubFormRowCount(pFieldRec(FieldList[i]).FrameNo, pFieldRec(FieldList[i]).ParentRowNo);
        subrow := pFieldRec(FieldList[i]).RowNo;
        if assigned(MDMap) and (pos(inttostr(subrow)+',', delrows) = 0) and (pFieldRec(FieldList[i]).recordid > 0) then begin
          MDMap.DeleteRow(ftranstype, pFieldRec(FieldList[i]).frameno, row);
          delrows := delrows + inttostr(subrow)+',';
          subdrows := subdrows + 'd' + inttostr(subrow) +',';
          subdc := inttostr(pFieldRec(FieldList[i]).frameno);
        end;
        pFieldRec(FieldList[i]).OldRow := pFieldRec(FieldList[i]).RowNo;
        pFieldRec(FieldList[i]).RowNo := -1;
        pFieldRec(FieldList[i]).OldParentRow := pFieldRec(FieldList[i]).ParentRowNo;
        pFieldRec(FieldList[i]).ParentRowNo := -1;
      end else if (pFieldRec(FieldList[i]).ParentRowNo > Row) Then
        pFieldRec(FieldList[i]).ParentRowNo := pFieldRec(FieldList[i]).ParentRowNo - 1;
      If (pFieldRec(FieldList[i]).RowNo > SubRow) and (subrow <> -1) Then
        pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo - k;
    End;
  End;
  if (structdef.axprovider.dbm.gf.isservice) then begin
    if ins_del_rows.Count > 0 then
    begin
      for i := 0 to ins_del_rows.Count - 1 do
      begin
         if ins_del_rows.Names[i] = 'DC'+inttostr(frameno) then
            ins_del_rows.Strings[i] := ins_del_rows.Strings[i] + 'd' + inttostr(row) +','
         else ins_del_rows.Add('DC'+inttostr(frameno)+'=d'+inttostr(row)+',');
         if subdc <> '' then
         begin
  //          delete(subdrows,length(subdrows),1);
            if ins_del_rows.Names[i] = 'DC'+subdc then
              ins_del_rows.Strings[i] := ins_del_rows.Strings[i] + subdrows;
         end;
      end;
    end else begin
      ins_del_rows.Add('DC'+inttostr(frameno)+'=d'+inttostr(row)+',');
      if subdc <> '' then
      begin
        delete(subdrows,length(subdrows),1);
        ins_del_rows.Add('DC'+subdc+'='+subdrows+',');
      end;
    end;
  end;
End;

Procedure TStoreData.DeleteRow(FrameNo, Row: Integer;init : boolean);
Var
  i, k, p, parentframeno, subrow: integer;
  delrows,subdc : String;
Begin
  if assigned(MDMap) then begin
    MDMap.GetFieldData := GetFieldData;
    MDMap.GetRowCount := GetRowCount;
    MDMap.NewTrans := NewTrans;
    if GetRecordId(FrameNo, Row) > 0 then
      MDMap.DeleteRow(ftranstype, frameno, row);
  end;
  FieldList.Sort(SortFieldListLoad);
  AfterSort;
  k := 0;
  subrow := -1;
  delrows := '';
  subdc := '';
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(FieldList[i]).RowNo = Row) And (pFieldRec(FieldList[i]).FrameNo = FrameNo) Then Begin
      pFieldRec(FieldList[i]).OldRow := pFieldRec(FieldList[i]).RowNo;
      pFieldRec(FieldList[i]).RowNo := -1;
      DeletedSubgridRedids(floattostr(pFieldRec(FieldList[i]).recordid), inttostr(pFieldRec(FieldList[i]).frameno));
    End;

    If (pFieldRec(FieldList[i]).RowNo > Row) And (pFieldRec(FieldList[i]).FrameNo = FrameNo) Then
      pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo - 1;

    p := SubFrames.IndexOf(IntToStr(pFieldRec(FieldList[i]).FrameNo));
    If p <> -1 Then ParentFrameNo := StrToInt(SubFramesParent[p]) Else ParentFrameNo := 0;
    If (ParentFrameNo > 0) And (ParentFrameNo = FrameNo) Then Begin
      If (pFieldRec(FieldList[i]).ParentRowNo = Row) Then Begin
        If k = 0 Then
          k := GetSubFormRowCount(pFieldRec(FieldList[i]).FrameNo, pFieldRec(FieldList[i]).ParentRowNo);
        subrow := pFieldRec(FieldList[i]).RowNo;
        if assigned(MDMap) and (pos(inttostr(subrow)+',', delrows) = 0) and (pFieldRec(FieldList[i]).recordid > 0) then begin
          MDMap.DeleteRow(ftranstype, pFieldRec(FieldList[i]).frameno, row);
          delrows := delrows + inttostr(subrow)+',';
          subdc := inttostr(pFieldRec(FieldList[i]).frameno);
        end;
        pFieldRec(FieldList[i]).OldRow := pFieldRec(FieldList[i]).RowNo;
        pFieldRec(FieldList[i]).RowNo := -1;
        pFieldRec(FieldList[i]).OldParentRow := pFieldRec(FieldList[i]).ParentRowNo;
        pFieldRec(FieldList[i]).ParentRowNo := -1;
      end else if (pFieldRec(FieldList[i]).ParentRowNo > Row) Then
        pFieldRec(FieldList[i]).ParentRowNo := pFieldRec(FieldList[i]).ParentRowNo - 1;
      If (pFieldRec(FieldList[i]).RowNo > SubRow) and (subrow <> -1) Then
        pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo - k;
    End;
  End;
  if not init then exit;
  if (structdef.axprovider.dbm.gf.isservice) then begin
    if ins_del_rows.IndexOf('DC'+inttostr(frameno)+'=d*,') < 0  then ins_del_rows.Add('DC'+inttostr(frameno)+'=d*,');
    if subdc <> '' then
       if ins_del_rows.IndexOf('DC'+subdc+'=d*,') < 0  then ins_del_rows.Add('DC'+subdc+'=d*,');
  end;
  {
  if ins_del_rows.Count > 0 then
  begin
    for i := 0 to ins_del_rows.Count - 1 do
    begin
       if ins_del_rows.Names[i] = 'DC'+inttostr(frameno) then
          ins_del_rows.Values[ins_del_rows.Names[i]] := 'd*,';
       if subdc <> '' then
       begin
          if ins_del_rows.Names[i] = 'DC'+subdc then
            ins_del_rows.Values[ins_del_rows.Names[i]] := 'd*,';
       end;
    end;
  end else begin
    ins_del_rows.Add('DC'+inttostr(frameno)+'=d*,');
    if subdc <> '' then ins_del_rows.Add('DC'+subdc+'=d*,');
  end;
  }
End;

Procedure TStoreData.DeleteSubFormRow(FrameNo, ParentRow, Row: Integer);
Var
  i, p : integer;
Begin
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(FieldList[i]).RowNo = Row) And (pFieldRec(FieldList[i]).FrameNo
      = FrameNo) and (pFieldRec(FieldList[i]).ParentRowNo = ParentRow) Then Begin
      pFieldRec(FieldList[i]).OldRow := pFieldRec(FieldList[i]).RowNo;
      pFieldRec(FieldList[i]).RowNo := -1;
    End;

    If ((pFieldRec(FieldList[i]).RowNo > Row)) And (pFieldRec(FieldList[i]).FrameNo
      = FrameNo)  Then
      pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo - 1;
  End;
End;


Function TStoreData.GetFieldIndex(FieldName: String; RowNo: integer): Integer;
Var i: integer;
Begin
  Result := -1;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (lowercase(pFieldRec(FieldList[i]).FieldName) = lowercase(Fieldname)) And
      (pFieldRec(FieldList[i]).RowNo = RowNo) Then Begin
      Result := i;
      break;
    End;
  End;
End;

Function TStoreData.GetFieldFirstIndex(FieldName: String): Integer;
Var
  i: integer;
Begin
  Result := -1;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (lowercase(pFieldRec(FieldList[i]).FieldName) = lowercase(Fieldname))  Then Begin
      Result := i;
      break;
    End;
  End;
End;

Function TStoreData.CanDeleteTrans : String;
var kf:integer;
begin
  Result := '';
  If DeleteControl <> '' Then Begin
    kf := GetFieldIndex(DeleteControl, 1);
    If kf = -1 Then Result := 'Invalid value in delete control field'
    else if lowercase(pFieldRec(FieldList[kf]).Value) <> 't' then
      result:=pFieldRec(FieldList[kf]).Value;
  End;
end;

function TStoreData.IsTransRecord(tname:String; r:Extended):boolean;
var j:integer;
begin
  result := false;
  tname := lowercase(tname);
  for j:=0 to fieldlist.count-1 do begin
    if (pFieldRec(FieldList[j]).RecordId = r) and (lowercase(pFieldRec(FieldList[j]).TableName) = tname) then begin
      result := true;
      break;
    end;
  end;
end;

Procedure TStoreData.DeleteTrans(RecordId: Extended);
Var r : extended;
    kf,j,i : integer;
    deltabs : String;
//    q : txds;
Begin
  newtrans := false;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Deleting transaction '+fTransType + ' Record ' + FloatToStr(PrimaryTableid));
  if DataValidate then begin
    If Approval > ApprovalNo Then
      Raise EDatabaseError.Create('EntryDoc has been approved by higher authority. Cannot delete');
    If DeleteControl <> '' Then Begin
      structdef.axprovider.dbm.gf.DoDebug.msg('Validating Delete Control '+DeleteControl);
      kf := GetFieldIndex(DeleteControl, 1);
      If kf = -1 Then Raise EDatabaseError.Create('Invalid control field');
      If lowercase(pFieldRec(FieldList[kf]).Value) = 'f' Then
        Raise EDatabaseError.Create('Deleting this document is not allowed.')
      else if lowercase(pFieldRec(FieldList[kf]).Value) <> 't' Then
        Raise EDatabaseError.Create(pFieldRec(FieldList[kf]).Value);
    End;

    kf := GetFieldIndex('axp_parentcontrol', 1);
    If kf > -1 Then ParentControl := StrToInt(pFieldRec(FieldList[kf]).Value);
    if (PrimaryTableId > 0) and (ParentControl = 2) and (not childtrans) then begin                                        //and (pos('e', nochange) > 0) and (IsExported) then begin
      Raise EDatabaseError.Create('Transaction has been exported. Cannot Delete/Cancel.');
    end;
  end;

  i:=structdef.flds.count-1;
  tablename := '';
//  deltabs := ','+lowercase(primarytablename)+',';
 deltabs := '';
  while i>=0 do begin
    fld := pfld(structdef.flds[i]);
    if (fld.tablename <> '') and (tablename <> (companyname+fld.tablename)) then begin
      tablename := companyname+fld.tablename;   //by dhurga
//      tablename := fld.tablename;
      if pos(','+lowercase(tablename)+',', deltabs) > 0 then continue;
      work.deleterecord(tablename, primarytablename+'id='+floattostr(primarytableid));
      DelTabs := DelTabs + ',' + lowercase(tablename)+',';
    end;
    dec(i);
  end;
  Deleteimages;
  if structdef.treetables<>'' then updatetreelink('del');
//  savehistory(true); // Commeted 13052009
  if (assigned(MDMap)) and (not cancelled) then begin
//    MDMap.CompanyName := CompanyName;
    MDMap.GetFieldData := GetFieldData;
    MDMap.GetRowCount := GetRowCount;
    MDMap.NewTrans := False;
    MDMap.Submit(TransType, true);
  end;
//  q.free;
  Deleted := True;
  if hassendtosite then sendtosites(DelTran);
  //if IsInsertToOutbound then
  // InsertinOutboundTable(transtype, PrimaryTableid);
End;

Function TStoreData.ISDateEmpty(D: String): Boolean;
Var i: integer;
Begin
  For i := 1 To length(D) Do
    If d[i] = Char(structdef.axprovider.dbm.gf.ShortDateFormat.DateSeparator) Then d[i] := Char(' ');
  Result := (trim(D) = String(''));
End;

Procedure TStoreData.CloseCursors;
Begin
  if assigned(work) then
  begin
    work.close;
    work.destroy;
    work:=nil;
  end;
  if assigned(dqload) then
  begin
    dqload.close;
    dqload.destroy;
    dqload:=nil;
  end;
  if assigned(dqloadqualified) then
  begin
    dqloadqualified.close;
    dqloadqualified.destroy;
    dqloadqualified:=nil;
  end;
  if assigned(dqtrackfields) then
  begin
    dqTrackfields.close;
    dqTrackFields.destroy;
    dqTrackFields:=nil;
  end;
  if assigned(qseq) then
  begin
    qseq.close;
    qseq.destroy;
    qseq:=nil;
  end;
  if assigned(qlockseq) then begin
    qlockseq.close;
    qlockseq.destroy;
    qlockseq:=nil;
  end;
  if assigned(qupdseq) then begin
    qupdseq.close;
    qupdseq.destroy;
    qupdseq:=nil;
  end;
  if assigned(historytable) then begin
    historytable.close;
    historytable.destroy;
    historytable:=nil;
  end;
  if assigned(modtable) then begin
    modtable.close;
    modtable.destroy;
    modtable:=nil;
  end;
  if assigned(xtemp) then begin
    xtemp.close;
    xtemp.destroy;
    xtemp:=nil;
  end;
  if assigned(tlink) then begin
    tlink.close;
    tlink.destroy;
    tlink:=nil;
  end;
  if assigned(tparents) then begin
    tparents.close;
    tparents.destroy;
    tparents:=nil;
  end;
  if assigned(qpkt) then begin
    qpkt.close;
    qpkt.destroy;
    qpkt:=nil;
  end;

End;

Procedure TStoreData.EndSave;
Var i: integer;
Begin
  NoAutoGenStr := '';
  Statusidfieldlist.Clear;
  Statusflagfieldlist.Clear;
  Statusidvaluelist.clear;
  ModifiedOn := '';
  if newtrans then begin
    PrimaryTableId := 0;
    LastSavedRecordId := 0;
    Recid := 0;
  end;
  If FieldList.Count = 0 Then exit;
  i := 0;
  While true Do Begin
    pFieldRec(FieldList[i]).OldValue := pFieldRec(FieldList[i]).Value;
    pFieldRec(FieldList[i]).OldIdValue := pFieldRec(FieldList[i]).IdValue;
    If pFieldRec(FieldList[i]).RowNo = -1 Then Begin
      Dispose(pfieldrec(fieldlist[i]));
      fieldlist.Delete(i);
    End Else Begin
      pFieldRec(FieldList[i]).Recordid := GetParentDocid(pFieldRec(FieldList[i]).FrameNo,
        pFieldRec(FieldList[i]).RowNo);
      inc(i);
    End;
    If i > FieldList.Count - 1 Then break;
  End;
  AfterSort;
End;

procedure TStoreData.UpdateNonGridRecordId ;
  var i : integer;
      fd : pFld;
begin
  If FieldList.Count = 0 Then exit;
  i := 0;
  While true Do Begin
    fd := pFieldRec(FieldList[i]).fld;
    if not fd.AsGrid then
    begin
      if pFieldRec(FieldList[i]).Recordid = 0 then pFieldRec(FieldList[i]).Recordid := GetParentDocid(pFieldRec(FieldList[i]).FrameNo,pFieldRec(FieldList[i]).RowNo);
    end;
    inc(i);
    If i > FieldList.Count - 1 Then exit;
  End;
end;

Procedure TStoreData.CancelTrans(Rem:String);
Var kf,i,k: integer;
    r:Extended;
    deltabs,s : String;
    cxds : txds;
    tfld : txfield;
    emsg : String;
Begin
  (*
  Check for active tasks related to the current transaction.
  - If no PEG-attached transaction is found, then cancel the transaction.
  - If a PEG-attached transaction is found, withdraw it first and then allow cancellation.
  *)
  if (structdef.isPegAttached) and (Not CanCancelTransaction) then
  begin
    structdef.axprovider.dbm.gf.DoDebug.msg('>>This transaction is attached to PEG and has active tasks. To cancel the transaction, the initiator must withdraw the process.');
    Raise EDataBaseError.Create('Cancelling this transaction is not allowed.'+
    'This transaction is attached to PEG and has active tasks. To cancel the transaction, the initiator must withdraw the process.');
  end;

  structdef.axprovider.dbm.gf.DoDebug.msg('>>Writing to database tables '+fTransType + ' record '+FloatToStr(PrimaryTableId));
  NewTrans := false;
  if DataValidate then begin
    If DeleteControl <> '' Then Begin
      kf := GetFieldIndex(DeleteControl, 1);
      If kf = -1 Then Raise EDataBaseError.Create('Invalid control field');
      If lowercase(pFieldRec(FieldList[kf]).Value) <> 't' Then
        Raise EDataBaseError.Create('Cancelling this document is not allowed.');
    End;

    kf := GetFieldIndex('axp_parentcontrol', 1);
    If kf > -1 Then ParentControl := StrToInt(pFieldRec(FieldList[kf]).Value);
    if (PrimaryTableId > 0) and (ParentControl = 2) and (not childtrans) then begin
      Raise EDatabaseError.Create('Transaction has been exported. Cannot Delete/Cancel.');
    end;
  end;

  i := structdef.flds.count-1;
  tablename := '';
  deltabs := '';
  cxds := structdef.axprovider.dbm.GetXDS(nil);
  while i > -1 do begin
    fld := pfld(structdef.flds[i]);
    if (fld.tablename <> '') and (tablename <> fld.tablename) then begin
      tablename := fld.tablename;
      if pos(','+lowercase(tablename)+',', deltabs) > 0 then continue;
      cxds.buffered := True;
      cxds.CDS.CommandText := 'select cancel,cancelremarks,username,modifiedon from '+companyname+tablename+' where '+tablename+'id'+'=0';;
      try
        cxds.open;
        structdef.axprovider.dbm.gf.DoDebug.msg('Cancelling in '+tablename);
        work.edit(companyname+tablename, tablename+'id='+floattostr(primarytableid));
        work.submit('cancel', 'T', 'c');
        work.Submit('cancelremarks',rem,'c');

        k := getfieldindex('UserName', 1);
        if k<>-1 then
          s := pfieldrec(fieldlist[k]).Value
        else
          s := username;
        work.submit('username', s, 'c');
        SUserName := s;

        k := getfieldindex('ModifiedOn', 1);
        if k<>-1 then
          s:=pfieldrec(fieldlist[k]).Value
        else begin
          s:= datetimetostr(structdef.axprovider.dbm.getserverdatetime);
        end;
        if ModifiedOn <> '' then
        begin
          if timezone_diff <> 0 then
             s:=datetimetostr((strtodate(modifiedon)+timezone_diff))
          else s:=modifiedon;
        end;
        work.Submit('modifiedon', s, 'd');
        SModifiedOn := s;

        work.post;
        DelTabs := DelTabs + ',' + lowercase(tablename)+',';
      except
        On E:Exception do begin
          if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\CancelTrans - '+e.Message);
          emsg := E.Message;
        end;
      end;
    end;
    dec(i);
    cxds.close;
  end;
  if TrackChanges then SaveCancelRemarksToHistotyTable(true,Rem);
  cxds.close; cxds.free;
  if DelTabs = '' then
    Raise EDataBaseError.Create('Error in cancellation. '+#13+emsg);
  if assigned(MDMap) then begin
//    MDMap.CompanyName := CompanyName;
    MDMap.GetFieldData := GetFieldData;
    MDMap.GetRowCount := GetRowCount;
    MDMap.NewTrans := false;
    MDMap.Submit(TransType, true);
  end;
  if hassendtosite then sendtosites(CancelTran);
  cancelledTrans := True;
  cancelRemarks := rem;
  //if IsInsertToOutbound then
  // InsertinOutboundTable(transtype, PrimaryTableid);
  //PEG Task Cancel
  //This has been deprecated, instead of the withdraw functionality introduced.
  //CancelPEGActiveTasks(rem,SUserName,SModifiedOn);
End;

Function TStoreData.GetOldValue(FieldName: String; RowNo: Integer): String;
Var k: integer;
Begin
  Result := '';
  k := GetFieldIndex(FieldName, RowNo);
  If k = -1 Then exit;
  Result := pFieldRec(FieldList[k]).OldValue;
End;

Procedure TStoreData.ShowProgress(CStr: String);
Begin
  If assigned(ProgressBar) Then Begin
    ProgressBar.Caption := CStr;
    ProgressBar.Refresh;
  End;
End;

Procedure TStoreData.SetCompanyName(CompanyName: String);
Begin
  If CompanyName <> '' Then fCompanyName := CompanyName + '.'
  Else fCompanyname := Companyname;
End;

Procedure TStoreData.StoreChildTrans(pMapName:String; pSourceId, pSrcPrimaryId: Extended);
Begin
  MapName := pMapName;
  SourceId := pSourceId;
  PublicSourceId := pSourceId;
  SourcePrimaryId := pSrcPrimaryId;
  StoreTrans;
  MapName := '';
  SourceId := 0;
  SourcePrimaryId := 0;
  MapParentRecordId := 0;
  PublicSourceid := 0;
End;

Procedure TStoreData.LoadChildTrans(pMapName:String; pSourceId: Extended);
Begin
  MapName := pMapName;
  SourceId := pSourceId;
  PublicSourceId := SourceId;
  LoadTrans(SourceId);
  MapName := '';
  SourceId := 0;
  MapParentRecordId := 0;
  ChildDoc := 'F';
End;

Function TStoreData.GetParentDocId(FrameNo, RowNo: integer): Extended;
Var i: integer;
Begin
  Result := 0;
  For i := 0 To RecordIdList.Count - 1 Do Begin
    If (StrToInt(trim(Copy(RecordIdList[i], 1, 3))) = FrameNo) And
      (StrToInt(trim(Copy(RecordIdList[i], 4, 5))) = RowNo) Then Begin
      Result := StrToFloat(trim(Copy(RecordIdList[i], 9, structdef.axprovider.dbm.gf.MaxRecid)));
      break;
    End;
  End;
End;

Procedure TStoreData.SetParentDocId(TableName:String; FrameNo:integer);
Var
  i: integer;
  r : extended;
Begin
  For i := 0 To RecordIdList.Count - 1 Do Begin
    If lowercase(trim(Copy(RecordIdList[i], 24, 20))) = lowercase(trim(TableName)) then begin
     r := StrTofloat(trim(Copy(RecordIdList[i], 9, structdef.axprovider.dbm.gf.MaxRecid)));
     RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(FrameNo), 3, ' ') + structdef.axprovider.dbm.gf.Pad(IntToStr(1), 5, ' ') + structdef.axprovider.dbm.gf.pad(FloatToStr(r),structdef.axprovider.dbm.gf.MaxRecid,' ') + TableName);
     break;
    End;
  End;
End;

Function TStoreData.GetParentRowNo(FrameNo:integer; RecordId: Extended): integer;
Var
  i: integer;
Begin
  Result := 0;
  For i := 0 To RecordIdList.Count - 1 Do Begin
    If (StrToInt(trim(Copy(RecordIdList[i], 1, 3))) = FrameNo) And
      (StrTofloat(trim(Copy(RecordIdList[i], 9, structdef.axprovider.dbm.gf.MaxRecid))) = RecordId) Then Begin
      Result := StrToInt(trim(Copy(RecordIdList[i], 4, 5)));
      break;
    End;
  End;
End;

Function TStoreData.GetFrameNo(TableName: String): integer;
Var
  i: integer;
Begin
  Result := 0;
  For i := 0 To fieldlist.count - 1 Do Begin
    If lowercase(pfieldrec(fieldlist[i]).Tablename) = lowercase(tablename) Then Begin
      Result := pfieldrec(fieldlist[i]).frameno;
      break;
    End;
  End;
End;

Function TStoreData.RowCount(FrameNo:Integer):Integer;
var fm:pFrm;
    i,j,k, rcount:integer;
begin
  result:=0;
  fm:=pFrm(structdef.Frames[FrameNo-1]);
  for I := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
    if pFld(StructDef.flds[i]).DataRows.Count > 0 then begin
      rcount:=0;
      for j := 0 to pFld(Structdef.flds[i]).datarows.count-1 do begin
        k:=strtoint(pFld(StructDef.flds[i]).datarows[j]);
        if pFieldRec(fieldlist[k]).RowNo>-1 then
          inc(rcount);
      end;
      if rcount>result then result:=rcount;
    end;
  end;
end;

Function TStoreData.GetRowCount(FrameNo: integer): integer;
Var
  i: integer;
Begin
  Result := 0;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(fieldlist[i]).frameno = frameno) And
      (pFieldRec(fieldlist[i]).RowNo > Result) Then
      Result := pFieldRec(fieldlist[i]).RowNo;
  End;
End;

Procedure TStoreData.StoreParentRecordId(i: integer);
Var k: integer;
    r: extended;
Begin
  k := SubFrames.Indexof(inttostr(pfieldrec(Fieldlist[i]).frameno));
  If k = -1 Then exit;
  k := strtoint(SubFramesParent[k]);
  r := GetParentDocId(k, pfieldrec(Fieldlist[i]).ParentRowNo);
  structdef.axprovider.dbm.gf.DoDebug.msg('Parent RecordId for Frame No '+IntToStr(PFieldRec(fieldlist[i]).Frameno)+', Row '+IntToStr(PFieldRec(fieldlist[i]).Rowno)+' Parent Row '+IntToStr(PFieldRec(fieldlist[i]).ParentRowNo)+' is '+floattostr(r) );
  if r = 0 then
    raise EDataBaseError.Create('ParentRecordId improper');
  modtable.submit('parentrecordid', floattostr(r), 'n');
End;

Procedure TStoreData.SetParentRowNo(FieldName: String; RowNo, ParentRowNo:
  integer);
Var
  k: integer;
Begin
  k := GetFieldIndex(FieldName, RowNo);
  If k = -1 Then exit;
  pFieldRec(fieldlist[k]).ParentRowNo := ParentRowNo;
End;

Procedure TStoreData.InsertRow(FrameNo, RowNo: integer);
  Var k: integer;
  inserted : boolean;
Begin
  inserted := false;
  For k := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(fieldlist[k]).FrameNo = FrameNo) And (pFieldRec(fieldlist[k]).RowNo >= RowNo) Then
    Begin
      pFieldRec(fieldlist[k]).RowNo := pFieldRec(fieldlist[k]).RowNo + 1;
      inserted := true;
    End;
  End;
  if inserted then InsertedRowNoInfo(FrameNo,RowNo);
End;

Procedure TStoreData.InsertedRowNoInfo(frameno,RowNo : Integer) ;
Var ind : integer;
begin
    if (rowno = -1) or (not structdef.axprovider.dbm.gf.isservice) then exit;
    if depCall then exit;
    ind := ins_del_rows.IndexOfName('DC'+IntToStr(frameno));
    if ind >= 0  then
    begin
      if pos(',i' + inttostr(RowNo) +',' ,','+ins_del_rows.ValueFromIndex[ind]) = 0 then
        ins_del_rows.Strings[ind] := ins_del_rows.Strings[ind] + 'i' + inttostr(RowNo) + ',';
    end else
      ins_del_rows.Add('DC'+inttostr(frameno)+'=i'+inttostr(RowNo) +',');
end;

Procedure TStoreData.DeletedSubgridRedids(recid,fno : String) ;
Var ind : integer;
begin
    ind := subgrid_del_recid_list.IndexOfName('DC'+fno);
    if ind >= 0  then
    begin
      if pos(recid ,subgrid_del_recid_list.ValueFromIndex[ind]) = 0 then
        subgrid_del_recid_list.Strings[ind] := subgrid_del_recid_list.Strings[ind] + recid + ',';
    end else
      subgrid_del_recid_list.Add('DC'+fno+'='+recid +',');
end;

Function TStoreData.GetSubFormLastRow(FrameNo, ParentRowNo: integer): integer;
Var
  i: integer;
Begin
  Result := 0;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(fieldlist[i]).frameno = frameno) And
      (pFieldRec(fieldlist[i]).ParentRowNo = ParentRowNo) And
      (pFieldRec(fieldlist[i]).RowNo > Result) Then
      Result := pFieldRec(fieldlist[i]).RowNo;
  End;
End;

Function TStoreData.GetSubFormRowCount(FrameNo, ParentRowNo: integer): integer;
Var
  i, LastRowNo: integer;
Begin
  Result := 0;
  LastRowNo := 0;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(fieldlist[i]).frameno = frameno) And
      (pFieldRec(fieldlist[i]).ParentRowNo = ParentRowNo) and
      (pFieldRec(fieldlist[i]).RowNo > LastRowNo) and
      (pFieldRec(fieldlist[i]).RowNo <> -1) Then begin
       inc(Result);
       LastRowNo := pFieldRec(fieldlist[i]).RowNo;
      end;
  End;
End;

procedure TStoreData.SetChildTrackListToParent(cTrackList : TStringlist);
begin
  tracklist.Free;
  tracklist := cTracklist;
end;

Procedure TStoreData.MakeList(TransDeleted:Boolean);
var  v, ov, fname, s : String;
     modno, i, p ,rowno: integer;
     isFirst, isFound : Boolean;
     tstrlst : TStringlist;
begin
  if (not trackchanges) then exit;
  if NewTrans then begin
    s:= datetimetostr(structdef.axprovider.dbm.getserverdatetime);
    tracklist.Add('<d>');
    tracklist.Add(s+','+username);
    tracklist.Add('<nt>');
    exit;
  end;
  if UndoAmendment then exit;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Saving to history table.');
  p := GetFieldIndex('TransAmended', 1);
  if p <> -1 then begin
    if not ((lowercase(pFieldRec(FieldList[p]).Value) = 't') or (lowercase(pFieldRec(FieldList[p]).Value) = 'yes')) then exit;
  end;
  if not DetailStruct then ModNo := GetNoOfTimesModified(LastSavedRecordId);
  for i:=0 to fieldlist.count-1 do begin
    fname := lowercase(pFieldRec(fieldlist[i]).fieldname);
    rowno := pFieldRec(fieldlist[i]).rowno;
    if ((StructDef.TrackAllFields) or (trackFieldsList.indexof(fname) <> -1)) and  (pFieldRec(fieldlist[i]).tablename <> '') or (detailstruct) then begin
      v := pFieldRec(fieldlist[i]).value;
      if pFieldRec(fieldlist[i]).DataType = 'n' then begin
        if StrToFloat(pFieldRec(fieldlist[i]).value) <> StrToFloat(pFieldRec(fieldlist[i]).OldValue) then   //to handle values like 1000 and 1000.00
          ov := pFieldRec(fieldlist[i]).oldvalue
        else
          ov := pFieldRec(fieldlist[i]).value;
      end else begin
        ov := pFieldRec(fieldlist[i]).oldvalue;
      end;
      if (v = ov) and (rowno <>  -1) then continue;
      if tracklist.Count = 0 then
      begin
        s:= datetimetostr(structdef.axprovider.dbm.getserverdatetime);
        tracklist.Add('<d>');
        tracklist.Add(s+','+username);
      end;
      SaveToHistory(i,ModNo, TransDeleted);
    end;
  end;
end;

procedure TStoreData.SaveToHistory(i,modno:integer; TransDeleted:Boolean);
var fname, oldval, value, tstr, delflag  : String;
    row_no, j : integer;
    tfld : pfld;
    tstrlst : TStringlist;
begin
  fname := pFieldRec(fieldlist[i]).FieldName;
  Tfld := StructDef.GetField(fname);
  if lowercase(fname) = lowercase(pFieldRec(fieldlist[i]).tablename)+'row' then exit;
  row_no := pFieldRec(fieldlist[i]).rowno;
  if (row_no <> -1) and (not tfld.AsGrid) then
    row_no := 0;
  tstr :=  tfld.Caption  +',';
  if row_no = -1 then
  begin
    delflag := 't';
    row_no := pFieldRec(fieldlist[i]).OldRow;
  end
  else
    delflag := 'f';
  tstr := tstr + inttostr(row_no)+',';
  tstr := tstr + delflag;
  if DetailStruct then tstr := tstr + Parent_Row_Field_Caption;
  tracklist.Add('<f>');
  tracklist.Add(tstr);
  oldval := pFieldRec(fieldlist[i]).oldvalue;
  value := pFieldRec(fieldlist[i]).value;
  tracklist.Add('<o>');
  if  tfld.datatype = 't' then
  begin
    tstrlst := TStringlist.Create;
    tstrlst.Text := oldval;
    for j := 0 to tstrlst.Count-1 do
      tracklist.Add(tstrlst[j]);
    tstrlst.Free;
  end else tracklist.Add(oldval);
  tracklist.Add('<n>');
  if  lowercase(pFieldRec(fieldlist[i]).DataType) = 't' then
  begin
    tstrlst := TStringlist.Create;
    tstrlst.Text := value;
    for j := 0 to tstrlst.Count-1 do
      tracklist.Add(tstrlst[j]);
    tstrlst.Free;
  end else tracklist.Add(value);
end;


procedure TStoreData.SaveHistoryToDB(i,modno:integer; TransDeleted:Boolean);
var fname, oldval, value, delflag,s : String;
    rowno, oldrow, fno, prow : integer;
    tid, idv, oidv : extended;
begin
                                                                                            // changed due to view history store on db
  if NewTrans then begin
    historytable.Append(companyname+transtype+'history');
    s := datetimetostr(structdef.axprovider.dbm.getserverdatetime);
    historytable.submit('MODIFIEDDATE',s,'d');
    historytable.submit('recordid',floatTostr(LastSavedRecordId),'n');
    historytable.submit('USERNAME',UserName,'c');
    historytable.submit('tablerecid', floattostr(LastSavedRecordId), 'n');
    historytable.submit('newtrans','t', 'c');
    historytable.submit('canceltrans','f', 'c'); //ch1
    historytable.submit('cancelremarks','', 'c');
  end
  else begin
    fname := pFieldRec(fieldlist[i]).FieldName;
    if lowercase(fname) = lowercase(pFieldRec(fieldlist[i]).tablename)+'row' then exit;
    rowno := pFieldRec(fieldlist[i]).rowno;
    if (rowno <> -1) and (not PFieldRec(FieldList[i]).fld.AsGrid) then            //ch1  from
     rowno := 0;
    if rowno = -1 then
    begin
      delflag := 't';
      rowno := pFieldRec(fieldlist[i]).OldRow;
    end
    else
      delflag := 'f';                                                            //to
    value := pFieldRec(fieldlist[i]).value;
    oldrow := pFieldRec(fieldlist[i]).oldrow;
    oldval := pFieldRec(fieldlist[i]).oldvalue;
    fno := pFieldRec(fieldlist[i]).frameno;
    prow := pFieldRec(fieldlist[i]).ParentRowNo;
    idv := pFieldRec(fieldlist[i]).idvalue;
    oidv := pFieldRec(fieldlist[i]).oldidvalue;
    if prow < 0 then prow := pFieldRec(fieldlist[i]).OldParentRow;
    tid := pFieldRec(fieldlist[i]).recordid;
    historytable.Append(companyname+transtype+'history');
    s := datetimetostr(structdef.axprovider.dbm.getserverdatetime);
    historytable.submit('MODIFIEDDATE',s,'d');
    historytable.submit('recordid',floatTostr(LastSavedRecordId),'n');
    historytable.submit('USERNAME',UserName,'c');
    historytable.submit('fieldname',fname,'c');
    historytable.submit('modno', inttostr(Modno+1), 'c');
    historytable.submit('frameno', inttostr(fno), 'n');
    historytable.submit('parentrow', inttostr(prow), 'n');
    historytable.submit('tablerecid', floattostr(tid), 'n');
    historytable.submit('idvalue', floattostr(idv), 'n');
    historytable.submit('oldidvalue', floattostr(oidv), 'n');
    historytable.submit('newtrans','f', 'c');
    historytable.submit('canceltrans','f', 'c');
    historytable.submit('cancelremarks','', 'c');
    if rowno = -1 then begin
      historytable.submit('rowno', inttostr(oldrow), 'n');
      historytable.submit('newvalue', '', 'c');
      historytable.submit('delflag', 't', 'c');
    end else begin
      historytable.submit('rowno', inttostr(rowno), 'n');
      historytable.submit('newvalue', value, 'c');
      historytable.submit('delflag', delflag, 'c');
    end;
    historytable.submit('oldvalue',oldval, 'c');
    historytable.submit('transdeleted', structdef.axprovider.dbm.gf.bool2str(TransDeleted), 's');
  end;
 historytable.post;
end;

procedure TStoredata.SaveHistoryToTable(TransDeleted : Boolean);
var
  tstrlst : TStringlist;
  isFound : Boolean;
  w,flname,x,w1,p : String;
  j,ModNo : integer;
  stm : TStringStream;
begin
  if  DetailStruct then exit;
  if (not trackchanges) then exit;
  ModNo := GetNoOfTimesModified(LastSavedRecordId);
  w :=  'recordid='+floatTostr(LastSavedRecordId);
  w1 := 'recordid=:recid' ;
  p := floatTostr(LastSavedRecordId);
  isFound := historytable.FindRecord(companyname+transtype+'history',w);
  flname := structdef.axprovider.dbm.gf.startpath + 'tempfile.txt';
  stm := TStringStream.Create('');
  if isFound then begin
    structdef.axprovider.dbm.ReadMemo('ChangedValue',companyname+transtype+'history',w1,p,'n',stm);
    if stm.Size>0 then
    begin
      tstrlst := TStringlist.Create;
      tstrlst.Text := stm.DataString ;
      for j := 0 to tstrlst.Count-1 do
        tracklist.Add(tstrlst[j]);
      tstrlst.Free;
      stm.Free;
      stm := nil;
    end;
    historytable.Edit(companyname+transtype+'history',w);
    historytable.submit('recordid',floatTostr(LastSavedRecordId),'n');
    historytable.submit('modno', inttostr(Modno+1), 'c');
    historytable.submit('transdeleted', structdef.axprovider.dbm.gf.bool2str(TransDeleted), 'c');
    historytable.post;
  end
  else begin
    historytable.Append(companyname+transtype+'history');
    historytable.submit('recordid',floatTostr(LastSavedRecordId),'n');
    historytable.submit('modno', inttostr(Modno+1), 'c');
    historytable.submit('transdeleted', structdef.axprovider.dbm.gf.bool2str(TransDeleted), 'c');
    historytable.post;
  end;
  x := Tracklist.text;
  stm := TStringStream.Create(x);
  if stm.Size > 0 then
  begin
    structdef.axprovider.dbm.WriteMemo('ChangedValue',companyname+transtype+'history',w,stm);
  end;
  stm.Free;stm:=nil;
end;

Procedure  TStoredata.PrepareHistoryDetails(TransDeleted:Boolean);
var
    v, ov, fname : String;
    f, olf : extended;
    modno, i, p : integer;
begin                                                                                                   // changed due to view history store on db
  if (not trackchanges) then exit;
  if NewTrans then begin
    SaveHistoryToDB(i, modno, TransDeleted);
    exit;
  end;
  if UndoAmendment then exit;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Saving to history table.');
  work.buffered := True;
  work.CDS.CommandText := 'select * from '+companyname+transtype+'history where recordid=0';
  work.open;
  newvaluesize := work.CDS.fieldbyname('newvalue').datasize;
  oldvaluesize := work.CDS.fieldbyname('oldvalue').datasize;
  work.close;

  p := GetFieldIndex('TransAmended', 1);
  if p <> -1 then begin
    if not ((lowercase(pFieldRec(FieldList[p]).Value) = 't') or (lowercase(pFieldRec(FieldList[p]).Value) = 'yes')) then exit;
  end;

{  for i:=0 to trackfieldslist.count-1 do begin
    p := autofields.IndexOf(trackfieldslist[i]);
    if p >= 0 then autofields.Delete(p);
  end;}

  ModNo := GetNoOfTimesModified(LastSavedRecordId);
  for i:=0 to fieldlist.count-1 do begin
    fname := lowercase(pFieldRec(fieldlist[i]).fieldname);

//    if (autofields.indexof(fname) = -1) and  (pFieldRec(fieldlist[i]).tablename <> '') then begin
    if ((StructDef.TrackAllFields) or (trackFieldsList.indexof(fname) <> -1)) and  (pFieldRec(fieldlist[i]).tablename <> '') then begin
      v := pFieldRec(fieldlist[i]).value;
      ov := pFieldRec(fieldlist[i]).oldvalue;
      if TransDeleted then SaveHistoryToDB(i, modno, TransDeleted)
      else if (pFieldRec(fieldlist[i]).rowno = -1) and (ov <> '') then begin
        if ((pFieldRec(fieldlist[i]).datatype = 'n') and (strtofloat(ov) <> 0)) or (pFieldRec(fieldlist[i]).datatype <> 'n') then
          SaveHistoryToDB(i, modno, TransDeleted)
      end else begin
        if pFieldRec(fieldlist[i]).datatype = 'n' then begin
          if v <> '' then f := strtofloat(v) else f := 0;
          if ov <> '' then olf := strtofloat(ov) else olf := 0;
          if f <> olf then
            SaveHistoryToDB(i,modno, TransDeleted);
        end else begin
          if v <> ov then SaveHistoryToDB(i, modno, TransDeleted);
        end;
      end;
    end;
  end;
end;

Procedure TstoreData.LoadTrackDetails;
var tablename: String;
begin
  TrackFieldsList:=Tstringlist.create;
  if not (TrackChanges) then exit;
  DQTrackFields.buffered := True;
  DQTrackfields.CDS.CommandText:='Select * from TRACKFIELDS where '+structdef.axprovider.dbm.gf.sqllower+'(transid)=:transid';
//  DQTrackfields.Parambyname('transid').Asstring:=lowercase(ftranstype);
  DQTrackfields.AssignParam(0,lowercase(ftranstype),'c');
  DQTrackfields.Open;
  while not (DQTrackfields.CDS.eof) do begin
    TrackFieldsList.Add(lowercase(DqTrackFields.CDS.fieldbyname('fieldname').AsString));
    DQTrackfields.CDS.Next;
  end;
  DQTrackfields.Close;
end;

Function TStoreData.GetFieldValue(FieldName: String; RowNo: integer): String;
Var i: integer;
Begin
    Result := '';
    For i := 0 To fieldlist.count - 1 Do Begin
        If (lowercase(pFieldRec(FieldList[i]).FieldName) = lowercase(Fieldname)) And
                (pFieldRec(FieldList[i]).RowNo = RowNo) Then Begin
           Result := pFieldRec(FieldList[i]).Value;
           LastIdValue := pFieldRec(FieldList[i]).IdValue;
           break;
        End;
    End;
End;

Function TStoreData.GetFieldRec(FieldName: String; RowNo: integer): Pointer;
Var i: integer;
Begin
    Result := nil;
    For i := 0 To fieldlist.count - 1 Do Begin
        If (lowercase(pFieldRec(FieldList[i]).FieldName) = lowercase(Fieldname)) And
                (pFieldRec(FieldList[i]).RowNo = RowNo) Then Begin
           Result := pFieldRec(FieldList[i]);
           break;
        End;
    End;
End;

Function TStoreData.GetFieldRec(fld:pFld;RowNo:integer):Pointer;
var i,k:integer;
begin
  result:=nil;
  for I := 0 to Fld.DataRows.Count - 1 do begin
    k:=strtoint(fld.DataRows[i]);
    if pFieldRec(FieldList[k]).RowNo=RowNo then begin
      result:=pFieldRec(FieldList[k]);
      break;
    end;
  end;
end;

//gou for subform validation.
Function TStoreData.GetBreakupCumilation( Frameno,ParentRowno :integer;Fieldname : String):Currency;
var
    i : integer;
begin
    Result := 0;
    For i := 0 To fieldlist.count - 1 Do Begin
      If (pFieldRec(FieldList[i]).FrameNo <> Frameno ) or
      (pFieldRec(FieldList[i]).ParentRowno <> ParentRowno)  or
      (pFieldRec(FieldList[i]).Rowno = -1 ) then continue;
      If (lowercase(pFieldRec(FieldList[i]).FieldName) = lowercase(Fieldname)) Then Begin
         if (pFieldRec(FieldList[i]).Value = '')  then pFieldRec(FieldList[i]).Value := '0';
         Try
             Result := Result + strtocurr(pFieldRec(FieldList[i]).Value);
         Except on e:Exception do
          begin
            if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\GetBreakupCumilation - '+e.Message);
          end;
         End;
      End;
    End;
end;

Procedure TStoreData.AddSubFormIdElement(Fieldname,DataType, Value: String;IdValue:extended; FrameNo,Rowno : integer; SourceKey: Boolean);
var
 I , LastRowNo : integer;
begin
    LastRowNo := 0;
    For i := 0 To fieldlist.count - 1 Do Begin
      if (pFieldRec(FieldList[i]).Rowno = -1 ) or
      (pFieldRec(FieldList[i]).FrameNo <> FrameNo) or
      (pFieldRec(FieldList[i]).ParentRowno <> Rowno ) then Continue;

      If (pFieldRec(FieldList[i]).Rowno > LastRowNo ) then begin
       LastRowNo := pFieldRec(FieldList[i]).Rowno;
       SetFieldvalue(FieldName, DataType, '', Value, '', LastRowno, idvalue, 0, frameno, 0, Sourcekey);
       SetParentRowNo(FieldName, LastRowno,pFieldRec(FieldList[i]).ParentRowno );
      end;
    end;
end;

Function TStoreData.CheckIdFieldChanged(idField,value : String;FrameNo,Rowno: integer; idvalue : extended; Sourcekey : Boolean):Boolean;
var
 cnt :integer;
begin
 Result := False;
 for cnt := 0 to FieldList.Count -1 do begin
  IF (PFieldRec(FieldList[cnt]).RowNo = -1) or
     (PFieldRec(FieldList[cnt]).FrameNo <> FrameNo) or
     (PFieldRec(FieldList[cnt]).parentRowNo <> RowNo) or
     (Lowercase(PFieldRec(FieldList[cnt]).fieldname) <> IdField )then continue;
  if Sourcekey then begin
   if (PFieldRec(FieldList[cnt]).idvalue <> Idvalue) then begin
    Result := True;
    Break;
   end;
  end else begin
   if Trim(Lowercase(PFieldRec(FieldList[cnt]).value)) <> Trim(Lowercase(value)) then begin
    Result := True;
    Break;
   end;
  end;
 end;
end;

Procedure TStoreData.DeleteSubFormBreakup(FrameNo,ParentRowNo : integer);
var
 i :integer;
begin
    For i := 0 To fieldlist.count - 1 Do Begin
      if (pFieldRec(FieldList[i]).Rowno = -1 ) or
      (pFieldRec(FieldList[i]).FrameNo <> FrameNo) or
      (pFieldRec(FieldList[i]).ParentRowno <> ParentRowno ) then Continue;
      pFieldRec(FieldList[i]).Rowno := -1 ;
   end;
end;

procedure TStoreData.AddGridRow(FrameNo:Integer);
var i, rcount, k, j:integer;
    skey : boolean;
    fname, dtype, tabname : String;
begin
 rcount := 0;
 for i:=0 to fieldlist.count-1 do begin
  if (pFieldRec(fieldlist[i]).frameno = frameno) and (rcount < pFieldRec(fieldlist[i]).rowno) then
   rcount := pFieldRec(fieldlist[i]).rowno;
 end;
 inc(rcount);
 for k:=0 to structdef.flds.count-1 do begin
   if pfld(structdef.flds[k]).frameno=frameno then begin
   j:=k;
    while (j<structdef.flds.count) and (pfld(structdef.flds[k]).frameno = frameno) do begin
      fname := pfld(structdef.flds[k]).fieldname;
      dtype := pfld(structdef.flds[k]).datatype;
      tabname := pfld(structdef.flds[k]).tablename;
      skey := pfld(structdef.flds[k]).sourcekey;
      SetFieldValue(FName, DType, TabName, '', '', rcount, 0, 0, frameno, 0, skey);
      inc(j);
    end;
    break;
   end;
 end;
end;

procedure TStoreData.InitRecordIds;
var
   i: integer;
begin
   for i:=0 to fieldlist.Count-1 do pFieldRec(FieldList[i]).RecordId:=0;
   LastSavedRecordId:=0;
   PrimaryTableId:=0;
   recid:=0;
end;

function TStoreData.GetNoofTimesModified(Primarytableid: Extended): Integer;
begin
  result:=0;
  with DQTrackfields do begin
    buffered := True;
    cds.CommandText:='select max(modno) as cnt from '+companyname+fTransType+'history where recordid='+floatTostr(primarytableid)+'';
    open;
    result:=cds.fieldbyname('cnt').AsInteger;
    close;
  end;
end;

Procedure TStoreData.SubmitValue(FieldName:String; RowNo:integer;  Value, OldValue: String; IdValue, OldIdValue, Recordid :extended);
var f:String;
    fp : pFld;
Begin
  fp:=structdef.GetField(fieldname);
  if not assigned(fp) then begin
    f := ','+lowercase(CompanyName+copy(fieldname,1,length(fieldname)-2))+',';
    if pos(f, ','+lowercase(tables)+',') = 0 then exit
    else begin
      setFieldValue(fieldname, 'n', '', value, '', rowno,0, 0, 0, 0, false);
      exit;
    end;
  end;
  if not (fp.AsGrid) then RowNo := 1;
  SetFieldValue(FieldName,
                fp.DataType,
                fp.Tablename,
                Value, OldValue, RowNo, IdValue, OldIdValue,
                fp.FrameNo,
                RecordId, fp.SourceKey);
End;

Procedure TStoreData.SubmitValue(fp : pFld; FieldName:String; RowNo:integer;  Value, OldValue: String; IdValue, OldIdValue, Recordid :extended);
var f:String;
Begin
  if not assigned(fp) then begin
    f := ','+lowercase(CompanyName+copy(fieldname,1,length(fieldname)-2))+',';
    if pos(f, ','+lowercase(tables)+',') = 0 then exit
    else begin
      setFieldValue(fieldname, 'n', '', value, '', rowno,0, 0, 0, 0, false);
      exit;
    end;
  end;
  if not (fp.AsGrid) then RowNo := 1;
  SetFieldValue(FieldName,
                fp.DataType,
                fp.Tablename,
                Value, OldValue, RowNo, IdValue, OldIdValue,
                fp.FrameNo,
                RecordId, fp.SourceKey);
End;

procedure TStoreData.SetAutoGenList;
var i:integer;
    pxml : IXMLDocument;
    n:ixmlnode;
    s, seqtbl:string;
begin
  if autogenfields.count>0 then exit;
  if not structdef.HasAutoGenFields then exit;
  if (fileexists(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pfx')) and (not structdef.axprovider.dbm.gf.isservice) then begin
    prefixes.LoadFromFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pfx');
    Autogenfields.LoadFromFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.agf');
    if (fileexists(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pff')) then
      prefixFields.LoadFromFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pff');
    for i:=0 to prefixes.count-1 do begin
      autogentransid.add(ftranstype);
      autogenvals.Add('');
    end;
  end else begin
    seqtbl := Trim(GetFieldValue('Axp_SeqTable',1));
    if seqtbl = '' then
      seqtbl := 'Sequence';
    pxml:=structdef.axprovider.ExecSQL('Select * FROM '+UPPERCASE(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+quotedstr(lowercase(fTranstype))+' order by activesequence desc ', '', '', true);
    n:=pxml.DocumentElement.ChildNodes[1];
    for i:=0 to n.ChildNodes.Count-1 do begin
      Prefixes.add(lowercase(vartostr(structdef.axprovider.dbm.gf.FindNode(n.ChildNodes[i],'prefix').NodeValue)));
      PrefixFields.add(lowercase(vartostr(structdef.axprovider.dbm.gf.FindNode(n.ChildNodes[i],'prefixfield').NodeValue)));
      s:=lowercase(vartostr(structdef.axprovider.dbm.gf.FindNode(n.ChildNodes[i],'fieldname').NodeValue));
      AutoGenFields.add(s);
      AutogenTransid.add(lowercase(fTransType));
      AutoGenVals.Add('');
    end;
    if not structdef.axprovider.dbm.gf.isservice then begin
      if DirectoryExists(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName) then
      begin
        prefixes.SaveToFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pfx');
        prefixFields.SaveToFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.pff');
        Autogenfields.SaveToFile(structdef.axprovider.dbm.gf.startpath+'Structures\'+structdef.axprovider.dbm.gf.AppName+'\'+transtype+'.agf');
      end else begin
        prefixes.SaveToFile(GetCurrentDir{AppDir}+'\'+transtype+'.pfx');
        prefixfields.SaveToFile(GetCurrentDir{AppDir}+'\'+transtype+'.pff');
        Autogenfields.SaveToFile(GetCurrentDir{AppDir}+'\'+transtype+'.agf');
      end;
    end;
  end;
end;

function TStoreData.GetLastNo(FieldName : String; OnlyGet:Boolean):String;
var i,digits,j,done:integer;
    CompName,lastno, Transid, wstr, sql,dstr,sval,prefix,prefixfield,s,sPrefix ,seqtbl, tmpupdstr, sqlWoUpd: String;
    arec : pAutoGenRec;
    bActive : Boolean;
begin
  result := '';
  sqlWoUpd := '';
  SetAutoGenList;
  if fCompanyName <> '' then CompName := copy(fCompanyName, 1, length(fCompanyName)-1) else CompName := '';
  fieldname := lowercase(fieldname);
  i := AutoGenFields.Indexof(fieldname);
  if (i = -1)  then exit;
  Transid := Autogentransid[i];
  seqtbl := Trim(GetFieldValue('Axp_SeqTable',1));
  if seqtbl = '' then
    seqtbl := 'Sequence';
  if prefixfields[i]<>'' then begin
    SQL:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(Transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname))+
         'and '+structdef.axprovider.dbm.gf.sqllower+'(prefixfield)='+lowercase(quotedstr(prefixfields[i]));
    wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(Transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname))+
         'and '+structdef.axprovider.dbm.gf.sqllower+'(prefixfield)='+ lowercase(quotedstr(prefixfields[i]));
  end else begin
    prefix := GetUserActivePrefix(transid,fieldname);
    if (not OnlyGet) and (structdef.axprovider.dbm.Connection.DbType = 'ms sql') then begin
      tmpupdstr := ' ';
      if (not structdef.axprovider.dbm.gf.PostAutoGen) then
        tmpupdstr := tmpupdstr+structdef.axprovider.dbm.gf.forupdate;
      sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+ tmpupdstr + ' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(Transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname))
    end
    else
       sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(Transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname));
    wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(fieldname))+ ' ';
    if prefix = '' then begin
      SQl := sql + ' and ACTIVESEQUENCE = ''T''';
      wstr := wstr + ' and ACTIVESEQUENCE = ''T''';
      bActive := True;
    end else begin
      SQl := sql + ' and '+ structdef.axprovider.dbm.gf.sqllower+'(prefix) ='+lowercase(quotedstr(prefix));
      wstr := wstr + ' and '+ structdef.axprovider.dbm.gf.sqllower+'(prefix) ='+lowercase(quotedstr(prefix));
      bActive := False;
    end;
    if (not OnlyGet) and (structdef.axprovider.dbm.Connection.DbType <> 'ms sql') and (not structdef.axprovider.dbm.gf.PostAutoGen) then
    begin
      sqlWoUpd := sql;
      sql := sql+structdef.axprovider.dbm.gf.forupdate;   // todo - where forupdate to be added for mysql to be checked and code needs to be changed.
    end;
  end;

  if structdef.axprovider.dbm.Connection.DbType = 'mysql' then
  begin
    done := 0;
    while (done < 100) do begin
      try
        QSeq.close;
        Qseq.buffered := True;
        Qseq.CDS.CommandText := sql;
        Qseq.open;
        break;
      except on e:Exception do
        begin
          inc(done);
          if done = 99 then
          begin
             raise Exception.Create(e.Message);
          end;
        end;
      end;
    end;
  end else
  begin
    QSeq.close;
    Qseq.buffered := True;
    Qseq.CDS.CommandText := sql;
    Qseq.open;
  end;

  if QSeq.CDS.RecordCount > 0 then begin
    lastno := QSeq.CDS.FieldByName('lastno').AsString;
    prefixfield := Trim(QSeq.CDS.FieldByName('prefixfield').AsString);
    prefix := Trim(QSeq.CDS.FieldByName('prefix').AsString);
    digits := QSeq.CDS.FieldByName('noofdigits').AsInteger;
    dstr := '';
    for j := 0 to digits-1 do
      dstr := dstr+'0';
    if prefixfield <> '' then begin
      sval := getfieldvalue(prefixfield, 1);
      if copy(sval,1,1) = ':' then begin
        if structdef.axprovider.dbm.Connection.DbType = 'mysql' then
        begin
          if ((not OnlyGet)) and (sqlWoUpd <> '') then
          begin
            Qseq.Close;
            Qseq.buffered := True;
            Qseq.CDS.CommandText := sqlWoUpd;
            Qseq.open;
          end;
        end;
        result := GetPrefixFieldValue(FieldName,sval,transid,OnlyGet,digits);
        Qseq.Close;
        exit;
      end else
        sPrefix :=sval;
    end else
      sPrefix := prefix;
    if not OnlyGet then begin
      if not structdef.axprovider.dbm.gf.PostAutoGen then begin
        result := sPrefix + copy(dstr, 1, (digits - length(lastno))) + lastno;
        structdef.axprovider.ExecSQL('update '+companyname+seqtbl+' set lastno = '+inttostr(strtoint(lastno) + 1)+' where '+wstr,'','',false);
        s := RefreshAutoGen(ModTable,Fieldname, result);
        if s<>'' then begin
          Raise EDataBaseError.Create(s);
        end;
        if (connection.dbtype<>'access') then QLockSeq.Close;
      end else begin
        result := structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.Connect.Connection.ConnectNo),4,'0')+structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.gf.AutoMemNo),3,'0');
        New(aRec);
        aRec.Transid := Transtype;
        aRec.FieldName := FieldName;
        aRec.Prefix := sPrefix;
        aRec.PrefixField := '';
        aRec.Schema := CompanyName;
        aRec.TableName := Tablename;
        aRec.RType := 'auto';
        aRec.MemNo := result;
        aRec.RecordId := NewRecid;
        aRec.RecordidUpdated := True;
        aRec.Rowno := 1;
        aRec.ParentList := nil;
        aRec.Active := bActive;
        structdef.axprovider.dbm.gf.AutoGenData.Add(aRec);
        Inc(structdef.axprovider.dbm.gf.AutoMemNo);
        s := RefreshAutoGen(ModTable,Fieldname, result);
        if s<>'' then begin
          Raise EDataBaseError.Create(s);
        end;
      end;
    end else
      result := sPrefix + copy(dstr, 1, (digits - length(lastno))) + lastno;
  end;
  Qseq.close;
end;

procedure TStoreData.SetPrefix(Transid, FieldName, Prefix:String);
var i: integer;
    wstr,wstr1, seqtbl : String;
    flag:boolean;
begin
  if fieldname = '' then exit;
  SetAutoGenList;
  fieldname := lowercase(fieldname);
  i := AutoGenFields.IndexOf(FieldName);
  if i=-1 then exit;
  if transid <> '' then
    AutoGenTransid[i] := lowercase(Transid);
  Transid := lowercase(Transid);
  if (transid = '') then transid := lowercase(transtype);
  if structdef.axprovider.dbm.gf.remotelogin then begin
    structdef.axprovider.RemoteSetPrefix(transid,fieldname,prefix);
    exit;
  end;
  seqtbl := Trim(GetFieldValue('Axp_SeqTable',1));
  if seqtbl = '' then
    seqtbl := 'Sequence';
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+quotedstr(transid)+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+quotedstr(fieldname)+' and ACTIVESEQUENCE = ''T''';
  QUpdSeq.edit(uppercase(fCompanyName)+seqtbl, wstr);
  if connection.dbtype<>'access' then begin
    QLockSeq.buffered := True;
    if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
       QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+seqtbl+' '+ structdef.axprovider.dbm.gf.forupdate + 'WHERE '+wstr
    else QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+wstr+ structdef.axprovider.dbm.gf.forupdate;
    flag:=structdef.axprovider.dbm.InTransaction;
    if not flag then structdef.axprovider.dbm.StartTransaction(structdef.axprovider.dbm.connection.ConnectionName);
    QLockSeq.open;
  end;
  qupdseq.submit('activesequence', 'F', 'c');
  qupdseq.post;
  qupdseq.close;
  if connection.dbtype<>'access' then begin
    QLockSeq.Close;
    if not flag then structdef.axprovider.dbm.Commit(structdef.axprovider.dbm.connection.ConnectionName);
  end;
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+quotedstr(transid)+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+quotedstr(fieldname)+' and PREFIX = '+quotedstr(prefix);
  QUpdSeq.edit(uppercase(fCompanyName)+seqtbl, wstr);
  if connection.dbtype<>'access' then begin
    QLockSeq.buffered := True;
    if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
       QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+seqtbl+' ' + structdef.axprovider.dbm.gf.forupdate + ' WHERE '+wstr
    else QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+wstr+structdef.axprovider.dbm.gf.forupdate ;
    flag:=structdef.axprovider.dbm.InTransaction;
    if not flag then structdef.axprovider.dbm.StartTransaction(structdef.axprovider.dbm.connection.ConnectionName);
    QLockSeq.open;
  end;
  qupdseq.submit('activesequence', 'T', 'c');
  qupdseq.post;
  qupdseq.close;
  if connection.dbtype<>'access' then begin
    QLockSeq.Close;
    if not flag then structdef.axprovider.dbm.Commit(structdef.axprovider.dbm.connection.ConnectionName);
  end;
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+quotedstr(transid)+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+quotedstr(fieldname)+
        ' and '+structdef.axprovider.dbm.gf.sqllower+'(uname) = '+quotedstr(lowercase(username));

  if connection.dbtype<>'access' then begin
    QLockSeq.buffered := True;
    if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
    QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+'USERSEQUENCE ' + structdef.axprovider.dbm.gf.forupdate + ' WHERE '+wstr
    else QLockSeq.CDS.CommandText := 'Select * FROM '+uppercase(fCompanyName)+'USERSEQUENCE WHERE '+wstr+structdef.axprovider.dbm.gf.forupdate;
    flag:=structdef.axprovider.dbm.InTransaction;
    if not flag then structdef.axprovider.dbm.StartTransaction(structdef.axprovider.dbm.connection.ConnectionName);
    QLockSeq.open;
  end;

  qupdseq.Submit('transtype',transid,'c');
  qupdseq.Submit('fieldname',fieldname,'c');
  qupdseq.Submit('uname',username,'c');
  qupdseq.Submit('prefix',prefix,'c');
  qupdseq.AddOrEdit(uppercase(fcompanyname)+'USERSEQUENCE',wstr);
  if connection.dbtype<>'access' then begin
    QLockSeq.Close;
    if not flag then structdef.axprovider.dbm.Commit(structdef.axprovider.dbm.connection.ConnectionName);
  end;
end;

function TStoreData.GetPrefixFieldValue(fieldname,sval,transid:String;OnlyGet:Boolean;digits:integer):String;
var j,done :Integer;
    pval,sql,wstr,dstr,s,lastno,fval, seqtbl : String;
    id : Extended;
    GetVal : Boolean;
    xdoc : ixmldocument;
    n,pnode,dnode : ixmlnode;
    fd : pfld;
    arec : pAutoGenRec;
    aTransid, aFName : String;
    openforupdate : boolean;
begin
  result := '';
  s := structdef.axprovider.dbm.gf.getnthstring(sval,1);
  fval := copy(s,2,length(s));
  fd := structdef.GetField(fval);
  if fd <> nil then
    pval := getfieldvalue(fval, 1)
  else
    pval := fval;
  s := structdef.axprovider.dbm.gf.getnthstring(sval,4);
  if s<> '' then
    aTransid := s
  else
    aTransid := Transid;

  s := structdef.axprovider.dbm.gf.getnthstring(sval,5);
  if s<> '' then
    aFName := s
  else
    aFName := fieldname;

  seqtbl := Trim(GetFieldValue('Axp_SeqTable',1));
  if seqtbl = '' then
    seqtbl := 'Sequence';
  sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(aTransid))+
       ' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(aFName))+
       ' and '+structdef.axprovider.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval));
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(aTransid))+' and '+
          structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(aFName))+
         ' and '+structdef.axprovider.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval));

  qseq.close;
  qseq.buffered := True;
  qseq.CDS.CommandText := sql;
  qseq.open;
  if qseq.CDS.RecordCount = 0 then begin
    s := structdef.axprovider.dbm.gf.getnthstring(sval,2);
    if s <> '' then
      lastno := s
    else
      lastno := '1';
    s := structdef.axprovider.dbm.gf.getnthstring(sval,3);
    if s <> '' then
      digits := StrToInt(s);
    if OnlyGet then
      GetVal := False
    else begin
      qseq.close;
      id := structdef.axprovider.dbm.Gen_id(structdef.axprovider.dbm.Connect.Connection);
      s := 'insert into '+uppercase(fcompanyname)+seqtbl+'(sequenceid, prefix,transtype,fieldname,activesequence,'+
       'description,prefixfield,lastno,noofdigits) values(';
      s := s+FloatToStr(id)+',';
      s := s+Quotedstr(pval)+',';
      s := s+Quotedstr(aTransid)+',';
      s := s+QuotedStr(aFName)+',';
      s := s+QuotedStr('F')+',';
      s := s+QuotedStr('~dynamic prefix')+',';
      s := s+quotedstr('')+',';
      s := s+inttostr(Strtoint(LastNo)+1)+',';
      s := s+IntToStr(digits)+')';
      qseq.close;
      qseq.cds.CommandText := s;
      try
        if structdef.axprovider.dbm.gf.remotelogin then
          qseq.open
        else
          qseq.CDS.Execute;
        if structdef.axprovider.dbm.gf.PostAutoGen then begin
          result := structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.Connect.Connection.ConnectNo),4,'0')+structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.gf.AutoMemNo),3,'0');
          New(aRec);
          aRec.Transid := Transtype;
          aRec.FieldName := FieldName;
          aRec.Prefix := pval;
          aRec.Schema := CompanyName;
          aRec.TableName := Tablename;
          aRec.RType := 'auto';
          aRec.MemNo := result;
          aRec.RecordId := NewRecid;
          aRec.RecordidUpdated := True;
          aRec.Rowno := 1;
          aRec.ParentList := nil;
          aRec.PrefixField := Copy(sval,2,length(sval));
          structdef.axprovider.dbm.gf.AutoGenData.Add(aRec);
          Inc(structdef.axprovider.dbm.gf.AutoMemNo);
        end;
        GetVal := False;
      except
        On E:Exception do begin
          if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\GetPrefixFieldValue - '+e.Message);
          if pos('unique',lowercase(e.Message))>0 then
            GetVal := True
          else
            Raise Exception.Create(E.Message);
        end;
      end;
    end;
  end else
    GetVal := True;

  try
    if GetVal then begin
      if not onlyget then begin
        if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
          sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' ' + structdef.axprovider.dbm.gf.forupdate + ' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(aTransid))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(aFName))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval))
        else
          sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(aTransid))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(aFName))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval));//+structdef.axprovider.dbm.gf.forupdate; ;
      end else begin
          sql:='Select * FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(aTransid))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(aFName))+
            ' and '+structdef.axprovider.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval))
      end;
      xdoc:=structdef.axprovider.GetOneRecord(sql,'','');
      n:=xdoc.DocumentElement;
      openforupdate := false;
      if not structdef.axprovider.dbm.gf.PostAutoGen then begin
        if (not OnlyGet) and (connection.dbtype<>'access') then begin
          if structdef.axprovider.dbm.Connection.DbType = 'mysql' then
          begin
            done := 0;
            while (done < 100) do begin
              try
                QLockSeq.close;
                QLockSeq.buffered := True;
                QLockSeq.CDS.CommandText := sql+ structdef.axprovider.dbm.gf.forupdate;
                QLockSeq.open;
                openforupdate := true;
                break;
              except on e:Exception do
                begin
                  inc(done);
                  if done = 99 then
                  begin
                    raise Exception.Create(e.Message);
                  end;
                end;
              end;
            end;
          end else
          begin
            QLockSeq.close;
            QLockSeq.buffered := True;
            if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
              QLockSeq.CDS.CommandText := sql
            else QLockSeq.CDS.CommandText := sql+ structdef.axprovider.dbm.gf.forupdate;
              QLockSeq.open;
            if structdef.axprovider.dbm.Connection.DbType = 'ms sql' then
              structdef.axprovider.ExecSQL(sql, '', '', false)
            else structdef.axprovider.ExecSQL(sql+structdef.axprovider.dbm.gf.forupdate, '', '', false);
          end;
        end;
      end;
      if n.ChildNodes.count > 0 then begin
        n:=n.childnodes[0];
        lastno := vartostr(structdef.axprovider.dbm.gf.FindNode(n,'LASTNO').NodeValue);
        pnode := structdef.axprovider.dbm.gf.FindNode(n,'PREFIXFIELD');
        dnode := structdef.axprovider.dbm.gf.FindNode(n,'NOOFDIGITS');
        if (assigned(dnode)) and (vartostr(dnode.NodeValue) <> '') then
          digits := StrToInt(vartostr(dnode.NodeValue));
        pval := Trim(vartostr(structdef.axprovider.dbm.gf.FindNode(n,'PREFIX').NodeValue));
      end else
        pval := '';
    end;
    if pval <> '' then begin
      dstr := '';
      for j := 0 to digits-1 do
        dstr := dstr+'0';
      result := pval + copy(dstr, 1, (digits - length(lastno))) + lastno;
      if (not OnlyGet) then begin
        if not structdef.axprovider.dbm.gf.PostAutoGen then begin
            s := RefreshAutoGen(ModTable,Fieldname, result);
            if s<>'' then begin
              Raise EDataBaseError.Create(s);
            end;
        end;
        if (GetVal) then begin
          if not structdef.axprovider.dbm.gf.PostAutoGen then begin
            structdef.axprovider.ExecSQL('update '+companyname+seqtbl+' set lastno = '+inttostr(strtoint(lastno) + 1)+' where '+wstr,'','',false);
            if (connection.dbtype<>'access') then QLockSeq.Close;
          end else begin
            result := structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.Connect.Connection.ConnectNo),4,'0')+structdef.axprovider.dbm.gf.LeftPad(IntToStr(structdef.axprovider.dbm.gf.AutoMemNo),3,'0');
            New(aRec);
            aRec.Transid := Transtype;
            aRec.FieldName := FieldName;
            aRec.Prefix := pval;
            aRec.Schema := CompanyName;
            aRec.TableName := Tablename;
            aRec.RType := 'auto';
            aRec.MemNo := result;
            aRec.RecordId := NewRecid;
            aRec.RecordidUpdated := True;
            aRec.Rowno := 1;
            aRec.ParentList := nil;
            aRec.PrefixField := Copy(sval,2,length(sval));
            structdef.axprovider.dbm.gf.AutoGenData.Add(aRec);
            Inc(structdef.axprovider.dbm.gf.AutoMemNo);
          end;
        end;
      end;
    end;
  except
    On E:Exception do begin
      if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\GetPrefixFieldValue - '+e.Message);
      if openforupdate then
      begin
        QLockSeq.close;
        QLockSeq.CDS.CommandText := sql;
        QLockSeq.open;
      end;
      Raise Exception.Create(E.Message);
    end;
  end;
end;

Procedure TStoreData.NoAutoGen(FieldName:String);
var i:integer;
begin
  if fieldname = '' then exit;
  SetAutoGenList;
  i := AutoGenFields.IndexOf(FieldName);
  if i=-1 then exit;
  if pos(';'+FieldName+';', NoAutoGenStr) > 0 then exit;
  NoAutoGenStr := NoAutoGenStr + ';'+FieldName+';';
end;

function TStoreData.IsExported : boolean;
begin
  result := false;
end;

procedure TStoreData.CheckAutoGen(sender:tobject);
var flag : boolean;
    fname, value, tname, agenstr : string;
    i, k, x : integer;
begin
  if (not newtrans) then exit;
  flag := true;
  x := 10;
  while (flag) do begin
    flag := false;
    agenstr := ',';
    for i:=0 to AutoGenFields.count-1 do begin
      fname := AutoGenFields[i];
      k := getfieldindex(fname, 1);
      if k = -1 then continue;
      tname := pFieldRec(FieldList[k]).TableName;
      if lowercase(tname) <> lowercase(tablename) then continue;
      if pos(','+fname+',',agenstr) > 0 then continue;
      agenstr := agenstr+fname+',';
      value := pFieldRec(FieldList[k]).value;
      work.buffered := True;
      work.CDS.CommandText := 'select '+fname+' from '+tname+ ' where '+fname+ ' = '+quotedstr(value) + ' and '+tname+'id <> :t';
      work.AssignParam(0,floattostr(Newrecid),'n');
      //work.parambyname('t').asfloat := Newrecid;
      work.open;
      if not work.CDS.isempty then begin
        structdef.axprovider.dbm.gf.DoDebug.msg('Changed value of '+fname);
        pFieldRec(FieldList[k]).Value := GetLastNo(fname, false);
        ModTable.Submit(fname, pFieldRec(FieldList[k]).Value, 'c');
        structdef.axprovider.dbm.gf.DoDebug.msg('to '+pFieldRec(FieldList[k]).Value);
        flag := true;
      end;
      work.close;
    end;
    if x = 1 then begin
      Raise EDataBaseError.Create('Unable to get unique number. Please Save again');
    end;
    dec(x);
  end;
end;

Procedure TStoreData.InsertFrameRow(FrameNo, Row: Integer);
Var
  i, k, p, parentframeno: integer;
Begin
  k := 0;
  FieldList.Sort(SortFieldListLoad);
  AfterSort;
  For i := 0 To fieldlist.count - 1 Do Begin
    If (pFieldRec(FieldList[i]).RowNo >= Row) And (pFieldRec(FieldList[i]).FrameNo = FrameNo) Then
      pFieldRec(FieldList[i]).RowNo := pFieldRec(FieldList[i]).RowNo + 1;

    p := SubFrames.IndexOf(IntToStr(pFieldRec(FieldList[i]).FrameNo));
    If p <> -1 Then ParentFrameNo := StrToInt(SubFramesParent[p]) Else
      ParentFrameNo := 0;
    If (ParentFrameNo > 0) And (ParentFrameNo = FrameNo) Then Begin
      if (pFieldRec(FieldList[i]).ParentRowNo >= Row) Then
        pFieldRec(FieldList[i]).ParentRowNo := pFieldRec(FieldList[i]).ParentRowNo + 1;
    End;
  End;
End;

procedure TStoredata.GetFieldData(FieldName:String;RowNo:integer;FieldData:pFieldData);
var k:integer;
begin
  if not assigned(fielddata) then exit;
  if Fieldname = '__autoinc' then begin
    fielddata.value := '1';
    if newtrans then fielddata.oldvalue := '0' else fielddata.OldValue := '1';
    fielddata.datatype := 'n';
    fielddata.id := 0;
    fielddata.oldid := 0;
    fielddata.table := '';
  end else if FieldName = '__autodec' then begin
    fielddata.value := '-1';
    if newtrans then fielddata.oldvalue := '0' else fielddata.OldValue := '-1';
    fielddata.datatype := 'n';
    fielddata.id := 0;
    fielddata.oldid := 0;
    fielddata.table := '';
  end else if lowercase(FieldName) = lowercase(primarytablename)+'id' then begin
    fielddata.value := floattostr(primarytableid);
    if newtrans then fielddata.oldvalue := '0' else fielddata.OldValue := fielddata.value;
    fielddata.datatype := 'n';
    fielddata.id := 0;
    fielddata.oldid := 0;
    fielddata.table := companyname+primarytablename;
  end else begin
    k := GetFieldIndex(FieldName, Rowno);
    if (k = -1) and (rowno > 1) then k := GetFieldIndex(FieldName,1);
    if k = -1 then begin
      fielddata.Value := '';
      fielddata.OldValue := '';
      fielddata.datatype := '';
      fielddata.id := 0;
      fielddata.oldid := 0;
      fielddata.table := '';
    end else begin
      fielddata.Value := pFieldRec(FieldList[k]).Value;
      fielddata.OldValue := pFieldRec(FieldList[k]).OldValue;
      fielddata.datatype := pFieldRec(FieldList[k]).DataType;
      fielddata.id := pFieldRec(FieldList[k]).IdValue;
      fielddata.oldid := pFieldRec(FieldList[k]).OldIdValue;
      fielddata.table := companyname+pFieldRec(FieldList[k]).tablename;
    end;
  end;
end;

function TStoreData.GetRecordId(FrameNo, Rowno: integer): extended;
var i:integer;
begin
  Result := 0;
  for i:=0 to fieldlist.count-1 do begin
    if (pFieldRec(fieldlist[i]).FrameNo = frameno) and (pFieldRec(fieldlist[i]).RowNo = rowno) and (pFieldRec(fieldlist[i]).TableName <> '') then begin
      Result := pFieldRec(fieldlist[i]).RecordId;
      break;
    end;
  end;
end;

Function TStoreData.IsTransChanged : boolean;
var i,r:integer;
    name, v, ov : String;
    vf, ovf : extended;
    vd, ovd : TDateTime;
begin
  result := false;
  for i:=0 to fieldlist.count-1 do begin
    if (pFieldRec(fieldlist[i]).TableName = '') then continue;
    name := pFieldRec(fieldlist[i]).fieldname;
    r := pFieldRec(fieldlist[i]).rowno;
    v := GetFieldValue(name, r);
    ov := pFieldRec(fieldlist[i]).Value;
    if lowercase(pFieldRec(fieldlist[i]).Datatype) = 'n' then begin
      if v <> '' then vf := StrToFloat(structdef.axprovider.dbm.gf.removecommas(v));
      if ov <> '' then ovf := StrToFloat(structdef.axprovider.dbm.gf.removecommas(ov));
      if vf <> ovf then begin
        Result := true;
        break;
      end;
    end else begin
      if v <> ov then begin
        Result := true;
        break;
      end;
    end;
  end;
end;

procedure TStoreData.UpdateTreelink(cmd:String);
var i,k:integer;
    s,table:String;
    id:extended;
begin
  i:=1;
  while true do begin
    table:=structdef.axprovider.dbm.gf.getnthstring(structdef.treetables, i);
    if table='' then break;
    s:=structdef.axprovider.dbm.gf.getnthstring(structdef.treeparents, i);
    if s='' then break;
    k:=getfieldindex(s,1);
    if k>-1 then begin
      id:=pfieldrec(fieldlist[k]).RecordId;
      if cmd='add' then addtreelink(table, lastsavedrecordid, id)
      else deltreelink(table, primarytableid);
    end;
    inc(i);
  end;
end;

procedure TStoreData.AddTreeLink(LinkTable:String; recid, parentid:extended);
var s:String;
begin
  tlink:=structdef.axprovider.dbm.getxds(tlink);
  tparents:=structdef.axprovider.dbm.getxds(tparents);tparents.buffered:=true;
  tparents.cds.commandtext:='select * from '+linktable+' where child=:id';
  tparents.AssignParam(0, floattostr(parentid), 'n');
  tparents.open;
  while not tparents.cds.eof do begin
    s:=tparents.CDS.fieldbyname('parent').AsString;
    tlink.append(linktable);
    tlink.submit('parent', s, 'n');
    tlink.submit('child', floattostr(recid), 'n');
    tlink.post;
    tparents.cds.next;
  end;
  tparents.close;
  tlink.close;
end;

procedure TStoreData.DelTreelink(Linktable :String; recid:extended);
begin
  tlink:=structdef.axprovider.dbm.getxds(tlink);
  tlink.DeleteRecord(linktable, 'child='+floattostr(recid));
  tlink.close;
end;

procedure TStoreData.SendToSites(op:TSend);
var i:integer;
begin
  if not HasSendToSite then exit;
  SendTransid:=transtype;
  for i:=0 to fieldlist.count-1 do begin
    if pFieldRec(fieldlist[i]).FieldName='sendtosite' then
      tosites:=pFieldRec(fieldlist[i]).value
    else if pFieldRec(fieldlist[i]).Fieldname='sendtransid' then
      SendTransid:=pFieldRec(fieldlist[i]).value;
  end;
  if op = DelTran then
    SyncAction := 'd'
  else if op = CancelTran then
    SyncAction := 'c'
  else begin
    if NewTrans  then
      SyncAction := 'a'
    else
      SyncAction := 'm';
  end;
  DoSend;
end;

procedure TStoreData.SetRecid(rid:Extended);
begin
  LastSavedRecordId := rid;
  PrimaryTableId := rid;
  Recid := rid;
end;

Procedure TStoreData.RemoveNoAutoGen(FieldName:String);
var i,cpos,len:integer;
    ls,rs : String;
begin
  if fieldname = '' then exit;
  i := AutoGenFields.IndexOf(FieldName);
  if i=-1 then exit;
  cpos := pos(';'+FieldName+';', NoAutoGenStr);
  if (cpos = 0) then exit;
  len := Length(';'+FieldName+';');
  ls := Copy(NoAutoGenStr,1,cpos-1);
  rs := Copy(NoAutoGenStr,cpos+len-1,Length(NoAutoGenStr));
  NoAutoGenStr := Trim(ls+rs);
end;

procedure TStoreData.DoSend;
var i,x:integer;
    sno:String;
begin
  if tosites <> '' then begin
    if tosites[1]='*' then begin
      x:=structdef.axprovider.dbm.gf.strtointz(copy(tosites,2,100));
      for i:=1 to x do begin
        if i<>siteno then
          writepkt(i);
      end;
    end else begin
      i:=1;
      while true do begin
        sno:=structdef.axprovider.dbm.gf.getnthstring(tosites,i);
        if sno='' then break;
        if siteno<>strtoint(sno) then
          writepkt(strtoint(sno));
        inc(i);
      end;
    end;
  end;
end;

procedure TStoreData.Writepkt(psiteno:integer);
var name, cname,w,pktdate,pktid,PktPriority, s:String;
    k:integer;
begin
  if not newtrans then
  begin
    s := 'update sendpkts set status = ''abdn'' where ' +
        ' ((status =''resend'')  or (status is null)) and recordid = :recid '+
        ' and tosite = :siteno and transid = :tid';
    structdef.axprovider.ExecSQL(s,FloatToStr(LastSavedRecordId)+','+IntTostr(psiteno)+','+TransType,'nn',False);
  end;
  k:=getfieldindex('ax_pktpriority',1);
  if k>-1 then PktPriority:=pfieldrec(fieldlist[k]).Value else PktPriority:='';
  if (PktPriority = '') or (PktPriority='0') then
    PktPriority := '99';
  pktdate := structdef.axprovider.dbm.gf.nowstringWithPriority(PktPriority)+
     structdef.axprovider.dbm.gf.Leftpad(inttostr(psiteno),structdef.axprovider.dbm.gf.LenMaxSiteNo,'0');
  qpkt.Append('SendPkts');
  qpkt.Submit('pktdate',pktdate,'c');
  qpkt.Submit('tosite',IntToStr(psiteno),'n');
  qpkt.Submit('transid',TransType,'c');
  qpkt.Submit('username',username,'c');
  qpkt.Submit('action',SyncAction,'c');
  qpkt.Submit('totransid',SendTransid,'c');
  qpkt.Submit('recordid',FloatToStr(LastSavedRecordId),'n');
  k:=getfieldindex('ax_pktid',1);
  if k>-1 then pktid:=pfieldrec(fieldlist[k]).Value else pktid:='';
  qpkt.submit('pktid', pktid, 's');
  qpkt.submit('pktpriority', PktPriority, 'n');
  qpkt.Post;
  qpkt.close;
end;

function TStoreData.GetUserActivePrefix(transid,fieldname:String):String;
var wstr,sql : String;
begin
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(fieldname))+
      ' and '+structdef.axprovider.dbm.gf.sqllower+'(uname)='+quotedstr(username);
  sql := 'select prefix from '+uppercase(fcompanyname)+'USERSEQUENCE where '+wstr;
  qSeq.close;
  qSeq.buffered := True;
  qSeq.CDS.CommandText := sql;
  qSeq.open;
  if qSeq.CDS.IsEmpty then
    result := ''
  else
    result := qSeq.CDS.FieldByName('prefix').AsString;
  qSeq.close;
end;

function TStoreData.GetActivePrefix(transid,fieldname:String):String;
var wstr,sql,seqtbl : String;
begin
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(fieldname))+
      ' and '+structdef.axprovider.dbm.gf.sqllower+'(uname)='+quotedstr(username);
  sql := 'select prefix from '+uppercase(fcompanyname)+'USERSEQUENCE where '+wstr;
  qSeq.close;
  qSeq.buffered := True;
  qSeq.CDS.CommandText := sql;
  qSeq.open;
  seqtbl := Trim(GetFieldValue('Axp_SeqTable',1));
  if seqtbl = '' then
    seqtbl := 'Sequence';
  sql:='Select prefixfield FROM '+uppercase(fCompanyName)+seqtbl+' WHERE '+structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(Transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname));
  wstr := structdef.axprovider.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(transid))+' and '+structdef.axprovider.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(fieldname))+ ' ';
  if qSeq.CDS.IsEmpty then begin
    SQl := sql + ' and ACTIVESEQUENCE = ''T''';
    wstr := wstr + ' and ACTIVESEQUENCE = ''T''';
  end else begin
    SQl := sql + ' and prefix = '+quotedstr(qSeq.CDS.FieldByName('prefix').AsString);
    wstr := wstr + ' and prefix = '+quotedstr(qSeq.CDS.FieldByName('prefix').AsString);
  end;
  QSeq.close;
  Qseq.buffered := True;
  Qseq.CDS.CommandText := sql;
  Qseq.open;
  if qSeq.CDS.IsEmpty then
    result := ''
  else
    result := Trim(qSeq.CDS.FieldByName('prefixfield').AsString);
  qSeq.close;
end;

Procedure TStoreData.SaveList(source:String);
var templist : TStringlist;
    fldrec : pFieldRec;
    i : integer;
    s : String;
begin
  templist := TStringList.create;
  if fileexists('slist.txt') then
    templist.LoadFromFile('slist.txt');
  templist.add(source);
  for i := 0 to fieldlist.Count - 1 do begin
    fldrec := pFieldRec(fieldlist[i]);
    s := fldrec.fieldname+','+inttostr(fldrec.FrameNo)+','+inttostr(fldrec.rowno)+','+floattostr(fldrec.RecordId)+','+fldrec.value+' '+fldrec.fld.DataRows.CommaText;
    templist.add(s);
  end;
  templist.savetofile('slist.txt');
  templist.free;
end;

procedure TStoreData.InsertinOutboundTable(transid : String; rid : Extended);
var
  sxds : TXDS;
  outboundid : Extended;
  outboundstr : String;
begin
  // IsCancelDefined := true;
  sxds := structdef.axprovider.dbm.GetXDS(nil);
  sxds.buffered := true;
  sxds.CDS.CommandText := 'select outboundid from '+companyname+'outbound'+' where (transid = :tid) and (recordid = :rid) and (SentOn is NULL)';
  sxds.CDS.Params.ParamByName('tid').AsString := transid;
  if Connection.Driver = 'ado' then
    sxds.CDS.Params.ParamByName('rid').AsFloat := rid
  else
    sxds.CDS.Params.ParamByName('rid').AsString := floattostr(rid);
  sxds.open;
  if sxds.CDS.RecordCount > 0 then
  begin
    if Connection.Driver = 'ado' then
      outboundid := sxds.CDS.FieldByName('outboundid').AsFloat
    else
      outboundstr :=  sxds.CDS.FieldByName('outboundid').AsString;
    try
      sxds.close;
      sxds.CDS.CommandText := 'update '+companyname+'outbound'+' set username = :uname, modifiedon = :modifiedon where outboundid = :outboundid';
      sxds.CDS.Params.ParamByName('uname').AsString := UserName;
      sxds.CDS.Params.ParamByName('modifiedon').AsString := datetimetostr(now);
      if Connection.Driver = 'ado' then
        sxds.CDS.Params.ParamByName('outboundid').AsFloat := outboundid
      else
        sxds.CDS.Params.ParamByName('outboundid').AsString := outboundstr;
      if structdef.axprovider.dbm.gf.RemoteLogin then
        sxds.open
      else
        sxds.execsql;
      except
      on e : exception do
      begin
        if assigned(structdef) then  begin
          structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\InsertinOutboundTable - '+e.Message);
          structdef.axprovider.dbm.gf.DoDebug.msg('   ' + e.Message);
        end;
        sxds.close; sxds.Free; sxds := nil;
        exit;
      end;
    end;
  end
  else
  begin
    if (Connection.DbType = 'ms sql') or (Connection.DbType = 'mysql') or (Connection.DbType = 'postgre') then
    begin
      try
        sxds.close;
        sxds.CDS.CommandText := 'insert into '+companyname+'outbound'+' (transid, recordid, oaction, username, modifiedon, senton)'
                                 + ' values (:tid,:rid,NULL,:uname,NULL,NULL)';
        sxds.CDS.Params.ParamByName('tid').AsString := transid;
        sxds.CDS.Params.ParamByName('rid').AsFloat := rid;
        sxds.CDS.Params.ParamByName('uname').AsString := UserName;
        if structdef.axprovider.dbm.gf.RemoteLogin then
          sxds.open
        else
          sxds.execsql;
        except
        on e : exception do
        begin
          if assigned(structdef) then  begin
            structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\InsertinOutboundTable - '+e.Message);
            structdef.axprovider.dbm.gf.DoDebug.msg('   ' + e.Message);
          end;
          sxds.close; sxds.Free; sxds := nil;
          exit;
        end;
      end;
    end
    else if Connection.DbType = 'oracle' then
    begin
      try
        sxds.close;
        sxds.CDS.CommandText := 'insert into '+companyname+'outbound'+' (outboundid, transid, recordid, oaction, username, modifiedon, senton)'
                                 + ' values ('+companyname+'outbound_seq.nextval,:tid,:rid,NULL,:uname,NULL,NULL)';
        sxds.CDS.Params.ParamByName('tid').AsString := transid;
        sxds.CDS.Params.ParamByName('rid').AsString := floattostr(rid);
        sxds.CDS.Params.ParamByName('uname').AsString := UserName;
        if structdef.axprovider.dbm.gf.RemoteLogin then
          sxds.open
        else
          sxds.execsql;
        except
        on e : exception do
        begin
          if assigned(structdef) then begin
            structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\InsertinOutboundTable - '+e.Message);
            structdef.axprovider.dbm.gf.DoDebug.msg('   ' + e.Message);
          end;
          sxds.close; sxds.Free; sxds := nil;
          exit;
        end;
      end;
    end;
  end;
  sxds.close; sxds.Free; sxds := nil;
end;

function TStoreData.CheckInsertToOutbound(transid : String) : Boolean;
var
  sxds : TXDS;
begin
  Result := false;
  if structdef.axprovider.dbm.gf.axpdataexchange = true then
  begin
    sxds := structdef.axprovider.dbm.GetXDS(nil);
    sxds.buffered := true;
    sxds.CDS.CommandText := 'select transid from '+companyname+'axpexchange'+' where (transid = :tid) and (adxinout = :adxinout)';
    sxds.CDS.Params.ParamByName('tid').AsString := transid;
    sxds.CDS.Params.ParamByName('adxinout').AsString := 'o';
    sxds.open;
    if sxds.CDS.RecordCount > 0 then
      Result := true;
    sxds.close; sxds.Free; sxds := nil;
  end;
end;

procedure TStoreData.AddRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow: integer);
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Adding RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PgRow= '+Inttostr(PgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SdRow= '+Inttostr(SdRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PPgRow= '+Inttostr(PPgRow));
  New(RowRec);
  RowRec.FrmNo := FrmNo;
  RowRec.SgRow := SgRow;
  RowRec.PgRow := PgRow;
  RowRec.SdRow := SdRow;
  RowRec.PPgRow := PPgRow;
  RowList.Add(RowRec);
End;

procedure TStoreData.InsertRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow: integer);
Var k: integer;
Begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Inserting RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PgRow= '+Inttostr(PgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SdRow= '+Inttostr(SdRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PPgRow= '+Inttostr(PPgRow));
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) And
      (pRowRec(RowList[k]).SgRow >= SgRow) Then
    Begin
      pRowRec(RowList[k]).SgRow := pRowRec(RowList[k]).SgRow + 1;
      if pRowRec(RowList[k]).PgRow > 0 then
        pRowRec(RowList[k]).PgRow := pRowRec(RowList[k]).PgRow + 1;
      if pRowRec(RowList[k]).SdRow > 0 then
        pRowRec(RowList[k]).SdRow := pRowRec(RowList[k]).SdRow + 1;
    End;
  End;
  New(RowRec);
  RowRec.FrmNo := FrmNo;
  RowRec.SgRow := SgRow;
  RowRec.PgRow := PgRow;
  RowRec.SdRow := SdRow;
  RowRec.PPgRow := PPgRow;
  RowList.Insert(SgRow,RowRec);
End;

procedure TStoreData.InsertStaticRowRec(FrmNo, SgRow: integer);
Var k: integer;
Begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Inserting Static RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) And
      (pRowRec(RowList[k]).SgRow >= SgRow) Then
    Begin
      pRowRec(RowList[k]).SgRow := pRowRec(RowList[k]).SgRow + 1;
    End;
  End;
  New(RowRec);
  RowRec.FrmNo := FrmNo;
  RowRec.SgRow := SgRow;
  RowRec.PgRow := 0;
  RowRec.SdRow := 0;
  RowRec.PPgRow := 0;
  RowList.Insert(SgRow,RowRec);
End;

procedure TStoreData.DeleteRowRec(FrmNo, SgRow : integer);
Var k: integer;
Begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Deleting RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) And
      (pRowRec(RowList[k]).SgRow = SgRow) Then
    Begin
      Dispose(pRowRec(Rowlist[k]));
      RowList.Delete(k);
      Break;
    End;
  End;
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) And
      (pRowRec(RowList[k]).SgRow > SgRow) Then
    Begin
      pRowRec(RowList[k]).SgRow := pRowRec(RowList[k]).SgRow - 1;
      if pRowRec(RowList[k]).PgRow > 0 then
        pRowRec(RowList[k]).PgRow := pRowRec(RowList[k]).PgRow - 1;
      if pRowRec(RowList[k]).SdRow > 0 then
        pRowRec(RowList[k]).SdRow := pRowRec(RowList[k]).SdRow - 1;
    End;
  End;
End;

procedure TStoreData.DelRowRecWithSdRow(FrmNo, SdRow : integer);
Var k, r, n: integer;
Begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Deleting RowRec with sdrow. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SdRow= '+Inttostr(SdRow));
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) And
      (pRowRec(RowList[k]).SdRow = SdRow) Then
    Begin
      r := pRowRec(Rowlist[k]).SgRow;
      Dispose(pRowRec(Rowlist[k]));
      RowList.Delete(k);
      n := k;
      Break;
    End;
  End;
  For k := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[k]).FrmNo = FrmNo) then
    begin
      if (pRowRec(RowList[k]).SdRow > SdRow) or (pRowRec(RowList[k]).SgRow > r) Then
      Begin
        pRowRec(RowList[k]).SgRow := pRowRec(RowList[k]).SgRow - 1;
        if pRowRec(RowList[k]).PgRow > 0 then
          pRowRec(RowList[k]).PgRow := pRowRec(RowList[k]).PgRow - 1;
        if pRowRec(RowList[k]).SdRow > 0 then
          pRowRec(RowList[k]).SdRow := pRowRec(RowList[k]).SdRow - 1;
      End;
    end;
  End;
End;

procedure TStoreData.SetRowRec(FrmNo, SgRow, PgRow, SdRow, PPgRow : integer);
var p : integer;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Setting RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PgRow= '+Inttostr(PgRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SdRow= '+Inttostr(SdRow));
  structdef.axprovider.dbm.gf.DoDebug.msg('    PPgRow= '+Inttostr(PPgRow));
  p := GetRowIndex(FrmNo, SgRow);
  If p = -1 Then Begin
    new(RowRec);
    RowList.Add(RowRec);
  End Else
    RowRec := RowList.Items[p];
  RowRec.PgRow := PgRow;
  RowRec.SdRow := SdRow;
  RowRec.PPgRow := PPgRow;
End;

Function TStoreData.GetRowIndex(FrmNo, SgRow: Integer): integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).SgRow = SgRow) then
    Begin
      result := i;
      break;
    End;
  End;
End;

Function TStoreData.Sg2Pg(FrmNo,SgRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).SgRow = SgRow) then
    Begin
      result := pRowRec(RowList[i]).PgRow;
      break;
    End;
  End;
end;

Function TStoreData.Pg2Sg(FrmNo,PgRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).PgRow = PgRow) then
    Begin
      result := pRowRec(RowList[i]).SgRow;
      break;
    End;
  End;
end;

Function TStoreData.Pg2Sd(FrmNo,PgRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).PgRow = PgRow) then
    Begin
      result := pRowRec(RowList[i]).SdRow;
      break;
    End;
  End;
end;

Function TStoreData.Sg2Sd(FrmNo,SgRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).SgRow = SgRow) then
    Begin
      result := pRowRec(RowList[i]).SdRow;
      break;
    End;
  End;
end;

Function TStoreData.Sd2Sg(FrmNo,SdRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).SdRow = SdRow) then
    Begin
      result := pRowRec(RowList[i]).SgRow;
      break;
    End;
  End;
end;

Function TStoreData.Sd2Pg(FrmNo,SdRow:Integer):Integer;
Var
  i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
      (pRowRec(RowList[i]).SdRow = SdRow) then
    Begin
      result := pRowRec(RowList[i]).PgRow;
      break;
    End;
  End;
end;

Function TStoreData.PrPg2Sd(FrmNo,PPgRow,PgRow:Integer):Integer;
Var i: integer;
Begin
  result := -1;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
       (pRowRec(RowList[i]).PPgRow = PPgRow) And
       (pRowRec(RowList[i]).pgRow = pgRow) then
    Begin
      result := pRowRec(RowList[i]).SdRow;
      break;
    End;
  End;
end;

function TStoreData.GetSubRowCount(FrmNo,PPgRow:Integer):Integer;
Var i: integer;
Begin
  result := 0;
  For i := 0 To RowList.count - 1 Do Begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) And
       (pRowRec(RowList[i]).PPgRow = PPgRow) {And (pRowRec(RowList[i]).SdRow <> 0)} then
      result := result+1;
  End;
end;

procedure TStoreData.DeleteRowList(FrmNo:Integer);
var i : integer;
begin
  i := 0;
  while i <= RowList.count-1 do
  begin
    If (pRowRec(RowList[i]).FrmNo = FrmNo) then
    begin
       Dispose(pRowRec(RowList[i]));
       RowList.Delete(i);
    end else
       inc(i);
  end;
end;

procedure TStoreData.AddStaticRowRec(FrmNo, SgRow: integer);
Var k: integer;
Begin
  structdef.axprovider.dbm.gf.DoDebug.msg('  Adding Static RowRec. FrameNo= '+Inttostr(Frmno));
  structdef.axprovider.dbm.gf.DoDebug.msg('    SgRow= '+Inttostr(SgRow));
  New(RowRec);
  RowRec.FrmNo := FrmNo;
  RowRec.SgRow := SgRow;
  RowRec.PgRow := 0;
  RowRec.SdRow := 0;
  RowRec.PPgRow := 0;
  RowList.Add(RowRec);
End;

procedure TStoreData.SaveImages(i:integer);
var imglist,imgnames, tblname,fname,sqlStr,s,tmp_AxpPath : String;
    k : integer;
    tmp_fd : pFld;
begin
  tmp_AxpPath := '';
  if StructDef.HasImgPath then
  begin
     s := 'dc'+Trim(Inttostr(PFieldRec(fieldlist[i]).FrameNo))+'_imagepath' ;
     tmp_fd := StructDef.GetField(s);
     if assigned(tmp_fd) then
     begin
       if GetFieldValue(s,1) = '' then
       begin
         tmp_AxpPath := AxpImagePath;
         AxpImagePath := '';
       end;
     end;
  end;
  if (imgPath = '') or (Trim(PFieldRec(fieldlist[i]).Value) = '')
    or (AxpImagePath <> '') then exit;
  tblname := Companyname+Transtype+PFieldRec(fieldlist[i]).fieldname;
  imgnames := PFieldRec(fieldlist[i]).Value;
  imglist := GetString(imgnames);
  k := 1;
  fname := structdef.axprovider.dbm.gf.GetNthString(imglist,k);
  while fname <> '' do
  begin
    if FileExists(ImgPath+fname) then
      structdef.axprovider.SaveImage(imgPath,fname,tblname,LastSavedRecordId);
    inc(k);
    fname := structdef.axprovider.dbm.gf.GetNthString(imglist,k);
  end;
  if tmp_AxpPath <> '' then AxpImagePath := tmp_AxpPath;
end;

Procedure TStoreData.DeleteImages;
var i,rc,j, r : integer;
    tblname,sqlstr, fname, ImgFiles : String;
    imglist,oimglist : TStringList;
begin
  if (AxpImagePath <> '') or (structdef.HasImgPath) then exit;
  try
  imglist := TStringList.Create;
  oimglist := TStringList.Create;
  for i := 0 to structdef.ImgFldList.Count - 1 do begin
    imglist.Clear;
    fld := structdef.GetField(structdef.ImgFldList.Names[i]);
    if structdef.ImgFldList.ValueFromIndex[i] = 'i' then continue;
    rc := GetRowCount(fld.FrameNo);
    for r := 1 to rc do begin
      ImgFiles := GetOldValue(fld.FieldName,r);
      if ImgFiles <> '' then begin
        j := 1;
        fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFiles,j);
        while fname <> '' do begin
          oImgList.Add(fname);
          inc(j);
          fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFiles,j);
        end;
      end;
      ImgFiles := GetFieldValue(fld.FieldName,r);
      if ImgFiles <> '' then begin
        j := 1;
        fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFiles,j);
        while fname <> '' do begin
          ImgList.Add(fname);
          inc(j);
          fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFiles,j);
        end;
      end;
    end;
    for j := 0 to ImgList.Count - 1 do begin
      r := oImgList.IndexOf(ImgList[j]);
      if r>=0 then oImgList.Delete(r);
    end;
    tblname := Companyname+Transtype+structdef.ImgFldList.Names[i];
    for j := 0 to oImgList.Count - 1 do
    begin
      sqlStr := 'delete from '+tblname+' where recordid = '+Floattostr(LastSavedRecordid)+' and filename = '+Quotedstr(oimgList[j]);
      Structdef.axprovider.ExecSQL(sqlStr,'','',false);
    end;
  end;
  RemoveImagesForDeletedRows;
  finally
    if assigned(ImgList) then FreeAndNil(ImgList);
    if assigned(oImgList) then FreeAndNil(oImgList);
  end;
end;

Function TStoreData.GetString(ImageNames : String):String;
var
  tblName,transid,x,y,ans,temp,fname : String;
  i,ob,cb,count : integer;
  recid : Extended;

begin
  ans :=''; i := 1;
  x := ImageNames;
  count := CountNumberOfAt(x);
  if count = 0 then begin
    result := trim(ImageNames);
    exit;
  end;
  while count > 0 do begin
   // delete(x,1,1);
    tblName := copy(x,1,pos(',',x)-1);
    recid := StrToFloat(copy(x,pos(',',x)+1,pos('(',x)-pos(',',x)-1));
    ob := pos('(',x)+1;
    CB := pos(')',x);
    y := copy(x,ob,cb-ob);
    x := copy(x,pos('@',x),length(x)-pos('@',x)+1);
    count := count- 1;
    if count > 0 then
      ans := ans+','+y
    else ans := y ;
  end;
  temp := trim(copy(x,cb+2,length(x)-cb));
  result := temp;
end;


function TStoreData.CountNumberOfAt(FieldValue :String ): integer;
var
  i,a : integer;
  s : String;
  found : boolean;
begin
  found := false; a :=0;
  for I := 0 to length(FieldValue) - 1 do begin
    s := FieldValue[i];
    if s = '@' then begin
      a := a + 1;
      found := true;
    end;
  end;
  if not found then result := 0
  else result := a;

end;

Procedure TStoreData.AfterSort;
var i:integer;
    fd:pFld;
    frec:pFieldRec;
begin
  for I := 0 to structdef.flds.count - 1 do
    pFld(structdef.flds[i]).datarows.clear;

  for I := 0 to FieldList.count - 1 do begin
    frec:=pFieldRec(FieldList[i]);
    fd:=frec.fld;
    if assigned(fd) then fd.datarows.Add(inttostr(i));
  end;
end;

Procedure TStoreData.UpdateRecIdInAutoGenData(Rowno:Integer);
var i : integer;
    arec : pAutoGenRec;
begin
  for i := 0 to structdef.axprovider.dbm.gf.AutoGenData.Count - 1 do
  begin
    arec := pAutoGenRec(structdef.axprovider.dbm.gf.AutoGenData[i]);
    if (arec.Transid = TransType) and (arec.Rowno = Rowno) and (not arec.RecordidUpdated) and
      (lowercase(arec.Schema) = lowercase(CompanyName)) and (lowercase(arec.TableName) = lowercase(TableName)) then
    begin
      arec.RecordId := NewRecid;
      Arec.RecordidUpdated := True;
    end;
  end;
end;

Procedure TStoreData.ClearDatarows;
var i : integer;
begin
  for I := 0 to structdef.flds.count - 1 do
    pFld(structdef.flds[i]).datarows.clear;
end;

Function TStoreData.GetTableId(TblName:String):Extended;
var i : integer;
begin
  result := 0;
  for i := 0 to structdef.frames.Count-1 do begin
    if pFrm(structdef.frames[i]).TableName = TblName then
    begin
      result := GetParentDocid(pFrm(structdef.frames[i]).FrameNo,1);
      if result > 0 then
        break;
    end;
  end;
end;

procedure TStoreData.SaveCancelRemarksToHistotyTable(crem:Boolean;rem:String);
var
  tblname ,s : string;
begin
  tblname := companyname+transtype+'history';
  if crem and structdef.axprovider.FieldFound('fieldname',tblname) then begin
    historytable.Append(tblname);
    s := datetimetostr(structdef.axprovider.dbm.getserverdatetime);
    historytable.submit('MODIFIEDDATE',s,'d');
    historytable.submit('recordid',floatTostr(LastSavedRecordId),'n');
    historytable.submit('USERNAME',UserName,'c');
    historytable.submit('newtrans','f', 'c');
    historytable.submit('canceltrans','t', 'c');
    historytable.submit('cancelremarks',rem, 'c');
    historytable.post;
  end
  else begin
    if assigned(Tracklist) then Tracklist.clear
    else tracklist := TStringList.create;
    s:= datetimetostr(structdef.axprovider.dbm.getserverdatetime);
    tracklist.Add('<d>');
    tracklist.Add(s+','+username);
    tracklist.Add('<cr>');
    tracklist.Add(rem);
    SaveHistoryToTable(true);
  end;
end;

procedure TStoreData.RemoveImagesForDeletedRows;
Var i, j: integer;
    imgFldName,ImgFldVal,sqlstr,fname,tblname : String;
Begin
  i := 0;
  While (i < fieldlist.count) Do Begin
    If (PFieldRec(FieldList[i]).RowNo = -1) Then Begin
      If (PFieldRec(fieldlist[i]).oldrow <> 0) Then Begin
        ImgFldName := 'dc'+IntTostr((PFieldRec(FieldList[i]).FrameNo))+'_image';
        if (lowercase(PFieldRec(FieldList[i]).FieldName)=ImgFldName) then begin
          ImgFldVal := PFieldRec(FieldList[i]).OldValue;
          j :=1;
          fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFldVal,j);
          while fname <> '' do begin
            tblName := transtype+ImgFldName;
            sqlStr := 'delete from '+tblName+' where recordid = '+Floattostr(LastSavedRecordid)+' and filename = '+Quotedstr(fname);
            Structdef.axprovider.ExecSQL(sqlStr,'','',false);
            inc(j);
            fname := Structdef.axprovider.dbm.gf.GetNthString(ImgFldVal,j);
          end;
        end;
      End;
      inc(i);
    End Else
      inc(i);
  End;
end;

Procedure TStoredata.DeleteAllImages;
var i : integer;
    tblname,SqlStr : String;
begin
  if (AxpImagePath <> '') or (structdef.HasImgPath) then exit;
  for i := 0 to structdef.ImgFldList.Count - 1 do begin
    tblName := CompanyName+TransType+structdef.ImgFldList.Names[i];
    sqlStr := 'delete from '+tblname+' where recordid = '+Floattostr(LastSavedRecordid);
    Structdef.axprovider.ExecSQL(sqlStr,'','',false);
  end;
end;

Procedure TStoredata.SetCurrencyDec(CurStr:String;RowNo:Integer);
var dec,i,j : integer;
    s,s1 : String;
    cFld : pFld;
begin
    CurStr := CurStr + '~';
  j := 1;
  while True do
  begin
    s1 := structdef.axprovider.dbm.gf.GetNthString(CurStr,j,'~');
    if s1 = '' then break;
    inc(j);
    s := structdef.axprovider.dbm.gf.GetNthString(s1,1);
    if not Isnumeric(s) then begin
      raise Exception.Create('AxpCurrencyDec field is having invalid decimal value');
    end;
    dec := StrToInt(s);
    i := 2;
    s := structdef.axprovider.dbm.gf.GetNthString(s1,i);
    while s <> '' do begin
      cfld := structdef.GetField(s);
      if cfld <> nil then begin
        //if Dynamic decimal > defined fld decimal
        if dec > cfld.CurDec then raise Exception.Create(cfld.Fieldname+' field should not have decimal value '+
                                                            ' greater than defined decimal value('+inttostr(cfld.CurDec)+') in tstruct field properties.');
        if cfld.Dec <> dec then begin
          cfld.Dec := dec;
          if Assigned(RefreshCurrencyFld) then
            RefreshCurrencyFld(cfld);
        end;
      end;
      inc(i);
      s := structdef.axprovider.dbm.gf.GetNthString(s1,i);
    end;
  end;
end;


Procedure TStoreData.LoadTransForWeb(RecordId: Extended);
Var
  RowNo, rcount, k, pr, priorpr, f, i, x,j : integer;
  value,tnames, dcno : String;
  id : extended;
  PRowDefined : Boolean;
  frm : pFrm;
Begin
  Attachment_files := '';
  GridDc_Attach := false;
  structdef.axprovider.dbm.gf.DoDebug.msg('>>Loading transaction '+ftranstype+ ' record '+floattostr(recordid));
  ClearFieldList;
  ParentControl := 0;
  {
  RowCountList.clear;
  for x := 0 to structdef.framecount-1 do
    rowcountlist.add('0');
  }
  PrimaryTableId := RecordId;
  RecId := RecordId;
  TableName := '';
  FirstTableName := '';
  RecordIdList.Clear;
  EntryDocLoaded := false;
  Cancelled := false;
  CancelledTrans := false;
  CancelRemarks := '';
  Deleted := False;
  tnames := '';
//  structdef.flds.sort(sortfldsload);
  for i := 0 to structdef.frames.Count-1 do begin
    frm := pFrm(structdef.frames[i]);
    TableName := frm.TableName;
    if pos(','+tablename+',',tnames) > 0 then continue;
    tnames := tnames + ',,' + TableName  + ',';
    If FirstTableName = '' Then FirstTableName := TableName;
    LoadIntoDataSetForWeb(frm);
    PriorPR := 0;
    If (ChildTrans) And (TableName = FirstTableName) Then
       Recid := DQLoad.cds.FieldByName(TableName + 'Id').AsFloat;
    If (TableName = FirstTableName) Then Begin
      If ApprovalDefined Then Begin
        Self.Approval := DQLoad.cds.FieldByName('Approval').AsInteger;
        Self.ApprovalStatus := DQLoad.cds.FieldByName('ApprovalStatus').AsString;
        Self.MaxApproved := DQLoad.cds.FieldByName('MaxApproved').AsInteger;
      End;
      If DQLoad.CDS.Fieldbyname('SourceId').asFloat > 0 Then
        Self.ChildDoc := 'T'
      Else
        Self.ChildDoc := 'F';
    End;
    RowNo := 1;
    RCount := 0;
    PRowDefined := assigned(DQLoad.CDS.FindField('parentrow'));

    While Not DQLoad.cds.Eof Do Begin
      RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(frm.frameno), 3, ' ')
        + structdef.axprovider.dbm.gf.Pad(IntToStr(RowNo), 5, ' ') + structdef.axprovider.dbm.gf.pad(DQLoad.cds.FieldByName(TableName +'id').asstring,structdef.axprovider.dbm.gf.MaxRecid,' ')+Tablename);
      inc(RCount);
      structdef.axprovider.dbm.gf.DoDebug.msg('Loading from '+ DQLoad.cds.FieldByName(TableName +'id').asstring +' into frame '+inttostr(frm.frameno)+', row '+inttostr(rowno));
      for j:=0 to DQLoad.CDS.FieldCount-1 do begin
        fld := structdef.GetField(DQLoad.CDS.Fields[j].FieldName);

        if not assigned(fld) then continue;
        if fld.Tablename = '' then continue;
        if (fld.Tablename <> '') and (frm.TableName <> fld.Tablename) then continue;

        If fld.sourcekey Then Begin
          Value := GetValueFromTable(Rowno);
          id := DQload.cds.fieldbyname(fld.fieldname).asfloat;
        End Else Begin
          if fld.DataType = 'n' then
          begin
            if DQload.cds.fieldbyname(fld.fieldname).asstring <> '' then
               value := floattostr(DQload.cds.fieldbyname(fld.fieldname).asfloat)
            else value := DQload.cds.fieldbyname(fld.fieldname).asstring;
          end else
            value := DQload.cds.fieldbyname(fld.fieldname).asstring;
          id := 0;
        End;

        if ((fld.ModeofEntry = 'calculate') and (fld.cexp<>'')) or (fld.ComponentType <> '') then
        begin
           //if pos(','+fld.FieldName,empty_load_flds) <=0 then
           //   empty_load_flds := empty_load_flds + ',' + fld.FieldName;
           if assigned(NoSaveFldDcs) then
           begin
              dcno := inttostr(fld.FrameNo);
              if NoSaveFldDcs.IndexOf(dcno) = -1 then
                 NoSaveFldDcs.Add(dcno);
           end else
           begin
             NoSaveFldDcs := TStringList.Create;
             NoSaveFldDcs.Add(inttostr(fld.FrameNo));
           end;
        end;

        if fld.EncryptValue then value := structdef.axprovider.dbm.gf.DecryptFldValue(value,fld.datatype);
        Fieldorder := fld.orderno;
        structdef.axprovider.dbm.gf.DoDebug.msg(fld.fieldname + ' = '+Value);
        if Id > 0 then structdef.axprovider.dbm.gf.DoDebug.msg('IdValue = '+FloatTostr(id));
        if (lowercase(fld.fieldname) = 'axp_attach') and (value <> '') then
        begin
            GridDc_Attach := true;
            Attachment_files := 'trans data loaded';
        end;

        SetFieldValue(fld.fieldname,
          fld.datatype,
          fld.tablename,
          value,
          value,
          RowNo,
          id,
          id,
          fld.frameno,
          DQLoad.cds.fieldbyname(TableName + 'id').asfloat,
          fld.sourcekey);
          Parser.RegisterVar(fld.FieldName,Char(fld.DataType[1]),value);

        if PRowDefined then begin
          k := getfieldindex(fld.fieldname, rowno);
          pFieldRec(Self.FieldList[k]).ParentRowNo := DQLoad.cds.Fieldbyname('parentrow').asinteger;
        end else begin
          f := SubFrames.Indexof(inttostr(fld.frameno));
          If (f <> -1) Then begin
            pr := GetParentRowNo(StrToInt(trim(SubFramesParent[f])), DQLoad.cds.fieldbyname('ParentRecordid').asFloat);
            if pr < PriorPr then
              Raise EDataBaseError.Create('Improper RowOrder in Sub form, Frame No '+subframes[f]);
            SetParentRowNo(fld.fieldname, RowNo, pr);
            PriorPr := pr;
          end;
        end;
      End;
      DQLoad.cds.next;
      inc(RowNo);
    End;
  end ;
  structdef.MakeProperStartIndex;

  for i := 0 to structdef.frames.Count-1 do begin
    id := GetParentDocid(pFrm(structdef.frames[i]).FrameNo,1);
    if id = 0 then begin
      id := GetRecordId(pFrm(structdef.frames[i]).FrameNo,1);
      if id = 0 then
      begin
        id := GetTableId(pFrm(structdef.frames[i]).TableName);
      end;
      RecordIdList.Add(structdef.axprovider.dbm.gf.Pad(IntToStr(pFrm(structdef.frames[i]).FrameNo), 3, ' ') + structdef.axprovider.dbm.gf.Pad('1', 5, ' ') + structdef.axprovider.dbm.gf.pad(FloatToStr(id), structdef.axprovider.dbm.gf.MaxRecid, ' ') + pFrm(structdef.frames[i]).TableName);
    end;
    if RowCountForWeb(pFrm(structdef.frames[i]).FrameNo) > 0 then pFrm(structdef.frames[i]).HasDataRows := True;
  end;
//  structdef.flds.sort(sortfldsDefault);

  structdef.axprovider.dbm.gf.DoDebug.msg('Loading no-save fields');
//  LoadNotSavedFields;
  dqload.close;
  dqloadqualified.close;
//  FieldList.Sort(SortFieldListLoad);
//  AfterSort;
  FieldOrder := 0;
  LastSavedRecordId := RecId;
  PrimaryTableid := RecId;

  //Is Amendment enabled  | AMENDMENT check  | If not new trans
  //transations can have Amendment and PEG both paralelly
  if  (LastSavedRecordId > 0) and (structdef.IsAmendmentEnabled) then
  begin
    structdef.axprovider.dbm.gf.DoDebug.msg('LoadTrans/ LoadAmendment data starts');
    FetchAmendForLoadData;
    structdef.axprovider.dbm.gf.DoDebug.msg('LoadTrans/ LoadAmendment data ends.');
  end;
  //PEG check
  //Make transaction readonly if its PEG transaction. //axpegreadonlytrans pair will be added with Loaddatajson
  if (structdef.isPegAttached) then
    structdef.axprovider.dbm.gf.bAxPegReadOnlyTrans := IsPegTaskInitiated;
End;

Procedure TStoreData.LoadIntoDataSetForWeb(frm : pFrm);
Var
  SelectText, FromText, WhereText, OrderText, fno: String;
  Alias: char;
  p, sfn: integer;
  Asgrid : Boolean;
Begin
  Alias := 'a';
  OrderText := '';
  Selecttext := '';
  MasterTableName := PrimaryTableName;
  fno := inttostr(frm.frameno);
  sfn := SubFrames.Indexof(fno);
  {
  If TableName = FirstTableName Then Begin
    Selecttext := 'Select a.' + TableName + 'id, a.SourceId';
    if IsCancelDefined then
     SelectText := SelectText + ', a.cancel, a.cancelremarks ';
    If ApprovalDefined Then
      SelectText := SelectText + ', a.Approval, a.ApprovalStatus, a.MaxApproved';
    if IsCreatedOnDefined then
      SelectText := SelectText +', a.CreatedOn, a.CreatedBy ';
    if IsModifiedOnDefined then
      SelectText := SelectText+', a.ModifiedOn ';
    if IsUserNameDefined then
      SelectText := SelectText+', a.UserName ';
    if IsSiteNoDefined then
      SelectText := SelectText+', a.SiteNo ';
  End Else
    Selecttext := 'Select a.' + TableName + 'id';
  If (sfn <> -1) Then Begin
    if ParentRowDefined[sfn+1] = 't' then begin
      SelectText := SelectText + ', a.ParentRow';
      OrderText := ' order by a.ParentRow';
    end else
      SelectText := SelectText +', a.ParentRecordId';
  End;
  }
  If (MasterTableName = '') Or (MasterTableName = FirstTableName) Then Begin
    if connection.dbtype='access' then
       FromText := ' from ' + UpperCase(fCompanyName + '"'+TableName+'"') + ' as ' + Alias
    else
      FromText := ' from ' + UpperCase(fCompanyName + TableName) + ' ' + Alias;
    If (ChildTrans) And (TableName = FirstTableName) Then
      WhereText := ' where a.SourceId = ' + FloatTostr(PrimaryTableid) +
       ' and a.mapname = ' + quotedstr(mapname)
    Else
      WhereText := ' where a.' + FirstTableName + 'id = ' + FloatTostr(Recid);
  End Else Begin
    if connection.dbtype='access' then
       FromText := ' from ' + UpperCase(fCompanyName + '"' + TableName + '"') + ' as ' + Alias + ', '
    else
      FromText := ' from ' + UpperCase(fCompanyName + TableName) + ' ' + Alias + ', ';
    inc(alias);
    FromText := FromText + UpperCase(fCompanyName + MasterTableName) + ' ' + Alias;
    WhereText := ' where b.' + FirstTableName + 'id = ' + FloatTostr(Recid) +
      ' and a.' + MasterTableName + 'id = b.' + MasterTableName + 'id';
  End;
  inc(alias);
  SelectText := SelectText + 'Select a.* ';
  {
  While (i<structdef.flds.count) And (pfld(structdef.flds[i]).tablename = tablename) And (pfld(structdef.flds[i]).DataType <> 'i')  Do Begin
    if (Connection.MsDBverno ='Above 2012') and (pfld(structdef.flds[i]).DataType = 't') then
        SelectText := SelectText + ', cast(a.' + pfld(structdef.flds[i]).fieldname + ' as text) as ' +  pfld(structdef.flds[i]).fieldname
    else SelectText := SelectText + ', a.' + pfld(structdef.flds[i]).fieldname;
    AsGrid := pfld(structdef.flds[i]).AsGrid;
    inc(i);
  End;
  Asgrid := false;
  if frm.AsGrid then begin
    p := pos(lowercase(TableName) + 'row', lowercase(SelectText));
    if (p = 0) then begin
      if lowercase(tablename) <> lowercase(primarytablename) then
        Asgrid := true;
    end;
  end;
  }

//  p := pos(lowercase(TableName) + 'row', lowercase(SelectText));
  If frm.AsGrid Then Begin
    If ordertext = '' Then
      OrderText := ' Order by ' + lowercase(TableName) + 'row'
    Else
      OrderText := OrderText + ', ' + lowercase(TableName) + 'row';
  end;
  With DQLoad Do Begin
    Close;
    buffered := True;
    cds.CommandText := selecttext + fromtext + wheretext + OrderText;
    Try
      open;
      if Tablename=FirstTableName then begin
        if (Iscanceldefined) and (TableName=FirstTableName) then begin
          Cancelled := cds.Fieldbyname('cancel').asboolean;
          CancelRemarks := cds.Fieldbyname('cancelremarks').asstring;
          CancelledTrans := Cancelled;
        end;

        if (IsCreatedOnDefined) then begin
          CreatedOn:= datetimetostr(cds.Fieldbyname('CreatedOn').asdatetime);
          CreatedBy := cds.Fieldbyname('CreatedBy').asstring;
        end;
        if (IsUserNameDefined) then
          SUserName := cds.Fieldbyname('UserName').asstring;
        if (IsSiteNoDefined) then
          SSiteNo   := cds.Fieldbyname('SiteNo').asstring;
        if (IsModifiedOnDefined) then begin
          SModifiedOn:= datetimetostr(cds.Fieldbyname('ModifiedOn').AsDateTime);
        end;
      end;
      if (ParentControl = 0) and (assigned(cds.Fields.FindField('axp_parentcontrol'))) then
        ParentControl := cds.FieldByName('axp_parentcontrol').AsInteger;

    Except on e:Exception do
      begin
        if assigned(structdef) then  structdef.axprovider.dbm.gf.DoDebug.Log(structdef.axprovider.dbm.gf.Axp_logstr+'\uStoreData\LoadIntoDataSet - '+e.Message);
        Raise EDataBaseError.Create('Unable to load. SQL : ' + SelectText +
        FromText + WhereText + OrderText);
      end;
    End;
  End;
  if (lowercase(TableName) = lowercase(PrimaryTableName)) and (DQLoad.CDS.IsEmpty) and (not childtrans) then
    raise EDataBaseError.Create('Data stored in '+ TableName + ' is improper. Cannot load transaction');
End;

Function TStoreData.RowCountForWeb(FrameNo:Integer):Integer;
var fm:pFrm;
    i,j,k, rcount:integer;
begin
  result:=0;
  fm:=pFrm(structdef.Frames[FrameNo-1]);
  if fm.FieldCount = 0 then exit;
  for I := fm.StartIndex to fm.StartIndex+fm.FieldCount-1 do begin
    if pFld(StructDef.flds[i]).DataRows.Count > 0 then begin
      rcount:=0;
      for j := 0 to pFld(Structdef.flds[i]).datarows.count-1 do begin
        k:=strtoint(pFld(StructDef.flds[i]).datarows[j]);
        if pFieldRec(fieldlist[k]).RowNo>-1 then
        begin
          inc(rcount);
          break;
        end;
      end;
      if rcount>0 then
      begin
         result:=rcount;
         break
      end;
    end;
  end;
end;


//PEG starts here

//StoreFieldList
Procedure TStoreData.RegisterFieldList;
var
  FldRec: pFieldRec;
  i: Integer;
  sFieldName,sFieldValue,sDataType : String;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('RegisterFieldList starts...');
  if not Assigned(SDRegVarToParser) then
    Exit;
  for i := 0 to fieldlist.Count - 1 do
  begin
    FldRec := pFieldRec(fieldlist[i]);
    if FldRec.RowNo > 1 then
      Continue; //registers only row 1 values
    //if FldRec.FrameNo > 1 then //registers only frameno 1 values
    //   Continue;
    sFieldName := FldRec.fieldname;
    sFieldValue := FldRec.Value;
    sDataType := FldRec.DataType;
    //This is to register fields with datatype since in PEG conditions we used fields with datatype
    SDRegVarToParser(sDataType+sFieldName,sDataType,sFieldValue);
  end;
end;

//InitPEG
Procedure TStoreData.InitPEG;
begin
  try
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ InitPEG starts...');
    if Not Assigned(AxPEG) then
    begin
      AxPEG := TAxPEG.Create(StructDef);
      AxPEG.Parser := Parser;
      AxPEG.GetFieldValue := GetFieldValue;
      AxPEG.SDEvaluateExpr := SDEvaluateExpr;
      AxPEG.SDRegVarToParser := SDRegVarToParser;
      AxPEG.Object_ASBDataObj := Object_ASBDataObj;
      RegisterFieldList;//Registers value into parser with datatype+fieldname
    end;
    AxPEG.TransType := TransType;
    AxPEG.LastSavedRecordId := LastSavedRecordId;
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ InitPEG ends.');
  Except on E:Exception do
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ Error in InitPEG '+E.Message);
  end;
end;

//CheckAxProcessDef
procedure TStoreData.CheckAxProcessDef;
begin
  //Donot init PEG when the call is from PEG Actions (AxApprove/AxCheck)
  //This is to avoid the reinit of PEG Process
  if (bDoNotInitPEG) or (bDoNotInitPEGorAmendment) {or (IsProcessOnHold)} then
    Exit;
  InitPEG;
  if Assigned(AxPEG) then
    AxPEG.CheckAxProcessDef
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/CheckAxProcessDef/ AxPEG is not assigned.');
end;


//IsPegTaskInitiated
function TStoreData.IsPegTaskInitiated: Boolean;
begin
  result := False;
  //When process is on HOLD , the let the transaction behave as it is (normal save without peg)
  if IsProcessOnHold then
    Exit;
  InitPEG;
  if Assigned(AxPEG) then
  begin
    AxPEG.IsPegEdit := IsPegEdit;
    result := AxPEG.IsPegTaskInitiated
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/IsPegTaskInitiated/ AxPEG is not assigned.');
end;


//CancelPEGTasks
Procedure TStoreData.CancelPEGActiveTasks(pCancelRemarks,pCancelledBy,pCancelledOn : String);
begin
  InitPEG;
  if Assigned(AxPEG) then
  begin
    AxPEG.sCancelRemarks := pCancelRemarks;
    AxPEG.sCancelledBy := pCancelledBy;
    AxPEG.sCancelledOn := pCancelledOn;
    AxPEG.CancelPEGActiveTasks;
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/CancelPEGActiveTasks/ AxPEG is not assigned.');
end;

//IsPegTaskInitiated
Procedure TStoreData.CallPEGApproveUsingTaskId(pTaskId : String);
begin
  //When process is on HOLD , the let the transaction behave as it is
  bDoNotInitPEG := False;
  if (IsProcessOnHold) then
  begin
    bDoNotInitPEG := true;
    Exit;
  end;
  bDoNotInitPEG := true;
  InitPEG;
  if Assigned(AxPEG) then
  begin
    AxPEG.bIsPEGApprovalOnSave := DoPEGApprovalOnSave;
    AxPEG.CallPEGApproveUsingTaskId(pTaskId)
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/CallPEGApproveUsingTaskId/ AxPEG is not assigned.');
end;

//PEG ends here

//ConvertSDtoRapidSaveInputJSON
Function TStoreData.ConvertSDtoRapidSaveInputJSON:String;
var
  rapidsaveObject : TJSONObject;
  dataObject: TJSONObject;
  dataArray: TJSONObject;
  data1Object: TJSONObject;
  dcObject: TJSONObject;
  rowObject: TJSONObject;
  pFieldRec: Pointer; // assuming this is the type of pFieldRec
  FldRec: TFieldRec; // assuming this is the type of FldRec

  bIsFirstTime : Boolean;
  NewFrameNo, OldFrameNo, NewRowNo, OldRowNo : Integer;
begin
  result := '';
  try
  try
  structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/ConvertSDtoRapidSaveInputJSON starts.');
  // Initialize the JSON objects
  rapidsaveObject := TJSONObject.Create;
  dataObject := TJSONObject.Create;
  dataArray := TJSONObject.Create;
  data1Object := TJSONObject.Create;

  // Set the common values
  dataObject.AddPair('axpapp', structdef.axprovider.dbm.Connection.ConnectionName{ProjectName});
  dataObject.AddPair('username', structdef.axprovider.dbm.gf.Username);
  dataObject.AddPair('trace', '');
  dataObject.AddPair('transid', transtype);
  dataObject.AddPair('keyfield', '');
  dataObject.AddPair('primaryfield', '');

  bIsFirstTime := True;
  OldFrameNo := 0;
  OldRowNo := 0;

  FieldList.Sort(SortFieldListSave);
  // Process each field record
  for pFieldRec in fieldlist do
  begin
    FldRec := TFieldRec(pFieldRec^);
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

    // Add the fieldname and value pair to the row object
    rowObject.AddPair(FldRec.fieldname, FldRec.Value);

    if bIsFirstTime then
    begin
      // Update the mode and recordid based on the conditions
      if FldRec.RecordId = 0 then
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

  // Add the data1 object to the data array
  dataArray.AddPair('data1', data1Object);

  // Add the data array to the main data object
  dataObject.AddPair('dataarray', dataArray);

  //Add dataObject to rapidsaveObject
  rapidsaveObject.AddPair('rapidsave',dataObject);

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
  end;
end;


//PushSaveDataToQueue
Procedure TStoreData.PushSaveDataToQueue;
var
  sRapidSavePayload : String;
  A31SaveMode, A31ApiQueueName, A31SaveQueueName: string;
  bSaveDBandQueue : Boolean;

//ReadA31NodesFromXML
procedure ReadA31NodesFromXML(const XMLString: string);
var
  XMLDoc: IXMLDocument;
  RootNode, A31ParentNode,A31Node: IXMLNode;
  I : Integer;
  //A31SaveMode, A31ApiQueueName, A31SaveQueueName: string;
begin
  // Create and load the XML document
  XMLDoc := TXMLDocument.Create(nil);
  XMLDoc.LoadFromXML(XMLString);

  // Get the root node
  RootNode := XMLDoc.DocumentElement;

  // Find the child node with cat="tstruct"
  for I := 0 to RootNode.ChildNodes.Count - 1 do
  begin
    A31ParentNode := RootNode.ChildNodes[I];
    if A31ParentNode.HasAttribute('cat') and (A31ParentNode.Attributes['cat'] = 'tstruct') then
    begin
      A31Node := nil;
      A31Node := A31ParentNode.ChildNodes.FindNode('a31');
      if Assigned(A31Node) then
      begin
        // Read the attributes and child node values of <a31>
        A31SaveMode := A31Node.Attributes['savemode'];
        A31ApiQueueName := A31Node.ChildNodes['apiqueuename'].Text;
        A31SaveQueueName := A31Node.ChildNodes['savequeuename'].Text;
        // Break the loop since we found the desired node
        Break;
      end;
    end;
  end;
end;

begin
  bSaveDBandQueue := False;
  InitPEG;
  if Assigned(AxPEG) then
  begin
    //bSaveDBandQueue can be read from Structdef.SaveMode property but this has to be handled in uStructdef and
    //Web , this proprty has to be added and returned while saving.
    try
      ReadA31NodesFromXML(structdef.XML.XML.Text);
    except on E:Exception do
      structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/PushSaveDataToQueue/ ReadA31NodesFromXML Error : '+E.Message);
    end;
    bSaveDBandQueue := lowercase(A31SaveMode) = 'database and api queue';//Database and API queue
    if bSaveDBandQueue then
    begin
      sRapidSavePayload := ConvertSDtoRapidSaveInputJSON;
      if sRapidSavePayload = '' then
        structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/PushSaveDataToQueue/ queue message for save is empty.')
      else
        AxPEG.PushSaveDataToQueue(A31ApiQueueName,sRapidSavePayload);
    end;
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/PushSaveDataToQueue/ AxPEG is not assigned.');
end;


//CanCancelTransaction
//If the transaction is PEG attached and if any task id pendin then it should not allow.
Function TStoreData.CanCancelTransaction:Boolean;
begin
  Result := True;
  //When process is on HOLD , the let the transaction behave as it is
  if IsProcessOnHold then
    Exit;
  InitPEG;
  if Assigned(AxPEG) then
  begin
    Result := Not AxPEG.IsPegActiveTaskExists; //if tasl found the it returns true
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/CanCancelTransaction/ AxPEG is not assigned.');
end;

//IsProcessOnHold |  works based on Axp_ProcessHold var value
Function TStoreData.IsProcessOnHold:Boolean;
var
  sAxProcessHold : String;
  bAxProcessHold : Boolean;
  // Hold/Unhold functionality in the PEG module for the Kauvery
  (*
  Axp_ProcessHold value can be 0,1,2
  0 - As it's -
  1 - hold -
  2 - unhold -
  As of now,
  0 and 1 acts same for existing records
  0 and 2 acts same for new records

  later the functionality can be implemented as req.
  *)

begin
  Result := False;
  bAxProcessHold := False;
  //Check the parser first, if parser not assigned then check the form

  //When the call save is from Action/Script and if we execute SDEvaluateExpr
  //Then we are getting Av err from uparse->EvalFunction -> after CallFunction - f^.Fname
  //This might be because some object use, As a temp fix we skipped this for storetrans
  //This fix has been included to handle - option to edit trans even after peg flow ends.
  //The same way need to check with script loaddata  | also check with pegattached
  if (Not bCallFromStoreTrans) and (Assigned(SDEvaluateExpr)) then
  begin
    sAxProcessHold := Trim(SDEvaluateExpr('Axp_ProcessHold'));
    //Parser returns variable name as result when there is var found, to handle this
    //we have added below statement
    sAxProcessHold := ifthen(sAxProcessHold='Axp_ProcessHold','',sAxProcessHold);
  end
  else
    sAxProcessHold := Trim(GetFieldValue('Axp_ProcessHold',1));
  //bAxProcessHold := (sAxProcessHold = '1'); //Hold
  if sAxProcessHold = '1' then
    bAxProcessHold := true
  else if sAxProcessHold = '2' then
    bAxProcessHold := false
  else //if 0 or empty or any other value - Keep actual value of peginit
    bAxProcessHold := bDoNotInitPEG;

  Result := bAxProcessHold;
end;

//Amendment | SaveAmend
Procedure TStoreData.SaveAmend;
begin
  InitPEG;
  if Assigned(AxPEG) then
  begin
    AxPEG.StoreDataObject := Self;
    AxPEG.ParserObject := ParserObject;
    AxPEG.delrowsnode := delrowsnode;
    AxPEG.SaveAmend;
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/SaveAmend/ AxPEG is not assigned.');
end;

//FetchAmendForLoadData
Procedure TStoreData.FetchAmendForLoadData ;
begin
  structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/Executing FetchAmendForLoadData...');
  InitPEG;
  if Assigned(AxPEG) then
  begin
    AxPEG.StoreDataObject := Self;
    AxPEG.ParserObject := ParserObject;
    AxPEG.GetFieldValue := GetFieldValue;
    AxPEG.SDEvaluateExpr := SDEvaluateExpr;
    AxPEG.SDRegVarToParser := SDRegVarToParser;
    AxPEG.FetchAmendForLoadData;
  end
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/FetchAmendForLoadData/ AxPEG is not assigned.');
end;

//HasPegActiveTasks
function TStoreData.HasPegActiveTasks: Boolean;
begin
  result := False;
  InitPEG;
  if Assigned(AxPEG) then
    result := AxPEG.HasPegActiveTasks
  else
    structdef.axprovider.dbm.gf.DoDebug.msg('Storedata/HasPegActiveTasks/ AxPEG is not assigned.');
end;

//PEG ends here

End.

{
Tree structures :-
Introduce tstruct property tree. values can be true/false. the default is false.

if this property is true then after saving/deleting a record in the primary table,
call function to update treelink.
}

