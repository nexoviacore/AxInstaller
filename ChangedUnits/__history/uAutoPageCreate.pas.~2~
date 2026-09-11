unit uAutoPageCreate;
{Copied from Ver 10.5/Asb}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DateUtils, Menus, XMLDoc, XMLIntf,
  uGeneralFunctions, uXDS, uAxProvider

  {$IFNDEF  ForService}
  {$IFNDEF  ForAxpManager}
   , uDeskTop
  {$ENDIF}
  {$ENDIF}
  ;

type
  TAutoPageCreate = class
  private
    pxml,tmpxml : IXMLDocument;
    inode,xnode : IXMLNode;

  {$IFNDEF  ForService}
    {$IFNDEF  ForAxpManager}
      dtop : TDeskTop;
    {$ENDIF}
  {$ENDIF}

    q : TXDS;
    procedure CreateTsructPage ;
    procedure CreateIViewPage;
    procedure SavetoUserAccess;
    procedure UpdatePageType;
    function GetLocalNum: integer;

  public
    Axp : TAxProvider;
    xml : IXMLDocument;
    enode,orgNode : IXMLNode;
    name , caption , stype , pname : string;
    dtopint : integer;
    dxml : IxmlDocument;
    InteractiveFlag : Boolean;
    ParentName : String;
    bSkipUserAccessDelOnWriteDef : Boolean;

    procedure SavePageXML;
    procedure RemoveUserAccess;
    constructor create;
    destructor destroy; override;
    procedure CreateDefaultPageForFormStore;
    function GetPageXML: IXMLDocument;

end;

implementation

{ TAutoPageCreate }

constructor TAutoPageCreate.create;
begin
  inherited;
  ParentName := '';
  pxml := LoadXMLData('<root></root>');
  tmpxml := LoadXMLData('<root></root>');
  inode := pxml.DocumentElement;
  InteractiveFlag := false;
end;

destructor TAutoPageCreate.destroy;
begin
  inherited;
end;

procedure TAutoPageCreate.SavePageXML ;
   var s,nm,cap,ordno,typ,sqlstring : string;
begin
    {$IFNDEF  ForService}
      {$IFNDEF  ForAxpManager}
        dtop := TDeskTop(dtopint);
      {$ENDIF}
    {$ENDIF}
    q:= Axp.dbm.GetXDS(nil);
    q.buffered := True;
    q.CDS.CommandText := 'select max(ordno) + 1 from axpages';
    q.open;
    ordno := q.CDS.FieldList[0].AsString;
    if Assigned(q) then q.close;
    q.buffered := True;
    q.CDS.CommandText := 'select * from axpages where caption='+ QuotedStr(caption);
    q.open;

    if ordno = '' then ordno := '1' ;
    if stype = 'tstruct' then
    begin
      CreateTsructPage ;
      //nm := 'ts_' + name ;
      nm := 'PageTs' + name ;
      typ := 't';
      if q.CDS.RecordCount=0 then
        cap := caption
      else
        cap := caption + '_' + ordno;
    end
    else
    begin
      CreateIviewPage ;
      //nm := 'iv_' + name ;
      nm := 'PageIv' + name ;
      typ := 'i';
      if q.CDS.RecordCount=0 then
        cap := caption
      else
        cap := caption + '_' + ordno;
    end;
    pname := nm;
    SavetoUserAccess;
    pxml.DocumentElement.Attributes['visible'] := 'T';
    pxml.DocumentElement.Attributes['type'] := 'p';
    pxml.DocumentElement.Attributes['defpage']:= 'T';   // for default page identification.
    if ParentName <> '' then
      pxml.DocumentElement.Attributes['parent'] := ParentName;
    axp.SetStructure('axpages',nm,cap,pxml);
    UpdatePageType;
    if ParentName <> '' then
      axp.ExecSQL('update axpages set visible = ' + quotedstr('T') + ', type = ' + quotedstr('p')+', parent ='+QuotedStr(ParentName) + ' where name = ' + quotedstr(nm),'','',true)
    else
      axp.ExecSQL('update axpages set ordno =  ' + ordno + ', levelno = 0, visible = ' + quotedstr('T') + ', type = ' + quotedstr('p')+' where name = ' + quotedstr(nm),'','',true);
    s := axp.dbm.gf.startpath+'Structures\'+axp.dbm.gf.AppName+'\pageorder.axprops';
    if fileexists(s) then deletefile(s);
    axp.SetStructure('axprops','pageorder','pageorder',tmpxml);
    {$IFNDEF  ForService}
      {$IFNDEF  ForAxpManager}
        axp.SetStructure('axprops', 'app', '', dtop.xml);
      {$ENDIF}
    {$ELSE}
      axp.dbm.gf.AppXML.DocumentElement.ChildNodes.FindNode('props').Attributes['LocalNum'] := axp.dbm.gf.GlobalProps.Attributes['LocalNum'];
      axp.SetStructure('axprops', 'app', '', axp.dbm.gf.AppXML);
    {$ENDIF}
    q.close;
    q.destroy;
// inserting values to axpagedetail table

    sqlstring := 'insert into axpagedetail(name,sname,stype) values ('+quotedstr(Nm)+','+
                 Quotedstr(name)+','+Quotedstr(typ)+')';
    axp.ExecSQL(sqlstring,'','',false);
end;

procedure TAutoPageCreate.CreateTsructPage ;
var s,ts:string;
begin
  {$IFNDEF  ForService}
    {$IFNDEF  ForAxpManager}
      s := 'Container'+IntToStr(dtop.getlocalnum) ;
    {$ENDIF}
  {$ELSE}
    s :=  'Container'+IntToStr(getlocalnum) ;
  {$ENDIF}
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then begin
    xnode:=inode.AddChild(s);
    xnode.Attributes['paged']:='False';
    xnode.Attributes['align']:='Client';
    axp.dbm.gf.IcompChanged := True;
  end;
  xnode.Attributes['cat']:='cntr';
  xnode.Attributes['parent']:='ClientPanel';
  xnode.Attributes['defpage'] := 'T'; // for identifying default page.
//  SaveFont(pnl.Font, TPanel(pnl.Parent).Font, xnode);
  xnode.Attributes['tlhw']:=inttostr(0)+','+inttostr(0)+','+inttostr(0)+','+inttostr(0);
//  xnode.Attributes['color']:=colortostring(pnl.Color);
  ts := 'tstruct__'+name;
  xnode.Attributes['st'] := ts;
  xnode:=inode.ChildNodes.FindNode(ts);
  if not assigned(xnode) then
    xnode:=inode.AddChild(ts);
  xnode.Attributes['cat']:='tstruct';
  xnode.Attributes['transid']:=name;
  xnode.Attributes['parent']:=s;
  xnode.Attributes['align']:='Client';
end;

function TAutoPageCreate.GetLocalNum:integer;
begin
  if not axp.dbm.gf.GlobalProps.HasAttribute('LocalNum') then
    axp.dbm.gf.GlobalProps.Attributes['LocalNum']:=0;
  result:=strtoint(axp.dbm.gf.GlobalProps.attributes['LocalNum'])+1;
  axp.dbm.gf.GlobalProps.Attributes['LocalNum']:=inttostr(result);
end;

procedure TAutoPageCreate.CreateIViewPage ;
var s,ts:string;
begin
  s := 'Container'+IntToStr(getlocalnum) ;
  xnode:=inode.ChildNodes.FindNode(s);
  if not assigned(xnode) then begin
    xnode:=inode.AddChild(s);
    xnode.Attributes['paged']:='False';
    xnode.Attributes['align']:='Client';
    axp.dbm.gf.IcompChanged := True;
  end;
  xnode.Attributes['cat']:='cntr';
  xnode.Attributes['parent']:='ClientPanel';
  xnode.Attributes['defpage'] := 'T'; // for identifying default page.
//  SaveFont(pnl.Font, TPanel(pnl.Parent).Font, xnode);
  xnode.Attributes['tlhw']:=inttostr(0)+','+inttostr(0)+','+inttostr(0)+','+inttostr(0);
//  xnode.Attributes['color']:=colortostring(pnl.Color);
  ts := 'view__'+name;
  xnode.Attributes['st'] := ts;
  xnode:=inode.ChildNodes.FindNode(ts);
  if not assigned(xnode) then
    xnode:=inode.AddChild(ts);
  xnode.Attributes['cat']:='iview';
  xnode.Attributes['name']:=name;
  xnode.Attributes['parent']:=s;
  xnode.Attributes['align']:='Client';  
end;

procedure TAutoPageCreate.SavetoUserAccess;
var  i : integer;
    xQry : TXDS;
    r,sqltext,s : string;
    Errstr:string;
begin
  RemoveUserAccess;
  xQry := axp.dbm.GetXDS(nil);
  xQry.buffered := True;
  i := 1;

  (*
  SavetoUserAccess called from SavePageXML.
  UserAccess to the current structure for the login user role will be updated here,
  before appending data to the axuseraccess table, we are calling delete to clear axuseraccess data where the rname in login user roles.
  because the table will be updated again.
  if its new structure/ first timne save during that time also useracess should get updated.
  To keep that functional flow , we added below code , so it wont allow to create any duplicate records.

  if we check for role exists or not and then update then process may take time.due to that we deleted and updated.
  *)
  if bSkipUserAccessDelOnWriteDef and (axp.dbm.gf.userroles <> '') and (axp.dbm.gf.userroles <> 'default') then
  begin
     xQry.CDS.CommandText := 'delete from axuseraccess where stype = ''p'' and sname = ' + quotedstr(pName)+ ' and '+
      'rname in ('''+StringReplace(axp.dbm.gf.userroles,',',''',''',[rfReplaceAll])+''')';
     xQry.execsql;
  end;


  r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
  while r<>'' do
  begin
    if r = 'default' then
    begin
      inc(i);
      r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
      continue;
    end;
    try
      xQry.close;
      sqltext := 'insert into axuseraccess(rname,sname,stype,blobno) values (' + quotedstr(r) + ',' + quotedstr(pName) + ',' + quotedstr('p') + ',' + quotedstr('1') + ')';
      xQry.CDS.CommandText := sqlText;
      if axp.dbm.gf.remotelogin then
        xQry.open
      else
        xQry.execsql;
      axp.dbm.gf.doDebug.Msg('Firing SQL '+ sqltext+' <OK>');
      inc(i);
      r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
    Except on e:exception do
      begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uAutoPageCreate\SavetoUserAccess - '+e.Message;
          Axp.dbm.gf.DoDebug.Log(Errstr);
        end;
        s := 'Firing SQL '+ sqltext +' <error> '+E.Message ;
        axp.dbm.gf.doDebug.Msg('Firing SQL '+ sqltext +' <error> '+E.Message);
        inc(i);
        r := axp.dbm.gf.getnthstring(axp.dbm.gf.userroles,i);
      end;
    end;
  end;
  xQry.Free;
end;

procedure TAutoPageCreate.RemoveUserAccess;
var  xQry : TXDS;
     sqltext,s : string;
     Errstr:string;
begin
  xQry := axp.dbm.GetXDS(nil);
  xQry.buffered := True;
  try
   (*
   Clearing ALL the records from the axuseraccess table for the current structure is handled based on the
   boolean variable bSkipUserAccessDelOnWriteDef.
   if the call is from WriteDefinition the AxUserAccess table clear will not be called.

   This function called from two places (from uCreateStructre and in this SameObject)
   To handle in one place we added condition here. also Not to overwrite the existing functionality we used
   boolean var bSkipUserAccessDelOnWriteDef.
   *)
   if Not bSkipUserAccessDelOnWriteDef then
   begin
     xQry.CDS.CommandText := 'delete from axuseraccess where stype = ''p'' and sname = ' + quotedstr(pName);
     if axp.dbm.gf.remotelogin then
       xQry.open
     else
       xQry.execsql;
   end;
   xQry.CDS.CommandText := 'delete from axpages where name = ' + quotedstr(pName);
   if axp.dbm.gf.remotelogin then
     xQry.open
   else
     xQry.execsql;
   Except on e:exception do
      begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uAutoPageCreate\RemoveUserAccess - '+e.Message;
          Axp.dbm.gf.DoDebug.Log(Errstr);
        end;
        s := 'Firing SQL '+ sqltext +' <error> '+E.Message ;
        axp.dbm.gf.doDebug.Msg('Firing SQL '+ sqltext +' <error> '+E.Message);
      end;
   end;
   xQry.Free;
end;

procedure TAutoPageCreate.UpdatePageType;  // update the pagetype field in axpage table to be userd for web
var  containercount ,i : integer;
     st,sname ,sqlstring: string;
begin
  containercount := 0;
  enode := pxml.DocumentElement;
  sname := '';
  for i := 0 to enode.ChildNodes.Count-1 do
  begin
    if lowercase(vartostr(enode.ChildNodes[i].Attributes['cat']))='cntr' then begin
      st := vartostr(enode.ChildNodes[i].Attributes['st']);
      sname := trim(copy(st,pos('__',st)+2,length(st)));
      inc(containercount)
    end;
  end;
  if containercount > 1 then sname := 'stem'
  else
  begin
    if copy(st,1,pos('__',st)-1 ) = 'tstruct' then sname := 't' + sname
    else if (copy(st,1,pos('__',st)-1 ) = 'view') and (not InteractiveFlag) then sname := 'i' + sname
    else if (copy(st,1,pos('__',st)-1 ) = 'view') and (InteractiveFlag) then sname := 'n' + sname
    else if copy(st,1,pos('__',st)-1 ) = 'tree' then sname := 'r' + sname;
  end;
  sqlstring  := 'update axpages set pagetype='+quotedstr(sname)+ ' where name = '+quotedstr(vartostr(enode.Attributes['name']));
  axp.ExecSQL(sqlstring,'','',FALSE);
end;

procedure TAutoPageCreate.CreateDefaultPageForFormStore;
var s,nm,cap,ordno,hNo,typ,sqlstring : string;
begin
  q:= Axp.dbm.GetXDS(nil);
  q.buffered := True;
  q.CDS.CommandText := 'select max(ordno) + 1 from axpages';
  q.open;
  ordno := q.CDS.FieldList[0].AsString;
  if Assigned(q) then q.close;
  q.buffered := True;
  q.CDS.CommandText := 'select * from axpages where caption='+ QuotedStr(caption);
  q.open;
  if ordno = '' then ordno := '1' ;
  if stype = 'tstruct' then
  begin
    CreateTsructPage ;
    nm := 'PageTs' + name ;
    typ := 't';
    if q.CDS.RecordCount=0 then
      cap := caption
    else
      cap := caption + '_' + ordno;
  end
  else if stype = 'iview' then
  begin
    CreateIviewPage ;
    nm := 'PageIv' + name ;
    typ := 'i';
    if q.CDS.RecordCount=0 then
      cap := caption
    else
      cap := caption + '_' + ordno;
  end;
  pxml.DocumentElement.Attributes['visible'] := 'T';
  pxml.DocumentElement.Attributes['type'] := 'p';
  pxml.DocumentElement.Attributes['defpage']:= 'T';   // for default page identification.
  axp.SetStructure('axpages',nm,cap,pxml);
  UpdatePageType;
  axp.ExecSQL('update axpages set ordno =  ' + quotedstr(ordno) + ', visible = ' + quotedstr('T') + ', type = ' + quotedstr('p') + ' where name = ' + quotedstr(nm),'','',true);
  s := axp.dbm.gf.startpath+'Structures\'+axp.dbm.gf.AppName+'\pageorder.axprops';
  if fileexists(s) then deletefile(s);
  axp.SetStructure('axprops','pageorder','pageorder',tmpxml);

  {$IFNDEF  ForService}
    {$IFNDEF  ForAxpManager}
      axp.SetStructure('axprops', 'app', '', dtop.xml);
    {$ENDIF}
  {$ENDIF}
  q.close;
  q.destroy;
  // inserting values to axpagedetail table

  sqlstring := 'insert into axpagedetail(name,sname,stype) values ('+quotedstr(Nm)+','+
               Quotedstr(name)+','+Quotedstr(typ)+')';
  axp.ExecSQL(sqlstring,'','',false);
end;

Function TAutoPageCreate.GetPageXML:IXMLDocument;
begin
  result := pxml;
end;
end.
