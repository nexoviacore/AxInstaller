unit uStructInTable;
{copied from Ver 9.8\New Licensing Changes - 9.8latest\Fix2}
{Copied from Axpert9-XE3\Ver 9.90}
{Copied from Axpert9-XE3\Ver 11.1}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DateUtils, Menus, XMLDoc, XMLIntf,
  Grids, ComCtrls, Buttons,Ustructdef,UXDS,uaxprovider,upropsxml,
  uGeneralFunctions,  StrUtils, uGetDependencies;

type
  TstructInTable =class
  private
    axp : TAxprovider;sl,caps,purpose,post :Tstringlist;
    x,xl : TXds;
    f : TextFile;
    xml : IXMLDocument;xnode,inode,cnode : IXMLNode;
    procedure deleteexistdata(name: string);
  public
    sdef : Tstructdef;
    ErrMsg,getupdtime : String;
    StoreDepIntoTable: Boolean;
    constructor create(Axpro : TAxprovider);
    destructor destroy;override;
    procedure saveflds(name : string);
    function saveallstruct : String;
    procedure saveDC(name : string);
    procedure saveMDMaps(name:string);
    procedure saveGenmaps(name:string);
    procedure saveFillgrid(name:string);
    procedure Structwise(name: string);
    procedure SavePopDc(name: String;popgrid :pPopGrid);
    procedure SaveTStruct(name: string);
  end;

implementation


constructor TStructInTable.Create(Axpro :TAxprovider);
begin
  inherited create;
  axp     := axpro;
  sl      := Tstringlist.create;
  caps    := TStringList.Create;
  purpose := TStringlist.create;
  post    := TStringlist.create;
  x       := axp.dbm.GetXDS(nil);
  xl      := axp.dbm.GetXDS(nil);
  StoreDepIntoTable := False;
  ErrMsg  := '';
  getupdtime := '';
  AssignFile(f,'dataupd_'+axp.dbm.gf.sessionid+'.txt');
  Rewrite(f);
end;

destructor TStructInTable.Destroy;
begin
  FreeAndNil(sl);
  FreeAndNil(caps);
  FreeAndNil(purpose);
  FreeAndNil(post);
  x.Destroy; x := nil;
  xl.Destroy;xl := nil;
  closefile(f);
  inherited;
end;

procedure TStructInTable.SaveTStruct(name: string);
var s,cond, ErrStr :string;
    stm : TStringStream;
    n,cnode : ixmlnode;
    i : integer;
begin
  try
    inode := xnode.ChildNodes[0];
    x.close;
    writeln(f,' Updating TStruct :'+name);
    x.Append('AxpTStructs');
    x.Submit('tstruct',name,'c');
    x.Submit('caption',sdef.Caption,'c');
    x.Submit('SaveCtrlFld',sdef.savecontrol,'c');
    x.Submit('DelCtrlFld',sdef.delcontrol,'c');
    if sdef.attach then s := 'T' else s:='F';
    x.Submit('Attach',s,'c');
    x.Submit('SearchCond',Sdef.SearchCond,'c');
    if sdef.ListView then s := 'T' else s:='F';
    x.Submit('ListView',s,'c');
    x.Submit('SchemaName',Sdef.SchemaName,'c');
    if sdef.WorkFlow then s := 'T' else s:='F';
    x.Submit('WorkFlow',s,'c');
    if sdef.Traceability then s := 'T' else s:='F';
    x.Submit('Traceability',s,'c');
    if sdef.TrackAllFields then s := 'T' else s:='F';
    if sdef.track_chng then s := 'T' else s:='F';
    x.Submit('TrackChanges',s,'c');
    x.Submit('AllFlds',s,'c');
    x.Submit('TrackFlds',sdef.TrackFieldsList.CommaText,'c');
    n := inode.ChildNodes[xml_track];
    if vartostr(n.Attributes['ausers']) = 't' then s:='T' else s:='F';
    x.Submit('AllUsers',s,'c');
    cnode := n.ChildNodes.FindNode(xml_TrackUsers);
    s := '';
    if (cnode <> nil) then
    begin
      for i := 0 to cnode.ChildNodes.Count - 1 do
        s := s+','+vartostr(cnode.ChildNodes[i].NodeValue);
      Delete(s,1,1);
    end;
    x.Submit('TrackUsers',s,'c');

    if vartostr(n.Attributes['aflds']) = 't' then s:='T' else s:='F';
    x.Submit('AllFlds',s,'c');
    cnode := n.ChildNodes.FindNode(xml_TrackFields);
    s := '';
    if (cnode <> nil) then
    begin
      for i := 0 to cnode.ChildNodes.Count - 1 do
        s := s+','+vartostr(cnode.ChildNodes[i].NodeValue);
      Delete(s,1,1);
    end;
    x.Submit('TrackFlds',s,'c');
    x.Submit('UpdatedOn',getupdtime,'c');
    x.Post;
    n:= inode.Childnodes[xml_Purpose];
    purpose.clear;
    for i := 0 to n.ChildNodes.Count-1 do
       purpose.Add(vartostr(n.ChildNodes[i].NodeValue));
    if trim(purpose.text)<> ''  then begin
      s := purpose.Text;
      stm := TStringStream.Create(s);
      cond := 'tstruct='+quotedstr(name);
      x.WriteStream('purpose','AxpTstructs',cond, stm);
      stm.Free;
    end;
  except
    on e:exception do begin
      if assigned(Axp) then begin
        Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\savetstruct - '+e.Message;
        AxP.dbm.gf.DoDebug.Log(Errstr);
      end;
      Writeln(f,'Error in tstruct - ' + name+': '+e.Message);
      ErrMsg := e.Message;
    end;
  end;

end;


procedure TStructInTable.saveflds(name: string);
var i, j :integer;val,sql,sname:string;
    s,w,agstr :string;
    stm : TStringStream;
    Errstr:string;
begin
  xnode := sdef.XML.DocumentElement;
  for i := 0 to sdef.flds.count-1 do
  begin
    try
      x.close;
      sl.clear;
      inode := xnode.ChildNodes.FindNode(pfld(sdef.flds[i]).FieldName);
      sname := pfld(sdef.flds[i]).FieldName;
      writeln(f,' Updating Field :'+sname);
      x.Append('AxpFlds');
      x.Submit('tstruct',name,'c');
      x.Submit('Itype','Fields','c');
      x.Submit('Fname',pfld(sdef.flds[i]).FieldName,'c');
      x.Submit('caption',pfld(sdef.flds[i]).Caption,'c');
      x.Submit('datatype',pfld(sdef.flds[i]).DataType,'c');
      if pfld(sdef.flds[i]).DataType = 't' then
         x.Submit('datawidth','99999','n')
      else
         x.Submit('datawidth',Inttostr(pfld(sdef.flds[i]).Width),'n');
      x.Submit('modeofentry',pfld(sdef.flds[i]).ModeofEntry,'c');
      x.Submit('expression',pfld(sdef.flds[i]).cexp,'c');
      x.Submit('valexpr',pfld(sdef.flds[i]).cvalexp,'c');
      x.Submit('srcTf',pfld(sdef.flds[i]).Sourcetable,'c');
      x.Submit('srcFld',pfld(sdef.flds[i]).SourceField,'c');
      x.Submit('flddecimal',Inttostr(pfld(sdef.flds[i]).Dec),'n');
      x.Submit('dcname','dc'+Inttostr(pfld(sdef.flds[i]).FrameNo),'c');
      x.Submit('frmno',Inttostr(pfld(sdef.flds[i]).FrameNo),'n');
      if pfld(sdef.flds[i]).AsGrid then s:='T' else s:='F';
      x.Submit('AsGrid',s,'c');
      if pfld(sdef.flds[i]).Hidden then s:='T' else s:='F';
      x.Submit('Hidden',s,'c');
      if pfld(sdef.flds[i]).readonly then s:= 'T' else s:='F';
      x.Submit('readonly',s,'c');
      if pfld(sdef.flds[i]).SaveValue then s:='T' else s:='F';
      x.Submit('savevalue',s,'c');
      x.Submit('ordno',IntToStr(pfld(sdef.flds[i]).orderno),'n');
      x.Submit('customdatatype',pfld(sdef.flds[i]).CustType,'c');
      x.Submit('stype',pfld(sdef.flds[i]).SelType,'c');
      if pfld(sdef.flds[i]).Empty then s:= 'T' else s:='F';
      x.Submit('AllowEmpty',s,'c');
      if pfld(sdef.flds[i]).NoDuplicate then s:= 'F' else s:='T';
      x.Submit('AllowDuplicate',s,'c');
      if pfld(sdef.flds[i]).Tabstop then s:= 'T' else s:='F';
      x.Submit('TabStop',s,'c');
      if pfld(sdef.flds[i]).SetCarry then s:= 'T' else s:='F';
      x.Submit('SetCarry',s,'c');
      if pfld(sdef.flds[i]).ApplyComma then s:= 'T' else s:='F';
      x.Submit('ApplyComma',s,'c');
      if pfld(sdef.flds[i]).OnlyPositive then s:= 'T' else s:='F';
      x.Submit('OnlyPositive',s,'c');
      if pfld(sdef.flds[i]).ClientValidation then s:= 'T' else s:='F';
      x.Submit('ClientValidate',s,'c');
      x.Submit('Mask',pfld(sdef.flds[i]).Mask,'c');
      x.Submit('Pattern',pfld(sdef.flds[i]).Pattern,'c');
      x.Submit('Hint',pfld(sdef.flds[i]).Hint,'c');
      if pfld(sdef.flds[i]).pwchar = #0 then s := '' else s := pfld(sdef.flds[i]).pwchar;
      x.Submit('PWordChar',s,'c');
      if pfld(sdef.flds[i]).SourceKey then s:= 'T' else s:='F';
      x.Submit('SrcKey',s,'c');
      x.Submit('SgWidth',pfld(sdef.flds[i]).sgwidth,'c');
      x.Submit('SgHeight',IntToStr(pfld(sdef.flds[i]).sgheight),'n');
      x.Submit('CField',pfld(sdef.flds[i]).CField,'c');
      x.Submit('SrcTrans',pfld(sdef.flds[i]).SourceTransid,'c');
      x.Submit('SCol',InttoStr(pfld(sdef.flds[i]).searchcol),'c');
      if pfld(sdef.flds[i]).Autoselect then s:= 'T' else s:='F';
      x.Submit('AutoSelect',s,'c');
      x.Submit('LinkField',pfld(sdef.flds[i]).LinkField,'c');
      if pfld(sdef.flds[i]).Suggestive then s:= 'T' else s:='F';
      x.Submit('Suggestive',s,'c');
      x.Submit('CType',pfld(sdef.flds[i]).ComponentType,'c');
      x.Submit('DispType',pfld(sdef.flds[i]).Kind,'c');
      x.Submit('Sep',pfld(sdef.flds[i]).Separator,'c');
      x.Submit('Font',pfld(sdef.flds[i]).FontStr,'c');
      x.Submit('Color',pfld(sdef.flds[i]).ColorStr,'c');
      if pfld(sdef.flds[i]).Refresh then s:= 'T' else s:='F';
      x.Submit('RefreshOnSave',s,'c');
      if assigned(pfld(sdef.flds[i]).SearchSQL) then
        x.Submit('SearchSQL',pfld(sdef.flds[i]).SearchSQL.Text,'c');
      if assigned(pfld(sdef.flds[i]).displaydetail) then
        x.Submit('DispDet',pfld(sdef.flds[i]).displaydetail.Text,'c');
      x.Submit('TableName',pfld(sdef.flds[i]).Tablename,'c');
      x.Submit('runtimefld', VartoStr(inode.Attributes['runtimefld']),'c');
      x.Submit('applyrule', VartoStr(inode.Attributes['applyrule']),'c');
      s := '';
      if pfld(sdef.flds[i]).FromList then
      begin
         while not pfld(sdef.flds[i]).QSelect.CDS.Eof do
         begin
           s := s+'|'+ pfld(sdef.flds[i]).QSelect.CDS.Fields[0].AsString;
           pfld(sdef.flds[i]).QSelect.CDS.Next
         end;
         Delete(s,1,1);
      end;
      x.Submit('ListValues',s,'c');
      if lowercase(pfld(sdef.flds[i]).ModeofEntry)='autogenerate' then
      begin
//        inode := xnode.ChildNodes.FindNode(pfld(sdef.flds[i]).FieldName);
        if assigned(inode) then
        begin
          inode := inode.ChildNodes[xml_Details];
          inode := inode.ChildNodes[xml_Sequence];
          agstr := '';
          for j := 0 to inode.ChildNodes.Count-1 do
          begin
            cnode := inode.ChildNodes[j];
            s := VarToStr(cnode.ChildValues[xml_Prefix]);
            s := s+'|'+VarToStr(cnode.ChildValues[xml_PrefixField]);
            s := s+'|'+VarToStr(cnode.ChildValues[xml_Desc]);
            s := s+'|'+VarToStr(cnode.ChildValues[xml_StartNo]);
            s := s+'|'+VarToStr(cnode.ChildValues[xml_SActive]);
            s := s+'|'+VarToStr(cnode.ChildValues[xml_Digits]);
            agstr := agstr+'~#@~'+s;
          end;
          Delete(agstr,1,4);
          x.Submit('AutoGenDet',agstr,'c');
        end;
      end;
      inode:= inode.Childnodes[xml_Purpose];
      purpose.clear;
      for j := 0 to inode.ChildNodes.Count-1 do
         purpose.Add(vartostr(inode.ChildNodes[j].NodeValue));
      if trim(purpose.text)<> ''  then
        x.Submit('purpose',purpose.text,'c');
      x.Post;
      if assigned(pfld(sdef.flds[i]).Sql) then
         sl.text := pfld(sdef.flds[i]).Sql.text;
      if sl.text<> ''  then begin
        s := sl.Text;
        stm := TStringStream.Create(s);
        w := 'tstruct='+quotedstr(name)+'and FName='+quotedstr(pfld(sdef.flds[i]).FieldName);
        x.WriteStream('fldSQl','axpflds',w, stm);
        stm.Free;
      end;
     except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\saveflds - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        Writeln(f,'Error in - ' + sname+': '+e.Message);
        ErrMsg := e.Message;
        break;
      end;
    end;
  end;
end;

function TstructInTable.saveallstruct : String;
begin
  ErrMsg := '';
  xl.SqlText := 'select name,updatedon from tstructs';
  xl.open;
  while not xl.eof do
  begin
    getupdtime := xl.fieldbyname('updatedon').AsString;
    structwise(xl.fieldbyname('name').AsString);
    xl.next;
  end;
  if ErrMsg <> '' then
    Result := 'Error in data generation. Please refer ''dataupd.txt'' file.'
  else
    Result := 'Data generated successfully';
end;

//will save popgrid details in AxpPopDc table
procedure TstructInTable.SavePopDc(name: String;popgrid :pPopGrid);
var
  s,w :string;
  stm : TStringStream;
  Errstr:string;
begin
  xl.close;
  sl.clear;
  try
      xl.Append('AxpPopDc');
      xl.Submit('tstruct',name,'c');
      xl.Submit('frameno',Inttostr(popgrid.FrameNo),'n');
      xl.Submit('dcname','dc'+Inttostr(popgrid.FrameNo),'c');
      xl.Submit('parent',popgrid.Parent,'c');
      xl.Submit('parentfield',popgrid.ParentField,'c');
      xl.Submit('heading',popgrid.Heading,'c');
      xl.Submit('popcond',popgrid.Popcond,'c');
      xl.Submit('autoshow',ifthen(popgrid.AutoShow,'t','f'),'c');
      xl.Submit('firmbind',ifthen(popgrid.FirmBind,'t','f'),'c');
      xl.Submit('keycols',popgrid.keyCols,'c');
      xl.Submit('dispfield',popgrid.DispField,'c');
      xl.Submit('sumformat',popgrid.SumFormat,'c');
      xl.Submit('delimiter',popgrid.Delimiter,'c');
      xl.Submit('addrow',ifthen(popgrid.AutoFillFld,'t','f'),'c');
      xl.Submit('showbuttons',popgrid.ShowButtons,'c');
      xl.Post;
      if assigned(popgrid.AutoFill) then
         sl.text := popgrid.AutoFill.text;
      if sl.text<> ''  then begin
        s := sl.Text;
        stm := TStringStream.Create(s);
        w := 'tstruct='+quotedstr(name)+' and dcname='+quotedstr('dc'+Inttostr(popgrid.FrameNo));
        xl.WriteStream('autofill','AxpPopDc',w, stm);
        stm.Free;
      end;
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\SavePopDc - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        Writeln(f,'Error in - ' + name+': '+e.Message);
      end;
    end;
end;

procedure TstructInTable.Structwise(name :string);
var Errstr:string;
    deps : TGetDependencies;
begin
  try
    try
      if axp.dbm.InTransaction then axp.dbm.Commit(axp.dbm.gf.connectionname); // added because in AxpManager, there is a starttransaction
      axp.dbm.StartTransaction(axp.dbm.gf.connectionname);
      Writeln(f,'Updating tstruct ' + name);
      deleteexistdata(name);
      axp.dbm.Commit(axp.dbm.gf.connectionname);
      sdef := TStructdef.Create(axp,name,'','');
      xnode := sdef.XML.DocumentElement;
      deps := TGetDependencies.Create(axp,name,sdef.XML);
      deps.StoreInTable := True;

      axp.dbm.StartTransaction(axp.dbm.gf.connectionname);
      ErrMsg := '';
      SaveTStruct(name);
      if ErrMsg <> '' then
        raise Exception.Create('save tstruct - '+ ErrMsg);
      saveflds(name);
      if ErrMsg <> '' then
        raise Exception.Create('save fields - '+ ErrMsg);
      savedc(name);
      if ErrMsg <> '' then
        raise Exception.Create('save dc - '+ ErrMsg);
      savemdmaps(name);
      if ErrMsg <> '' then
        raise Exception.Create('save mdmaps - '+ ErrMsg);
      savegenmaps(name);
      if ErrMsg <> '' then
        raise Exception.Create('save genmaps - '+ ErrMsg);
      savefillgrid(name);
      if ErrMsg <> '' then
        raise Exception.Create('save fillgrids - '+ ErrMsg);
      deps.GetDependencies;
      if deps.ErrStr <> '' then
        raise Exception.Create('GetDependencies - '+ deps.ErrStr);
      axp.dbm.Commit(axp.dbm.gf.connectionname);
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\Structwise - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        if axp.dbm.InTransaction then axp.dbm.RollBack(axp.dbm.gf.connectionname);
        ErrMsg := 'Error in - ' + name+': '+e.Message;
        Writeln(f,ErrMsg);
      end;
    end;
  finally
     if assigned(sdef) then begin
      sdef.Free;
      sdef := nil;
     end;
     if assigned(deps) then
     begin
       deps.Destroy;
       deps := nil;
     end;
  end;
end;

procedure TstructInTable.saveDC(name :string);
var i, j:integer;sname, s :string;
  Errstr:string;
begin
  x.close;
  for i := 0 to sdef.frames.count-1 do
  begin
    try
      x.Append('AxpDc');
      x.Submit('tstruct',name,'c');
      x.Submit('Dname','dc'+Inttostr(pfrm(sdef.frames[i]).FrameNo),'c');
      sname := 'dc'+Inttostr(pfrm(sdef.frames[i]).FrameNo);
      Writeln(f,'  Updating DC: '+sname);
      x.Submit('Dcno',Inttostr(pfrm(sdef.frames[i]).FrameNo),'n');
      x.Submit('caption',pfrm(sdef.frames[i]).caption,'c');
      x.Submit('tablename',pfrm(sdef.frames[i]).TableName,'c');
      if pfrm(sdef.frames[i]).AsGrid then s:= 'T' else s:='F';
      x.Submit('asgrid',s,'c');
      if pfrm(sdef.frames[i]).AllowChange then s:='T' else s:='F';
      x.Submit('allowchange',s,'c');
      if pfrm(sdef.frames[i]).AllowEmpty then s:='T' else s:='F';
      x.Submit('allowempty',s,'c');
      if pfrm(sdef.frames[i]).AllowAddRow then s:='T' else s:='F';
      x.Submit('AddRow',s,'c');
      if pfrm(sdef.frames[i]).AllowDeleteRow then s:='T' else s:='F';
      x.Submit('DeleteRow',s,'c');
      if pfrm(sdef.frames[i]).popup then
      begin
         x.Submit('popup','T','c');
         SavePopDc(name,pPopgrid(sdef.popgrids[pfrm(sdef.frames[i]).PopIndex]));//will save popgrid details in axppopdc table
      end
      else x.Submit('popup','F','c');
      inode := xnode.ChildNodes.FindNode(sname);
      inode:= inode.Childnodes[xml_Purpose];
      purpose.clear;
      for j := 0 to inode.ChildNodes.Count-1 do
         purpose.Add(vartostr(inode.ChildNodes[j].NodeValue));
      if trim(purpose.text)<> ''  then
         x.Submit('purpose',purpose.text,'c');
      x.Post;
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\saveDC - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        Writeln(f,'Error in - ' + sname+': '+e.Message);
        ErrMsg := e.Message;
        break;
      end;
    end;
  end;
end;

procedure TStructIntable.saveMDMaps(name: string);
var i,z :integer;purnode : IXMlNode;
   s,w,mdmap,sname,pur :string;
  J: Integer;
  stm : TStringStream;
  Errstr:string;
begin
  xml :=sdef.XML;
  xnode := xml.DocumentElement;
  x.close;
  for I := 0 to xnode.ChildNodes.Count-1 do
  begin
    try
      inode := xnode.ChildNodes[i];
      if vartostr(inode.Attributes['cat']) <> 'mdmap' then continue;
      sl.clear;purpose.Clear;
      sname := vartostr(inode.NodeName);
      Writeln(f,'  Updating mdmap: '+sname);
      x.Append('axpmdmaps');
      x.Submit('tstruct',name,'c');
      x.Submit('mname',vartostr(inode.NodeName),'c');
      x.Submit('caption',vartostr(inode.ChildValues[xml_Caption]),'c');
      if vartostr(inode.ChildValues[xml_Extended]) = 'True' then
         x.Submit('extended','T','c')
      else
         x.Submit('extended','F','c');
      x.Submit('mastrans',vartostr(inode.ChildValues[xml_Master]),'c');
      x.Submit('masfld',vartostr(inode.ChildValues[xml_MField]),'c');
      x.Submit('detfld',vartostr(inode.ChildValues[xml_DField]),'c');
      x.Submit('msrcfld',vartostr(inode.ChildValues[xml_MSField]),'c');
      x.Submit('dtlsrcfld',vartostr(inode.ChildValues[xml_DSField]),'c');
      x.Submit('mastable',vartostr(inode.ChildValues[xml_MTable]),'c');
      x.Submit('updatetype',vartostr(inode.ChildValues[xml_Type]),'c');
      x.Submit('ctrlfield',vartostr(inode.ChildValues[xml_MDControl]),'c');
      x.Submit('masdec',vartostr(inode.ChildValues[xml_masterfielddec]),'n');
      if vartostr(inode.ChildValues[xml_Append]) = 'True' then      x.Submit('mdappend','T','c')
      else  x.Submit('mdappend','F','c');
      if vartostr(inode.ChildValues[xml_InitonDel]) = 'True' then    x.Submit('InitonDel','T','c')
      else  x.Submit('InitonDel','F','c');
      if vartostr(inode.ChildValues[xml_OnApprove]) = 'True' then
        x.Submit('onapprove','T','c')
      else
        x.Submit('onapprove','F','c');
      if vartostr(inode.ChildValues[xml_OnReject]) = 'True' then
        x.Submit('onreject','T','c')
      else
        x.Submit('onreject','F','c');
      x.post;
      purnode  := inode.Childnodes[xml_Purpose];
      purpose.clear;
      for z := 0 to purnode.ChildNodes.Count-1 do
         purpose.Add(vartostr(purnode.ChildNodes[z].NodeValue));
      if trim(purpose.text)<> ''  then begin
        s := purpose.Text;
      stm := TStringStream.Create(s);
      mdmap := 'tstruct='+quotedstr(name)+'and MName='+quotedstr(vartostr(inode.NodeName));
      x.WriteStream('purpose','axpmdmaps',mdmap, stm);
      stm.Free;
    end;
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\saveMDMaps - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        Writeln(f,'Error in - ' + sname+': '+e.Message);
        ErrMsg := e.Message;
        break;
      end;
    end;
    cnode := inode.ChildNodes.FindNode(xml_MapText);
    for j := 0 to cnode.ChildNodes.Count - 1 do
      sl.Add(vartostr(cnode.ChildNodes[j].NodeValue));
    if sl.text <> ''  then begin
      s := sl.Text;
      stm := TStringStream.Create(s);
      w := 'tstruct='+quotedstr(name)+' and mname ='+quotedstr(vartostr(inode.NodeName));
      x.Writestream('maptext','axpmdmaps',w, stm);
      stm.Free;
    end;
  end;
  xnode := nil;purnode := nil; inode := nil;cnode := nil;
end;

procedure TStructIntable.saveGenMaps(name: string);
var i :integer; s,w,gname,gmap :string; gxml : Ixmldocument;
  J,k,z: Integer;  gnode,postnode,purnode :IXMLNode;
  stm : TStringStream;
  Errstr:string;
begin
  xml := sdef.XML;
  xnode := xml.DocumentElement;
  for I := 0 to xnode.ChildNodes.Count-1 do
  begin
    try
      x.close;
      inode := xnode.ChildNodes[i];
      if vartostr(inode.Attributes['cat']) <> 'genmap' then continue;
      sl.clear;gname := '';purpose.clear;post.clear;
      gname := inode.ChildValues[xml_name];
      Writeln(f,'  Updating GenMap: '+gname);
      x.Append('axpgenmaps');
      x.Submit('tstruct',name,'c');
      x.Submit('gname',vartostr(inode.ChildValues[xml_name]),'c');
      x.Submit('caption',vartostr(inode.ChildValues[xml_Caption]),'c');
      x.Submit('axpschema',vartostr(inode.ChildValues[xml_GencField]),'c');
      x.Submit('basedondc',vartostr(inode.ChildValues[xml_Genparent]),'c');
      x.Submit('ctrlFldname',vartostr(inode.ChildValues[xml_gencontrol]),'c');
      x.Submit('Targettstr',vartostr(inode.ChildValues[xml_genTarget]),'c');
      if vartostr(inode.ChildValues[xml_Active]) = 'True' then
        x.Submit('active','T','c') else     x.Submit('active','F','c');
      if vartostr(inode.ChildValues[xml_OnApprove]) = 'True' then
        x.Submit('onapprove','T','c')    else
        x.Submit('onapprove','F','c');
      if vartostr(inode.ChildValues[xml_OnReject]) = 'True' then
        x.Submit('onreject','T','c')
      else
        x.Submit('onreject','F','c');
      x.post;
       purnode  := inode.Childnodes[xml_Purpose];
       purpose.clear;
       for z := 0 to purnode.ChildNodes.Count-1 do
           purpose.text := purpose.text +(vartostr(purnode.ChildNodes[z].NodeValue));
       postnode := inode.Childnodes[xml_onpost];
      if purpose.text<> ''  then begin
        s := purpose.Text;
        stm := TStringStream.Create(s);
        gmap := 'tstruct='+quotedstr(name)+'and GName='+quotedstr(vartostr(inode.NodeName));
        x.WriteStream('purpose','axpgenmaps',gmap, stm);
        stm.Free;
      end;
      post.clear;
      for z := 0 to postnode.ChildNodes.Count-1 do
        post.add(vartostr(postnode.ChildNodes[z].NodeValue));

      if post.text<> ''  then begin
        s := post.Text;
        stm := TStringStream.Create(s);
        gmap := 'tstruct='+quotedstr(name)+'and GName='+quotedstr(vartostr(inode.NodeName));
        x.WriteStream('onpost','axpgenmaps',gmap, stm);
        stm.Free;
      end;
      cnode := inode.ChildNodes.FindNode(xml_GMap);
      for j := 0 to cnode.ChildNodes.Count - 1 do
      begin
        gnode := cnode.childnodes[j];
        x.close;
        x.Append('axpgenmapdtl');
        x.Submit('tstruct',name,'c');
        x.Submit('gname',gname,'c');
        x.Submit('tarfld',vartostr(gnode.nodename),'c');
        x.Submit('srcfld',vartostr(gnode.nodevalue),'c');
        x.Submit('trow',vartostr(gnode.Attributes['trow']),'n');
        x.Submit('srow',vartostr(gnode.Attributes['srow']),'n');
        x.Submit('control',vartostr(gnode.Attributes['control']),'c');
        x.Submit('dgroup',vartostr(gnode.Attributes['group']),'c');
        x.Submit('dtype',vartostr(gnode.Attributes['type']),'c');
        x.Submit('field',vartostr(gnode.Attributes['field']),'c');
        x.Submit('dgroup',vartostr(gnode.Attributes['group']),'c');
        x.Submit('ord',vartostr(gnode.Attributes['ord']),'c');
        if (vartostr(gnode.Attributes['id']))='True' then
          x.Submit('id','T','c')
        else x.Submit('id','F','c');
        x.post;
      end;
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\saveGenMaps - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
        Writeln(f,'Error in - ' + gname+': '+e.Message);
        ErrMsg := e.Message;
        break;
      end;
    end;
  end;
  xnode := nil;inode := nil;gnode :=nil;
  postnode := nil;purnode := nil;
end;

procedure TstructInTable.saveFillgrid(name: string);
var i,j:integer; sql :tstringlist;
   stm : TStringStream;s,w,sname:string;
   Errstr:string;
begin
  xml := sdef.XML;
  xnode := xml.DocumentElement;
  for i := 0 to sdef.fgs.count-1 do
  begin
    try
      x.close;
      sl.Clear; caps.Clear;
      sname := pfg(sdef.fgs[i]).name;
      Writeln(f,'  Updating Fillgrid: '+sname);
      x.Append('Axpfillgrid');
      x.Submit('tstruct',name,'c');
      x.Submit('fgname',(pfg(sdef.fgs[i]).fname),'c');
      x.Submit('caption',pfg(sdef.fgs[i]).name,'c');
      if pfg(sdef.fgs[i]).FromIView then   x.Submit('fromiview','T','c')
      else x.Submit('fromiview','F','c');
      if pfg(sdef.fgs[i]).MultiSelect then   x.Submit('multiselect','T','c')
      else x.Submit('multiselect','F','c');
      if pfg(sdef.fgs[i]).AutoShow then   x.Submit('AutoShow','T','c')
      else x.Submit('AutoShow','F','c');
      if pfg(sdef.fgs[i]).ValidateRow then   x.Submit('validat','T','c')
      else x.Submit('validat','F','c');
      if pfg(sdef.fgs[i]).ExecuteOnSave then   x.Submit('ExeOnSave','T','c')
      else x.Submit('Exeonsave','F','c');
      if pfg(sdef.fgs[i]).firmbind then   x.Submit('firmbind','T','c')
      else x.Submit('firmbind','F','c');//Check this - in pcal this field was available for fillgrid,later it is not avialable 
      x.Submit('footer',pfg(sdef.fgs[i]).FooterStr,'c');
      x.Submit('valexpr',pfg(sdef.fgs[i]).VExp,'c');
      x.Submit('selecton',pfg(sdef.fgs[i]).SelectOn,'c');
      x.Submit('tardc',Inttostr(pfg(sdef.fgs[i]).TargetFrame),'c');
      x.Submit('srcdc',Inttostr(pfg(sdef.fgs[i]).SourceFrame),'c');
      x.Submit('addrows',inttostr(pfg(sdef.fgs[i]).Addrows),'c');
      x.Submit('GFld',pfg(sdef.fgs[i]).Groupfield,'c');
      x.Submit('PList',pfg(sdef.fgs[i]).ParamNames,'c');
      inode := xnode.ChildNodes.FindNode(pfg(sdef.fgs[i]).fname);
      inode:= inode.Childnodes[xml_Purpose];
      purpose.clear;
      for j := 0 to inode.ChildNodes.Count-1 do
         purpose.Add(vartostr(inode.ChildNodes[j].NodeValue));
      if trim(purpose.text) <> ''  then
        x.Submit('purpose',purpose.text,'c');
      x.post;
      w := 'tstruct='+quotedstr(name)+'and fgName='+quotedstr(pfg(sdef.fgs[i]).Name);
      if assigned(pfg(sdef.fgs[i]).q) and  assigned(pfg(sdef.fgs[i]).q.CDS) then begin
        sl.text := pfg(sdef.fgs[i]).q.CDS.CommandText;
        s := sl.Text;
        stm := TStringStream.Create(s);
        w := 'tstruct='+quotedstr(name)+'and fgName='+quotedstr(pfg(sdef.fgs[i]).Name);
        x.WriteStream('FGSQL','Axpfillgrid',w, stm);
        stm.Free;
      end;
      if assigned(pfg(sdef.fgs[i]).Map) then
        sl.text := pfg(sdef.fgs[i]).Map.text;
      if assigned(pfg(sdef.fgs[i]).caps) then
         caps.text := pfg(sdef.fgs[i]).caps.text;
      for J := 0 to sl.Count-1 do
      begin
        x.close;
        x.Append('axpfgdtl');
        x.Submit('tstruct',name,'c');
        x.Submit('fgname',(pfg(sdef.fgs[i]).fname),'c');
        x.Submit('tarfld',sl.Names[j],'c');
        x.Submit('srcfld',sl.ValueFromIndex[j],'c');
        if caps.count > 0 then
          x.Submit('caption',caps.ValueFromIndex[j],'c');
        x.post;
      end;
    except
      on e:exception do begin
        if assigned(Axp) then begin
          Errstr:=Axp.dbm.gf.Axp_logstr+'\uStructInTable\saveFillgrid - '+e.Message;
          AxP.dbm.gf.DoDebug.Log(Errstr);
        end;
         Writeln(f,'Error in - ' + sname+': '+e.Message);
        ErrMsg := e.Message;
        break;
      end;
    end;
  end;
  xnode := nil;
end;

procedure TstructInTable.deleteexistdata(name :string);
var sxds : TXds; s : string;
begin
  sxds := axp.dbm.GetXDS(nil);
  s := 'delete from axptstructs where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpflds where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpdc where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axppopdc where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpmdmaps where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpgenmaps where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpgenmapdtl where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpfillgrid where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  s := 'delete from axpfgdtl where tstruct = '+quotedstr(name);
  axp.ExecSQL(s,'','',False);
  sxds.close;
  sxds.Destroy;
end;

end.
