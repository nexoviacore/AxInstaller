unit uImportDiff;
{Copied from ver 10.6}
{Copied from Axpert9-XE3\Ver 11.0\Asb}
{Copied from Axpert9-XE3\Ver 11.1}
interface

Uses db, classes, forms, sysutils, Extctrls,
dialogs, controls, Variants, XMLDoc, XMLIntf, uAxProvider, uStructDef, uPropsXML,
uXds, UProfitEVAL,ComObj,FileCtrl,Graphics,uDBCall, uGeneralFunctions,System.IOUtils,
uMDMap, uProvideLink, uIViewXML, uViewDef, uImportStructDef, uStoreDependencies,
uStructInTable,Math,DBClient,inifiles,{uUtils,}uAgileCloudObj,uAxfastrun, {$IFDEF ForService}AXMLibrary, {$ENDIF} UIviewTables;

type

pCreatedDetail = ^TCreatedDetail;
TCreatedDetail = Record
  SType : string;
  SName : string;
end;

pDeletedDetail = ^TDeletedDetail;
TDeletedDetail = Record
  SType : string;
  SName : string;
end;

pModifiedDetail = ^TModifiedDetail;
TModifiedDetail = Record
  SType     : string;
  SName     : string;
  SProperty : string;
  OldValue  : string;
  NewValue  : string;
end;

pUnModifiedDetail = ^TUnModifiedDetail;
TUnModifiedDetail = Record
  SType     : string;
  SName     : string;
  SProperty : string;
  SValue  : string;
end;

pStructDiff = ^TStructDiff;
TStructDiff = Record
  Transid   : string;
  SType     : string;
  ErrorMsg  : string;
  LogSQLScript : TStringList;

  CreateFieldSQLScript : TStringList;
  CreateConstraintSQLScript : TStringList;
  DeleteFieldSQLScript : TStringList;
  DeleteConstraintSQLScript : TStringList;
  
  CreatedDetailList : TList;
  DeletedDetailList : TList;
  ModifiedDetailList: TList;
  UnModifiedDetailList: TList;
end;

TOnCreateField = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnDeleteField = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnFieldNameChange = function(nfd, ofd : pFld) : string of object;
TOnSourceKeyChange = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnFieldBasicPropertiesChange = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnSaveValueChange = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnTableNameChange = function(fd : pFld; schemaname, transid : string; PSQLScriptList : TStringList) : string of object;
TOnSchemaNameChange = function(nstruct, ostruct : TStructDef; PSQLScriptList : TStringList) : string of object;

TOnCreateTStruct = function(sdef : TStructDef; PSQLScriptList : TStringList) : string of object;
TOnCreateDC = function(frm : pFrm; schemaname, primarytable, transid : string; PSQLScriptList : TStringList) : string of object;
TOnDeleteDC = function(frm : pFrm; schemaname, primarytable, transid : string; PSQLScriptList : TStringList) : string of object;
TOnAsGridChange = function(frm : pFrm; schemaname, primarytable, transid : string; PSQLScriptList : TStringList) : string of object;
TOnModeOfEntryChange = function(nfd, ofd : pFld; nschemaname, oschemaname, ntransid, otransid : string; PSQLScriptList : TStringList) : string of object;

TOnDeleteDetailRelations = function(strans : string; PSQLScriptList : TStringList):Boolean of Object;
TOnCreateorDeleteAttachTable = function(Attach : Boolean; schemaname, transid : string; PSQLScriptList : TStringList) : Boolean of Object;
TOnCreateorDeleteHistoryTable = function(Track : Boolean; schemaname, transid : string; PSQLScriptList : TStringList) : Boolean of Object;
TOnCreateorDeleteWorkflowTable = function (WFlow : Boolean; schemaname, transid : String; PSQLScriptList : TStringList) : Boolean of object;
TOnCreateSeqInfo = procedure(transid, schemaname : string;txml : IXMLDocument) of Object;

TOnWriteLog = procedure(s:string) of object;

TOnWriteStatus = procedure(s:string) of object;
TOnStepIt = procedure of Object;

TImportDiff = Class
  private
    Axpro : TAxprovider;

    OldDBCall : TDBCall;
    NewDBCall : TDBCall;
    OldStruct : TStructDef;
    NewStruct : TStructDef;
    OldView : TViewDef;
    NewView : TViewDef;
    Ixds : Txds;
    StoreDependencies : TStoreDependencies;
    StructInTable : TStructInTable;

    FileContent : TStringList;
    FXML : IXMLDocument;
    Enode : IXMLNode;
    NNode : IXMLNode;
    Stype : string;
    Transid : string;
    Caption : string;
    DiffDocument : TStringList;

    CreatedDetail : pCreatedDetail;
    DeletedDetail : pDeletedDetail;
    ModifiedDetail : pModifiedDetail;
    UnModifiedDetail : pUnModifiedDetail;

    StructDiff : pStructDiff;
    StructDiffList : TList;

    newtext : string;
    oldtext : string;
    ofldslist : TStringList;
    nfldslist : TStringList;
    omdmapdefs : TList;
    nmdmapdefs : TList;
    ogenmapsdrecs : TList;
    ngenmapsdrecs : TList;
    ocolslist : TStringList;
    ncolslist : TStringList;
    osqlslist : TStringList;
    nsqlslist : TStringList;
    oparamslist : TStringList;
    nparamslist : TStringList;
    nsubtotalslist : TStringList;
    osubtotalslist : TStringList;
    obuttonslist : TStringList;
    nbuttonslist : TStringList;
    nschemaname : string;
    oschemaname : string;
    ntransid : string;
    otransid : string;
    nprimarytable : string;
    oprimarytable : string;

    pinfo : TStringList;
    x1,Cxds:TXDS;
    FCDS,WCDS :TClientDataset;
    errmsg : string;
    selected_struct : boolean;
    IviewTbl   : TIviewTables;


    procedure CreateStructDiff(PXML : IXMLDocument);
    procedure InitTstructDetails(PXML : IXMLDocument);
    procedure InitIViewDetails(PXML : IXMLDocument);

    function TStructDiff(PXML : IXMLDocument) : Boolean;
    function IViewDiff(PXML : IXMLDocument) : Boolean;
    procedure ModifyTStruct(PNStruct, POStruct : TStructDef; PSType, PSName : string);
    procedure ModifyIView(PNView, POView : TViewDef; PSType, PSName : string);

    function StringDiff(PNewString, POldString, PSType, PSName, PSProperty : string) : Boolean;
    function IntegerDiff(PNewNumber, POldNumber : Integer; PSType, PSName, PSProperty : string) : Boolean;
    function BooleanDiff(PNewBool, POldBool : Boolean; PSType, PSName, PSProperty : string) : Boolean;
    function StringListDiff(PNewSList, POldSList : TStringList; PSType, PSName, PSProperty : string) : Boolean;
    function CharacterDiff(PNewChar, POldChar : Char; PSType, PSName, PSProperty : String) : Boolean;
    function XMLNodeDiff(PNewXMLNode, POldXMLNode : IXMLNode; PSType, PSName, PSProperty : string) : Boolean;

    procedure DCDiff(PNStruct, POStruct : TStructDef);
    procedure ModifyDC(PNFrame, POFrame : pFrm; PSType, PSName : string);
    procedure FieldDiff(PNStruct, POStruct : TStructDef);
    procedure ModifyField(PNField, POField : pFld; PSType, PSName : string);
    procedure FillGridDiff(PNStruct, POStruct : TStructDef);
    procedure ModifyFillGrid(PNFillGrid, POFillGrid : pFg; PSType, PSName : string);
    procedure MDMapDiff(PNMDMapDefs, POMDMapDefs : TList);
    procedure ModifyMDMap(PNDef, PODef : pDef; PSType, PSName : string);
    procedure GenMapDiff(PNGenMapSDRecs, POGenMapSDRecs : TList);
    procedure ModifyGenMap(PNSDRec, POSDRec : pStoreDataRec; PSType, PSName : String);

    procedure ColDataDiff(PNView, POView : TViewDef);
    procedure ModifyColData(PNColData, POColData : pColData; PSType, PSName : string);
    procedure SQLDiff(PNView, POView : TViewDef);
    procedure ModifySQL(PNSQL, POSQL : pSQL; PSType, PSName : string);
    procedure ParamDiff(PNView, POView : TViewDef);
    procedure ModifyParam(PNParam, POParam : pParam; PSType, PSName : string);
    procedure SubTotalDiff(PNView, POView : TViewDef);
    procedure ModifySubTotal(PNSubTotal, POSubTotal : pSubTotal; PSType, PSName : string);
    procedure ButtonDiff(PNView, POView : TViewDef);
    procedure ModifyButton(PNButton, POButton : pButton; PSType, PSName : string);
    procedure DecodeAndExecuteSQLScripts(PTransid, PStype : string);
    procedure DecodeAndExecute(PScriptType, PScriptParamstr : string);
    procedure AxpCreateorEditField(PScriptType, PScriptParamstr : string);
    procedure AxpDeleteFields(PScriptParamstr : string);
    procedure AxpAddConstraint(PScriptParamstr : string);
    procedure AxpCreateTable(PScriptParamstr : string);
    procedure AxpDropTable(PScriptParamstr : string);
    procedure AxpExecSQL(PScriptParamstr : string);

    procedure ImportListView(PFileName : string);
    function GetPrintDocCaption(PFileName : string) : string;
    function GetPrintDocTransid(PFileName : string) : string;
    procedure ImportNonPDFPrintDocs(PFileName, PTransid : string);
    procedure ImportPDFPrintDocs(PFileName, PTransid : string);
    procedure ImportPage(PFileName : string);
    
   // procedure AssignOrderNo(ptransid,OldParent,ptype:Ansistring;newlvlno,Pendnode:integer);
    procedure ClearLists;
    procedure DestroyTStruct;
    procedure DestroyIView;
    procedure CreateNewPageOrder;
    procedure OrderWithOutParent(page_name:string);
    procedure OrderWithParent(parent_name,page_name: string);
    function GetEndNodeOrdno(MaxOrdno: integer):integer;
    function GetPageflds(Sql: string;fld:string): string;
    procedure SetOrderNo(Sql:string);
    procedure SetLevelNo(PageName:string);
 //   procedure ChangeOrderNo(parent,PageName:Ansistring;Oldorderno,OldLevelno,newlvlno,Pendnode:integer);
    procedure WritetoLog(s: string);
    procedure InserOrderNo(Pagename,ParentName :string);
    procedure ImportFastReport(PFileName, PTransid: string);
    function GetFastReportOutput(PFileName: string): string;
    procedure ImportCDS(Filename, Transid: string);
 //   procedure ImportCDSDefaultTable;
    function GetFieldType(Typestr: string): string;
    function GetCdsFieldxml: IxmlNode;
    function GetFieldWidth(Fieldname,Ftype:string): string;
    procedure CreateTable(Tablenm: string);
    procedure InsertRowsFromCDS(Tablenm,Whr,Transid: string);
    function FrameCondition(Tablenm: string): string;
    procedure DeleteRows(Tablenm, Whr: string);
    procedure UpdateAxp_VersionChanges;
    Procedure SubmitAxp_VersionChanges(Tablenm:string;Strlist:TStringlist);
    procedure UpdateAxp_Versions;
    procedure UpdateAxp_VersionChangeDetails;
    function UpgradeConstraint(Tablenm: string): boolean;
    function ConditionForCLOB(Tablenm: string): string;
    function GetParent(pagename, parentname: string): string;
    procedure VerifyFields(Tablenm:string;Fldlist: TStringList);
    function GetConstraintString(Tablenm: string): string;
    function ConvertToDBDateString(dbtype,dstring: string): string;
    procedure UpdateDateFields(iXML :IXmlDocument);
    procedure WriteToTraceFile(fd:pfld;OWidth,est :string);
    procedure WriteFRXToDB(whrstr,FastReportCaption,PFileName: string);
    procedure UpdatePageDetails(PXML: IXMLDocument; PageName: String);
    function CheckInPageDetails(pagename, pagetype: string): Boolean;


  public
   // Transid : string;
    FImpDir,servicename : string;
    IsAxpDefStructure : Boolean;
    chktstruct : Boolean;
    FromService : Boolean;
    IsTransidSelectedfromapm : Boolean;

    FFilestoImport  : TStringList;
    SelectedTStruct : TStringList;
    SelectedIview   : TStringList;
    SelectedPage    : TStringList;
    CreateLog : Boolean;
    StepWhen : Integer;
    ErrorMessage : string;

    ComparedTStructs : TStringList;
    ComparedIViews   : TStringList;
    ImportedTStructs : TStringList;
    ImportedIViews   : TStringList;
    ImportedPages    : TStringList;

    OnCreateField : TOnCreateField;
    OnDeleteField : TOnDeleteField;
    OnFieldNameChange : TOnFieldNameChange;
    OnSourceKeyChange : TOnSourceKeyChange;
    OnFieldBasicPropertiesChange : TOnFieldBasicPropertiesChange;
    OnSaveValueChange : TOnSaveValueChange;
    OnTableNameChange : TOnTableNameChange;
    OnSchemaNameChange : TOnSchemaNameChange;

    OnCreateTStruct : TOnCreateTStruct;
    OnCreateDC : TOnCreateDC;
    OnDeleteDC : TOnDeleteDC;
    OnAsGridChange : TOnAsGridChange;
    OnModeOfEntryChange : TOnModeOfEntryChange;

    OnDeleteDetailRelations : TOnDeleteDetailRelations;
    OnCreateorDeleteAttachTable : TOnCreateorDeleteAttachTable;
    OnCreateorDeleteHistoryTable : TOnCreateorDeleteHistoryTable;
    OnCreateorDeleteWorkflowTable : TOnCreateorDeleteWorkflowTable;
    OnCreateSeqInfo : TOnCreateSeqInfo;

    WriteLog : TOnWriteLog;

    WriteStatus : TOnWriteStatus;
    StepIt : TOnStepIt;
    Verno,domain,Publishedby,publishedfrom,comments :string;
    AgileCloudObj:TAgileCloudObj;
    Display_Error_Message,CompareOnly:boolean;
    inode : IXMLNode;

    constructor Create(PAxpro : TAxProvider; PFromService : Boolean);
    destructor Destroy; override;
    function GetStructDiffList : TList;
    procedure DoImportDiff;
    procedure WriteDiffinExcelFile(filename : string);
    procedure ImportStructure(FormName: String; SXML: IXMLDocument; fextn:String='trn');
    procedure ImportAutoPage(PageName: String; PXML: IXMLDocument);
    procedure ImportStructXMLandCreateTransactionTables(sTransid: String;
      sXML: IXMLDocument);
    procedure StructureDiff(PFileName : string);

end;

{ TImportDiff }

implementation

constructor TImportDiff.Create(PAxpro : TAxProvider; PFromService : Boolean);
begin
  Axpro := PAxpro;
  FromService := PFromService;
  StepWhen := 1;
  ErrorMessage := '';
  StoreDependencies := TStoreDependencies.Create(Axpro, FromService);
  FileContent := TStringList.Create;
  DiffDocument := TStringList.Create;
  StructDiffList := TList.Create;
  ComparedTStructs := TStringList.Create;
  ComparedIViews   := TStringList.Create;
  ImportedTStructs := TStringList.Create;
  ImportedIViews   := TStringList.Create;
  ImportedPages    := TStringList.Create;
  ofldslist := TStringList.Create;
  nfldslist := TStringList.Create;
  ocolslist := TStringList.Create;
  ncolslist := TStringList.Create;
  osqlslist := TStringList.Create;
  nsqlslist := TStringList.Create;
  oparamslist := TStringList.Create;
  nparamslist := TStringList.Create;
  nsubtotalslist := TStringList.Create;
  osubtotalslist := TStringList.Create;
  obuttonslist := TStringList.Create;
  nbuttonslist := TStringList.Create;
  x1 := Axpro.dbm.GetXDS(nil);
  x1.buffered:=true;
  Cxds:=Axpro.dbm.GetXDS(nil);
  FCDS :=TClientDataset.Create(nil);
  WCDS :=TClientDataset.Create(nil);
  Display_Error_Message := false;
  errmsg := '';
  CompareOnly := not(FromService);
  chktstruct := False;
  IsAxpDefStructure := False;
  IviewTbl := TIViewTables.Create(Axpro);
end;

destructor TImportDiff.Destroy;
begin
  StoreDependencies.Destroy;
  StoreDependencies := nil;
  FileContent.Free;
  FileContent := nil;
  DiffDocument.Free;
  DiffDocument := nil;
  ComparedTStructs.Free;
  ComparedTStructs := nil;
  ComparedIViews.Free;
  ComparedIViews := nil;
  ImportedTStructs.Free;
  ImportedTStructs := nil;
  ImportedIViews.Free;
  ImportedIViews := nil;
  ImportedPages.Free;
  ImportedPages := nil;
  ClearLists;
  ofldslist.Free;
  ofldslist := nil;
  nfldslist.Free;
  nfldslist := nil;
  ocolslist.Free;
  ocolslist := nil;
  ncolslist.Free;
  ncolslist := nil;
  osqlslist.Free;
  osqlslist := nil;
  nsqlslist.Free;
  nsqlslist := nil;
  oparamslist.Free;
  oparamslist := nil;
  nparamslist.Free;
  nparamslist := nil;
  nsubtotalslist.Free;
  nsubtotalslist := nil;
  osubtotalslist.Free;
  osubtotalslist := nil;
  obuttonslist.Free;
  obuttonslist := nil;
  nbuttonslist.Free;
  nbuttonslist := nil;
  FXML := nil;
  Enode := nil;
  NNode := nil;
  x1.destroy;
  x1:=nil;
  if Assigned(cxds) then begin
    Cxds.close;
    freeandnil(cxds);
  end;
  if Assigned(FCDS) then FreeAndnil(FCDS);
  if Assigned(WCDS) then FreeAndnil(WCDS);
  if Assigned(IviewTbl) then begin
    IviewTbl.Destroy;
    IviewTbl := nil;
  end;
  inherited;
end;

function TImportDiff.GetStructDiffList : TList;
begin
  Result := StructDiffList;
end;

procedure TImportDiff.DoImportDiff;
var
  i : Integer;
  Liststr:string;
begin
  ErrorMessage := '';
  for i := 0 to FFilestoImport.Count - 1 do
  begin
    try
      errmsg := '';
      Liststr:=IntTostr(i+1)+'. '+ExtractFileName(FFilestoImport.Strings[i]);
      if FromService then
        StructureDiff(FImpDir + FFilestoImport.Strings[i])
      else
        StructureDiff(FFilestoImport.Strings[i]);
      if selected_struct = false then continue;
      WriteToLog(FFilestoImport.Strings[i]+ ' : Imported');
      if errmsg <> '' then
      begin
        WriteToLog(errmsg);
        WriteToLog('Structure '+ Caption +' ['+transid+'] imported with above mentioned errors, Needs to be taken care manually in Axpert build mode.'+#$D#$A);
      end;
      if Assigned(AgileCloudObj)then AgileCloudObj.AddtoSuccessList(Liststr);
    except on e:Exception do
     begin
      if Assigned(AgileCloudObj)then AgileCloudObj.AddtoFailedList(Liststr);
      WriteToLog(FFilestoImport.Strings[i]+ 'Import Failed, Reason : ' + e.message);
      axpro.dbm.gf.DoDebug.Msg('Error: '+e.message);
      continue;
     end;
    end;
  end;
  if FromService or (not CompareOnly) then
  begin
    if Assigned(pinfo) then CreateNewPageOrder;       // by ar .........
  end;
  if (FromService) and  (Not IsAxpDefStructure) then
  begin
    UpdateAxp_Versions;
    UpdateAxp_VersionChanges;
    UpdateAxp_VersionChangeDetails;
   // WriteDiffinExcelFile(Axpro.dbm.gf.startpath+'comparestructures.xls');
    ComparedTStructs.Clear;
    ComparedIViews.Clear;
    ImportedTStructs.Clear;
    ImportedIViews.Clear;
    ImportedPages.Clear;
  end;
end;

procedure TImportDiff.StructureDiff(PFileName : string);
var
  CanExit : Boolean;
  AlreadyCompared : Boolean;
  AlreadyImported : Boolean;
  IsTransidSelected : Boolean;
  LVFName, fpath : string;
  PTransid : string;
  sCurTransId:string;
begin
  selected_struct := false;
  if (lowercase(ExtractFileExt(PFileName)) = '.trn') and (not chktstruct) then
  begin
    ErrorMessage := '';
    {$IFNDEF ForService}
      FileContent.Clear;
      FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
      FXML := LoadXMLData(FileContent.Text);
    {$ENDIF}
    InitTstructDetails(FXML);
    if FromService then
      IsTransidSelected := True
    else
      IsTransidSelected := SelectedTStruct.IndexOf(lowercase(Transid)) <> -1;
    if IsTransidSelectedfromapm then
      IsTransidSelected := True;
    if not IsTransidSelected then exit;
    if not FromService then begin
      if assigned(StepIt) then
         StepIt;
    end;
    AlreadyCompared := ComparedTStructs.IndexOf(lowercase(Transid)) <> -1;
    AlreadyImported := ImportedTStructs.IndexOf(lowercase(Transid)) <> -1;
    if AlreadyImported then exit;
    if not AlreadyCompared then
    begin
      if not FromService then begin
        if assigned(WriteStatus) then
          WriteStatus('Comparing TStruct - '+transid+' ('+caption+')');
      end;
      CreateStructDiff(FXML);
      OnDeleteDetailRelations(Transid, pStructDiff(StructDiff).LogSQLScript);
      CanExit := TStructDiff(FXML);
      if not CanExit then
      begin
        nschemaname := NewStruct.SchemaName;
        oschemaname := OldStruct.SchemaName;
        ntransid := NewStruct.Transid;
        otransid := OldStruct.Transid;
        nprimarytable := NewStruct.PrimaryTable;
        oprimarytable := OldStruct.PrimaryTable;
        DCDiff(NewStruct,OldStruct);
        FieldDiff(NewStruct,OldStruct);
        FillGridDiff(NewStruct,OldStruct);
        MDMapDiff(NMDMapDefs, OMDMapDefs);
        GenMapDiff(NGenMapSDRecs, OGenMapSDRecs);
        if Axpro.dbm.gf.IsService then
        begin
          if (servicename = 'CreateStruct') then
            OnCreateTStruct(NewStruct, pStructDiff(StructDiff).LogSQLScript);
        end;
        DestroyTStruct;
      end;
    end;
    ErrorMessage := StructDiff.ErrorMsg;
    if (not CanExit) or (ErrorMessage='') then
    begin
      if FromService or (not CompareOnly) then
      begin
        if FromService or AlreadyCompared then
        begin
          DecodeAndExecuteSQLScripts(Transid, 'TStruct');
        end;
        if not FromService then begin
          if assigned(WriteStatus) then
            WriteStatus('Importing TStruct - '+transid+' ('+caption+')');
        end;
        StoreDependencies.SXML := FXML;
        StoreDependencies.transid := Transid;
        StoreDependencies.StoreDependencies;
        StoreDependencies.ClearValues;
        WriteToLog('');
        WriteToLog('Importing Transaction from : '+PFileName);
        WriteToLog('Transid : '+transid);
        WriteToLog('Caption : '+caption);
        UpDateDateFields(FXML);
        {$IFNDEF ForService}
        Axpro.SetStructure('tstructs', Transid, Caption, FXML,True);
        {$ELSE}
        Axpro.SetStructure('tstructs', Transid, Caption, FXML,False);
        {$ENDIF}
        if nschemaname <> '' then
          OnCreateSeqInfo(Transid, nschemaname+'.', FXML)
        else
          OnCreateSeqInfo(Transid, nschemaname, FXML);
        StructInTable := TStructInTable.create(Axpro);
        StructInTable.Structwise(Transid);
        StructInTable.Destroy;
        StructInTable := nil;
        if FromService then
        begin
          if fileexists(PFileName) then
            DeleteFile(PFileName);
          if (Not IsAxpDefStructure) then
          begin
            if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
              DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
          end;
        end;
        if FileExists(copy(PFileName,1,length(PFileName)-4)+'.lvw') then begin
          lvfname := copy(PFileName,1,length(PFileName)-4)+'.lvw';
          ImportListView(lvfname);
        end;
        ImportedTStructs.Add(lowercase(Transid));
      end;
      ComparedTStructs.Add(lowercase(Transid));
    end;
    selected_struct := true;
    fpath := ExtractFilePath(pFileName);
    PFileName := fpath+'AX_LAYOUTDESIGN_SAVED'+'_'+Transid+'.tab';
    if FileExists(PFileName) then
    begin

      ImportCDS(PFileName,transid);

    end;
    PFileName := fpath+'AX_LAYOUTDESIGN'+'_'+Transid+'.tab';
    if FileExists(PFileName) then
    begin

      ImportCDS(PFileName,transid);

    end;
  end
  else if lowercase(ExtractFileExt(PFileName)) = '.ivw' then
  begin
    {$IFNDEF ForService}
      FileContent.Clear;
      FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
      FXML := LoadXMLData(FileContent.Text);
    {$ENDIF}
    InitIViewDetails(FXML);
    if FromService then
      IsTransidSelected := True
    else
      IsTransidSelected := SelectedIview.IndexOf(lowercase(Transid)) <> -1;
    if IsTransidSelectedfromapm then
      IsTransidSelected := True;
   IsTransidSelected := true;
    if not IsTransidSelected then exit;
    if not FromService then begin
       if assigned(StepIt) then
         StepIt;
    end;
    AlreadyCompared := ComparedIViews.IndexOf(lowercase(Transid)) <> -1;
    AlreadyImported := ImportedIViews.IndexOf(lowercase(Transid)) <> -1;
    if AlreadyImported then exit;
    if not AlreadyCompared then
    begin
      if not FromService then begin
        if assigned(WriteStatus) then
           WriteStatus('Comparing IView - '+transid+' ('+caption+')');
      end;
      CreateStructDiff(FXML);
      CanExit := IViewDiff(FXML);
      ComparedIViews.Add(lowercase(Transid));
      if not CanExit then
      begin
        ColDataDiff(NewView, OldView);
        SQLDiff(NewView, OldView);
        ParamDiff(NewView, OldView);
        SubTotalDiff(NewView, OldView);
        ButtonDiff(NewView, OldView);
        DestroyIView;
      end;
    end;
    if FromService or (not CompareOnly) then
    begin
      if not FromService then begin
        if assigned(WriteStatus) then
           WriteStatus('Importing IView - '+transid+' ('+caption+')');
      end;
      WriteToLog('');
      WriteToLog('Importing IView from : '+PFileName);
      WriteToLog('Transid : '+transid);
      WriteToLog('Caption : '+caption);
      UpDateDateFields(FXML);
      Axpro.SetStructure('iviews', Transid, Caption, FXML,True);
      IviewTbl.enode := FXML.DocumentElement;
      IviewTbl.InsertIntoIViewTables;
      if FromService then
      begin
        if fileexists(PFileName) then
          DeleteFile(PFileName);
        if (Not IsAxpDefStructure) then
        begin
          if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
            DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
        end;
      end;
      ImportedIViews.Add(lowercase(Transid));
    end;
    selected_struct := true;
  end
  else if (lowercase(ExtractFileExt(PFileName)) = '.prt') or (lowercase(ExtractFileExt(PFileName)) = '.pdo') or (lowercase(ExtractFileExt(PFileName)) = '.pwd') then
  begin
    ptransid := GetPrintDocTransid(PFileName);
    if FromService then
      ImportNonPDFPrintDocs(PFileName, PTransid)
    else
    begin
      if SelectedTStruct.IndexOf(lowercase(ptransid)) <> -1 then
      begin
        if not CompareOnly then
        begin
           ImportNonPDFPrintDocs(PFileName, PTransid);
           selected_struct := true;
         end;
      end;
    end;
  end
  else if (lowercase(ExtractFileExt(PFileName)) = '.pdd') then
  begin
    ptransid := GetPrintDocTransid(PFileName);
    if FromService then
      ImportPDFPrintDocs(PFileName, PTransid)
    else
    begin
      if SelectedTStruct.IndexOf(lowercase(ptransid)) <> -1 then
      begin
        if not CompareOnly then
         begin
           ImportPDFPrintDocs(PFileName, PTransid);
           selected_struct := true;
         end;
      end;
    end;
  end
  else if (lowercase(ExtractFileExt(PFileName)) = '.fr3') then
  begin
    ptransid := GetPrintDocTransid(PFileName);
    SelectedTStruct.Add(ptransid);
      if SelectedTStruct.IndexOf(lowercase(ptransid)) <> -1 then
      begin
        if not CompareOnly then
         begin
           ImportFastReport(PFileName, PTransid);
           selected_struct := true;
         end;
      end;
      write('   - ');
//      Console_write( ExtractFileName(PFileName), 10);
      write(' Fast report imported Successfully...!');
//      AxStructures.Add(extractfilename(PFileName));
      writeln;
  end
  else if (lowercase(ExtractFileExt(PFileName)) = '.pge') then
  begin
    if FromService or (not CompareOnly) then
    begin
      ImportPage(PFileName);
          write('   - ');
//      Console_write( ExtractFileName(PFileName), 10);
      write(' Page imported Successfully...!');
//      AxStructures.Add(extractfilename(PFileName));
      writeln;
    end;
  end
  else if (lowercase(ExtractFileExt(PFileName)) = '.app') then
  begin
    if lowercase(axpro.dbm.gf.username)<>'admin' then
      exit;
    if FromService or (not CompareOnly) then
    begin
      FileContent.Clear;
      FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
      FXML := LoadXMLData(FileContent.Text);
      UpDateDateFields(FXML);
      axpro.SetStructure('axprops','app','',FXML,True);
      if FromService then
      begin
        if fileexists(PFileName) then
          DeleteFile(PFileName);
        if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
          DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
      end;
    end;
    selected_struct := true;
  end
//  else if (lowercase(ExtractFileExt(PFileName)) = '.tab') and (pos('ax_layoutdesign',lowercase(PFileName)) = 0) then
 else if lowercase(ExtractFileExt(PFileName)) = '.tab' then
 begin
// try
   servicename:='WriteTStructDef';
   if (lowercase(ExtractFileExt(PFileName)) = '.tab') and ((servicename = 'WriteTStructDef') or (pos('ax_layoutdesign',lowercase(PFileName)) = 0)) then
   begin
     sCurTransId := extractFileName(PFileName);
     sCurTransId:=ChangeFileExt(sCurTransId,'');
     if pos('ax_layoutdesign_saved',lowercase(sCurTransId))>0 then
     begin
     sCurTransId:=StringReplace(lowercase(sCurTransId),'ax_layoutdesign_saved_', '', [rfReplaceAll]);
     //ImportCDS(PFileName,''); sCurTransId
     ImportCDS(PFileName,sCurTransId);
     end
     else if pos('ax_layoutdesign',lowercase(sCurTransId))>0 then
     begin
     sCurTransId:=StringReplace(lowercase(sCurTransId),'ax_layoutdesign_', '', [rfReplaceAll]);
     //ImportCDS(PFileName,''); sCurTransId
     //try
     ImportCDS(PFileName,sCurTransId);
//     except
//      on E: Exception do
//      begin
//
//      end;
//     end;
     end
     else
     ImportCDS(PFileName,'');
    selected_struct := true;
   end;
// Except
// on E:Exception do
// begin
//   if(E.Message).ansi.string
//
// end;

 end;
// end

// else if (lowercase(ExtractFileExt(PFileName)) = '.tab') and ((servicename = 'WriteTStructDef') or (pos('ax_layoutdesign',lowercase(PFileName)) = 0)) then
//  begin
//    ImportCDS(PFileName,'');
//    selected_struct := true;
//  end;
end;

procedure TImportDiff.ImportCDS(Filename, Transid:string);
var
  Tablenm,fname,Errorstr,Errorstr1,Condition,DeleteCondition,Blobno,Sql,Schemafile,dir:string;
  i,j,FailedRec, cpos:integer;
  FieldList :TStringList;
  Tablefound:boolean;
  ConstStr : String;
begin

  fname := ExtractFileName(Filename);
  dir :=ExtractFileDir(Filename);
  Tablenm :=Lowercase(Copy(fname,1,Pos('.',fname)-1));
  Schemafile :=dir+'\'+Tablenm+'.fld';
  if Transid <> '' then
  begin
    cpos := pos('_'+lowercase(transid),lowercase(Tablenm));
    Tablenm := Copy(Tablenm,1,cpos-1);
  end;
  if Tablenm=''  then exit;

  try
    Errorstr :='';
    Fieldlist :=TStringlist.Create;
    Fcds.Close;
    if FileExists(Filename) then
    begin
      Fcds.LoadFromFile(Filename);
      Fcds.Open;
    end;
    Wcds.Close;
    if FileExists(Schemafile) then
    begin
      Wcds.LoadFromFile(Schemafile);
      Wcds.Open;
    end;
    if (not FCDS.active) or  (FCDS.RecordCount=0) then
    begin
    axpro.dbm.gf.DoDebug.Msg('No records found in '+Filename);
    exit;
    end;
     //raise exception.Create('No records found in '+Filename);
    if (not Wcds.active) or  (Wcds.RecordCount=0) then
    begin
       axpro.dbm.gf.DoDebug.Msg('No records found in '+Filename);
      exit;
    end;
     //raise exception.Create('No records found in '+Schemafile);
    Tablefound :=false;
    Tablefound :=UpgradeConstraint(Tablenm);
    if not Tablefound then
    begin
      try
        Errorstr1 :='';
        x1.close;
        x1.CDS.CommandText :='Select * from '+Tablenm+' where 1=2 ';
        x1.open;
      Except on e:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then
      begin
        Tablefound :=false;
        CreateTable(Tablenm);
      end
      else
      begin
        FieldList.Clear;
        for I := 0 to x1.CDS.Fields.Count-1 do
          FieldList.Add(x1.CDS.Fields[i].FieldName);
        x1.close;
        VerifyFields(Tablenm,FieldList);
      end;
    end;

    if Tablenm='axpages'  then
      DeleteRows(Tablenm,'');               /// for Publish menu's
    Fcds.First;
    FailedRec :=0;
    Condition :='';
    if Transid <> '' then
      Condition := 'transid = '+lowercase(QuotedStr((transid)))
    else
      Condition :=FrameCondition(Tablenm);
    DeleteCondition :='';
    DeleteCondition :=Trim(ConditionForCLOB(Tablenm));
    if Condition <>'' then
     begin
       ConstStr := '';
      while ((not Fcds.Eof) and (Condition<>'')) do
      begin
        try
         Errorstr1 :='';
         if ((DeleteCondition<>'') and (Tablenm<>'axpages')) then
         begin
           Blobno :=Trim(Fcds.FieldByName('blobno').AsString);
           if ((Blobno='') or (Blobno='1')) then
           begin
             DeleteRows(Tablenm,DeleteCondition);
           end;
         end;
         InsertRowsFromCDS(Tablenm,Condition,Transid);
         Fcds.Next;
         Condition :=FrameCondition(Tablenm);
         DeleteCondition :=Trim(ConditionForCLOB(Tablenm));
        Except on e:Exception do
         Errorstr1 :=E.Message;
        end;
        if Errorstr1<>'' then
        begin
          if DeleteCondition<>'' then
            Axpro.dbm.RollBack(axpro.dbm.gf.ConnectionName);
          Inc(FailedRec);
          Fcds.Next;
          DeleteCondition :=Trim(ConditionForCLOB(Tablenm));
          Condition :=FrameCondition(Tablenm);
        end;
      end;
    end;
    Axpro.dbm.gf.DoDebug.Msg('***********************************');
    Axpro.dbm.gf.DoDebug.Msg('Tablename :'+Tablenm);
    Axpro.dbm.gf.DoDebug.Msg('Total no.records :'+Inttostr(Fcds.RecordCount));
    Axpro.dbm.gf.DoDebug.Msg('No.records failed to import :'+Inttostr(FailedRec));
    Axpro.dbm.gf.DoDebug.Msg('***********************************');
    x1.close;
    fcds.Close;
    Wcds.Close;
    if Assigned(FieldList) then Freeandnil(FieldList);
  Except on e:Exception do
    Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    x1.close;
    fcds.Close;
    Wcds.Close;
    if Assigned(FieldList) then Freeandnil(FieldList);
    Axpro.dbm.gf.DoDebug.Msg(Errorstr);
    raise Exception.Create(Errorstr);
  end;
end;

Procedure TImportDiff.VerifyFields(Tablenm:string;Fldlist:TStringList);
var I,j,FieldSize,Fielddecimal:Integer;
 Fieldname,FieldType,Errorstr,Flds:string;
 Fieldfound :Boolean;
 FldNotfound :TStringList;
begin
  FldNotfound :=TStringlist.Create;
  for i :=0 to fcds.Fields.Count -1 do begin
    Fieldname :=lowercase(fcds.Fields[i].FieldName);                     // create field if the field not exist in the fieldlist
    Fieldfound :=false;
    try
       Errorstr :='';
      for j := 0 to Fldlist.Count-1 do begin
        if Fieldname=Lowercase(Fldlist.Strings[j]) then begin
           Fieldfound :=true;
           break;
        end;
      end;
      if not Fieldfound then begin
        FieldType :=GetFieldType(Lowercase(Axpro.dbm.gf.GetDataType(Fcds.Fields[i].DataType)));
        Fielddecimal :=0;
        if ((FieldType='t') or (FieldType='d'))then
          FieldSize :=1
        else
          FieldSize :=StrtoInt(GetFieldWidth(Fieldname,FieldType));
        if FieldSize >0 then
          Axpro.CreateField(Tablenm,Fieldname,FieldType,FieldSize,Fielddecimal)
        else
          raise Exception.Create('Datawidth '+QuotedStr(Inttostr(FieldSize))+' is not valid');
      end;
    Except on e:Exception do
      Errorstr :=e.Message;
    end;
    if Errorstr<>'' then begin
      FldNotfound.Add(Fieldname);
      Axpro.dbm.gf.DoDebug.Msg('Failed to create field '+Fieldname+' :'+Errorstr);
      Errorstr:='';
      continue;
    end;
  end;
  if FldNotfound.Count>0 then begin
    Flds :=FldNotfound.CommaText;
    if Assigned(FldNotfound) then Freeandnil(FldNotfound);
    raise Exception.Create('No records imported due to the following fields were not Created in '+Tablenm+#13#10+'Fields : '+Flds);
  end;
end;

Procedure TImportDiff.InsertRowsFromCDS(Tablenm,Whr,Transid:string);
var Errstr,Fieldnm,Fieldtype,FieldVal:string;
  I:Integer;
  ClobfldList:TStringlist;
begin
   try
    ClobfldList :=TStringlist.Create;
    ClobfldList.Clear;
    Cxds.close;
    for I := 0 to Fcds.Fields.Count-1 do
    begin
      Fieldnm :=Fcds.Fields[i].FieldName;
      if (Transid <> '') and (lowercase(Fieldnm) = 'design_id') then Continue;
      Fieldtype :=GetFieldType(Lowercase(Axpro.dbm.gf.GetDataType(Fcds.Fields[i].DataType)));
      if Fieldtype <>'t' then
      begin
        FieldVal :=Fcds.FieldByName(Fieldnm).AsString;
        if Lowercase(Fieldnm)='blobno' then
        begin
          if FieldVal='' then
            FieldVal :='1';
        end;
        Cxds.Submit(Fieldnm,FieldVal,Fieldtype);
      end
      else
        ClobfldList.Add(Fieldnm);
    end;
    Cxds.AddOrEdit(Tablenm,Whr);
    if ClobfldList.Count>0 then
    begin
      Fieldnm :='';
      FieldVal :='';
      for I := 0 to ClobfldList.Count-1 do
      begin
       Fieldnm := ClobfldList.Strings[i];
       FieldVal:= Fcds.FieldByName(Fieldnm).AsString;
       if Transid = '' then
         whr :=ConditionForCLOB(Tablenm);
       Axpro.dbm.WriteCLOB(Fieldnm,Tablenm,whr,FieldVal);
      end;
    end;
    if Assigned(ClobfldList) then freeandnil(ClobfldList);

  Except on e:Exception do
    Errstr:=e.Message;
  end;
  if Errstr<>'' then begin
    Cxds.close;
    if Assigned(ClobfldList) then freeandnil(ClobfldList);
    raise Exception.Create(Errstr);
  end;
end;

Procedure TImportDiff.DeleteRows(Tablenm,Whr:string);
var Errstr,Sql:string;
begin
  try
    Errstr :='';
    if Whr<>'' then
      Sql :=' delete from '+Tablenm+' where '+Whr
    else
      Sql :=' delete from '+Tablenm;
    x1.close;
    x1.CDS.CommandText :=Sql;
    x1.execsql;
    x1.close;
  Except on e:Exception do
    Errstr:=e.Message;
  end;
  if Errstr<>'' then begin
    x1.close;
    raise Exception.Create(Errstr);
  end;
end;

Procedure TImportDiff.CreateTable(Tablenm :string);
var I,Fielddecimal,FieldSize:Integer;
  Fieldname,FieldType,Fieldstr,Constr:string;
begin
   Fieldstr :='';
   for I :=0 to fcds.Fields.Count -1 do begin
    Fieldname :=lowercase(fcds.Fields[i].FieldName);                     // create field if the field not exist in the fieldlist
    FieldType :=GetFieldType(Lowercase(Axpro.dbm.gf.GetDataType(Fcds.Fields[i].DataType)));
    Fielddecimal :=0;
    if ((FieldType='t') or (FieldType='d')) then
     FieldSize :=1
    else
     FieldSize :=StrtoInt(GetFieldWidth(Fieldname,FieldType));
    if ((Fieldname<>'') and (FieldType<>'') and (FieldSize>0)) then begin
       if Fieldstr ='' then
          Fieldstr := Axpro.GetJoinStr(Fieldname,FieldType,FieldSize,Fielddecimal)
       else
          Fieldstr :=Fieldstr +','+Axpro.GetJoinStr(Fieldname,FieldType,FieldSize,Fielddecimal);
    end;
   end;
   if Fieldstr <>'' then begin
     Constr :=GetConstraintString(Tablenm);
     if Constr<>'' then Fieldstr :=Fieldstr+','+Constr;
     Axpro.CreateTable(Tablenm,Fieldstr);
   end;
end;

function TImportDiff.GetConstraintString(Tablenm:string):string;
var constr:string;
begin
  result :='';
  if Tablenm='axusers' then
    constr :=' primary key (username) '
  else if Tablenm='axuseraccess' then
    Constr :=' primary key (rname,sname,stype) '
  else if Tablenm='axusergroups' then
    Constr :=' primary key (groupname) '
  else if Tablenm='axworkflow' then
    Constr :=' primary key(name) '
  else if Tablenm='axattachworkflow' then
    Constr :=' CONSTRAINT pk__axattach_wkidtransid primary key(wkid,transid) '
  else if Tablenm='axpages' then
    Constr :=' primary key (name, blobno) '
  else if Tablenm='axprops' then
    Constr :=' primary key (name, blobno) ';

  if Constr<>'' then
     result :=constr;
end;

Function TImportDiff.FrameCondition(Tablenm:string):string;
var whr,CondStr :string;
begin
   result :='';
   Whr :='';

    if Tablenm = 'axuseraccess' then
      Whr :=' 1=2 '
    else if Tablenm ='axusers' then
      Whr :=Axpro.dbm.gf.sqllower+'(username) = '+Lowercase(Quotedstr(Fcds.FieldByName('username').AsString))
    else if Tablenm='axusergroups' then
      Whr :=Axpro.dbm.gf.sqllower+'(groupname) = '+Lowercase(Quotedstr(Fcds.FieldByName('groupname').AsString))
    else if Tablenm='axworkflow' then
      Whr :=' 1=2 '
    else if Tablenm='axattachworkflow' then
      Whr :=' 1=2 '
    else if ((Tablenm='axpages') or (Tablenm='axprops')) then
      Whr :=' 1=2 '
    else if Tablenm='axuserlevelgroups' then
      whr :=Axpro.dbm.gf.sqllower+'(username) = '+Lowercase(Quotedstr(Fcds.FieldByName('username').AsString))
            +' and '+Axpro.dbm.gf.sqllower+'(usergroup) = '+Lowercase(Quotedstr(Fcds.FieldByName('usergroup').AsString));
   if Whr <>'' then
    Result :=Whr;
end;

Function TImportDiff.ConditionForCLOB(Tablenm:string):string;
var whr,CondStr :string;
begin
   result :='';
   Whr :='';

    if Tablenm = 'axuseraccess' then begin
      Whr :=Axpro.dbm.gf.sqllower+'(rname) = '+Lowercase(Quotedstr(Fcds.FieldByName('rname').AsString))+' and '+Axpro.dbm.gf.sqllower+'(sname) = '+lowercase(Quotedstr(Fcds.FieldByName('sname').AsString))
            +' and '+Axpro.dbm.gf.sqllower+'(stype) = '+lowercase(Quotedstr(Fcds.FieldByName('stype').AsString))
    end
    else if Tablenm='axworkflow' then
      Whr :=Axpro.dbm.gf.sqllower+'(name) = '+Lowercase(Quotedstr(Fcds.FieldByName('name').AsString))
    else if Tablenm='axattachworkflow' then
      Whr :=Axpro.dbm.gf.sqllower+'(wkid) = '+Lowercase(Quotedstr(Fcds.FieldByName('wkid').AsString))+' and '+Axpro.dbm.gf.sqllower+'(transid) = '+Lowercase(Quotedstr(Fcds.FieldByName('transid').AsString))
    else if ((Tablenm='axpages') or (Tablenm='axprops')) then
      Whr :=Axpro.dbm.gf.sqllower+'(name) = '+Lowercase(Quotedstr(Fcds.FieldByName('name').AsString));

   if Whr <>'' then
    Result :=Whr;
end;


function TImportDiff.GetFieldType(Typestr:string):string;
begin
  result :='';
  if Typestr= 'character' then 
    result :='c'
  else if Typestr= 'numeric' then
    result :='n'
  else if Typestr = 'date' then
    result :='d'
  else if Typestr= 'text' then
    result :='t'
  else if Typestr = 'image' then
    result :='i';
end;

function TImportDiff.GetCdsFieldxml:IxmlNode;
var 
  CDSxml:IXMLDocument;
  Fxml:IXmlNode;
begin
  Fxml :=nil;
  CdsXml :=LoadXMLData(Fcds.XMLData);
  if CdsXml<> nil then begin
    Fxml :=CDSxml.ChildNodes.FindNode('DATAPACKET');
    if Fxml<>nil then begin
      Fxml :=FXML.ChildNodes.FindNode('METADATA');
      if Fxml<>nil then
        Fxml :=FXML.ChildNodes.FindNode('FIELDS');
    end;
  end;
  result := Fxml;
end;

function TImportDiff.GetFieldWidth(Fieldname,Ftype:string):string;
var
  i: Integer;
  fwid,Temp :string;
begin
 result :='';
 fwid :='0';
 Wcds.First;
 while not Wcds.Eof do begin
   if Fieldname=Lowercase(Trim(Wcds.FieldByName('name').AsString)) then begin
     if Ftype='c' then
       Fwid :=Wcds.FieldByName('cwidth').AsString
     else if Ftype='n' then
       Fwid :=Wcds.FieldByName('nwidth').AsString;
     break;
  end;
  wcds.Next;
 end;
 result :=fwid;
end;


function TImportDiff.UpgradeConstraint(Tablenm:string):boolean;
var Constraintname,Tablestr,Errorstr:string;
NotNullCount :Integer;
begin
   result :=false;
  if Tablenm<>'axattachworkflow' then exit;
  NotNullCount :=0;
  try
    Errorstr :='';
    Axpro.dbm.gf.DoDebug.Msg('Upgrade Constraint for '+Tablenm);
    x1.close;
    x1.CDS.CommandText :='Select wkid from '+Tablenm+' where wkid is not null';
    x1.open;
    NotNullCount :=x1.CDS.RecordCount;
 //   Constraintname:=Axpro.GetConstraintName(Tablenm);
    Axpro.dbm.gf.DoDebug.Msg('Constraint name :'+Constraintname);
    if ((NotNullCount>0) or (Axpro.dbm.Connection.DbType='oracle')) then begin
      if Lowercase(Constraintname)<>'pk__axattach_wkidtransid' then begin
        x1.close;
        x1.CDS.CommandText :='Delete from '+Tablenm+' where wkid is null';
        x1.execsql;
        if Constraintname<>'' then
          Axpro.DropConstraint(Tablenm,Constraintname);
        Constraintname :=' pk__axattach_wkidtransid Primary key(wkid,transid) ';
        Axpro.AddConstraint(Tablenm,Constraintname);
      end;
      Result :=true;
    end
    else begin
      if Lowercase(Constraintname)<>'pk__axattach_wkidtransid' then begin
        Axpro.DropTable(Tablenm);
        raise Exception.Create('table not found');
      end;
    end;
  Except on e:Exception do
   Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    CreateTable(Tablenm);
    Result :=true;
  end;
end;

procedure TImportDiff.CreateStructDiff(PXML : IXMLDocument);
begin
  new(StructDiff);
  pStructDiff(StructDiff).Transid := Transid;
  pStructDiff(StructDiff).Stype := Stype;
  pStructDiff(StructDiff).ErrorMsg := '';
  pStructDiff(StructDiff).LogSQLScript := TStringList.Create;
  pStructDiff(StructDiff).CreatedDetailList  := TList.Create;
  pStructDiff(StructDiff).DeletedDetailList  := TList.Create;
  pStructDiff(StructDiff).ModifiedDetailList := TList.Create;
  pStructDiff(StructDiff).UnModifiedDetailList := TList.Create;
end;

procedure TImportDiff.InitTstructDetails(PXML : IXMLDocument);
begin
  Enode := PXML.DocumentElement;
  NNode := ENode.ChildNodes[0];
  Transid := NNode.ChildValues[uPropsXML.xml_name];
  Caption := NNode.ChildValues[uPropsXML.xml_caption];
  Stype := 'TStruct';
end;

procedure TImportDiff.InitIViewDetails(PXML : IXMLDocument);
begin
  Enode := PXML.DocumentElement;
  NNode := ENode.ChildNodes[0];
  Transid := NNode.ChildValues[uIViewXML.xml_name];
  Caption := NNode.ChildValues[uIViewXML.xml_caption];
  Stype := 'IView';
end;

function TImportDiff.TStructDiff(PXML : IXMLDocument) : Boolean;
var
  pstype, psname : string;
  structurefile : string;
  Errorstr:string;
begin
  Errorstr :='';
  Result := true;
  Ixds := Axpro.dbm.GetXDS(nil);
  Ixds.buffered := true;
  Ixds.CDS.CommandText  := 'select name from tstructs where '+Axpro.dbm.gf.sqllower+'(name)= '+ QuotedStr(lowercase(Transid));
  Ixds.open;

  if Ixds.CDS.isempty then
  begin
    new(CreatedDetail);
    CreatedDetail.SType := 'TStruct';
    CreatedDetail.SName := Transid;
    NewDBCall := TDbCall.create;
    NewDBCall.axprovider:=axpro;
    NewDBCall.dbm := axpro.dbm;
    NewDBCall.sxml := PXML;
    try
      Errorstr :='';
      NewDBCall.transid := Transid;
    except on e : Exception do
      Errorstr := e.Message;
    end;
    if Errorstr<>''  then begin
    //pStructDiff(StructDiff).ErrorMsg := e.Message;
      NewStruct := NewDBCall.struct;
      OnCreateTStruct(NewStruct, pStructDiff(StructDiff).LogSQLScript);
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;

    try
      Errorstr :='';
      NewDBCall.CreateMapObjects;
    except on e : Exception do
      Errorstr := e.Message;
    end;
    if Errorstr <>'' then begin
      pStructDiff(StructDiff).ErrorMsg :=Errorstr;
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;

    NewStruct := NewDBCall.struct;
    OnCreateTStruct(NewStruct, pStructDiff(StructDiff).LogSQLScript);
    pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
    DestroyTStruct;
  end
  else
  begin
    OldDBCall := TDbCall.create;
    OldDBCall.axprovider:=axpro;
    OldDBCall.dbm := axpro.dbm;
    try
      Errorstr :='';
      structurefile := axpro.dbm.gf.startpath+'Structures\'+axpro.dbm.gf.AppName+'\'+Transid+'.tstructs';
      if fileexists(structurefile) then
        deletefile(structurefile);
      OldDBCall.transid := Transid;
    except on e : Exception do
      Errorstr := e.Message;
    end;
    if Errorstr<>'' then begin
      pStructDiff(StructDiff).ErrorMsg := Errorstr;
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;

    try
      Errorstr :='';
      OldDBCall.CreateMapObjects;
    except on e : Exception do
      Errorstr := e.Message;
    end;
    if Errorstr<>'' then begin
      pStructDiff(StructDiff).ErrorMsg := Errorstr;
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;
    OldStruct := OldDBCall.struct;
    omdmapdefs := OldDBCall.MDMap.GetDefList;
    ogenmapsdrecs := OldDBCall.ProvideLink.StoreDataList;

    NewDBCall := TDbCall.create;
    NewDBCall.axprovider:=axpro;
    NewDBCall.dbm := axpro.dbm;
    NewDBCall.sxml := PXML;

    try
      Errorstr :='';
      NewDBCall.transid := Transid;
    except on e : Exception do
       Errorstr :=e.Message;
    end;
    if ErrorStr<>'' then begin
//      pStructDiff(StructDiff).ErrorMsg := ErrorStr;
      NewStruct := NewDBCall.struct;
      OnCreateTStruct(NewStruct, pStructDiff(StructDiff).LogSQLScript);
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;

    try
      Errorstr :='';
      NewDBCall.CreateMapObjects;
    except on e : Exception do
      Errorstr :=e.Message;
    end;
    if Errorstr <>'' then begin
      pStructDiff(StructDiff).ErrorMsg := Errorstr;
      StructDiffList.Add(StructDiff);
      Ixds.close;
      Ixds.Free;
      DestroyTStruct;
      exit;
    end;
    NewStruct := NewDBCall.struct;
    nmdmapdefs := NewDBCall.MDMap.GetDefList;
    ngenmapsdrecs := NewDBCall.ProvideLink.StoreDataList;
    Result := false;
    pstype := 'TStruct';
    psname := NewStruct.Transid;
    ModifyTStruct(NewStruct, OldStruct, pstype, psname);
  end;
  StructDiffList.Add(StructDiff);
  Ixds.close;
  Ixds.Free;
end;

function TImportDiff.IViewDiff(PXML : IXMLDocument) : Boolean;
var
  pstype, psname : string;
  structurefile  : string;
begin
  Result := true;
  Ixds := Axpro.dbm.GetXDS(nil);
  Ixds.buffered := true;
  Ixds.CDS.CommandText  := 'select name from iviews where '+Axpro.dbm.gf.sqllower+'(name)= '+ QuotedStr(lowercase(Transid));
  Ixds.open;
  if Ixds.CDS.isempty then
  begin
    new(CreatedDetail);
    CreatedDetail.SType := 'IView';
    CreatedDetail.SName := Transid;
    pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
  end
  else
  begin
   structurefile := axpro.dbm.gf.startpath+'Structures\'+axpro.dbm.gf.AppName+'\'+Transid+'.iviews';
   if fileexists(structurefile) then
     deletefile(structurefile);
    OldView := TViewDef.Create(axpro, transid, '', '');
    NewView := TViewDef.Create(axpro, transid, '', '', PXML);
    Result := false;
    pstype := 'IView';
    psname := transid;
    ModifyIView(NewView, OldView, pstype, psname);
  end;
  StructDiffList.Add(StructDiff);
  Ixds.close;
  Ixds.Free;
end;

procedure TImportDiff.ModifyTStruct(PNStruct, POStruct : TStructDef; PSType, PSName : string);
var
  IsModified : Boolean;
begin
  StringDiff(PNStruct.Caption, POStruct.Caption, PSType, PSName, 'Caption');
  StringDiff(PNStruct.savecontrol, POStruct.savecontrol, PSType, PSName, 'Savecontrol');
  StringDiff(PNStruct.delcontrol, POStruct.delcontrol, PSType, PSName, 'Deletecontrol');
  IsModified := StringDiff(PNStruct.SchemaName, POStruct.SchemaName, PSType, PSName, 'SchemaName');
  if IsModified then
  begin
    onSchemaNameChange(PNStruct, POStruct, pStructDiff(StructDiff).LogSQLScript);
  end;
  StringDiff(PNStruct.DocDateField, POStruct.DocDateField, PSType, PSName, 'DocDateField');
  StringDiff(PNStruct.treeparents, POStruct.treeparents, PSType, PSName, 'TreeParents');
  StringDiff(PNStruct.treetables, POStruct.treetables, PSType, PSName, 'TreeTables');
  IsModified := BooleanDiff(PNStruct.track, POStruct.track, PSType, PSName, 'Track');
  if IsModified then
  begin
    onCreateorDeleteHistoryTable(PNStruct.track, PNStruct.SchemaName, PNStruct.Transid, pStructDiff(StructDiff).LogSQLScript);
  end;
  IsModified := BooleanDiff(PNStruct.attach, POStruct.attach, PSType, PSName, 'Attach');
  if IsModified then
  begin
    onCreateorDeleteAttachTable(PNStruct.attach, PNStruct.SchemaName, PNStruct.Transid, pStructDiff(StructDiff).LogSQLScript);
  end;
  IsModified := BooleanDiff(PNStruct.WorkFlow, POStruct.WorkFlow, PSType, PSName, 'WorkFlow');
  if IsModified then
  begin
    OnCreateorDeleteWorkflowTable(PNStruct.WorkFlow, PNStruct.SchemaName, PNStruct.Transid, pStructDiff(StructDiff).LogSQLScript);
  end;

  BooleanDiff(PNStruct.TrackAllFields, POStruct.TrackAllFields, PSType, PSName, 'TrackAllFields');
end;

procedure TImportDiff.ModifyIView(PNView, POView : TViewDef; PSType, PSName : string);
begin
  StringDiff(PNView.Name, POView.Name, PSType, PSName, 'Name');
  StringDiff(PNView.Caption, POView.Caption, PSType, PSName, 'Caption');
  StringDiff(PNView.LoadTStruct, POView.LoadTStruct, PSType, PSName, 'LoadTStruct');
  IntegerDiff(PNView.TrailingSpace, POView.TrailingSpace, PSType, PSName, 'TrailingSpace');
  IntegerDiff(PNView.LinesPerPage, POView.LinesPerPage, PSType, PSName, 'LinesPerPage');
  IntegerDiff(PNView.Factor, POView.Factor, PSType, PSName, 'Factor');

  BooleanDiff(PNView.PrintPageTotal, POView.PrintPageTotal, PSType, PSName, 'PrintPageTotal');
  BooleanDiff(PNView.RowSeparator, POView.RowSeparator, PSType, PSName, 'RowSeparator');
  BooleanDiff(PNView.GrandTotal, POView.GrandTotal, PSType, PSName, 'GrandTotal');
  StringDiff(PNView.ExpressionSet, POView.ExpressionSet, PSType, PSName, 'ExpressionSet');
  StringDiff(PNView.GroupField, POView.GroupField, PSType, PSName, 'GroupField');
  StringDiff(PNView.Font, POView.Font, PSType, PSName, 'Font');

  StringDiff(PNView.CaptionColumn, POView.CaptionColumn, PSType, PSName, 'CaptionColumn');
  StringDiff(PNView.Folder, POView.Folder, PSType, PSName, 'Folder');
  StringDiff(PNView.PrinterSettings, POView.PrinterSettings, PSType, PSName, 'PrinterSettings');
  StringDiff(PNView.OptionType, POView.OptionType, PSType, PSName, 'OptionType');
  StringDiff(PNView.TotalSeparator, POView.TotalSeparator, PSType, PSName, 'TotalSeparator');
  StringDiff(PNView.DosGraphicMode, POView.DosGraphicMode, PSType, PSName, 'DosGraphicMode');

  BooleanDiff(PNView.LineSpace, POView.LineSpace, PSType, PSName, 'LineSpace');
  BooleanDiff(PNView.Condensed, POView.Condensed, PSType, PSName, 'Condensed');
  BooleanDiff(PNView.ShowGraph, POView.ShowGraph, PSType, PSName, 'ShowGraph');
  BooleanDiff(PNView.FitToPage, POView.FitToPage, PSType, PSName, 'FitToPage');
  BooleanDiff(PNView.PrintLogo, POView.PrintLogo, PSType, PSName, 'PrintLogo');

  StringDiff(PNView.FilterExpression, POView.FilterExpression, PSType, PSName, 'FilterExpression');
  StringDiff(PNView.RecordIdColumn, POView.RecordIdColumn, PSType, PSName, 'RecordIdColumn');

  BooleanDiff(PNView.HeadingLineSpace, POView.HeadingLineSpace, PSType, PSName, 'HeadingLineSpace');
  BooleanDiff(PNView.ReportStyle, POView.ReportStyle, PSType, PSName, 'ReportStyle');
  BooleanDiff(PNView.PrintIndexPage, POView.PrintIndexPage, PSType, PSName, 'PrintIndexPage');

  StringDiff(PNView.NextQueryName, POView.NextQueryName, PSType, PSName, 'NextQueryName');
  StringDiff(PNView.TransId, POView.TransId, PSType, PSName, 'TransId');
  StringDiff(PNView.PrinterName, POView.PrinterName, PSType, PSName, 'PrinterName');
  BooleanDiff(PNView.AbsoluteCheck, POView.AbsoluteCheck, PSType, PSName, 'AbsoluteCheck');
  StringDiff(PNView.HeadingColor, POView.HeadingColor, PSType, PSName, 'HeadingColor');
  StringDiff(PNView.Heading1Font, POView.Heading1Font, PSType, PSName, 'Heading1Font');
  StringDiff(PNView.Heading2Font, POView.Heading2Font, PSType, PSName, 'Heading2Font');
  StringDiff(PNView.Heading3Font, POView.Heading3Font, PSType, PSName, 'Heading3Font');

  StringDiff(PNView.HeadRowColor, POView.HeadRowColor, PSType, PSName, 'HeadRowColor');
  StringDiff(PNView.HeadRowFont, POView.HeadRowFont, PSType, PSName, 'HeadRowFont');
  StringDiff(PNView.OddColor, POView.OddColor, PSType, PSName, 'OddColor');
  StringDiff(PNView.EvenColor, POView.EvenColor, PSType, PSName, 'EvenColor');
  StringDiff(PNView.RowHeight, POView.RowHeight, PSType, PSName, 'RowHeight');

  StringDiff(PNView.ReportHeading1, POView.ReportHeading1, PSType, PSName, 'ReportHeading1');
  StringDiff(PNView.ReportHeading2, POView.ReportHeading2, PSType, PSName, 'ReportHeading2');
  StringDiff(PNView.ReportHeading3, POView.ReportHeading3, PSType, PSName, 'ReportHeading3');
  StringDiff(PNView.PageFooter1, POView.PageFooter1, PSType, PSName, 'PageFooter1');
  StringDiff(PNView.PageFooter2, POView.PageFooter2, PSType, PSName, 'PageFooter2');
  StringDiff(PNView.PageFooter3, POView.PageFooter3, PSType, PSName, 'PageFooter3');

  StringDiff(PNView.ReportFooter1, POView.ReportFooter1, PSType, PSName, 'ReportFooter1');
  StringDiff(PNView.ReportFooter2, POView.ReportFooter2, PSType, PSName, 'ReportFooter2');
  StringDiff(PNView.ReportFooter3, POView.ReportFooter3, PSType, PSName, 'ReportFooter3');
  StringDiff(PNView.PaperSize, POView.PaperSize, PSType, PSName, 'PaperSize');
  StringDiff(PNView.PaperWidth, POView.PaperWidth, PSType, PSName, 'PaperWidth');
  StringDiff(PNView.PaperLength, POView.PaperLength, PSType, PSName, 'PaperLength');
  StringDiff(PNView.Source, POView.Source, PSType, PSName, 'Source');
  StringDiff(PNView.NoOfCopies, POView.NoOfCopies, PSType, PSName, 'NoOfCopies');
  StringDiff(PNView.ReportHeading3, POView.ReportHeading3, PSType, PSName, 'ReportHeading3');
  StringDiff(PNView.Orientation, POView.Orientation, PSType, PSName, 'Orientation');
  StringDiff(PNView.Left, POView.Left, PSType, PSName, 'Left');
  StringDiff(PNView.Top, POView.Top, PSType, PSName, 'Top');
  StringDiff(PNView.Right, POView.Right, PSType, PSName, 'Right');
  StringDiff(PNView.Bottom, POView.Bottom, PSType, PSName, 'Bottom');
  StringDiff(PNView.ShowPrinterDialog, POView.ShowPrinterDialog, PSType, PSName, 'ShowPrinterDialog');
  StringDiff(PNView.OpeningCaption, POView.OpeningCaption, PSType, PSName, 'OpeningCaption');
  StringDiff(PNView.ClosingCaption, POView.ClosingCaption, PSType, PSName, 'ClosingCaption');

  BooleanDiff(PNView.DetailsInFooter, POView.DetailsInFooter, PSType, PSName, 'DetailsInFooter');
  BooleanDiff(PNView.HideFirstCol, POView.HideFirstCol, PSType, PSName, 'HideFirstCol');
  BooleanDiff(PNView.HideColumnLines, POView.HideColumnLines, PSType, PSName, 'HideColumnLines');
  BooleanDiff(PNView.DisplayParamWin, POView.DisplayParamWin, PSType, PSName, 'DisplayParamWin'); 

  StringDiff(PNView.OpenForm, POView.OpenForm, PSType, PSName, 'OpenForm');
  StringDiff(PNView.ExtractData, POView.ExtractData, PSType, PSName, 'ExtractData');
  StringDiff(PNView.BeforeFill, POView.BeforeFill, PSType, PSName, 'BeforeFill');
  StringDiff(PNView.Click, POView.Click, PSType, PSName, 'Click');
  StringDiff(PNView.DBlClick, POView.DBlClick, PSType, PSName, 'DBlClick');

  IntegerDiff(PNView.FixedRows, POView.FixedRows, PSType, PSName, 'FixedRows');
end;

function TImportDiff.StringDiff(PNewString, POldString, PSType, PSName, PSProperty : string) : Boolean;
begin
  if trim(PNewString) <> trim(POldString) then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    ModifiedDetail.OldValue := POldString;
    ModifiedDetail.NewValue := PNewString;
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    UnModifiedDetail.SValue := POldString;
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;
end;

function TImportDiff.IntegerDiff(PNewNumber, POldNumber : Integer; PSType, PSName, PSProperty : string) : Boolean;
begin
  if PNewNumber <> POldNumber then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    ModifiedDetail.OldValue := inttostr(POldNumber);
    ModifiedDetail.NewValue := inttostr(PNewNumber);
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    UnModifiedDetail.SValue := inttostr(POldNumber);
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;  
end;

function TImportDiff.BooleanDiff(PNewBool, POldBool : Boolean; PSType, PSName, PSProperty : string) : Boolean;
begin
  if PNewBool <> POldBool then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    if POldBool then
      ModifiedDetail.OldValue := 'True'
    else
      ModifiedDetail.OldValue := 'False';
    if PNewBool then
      ModifiedDetail.NewValue := 'True'
    else
      ModifiedDetail.NewValue := 'False';
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;    
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    if POldBool then
      UnModifiedDetail.SValue := 'True'
    else
      UnModifiedDetail.SValue := 'False';
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;  
end;

function TImportDiff.StringListDiff(PNewSList, POldSList : TStringList; PSType, PSName, PSProperty : string) : Boolean;
begin
  oldtext := '';
  newtext := '';
  if assigned(PNewSList) then
    newtext := PNewSList.Text;
  if assigned(POldSList) then
    oldtext := POldSList.Text;
  if trim(newtext) <> trim(oldtext) then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    ModifiedDetail.OldValue := oldtext;
    ModifiedDetail.NewValue := newtext;
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;    
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    UnModifiedDetail.SValue := oldtext;
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;  
end;

function TImportDiff.CharacterDiff(PNewChar, POldChar : Char; PSType, PSName, PSProperty : String) : Boolean;
begin
  if PNewChar <> POldChar then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    ModifiedDetail.OldValue := POldChar;
    ModifiedDetail.NewValue := PNewChar;
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;    
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    UnModifiedDetail.SValue := POldChar;
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;  
end;

function TImportDiff.XMLNodeDiff(PNewXMLNode, POldXMLNode : IXMLNode; PSType, PSName, PSProperty : string) : Boolean;
begin
  oldtext := '';
  newtext := '';
  if assigned(PNewXMLNode) then
    newtext := PNewXMLNode.XML;
  if assigned(POldXMLNode) then
    oldtext := POldXMLNode.XML;
  if trim(newtext) <> trim(oldtext) then
  begin
    new(ModifiedDetail);
    ModifiedDetail.SType := PSType;
    ModifiedDetail.SName := PSName;
    ModifiedDetail.SProperty := PSProperty;
    ModifiedDetail.OldValue := oldtext;
    ModifiedDetail.NewValue := newtext;
    pStructDiff(StructDiff).ModifiedDetailList.Add(ModifiedDetail);
    Result := True;    
  end
  else
  begin
    new(UnModifiedDetail);
    UnModifiedDetail.SType := PSType;
    UnModifiedDetail.SName := PSName;
    UnModifiedDetail.SProperty := PSProperty;
    UnModifiedDetail.SValue := oldtext;
    pStructDiff(StructDiff).UnModifiedDetailList.Add(UnModifiedDetail);
    Result := False;  
  end;  
end;

procedure TImportDiff.DCDiff(PNStruct, POStruct : TStructDef);
var
  dcidx : Integer;
  pstype,psname : string;
begin
  pstype := 'DC';
  if POStruct.frames.Count >= PNStruct.frames.Count then
  begin
    for dcidx := 0 to PNStruct.frames.Count - 1 do
    begin
      psname := 'dc' + inttostr(dcidx+1);
      ModifyDC(pfrm(PNStruct.frames[dcidx]),pfrm(POStruct.frames[dcidx]),pstype,psname);
    end;
    for dcidx := PNStruct.frames.Count to POStruct.frames.Count - 1 do
    begin
      psname := 'dc' + inttostr(dcidx+1);
      new(DeletedDetail);
      DeletedDetail.SType := pstype;
      DeletedDetail.SName := psname;
      pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
    end;
  end
  else
  begin
    for dcidx := 0 to POStruct.frames.Count - 1 do
    begin
      psname := 'dc' + inttostr(dcidx+1);
      ModifyDC(pfrm(PNStruct.frames[dcidx]),pfrm(POStruct.frames[dcidx]),pstype,psname);
    end;
    for dcidx := POStruct.frames.Count to PNStruct.frames.Count - 1 do
    begin
      psname := 'dc' + inttostr(dcidx+1);
      new(CreatedDetail);
      CreatedDetail.SType := pstype;
      CreatedDetail.SName := psname;
      onCreateDC(pFrm(PNStruct.frames[dcidx]), nschemaname, nprimarytable, ntransid, pStructDiff(StructDiff).LogSQLScript);
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
    end;
  end;
end;

procedure TImportDiff.ModifyDC(PNFrame, POFrame : pFrm; PSType, PSName : string);
var
  IsModified : Boolean;
begin
  IntegerDiff(PNFrame.FrameNo, POFrame.FrameNo, PSType, PSName, 'FrameNo');
  IntegerDiff(PNFrame.Parent, POFrame.Parent, PSType, PSName, 'Parent');
  IntegerDiff(PNFrame.PageNo, POFrame.PageNo, PSType, PSName, 'PageNo');
  IntegerDiff(PNFrame.PopParent, POFrame.PopParent, PSType, PSName, 'PopParent');
  IntegerDiff(PNFrame.PopIndex, POFrame.PopIndex, PSType, PSName, 'PopIndex');
  IsModified := StringDiff(PNFrame.TableName, POFrame.TableName, PSType, PSName, 'TableName');
  if IsModified then
  begin
    onCreateDC(pFrm(PNFrame), nschemaname, nprimarytable, ntransid, pStructDiff(StructDiff).LogSQLScript);
    onDeleteDC(pFrm(POFrame), oschemaname, oprimarytable, otransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  StringDiff(PNFrame.caption, POFrame.caption, PSType, PSName, 'Caption');
  IsModified := BooleanDiff(PNFrame.AsGrid, POFrame.AsGrid, PSType, PSName, 'AsGrid');
  if IsModified then
  begin
    onAsGridChange(PNFrame, nschemaname, nprimarytable, ntransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  BooleanDiff(PNFrame.Popup, POFrame.Popup, PSType, PSName, 'Popup');
  BooleanDiff(PNFrame.AllowChange, POFrame.AllowChange, PSType, PSName, 'AllowChange');
  BooleanDiff(PNFrame.ReadOnly, POFrame.ReadOnly, PSType, PSName, 'ReadOnly');
  BooleanDiff(PNFrame.AllowEmpty, POFrame.AllowEmpty, PSType, PSName, 'AllowEmpty');
  StringDiff(PNFrame.ActRowDeps, POFrame.ActRowDeps, PSType, PSName, 'ActRowDeps');
end;

procedure TImportDiff.FieldDiff(PNStruct, POStruct : TStructDef);
var
  fldidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'InputField';
  ofldslist.Clear;
  nfldslist.Clear;

  for fldidx := 0 to PNStruct.flds.Count - 1 do
  begin
    nfldslist.Add(lowercase(pfld(PNStruct.flds[fldidx]).FieldName));
  end;
  for fldidx := 0 to POStruct.flds.Count - 1 do
  begin
    ofldslist.Add(lowercase(pfld(POStruct.flds[fldidx]).FieldName));
  end;
  if POStruct.flds.Count >= PNStruct.flds.Count then
  begin
    for fldidx := 0 to PNStruct.flds.Count - 1 do
    begin
      psname := ofldslist[fldidx];
      idx := nfldslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        OnDeleteField(pFld(POStruct.flds[fldidx]), oschemaname, otransid, pStructDiff(StructDiff).LogSQLScript);
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);        
        psname := nfldslist[fldidx];
        idx := ofldslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          OnCreateField(pFld(PNStruct.flds[fldidx]), nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifyField(pfld(PNStruct.flds[idx]),pfld(POStruct.flds[fldidx]),pstype,psname);
    end;
    for fldidx := PNStruct.flds.Count to POStruct.flds.Count - 1 do
    begin
      psname := ofldslist[fldidx];
      idx := nfldslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        OnDeleteField(pFld(POStruct.flds[fldidx]), oschemaname, otransid, pStructDiff(StructDiff).LogSQLScript);
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifyField(pfld(PNStruct.flds[idx]),pfld(POStruct.flds[fldidx]),pstype,psname);
    end;
  end
  else
  begin
    for fldidx := 0 to POStruct.flds.Count - 1 do
    begin
      psname := nfldslist[fldidx];
      idx := ofldslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        OnCreateField(pFld(PNStruct.flds[fldidx]), nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := ofldslist[fldidx];
        idx := nfldslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          OnDeleteField(pFld(POStruct.flds[fldidx]), oschemaname, otransid, pStructDiff(StructDiff).LogSQLScript);
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifyField(pfld(PNStruct.flds[fldidx]),pfld(POStruct.flds[idx]),pstype,psname);
    end;
    for fldidx := POStruct.flds.Count to PNStruct.flds.Count - 1 do
    begin
      psname := nfldslist[fldidx];
      idx := ofldslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        OnCreateField(pFld(PNStruct.flds[fldidx]), nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifyField(pfld(PNStruct.flds[fldidx]),pfld(POStruct.flds[idx]),pstype,psname);
    end;
  end;
end;

procedure TImportDiff.ModifyField(PNField, POField : pFld; PSType, PSName : string);
var
  IsModified : Boolean;
  errstr : string;
begin
  errstr := '';
  IsModified := StringDiff(PNField.Tablename, POField.Tablename, PSType, PSName, 'Tablename');
  if IsModified then
  begin
    {
    onTableNameChange(PNField, nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
    }
    onDeleteField(POField, oschemaname, otransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  IsModified := StringDiff(PNField.DataType, POField.DataType, PSType, PSName, 'DataType');
  IsModified := IsModified or IntegerDiff(PNField.Width, POField.Width, PSType, PSName, 'Width');
  IsModified := IsModified or IntegerDiff(PNField.Dec, POField.Dec, PSType, PSName, 'Dec');
  IsModified := IsModified or IntegerDiff(PNField.DBDec, POField.DBDec, PSType, PSName, 'DBDec');
  if IsModified then
  begin
    if not PNField.SourceKey then errstr := OnFieldBasicPropertiesChange(PNField, nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  if errstr <> '' then begin
    WriteToTraceFile(PNField,inttostr(POField.Width),errstr);
    Display_Error_Message := true;
  end;
  IsModified := BooleanDiff(PNField.SaveValue, POField.SaveValue, PSType, PSName, 'SaveValue');
  if IsModified then
  begin
    onSaveValueChange(PNField, nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
  end else
  begin
    if (PNField.SaveValue) then
      OnCreateField(PNField, nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  StringDiff(PNField.Caption, POField.Caption, PSType, PSName, 'Caption');
  IntegerDiff(PNField.FrameNo, POField.FrameNo, PSType, PSName, 'FrameNo');
  BooleanDiff(PNField.Empty, POField.Empty, PSType, PSName, 'Empty');
  BooleanDiff(PNField.NoDuplicate, POField.NoDuplicate, PSType, PSName, 'NoDuplicate');
  BooleanDiff(PNField.AsGrid, POField.AsGrid, PSType, PSName, 'AsGrid');
  StringDiff(PNField.cvalexp, POField.cvalexp, PSType, PSName, 'CValExp');
  IntegerDiff(PNField.orderno, POField.orderno, PSType, PSName, 'OrderNo');
  BooleanDiff(PNField.hidden, POField.hidden, PSType, PSName, 'Hidden');
  BooleanDiff(PNField.readonly, POField.readonly, PSType, PSName, 'ReadOnly');
  BooleanDiff(PNField.SetCarry, POField.SetCarry, PSType, PSName, 'SetCarry');
  BooleanDiff(PNField.ApplyComma, POField.ApplyComma, PSType, PSName, 'ApplyComma');
  BooleanDiff(PNField.OnlyPositive, POField.OnlyPositive, PSType, PSName, 'OnlyPositive');
  StringDiff(PNField.DispName, POField.DispName, PSType, PSName, 'DispName');
  BooleanDiff(PNField.DisplayTotal, POField.DisplayTotal, PSType, PSName, 'DisplayTotal');
  BooleanDiff(PNField.ClientValidation, POField.ClientValidation, PSType, PSName, 'ClientValidation');
  StringDiff(PNField.Mask, POField.Mask, PSType, PSName, 'Mask');
  StringDiff(PNField.Pattern, POField.Pattern, PSType, PSName, 'Pattern');
  StringDiff(PNField.Hint, POField.Hint, PSType, PSName, 'Hint');
  CharacterDiff(char(PNField.pwchar),char(POField.pwchar), PSType, PSName, 'PWChar');
  IsModified := StringDiff(PNField.ModeofEntry, POField.ModeofEntry, PSType, PSName, 'ModeofEntry');
  if IsModified then
  begin
    onModeOfEntryChange(PNField, POField, nschemaname, oschemaname, ntransid, otransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  IsModified := BooleanDiff(PNField.SourceKey, POField.SourceKey, PSType, PSName, 'SourceKey');
  if IsModified then
  begin
    onSourceKeyChange(PNField, nschemaname, ntransid, pStructDiff(StructDiff).LogSQLScript);
  end;
  StringDiff(PNField.cexp, POField.cexp, PSType, PSName, 'CExp');
  StringDiff(PNField.sgwidth, POField.sgwidth, PSType, PSName, 'SGWidth');    // need to be discuss
//  IntegerDiff(PNField.Width, POField.Width, PSType, PSName, 'SGWidth');             // by ar
//  IntegerDiff(PNField.sgwidth, POField.sgWidth, PSType, PSName, 'SGWidth');
  IntegerDiff(PNField.sgheight, POField.sgheight, PSType, PSName, 'SgHeight');
  StringDiff(PNField.CField, POField.CField, PSType, PSName, 'CField');
  StringDiff(PNField.SourceField, POField.SourceField, PSType, PSName, 'SourceField');
  StringDiff(PNField.SourceTransid, POField.SourceTransid, PSType, PSName, 'SourceTransid');
  StringDiff(PNField.SourceTable, POField.SourceTable, PSType, PSName, 'SourceTable');
  IntegerDiff(PNField.searchcol, POField.searchcol, PSType, PSName, 'SearchCol');
  BooleanDiff(PNField.FromList, POField.FromList, PSType, PSName, 'FromList');
  StringDiff(PNField.LinkField, POField.LinkField, PSType, PSName, 'LinkField');
  StringListDiff(PNField.SQL, POField.SQL, PSType, PSName, 'SQL');
  StringListDiff(PNField.SearchSQL, POField.SearchSQL, PSType, PSName, 'SearchSQL');
  StringDiff(PNField.DetTransid, POField.DetTransid, PSType, PSName, 'DetTransid');
  StringDiff(PNField.DetCondition, POField.DetCondition, PSType, PSName, 'DetCondition');
  StringDiff(PNField.DepFrames, POField.DepFrames, PSType, PSName, 'DepFrames');
  IntegerDiff(PNField.PopIndex, POField.PopIndex, PSType, PSName, 'PopIndex');
  BooleanDiff(PNField.Suggestive, POField.Suggestive, PSType, PSName, 'Suggestive');
  BooleanDiff(PNField.Autoselect, POField.Autoselect, PSType, PSName, 'AutoSelect');
  BooleanDiff(PNField.multiline, POField.multiline, PSType, PSName, 'MultiLine');
  BooleanDiff(PNField.AllowChange, POField.AllowChange, PSType, PSName, 'AllowChange');
  BooleanDiff(PNField.HasParams, POField.HasParams, PSType, PSName, 'HasParams');
  BooleanDiff(PNField.Refresh, POField.Refresh, PSType, PSName, 'Refresh');
  //BooleanDiff(PNField.DynamicParams, POField.DynamicParams, PSType, PSName, 'DynamicParams');          // by ar
 BooleanDiff(PNField.DispField, POField.DispField, PSType, PSName, 'DispField');
  StringListDiff(PNField.listvals, POField.listvals, PSType, PSName, 'ListVals');
//  StringListDiff(PNField.deps, POField.deps, PSType, PSName, 'Deps');    // Commented because in value of deps in version 9.0 and other versions is different
//  StringListDiff(PNField.displaydetail, POField.displaydetail, PSType, PSName, 'DisplayDetail');
  StringListDiff(PNField.detmap, POField.detmap, PSType, PSName, 'DetMap');
//  BooleanDiff(PNField.CommaSelection, POField.CommaSelection, PSType, PSName, 'DynamicParams');     // by ar
//  BooleanDiff(PNField.txtSelection, POField.txtSelection, PSType, PSName, 'TxtSelection');        // by ar
//  XMLNodeDiff(PNField.SequenceNode, POField.SequenceNode, PSType, PSName, 'SequenceNode');
end;

procedure TImportDiff.FillGridDiff(PNStruct, POStruct : TStructDef);
var
  fgidx : Integer;
  pstype,psname : string;
begin
  pstype := 'FillGrid';
  if POStruct.fgs.Count >= PNStruct.fgs.Count then
  begin
    for fgidx := 0 to PNStruct.fgs.Count - 1 do
    begin
      psname := 'fillgrid' + inttostr(fgidx+1);
      ModifyFillGrid(pfg(PNStruct.fgs[fgidx]),pfg(POStruct.fgs[fgidx]),pstype,psname);
    end;
    for fgidx := PNStruct.fgs.Count to POStruct.fgs.Count - 1 do
    begin
      psname := 'fillgrid' + inttostr(fgidx+1);
      new(DeletedDetail);
      DeletedDetail.SType := pstype;
      DeletedDetail.SName := psname;
      pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
    end;
  end
  else
  begin
    for fgidx := 0 to POStruct.fgs.Count - 1 do
    begin
      psname := 'fillgrid' + inttostr(fgidx+1);
      ModifyFillGrid(pfg(PNStruct.fgs[fgidx]),pfg(POStruct.fgs[fgidx]),pstype,psname);
    end;
    for fgidx := POStruct.fgs.Count to PNStruct.fgs.Count - 1 do
    begin
      psname := 'fillgrid' + inttostr(fgidx+1);
      new(CreatedDetail);
      CreatedDetail.SType := pstype;
      CreatedDetail.SName := psname;
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
    end;
  end;
end;


procedure TImportDiff.ModifyFillGrid(PNFillGrid, POFillGrid : pFg; PSType, PSName : string);
begin
  StringDiff(PNFillGrid.name, POFillGrid.name, PSType, PSName, 'Name');
  StringDiff(PNFillGrid.SQLText, POFillGrid.SQLText, PSType, PSName, 'SQLText');
  StringDiff(PNFillGrid.colwidths, POFillGrid.colwidths, PSType, PSName, 'ColWidths');
  StringDiff(PNFillGrid.Groupfield, POFillGrid.Groupfield, PSType, PSName, 'Groupfield');
  StringDiff(PNFillGrid.SelectOn, POFillGrid.SelectOn, PSType, PSName, 'SelectOn');
  StringDiff(PNFillGrid.FooterStr, POFillGrid.FooterStr, PSType, PSName, 'FooterStr');
  StringDiff(PNFillGrid.VExp, POFillGrid.VExp, PSType, PSName, 'VExp');

  StringListDiff(PNFillGrid.Map, POFillGrid.Map, PSType, PSName, 'Map');
  StringListDiff(PNFillGrid.Caps, POFillGrid.Caps, PSType, PSName, 'Caps');

  BooleanDiff(PNFillGrid.FromIView, POFillGrid.FromIView, PSType, PSName, 'FromIView');
  BooleanDiff(PNFillGrid.MultiSelect, POFillGrid.MultiSelect, PSType, PSName, 'MultiSelect');
  BooleanDiff(PNFillGrid.AutoShow, POFillGrid.AutoShow, PSType, PSName, 'AutoShow');
  BooleanDiff(PNFillGrid.ValidateRow, POFillGrid.ValidateRow, PSType, PSName, 'ValidateRow');
  BooleanDiff(PNFillGrid.HasParams, POFillGrid.HasParams, PSType, PSName, 'HasParams');
  BooleanDiff(PNFillGrid.DynamicParams, POFillGrid.DynamicParams, PSType, PSName, 'DynamicParams');
  BooleanDiff(PNFillGrid.ExecuteOnSave, POFillGrid.ExecuteOnSave, PSType, PSName, 'ExecuteOnSave');
//  BooleanDiff(PNFillGrid.firmbind, POFillGrid.firmbind, PSType, PSName, 'FirmBind');
  IntegerDiff(PNFillGrid.TargetFrame, POFillGrid.TargetFrame, PSType, PSName, 'TargetFrame');
  IntegerDiff(PNFillGrid.SourceFrame, POFillGrid.SourceFrame, PSType, PSName, 'SourceFrame');
  IntegerDiff(PNFillGrid.AddRows, POFillGrid.AddRows, PSType, PSName, 'AddRows');
end;
procedure TImportDiff.MDMapDiff(PNMDMapDefs, POMDMapDefs : TList);
var
  mdidx : Integer;
  pstype,psname : string;
begin
  pstype := 'MDMap';
  if POMDMapDefs.Count >= PNMDMapDefs.Count then
  begin
    for mdidx := 0 to PNMDMapDefs.Count - 1 do
    begin
      psname := 'mdmap' + inttostr(mdidx+1);
      ModifyMDMap(pdef(PNMDMapDefs[mdidx]),pdef(POMDMapDefs[mdidx]),pstype,psname);
    end;
    for mdidx := PNMDMapDefs.Count to POMDMapDefs.Count - 1 do
    begin
      psname := 'mdmap' + inttostr(mdidx+1);
      new(DeletedDetail);
      DeletedDetail.SType := pstype;
      DeletedDetail.SName := psname;
      pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
    end;
  end
  else
  begin
    for mdidx := 0 to POMDMapDefs.Count - 1 do
    begin
      psname := 'mdmap' + inttostr(mdidx+1);
      ModifyMDMap(pdef(PNMDMapDefs[mdidx]),pdef(POMDMapDefs[mdidx]),pstype,psname);
    end;
    for mdidx := POMDMapDefs.Count to PNMDMapDefs.Count - 1 do
    begin
      psname := 'mdmap' + inttostr(mdidx+1);
      new(CreatedDetail);
      CreatedDetail.SType := pstype;
      CreatedDetail.SName := psname;
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
    end;
  end;
end;

procedure TImportDiff.ModifyMDMap(PNDef, PODef : pDef; PSType, PSName : string);
begin
  StringDiff(PNDef.Transid, PODef.Transid, PSType, PSName, 'Transid');
  StringDiff(PNDef.Table, PODef.Table, PSType, PSName, 'Table');
  StringDiff(PNDef.ControlField, PODef.ControlField, PSType, PSName, 'ControlField');
  StringDiff(PNDef.TargetTypes, PODef.TargetTypes, PSType, PSName, 'TargetTypes');
  StringDiff(PNDef.TreeTable, PODef.TreeTable, PSType, PSName, 'TreeTable');
  StringDiff(PNDef.TreeLink, PODef.TreeLink, PSType, PSName, 'TreeLink');
  StringDiff(PNDef.CompanyName, PODef.CompanyName, PSType, PSName, 'CompanyName');

  StringListDiff(PNDef.target, PODef.target, PSType, PSName, 'Target');
  StringListDiff(PNDef.source, PODef.source, PSType, PSName, 'Source');
  StringListDiff(PNDef.decs, PODef.decs, PSType, PSName, 'Decs');

  IntegerDiff(PNDef.SourceFrame, PODef.SourceFrame, PSType, PSName, 'SourceFrame');

  BooleanDiff(PNDef.Append, PODef.Append, PSType, PSName, 'Append');
  BooleanDiff(PNDef.Tree, PODef.Tree, PSType, PSName, 'Tree');
  BooleanDiff(PNDef.InitOnDel, PODef.InitOnDel, PSType, PSName, 'InitOnDel');
  BooleanDiff(PNDef.PostOnApprove, PODef.PostOnApprove, PSType, PSName, 'PostOnApprove');
  BooleanDiff(PNDef.PostOnReject, PODef.PostOnReject, PSType, PSName, 'PostOnReject');
end;

procedure TImportDiff.GenMapDiff(PNGenMapSDRecs, POGenMapSDRecs : TList);
var
  genidx : Integer;
  pstype,psname : string;
begin
  pstype := 'GenMap';
  if POGenMapSDRecs.Count >= PNGenMapSDRecs.Count then
  begin
    for genidx := 0 to PNGenMapSDRecs.Count - 1 do
    begin
      psname := 'genmap' + inttostr(genidx+1);
      ModifyGenMap(pStoreDataRec(PNGenMapSDRecs[genidx]),pStoreDataRec(POGenMapSDRecs[genidx]),pstype,psname);
    end;
    for genidx := PNGenMapSDRecs.Count to POGenMapSDRecs.Count - 1 do
    begin
      psname := 'genmap' + inttostr(genidx+1);
      new(DeletedDetail);
      DeletedDetail.SType := pstype;
      DeletedDetail.SName := psname;
      pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
    end;
  end
  else
  begin
    for genidx := 0 to POGenMapSDRecs.Count - 1 do
    begin
      psname := 'genmap' + inttostr(genidx+1);
      ModifyGenMap(pStoreDataRec(PNGenMapSDRecs[genidx]),pStoreDataRec(POGenMapSDRecs[genidx]),pstype,psname);
    end;
    for genidx := POGenMapSDRecs.Count to PNGenMapSDRecs.Count - 1 do
    begin
      psname := 'genmap' + inttostr(genidx+1);
      new(CreatedDetail);
      CreatedDetail.SType := pstype;
      CreatedDetail.SName := psname;      
      pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
    end;
  end;
end;

procedure TImportDiff.ModifyGenMap(PNSDRec, POSDRec : pStoreDataRec; PSType, PSName : String);
begin
  IntegerDiff(PNSDRec.SourceFrame, POSDRec.SourceFrame, PSType, PSName, 'SourceFrame');
  StringDiff(PNSDRec.MapName, POSDRec.MapName, PSType, PSName, 'MapName');
  StringDiff(PNSDRec.SourceTransId, POSDRec.SourceTransId, PSType, PSName, 'SourceTransId');
  StringDiff(PNSDRec.TargetTransId, POSDRec.TargetTransId, PSType, PSName, 'TargetTransId');
  StringDiff(PNSDRec.ControlFieldName, POSDRec.ControlFieldName, PSType, PSName, 'ControlFieldName');
  StringDiff(PNSDRec.CompanyFieldName, POSDRec.CompanyFieldName, PSType, PSName, 'CompanyFieldName');
  StringListDiff(PNSDRec.MaxRowList, POSDRec.MaxRowList, PSType, PSName, 'MapName');
  StringDiff(PNSDRec.SubTypeField, POSDRec.SubTypeField, PSType, PSName, 'SubTypeField');
  BooleanDiff(PNSDRec.Posted, POSDRec.Posted, PSType, PSName, 'Posted');
  BooleanDiff(PNSDRec.PostOnApprove, POSDRec.PostOnApprove, PSType, PSName, 'PostOnApprove');
  BooleanDiff(PNSDRec.PostOnReject, POSDRec.PostOnReject, PSType, PSName, 'PostOnReject');
  CharacterDiff(PNSDRec.UpdatePosted, POSDRec.UpdatePosted, PSType, PSName, 'UpdatePosted');
  XMLNodeDiff(PNSDRec.node, POSDRec.node, PSType, PSName, 'Node');
  StringListDiff(PNSDRec.Expr, POSDRec.Expr, PSType, PSName, 'Expr');
  StringDiff(PNSDRec.SourceMapName, POSDRec.SourceMapName, PSType, PSName, 'SourceMapName');
end;

procedure TImportDiff.ColDataDiff(PNView, POView : TViewDef);
var
  colidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'Column';
  ocolslist.Clear;
  ncolslist.Clear;
  for colidx := 0 to PNView.cols.Count - 1 do
  begin
    ncolslist.Add(lowercase(pColData(PNView.cols[colidx]).columnname));
  end;
  for colidx := 0 to POView.cols.Count - 1 do
  begin
    ocolslist.Add(lowercase(pColData(POView.cols[colidx]).columnname));
  end;
  if POView.cols.Count >= PNView.cols.Count then
  begin
    for colidx := 0 to PNView.cols.Count - 1 do
    begin
      psname := ocolslist[colidx];
      idx := ncolslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        psname := ncolslist[colidx];
        idx := ocolslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifyColData(pColData(PNView.cols[idx]),pColData(POView.cols[colidx]),pstype,psname);
    end;
    for colidx := PNView.cols.Count to POView.cols.Count - 1 do
    begin
      psname := ocolslist[colidx];
      idx := ncolslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifyColData(pColData(PNView.cols[idx]),pColData(POView.cols[colidx]),pstype,psname);
    end;
  end
  else
  begin
    for colidx := 0 to POView.cols.Count - 1 do
    begin
      psname := ncolslist[colidx];
      idx := ocolslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := ocolslist[colidx];
        idx := ncolslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifyColData(pColData(PNView.cols[colidx]),pColData(POView.cols[idx]),pstype,psname);
    end;
    for colidx := POView.cols.Count to PNView.cols.Count - 1 do
    begin
      psname := ncolslist[colidx];
      idx := ocolslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifyColData(pColData(PNView.cols[colidx]),pColData(POView.cols[idx]),pstype,psname);
    end;
  end;
end;

procedure TImportDiff.ModifyColData(PNColData, POColData : pColData; PSType, PSName : string);
begin
  StringDiff(PNColData.datatype, POColData.datatype, PSType, PSName, 'Datatype');
  StringDiff(PNColData.alignment, POColData.alignment, PSType, PSName, 'Alignment');
  StringDiff(PNColData.ColumnHeading, POColData.ColumnHeading, PSType, PSName, 'ColumnHeading');
  StringDiff(PNColData.colour, POColData.colour, PSType, PSName, 'Colour');
  StringDiff(PNColData.fontname, POColData.fontname, PSType, PSName, 'FontName');
  StringDiff(PNColData.fontcolor, POColData.fontcolor, PSType, PSName, 'FontColor');
  StringDiff(PNColData.click, POColData.click, PSType, PSName, 'Click');
  StringDiff(PNColData.dblclick, POColData.dblclick, PSType, PSName, 'DblClick');
  StringDiff(PNColData.font, POColData.font, PSType, PSName, 'Font');

  IntegerDiff(PNColData.displayexprn, POColData.displayexprn, PSType, PSName, 'DisplayExprn');
  IntegerDiff(PNColData.width, POColData.width, PSType, PSName, 'Width');
  IntegerDiff(PNColData.columnno, POColData.columnno, PSType, PSName, 'ColumnNo');
  IntegerDiff(PNColData.exprid, POColData.exprid, PSType, PSName, 'ExprId');
  IntegerDiff(PNColData.decimals, POColData.decimals, PSType, PSName, 'Decimals');
  IntegerDiff(PNColData.VIndex, POColData.VIndex, PSType, PSName, 'VIndex');
  IntegerDiff(PNColData.fontsize, POColData.fontsize, PSType, PSName, 'fontsize');
  IntegerDiff(PNColData.groupno, POColData.groupno, PSType, PSName, 'GroupNo');

  BooleanDiff(PNColData.RunningTotal, POColData.RunningTotal, PSType, PSName, 'RunningTotal');
  BooleanDiff(PNColData.ComputePost, POColData.ComputePost, PSType, PSName, 'ComputePost');
  BooleanDiff(PNColData.ZeroOff, POColData.ZeroOff, PSType, PSName, 'ZeroOff');
  BooleanDiff(PNColData.SetFactor, POColData.SetFactor, PSType, PSName, 'SetFactor');
  BooleanDiff(PNColData.norepeat, POColData.norepeat, PSType, PSName, 'NoRepeat');
  BooleanDiff(PNColData.hidden, POColData.hidden, PSType, PSName, 'Hidden');
  BooleanDiff(PNColData.displaytotal, POColData.displaytotal, PSType, PSName, 'DisplayTotal');
  BooleanDiff(PNColData.applycomma, POColData.applycomma, PSType, PSName, 'ApplyComma');

  BooleanDiff(PNColData.fontbold, POColData.fontbold, PSType, PSName, 'FontBold');
  BooleanDiff(PNColData.fontstrike, POColData.fontstrike, PSType, PSName, 'FontStrike');
  BooleanDiff(PNColData.fontunderline, POColData.fontunderline, PSType, PSName, 'FontUnderline');
  BooleanDiff(PNColData.fontitalic, POColData.fontitalic, PSType, PSName, 'FontItalic');
  BooleanDiff(PNColData.colseperator, POColData.colseperator, PSType, PSName, 'ColSeperator');
  
  StringDiff(PNColData.QuerySQLName, POColData.QuerySQLName, PSType, PSName, 'QuerySQLName');
  StringDiff(PNColData.Expr, POColData.Expr, PSType, PSName, 'Expr');
  StringDiff(PNColData.DisplayExpr, POColData.DisplayExpr, PSType, PSName, 'DisplayExpr');
  StringDiff(PNColData.tablename, POColData.tablename, PSType, PSName, 'TableName');
  StringDiff(PNColData.searchname, POColData.searchname, PSType, PSName, 'SearchName');
  StringDiff(PNColData.groupheading, POColData.groupheading, PSType, PSName, 'GroupHeading');
  StringDiff(PNColData.actname, POColData.actname, PSType, PSName, 'ActName');
  XMLNodeDiff(PNColData.cellFont, POColData.cellFont, PSType, PSName, 'CellFont');
end;

procedure TImportDiff.SQLDiff(PNView, POView : TViewDef);
var
  sqlidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'SQL';
  osqlslist.Clear;
  nsqlslist.Clear;
  for sqlidx := 0 to PNView.sqls.Count - 1 do
  begin
    nsqlslist.Add(lowercase(pSQL(PNView.sqls[sqlidx]).QueryName));
  end;
  for sqlidx := 0 to POView.sqls.Count - 1 do
  begin
    osqlslist.Add(lowercase(pSQL(POView.sqls[sqlidx]).QueryName));
  end;
  if POView.sqls.Count >= PNView.sqls.Count then
  begin
    for sqlidx := 0 to PNView.sqls.Count - 1 do
    begin
      psname := osqlslist[sqlidx];
      idx := nsqlslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        psname := nsqlslist[sqlidx];
        idx := osqlslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifySQL(pSQL(PNView.sqls[idx]),pSQL(POView.sqls[sqlidx]),pstype,psname);
    end;
    for sqlidx := PNView.sqls.Count to POView.sqls.Count - 1 do
    begin
      psname := osqlslist[sqlidx];
      idx := nsqlslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifySQL(pSQL(PNView.sqls[idx]),pSQL(POView.sqls[sqlidx]),pstype,psname);
    end;
  end
  else
  begin
    for sqlidx := 0 to POView.sqls.Count - 1 do
    begin
      psname := nsqlslist[sqlidx];
      idx := osqlslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := osqlslist[sqlidx];
        idx := nsqlslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifySQL(pSQL(PNView.sqls[sqlidx]),pSQL(POView.sqls[idx]),pstype,psname);
    end;
    for sqlidx := POView.sqls.Count to PNView.sqls.Count - 1 do
    begin
      psname := nsqlslist[sqlidx];
      idx := osqlslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifySQL(pSQL(PNView.sqls[sqlidx]),pSQL(POView.sqls[idx]),pstype,psname);
    end;
  end;
end;


procedure TImportDiff.ModifySQL(PNSQL, POSQL : pSQL; PSType, PSName : string);
begin
  StringDiff(PNSQL.SqlText, POSQL.SqlText, PSType, PSName, 'SqlText');
  StringDiff(PNSQL.RelationField, POSQL.RelationField, PSType, PSName, 'RelationField');
  StringDiff(PNSQL.SQLType, POSQL.SQLType, PSType, PSName, 'SQLType');
  StringDiff(PNSQL.PrimaryField, POSQL.PrimaryField, PSType, PSName, 'PrimaryField');
  StringDiff(PNSQL.SecondaryField, POSQL.SecondaryField, PSType, PSName, 'SecondaryField');
end;

procedure TImportDiff.ParamDiff(PNView, POView : TViewDef);
var
  paramidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'Param';
  oparamslist.Clear;
  nparamslist.Clear;
  for paramidx := 0 to PNView.params.Count - 1 do
  begin
    nparamslist.Add(lowercase(pParam(PNView.params[paramidx]).Name));
  end;
  for paramidx := 0 to POView.params.Count - 1 do
  begin
    oparamslist.Add(lowercase(pParam(POView.params[paramidx]).Name));
  end;
  if POView.params.Count >= PNView.params.Count then
  begin
    for paramidx := 0 to PNView.params.Count - 1 do
    begin
      psname := oparamslist[paramidx];
      idx := nparamslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        psname := nparamslist[paramidx];
        idx := oparamslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifyParam(pParam(PNView.params[idx]),pParam(POView.params[paramidx]),pstype,psname);
    end;
    for paramidx := PNView.params.Count to POView.params.Count - 1 do
    begin
      psname := oparamslist[paramidx];
      idx := nparamslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifyParam(pParam(PNView.params[idx]),pParam(POView.params[paramidx]),pstype,psname);
    end;
  end
  else
  begin
    for paramidx := 0 to POView.params.Count - 1 do
    begin
      psname := nparamslist[paramidx];
      idx := oparamslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := oparamslist[paramidx];
        idx := nparamslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifyParam(pParam(PNView.params[paramidx]),pParam(POView.params[idx]),pstype,psname);
    end;
    for paramidx := POView.params.Count to PNView.params.Count - 1 do
    begin
      psname := nparamslist[paramidx];
      idx := oparamslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifyParam(pParam(PNView.params[paramidx]),pParam(POView.params[idx]),pstype,psname);
    end;
  end;
end;

procedure TImportDiff.ModifyParam(PNParam, POParam : pParam; PSType, PSName : string);
begin
  StringDiff(PNParam.QueryName, POParam.QueryName, PSType, PSName, 'QueryName');
  StringDiff(PNParam.Caption, POParam.Caption, PSType, PSName, 'Caption');
  StringDiff(PNParam.Datatype, POParam.Datatype, PSType, PSName, 'Datatype');
  StringDiff(PNParam.SourceField, POParam.SourceField, PSType, PSName, 'SourceField');
  StringDiff(PNParam.ParamValue, POParam.ParamValue, PSType, PSName, 'ParamValue');
  BooleanDiff(PNParam.MultiSelect, POParam.MultiSelect, PSType, PSName, 'MultiSelect');
  StringDiff(PNParam.Expression, POParam.Expression, PSType, PSName, 'Expression');
  StringDiff(PNParam.ValidateExpression, POParam.ValidateExpression, PSType, PSName, 'ValidateExpression');
  BooleanDiff(PNParam.Hidden, POParam.Hidden, PSType, PSName, 'Hidden');
  StringDiff(PNParam.ParamSqlName, POParam.ParamSqlName, PSType, PSName, 'ParamSqlName');
  IntegerDiff(PNParam.Decimals, POParam.Decimals, PSType, PSName, 'Decimals');
  BooleanDiff(PNParam.SaveValue, POParam.SaveValue, PSType, PSName, 'SaveValue');
  BooleanDiff(PNParam.DynamicParam, POParam.DynamicParam, PSType, PSName, 'DynamicParam');
  StringDiff(PNParam.ModeOfEntry, POParam.ModeOfEntry, PSType, PSName, 'ModeOfEntry');
  XMLNodeDiff(PNParam.Deps, POParam.Deps, PSType, PSName, 'Deps');
end;


procedure TImportDiff.SubTotalDiff(PNView, POView : TViewDef);
var
  stidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'SubTotal';
  osubtotalslist.Clear;
  nsubtotalslist.Clear;
  for stidx := 0 to PNView.subtotals.Count - 1 do
  begin
    nsubtotalslist.Add(lowercase(pSubTotal(PNView.subtotals[stidx]).BlockedColumn));
  end;
  for stidx := 0 to POView.subtotals.Count - 1 do
  begin
    osubtotalslist.Add(lowercase(pSubTotal(POView.subtotals[stidx]).BlockedColumn));
  end;
  if POView.subtotals.Count >= PNView.subtotals.Count then
  begin
    for stidx := 0 to PNView.subtotals.Count - 1 do
    begin
      psname := osubtotalslist[stidx];
      idx := nsubtotalslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        psname := nsubtotalslist[stidx];
        idx := osubtotalslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifySubTotal(pSubTotal(PNView.subtotals[idx]),pSubTotal(POView.subtotals[stidx]),pstype,psname);
    end;
    for stidx := PNView.subtotals.Count to POView.subtotals.Count - 1 do
    begin
      psname := osubtotalslist[stidx];
      idx := nsubtotalslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifySubTotal(pSubTotal(PNView.subtotals[idx]),pSubTotal(POView.subtotals[stidx]),pstype,psname);
    end;
  end
  else
  begin
    for stidx := 0 to POView.subtotals.Count - 1 do
    begin
      psname := nsubtotalslist[stidx];
      idx := osubtotalslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := osubtotalslist[stidx];
        idx := nsubtotalslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifySubTotal(pSubTotal(PNView.subtotals[stidx]),pSubTotal(POView.subtotals[idx]),pstype,psname);
    end;
    for stidx := POView.subtotals.Count to PNView.subtotals.Count - 1 do
    begin
      psname := nsubtotalslist[stidx];
      idx := osubtotalslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifySubTotal(pSubTotal(PNView.subtotals[stidx]),pSubTotal(POView.subtotals[idx]),pstype,psname);
    end;
  end;
end;

procedure TImportDiff.ModifySubTotal(PNSubTotal, POSubTotal : pSubTotal; PSType, PSName : string);
begin
  StringDiff(PNSubTotal.CaptionColumn, POSubTotal.CaptionColumn, PSType, PSName, 'CaptionColumn');
  StringDiff(PNSubTotal.HeaderCaption, POSubTotal.HeaderCaption, PSType, PSName, 'HeaderCaption');
  StringDiff(PNSubTotal.FooterCaption, POSubTotal.FooterCaption, PSType, PSName, 'FooterCaption');
  BooleanDiff(PNSubTotal.LineSpace, POSubTotal.LineSpace, PSType, PSName, 'LineSpace');
  StringDiff(PNSubTotal.OPCaption, POSubTotal.OPCaption, PSType, PSName, 'OPCaption');
  StringDiff(PNSubTotal.ClCaption, POSubTotal.ClCaption, PSType, PSName, 'ClCaption');
  BooleanDiff(PNSubTotal.LineSeperator, POSubTotal.LineSeperator, PSType, PSName, 'LineSeperator');
  StringDiff(PNSubTotal.TotalOrder, POSubTotal.TotalOrder, PSType, PSName, 'TotalOrder');
  BooleanDiff(PNSubTotal.PageSkip, POSubTotal.PageSkip, PSType, PSName, 'PageSkip');
  XMLNodeDiff(PNSubTotal.Advanced, POSubTotal.Advanced, PSType, PSName, 'Advanced');
  BooleanDiff(PNSubTotal.TotalOnTop, POSubTotal.TotalOnTop, PSType, PSName, 'TotalOnTop');
end;

procedure TImportDiff.ButtonDiff(PNView, POView : TViewDef);
var
  btnidx, idx : Integer;
  pstype,psname : string;
begin
  pstype := 'Button';
  obuttonslist.Clear;
  nbuttonslist.Clear;
  for btnidx := 0 to PNView.buttons.Count - 1 do
  begin
    nbuttonslist.Add(lowercase(pButton(PNView.buttons[btnidx]).Caption));
  end;
  for btnidx := 0 to POView.buttons.Count - 1 do
  begin
    obuttonslist.Add(lowercase(pButton(POView.buttons[btnidx]).Caption));
  end;
  if POView.buttons.Count >= PNView.buttons.Count then
  begin
    for btnidx := 0 to PNView.buttons.Count - 1 do
    begin
      psname := obuttonslist[btnidx];
      idx := nbuttonslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        psname := nbuttonslist[btnidx];
        idx := obuttonslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(CreatedDetail);
          CreatedDetail.SType := pstype;
          CreatedDetail.SName := psname;
          pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        end;
      end
      else
        ModifyButton(pButton(PNView.buttons[idx]),pButton(POView.buttons[btnidx]),pstype,psname);
    end;
    for btnidx := PNView.buttons.Count to POView.buttons.Count - 1 do
    begin
      psname := obuttonslist[btnidx];
      idx := nbuttonslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(DeletedDetail);
        DeletedDetail.SType := pstype;
        DeletedDetail.SName := psname;
        pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
      end
      else
        ModifyButton(pButton(PNView.buttons[idx]),pButton(POView.buttons[btnidx]),pstype,psname);
    end;
  end
  else
  begin
    for btnidx := 0 to POView.buttons.Count - 1 do
    begin
      psname := nbuttonslist[btnidx];
      idx := obuttonslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
        psname := obuttonslist[btnidx];
        idx := nbuttonslist.IndexOf(psname);
        if idx = -1 then
        begin
          new(DeletedDetail);
          DeletedDetail.SType := pstype;
          DeletedDetail.SName := psname;
          pStructDiff(StructDiff).DeletedDetailList.Add(DeletedDetail);
        end;
      end
      else
        ModifyButton(pButton(PNView.buttons[btnidx]),pButton(POView.buttons[idx]),pstype,psname);
    end;
    for btnidx := POView.buttons.Count to PNView.buttons.Count - 1 do
    begin
      psname := nbuttonslist[btnidx];
      idx := obuttonslist.IndexOf(psname);
      if idx = -1 then
      begin
        new(CreatedDetail);
        CreatedDetail.SType := pstype;
        CreatedDetail.SName := psname;
        pStructDiff(StructDiff).CreatedDetailList.Add(CreatedDetail);
      end
      else
        ModifyButton(pButton(PNView.buttons[btnidx]),pButton(POView.buttons[idx]),pstype,psname);
    end;
  end;
end;

procedure TImportDiff.ModifyButton(PNButton, POButton : pButton; PSType, PSName : string);
begin
  BooleanDiff(PNButton.Hidden, POButton.Hidden, PSType, PSName, 'Hidden');
  StringDiff(PNButton.Details, POButton.Details, PSType, PSName, 'Details');
  BooleanDiff(PNButton.OptionType, POButton.OptionType, PSType, PSName, 'OptionType');
  BooleanDiff(PNButton.OptionValue, POButton.OptionValue, PSType, PSName, 'OptionValue');
end;

procedure TImportDiff.ClearLists;
var
  i : Integer;
begin
  if Assigned(StructDiffList) then begin
    for i:= StructDiffList.Count-1 downto 0 do
    begin
      try
        if assigned(pStructDiff(StructDiffList[i]).LogSQLScript) then
          pStructDiff(StructDiffList[i]).LogSQLScript.Free;
      except
        pStructDiff(StructDiffList[i]).LogSQLScript := nil;
      end;
      try
        if assigned(pStructDiff(StructDiffList[i]).CreatedDetailList) then
          pStructDiff(StructDiffList[i]).CreatedDetailList.Free;
      except
        pStructDiff(StructDiffList[i]).CreatedDetailList := nil;
      end;
      try
        if assigned(pStructDiff(StructDiffList[i]).DeletedDetailList) then
          pStructDiff(StructDiffList[i]).DeletedDetailList.Free;
      except
        pStructDiff(StructDiffList[i]).DeletedDetailList := nil;
      end;
      try
        if assigned(pStructDiff(StructDiffList[i]).ModifiedDetailList) then
          pStructDiff(StructDiffList[i]).ModifiedDetailList.Free;
      except
        pStructDiff(StructDiffList[i]).ModifiedDetailList := nil;
      end;
      try
        Dispose(pStructDiff(StructDiffList[i]));
      except
      end;
    end;
  end;
  StructDiffList.Clear;
end;

procedure TImportDiff.WriteDiffinExcelFile(filename : string);
var
  hrow : Integer;
  XL : OleVariant;
  achar, rowstr : string;
  fontname, fontcolor : string;
  errorhcolor, createdhcolor, deletedhcolor, modifiedhcolor : string;
  i, j : Integer;
  trnsid : string;
  styp : string;
  errormsg,exporttoxl : string;
const
  xlBottom = -4107;
  xlLeft = -4131;
  xlRight = -4152;
  xlTop = -4160;
  // Text Alignment
  xlHAlignCenter = -4108;
  xlVAlignCenter = -4108;
  // Cell Borders
  xlThick = 4;
  xlThin = 2;
Begin
  try
  if filename = '' then
    Raise Exception.Create('File Name empty');
  if not FromService then begin
    if assigned(WriteStatus) then
      WriteStatus('Preparing the Comparison Report');
  end;
  fontname := 'Calibri';
  fontcolor := 'ClBlack';
  errorhcolor := 'ClRed';
  createdhcolor := 'ClGreen';
  deletedhcolor := 'ClRed';
  modifiedhcolor := 'ClYellow';
  axpro.dbm.gf.dodebug.msg('Creating OLE Excel Object');
  XL := CreateOLEObject('Excel.Application');
  XL.WorkBooks.Add;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].ColumnWidth  := 15;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].ColumnWidth  := 20;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].ColumnWidth  := 15;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].ColumnWidth  := 15;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].ColumnWidth  := 20;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].ColumnWidth  := 40;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].ColumnWidth  := 40;
  
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[1].Interior.Color := ClWhite;

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[2].Interior.Color := ClWhite;

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[3].Interior.Color := ClWhite;  

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[4].Interior.Color := ClWhite;  

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[5].Interior.Color := ClWhite;

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[6].Interior.Color := ClWhite;  

  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].Font.Name := fontname;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].Font.Color := StringtoColor(fontcolor);
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].Font.Size := 8;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].Font.Bold := False;
  XL.Workbooks[1].WorkSheets[1].Columns.Columns[7].Interior.Color := ClWhite;  
  
  // Title Row Caption
  hrow := 1;
  rowstr := inttostr(hrow);
  achar := 'A'+rowstr;
  XL.Range[achar,achar].Value := 'Transid';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'B'+rowstr;
  XL.Range[achar,achar].Value := 'Name';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'C'+rowstr;
  XL.Range[achar,achar].Value := 'Type';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'D'+rowstr;
  XL.Range[achar,achar].Value := 'Status';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'E'+rowstr;
  XL.Range[achar,achar].Value := 'Property';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'F'+rowstr;
  XL.Range[achar,achar].Value := 'Old Value';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;

  achar := 'G'+rowstr;
  XL.Range[achar,achar].Value := 'New Value';
  XL.Range[achar,achar].Font.Name := fontname;
  XL.Range[achar,achar].Font.Color := StringtoColor(fontcolor);
  XL.Range[achar,achar].Font.Size := 9;
  XL.Range[achar,achar].Font.Bold := True;
  
  for i := 0 to StructDiffList.Count - 1 do
  begin
    trnsid := pStructDiff(StructDiffList[i]).Transid;
    styp := pStructDiff(StructDiffList[i]).Stype;
    if not FromService then
    begin
      if styp = 'TStruct' then
      begin
        if SelectedTStruct.IndexOf(lowercase(trnsid)) = -1 then
          continue;
      end
      else if styp = 'IView' then
      begin
        if SelectedIview.IndexOf(lowercase(trnsid)) = -1 then
          continue;
      end;
    end;
    errormsg := pStructDiff(StructDiffList[i]).ErrorMsg;
    if trim(errormsg) <> '' then
    begin
      hrow := hrow + 1;
      rowstr := inttostr(hrow);
      achar := 'A'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(errorhcolor);
      XL.Range[achar,achar].Value := trnsid;
      achar := 'B'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(errorhcolor);      
      XL.Range[achar,achar].Value := trnsid;
      achar := 'C'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(errorhcolor);      
      XL.Range[achar,achar].Value := 'TStruct';
      achar := 'D'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(errorhcolor);      
      XL.Range[achar,achar].Value := 'Failed due to exception - '+errormsg;
      continue;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).CreatedDetailList.Count - 1 do
    begin
      hrow := hrow + 1;
      rowstr := inttostr(hrow);
      achar := 'A'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(createdhcolor);
      XL.Range[achar,achar].Value := trnsid;
      achar := 'B'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(createdhcolor);
      XL.Range[achar,achar].Value := pCreatedDetail(pStructDiff(StructDiffList[i]).CreatedDetailList[j]).SName;
      achar := 'C'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(createdhcolor);      
      XL.Range[achar,achar].Value := pCreatedDetail(pStructDiff(StructDiffList[i]).CreatedDetailList[j]).SType;
      achar := 'D'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(createdhcolor);      
      XL.Range[achar,achar].Value := 'New';
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).DeletedDetailList.Count - 1 do
    begin
      hrow := hrow + 1;
      rowstr := inttostr(hrow);
      achar := 'A'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(deletedhcolor);      
      XL.Range[achar,achar].Value := trnsid;
      achar := 'B'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(deletedhcolor);
      XL.Range[achar,achar].Value := pDeletedDetail(pStructDiff(StructDiffList[i]).DeletedDetailList[j]).SName;
      achar := 'C'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(deletedhcolor);      
      XL.Range[achar,achar].Value := pDeletedDetail(pStructDiff(StructDiffList[i]).DeletedDetailList[j]).SType;
      achar := 'D'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(deletedhcolor);      
      XL.Range[achar,achar].Value := 'Deleted';
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).UnModifiedDetailList.Count - 1 do
    begin
      hrow := hrow + 1;
      rowstr := inttostr(hrow);
      achar := 'A'+ rowstr;
      XL.Range[achar,achar].Value := trnsid;
      achar := 'B'+ rowstr;
      XL.Range[achar,achar].Value := pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SName;
      achar := 'C'+ rowstr;
      XL.Range[achar,achar].Value := pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SType;
      achar := 'D'+ rowstr;
      XL.Range[achar,achar].Value := 'Same';
      achar := 'E'+ rowstr;
      XL.Range[achar,achar].Value := pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SProperty;
      achar := 'F'+ rowstr;
      XL.Range[achar,achar].Value := pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SValue;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).ModifiedDetailList.Count - 1 do
    begin
      hrow := hrow + 1;
      rowstr := inttostr(hrow);
      achar := 'A'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := trnsid;
      achar := 'B'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);
      XL.Range[achar,achar].Value := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SName;
      achar := 'C'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SType;
      achar := 'D'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := 'Modified';
      achar := 'E'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SProperty;
      achar := 'F'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).OldValue;
      achar := 'G'+ rowstr;
      XL.Range[achar,achar].Interior.Color := StringtoColor(modifiedhcolor);      
      XL.Range[achar,achar].Value := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).NewValue;
    end;
  end;
  if FileExists(filename) then
    DeleteFile(filename);
  XL.ActiveWorkBook.SaveAs(filename);
  if not VarIsEmpty(XL) then
  begin
    XL.DisplayAlerts := False;  // Discard unsaved files....
    XL.Quit;
    XL := Unassigned;
  end;
    except on e: Exception do
    begin
      if not VarIsEmpty(XL) then
       begin
         XL.DisplayAlerts := False;  // Discard unsaved files....
         XL.Quit;
         XL := Unassigned;
       end;
    end;
  end;
  if not FromService then      
    WriteStatus('Comparison Report completed');
end;

procedure TImportDiff.DecodeAndExecuteSQLScripts(PTransid, PStype : string);
var
  i, j : Integer;
  trnsid : string;
  styp : string;
  scripttype : string;
  scriptparamstr : string;
begin
  for i := 0 to StructDiffList.Count - 1 do
  begin
    trnsid := pStructDiff(StructDiffList[i]).Transid;
    styp := pStructDiff(StructDiffList[i]).Stype;
    if lowercase(trnsid) <> lowercase(PTransid) then continue;
    if styp <> PStype then continue;
    for j := 0 to pStructDiff(StructDiffList[i]).LogSQLScript.Count - 1 do
    begin
      scripttype := pStructDiff(StructDiffList[i]).LogSQLScript.Names[j];
      scriptparamstr := pStructDiff(StructDiffList[i]).LogSQLScript.ValueFromIndex[j];
      DecodeAndExecute(scripttype, scriptparamstr);
    end;
  end;
end;

procedure TImportDiff.DecodeAndExecute(PScriptType, PScriptParamstr : string);
begin
  if PScriptType = 'CreateField' then
  begin
    AxpCreateorEditField(PScriptType, PScriptParamstr);
  end
  else if PScriptType = 'DeleteFields' then
  begin
    AxpDeleteFields(PScriptParamstr);
  end
  else if PScriptType = 'EditField' then
  begin
    AxpCreateorEditField(PScriptType, PScriptParamstr);
  end  
  else if PScriptType = 'AddConstraint' then
  begin
    AxpAddConstraint(PScriptParamstr);
  end
  else if PScriptType = 'CreateTable' then
  begin
    AxpCreateTable(PScriptParamstr);
  end
  else if PScriptType = 'DropTable' then
  begin
    AxpDropTable(PScriptParamstr);
  end
  else if PScriptType = 'Query' then
  begin
    AxpExecSQL(PScriptParamstr);
  end;
end;

procedure TImportDiff.AxpCreateorEditField(PScriptType, PScriptParamstr : string);
var
  TableName, FName, DType : string;
  FWidth, FDec : Integer;
begin
  TableName := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  FName := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  DType := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  FWidth := StrToInt(Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1));
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  FDec := StrToInt(PScriptParamstr);
  try
    if PScriptType = 'CreateField' then
      Axpro.CreateField(TableName, FName, DType, FWidth, FDec)
    else if PScriptType = 'EditField' then
      Axpro.EditField(TableName, FName, DType, FWidth, FDec)
  except
  end;
end;

procedure TImportDiff.AxpDeleteFields(PScriptParamstr : string);
var
  TableName, FName : string;
begin
  TableName := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  FName := PScriptParamstr;
  try
    Axpro.Deletefields(TableName, FName);
  except
  end;
end;

procedure TImportDiff.AxpAddConstraint(PScriptParamstr : string);
var
  TableName, Constraints : string;
begin
  TableName := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  Constraints := PScriptParamstr;
  try
    Axpro.AddConstraint(TableName, Constraints);
  except
  end;
end;

procedure TImportDiff.AxpCreateTable(PScriptParamstr : string);
var
  TableName, FName : string;
begin
  TableName := Copy(PScriptParamstr, 1, pos('<<<>>>', PScriptParamstr)-1);
  Delete(PScriptParamstr, 1, (pos('<<<>>>', PScriptParamstr)+5));
  FName := PScriptParamstr;
  try
    Axpro.CreateTable(TableName, FName);
  except
  end;
end;

procedure TImportDiff.AxpDropTable(PScriptParamstr : string);
var
  TableName : string;
begin
  TableName := PScriptParamstr;
  try
    Axpro.DropTable(TableName);
  except
  end;
end;

procedure TImportDiff.AxpExecSQL(PScriptParamstr : string);
var
  SQLText : string;
begin
  SQLText := PScriptParamstr;
  try
    Axpro.ExecSQL(SQLText, '', '', False);
  except
  end;
end;

procedure TImportDiff.ImportListView(PFileName : string);
var
  LXML : IXMLDocument;
  ts : TStringlist;
  ltransid,lcaption : string;
begin
  ts := TStringlist.Create;
  ts.LoadFromFile(PFileName,TEncoding.UTF8);
  LXML := LoadXMLData(ts.Text);
  if not FromService then begin
    if assigned(WriteStatus) then
      WriteStatus('Importing ListView for TStruct - '+transid+' ('+caption+')');
  end;
  ltransid := vartostr(LXML.DocumentElement.Attributes['name']);
  lcaption := vartostr(LXML.DocumentElement.Attributes['caption']);
  UpDateDateFields(LXML);
  axpro.SetStructure('lviews',ltransid, lcaption,'all',ltransid,'', lxml);
  if FromService then
  begin
    if fileexists(PFileName) then
      DeleteFile(PFileName);
    if (Not IsAxpDefStructure) then
    begin
      if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
        DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
    end;
  end;
  ts.Free;
end;

function TImportDiff.GetPrintDocCaption(PFileName : string) : string;
var
  fname : string;
  p : Integer;
begin
  Result := '';
  fname := ExtractFileName(PFileName);
  p := pos('$',fname);
  if p=0 then exit;
  Result := copy(fname,p+1,length(fname)-(p+4));
end;

function TImportDiff.GetPrintDocTransid(PFileName : string) : string;
var
  fname : string;
  p : Integer;
begin
  Result := '';
  fname := ExtractFileName(PFileName);
  p := pos('$',fname);
  if p=0 then exit;
  Result := trim(copy(fname,1,p-1));
end;

procedure TImportDiff.ImportNonPDFPrintDocs(PFileName, PTransid : string);
var
  cap : string;
  fname : string;
  prndoctype : string;
begin
  if ExtractFileExt(PFileName)='.prt' then
    fname := copy(PFileName,1,length(PFileName)-4) + '.trt'
  else if ExtractFileExt(PFileName)='.pdo' then
    fname := copy(PFileName,1,length(PFileName)-4) +  '.tdo'
  else if ExtractFileExt(PFileName)='.pwd' then
    fname := copy(PFileName,1,length(PFileName)-4) +  '.twd';
  ptransid := 't'+trim(ptransid);
  FileContent.Clear;
  FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
  if FileContent.Count = 0 then
  begin
    WriteToLog('Invalid Print Form: '+PFileName);
    exit;
  end;
  FXML := LoadXMLData(FileContent.Text);
  cap := FXML.DocumentElement.Attributes['caption'];
  prndoctype := FXML.DocumentElement.Attributes['doctype'];
  if (prndoctype = 'D') or (prndoctype = 'M') then
  begin
    axpro.bImportPrintDoc := true;
    FXML.DocumentElement.Attributes['filename']:=fname;
    try
      WriteToLog('');
      if prndoctype = 'D' then
      begin
        if not FromService then begin
          if assigned(WriteStatus) then
             WriteStatus('Importing Dos Print Format - '+cap);
        end;
        WriteToLog('Importing Dos Print Format from : '+PFileName)
      end
      else
      begin
       if not FromService then begin
          if assigned(WriteStatus) then
             WriteStatus('Importing MS Word Print Format - '+cap);
       end;
        WriteToLog('Importing MS Word Print Format from : '+PFileName);
      end;
      axpro.SetPrintTemplate(cap,ptransid,prndoctype,FXML);
      if FromService then
      begin
        if fileexists(PFileName) then
          DeleteFile(PFileName);
        if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
          DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
        if fileexists(FName) then
          DeleteFile(FName);
        if fileexists(FImpDir + 'c__'+ExtractFileName(FName)) then
          DeleteFile(FImpDir + 'c__'+ExtractFileName(FName));
      end;
      except
      on e : Exception do
        axpro.bImportPrintDoc := false;
    end;
    axpro.bImportPrintDoc := false;
  end
  else
  begin
    FXML.DocumentElement.Attributes['filename']:=fname;
    if not FromService then begin
      if assigned(WriteStatus) then
         WriteStatus('Importing RTF Print Format - '+cap);
    end;
    WriteToLog('');
    WriteToLog('Importing RTF Print Format from : '+PFileName);
    axpro.SetPrintTemplate(cap,ptransid,prndoctype,FXML);
    if FromService then
    begin
      if fileexists(PFileName) then
        DeleteFile(PFileName);
      if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
        DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
      if fileexists(FName) then
        DeleteFile(FName);
      if fileexists(FImpDir + 'c__'+ExtractFileName(FName)) then
        DeleteFile(FImpDir + 'c__'+ExtractFileName(FName));
    end;
  end;
end;

procedure TImportDiff.ImportPDFPrintDocs(PFileName, PTransid : string);
var
  cap : string;
begin
  cap := GetPrintDocCaption(PFileName);
  FileContent.Clear;
  FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
  FXML := LoadXMLData(FileContent.Text);
  if not FromService then begin
    if assigned(WriteStatus) then
       WriteStatus('Importing PDF Print Format - '+cap);
  end;
  WriteToLog('');
  WriteToLog('Importing PDF Print Format from : '+PFileName);
  UpDateDateFields(FXML);
  axpro.SetStructure('PDFPRops',cap,cap,FXML,True);
  axpro.ExecSQL('update pdfprops set transid='+Quotedstr(ptransid)+' where name='+Quotedstr(cap),'','',false);
  if FromService then
  begin
    if fileexists(PFileName) then
      DeleteFile(PFileName);
    if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
      DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
  end;
end;

procedure TImportDiff.ImportFastReport(PFileName, PTransid : string);
var
  cap,Where,OutPut : string;
begin
  cap := GetPrintDocCaption(PFileName);
  OutPut :=GetFastReportOutput(cap);
  Delete(Cap,pos('$',Cap),length(cap));
  if not FromService then begin
    if assigned(WriteStatus) then
       WriteStatus('Importing PDF Print Format - '+cap);
  end;
  WriteToLog('');
  WriteToLog('Importing Fast Report Format from : '+PFileName);

  Cxds.close;
  Cxds.Submit('caption',cap,'c');
  Cxds.AddOrEdit('Axpertreports',Axpro.dbm.gf.SQLLower+'(caption)='+QuotedStr(LowerCase(cap)));
  Cxds.close;

  where:='caption = '+quotedStr(cap);
  WriteFRXToDB(where,cap,PFileName);
  //axpro.dbm.WriteBlob('design','axpertreports',where,PFileName);

  Cxds.Submit('caption',cap,'c');
  Cxds.Submit('transid',PTransid,'c');
  Cxds.Submit('output',OutPut,'c');
  where :=Axpro.dbm.gf.SQLLower+'(caption)='+QuotedStr(LowerCase(cap))+' and '+Axpro.dbm.gf.SQLLower+'(transid)='+QuotedStr(LowerCase(PTransid));
  Cxds.AddOrEdit('Axfastlink',where);
  Cxds.close;
  if FromService then
  begin
    if fileexists(PFileName) then
      DeleteFile(PFileName);
    if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
      DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
  end;
end;

function TImportDiff.GetFastReportOutput(PFileName : string) : string;
var
  p : Integer;
begin
  Result := '';
  p := pos('$$',PFileName);
  if p=0 then exit;
  Result := copy(PFileName,p+2,length(PFileName));
end;


procedure TImportDiff.ImportPage(PFileName : string);
var
  cap, ptransid : string;
  imgname,visible,temp,Parentname,ptype,Pagename,ophead,pgtype,OldParent,Ordnum : string;
  oldordno,lvno : Integer;
  AlreadyImported : Boolean;
  IsTransidSelected : Boolean;
  XmlOrdNo,XmlLevelno:Integer;
  POrno,Pendnode:Integer;
  Sql,IsPagefound,OldParentName:string;
  xmlfilepath:string;
  xmlfilename:string;
begin
  OldParentName := '';
  {$IFNDEF ForService}
    FileContent.Clear;
    FileContent.LoadFromFile(PFileName,TEncoding.UTF8);
    FXML := LoadXMLData(FileContent.Text);
  {$ENDIF}
  xmlfilename:='c__'+ExtractFilename(PFileName);
  xmlfilename:=ChangeFileExt(xmlfilename,'.xml');
  xmlfilepath:=ExtractFilePath(PFileName)+xmlfilename;
  FXML := LoadXMLData(TFile.ReadAllText(xmlfilepath));
  ENode := FXML.DocumentElement;
  ptransid := ENode.Attributes['name'];
  if FromService then
    IsTransidSelected := True
  else
    IsTransidSelected := SelectedPage.IndexOf(lowercase(ptransid)) <> -1;
  if IsTransidSelected then
  begin
    if not FromService then begin
       if assigned(StepIt) then
         StepIt;
    end;

    AlreadyImported := ImportedPages.IndexOf(lowercase(PTransid)) <> -1;
    if AlreadyImported then exit;
    cap := ENode.Attributes['caption'];
    if not assigned(pinfo) then
    begin
      pinfo:=TStringlist.Create;
    end;
    Parentname := vartostr(FXML.DocumentElement.Attributes['parent']);         // by ar ..

    OldParentName :=  GetParent(ptransid, Parentname);
    FXML.DocumentElement.Attributes['parent'] := OldParentName;
    Parentname := OldParentName;

    if vartostr(FXML.DocumentElement.Attributes['ordno'])<>'' then
      XmlOrdNo:= strtoint(vartostr(FXML.DocumentElement.Attributes['ordno']))             // get order no from xml
    else
      XmlOrdNo:=0;
    if vartostr(FXML.DocumentElement.Attributes['levelno'])<>'' then
      XmlLevelno:= strtoint(vartostr(FXML.DocumentElement.Attributes['levelno']))          // get level no from xml
    else
      XmlLevelno:=0;
    UpDateDateFields(FXML);
    axpro.SetStructure('axpages',ptransid,cap,FXML,True);
    if FromService then
    begin
      if fileexists(PFileName) then
        DeleteFile(PFileName);
      if (Not IsAxpDefStructure) then
      begin
        if fileexists(FImpDir + 'c__'+ExtractFileName(PFileName)) then
          DeleteFile(FImpDir + 'c__'+ExtractFileName(PFileName));
      end;
    end;
    ImportedPages.Add(PTransid);
    imgName := vartostr(FXML.DocumentElement.Attributes['img']);
    visible := vartostr(FXML.DocumentElement.Attributes['visible']);
    ptype := vartostr(FXML.DocumentElement.Attributes['ptype']);
    pgtype := vartostr(FXML.DocumentElement.Attributes['pgtype']);
    Pagename := ptransid;
    Axpro.dbm.gf.DoDebug.Msg('updating axpages...');
    try
    Ixds := Axpro.dbm.GetXDS(nil);
    Ixds.buffered := true;
    Ixds.CDS.CommandText := 'update axpages set parent='+quotedstr(Parentname)+',img='+Quotedstr(imgname)
                             +',visible='+quotedstr(visible)+',type='+Quotedstr(ptype)+',pagetype='+Quotedstr(pgtype)+' where name='+Quotedstr(Pagename);
    if axpro.dbm.gf.remotelogin then
      Ixds.open
    else
      Ixds.CDS.execute;
    Except
      On E:Exception do
      begin
        Axpro.dbm.gf.DoDebug.Msg('Error: '+E.Message);
        Axpro.dbm.gf.DoDebug.Msg(Ixds.CDS.CommandText);
      end;
    end;
    if ptype = 'p' then
      UpdatePageDetails(FXML,ptransid);

//    if OldParentName = '' then
//    begin
//      sql := 'insert into axpagedetail(name,sname,stype) values ('+quotedstr(ptransid)+','+
//               Quotedstr(copy(pgtype,2,length(pgtype)))+','+Quotedstr(copy(pgtype,1,1))+')';
//      axpro.ExecSQL(sql,'','',false);
//    end;
    Axpro.dbm.gf.DoDebug.Msg('Adding page info');
    pinfo.Add(Inttostr(XmlOrdNo)+','+Pagename+','+Parentname);  // pinfo(Orderno from xml,Pagename,Parent)
    Ixds.Destroy;
    Ixds:=nil;
    selected_struct := true;
  end;
end;

function compare(List: TStringList; Index1, Index2: Integer): Integer;
var
  n1, n2: integer;
begin
  n1 := StrToInt(Copy(List[Index1], 1, pos(',',List[Index1]) - 1));
  n2 := StrToInt(Copy(List[Index2], 1, pos(',',List[Index2]) - 1));
  result := n1 - n2;
end;

procedure TImportDiff.CreateNewPageOrder;
var
  i : integer;
  pagename,Parent,s,ordrno: string;
  Sorted:TstringList;
  newlvlno,Pendnode:integer;
begin
  Axpro.dbm.gf.DoDebug.Msg('');
  Axpro.dbm.gf.DoDebug.Msg('Before Sorting page order from xml : ');
  Axpro.dbm.gf.DoDebug.Msg('');
  Axpro.dbm.gf.DoDebug.Msg(pinfo.CommaText);
  pinfo.CustomSort(compare);
  Axpro.dbm.gf.DoDebug.Msg('');
  Axpro.dbm.gf.DoDebug.Msg('After Sorting page order from xml : ');
  Axpro.dbm.gf.DoDebug.Msg('');
  Axpro.dbm.gf.DoDebug.Msg(pinfo.CommaText);
  Axpro.dbm.gf.DoDebug.Msg('');
  for  i := 0 to pinfo.Count-1 do begin
    s := pinfo[i]+',';
   // ordrno:= copy(s,1,pos(',',s)-1);
    s := copy(s,pos(',',s)+1,length(s));
    pagename := copy(s,1,pos(',',s)-1);
    s := copy(s,pos(',',s)+1,length(s));
    Parent := copy(s,1,pos(',',s)-1);
    InserOrderNo(pagename,Parent);
  end;
  pinfo.Clear;
  pinfo.Free;
  pinfo := nil;
end;

procedure TImportDiff.InserOrderNo(Pagename, ParentName: string);
var
  OrderNo,Sql,IsPagefound, pname :string;
begin

  x1.close;
  x1.CDS.CommandText  := 'select parent, ordno from axpages where '+axpro.dbm.gf.sqllower+'(name)=' + QuotedStr(lowercase(Pagename));
  x1.open;

  if not x1.CDS.IsEmpty  then begin
    OrderNo :=x1.CDS.FieldByName('ordno').AsString;
    pname   :=x1.CDS.FieldByName('parent').AsString;
    if (ParentName <> pname) or (OrderNo = '') then
//    if OrderNo ='' then                       // if the Page is not avilable
    begin
      if Parentname<>'' then begin
        Sql:='select * from axpages where name= '+QuotedStr(Parentname); // orderno of the parent
        IsPagefound:=GetPageflds(sql,'name');
        if IsPagefound <> '' then begin
          OrderWithParent(Parentname,Pagename);
          SetLevelNo(Pagename);
        end
        else begin
          OrderWithOutParent(Pagename);
          SetLevelNo(Pagename);
        end
      end
      else begin
        OrderWithOutParent(Pagename);
        SetLevelNo(Pagename);
      end;
    end;
  end;
end;

procedure TImportDiff.OrderWithParent(parent_name,page_name:string);
var ParentOrdno,EndOrdNo:integer;
  sql,temp,tLevel:string;
begin
 Sql:='select ordno,levelno from axpages where name= '+QuotedStr(parent_name);
 temp := Trim(GetPageflds(Sql,'ordno'));   /// getting  order no of the parent
 tLevel := Trim(GetPageflds(Sql,'levelno'));
 if temp <>'' then begin
   ParentOrdno:= Strtoint(temp);
   EndOrdNo:=GetEndNodeOrdno(ParentOrdno);                  // getting maximum child order no for a parent
   if (EndOrdNo=0) then
     EndOrdNo:=ParentOrdno;

   Sql:='select ordno from axpages where ordno >= '+ InttoStr(ParentOrdno) +' and levelno <= '+ tLevel +
   ' and '+Axpro.dbm.gf.sqllower+'(name) <> '+ quotedstr(LowerCase(parent_name))+' and visible = ''T'' order by ordno';
   temp := Trim(GetPageflds(Sql,'ordno'));
   if (Strtoint(temp)- EndOrdNo)<2 then
   begin
    sql:='update axpages set ordno=ordno+1 where ordno>'+inttostr(EndOrdNo);
    SetOrderNo(sql);
   end;

   sql:='update axpages set ordno = '+inttostr(EndOrdNo+1)+' where name = '+QuotedStr(page_name);
   SetOrderNo(sql);
 end
 else begin
   OrderWithOutParent(page_name);
 end;
end;

function TimportDiff.GetEndNodeOrdno(MaxOrdno:integer):integer;
var pname,sql,temp:string;
first:boolean;
begin
result:=0;
first:=true;
 while ((MaxOrdno<>0) or (first))do begin
  (*
  This functionality is to find the Max(ordno) In the current Parent/Folder/Menu.
  But some existing menus were updated wrongly, TStruct page has another Tstruct as a parent, and its updated in the
  AxPages.  Even type updated as 'h' for the pages.
  To avoid those menus while finding MaxOrdno, we modified the query.
  *)
  (*
  //Old code
  first:=false;
  Sql :='Select name from axpages where ordno = '+QuotedStr(IntTostr(MaxOrdno));
  pname:=GetPageflds(Sql,'name');
  sql:='select max(ordno) cnt from axpages where parent='+QuotedStr(pname);
  temp := trim(GetPageflds(sql,'cnt'));
  *)
  //Modified code
  first:=false;  temp := '';
  Sql :='Select name from axpages where ordno = '+QuotedStr(IntTostr(MaxOrdno))+
        ' and (name not like ''PageTs%'' and name not like ''PageIv%'' )'; //skip normal pages (tstruct/iview pages)
  //In the below statement we are getting parent name | Page cannot be parent so in the above query we filtered pages
  pname:=GetPageflds(Sql,'name');
  if pname <> '' then
  begin
    sql:='select max(ordno) cnt from axpages where parent='+QuotedStr(pname);
    temp := trim(GetPageflds(sql,'cnt'));
  end;
  if temp <>'' then
    Maxordno:= StrToInt(temp)
  else
    Maxordno :=0;
  if MaxOrdno<> 0 then
   result:=Maxordno;
 end;
end;


procedure TImportDiff.OrderWithOutParent(page_name:string);
var MaxOrdno,OldOrdno,EndOrdNo,Newordno:integer;
  sql,temp:string;
begin
 Sql:='select max(ordno) cnt from axpages where '+axpro.dbm.gf.sqlnull+'(ordno,0)>0';
 temp := Trim(GetPageflds(Sql,'cnt'));
 if temp<>'' then
   MaxOrdno:=StrtoInt(temp)
 else
   MaxOrdno :=0;
 Newordno:=MaxOrdno+1;
 Sql:='update axpages set ordno = '+inttostr(Newordno)+',Parent='''' where name = '+QuotedStr(page_name);
 SetOrderNo(sql);
end;

procedure TImportDiff.SetOrderNo(Sql:string);
begin
 x1.close;
 x1.CDS.CommandText:= Sql;
 x1.CDS.Execute;
 x1.close;
end;

procedure TImportDiff.SetLevelNo(PageName:string);
var ParentLvlno,levelNo:integer;
Parent_name,sqltext,temp:string;
begin
 sqltext:='select parent from axpages where name= '+QuotedStr(pagename);
 Parent_name:=GetPageflds(sqltext,'parent');
 if Parent_Name<>'' then begin
  sqltext :='Select levelno from axpages where name = '+Quotedstr(Parent_name);
  temp :=Trim(GetPageflds(sqltext,'levelno'));
  if Temp <>'' then begin
    ParentLvlno :=StrToInt(Temp);
    levelNo :=ParentLvlno +1;
  end
  else begin
    levelNo :=0;
  end;
 end
 else
  levelNo:=0;

 x1.close;
 x1.CDS.CommandText:='update axpages set levelno = '+inttostr(levelNo)+' where name ='+QuotedStr(PageName);
 X1.CDS.Execute;
 x1.close;
end;

function TImportDiff.GetPageflds(Sql:string;fld:string):string;
begin
 x1.close;
 x1.CDS.CommandText:= Sql;
 x1.open;
 result:=x1.CDS.FieldByName(fld).AsString;
 x1.close;
end;


procedure TImportDiff.DestroyTStruct;
begin
  if assigned(OldDBCall) then
    OldDBCall.Destroy;
  OldDBCall := nil;
  OldStruct := nil;
  if assigned(NewDBCall) then
    NewDBCall.Destroy;
  NewDBCall := nil;
  NewStruct := nil;
end;

procedure TImportDiff.DestroyIView;
begin
  if assigned(OldView) then
    OldView.Destroy;
  OldView := nil;
  if assigned(NewView) then
    NewView.Destroy;
  NewView := nil;
end;


procedure TImportDiff.WriteToLog(s:string);
begin
  if assigned(WriteLog) then
    WriteLog(s)
  else
    Axpro.dbm.gf.DoDebug.Log(s);
end;

Procedure TImportDiff.UpdateAxp_Versions;
var Errorstr,Sql,Tablestr,t,Whr:string;
begin
  try
    Errorstr :='';
    x1.close;
    Sql:='Select * from axp_versions where 1=2';
    x1.CDS.CommandText :=Sql;
    x1.open;
  Except on E:Exception do
    Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    x1.close;
    Tablestr := Axpro.GetJoinStr('verno','c',50,0)+','+Axpro.GetJoinStr('domainname','c',50,0)+','+Axpro.GetJoinStr('servername','c',50,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('publishedon','c',50,0)+','+Axpro.GetJoinStr('publishedby','c',30,0)+','+Axpro.GetJoinStr('publishedfrom','c',20,0)+','+Axpro.GetJoinStr('comments','T',1,0)+','+Axpro.GetJoinStr('blobno','n',3,0);
    Axpro.CreateTable('axp_versions',Tablestr);
  end;
  Cxds.close;
  Whr := Axpro.dbm.gf.SQLLower+'(verno)'+' = '+QuotedStr(Lowercase(verno));
  Cxds.Submit('verno',verno,'c');
  Cxds.Submit('domainname',domain,'c');
  Cxds.Submit('servername','','c');
  t := Axpro.dbm.gf.convertToDBDateTime(Axpro.dbm.connection.dbtype,Axpro.dbm.getserverdatetime);
  Cxds.Submit('publishedon',t,'c');
  Cxds.Submit('publishedby',publishedby,'c');
  Cxds.Submit('publishedfrom',publishedfrom,'c');
  Cxds.AddOrEdit('axp_versions',whr);
  Axpro.dbm.WriteCLOB('comments','axp_versions',whr,Comments);

end;


Procedure TImportDiff.UpdateAxp_VersionChanges;
begin
  if ImportedTStructs.Count>0 then
    SubmitAxp_VersionChanges('tstructs',ImportedTStructs);

  if ImportedIViews.Count>0 then
    SubmitAxp_VersionChanges('iviews',ImportedIViews);

  if ImportedPages.Count>0 then
    SubmitAxp_VersionChanges('axpages',ImportedPages);

end;


Procedure TImportDiff.UpdateAxp_VersionChangeDetails;
var i ,j:Integer;
trnsid,styp,errormsg,Errorstr,Errorstr1,sql,Tablestr,Whr,oldval,newval,propertyval,nam,status :string;
begin
  try
    Errorstr :='';
    x1.close;
    Sql:='Select * from axp_versionchangedetails where 1=2';
    x1.CDS.CommandText :=Sql;
    x1.open;
  Except on E:Exception do
    Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    x1.close;
    Tablestr := Axpro.GetJoinStr('verno','c',50,0)+','+Axpro.GetJoinStr('transid','c',50,0)+','+Axpro.GetJoinStr('name','c',200,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('stype','c',100,0)+','+Axpro.GetJoinStr('status','c',20,0)+','+Axpro.GetJoinStr('property','c',100,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('oldvalue','c',250,0)+','+Axpro.GetJoinStr('newvalue','c',250,0)+','+Axpro.GetJoinStr('blobno','n',3,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('oldvalueclob','T',1,0)+','+Axpro.GetJoinStr('newvalueclob','T',1,0);
    Axpro.CreateTable('axp_versionchangedetails',Tablestr);
  end;

 for i := 0 to StructDiffList.Count - 1 do
 begin
  try
    trnsid := pStructDiff(StructDiffList[i]).Transid;
    styp := pStructDiff(StructDiffList[i]).Stype;
    if not FromService then
    begin
      if styp = 'TStruct' then
      begin
        if SelectedTStruct.IndexOf(lowercase(trnsid)) = -1 then
          continue;
      end
      else if styp = 'IView' then
      begin
        if SelectedIview.IndexOf(lowercase(trnsid)) = -1 then
          continue;
      end;
    end;
    errormsg := pStructDiff(StructDiffList[i]).ErrorMsg;
    if trim(errormsg) <> '' then
    begin
      try
        Errorstr1 :='';
        whr :='';
        whr :=Axpro.dbm.gf.SQLLower+'(verno) = '+QuotedStr(Lowercase(Trim(verno)))+' and '+Axpro.dbm.gf.SQLLower+'(transid) = '+QuotedStr(Lowercase(trim(trnsid)));
        Cxds.close;
        Cxds.Submit('verno',Verno,'c');
        Cxds.Submit('transid',trnsid,'c');
        Cxds.Submit('name',trnsid,'c');
        Cxds.Submit('stype','TStruct','c');
        Cxds.Submit('status','Failed due to exception - '+errormsg,'c');
        Cxds.Submit('property','','c');
        Cxds.Submit('oldvalue','','c');
        Cxds.Submit('newvalue','','c');
        Cxds.AddOrEdit('axp_versionchangedetails',whr);
        Cxds.close;
        continue;
      Except on E:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then begin
        Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails by ErrorMsgList :'+Errorstr1);
        Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
        Continue;
      end;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).CreatedDetailList.Count - 1 do
    begin
      try
        Errorstr1 :='';
        nam := pCreatedDetail(pStructDiff(StructDiffList[i]).CreatedDetailList[j]).SName;
        whr :='';
        whr :=Axpro.dbm.gf.SQLLower+'(verno) = '+QuotedStr(Lowercase(Trim(verno)))+' and '+Axpro.dbm.gf.SQLLower+'(transid) = '+QuotedStr(Lowercase(trim(trnsid)));
        whr :=Whr+' and '+Axpro.dbm.gf.SQLLower+'(name) = '+QuotedStr(Lowercase(trim(nam)));
        status :='New';
        Cxds.close;
        Cxds.Submit('verno',Verno,'c');
        Cxds.Submit('transid',trnsid,'c');
        Cxds.Submit('name',nam,'c');
        Cxds.Submit('stype',pCreatedDetail(pStructDiff(StructDiffList[i]).CreatedDetailList[j]).SType,'c');
        Cxds.Submit('status',status,'c');
        Cxds.Submit('property','','c');
        Cxds.Submit('oldvalue','','c');
        Cxds.Submit('newvalue','','c');
        Cxds.AddOrEdit('axp_versionchangedetails',whr);
        Cxds.close;
      Except on E:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then begin
        Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails by CreatedDetailList :'+Errorstr1);
        Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
        Continue;
      end;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).DeletedDetailList.Count - 1 do
    begin
      try
        Errorstr1 :='';
        nam := pDeletedDetail(pStructDiff(StructDiffList[i]).DeletedDetailList[j]).SName;
        whr :='';
        whr :=Axpro.dbm.gf.SQLLower+'(verno) = '+QuotedStr(Lowercase(Trim(verno)))+' and '+Axpro.dbm.gf.SQLLower+'(transid) = '+QuotedStr(Lowercase(trim(trnsid)));
        whr :=whr+' and '+Axpro.dbm.gf.SQLLower+'(name) = '+QuotedStr(Lowercase(trim(nam)));
        status :='Deleted';
        Cxds.close;
        Cxds.Submit('verno',Verno,'c');
        Cxds.Submit('transid',trnsid,'c');
        Cxds.Submit('name',nam,'c');
        Cxds.Submit('stype',pDeletedDetail(pStructDiff(StructDiffList[i]).DeletedDetailList[j]).SType,'c');
        Cxds.Submit('status',status,'c');
        Cxds.Submit('property','','c');
        Cxds.Submit('oldvalue','','c');
        Cxds.Submit('newvalue','','c');
        Cxds.AddOrEdit('axp_versionchangedetails',Whr);
        Cxds.close;
      Except on E:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then begin
        Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails  by DeletedDetailList :'+Errorstr1);
        Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
        Continue;
      end;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).UnModifiedDetailList.Count - 1 do
    begin
      try
        Errorstr1 :='';
        nam := pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SName;
        propertyval:=pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SProperty;
        oldval :=pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SValue;
        whr :='';
        whr :=Axpro.dbm.gf.SQLLower+'(verno) = '+QuotedStr(Lowercase(Trim(verno)))+' and '+Axpro.dbm.gf.SQLLower+'(transid) = '+QuotedStr(Lowercase(trim(trnsid)));
        whr :=Whr+' and '+Axpro.dbm.gf.SQLLower+'(name) = '+QuotedStr(Lowercase(trim(nam)))+' and '+Axpro.dbm.gf.SQLLower+'(property) = '+QuotedStr(Lowercase(trim(propertyval)));;
        status :='Same';

        Cxds.close;
        Cxds.Submit('verno',Verno,'c');
        Cxds.Submit('transid',trnsid,'c');
        Cxds.Submit('name',nam,'c');
        Cxds.Submit('stype',pUnModifiedDetail(pStructDiff(StructDiffList[i]).UnModifiedDetailList[j]).SType,'c');
        Cxds.Submit('status',status,'c');
        Cxds.Submit('property',propertyval,'c');

        if length(oldval)>200 then begin
          Cxds.AddOrEdit('axp_versionchangedetails',whr);
          Cxds.close;
          Axpro.dbm.WriteCLOB('oldvalueclob','axp_versionchangedetails',whr,oldval);
        end
        else begin
          Cxds.Submit('oldvalue',oldval,'c');
          Cxds.Submit('newvalue','','c');
          Cxds.AddOrEdit('axp_versionchangedetails',whr);
          Cxds.close;
        end;
      Except on E:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then begin
        Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails  by UnModifiedDetailList :'+Errorstr1);
        Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
        Continue;
      end;
    end;
    for j := 0 to pStructDiff(StructDiffList[i]).ModifiedDetailList.Count - 1 do
    begin
      try
        Errorstr1 :='';
        nam := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SName;
        propertyval :=pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SProperty;
        oldval := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).OldValue;
        newval := pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).NewValue;

        whr :='';
        whr :=Axpro.dbm.gf.SQLLower+'(verno) = '+QuotedStr(Lowercase(Trim(verno)))+' and '+Axpro.dbm.gf.SQLLower+'(transid) = '+QuotedStr(Lowercase(trim(trnsid)));
        whr :=Whr+' and '+Axpro.dbm.gf.SQLLower+'(name) = '+QuotedStr(Lowercase(trim(nam)))+' and '+Axpro.dbm.gf.SQLLower+'(property) = '+QuotedStr(Lowercase(trim(propertyval)));
        status :='Modified';
        Cxds.close;
        Cxds.Submit('verno',Verno,'c');
        Cxds.Submit('transid',trnsid,'c');
        Cxds.Submit('name',nam,'c');
        Cxds.Submit('stype',pModifiedDetail(pStructDiff(StructDiffList[i]).ModifiedDetailList[j]).SType,'c');
        Cxds.Submit('status',status,'c');
        Cxds.Submit('property',propertyval,'c');

        if ((length(oldval)>200) or (length(newval)>200)) then begin
          Cxds.AddOrEdit('axp_versionchangedetails',whr);
          Cxds.close;
          Axpro.dbm.WriteCLOB('oldvalueclob','axp_versionchangedetails',whr,oldval);
          Axpro.dbm.WriteCLOB('newvalueclob','axp_versionchangedetails',whr,newval);
        end
        else begin
          Cxds.Submit('oldvalue',oldval,'c');
          Cxds.Submit('newvalue',newval,'c');
          Cxds.AddOrEdit('axp_versionchangedetails',whr);
          Cxds.close;
        end;
      Except on E:Exception do
        Errorstr1 :=e.Message;
      end;
      if Errorstr1<>'' then begin
        Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails  by ModifiedDetailList :'+Errorstr1);
        Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
        Continue;
      end;
    end;
  Except on e:Exception do
    Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    Axpro.dbm.gf.DoDebug.Msg(' Exception in updating Axp_versionchangedetails :'+Errorstr);
    Axpro.dbm.gf.DoDebug.Msg(' Transid :'+trnsid+' Name :'+nam+' Status :'+status+' Property :'+propertyval+' Oldvalue :'+oldval+' Newvalue :'+newval);
    Continue;
  end;
 end;
end;


procedure TImportDiff.SubmitAxp_VersionChanges(Tablenm:string; Strlist: TStringlist);
var
  I: Integer;
  TempList :Tstringlist;
  Errorstr,Sql,Tablestr,Whr,Stype,val:string;
begin
  TempList :=TStringList.Create;
  TempList.Clear;
  for I := 0 to Strlist.Count-1 do begin
    val :=Lowercase(QuotedStr(Strlist.Strings[i]));
    TempList.Add(val);
  end;

  try
    Errorstr :='';
    x1.close;
    Sql:='Select * from axp_versionchanges where 1=2';
    x1.CDS.CommandText :=Sql;
    x1.open;
  Except on E:Exception do
    Errorstr :=e.Message;
  end;
  if Errorstr<>'' then begin
    x1.close;
    Tablestr := Axpro.GetJoinStr('verno','c',50,0)+','+Axpro.GetJoinStr('stype','c',20,0)+','+Axpro.GetJoinStr('name','c',20,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('caption','c',50,0)+','+Axpro.GetJoinStr('createdby','c',25,0)+','+Axpro.GetJoinStr('createdon','c',25,0);
    Tablestr :=Tablestr +','+Axpro.GetJoinStr('updatedby','c',25,0)+','+Axpro.GetJoinStr('updatedon','c',25,0);
    Axpro.CreateTable('Axp_versionchanges',Tablestr);
  end;
  Sql :='';
  if Tablenm='tstructs' then
    Stype :='tstruct'
  else if Tablenm='iviews' then
    Stype :='iview'
  else if Tablenm='axpages' then
    Stype :='page';


  sql:='Select name,caption,createdby,createdon,updatedby,updatedon from '+Tablenm+' where '+Axpro.dbm.gf.SQLLower+'(name) in ('+TempList.CommaText+')';
  x1.CDS.CommandText :=sql;
  x1.open;
  while not x1.CDS.Eof do begin
    Cxds.close;
    Whr :=Axpro.dbm.gf.SQLLower+'(name)'+' = '+QuotedStr(Lowercase(x1.CDS.FieldByName('name').AsString));
    Cxds.Submit('verno',Verno,'c');
    Cxds.Submit('stype',Stype,'c');
    Cxds.Submit('name',x1.CDS.FieldByName('name').AsString,'c');
    Cxds.Submit('caption',x1.CDS.FieldByName('caption').AsString,'c');
    Cxds.Submit('createdby',x1.CDS.FieldByName('createdby').AsString,'c');
    Cxds.Submit('createdon',x1.CDS.FieldByName('createdon').AsString,'c');
    Cxds.Submit('updatedby',x1.CDS.FieldByName('updatedby').AsString,'c');
    Cxds.Submit('updatedon',x1.CDS.FieldByName('updatedon').AsString,'c');
    Cxds.AddOrEdit('axp_versionchanges',Whr);
    x1.CDS.Next;
  end;
 X1.close;
 Cxds.close;
 if Assigned(Templist) then Freeandnil(TempList);
end;
function TImportDiff.GetParent(pagename, parentname : string) : string;
begin
  result := '';
  x1.close;
  if (parentname <> '') then
  begin
    x1.CDS.CommandText  := 'select parent from axpages where '+axpro.dbm.gf.sqllower+'(name)=' + QuotedStr(lowercase(parentname));
    x1.cds.open;
    if x1.cds.recordcount > 0 then
      result := parentname;
    x1.close;
  end;

  if (result = '') then
  begin
    x1.close;
    x1.CDS.CommandText  := 'select parent from axpages where '+axpro.dbm.gf.sqllower+'(name)=' + QuotedStr(lowercase(Pagename));
    x1.cds.open;
    if x1.cds.recordcount > 0 then
      result := x1.cds.fieldbyname('parent').AsString;
    x1.close;
  end;
end;

procedure TImportDiff.UpdateDateFields(iXML :IXmlDocument);
var
  Source_Structure_DbType,C_On,Imp_On,Updt_On : String;
begin
  Source_Structure_DbType := lowercase(vartostr(iXML.DocumentElement.Attributes['dbtype']));
  if (Source_Structure_DbType <> Axpro.dbm.Connection.dbtype) and (Source_Structure_DbType <> '') then
  begin
    C_On := vartostr(iXML.DocumentElement.Attributes['createdon']);
    Imp_On := vartostr(iXML.DocumentElement.Attributes['importedon']);
    Updt_on :=   vartostr(iXML.DocumentElement.Attributes['updatedon']);
    iXML.DocumentElement.Attributes['updatedon'] := ConvertToDBDateString(Source_Structure_DbType,Updt_On);
    iXML.DocumentElement.Attributes['createdon'] := ConvertToDBDateString(Source_Structure_DbType,C_On);;
    iXML.DocumentElement.Attributes['importedon'] := ConvertToDBDateString(Source_Structure_DbType,Imp_On);
  end;
end;

function TImportDiff.ConvertToDBDateString(dbtype,dstring:string):string;
var
  DTime : TDateTime;
  date_string : string;
begin
  if dstring <> '' then
  begin
    if length(dstring) > 10 then dstring := copy(dstring,1,10);
    date_string := Axpro.dbm.gf.ToShortDateFormat(dbtype,dstring);
    result := Axpro.dbm.gf.ConvertToDBDateTime(Axpro.dbm.Connection.dbtype,strtodate(date_string))
  end
  else result := Axpro.dbm.gf.convertToDBDateTime(Axpro.dbm.connection.dbtype,Axpro.dbm.getserverdatetime);
end;

procedure TImportDiff.WriteToTraceFile(fd:pfld;OWidth,est :string);
begin
  if assigned(writelog) then
  begin
    errmsg := errmsg +#$D#$A+est+ #$D#$A +'Structure Name :'+ Caption +' ['+transid+']';
    errmsg := errmsg + #$D#$A + 'Table Name :'+fd.TableName;
    errmsg := errmsg + #$D#$A + 'Column Name :'+fd.FieldName;
    errmsg := errmsg + #$D#$A + 'New Width :'+inttostr(fd.width);
    errmsg := errmsg + #$D#$A + 'Old Width :'+OWidth;
    errmsg := errmsg + #$D#$A;
  end;
end;

procedure TImportDiff.WriteFRXToDB(whrstr,FastReportCaption,PFileName:string);
var Axfast:TAxfastRun;
  sfile,tfile,frxpath,ErrorMsg:string;
begin
  try
    ErrorMsg:='';
    frxpath:=Axpro.dbm.gf.StartPath+'temp\Frxtemp\';
    if not DirectoryExists(frxpath) then ForceDirectories(frxpath);
    sfile:=PFileName;
    tfile:=frxpath+FastReportCaption+'.'+'WTDB';
    Axfast:=TAxfastRun.create(Axpro);
    Axfast.WriteFastReport(whrstr,sfile,tfile);
  Except on e:exception do
    ErrorMsg:=e.Message;
  end;
  if Assigned(Axfast) then  Freeandnil(Axfast);
  if ErrorMsg <> '' then raise Exception.Create(ErrorMsg);
end;


procedure TImportDiff.UpdatePageDetails(PXML:IXMLDocument;PageName:String);
var i : integer;
    cat, typ, nm, sqlstring, ErrStr : string;
    IsFound : Boolean;
begin
  try
    for i := 0 to PXML.DocumentElement.ChildNodes.Count-1 do
    begin
      cat := vartostr(PXML.DocumentElement.ChildNodes[i].Attributes['cat']);
      typ := '';
      nm := '';
      if cat='iview' then
      begin
        typ := 'i';
        nm  := vartostr(PXML.DocumentElement.ChildNodes[i].Attributes['name']);
      end
      else if cat = 'tstruct' then
      begin
        typ := 't';
        nm  := vartostr(PXML.DocumentElement.ChildNodes[i].Attributes['transid']);
      end
      else if cat='tree' then
      begin
        typ := 'r';
        nm  := vartostr(PXML.DocumentElement.ChildNodes[i].Attributes['transid']);
      end;
      if (typ='') or (nm='')  then continue;
      IsFound := CheckInPageDetails(PageName,typ+nm);
      if not IsFound then
      begin
        sqlstring := 'insert into axpagedetail(name,sname,stype) values ('+quotedstr(PageName)+','+
                     Quotedstr(nm)+','+Quotedstr(typ)+')';
        Axpro.ExecSQL(sqlstring,'','',false);
      end;
    end;
  except on e:exception do
    begin
      if assigned(Axpro) then begin
        Errstr:=Axpro.dbm.gf.Axp_logstr+'\uPagedesign\SavePageStruct - '+e.Message;
        Axpro.dbm.gf.DoDebug.Log(Errstr);
      end;
    end;
  end;
end;

function TImportDiff.CheckInPageDetails(pagename, pagetype : string) : Boolean;
var ErrStr : String;
begin
  try
  result := False;
  x1.close;
  x1.CDS.CommandText  := 'select namet from axpagedetails where '+axpro.dbm.gf.sqllower+'(name)=' + QuotedStr(lowercase(Pagename))
       +axpro.dbm.gf.sqllower+'(sname)=' + QuotedStr(lowercase(PageType));
  x1.cds.open;
  if x1.cds.recordcount > 0 then
    result := true;
  x1.close;
  except on e:exception do
    begin
      if assigned(Axpro) then begin
        Errstr:=Axpro.dbm.gf.Axp_logstr+'\uPagedesign\CheckInPageDetails - '+e.Message;
        Axpro.dbm.gf.DoDebug.Log(Errstr);
      end;
    end;
  end;
end;



procedure TImportDiff.ImportStructure(FormName:String; SXML:IXMLDocument; fextn:String='trn');
var FName : String;
begin

  FXML := SXML;
  FName := FormName+'.'+fextn;
  SelectedTStruct.Add(FormName);
  try
    if FromService then
      StructureDiff(FImpDir + FName)
    else
      StructureDiff(FName);
    WriteToLog(FName+ 'Imported');
  except on e:Exception do
    begin
      WriteToLog(FName+ 'Import Failed. Error: '+e.Message);
    end;
  end;

end;

procedure TImportDiff.ImportAutoPage(PageName:String; PXML:IXMLDocument);
var FName : String;
begin
  FXML := PXML;
  FName := PageName+'.pge';
  SelectedPage.Add('PageTs'+PageName);
  try
    if FromService then
    begin
      StructureDiff(FImpDir + FName);
      {$IFDEF ForService}
      CreateNewPageOrder;
      {$ENDIF}
    end
    else
      StructureDiff(FName);
    WriteToLog(FName+ 'Imported');
  except on e:Exception do
    begin
      WriteToLog(FName+ 'Import Failed');
    end;
  end;

end;


// ImportStructXMLandCreateTransactionTables
(*
  Purpose of this procedure is to Import structure XML and Create Transaction tables.
  This is implemented for DWB purpose.
  When importing structure to APPSCHEMA this functionality will be called.
  So only required data at RUNTIME will be imported through this procedure.

  (required data at runtime = Structure XML + Transation Tables + Pages + Listview)
*)
Procedure TImportDiff.ImportStructXMLandCreateTransactionTables
  (sTransid: String; SXML: IXMLDocument);
var
  bCanExit: Boolean;
  sdef : TStructdef;
begin
  try
    StructInTable := nil;
    try
      axpro.dbm.gf.DoDebug.Msg('Executing ImportStructXMLandCreateTransactionTables...');
      WritetoLog('Executing ImportStructXMLandCreateTransactionTables...');
      // Assign / Init required values
      FXML := SXML;
      Transid := sTransid;
      InitTstructDetails(FXML);
      nschemaname := '';
      axpro.dbm.gf.DoDebug.Msg('Executing CreateStructDiff...');
      // Creates objects for comparing struct diff
      CreateStructDiff(FXML);

      // Compare structdiff
      axpro.dbm.gf.DoDebug.Msg('Comparing structdiff...');
      bCanExit := TStructDiff(FXML);
      if not bCanExit then
      begin
        nschemaname := NewStruct.schemaname;
        oschemaname := OldStruct.schemaname;
        ntransid := NewStruct.Transid;
        otransid := OldStruct.Transid;
        nprimarytable := NewStruct.primarytable;
        oprimarytable := OldStruct.primarytable;
        // DO DC diff and modify if any diff found
        DCDiff(NewStruct, OldStruct);
        // DO Field diff and modify if any diff found
        FieldDiff(NewStruct, OldStruct);
        // DO FillGrid diff and modify if any diff found
        FillGridDiff(NewStruct, OldStruct);
        // DO MDMap diff and modify if any diff found
        MDMapDiff(nmdmapdefs, omdmapdefs);
        // DO GenMap diff and modify if any diff found
        GenMapDiff(ngenmapsdrecs, ogenmapsdrecs);
        if Axpro.dbm.gf.IsService then
        begin
          if (servicename = 'WriteTStructDef') then
            OnCreateTStruct(NewStruct, pStructDiff(StructDiff).LogSQLScript);
        end;
        //Reverted the changes , DestroyTStruct statement added here.
	DestroyTStruct;
      end;

      ErrorMessage := StructDiff.ErrorMsg;
      axpro.dbm.gf.DoDebug.Msg('StructDiff ErrorMessage '+ErrorMessage);
      // If no error / canExit false then Call SetStructure to update structure
      if (not bCanExit) or (ErrorMessage = '') then
      begin
        // DecodeAndExecuteSQLScripts(Transid, 'TStruct');
        // Prepare dependencies and update in XML
        StoreDependencies.SXML := FXML;
        StoreDependencies.Transid := Transid;
        StoreDependencies.StoreDependencies;
        StoreDependencies.ClearValues;
        WritetoLog('');
        WritetoLog('Transid : ' + Transid);
        WritetoLog('Caption : ' + Caption);
        // Update date fields
        UpdateDateFields(FXML);
        axpro.dbm.gf.DoDebug.Msg('Updating tstructs table');
        // Set Structure - To Add /update structure in tstructs table

//ForAxInstaller - To update only importedon (not updatedon) during the installation of structure
{$IFDEF ForAxInstaller}
    Axpro.SetStructure('tstructs', Transid, Caption, FXML, false);
{$ELSE}
    {$IFNDEF ForService}
        Axpro.SetStructure('tstructs', Transid, Caption, FXML, true);
    {$ELSE}
        Axpro.SetStructure('tstructs', Transid, Caption, FXML, false);
    {$ENDIF}
{$ENDIF}


//{$IFNDEF ForService}
//        Axpro.SetStructure('tstructs', Transid, Caption, FXML, true);
//{$ELSE}
//        Axpro.SetStructure('tstructs', Transid, Caption, FXML, false);
//{$ENDIF}
        // Create SeqInfo for transid
        OnCreateSeqInfo(Transid, nschemaname, FXML);
        (*
        StructInTable.Structwise - Add Tstruct details into Axpert default tables.
        As of now we are updating only AxpFlds,axpmdmaps&axpgenmaps for Axpert Rule Engine purpose.
        If required other tables needs to be updated.
        *)
        try
          axpro.dbm.gf.DoDebug.Msg('Updating StructInTable');
          sdef := nil;
          sdef := TStructdef.Create(Axpro,Transid,'','',FXML);
          StructInTable := TStructInTable.create(Axpro);
          (*
          Assigning NewStruct to sdef is commented, because for new trans NewStruct will be nil.
          So instead of  NewTstruct we created sdef object here.
          *)
          //StructInTable.sdef := NewStruct;
          StructInTable.sdef := sdef;
          //Delete data from axpflds,axpdc,axpmdmaps,axpgenmaps & axpgenmapdtl table, if data exists
          Axpro.ExecSQL('delete from axpflds where tstruct = '+quotedstr(Transid),'','',False);
          Axpro.ExecSQL('delete from axpdc where tstruct = '+quotedstr(Transid),'','',False);
          Axpro.ExecSQL('delete from axpmdmaps where tstruct = '+quotedstr(Transid),'','',False);
          Axpro.ExecSQL('delete from axpgenmaps where tstruct = '+quotedstr(Transid),'','',False);
          Axpro.ExecSQL('delete from axpgenmapdtl where tstruct = '+quotedstr(Transid),'','',False);
          //StructInTable.Structwise(Transid); //Update all Axpert core tables
          StructInTable.saveflds(Transid); //flds
          StructInTable.saveDC(Transid); //dcs
          StructInTable.savemdmaps(Transid); //mdmaps
          StructInTable.savegenmaps(Transid); //genamaps
        finally
          If Assigned(sdef) then
            FreeAndNil(sdef);
        end;
      end;
    Except
      on e: Exception do
      begin
        WritetoLog('Error in ImportStructXMLandCreateTransactionTables ' +
          e.message);
        axpro.dbm.gf.DoDebug.Msg('Error in ImportStructXMLandCreateTransactionTables ' +
          e.message);
      end;
    end;
  finally
    if Assigned(StructInTable) then
      FreeAndNil(StructInTable);
  end;
end;


end.
