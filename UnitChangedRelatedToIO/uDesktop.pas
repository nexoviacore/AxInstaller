unit uDeskTop;
{copied from 9.6}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DateUtils, Menus, uHSplit, XMLDoc, XMLIntf,
  Grids, ComCtrls, Buttons, uGeneralFunctions, uPropsXML, uResizer,
  uResizers, CheckLst, uButtons, uaxprovider, uInputFrame, uDoAction,
  uViewFrame, uXDS, uProfitEval, upopup, uFormDesign ,uCompress ,ActnList,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTP , uTasks,
  uUpdateMgr,uImageObj,CategoryButtons,uPopupForm,vcl.ribbon
  {$ifdef withsmtp}
   ,UXSMTP
  {$endif}
  ;

type

  pOpt=^TOpt;
  TOpt=record
    frame : TFrame;
    name : string;
    act : TDoAction;
    axml : ixmldocument;
  end;

  pPrList=^TPrList;
  TPrList=record
    name : string;
    hp : TProfitEval;
  end;
  TScalePage = procedure of object;
  TDeskTop=Class
  private
    xnode, tnode, relations, pagesnode, paramvalues, actions : IXMLNode;
    subtop : integer;
    fbuild: boolean;
    clickpoint : TPoint;
    fOwner: TComponent;
    fClientPanel: TScrollingWinControl;
    fPage , fPageName : string;
    hparser, hparsebak: TProfitEval;
    pnlWins : TPanel;
    sno:integer;
    qnavigate:TXDS;
    opt : pOpt;
    pList : pPrList;
    act : TDoAction;

    cbSearch : TComboBox;
    LinkFrom,lview_hidepurpose : String;
    LoadNewPage : boolean;
//    PgGrpName : String;
    FromHyperlink : Boolean;
    axp : TAxprovider;
    RefreshView: boolean;

    procedure SetBuild(const Value: boolean);
    procedure SaveStructures;
    procedure SetOwner(const Value: TComponent);
    procedure SetClientPanel(const Value: TScrollingWinControl);
    procedure AddIView;
    procedure AddTStruct;
    Procedure AddTree;
    procedure LoadTStruct(n: ixmlnode);overload;
    procedure LoadTStruct(n:ixmlnode;tbuild:boolean);overload;
    function Getselected: pointer;

    procedure LoadIView(n: ixmlnode);overload;
    procedure LoadIView(n:ixmlnode;tbuild:boolean);overload;
    function DoHyperLink(sender: TObject; name: string):boolean;
    function GetPValue(pName: string): string;
//    function ShowRelated(sender: TObject; pName: String):boolean;
    procedure AddWin;
    procedure ClearWin(wno: integer);
    procedure HideWin; overload ;
    procedure HideWin(hcntr : string) ; overload;
    procedure ShowWin;
    procedure ClearClient;
    function GetClicked: TSpeedButton;
    procedure Setclicked(const Value: TSpeedButton);
    function ShowRelatedOption(pRelation: String): boolean;
    function GetOption(pName: string): TFrame;
    function GetParser(s: string): TProfitEval;

    procedure assignparser(hp: TProfitEval);
    procedure Registerparams;
    procedure FillParamValues(n: ixmlnode);
    procedure InitPageVars(pgname:string);
//    procedure AccessRole(pages: TCategoryButtons);
//    procedure CompAccess(pages: TCategoryButtons; acclist: TStringList;Dellist:TStringList);
    procedure LoadCal(n: ixmlnode;cat:string);
//    procedure FindTStructBtnComp(inp: TFrame; cStr, acs, cacs: String);
    function IsGraphicControl(sender: TObject): boolean;
//    procedure LoadAccess(n: IXMLNode);
//    procedure LoadBtnAccess(ParentName, acs: String; n: IXMLNode;
//      acclist: TStringList);
//    procedure LoadCompAccess(n: IXMLNode; accList: TStringList);
//    procedure LoadIViewAccess(ParentName, acs: String; n: IXMLNode;
//      acclist: TStringList);
//    procedure LoadTStructAccess(ParentName, acs: String; n: IXMLNode;
//      acclist: TStringList);
    procedure AddtoOptions(f: TFrame);
    function Getaction(f:TFrame) : TDoAction;
    procedure getrelated(sname: string);
    procedure SetPageName(const Value: string);
    procedure AddtoOptionsTree(f : TFrame);
    procedure LoadTreeStruct (n: ixmlnode);
    function GetCompName(compnode: ixmlnode; cstr: String): String;
//    procedure LoadTemplate;
    procedure AddCalender;
    procedure AddTCalender;
    procedure AddtoPrList(f: String);
//    procedure HandleDelList(ds1, ds2: TStringList);
    procedure ComboOnChange(Sender: TObject);
    procedure UpdateVersion;
    procedure SetAppTheme;
    function GetInputFrame(f: String): TFrame;
    function ListViewExist(sname:String): boolean;
    procedure SetFormFontProperties;
    procedure getIViewCDS;
    procedure getTStructCDS;
    function  ChkPageAccess(pname : string) : Boolean;
    function GetAccessControlXML(stable, stype, sname : string): ixmldocument;
    procedure DeleteFromOptions(f: String);
    function CreateAccessControlXML(cxml : ixmldocument) : ixmldocument ;
    procedure RegisterIviewParamValues(vFrm: TViewFrame; sname: String);
    function LoadXml(Pagename, Pagecaption: string): IXmlDocument;
    function LoadAppMgrXML: ixmldocument;

    Procedure CopyAppMgrStructstoStructureDir;

//    function GetRelations(tname:String): TStringList;
  public
    ImageObj : TImageObj;
    ParentForm : TForm;
    options,hpList:Tlist;
    xml,axml,viewxml,orgaxml,accxml : IXMLDocument;
    selstruct : string;
    inode, hypernode : IXMLNode;
    odialog : TOpenDialog;
    sdialog : TSaveDialog;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    ftp: TIdFTP;
    EditStruct : TOnEditStruct;
    PageToLoad,calenderid,caltransid,calType,calDate,caluserid,calUserName : string;
    calPos,winno : integer ;
    fdesign:TFormDesign;
    imgList : TImageList;
    pb: TProgressBar;
    ActList : TActionList;
//    ShowMsgCount : TShowMsgCount;
    fontCDS,iviewCDS,tstructCDS, pageCDS  : TXDS;
    pxml : IXMLDocument;
    pageNames : TStringList;
    poptasks : TTasks;
    tvmenu:TTreeView;
    ScalePage : TScalePage;
    tid : string;
    is_editstruct : boolean;
    Iview_frame : TFrame;
    is_hiddenpage :boolean;
    pgtype :string;
    prev_sel_stem : boolean; //ch1 m13
    StatusBar: TStatusBar;
    constructor create(AxPro : TAxProvider);
    destructor destroy;override;
    procedure Save;
    procedure Remove;
    procedure RemoveControl;
    procedure GoPrior;
    procedure GoNext;

    procedure SetClick(btn: TSpeedButton);
    function GetLocalNum: integer;
    procedure LoadForm;overload;
    procedure LoadForm(build : boolean; page:string);overload;
    procedure LoadData(pInp: TInputFrame);overload;
    procedure LoadData(pInp: TInputFrame;hnode:ixmlnode);overload;
    procedure SetPage(const Value: string);
    procedure BtnClick(sender: TObject);
    procedure FreeChildOptions(mycomp: TWinControl);
    procedure ClearContainer(pnl: TPanel);
    function CallAction(Sender:TObject; Actionname: String;n:IXMLNode) : String ;
    procedure StructBtnClick(Callframe:TFrame; btn:TSpeedButton; n,act:ixmlnode);
    function Showiview(pname, container: string):pointer;  overload;
    function Showiview(pname, container: string; hp : TProfitEval):pointer;  overload;
    function Showtstruct(pname, container: string):pointer;overload;
    function Showtstruct(pname, container: string; hn,pv:ixmlnode):pointer;overload;
    procedure LoadPage(s: string);overload;
    procedure LoadPage(s:string;tbuild:boolean);overload;
    function Inpage(frm: TFrame): boolean;

    property build : boolean read fbuild write SetBuild;
    property AOwner : TComponent read fOwner write SetOwner;
    property ClientPanel : TScrollingWinControl read fClientPanel write SetClientPanel;
    property Page : string read fPage write SetPage;
    property PageName : String read fPageName write SetPageName ;
    property selected : pointer read Getselected;
    property clicked : TSpeedButton read GetClicked write Setclicked;
    function ShowTree(pname, container : string) : pointer;
    function ShowRelated(sender: TObject; pName: String):boolean;
    function GetRelations(tname:String): TStringList;
    procedure AddtoOptionsCon(f: TFrame);
    procedure PageRefresh;
    function DoActionPageLoad(sender: TObject; name,task: string;
      n: IXMLNode): boolean;
    procedure FreeAllPrList;
    function Gethp(pName: string): TProfitEval;
    function StructuresXMLChange : Boolean;
    function IViewColWidthChange: Boolean;
    function IViewColMove: Boolean;
    procedure IViewRunTimeSave;
    procedure SetFontDetails(sender: TObject);
    procedure GetFontCDS(sname : string ; fcds: TXDS);
    function FillValueFromSql(sqltext: string): TStringList;
    function GetActionObj: TObject;
    procedure FreeAllOptions;
    function GetStructure(s: string): TObject;
    function GetCurrentStructure: TFrame;
    function CheckToBeSaved: Boolean;
    function CheckForAppMgrStructs: Boolean;
   end;

implementation

uses uCalender,uTreeFrame;

constructor TDesktop.Create(AxPro : TAxProvider);
var s:string;
begin
  inherited create;
  axp := AxPro;
  options:=TList.create;
  hpList:=TList.create;
  fbuild:=false;
  FromHyperLink:=false;
  axml:=loadxmldata('<root></root>');
  orgaxml:=loadxmldata('<root></root>');
  inode:=axml.DocumentElement;
  fclientpanel:=nil;
  hparser:=nil;
  relations:=nil;
  winno:=0;sno:=1;
  hypernode:=nil;
  fdesign:=nil;
  qnavigate:=nil;
  paramvalues:=nil;
  hparsebak:=nil;
  viewxml := nil;
  StatusBar := nil;
//  dtemplate := nil;
  axp.dbm.gf.registered:=tstringlist.create;
  axp.dbm.gf.btnactions:=tstringlist.create;

  act:=TDoAction.Create;
  act.imglist := imglist;
  act.OnGetparser:=GetParser;
  act.OnAssignParser:=AssignParser;
  act.OnGetStructure:=GetStructure;
  act.OnGethparser:=Gethp;
  act.OnShowTStruct:=ShowTStruct;
  act.OnShowIView:=ShowIView;
  act.opendialog:=odialog;
  act.savedialog:=sdialog;
  act.ShowRelated:=ShowRelated;
  act.doLoadPage:=DoActionPageLoad;
  act.ParentRefresh := PageRefresh;
  act.OnLoadData:=LoadData;
  act.pb := pb;
  axp.dbm.gf.IcompChanged := False;
  axp.dbm.gf.TcompChanged := False;
  pageNames := tstringlist.create;
  poptasks := TTasks.Create(axp);
  is_hiddenpage := false;
  prev_sel_stem := false;
  RefreshView := false;
end;

destructor TDesktop.destroy;
var i:integer;
begin
  if (assigned(fdesign)) and (assigned(fdesign.resizers)) then
    fdesign.ClearResizers;
  clearcontainer(TPanel(clientpanel));
  if assigned(pnlwins) then begin
    for i:=0 to pnlwins.controlcount-1 do
      clearwin(0);
  end;
  if assigned(fontCDS) then
  begin
    fontCDS.close;
    fontCDS.Free;
  end;
  if assigned(tstructCDS) then
  begin
    tstructCDS.close;
    tstructCDS.Free;
  end;
  if assigned(iviewCDS) then
  begin
    iviewCDS.close;
    iviewCDS.Free;
  end;
  if assigned(pageCDS) then
  begin
    pageCDS.close;
    pageCDS.Free;
  end;
  FreeAllOptions;
  options.Free;
  FreeAllPrList;
  if assigned(hplist) then hpList.Free;
  axml := nil;
  orgaxml := nil;
  if assigned(fdesign) then
    fdesign.free;
  act.destroy;
  axp.dbm.gf.registered.Free;
  axp.dbm.gf.btnactions.Free;
  PageNames.Free;
  poptasks.free;
  inherited;
end;

procedure TDeskTop.Remove;
begin

end;

procedure TDeskTop.SaveStructures;
var i:integer;
begin
  for i:=0 to options.count-1 do begin
    if not inpage(pOpt(options[i]).frame) then continue;
    if TObject(pOpt(options[i]).frame).ClassType=TInputFrame then
    begin
       TInputFrame(pOpt(options[i]).frame).Save(true);
       Axp.SetStructure('tstructs',TInputFrame(pOpt(options[i]).frame).TransType,TInputFrame(pOpt(options[i]).frame).TransDesc,TInputFrame(pOpt(options[i]).frame).xml);
    end
    else if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
      TViewFrame(pOpt(options[i]).frame).Savebtnpnl ;
      axp.SetStructure('iviews',TViewFrame(pOpt(options[i]).frame).iview.QueryMasterName,TViewFrame(pOpt(options[i]).frame).iview.QueryCaption,TViewFrame(pOpt(options[i]).frame).iview.xml);
    end
    else if (TObject(pOpt(options[i]).frame).ClassType=TfrmTreeFrame) then
    begin
      axp.SetStructure('axptree',TfrmTreeFrame(pOpt(options[i]).frame).TreeName,TfrmTreeFrame(pOpt(options[i]).frame).TreeCaption,TfrmTreeFrame(pOpt(options[i]).frame).TXML);
    end;
  end;
end;


function TDeskTop.StructuresXMLChange : Boolean;
var i:integer;
//   chkXML : IXMLDocument;
begin
  Result := False;
  fdesign.savexml;
  if orgaxml.XML.Text <> axml.XML.Text then Result := True;
//  chkXML := loadxmldata('<root></root>');
  for i:=0 to options.count-1 do begin
    if not inpage(pOpt(options[i]).frame) then continue;
    if TObject(pOpt(options[i]).frame).ClassType=TInputFrame then
    begin
//       chkXML.DocumentElement := TInputFrame(pOpt(options[i]).frame).xml.DocumentElement.CloneNode(True);
       if {(chkXML.XML.Text <> TInputFrame(pOpt(options[i]).frame).xml.XML.Text) or} (axp.dbm.gf.TcompChanged) then
       begin
          TInputFrame(pOpt(options[i]).frame).Save(True);
          axp.dbm.gf.TcompChanged := false;
          Result := True;
       end;
    end
    else if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
//      chkXML.DocumentElement := TViewFrame(pOpt(options[i]).frame).iview.xml.DocumentElement.CloneNode(True);
      if {(chkXML.XML.Text <>  TViewFrame(pOpt(options[i]).frame).iview.xml.XML.Text) or} (axp.dbm.gf.IcompChanged) then
       begin
      TViewFrame(pOpt(options[i]).frame).Savebtnpnl ;
          axp.dbm.gf.IcompChanged := false;
          Result := True;
       end;
    end ;
//    else if (TObject(pOpt(options[i]).frame).ClassType=TfrmTreeFrame) then
//    begin
//      axp.SetStructure('axptree',TfrmTreeFrame(pOpt(options[i]).frame).TreeName,TfrmTreeFrame(pOpt(options[i]).frame).TreeCaption,TfrmTreeFrame(pOpt(options[i]).frame).TXML);
//    end;
  end;
end;

function TDeskTop.IViewColMove: Boolean;
var i:integer;
begin
  result := False;
  for i:=0 to options.count-1 do begin
    if not assigned(options[i]) then continue;
    if not assigned(pOpt(options[i]).frame) then continue;
    if not inpage(pOpt(options[i]).frame) then continue;
    if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
      if TViewFrame(pOpt(options[i]).frame).ColMoved then
       begin
          Result := True;
          break;
       end;
    end ;
  end;
end;

function TDeskTop.CheckToBeSaved: Boolean;
var i:integer;
begin
  result := False;
  for i:=0 to options.count-1 do begin
    if not assigned(options[i]) then continue;
    if not assigned(pOpt(options[i]).frame) then continue;
    if inpage(pOpt(options[i]).frame) then
    begin
      if (TObject(pOpt(options[i]).frame).ClassType=TInputframe) then
      begin
        if TInputframe(pOpt(options[i]).frame).ToBesaved then
         begin
            Result := True;
            break;
         end;
      end ;
    end;
  end;
end;

function TDeskTop.IViewColWidthChange : Boolean;
var i:integer;
begin
  result := False;
  for i:=0 to options.count-1 do begin
    if not assigned(options[i]) then continue;
    if not assigned(pOpt(options[i]).frame) then continue;
    if not inpage(pOpt(options[i]).frame) then continue;
    if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
      if TViewFrame(pOpt(options[i]).frame).ColWidthChanged then
       begin
          Result := True;
          break;
       end;
    end ;
  end;
end;

procedure TDeskTop.IViewRunTimeSave ;
var i:integer;
    tmpxml : ixmldocument;
    DefaultSETTO : String;
begin
  for i:=0 to options.count-1 do begin
    if not inpage(pOpt(options[i]).frame) then continue;
    if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
      if TViewFrame(pOpt(options[i]).frame).ColWidthChanged or TViewFrame(pOpt(options[i]).frame).ColMoved then
       begin
          if TViewFrame(pOpt(options[i]).frame).iview.xml.DocumentElement.HasAttribute('type') then
          begin
             if vartostr(TViewFrame(pOpt(options[i]).frame).iview.xml.DocumentElement.Attributes['type']) = 'lview' then
             begin
               axp.SetStructure('lviews',TViewFrame(pOpt(options[i]).frame).iview.QueryMasterName,TViewFrame(pOpt(options[i]).frame).iview.QueryCaption,axp.dbm.gf.username,TViewFrame(pOpt(options[i]).frame).iview.xml);
               TViewFrame(pOpt(options[i]).frame).ColWidthChanged := false;
               TViewFrame(pOpt(options[i]).frame).ColMoved := false;
               continue;
             end;
          end;
          DefaultSETTO := axp.dbm.gf.structSetTo;
          axp.dbm.gf.structSetTo := 'folder';
          axp.SetStructure('iviews',TViewFrame(pOpt(options[i]).frame).iview.QueryMasterName,TViewFrame(pOpt(options[i]).frame).iview.QueryCaption,TViewFrame(pOpt(options[i]).frame).iview.xml);
          axp.dbm.gf.structSetTo := DefaultSETTO;
          TViewFrame(pOpt(options[i]).frame).ColWidthChanged := false;
          TViewFrame(pOpt(options[i]).frame).ColMoved := false;
        end;
    end ;
  end;
end;

procedure TDeskTop.SetBuild(const Value: boolean);
var i:integer;
    comp,hcomp:TControl;
    nodename, cat, prnt : string;
begin
  fbuild := Value;
  i := 0;
  while (i <= options.count -1) and build do begin
    if not inpage(TFrame(pOpt(options[i]).frame)) then begin
      i := i+1;
      continue;
    end;
    if TObject(pOpt(options[i]).frame).ClassType=TInputFrame then begin
      DeleteFromOptions('tstruct__'+TInputFrame(pOpt(options[i]).frame).TransType);
      i := i+1;
    end else if TObject(pOpt(options[i]).frame).ClassType=TViewFrame then begin
      DeleteFromOptions(TViewFrame(pOpt(options[i]).frame).Name);
      i := i+1;
    end;
  end;
end;

function TDesktop.GetLocalNum:integer;
begin
  if not axp.dbm.gf.GlobalProps.HasAttribute('LocalNum') then
    axp.dbm.gf.GlobalProps.Attributes['LocalNum']:=0;
  result:=strtoint(axp.dbm.gf.GlobalProps.attributes['LocalNum'])+1;
  axp.dbm.gf.GlobalProps.Attributes['LocalNum']:=inttostr(result);
end;

procedure TDeskTop.SetOwner(const Value: TComponent);
var fnode:IXMLNode;
    fprops:string;
    fxml:IXMLDocument;
begin
  fOwner := Value;
  ParentForm:=TForm(fOwner);
  pnlWins:=TPanel(ParentForm.FindComponent('pnlWins'));
  fprops:= axp.dbm.gf.GFontProps;
  if axp.dbm.gf.GFontProps<>'' then begin
    ParentForm.Font.Name:=axp.dbm.gf.GetNthString(fprops,1);
    ParentForm.Font.Size:=StrToInt(axp.dbm.gf.GetNthString(fprops,2));
    ParentForm.Font.Color:=StringToColor(axp.dbm.gf.GetNthString(fprops,3));
    if axp.dbm.gf.GetNthString(fprops,4)='t' then
      ParentForm.Font.Style:=ParentForm.Font.Style+[fsBold];
    if axp.dbm.gf.GetNthString(fprops,5)='t' then
      ParentForm.Font.Style:=ParentForm.Font.Style+[fsItalic];
    if axp.dbm.gf.GetNthString(fprops,6)='t' then
       ParentForm.Font.Style:=ParentForm.Font.Style+[fsUnderline];
    if axp.dbm.gf.GetNthString(fprops,6)='t' then
       ParentForm.Font.Style:=ParentForm.Font.Style+[fsStrikeOut];
    tvMenu.Font.Name:=axp.dbm.gf.GetNthString(fprops,1);
    tvMenu.Font.Size:=StrToInt(axp.dbm.gf.GetNthString(fprops,2));
    tvMenu.Font.Color:=StringToColor(axp.dbm.gf.GetNthString(fprops,3));
    if axp.dbm.gf.GetNthString(fprops,4)='t' then
      tvMenu.Font.Style:=ParentForm.Font.Style+[fsBold];
    if axp.dbm.gf.GetNthString(fprops,5)='t' then
      tvMenu.Font.Style:=ParentForm.Font.Style+[fsItalic];
    if axp.dbm.gf.GetNthString(fprops,6)='t' then
       tvMenu.Font.Style:=ParentForm.Font.Style+[fsUnderline];
    if axp.dbm.gf.GetNthString(fprops,6)='t' then
       tvMenu.Font.Style:=ParentForm.Font.Style+[fsStrikeOut];
  end
  else begin
    ParentForm.Font.Name:='Tahoma';
    ParentForm.Font.Size:=8;
    ParentForm.Font.Color:= -16777208;
    ParentForm.Font.Style:=ParentForm.Font.Style-[fsBold];
    ParentForm.Font.Style:=ParentForm.Font.Style-[fsItalic];
    ParentForm.Font.Style:=ParentForm.Font.Style-[fsUnderline];
    ParentForm.Font.Style:=ParentForm.Font.Style-[fsStrikeOut];
    tvMenu.Font.Name:='Segoe UI';
    tvMenu.Font.Size:=9;
    tvMenu.Font.Color:= -16777208;
  end;
end;

procedure TDeskTop.RemoveControl;
begin
//  fdesign.RemoveControl;
end;

procedure TDeskTop.FreeAllOptions;
var i:integer;
begin
  for i:=options.count-1 downto 0 do begin //ch1

    if not assigned(options[i]) then continue;
    if not assigned(pOpt(options[i]).frame) then continue;
    if TObject(pOpt(options[i]).frame).ClassType=TInputFrame then
    begin
      TInputFrame(pOpt(options[i]).frame).Clear   ;
      FreeAndNil(TInputFrame(pOpt(options[i]).frame));
    end else if TObject(pOpt(options[i]).frame).ClassType=TViewFrame then
    begin
      TViewFrame(pOpt(options[i]).frame).Clear ;
      FreeAndNil(TViewFrame(pOpt(options[i]).frame));
    end else begin
      TfrmTreeFrame(pOpt(options[i]).frame).clear;
      dispose(pOpt(Options[i]));
      break;
    end;
    pOpt(Options[i]).act.Destroy;
    dispose(pOpt(Options[i]));
  end;
  options.clear;
end;

procedure TDeskTop.FreeAllPrList;
var i:integer;
begin
  if assigned(hplist) then begin
    for i:=0 to hpList.count-1 do begin
      if assigned(pPrList(hplist[i]).hp) then
      begin
        pPrList(hplist[i]).hp.Free;
        pPrList(hplist[i]).hp := nil;
      end;
      dispose(pPrList(hplist[i]));
    end;
    hpList.clear;
  end;
end;

procedure TDeskTop.FreeChildOptions(mycomp:TWinControl);
var j:integer;
    wc:twincontrol;
begin
  if not assigned(mycomp) then exit;
  j:=0;
  while j<options.Count do begin
    wc:=TWincontrol(pOpt(options[j]).frame);
    try
      while (assigned(wc)) and (wc<>mycomp) do wc:=wc.parent;
    except on e:Exception do
      begin
        if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\FreeChildOptions - '+e.Message);
        pOpt(Options[j]).act.Destroy;
        dispose(pOpt(Options[j]));
        options.Delete(j);
        inc(j);
        continue;
      end;
    end;
    if wc=mycomp then begin
      if TFrame(pOpt(options[j]).frame).ClassType=TInputframe then
      begin
        TInputframe(pOpt(options[j]).frame).clear;
        FreeAndNil(TInputframe(pOpt(options[j]).frame));
      end else if TFrame(pOpt(options[j]).frame).ClassType=TViewframe then
      begin
        TViewFrame(pOpt(options[j]).frame).clear ;
        FreeAndNil(TViewFrame(pOpt(options[j]).frame));
      end else begin
        TfrmTreeFrame(pOpt(options[j]).frame).clear;
        options.Delete(j);
        break;
      end;
      pOpt(Options[j]).act.Destroy;
      dispose(pOpt(Options[j]));
      options.Delete(j);
    end else inc(j);
  end;
end;

procedure TDesktop.ClearClient;
var i:integer;
    mycomp:TControl;
begin
  if assigned(fdesign.ctoolbar) then fdesign.ctoolbar.Parent := nil;
  lockwindowupdate(TWinControl(AOwner).Handle);
  for i:=0 to fdesign.Resizers.sizers.count-1 do
    fdesign.Resizers.Remove(TResizer(fdesign.Resizers.sizers[0]).component);

  for i:=clientpanel.controlcount-1 downto 0 do begin
    if clientpanel.controls[i].HelpKeyword = 'static' then continue;
//  for i:=0 to clientpanel.ControlCount-1 do begin
    mycomp:=clientpanel.Controls[i];
    freechildoptions(TWinControl(mycomp));
    mycomp.Free;
  end;
  lockwindowupdate(0);
end;

procedure TDeskTop.SetClientPanel(const Value: TScrollingWinControl);
begin
  fClientPanel := Value;
end;

//Load form.

procedure TDeskTop.UpdateVersion;
   var x : TXDS;
     upd : TupdateMgr;
     upAvilable : boolean;
begin
   upAvilable := false;
   upd := TupdateMgr.create(axp);
   upd.pb := pb;
   upAvilable := upd.updateavailable;
   upd.Free;
   if upAvilable then
     raise exception.Create('Application Version not compatible with DB version.' + #13 + 'Please use AxpManager to upgrade the DB version.');
{   if not upd.updateavailable then  //**** commented as per discussion with SAB on 3rd Jan 2014
   begin
    upd.DeleteLocalStructs;
    xml.DocumentElement.Attributes['appverno'] := axp.dbm.gf.exeverno; //
     setAppTheme;
     upd.Free;
     exit;
   end;
   raise exception.Create('Application Version not compatible with DB version.' + #13 + 'Please use AxpManager to upgrade the DB version.');
   }
   {
   if messagedlg('Application Version not compatible with DB version...Do you want to update DB version? ',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
   begin
      raise exception.Create('Version Conflict... Can''t continue....');
      exit;
   end;
   if remotelogin then
   begin
     upd.DeleteLocalStructs;
     upd.Free;
     axp.remoteupdateversion;
     xml.DocumentElement.Attributes['appverno'] := exeverno;
     setAppTheme;
//     axp.SetStructure('axprops', 'app', '', xml);
     exit;
   end;
   x := Axp.dbm.GetXDS(nil);
   x.sqltext:='select * from axprops where name = ''app'' '+forupdate;
   try
     if not axp.dbm.InTransaction then axp.dbm.StartTransaction(connectionname);
     x.open;
     upd.DeleteLocalStructs;
     upd.execUpdate;
     xml.DocumentElement.Attributes['appverno'] := exeverno;
     setAppTheme;
     if axp.dbm.InTransaction then axp.dbm.Commit(connectionname);
     upd.Free;
     x.free;
   except
     on e:exception do begin
       showmessage(e.Message) ;
        if axp.dbm.InTransaction then axp.dbm.RollBack(connectionname);
       x.free;
       exit ;
     end
   end;
   }
end;

procedure TDeskTop.SetAppTheme  ;
  var n,n1 : ixmlnode;
begin
     n := xml.DocumentElement.ChildNodes[0];
     n1 := n.ChildNodes.FindNode('gridhead');
     if n1 = nil then n1 := n.AddChild('gridhead') ;
     n1.Attributes['color'] := '$00F8E7F1';
     n1 := n.ChildNodes.FindNode('gridrow');
     if n1 = nil then n1 := n.AddChild('gridrow') ;
     n1.Attributes['oddrowcolor'] := '$00F4F4F4';
     n1.Attributes['evenrowcolor'] := '$00FFEAEA';
     axp.SetStructure('axprops', 'app', '', xml);
end;

procedure TDeskTop.LoadForm;
var i,cpos:integer;
    newPage :TTreeNode;
    s, firstPage :string;
    img : TImage;
    n:ixmlnode;
    pnl : TPanel;
    aVerNo,eVerno : Extended;
begin
  axp.dbm.gf.appverno := '';
  xml:=axp.GetStructure('axprops', 'app', '','');
  n:=xml.DocumentElement;
  if xml.DocumentElement.HasAttribute('appverno') then
  begin
    axp.dbm.gf.appverno := vartostr(xml.DocumentElement.Attributes['appverno']);
    aVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.appverno);
    eVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.exeverno);
    if aVerNo < eVerNo then
    begin
      UpdateVersion ;
    end;
  end
  else begin
    aVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.appverno);
    eVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.exeverno);
    UpdateVersion ;
  end;
 { if aVerNo > eVerNo then
  begin
    if messagedlg('Application Version is lower than DB version!!!! Want to continue? ',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    begin
      showmessage('Please use application exe compatible with DB....');
      application.Terminate;
    end;
  end;  }
  if n.ChildNodes.Count=0 then
  begin
    raise exception.Create('Application parameters are not correct....Can''t continue');
  end;
  hypernode:=nil;
  act.ftp:=ftp;
  fdesign:=TFormdesign.create;
  fdesign.Axp:=axp;
  fdesign.ClientPanel:=clientpanel;
  fdesign.AOwner:=AOwner;
  fdesign.AddTStruct:=Addtstruct;
  fdesign.AddTree := AddTree;
  fdesign.AddIView:=addiview;
  fdesign.AddCalender:=AddCalender;
  fdesign.AddTCalender:=AddTCalender;
  fdesign.Loadtstruct:=Loadtstruct;
  fdesign.LoadTreeStruct := LoadTreeStruct;
  fdesign.Loadiview:=loadiview;
  fdesign.BtnClick:=BtnClick;
  fdesign.GetLocalNum:=GetLocalnum;
  fdesign.XML:=xml;
  fdesign.ODialog:=Odialog;
  fdesign.CDialog:=ColorDialog;
  fdesign.FDialog:=FontDialog;
  fdesign.Build:=build;
  fdesign.freeoptions:=freechildoptions;
  fdesign.imgList := imgList ;
  fdesign.ComboChange := ComboOnChange;
  fdesign.fromdtop := 'yes';
  fdesign.FillComboFromSql := FillValueFromSql ;
  axp.dbm.gf.GlobalProps:=n.Childnodes[0];
  //Assigning form properties.
  SetFormFontProperties;
  fdesign.fontCDS := fontCDS;  // This is for language.
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('head');
  if assigned(tnode) then begin
    axp.dbm.gf.headcolor:=vartostr(tnode.attributes['color']);
    axp.dbm.gf.headfont:=vartostr(tnode.attributes['font']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('gridhead');
  if assigned(tnode) then begin
    axp.dbm.gf.gridheadcolor:=vartostr(tnode.attributes['color']);
    axp.dbm.gf.gridheadfont:=vartostr(tnode.attributes['font']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('gridrow');
  if assigned(tnode) then begin
    axp.dbm.gf.gridoddrowcolor:=vartostr(tnode.attributes['oddrowcolor']);
    axp.dbm.gf.gridevenrowcolor:=vartostr(tnode.attributes['evenrowcolor']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('contaienr');
  if assigned(tnode) then begin
    axp.dbm.gf.containercolor:=vartostr(tnode.attributes['color']);
  end;
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('img');
  if assigned(tnode) then begin
    img := TImage(Parentform.FindComponent('img'));
    if vartostr(tnode.NodeValue) <> '' then
      axp.GetImage(vartostr(tnode.NodeValue), img);
  end;
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('name');
  if assigned(tnode) then begin
    if vartostr(tnode.NodeValue) <> '' then
    begin

       s := vartostr(tnode.NodeValue);
       s := axp.dbm.gf.FindAndReplace(s,'&','&&');
       TLabel(Parentform.findcomponent('lblAppCaption')).caption := s;
       Parentform.Caption := s;
    end;
  end;
  axp.dbm.gf.defbackcolor := '$00FDFEFF';
  pxml := axp.GetAllPages('axpages');
  tnode := axp.dbm.gf.globalprops.ChildNodes.FindNode('mail');
  if assigned(tnode) then begin
    axp.dbm.gf.MailHost := vartostr(tnode.ChildValues['host']);
    axp.dbm.gf.MailPort := vartostr(tnode.ChildValues['port']);
    axp.dbm.gf.MailUserId := vartostr(tnode.ChildValues['userid']);
    axp.dbm.gf.MailPassword := vartostr(tnode.ChildValues['password']);
//    MailFrom := vartostr(tnode.ChildValues['from']);
  end;
//  AccessRole(pages);
  if pos('default',axp.dbm.gf.userroles) = 0 then
  begin
    if not assigned(tstructCDS) then
    begin
      tstructCDS := axp.dbm.GetXDS(tstructCDS) ;
      tstructCDS.buffered := True;
    end;
    if not assigned(iviewCDS) then
    begin
      iviewCDS := axp.dbm.GetXDS(iviewCDS) ;
      iviewCDS.buffered := True;
    end;
    getIViewCDS;
    getTStructCDS;
  end;
end;

procedure TDeskTop.SetFormFontProperties;
begin
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('app');
  if assigned(tnode) then begin
    if tnode.HasAttribute('charset') then
    begin
      if (axp.dbm.gf.AppFontCharSet <> '') then
      begin
        ParentForm.Font.Charset := axp.dbm.gf.GetCharacterSet(axp.dbm.gf.appfontcharset);
        ParentForm.Font.Name := axp.dbm.gf.AppFontName;
        ParentForm.Font.Size := axp.dbm.gf.AppFontSize;
      end else begin
        if tnode.HasAttribute('font') then
        begin
           ParentForm.Font.Charset := axp.dbm.gf.GetCharacterSet('default');
           axp.dbm.gf.LoadFont(parentform.font, vartostr(tnode.attributes['font']),'');
        end
        else begin
           ParentForm.Font.Charset := axp.dbm.gf.GetCharacterSet('default');
           Parentform.Font.Name := 'Thahoma';
           Parentform.Font.Size := 8;
        end;
      end;
    end;
  end;
  if build then
  begin
    if tnode.HasAttribute('font') then
    begin
       ParentForm.Font.Charset := axp.dbm.gf.GetCharacterSet('default');
       axp.dbm.gf.LoadFont(parentform.font, vartostr(tnode.attributes['font']),'');
       axp.dbm.gf.AppFontName:=Parentform.Font.Name;
       axp.dbm.gf.AppFontSize:=Parentform.Font.Size;
    end
    else begin
       ParentForm.Font.Charset := axp.dbm.gf.GetCharacterSet('default');
       Parentform.Font.Name := 'Thahoma';
       Parentform.Font.Size := 8;
    end;
    axp.dbm.gf.AppFontCharSet:='';
    axp.dbm.gf.AppFontName:='';
    axp.dbm.gf.AppFontSize := 8;
  end;
  if (axp.dbm.gf.appfontcharset <> '') then
  begin
    if not assigned(fontCDS) then
    begin
      fontCDS := axp.dbm.GetXDS(fontCDS) ;
      fontCDS.buffered := True;
    end;
    fontCDS.close;
    fontCDS.CDS.CommandText := 'select compname,compcaption,comphint from axlanguage where ' + axp.dbm.gf.sqllower + '(sname) = ' +quotedstr('axpages')+ ' and ' + axp.dbm.gf.sqllower +'(lngname) = ' + quotedstr(lowercase(axp.dbm.gf.AppFontCharSet));
    fontCDS.open;
  end;
end;

procedure TDeskTop.SetPage(const Value: string);
var i,cpos:integer;
    n:ixmlnode;
    v:String;
begin
  if Value = 'Axp__AppMgrPGE' then begin
    if fPage=value then
      exit
    else
      fpage := value;
    HideWin;
    LoadPage(Value);
    exit;
  end;
  if pos('default',axp.dbm.gf.userroles) = 0 then
  begin
    if not ChkPageAccess(Value) then
    begin
      ShowMessage('Access not available for the page...');
      exit;
    end;
  end;
  if fPage=value then exit;
  if fPage<>'' then begin
    if build then begin
      ClearClient;
      fdesign.SaveXML;
    end else begin
      HideWin;
    end;
  end;
  fPage := '';
  for i := 0 to pxml.DocumentElement.ChildNodes.Count-1 do begin
    xnode := pxml.DocumentElement.ChildNodes[i];
    if (uppercase(vartostr(xnode.Attributes['visible']))='F') and (not build) then continue;
    if xnode.Attributes['group'] = 'true' then continue;
    if vartostr(xnode.NodeValue) = Value then
    begin
      fpage := vartostr(xnode.NodeName);
      fPageName := Value;
      break;
    end;
  end;
  if fpage = '' then fPAge := Value;
  loadpage(fpage);
end;

procedure TDeskTop.SetPageName(const Value: string);
var i:integer;
    n:ixmlnode;
begin
  if pos('default',axp.dbm.gf.userroles) = 0 then
  begin
    if not ChkPageAccess(Value) then
    begin
      ShowMessage('Access not available for the page...');
      exit;
    end;
  end;
  if fPageName=value then exit;
  if fPageName<>'' then begin
    if build then begin
      ClearClient;
      fdesign.SaveXML;
    end else begin
      HideWin;
    end;
  end;
  fPageName := Value;
  fPage := Value;
  loadpage(fPage);
end;

function TDeskTop.ChkPageAccess(pname : string) : Boolean;
  var i : integer;
begin
   if lowercase(pname) = 'inbox' then
   begin
      result := true;
      exit;
   end;
   result := false;
   pname := lowercase(pname);
   for i := 0 to pxml.DocumentElement.ChildNodes.Count-1 do
   begin
     xnode := pxml.DocumentElement.ChildNodes[i];
     if (pname = lowercase(vartostr(xnode.NodeName))) or (pname = lowercase(vartostr(xnode.NodeValue))) then
     begin
        result := True;
        break;
     end;
   end;
end;

procedure TDeskTop.LoadPage(s:string);
var i , j,cpos:integer;
    cat,cn,v,licMsg : string;
    found : boolean;
    stime : TDateTime;
begin
  stime := now;
  axp.dbm.gf.doDebug.Msg('>>Start Pageload Time - ' + inttostr(millisecondsbetween(now(),stime)) );
  if s <> 'Axp__AppMgrPGE' then begin
    licMsg := axp.lm.RTCheckLicence;
    if licMsg <> '' then
    begin
      showmessage(licMsg);
      Application.Terminate;
    end;
  end;
  FreeAllPrList;
  if fPage = '' then exit;
  pb.StepIt;
  LoadNewPage := True;
  pb.StepIt;
  InitPageVars(s);
  pb.StepIt;
  if inode = nil then exit;
  lockwindowupdate(ClientPanel.Handle);
  axp.dbm.gf.pagination_pageno := 0;
  for i:=0 to inode.ChildNodes.Count-1 do begin
    pb.StepIt;
    xnode:=inode.ChildNodes[i];
    cat:=xnode.Attributes['cat'];
    if (assigned(act.varComps))and (vartostr(xnode.Attributes['runvar']) = 'yes')then
    begin
      found := false;
      cn := (vartostr(xnode.Attributes['parent'])+','+vartostr(xnode.Attributes['name'])) ;
      for j := 0 to act.varComps.Count - 1 do
      begin
         if cn = act.varComps.Strings[j] then
         begin
           found := true;
           break;
         end;
      end;
      if found = false then  act.varComps.Add(cn);
    end;
    if assigned(aowner.findcomponent(xnode.NodeName)) then continue;
    if build and assigned(fdesign) then
      fdesign.ImageObj := ImageObj;
    if not build or (build and (pgtype ='stem')) then begin
      if cat='cntr' then fdesign.loadcontainer(xnode)
      else if cat='tstruct' then fdesign.loadtstruct(xnode)
      else if cat='iview' then fdesign.loadiview(xnode)
      else if cat='cal' then loadcal(xnode,cat)
      else if cat = 'teamcal' then loadcal(xnode,cat)
      else if cat='tree' then fdesign.loadtreestruct(xnode);
    end
    else if build then begin
      if cat='cntr' then fdesign.loadcontainer(xnode)
      else if cat='tstruct' then loadtstruct(xnode)
      else if cat='iview' then loadiview(xnode)
      else if cat='cal' then loadcal(xnode,cat)
      else if cat = 'teamcal' then loadcal(xnode,cat)
      else if cat='tree' then loadtreestruct(xnode);
    end;      
  end;
  lockwindowupdate(0);
  if not build or  ( build and (pgtype = 'stem')) then begin
    if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
    begin
      if not assigned(pageCDS) then
      begin
        pageCDS := axp.dbm.GetXDS(pageCDS) ;
        pageCDS.buffered := True;
      end;
      pageCDS.close;
      GetFontCDS('p'+fPage,pageCDS);
      fdesign.fontCDS :=  pageCDS;
    end;
    fdesign.LoadComps(inode,'');
    pb.StepIt;
    fdesign.inode := inode;
    fdesign.PageXML := axml;
    pb.StepIt;
    if (lowercase(axp.PageType) <> 'h') and (lowercase(axp.PageType) <> '') then AddWin;
    while true do
    begin
      pb.StepIt;
      if pb.Position >= pb.Width then break;
    end;
    pb.Position := 0;
    axp.dbm.gf.doDebug.Msg('>>Pageload Completion Time - ' + inttostr(millisecondsbetween(now(),stime)));
  end;
end;

procedure TDeskTop.InitPageVars(pgname:string);
var i:integer;
    n:ixmlnode;
    pg,purpose:string;
begin
  purpose := '';
  if build then purpose := 'update';
  pb.StepIt;
  if pgname = 'Axp__AppMgrPGE' then begin
    axml := LoadAppMgrXML;
  end else begin
    if not is_hiddenpage then begin
      axml := axp.GetPage(pgname,fPageName,purpose);
      if axp.GetPageName <> '' then fPage := axp.GetPageName ;
      if axp.GetPageCaption <> '' then fPAgeName := axp.GetPageCaption ;
    end
    else begin
      axml := LoadXml(pgname,fpagename);
    end;
  end;
  pb.StepIt;
  inode := axml.DocumentElement;
  if not build then begin
    fdesign.inode:=inode;
    fdesign.wParentName := fPage ;
  end;
  relations:=inode.childnodes.FindNode('relations');
  actions := inode.ChildNodes.FindNode('actions') ;
  orgaxml.DocumentElement := axml.DocumentElement.CloneNode(True);
end;

procedure TDesktop.Save;
var
  n:IXMLNode;
  i,cntr:integer;
  bClient,bNone:boolean;
begin
  fdesign.savexml;
  pb.StepIt;
  axp.SetStructure('axprops', 'app', '', xml);
  pb.StepIt;
  bClient:=False;
  cntr:=0;
  if inode <> nil then begin
    for i := 0 to inode.childnodes.Count - 1 do begin
      n:=inode.ChildNodes[i];
      if n.Attributes['cat']='cntr' then
        cntr:=cntr+1;
      if n.Attributes['align']='Client' then
        bClient:=True;
      if (n.Attributes['align']='None') or (n.Attributes['align']='none') then
        bNone:=True;
    end;
    if (bClient) and (cntr>1) and (bNone) then begin
      MessageDlg('Cannot Save - Containers are not aligned properly.', mtWarning,[mbok],0);
      exit;
    end;
  end;
  axp.SetStructure('axpages',fPage,fPageName,axml);
//  pb.StepIt;
//  axp.ExecSQL('update axpages set type = ' + quotedstr(axp.PageType) + ',parent = ' + quotedstr(axp.PageParent) + ',ordno = ' + quotedstr(axp.PageOrdNo)
//   + ',levelno = ' + quotedstr(axp.PageLevelNo) + ',img = ' + quotedstr(axp.GetPageImg) + ',visible = ' + quotedstr(axp.GetPageVisible) + ' where name = ' + quotedstr(fPage),'','',true);
  pb.StepIt;
  savestructures;
  orgaxml.DocumentElement := axml.DocumentElement.CloneNode(True);
  while true do
  begin
    pb.StepIt;
    if pb.Position >= pb.Width then break;
  end;
  pb.Position := 0;
end;

//tstruct & iview related routines
procedure TDesktop.AddTStruct;
var s:string;
    inp:TInputFrame;
begin
  if (selstruct='') or (fdesign.infocus.tag<>tagDtopContainer) then exit;
  s := 'tstruct__'+selstruct;
  xnode:=inode.ChildNodes.FindNode(s);
  if assigned(xnode) then
  begin
    showmessage('Structure ' + selstruct + ' already added in this page');
    exit;
  end;
  inp:=TInputFrame(showtstruct(selstruct, fdesign.infocus.Name));
  s:=inp.Name;
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then
    xnode:=inode.AddChild(s);
  xnode.Attributes['cat']:='tstruct';
  xnode.Attributes['transid']:=selstruct;
  xnode.Attributes['parent']:=fdesign.infocus.name;
end;
procedure TDeskTop.AddTree;
var
  treeView : TfrmTreeFrame;
  s : string;
Begin
  if (selstruct='') or (fdesign.infocus.tag<>tagDtopContainer) then exit;
  s := 'tree__'+selstruct;
  xnode:=inode.ChildNodes.FindNode(s);
  if assigned(xnode) then
  begin
    showmessage('Tree ' + selstruct + ' already added in this page');
    exit;
  end;
  treeview:=TfrmTreeFrame(ShowTree(selstruct,fdesign.infocus.Name));
  s := selstruct;
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then
    xnode:=inode.AddChild(s);
  xnode.Attributes['cat']:='tree';
  xnode.Attributes['transid']:= selstruct;
  xnode.Attributes['parent']:=fdesign.infocus.name;
end;

procedure TDeskTop.LoadTStruct(n:ixmlnode);
var pnl:TPanel;
begin
//  LoadNewPage := False;
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if not assigned(pnl) then
    showmessage('Unable to find parent container to load '+n.nodename)
  else begin
    if not build or (build and (pgtype ='stem'))  then
      ShowTStruct(n.attributes['transid'], pnl.name)
    else begin
      EditStruct(n.attributes['transid'],'t',pnl.Name);        //ch1
    end
  end;
end;
procedure TDeskTop.LoadTreeStruct(n:ixmlnode);
var pnl:TPanel;
 s : string ;
begin
  s := '';
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if assigned(pnl) then
     s := pnl.name
  else
     if n.HasAttribute('parent') then s := n.attributes['parent'] ;
  if s = '' then
    showmessage('Unable to find parent container to load ')
  else begin
    ShowTree(n.attributes['transid'], s);
  end;
end;

procedure TDesktop.AddtoOptions(f:TFrame);
begin
  new(opt);
  opt.name:=f.Name;opt.frame:=f;
  opt.axml:=accxml;
  opt.act:=TDoAction.create;
  opt.act.imglist := imglist;
  opt.act.OnGetparser:=GetParser;
  opt.act.OnAssignParser:=AssignParser;
  opt.act.OnGetStructure:=GetStructure;
  opt.act.OnGethparser:=Gethp;
  opt.act.axp:=axp;
  opt.act.OnShowTStruct:=ShowTStruct;
  opt.act.OnShowIView:=ShowIView;
  opt.act.opendialog:=odialog;
  opt.act.savedialog:=sdialog;
  opt.act.ftp:=ftp;
  opt.act.ShowRelated:=ShowRelated;
  opt.act.ParentRefresh:=PageRefresh;
  opt.act.doLoadPage:=DoActionPageLoad;
  opt.act.OnLoadData:=LoadData;
  opt.act.pb:=pb;
  options.Add(opt);
end;

procedure TDesktop.DeleteFromOptions(f:String);
  var i : integer;
begin
  for i := options.Count - 1 downto 0 do
  begin
     if Popt(options[i]).name = f then
     begin
        if not assigned(options[i]) then continue;
        if not assigned(pOpt(options[i]).frame) then continue;
        if TObject(pOpt(options[i]).frame).ClassType=TInputFrame then
        begin
          TInputFrame(pOpt(options[i]).frame).Clear ;
          FreeAndNil(TInputFrame(pOpt(options[i]).frame));
        end else if TObject(pOpt(options[i]).frame).ClassType=TViewFrame then
        begin
          TViewFrame(pOpt(options[i]).frame).Clear ;
          FreeAndNil(TViewFrame(pOpt(options[i]).frame));
        end else begin
          TfrmTreeFrame(pOpt(options[i]).frame).clear;
          dispose(pOpt(Options[i]));
          break;
        end;
        pOpt(Options[i]).act.Destroy;
        dispose(pOpt(Options[i]));
        options.Delete(i);
     end;
  end;
end;

procedure TDesktop.AddtoPrList(f:String);
  var i : integer;
begin
  for i := 0 to hplist.Count - 1 do
  begin
    if PPrList(hplist[i]).name = f then exit;
  end;
  new(pList);
  pList.name:=f;
  pList.hp:=TProfitEval.Create(axp);
  pList.hp.Assign(hparser);
  hplist.add(pList);
end;

procedure TDesktop.AddtoOptionsCon(f:TFrame);
  var i : integer;
begin
  for i := 0 to  options.Count - 1 do
  begin
     if Popt(options[i]).frame = f then exit;
  end;
  new(opt);
  opt.name:=f.Name;opt.frame:=f;
  opt.act:=TDoAction.create;
  opt.act.imglist := imglist;
  opt.act.OnGetparser:=GetParser;
  opt.act.OnAssignParser:=AssignParser;
  opt.act.OnGetStructure:=GetStructure;
  opt.act.OnGethparser:=Gethp;
  opt.act.axp:=axp;
  opt.act.OnShowTStruct:=ShowTStruct;
  opt.act.OnShowIView:=ShowIView;
  opt.act.opendialog:=odialog;
  opt.act.savedialog:=sdialog;
  opt.act.ftp:=ftp;
  opt.act.ShowRelated:=ShowRelated;
  opt.act.ParentRefresh:=PageRefresh;
  opt.act.doLoadPage:=DoActionPageLoad;
  opt.act.OnLoadData:=LoadData;
  opt.act.pb:=pb;
  options.Add(opt);
end;

procedure TDesktop.AddtoOptionsTree(f:TFrame);
begin
  new(opt);
  opt.name:=f.Name;opt.frame:=f;
  options.Add(opt);
end;

function TDeskTop.Showtstruct(pname, container:string):pointer;
var wc:TWinControl;
    inp:TInputFrame;
    i,frmno : integer;
    cat : string ;
    stime, sltime : TDateTime;
    fmPopup : TfmPopup ;
begin
  if pos('default',axp.dbm.gf.userroles) = 0 then
  begin
    if not axp.dbm.gf.useraccess(pname,TStructCDS.CDS) then
    begin
      ShowMessage('Access not available for the structure...');
      axp.SaveToLog('Open Tstruct',pname,'Access not available for the structure...',0);
      result:=nil;
      exit;
    end;
  end;
  axp.SaveToLog('Open Tstruct',pname,'Success',0);
  accxml := GetAccessControlXML('tstructs','t',pname);
  stime := now;
  pb.StepIt;
  try
  registerparams;
  fillparamvalues(paramvalues);
  AddtoPrList('t'+pname);
  if container='pop' then begin
    fmPopup := TfmPopup.Create(nil);
    fmPopup.FormInit(axp);
    fmPopup.Name := 'tstruct__'+pname;
//    fmPopup.AxProvider:=axp;
    fmPopUp.CallAction := CallAction;
    fmPopUp.GetActObject := GetActionObj;
    fmPopup.ShowRelated := ShowRelated;
    fmPopup.LoadData := LoadData ;
    fmPopup.Paramvalues:=Paramvalues;
    fmPopup.structbtnclick:=structbtnclick;
    fmPopup.OnCreateFrame:=Addtooptions;
    fmPopup.imgList := imgList ;
    fmPopup.pb := pb;
    fmPopup.Color:=TPanel(clientpanel).Color;
    fmPopup.accxml := accxml;
    fmPopup.GetDeskTopFontCDS := GetFontCDS;
    fmPopup.poptasks := poptasks;
    if assigned(qnavigate) then begin
      if not assigned(fmPopup.qNavigate) then
        fmPopup.qNavigate:=axp.dbm.getxds(nil);
      fmPopup.qNavigate.buffered:=true;
      fmPopup.qNavigate.CDS.Data := qnavigate.CDS.data;
    end else
      fmPopup.qNavigate:=nil;
    fmPopup.PopupMode:=pmAuto;
    fmPopup.PopupParent:=ParentForm;
    fmPopup.StatusBar := StatusBar;
    fmPopup.FromHyperLink := FromHyperLink;
    fmPopup.transid:=pname;
    while true do
    begin
      pb.StepIt;
      if pb.Position >= pb.Width then break;
    end;
    pb.Position := 0;
    if axp.dbm.gf.biDirectional then fmPopup.WindowState := wsMaximized;
    fmPopup.ShowModal;
    if (FromHyperLink) and (fmPopup.inp.RefreshView) and RefreshView then
      PageRefresh;

    DeleteFromOptions('tstruct__'+pname);
    fmpopup.Free;fmpopup := nil;
    axp.SaveToLog('Open Tstruct',pname,'Success',0);
    exit;
  end;
  if copy(container,1,2) = 'iv' then
  begin
    LoadNewPage := False;
    delete(container,1,2);
  end;
  wc:=TWinControl(parentform.findcomponent(container));
  if assigned(wc) then begin
    inp:=TInputFrame(wc.FindChildControl('tstruct__'+pname));
    if not assigned(inp) then
    begin
      if LoadNewPage = False then HideWin(lview_hidepurpose+container);
//      clearcontainer(TPanel(wc))
//      else begin
        for i:=0 to inode.ChildNodes.Count-1 do begin
          xnode:=inode.ChildNodes[i];
          cat:=xnode.Attributes['cat'];
          if assigned(aowner.findcomponent(xnode.NodeName)) then continue;
          if (cat='cntr') and (vartostr(lowercase(xnode.NodeName)) = lowercase(container)) then
          begin
             fdesign.loadcontainer(xnode) ;
             wc:=TWinControl(parentform.findcomponent(container));
             if lview_hidepurpose <> '' then wc.HelpKeyword := lview_hidepurpose;
             if LoadNewPage = False then Addwin;
             break;
          end;
        end;
//      end;
    end ;
  end else begin
    inp.clear;
    FreeAndNil(inp);
  end;
  if not assigned(inp) then begin
    inp:=TInputFrame.Create(wc);
    inp.parentform:=parentform;
    inp.parent:=wc;
    inp.Name := 'tstruct__'+pname;
    if build then inp.Tag:=tagdtoptstruct;
    if container = '' then inp.Visible := false;
    inp.Align := alclient;
    inp.AsPopup := false;
    inp.dbm:=axp.dbm;
    inp.AxProvider:=axp;
    inp.Color:=TPanel(clientpanel).Color;
//    inp.qNavigator:=qnavigate;
    if assigned(qnavigate) then begin
      if not assigned(inp.qNavigator) then
        inp.qNavigator:=axp.dbm.getxds(nil);
      inp.qNavigator.buffered:=true;
      inp.qNavigator.CDS.Data := qnavigate.CDS.data;
    end else
      inp.qNavigator:=nil;
    inp.paramvalues:=paramvalues;
    inp.btnclick:=Structbtnclick;
    inp.OnCallAction := CallAction;
    inp.GetActObject := GetActionObj;
    inp.ShowRelated := ShowRelated;
    inp.EditStruct := EditStruct;
    inp.statusbar:=TStatusbar(parentform.findcomponent('statusbar'));
    inp.DoHyperLink := DoHyperLink;
    inp.ListViewExist := ListViewExist;
    inp.ShowIView := ShowIView;
    addtooptions(inp);
    inp.imgList := imgList ;
    inp.pb := pb;
    inp.ActList := ActList;
    inp.accxml := accxml;
//{begin}added for poptstruct
    inp.TstructCDS := TStructCDS;
    inp.GetDeskTopFontCDS := GetFontCDS;
    inp.GetAccessControlXML := GetAccessControlXML;
    inp.poptasks := poptasks;
//added for poptstuct{end}
    inp.Init;
    inp.Relations := GetRelations(pname);
    Inp.FromHyperLink := FromHyperLink;
    inp.statusbar:= StatusBar;
    if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
    begin
      GetFontCDS('t'+pname,inp.fontCds);
    end;
    pb.StepIt;
    if build then
      inp.LoadDefinition(pname, '','update')
     else
       inp.LoadDefinition(pname, '','');
    pb.StepIt;
    frmNo := inp.GetFirstEnabledFrameno;
    if (frmno <> 0) and ((not FromHyperLink) or ((FromHyperlink) and (assigned(Paramvalues))))  then begin
      inp.Validate.Validation := False;
      inp.SelectFirstField(frmno);
      inp.Validate.Validation := True;
      if frmno > 1  then begin
        inp.exitframe(frmno-1);
        inp.enterframe(frmno);
      end;
    end;
    pb.StepIt;
  end;
  axp.dbm.gf.doDebug.Msg('>>Load Definition Time - ' + inttostr(millisecondsbetween(now(),stime)));
  stime := now;
  if build then begin
    inp.mode:=moBuild;
    inp.IForm.ImageObj := ImageObj;
    if assigned(inp.Parent.Parent) and (inp.Parent.Parent.Name = 'ClientPanel')then
    begin
       inp.IForm.fromdtop := 'yes';
       inp.IForm.Buildopts.Items.Clear;
       inp.Buildopts.Items.Clear;
    end;
  end
  else loaddata(inp);
  axp.dbm.gf.doDebug.Msg('>>Load Data Time - ' + inttostr(millisecondsbetween(now(),stime)));
  pb.StepIt;
  inp.SetFreezeColumnsforGridDC;
  inp.scalePage := ScalePage;
  result:=pointer(inp);
  except
  on e:exception do begin
    if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\Showtstruct - '+e.Message);
    axp.SaveToLog('Open Tstruct',pname,e.Message,0);
    showmessage(e.Message);
    if pos('['+pname+']',e.Message) > 0 then DeleteFromOptions('tstruct__'+pname) ;
    result:=nil;
  end;
  end;
end;

function TDeskTop.ShowTree(pname, container:string):pointer;
var wc:TWinControl;
    treeview1 : TfrmTreeFrame;
begin
  try
  wc:=TWinControl(parentform.findcomponent(container));
  if assigned(wc) then begin
    treeview1 := TfrmTreeFrame(wc.FindChildControl('tree__'+pname));
    if not assigned(treeview1) then
       clearcontainer(TPanel(wc))
    else begin
      treeview1.dtop := self;
      treeview1.DoHyperlink := DoHyperLink;
      if build then  begin
         treeview1.TreeName := pname;
         treeview1.Align := alclient;
         treeview1.Visible := true;
         treeview1.dbm := axp.dbm;
         treeview1.axp:= axp;
         treeview1.Init;
      end
      else
      begin
         treeview1.TreeName := pname;
         treeview1.Visible := true;
         treeview1.dbm := axp.dbm;
         treeview1.axp:= axp;
         treeview1.Align := alclient;
         treeview1.Init;
         treeview1.Enabled := true;
         if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
         begin
           GetFontCDS('r'+pname,treeview1.fontCds);
         end;
      end;
    end;
  end else treeview1:=nil;
  if not assigned(treeview1) then begin
    treeview1:=TfrmTreeFrame.Create(wc);
    treeview1.parentform:=parentform;
    treeview1.parent:=wc;
    treeview1.TreeName := pname;
    treeview1.Align := alclient;
    treeview1.Visible := true;
    treeview1.dbm := axp.dbm;
    treeview1.axp:= axp;
    treeview1.Enabled := true;
    if container = '' then treeview1.Visible := false ;
    treeview1.Align := alclient;
    treeview1.dtop := self;
    treeview1.DoHyperlink := DoHyperLink;
    treeview1.GetAccessControlXML := GetAccessControlXML;
    treeview1.GetActObject := GetActionObj;
  end;
  AddtoOptionsTree(treeview1);
  treeview1.BMode := build;
  treeview1.Init;
  if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
  begin
    GetFontCDS('r'+pname,treeview1.fontCds);
  end;
   treeview1.LoadDetails;
  except
  on e:exception do begin
    if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\ShowTree - '+e.Message);
    showmessage(e.Message);
    result:=nil;
  end;
  end;
end;

procedure TDesktop.AddIView;
var s:string;
begin
  if (selstruct='') or (fdesign.infocus.tag<>tagDtopContainer) then exit;
  s:='view__'+selstruct;
  xnode:=inode.ChildNodes.FindNode(s);
  if assigned(xnode) then
  begin
    showmessage('IView ' + selstruct + ' already added in this page');
    exit;
  end;
  showiview(selstruct,fdesign.infocus.name);
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then
    xnode:=inode.AddChild(s);
  xnode.Attributes['cat']:='iview';
  xnode.Attributes['name']:=selstruct;
  xnode.Attributes['parent']:=fdesign.infocus.name;
end;

function TDesktop.Showiview(pname, container:string):pointer;
var view:TViewFrame;
    wc:TWinControl;
    s,cat,purpose,cont,ct,vfilter : string ;
    i,j : integer;
    fmPopup : TfmPopup ;
begin
  purpose := '';
  lview_hidepurpose := '';
  cont := '';
  vfilter := '';
  axp.dbm.gf.pagination_pageno := 1;
  if copy(container,1,4) = 'list' then
  begin
     purpose := 'list';
     lview_hidepurpose := purpose;
     LoadNewPage := False ;
     delete(container,1,4);
     i := pos('~h',container);
     if i = 0 then
       i := pos('~t',container);
     if i > 0 then
     begin
       ct := copy(container,i+1,length(container));
       j := pos('~v',ct);
       if j > 0 then begin
         cont := copy(ct,1,j-1);
         vfilter := Trim(copy(ct,j+2,Length(ct)));
       end else
         cont := copy(container,i+1,length(container));
       delete(container,i,length(container));
     end;
  end else begin
    if container <> 'Panel6' then  // calling from iview define with container as Panel6
    begin
      if pos('default',axp.dbm.gf.userroles) = 0 then
      begin
        if not axp.dbm.gf.useraccess(pname,iviewCDS.CDS) then
        begin
          ShowMessage('Access not available for the IView...');
          axp.SaveToLog('Open Iview',pname,'Access not available for the IView...',0);
          result:=nil;
          exit;
        end;
      end;
    end;
  end;
//  accxml:=loadxmldata('<root></root>');
  if purpose <> 'list' then
    begin
       axp.SaveToLog('Open Iview',pname,'Success',0); 
       accxml := GetAccessControlXML('iviews','i',pname);
    end
  else
     accxml := GetAccessControlXML('lviews','l',pname);
  try
  registerparams;
  if container='pop' then begin
    fmPopup := TfmPopup.Create(nil);
    fmPopup.FormInit(axp);
    fmPopup.Name := 'view__'+pname;
    fmPopup.hparser:= hparser;
    fmPopup.structbtnclick := StructBtnClick;
    fmPopup.DoHyperLink:=DoHyperLink;
    fmPopup.ShowRelated := ShowRelated;
    fmPopup.CallAction:=CallAction;
    fmPopup.GetActObject := GetActionObj;
    fmPopup.OnCreateFrame:=Addtooptions;
    fmPopup.imgList := imgList ;
    fmPopup.Color:=TPanel(clientpanel).Color;
    fmPopup.accxml := accxml;
    fmPopup.GetDeskTopFontCDS := GetFontCDS;
    fmPopup.GetAccessControlXML := GetAccessControlXML;
    fmPopup.poptasks := poptasks;
    fmPopup.StatusBar := StatusBar;
    fmPopup.FromHyperLink := FromHyperLink;
    fmPopup.PopupParent:=ParentForm; //ch1
    fmPopup.QueryName:=pname;
    while true do
    begin
      pb.StepIt;
      if pb.Position >= pb.Width then break;
    end;
    pb.Position := 0;
    fmPopup.ShowModal;
    DeleteFromOptions('view__'+pname);
    fmpopup.Free;
    fmpopup:=nil;
    axp.SaveToLog('Open Iview',pname,'Success',0); 
    exit;
  end;
  wc:=TWinControl(parentform.findcomponent(container));
  if (container = 'Panel6') or (container = 'pnlHeading') then
    wc := TWinControl(Iview_frame.FindComponent(container))
  else
    wc:=TWinControl(parentform.findcomponent(container));
  if not assigned(wc) then
    wc:=TWinControl(ClientPanel);
  if container = 'Panel6' then  // calling from iview define with container as Panel6
  begin
     clearcontainer(TPanel(wc));
     view:=TViewFrame(wc.FindComponent('view__'+pname));
  end
  else
  begin
    if assigned(wc) then begin
      view:=TViewFrame(wc.FindComponent('view__'+pname));
      if not assigned(view) then
      begin
        if LoadNewPage = False then HideWin(purpose+container);
          for i:=0 to inode.ChildNodes.Count-1 do begin
            xnode:=inode.ChildNodes[i];
            cat:=xnode.Attributes['cat'];
            if assigned(aowner.findcomponent(xnode.NodeName)) then continue;
            if (cat='cntr') and (vartostr(lowercase(xnode.NodeName)) = lowercase(container)) then
            begin
               fdesign.loadcontainer(xnode) ;
               wc:=TWinControl(parentform.findcomponent(container));
                if purpose <> '' then wc.HelpKeyword := purpose;
               if LoadNewPage = False then Addwin;
               break;
            end;
          end;
      end ;
    end else view:=nil;
  end;
  if not assigned(view) then begin
    view := TViewframe.Create(wc);
    view.parent:=wc;
    view.Name:='view__'+pname;
    if build then view.Tag:=tagdtopiview;
    view.AxProvider:=axp;
    view.dbm:=axp.dbm;
    view.imgList := imgList;
    view.Color:=TPanel(clientpanel).Color;
    view.poptasks := poptasks;
    view.init;
    view.StatusBar := StatusBar;
    view.xml := viewxml;
    view.AsPopup:=false;
    view.parentform:=parentform;
    view.align:=alclient;
    view.btnclick:=structbtnclick;
    view.OnCallAction:=CallAction;
    view.GetActObject:=GetActionObj;
    view.DoHyperLink:=DoHyperLink;
    view.DoRelate:=ShowRelated;
    view.ParentParser:=TProfitEval.Create(axp);
    view.ParentParser.Assign(hparser);
    view.FromHyperLink := FromHyperLink;
    RegisterIviewParamValues(view,pname);
    //view.ParentParser:=hParser;
    view.EditStruct:=EditStruct;
    view.ShowTruct:=Showtstruct;
    view.sbtnClick := SetClick;
    view.AddOpt := AddtoOptionsCon;
    view.ActList := ActList;
    view.pb := pb;
    view.scalepage := scalepage;
//    view.ShowMsgCount := ShowMsgCount;
    view.btnaccxml := accxml;
    if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
    begin
      if purpose <> 'list' then
         GetFontCDS('i'+pname,view.fontCds)
      else
         GetFontCDS('t'+pname,view.fontCds);
      view.wFormDes.fontCDS :=  view.fontCDS;
    end;
    if not build then addtooptions(view);
    view.iview.build := build;
    if copy(cont,1,1) = 'h' then begin
       delete(cont,1,1);
       view.listviewcont := cont;
    end else begin
       delete(cont,1,1);
       view.TransCondition := cont;
    end;
    if vfilter <> '' then
      view.ParentParser.RegisterVar('viewfilter','c',vfilter);
    view.Build:=build;
    if build then begin
       view.LoadView(pname, '', 'update');
       view.wFormDes.ImageObj := ImageObj;
    end
    else
       view.LoadView(pname,'',purpose);
    if assigned(view.Parent.Parent) and (view.Parent.Parent.Name = 'ClientPanel') and (build) then
    begin
       view.wFormDes.fromdtop := 'yes';
       view.wFormDes.Buildopts.Items.Clear;
       view.Buildopts.Items.Clear;
    end;
  end else
  begin
    if hparser.GetVarValue('paramgiven') = 'yes' then
    begin
      if view.iview.Default_displayParamWin then
      Begin
        view.iview.ParamsGiven := false;
        view.iview.PaginationParamsGiven := false;
        view.iview.displayParamWin := true;
      End;
      axp.dbm.gf.pagination_pageno := 1;
    end;
    view.ParentParser.Assign(hparser);
    view.iview.ExecuteQuery;
  end;
  AddtoPrList('i'+pname);

  if (view.ColFound('tstructname')) or (view.ColFound('transid') ) then s:= 'dynamic';
  if  view.loadstruct <> '' then s := 'static' ;
  poptasks.fontCDS := view.fontCDS;
  if purpose <> 'list' then
  poptasks.tasksPopup(view.tasks, view.iview.xml,'iview',s, imgList, view.AcsTaskList,nil)
  else poptasks.tasksPopup(view.tasks, view.iview.xml,'lview',s, imgList, view.AcsTaskList,nil) ;
  view.PopupMenu :=  view.tasks;
  view.PopupMenu.AutoPopup := False;
  if view.loadstruct <> '' then
  begin
    accxml := GetAccessControlXML('tstructs','t',view.loadstruct);
    view.accxml :=  accxml;
  end;
  view.ShowTotalRecBar;
  view.stbar.Visible := false;
  if build then
     view.recPanel.Visible := false     // by ar
  else
     view.recPanel.Visible := True;
  view.iRefresh := PageRefresh;   //ch1
  axp.dbm.gf.pagination_pageno := 0;
  result:=pointer(view);
  except
  on e:exception do begin
    if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\Showiview - '+e.Message);
    axp.SaveToLog('Open Iview',pname,e.Message,0); 
    if container = 'Panel6' then raise;
    if (purpose <> 'list') then
      showmessage(e.message);
    if (pos('['+pname+']',e.Message) > 0) and not build then DeleteFromOptions('view__'+pname);
    if build and (pos('['+pname+']',e.Message) > 0) then begin
      TViewFrame(view).Clear ;
      FreeAndNil(view);
    end;
    axp.dbm.gf.pagination_pageno := 0;
    result:=nil;
  end;
  end;
end;

procedure TDeskTop.LoadIView(n:ixmlnode);
var pnl:TPanel;
    s:string;
begin
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if not assigned(pnl) then
    showmessage('Unable to find parent container to load '+vartostr(n.attributes['transid']))
  else begin
    s:=n.attributes['name'];
    GetRelated('i'+s);
    if not build or (build and (pgtype = 'stem')) then
      ShowIView(s, pnl.name)
    else begin
      EditStruct(s,'i',pnl.Name);        //ch1
    end
  end;
end;

procedure TDesktop.getrelated(sname:string);
var i:integer;
    cnode:ixmlnode;
    frm:tframe;
begin
  if not assigned(relations) then exit;
  for i:=0 to relations.ChildNodes.Count-1 do begin
    cnode:=relations.ChildNodes[i];
    if vartostr(cnode.attributes['detail'])<>sname then continue;
    frm:=Getoption(vartostr(cnode.attributes['master']));
    if assigned(frm) then begin
      hypernode:=cnode;
      if assigned(hparser) then begin
        hparser.free;
        hparser:=nil;hparsebak:=nil;
      end;
      hparser:=TProfitEval.Create(axp);
      if frm.classtype=TInputframe then begin
        hparser.Assign(TInputFrame(frm).Parser);
      end else begin
        hparser.Assign(TViewFrame(frm).Parser);
      end;
    end;
  end;
end;

function TDeskTop.CallAction(Sender:TObject; Actionname:String;n:IXMLNode) : String ;
var sact:TDoAction;
begin
  result := '';
  sact:=GetAction(TFrame(sender));
  if assigned(sact) then
    result := sact.execute(sender, actionname,n);
end;

function TDeskTop.Getselected: pointer;
var wc:TWinControl;
begin
  result:=nil;
  wc:=parentform.activecontrol;
  while assigned(wc) do begin
    if (wc.ClassType=TInputFrame) or (wc.ClassType=TViewFrame) then begin
      result:=wc;
      break;
    end;
    wc:=wc.Parent;
  end;
end;

procedure TDeskTop.LoadData(pInp:TInputFrame);
var ws,s,t,nv,s1,ErrStr :string;
    x:txds;
    i,frmno:integer;
    recid:extended;
    xdoc: ixmldocument;
    n,n1 : IXMLNode;
    ohp:TProfitEval;
begin
  if build then
  begin
     LinkFrom := '';
     exit;
  end;
  ws := '';
  if (calenderid <> '') and (pInp.TransType = calTransId)then
  begin
    ws := pInp.Sdef.PrimaryTable+'id = ' + calenderid ;
    ws:='select ' + pInp.Sdef.PrimaryTable+'id' + ' from '+pInp.StoreData.CompanyName+pInp.Sdef.PrimaryTable+' where '+ws;
    x := Axp.dbm.GetXDS(nil);
    x.buffered := True;
    x.CDS.CommandText:=ws;
    x.open;
    if not x.CDS.isempty then begin
      recid:=x.CDS.fieldbyname(pInp.Sdef.PrimaryTable+'id').asfloat;
      pInp.LoadData(recid);
    end;
    x.close;
    x.free;
    LinkFrom := '';
    axp.SaveToLog('Load Data',pInp.TransType,'Success',recid);
    exit;
  end;
  ws:='';
  if (not assigned(hparser)) or (not assigned(hypernode)) then begin
    LinkFrom := '';
    exit;
  end;

  if assigned(hypernode) and (hypernode.ChildNodes.Count>0) then begin
    for i:=0 to hypernode.childnodes.count-1 do begin
      nv := vartostr(hypernode.ChildNodes[i].Attributes['n']) ;
      if pos('.',nv) > 0 then
      begin
        if copy(nv,1,pos('.',nv)-1) <> pInp.TransType then continue;
        delete(nv,1,pos('.',nv));
      end;

      if lowercase(nv) = 'recordid' then nv := pInp.Sdef.PrimaryTable+'id';

      s:=vartostr(hypernode.ChildNodes[i].Attributes['v']);
      if copy(s,1,1) = ':' then begin
        delete(s,1,1);
        s1 := GetPValue(s);
        if s1=quotedstr('') then
        begin
          ohp:=hparser;
          hparser:=TProfitEval.create(axp);
          hparser.Assign(pInp.parser);
          s1 := GetPValue(s);
          hparser := nil;
          hparser:=ohp;
        end;
      end else begin
        if copy(s,1,1) = '{' then begin
          if copy(s, Length(s)-2,3) = '*d}' then begin
            s := copy(s,2,length(s)-4);
            s := axp.dbm.gf.findandreplace(axp.dbm.gf.dbdatestring, ':value', axp.dbm.gf.ConvertToDBDateTime(axp.dbm.Connection.dbtype,strtodatetime(s)))
          end else
            s := QuotedStr(copy(s,2,length(s)-2));
        end;
        s1 := s;
      end;
      if s1<>quotedstr('') then begin
        if trim(s1)= '' then s1 := quotedstr('');  //ch1
         ws:=ws + ' and '+nv+' = '+s1;
      end;
    end;
  end else if assigned(hparser) then begin
    if LinkFrom <> 'tstruct' then begin
      s:=vartostr(hypernode.Attributes['source']);
      if s<>'' then
        ws:=' and '+s+' = '+GetPValue(vartostr(hypernode.Attributes['source']));
    end;
  end;
  if ws<>'' then begin
    pb.StepIt;
    delete(ws, 1, 5);
    ws:='select ' + pInp.Sdef.PrimaryTable+'id' + ' from '+pInp.StoreData.CompanyName+pInp.Sdef.PrimaryTable+' where '+ws;
    x := axp.dbm.GetXDS(nil);
    x.buffered := True;
    x.CDS.CommandText:=ws;
    try
      xdoc:=axp.GetOneRecord(x.cds.CommandText, '', '');
    except on e : exception do
    begin
       if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\LoadData - '+e.Message);
       errstr := e.Message;
       x.close;
       ws := axp.dbm.gf.FindAndReplace(ws,'=','like');  // to deal hyperlink from a text datatype field/column
       x.CDS.CommandText:=ws;
       xdoc:=axp.GetOneRecord(x.cds.CommandText, '', '');
    end;
    end;
    if (errstr <> '') then
    begin
      axp.SaveToLog('Load Data',pInp.TransType,'Failure',0);
    end;
    if xdoc.DocumentElement.childnodes.count>0 then
    begin
      n := xdoc.DocumentElement.ChildNodes[0];
      if n <> nil then n1 := n.ChildNodes.findnode(uppercase(pInp.Sdef.PrimaryTable+'id'));
      if n1 = nil then n1 := n.ChildNodes.findnode(pInp.Sdef.PrimaryTable+'id');
      if n1 <> nil then
      begin
        recid:=strtofloat(vartostr(n1.NodeValue));
        pInp.LoadData(recid);
        axp.SaveToLog('Load Data',pInp.TransType,'Success',recid);
      end;
    end else pInp.ClearForm;
    pb.StepIt;
    x.close;
    x.free;
  end else begin
    pb.StepIt;
    frmNo := pInp.GetFirstEnabledFrameno;
    if (frmno <> 0) then begin
      pInp.Validate.Validation := False;
      pInp.SelectFirstField(frmno);
      pInp.Validate.Validation := True;
      if frmno > 1  then begin
        pInp.exitframe(frmno-1);
        pInp.enterframe(frmno);
      end;
    end;
    pb.StepIt;
  end;

  LinkFrom := '';
  while true do
  begin
    pb.StepIt;
    if pb.Position >= pb.Width then break;
  end;
  pb.Position := 0;
end;

function TDesktop.GetPValue(pName:string):string;
begin
  result:=hparser.GetVarValue(pName);
  if result <> '' then
  begin
    if hparser.LastVarType='c' then result:=QuotedStr(result)
    else if hparser.LastVarType='t' then result:=QuotedStr(result)
    else if hparser.LastVarType='d' then begin
      result := axp.dbm.gf.findandreplace(axp.dbm.gf.dbdatestring, ':value', axp.dbm.gf.ConvertToDBDateTime(axp.dbm.Connection.dbtype,strtodatetime(result)));
    end else if hparser.LastVarType='' then result := QuotedStr('');                         //result:='''';
  end else result := QuotedStr('');
end;

//hyper link related methods
function TDeskTop.DoHyperLink(sender:TObject; name:string):boolean;
var hnode, cnode:ixmlnode;
    stype, sname, cntr, sval:string;
    i:integer;
begin
  result:=false;sname:='';
  if build then exit;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;hparsebak:=nil;
  end;
  hparser:=TProfitEval.Create(axp);
  hypernode:=nil;qnavigate:=nil;Paramvalues:=nil;
  if sender.ClassType=TInputFrame then begin
    LinkFrom := 'tstruct';
    hnode:=TInputFrame(sender).hypernode;
    hparser.Assign(TInputFrame(sender).Parser);
  end else begin
    hnode:=TViewFrame(sender).hypernode;
    hparser.Assign(TViewFrame(sender).iview.Parser);
    qnavigate:=txds(TViewFrame(sender).iview.QueryList[0]);
    if TViewFrame(sender).iview.QueryName = 'inbox' then
       sname := TViewFrame(sender).iview.parser.GetVarValue('sname');
  end;
  if not assigned(hnode) then begin
    hparser.free;hparser:=nil;hparsebak:=nil;
    qnavigate := nil;
    exit;
  end;
  cntr:=TWinControl(sender).Parent.Name;

  for i:=0 to hnode.ChildNodes.Count-1 do begin
     cnode:=hnode.ChildNodes[i].CloneNode(true);
     hypernode:=cnode;
     if (vartostr(cnode.Attributes['source'])<>name) then continue;
     if sname = '' then sname:=vartostr(cnode.Attributes['sname']);
     if sname='' then continue;
     if sname[1]=':' then begin
       delete(sname,1,1);
       sname:=hparser.GetVarValue(sname);
       if sname='' then continue;
     end;

     stype:=sname[1];delete(sname,1,1);
     if sname='' then continue;

     if vartostr(cnode.Attributes['pop'])='True' then cntr:='pop';
     if TFrame(Sender).Parent.ClassName = 'TfmPopup' then  cntr:='pop';
     RefreshView := lowercase(vartostr(cnode.Attributes['refresh'])) = 'true';
     if cnode.HasAttribute('load') then
     begin
       if vartostr(cnode.Attributes['load']) = 'True' then
          hypernode := cnode
       else begin
         paramvalues := cnode;
         hypernode := nil;
       end;
     end;
     FromHyperlink := True;
     if stype='t' then begin
       LoadNewPage := False ;
       if (copy(cnode.Attributes['source'],1,3) = 'lbl') and
          (copy(cnode.NodeName,1,4) = 'hl__' ) then begin
         Registerparams;
         sval := '';
         if (cnode.ChildNodes.Count > 0) then begin
           sval := vartostr(cnode.ChildNodes[0].Attributes['v']);
           if copy(sval,1,1) = ':' then delete(sval,1,1);
           sval := hparser.GetVarValue(sval);
         end;
         if (sval = '')  then begin
           if (ListViewExist(sname)) then
             showiview(sname,'list'+cntr)
           else
             showtstruct(sname, cntr);
         end else
             showtstruct(sname, cntr);
       end else
         showtstruct(sname, cntr);
       result:=true;
     end else if stype='p' then begin
       LoadNewPage := False ;
       PageName:=sname;
       pgtype := 'p';  //ch1
       result:=true;
     end else if stype='i' then begin
       LoadNewPage := False ;
       showiview(sname, cntr);
       result:=true;
     end;
     sname := '';
     FromHyperlink := False;
  end;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;hparsebak:=nil;
  end;
  hypernode:=nil;qnavigate:=nil;Paramvalues:=nil;
  RefreshView := false;
end;

function TDeskTop.DoActionPageLoad(sender:TObject; name,task:string;n : IXMLNode):boolean;
begin
  result:=false;
  if build then exit;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;hparsebak:=nil;
  end;
  hparser:=TProfitEval.Create(axp);
  hypernode:=nil;qnavigate:=nil;paramvalues:=nil;
  if task = 'load' then
     hypernode := n
  else if task = 'open' then begin
    paramvalues := n;
//    hypernode:=n;
  end;
  if assigned(Sender) then begin
    if sender.ClassType=TInputFrame then begin
      LinkFrom := 'tstruct';
      hparser.Assign(TInputFrame(sender).Parser);
    end else begin
      axp.dbm.gf.pagination_pageno := 1;
      hparser.Assign(TViewFrame(sender).Parser);
      qnavigate:=txds(TViewFrame(sender).iview.QueryList[0]);
    end;
  end;
  if not assigned(n) then begin
    hparser.free;hparser:=nil;hparsebak:=nil;
    exit;
  end;
  PageName:=name;
  result:=true;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;hparsebak:=nil;
  end;
  hypernode:=nil;qnavigate:=nil;paramvalues:=nil;
end;

function TDesktop.ShowRelated(sender:TObject;pName:String):boolean;
var cnode:ixmlnode;
    s, mstruct, mname, stype, sname, cntr, cname:string;
    i:integer;
    comp:TComponent;
    wc : TWinControl;
begin
  result:=false;
  if build then exit;
  if not assigned(relations) then exit;
  if sender.ClassType=TInputFrame then
    mstruct:='t'+TInputFrame(sender).TransType
  else
    mstruct:='i'+TViewFrame(sender).iview.QueryName;
  for i:=0 to relations.ChildNodes.Count-1 do begin
    cnode:=relations.ChildNodes[i];
    hypernode:=nil;
    hypernode:=cnode;
    if vartostr(cnode.attributes['master'])<>mstruct then continue;
    if assigned(hparser) then begin
      hparser.free;
      hparser:=nil;hparsebak:=nil;
    end;
    hparser:=nil;qnavigate:=nil;paramvalues:=nil;hparsebak:=nil;
    hparser:=TProfitEval.Create(axp);
    if sender.ClassType=TInputFrame then begin
      hparser.Assign(TInputFrame(sender).Parser);
    end else begin
      hparser.Assign(TViewFrame(sender).Parser);
      qnavigate:=txds(TViewFrame(sender).iview.querylist[0]);
    end;
    s:=vartostr(cnode.Attributes['source']);
    if (s<>'') and (s<>pname) then continue;
    sname:=vartostr(cnode.Attributes['detail']);
    if sname='' then continue;
    if sname[1]=':' then begin
      delete(sname,1,1);
      sname:=hparser.GetVarValue(sname);
      if sname<>'' then begin
        stype:=sname[1];delete(sname,1,1);
      end
      else if vartostr(cnode.Attributes['detail']) = ':sname' then
      begin
         cntr:=vartostr(cnode.Attributes['container']);
         wc:=TWinControl(parentform.findcomponent(cntr));
         if assigned(wc) then ClearContainer(TPanel(wc));
         continue;
      end
      else continue;
    end else begin
      stype:=sname[1];delete(sname,1,1);
    end;
    cntr:=vartostr(cnode.Attributes['container']);
    comp:=parentform.findcomponent(cntr);
    if assigned(comp) then begin
      if (stype='t') {and (assigned(comp.findcomponent('tstruct__'+sname)))} then begin
       LoadNewPage := true;
       showtstruct(sname, cntr);
       result:=true;
      end else if (stype='i') {and (assigned(comp.findcomponent('view__'+sname)))}  then begin
       LoadNewPage := true;
       showiview(sname, cntr);
       result:=true;
      end;
    end;
  end;
  hparser.Free;hparser:=nil;hypernode:=nil;qnavigate:=nil;hparsebak:=nil;
end;

procedure TDeskTop.BtnClick(sender: TObject);
var k:integer;
    n,n1:ixmlnode;
    stype, sname, cntr:string;
    obj : TObject;
    wc : TWinControl;
begin
  if build then exit;
  if assigned(hparser) then begin
    hparser.free;hparser:=nil;hparsebak:=nil;
  end;
  hypernode:=nil ;

  n:=inode.ChildNodes.FindNode(TWincontrol(sender).name);
//  if (n = nil) and (dtemplate <> nil) then n:=dtemplate.ChildNodes.FindNode(TWincontrol(sender).name);
  if not assigned(n) then exit;
  if n.childnodes.count>0 then paramvalues:=n.CloneNode(true) else paramvalues:=nil;

  sname:=vartostr(n.Attributes['rel']);
  if sname<>'' then begin
    Showrelatedoption(sname);
    exit;
  end;

  sname:=vartostr(n.Attributes['sname']);
  if LowerCase(vartostr(n.Attributes['pop']))='true' then cntr:='pop'
  else cntr:=vartostr(n.Attributes['container']);
  if sname<>'' then begin
    stype:=sname[1];delete(sname,1,1);
    if stype='t' then begin
     LoadNewPage := False ;
     showtstruct(sname, cntr);
    end else if stype='p' then begin
     LoadNewPage := True ;
     PageName:=sname;
    end else if stype='i' then begin
     LoadNewPage := False ;
     showiview(sname, cntr);
    end;
  end else begin
    if not assigned(actions) then exit;
    if actions.ChildNodes.Count = 0 then exit;
    k:=axp.dbm.gf.registered.IndexOf(TWinControl(sender).name);
    if k>-1 then begin
      n1 := actions.ChildNodes.FindNode(axp.dbm.gf.btnactions[k]);
      if n1 = nil then exit;
      n := actions.ChildNodes.FindNode(axp.dbm.gf.btnactions[k]).CloneNode(true);
      act.axp:=axp;
      act.Container:=cntr;
      act.opendialog := odialog;
      act.pb := pb;
      act.PageActions(n,axp.dbm.gf.btnactions[k]);
      act.Container:='';
    end;
  end;
end;

procedure TDeskTop.StructBtnClick(CallFrame:TFrame; btn:TSpeedbutton; n,act:ixmlnode);
var k:integer;
    stype, sname, cntr:string;
    wc:TWinControl;
    sact:TDoAction;
begin
  if callframe.classtype=TViewFrame then begin
    if TViewFrame(callframe).Build then exit;
  end else begin
    if TInputframe(callframe).Mode = moRun then
      build := False
    else
      build := True;
  end;
  if build then exit;
  hypernode:=nil;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;
    hparsebak:=nil;
  end;
  hparser:=TProfitEval.Create(axp);
  if callframe.classtype=TViewFrame then
    hparser.Assign(TViewFrame(callframe).iview.parser)
  else
    hparser.assign(TInputframe(callframe).parser);

  if not assigned(n) then exit;
  if n.childnodes.count>0 then paramvalues:=n.CloneNode(true) else paramvalues:=nil;

  sname:=vartostr(n.Attributes['sname']);
  cntr:=vartostr(n.Attributes['container']);
  if vartostr(n.Attributes['pop'])='True' then cntr:='pop';
  if cntr='' then begin
    cntr:=Callframe.Parent.Name;
  end;
  if sname<>'' then begin
    stype:=sname[1];delete(sname,1,1);
    if stype='t' then begin
     LoadNewPage := False ;
     showtstruct(sname, cntr);
    end else if stype='p' then begin
     LoadNewPage := True ;
     PageName:=sname;
    end else if stype='i' then begin
     LoadNewPage := False ;
     showiview(sname, cntr);
    end;
  end;
  k:=btn.Tag;
  if k>=0 then begin
    sact:=Getaction(TFrame(CallFrame));
    if sact <> nil then begin
      sact.Container:=cntr;
      sact.pb := pb;
      sact.hparser:=hparser;
      if axp.dbm.gf.btnactions.Count-1 >= k then
        sact.execute(TObject(CallFrame), axp.dbm.gf.btnactions[k],act);
    end;
  end;
end;

function TDeskTop.ShowRelatedOption(pRelation:String):boolean;
var i:integer;
    n:ixmlnode;
    s,mstruct,mname,stype,sname,cntr:string;
    frm:TFrame;
begin
  result:=false;
  for i:=0 to relations.childnodes.count-1 do begin
    n:=relations.childnodes[i];
    if n.NodeName=pRelation then begin

      //Find the master option in the current page
      mstruct:=vartostr(n.attributes['master']);
      frm:=GetOption(mstruct);
      if not assigned(frm) then break;
      hypernode:=n;
      if frm.classtype=TInputFrame then begin
        hparser:=TProfitEval.create(axp);
        hparser.Assign(TInputFrame(frm).Parser);
      end else begin
        hparser:=TProfitEval.create(axp);
        hparser.Assign(TViewFrame(frm).parser);
        qnavigate:=TXDS(TViewFrame(frm).iview.QueryList[0]);
      end;

      //calling the option
      sname:=vartostr(n.Attributes['detail']);
      if sname='' then continue;
      if sname[1]=':' then begin
        delete(sname,1,1);
        sname:=hparser.GetVarValue(sname);
        if sname<>'' then begin
          stype:=sname[1];delete(sname,1,1);
        end else break;
      end else begin
        stype:=sname[1];delete(sname,1,1);
      end;
      cntr:=vartostr(n.attributes['container']);
      if vartostr(n.Attributes['pop'])='True' then cntr:='pop';
      if stype='t' then begin
       LoadNewPage := True ;
       showtstruct(sname, cntr);
       result:=true;
      end else if stype='i' then begin
       LoadNewPage := True ;
       showiview(sname, cntr);
       result:=true;
      end;
    end;
  end;
  hypernode:=nil;qnavigate:=nil;
end;

function TDesktop.GetOption(pName:string):TFrame;
var j:integer;
    s:string;
begin
  result:=nil;
  if pname='' then exit;
  if pname[1]='t' then begin
    delete(pname,1,1);
    for j:=0 to options.count-1 do begin
      if (inpage(pOpt(options[j]).frame)) and (pname=TInputFrame(pOpt(options[j]).frame).TransType) then begin
        result:=pOpt(options[j]).frame;
        break;
      end;
    end;
  end else begin
    delete(pname,1,1);
    for j:=0 to options.count-1 do begin
      if (inpage(pOpt(options[j]).frame)) and (pname=TViewFrame(pOpt(options[j]).frame).iview.QueryName) then begin
        result:=pOpt(options[j]).frame;
        break;
      end;
    end;
  end;
end;

function TDesktop.Gethp(pName:string):TProfitEval;
var j:integer;
    s:string;
begin
  result:=nil;
  if pname='' then exit;
  for j:=0 to hplist.count-1 do begin
    if pPrList(hplist[j]).name = pName then
    begin
      result:=pPrList(hplist[j]).hp;
      break;
    end;
  end;
end;

//Handling GoNext, GoPrior

procedure TDeskTop.AddWin;
var i:integer;
    pnl:TPanel;
begin
  if (build) or (fpage = 'Axp__AppMgrPGE') then exit;        //'Axp__AppMgrPGE' is application manager page
  if not assigned(pnlWins) then exit;
  for i:=winno+1 to pnlwins.controlcount-1 do
  begin
    if pnlwins.controls[winno+1].HelpKeyword = 'static' then continue;
    clearwin(winno+1);
  end;
  if pnlwins.ControlCount=10 then ClearWin(0);
  pnl:=TPanel.create(pnlWins);
  pnl.parent:=pnlWins;
  pnl.Caption:=fPage;
  winno:=pnlwins.controlcount-1;
end;

procedure TDeskTop.ClearWin(wno:integer);
var pnl:TPanel;
begin
  pnl:=TPanel(pnlwins.controls[wno]);
  Freechildoptions(pnl);
  pnl.Free;
end;

procedure TDeskTop.HideWin;
var i:integer;
    pnl:TPanel;
    s,purp:string;
    frm : TFrame;
begin
  if not assigned(pnlwins) or (winno=pnlwins.controlcount) then exit;         //ch1
  if (fpage = 'Axp__AppMgrPGE') then begin
    clearcontainer(TPanel(clientpanel));
    exit;
  end;
  for i:=0 to options.count-1 do begin
    frm:=pOpt(options[i]).frame;
    if frm.classtype=TInputFrame then begin
      if assigned(TInputFrame(frm).Selection) then
        TInputFrame(frm).Selection.grid.Visible := False;
      if assigned(TInputFrame(frm).pnlical) then begin
        TInputFrame(frm).pnlical.Visible:=false;
        TInputFrame(frm).pnlical.SendToBack;
      end;
    end;
   end;
  pnl:=TPanel(pnlwins.controls[winno]);
  for i:=clientpanel.controlcount-1 downto 0 do begin
    if clientpanel.controls[i].HelpKeyword = 'static' then continue;
    s:=clientpanel.controls[i].Name;
    s:='x'+axp.dbm.gf.leftpad(inttostr(sno), 5, '0')+s;
    sno:=sno+1;
    purp := clientpanel.controls[i].HelpKeyword;
    clientpanel.controls[i].Name:=purp+s;
    clientpanel.controls[i].parent:=pnl;
  end;
end;

procedure TDeskTop.HideWin(hcntr : string) ;
var i,j:integer;
    pnl:TPanel;
    s,purp:string;
    frm : TFrame;
begin
  if (winno=pnlwins.controlcount) or (fpage = 'Axp__AppMgrPGE') then exit;
  purp := '';
  hcntr := trim(hcntr);
  if copy(hcntr,1,4) = 'list' then
  begin
     purp := 'list';
     delete(hcntr,1,4);
  end;
  for i:=0 to options.count-1 do begin
    frm:=pOpt(options[i]).frame;
    if frm.classtype=TInputFrame then begin
      if assigned(TInputFrame(frm).Selection) then
        TInputFrame(frm).Selection.grid.Visible := False;
      if assigned(TInputFrame(frm).pnlical) then begin
        TInputFrame(frm).pnlical.Visible:=false;
        TInputFrame(frm).pnlical.SendToBack;
      end;
    end;
   end;
  pnl:=TPanel(pnlwins.controls[winno]);
  for i:=clientpanel.controlcount-1 downto 0 do begin
    if lowercase(clientpanel.controls[i].Name) <> lowercase(hcntr) then   continue;
    if clientpanel.controls[i].HelpKeyword = 'static' then continue;
    s:=clientpanel.controls[i].Name;
    s:='x'+axp.dbm.gf.leftpad(inttostr(sno), 5, '0')+s;
    sno:=sno+1;
    clientpanel.controls[i].Name:=purp+s;
    clientpanel.controls[i].parent:=pnl;
  end;
end;

procedure TDeskTop.ShowWin;
var i , ccount,j :integer;
    pnl:TPanel;
    s,cat,caption,contname,sname,purp,lvcntr:string;
    inp : TInputFrame;
    wc : TWinControl;
begin
  if winno=pnlwins.controlcount then exit;
  pnl:=TPanel(pnlwins.controls[winno]);
  fpage:=pnl.caption;
  caption := '';
  fPageName := '';
  for i := 0 to pxml.DocumentElement.ChildNodes.Count-1 do begin
    xnode := pxml.DocumentElement.ChildNodes[i];
    if (uppercase(vartostr(xnode.Attributes['visible']))='F') and (not build) then continue;
    if xnode.Attributes['group'] = 'true' then continue;
    if vartostr(xnode.NodeValue) = fpage then
    begin
       fpage := vartostr(xnode.NodeName);
       caption := vartostr(xnode.NodeValue);
       fPageName := '';
       break;
    end;
    if caption = '' then
    begin
      if vartostr(xnode.NodeName) = fpage then caption := vartostr(xnode.NodeValue);
    end;
  end;
  InitPageVars(fpage);
  lvcntr := '';
  for i:= pnl.controlcount-1 downto 0 do begin
    purp := '';
    s:=trim(pnl.controls[0].name);
    if copy(s,1,4) = 'list' then
    begin
       purp := 'list';
       delete(s,1,4);
    end;
    delete(s,1,6);
    pnl.controls[0].Name:=s;
    if purp <> '' then  lvcntr := lvcntr + s;
    pnl.controls[0].parent:=clientpanel;
    contname := contname + s + ',';
  end;
  ccount := 0;
  for i:=0 to inode.ChildNodes.Count-1 do
  begin
    xnode:=inode.ChildNodes[i];
    cat:=xnode.Attributes['cat'];
    if cat='cntr' then ccount := ccount + 1;
    if assigned(aowner.findcomponent(xnode.NodeName)) then continue;
    if cat='cal' then loadcal(xnode,cat)
    else if cat = 'teamcal' then loadcal(xnode,cat)  ;
  end;
  if ccount <= 1 then begin
    if not fBuild then begin
      for i:=0 to inode.ChildNodes.Count-1 do
      begin
        xnode:=inode.ChildNodes[i];
        cat:=xnode.Attributes['cat'];
        if cat='cntr' then begin
          wc := TWinControl(aowner.findcomponent(xnode.NodeName));
          if assigned(wc) then begin
            for j := 0 to wc.ControlCount- 1 do begin
              if wc.Controls[j].ClassType = TInputFrame then begin
                if axp.dbm.gf.Axp_LockOnRead then
                begin
                  if axp.CheckExistanceInTransControl(TInputFrame(wc.Controls[j]).StoreData.LastSavedRecordid,
                      TInputFrame(wc.Controls[j]).StoreData.TransType)
                      or (TInputFrame(wc.Controls[j]).StoreData.LastSavedRecordID <> 0) then
                  begin
                    TInputFrame(wc.Controls[j]).LoadData(TInputFrame(wc.Controls[j]).StoreData.LastSavedRecordid);
                  end;
                end;
                if TInputFrame(wc.Controls[j]).Sdef.popgrids.Count>0 then begin
                  TInputFrame(wc.Controls[j]).CreatePopupForm;
                  fmPopupForm.Build := False;
                  break;
                end;
              end;
            end;
          end;
          break;
        end;
      end;
    end;
    exit;
  end;
  for i:=0 to inode.ChildNodes.Count-1 do
  begin
    xnode:=inode.ChildNodes[i];
    cat:=xnode.Attributes['cat'];
    purp := vartostr(xnode.NodeName);
    if pos(purp,lvcntr) > 0 then
    begin
//      delete(lvcntr,pos(purp,lvcntr),length(purp));
      continue;
    end;
    if assigned(aowner.findcomponent(purp)) then continue;
    if cat='cntr' then
    begin
       s := xnode.NodeName;
       if pos(s,contname) > 0 then continue;
       fdesign.loadcontainer(xnode)
    end
    else if cat='tstruct' then
    begin
       s := vartostr(xnode.Attributes['parent']);
      if pos(s,lvcntr) > 0 then
      begin
  //      delete(lvcntr,pos(purp,lvcntr),length(purp));
        continue;
      end;
//       if pos(s,contname) > 0 then continue;
       LoadNewPage := True ;
//       fdesign.loadtstruct(xnode)
       sname := vartostr(xnode.NodeName);
       inp :=  TInputFrame(GetInputFrame(sname));
       if not assigned(inp) then
       begin
          sname := vartostr(xnode.attributes['transid']);
          sname := 'tstruct__'+sname;
          inp :=  TInputFrame(GetInputFrame(sname));
       end;
       if not assigned(inp) then  continue;
       wc:=TWinControl(parentform.findcomponent(s));
       if assigned(wc) then
       begin
         if assigned(hparser) then begin
           hparser.free;
           hparser:=nil;hparsebak:=nil;
         end;
         hparser:=TProfitEval.Create(axp);
         hypernode:=nil;qnavigate:=nil;
         inp.Parent := wc;
         if assigned(inp.hypernode) then
            hypernode:=inp.hypernode;
         hparser.Assign(inp.Parser);
         loaddata(inp);
       end;
    end
    else if cat='iview' then
    begin
       s := vartostr(xnode.Attributes['parent']);
       if pos(s,contname) > 0 then continue;
       LoadNewPage := True ;
       fdesign.loadiview(xnode) ;
       sname := vartostr(xnode.attributes['name']);
    end
    else if cat='tree' then
    begin
       s := vartostr(xnode.Attributes['parent']);
       if pos(s,contname) > 0 then continue;
       LoadNewPage := True ;
       fdesign.loadtreestruct(xnode);
    end;
  end;
  if assigned(hparser) then begin
    hparser.free;
    hparser:=nil;hparsebak:=nil;
  end;
  hypernode:=nil;qnavigate:=nil;
  fdesign.LoadComps(inode,'');
end;


function TDeskTop.GetInputFrame(f: String): TFrame;
var n:string;
    j:integer;
begin
  result:=nil;
  for j:=0 to options.count-1 do begin
    if (inpage(pOpt(options[j]).frame)) and (f=TInputFrame(pOpt(options[j]).frame).TransType) then begin
      result:=pOpt(options[j]).frame;
      break;

    end;
  end;
end;


procedure TDesktop.GoPrior;
begin
  if Winno=0 then exit;
  if assigned(fmPopupForm) then begin
    fmPopupForm.Free;
    fmPopupForm:=nil;
  end;
  HideWin;
  WinNo:=WinNo-1;
  ShowWin;
end;

procedure TDeskTop.GoNext;
begin
  if Winno=pnlWins.ControlCount-1 then exit;
  if pnlWins.ControlCount = 0 then exit;
  if assigned(fmPopupForm) then begin
    fmPopupForm.Free;
    fmPopupForm:=nil;
  end;
  HideWin;
  WinNo:=WinNo+1;
  ShowWin;
end;

function TDeskTop.GetClicked: TSpeedButton;
begin
  if assigned(fdesign) then
    result:=fdesign.clicked
  else result:=nil;
end;

procedure TDeskTop.Setclicked(const Value: TSpeedButton);
begin
  if assigned(fdesign) then
    fdesign.clicked:=value
  else fdesign:=nil;
end;

procedure TDeskTop.SetClick(btn : TSpeedButton);
begin
  clicked := btn;
end;

function TDesktop.Inpage(frm:TFrame):boolean;
var wc:TWinControl;
begin
  wc:=TWinControl(frm);
  try
    while assigned(wc) and (wc<>ClientPanel) do
      wc:=wc.parent;
    result:=wc=ClientPanel;
  except on e:Exception do
    begin
      if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\Inpage - '+e.Message);
      result:=false;
    end;
  end;
end;

procedure TDeskTop.ClearContainer(pnl:TPanel);
var i:integer;
begin
  if not assigned(pnl) then exit;
  i:=0;
  FreeChildOptions(pnl);
  while (i<pnl.ControlCount) do begin
    if (pnl.Controls[i].Tag=tagDtopBorder) or (pnl.Controls[i].Tag=tagDtopCCap) or (pnl.Controls[i].Tag=tagDtopBanner) then begin
      inc(i);
      continue;
    end;
    pnl.Controls[i].Free;
  end;
end;

function TDesktop.GetParser(s:string):TProfitEval;
var frm:TFrame;
    n:string;
    j:integer;
begin
  s:=lowercase(s);
  for j:=0 to options.count-1 do begin
    frm:=pOpt(options[j]).frame;
    if (inpage(frm))  then begin
      if frm.classtype=TInputFrame then begin
        n:=lowercase(TInputFrame(frm).Name);
        delete(n,1,length('tstruct__'));
        if s=n then begin
          result:=TInputframe(frm).parser;
          break;
        end;
      end else begin
        n:=lowercase(TViewFrame(frm).Name);
        delete(n,1,length('view__'));
        if s=n then begin
          result:=TViewframe(frm).parser;
          break;
        end;
      end;
    end;
  end;
end;

function TDesktop.GetStructure(s:string):TObject;
var frm:TFrame;
    n:string;
    j:integer;
begin
  result := nil;
  s:=lowercase(s);
  for j:=0 to options.count-1 do begin
    frm:=pOpt(options[j]).frame;
    if (inpage(frm))  then begin
      if frm.classtype=TInputFrame then begin
        n:=lowercase(TInputFrame(frm).Name);
        delete(n,1,length('tstruct__'));
        if s=n then begin
          result:=TInputframe(frm);
          break;
        end;
      end else begin
        n:=lowercase(TViewFrame(frm).Name);
        delete(n,1,length('view__'));
        if s=n then begin
          result:=TViewframe(frm);
          break;
        end;
      end;
    end;
  end;
end;

procedure TDesktop.assignparser(hp:TProfitEval);
begin
  if not assigned(hp) then begin
    if assigned(hparser) then hparser.free;
    hparser:=hparsebak;
    hparsebak:=nil;
  end else begin
    if not assigned(hparsebak) then
      hparsebak:=hparser;
    hparser:=TProfitEval.Create(axp);
    hparser.Assign(hp);
  end;
end;

procedure TDesktop.Registerparams;
var n,v,t:string;
    i:integer;
begin
  if (not assigned(hparser)) or (not assigned(hypernode)) then exit;
  if assigned(hypernode) and (hypernode.ChildNodes.Count>0) then begin
    for i:=0 to hypernode.childnodes.count-1 do begin
      n:=hypernode.ChildNodes[i].Attributes['n'];
      if pos('.',n) > 0 then
      begin
        delete(n,1,pos('.',n));
      end;
      v:=vartostr(hypernode.ChildNodes[i].Attributes['v']);
      if copy(v,1,1) = ':' then begin
        delete(v,1,1);
        v:=hparser.getvarvalue(v);
        if hparser.lastvartype='' then t:='c' else t:=hparser.lastvartype[1];
      end else begin
        if copy(v,1,1) = '{' then begin
          if copy(v, Length(v)-2,3) = '*d}' then begin
            v := copy(v,2,length(v)-4);
            t := 'd'
          end else begin
            v := copy(v,2,length(v)-2);
            t := 'c'
          end;
        end else t := 'n';
      end;
      hparser.registervar(n,Char(t[1]),v);
    end;
  end;
end;

procedure TDesktop.FillParamValues(n:ixmlnode);
var i:integer;
    v:string;
begin
  if not assigned(n) then exit;
  if not assigned(hparser) then exit;
  for i:=0 to n.childnodes.count-1 do begin
    v:=vartostr(n.ChildNodes[i].Attributes['v']);
    if copy(v,1,1) = ':' then begin
      delete(v,1,1);
      n.ChildNodes[i].Attributes['v']:=hparser.getvarvalue(v);
    end else begin
      if copy(v,1,1) = '{' then begin
         if copy(v, Length(v)-2,3) = '*d}' then begin
          v := copy(v,2,length(v)-4);
        end else
          v := copy(v,2,length(v)-2);
      end;
      n.ChildNodes[i].Attributes['v']:=v;
    end;
  end;
end;

procedure TDesktop.AddCalender;
var s:string;
    axcal : TfrmCalender;
begin
  if (fdesign.infocus.tag<>tagDtopContainer) then exit;
//  axcal:= TfrmCalender(fdesign.infocus);
  if not assigned(axcal) then begin
    axcal := TfrmCalender(TfrmCalender.create(fdesign.infocus));
    axcal.Parent := TPanel(fdesign.infocus);
    axcal.AxProvider := axp;
    axcal.Align := alClient;
    if calUserid = '' then
       axcal.Userid := '0'
    else
       axcal.Userid := '0';
    axcal.teamid := '';
    axcal.wDeskTop := self ;
    axcal.calDate := calDate;
    axCal.calType := calType;
    axcal.calpos := calpos;
    axcal.SpeedButton2.Visible := True;
  end ;
  s:='axpcal';
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then
    xnode:=inode.AddChild(s);
  xnode.Attributes['cat']:='cal';
  xnode.Attributes['name']:='axpcal';
  xnode.Attributes['parent']:=fdesign.infocus.name;
end;

procedure TDesktop.AddTCalender;
var s:string;
    axcal : TfrmCalender;
begin
  if (fdesign.infocus.tag<>tagDtopContainer) then exit;
//  axcal:= TfrmCalender(fdesign.infocus);
  if not assigned(axcal) then begin
    axcal := TfrmCalender(TfrmCalender.create(fdesign.infocus));
    axcal.Parent := TPanel(fdesign.infocus);
    axcal.AxProvider := axp;
    axcal.Align := alClient;
    if calUserid = '' then
       axcal.Userid := '0'
    else
       axcal.Userid := '0';
    axcal.teamid := '';
    axcal.wDeskTop := self ;
    axcal.calDate := calDate;
    axCal.calType := calType;
    axcal.calpos := calpos;
    axcal.SpeedButton2.Visible := True;
  end ;
  s:='axpcal';
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then
    xnode:=inode.AddChild(s);
  xnode.Attributes['cat']:='teamcal';
  xnode.Attributes['name']:='axpcal';
  xnode.Attributes['parent']:=fdesign.infocus.name;
end;

procedure TDesktop.LoadCal(n:ixmlnode;cat:string);
var axcal : TfrmCalender;
    pnl : TPanel;
    sql , sql1,sql2, userid , teamid : string ;
    i , j: integer ;
    wDataNode , dNode , n1 , n2: IXMLNode;
begin
  if build then
  begin
    pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
    clearcontainer(pnl);
    axcal:= TfrmCalender(pnl.FindChildControl(n.NodeName));
    if not assigned(axcal) then
    begin
      axcal := TfrmCalender(TfrmCalender.create(pnl));
      axcal.Parent := pnl;
      axcal.AxProvider := axp;
      axcal.Align := alClient;
      if calUserid = '' then
         axcal.Userid := '0'
      else
         axcal.Userid := '0';
      axcal.teamid := '';
      axcal.wDeskTop := self ;
      axcal.calDate := calDate;
      axCal.calType := calType;
      axcal.calpos := calpos;
    end;
    axcal.SpeedButton2.Visible := True;
    axcal.n := n;
    exit;
  end;
  wDataNode := nil ;dNode := nil;
  try
    if n.ChildNodes.Count > 0 then
    begin
      n1 := n.ChildNodes.FindNode('sql');
      for i := 0 to n1.ChildNodes.Count - 1 do
      begin
        n2 := n1.ChildNodes[i];
        if n2 <> nil then
        begin
        //  sql := 'select unameid , teamname from uname where username = :u';
           if i = 0 then sql1 := vartostr(n2.NodeValue);
           if i = 1 then sql2 := vartostr(n2.NodeValue);
        end;
      end;
    end;
    if sql1 <> '' then
    begin
  //    sql := 'select unameid , teamname from uname where username = :u';
  //    sql := 'select unameid, uname from uname where teamname = :u';
      wDataNode := axp.ExecSql(sql1,axp.dbm.gf.username,'c',True).DocumentElement;
      dNode := wDataNode.ChildNodes.FindNode('data');
      if dNode.ChildNodes.Count = 0 then
      begin
        showmessage('Calender UserID not found.... '+n.nodename);
        exit;
      end;
      dNode := dNode.ChildNodes[0];
      userid := vartostr(dNode.ChildValues['UNAMEID']);
      teamid := vartostr(dNode.ChildValues['TEAMNAME']);
    end
    else begin
      userid := '0';
      teamid := '0';
    end;
  except on e:exception do
    begin
      if assigned(axp) then  axp.dbm.gf.DoDebug.Log(axp.dbm.gf.Axp_logstr+'\uDeskTop\LoadCal - '+e.Message);
      userid := '0';
      teamid := '0';
    end;
  end;
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if not assigned(pnl) then begin
    showmessage('Unable to find parent container to load '+n.nodename);
    exit;
  end;
  clearcontainer(pnl);
  axcal:= TfrmCalender(pnl.FindChildControl(n.NodeName));
  if not assigned(axcal) then begin
    axcal := TfrmCalender(TfrmCalender.create(pnl));
    axcal.Parent := pnl;
    axcal.AxProvider := axp;
    axcal.Align := alClient;
    if calUserid = '' then
       axcal.Userid := userid
    else
       axcal.Userid := calUserId;
    axcal.teamid := teamid;
    axcal.wDeskTop := self ;
    axcal.calDate := calDate;
    axCal.calType := calType;
    axcal.calpos := calpos;
  end
  else begin
    axcal.calDate := calDate;
    axCal.calType := calType;
    axcal.calpos := calpos;
  end;
  if cat = 'teamcal' then
  begin
    wDataNode := nil ;dNode := nil;
    axCal.cbTeam.Visible := True;
    axCal.Label2.Visible := True;
    axCal.sbGo.Visible := True;
    axCal.cbTeam.Items.Add('') ;
//    sql := 'select doctorid unameid, uname from doctor where teamname = :u';
    if (teamid <> '') and (teamid <> '0') then
    begin
      wDataNode := axp.ExecSql(sql2,teamid,'c',True).DocumentElement;
      dNode := wDataNode.ChildNodes.FindNode('data');
    end;
    if assigned(dnode) then
    begin
      for i := 0 to dNode.ChildNodes.Count - 1 do
      begin
          n1 := dNode.ChildNodes[i];
          axCal.cbTeam.Items.Add(n1.ChildValues['UNAME']) ;
      end;
    end;
    axCal.sql1 := sql1;
    axCal.sql2 := sql2;
    if calUserName = '' then
      axCal.cbTeam.ItemIndex := axCal.cbTeam.Items.IndexOf(axp.dbm.gf.username)
    else
      axCal.cbTeam.ItemIndex := axCal.cbTeam.Items.IndexOf(calUserName)
  end;
  axcal.init;
  calDate := '';
  calType := '';
  calUserName := '';
  calUserId := '';
  calPos := 0;
end;


function TDeskTop.IsGraphicControl(sender:TObject):boolean;
var classref:TClass;
begin
  result:=false;
  ClassRef := Sender.ClassType;
  while ClassRef <> nil do
  begin
    if ClassRef=TGraphicControl then begin
      result:=true;
      break;
    end;
    ClassRef := ClassRef.ClassParent;
  end;
end;

function TDeskTop.Getaction(f: TFrame): TDoAction;
var n:string;
    j:integer;
begin
  result:=nil;
  for j:=0 to options.count-1 do begin
    if f=pOpt(options[j]).frame then begin
      result:=pOpt(options[j]).act;
      break;
    end;
  end;
end;

function TDeskTop.Showtstruct(pname, container: string; hn,
  pv: ixmlnode): pointer;
var oldhnode, oldpvalue:ixmlnode;
begin
  hypernode:=hn;
  paramvalues:=pv;
  LoadNewPage := False ;
  if container = '' then container := 'pop';
  result:=showtstruct(pname, container);
  hypernode := oldhnode ;
  paramvalues := oldpvalue ;
end;

procedure TDeskTop.loaddata(pInp : TInputFrame; hnode: ixmlnode);
var oldhnode, oldpvalue:ixmlnode;
begin
  hypernode:=hnode;
  loaddata(pInp);
  hypernode := oldhnode ;
end;

function TDeskTop.ShowIview(pname, container: string; hp: TProfitEval): pointer;
var ohp:TProfitEval;
begin
  ohp:=hparser;
  hparser:=TProfitEval.create(axp);
  hparser.Assign(hp);
  LoadNewPage := False ;
  if container = '' then container := 'pop';
  result:=showiview(pname, container);
  hparser := nil;
  hparser:=ohp;
end;

function TDeskTop.GetRelations(tname:String):TStringList;
var i,j  : Integer;
    cnode : ixmlnode;
    mstruct,autorefresh, v: String;
begin
  result := nil;
  if not assigned(relations) then exit;
  mstruct:='t'+tname;
  result := TStringList.Create;
  for i:=0 to relations.ChildNodes.Count-1 do begin
    cnode:=relations.ChildNodes[i];
    autorefresh := lowercase(vartostr(cnode.Attributes['autorefrsh']));
    if autorefresh = 'true' then break;
  end;
  if autorefresh = 'true' then begin
    for i:=0 to relations.ChildNodes.Count-1 do begin
      cnode:=relations.ChildNodes[i];
      if vartostr(cnode.attributes['master']) <> mstruct then continue;
      for j := 0 to cnode.ChildNodes.Count-1 do begin
        v := vartostr(cnode.ChildNodes[j].Attributes['v']);
        if copy(v,1,1) = ':' then
          delete(v,1,1);
        result.Add(v);
      end;
    end;
  end;
  cnode := nil;
end;

function TDeskTop.GetCompName(compnode:ixmlnode;cstr:String):String;
var i : Integer;
    n : ixmlnode;
    tsk : String;
begin
  result := '';
  for i := 0 to compnode.ChildNodes.Count-1 do begin
    n := compnode.ChildNodes[i];
    if n.Attributes['cat'] <> 'btn' then continue;
    tsk := Trim(vartostr(n.Attributes['task']));
    if tsk = '' then
      tsk := Trim(vartostr(n.Attributes['action']));
    if tsk = '' then continue;
    if lowercase(axp.dbm.gf.RemoveSpace(tsk)) = lowercase(cstr) then
      result := n.NodeName;
  end;
end;

procedure TDeskTop.PageRefresh;
var i, LastRow, LastCol:integer;
begin
  if build then exit;
  for i:=0 to options.count-1 do begin
    if not inpage(pOpt(options[i]).frame) then continue;
    if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
    begin
      TViewFrame(pOpt(options[i]).frame).MouseClick := False;
      TViewFrame(pOpt(options[i]).frame).Sort_Direction := '';
      TViewFrame(pOpt(options[i]).frame).x__sg.Cursor := crHourGlass;
      TViewFrame(pOpt(options[i]).frame).iview.displayParamWin := false;
      TViewFrame(pOpt(options[i]).frame).iview.PaginationParamsGiven := true;
      axp.dbm.gf.pagination_pageno := 1;
      LastRow := TViewFrame(pOpt(options[i]).frame).x__sg.Row;
      LastCol := TViewFrame(pOpt(options[i]).frame).x__sg.Col;
      TViewFrame(pOpt(options[i]).frame).iview.ExecuteQuery;
      TViewFrame(pOpt(options[i]).frame).ShowTotalRecBar;
      TViewFrame(pOpt(options[i]).frame).stbar.Visible := false;
     // TViewFrame(pOpt(options[i]).frame).recPanel.Visible := false;//true;//pon
      TViewFrame(pOpt(options[i]).frame).recPanel.Visible :=true;//  by ar
      if (TViewFrame(pOpt(options[i]).frame).iview.pivot>-1) then
      begin
        TViewFrame(pOpt(options[i]).frame).iview.rfixedrow := 2;
        TViewFrame(pOpt(options[i]).frame).CreateGroupHeading;
      end;
      TViewFrame(pOpt(options[i]).frame).x__sg.Cursor := crDefault;
      axp.dbm.gf.pagination_pageno := 0;
      if TViewFrame(pOpt(options[i]).frame).FocusActiveRowOnRefresh then
      begin
        if LastRow > TViewFrame(pOpt(options[i]).frame).x__sg.RowCount-2 then
           LastRow := TViewFrame(pOpt(options[i]).frame).x__sg.RowCount-2;
        TViewFrame(pOpt(options[i]).frame).x__sg.Row := LastRow;
        TViewFrame(pOpt(options[i]).frame).x__sg.Col := LastCol;
      end;
    end;
  end;
end;


procedure TDeskTop.ComboOnChange(Sender : TObject);
  var n,v : string;
  i : integer;
begin
   n := TComboBox(Sender).Name;
   v := TComboBox(Sender).Text;
   if assigned(hparser) then hparser.registervar(n,'c',v);
   for i:=0 to options.count-1 do begin
      if not inpage(pOpt(options[i]).frame) then continue;
      if (TObject(pOpt(options[i]).frame).ClassType=TViewFrame) then
      begin
        TViewFrame(pOpt(options[i]).frame).iview.parser.RegisterVar(n,'c',v);
      end;
   end;
   if TComboBox(Sender).Hint = 'auto' then PageRefresh;
end;

function TDeskTop.ListViewExist(sname:String):boolean;
var lv : TXDS;
begin
  lv := axp.dbm.GetXDS(nil);
  lv.buffered := True;
  lv.CDS.CommandText := 'select name from lviews where name ='+quotedstr(sname);
  lv.open;
  if lv.cds.IsEmpty then result := False
  else result := True;
  lv.close; lv := nil;
end;
procedure TDeskTop.SetFontDetails(sender:TObject);
begin
  if not assigned(screen.ActiveForm) then exit;
  screen.ActiveForm.Font.Charset := axp.dbm.gf.GetCharacterSet(axp.dbm.gf.appfontcharset);
  screen.ActiveForm.Font.Name := axp.dbm.gf.appfontname;
  if axp.dbm.gf.appfontsize > 0 then
    screen.activeform.font.Size := axp.dbm.gf.appfontsize;
end;

procedure TDeskTop.GetFontCDS(sname : string ; fcds : TXDS);
begin
  if Trim(axp.dbm.gf.AppFontCharSet) <> '' then
  begin
    fcds.close;
    fCDS.CDS.CommandText := 'select compname,compcaption,comphint,fontname,fontsize from axlanguage where '+axp.dbm.gf.sqllower+'(sname)= '+quotedstr(lowercase(sname))+ ' and ' + axp.dbm.gf.sqllower +'(lngname) = ' + quotedstr(lowercase(axp.dbm.gf.AppFontCharSet));
    fCDS.open;
    if not fcds.CDS.IsEmpty then begin
      axp.dbm.gf.AppFontName := fCDS.CDS.fieldbyname('fontname').AsString;
      axp.dbm.gf.AppFontSize := fCDS.CDS.fieldbyname('fontsize').AsInteger;
    end;
  end;
end;

procedure TDeskTop.getIViewCDS;
begin
   IViewCDS.CDS.CommandText := 'select name,caption from iviews where blobno=1 and name in (SELECT SNAME FROM AXUSERACCESS WHERE RNAME IN ('+ axp.dbm.gf.inuserroles +') and stype = ' + quotedstr('i') +' )';
   IViewCDS.open;
end;

procedure TDeskTop.getTStructCDS;
begin
   tStructCDS.CDS.CommandText := 'select name,caption from tstructs where blobno=1 and name in (SELECT SNAME FROM AXUSERACCESS WHERE RNAME IN ('+ axp.dbm.gf.inuserroles +') and stype = ' + quotedstr('t') +' )';
   tStructCDS.open;
end;

function TDeskTop.GetAccessControlXML(stable,stype,sname : string) : ixmldocument;
  var i : integer;
  optname,s,w,r,rt,Errstr : string;
  found : boolean;
  n : ixmlnode;
  Qxds : TXDS;
begin
   result := loadxmldata('<root></root>');
   found := false;
   Qxds := nil;
   Errstr := '';
   try
     try
       Qxds := axp.dbm.GetXDS(nil);
       Qxds.buffered := true;
       if stype = 't' then
          optName := 'tstruct__'+sname
       else if stype = 'i' then
          optName := 'view__'+sname  ;
       for i := 0 to  options.Count - 1 do
       begin
          if Popt(options[i]).Name = OptName then
          begin
            result := Popt(options[i]).axml;
            found := true;
            break;
          end;
       end;
       if found then raise exception.Create('');
       i := 1;
       r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
       while r<>'' do
       begin
         s:=axp.dbm.gf.startpath+'temp\xmlmemo'+axp.dbm.gf.getnumber;
         if stype = 't' then
            w:=axp.dbm.gf.sqllower+'(rname)='+lowercase(quotedstr(r)) + ' and ' + axp.dbm.gf.sqllower + '(sname)=' + lowercase(quotedstr(sname)) + ' and stype = ' + quotedstr('t')
         else if stype = 'i' then
            w:=axp.dbm.gf.sqllower+'(rname)='+lowercase(quotedstr(r)) + ' and ' + axp.dbm.gf.sqllower + '(sname)=' + lowercase(quotedstr(sname)) + ' and stype = ' + quotedstr('i')
         else if stype = 'l' then
            w:=axp.dbm.gf.sqllower+'(rname)='+lowercase(quotedstr(r)) + ' and ' + axp.dbm.gf.sqllower + '(sname)=' + lowercase(quotedstr(sname)) + ' and stype = ' + quotedstr('l')
         else
            w:=axp.dbm.gf.sqllower+'(rname)='+lowercase(quotedstr(r)) + ' and ' + axp.dbm.gf.sqllower + '(sname)=' + lowercase(quotedstr(sname)) + ' and stype = ' + quotedstr('t')  ;
         rt := 't'+inttostr(i);
         if axp.dbm.gf.remoteLogin then
         begin
           s := axp.RemoteReadMemo('props', 'axuseraccess', w) ;
           axp.DownLoadFile('axpert\'+axp.dbm.gf.sessionid+'\'+s,axp.dbm.gf.startpath+'temp\'+s);
           s := axp.dbm.gf.startpath+'temp\'+s ;
         end
         else begin
           Qxds.CDS.CommandText := 'select Props from axuseraccess where '+w;
           Qxds.Open;
           if (Qxds.CDS.RecordCount <= 0) then begin
              if stype = 't' then begin
                n := result.DocumentElement.AddChild(rt);
                n := n.AddChild('root');
                n.Attributes['deny'] := 'y';
              end;
           end
           else begin
             if Trim(Qxds.CDS.fieldbyname('props').AsString) = '' then begin
                if stype = 't' then begin
                  n := result.DocumentElement.AddChild(rt);
                  n := n.AddChild('root');
                end;
             end
             else begin
                if (Qxds.CDS.RecordCount = 1) then
                  accxml:=Loadxmldata(trim(Qxds.CDS.fieldbyname('props').AsString))
                else begin
                  axp.dbm.ReadMemo('props', 'axuseraccess', w, s);
                  with tstringlist.create do begin
                    loadfromfile(s);
                    accxml:=Loadxmldata(text);
                    deletefile(s);
                    Free;
                  end;
                end;
               n := result.DocumentElement.AddChild(rt);
               n.ChildNodes.Add(accxml.DocumentElement.CloneNode(True));
             end;
           end;
         end;
         Qxds.close;
         inc(i);
         r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
       end;
       if (stype = 'i') or (stype = 'l') then
       begin
          result :=  CreateAccessControlXML(result) ;
       end;
     Except on E:Exception do
       Errstr := e.message;
     End;
   finally
      if Assigned(Qxds) then begin
        Qxds.close;
        Qxds.Free;
        Qxds := nil;
      end;
   end;
   if Errstr <> '' then begin
     raise Exception.create(Errstr);
   end;
end;

function TDeskTop.CreateAccessControlXML(cxml : ixmldocument) : ixmldocument ;
var i,j:integer;
    s : string ;
    n,n1,n2 : ixmlnode;
begin
  result := loadxmldata('<root></root>');
  if assigned(cxml) and (cxml.DocumentElement.ChildNodes.Count > 0) then
  begin
     for i := 0 to cxml.DocumentElement.ChildNodes.Count - 1 do
     begin
        n :=  cxml.DocumentElement.ChildNodes[i].ChildNodes[0];
        if i = 0 then
        begin
           for j := 0 to n.ChildNodes.Count - 1 do
              result.DocumentElement.ChildNodes.Add(n.ChildNodes[j]);
        end else
        begin
           for j := 0 to n.ChildNodes.Count - 1 do
           begin
             n1 := n.ChildNodes[j].ChildNodes[0];
             s := vartostr(n1.NodeName);
             n2 := result.DocumentElement.ChildNodes[0];
             if n2 <> nil then n2 := n2.ChildNodes.FindNode(s);
             if n2 = nil then result.DocumentElement.ChildNodes[0].ChildNodes.Add(n1)
             else begin
                if vartostr(n1.Attributes['a']) = 'h' then
                   n2.Attributes['a'] := 'h';
             end;
           end;
        end;
     end;
  end;
end;

function TDeskTop.FillValueFromSql(sqltext : string) : TStringList;
  var x : TXDS;
  wXParams : ixmldocument;
  wp : ixmlnode;
  c,cc : integer;
  hp : TProfitEval;
  f,v,t,fv,s : string;
  i,j : integer;
begin
    result := TStringList.Create;
    x := Axp.dbm.GetXDS(nil);
    x.buffered := True;
    x.CDS.CommandText :=  sqltext;
    wXParams := axp.GetParam(sqltext);
    wp := wXParams.DocumentElement;
    c := wp.ChildNodes.Count;
    if c > 0 then
    begin
      fv := '';
      cc := 0;
      for j:=0 to options.count-1 do
      begin
        if c = cc then break;
        s := '';
        if not inpage(pOpt(options[j]).frame) then continue;
        s:=pOpt(options[j]).Name;
        if copy(s,1,9) = 'tstruct__' then
        begin
           delete(s,1,9);
           s := 't'+s
        end else if copy(s,1,6) = 'view__' then
        begin
          delete(s,1,6);
          s := 'i'+s;
        end;
        hp := Gethp(s);
        for i := 0 to wp.ChildNodes.Count - 1 do
        begin
           f := lowercase(wp.ChildNodes[i].NodeName);
           if pos(f,fv) > 0 then continue;
           v := hp.GetVarValue(f);
           if v <> '' then
           begin
              t := hp.LastVarType;
              x.AssignParam(i,v,t);
              fv := fv + f + ',';
              cc := cc + 1;
           end;
        end;
      end;
      if cc = 0 then
      begin
        hp := TProfitEval.Create(axp);
        for i := 0 to wp.ChildNodes.Count - 1 do
        begin
           f := lowercase(wp.ChildNodes[i].NodeName);
           v := hp.GetVarValue(f);
           t := hp.LastVarType;
           x.AssignParam(i,v,t);
        end;
        hp.Free;
      end;
    end;
    x.open;
    for i := 0 to x.CDS.RecordCount - 1  do
    begin
      result.Add(x.CDS.Fields[0].AsString);
      x.CDS.Next;
    end;
    x.close;
    x.Free;
end;

function TDeskTop.GetActionObj : TObject ;
  var actobj : TDoAction;
begin
  actobj:=TDoAction.Create;
  actobj.imglist := imglist;
  actobj.OnGetparser:=GetParser;
  actobj.OnAssignParser:=AssignParser;
  actobj.OnGetStructure:=GetStructure;
  actobj.OnGethparser:=Gethp;
  actobj.OnShowTStruct:=ShowTStruct;
  actobj.OnShowIView:=ShowIView;
  actobj.opendialog:=odialog;
  actobj.savedialog:=sdialog;
  actobj.ShowRelated:=ShowRelated;
  actobj.doLoadPage:=DoActionPageLoad;
  actobj.ParentRefresh := PageRefresh;
  actobj.OnLoadData:=LoadData;
  actobj.pb := pb;
  result := TObject(actobj);
end;

Procedure TDeskTop.RegisterIviewParamValues(vFrm:TViewFrame;sname:String);
var i : integer;
    vname,vtype,s,wParam,pval,pname : string;
begin
  if assigned(paramvalues) then begin
    for i:=0 to paramvalues.childnodes.count-1 do begin
      s := vartostr(paramvalues.ChildNodes[i].Attributes['n']);
      wParam := '';
      if pos('.',s) > 0 then
      begin
        vname := copy(s,1,pos('.',s)-1);
        if  sname = vname then wParam := copy(s,pos('.',s)+1,length(s)-pos('.',s));
      end
      else wParam := s;
      pname:= vartostr(paramvalues.ChildNodes[i].Attributes['v']);
      if copy(pname,1,1) = ':' then delete(pname,1,1);
      pval := vFrm.ParentParser.GetVarvalue(pname);
//      vtype := vartostr(paramvalues.ChildNodes[i].Attributes['vtype']);
      vtype :=vFrm.ParentParser.lastvartype;
      if vtype = '' then vtype := 'c';     //ch1
//      vFrm.ParentParser.RegisterVar(wParam,Char(vtype[1]),VarToStr(paramvalues.ChildNodes[i].Attributes['value']));
      vFrm.ParentParser.RegisterVar(wParam,Char(vtype[1]),pval);
    end;
  end;
end;

procedure TDeskTop.LoadForm(build : boolean; page:string);
var i,cpos:integer;
    newPage :TTreeNode;
    s, firstPage :string;
    img : TImage;
    n:ixmlnode;
    pnl : TPanel;
    aVerNo,eVerno : Extended;
begin
  axp.dbm.gf.appverno := '';
  xml:=axp.GetStructure('axprops', 'app', '','');
  n:=xml.DocumentElement;
  if xml.DocumentElement.HasAttribute('appverno') then
  begin
    axp.dbm.gf.appverno := vartostr(xml.DocumentElement.Attributes['appverno']);
    aVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.appverno);
    eVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.exeverno);
    if aVerNo < eVerNo then
    begin
      UpdateVersion ;
    end;
  end
  else begin
    aVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.appverno);
    eVerNo := axp.dbm.gf.GetNumericVerNo(axp.dbm.gf.exeverno);
    UpdateVersion ;
  end;
  {if aVerNo > eVerNo then
  begin
    if messagedlg('Application Version is lower than DB version!!!! Want to continue? ',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    begin
      showmessage('Please use application exe compatible with DB....');
      application.Terminate;
    end;
  end; }
  if n.ChildNodes.Count=0 then
  begin
    raise exception.Create('Application parameters are not correct....Can''t continue');
  end;
  hypernode:=nil;
  axp.dbm.gf.GlobalProps:=n.Childnodes[0];
  //Assigning form properties.
  SetFormFontProperties;
  fdesign.fontCDS := fontCDS;  // This is for language.
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('head');
  if assigned(tnode) then begin
    axp.dbm.gf.headcolor:=vartostr(tnode.attributes['color']);
    axp.dbm.gf.headfont:=vartostr(tnode.attributes['font']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('gridhead');
  if assigned(tnode) then begin
    axp.dbm.gf.gridheadcolor:=vartostr(tnode.attributes['color']);
    axp.dbm.gf.gridheadfont:=vartostr(tnode.attributes['font']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('gridrow');
  if assigned(tnode) then begin
    axp.dbm.gf.gridoddrowcolor:=vartostr(tnode.attributes['oddrowcolor']);
    axp.dbm.gf.gridevenrowcolor:=vartostr(tnode.attributes['evenrowcolor']);
  end;

  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('contaienr');
  if assigned(tnode) then begin
    axp.dbm.gf.containercolor:=vartostr(tnode.attributes['color']);
  end;
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('img');
  if assigned(tnode) then begin
    img := TImage(Parentform.FindComponent('img'));
    if vartostr(tnode.NodeValue) <> '' then
      axp.GetImage(vartostr(tnode.NodeValue), img);
  end;
  tnode:=axp.dbm.gf.GlobalProps.ChildNodes.FindNode('name');
  if assigned(tnode) then begin
//    cpos := pos(' - ',Parentform.Caption);
//    if  cpos> 0 then
//      Parentform.Caption := copy(Parentform.Caption,1,cpos-1);
    if vartostr(tnode.NodeValue) <> '' then
    begin
       // Parentform.Caption := Parentform.Caption+' - '+ vartostr(tnode.NodeValue);
       s := vartostr(tnode.NodeValue);
       s := axp.dbm.gf.FindAndReplace(s,'&','&&');
       pnl:=TPanel(Parentform.findcomponent('Panel6'));
       pnl.ParentFont := True;
       if assigned(pnl) then begin
         pnl.Caption := s;
         if vartostr(tnode.Attributes['fontname'])  <> '' then pnl.Font.Name := tnode.Attributes['fontname'];
         if vartostr(tnode.Attributes['fontsize'])  <> '' then pnl.Font.Size := strtoint(tnode.Attributes['fontsize']);
         if vartostr(tnode.Attributes['fontcolor']) <> '' then pnl.Font.Color := stringtocolor(tnode.Attributes['fontcolor']);
         if vartostr(tnode.Attributes['fontbold'])      = 'true' then pnl.Font.Style := pnl.Font.Style+[fsBold];
         if vartostr(tnode.Attributes['fontitalic'])    = 'true' then pnl.Font.Style := pnl.Font.Style+[fsItalic];
         if vartostr(tnode.Attributes['fontunderline']) = 'true' then pnl.Font.Style := pnl.Font.Style+[fsUnderline];
         if vartostr(tnode.Attributes['fontstrikeout']) = 'true' then pnl.Font.Style := pnl.Font.Style+[fsStrikeout];
       end;
    end;
  end;
  axp.dbm.gf.defbackcolor := '$00FDFEFF';
  pxml := axp.GetAllPages('axpages');
  tnode := axp.dbm.gf.globalprops.ChildNodes.FindNode('mail');
  if assigned(tnode) then begin
    axp.dbm.gf.MailHost := vartostr(tnode.ChildValues['host']);
    axp.dbm.gf.MailPort := vartostr(tnode.ChildValues['port']);
    axp.dbm.gf.MailUserId := vartostr(tnode.ChildValues['userid']);
    axp.dbm.gf.MailPassword := vartostr(tnode.ChildValues['password']);
//    MailFrom := vartostr(tnode.ChildValues['from']);
  end;
//  AccessRole(pages);
  if pos('default',axp.dbm.gf.userroles) = 0 then
  begin
    if not assigned(tstructCDS) then
    begin
      tstructCDS := axp.dbm.GetXDS(tstructCDS) ;
      tstructCDS.buffered := True;
    end;
    if not assigned(iviewCDS) then
    begin
      iviewCDS := axp.dbm.GetXDS(iviewCDS) ;
      iviewCDS.buffered := True;
    end;
    getIViewCDS;
    getTStructCDS;
  end;
end;
procedure TDeskTop.LoadPage(s:string;tbuild:boolean);
var i , j,cpos:integer;
    cat,cn,v,licMsg : string;
    found : boolean;
    stime : TDateTime;
begin
  stime := now;
  axp.dbm.gf.doDebug.Msg('>>Start Pageload Time - ' + inttostr(millisecondsbetween(now(),stime)) );
//  axp.checkLicence  ;
  licMsg := axp.lm.RTCheckLicence;
  if licMsg <> '' then
  begin
    showmessage(licMsg);
    Application.Terminate;
  end;
  if build and prev_sel_stem then begin
    ClearClient;
    prev_sel_stem := false;
  end;
  FreeAllPrList;
  if fPage = '' then exit;
  LoadNewPage := True;
  pb.StepIt;
  InitPageVars(s);
  pb.StepIt;
  if inode = nil then exit;
  lockwindowupdate(ClientPanel.Handle);
  axp.dbm.gf.pagination_pageno := 0;
  for i:=0 to inode.ChildNodes.Count-1 do begin
    pb.StepIt;
    xnode:=inode.ChildNodes[i];
    cat:=xnode.Attributes['cat'];
    if (assigned(act.varComps))and (vartostr(xnode.Attributes['runvar']) = 'yes')then
    begin
      found := false;
      cn := (vartostr(xnode.Attributes['parent'])+','+vartostr(xnode.Attributes['name'])) ;
      for j := 0 to act.varComps.Count - 1 do
      begin
         if cn = act.varComps.Strings[j] then
         begin
           found := true;
           break;
         end;
      end;
      if found = false then  act.varComps.Add(cn);
    end;
    if assigned(aowner.findcomponent(xnode.NodeName)) then continue;
    if tbuild and assigned(fdesign) then
      fdesign.ImageObj := ImageObj;
    if tbuild then begin
      if cat='cntr' then fdesign.loadcontainer(xnode)
      else if cat='tstruct' then loadtstruct(xnode,tbuild)
      else if cat='iview' then loadiview(xnode,tbuild)
      else if cat='cal' then loadcal(xnode,cat)
      else if cat = 'teamcal' then loadcal(xnode,cat)
      else if cat='tree' then loadtreestruct(xnode);
    end;      
  end;
 lockwindowupdate(0);
end;

procedure TDeskTop.LoadTStruct(n:ixmlnode;tbuild:boolean);
var pnl:TPanel;
begin
//  LoadNewPage := False;
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if not assigned(pnl) then
    showmessage('Unable to find parent container to load '+n.nodename)
  else begin
    if not tbuild then
      ShowTStruct(n.attributes['transid'], pnl.name)
    else begin
      EditStruct(n.attributes['transid'],'t',pnl.Name);        //ch1
    end
  end;
end;

procedure TDeskTop.LoadIView(n:ixmlnode;tbuild:boolean);
var pnl:TPanel;
    s:string;
begin
  pnl:=TPanel(ParentForm.FindComponent(vartostr(n.attributes['parent'])));
  if not assigned(pnl) then
    showmessage('Unable to find parent container to load '+vartostr(n.attributes['transid']))
  else begin
    s:=n.attributes['name'];
    GetRelated('i'+s);
    if not tbuild then
      ShowIView(s, pnl.name)
    else begin
      EditStruct(s,'i',pnl.Name);        //ch1
    end  
  end;
end;

function TDeskTop.LoadXml(Pagename,Pagecaption:string):IXmlDocument;
var cxml : IXmlDocument; cnode,Inode,snode :IXmlNode;
  cntr:string;
begin
  cxml := LoadXMLData('<root></root>');
  cnode:= cxml.DocumentElement;
  cnode.Attributes['name']    := 'CorePage';
  cnode.Attributes['caption'] := 'Core structure';
  cnode.Attributes['Layout']  := 'Default';
  cnode.Attributes['ConCount']:= 1;

  cntr :='Container'+IntToStr(GetLocalNum);
  inode := cnode.addchild(cntr);
  inode.Attributes['paged']  := 'false';
  inode.Attributes['align']  := 'Client';
  inode.Attributes['paged']  := 'false';
  inode.Attributes['caption']:= Pagecaption;
  inode.Attributes['cat']    := 'cntr';
  inode.Attributes['parent'] := 'ClientPanel';
  inode.Attributes['defpage']  := 'F';
  inode.Attributes['tlhw']  := '0,0,0,0';
  
  if (pgtype <> '') and (pgtype[1]='t') then
  begin
    inode.Attributes['st']:= 'tstruct__'+Pagename ;
    snode := cnode.AddChild('tstruct__'+Pagename);
    snode.Attributes['cat'] := 'tstruct';
    snode.Attributes['transid'] := PageName;
    snode.Attributes['parent'] := cntr;
    snode.Attributes['align']  := 'Client'; 
  end
  else if (pgtype <> '') and (pgtype[1]='i') then
  begin
    inode.Attributes['st']:= 'view__'+Pagename;
    snode := cnode.AddChild('view__'+Pagename);
    snode.Attributes['cat'] := 'iview';
    snode.Attributes['name'] := PageName;
    snode.Attributes['parent'] := cntr;
    snode.Attributes['align']  := 'Client';

  end
  else if (pgtype <> '') and (pgtype[1]='l') then
  begin
    inode.Attributes['st']:= 'lview__'+Pagename;
    snode := cnode.AddChild('lview__'+Pagename);
    snode.Attributes['cat'] := 'lview';
  end;
  result := cxml;
end;

function TDeskTop.GetCurrentStructure:TFrame;
var i:integer;
begin
  result := nil;
  for i:=0 to options.count-1 do begin
    if inpage(pOpt(options[i]).frame) then
       Result := pOpt(options[i]).frame;
  end;
end;

//Loading ApplicationManager
function TDesktop.LoadAppMgrXML:ixmldocument;
var sfile, tfile : string;
    FxmlDoc:IXMLDocument;
begin
  sfile := axp.dbm.gf.startpath+'Structures\'+axp.dbm.gf.AppName+'\'+'Axp__AppMgrPGE.axpages';
  tfile := axp.dbm.gf.startpath+'Structures\'+axp.dbm.gf.AppName+'\'+'Axp__AppMgrPGE.xml' ;
  if Not fileexists(sfile) then
     CopyAppMgrStructstoStructureDir;
  with TCompress.Create do begin
   decompressfile(sfile, tfile);
   destroy;
  end;
  if fileexists(tfile) then begin
    if axp.dbm.gf.MsSql_Unicode_Char = 'N' then begin
      FxmlDoc:=nil;
      FxmlDoc:=LoadXMLData('<root></root>');
      FxmlDoc.LoadFromFile(tfile);
      result:=FxmlDoc;
    end else begin
      if fileexists(tfile) then begin
        with tstringlist.create do begin
          loadfromfile(tfile);
          result := Loadxmldata(text);
          Free;
        end;
      end;
    end;
    deletefile(tfile);
    fpage := 'Axp__AppMgrPGE';
    fPageName := 'Application Manager';
  end;
end;

//checking for Application manager required files
Function TDesktop.CheckForAppMgrStructs:Boolean;
var
  ChkDir,ReqFiles,SearchFile : String;
  i : Integer;
begin
   ReqFiles := 'Axp__AppMgrMS.trn,Axp__AppMgrSS.trn,Axp__AppMgrIVW.ivw,Axp__AppMgrPGE.pge,Axp__AppMgrSQL.ivw,Axp__AppMgrMS.sql,Axp__AppMgrSS.sql';
   result := True;
   if lowercase(AxP.dbm.connection.dbtype) = 'oracle' then
      ChkDir := AxP.dbm.gf.startpath+'AxpStructs\Oracle\'
   else
      ChkDir := AxP.dbm.gf.startpath+'AxpStructs\Ms Sql\';
   i := 1;
   SearchFile := AxP.dbm.gf.GetNthString(ReqFiles,i);
   while SearchFile <> '' do begin
     SearchFile := ChkDir+ SearchFile;
     if Not FileExists(SearchFile) then begin
        result := false;
        Break;
     end;
     Inc(i);
     SearchFile := AxP.dbm.gf.GetNthString(ReqFiles,i);
   end;
end;

//Copying Application manager required structs to Strcuture folder
Procedure TDesktop.CopyAppMgrStructstoStructureDir;
var
  ChkDir,ReqFiles,CpyFile,SrcFilepath,targetfilepath,sfile,tfile,FExt,ExtFile : String;
  i : Integer;
  SqlStr : TStringList;
begin
   SqlStr := TSTringList.Create;
   ReqFiles := 'Axp__AppMgrMS.trn,Axp__AppMgrSS.trn,Axp__AppMgrIVW.ivw,Axp__AppMgrPGE.pge,Axp__AppMgrSQL.ivw';
   if lowercase(AxP.dbm.connection.dbtype) = 'oracle' then
      SrcFilePath := axp.dbm.gf.startpath+'AxpStructs\Oracle\'
   else
      SrcFilePath := AxP.dbm.gf.startpath+'AxpStructs\Ms Sql\';
   targetfilePath := axp.dbm.gf.startpath+'Structures\'+axp.dbm.gf.AppName+'\';
   i := 1;
   CpyFile := AxP.dbm.gf.GetNthString(ReqFiles,i);
   while CpyFile <> '' do begin
     sfile := SrcFilePath+CpyFile;
     FExt := lowercase(ExtractFileExt(CpyFile));
     if FExt = '.trn' then
        CpyFile := StringReplace(CpyFile,'.trn','.tstructs',[rfIgnoreCase])
     else if FExt = '.ivw' then
        CpyFile := StringReplace(CpyFile,'.ivw','.iviews',[rfIgnoreCase])
     else if FExt = '.pge' then
        CpyFile := StringReplace(CpyFile,'.pge','.axpages',[rfIgnoreCase]);
     tfile := targetfilePath+CpyFile;
     copyfile(Pchar(sfile),Pchar(tfile),false);
     Inc(i);
     CpyFile := AxP.dbm.gf.GetNthString(ReqFiles,i);
   end;
   if Not axp.TableFound('Axp__AppMgrMS1') then begin
      SqlStr.LoadFromFile(SrcFilePath+'Axp__AppMgrMS.sql');
      axp.ExecSQL(Trim(SqlStr.Text),'','',false);
   end;
   if Not axp.TableFound('Axp__AppMgrSS1') then begin
      SqlStr.LoadFromFile(SrcFilePath+'Axp__AppMgrSS.sql');
      axp.ExecSQL(Trim(SqlStr.Text),'','',false);
   end;
   if Assigned(SqlStr) then
      FreeAndNil(SqlStr);
end;


end.


