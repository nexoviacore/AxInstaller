Unit uGeneralFunctions;
{Copied from Axpert9-XE3\Ver 11.1}
Interface
Uses System.SysUtils, Dialogs, math, controls, db, forms, StdCtrls, ExtCtrls, Graphics,
Classes, buttons, windows, ComCtrls, checklst, Grids, dbgrids, mask,
DateUtils, Masks, IniFiles, Menus, dbclient, XMLDoc, XMLIntf, Variants, WinSock,
SoapHTTPClient, uDoDebug,IdGlobal,SHELLAPI,strutils, uCompress,IdStack,TlHelp32,
uAES
  {$IFNDEF NOT ForRestDll}
    ,Redis.Client , Redis.netlib.INDY, Redis.Commons
    {$IFDEF ABOVE_DXE8}//FOR ABOVE XE8 VERSION
    ,Redis.Values
    {$ENDIF}
  {$ENDIF};

type

TPickListMode = (plmStartwith, plmAnywhere, plmEndsWith, plmNone);
type TSetChar = set of Char;

pColData = ^TColData;
TColData = record
  columnname, datatype, ctype , alignment, ColumnHeading, colour, fontname, fontcolor,click,dblclick,beforefill,font,color,langcaption   : String;
  displayexprn, width, columnno, exprid,  decimals, QIndex, VIndex, fontsize,groupno,HlinkColNo,pvcolno : integer;
  RunningTotal, ComputePost, ZeroOff, SetFactor, norepeat, hidden, displaytotal, applycomma, fontbold, fontstrike, fontunderline, fontitalic, colseperator,encrypted,freezecol : boolean;
  QuerySQLName, Expr, DisplayExpr,tablename,searchname,groupheading , actname ,maskchar,maskroles,masking,firstcharmask,lastcharmask,negativerep  : String;
  calculatetime : AnsiString;
  cellFont, hlinknode : ixmlnode;
end;
pEventRec = ^TEventRec;
TEventRec = record
  Event : String;
  Element : String;
  Action : String;
end;

pTaskRec = ^TTaskRec;
TTaskRec = record
  Name : String;
  Shortcut : Word;
  Caption : String;
  Comp : TComponent;
  OnExecute : TNotifyEvent;
  CompName : String;
  ScutComb : String;
end;

pStatusRec = ^TStatusRec;
TStatusRec = record
  Comp : TComponent;
  Visible : Boolean;
  Enabled : Boolean;
  FldName : String;
  Hidden  : Boolean;
  ReadOnly: Boolean;
  TabStop : Boolean;
  ColNo   : Integer;
  ColWidth: Integer;
  ParentName :String;
  Font : TFont;
  colorstr : String; //ch1
end;

PDependRec = ^TDependRec;
TDependRec = Record
  ParentName : String;
  CList : TStringList;
end;

pDetailRec=^TDetailRec;
TDetailRec=record
  RowNo : Integer;
  FList : TList;
  Recordid : Extended;
end;
pAutoGenRec = ^TAutoGenRec;
TAutoGenRec = Record
  Transid, FieldName,  Prefix, Schema, TableName, RType, Expression, SQLString,
     MemNo, ParentTransid, ParentFldName, Value, PrefixField: String;
  RecordId : Extended;
  Rowno : Integer;
  ParentList : TStringList;
  Active : Boolean;
  RecordidUpdated : Boolean;
End;

TTransRec = packed record
Lang,             // language code
CharSet: Word;    // character set (code page)
end;

PTransRec = ^TTransRec;
TTransRecArray = array of TTransRec;

TSend = (NewTran, DelTran, CancelTran);
TOnLoadtstruct = procedure(pname, pcaption, optiontype, framename:String) of object;
TOnDoAction = procedure(n:IXMLNode) of object;
TOnCallAction=function(sender:TObject; s:String;n:ixmlnode) : String of object;
TOnActivate=procedure(s:String) of object;
THContext=(hcNone, hcCellClick, hcIViewDisplay, hcDataLoad, hcValueChange, hcFieldEnter);
TDoHyperLink=function(sender:TObject; name:String):boolean of object;
TDoShowRealted=function(sender:TObject; name:String):boolean of object;
TDoActionPageLoad=function(sender:TObject; name,task:String;n:ixmlnode):boolean of object;
TOnStructBtnClick=procedure(callframe:TFrame; btn:TSpeedButton; n,act:ixmlnode) of object;
//TOnEditStruct=procedure(callframe:TFrame) of object; //ch1
TOnEditStruct=procedure(sname,stype,caption : string) of object;
TOnLabelClick=procedure(Sender:TObject) of object;
TOnShowTSruct= function(pname, container: String):pointer of object ;
TOnShowIView= function(pname, container: String):pointer of object ;
TOnAcceptParams=procedure of object;
TComboChange=procedure(Sender : TObject) of object;
TShowMsgCount=Procedure of Object ;
TValidateSQL=Function(sql:String;fldname:String;cFrom:String):Boolean of object;
TListViewExist=Function(sname:String):boolean of object;
TOnLoadComponent=procedure(tval:TStrings;cat:String) of object;
TGetAccessControlXML = function(stable, stype, sname : String): ixmldocument of object;
TOnCreateFrame=procedure(f:TFrame) of object;
TCallDetailStruct = procedure(FName:String;RowNo:Integer;bShow:Boolean) of object;
TResetStatus = procedure(sType:String) of object;
TFillOnClickFields = procedure(tval:TStrings) of object;
TCallPopupForm = Procedure(FName:String;RowNo:Integer) of object;
TShowGridCalender = procedure(Cobj : TObject;FldName : String) of object;
THideGridCalender = procedure() of object;
TOnGetActionObj=function() : TObject of object;
TUpdateChanges = procedure(SqlText:String) of object;
TFormatNumericData = function(FldName,txt:String):String of object;
TShowSearchWindow = Procedure (obj:TObject;Value:String) of object;
TSiteLicUpdate = procedure() of object;
TSaveForm = Procedure(FormName:String) of object;


type
  TGeneralFunctions = class
  private

    IsConnectMap : Boolean;
    Axp_MapDriveLetter : String;
    numbers       : TSetChar;
    DayLen, MonLen, YearLen : integer;
    redis_errmsg : String;


    {$IFNDEF  NOT ForRestDll}
      FRedis: IRedisClient;
    {$ENDIF}

    function GetTranslation(Idx: Integer; fTransTable: TTransRecArray): string;
    function GetTransTable(const Buffer: Pointer): TTransRecArray;
    function GetVerInfoStr(const Buffer: Pointer; const Trans,
      StrName: string): string;
    function ConnectMap(const sRemoteName, sLocalDrive, sUserName,
      sPassword: string): Boolean;
    function ChangeTableNametoLowercase(SubStr, Tmp_Str,
      Org_Str: string): String;
    function ReplaceTableName(st_pos: Integer; SubStr, Tmp_Str,
      SQL_Query: String): String;
    function GetDriveLetter: String;
    function GetGMTBias: Integer;
    function EncodeDBID(dtid, dbid: String): String;
    function GetTimeId: string;
    function GetAutoCorrectFmtDate(const ADate, ADateSeparator: string): string;
    function IsValidDate(ADate: String): Boolean;
    procedure ConnectToRedisServer(Host : String;pwd:String='');
    procedure ConnectToRedisServerWithXML(Host : String);
  public
      nownum,Zoomvalue : integer;
      lastnowstring,Applanguage,ReadOnly_FontColor,ReadOnly_BgColor,schemaname,defstrtrns : String;
      UserType, SQLLower, DbDateString , fileverno , appverno , exeverno,forupdate,dbmflag,SqlNull,nullcds,remotedbType,dbdateformat,datemode,AppVarComments : String;
      SiteNo, SesCount,remoteConnectNo : integer;
      Millions, NewGen : boolean;
      GlobalSerialNo, LastConnectNo : extended;
      TraceAppLoad, EvalCopy, AppTerminate, PartnersCopy , SiteCopy : Boolean;
      usercategoryid, userid : integer;
      BaseCurrencyId : Extended;
      companyname, username, usergroup, userroles,inuserroles ,team , usercategory, userdepartment, dbrep, crrep, profitpath, AppTitle, StartPath, dbase,usergroupno,pageaccess : String;
      AxpertPath : String;
      _MainCurr, _SubCurr, _Millions, AppFontCharSet, AppFontName,  currencyname, currencytable, connectionname,projectname  : String;
      AppFontSize : integer;
      _CurrDecimal, LoginLevel : integer;
      finyrst,finyred,afinyrst, afinyred : TDateTime;
      Registered, BtnActions : TStringlist;
      GlobalProps, LocalProps, mailprops : IXMLNode;
      AppXML, AxProps : IXMLDocument;
      HeadColor, GridHeadColor, HeadFont, GridHeadFont, ContainerColor, GridOddRowColor, GridEvenRowColor, defbackcolor : String;
      MailHost, MailPort, MailUserId, MailPassword, MailFrom : String;
      SessionId, AppName, URL, wsdl , axpservice, axpport : String;
      AppVars,UserVars : TStringList;
      AppVarTypes : String;
      AMSCall,AESCall , AMSDataCall : THTTPRIO;
      structURL , dataURL , LicenseURL : String ;
      structGetFrom, structSetTo : String;
      RemoteLogin,KioskLogin : Boolean;
      AcsBuild, AcsManage,AcsTools ,AcsWorkFlow,AcsSend,AcsImportStruct,AcsLanguage,AcsExportStruct,AcsAxpertManager,AcsAppParams, AcsAppManager: Boolean;
      DoDebug : TDoDebug;
      IsService, FillAllFields, ServiceReconnected , ReConnectDB : boolean;
  //    serviceno,IPAddress : String;
      verno : String;
      execActName : String;
      totalmsg,readmsg : integer;
      IcompChanged,TcompChanged : boolean;
      AppfontCDS : TClientDataSet;
      pagination_pageno , pagination_pagesize , pagination_totalrows : integer;
      selectTable : String ; //to use in views for multiselect parameters table name
      listvieworderby : String;
      OraErrFrom,OraErrTo :Extended;
      AxConstraintExist : Boolean;
      PktFolder : String;
      RunMode : Boolean;
      lastlogintime,exepath : String;
      biDirectional : boolean;
      PickListMode : TPickListMode;
      FormLevelPickListMode, CompLevelPickListMode : TPickListMode;
      axpdataexchange, FromAdr : boolean;
      proj_usergroup_cond : String;
      ShowChangePwd : Boolean;
      menu_pnl_width : integer;
      NewTrans, CopyTrans : boolean;
      AppVarsLoadDateTime : TDateTime;
      SysCrossDate : Boolean;
      dbtimetaken,sqltimetaken,dbconnectiontime : integer;
      ShortDateFormat : TFormatSettings;
      AutoMemNo : integer;
      AutoGenData : TList;
      AppTitleFont,Toplinkfont,Titlefont,ToolbarFont,Textfont,RibbonFont,Gridfont:TFont;
      Skinname,Background,ForeColor,GridHead,Fonttype,Bordercolor,Toolbarcolor,TBStartcolor,TBEndColor,PaginationPanelColor,ButCaps,GridColorfromGUI:string;  /// by ar
      d_sessionid : string;
      GFontProps:string;
      DFont:boolean;
      axcloudid,axRegId,axurl:string;
      axpublish:boolean;
      PostAutoGen : Boolean;

      SQLValuePair :TStringlist;
      IViewSQLPagination : Boolean;
      Axp_logstr:string;
      ErrorInActionExecution : String;
      DomainName :String;
      PublishAxprops:Boolean;
      pwdmaxlogintry,pwdexpdays,pwdalterdays,pwdminchars,pwdprevnos,pwdexpdayswithin : integer;
      pwdalphanum : boolean;
      RecordLockedBy,MsSql_Unicode_Char :String;
      Axp_LockOnRead : Boolean;
      Axhelp:boolean;
      defaultdbtimeout:Integer;
      sMapUserName,sMapPassword : String;
      sql_query : string;
      trace_servicesql : boolean;
      LicString,LicDevString,LicLocString,UnlimitedTransIds : String;
      LicActivated : boolean;
      DisplayTotRows, GetTotalRowsForWeb,Axp_Axpertlog,lowercase_tablenames,chkdebug : Boolean;
      Axp_Timeout : Integer;
      CurrencySeparator,currlang: String;
      MaxSiteNo, MaxRecid, LenMaxSiteNo : Integer;
      MaxConnectNo, MaxLastNo : Extended;
      WinUserName : String;
      LocDecimalSeparator, LocThousandSeparator : String;
      DummyDate : String;
      chkbeforlogin, FastDataFlag : Boolean;
      LicSessionTrans , LicWebSessionTrans : integer;
      srlKeyWords : TStringList;
      SiteLicUpdate : TSiteLicUpdate;
      UsedQuotedStr : Boolean;
      MutexFlag , multilingual , ConnectRestDll : Boolean;
      LoginSysIP : string ;
      validatedtopsession,updatepid : boolean;
      UserLevel : integer; // 1 - Builder, 2 - Administrator, 3 - User)
      PerfIview : Boolean;
      MobileWSFlag : Boolean;
      GlobalVarsInSqlParams : TStringList;
      FrPrintPath,ClientIP : String;
      clouddb : AnsiString;
      RaiseErrOnDBReconnect,pwd_AES, ConfigTblFound : Boolean;
      SaveAllImagesInDB : Boolean;
      TransCheckCount : Integer;
      ForRepostGenMaps , breakonerror : Boolean;
      timezone_diff : integer;
      WebAppConXML : iXMLDocument;
      actionName : ansistring;
      postgre_search_path : string;
      WebRedisPwd,WebRedisHost : AnsiString;
      GenMapTrans,Db_Conn_Lost : boolean;
      ServiceName,AxMemVars : String;
      AxRuleNode , AxValErrMsgs , RedisConnXML : ixmlnode;
      bAxPegReadOnlyTrans,bImageFromDB : Boolean;
      sAxPegStatus : String;
      axdecimal : integer;
      AutoselectCompatibility,isSXMLGetFromClient,PushToApiJobs : Boolean;

      constructor Create;
      destructor Destroy; override;
      function ToShortDateFormat(dbtype,MyDate: String): String;
      Function Gen_id(TableName: String; Incr: Integer): Extended;
      function GetLocalSystemName:String;
      Function RealRound(num: extended; d: integer): extended;
      Function IsEmptyValue(Value, DataType: String): String;
      Function GetNthString(SrcString: String; StrPos: integer): String;Overload;
      Function GetNthString(SrcString: String; StrPos: integer; Separator : Char ): String;Overload;
      Function GetNthString(SrcString: String; StrPos: integer; Separator : String): String;Overload;
      Function Pad(S: String; MaxLength: integer; c: Char): String;
      Function LeftPad(S: String; MaxLength: integer; c: Char): String;
      function AddString(str:String;RepeatTime:Integer):String;
      Function FindAndReplace(S:String;FindWhat:String;ReplaceWith: String):String;
      Function InsertCommas(Value: String): String;
      Function RemoveCommas(S: String): String;
      Function TrimToSingleSpace(s:String):String;
      Function RepeatString(s:String;n:Integer):String;
      Function FormatValue(value: String; Declen: integer): String;
      Function RemoveAmpherSand(PString: String): String;
      Function RemoveSlash(PString: String): String;
      Function GetSeperatorCount(Const SrcStr: String; Seperator: char): integer;
//      function CreateQuery(Name, Databasename:String;DM:TDataModule):TQuery;
      function QueryLocate(Q:TClientDataset; FName : String; FValue : Extended):Boolean;
      function strtointz(s:String):integer;
      function strtofloatz(s:String):extended;
      function strtodtz(s:String):TDateTime;
      function GetOptionNamePrefix(OptionType:String) : String;
      Procedure SetRegistry(RegistryString, KeyValue: String);
      Function GetRegistry(RegistryString: String): String;
      function GetKeyCode(KeyString:String) : integer;
      Function RemoveSpace(PString: String): String;
      Function ConvertCRCNo(Total:Integer): Integer;
//      Function GetCRC(Q:TQuery) : integer;
      function IsSysVar(S:String):Boolean;
      function PRound(num:extended;d:integer):extended;
      function getcharacterset(s:String):TFontCharSet;
      Function SplitString(S, Delimiter: String): TStringList;
      Function ReadFileName(FileWithPath: String; Var pFilePath: String):String;
      function MakeFormatString(Width, Decimals:integer):String;
      Procedure ShowPopupMenu(Btn: TSpeedButton; PopMenu: TPopupMenu);
      Procedure ShowPopupMenuB(Btn: TBitBtn; PopMenu: TPopupMenu);

      Procedure IWrite(ININame, Context, RegistryString, KeyValue: String);
      Function IRead(ININame, Context, RegistryString: String): String;
      Function GenerateNumber : extended;
      Function ConvertDateTime(dbtype:String;Dt:TDateTime):String;
      Function SQLTrimLower(dbtype:String):String;
      //Function ConvertDate(dbtype:String;dt:TDateTime):String;
      Function Bool2Str(f:boolean) : String;
      Function Str2Bool(s:String) : boolean;
      Function GetFontProp(xnode:IXMLNode):TFont;
      function SeekNode(N:IXMLNode; Name, Attr, Value:String):IXMLNode;overload;
      function SeekNode(N:IXMLNode; Name, Value:String):IXMLNode;overload;
      function ReplaceStr(s, findstr, replstr:String):String;
      function ReadListFile(filename:String; key:String):String;
      Function GetNumber:String;
      function writenode(pnode: ixmlnode; name, value:String):ixmlnode;
      procedure LoadFont(f:TFont; fontstr,lf:String);overload;
      procedure LoadFont(tf,sf:TFont); overload;
      procedure SaveFont(f, pf:TFont; n:ixmlnode);overload;
      procedure SaveFont(f:TFont; n:ixmlnode); overload;
      function ButtonRegister(cap, act:String):integer;
      procedure ButtonUnRegister(cap:String);
      procedure DrawBorder(pnl:TPanel;clr:TColor;Edges:String);
      Function GetGlobalProperty(propname:String):String;
      function iswincontrol(wc:TObject):boolean;
      function isframe(wc:TObject):boolean;
      function CheckMatch(matchstring, value:String):boolean;
      function GetDefaultImages(iname : String ) : integer;
      procedure SetAppFont(tfrm:TFrame);
      function NowString:String;
      function GridConvert(sg : TStringGrid) : TStringGrid;
      function IsAlphaNumeric(s : String) : Boolean;  overload;
      function IsAlphaNumeric(s,schar : String) : Boolean; overload;
      Function FindNode(n:ixmlnode;name:String):ixmlnode;
      function setColHeadings(cName : String ;fontCDS : TClientDataSet) : String;
      Function setcompprop(cname : String ;fontCDS : TClientDataSet; cmp : TWinControl ) : String;
      function GetDefName(cName : String ;fontCDS : TClientDataSet) : String;
      function UserAccess(cName : String ;fontCDS : TClientDataSet) : Boolean;
      function isValidName(nm : String) : String; overload;
      function isValidName(nm : String; allowed : integer) : String; overload;
      function GetNumericVerNo(verno:String):Extended;
      function GetDataType(fldDataType:TFieldType):String;
      function IsAppVar(S:String):Boolean;
      function ConvertToExprSet(exprstr: String): String;
      function ConvertToExpr(fldname,dtype,op,fldvalue,fldvalue1: String) : String ;
      Procedure ShowPopupMenuUp(Btn: TSpeedButton; PopMenu: TPopupMenu);
      function GetWFString(stint: integer): String;
      function GetWFInt(stat : String) : integer;
      procedure SetBiDiMode(wc: TWinControl);
      function ConvertToDBDateTime(dbtype: String; Dt: TDateTime): String;
      procedure DeleteFilesFromFolder(PathWithPattern:String);
      function GetCondStr(fldname, dtype, op, fldvalue,
          fldvalue1: String): String;
      Procedure ClearAutoGenData(DelModRec:Boolean);
      function RemoveReadOnly(const FileName: String): Boolean;
      function RemoveExtraSpaces(PString: String): String;
      function FileIsReadOnly(FileName: String): boolean;
      procedure Applyskin(color: String);
      procedure StringToFont(sFont: string; Font: TFont);
      function EncryptString(datetime: TDateTime): String;
      function CountNumberOfComma(FieldValue :String ): integer;
      function FormatXmlString(str:String):String;
      function EncryptPassword(Org_Md5_pwd: string; Access_code: string): string;
      function IsDirectoryEmpty(const directory: String): boolean;
      function PosOfLastSeperator(Str, Seperator: String): Integer;
      procedure DeleteDirectories(DirName: String);
      procedure DeleteStructureResource;
      function ShellExecute_WithInfo(FileWithPathName : String):Boolean;
      function FileSize(fileName: wideString): Integer;
      function GetVersion(sFileName: string): string;
      function GetRealExeName: string;
      function CheckForLicenseFile: string;
      function ReadLicFile(licfile: String): TStringList;
      function IsValidEmailid(Mailid :String):boolean;
      function GetFontProps(OrgStr, SearchStr: String): String;
      function GetValueFromStringList(InputStr, ValSide: String): String;
      function AlphaNumericCheck(s: string): Boolean;
      function GetIP: String;
      function SubStringOccurences(const subString, sourceString: string;
         caseSensitive: boolean): integer;
      function getValueBetweenCurlyBraces(dccaptionStr: String): String;
      Function IsAccessiblePath(sPath : String): Boolean;
      function IsDefaultFldName(S: String): Boolean;
      function CheckIfCompressedFile(PFileName: String): Boolean;
      function DeCompressFile(PFileName: String): String;
      procedure GetSortedFileList(fl: TStringList; fpath: String);
      function DisconnectMap(sPath :String;IsInitCall : Boolean = False): Boolean;
      function RemoveSeparator(S: String): String;
      function InsertSeparator(S: String): String;
      function SubTotalColour(FStr: String): String;
      function ColorToHtml(DColor: TColor): string;
      function RemoveDynamicFilterCBraces(Input: string): string;
      Procedure DeleteReadOnlyFile(ReadOnlyFile:String);
      procedure SetConnectVariables;
      function CallChangeTableNametoLowercase(ORG_SQL,Sub_Str:String): String;
      function GetUserFromWindows: string;
      procedure AxpGetLocaleInfo;
      function GMTToLocale(const Value: TDateTime): TDateTime;
      function LocaleToGMT(const Value: TDateTime): TDateTime;
      function IsKeyword(fname: String): Boolean;
      procedure StoreInPercentage(n: ixmlnode; tlhwstr: String; wc: TControl);
      function GetTlhw(tlhwstr: String; wc: TControl): String;
      procedure AlignTextinGrid(PCanvas: TCanvas; PHandle: HDC;
        PAlignment: Integer; PRect: TRect; ctxt: String);
      procedure SaveFont(f: TFont; n: ixmlnode; Att: String); overload;
      function IsFileInUse(FileName: TFileName): Boolean;
      function RemoveSpecificChar(ch: char; S: String): String;
      function ReplaceSpecialChars(sVal: String): String;
      Function EncryptPwd(pwd : string):String;
      function Isnumeral(s: String): boolean;
      function GetPickListModeValue(plMode: TPickListMode): String;
      function GetPickListMode(smode: String): TPickListMode;
      function GetPickListModeItem(smode: String): String;
      function GetSearchValue(plmode: TPickListMode; SrchVal: String): String;
      function GetAutoFilledDate(const ADate: String): TDate;
      function GetIPAddress: String;
      procedure TrimAppMemorySize;
      procedure GetUsedGlobalVarsInSqlParams(SqlCds: TCLientDataSet);
      procedure GetUsedGlobalVarsInExpr(fld_expr: string);
      function GlobalVarsInExprAndSqls  : String;
      function RoundEx(const AInput: extended; APlaces: integer): extended;
      function DecryptStr(Value: String): String;
      function EncryptStr(Value: String): String;
      function GetQuotedStr(DelimitedStr, Delimiter: String): String;
      procedure SetValuesToRedis(HostName, KeyName, KeyValue: String;pwd:String=''; timeout:integer=0);
      function GetValuesFromRedis(Hostname, KeyName: String;pwd:String=''): String;
      procedure SetValuesToRedisConn(HostName, KeyName, KeyValue: String);
      function GetValuesFromRedisConn(Hostname, KeyName: String): String;
      function GetRedisKeyCount(Hostname, KeyName: String;pwd:String=''): Integer;
      Procedure DeleteKeyFromRedis(Hostname, KeyName : String;pwd:String='');
      function Get_Password(dtid, mid: String): String;
      function GetFieldType(fldDataType: TFieldType): String;
      procedure PostResultToRedis(ResString: string);
      function GetDateTimeStampString: String;
      function DecryptFldValue(Value , dt : String): String;
      function EncryptFldValue(Value , dt : String): String;
      function ConvertTimestampToDateTime(const timestamp: string): string;
      function NowStringWithPriority(sPriority: String): String;
end;

const tagDtopBorder=500;

      wf_CREATED  : integer = 0;
      wf_APPROVED : integer = 1;
      wf_REVIEW   : integer = 2;
      wf_RETURN   : integer = 3;
      wf_APPROVE  : integer = 4;
      wf_REJECTED : integer = 5;
      wf_ORPHAN : integer = 9;
      TDateType = [ftDate, ftTime, ftDateTime, ftTimeStamp];
      TNumType = [ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD,
              ftBytes, ftVarBytes, ftAutoInc, ftLargeInt, ftFMTBcd];
      TCharType = [ftString, ftFixedChar, ftWideString];
      TTextType = [ftMemo, ftFmtMemo, ftOraClob, ftWideMemo];
      TBoolType = [ftBoolean];
      TImgType = [ftblob,ftGraphic, ftOraBlob];
      TOtherType = [ftunknown, ftVariant, ftInterface, ftParadoxOLE, ftDBaseOLE,
                    ftTypedBinary, ftADT, ftArray, ftReference, ftDataSet, ftIDispatch,
                    ftGUID, ftCursor];
      PDF_A4_PORTRAIT_PAGE_WIDTH       = 596;
      PDF_A4_PORTRAIT_PAGE_HEIGHT      = 842;
      PDF_A4_LANDSCAPE_PAGE_WIDTH      = 842;
      PDF_A4_LANDSCAPE_PAGE_HEIGHT     = 596;
      PDF_A3_PORTRAIT_PAGE_WIDTH       = 842;
      PDF_A3_PORTRAIT_PAGE_HEIGHT      = 1191;
      PDF_A3_LANDSCAPE_PAGE_WIDTH      = 1191;
      PDF_A3_LANDSCAPE_PAGE_HEIGHT     = 842;
      PDF_LETTER_PORTRAIT_PAGE_WIDTH   = 593;
      PDF_LETTER_PORTRAIT_PAGE_HEIGHT  = 699;
      PDF_LETTER_LANDSCAPE_PAGE_WIDTH  = 699;
      PDF_LETTER_LANDSCAPE_PAGE_HEIGHT = 593;
      PDF_LEGAL_PORTRAIT_PAGE_WIDTH    = 612;
      PDF_LEGAL_PORTRAIT_PAGE_HEIGHT   = 1008;
      PDF_LEGAL_LANDSCAPE_PAGE_WIDTH   = 1008;
      PDF_LEGAL_LANDSCAPE_PAGE_HEIGHT  = 612;
      CONST_MAX_DATASETS = 10;
      encrypt_key = '22723BBD4217A0ABF6D3E68073C7603D';  //md5 encrypt - agile


const
  csfsBold      = '|Bold';
  csfsItalic    = '|Italic';
  csfsUnderline = '|Underline';
  csfsStrikeout = '|Strikeout';

Implementation

{ TGeneralFunctions }

constructor TGeneralFunctions.Create;
begin
   dodebug := TDoDebug.create;
   biDirectional := false;
   PickListMode := plmAnyWhere;
   FormLevelPickListMode := plmAnyWhere;
   CompLevelPickListMode := plmAnyWhere;
//   axpdataexchange := true;
   axpdataexchange := false;
   FromAdr := False;
   NewTrans := false;
   CopyTrans := False;
   ShortDateFormat := TFormatSettings.Create;
   SQLValuePair := TStringlist.Create;
   PostAutoGen := false;
   IViewSQLPagination := false;
   datemode := '8909mode';
   dbmflag:='';
   ErrorInActionExecution := '';
   pwdmaxlogintry := 0;
   pwdexpdays := 0;
   pwdalterdays := 0;
   pwdminchars := 0;
   pwdprevnos := 0;
   pwdalphanum := False;
   pwdexpdayswithin := 0;
   Axp_LockOnRead := false;
   Axp_Axpertlog  := false;
   RecordLockedBy := '';
   SysCrossDate := False;
   MsSql_Unicode_Char := '';
   defaultdbtimeout := 30;      //  Command Timeout is default by 30secs for SQL Server
   LicString := '';
   LicDevString := '';
   LicLocString := '';
   sMapUserName := '';
   sMapPassword := '';
   ServiceReconnected := False;
   sql_query := '';
   trace_servicesql := false;
   LicActivated := false;
   DisplayTotRows := True;
   GetTotalRowsForWeb := False;
   Axp_Timeout := 0; //Axpert Timeout - value in Milli seconds
   IsConnectMap := False;
   CurrencySeparator := '';
   ReConnectDB := True;
   MaxConnectNo := 9999;
   MaxLastNo := 999999999;
   lowercase_tablenames := false;
   chkdebug := False;
   currlang := '';
   LocDecimalSeparator := '.';
   LocThousandSeparator := ',';
   DummyDate := '01'+ShortDateFormat.DateSeparator+'01'+ShortDateFormat.DateSeparator+'1900';
   chkbeforlogin := False;
   PartnersCopy := False;
   SiteCopy := False;
   LicSessionTrans := 0;
   LicWebSessionTrans := -1;
   FastDataFlag := false;
   srlKeyWords := nil;
   SiteLicUpdate := nil;
   UsedQuotedStr := False;
   MutexFlag := false;
   dbconnectiontime := 0;
   AppVarTypes := '';
   MaxSiteNo := 999;
   multilingual := false;
   ConnectRestDll := false;
   validatedtopsession := false;
   numbers := ['0','1','2','3','4','5','6','7','8','9'];
   updatepid := false;
   PerfIview := false;
   MobileWSFlag := false;
   AppVars := nil;
   UserVars := nil;
   AutoGenData := nil;
   defstrtrns := 'axrol,axusr,axroles,axusers,PageIvaxusers';
   AcsAxpertManager := true;
   GlobalVarsInSqlParams := nil;
   FrPrintPath := '';
   ClientIP := '';
   clouddb := '';
   RaiseErrOnDBReconnect := False;
   pwd_AES := False;
   SaveAllImagesInDB := False;
   ConfigTblFound := False;
   TransCheckCount := 0;
   GenMapTrans := False;
   ForRepostGenMaps := False;
   breakonerror := false;
   AppXML := nil;
   WebAppConXML := nil;
   actionName := '';
   postgre_search_path := '';
   WebRedisHost := '';
   WebRedisPwd := '';
   Db_Conn_Lost := False;
   timezone_diff := 0;
  {$IFNDEF  NOT ForRestDll}
    FRedis:= nil;
  {$ENDIF}
  ServiceName := '';
  AxMemVars := '';
  AxRuleNode := nil;
  AxValErrMsgs := nil;
  RedisConnXML := nil;
  bAxPegReadOnlyTrans := False;
  axdecimal := -1;
  bImageFromDB := False;
  sAxPegStatus := '';
  AutoselectCompatibility := false;
  isSXMLGetFromClient := true;
  PushToApiJobs := true;
end;

destructor TGeneralFunctions.Destroy;
begin
   dodebug.Free;
   if assigned(SQLValuePair) then
   begin
     SQLValuePair.Clear;
     FreeAndNil(SQLValuePair);
   end;
   if assigned(srlKeyWords) then
   begin
     srlKeyWords.Clear;
     FreeAndNil(srlKeyWords);
   end;
    if assigned(appvars) then
    begin
      appvars.Clear;
      FreeAndNil(appvars);
    end;
    if assigned(UserVars) then
    begin
      UserVars.Clear;
      FreeAndNil(UserVars);
    end;
    if assigned(AutoGenData) then
    begin
      ClearAutoGenData(True);
      FreeAndNil(AutoGenData);
    end;
    if assigned(GlobalVarsInSqlParams) then
    begin
      GlobalVarsInSqlParams.Clear;
      FreeAndNil(GlobalVarsInSqlParams);
    end;
   inherited;
end;

function TGeneralFunctions.GetLocalSystemName:String;
var
    pChr:array[0..255] of Char;
    Size:DWORD;
begin
    Size:=255;
    GetComputerName(pChr,Size);
    Result:=Trim(pChr);
end;

Function TGeneralFunctions.RealRound(num: extended; d: integer): extended;
Var
  f1, f2, d1, fact, diff: extended;
  str_num: String;
  l, w, p: integer;
Begin
  str_num := trim(floatToStr(num));
  l := length(str_num);
  p := pos(LocDecimalSeparator, str_num);
  If (p > 0) Then
    str_num := copy(str_num, p + 1, l - p);
  w := length(str_num);
  If (num = 0) Then
  Begin
    result := StrToFloat('0'+LocDecimalSeparator+'0');
    exit;
  End;
  if d > w then begin
   Result := num;
   exit;
  end;
  if (num < 0) and (w >= d) then
  begin
    result := RoundEx(num,d);
    exit;
  end;
  f1 := power(10, w);
  f2 := power(10, w - d);
  num := num * f1;
  d1 := int(num / f2);
  fact := num - (d1 * f2);
  If (fact >= f2 / 2) Then
  Begin
    diff := f2 - fact;
    num := num + diff;
  End
  Else
    num := num - fact;
  result := num / f1;
End;

Function TGeneralFunctions.IsEmptyValue(Value, DataType: String): String;
Begin
  Result := 'F';
  Datatype := lowercase(datatype);
  Value := trim(value);
  If (value = '') Or (lowercase(value) = 'null') Then
    Result := 'T'
  Else Begin
  If (DataType = 'd') And (value = ShortDateFormat.DateSeparator + '  ' + ShortDateFormat.DateSeparator) Then
      Result := 'T'
  End;
End;

Function TGeneralFunctions.GetNthString(SrcString: String; StrPos: integer): String;
Var
  i, k: integer;
Begin
  Result := '';
  i := 1;
  k := 1;
  while (k <= strpos) and (i<=length(srcstring)) do begin
   if srcstring[i] = ',' then
    inc(k)
   else if k = strpos then
    result := result + srcstring[i];
   inc(i);
  end;
End;

Function TGeneralFunctions.GetNthString(SrcString: String; StrPos: integer; Separator : Char ): String;
Var
  i, k: integer;
Begin
  Result := '';
  i := 1;
  k := 1;
  while (k <= strpos) and (i<=length(srcstring)) do begin
   if srcstring[i] = Separator then
    inc(k)
   else if k = strpos then
    result := result + srcstring[i];
   inc(i);
  end;
end;

function TGeneralFunctions.GetNthString(SrcString: String; StrPos: integer; Separator: String): String;
Var
  i, k: integer;
  searchlength : integer;
Begin
  if length(Separator) = 1 then
    Result := GetNthString(SrcString, StrPos, Separator[1])
  else
  begin
    Result := '';
    i := 1;
    k := 1;
    searchlength := length(Separator);
    while (k <= strpos) and (i<=length(srcstring)) do begin
      if copy(srcstring, i, searchlength) = Separator then
      begin
        inc(k);
        i := i + searchlength;
      end
      else if k = strpos then
      begin
        result := result + srcstring[i];
        inc(i);
      end
      else
        inc(i);
    end;
  end;
end;

Function TGeneralFunctions.Pad(S: String; MaxLength: integer; c: Char): String;
Var
  l, i: integer;
Begin
  Result := S;
  l := Length(S);
  If l >= MaxLength Then exit;
  For i := l + 1 To MaxLength Do Begin
    Result := Result + C;
  End;
End;

Function TGeneralFunctions.LeftPad(S: String; MaxLength: integer; c: Char): String;
Var
  l, i: integer;
Begin
  Result := S;
  l := Length(S);
  If l >= MaxLength Then exit;
  For i := l + 1 To MaxLength Do Begin
    Result := C + Result;
  End;
End;

Function TGeneralFunctions.InsertCommas(Value: String): String;
Var
  DecPos, CommaAfter: integer;
  NegVal: String;
Begin
  value := RemoveCommas(trim(Value));
  If copy(value, 1, 1) = '-' Then Begin
    NegVal := '-';
    delete(Value, 1, 1);
  End Else NegVal := '';
  DecPos := Pos(LocDecimalSeparator, Value);
  If DecPos = 0 Then
    DecPos := Length(Value) + 1;
  If Millions Then CommaAfter := 3 Else CommaAfter := 2;
  If ((DecPos - 3) > 1) Then // if the amount is in thousands or higher
  Begin
    Result := Copy(Value, DecPos - 3, Length(Value));
    Value := Copy(Value, 1, Length(Value) - Length(Result));
    While (Length(Value) > (CommaAfter - 1)) Do
    Begin
      Result := Copy(Value, Length(Value) - (CommaAfter - 1), CommaAfter) + LocThousandSeparator+ Result;
      Value := Copy(Value, 1, Length(Value) - CommaAfter);
    End;
    If Length(Value) > 0 Then Result := Value + LocThousandSeparator + Result;
  End
  Else
    Result := Value;
  Result := NegVal + Result;
End;

Function TGeneralFunctions.RemoveCommas(S: String): String;
Var
  k: integer;
Begin
  While true Do Begin
    k := pos(LocThousandSeparator, s);
    If k = 0 Then break;
    delete(s, k, 1);
  End;
  Result := S;
End;

Function TGeneralFunctions.RemoveSpecificChar(ch : char ; S: String): String;
Var
  k: integer;
Begin
  While true Do Begin
    k := pos(ch, s);
    If k = 0 Then break;
    delete(s, k, 1);
  End;
  Result := S;
End;

Function TGeneralFunctions.FormatValue(value: String; Declen: integer): String;
Var
  decval: String;
  decpos, i: integer;
Begin

  If value = '' Then Begin
    result := '';
    exit;
  End;
  if Declen=0 then
  begin
  Result :=Value;
  exit;
  end;
  decval := '00';
    decpos := pos(LocDecimalSeparator , value);

  If (decpos > 0) Then Begin
    value := value + '00000';
    result := copy(value, 1, decpos + declen)
  End Else Begin
    For i := 3 To declen Do
      decval := decval + '0';
        result := value + LocDecimalSeparator + decval;  //result := value + '.' + decval;
  End;
End;

function TGeneralFunctions.FormatXmlString(str: String): String;
var s:string;
begin
 result:='';
  s:=str;
  s:=FindAndReplace(s,'&','&amp;');
 // s:=FindAndReplace(s,'<', '&lt;');
//  s:=FindAndReplace(s, '>', '&gt;');
  s:=FindAndReplace(s, '''', '&apos;');
  s:=FindAndReplace(s, '''''', '&quot;');
 result:=s;
end;


function TGeneralFunctions.TrimToSingleSpace(s:String):String;
//kishore  17-Jan-2002
//Trims outer spaces and Reduces Inner Spaces to single space
//input  '  P  Kishore    Kumar  '
//Output 'P Kishore Kumar'
var
PrevSpace:Boolean;
i,l :integer;
begin
  s:=Trim(s);
  PrevSpace:=False;
  l:=Length(S);
  i:=1;
  while i<=l do
  begin
       if s[i]=' ' then
       begin
            if PrevSpace then
            begin
                 Delete(s,i,1);
                 l:=l-1;
                 i:=i-1;
            end
            else PrevSpace:=True;
       end
       else PrevSpace:=False;
       i:=i+1;
  end;
  Result:=s;
end;

function TGeneralFunctions.RepeatString(s:String;n:Integer):String;
//repeats String s for n times
var i:Integer;
begin
     Result:='';
     for i:=1 to n do
     begin
          Result:=Result+s;

     end;
end;

Function TGeneralFunctions.RemoveAmpherSand(PString: String): String;
Var
  HotPos: Integer;
Begin
  Result := PString;
  While True Do
  Begin
    HotPos := Pos('&', PString);
    If HotPos > 0 Then
      Delete(PString, HotPos, 1)
    Else If HotPos = 0 Then
      Break;
  End;
  Result := PString;
End;

Function TGeneralFunctions.RemoveSlash(PString: String): String;
Var
  HotPos: Integer;
Begin
  Result := PString;
  While True Do
  Begin
    HotPos := Pos('/', PString);
    If HotPos > 0 Then
      Delete(PString, HotPos, 1)
    Else If HotPos = 0 Then
      Break;
  End;
  Result := PString;
End;

Function TGeneralFunctions.GetSeperatorCount(Const SrcStr: String; Seperator: char): integer;
Var
  ind, cnt: integer;
  Src: String;
Begin
  src := SrcStr;
  cnt := 0;
  ind := pos(Seperator, Src);
  While ind > 0 Do
  Begin
    inc(cnt);
    delete(Src, 1, ind);
    ind := pos(Seperator, Src);
  End;
  result := cnt;
End;

function TGeneralFunctions.AddString(str:String;RepeatTime:Integer):String;
  var
    i:Integer;
begin
    Result:='';
    for  i:=1 to RepeatTime do
    begin
        Result:=Result + str;
    end;
end;

Function TGeneralFunctions.FindAndReplace(S:String;FindWhat:String;ReplaceWith: String):String;
var p:Integer;
begin
     Result:=s;
     p:=Pos(FindWhat,S);
     if p=0 then exit;
     Result:='';
     while p>0 do
     begin
          Result:=Result + copy(s,1,p-1) + ReplaceWith;
//          s:=copy(s,p+length(FindWhat)+ 1,8000);
          Delete(s,1,p+length(FindWhat)-1);
          p:=Pos(FindWhat,S);
     end;
     Result := Result + s;
end;
 {
function TGeneralFunctions.CreateQuery(Name, Databasename:String;DM:TDataModule):TQuery;
begin
 if assigned(dm) then Result := TQuery(DM.findcomponent(name))
 else result := nil;
 if not assigned(Result) then begin
  Result := TQuery.Create(DM);
  Result.name := Name;
  Result.Databasename := Databasename;
 end;
end;
}
function TGeneralFunctions.QueryLocate(Q:TClientDataSet; FName : String; FValue : Extended):Boolean;
begin
 result := false;
 q.First;
 while not q.eof do begin
  if q.fieldbyname(fname).asfloat = fValue then begin
   result := true;
   break;
  end;
  q.Next;
 end;
end;

function TGeneralFunctions.StrToIntz(s:String):integer;
begin
  if trim(s) <> '' then result := strtoint(removecommas(s)) else result := 0
end;

function TGeneralFunctions.StrToFloatz(s:String):extended;
begin
  if trim(s) <> '' then result := strtofloat(removecommas(s)) else result := 0
end;

function TGeneralFunctions.StrToDTz(s:String):TDateTime;
begin
  if trim(s) <> '' then result := strtodatetime(s) else result := strtodatetime(DummyDate);
end;

Procedure TGeneralFunctions.SetRegistry(RegistryString, KeyValue: String);
var n:ixmlnode;
begin
  registrystring:=lowercase(registrystring);
  n:=localprops.childnodes.findnode(registrystring);
  if not assigned(n) then n:=localprops.AddChild(registrystring);
  n.NodeValue:=keyvalue;
  axprops.SaveToFile(startpath+'axprops.xml');
end;

Function TGeneralFunctions.GetRegistry(RegistryString: String): String;
var n:ixmlnode;
begin
  n:=localprops.ChildNodes.FindNode(registrystring);
  if not assigned(n) then result:=''
  else result:=vartostr(n.NodeValue);
end;

Function TGeneralFunctions.GetGlobalProperty(propname:String):String;
var n:ixmlnode;
begin
  n:=globalprops.ChildNodes.FindNode(propname);
  if not assigned(n) then result:=''
  else result:=n.NodeValue;
end;

Function TGeneralFunctions.GetOptionNamePrefix(OptionType:String) : String;
begin
  If OptionType = 'fillgrid' Then
    Result := 'F_B'
  Else If OptionType = 'search' Then
    Result := 'S_B'
  Else If OptionType = 'docopen' Then
    Result := 'D_C'
  Else if OptionType = 'bulkpost' then
    Result := 'B_P'
  Else if OptionType = 'exprset' then
    Result := 'E_S'
  else if OptionType='newform' then
    Result:='N_F'
  else if optiontype='openform' then
    Result:='O_F'
  else if optiontype='previewreport' then
    Result:='P_R'
  else if optiontype='printreport' then
    Result:='T_R'
  else if optiontype='params' then
    Result:='P_M'
  else if optiontype='sendxl' then
    Result:='S_X'
  else if optiontype='sendword' then
    Result:='S_W'
  else if optiontype='sendmail' then
    Result:='S_M'
  else if optiontype='savexml' then
    Result:='S_L'
  else if optiontype='savehtml' then
    Result:='S_H'
  else if optiontype='savecsv' then
    Result:='S_C'
  else if optiontype='saveprint' then
    Result:='S_F'
  else if optiontype='graph' then
    Result:='T_G'
  else if optiontype='nextview' then
    Result:='N_V'
  else if optiontype='sort' then
    Result:='S_O'
  else if optiontype='filter' then
    Result:='F_I'
  else if optiontype='group' then
    Result:='G_R'
  Else
    Result := 'ASB';
end;

function TGeneralFunctions.GetKeyCode(KeyString:String) : integer;
begin
  keystring := lowercase(trim(keystring));
  if keystring = 'f2' then result := vk_f2
  else if keystring = 'f3' then result := vk_f3
  else if keystring = 'f4' then result := vk_f4
  else if keystring = 'f5' then result := vk_f5
  else if keystring = 'f6' then result := vk_f6
  else if keystring = 'f7' then result := vk_f7
  else if keystring = 'f8' then result := vk_f8
  else if keystring = 'f9' then result := vk_f9
  else if keystring = 'f10' then result := vk_f10
  else if keystring = 'f12' then result := vk_f12
  else result := 0;
end;

Function TGeneralFunctions.RemoveSpace(PString: String): String;
Var
  Str: String;
  Len: Integer;
Begin
  Result := Trim(PString);
  Str := PString;
  If Pos(' ', Str) = 0 Then
    Result := PString
  Else
  Begin
    While True Do
    Begin
      Len := Pos(' ', Str);
      If Len = 0 Then Break;
      If Len > 0 Then
        Delete(Str, Len, 1);
    End;
    Result := Str;
  End;
End;

Function TGeneralFunctions.RemoveExtraSpaces(PString: String): String;
Var
  Str: String;
  Len,i: Integer;
Begin
  Str := Trim(PString);
  i := 1;
  Len := Length(Str);
  while i<=Len do
  begin
    if (Str[i] = ' ') and (Str[i+1] = ' ') then
    begin
       delete(str,i,1);
       continue;
    end;
    inc(i);
  end;
  Result := Str;
End;

Function TGeneralFunctions.ConvertCRCNo(Total:Integer): Integer;
begin
  if (Total mod 5) = 0 then Total := Total - 21
  else if (Total mod 4) = 0 then Total := Total - 42
  else if (Total mod 3) = 0 then Total := Total - 74
  else if (Total mod 2) = 0 then Total := Total - 67
  else Total := Total - 91;
  if Total >= 0 then Result := Total
  else Result := 0;
end;
{
Function TGeneralFunctions.GetCRC(Q:TQuery) : integer;
var s:String;
    i, Tot : integer;
begin
  s := '';
  for i:=0 to q.fieldcount-1 do begin
    if lowercase(Q.fields[i].FieldName) <> 'crcfield' then
      s := s + q.fields[i].asstring;
  end;
  tot := 0;
  for i :=1 To Length(s) do
   tot := tot + (ord(s[i]));
  Result := ConvertCRCNo(Tot);
end;

}
function TGeneralFunctions.IsSysVar(S:String):Boolean;
var vstr : string;
begin
  vstr :=  ';username;recordid;finyrst;finyred;afinyrst;afinyred;usergroup;';
  vstr := vstr+'usergroupno;activerow;_maincurr;rolename;responsibilities;';
  vstr := vstr+'siteno;wf_applevel;wf_status;wf_maxlevel;axp_language;';
  vstr := vstr+'axp_timezone;axp_service;axp_apipath;axp_appschema;axp_devschema;';
  result := pos(';'+lowercase(s)+';',vstr )>0;
end;

function TGeneralFunctions.IsValidEmailid(Mailid: String): boolean;
var
  i,len: Integer;
  namePart, serverPart: String;
begin
  Result:= False;
  i:= Pos('@', Mailid);
  IF (i=0) OR (Pos('..',Mailid) > 0) THEN Exit;
  namePart:= Copy(Mailid, 1, i - 1);
  serverPart:= Copy(Mailid,i+1,Length(Mailid));
  len:=Length(serverPart);
  // must have dot and at least 3 places from end, 2 places from begin
  IF (len<4) OR                         // com
     (Pos('.',serverPart)=0) OR         // com
     (serverPart[1]='.') OR             // .com  (ee@.com)
     (serverPart[len]='.') OR           // com.
     (serverPart[len-1]='.') THEN Exit; //co.m
  Result:= IsAlphaNumeric(namePart,'abcdefghijklmnopqrstuvwxyz0123456789-_.') AND IsAlphaNumeric(serverPart,'abcdefghijklmnopqrstuvwxyz0123456789-_.');
end;

function TGeneralFunctions.PRound(num:extended;d:integer):extended;
var
  f1,f2,d1,fact,diff : real;
  str_num: String;
  l,w,p: integer;
begin
  str_num:=trim(floatToStr(num));
  l:=length(str_num);
  p:=pos(LocDecimalSeparator,str_num);
  if (p>0 ) then
    str_num:=copy(str_num,p+1,l-p);
  w:=length(str_num);
  if (num=0) then begin
    result := StrToFloat('0'+LocDecimalSeparator+'0');
    exit;
  end;
  if d > w then begin
    Result := num;
    exit;
  end;
  if (num < 0) and (w >= d) then
  begin
    result := RoundEx(num,d);
    exit;
  end;
  f1:=power(10,w);
  f2:=power(10,w-d);
  num:=num*f1;
  d1:=int(num/f2);
  fact:= num-(d1*f2);
  if (fact>= f2/2) then begin
    diff:=f2-fact ;
    num:=num+diff;
  end else num:=num-fact;
  result:= num/f1;
end;

function TGeneralFunctions.getcharacterset(s:String):TFontCharSet;
begin
  result:=0;
  s := lowercase(s);
  if s = 'ansi' then
    result := ANSI_CHARSET
  else if s = 'default' then
    result := DEFAULT_CHARSET
  else if s = 'symbol' then
    result := SYMBOL_CHARSET
  else if s = 'mac' then
    result := MAC_CHARSET
  else if s = 'shiftjis' then
    result := SHIFTJIS_CHARSET
  else if s = 'hangeul' then
    result := HANGEUL_CHARSET
  else if s = 'johab' then
    result := JOHAB_CHARSET
  else if s = 'gb2312' then
    result := GB2312_CHARSET
  else if s = 'chinesebig5' then
    result := CHINESEBIG5_CHARSET
  else if s = 'greek' then
    result := GREEK_CHARSET
  else if s = 'turkish' then
    result := TURKISH_CHARSET
  else if s = 'vietnamese' then
//    result := VIETNAMESE_CHARSET
    result := ANSI_CHARSET
  else if s = 'hebrew' then
    result := HEBREW_CHARSET
  else if s = 'arabic' then
    result := ARABIC_CHARSET
  else if s = 'baltic' then
    result := BALTIC_CHARSET
  else if s = 'russian' then
    result := RUSSIAN_CHARSET
  else if s = 'thai' then
    result := THAI_CHARSET
  else if s = 'easteurope' then
    result := EASTEUROPE_CHARSET
  else if s = 'oem' then
    result := OEM_CHARSET;
end;

Function TGeneralFunctions.SplitString(S, Delimiter: String): TStringList;
Var
  i: integer;
  Temp: String;
Begin
  Result := TStringList.Create;
  Temp := '';
  For i := 0 To Length(S) Do
  Begin
    If (S[i + 1] = Delimiter) Then
    Begin
      Result.Add(Temp);
      Temp := '';
    End
    Else
      Temp := Temp + S[i + 1];
  End;
  If (Length(Temp) > 0) Then
    Result.Add(Temp);
End;

Function TGeneralFunctions.ReadFileName(FileWithPath: String; Var pFilePath: String):
  String;
Var
  i: Integer;
Begin
  Result := '';
  If (pos('\', FileWithPath) = 0) and (pos('/', FileWithPath) = 0) then
  Begin
    Result := FileWithPath;
    exit;
  End;
  For i := length(FileWithPath) - 1 Downto 1 Do
    If (FileWithPath[i] = '\') Or (FileWithPath[i] = '/') Then
    Begin
      pFilePath := Copy(FileWithPath, 1, i);
      Result := Copy(FileWithPath, i + 1, length(FileWithPath));
      Break;
    End;
End;

function TGeneralFunctions.MakeFormatString(Width, Decimals:integer):String;
var i,x:integer;
begin
 Result := '';
 if decimals > 0 then x := 2 else x := 0;
 for i:=1 to Width-decimals-x do
  Result := Result + '#';
 if decimals > 0 then begin
  Result := Result + '0';
  Result := Result + LocDecimalSeparator;
 end;
 for i:=1 to Decimals do
  Result := Result + '0';
end;

Procedure TGeneralFunctions.ShowPopupMenu(Btn: TSpeedButton; PopMenu: TPopupMenu);
Var
  p: TPoint;
Begin
  p := Btn.Parent.ClientToScreen(Point(Btn.left + 2, Btn.top + Btn.height + 3));
  PopMenu.Popup(p.x, p.y);
End;
Procedure TGeneralFunctions.ShowPopupMenuB(Btn: TBitBtn; PopMenu: TPopupMenu);
Var
  p: TPoint;
Begin
  p := Btn.Parent.ClientToScreen(Point(Btn.left + 2, Btn.top + Btn.height + 3));
  PopMenu.Popup(p.x, p.y);
End;

Procedure TGeneralFunctions.ShowPopupMenuUp(Btn: TSpeedButton; PopMenu: TPopupMenu);
Var
  p: TPoint;
Begin
  p := Btn.Parent.ClientToScreen(Point(Btn.left + 2, Btn.top-10));
  PopMenu.Popup(p.x, p.y-(PopMenu.Items.Count*15));
End;

Procedure TGeneralFunctions.IWrite(ININame, Context, RegistryString, KeyValue: String);
var
 exepath: String;
 profit5RMIniFile: TIniFile;
begin
   exepath:=ExtractFilePath(application.ExeName);
   profit5RMIniFile:=TIniFile.Create(exepath+ININame);
   profit5RMIniFile.WriteString(context,RegistryString,KeyValue);
   profit5RMIniFile.free;
end;

Function TGeneralFunctions.IRead(ININame, Context, RegistryString: String): String;
var
 exepath,res: String;
 profit5RMIniFile: TIniFile;
begin
   res:='';
   exepath:=ExtractFilePath(application.ExeName);
   profit5RMIniFile:=TIniFile.Create(exepath+ININame);
   res:=profit5RMIniFile.ReadString(Context,RegistryString,res);
   profit5RMIniFile.free;
   result:=res;
end;

Function TGeneralFunctions.GenerateNumber : extended;
begin
  GlobalSerialNo := GlobalSerialNo + 1;
  Result := StrToFloat(LeftPad(IntToStr(Sescount), 3, '0') + LeftPad(FloatToStr(GlobalSerialNo), 5, '0'));
end;
{
Function ConvertDate(dbtype:String;dt:TDateTime):String;
begin
  if dbtype = 'oracle' then
    Result := FormatDateTime('dd-mmm-yyyy',dt)
  else if dbtype = 'ms sql' then
    Result := FormatDateTime('mm/dd/yyyy',dt)
  else
    Result := FormatDateTime('dd/mm/yyyy', dt);
end;
}

Function TGeneralFunctions.ConvertDateTime(dbtype:String;Dt:TDateTime):String;
begin
  if dbtype = 'oracle' then
    Result := 'to_date('+quotedstr(datetimetostr(dt))+',''dd-mm-yyyy hh24:mi:ss'')'
  else if dbtype = 'ms sql' then
    result := '(CONVERT(VARCHAR(23), '+quotedstr(datetimetostr(dt))+', 103) + '' '' + CONVERT(VARCHAR(23),'+quotedstr(datetimetostr(dt))+', 108))'
  else if dbtype='mysql' then
    Result:=quotedstr(formatdatetime('yyyy/MM/dd hh:nn:ss',dt))
  else
    Result := Quotedstr(FormatDateTime('dd/mm/yyyy hh:nn:ss', Dt));
end;

Function TGeneralFunctions.ConvertToDBDateTime(dbtype:String;Dt:TDateTime):String;
begin
  if dbtype = 'oracle' then
    Result := formatdatetime('dd/mm/yyyy hh:nn:ss',dt)
  else if dbtype = 'ms sql' then
  begin
    if length(datetimetostr(dt)) > 10 then
       Result:=formatdatetime('mm/dd/yyyy hh:nn:ss',dt)
    else result := formatdatetime('mm/dd/yyyy',dt)
  end else if dbtype='mysql' then
  begin
    if length(datetimetostr(dt)) > 10 then
       Result:=formatdatetime('yyyy-mm-dd hh:mm:ss',dt)
    else Result := formatdatetime('yyyy-mm-dd',dt)
  end
  else
    Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Dt);
end;

Function TGeneralFunctions.SQLTrimLower(dbtype:String):String;
begin
  if dbtype = 'access' then result := 'LCase(Trim(' else result := 'Lower(Trim(';
end;

Function TGeneralFunctions.GetNumber:String;
begin
  GlobalSerialNo:=GlobalSerialNo+1;
  Result:=LeftPad(IntToStr(SesCount), 3, '0') + LeftPad(FloatToStr(GlobalSerialNo), 5, '0');
end;

Function TGeneralFunctions.Gen_id(TableName : String;incr : integer):extended;
begin
  GlobalSerialNo := GlobalSerialNo + 1;
  Result := StrToFloat(LeftPad(IntToStr(SesCount), 3, '0') + LeftPad(FloatToStr(GlobalSerialNo), 5, '0'));
end;

Function TGeneralFunctions.Bool2Str(f:boolean) : String;
begin
  if f then result:='t' else result:='f';
end;

Function TGeneralFunctions.Str2Bool(s:String):boolean;
begin
  if lowercase(s)='t' then result:=true else result:=false;
end;

Function TGeneralFunctions.GetFontProp(xnode:IXMLNode):TFont;
var s:String;
begin
  result := tfont.create;
  s:=vartostr(xnode.ChildValues['name']);
  if s<>'' then result.Name:=s;
  s:=vartostr(xnode.ChildValues['size']);
  if s<>'' then result.Size:=strtoint(s);
  s:=vartostr(xnode.ChildValues['charset']);
  if s<>'' then result.charset:=getcharacterset(s);
  s:=vartostr(xnode.ChildValues['style']);
  if s<>'' then begin
    result.Style:=[];
    if pos('b',s)>0 then result.style:=result.style+[fsBold];
    if pos('u',s)>0 then result.style:=result.style+[fsUnderLine];
    if pos('i',s)>0 then result.style:=result.style+[fsItalic];
    if pos('s',s)>0 then result.style:=result.style+[fsStrikeOut];
  end;
end;

function TGeneralFunctions.SeekNode(N:IXMLNode; Name, Attr, Value:String):IXMLNode;
var i:integer;
    x:IXMLNode;
begin
  result:=nil;
  for i:=0 to n.childnodes.count-1 do begin
    x:=n.ChildNodes[i];
    if not x.HasAttribute(attr) then continue;
    if (x.NodeName=name) and (x.Attributes[attr]=value) then begin
      result:=x;
      break;
    end;
  end;
end;

function TGeneralFunctions.SeekNode(N:IXMLNode; Name, Value:String):IXMLNode;
var i:integer;
    x:IXMLNode;
begin
  result:=nil;
  for i:=0 to n.childnodes.count-1 do begin
    x:=n.ChildNodes[i];
    if (x.NodeName=name) and (x.NodeValue=value) then begin
      result:=x;
      break;
    end;
  end;
end;

function TGeneralFunctions.ReplaceStr(s, findstr, replstr:String):String;
var p:integer;
begin
  while true do begin
    p := pos(findstr, s);
    if p=0 then break;
    delete(s, p, length(findstr));
    insert(replstr, s, p);
  end;
  result := s;
end;

function TGeneralFunctions.ReadListFile(filename:String; key:String):String;
begin
  result:='';
  if not fileexists(filename) then exit;
  with tstringlist.create do begin
    loadfromfile(filename);
    result := values[key];
    free;
  end;
end;

function TGeneralFunctions.writenode(pnode: ixmlnode; name, value:String):ixmlnode;
begin
  result:=pnode.childnodes.FindNode(name);
  if not assigned(result) then result:=pnode.AddChild(name);
  result.NodeValue:=value;
end;

procedure TGeneralFunctions.LoadFont(f:TFont; fontstr,lf:String);
var s,t,t3,t4:String;
begin

  if trim(fontstr) = '' then
  begin
    f.Name := 'Tahoma';
    f.Size := 8;
    f.Style := [];
    f.Color := StringtoColor('clBlack');
  end
  else
  begin
    s:=fontstr;
    if s='' then exit;
    t:=getnthstring(s,1);
    if t<>'' then f.Name:=t;
    t:=getnthstring(s,2);
    if t<>'' then f.size:=strtoint(t);

    t4:=getnthstring(s,4);
    t3:=getnthstring(s,3);
    if length(t4)>4 then begin
      f.color:=stringtocolor(t4);
      s:=t3;
    end else if length(t3)>4 then begin
      f.Color:=stringtocolor(t3);
      s:=t4;
    end else begin
      if length(t3)=4 then s:=t3 else s:=t4;
    end;

    if s<>'' then begin
      f.Style:=[];
      if s[1]='t' then f.Style:=f.Style+[fsBold];
      if s[2]='t' then f.Style:=f.Style+[fsItalic];
      if s[3]='t' then f.Style:=f.Style+[fsUnderline];
      if s[4]='t' then f.Style:=f.Style+[fsStrikeOut];
    end;
  end;
  if (lf <> '') and (AppFontCharSet <> '') then
  begin
     f.Charset := GetCharacterSet(AppFontCharSet);
     f.Name := AppFontName;
  end;
end;

procedure TGeneralFunctions.SaveFont(f, pf:TFont; n:ixmlnode);
var s,t:String;
begin
  s:='';
  if f.Name<>pf.Name then
    s:=f.Name;
  s:=s+',';
  if f.Size<>pf.Size then
    s:=s+inttostr(f.Size);
  s:=s+',';
  if f.Style<>pf.Style then begin
    t:='ffff';
    if fsbold in f.style then t[1]:='t';
    if fsItalic in f.Style then t[2]:='t';
    if fsUnderline in f.Style then t[3]:='t';
    if fsStrikeOut in f.Style then t[4]:='t';
    s:=s+t;
  end;
  s:=s+',';
  if f.Color<>pf.Color then
    s:=s+colortostring(f.color);
//  if s<>',,,' then
    n.Attributes['font']:=s;
end;

procedure TGeneralFunctions.SaveFont(f:TFont; n:ixmlnode);
var s,t:String;
begin
  s:='';
//  if f.Name<>pf.Name then
    s:=f.Name;
  s:=s+',';
//  if f.Size<>pf.Size then
    s:=s+inttostr(f.Size);
  s:=s+',';
//  if f.Style<>pf.Style then begin
    t:='ffff';
    if fsbold in f.style then t[1]:='t';
    if fsItalic in f.Style then t[2]:='t';
    if fsUnderline in f.Style then t[3]:='t';
    if fsStrikeOut in f.Style then t[4]:='t';
    s:=s+t;
//  end;
  s:=s+',';
//  if f.Color<>pf.Color then
    s:=s+colortostring(f.color);
//  if s<>',,,' then
    n.Attributes['font']:=s;
end;

function TGeneralFunctions.ButtonRegister(cap, act:String):integer;
begin
  registered.add(cap);
  btnactions.add(act);
  result:=btnactions.count-1;
end;

procedure TGeneralFunctions.ButtonUnRegister(cap:String);
var k:integer;
begin
  k:=registered.IndexOf(cap);
  if k>-1 then begin
    registered.Delete(k);
    btnactions.delete(k);
  end;
end;

procedure TGeneralFunctions.DrawBorder(pnl:TPanel;clr:TColor;Edges:String);
var i:integer;
begin
  if not assigned(pnl) then exit;
  for i:=0 to pnl.controlcount-1 do begin
    if pnl.Controls[i].Tag=tagDtopborder then exit;
  end;
  pnl.bevelouter:=bvNone;
  pnl.borderstyle:=bsNone;
  pnl.ctl3d:=false;
  if pos('l', edges)>0 then begin
    with TShape.Create(pnl) do begin
      parent:=pnl;
      width:=1;
      brush.Style:=bsClear;
      pen.Color:=clr;
      align:=alLeft;
      tag:=tagDtopBorder;
    end;
  end;
  if pos('t', edges)>0 then begin
    with TShape.Create(pnl) do begin
      parent:=pnl;
      height:=1;
      brush.Style:=bsClear;
      pen.Color:=clr;
      align:=altop;
      tag:=tagDtopBorder;
    end;
  end;
  if pos('r', edges)>0 then begin
    with TShape.Create(pnl) do begin
      parent:=pnl;
      width:=1;
      brush.Style:=bsClear;
      pen.Color:=clr;
      align:=alRight;
      tag:=tagDtopBorder;
    end;
  end;
  if pos('b', edges)>0 then begin
    with TShape.Create(pnl) do begin
      parent:=pnl;
      height:=1;
      brush.Style:=bsClear;
      pen.Color:=clSilver;
      align:=alBottom;
      tag:=tagDtopBorder;
    end;
  end;
end;

function TGeneralFunctions.iswincontrol(wc:TObject):boolean;
begin
  result:=false;
  while assigned(wc) do begin
    if wc.ClassType=TWinControl then begin
      result:=true;
      break;
    end;
    wc:=TObject(TWinControl(wc).parent);
  end;
end;

function TGeneralFunctions.isframe(wc:TObject):boolean;
begin
  result:=false;
  while assigned(wc) do begin
    if wc.ClassType=TFrame then begin
      result:=true;
      break;
    end;
    wc:=TObject(TWinControl(wc).parent);
  end;
end;

function TGeneralFunctions.CheckMatch(matchstring, value:String):boolean;
begin
  result:=true;
  if lowercase(matchstring) = 'caps' then
  begin
     if value <> UpperCase(value)then result:=false;
  end else  if lowercase(matchstring) = 'small' then
  begin
     if value <> LowerCase(value)then result:=false;
  end else if lowercase(matchstring) = 'initcaps' then
  begin
     if copy(value,1,1) <> UpperCase(copy(value,1,1))then result:=false;
  end else
  begin
    with tmask.create(matchstring) do begin
      if not matches(value) then result:=false;
      destroy;
    end;
  end;
end;

function TGeneralFunctions.GetDefaultImages(iname : String ) : integer;
  var i : integer;
begin
  iname := Lowercase(iname);
  if iname = 'new' then result := 0
  else if iname = 'open' then result := 1
  else if iname = 'save' then result := 2
  else if iname = 'save as' then result := 3
  else if (iname = 'preview') then result := 4
  else if (iname = 'print')  then result := 5
  else if iname = 'tasks' then result := 6
  else if iname = 'view' then result := 7
  else if iname = 'find' then result := 8
  else if iname = 'analyze' then result := 9
  else if iname = 'refresh' then result := 10
  else if (iname = 'delete') or (iname = 'remove') then result := 11
  else if iname = 'search' then result := 12
  else if (iname = 'view attachment') or (iname = 'attach') then result := 13
  else if iname = 'email' then result := 14
  else if (iname = 'params') or (iname = 'parameters') then result := 15
  else if iname = 'send' then result := 16
  else if iname = 'pdf' then result := 17
  else if iname = 'to xl' then result := 18
  else if iname = 'rapid xl export' then result := 18
  else if iname = 'to word' then result := 19
  else if  iname = 'defpage' then result := 20
  else if iname = 'combo' then result := 22
  else if iname = 'cancel' then result := 23
  else if  iname = 'print form' then result := 24
  else if  iname = 'preview form' then result := 25
  else if  iname = 'autogen' then result := 26
  else if  iname = 'calendar' then result := 27
  else if  iname = 'undo' then result := 28
  else if  iname = 'go' then result := 29
  else if  iname = 'action' then result := 30
  else if  iname = 'graph' then result := 31
  else if  iname = 'view history' then result := 32  
  else if  iname = 'page setup / printer setting' then result := 33
  else if  iname = 'poptstruct' then result := 34
  else if  iname = 'previous' then result := 36
  else if  iname = 'next' then result := 37
  else if  iname = 'first' then result := 38
  else if  iname = 'last' then result := 39
  else if  iname = 'picklist' then result := 40
  else if  iname = 'popgrid' then result := 41
  else if  iname = 'add' then result := 42
  else if  iname = 'download' then result := 43
  else if  iname = 'page refresh' then result := 44
  else result := -1;

end;

procedure TGeneralFunctions.SetAppFont(tfrm:TFrame);
begin
  if Trim(AppFontCharSet) <> '' then
    tfrm.Font.Charset := GetCharacterSet(AppFontCharSet);
  if Trim(AppFontName) <> '' then
    tfrm.Font.Name := AppFontName;
 if AppFontSize >0  then
    tfrm.Font.Size := AppFontSize;
end;

function TGeneralFunctions.setColHeadings(cName : String ;fontCDS : TClientDataSet) : String;
  var i : integer;
begin
  result := '';
  if fontCDS.Active then
  begin
    fontCDS.First;
    while not fontCDS.Eof do
    begin
      if lowercase(cName) = lowercase(fontCDS.FieldByName('compname').AsString)  then
      begin
         result := fontCDS.FieldByName('compcaption').AsString;
         break;
      end;
      fontCDS.Next;
    end;
  end;
end;

function TGeneralFunctions.GetDefName(cName : String ;fontCDS : TClientDataSet) : String;
  var i : integer;
begin
  fontCDS.First;
  while not fontCDS.Eof do
  begin
    if lowercase(cName) = lowercase(fontCDS.FieldList[1].AsString)  then
    begin
       result := fontCDS.FieldList[0].AsString;
       break;
    end;
    fontCDS.Next;
  end;
end;

function TGeneralFunctions.setcompprop(cname : String ;fontCDS : TClientDataSet; cmp : TWinControl ) : String ;
  var i : integer;
begin
  result := '';
  fontCDS.First;
  while not fontCDS.Eof do
  begin
    if lowercase(cName) = lowercase(fontCDS.FieldByName('compname').AsString)  then
    begin
       TPanel(cmp).ParentFont := True;
       if fontCDS.FieldByName('compcaption').AsString <> '' then TPanel(cmp).Caption := fontCDS.FieldByName('compcaption').AsString;
       {
       if fontCDS.FieldList[2].AsString = '' then
          TPanel(cmp).Hint := fontCDS.FieldList[1].AsString
       else  TPanel(cmp).Hint := fontCDS.FieldList[2].AsString ;
       }
       if fontCDS.FieldByName('comphint').AsString <> '' then TPanel(cmp).Hint := fontCDS.FieldByName('comphint').AsString ;
       result := 'yes';
       break;
    end;
    fontCDS.Next;
  end;
end;

function TGeneralFunctions.UserAccess(cName : String ;fontCDS : TClientDataSet) : Boolean;
  var i : integer;
begin
   if lowercase(cName) = 'inbox' then
   begin
      result := true;
      exit;
   end;
  result := False;
  fontCDS.First;
  while not fontCDS.Eof do
  begin
    if lowercase(cName) = lowercase(fontCDS.FieldByName('name').AsString)  then
    begin
       result := True;
       break;
    end;
    fontCDS.Next;
  end;
end;

function TGeneralFunctions.IsAlphaNumeric(s : String) : Boolean;
  var i : integer;
  c : String;
begin
  result := True;
// s := trim(lowercase(s)) ;
   s := trim(s);
   for i := 1 to length(s) do
  begin
     c := copy(s,i,1);
     if pos(c,'abcdefghijklmnopqrstuvwxyz0123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0 then continue
     else
     begin
       result := false;
       break
     end;
  end;
end;

function TGeneralFunctions.IsAlphaNumeric(s,schar : String) : Boolean;
  var i : integer;
  c : String;
begin
  result := True;
  s := trim(lowercase(s)) ;
  for i := 1 to length(s) do
  begin
     c := copy(s,i,1);
     if pos(c,schar) > 0 then continue
     else
     begin
       result := false;
       break
     end;
  end;
end;

function TGeneralFunctions.AlphaNumericCheck(s : string) : Boolean;
  var i : integer;
  c : string;
begin
  result := True;
  s := trim(lowercase(s)) ;
  for i := 1 to length(s) do
  begin
     c := copy(s,i,1);
     if pos(c,'abcdefghijklmnopqrstuvwxyz0123456789_') > 0 then continue
     else
     begin
       result := false;
       break;
     end;
  end;
  if not result then exit;
  result := false;
  for i := 1 to length(s) do
  begin
     c := copy(s,i,1);
     if pos(c,'abcdefghijklmnopqrstuvwxyz_') > 0 then
     begin
       result := true;
       break
     end;
  end;
  if result then result := false
  else exit;
  for i := 1 to length(s) do
  begin
     c := copy(s,i,1);
     if pos(c,'0123456789') > 0 then
     begin
       result := true;
       break
     end;
  end;
end;

function TGeneralFunctions.NowString:String;
var y,m,d,h,mn,s,ms:word;
    nStr : String;
begin
  decodedatetime(now, y, m, d, h, mn, s, ms);
  nStr:=inttostr(y)+leftpad(inttostr(m),2,'0')+leftpad(inttostr(d),2,'0');
  nStr:=nStr+leftpad(inttostr(h),2,'0')+leftpad(inttostr(mn),2,'0');
  nStr:=nStr+leftpad(inttostr(s),2,'0');
  if lastnowstring = nStr then nownum:=nownum+1 else nownum:=1;
  lastnowstring:=nStr;
  result:=nStr+leftpad(inttostr(nownum),4,'0')+leftpad(inttostr(sescount),4,'0')+leftpad(inttostr(siteno),LenMaxSiteNo,'0');
end;

function TGeneralFunctions.NowStringWithPriority(sPriority:String):String;
var y,m,d,h,mn,s,ms:word;
    nStr : String;
begin
  decodedatetime(now, y, m, d, h, mn, s, ms);
  nStr:=inttostr(y)+leftpad(inttostr(m),2,'0')+leftpad(inttostr(d),2,'0');
  nStr:=nStr+leftpad(inttostr(h),2,'0')+leftpad(inttostr(mn),2,'0');
  nStr:=nStr+leftpad(inttostr(s),2,'0');
  if lastnowstring = nStr then nownum:=nownum+1 else nownum:=1;
  lastnowstring:=nStr;
  result:=nStr+leftpad(inttostr(nownum),4,'0')+leftpad(inttostr(sescount),4,'0')
        +leftpad(sPriority,3,'0')+leftpad(inttostr(siteno),LenMaxSiteNo,'0');
end;


function TGeneralFunctions.GridConvert(sg : TStringGrid) : TStringGrid;
var  r,c,hrow,brow,r1,orgrow : Integer;
nvaltext : String;
rt : TStringGrid;
begin
  rt := TstringGrid.Create(nil);
  rt.ColCount := sg.ColCount;
  rt.RowCount := sg.FixedRows+1;
  rt.FixedRows := sg.FixedRows;
  rt.OnDrawCell := sg.OnDrawCell;
  for r := 0 to sg.fixedrows-1 do begin
    if not biDirectional then
    begin
      for c := 0 to  sg.ColCount-1 do begin
        rt.cells[c,r] := sg.cells[c,r]
      end;
    end else
    begin
      for c := sg.ColCount-1 downto 0 do begin
        rt.cells[c,r] := sg.cells[c,r]
      end;
    end;
  end;
  if not biDirectional then
  begin
    for c := 0 to  sg.ColCount-1 do begin
      rt.Cells[c,0]:= sg.Cells[c,0];
      rt.ColWidths[c] := sg.ColWidths[c];
    end;
  end else begin
    for c := sg.ColCount-1 downto 0 do begin
      rt.Cells[c,0]:= sg.Cells[c,0];
      rt.ColWidths[c] := sg.ColWidths[c];
    end;
  end;
  r := sg.FixedRows;
  orgrow := sg.FixedRows;
  while r <= sg.RowCount-1 do begin
    r1 := r;
    if not biDirectional then
    begin
      for c:= 1 to sg.Colcount do begin
        nvaltext := '';
        brow := r;
        while true do begin
          nvaltext := nvaltext+sg.Cells[c,brow];
          if brow > sg.rowcount-1 then
            break
          else if  copy(sg.Cells[sg.ColCount-1,brow+1],1,1)='1'  then begin
            brow := brow+1;
            if r1 < brow then
              r1 := brow;
          end
          else break;
        end;
          if orgrow > rt.RowCount-1 then
            rt.RowCount := rt.RowCount+1;
          rt.Cells[c,orgrow]:= nvaltext;
      end;
    end else begin
      for c:= sg.Colcount downto 1 do begin
        nvaltext := '';
        brow := r;
        while true do begin
          nvaltext := nvaltext+sg.Cells[c,brow];
          if brow > sg.rowcount-1 then
            break
          else if  copy(sg.Cells[sg.ColCount-1,brow+1],1,1)='1'  then begin
            brow := brow+1;
            if r1 < brow then
              r1 := brow;
          end
          else break;
        end;
          if orgrow > rt.RowCount-1 then
            rt.RowCount := rt.RowCount+1;
          rt.Cells[c,orgrow]:= nvaltext;
      end;
    end;
    r := r1;
    r := r+1;
    orgrow := orgrow+1;
  end;
  Result := rt;
end;

Function TGeneralFunctions.FindNode(n:ixmlnode;name:String):ixmlnode;
var i : integer;
begin
  result := nil;
  name := lowercase(name);
  for I := 0 to n.ChildNodes.Count - 1 do begin
    if (lowercase(n.ChildNodes[i].NodeName) =  name) then begin
      result := n.ChildNodes[i];
      exit;
    end;
  end;
end;

function TGeneralFunctions.isValidName(nm : String) : String;
begin
  result := '';
  nm := findandreplace(nm,'.','n');
  if pos(' ',nm) > 0 then result := 'Space not allowed.'
  else if not IsalphaNumeric(nm) then result := 'Special characters not allowed.'
  else if IsNumeric(nm[1]) then result := 'Should not begin with number.';
end;

function TGeneralFunctions.isValidName(nm : String; allowed:integer) : String;
begin
  result := '';
  nm := findandreplace(nm,'.','n');
  if pos(' ',nm) > 0 then result := 'Space not allowed.'
  else if not IsalphaNumeric(nm) then result := 'Special characters not allowed.'
  else if IsNumeric(nm[1]) then result := 'Should not begin with number.'
  else if Length(nm)>allowed then result := 'Should not allow more than ' + IntToStr(allowed) + ' characters';
end;

function TGeneralFunctions.GetNumericVerNo(verno:String):Extended;
var i : integer;
    s,s1 : String;
begin
  i := 1;
  s1 := '';
  while (i<=4) do
  begin
    s := getnthstring(verno,i,'.');
    s := LeftPad(s,2,'0');
    s1 := s1+s;
    i := i+1;
  end;
  result := StrToFloat(s1);
end;

function TGeneralFunctions.GetDataType(fldDataType:TFieldType):String;
begin
  if (fldDataType in TCharType) then Result := 'Character'
  else if (fldDataType in TNumType) then Result := 'Numeric'
  else if (fldDataType in TDatetype) then Result := 'Date'
  else if (fldDataType in TTexttype) then Result := 'Text'
  else if (fldDataType in TImgType) then Result := 'Image'
  else if (fldDataType in TOthertype) then Result := 'Unknown';
end;

function TGeneralFunctions.IsAppVar(S:String):Boolean;
begin
  result := True;
  if not assigned(appvars) then exit;
  result := (appvars.IndexOfName(s)>=0)
end;

function TGeneralFunctions.ConvertToExprSet(exprstr : String) : String ;
   var fldName, fldValue , fldType , v1,v2: String ;
begin
   result := '';
   exprstr := exprstr;
   if pos('Less Than or Equal to',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Less Than or Equal to','<=');
     fldName := copy(exprstr,1,pos('<=',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('<=',exprstr)+2,length(exprstr)-pos('<=',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif ((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})' ;
     end
     else
       result := fldName + '-iif ((' + fldName + ' < {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}), {T} , {F})' ;
   end
   else if pos('Greater Than or Equal to',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Greater Than or Equal to','>=');
     fldName := copy(exprstr,1,pos('>=',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('>=',exprstr)+2,length(exprstr)-pos('>=',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif ((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})' ;
     end
     else
       result := fldName + '-iif ((' + fldName + ' > {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}), {T} , {F})' ;
   end
   else if pos('Not Equal to',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Not Equal to','#');
     fldName := copy(exprstr,1,pos('#',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('#',exprstr)+1,length(exprstr)-pos('#',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif (' + fldName + ' # ' + fldValue + ' , {T} , {F})' ;
     end
     else
       result := fldName + '-iif (' + fldName + ' # {' + fldValue + '} , {T} , {F})' ;
   end
   else if pos('Equal to',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Equal to','=');
     fldName := copy(exprstr,1,pos('=',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('=',exprstr)+1,length(exprstr)-pos('=',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif (' + fldName + ' = ' + fldValue + ' , {T} , {F})' ;
     end
     else
       result := fldName + '-iif (' + fldName + ' = {' + fldValue + '} , {T} , {F})' ;
   end
   else if pos('Less Than',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Less Than','<');
     fldName := copy(exprstr,1,pos('<',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('<',exprstr)+1,length(exprstr)-pos('<',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif (' + fldName + ' < ' + fldValue + ' , {T} , {F})' ;
     end
     else
       result := fldName + '-iif (' + fldName + ' < {' + fldValue + '} , {T} , {F})' ;
   end
   else if pos('Greater Than',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Greater Than','>');
     fldName := copy(exprstr,1,pos('>',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('>',exprstr)+1,length(exprstr)-pos('>',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       result := fldName + '-iif (' + fldName + ' > ' + fldValue + ' , {T} , {F})' ;
     end
     else
       result := fldName + '-iif (' + fldName + ' > {' + fldValue + '} , {T} , {F})' ;
   end
   else if pos('Between',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Between','.');
     fldName := copy(exprstr,1,pos('.',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('.',exprstr)+1,length(exprstr)-pos('.',exprstr)));
     if copy(fldValue,1,1) = ':' then
     begin
       delete(fldValue,1,1);
       if pos(',',fldValue) > 0 then
       begin
         v1 := copy(fldValue,1,pos(',',fldValue)-1);
         delete(fldValue,1,pos(',',fldValue));
         v2 := fldValue;
         if copy(v2,1,1) = ':' then delete(v2,1,1);
       end  ;
       result := fldName + '-iif ((' + fldName + ' > ' + v1 + ') | (' + fldName + ' = ' + v1 + ') & (' + fldName + ' > ' + v2 + ') | (' + fldName + ' = ' + v2 + '), {T} , {F})' ;
     end
     else
     begin
       if pos(',',fldValue) > 0 then
       begin
         v1 := copy(fldValue,1,pos(',',fldValue)-1);
         delete(fldValue,1,pos(',',fldValue));
         v2 := fldValue;
       end  ;
       result := fldName + '-iif ((' + fldName + ' > {' + v1 + '}) | (' + fldName + ' = {' + v1 + '}) & (' + fldName + ' > {' + v2 + '}) | (' + fldName + ' = {' + v2 + '}), {T} , {F})' ;
     end;
   end
   else if pos('Contains',exprstr) > 0 then   begin
     exprstr := FindAndReplace(exprstr,'Contains','.');
     fldName := copy(exprstr,1,pos('.',exprstr)-1);
     fldValue := trim(copy(exprstr,pos('.',exprstr)+1,length(exprstr)-pos('.',exprstr)));
     result := '-iif ({'+ fldValue + '} $ '+fldName+ ' , {T} , {F})' ;
   end
   else if pos('Is Empty',exprstr) > 0 then
   begin
     exprstr := FindAndReplace(exprstr,'Is Empty','.');
     fldName := copy(exprstr,1,pos('.',exprstr)-1);
     fldValue := '';
     result := fldName + '-isemptyvalue (' + fldName + ' , {' + fldType + '})' ;
   end ;
end;

function TGeneralFunctions.ConvertToExpr(fldname,dtype,op,fldvalue,fldvalue1: String) : String ;
begin
   result := '';
   op := lowercase(op);
   if (op = 'less than or equal to') or (op = 'less_than_or_equal_to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := 'iif ((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif ((' + fldName + ' < ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '})), {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif ((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})'
       else
         result := 'iif ((' + fldName + ' < {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}), {T} , {F})' ;
     end;
   end else if (op = 'greater than or equal to') or (op = 'greater_than_or_equal_to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := 'iif ((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif ((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '})), {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif ((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})'
       else
         result := 'iif ((' + fldName + ' > {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}), {T} , {F})' ;
     end;
   end
   else if (op = 'not equal to') or (op = 'not_equal_to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := 'iif (' + fldName + ' # ' + fldValue + ' , {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif (' + fldName + ' # ctod({' + fldValue + '}) , {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif (' + fldName + ' # ' + fldValue + ' , {T} , {F})'
       else
         result := 'iif (' + fldName + ' # {' + fldValue + '} , {T} , {F})' ;
     end;
   end else if (op = 'equal to') or (op = 'equal_to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := 'iif (' + fldName + ' = ' + fldValue + ' , {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif (' + fldName + ' = ctod({' + fldValue + '}) , {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif (' + fldName + ' = ' + fldValue + ' , {T} , {F})'
       else
         result := 'iif (' + fldName + ' = {' + fldValue + '} , {T} , {F})' ;
     end;
   end else if (op = 'less than') or (op = 'less_than') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
         result := 'iif (' + fldName + ' < ' + fldValue + ' , {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif (' + fldName + ' < ctod({' + fldValue + '}) , {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif (' + fldName + ' < ' + fldValue + ' , {T} , {F})'
       else
         result := 'iif (' + fldName + ' < {' + fldValue + '} , {T} , {F})' ;
     end;
   end else if (op = 'greater than') or (op = 'greater_than') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := 'iif (' + fldName + ' > ' + fldValue + ' , {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif (' + fldName + ' > ctod({' + fldValue + '}) , {T} , {F})'
       else if (dtype = 'n') then
         result := 'iif (' + fldName + ' > ' + fldValue + ' , {T} , {F})'
       else
         result := 'iif (' + fldName + ' > {' + fldValue + '} , {T} , {F})' ;
     end;
   end else if (op = 'between') then begin
     if (copy(fldValue,1,1) = ':') and (copy(fldValue1,1,1) = ':') then begin
       delete(fldValue,1,1);
       delete(fldValue1,1,1);
       result := 'iif (((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')), {T} , {F})' ;
     end else if (copy(fldValue,1,1) = ':') and (copy(fldValue1,1,1) <> ':') then begin
       delete(fldValue,1,1);
       if (dtype = 'd') then
         result := 'iif (((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ctod({' + fldValue1 + '})) | (' + fldName + ' = ctod({' + fldValue1 + '}))), {T} , {F})'
       else
         result := 'iif (((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')), {T} , {F})' ;
     end else if (copy(fldValue,1,1) <> ':') and (copy(fldValue1,1,1) = ':') then begin
       delete(fldValue1,1,1);
       if (dtype = 'd') then
         result := 'iif (((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '}))) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')), {T} , {F})'
       else
         result := 'iif (((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')), {T} , {F})' ;
     end else begin
       if (dtype = 'd') then
         result := 'iif (((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '}))) & ((' + fldName + ' < ctod({' + fldValue1 + '})) | (' + fldName + ' = ctod({' + fldValue1 + '}))), {T} , {F})'
       else
         result := 'iif (((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')), {T} , {F})' ;
     end;
   end else if (op = 'isempty') then   begin
     result := 'isemptyvalue (' + fldName + ' , {' + dType + '})' ;
   end else if (op = 'containing') then   begin
     result := 'iif ({'+ fldValue + '} $ '+fldName+ ' , {T} , {F})' ;
   end ;
end;

function TGeneralFunctions.ToShortDateFormat(dbtype,MyDate:String) : String;
var i,p,j:integer;
    d,m,y:word;
    s : String;
begin
  if (dbtype = 'oracle') or (dbtype = 'postgre') then
  begin
    p:=1;
    for i := 1 to Length(mydate)  do begin
      if mydate[i] in ['/','-','.'] then begin
         if p=1 then begin
           d:=strtoint(s);
           inc(p);
         end else if p=2 then begin
           try
           m:=strtoint(s);
           except
             for j := 1 to 12 do begin
               if ShortDateFormat.shortmonthnames[j]=s then begin
                 m:=j;
                 break;
               end;
             end;
           end;
           inc(p);
         end else if p=3 then begin
           y:=strtoint(s);
           s:='';
           break;
         end;
         s:='';
      end else
        s:=s+mydate[i];
    end;
    if s<>'' then
      y:=strtoint(s);
    result:=FormatDateTime(ShortDateFormat.ShortDateFormat,encodedate(y, m, d));
  end else   if dbtype = 'ms sql' then
  begin
    p:=1;
    for i := 1 to Length(mydate)  do begin
      if mydate[i] in ['/','-','.'] then begin
         if p=1 then begin
           try
           m:=strtoint(s);
           except
             for j := 1 to 12 do begin
               if ShortDateFormat.shortmonthnames[j]=s then begin
                 m:=j;
                 break;
               end;
             end;
           end;
           inc(p);
         end else if p=2 then begin
           d:=strtoint(s);
           inc(p);
         end else if p=3 then begin
           y:=strtoint(s);
           s:='';
           break;
         end;
         s:='';
      end else
        s:=s+mydate[i];
    end;
    if s<>'' then
      y:=strtoint(s);
    result:=FormatDateTime(ShortDateFormat.ShortDateFormat,encodedate(y, m, d));
  end
  else if (dbtype = 'mysql') then
  begin
    p:=1;
    for i := 1 to Length(mydate)  do begin
      if mydate[i] in ['/','-','.'] then begin
         if p=1 then begin
           y:=strtoint(s);
           inc(p);
         end else if p=2 then begin
           try
           m:=strtoint(s);
           except
             for j := 1 to 12 do begin
               if ShortDateFormat.shortmonthnames[j]=s then begin
                 m:=j;
                 break;
               end;
             end;
           end;
           inc(p);
         end else if p=3 then begin
           d:=strtoint(s);
           s:='';
           break;
         end;
         s:='';
      end else
        s:=s+mydate[i];
    end;
    if s<>'' then
      d:=strtoint(s);
    result:=FormatDateTime(ShortDateFormat.ShortDateFormat,encodedate(y, m, d));
  end;
end;

{New function for getting the String value for workflow}
function TGeneralFunctions.GetWFString(stint : integer) : String;
var
  stat : String;
begin
  stat := '';
  if      stint = wf_APPROVED  then stat := 'Approved'
  else if stint = wf_CREATED   then stat := 'Created'
  else if stint = wf_REJECTED  then stat := 'Rejected'
  else if stint = wf_REVIEW    then stat := 'Review'
  else if stint = wf_APPROVE   then stat := 'Approve'
  else if stint = wf_RETURN    then stat := 'Return'
  else if stint = wf_ORPHAN    then stat := 'Orphan';


  result := stat;
end;

procedure TGeneralFunctions.SetBiDiMode(wc : TWinControl);
begin
   if biDirectional then wc.BiDiMode := bdRightToLeft;
end;

function TGeneralFunctions.GetWFInt(stat : String) : integer;
var
  wfstat : integer;
begin
  wfstat := -2;
  stat := lowercase(stat);
  if      stat = 'approved'   then wfstat := wf_APPROVED
  else if stat = 'created'   then wfstat := wf_CREATED
  else if (stat = 'rejected') or (stat = 'reject') then wfstat := wf_REJECTED
  else if stat = 'review'   then wfstat := wf_REVIEW
  else if stat = 'approve'   then wfstat := wf_APPROVE
  else if stat = 'return'   then wfstat := wf_RETURN
  else if stat = 'orphan'   then wfstat := wf_ORPHAN;
  result := wfstat;
end;

procedure TGeneralFunctions.DeleteFilesFromFolder(PathWithPattern:String);
var
  SourceLst: String;
  FOS: TSHFileOpStruct;
begin
  FillChar(FOS, SizeOf(FOS), 0);
  FOS.Wnd := 0;
  FOS.wFunc := FO_DELETE;
  SourceLst := PathWithPattern + #0;
  FOS.pFrom := PChar(SourceLst);
  FOS.fFlags := FOS.fFlags OR FOF_FILESONLY;
  FOS.fFlags := FOS.fFlags OR FOF_NOCONFIRMATION;
  SHFileOperation(FOS);
end;

function TGeneralFunctions.GetCondStr(fldname,dtype,op,fldvalue,fldvalue1: String) : String ;
begin
   result := '';
   op := lowercase(op);
   if (op = 'less than or equal to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := '((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '))' ;
     end else begin
       if (dtype = 'd') then
         result := '((' + fldName + ' < ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '})))'
       else if (dtype = 'n') then
         result := '(' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '), {T} , {F})'
       else
         result := '((' + fldName + ' < {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}))' ;
     end;
   end else if (op = 'greater than or equal to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := '((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '))' ;
     end else begin
       if (dtype = 'd') then
         result := '((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '})))'
       else if (dtype = 'n') then
         result := '((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + '))'
       else
         result := '((' + fldName + ' > {' + fldValue + '}) | (' + fldName + ' = {' + fldValue + '}))' ;
     end;
   end
   else if (op = 'not equal to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := '(' + fldName + ' # ' + fldValue + ')' ;
     end else begin
       if (dtype = 'd') then
         result := '(' + fldName + ' # ctod({' + fldValue + '}))'
       else if (dtype = 'n') then
         result := '(' + fldName + ' # ' + fldValue + ')'
       else
         result := '(' + fldName + ' # {' + fldValue + '})' ;
     end;
   end else if (op = 'equal to') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := '(' + fldName + ' = ' + fldValue + ')' ;
     end else begin
       if (dtype = 'd') then
         result := '(' + fldName + ' = ctod({' + fldValue + '}))'
       else if (dtype = 'n') then
         result := '(' + fldName + ' = ' + fldValue + ')'
       else
         result := '(' + fldName + ' = {' + fldValue + '})' ;
     end;
   end else if (op = 'less than') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
         result := '(' + fldName + ' < ' + fldValue + ')' ;
     end else begin
       if (dtype = 'd') then
         result := '(' + fldName + ' < ctod({' + fldValue + '}))'
       else if (dtype = 'n') then
         result := '(' + fldName + ' < ' + fldValue + ')'
       else
         result := '(' + fldName + ' < {' + fldValue + '})' ;
     end;
   end else if (op = 'greater than') then begin
     if copy(fldValue,1,1) = ':' then begin
       delete(fldValue,1,1);
       result := '(' + fldName + ' > ' + fldValue + ')' ;
     end else begin
       if (dtype = 'd') then
         result := '(' + fldName + ' > ctod({' + fldValue + '}))'
       else if (dtype = 'n') then
         result := '(' + fldName + ' > ' + fldValue + ')'
       else
         result := '(' + fldName + ' > {' + fldValue + '})' ;
     end;
   end else if (op = 'between') then begin
     if (copy(fldValue,1,1) = ':') and (copy(fldValue1,1,1) = ':') then begin
       delete(fldValue,1,1);
       delete(fldValue1,1,1);
       result := '(((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')))' ;
     end else if (copy(fldValue,1,1) = ':') and (copy(fldValue1,1,1) <> ':') then begin
       delete(fldValue,1,1);
       if (dtype = 'd') then
         result := '(((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ctod({' + fldValue1 + '})) | (' + fldName + ' = ctod({' + fldValue1 + '}))))'
       else
         result := '(((' + fldName + ' < ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')))' ;
     end else if (copy(fldValue,1,1) <> ':') and (copy(fldValue1,1,1) = ':') then begin
       delete(fldValue1,1,1);
       if (dtype = 'd') then
         result := '(((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '}))) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')))'
       else
         result := '(((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')))' ;
     end else begin
       if (dtype = 'd') then
         result := '(((' + fldName + ' > ctod({' + fldValue + '})) | (' + fldName + ' = ctod({' + fldValue + '}))) & ((' + fldName + ' < ctod({' + fldValue1 + '})) | (' + fldName + ' = ctod({' + fldValue1 + '}))))'
       else
         result := '(((' + fldName + ' > ' + fldValue + ') | (' + fldName + ' = ' + fldValue + ')) & ((' + fldName + ' < ' + fldValue1 + ') | (' + fldName + ' = ' + fldValue1 + ')))' ;
     end;
   end else if (op = 'isempty') then   begin
     result := 'isemptyvalue (' + fldName + ' , {' + dType + '})' ;
   end else if (op = 'containing') then   begin
     result := '({'+ fldValue + '} $ '+fldName+ ')' ;
   end ;
end;

Procedure TGeneralFunctions.ClearAutoGenData(DelModRec:Boolean);
var i : integer;
begin
  if not assigned(AutoGenData) then exit;
  i := 0;
  while i <= AutoGenData.Count-1 do
  begin
    if (not DelModRec) and (pAutoGenRec(AutoGenData[i]).RType = 'mod') then
    begin
      inc(i);
      continue;
    end else
    begin
      if Assigned(pAutoGenRec(AutoGenData[i]).ParentList) then
      begin
        try
          pAutoGenRec(AutoGenData[i]).ParentList.Clear;
          pAutoGenRec(AutoGenData[i]).ParentList.Free;
        except
        end;
      end;
      Dispose(pAutoGenRec(AutoGenData[i]));
      AutoGenData.Delete(i);
    end;
  end;
end;

function TGeneralFunctions.RemoveReadOnly(const FileName: String): Boolean;
begin
  (* Assume Success *)
  Result := True;

  (* Make sure the file is read only before
    we try and change the attributes *)
  if (FileIsReadOnly(FileName)) then
  begin
    SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);

    Result := not FileIsReadOnly(FileName);
  end;
end;



function TGeneralFunctions.FileIsReadOnly(FileName: String): boolean;
begin
  Result := (GetFileAttributes(PChar(FileName)) and FILE_ATTRIBUTE_READONLY > 0);
end;

procedure TGeneralFunctions.Applyskin(color:String);//pon skin
var colorstring : Tstringlist; var i:integer;
begin
  AppTitleFont := TFont.Create;
  Toplinkfont:= TFont.Create;Titlefont:= TFont.Create;ToolbarFont:= TFont.Create;Textfont:= TFont.Create;RibbonFont:= TFont.Create;
  GridFont := TFont.Create;
  if color <> '' then
  begin
    colorstring := TStringlist.create();
    colorstring.clear;
    colorstring.LoadFromFile(color);
    for I := 0 to colorstring.Count - 1 do
    begin
      if colorstring.Names[i] ='Skin' then
        Skinname := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='Fonttype' then
        Fonttype := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='Background' then
        Background := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='Forecolor' then
        Forecolor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='Toolbarcolor' then
        Toolbarcolor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='Tstartcolor' then
        TBstartcolor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='TEndcolor' then
        TBEndcolor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='BorderColor' then
        BorderColor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='GridOddRowColor' then
        GridOddRowColor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='GridEvenRowColor' then
        GridEvenRowColor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='PaginationPanelColor' then
        PaginationPanelColor := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='GridHeadColor' then
        GridHead := trim(colorstring.ValueFromIndex[i])
      else if colorstring.Names[i] ='AppTitleFont' then
         stringtoFont(colorstring.ValueFromIndex[i],AppTitleFont)
      else if colorstring.Names[i] ='ToplinkFont' then
         stringtoFont(colorstring.ValueFromIndex[i],Toplinkfont)
      else if colorstring.Names[i] ='TitleFont' then
         stringtoFont(colorstring.ValueFromIndex[i],TitleFont)
      else if colorstring.Names[i] ='ToolbarFont' then
         stringtoFont(colorstring.ValueFromIndex[i],ToolbarFont)
      else if colorstring.Names[i] ='Textfont' then
         stringtoFont(colorstring.ValueFromIndex[i],Textfont)
      else if colorstring.Names[i] ='GridFont' then
         stringtoFont(colorstring.ValueFromIndex[i],Gridfont)
      else if colorstring.Names[i] ='RibbonFont' then
         stringtoFont(colorstring.ValueFromIndex[i],Ribbonfont)
      else if colorstring.Names[i] ='Buttoncaption' then
         ButCaps := trim(colorstring.ValueFromIndex[i]);
    end;
    FreeAndNil(colorstring);
  end;
end;
procedure TGeneralFunctions.StringToFont(sFont : string; Font : TFont );
var
  p      : integer;
  sStyle : string;
begin
  with Font do
  begin
    Font.Name := GetNthString(sFont,1);// get font name
    Size :=StrtoInt(GetNthString(sFont,2));// get font size
    sStyle :=GetNThstring(sFont,3);// get font style
    Color := StringToColor(GetNThstring(sFont,4));// get font color

    Style := [];
    if( Pos( csfsBold,sStyle ) > 0 )then
      Style := Style + [ fsBold ];
    if( Pos( csfsItalic,sStyle ) > 0 )then
      Style := Style + [ fsItalic ];
    if( Pos( csfsUnderline,sStyle ) > 0 )then
      Style := Style + [ fsUnderline ];

    if( Pos( csfsStrikeout,sStyle ) > 0 )then
      Style := Style + [ fsStrikeout ];
  end;
end;

function TGeneralFunctions.EncryptString(datetime: TDateTime):String;        /// by ar
var
i:Integer;
lpstring,enstring:string;
begin
  enstring := ''; lpstring := DatetimeToStr(datetime);
  If Length(lpString) > 0 Then
  begin
    for i := 1 to Length(lpString) do
    begin
      If Ord(lpString[i]) <> 255 Then
      begin
        enstring:= enstring + Chr(Ord(lpString[i])+ 1)
      end
      else begin
        enstring:= enstring + Chr(0)
      end;
    end;
  end;
  if pos(':',enstring) > 0 then enstring := FindAndReplace(enstring,':','N');
  if pos(';',enstring) > 0 then enstring := FindAndReplace(enstring,';','S');
  if pos('!',enstring) > 0 then enstring := FindAndReplace(enstring,'!','Y');
  result := enstring;
end;

function TGeneralFunctions.CountNumberOfComma(FieldValue :String ): integer;
var
  i,a : integer;
  s : String;
  found : boolean;
begin
  found := false; a :=0;
  for I := 0 to length(FieldValue) do begin
    s := FieldValue[i];
    if s = ',' then begin
      a := a + 1;
      found := true;
    end;
  end;
  if not found then result := 0
  else result := a;
 end;

function TGeneralFunctions.EncryptPassword(Org_Md5_pwd,Access_code: string): string;
var
  encstr,newpwd : string;
  i:integer;
  key : char;
  eval,x,z,j,hr:integer;
begin
  result := Org_Md5_pwd;
  exit;
  encstr := Access_code;
  for I := 1 to length(encstr) do begin
    x:= ord(encstr[i]);
    z:= ord(org_md5_pwd[i]);
    eval := x+z;
    if eval > 122 then begin
      eval := eval-122+65
    end;
    key := char(eval);
    while True do begin
      if key in['[','\',']','^','_','`',''''] then begin
        key := char(ord(key)+i);
      end
      else break;
    end;
    newpwd := lowercase(newpwd)+key;
  end;
  for I := 1 to length(newpwd)   do begin
    for j := i to length(org_md5_pwd) do begin
      if j mod 2 = 0 then begin
        org_md5_pwd[j] := newpwd[i];
        break;
      end;
    end;
  end;
  result := org_md5_pwd;
end;

function TGeneralFunctions.IsDirectoryEmpty(const directory : String) : boolean;
 var
   searchRec :TSearchRec;
begin
  try
    result := True;
    if (System.SysUtils.FindFirst(directory+'\*.*', faAnyFile, searchRec) = 0) then
    repeat
      if lowercase(searchRec.name) = 'thumbs.db' then
        System.SysUtils.Deletefile(directory+'\thumbs.db');
      if (searchRec.name <> '.') and (searchRec.name <> '..') and
        (lowercase(searchRec.name) <> 'thumbs.db')then begin
        result := False;
        break;
      end;
    until FindNext(searchRec) <> 0;


//    result := (SysUtils.FindFirst(directory+'\*.*', faAnyFile, searchRec) = 0) AND
//              (SysUtils.FindNext(searchRec) = 0)
//              AND (SysUtils.FindNext(searchRec) <> 0) ;
  finally
     System.SysUtils.FindClose(searchRec) ;
  end;
end;

Procedure TGeneralFunctions.DeleteDirectories(DirName:String);
var sPos : integer;
begin
  try
    while DirName <> '' do
    begin
      if DirectoryExists(DirName) then begin
        if IsDirectoryEmpty(DirName) then begin
           if Copy(DirName,Length(DirName),1) = '\' then
             Delete(DirName,Length(DirName),1);
           RemoveDir(DirName);
           sPos := PosofLastSeperator(DirName,'\');
           if sPos > 0 then
             Delete(DirName,sPos,Length(DirName));
        end else
           Break;
      end else Break;
    end;
  except
  end;
end;

Function TGeneralFunctions.PosOfLastSeperator(Str,Seperator:String):Integer;
var i : integer;
begin
  result := 0;
  for i := Length(Str) downto 1 do
  begin
    if Str[i] = Seperator then begin
      result := i;
      break;
    end;
  end;
end;



Procedure TGeneralFunctions.DeleteStructureResource;
var
  rfile : String;
  sr:TSearchRec;
begin
    rfile := startpath+'Structures\'+AppName+'\*.res';
    if (findfirst(rfile, faAnyFile, sr)=0) then begin
      repeat
        if (sr.name = '.') or (sr.Name = '..') then continue;
        system.sysutils.deletefile(startpath+'Structures\'+AppName+'\'+sr.name);
      until FindNext(sr) <> 0;
      system.sysutils.FindClose(sr);
    end;
    rfile := startpath+'Structures\'+AppName+'\*.cls';
    if (findfirst(rfile, faAnyFile, sr)=0) then begin
      repeat
        if (sr.name = '.') or (sr.Name = '..') then continue;
        system.sysutils.deletefile(startpath+'Structures\'+AppName+'\'+sr.name);
      until FindNext(sr) <> 0;
      system.sysutils.FindClose(sr);
    end;
end;

procedure TGeneralFunctions.LoadFont(tf,sf:TFont);
begin
  tf.Name := sf.Name;
  tf.Charset := sf.Charset;
  tf.Size := sf.Size;
  tf.Style := sf.Style;
  tf.Color := sf.Color;
end;

// ShellExecute - Opens the given File in corresponding application
Function TGeneralFunctions.ShellExecute_WithInfo(FileWithPathName : String):Boolean;
Var
  SEInfo: TShellExecuteInfo;
  Exitcd : Cardinal;
begin
  result := False;
  if Not FileExists(FileWithPathName) then Exit;
  FillChar(SEInfo,Sizeof(SEInfo),0);
  with SEInfo do
  begin
    cbSize := Sizeof(TShellExecuteInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := Application.Handle;
    lpFile := PWideChar(FileWithPathName);
    nShow := SW_SHOWNORMAL;
  end;
  if ShellExecuteEx(@SEInfo) then  // opens the Given File in Corresponding Application
  begin
    repeat  // Executes until the Application gets terminated
      Application.ProcessMessages;
      GetExitCodeProcess(SEInfo.hProcess, Exitcd);
    until (ExitCd <> STILL_ACTIVE) or Application.Terminated;
  end;
  result := true;
end;


//find the given file / folder size
function TGeneralFunctions.FileSize(fileName : wideString) : Integer;
var
  SR : TSearchRec;
  FSize : Int64;
begin
  if ExtractFileExt(ExtractFileName(fileName)) = ''  then     //for folders
  begin
    if Not AnsiEndsStr('\',fileName) then fileName := fileName+'\';
    fileName := fileName+'*.*';
  end;
  result := 0;
  FSize := 0;
  if FindFirst(fileName, faAnyFile, SR ) = 0 then
  repeat
    FSize := FSize+(Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow));
  until FindNext(SR) <> 0;
  system.SysUtils.FindClose(SR);
  result := Integer(FSize);
end;


function TGeneralFunctions.GetVersion(sFileName:string): string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  fTransTable: TTransRecArray;
  TransIdx : integer;
  Trans,StrName : string;
begin
  try
    try
      Result :='[Compiled on '+DateTimeToStr(FileDateToDateTime(FileAge(ExtractFileName(sFileName))));
      VerInfoSize := GetFileVersionInfoSize(PChar(sFileName), Dummy);
      GetMem(VerInfo, VerInfoSize);
      GetFileVersionInfo(PChar(sFileName), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do
      begin
        Result := Result + '] [File Version : ' + IntToStr(dwFileVersionMS shr 16);
        Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
        Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
        Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
        Result := Result + ']';
        exeverno := IntToStr(dwFileVersionMS shr 16) + '.' + IntToStr(dwFileVersionMS and $FFFF) +
                    '.' + IntToStr(dwFileVersionLS shr 16) + '.' + IntToStr(dwFileVersionLS and $FFFF);
      end;
      fTransTable := GetTransTable(VerInfo);
      for TransIdx := 0 to Pred(Length(fTransTable)) do
      begin
        Trans := GetTranslation(TransIdx,fTransTable);
        StrName := 'ProductVersion';
        StrName := GetVerInfoStr(VerInfo,Trans, StrName);
        Result := Result + '] [Product Version : ' + StrName + ']';
        StrName := 'Comments';
        AppVarComments := GetVerInfoStr(VerInfo,Trans, StrName);
        Result := Result + '[' + AppVarComments + ']';
      end;
    except
    end;
  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

function TGeneralFunctions.GetRealExeName: string;
var
  TheFileName : array[0..MAX_PATH] of char;
begin
 FillChar(TheFileName, sizeof(TheFileName), #0);
 GetModuleFileName(hInstance, TheFileName, sizeof(TheFileName));
 result :=  TheFileName;
end;

function TGeneralFunctions.GetTranslation(Idx: Integer ; fTransTable :TTransRecArray ): string;
begin
  Assert((Idx >= 0) and (Idx < Length(fTransTable)));
  // Return string representation of translation at given index
  Result := Format(
    '%4.4x%4.4x', [fTransTable[Idx].Lang, fTransTable[Idx].CharSet]
  );
end;

function TGeneralFunctions.GetTransTable(const Buffer: Pointer): TTransRecArray;
var
  TransRec: PTransRec;  // pointer to a translation record
  Size: DWORD;          // size of data read
  RecCount: Integer;    // number of translation records
  Idx: Integer;         // loops thru translation records
begin
  // Read translation data
  VerQueryValue(Buffer, '\VarFileInfo\Translation', Pointer(TransRec), Size);
  // Get record count and set length of array
  RecCount := Size div SizeOf(TTransRec);
  SetLength(Result, RecCount);
  // Loop thru table storing records in array
  for Idx := 0 to Pred(RecCount) do
  begin
    Result[Idx] := TransRec^;
    Inc(TransRec);
  end;
end;

function TGeneralFunctions.GetVerInfoStr(const Buffer: Pointer;
  const Trans, StrName: string): string;
var
  Value: PChar;   // the string value data
  Dummy: DWORD;   // size of value data (unused)
  Path: string;   // "path" to string value
begin
  // Build path from translation and string name
  Path := '\StringFileInfo\' + Trans + '\' + StrName;
  // Read the string: return '' if string doesn't exist
  if VerQueryValue(Buffer, PChar(Path), Pointer(Value), Dummy) then
    Result := Value
  else
    Result := '';
end;

Function TGeneralFunctions.CheckForLicenseFile : string;
  var rfile,s: String;
      sr: TSearchRec;
      l : integer;
begin
  result := '';
  rfile := exepath + '\' + '*axpert*.lic';
  if (findfirst(rfile, faAnyFile, sr) = 0) then
  begin
    repeat
      if (sr.Name = '.') or (sr.Name = '..') then continue;
      s := sr.name;
      l := length(s);
      if ((lowercase(copy(s,l-13,14)) = 'axpertpart.lic')) or ((lowercase(copy(s,l-13,14)) = 'axpertsrvr.lic')) then
      begin
        result := s;
        break;
      end;
    until FindNext(sr) <> 0;
    System.SysUtils.FindClose(sr);
  end;
  if result = '' then
  begin
    if (findfirst(rfile, faAnyFile, sr) = 0) then
    begin
      repeat
        if (sr.Name = '.') or (sr.Name = '..') then continue;
        s := sr.name;
        l := length(s);
        if (lowercase(copy(s,l-13,14)) = 'axperteval.lic') then
        begin
          result := s;
          break;
        end;
      until FindNext(sr) <> 0;
      System.SysUtils.FindClose(sr);
    end;
  end;
end;

Function TGeneralFunctions.ReadLicFile(licfile : String) : TStringList;
    var sfile : String;
    licstr : TStringList;
    stm,cstm : TStringStream ;
begin
  try
    Result := nil;
    stm := TStringStream.Create;
    sfile := exepath + '\' +licfile;
    if fileexists(sfile) then
    begin
      stm.LoadFromFile(sfile);
      stm.Position := 0;
      with TCompress.Create do begin
        cstm := DecompressLicStringStream(stm);
        destroy;
      end;
      licstr := TStringList.Create;
      licstr.Clear;
      cstm.Position := 0;
      licstr.LoadFromStream(cstm,TEncoding.GetEncoding(1252));
      result := licstr;
    end;
  finally
    FreeAndNil(stm);
    FreeAndNil(cstm);
  end;
End;

Function TGeneralFunctions.GetFontProps(OrgStr,SearchStr:String):String;
var
  SInd,EInd,Count : Integer;
  StrVal : String;
begin
  Result := '';
  StrVal := '';
  SInd := Pos(SearchStr,OrgStr);
  SInd := SInd;
  if SInd > 1 then
     OrgStr := Copy(OrgStr,SInd,length(OrgStr));
  EInd := Pos(',',OrgStr);
  if EInd < 1 then
     Count := Length(OrgStr)
  else
     Count := EInd-1;
  StrVal := Copy(OrgStr,0,Count);
  StrVal := GetValueFromStringList(StrVal,'r');
  Result := Trim(StrVal);
end;


Function TGeneralFunctions.GetValueFromStringList(InputStr : String;ValSide : String):String;
begin
  Result := '';
  if valside = 'r' then
     Result := Trim(Copy(InputStr,pos('=',InputStr)+1,length(InputStr)))
  else if valside = 'l' then
     Result := Trim(Copy(InputStr,0,pos('=',InputStr)-1));
end;

function TGeneralFunctions.GetIP:String;
begin
  TIdStack.IncUsage;
  try
    Result :=GStack.LocalAddress;
  finally
    TIdStack.DecUsage;
  end;
end;

function TGeneralFunctions.SubStringOccurences(const subString, sourceString : string; caseSensitive : boolean) : integer;
var
  pEx: integer;
  sub, source : string;
begin
  if caseSensitive then
  begin
    sub := subString;
    source := sourceString;
  end
  else
  begin
    sub := LowerCase(subString);
    source := LowerCase(sourceString);
  end;
  result := 0;
  pEx := PosEx(sub, source, 1);
  while pEx <> 0 do
  begin
    Inc(result);
    pEx := PosEx(sub, source, pEx + Length(sub));
  end;
end;


function TGeneralFunctions.getValueBetweenCurlyBraces(dccaptionStr : String):String;
var
  Idx , s1Pos , s2Pos : Integer;
  TempStr,resultStr : String;
begin
  result := '';
  TempStr := dccaptionStr;
  s1Pos := pos('{',TempStr);
  s2Pos := pos('}',TempStr);
  while (s1Pos > 0) and (s2Pos > 0) do begin
     if resultStr = '' then
        resultStr := Copy(TempStr,s1Pos+1,s2Pos-(s1Pos+1))
     else
        resultStr := resultStr +','+Copy(TempStr,s1Pos+1,s2Pos-(s1Pos+1));
     Delete(TempStr,1,s2Pos);
     s1Pos := pos('{',TempStr);
     s2Pos := pos('}',TempStr);
  end;
  result := resultStr;
end;

function TGeneralFunctions.CheckIfCompressedFile(PFileName : String) : Boolean;
begin
  Result := False;
  if copy(ExtractFileName(PFileName),1,3) = 'c__' then
  begin
    Result := True;
  end;
end;


function TGeneralFunctions.DeCompressFile(PFileName : String) : String;
var
  ucfile : String;
begin
  ucfile := ExtractFilePath(PFileName) +  copy(ExtractFileName(PFileName), 4, length(ExtractFileName(PFileName)));
  if fileexists(PFileName) then
  begin
    with TCompress.Create do
    begin
      decompressfile(PFileName, ucfile);
      PFileName := ucfile;
      destroy;
    end;
  end;
  Result := PFileName;
end;


procedure TGeneralFunctions.GetSortedFileList(fl:TStringList;fpath:String);
Var Rec : TSearchRec;
  FileList: array of string;
  DateList: array of TDateTime;
  i: Integer;
  Done: Boolean;
  TempName: string;
  TempDate: TDateTime;
begin
  if System.SysUtils.FindFirst(fpath, faAnyFile, Rec) = 0 then
  repeat
    Setlength(FileList, Length(FileList) + 1);
    Setlength(DateList, Length(DateList) + 1);
    FileList[High(FileList)]:= Rec.Name;
    DateList[High(DateList)]:= FileDateToDateTime(Rec.Time);
  until System.SysUtils.FindNext(Rec) <> 0;
  System.SysUtils.FindClose(Rec);

  // Sort
  // Bubble sort
  repeat
    Done:= True;
    for i:= 0 to High(FileList) - 1 do
      if DateList[i] > DateList[i + 1] then
      begin
        Done:= False;
        TempName:= FileList[i];
        FileList[i]:= FileList[i + 1];
        FileList[i + 1]:= TempName;

        TempDate:= DateList[i];
        DateList[i]:= DateList[i + 1];
        DateList[i + 1]:= TempDate;

      end;

  until Done;
  if assigned(fl) then
    fl.Clear;
  for i:= 0 to High(FileList) do
    fl.Add(FileList[i]);
  finalize(filelist);
  finalize(datelist);
  filelist:=nil;
  datelist:=nil;
end;




function TGeneralFunctions.IsDefaultFldName(S:String):Boolean;
begin
  result := pos(';'+lowercase(s)+';', ';cancel;sourceid;mapname;username;modifiedon;createdby;createdon;wkid;app_level;app_desc;app_slevel;cancelremarks;wfroles;')>0;
end;

function TGeneralFunctions.ConnectMap(const sRemoteName, sLocalDrive,
  sUserName, sPassword: string): Boolean;
Const
  CONNECT_TEMPORARY : DWORD = 0{x00000004};
var
  NetRes: TNetResource;
  Res: DWord;
  BufferSize: DWORD;
  ResultFlag: DWORD;
begin
  DoDebug.Msg('ConnectMap Satrts '+ TimeToStr(Now()));
  Result := True;
  FillChar(NetRes, SizeOf(TNetResource), 0);
  NetRes.dwType := RESOURCETYPE_DISK;
  NetRes.lpRemoteName := PChar(sRemoteName);
  NetRes.lpLocalName := PChar(sLocalDrive);
  try
  Res := WNetAddConnection2(NetRes, PChar(sPassword), PChar(sUserName), CONNECT_TEMPORARY);
//    Res := WNetUseConnection(0, NetRes, PChar(sUserName), PChar(sPassword),0, nil, BufferSize, ResultFlag);
  finally
    Result := (Res = NO_ERROR);
    if not Result then
    begin
      DoDebug.msg('Mapping Network Drive '+ IntToStr(Res)+' - ' +SysErrorMessage(Res));
      if IsConnectMap then DoDebug.Log('Connecting Network Drive ER'+Axp_logstr+'\uGeneralFunctions\ConnectMap - '+ IntToStr(Res)+' - ' +SysErrorMessage(Res));
      //1326 - bad username and password
      if {((Res = 1219) or (Res = 53) or (Res=1203)) and } (Res <> 1326) and (IsConnectMap) then     //1219 - multiple connections trying to access ; 53 - Netwrok path not found
      begin
         //DisconnectMap(sRemoteName);
         IsConnectMap := False;
         DoDebug.Msg('ConnectMap - '+ IntToStr(Res)+' - ' +SysErrorMessage(Res));
         DoDebug.Log(Axp_logstr+'\uGeneralFunctions\ConnectMap - '+ IntToStr(Res)+' - ' +SysErrorMessage(Res));
         Raise Exception.Create('ErrorCode.'+IntToStr(Res)+' NetWorkMapping connection problem.');
      end;
    end
    else
      DoDebug.msg('Mapping Network Drive Success');
    IsConnectMap := False;
  end;
  DoDebug.Msg('ConnectMap ends '+ TimeToStr(Now()));
end;

// this function will return unused driveletter
Function TGeneralFunctions.GetDriveLetter: String;
var
  MyStr: PChar;
  DrivesInUse, Drive: String;
  Idx, Len: integer;
const
  Size: integer = 200;
  DefDrives: String = 'zyxwvutsrqponmlkjihgfedcba';
begin
  try
    DoDebug.msg('GetDriveLetter Starts.'+ TimeToStr(Now()));
    Result := '';
    DrivesInUse := '';
    try
      GetMem(MyStr, Size);
      Len := GetLogicalDriveStrings(Size, MyStr);
      for Idx := 0 to Len - 1 do
      begin
        Drive := lowercase(MyStr[Idx]);
        if (Drive >= 'a') and (Drive <= 'z') then
          DrivesInUse := DrivesInUse + Drive; // DrivesInUse := DrivesInUse+','+Drive;
      end;
      Idx := 1;
      while (Idx < length(DefDrives)) do
      begin
        if pos(DefDrives[Idx], DrivesInUse) > 0 then
        begin
          inc(Idx);
          continue;
        end
        else
        begin

          Result := Uppercase(DefDrives[Idx]) + ':';
          break;
        end;
      end;
    Except
      on E: Exception do
      begin
        DoDebug.msg('GetDriveLetter Error - ' + E.Message);
        DoDebug.Log(Axp_logstr+'\uGeneralFunctions\GetDriveLetter Error - ' + E.Message);
      end;
    end;
    DoDebug.msg('GetDriveLetter ends.'+ TimeToStr(Now()));
  finally
    FreeMem(MyStr);
  end;
end;

Function TGeneralFunctions.IsAccessiblePath(sPath : String)
  : boolean; // Shankar.J  dt. 07/01/2015
Var
  sDrive: String;
  FAccess: Cardinal;
begin
  Result := true;
  if (sMapUserName = '') or (sMapPassword = '') then  Exit;
  if Axp_MapDriveLetter = '' then
    Axp_MapDriveLetter := GetDriveLetter;
  sDrive := Axp_MapDriveLetter;
  Result := False;
  if AnsiEndsStr('\', sPath) then
    delete(sPath, length(sPath), 1);
  DisconnectMap(sPath, true);
  DoDebug.msg('IsAccessiblePath - Connecting to Network Drive Starts.');
  DoDebug.msg('Connecting ' + sDrive);
  IsConnectMap := true;
  If ConnectMap(sPath, sDrive, sMapUserName, sMapPassword) then
  begin
    Result := true;
  end;
  DoDebug.msg('IsAccessiblePath - Connecting to Network Drive Ends.');
end;

function TGeneralFunctions.DisconnectMap(sPath: string;
  IsInitCall: boolean = False): boolean;
Const
  CONNECT_TEMPORARY: DWORD = 0 { x00000004 };
var
  res: DWORD;
  slash, hash, sDrive: String;
begin
  if Axp_MapDriveLetter = '' then
    exit;
  DoDebug.msg('DisconnectMap starts'+ TimeToStr(Now()));
  DoDebug.msg('Disconnecting ' + Axp_MapDriveLetter);
  sDrive := Axp_MapDriveLetter;
  res := WNetCancelConnection2(PChar(sDrive), CONNECT_TEMPORARY, true);
  // true - force Discoonect
  Result := (res = NO_ERROR);
  if not Result then
  begin
    DoDebug.msg('Disconnecting Network Drive ' + SysErrorMessage(res));
    DoDebug.Log(Axp_logstr + '\uGeneralFunctions\DisconnectMap - ' +
      SysErrorMessage(res));
  end;
  try
    ShellExecute(application.Handle, nil, 'cmd.exe',
      PWideChar('/c net use /del ' + sDrive), nil, SW_HIDE);
    // to delete the drive if it exists

  except
  end;
  if Not IsInitCall then
    Axp_MapDriveLetter := '';
  DoDebug.msg('DisconnectMap ends'+ TimeToStr(Now()));
end;

Function TGeneralFunctions.SubTotalColour(FStr:String):String;
var tcspos, tcepos : integer;
begin
    tcspos := pos('[tc', lowercase(FStr));
    if tcspos > 0 then
    begin
      tcepos := pos('tc]', lowercase(FStr));
      result := Trim(copy(FStr,tcspos+3,tcepos-tcspos-3));
    end else
      result := 'clMaroon';
end;

function TGeneralFunctions.ColorToHtml(DColor:TColor):string;
var
  tmpRGB : TColorRef;
begin
  tmpRGB := ColorToRGB(DColor) ;
  Result:=Format('#%.2x%.2x%.2x',
                 [GetRValue(tmpRGB),
                  GetGValue(tmpRGB),
                  GetBValue(tmpRGB)]) ;
end; {function ColorToHtml}



Function TGeneralFunctions.RemoveSeparator(S: String): String;
Begin
  result := RemoveCommas(s);
End;

Function TGeneralFunctions.InsertSeparator(S: String): String;
Begin
  result := InsertCommas(s);
End;

Function TGeneralFunctions.RemoveDynamicFilterCBraces(Input : string): string;
var
  spos, epos : integer;
begin
  Result := '';
  epos := -1;
  spos := pos('{dynamicfilter',lowercase(Input));
  while spos > 0 do
  begin
    epos := pos('}',Copy(Input,spos,length(Input)));
    Delete(Input,spos,epos);
    spos := pos('{dynamicfilter',lowercase(Input));
  end;
  Result := Input;
end;

Procedure TGeneralFunctions.DeleteReadOnlyFile(ReadOnlyFile:String);
Begin
	try
    if (FileGetAttr(ReadOnlyFile) and System.SysUtils.faReadOnly) > 0 then
    begin
       DoDebug.Msg('Removing ReadOnly mode from the file');
       FileSetReadOnly(ReadOnlyFile,False); //FileSetAttr(ImgPath+fname,Not faReadOnly);
       DoDebug.Msg('Deleting the file again');
       if Not System.SysUtils.DeleteFile(ReadOnlyFile) then
        RaiseLastOSError;
       DoDebug.Msg('File has been deleted successfully.');
    end;
  Except
    on E:Exception do
    begin
     DoDebug.Msg('Error while deleting file '+(ReadOnlyFile));
     DoDebug.Msg('Error : '+E.Message); DoDebug.Log('uGeneralFunction\DeleteReadOnlyFile - Error : '+E.Message);
    end;
  end;
end;

procedure TGeneralFunctions.SetConnectVariables;
begin
  LenMaxSiteNo := Length(IntToStr(MaxSiteNo));
  MaxConnectNo := 9999;
  MaxLastNo := StrToFloat(Pad('',9-(LenMaxSiteNo-2),'9'));
  MaxRecid := LenMaxSiteNo+Length(FloatToStr(MaxConnectNo))+Length(Floattostr(MaxLastNo));
end;


function TGeneralFunctions.ReplaceTableName(st_pos: Integer;
  SubStr, Tmp_Str, SQL_Query: String): String;
var
  Tab_Name, Search_Str: String;
  Tab_found: Boolean;
  End_Pos_of_SubStr, Idx, ed_pos: Integer;
begin
  result := SQL_Query;
  Tab_Name := '';
  End_Pos_of_SubStr := st_pos + (length(SubStr) - 1);
  Idx := End_Pos_of_SubStr;
  Tab_found := false;
  Search_Str := Trim(copy(SQL_Query, End_Pos_of_SubStr, length(SQL_Query)));
  while not Tab_found do
  begin
    if ((Tmp_Str[Idx] = ' ') or (Tmp_Str[Idx] = ')') or (Tmp_Str[Idx] = '(') or (Idx > length(SQL_Query)
      )) and (Trim(Tab_Name) <> '')  then
    begin
      if (copy(Trim(Tab_Name), 1, 1) = '(') then break;
      ed_pos := Idx - 1;
      Delete(SQL_Query, End_Pos_of_SubStr, length(Tab_Name));
      Insert(lowercase(Tab_Name), SQL_Query, End_Pos_of_SubStr);
      result := StringReplace(SQL_Query, Tab_Name, lowercase(Tab_Name),
        [rfIgnoreCase]);
      Tab_found := true;
      break;
    end
    else
      Tab_Name := Tab_Name + Tmp_Str[Idx];
    Inc(Idx);
  end;
end;


function TGeneralFunctions.ChangeTableNametoLowercase(SubStr, Tmp_Str, Org_Str: string): String;
var
  Len, Pos1: Integer;
begin
  Pos1 := length(Tmp_Str);
  Len := length(SubStr);
  Pos1 := Pos1 - Len;
  while (Pos1 > 0) do
  begin
    if copy(Tmp_Str, Pos1, Len) = SubStr then
    begin
      Org_Str := ReplaceTableName(Pos1, SubStr, Tmp_Str, Org_Str);
    end;
    Dec(Pos1);
  end;
  ChangeTableNametoLowercase := Org_Str;
end;


function TGeneralFunctions.CallChangeTableNametoLowercase(ORG_SQL,Sub_Str:String):String;
var
  TMP_SQL: String;
begin
  Result := ORG_SQL;
  //Sub_Str := ' from ';
  ORG_SQL := StringReplace(StringReplace(ORG_SQL, #10, ' ', [rfReplaceAll]),
    #13, ' ', [rfReplaceAll]);
  TMP_SQL := lowercase(ORG_SQL);
  ORG_SQL := ChangeTableNametoLowercase(Sub_Str, TMP_SQL, ORG_SQL);
  // ORG_SQL := CallReplaceTableName(' from(',TMP_SQL,ORG_SQL);
  Result := ORG_SQL;
end;

Function TGeneralFunctions.GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Unknown';
End;

procedure TGeneralFunctions.AxpGetLocaleInfo;
var  LocVal: PChar;
    fs : TFormatSettings;
    var s:array[0..1] of char;
    tmp : String;
begin
  LocVal := StrAlloc(10);
  GetLocaleInfo(LOCALE_User_DEFAULT,LOCALE_SDECIMAL,LocVal,2);
  LocDecimalSeparator := LocVal;
//  GetLocaleInfo(LOCALE_User_DEFAULT,LOCALE_NOUSEROVERRIDE+LOCALE_STHOUSAND,LocVal,2);
  GetLocaleInfo(LOCALE_User_DEFAULT,LOCALE_STHOUSAND,LocVal,2);
  LocThousandSeparator := LocVal;
  StrDispose(LocVal);
  if (CurrencySeparator <> '')  and (CurrencySeparator <> LocThousandSeparator) then
  begin
    fs := TFormatSettings.Create;
    fs.ThousandSeparator := CurrencySeparator[1];
    if CurrencySeparator = '.' then
      fs.DecimalSeparator := ','
    else
      fs.DecimalSeparator := '.' ;
    LocThousandSeparator := CurrencySeparator;
    LocDecimalSeparator := fs.DecimalSeparator ;
    System.SysUtils.FormatSettings := fs;
  end;
end;

Function TGeneralFunctions.GetGMTBias: Integer;
var
Info: TTimeZoneInformation;
Mode: DWord;
begin
Mode := GetTimeZoneInformation (info);
Result := info.Bias;
Case Mode of
TIME_ZONE_ID_INVALID:
RaiseLastOSError;
TIME_ZONE_ID_STANDARD:
Result := Result + info.StandardBias;
TIME_ZONE_ID_DAYLIGHT:
Result := Result + info. DaylightBias;
end;
end;


Function TGeneralFunctions.LocaleToGMT (const Value: TDateTime): TDateTime;
begin
Result := Value + (GetGMTBias / MinsPerDay);
end;


Function TGeneralFunctions.GMTToLocale (const Value: TDateTime): TDateTime;
begin
Result := Value - (GetGMTBias / MinsPerDay);
end;

Function TGeneralFunctions.IsKeyword(fname: String): Boolean;
Var
  KeyWordList: String;
Begin
  if not assigned(srlKeyWords) then
  begin
    srlKeyWords := TStringList.Create;
    srlKeyWords.CaseSensitive := false;
    KeyWordList :=
      'ADD,ALTER,AND,ANY,AS,ASC,AUDIT,BETWEEN,BY,CHAR,CHECK,CLUSTER,COLUMN,COMMENT';
    KeyWordList := KeyWordList + ',' +
      'COMPRESS,CONNECT,CREATE,CURRENT,DATE,DECIMAL,DEFAULT,DELETUE';
    KeyWordList := KeyWordList + ',' +
      'DESC,DISTINCT,DROP,ELSE,EXCLUSIVE,EXISTS,FILE,FLOAT,FOR,FROM';
    KeyWordList := KeyWordList + ',' +
      'GRANT,GROUP,HAVING,IDENTIFIED,IMMEDIATE,IN,INCREMENT,INDEX,INITIAL';
    KeyWordList := KeyWordList + ',' +
      'INSERT,INTEGER,INTERSECT,INTO,IS,LEVEL,LIKE,LOCK,LONG,MAXEXTENTS,MINUS';
    KeyWordList := KeyWordList + ',' +
      'MODE,MODIFY,NOAUDIT,NOCOMPRESS,NOT,NOWAIT,NULL,NUMBER,OF,OFFLINE,OPTION';
    KeyWordList := KeyWordList + ',' +
      'OR,ORDER,PCTFREE,PRIOR,PRIVILEGES,PUBLIC,RAW,RENAME,RESOURCE,REVOKE';
    KeyWordList := KeyWordList + ',' +
      'ROW,ROWID,ROWLABEL,ROWNUM,ROWS,SELECT,SESSION,SET,SHARE,SIZE,SMALLINT';
    KeyWordList := KeyWordList + ',' +
      'START,SUCCESSFUL,SYNONYM,SYSDATE,TABLE,THEN,TO,TRIGGER,UID,UNION';
    KeyWordList := KeyWordList + ',' +
      'UNIQUE,USER,VALIDATE,VALUES,VARCHAR,VARCHAR2,VIEW,WHENEVER,WHERE,WITH';
    KeyWordList := KeyWordList + ',' +
      'SIZE,SELECT,DROP,AS,IN,ADD,UPDATE,ALTER,FIELD,COLUMN,ORDER,VIEW';
    KeyWordList := KeyWordList + ',' +
      'TABLE,TAB,FROM,DATABASE,VALUES,ORDER BY,DEFAULT,VALUE,JOINT,PASSWORD';
    KeyWordList := KeyWordList + ',' +
      'GROUP,NO,NOT,TO,FieldChanged,GetRCell,Upper,Lower,DTOC';
    KeyWordList := KeyWordList + ',' +
      'CTOD,RND,ROUND,STUFF,IIF,AmtWord,Val,STR,SUBSTR,Convert,RevConvert';
    KeyWordList := KeyWordList + ',' +
      'Encode,Decode,HashChar,MandY,DaysElapsed,TimeElapsed,AddToTime';
    KeyWordList := KeyWordList + ',' +
      'AddToDate,AddToMonth,IsEmptyValue,LastDayOfMonth,ValidEncodeDate';
    KeyWordList := KeyWordList + ',' +
      'Eval,IsEmpty,Abs,MakeDate,Date,FormatDateTime,Time,DayofDate';
    KeyWordList := KeyWordList + ',' +
      'MonthofDate,YearofDate,Gen_id,Total,Sum,GetMax,GetValue,GetId';
    KeyWordList := KeyWordList + ',' +
      'GetRow,GetRowCount,GetCostRate,GetAdjustedAmount,SumTill';
    KeyWordList := KeyWordList + ',' +
      'GetCell,GETINTEGER,Power,CreatedBy,CreatedOn';
    KeyWordList := KeyWordList + ',' +
      'AxpCeil,AxpFloor,Days360,data';
    srlKeyWords.Delimiter := ',';
    srlKeyWords.DelimitedText := UpperCase(KeyWordList);
  end;
  if (srlKeyWords.IndexOf(uppercase(fname)) > -1) then
    result := True
  else
    result := false;
end;

Procedure TGeneralFunctions.StoreInPercentage(n:ixmlnode; tlhwstr:String; wc:TControl );
var t, l ,h, w : Real;
    ph : integer;
    s : string;
begin
  t :=  StrtoInt(GetNthString(tlhwstr,1));
  l :=  StrtoInt(GetNthString(tlhwstr,2));
  h :=  StrtoInt(GetNthString(tlhwstr,3));
  w :=  StrtoInt(GetNthString(tlhwstr,4));

  if lowercase(wc.Parent.Name) = 'clientpanel' then
    ph := wc.Parent.Height    //-50
  else
    ph := wc.Parent.Height;

  t := roundto((t/ph)*100,-4);
  l := roundto((l/wc.Parent.Width)*100,-4);
  h := roundto((h/ph)*100,-4);
  w := roundto((w/wc.Parent.Width)*100,-4);

  n.Attributes['ptlhw'] := FloatToStr(t)+','+FloatToStr(l)+','+FloatToStr(h)+','+FloatToStr(w);
  s := GetTlhw(vartostr(n.Attributes['ptlhw']),wc);
end;

Function TGeneralFunctions.GetTlhw(tlhwstr:String;wc:TControl):String;
var t, l ,h, w : integer;
    rt, rl ,rh, rw : Extended;
    s : string;
    ph, pw, wfact, hfact, cfact : integer;
begin
  result := '';
  if tlhwstr = '' then exit;
  hfact := 0;
  wfact := 0;

  rt := StrtoFloat(GetNthString(tlhwstr,1));
  rl := StrtoFloat(GetNthString(tlhwstr,2));
  rh := StrtoFloat(GetNthString(tlhwstr,3));
  rw := StrtoFloat(GetNthString(tlhwstr,4));
  wfact := 0;
  hfact := 0;
  ph := wc.Parent.ClientHeight+wfact;
  pw := wc.Parent.ClientWidth+hfact;
  t := Round((rt/100)*ph);
  cfact := 0;
  l := Round((rl/100)*pw)+cfact;
  h := Round((rh/100)*ph);
  w := Round((rw/100)*pw);
  result := IntToStr(t)+','+IntToStr(l)+','+IntToStr(h)+','+IntToStr(w);
end;


procedure TGeneralFunctions.AlignTextinGrid(PCanvas: TCanvas; PHandle: HDC; PAlignment: Integer; PRect: TRect; ctxt:String);
var
 PPos  :integer;
begin
  SetTextAlign(PHandle, PAlignment);
  if PAlignment = TA_LEFT then
  begin
    PPos := (PRect.Left + 2);
    PCanvas.TextRect(PRect, PPos, PRect.Top + 2, ctxt);
  end
  else if PAlignment = TA_CENTER then
  begin
    PPos := (PRect.Left + PRect.Right) div 2;
    PCanvas.TextRect(PRect, PPos, PRect.Top + 2, ctxt);
  end
  else if PAlignment = TA_RIGHT then
  begin
    PPos := (PRect.Right - 2);
    PCanvas.TextRect(PRect, PPos, PRect.Top + 2, ctxt);
  end;
end;

procedure TGeneralFunctions.SaveFont(f:TFont; n:ixmlnode; Att:String);
var s,t:String;
begin
  s:='';
  s:=f.Name;
  s:=s+',';
  s:=s+inttostr(f.Size);
  s:=s+',';
  t:='ffff';
  if fsbold in f.style then t[1]:='t';
  if fsItalic in f.Style then t[2]:='t';
  if fsUnderline in f.Style then t[3]:='t';
  if fsStrikeOut in f.Style then t[4]:='t';
  s:=s+t;
  s:=s+',';
  s:=s+colortostring(f.color);

  n.Attributes[att]:=s;
end;

function TGeneralFunctions.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

function TGeneralFunctions.ReplaceSpecialChars(sVal:String):String;
var i : integer;
begin
  result := '';
  for i := 1 to Length(sVal) do
  begin
    if (IsAlphaNumeric(sVal[i])) and (sVal[i] <> ' ') then
      result := result+sVal[i];
  end;
end;

Function TGeneralFunctions.EncryptPwd(pwd : string):String;
  var sfile,insid,dtid,s,dbn, dbuser : string;
  i : integer;
begin
  result := '';
  insid := pwd ;
  dtid := GetTimeId();
  i := length(dtid);
  s := dtid;
  delete(s,i-3,i);
  insid := EncodeDBID(s,insid);
  insid := insid + dtid;
  result := insid;
end;

function TGeneralFunctions.GetTimeId() : string   ;
   var dtime, s , s1 : string;
   i : integer;
begin
  dtime := '01020345060708';
  i := strtoint(copy(dtime,1,2));
  s := inttostr( i + 31);
  s := s  + inttostr(strtoint(copy(dtime,3,2))+ i+13);
  s := s + inttostr(strtoint(copy(dtime,5,4)) * i);
  s := s + copy(dTime,9,2) + copy(dTime,11,2) + copy(dTime,13,2);
  i := length(s);
  s1 := format('%.4d',[i]);
  result := s + s1;
end;

function TGeneralFunctions.EncodeDBID(dtid,dbid:String):String;
var l,l1, i : Integer;
    s,s1 : String;
begin
  Result := '';
  l := Length(dbid);
  l1 := Length(dtid);
  if l1 < l then
  begin
    for i := l1 to l do
        dtid := dtid + '0';
  end;
  for i := 1 to l do
  begin
    s := s + Chr(ord(dtid[i])+Ord(dbid[i]));
  end;
  l := length(s);
  for i := 1 to l do
  begin
    s1 := s1 + format('%.4d',[ord(s[i])]);
  end;
  i := length(dbid);
  s := format('%.4d',[i]);
  Result := s+s1;
end;

function TGeneralFunctions.Isnumeral(s:String):boolean;
var i:integer;
begin
  result:=true;
  for I := 1 to length(s) do begin
    if not (s[i] in numbers) then begin
      result:=false;
      break;
    end;
  end;
end;

function TGeneralFunctions.GetPickListModeValue(plMode:TPickListMode):String;
begin
  if plMode = plmAnywhere then
    result := 'c'
  else if plMode = plmStartwith then
    result := 's'
  else if plMode = plmEndswith then
    result := 'e'
  else
    result := 'c';
end;

function TGeneralFunctions.GetPickListMode(smode:String):TPickListMode;
begin
  smode := lowercase(smode);
  if smode = 'c' then
    result := plmAnywhere
  else if smode = 's' then
    result := plmStartwith
  else if smode = 'e' then
    result := plmEndswith
  else
    result := plmAnywhere
end;

function TGeneralFunctions.GetPickListModeItem(smode:String):String;
begin
  smode := lowercase(smode);
  if smode = 'c' then
    result := 'Contains'
  else if smode = 's' then
    result := 'Starts with'
  else if smode = 'e' then
    result := 'Ends with'
  else
    result := 'Contains';
end;

function TGeneralFunctions.GetSearchValue(plmode:TPickListMode;SrchVal:String):String;
begin
  if plmode = plmNone then
  begin
    if FormLevelPickListMode <> plmNone then
      plmode := FormLevelPickListMode
    else
      plmode := PickListMode
  end;
   if plmode = plmStartWith then
     result := SrchVal+'%'
   else if plmode = plmEndsWith then
     result := '%'+SrchVal
   else
     result := '%'+SrchVal+'%';
end;

function TGeneralFunctions.IsValidDate(ADate:String):Boolean;
var
  myDate:TDate;
begin
  Result := False;
  try
    myDate:= StrToDate(ADate);
    Result := True;
  except
  end;
end;

//Author: Manoj   Date: 22-03-2018
function TGeneralFunctions.GetAutoCorrectFmtDate(const ADate:String; const ADateSeparator:string): string;
var
  sDate, curChar, sDateParam, newDate:string;
  formattedDate:string;
begin
  sDate := ADate;
  sDateParam := '';
  if (Length(sDate)>=Length(ADateSeparator)) and (Copy(sDate, Length(sDate), Length(ADateSeparator))<> ADateSeparator) then
    sDate := sDate + ADateSeparator;
  while (sDate<>'') do begin
    curChar := Trim(Copy(sDate, 1, 1));
    Delete(sDate, 1, 1);
    if (curChar<>'') and (not IsNumeric(curChar) or (sDate='')) then
    begin
      if (Length(sDateParam)<=0) then
        sDateParam := 'X';
      if (Length(sDateParam)<DayLen) then
      begin
        if sDateParam = 'X' then
          sDateParam := sDateParam.PadLeft(DayLen, 'X')
        else
          sDateParam := sDateParam.PadLeft(DayLen, '0');
      end
      else if (Length(sDateParam)>DayLen) and (Length(sDateParam)< (DayLen+MonLen)) then
        sDateParam := sDateParam.PadLeft(YearLen, '0');
      newDate := newDate + ADateSeparator  + sDateParam;
      sDateParam := '';
    end
    else
      sDateParam := sDateParam + curChar;
  end;

  if (Length(newDate)>=Length(ADateSeparator)) then
    Delete(newDate, 1, Length(ADateSeparator));
  Result := newDate;
end;

//Requirement: Date Column – Format should take automatically. User will enter in any format (/,-,.). Also if enter only date current month & year should pick automatically, if enter only date and month year should pick automatically - 4th May 2018
//This function will do Auto Filling of Month and Year
function TGeneralFunctions.GetAutoFilledDate(const ADate:String):TDate;
var
  sDate, sSysDateFmt, sDStr, sMStr, sYStr:String;
  iDay, iMonth, iYear, iDaysInMonth: Integer;
  currentYear, currentMonth, currentDay: Word;
  ModifiedDate:TDate;
  dateArray : array[0..3] of Integer;
  errorPos:Integer;
  CurCent : String;
begin
  if (IsValidDate(ADate)) then
  begin
    Result := StrToDate(ADate);
    Exit;
  end;
  sSysDateFmt := LowerCase(ShortDateFormat.ShortDateFormat);
  DayLen := Length(GetNthString(sSysDateFmt, 1, ShortDateFormat.DateSeparator));
  MonLen := Length(GetNthString(sSysDateFmt, 2, ShortDateFormat.DateSeparator));
  YearLen := Length(GetNthString(sSysDateFmt, 3, ShortDateFormat.DateSeparator));
  sDate := GetAutoCorrectFmtDate(ADate, ShortDateFormat.DateSeparator);

  DecodeDate(Now, currentYear, currentMonth, currentDay);

  sDStr := GetNthString(sDate, 1, ShortDateFormat.DateSeparator);
  sMStr := GetNthString(sDate, 2, ShortDateFormat.DateSeparator);
  sYStr := GetNthString(sDate, 3, ShortDateFormat.DateSeparator);
  if (length(sYStr) = 2) and (YearLen = 4) then
  begin
    CurCent := Copy(intToStr(CurrentYear),1,2);
    sYStr := CurCent+sYStr;
  end;

  iDay   := StrToIntDef(sDStr, currentDay);
  iMonth := StrToIntDef(sMStr, currentMonth);
  iYear  := StrToIntDef(sYStr, currentYear);
  if iMonth > 12 then
    iMonth := Math.Min(iMonth, currentMonth);
  iDaysInMonth := DaysInAMonth(iYear, iMonth);
  if iDay > iDaysInMonth then
    iDay := CurrentDay;
  Result := EncodeDate(iYear, iMonth, iDay);
end;

Function TGeneralFunctions.GetIPAddress():String;
type
  pu_long = ^u_long;
var
  varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf : {Array[0..255] of} PAnsichar;
begin
  try
    If WSAStartup($101,varTWSAData) <> 0 Then
    Result := 'No. IP Address'
    Else Begin
      gethostname(namebuf,sizeof(namebuf));
      varPHostEnt := gethostbyname(namebuf);
      varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
      Result := inet_ntoa(varTInAddr);
    End;
    WSACleanup;
  Except on E:Exception do
  begin
    DoDebug.Msg('GetIPAddress error : '+E.Message);
    Result := 'No. IP Address';
  end;
  end;
end;

procedure TGeneralFunctions.TrimAppMemorySize;
var
  MainHandle : THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID) ;
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF) ;
    CloseHandle(MainHandle) ;
  except
  end;
  Application.ProcessMessages;
end;

procedure TGeneralFunctions.GetUsedGlobalVarsInSqlParams(SqlCds : TCLientDataSet);
  var  j,i : Integer;
       s : AnsiString;
begin
  if MobileWSFlag then exit;
  if not assigned(SqlCds) then exit;
  if SqlCds.Params.Count = 0 then exit;
  for j := 0 to SqlCds.Params.Count - 1 do
  begin
    i := -1;
    s := SqlCds.Params[j].Name;
    i := AppVars.IndexOfName(s);
    if i = -1 then
    begin
      s := lowercase(SqlCds.Params[j].Name);
      i := AppVars.IndexOfName(s);
    end;
    if i = -1 then
    begin
      s := uppercase(SqlCds.Params[j].Name);
      i := AppVars.IndexOfName(s);
    end;
    if i > -1 then
    begin
      s := SqlCds.Params[j].Name + '=' + appvars.Values[AppVars.Names[i]];
      if not assigned(GlobalVarsInSqlParams) then GlobalVarsInSqlParams := TStringList.Create;
      if GlobalVarsInSqlParams.IndexOf(s)=-1  then GlobalVarsInSqlParams.Add(s);
    end else if lowercase(s) = 'username' then
    begin
      if not assigned(GlobalVarsInSqlParams) then GlobalVarsInSqlParams := TStringList.Create;
      s := 'username='+username;
      if GlobalVarsInSqlParams.IndexOf(s)=-1  then GlobalVarsInSqlParams.Add(s);
    end;
  end;
end;

procedure TGeneralFunctions.GetUsedGlobalVarsInExpr(fld_expr : string);
  var  j,i,l : Integer;
       s,s1 : AnsiString;
begin
  if MobileWSFlag then exit;
  fld_expr := lowercase(fld_expr);
  for j := 0 to AppVars.Count - 1 do
  begin
    s := lowercase(AppVars.Names[j]);
    i := pos(s,fld_expr);
    if i > 0 then
    begin
      l := length(s);
      s1 := copy(fld_expr,i,l);
      if s = s1 then
      begin
         s := AppVars.Names[j] + '=' + appvars.Values[AppVars.Names[j]];
         if not assigned(GlobalVarsInSqlParams) then GlobalVarsInSqlParams := TStringList.Create;
         if GlobalVarsInSqlParams.IndexOf(s)=-1  then GlobalVarsInSqlParams.Add(s);
      end;
    end;
  end;
  if pos('username',fld_expr) > 0 then
  begin
    if not assigned(GlobalVarsInSqlParams) then GlobalVarsInSqlParams := TStringList.Create;
    s := 'username='+username;
    if GlobalVarsInSqlParams.IndexOf(s)=-1  then
    begin
      GlobalVarsInSqlParams.Add(s);
    end;
  end;
end;

function TGeneralFunctions.GlobalVarsInExprAndSqls : String;
  var i : integer;
      s,n,v,d : string;
begin
  result := '';
  if not assigned(GlobalVarsInSqlParams) then exit;
  s := '';
  for i := 0 to GlobalVarsInSqlParams.Count - 1 do
  begin
    n := trim(GlobalVarsInSqlParams.Names[i]);
    v := trim(GlobalVarsInSqlParams.Values[n]);
    v:=FindAndReplace(v, '"', '^^dq');
    s := s + '{"n":"'+n+'","v":"'+v+'"},';
  end;
  if s <> '' then
  begin
    delete(s,length(s),1);
    result := s;
  end;
end;

function TGeneralFunctions.RoundEx(const AInput: extended; APlaces: integer): extended;
var
  k: extended;
begin
  if APlaces = 0 then begin
    result := round(AInput);
  end else begin
    if APlaces > 0 then begin
      k := power(10, APlaces);
      result := round(AInput * k) / k;
    end else begin
      k := power(10, (APlaces*-1));
      result := round(AInput / k) * k;
    end;
  end;
end;

function TGeneralFunctions.EncryptStr(Value : String): String;
begin
  Result := Encrypt(Value, Sym_key);
end;

function TGeneralFunctions.DecryptStr(Value : String): String;
begin
  Result := Trim(Decrypt(Value, Sym_key));
end;

function TGeneralFunctions.EncryptFldValue(Value , dt : String): String;
  var key : string;
  val : Extended;
begin
  result := value;
  if value = '' then exit;
  if (dt = 'c') or (dt = 't') then
  begin
     key := encrypt_key;
     Result := Encrypt(Value,key);
  end;
end;

function TGeneralFunctions.DecryptFldValue(Value  , dt : String): String;
  var key, orgval : string;
  val : Extended;
begin
  orgval := Value;
  result := orgval;
  if value = '' then exit;
  try
  if (dt = 'c') or (dt = 't') then
  begin
     key := encrypt_key;
     Result := Trim(Decrypt(Value,key));
  end;
  except on e:exception do
  begin
    try
      key := copy(value,1,14);
      delete(value,1,14);
      Result := Trim(Decrypt(Value,key));
    except
      result := orgval;
    end;
  end;
  end;
end;

function TGeneralFunctions.GetQuotedStr(DelimitedStr, Delimiter: String) : String;
var i:integer;
    s : String;
begin
  Result := '';
  if delimiter = '' then delimiter := ',';
  i := 1;
  s := GetNthString(DelimitedStr,i,Delimiter);
  while s <> '' do begin
    result := result+','+QuotedStr(s);
    inc(i);
    s := GetNthString(DelimitedStr,i,Delimiter);
  end;
  if result <> '' then delete(result,1,1);
end;

Procedure TGeneralFunctions.SetValuesToRedis(HostName, KeyName, KeyValue : String ; pwd:String='' ; timeout:integer=0);
begin
  {$IFNDEF  NOT ForRestDll}
  ConnectToRedisServer(HostName,pwd);
  if FRedis <> nil then
  begin
    FRedis.&SET(KeyName,KeyValue);
    if timeout <> 0 then FRedis.EXPIRE(KeyName,timeout);
  end else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('InMemory DB Redis not ready to connect...');
  {$ENDIF};
end;

Procedure TGeneralFunctions.SetValuesToRedisConn(HostName, KeyName, KeyValue : String);
begin
  {$IFNDEF  NOT ForRestDll}
  ConnectToRedisServerWithXML(HostName);
  if FRedis <> nil then
  begin
    FRedis.&SET(KeyName,KeyValue);
//    if timeout <> 0 then FRedis.EXPIRE(KeyName,timeout);
  end else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('InMemory DB Redis not ready to connect...');
  {$ENDIF};
end;

Function TGeneralFunctions.GetValuesFromRedis(Hostname, KeyName : String;pwd:String=''): String;
begin
  {$IFNDEF  NOT ForRestDll}
  Result := '';
  ConnectToRedisServer(HostName,pwd);
  if FRedis <> nil then FRedis.GET(KeyName,Result)
  else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('Inmemory DB Redis not ready to connect...');
  {$ENDIF};
end;


Function TGeneralFunctions.GetValuesFromRedisConn(Hostname, KeyName : String): String;
begin
  {$IFNDEF  NOT ForRestDll}
  Result := '';
  ConnectToRedisServerWithXML(HostName);
  if FRedis <> nil then FRedis.GET(KeyName,Result)
  else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('Inmemory DB Redis not ready to connect...');
  {$ENDIF};
end;

Procedure TGeneralFunctions.DeleteKeyFromRedis(Hostname, KeyName : String;pwd:String='');
var
  {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
   lRes: TRedisArray;
   //lArr: TArray<TRedisString>;
  {$ENDIF}
  List: TArray<String>;
  i  : integer;
begin
  {$IFNDEF  NOT ForRestDll}
  ConnectToRedisServer(HostName,pwd);
//  if FRedis <> nil then FRedis.DEL(KeyName)
//    KeyName := KeyName+'*';
  if FRedis <> nil then
  begin
    List :=  TArray<String>.Create();
    {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
    lRes := FRedis.KEYS(KeyName);
    List := TArray<String>(lRes.Value);
    {$ELSE} //FOR XE3/XE8 VERSION
    List := FRedis.KEYS(KeyName);
    {$ENDIF}
    for i := 0 to High(List) do begin
      FRedis.DEL(List[i]);
    end;
    List := nil;
  end else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('Inmemory DB Redis not ready to connect...');
  {$ENDIF};
end;

Function TGeneralFunctions.GetRedisKeyCount(Hostname, KeyName : String;pwd:String='') : Integer;
var
  {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
  lRes: TRedisArray;
  //lArr: TArray<TRedisString>;
  {$ENDIF}
  List: TArray<String>;
begin
  {$IFNDEF  NOT ForRestDll}
  Result := 0;
  ConnectToRedisServer(HostName,pwd);
  if FRedis <> nil then
  begin
    KeyName := KeyName+'*';
    List :=  TArray<String>.Create();
    {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
    lRes := FRedis.KEYS(KeyName);
    List := TArray<String>(lRes.Value);
    {$ELSE} //FOR XE3/XE8 VERSION
    List := FRedis.KEYS(KeyName);
    {$ENDIF}
    result := high(List) + 1 ;
    List := nil;
  end else if redis_errmsg <> '' then raise Exception.Create(redis_errmsg)
  else raise Exception.Create('Inmemory DB Redis not not ready to connect...');
  {$ENDIF};
end;

procedure TGeneralFunctions.ConnectToRedisServer(Host : String;pwd:String='');
var PortNo , i : Integer;
    IPAddress,insid,cpuid : String;
begin
  {$IFNDEF  NOT ForRestDll}
  redis_errmsg := '';
  if POS(':',Host)>0 then
  begin
    IPAddress := Copy(Host,1,pos(':',Host)-1);
    PortNo := strtoint(Copy(Host,pos(':',Host)+1,Length(Host)));
  end else
  begin
    IPAddress := Host;
    PortNo := 6379;
  end;
  try
    if pwd <> '' then
    begin
      i := 0;
      insid := pwd;
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      pwd := Get_Password(insid,cpuid);
    end;
    {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
    FRedis := NewRedisClient(IPAddress,PortNo, REDIS_NETLIB_INDY);
    {$ELSE} //FOR XE3/XE8 VERSION
    FRedis := NewRedisClient(IPAddress,PortNo, False, REDIS_NETLIB_INDY);
    {$ENDIF}
    if pwd <> '' then FRedis.AUTH(pwd);
  Except on E:Exception do
  begin
    FRedis := nil;
    redis_errmsg := e.Message;
  end;
  end;
  {$ENDIF};
end;

procedure TGeneralFunctions.ConnectToRedisServerWithXML(Host : String);
var PortNo , i : Integer;
    IPAddress,insid,cpuid,pwd,port : String;
    n : ixmlnode;
begin
  {$IFNDEF  NOT ForRestDll}
  n := nil;
  redis_errmsg := '';
  if RedisConnXML <> nil then
     n := RedisConnXML.ChildNodes.FindNode(host)
  else begin
    with TStringList.Create do
    begin
      pwd := exepath + '\';
      // pt:= ExtractFilePath(application.ExeName);
      loadfromfile(pwd + 'redisconns.xml');
      if text <> '' then
      begin
         RedisConnXML := LoadXMLData(text).DocumentElement;
         n := RedisConnXML.ChildNodes.FindNode(host);
      end;
      Free;
    end;
  end;
  if n = nil then raise Exception.Create('Redis connection details not available...');
  host := vartostr(n.ChildNodes.FindNode('host').NodeValue);
  port := vartostr(n.ChildNodes.FindNode('port').NodeValue);
  pwd  := vartostr(n.ChildNodes.FindNode('pwd').NodeValue);
  if POS(':',Host)>0 then
  begin
    IPAddress := Copy(Host,1,pos(':',Host)-1);
    PortNo := strtoint(Copy(Host,pos(':',Host)+1,Length(Host)));
  end else
  begin
    IPAddress := Host;
    if port = '' then PortNo := 6379
    else PortNo := strtoint(port);
  end;
  try
    if pwd <> '' then
    begin
      i := 0;
      insid := pwd;
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      pwd := Get_Password(insid,cpuid);
    end;
    {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
    FRedis := NewRedisClient(IPAddress,PortNo, REDIS_NETLIB_INDY);
    {$ELSE} //FOR XE3/XE8 VERSION
    FRedis := NewRedisClient(IPAddress,PortNo, False, REDIS_NETLIB_INDY);
    {$ENDIF}
    if pwd <> '' then FRedis.AUTH(pwd);
  Except on E:Exception do
  begin
    FRedis := nil;
    redis_errmsg := e.Message;
  end;
  end;
  {$ENDIF};
end;

function TGeneralFunctions.Get_Password(dtid,mid : String) : String;
var l,l1, i, k : Integer;
    s,s1,s2,dbid :String;
begin
  Result := '';
  s := mid;
  l := length(s);
  while s <> '' do
  begin
    s1 := copy(s,1,4);
    k := strtoint(s1);
    s2 := chr(k);
    dbid := dbid + s2;
    delete(s,1,4);
  end;
  l := Length(dbid);
  l1 := Length(dtid);
  if l1 < l then
  begin
    for i := l1 to l do
        dtid := dtid + '0';
  end;
  for i := 1 to l do
  begin
    s := s + Chr(ord(dbid[i])-Ord(dtid[i]));
  end;
  result := s;
end;


function TGeneralFunctions.GetFieldType(fldDataType:TFieldType):String;
begin
  if (fldDataType in [ftString, ftFixedChar, ftWideString]) then Result := 'c'
  else if (fldDataType in [ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD,
          ftBytes, ftVarBytes, ftAutoInc, ftLargeInt, ftFMTBcd]) then Result := 'n'
  else if (fldDataType in [ftDate, ftTime, ftDateTime, ftTimeStamp]) then Result := 'd'
  else if (fldDataType in [ftMemo, ftFmtMemo, ftOraClob]) then Result := 't'
  else if (fldDataType in [ftblob,ftGraphic, ftOraBlob]) then Result := 'i'
  else if (fldDataType in [ftBoolean]) then Result := 'b'
  else if (fldDataType in [ftunknown, ftVariant, ftInterface, ftParadoxOLE, ftDBaseOLE,
                ftTypedBinary, ftADT, ftArray, ftReference, ftDataSet, ftIDispatch,
                ftGUID, ftCursor]) then Result := 'u';
end;

procedure TGeneralFunctions.PostResultToRedis(ResString : string);
  var ipno,pd,errmsg,key,tip,tport : string;
  portno : word;
begin
  {$IFNDEF  NOT ForRestDll}
  ipno := '127.0.0.1';
  portno := 6379;
  pd := 'agile.01';
  try
    dodebug.msg('Redis Host : '+ WebRedisHost);
    if WebRedisHost <> '' then begin
      tip := Trim(Copy(WebRedisHost, 0, POS(':',WebRedisHost)-1));
      tport := Trim(Copy(WebRedisHost, POS(':',WebRedisHost)+1, Length(WebRedisHost)));
      if tip <> '' then ipno := tip;
      if tport <> '' then portno := StrToInt(tport);
    end;
    dodebug.msg('Redis Server : ' + ipno);
    dodebug.msg('Redis Portno : ' + inttostr(portno));
    dodebug.msg('Redis Password : '+ WebRedisPwd);
    {$IFDEF ABOVE_DXE8} //FOR ABOVE XE8 VERSION
    FRedis := NewRedisClient(ipno,portno,REDIS_NETLIB_INDY);
    {$ELSE} //FOR XE3/XE8 VERSION
    FRedis := NewRedisClient(ipno,portno,False,REDIS_NETLIB_INDY);
    {$ENDIF}
    if Trim(WebRedisPwd) <> '' then FRedis.AUTH(WebRedisPwd);
    errmsg := 'Connection successful.';
    key := schemaname +'-'+username+'-notify-'+FormatDateTime('ddmmyyyyhhmmss',now());
    dodebug.msg('Redis Key : ' + key);
    dodebug.msg('Redis Value : ' + ResString);
    FRedis.&SET(key,ResString);
  Except on E:Exception do
    errmsg := E.Message;
  end;
  dodebug.msg('Redis connection : ' + errmsg);
  {$ENDIF};
end;

//GetDateTimeStampString returns result in yyyymmddhrmnscms format
function TGeneralFunctions.GetDateTimeStampString:String;
var y,m,d,h,mn,s,ms:word;
begin
  decodedatetime(now, y, m, d, h, mn, s, ms);
  result :=inttostr(y)+inttostr(m).PadLeft(2, '0')+inttostr(d).PadLeft(2, '0');
  result:=result+inttostr(h).PadLeft(2, '0')+inttostr(mn).PadLeft(2, '0');
  result:=result+inttostr(s).PadLeft(2, '0')+inttostr(ms).PadLeft(3, '0');
end;

//ConvertTimestampToDateTime
function TGeneralFunctions.ConvertTimestampToDateTime(const timestamp: string): string;
var
  year, month, day, hour, minute, second, ms: Word;
begin
  // Extract the individual date and time components from the timestamp
  year := StrToInt(Copy(timestamp, 1, 4));
  month := StrToInt(Copy(timestamp, 5, 2));
  day := StrToInt(Copy(timestamp, 7, 2));
  hour := StrToInt(Copy(timestamp, 9, 2));
  minute := StrToInt(Copy(timestamp, 11, 2));
  second := StrToInt(Copy(timestamp, 13, 2));
  ms := StrToInt(Copy(timestamp, 15, 3));

  // Create a TDateTime value using the extracted components
  //Result := Format('%4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d.%3.3d', [year, month, day, hour, minute, second, ms]);
  Result := Format('%4d/%2.2d/%2.2d %2.2d:%2.2d:%2.2d', [year, month, day, hour, minute, second]);
  try
    //Result := formatdatetime(structdef.axprovider.dbm.gf.ShortDateFormat.ShortDateFormat,StrtoDateTime(Result));
    Result := formatdatetime(ShortDateFormat.ShortDateFormat,EncodeDate(year,month,day)) +' '+
    formatdatetime(ShortDateFormat.LongTimeFormat,EncodeTime(hour,minute,second,ms))
  except
  end;
end;

end.

