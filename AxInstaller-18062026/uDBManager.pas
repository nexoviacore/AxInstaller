unit uDBManager;
{ Copied from  Ver 11.0}
{Copied from Axpert9-XE3\Ver 11.0\Action_DBConn_Lost}

interface

uses
  Windows , SysUtils, Classes, Vcl.dialogs, ADODb, Types,
  Vcl.Forms, Variants, XMLDoc, XMLIntf,  IdGlobal,
  uGeneralFunctions, uConnect, uXDS , DateUtils,Vcl.Controls,
  Data.DBXOracle, Data.DB, Data.SqlExpr,dbxcommon, DbxDevartMySql,DbxDevartPostgreSQL,uCompress ;

type
  TDBManager = class
  private
    Transaction: TDBXTransaction;
    cinfo, cilock, wcinfo, wtemp, wdt : TXDS;
    LoginDatabase, LoginPassword : String;
    fsource, ftarget : File of byte;
    blobfiles : TStringList;
    owngf : Boolean;
    pg_DbName , pg_SchemaName : String;

//    function GetServerpath: String;
//    function WriteRegistry(CompanyID: String): Boolean;
    procedure OracleConnect;
    procedure AccessConnect;
    procedure MySQLConnect;
    procedure PostGreConnect;
    procedure OracleBeforeConnect(Sender: TObject);
    function SetDefaults:String;
    function FileSplit(FileName: String;  MaxCount: integer): integer;
    function WriteToFile(MaxCount: Integer): boolean;
     procedure MsSqlConnect;
    procedure MySQLBeforeConnect(Sender: TObject);
    procedure SetGF(g: TGeneralFunctions);
    function GetOraConnectNo: integer;
    function OracleOpenConnection: boolean;
    function MsSqlOpenConnection: boolean;
    function GetMsSqlConnectNo: integer;
    function FindActualColNames(cols, sqltext: string): String;
    function PostGreOpenConnection: boolean;
    function GetPgaConnectNo: integer;
    function ComputerName: String;
    procedure PostGresBeforeConnect(Sender: TObject);
    function GetMySqlConnectNo: integer;
    function MySqlOpenConnection: boolean;
    procedure SetLowerCaseTableNameValue;
    function GetDecodedSystemId(macid: string): string;
    function GetLicStringFromDB: Boolean;
    procedure MariaDBBeforeConnect(Sender: TObject);
    procedure MariaDBConnect;

  public
    ErrorStr,dbpwd,ErrorCode : String;
    Connect : TPConnect;
    Connection : pConnection;
    remoteOpen : boolean;
    conXML : IXMLDocument;
    gf : TGeneralFunctions;
    ServerDateTime : TDateTime;
    MsWinAuth:Boolean;
    licupdatedays , almupdatedays , sitelicupdatedays , liccopieddays : integer;
    ServerId,ServerIDConnectNo,ServerLicIDConnectNo : string;
    SetDefaultValues,GetServerDT : Boolean;
    ForRapidImport : Boolean;
    webAppCon,LoginUser : AnsiString;

    constructor Create;
    Destructor destroy; override;
    Function OpenConnection : boolean;
    procedure CloseConnection(c:pConnection);
    Procedure SaveToConnectInfo(c:pconnection);
    function Gateclose:boolean;
    function GateOpen:boolean;
    Function Gen_id(c:pconnection): Extended;
    function ConnectToDatabase(ConnectionName:String) : boolean;
    procedure StartTransaction(ConnectionName: String);
    procedure Disconnect(ConnectionName:String);
    procedure Commit(Connectionname: String);
    procedure RollBack(ConnectionName: String);
    function GetServerDateTime: TDateTime;
    function GetXDS(x:txds) : TXDS;
    function GetData(x:txds; table, where:String):TXDS;
    procedure WriteMemo(fname, table, where, filename: String);overload;
    procedure WriteMemo(fname, table, where, filename: String;Append: boolean);overload;
    procedure WriteMemo(fname, table, where: String ; stm : TStringStream ;isblob:boolean=false ); overload ;
    procedure ReadMemo(fname, table, where, filename: String); overload ;
    procedure ReadMemo(fname, table, where, prmval , prmtype : String ; stm : TStringStream); overload ;
    procedure ReadMemo(fname, table, where : String; stm : TStringStream); overload ;
    procedure WriteBlob(fname, table, where, filename: String);Overload;
    procedure WriteBlob(fname, table, where, filename: String;HugeBlob:Boolean);Overload;
    Procedure WriteBlob(fname, table, where, filename: String;Append:string);Overload;
    procedure ReadBlob(fname, table, where, filename: String);Overload;
    procedure ReadBlob(fname, table, where, filename: String;HugeBlob:Boolean);Overload;
    function CreateSessionId: String;
    function InTransaction: boolean;
    procedure update_errorlog(sname, errmsg: String);
    function ChangeSqlForPagination(orgSql: String; findCount: boolean): String;
    function GetAxpertMsg(ErrMsg: String): String;
    procedure CloseAllDS;
    function ReConnectToDatabase: boolean;
    procedure WriteCLOB(Fieldnm, Tablenm, Whr, FieldVal: String);
    Property mygf:TGeneralfunctions read gf write setgf;
    function GetServerId: string;
    function Get_MacId(dtid, mid: String): String;
    function GetTimeId(insid: string): TDatetime;
    function UpdateLicStringWithTStamp(dt: TDateTime): AnsiString;
    function UpdateLicenseInDB(regkey: string; keycol,act : AnsiString): string;
    function Get_Password(dtid, mid: String): String;
    function GetMariadbVersion: real;

  end;


implementation

constructor TDBManager.Create;
begin
  inherited;
  cinfo := nil;
  wtemp := nil;
  wdt := nil;
  conXML := nil;
  Connect := TPConnect.Create;
  Connect.ServerDateTime := GetServerDateTime;
  Connect.ReConnectToDatabase := ReConnectToDatabase ;
  blobfiles:=TStringList.create;
  remoteOpen := True;
  gf := TGeneralFunctions.Create;
  owngf := true;
  dbpwd := '';
  MsWinAuth:=false;
  ServerId := '';
  ServerIDConnectNo := '';
  ServerLicIDConnectNo := '';
  licupdatedays := 0;
  almupdatedays := 0;
  sitelicupdatedays := 0;
  liccopieddays := 0;
  SetDefaultValues := true;
  GetServerDT := True;
  ForRapidImport := False;
  ServerDateTime := 0;
  webAppCon := '';
  LoginUser := '';
end;

Destructor TDBManager.destroy;
begin
  gf.DoDebug.Msg('Destroying Default xds in db manager ');
  if assigned(cinfo) then
  begin
    try
    cinfo.close;
    FreeAndNil(cinfo);
    cinfo := nil;
    except on e:exception do
    begin
      gf.DoDebug.Msg('cinfo free error : ' + e.Message);
      cinfo := nil;
    end;
    end;
  end;
  if assigned(wtemp) then
  begin
    try
    wtemp.close;
    FreeAndNil(wtemp);
    wtemp := nil;
    except on e:exception do
    begin
      gf.DoDebug.Msg('wtemp free error : ' + e.Message);
      wtemp := nil;
    end;
    end;
  end;
  if assigned(wdt) then
  begin
    try
    wdt.Destroy;
    wdt := nil;
    except on e:exception do
    begin
      gf.DoDebug.Msg('wdt free error : ' + e.Message);
      wdt := nil;
    end;
    end;
  end;
  gf.DoDebug.Msg('Destroying connect object');
  try
    while Connect.Connections.count > 0 do begin
      CloseConnection(pConnection(connect.Connections[0]));
      Disconnect(pConnection(connect.Connections[0]).ConnectionName);
      Connect.RemoveConnection(pConnection(connect.Connections[0]).ConnectionName);
    end;
    FreeAndNil(Connect);
  except on e:exception do begin
    gf.DoDebug.Msg('Connect free error : ' + e.Message);
    Connect := nil;
  end;
  end;
  gf.DoDebug.Msg('Destroyed connect object');
  if assigned(blobfiles) then
  begin
    try
    blobfiles.Clear;
    FreeAndNil(blobfiles);
    blobfiles := nil;
    except on e:exception do
    begin
      gf.DoDebug.Msg('blobfiles free error : ' + e.Message);
      blobfiles := nil;
    end;
    end;
  end;
  gf.DoDebug.Msg('Destroying GF');
  if owngf then FreeAndNil(gf);
  inherited;
end;

Function TDBManager.OpenConnection : boolean;
var cno, maxno : integer;
    f:Extended;
    s:String;
begin
//  if assigned(conXML) then exit;    removed since axpmanager needs open connection variables for ver upgrade option
  if (gf.dbmflag = 'axpman') or (gf.dbmflag = 'axpmandrop') then exit;
  if connection.dbtype = 'oracle' then
  begin
    OracleOpenConnection;
  end else if connection.dbtype = 'ms sql' then
  begin
    MsSqlOpenConnection;
  end else if connection.dbtype = 'mysql' then
  begin
    MySqlOpenConnection;
  end
  else if Lowercase(connection.dbtype)='postgre' then
    PostGreOpenConnection
  else begin
    wcinfo := TXDS.Create('q1', nil, connection,gf);
    wtemp := TXDS.create('q2', nil, connection,gf);
    cinfo := TXDS.create('q3', nil, Connection,gf);
    cinfo.buffered := true;
    cilock := TXDS.create('q4', nil, Connection,gf);

    result := false;
    cilock.sqltext := 'select max(connectno) as cno from connectinfo';
    cilock.open;
    if cilock.eof then maxno := 0 else maxno := cilock.fieldbyname('cno').asinteger;
    cilock.close;

    if connection.dbtype = 'access' then begin
      if not gateclose then begin
        errorstr := 'Failed in Gateclose';
        Exit;
      end;
    end;
    // chaged for sql performance
    try
      if connection.dbtype = 'access' then
        cilock.sqltext := 'select * from connectinfo where (active = :act) OR (now()-LASTUPDATED > 1)'
      else if connection.dbtype = 'postgres' then
        cilock.sqltext := 'select * from connectinfo where (active = :act) OR (now()-LASTUPDATED > 1) '+ gf.forupdate
      else if connection.dbtype = 'mysql' then
        cilock.sqltext := 'select * from CONNECTINFO where (ACTIVE = :act) OR (datediff(sysdate(),LASTUPDATED) > 1) '+ gf.forupdate
      else if connection.DbType = 'ms sql' then
        cilock.sqltext := 'select * from CONNECTINFO ' + gf.forupdate + ' where connectno=(select MAX(connectno) from connectinfo where (ACTIVE = :act) OR (DATEDIFF(day,lastupdated,getdate() ) >= 1)) '
      else
        cilock.sqltext := 'select * from CONNECTINFO where connectno=(select MAX(connectno) from connectinfo where (ACTIVE = :act) OR (sysdate-LASTUPDATED > 1)) '+ gf.forupdate;
      cilock.parambyname('act').AsString := 'F';
      StartTransaction(connection.ConnectionName);
      cilock.open;

      if not ciLock.IsEmpty then begin
        ciLock.First;
        cno := cilock.Fieldbyname('connectno').asinteger;
      end else begin
        cno := 0;
      end;

      if ciLock.Isempty then begin
        if cno = gf.MaxConnectNo then begin
          if connection.dbtype = 'access' then
            gateopen
          else begin
            cilock.close;
          end;
          errorstr := 'Connections exhausted';
          exit;
        end;
        wcinfo.sqltext := 'insert into connectinfo (connectno, lastnumber, lastupdated, active) values ('+inttostr(maxno+1)+',0,'+gf.findandreplace(gf.dbdatestring, ':value', gf.ConvertToDbDateTime(connection.dbtype,getserverdatetime))+',''T'')';
        wcinfo.execsql;
        Connection.LastNo := 0;
        Connection.ConnectNo := maxno+1;
      end else begin
        f := ciLock.fieldbyname('lastnumber').asfloat;
        if f > gf.MaxLastNo then f := 0;
        wcinfo.sqltext := 'update connectinfo set lastupdated='+gf.findandreplace(gf.dbdatestring, ':value', gf.ConvertToDbDateTime(connection.dbtype,getserverdatetime))+', lastnumber='+floattostr(f)+', active=''T'' where connectno = '+inttostr(cno);
        wcinfo.execsql;
        Connection.LastNo := f;
        Connection.ConnectNo := Cno;
      end;
      Commit(connection.ConnectionName);

      if connection.dbtype = 'access' then  gateopen
      else cilock.close;
    except on e:exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\OpenConnection - '+e.Message);
        RollBack(connection.ConnectionName);
        cilock.destroy;
        wcinfo.destroy;
        result := false;
        ErrorStr := e.Message;
        exit;
      end;
    end;
    cilock.destroy;
    wcinfo.destroy;
    result := true;
    gf.sescount:=connection.ConnectNo;
  end;
end;

Function TDBManager.OracleOpenConnection : boolean;
var cno,i : integer;
    f:Extended;
begin
  wcinfo := TXDS.Create('q1', nil, connection,gf);
  wtemp := TXDS.create('q2', nil, connection,gf);
  cinfo := TXDS.create('q3', nil, Connection,gf);
  result := false;
  cno:=-1;
  i:=1;
  try
    While true do begin
      cno := GetOraConnectNo;
      if cno = -1 then break;
      cinfo.sqltext := 'SELECT lastnumber FROM CONNECTINFO WHERE CONNECTNO = :cno';
      cinfo.parambyname('cno').AsInteger := cno;
      cinfo.Open;
      if cinfo.Isempty then begin
        wcinfo.sqltext := 'insert into connectinfo (connectno, lastnumber, lastupdated ) values ('+inttostr(cno)+',0,sysdate)';
        wcinfo.execsql;
        f := 0;
      End else f := CInfo.fieldbyname('lastnumber').asfloat;
      If f < gf.MaxLastNo then Break;
      If i > gf.MaxConnectNo then
      begin
        result := false;
        ErrorStr := 'All connections are exhausted.';
        break;
      end;
      Inc(i);
    End;
  except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\OracleOpenConnection - '+e.Message);
      inc(i);
    end;
  end;
  If (cno>-1) then
  begin
    Connection.LastNo := f;
    Connection.ConnectNo := cno;
    gf.sescount:=connection.ConnectNo;
    result := true;
  end else
  begin
    result := false;
    ErrorStr := 'Error in getting connection.';
  end;
  cinfo.close;
  wcinfo.destroy;
  wcinfo:=nil;
End;

Function TDBManager.PostGreOpenConnection : boolean;
var cno,i : integer;
    f:Extended;
begin
  wcinfo := TXDS.Create('q1', nil, connection,gf);
  wtemp := TXDS.create('q2', nil, connection,gf);
  cinfo := TXDS.create('q3', nil, Connection,gf);
  result := false;
  cno:=-1;
  i:=1;
  try
    While true do begin
      cno := GetPgaConnectNo;
      if cno = -1 then break;
      cinfo.sqltext := 'SELECT lastnumber FROM CONNECTINFO WHERE CAST(CONNECTNO AS VARCHAR) = :cno';
      cinfo.parambyname('cno').AsInteger := cno;
      cinfo.Open;
      if cinfo.Isempty then begin
        wcinfo.sqltext := 'insert into connectinfo (connectno, lastnumber, lastupdated ) values ('+inttostr(cno)+',0,now())';
        wcinfo.execsql;
        f := 0;
      End else f := CInfo.fieldbyname('lastnumber').asfloat;
//      wtemp.sqltext := 'SET AUTOCOMMIT TO ON';
//      wtemp.ExecSQL;
      {
      if pg_SchemaName <> '' then
        wtemp.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ','+ pg_SchemaName + ',public'
      else if pg_DbName <> '' then
        wtemp.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ','+pg_DbName + ',public'
      else
        wtemp.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',public';
      wtemp.ExecSQL;
      }
      If f < 999999999 then Break;
      If i > 9999 then
      begin
        result := false;
        ErrorStr := 'All connections are exhausted.';
        break;
      end;
      Inc(i);
    End;
  except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\PostGreOpenConnection - '+e.Message);
      inc(i);
    end;
  end;
  If (cno>-1) then
  begin
    Connection.LastNo := f;
    Connection.ConnectNo := cno;
    gf.sescount:=connection.ConnectNo;
    result := true;
  end else
  begin
    result := false;
    ErrorStr := 'Error in getting connection.';
  end;
  cinfo.close;
  wcinfo.destroy;
  wcinfo:=nil;
End;

Function TDBManager.MsSqlOpenConnection : boolean;
var cno,i : integer;
    f:Extended;
begin
  wcinfo := TXDS.Create('q1', nil, connection,gf);
  wtemp := TXDS.create('q2', nil, connection,gf);
  cinfo := TXDS.create('q3', nil, Connection,gf);
  result := false;
  cno:=-1;
  i:=1;
  try
    While true do begin
      cno := GetMsSqlConnectNo;
      if cno = -1 then break;
      cinfo.sqltext := 'SELECT lastnumber FROM CONNECTINFO WHERE CONNECTNO = :cno';
      cinfo.parambyname('cno').AsInteger := cno;
      cinfo.Open;
      if cinfo.Isempty then begin
        wcinfo.sqltext := 'insert into connectinfo (connectno, lastnumber, lastupdated ) values ('+inttostr(cno)+',0,getdate())';
        wcinfo.execsql;
        f := 0;
      End else f := CInfo.fieldbyname('lastnumber').asfloat;
      If f < gf.MaxLastNo then Break;
      If i > gf.MaxConnectNo then
      begin
        result := false;
        ErrorStr := 'All connections are exhausted.';
        break;
      end;
      Inc(i);
    End;
  except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\MsSqlOpenConnection - '+e.Message);
      inc(i);
    end;
  end;
  If (cno>-1) then
  begin
    Connection.LastNo := f;
    Connection.ConnectNo := cno;
    gf.sescount:=connection.ConnectNo;
    result := true;
  end else
  begin
    result := false;
    ErrorStr := 'Error in getting connection.';
  end;
  cinfo.close;
  wcinfo.destroy;
  wcinfo:=nil;
End;

Function TDBManager.MySqlOpenConnection : boolean;
var cno,i : integer;
    f:Extended;
begin
  wcinfo := TXDS.Create('q1', nil, connection,gf);
  wtemp := TXDS.create('q2', nil, connection,gf);
  cinfo := TXDS.create('q3', nil, Connection,gf);
  result := false;
  cno:=-1;
  i:=1;
  try
    While true do begin
      cno := GetMySqlConnectNo;
      if cno = -1 then break;
      cinfo.sqltext := 'SELECT lastnumber FROM CONNECTINFO WHERE CONNECTNO = :cno';
      cinfo.parambyname('cno').AsInteger := cno;
      cinfo.Open;
      if cinfo.Isempty then begin
        wcinfo.sqltext := 'insert into connectinfo (connectno, lastnumber, lastupdated ) values ('+inttostr(cno)+',0,sysdate())';
        wcinfo.execsql;
        f := 0;
      End else f := CInfo.fieldbyname('lastnumber').asfloat;
      If f < 999999999 then Break;
      If i > 9999 then
      begin
        result := false;
        ErrorStr := 'All connections are exhausted.';
        break;
      end;
      Inc(i);
    End;
  except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\MySqlOpenConnection - '+e.Message);
      inc(i);
    end;
  end;
  If (cno>-1) then
  begin
    Connection.LastNo := f;
    Connection.ConnectNo := cno;
    gf.sescount:=connection.ConnectNo;
    result := true;
  end else
  begin
    result := false;
    ErrorStr := 'Error in getting connection.';
  end;
  cinfo.close;
  wcinfo.destroy;
  wcinfo:=nil;
End;

Function TDBManager.GetOraConnectNo : integer;
  var cilock : TXDS;
Begin
  Result:=-1;
  cilock := TXDS.create('q4', nil, Connection,gf);
  try
    cilock.sqltext := 'select ConnectNoSeq.NextVal from Dual';
    cilock.open;
    Result:=cilock.Fields[0].AsInteger;
    cilock.close;
  Except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GetOraConnectNo - '+e.Message);
      Result:=-1;
    end;
  End;
  FreeAndNil(cilock);
End;

Function TDBManager.GetPgaConnectNo : integer;
  var cilock : TXDS;
Begin
  Result:=-1;
  cilock := TXDS.create('q4', nil, Connection,gf);
  try
//    cilock.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',public';
//    cilock.execsql;
    if pg_SchemaName <> '' then
      cilock.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ','+ pg_SchemaName + ',public'
    else if pg_DbName <> '' then
      cilock.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ','+pg_DbName + ',public'
    else
      cilock.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',public';
    cilock.ExecSQL;
    cilock.close;
    cilock.sqltext := ' Select nextval(''connectnoseq'') ';
    cilock.open;
    Result:=cilock.Fields[0].AsInteger;
    cilock.close;
  Except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GetPgaConnectNo - '+e.Message);
      Result:=-1;
    end;
  End;
  FreeAndNil(cilock);
End;

Function TDBManager.GetMsSqlConnectNo : integer;
  var s : String;
Begin
  Result:=-1;
  cilock := TXDS.create('q4', nil, Connection,gf);
  try
    cilock.spAdo.ProcedureName := 'GetNextVal';
    cilock.spAdo.Parameters.Refresh;
    cilock.spAdo.Parameters[0].Value := null;
    cilock.spAdo.Parameters[1].Value := 0;
    cilock.spAdo.ExecProc;
    Result:=cilock.spAdo.Parameters[1].Value;
  Except on e:exception do
  begin
    if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GetMsSqlConnectNo - '+e.Message);
    s := e.Message;
    Result:=-1;
  End;
  end;
  FreeAndNil(cilock);
End;

Function TDBManager.GetMySqlConnectNo : integer;
  var cilock : TXDS;
Begin
  Result:=-1;
  cilock := TXDS.create('q4', nil, Connection,gf);
  try
    if gf.dbase = 'mariadb' then
    begin
      if GetMariadbVersion >= 10.3 then
        cilock.sqltext := ' Select nextval(connectno) '
      else
        cilock.sqltext := ' Select nextval(''connectno'') ';
    end
    else
    cilock.sqltext := ' Select nextval(''connectno'') ';
    cilock.open;
    Result:=cilock.Fields[0].AsInteger;
    cilock.close;
  Except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GetMySqlConnectNo - '+e.Message);
      Result:=-1;
    end;
  End;
  FreeAndNil(cilock);
End;

function TDBManager.GateClose : boolean;
var done : integer;
begin
  result := false;
  done := 0;
  while (done < 100) do begin
    try
     wtemp.sqltext := 'create table connecttemp (connecttempid integer)';
     wtemp.ExecSQL;
     break;
    except on e:Exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GateClose - '+e.Message);
        if done=99 then ShowMessage('Unable to connect in GateClose.');
        inc(done);
      end;
    end;
  end;
  if done < 100 then
    result := true;
end;

function TDBManager.GateOpen : boolean;
begin
  result := false;
  wtemp.sql.clear;
  wtemp.sql.text := 'drop table connecttemp';
  wtemp.execsql;
end;

procedure TDBManager.CloseConnection(c:pconnection);
begin
  if (gf.dbmflag = 'axpman') or (gf.dbmflag = 'axpmandrop') then exit;
  if not assigned(wtemp) then exit;
  if connection.dbtype = '' then exit;
  if (connection.dbtype <> 'oracle') and (connection.dbtype <> 'ms sql') and
  (connection.dbtype <> 'mysql') and (connection.dbtype <> 'postgre') then
  begin
    try
      wtemp.sqltext := 'update connectinfo set active = ''F'' where connectno = '+inttostr(connection.connectno);
      wtemp.execsql;
    except on e:exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\CloseConnection - '+e.Message);
      end;
    end;
  end;
end;

Procedure TDBManager.SaveToConnectInfo(c:pConnection);
var done : integer;
    dt, dt2 : TDateTime;
    s,s1,orgdt : String;
begin
  if connection.dbtype = 'oracle' then
  begin
    wtemp.sqltext := 'update connectinfo set lastnumber=:lc,lastupdated=sysdate where connectno = :cn';
    wtemp.parambyname('lc').asfloat := c.lastno;
    wtemp.parambyname('cn').AsInteger := c.Connectno;
    wtemp.execsql;
  end else if connection.dbtype = 'ms sql' then
  begin
    wtemp.sqltext := 'update connectinfo set lastnumber=:lc,lastupdated=getdate() where connectno = :cn';
    wtemp.parambyname('lc').asfloat := c.lastno;
    wtemp.parambyname('cn').AsInteger := c.Connectno;
    wtemp.execsql;
  end
  else if connection.dbtype='postgre' then begin
   wtemp.sqltext := 'update connectinfo set lastnumber= ' + floattostr(c.lastno) + ',lastupdated=now() WHERE CAST(CONNECTNO AS VARCHAR) = :cn';
//   wtemp.parambyname('lc').AsFloat := c.lastno;
   wtemp.parambyname('cn').AsInteger := c.Connectno;
   wtemp.execsql;
  end
  else if connection.dbtype = 'mysql' then
  begin
    done := 0;
    while (done < 100) do begin
      try
        wtemp.sqltext := 'update connectinfo set lastnumber=:lc,lastupdated=sysdate() where connectno = :cn';
        wtemp.parambyname('lc').asfloat := c.lastno;
        wtemp.parambyname('cn').AsInteger := c.Connectno;
        wtemp.execsql;
        break;
      except on e:Exception do
        begin
          if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\SaveToConnectInfo - '+e.Message);
          inc(done);
          if done = 99 then raise;
        end;
      end;
    end;
  end
  else
  begin
    done := 0;
    while (done < 100) do begin
      try
        dt := GetServerDateTime;
        gf.dodebug.Msg('Actual Server Date time : ' + datetimetostr(dt));
        orgdt := gf.ConvertToDbDateTime(connection.dbtype,dt);
        s :=  formatdatetime(gf.ShortDateFormat.ShortDateFormat,dt);
        gf.dodebug.Msg('Server Date time : ' + s);
        dt := strtodatetime(s);
        if connection.dbtype <> 'access' then begin
          cinfo.CDS.CommandText := 'select lastupdated from connectinfo where connectno = '+inttostr(c.connectno);
          cinfo.open;
          dt2 := cinfo.cds.fieldbyname('lastupdated').asdatetime;
          gf.dodebug.Msg('Actual Last updated time : ' + datetimetostr(dt2));
          s1 :=  formatdatetime(gf.ShortDateFormat.ShortDateFormat,dt2);
          gf.dodebug.Msg('Last updated time : ' + s1);
          dt2 := strtodatetime(s1);
          if (dt-dt2) > 1 then
            raise EDataBaseError.Create('Invalid connection');
          cinfo.close;
        end;
        wtemp.sqltext := 'update connectinfo set lastupdated=' +gf.findandreplace(gf.dbdatestring, ':value', orgdt)+ ',lastnumber=:lc where connectno = :cn';
        wtemp.parambyname('lc').asfloat := c.lastno;
        wtemp.parambyname('cn').asinteger := c.Connectno;
        wtemp.execsql;
        break;
      except on e:Exception do
        begin
          if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\SaveToConnectInfo - '+e.Message);
          inc(done);
          if done = 99 then raise;
        end;
      end;
    end;
  end;
end;

Function TDBManager.Gen_id(C:pConnection) : extended;
var
  CnctNo : String;
begin
  if gf.newgen then
    Result := StrToFloat(IntToStr(c.SiteNo) + gf.Leftpad(IntToStr(c.ConnectNo),Length(FloatTostr(gf.MaxConnectNo)), '0') + FloatToStr(C.LastNo))
  else begin
    if gf.MaxSiteNo = 999 then begin
       CnctNo := InttoStr(c.ConnectNo);
       CnctNo := Copy(CnctNo,length(CnctNo),1);
       if CnctNo = '0' then CnctNo := '1';
       Result := StrToFloat(IntToStr(c.SiteNo) + gf.Leftpad(IntToStr(c.ConnectNo),Length(FloatTostr(gf.MaxConnectNo)), '0') +CnctNo+gf.LeftPad(FloatToStr(C.LastNo), Length(FloatTostr(gf.MaxLastNo))-1, '0'));
    end
    else
      Result := StrToFloat(IntToStr(c.SiteNo) + gf.Leftpad(IntToStr(c.ConnectNo),Length(FloatTostr(gf.MaxConnectNo)), '0') + gf.LeftPad(FloatToStr(C.LastNo), Length(FloatTostr(gf.MaxLastNo)), '0'));
  end;
  c.LastNo := c.LastNo + 1;
  SaveToConnectInfo(c);
end;
{
Function TDBManager.WriteRegistry(CompanyID:String):Boolean;
var
  DataPath:String;
  Reg:TRegistry;
Begin
  Result := False;
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  Reg.OpenKey('SOFTWARE\BLUECHIP\PROFIT',true);
  datapath :=Reg.ReadString('SERVERPATH');
  if datapath='' then datapath:=GetServerpath;
  if pos('\', companyid) = 0 then
    companyid:=datapath+companyid;
  reg.CloseKey;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  If Reg.KeyExists('SOFTWARE\ODBC\ODBC.INI\PROFITACCESSDSN') Then
  Begin
     Reg.OpenKey('SOFTWARE\ODBC\ODBC.INI\PROFITACCESSDSN\',True);
     Reg.WriteString('DBQ',CompanyID +'.mdb')
  End
  Else ShowMEssage('Unable to connect.');
  Reg.CloseKey;
  Reg.Free;
  Reg := Nil;
  Result := True;
End;

function TDBManager.GetServerpath: String;
var
  reg: TRegistry;
  i,l: integer;
  serverpath: String;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  If Reg.KeyExists('SOFTWARE\ODBC\ODBC.INI\PROFITACCESSDSN') Then
  Begin
     Reg.OpenKey('SOFTWARE\ODBC\ODBC.INI\PROFITACCESSDSN\',True);
     serverpath:=reg.ReadString('DBQ');
     if pos('\',serverpath)>0 then begin
      l:=length(serverpath);
      for i:=l downto 1 do begin
        if serverpath[i]='\' then begin
           result:=serverpath;
           break;
        end else
          delete(serverpath,i,1);
      end;
     end;
     Reg.CloseKey;
     reg.OpenKey('SOFTWARE\BLUECHIP\PROFIT',true);
     reg.WriteString('SERVERPATH',SERVERPATH);
  End
  Else ShowMEssage('Unable to connect.');
  Reg.CloseKey;
  Reg.Free;
  Reg := Nil;
end;
}
function TDBManager.ConnectToDatabase(ConnectionName:String) : boolean;
  var i : integer;
begin
  gf.dbtimetaken := 0;
  errorstr := '';
  Result := false;
  if ConnectionName = '' then exit;
  if gf.exepath = '' then  gf.exepath := GetCurrentDir;
  ConnectionName :=trim(connectionname);
  if gf.RemoteLogin then begin
     connect.RemoteConnect(connectionname);
     Connection := Connect.Connection;
     if gf.remotedbType = 'access' then
     begin
       gf.sqllower:='lcase';
       gf.forupdate :=' for update ';
       gf.sqlnull := 'nvl';
     end else if gf.remotedbType = 'ms sql' then
     begin
       gf.sqllower:='lower';
       gf.forupdate:=' with(holdlock,rowlock) ';
       gf.sqlnull := 'isnull';
       gf.nullcds := 'select lval from dual with(nolock)';
     end else if gf.remotedbType = 'oracle' then
     begin
        gf.sqllower:='lower';
        gf.forupdate :=' for update ';
        gf.sqlnull := 'nvl';
        gf.nullcds := 'select lpad('' '', 250, '' '') LVAL from dual';
     end else if gf.remotedbType = 'postgre' then
     begin
        gf.sqllower:='lower';
        gf.forupdate :=' for update ';
        gf.sqlnull := 'coalesce';
        gf.nullcds := 'select ''                                            ListVal'' LVal from dual';
     end else if gf.remotedbType = 'mysql' then
     begin
        gf.sqllower:='lower';
        gf.forupdate :=' for update';
        gf.sqlnull := 'nvl';
        gf.nullcds := 'select ''                                            ListVal'' LVal from dual';
     end;
     result := True;
     exit;
  end;
  gf.dodebug.Msg('creating connection starts...');
  if assigned(conXML) then Connect.conXML := conXML;
  Connect.AddConnection(ConnectionName);
  Connection := Connect.Connection;
  i:=0;
  if Connection = nil then
  begin
    while True do
    begin
      try
        Connect.AddConnection(ConnectionName);
        Connection := Connect.Connection;
        if Connection <> nil then break;
        if i >= 20 then raise Exception.Create('Error in getting connection. Please try later...');
      except on e:exception do
      begin
        gf.dodebug.Msg('error in getting connection...');
        inc(i);
      end;
      end;
    end;
  end;
  gf.dbase := connection.dbtype;
  gf.schemaname := Connection.ProjectName;  //schemaname
  gf.dodebug.Msg('creating connection end...');
  gf.dodebug.Msg('creating date xds...');
  wdt := TXDS.create('wdt', nil, Connection,gf);
  wdt.buffered:=true;
  gf.dodebug.Msg('creating date xds end...');
  if connection.DbType = 'access' then begin
    gf.currencytable := '"currency"';
    gf.sqllower:='lcase';
    gf.forupdate :=' for update ';
    gf.sqlnull := 'nvl';
    gf.dbdateformat := 'dd/mm/yyyy';
    gf.dbdatestring := 'format('':value'', ''dd/mm/yyyy hh:nn:ss'')';
    AccessConnect;
    wdt.cds.commandtext := 'Select now() as sdt from dual';
  end else if connection.DbType = 'ms sql' then begin
    gf.dodebug.Msg('Setting db vars...');
    gf.currencytable := '"currency"';
    gf.sqllower:='lower';
    gf.forupdate:=' with(holdlock,rowlock) ';
    gf.sqlnull := 'isnull';
    gf.nullcds := 'select lval from dual with(nolock)';
    gf.dbdateformat := 'mm/dd/yyyy';
    gf.dbdatestring :=  'CONVERT(VARCHAR(23), '':value'', 101)';
    gf.dodebug.Msg('Setting db vars ends...');
    MsSqlConnect;

    wdt.cds.commandtext := 'SELECT GETDATE()as [sdt]';
  end else if connection.DbType = 'oracle' then begin
    gf.currencytable := 'currency';
    gf.sqllower:='lower';
    gf.forupdate :=' for update ';
    gf.sqlnull := 'nvl';
    gf.nullcds := 'select lpad('' '', 250, '' '') LVAL from dual';
    gf.dbdateformat := 'dd-mmm-yyyy';
    gf.dbdatestring := gf.getregistry('oradatestring');
    if gf.dbdatestring = '' then
      gf.dbdatestring := 'to_date('':value'',''dd/mm/yyyy hh24:mi:ss'')'
    else
      gf.dbdatestring:='to_date('':value'','+quotedstr(gf.dbdatestring)+')';
    OracleConnect;
    wdt.cds.commandtext := 'Select sysdate as sdt from dual';
  end else if Connect.connection.DbType = 'mysql' then begin
    gf.currencytable := 'currency';
    gf.sqllower:='lower';
    gf.forupdate :=' for update ';
    gf.sqlnull := 'ifnull';
    gf.dbdateformat := 'YYYY-MM-DD';
    gf.dbdatestring := 'date_format('':value'', ''%Y-%m-%d %T'')';
    gf.nullcds := 'select ''                                                                                                     '' as lval from dual';
    MySQLConnect;
    SetLowerCaseTableNameValue;
    wdt.cds.commandtext := 'Select sysdate() as sdt ';
  end else if Connect.connection.DbType = 'mariadb' then begin
    gf.currencytable := 'currency';
    gf.sqllower:='lower';
    gf.forupdate :=' for update ';
    gf.sqlnull := 'ifnull';
    gf.dbdateformat := 'YYYY-MM-DD';
    gf.dbdatestring := 'date_format('':value'', ''%Y-%m-%d %T'')';
    gf.nullcds := 'select ''                                                                                                     '' as lval from dual';
    MariaDBConnect;
    SetLowerCaseTableNameValue;
    wdt.cds.commandtext := 'Select sysdate() as sdt ';
  end else if connection.DbType = 'postgre' then begin
    gf.currencytable := 'currency';
    gf.sqllower:='lower';
    gf.forupdate :=' for update ';
    gf.dbdateformat := 'dd/mm/yyyy';
   // gf.dbdatestring := 'format('':value'', ''dd/mm/yyyy hh:nn:ss'')';
    gf.dbdatestring := 'to_timestamp('':value'',''dd/mm/yyyy hh24:mi:ss'')';
    gf.sqlnull := 'coalesce';
    gf.nullcds := 'select ''                                                                                                     ''::varchar(250) as lval';

    PostGreConnect;
    wdt.cds.commandtext := 'Select now() as sdt ';
  end;
  gf.dodebug.Msg('db user : ' + LoginUser );
  if (errorstr = '') and (GetServerDT) then ServerDateTime := GetServerDateTime;
  if (errorstr = '') and (remoteOpen) then result := OpenConnection;
  if errorstr <> '' then raise exception.Create(errorstr);
  if (errorstr='') and (SetDefaultValues) then SetDefaults;
end;


Procedure TDBManager.SetLowerCaseTableNameValue;
var
  LowerCaseTableName,ErrMsg : String;
begin
  try
    ErrMsg := '';
    wdt.cds.commandtext := 'select @@global.lower_case_table_names as lowercasetablename';  //Get LowerCaseTableName
    wdt.open;
    LowerCaseTableName := wdt.cds.fieldbyname('lowercasetablename').AsString;
    (*
    ## 0 store=lowercase	; compare=sensitive	(works only on case sensitive file systems )
    ## 1 store=lowercase	; compare=insensitive
    ## 2 store=exact	; compare=insensitive	(works only on case INsensitive file systems )
    #default is 0/Linux ; 1/Windows
    *)
    if LowerCaseTableName = '0' then
       gf.lowercase_tablenames := true
    else
       gf.lowercase_tablenames := false;
    wdt.Close;
  except on e:exception do
      ErrMsg := e.Message;
  end;
  if ErrMsg <> '' then
    if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\SetLowerCaseTableNameValue - '+ErrMsg);
end;


procedure TDBManager.OracleConnect;
  var sfile,insid,cpuid :String;
  i : integer;
  starttime:TDateTime;
begin
    gf.dodebug.Msg('OracleConnect starts...');
    try
      if connection.projectname = '' then begin
        ErrorStr := 'Improper Project Name';
        Raise Exception.create(Errorstr);
      end;

      if connection.dbname = '' then begin
        ErrorStr := 'Improper Database Name';
        Raise Exception.create(Errorstr);
      end;

      LoginUser := connection.ProjectName;
      LoginDatabase := connection.DbName;

      if gf.dbmflag = 'axpman' then
         LoginPassword := Connection.PWord
      else if (gf.IsService) then begin
        LoginPassword := '';
        dbpwd := Connection.PWord;
        if  dbpwd = '' then
        begin
          sfile := gf.exepath + '\'+LoginUser+'.pwd';
          if fileexists(sfile) then begin
            with tstringlist.create do begin
              LoadFromFile(sfile);
              dbpwd := trim(text) ;
              free;
            end;
          end else dbpwd := '';
        end;
        if  dbpwd <> '' then
        begin
          i := 0;
          insid := dbpwd;
          i := strtoint(copy(insid,1,4));
          delete(insid,1,4);
          i := i * 4 ;
          cpuid := copy(insid,1,i);
          delete(insid,1,i);
          i := length(insid);
          delete(insid,i-3,i);
          LoginPassword := Get_Password(insid,cpuid);
        end else LoginPassword := 'log';
      end else begin
        LoginPassword := 'log';
        //sfile := gf.exepath + '\Axp.pwd';
        sfile := gf.exepath + '\'+LoginUser+'.pwd';
        i := 0;
        insid := '';
        if fileexists(sfile) then begin
          LoginPassword := '';
          with tstringlist.create do begin
            LoadFromFile(sfile);
            insid := trim(text) ;
            free;
          end;
        end else if (connection.PWord <> '') and gf.Isnumeral(connection.PWord) then
          insid := connection.PWord;
        if insid <> '' then
        begin
          i := strtoint(copy(insid,1,4));
          delete(insid,1,4);
          i := i * 4 ;
          cpuid := copy(insid,1,i);
          delete(insid,1,i);
          i := length(insid);
          delete(insid,i-3,i);
          LoginPassword := Get_Password(insid,cpuid);
        end;
      end;
      Connection.DbPwd := LoginPassword;
      connection.dbx.name := connection.ConnectionName;
      gf.dodebug.Msg('Dbx name = '+connection.dbx.Name);
      connection.dbx.connectionname := 'oracle';
      gf.dodebug.Msg('ConnectionName  = '+connection.dbx.ConnectionName);
      connection.dbx.drivername := 'oracle';
      gf.dodebug.Msg('DriverName  = '+connection.dbx.DriverName);
      connection.dbx.GetDriverFunc := 'getSQLDriverORACLE';
      gf.dodebug.Msg('GetDriverFunc  = '+connection.dbx.GetDriverFunc);
      connection.dbx.LibraryName := gf.exepath + '\dbxora.dll';
      gf.dodebug.Msg('LibraryName  = '+connection.dbx.LibraryName);
      connection.dbx.VendorLib := gf.exepath +'\OCI.dll';
      gf.dodebug.Msg('VendorLib  = '+connection.dbx.VendorLib);
      connection.dbx.Params.Clear;
      connection.dbx.LoginPrompt := false;
      connection.dbx.BeforeConnect := OracleBeforeConnect;
      starttime:=now();
      try
         connection.dbx.Connected := true;
       except on e:TDBXError do
         begin
            gf.dodebug.Msg('Error in Oracle connection  : ' + e.Message);
            if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\OracleConnect - '+e.Message);
            ErrorCode := inttostr(e.ErrorCode);
             ErrorStr := trim(e.Message);
            if (ErrorCode = '-1') and (ErrorStr ='DBX Error:  Error Code:  -1') then
              raise Exception.Create('OCI.dll not compatible with your oracle client')
            else if ErrorCode = '22' then
              raise Exception.Create('OCI.dll library may be missing from the system path')
            else if (ErrorCode='-1') and (ErrorStr='ORA-12154: TNS:could not resolve the connect identifier specified') then
              raise Exception.Create('Invalid Host String')
            else if (ErrorCode='-1') and (ErrorStr='ORA-01017: invalid username/password; logon denied')then
              raise Exception.Create('Invalid username/password')
            else raise Exception.Create(ErrorStr);
         end;
      end;
    //  connection.dbx.Connected := true;
      gf.dbconnectiontime := millisecondsbetween(now(),starttime);
      gf.dbtimetaken := gf.dbtimetaken + millisecondsbetween(now(),starttime);
    except on e:exception do
    begin
      ErrorStr := e.Message;
      if assigned(gf) then  begin
        gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\OracleConnect - '+e.Message);
        gf.dodebug.Msg('Error in OracleConnect. Error: '+ErrorStr);
      end;
    end;
    end;
end;

function TDBManager.Get_Password(dtid,mid : String) : String;
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

Procedure TDBManager.OracleBeforeConnect(Sender:TObject);
begin
  With Sender as TSQLConnection do begin
    Params.Values['Database'] := LoginDatabase;
    gf.dodebug.Msg('Database  = '+Params.Values['Database']);
    Params.Values['User_Name'] := LoginUser;
    gf.dodebug.Msg('User_Name  = '+Params.Values['User_Name']);
    Params.Values['Password'] := LoginPassword;
  end;
end;

Procedure TDBManager.MySQLBeforeConnect(Sender:TObject);
  var i : integer;
      dbName : String;
begin
  With Sender as TSQLConnection do begin
    Params.Values['unicode'] := 'True';
    dbName := LoginUser;
    if gf.dbmflag = 'axpman' then
    begin
       Params.Values['User_Name'] := LoginUser ;
       dbName := '';
    end else begin
       i := pos('\',LoginUser);
       if i > 0 then
       begin
          LoginUser := copy(LoginUser,1,i-1);
          Params.Values['User_Name'] := LoginUser;
          delete(dbName,1,i);
       end else Params.Values['User_Name'] := LoginUser;
    end;
    Params.Values['Password'] := LoginPassword;
    Params.Values['Database'] := dbName;
    Params.Values['HostName'] := LoginDatabase;
  end;
end;

procedure TDBManager.MySQLConnect;
var
  sfile,insid,cpuid,uname : string;
  i:integer;
begin

  if connection.projectname = '' then begin
    ErrorStr := 'Improper Project Name';


    Raise Exception.create(Errorstr);
  end;

  if connection.dbname = '' then begin
    ErrorStr := 'Improper Database Name';
    Raise Exception.create(Errorstr);
  end;

  LoginUser := connection.ProjectName;
  LoginDatabase := connection.DbName;
  i := pos('\',LoginUser);
  if i > 0 then
  begin
    uname := copy(LoginUser,1,i-1);
  end else uname := LoginUser;

  if gf.dbmflag = 'axpman' then
     LoginPassword := Connection.PWord
  else if (gf.IsService) then begin
    LoginPassword := '';
    dbpwd := Connection.PWord;
    if  dbpwd = '' then
    begin
      sfile := gf.exepath + '\'+LoginUser+'.pwd';
      if fileexists(sfile) then begin
        with tstringlist.create do begin
          LoadFromFile(sfile);
          dbpwd := trim(text) ;
          free;
        end;
      end else dbpwd := '';
    end;
    if  dbpwd <> '' then
    begin
      i := 0;
      insid := dbpwd;
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end else LoginPassword := 'log';
  end else begin
    LoginPassword := 'log';
    sfile := gf.exepath + '\'+uname+'.pwd';
    i := 0;
    insid := '';
    if fileexists(sfile) then begin
      LoginPassword := '';
      with tstringlist.create do begin
        LoadFromFile(sfile);
        insid := trim(text) ;
        free;
      end;
    end else if (connection.PWord <> '') and gf.Isnumeral(connection.PWord) then
      insid := connection.PWord;
    if insid <> '' then
    begin
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end;
  end;

  i := pos('\',connection.ConnectionName);
  if i > 0 then
  begin
    connection.ConnectionName := copy(connection.ConnectionName,1,i-1);
  end;

  connection.dbx.name := connection.ConnectionName;
  connection.dbx.connectionname := 'Devart MySQL';
  connection.dbx.drivername := 'DevartMySQL';
  connection.dbx.GetDriverFunc := 'getSQLDriverMySQL';
  connection.dbx.LibraryName := gf.exepath +'\dbexpmda40.dll';
  connection.dbx.VendorLib := gf.exepath + '\libmysql.dll';
  connection.dbx.LoginPrompt := false;
  connection.dbx.BeforeConnect := MySQLBeforeConnect;
  connection.dbx.Connected := true;
end;


procedure TDBManager.MariaDBConnect;
var
  sfile,insid,cpuid,uname : string;
  i:integer;
begin

  if connection.projectname = '' then begin
    ErrorStr := 'Improper Project Name';
    Raise Exception.create(Errorstr);
  end;

  if connection.dbname = '' then begin
    ErrorStr := 'Improper Database Name';
    Raise Exception.create(Errorstr);
  end;

  LoginUser := connection.ProjectName;
  LoginDatabase := connection.DbName;
  i := pos('\',LoginUser);
  if i > 0 then
  begin
    uname := copy(LoginUser,1,i-1);
  end else uname := LoginUser;

  if gf.dbmflag = 'axpman' then
     LoginPassword := Connection.PWord
  else if (gf.IsService) then begin
    LoginPassword := '';
    if (not gf.ConnectRestDll) then
       dbpwd := Connection.PWord
    else begin
      sfile := gf.exepath + '\'+LoginUser+'.pwd';
      if fileexists(sfile) then begin
        with tstringlist.create do begin
          LoadFromFile(sfile);
          dbpwd := trim(text) ;
          free;
        end;
      end else dbpwd := '';
    end;
    if  dbpwd <> '' then
    begin
      i := 0;
      insid := dbpwd;
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end else LoginPassword := 'log';
  end else begin
    LoginPassword := 'log';
    sfile := gf.exepath + '\'+uname+'.pwd';
    i := 0;
    insid := '';
    if fileexists(sfile) then begin
      LoginPassword := '';
      with tstringlist.create do begin
        LoadFromFile(sfile);
        insid := trim(text) ;
        free;
      end;
    end else if (connection.PWord <> '') and gf.Isnumeral(connection.PWord) then
      insid := connection.PWord;
    if insid <> '' then
    begin
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end;
  end;

  i := pos('\',connection.ConnectionName);
  if i > 0 then
  begin
    connection.ConnectionName := copy(connection.ConnectionName,1,i-1);
  end;
  try
    connection.dbx.name := connection.ConnectionName;
    connection.dbx.connectionname := 'Devart MySQL';
    connection.dbx.drivername := 'DevartMySQL';
    connection.dbx.GetDriverFunc := 'getSQLDriverMySQL';
    connection.dbx.LibraryName := gf.exepath +'\dbexpmda40.dll';
    connection.dbx.VendorLib := gf.exepath + '\libmysql.dll';
    connection.dbx.LoginPrompt := false;
    connection.dbx.BeforeConnect := MariaDBBeforeConnect;
    connection.dbx.Connected := true;
    Connect.connection.DbType := 'mysql';
  except on e:exception do
    raise Exception.Create('Not able to connect specified MariaDB. Please check the connection properties and try again...');
  end;
end;


Procedure TDBManager.MariaDBBeforeConnect(Sender:TObject);
  var i : integer;
      dbName : String;
begin
  dbName := LoginUser;
  With Sender as TSQLConnection do begin
    Params.Values['unicode'] := 'True';
    Params.Values['HostName'] := LoginDatabase;
    if gf.dbmflag = 'axpman' then
    begin
       Params.Values['User_Name'] := LoginUser ;
       Params.Values['Database'] := '';
    end else begin
       i := pos('\',LoginUser);
       if i > 0 then
       begin
          LoginUser := copy(LoginUser,1,i-1);
          Params.Values['User_Name'] := LoginUser;
          delete(dbName,1,i);
       end else Params.Values['User_Name'] := LoginUser;
       Params.Values['Database'] := dbName;
    end;
    Params.Values['Password'] := LoginPassword;
  end;
end;

procedure TDBManager.AccessConnect;
begin
  if connection.projectname = '' then begin
    ErrorStr := 'Improper Project Name';
    Raise Exception.create(Errorstr);
  end;
//  WriteRegistry(connection.projectname);
  connection.Ado.name := connection.Connectionname;
  connection.Ado.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=ProfitAccessDSN';
  connection.Ado.LoginPrompt := false;
  connection.Ado.Connected := true;
end;

procedure TDBManager.MsSqlConnect;
  var starttime:TDateTime;
    sfile,insid,cpuid,cname : string;
    i:integer;
    MsDbverno,NativeClient:string;
    ErrorMsg:string;
begin
 Try
  gf.dodebug.Msg('MsSqlConnect Starts.. ');
  ErrorMsg:='';
  LoginUser := connection.ProjectName;
  LoginDatabase := connection.DbName;
  LoginPassword := connection.PWord;
  MsDbverno:=connection.MsDBverno;
  if MsDbverno='Above 2012' then
    NativeClient:='MSDASQL.1'
  else if MsDbverno='2012' then
    NativeClient:='SQLNCLI11'
  else
    NativeClient:='SQLNCLI10.1';

  if connection.projectname = '' then begin
    ErrorStr := 'Improper Project Name';
    gf.dodebug.Msg('MsSqlConnect error : ' + ErrorStr);
    Raise Exception.create(Errorstr);
  end;
  Connection.dbtimeout:=30;  // Command Timeout is default by 30 sec for SQL Server
  connection.ado.Close;
  if not MsWinAuth then  connection.Ado.name := connection.Connectionname;
  if MsWinAuth then
  begin
    if MsDbverno='Above 2012' then
    begin
       cname := ComputerName;
       connection.Ado.ConnectionString := 'Provider='+NativeClient+';Persist Security Info=False;Extended Properties="DSN='+ logindatabase + ';Trusted_Connection=Yes;APP=Enterprise;WSID=' + cname + ';DATABASE=master;"';
    end else connection.Ado.ConnectionString := 'Provider='+NativeClient+';Persist Security Info=False;Initial Catalog=master;Data Source='+logindatabase+'; Integrated Security=SSPI;'
  end else if gf.dbmflag = 'axpman' then
  begin
      connection.Ado.ConnectionString := 'Provider='+NativeClient+';Persist Security Info=False;User ID='+loginuser+';pwd='+LoginPassword+ ';Initial Catalog=master;Data Source='+logindatabase;
  end else if (gf.IsService) then begin
    LoginPassword := '';
    dbpwd := Connection.PWord;
    if  dbpwd = '' then
     begin
      sfile := gf.exepath + '\'+LoginUser+'.pwd';
      if fileexists(sfile) then begin
        with tstringlist.create do begin
          LoadFromFile(sfile);
          dbpwd := trim(text) ;
          free;
        end;
      end else dbpwd := '';
    end;
    if  dbpwd <> '' then
    begin
      i := 0;
      insid := dbpwd;
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end else LoginPassword := 'log';
    connection.Ado.ConnectionString := 'Provider='+NativeClient+';Persist Security Info=False;User ID='+loginuser+';pwd='+LoginPassword+ ';Initial Catalog='+loginuser+';Data Source='+logindatabase;
  end else begin
    LoginPassword := 'log';
    sfile := gf.exepath + '\'+LoginUser+'.pwd';
    i := 0;
    insid := '';
    if fileexists(sfile) then begin
      LoginPassword := '';
      with tstringlist.create do begin
        LoadFromFile(sfile);
        insid := trim(text) ;
        free;
      end;
    end else if (connection.PWord <> '') and gf.Isnumeral(connection.PWord) then
      insid := connection.PWord;
    if insid <> '' then
    begin
      i := strtoint(copy(insid,1,4));
      delete(insid,1,4);
      i := i * 4 ;
      cpuid := copy(insid,1,i);
      delete(insid,1,i);
      i := length(insid);
      delete(insid,i-3,i);
      LoginPassword := Get_Password(insid,cpuid);
    end;
    connection.Ado.ConnectionString := 'Provider='+NativeClient+';Persist Security Info=False;User ID='+loginuser+';pwd='+LoginPassword+ ';Initial Catalog='+loginuser+';Data Source='+logindatabase;
  end;
  connection.Ado.LoginPrompt := false;
  starttime:=now();
  gf.dodebug.Msg('MsSqlConnect connection starts...');
  connection.Ado.Connected := true;
  gf.dodebug.Msg('MsSqlConnect connection end...');
  gf.dbtimetaken := gf.dbtimetaken + millisecondsbetween(now(),starttime);
 Except on e:Exception do
  ErrorMsg:=e.Message;
 End;
 if ErrorMsg<>'' then begin
   gf.dodebug.Msg('Error in Ms Sql connection  : ' + ErrorMsg);
   if MsWinAuth then begin
     if Lowercase(Copy(Trim(Errormsg),1,21))='login failed for user'then
       ErrorMsg:='Current windows user does not have admin privilege. Alternately you may try with DB login credentials, if you have. '
                 +'Otherwise please contact your administrator.';
   end else
   begin
     if pos('provider',Lowercase(Errormsg)) > 0 then
     begin
      if MsDbverno = '2008' then
         ErrorMsg:= ErrorMsg + ' - SQL Server Native Client 10.0 needs to be installed in this system'
      else if MsDbverno = '2012' then
         ErrorMsg:= ErrorMsg + ' - SQL Server Native Client 11.0 needs to be installed in this system'
      else ErrorMsg:= ErrorMsg + ' - ODBC Driver for SQL Server needs to bo installed in this system';
     end;
   end;
   gf.dodebug.Msg('Error in Ms Sql connection  : ' + ErrorMsg);
   raise Exception.Create(ErrorMsg);
 end;
end;

function TDBManager.ComputerName():String;
var
  ComputerName: Array [0 .. 256] of char;
  Size: DWORD;
begin
  Size := 256;
  Windows.GetComputerName(ComputerName, Size);
  Result := ComputerName;
end;


procedure TDBManager.PostGreConnect;
 var sfile,insid,cpuid,ErrorMsg :String;
  i : integer;
  starttime:TDateTime;
  uname : String;
begin
  try
    gf.dodebug.Msg('PostGreConnect starts...');
    if connection.projectname = '' then begin
      ErrorStr := 'Improper Project Name';
      Raise Exception.create(Errorstr);
    end;
    if connection.dbname = '' then begin
      ErrorStr := 'Improper Database Name';
      Raise Exception.create(Errorstr);
    end;
    LoginUser := connection.ProjectName;
    LoginDatabase := connection.DbName;
    if gf.dbmflag = 'axpman' then
       LoginPassword := Connection.PWord
    else begin
      i := pos('\',LoginUser);
      if i > 0 then
      begin
        uname := copy(LoginUser,1,i-1);
      end else uname := LoginUser;
      LoginPassword := 'log';
      if (connection.PWord <> '') and gf.Isnumeral(connection.PWord) then
        insid := connection.PWord
      else
      begin
        sfile := gf.exepath + '\'+uname+'.pwd';
        i := 0;
        insid := '';
        if fileexists(sfile) then begin
          LoginPassword := '';
          with tstringlist.create do begin
            LoadFromFile(sfile);
            insid := trim(text) ;
            free;
          end;
        end;
      end;
      if insid <> '' then
      begin
        i := strtoint(copy(insid,1,4));
        delete(insid,1,4);
        i := i * 4 ;
        cpuid := copy(insid,1,i);
        delete(insid,1,i);
        i := length(insid);
        delete(insid,i-3,i);
        LoginPassword := Get_Password(insid,cpuid);
      end;
    end;

     i := pos('\',connection.ConnectionName);
     if i > 0 then
     begin
       connection.ConnectionName := copy(connection.ConnectionName,1,i-1);
     end;

     connection.dbx.name := connection.ConnectionName;
     connection.dbx.connectionname := 'Devart PostgreSQL';
     connection.dbx.drivername := 'DevartPostgreSQL';
     connection.dbx.GetDriverFunc := 'getSQLDriverPostgreSQL';
     connection.dbx.LibraryName := gf.exepath +'\dbexppgsql40.dll';
     connection.dbx.VendorLib :=   gf.exepath +'\dbexppgsql40.dll';
     connection.dbx.LoginPrompt := false;
     connection.dbx.Params.Clear;
     connection.dbx.BeforeConnect := PostGresBeforeConnect;
     if connection.dbx.Connected then
       connection.dbx.Connected := False;
     connection.dbx.Connected := true;
  except on e:exception do
    begin
      ErrorMsg := e.Message;
      gf.dodebug.Msg('Error in PostGreConnect. Error: '+ErrorMsg);
      if pos('Unable to load dbexppgsql40.dll (ErrorCode 126)',ErrorMsg) > 0 then
      begin
        try
          gf.dodebug.Msg('Trying PostGreConnect again...');
          connection.dbx.Params.Values['LibraryName'] := gf.exepath +'\dbexppgsql40.dll';
          connection.dbx.Params.Values['VendorLib'] :=   gf.exepath +'\dbexppgsql40.dll';
          connection.dbx.Connected := true;
          ErrorMsg := '';
        except on e:exception do
          begin
            ErrorMsg := e.Message;
            gf.dodebug.Msg('Error in PostGreConnect. Error: '+ErrorMsg);
          end;
        end;
      end;
    end;
  end;
  if ErrorMsg<>'' then begin
    raise Exception.Create(ErrorMsg);
  end;
  gf.dodebug.Msg('PostGreConnect ends...');
end;

(*
 if database , username & schemaname are same then we can give any one value in DBusername
 if database & schemanames are same but username is diff  then we have to give DBusername like username\database(or)schemaname
 if database , username , schemaname are different the we have to give DBusername like username\database\schemaname

 it is a casesensitive ** so if we have Uppercase Database name / SchemaName then we will get error because
 in ConnecttoDataBase procedure we are making connection name string to lowercase.
*)

Procedure TDBManager.PostGresBeforeConnect(Sender:TObject);
var i : integer;
begin
  pg_DbName := '';
  pg_SchemaName := '';
  With Sender as TSQLConnection do begin
    pg_DbName := LoginUser;
    i := pos('\',LoginUser);
    if i > 0 then
    begin
      LoginUser := copy(LoginUser,1,i-1);
      delete(pg_DbName,1,i);
      i := pos('\',pg_DbName);
      if i > 0 then
      begin
         pg_SchemaName := pg_DbName;
         pg_DbName := copy(pg_DbName,1,i-1);
         delete(pg_SchemaName,1,i);
      end;
    end else begin
      if pg_DbName <> 'postgres' then
        pg_DbName := 'axpertdb';
    end;
//    pg_DbName := lowercase(pg_DbName);
    pg_DbName := pg_DbName;
    if pg_SchemaName <> '' then Params.Values['SchemaName'] := pg_SchemaName;
    Params.Values['User_Name'] := LoginUser;
    Params.Values['Password'] := LoginPassword;
    Params.Values['SchemaName'] := LoginUser;
    Params.Values['Database'] := pg_DbName;
    Params.Values['HostName'] := LoginDatabase;
    if (gf.dbmflag = 'axpman') or (gf.dbmflag = 'axpmandef') then
      Params.Values['UnpreparedExecute'] := 'True' ;
  end;
end;

procedure TDBManager.Disconnect(ConnectionName:String);
var i:integer;
begin
  try
    ConnectionName := trim(connectionname);
    Connection := Connect.GetConnectionRecord(ConnectionName, i);
    if i < 0 then exit;
    gf.DoDebug.Msg('Disconnecting from db ' + connectionname);
    if Connection.driver = 'dbx' then begin
      if Connection.Dbx.Connected then
      begin
         gf.DoDebug.Msg('Keep Connection setting false');
         Connection.Dbx.KeepConnection := False;
         gf.DoDebug.Msg('Disconnecting...');
         Connection.Dbx.Connected := false;
         gf.DoDebug.Msg('Disconnected...');
      end else  gf.DoDebug.Msg('Not connected...');
      if (connection.DbType = 'oracle') or (connection.DbType = 'postgre') then
      begin
        connection.dbx.Params.Clear;
        connection.dbx.name := '';
        gf.dodebug.Msg('Dbx name = '+connection.dbx.Name);
        connection.dbx.connectionname := '';
        gf.dodebug.Msg('ConnectionName  = '+connection.dbx.ConnectionName);
        connection.dbx.drivername := '';
        gf.dodebug.Msg('DriverName  = '+connection.dbx.DriverName);
        connection.dbx.GetDriverFunc := '';
        gf.dodebug.Msg('GetDriverFunc  = '+connection.dbx.GetDriverFunc);
        connection.dbx.LibraryName := '';
        gf.dodebug.Msg('LibraryName  = '+connection.dbx.LibraryName);
        connection.dbx.VendorLib := '';
        gf.dodebug.Msg('VendorLib  = '+connection.dbx.VendorLib);
      end;
      Connection.Dbx.Destroy;
      Connection.Dbx := nil;
    end else if Connection.driver = 'ado' then begin
      gf.DoDebug.Msg('Disconnecting...');
      if Connection.ado.Connected then Connection.ado.connected := false;
      Connection.ado.Destroy;
      Connection.ado := nil;
      gf.DoDebug.Msg('Disconnected...');
    end;
    gf.DoDebug.Msg('Successfully disconnected from db ' + connectionname);
  except on e:exception do
    gf.DoDebug.Msg('Disconnect error : ' + e.Message)
  end;
end;

procedure TDBManager.StartTransaction(ConnectionName:String);
var i:integer;
    s : String;
    conn : Boolean;
begin
  gf.dodebug.Msg('Starting Transaction');
  gf.dodebug.Msg('Start Transaction Status : ' + booltostr(InTransaction));
  Connectionname := trim(Connectionname);
  Connection := Connect.GetConnectionRecord(Connectionname, i);
  if i < 0 then begin
    ErrorStr := 'Invalid project name in StartTransaction.';
    Raise Exception.create(ErrorStr);
  end;
  conn := true;
  while conn do
  begin
    try
      if Connection.Driver = 'ado' then begin
        connection.ADO.BeginTrans;
      end else if connection.driver = 'dbx' then begin
//        if Lowercase(connection.dbtype)='postgre' then
//           exit
//        else Transaction := connection.dbx.BeginTransaction;

        Transaction := connection.dbx.BeginTransaction;
      end;
      conn := false;
    except on e:exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\StartTransaction - '+e.Message);
        if gf.IsService then
           conn := false
        else begin
          s := lowercase(e.Message);
          if (pos('shared',s) > 0) or (pos('memory',s) > 0) or (pos('pipe',s) > 0) or (pos('catastrophic',s) > 0)
          or (pos('oracle',s) > 0) or (pos('connect',s) > 0) or (pos('communication',s) > 0) or (pos('link',s) > 0) then
             conn := Connection.ReConnectToDatabase
          else conn := false;
        end;
      end;
    end;
  end;
  gf.dodebug.Msg('End of Starting Transaction');
  gf.dodebug.Msg('Start Transaction Status : ' + booltostr(InTransaction));
end;

procedure TDBManager.Commit(ConnectionName:String);
var i:integer;
begin
  gf.dodebug.Msg('Committing Transaction');
  gf.dodebug.Msg('Committing Transaction Status : ' + booltostr(InTransaction));
  if Lowercase(connection.dbtype)<>'oracle' then
     if not InTransaction then exit;
  try
    Connectionname := trim(Connectionname);
    Connection := Connect.GetConnectionRecord(ConnectionName, i);
    if i < 0 then begin
      ErrorStr := 'Invalid project name in DbAccess.SetProjectName.';
      Raise Exception.create(ErrorStr);
    end;
    if Connection.Driver = 'ado' then begin
      connection.ado.committrans;
    end else if connection.driver = 'dbx' then
    begin
//      if Lowercase(connection.dbtype)='postgre' then
//         exit
//      else connection.dbx.CommitFreeAndNil(Transaction);
      connection.dbx.CommitFreeAndNil(Transaction);
    end;
  except on e:exception do
  begin
    if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\Commit - '+e.Message);
    if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\Commit - '+ booltostr(InTransaction));
    raise Exception.Create(e.Message);
  end;
  end;
  gf.dodebug.Msg('End of Committing Transaction');
  gf.dodebug.Msg('Committing Transaction Status : ' + booltostr(InTransaction));
end;

procedure TDBManager.RollBack(ConnectionName:String);
var i:integer;
begin
  gf.dodebug.Msg('RollBack Transaction');
  gf.dodebug.Msg('RollBack Transaction Status : ' + booltostr(InTransaction));
  connectionname := trim(ConnectionName);
  Connection := Connect.GetConnectionRecord(ConnectionName, i);
  if Connection = nil then exit;
  if i < 0 then begin
    ErrorStr := 'Invalid project name in DbAccess.SetProjectName.';
    Raise Exception.create(ErrorStr);
  end;
  if (Connection.Driver = 'ado') and (connection.ado.InTransaction) then begin
    connection.ado.rollbacktrans;
  end else if (connection.driver = 'dbx') and (connection.dbx.InTransaction) then
  begin
//    if Lowercase(connection.dbtype)='postgre' then exit
//    else connection.dbx.RollbackFreeAndNil(Transaction);
   connection.dbx.RollbackFreeAndNil(Transaction);
  end;
  gf.dodebug.Msg('End of RollBack Transaction');
  gf.dodebug.Msg('RollBack Transaction Status : ' + booltostr(InTransaction));
end;

function TDBManager.GetServerDateTime : TDateTime;
  var i : integer;
  Ansis : string;
begin
  if (ServerDateTime <> 0) and (gf.IsService) then
  begin
    result := ServerDateTime;
    exit;
  end;
  i:=1;
  while true do begin
    try
      wdt.open;
      result := wdt.cds.fieldbyname('sdt').AsDateTime;
      wdt.Close;
      if gf.timezone_diff <> 0 then result := IncMinute(result,gf.timezone_diff);
      break;
    except on e:exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\GetServerDateTime - '+e.Message);
        if (i=10) or (gf.RaiseErrOnDBReconnect) then
          raise;
        inc(i);
      end;
    end;
  end;
end;

function TDBManager.GetXDS(x:txds):TXDS;
begin
  if not assigned(x) then
    result := txds.create('xds'+floattostr(gf.generatenumber), nil, connection,gf)
  else result := x;
end;

function TDbManager.GetData(x: TXDS; table, where:String):TXDS;
begin
  if not assigned(x) then
    result := txds.create('xds'+floattostr(gf.generatenumber), nil, connection,gf)
  else begin
    result := x;
    result.close;
  end;
  //if dbase='access' then table:=quotedstr(table);
  result.sqltext := 'select * from '+table+' where '+where;
end;


function TDbManager.SetDefaults:String;
var basecurrid: Extended;
    q : TXDS;
    xml : IXMLDocument;
    n,x,d : IXMLNode;
    s,w: String;
    dd,mm,yy : word;
    stm : TStringStream ;
Begin
  result:='';
  if gf.dbmflag = 'axpman' then exit;
  q:= TXDS.Create('control', nil, connection,gf);
  if Connection.DbType = 'postgre' then
     if LoginUser <> '' then
     begin
      if gf.postgre_search_path = '' then
      begin
        n := gf.localprops.ChildNodes.FindNode(LoginUser);
        if assigned(n)  then gf.postgre_search_path := vartostr(n.NodeValue);
      end;
      if gf.postgre_search_path <> '' then
      begin
        if pg_SchemaName <> '' then
          q.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',' + pg_SchemaName + ',' + gf.postgre_search_path + ',public'
        else if pg_DbName <> '' then
          q.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',' +pg_DbName + ',' + gf.postgre_search_path + ',public'
        else
          q.sqltext := 'SET SEARCH_PATH TO ' + LoginUser + ',' + gf.postgre_search_path + ',public';
        q.execsql;
      end;
     end;
  try
  stm := TStringStream.Create('');
  w:= gf.sqllower+'(name)='+lowercase(quotedstr('app'));
  ReadMemo('props', 'axprops' , w, stm);
  if stm.Size=0 then gf.AppXML :=LoadXMLData('<root/>')
  else gf.AppXML  := LoadXMLData(trim(stm.DataString));
  FreeAndNil(stm);
  except on e:exception do
    gf.dodebug.Msg('Error in getting axpropd '+ gf.AppXML.DocumentElement.XML);
  end;
  gf.dodebug.Msg('axprops xml  = '+ gf.AppXML.DocumentElement.XML);
  d:=gf.AppXML.DocumentElement;
  if gf.AppXML.DocumentElement.ChildNodes.Count>0 then  begin
    n:=gf.AppXML.DocumentElement.Childnodes[0];
    gf.globalprops:=n.CloneNode(true);
    x := n.childnodes.FindNode('mail');
    if x <> nil then gf.mailprops := x.clonenode(true);
  end;
  if connection.DbType = 'ms sql' then begin
    if d.HasAttribute('unicode') then begin
       if LowerCase(VartoStr(d.Attributes['unicode'])) = 'yes' then
          gf.MsSql_Unicode_Char := 'N'
       else
          gf.MsSql_Unicode_Char := '';
    end;
  end;
  n:=d.ChildNodes.FindNode('props');
  if not assigned(n) then exit;

  //Added on 24/06/2013
  x := n.ChildNodes.FindNode('readonlyprops');
  if assigned(x) then
  begin
    gf.Readonly_FontColor := VartoStr(x.Attributes['readonly_fontcolor']);
    gf.Readonly_BgColor := VartoStr(X.Attributes['readonly_bgcolor']);
  end else begin
    gf.Readonly_FontColor := 'clBlack';
    gf.Readonly_BgColor := 'clWindow';
  end;

  if trim(gf.Readonly_FontColor) = '' then  gf.Readonly_FontColor := 'clBlack';
  if  trim(gf.Readonly_BgColor) = '' then  gf.Readonly_BgColor := 'clWindow';

  x := n.ChildNodes.FindNode('showchngpwd');
  if assigned(x) then
  begin
    if vartostr(x.NodeValue) = 'F' then
      gf.ShowChangePwd := False
    else
      gf.ShowChangePwd := True;
  end else
    gf.ShowChangePwd := True;
  x:=n.ChildNodes.FindNode('envvar');
  if not assigned(x) then
    x := n.Addchild('envvar');
  n := x.ChildNodes.FindNode('siteno');
  if not assigned(n) then
    n := x.AddChild('siteno');
  if vartostr(n.NodeValue) = '' then
    connection.SiteNo := 1
  else
    connection.SiteNo := strtoint(n.NodeValue);
  n := x.ChildNodes.FindNode('currency');
  if not assigned(n) then
    n := x.AddChild('currency');
  gf._maincurr:= vartostr(x.ChildNodes['currency'].NodeValue);
//  DateSeparator := '/';
  n := x.ChildNodes.FindNode('millions');
  if not assigned(n) then
    n := x.AddChild('millions');
  if lowercase(vartostr(x.ChildNodes['millions'].NodeValue))='t' then
    gf.Millions:=true
  else
    gf.millions:=false;
  gf._millions := vartostr(x.ChildNodes['millions'].NodeValue);

  n := x.ChildNodes.FindNode('postauto');
  if not assigned(n) then
    n := x.AddChild('postauto');
  if lowercase(vartostr(x.ChildNodes['postauto'].NodeValue))='t' then
    gf.PostAutoGen:=true
  else
    gf.PostAutoGen:=false;

   n := x.ChildNodes.FindNode('finyrst');
  if not assigned(n) then
    n := x.AddChild('finyrst');

  gf.ShortDateFormat.DecimalSeparator := '.';

  if vartostr(n.NodeValue) = '' then
  begin
//    s := formatdatetime(gf.ShortDateFormat.ShortDateFormat,ServerDateTime);
//    gf.finyrst := strtodate(s);
    gf.finyrst := ServerDateTime;
  end else
  begin
    s := n.NodeValue;
    dd := strtoint(copy(s,1,2));
    mm := strtoint(copy(s,4,2));
    yy := strtoint(copy(s,7,4));
//    gf.finyrst := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yy,mm,dd)));
    try
       gf.dodebug.Msg('fs : ' + s);
       gf.dodebug.Msg('ft : ' + gf.ShortDateFormat.ShortDateFormat);
       gf.finyrst := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yy,mm,dd)));
    except
       try
         gf.finyrst := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yy,dd,mm)))
       except
       end;
    end;
  end;

  n := x.ChildNodes.FindNode('finyred');
  if not assigned(n) then
    n := x.AddChild('finyred');

  if vartostr(n.NodeValue) = '' then
//    gf.finyred := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat, ServerDateTime))
    gf.finyred :=  ServerDateTime
  else
  begin
    s := n.NodeValue;
    dd := strtoint(copy(s,1,2));
    mm := strtoint(copy(s,4,2));
    yy := strtoint(copy(s,7,4));
    try
       gf.dodebug.Msg('fe : ' + s);
       gf.dodebug.Msg('ft : ' + gf.ShortDateFormat.ShortDateFormat);
       gf.finyred := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yy,mm,dd)));
    except
       try
         gf.finyred := strtodate(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yy,dd,mm)))
       except
       end;
    end;
  end;


  gf.SiteNo := connection.SiteNo;
  gf.SetConnectVariables;

  s := vartostr(x.ChildNodes['oraerrfrom'].NodeValue);
  if s <> '' then
    gf.OraErrFrom := StrToFloat(s)
  else
    gf.OraErrFrom := 0;

  s := vartostr(x.ChildNodes['oraerrto'].NodeValue);
  if s <> '' then
    gf.OraErrTo := StrToFloat(s)
  else
    gf.OraErrTo := 0;

  s := vartostr(x.ChildNodes['cursep'].NodeValue);
  if s='.' then
    gf.CurrencySeparator := '.';
  if not gf.IsService then gf.AxpGetLocaleInfo;
  //Added on 01/03/2014
  n:=d.ChildNodes.FindNode('props');
  n:=n.ChildNodes.FindNode('pwdsetting');
  if assigned(n) then
  begin
    x := n.ChildNodes.FindNode('maxlogintry');
    if assigned(x) then
    begin
       if vartostr(x.NodeValue) <> '' then
          gf.pwdmaxlogintry := strtoint(vartostr(x.NodeValue));
    end;
    x := n.ChildNodes.FindNode('pwdexpdays');
    if assigned(x) then
    begin
       if vartostr(x.NodeValue) <> '' then
          gf.pwdexpdays := strtoint(vartostr(x.NodeValue));
    end;
    x := n.ChildNodes.FindNode('pwdalertdays');
    if assigned(x) then
    begin
       if vartostr(x.NodeValue) <> '' then
          gf.pwdalterdays := strtoint(vartostr(x.NodeValue));
    end;
    x := n.ChildNodes.FindNode('pwdminchars');
    if assigned(x) then
    begin
       if vartostr(x.NodeValue) <> '' then
          gf.pwdminchars := strtoint(vartostr(x.NodeValue));
    end;
    x := n.ChildNodes.FindNode('pwdprevnos');
    if assigned(x) then
    begin
       if vartostr(x.NodeValue) <> '' then
          gf.pwdprevnos := strtoint(vartostr(x.NodeValue));
    end;
    x := n.ChildNodes.FindNode('ispwdalphanum');
    if assigned(x) then
    begin
       if lowercase(vartostr(x.NodeValue))='t' then
         gf.pwdalphanum:=true
    end;
    x := n.ChildNodes.FindNode('pwdaes');
    if assigned(x) then
    begin
       if lowercase(vartostr(x.NodeValue))='t' then
         gf.pwd_AES:=true
    end;
  end;

  gf.GlobalSerialNo := 1;
  xml := nil; n := nil; x:= nil; d:=nil;
  q.close;
  q.sqltext := 'SELECT Constraint_Name FROM AXCONSTRAINTS where 1=2';
  try
    q.open;
    gf.AxConstraintExist := True;
    q.close;
    q.free;
  Except
    On E:Exception do begin
       if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\SetDefaults - '+e.Message);
      gf.AxConstraintExist := False;
      q.close;
      q.free;
    end;
  end;
End;

//Routines related to writing memo fields

function TDbManager.FileSplit(FileName:String; MaxCount:integer):integer;
begin
  assignfile(fsource, filename);
  reset(fsource);
  result:=1;
  blobfiles.clear;
  while true do begin
    if gf.isservice then
      blobfiles.add(gf.startpath+'\axp'+gf.getnumber)
    else
      blobfiles.add(gf.startpath+'temp\axp'+gf.getnumber);
    assignfile(ftarget, blobfiles[blobfiles.count-1]);
    rewrite(ftarget);
    if not writetofile(maxcount) then begin
      closefile(ftarget);
      break;
    end;
    closefile(ftarget);
    inc(result);
  end;
  closefile(fsource);
end;

function TDbManager.WriteToFile(MaxCount:Integer):boolean;
const bufsize=5000;
var pTemp : pointer;
    buf : TByteDynArray;
    rcount, wcount, tcount : integer;
begin
  result := false;
  setlength(buf, bufsize);
  ptemp:=@buf[0];
  tcount:=0;
  while true do begin
    BlockRead(fsource, pTemp^, bufsize , rcount );
    BlockWrite(ftarget, pTemp^, rcount);
    tcount := tcount+rcount;
    if (rcount<>bufsize) or (tcount>=maxcount) then break;
  end;
  buf:=nil;
  result := rcount=bufsize;
end;

procedure TDbManager.WriteMemo(fname, table, where, filename: String);
var source, target, x : TXDS;
     wstr, dtype : String;
     i, j : integer;
begin
  blobfiles.clear;
  filesplit(filename, 30000);

  x:=getxds(nil);
  x.sqltext:='delete from '+table+' where '+where+' and blobno>1';
  x.execsql;
  x.sqltext:='update '+table+' set blobno=1 where '+where;
  x.execsql;

  source:=getxds(nil);
  source.buffered := true;
  source.CDS.CommandText:='select * from '+table+' where '+where;
  source.open;
  target:=getxds(nil);
  if blobfiles.count=1 then begin
    wstr := where + ' and blobno=1';
    target.WriteMemo(fname, table, wstr, filename);
    deletefile(pchar(blobfiles[0]));
  end else begin
    for i:=0 to blobfiles.count-1 do begin
      for j:=0 to source.CDS.Fields.Count-1 do begin
        if source.CDS.Fields[j].IsBlob then continue;
        if source.CDS.fields[j].DataType in [ftDateTime, ftTimeStamp, ftDate] then
        dtype := 'd' else dtype:='c';
        x.Submit(source.CDS.fields[j].FieldName, source.CDS.Fields[j].AsString, dtype);
      end;
      x.Submit('blobno', inttostr(i+1), 'n');
      wstr := where + ' and blobno='+inttostr(i+1);
      x.AddOrEdit(table, wstr);
      target.WriteMemo(fname, table, wstr, blobfiles[i]);
      deletefile(pchar(blobfiles[i]));
    end;
  end;
  target.Free;

  source.close;
  source.Free;
  x.Free;
end;


procedure TDbManager.WriteMemo(fname, table, where, filename: String;Append:boolean);
var source, target, x : TXDS;
     wstr, dtype : String;
     i, j: integer;
begin
  blobfiles.clear;
  filesplit(filename, 30000);

  x:=getxds(nil);
  if not Append then begin
   x.sqltext:='delete from '+table+' where '+where+' and blobno>1 ';
   x.execsql;
   x.sqltext:='update '+table+' set blobno=1 where '+where;
   x.execsql;
  end;
  x.close;
  source:=getxds(nil);
  source.buffered := true;
  source.CDS.CommandText:='select * from '+table+' where '+where;
  source.open;
  target:=getxds(nil);
  if blobfiles.count=1 then begin
    wstr := where + ' and blobno=1';
    target.WriteMemo(fname, table, wstr, filename);
    deletefile(pchar(blobfiles[0]));
  end else begin
    for i:=0 to blobfiles.count-1 do begin
      for j:=0 to source.CDS.Fields.Count-1 do begin
        if source.CDS.Fields[j].IsBlob then continue;
        if source.CDS.fields[j].DataType in [ftDateTime, ftTimeStamp, ftDate] then
        dtype := 'd' else dtype:='c';
        x.Submit(source.CDS.fields[j].FieldName, source.CDS.Fields[j].AsString, dtype);
      end;
      x.Submit('blobno', inttostr(i+1), 'n');
      wstr := where + ' and blobno='+inttostr(i+1);
      x.AddOrEdit(table, wstr);
      target.WriteMemo(fname, table, wstr, blobfiles[i]);
      deletefile(pchar(blobfiles[i]));
    end;
  end;
  target.Free;
  source.close;
  source.Free;
  x.Free;
end;

procedure TDbManager.ReadMemo(fname, table, where, filename: String);
var x:txds;
  s,fldname : String;
begin
  if Connection.MsDBverno ='Above 2012' then fldname := 'cast(' + fname + ' as text) as ' +  fname
  else fldname := fname;
  assignfile(ftarget, filename);
  s := filename + '.tmp';
  rewrite(ftarget);
  try
    x:=getxds(nil);
    x.sqltext:='select '+fldname+' from '+table+' where '+where+' order by blobno';
    x.open;
    if x.isempty then
    begin
      closefile(ftarget);
      x.close;
      x.Free;
      exit;
    end;
    while not x.eof do begin
      x.ReadMemo(fname,s);
      assignfile(fsource, s);
      reset(fsource);
      writetofile(30000);
      closefile(fsource);
      x.next;
    end;
    closefile(ftarget);
    if fileExists(s) then sysutils.deleteFile(s);
  except on e:Exception do
    begin
      if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\ReadMemo - '+e.Message);
      closefile(ftarget);
    end;
  end;
  x.close;
  FreeAndNil(x);
end;

procedure TDbManager.ReadMemo(fname, table, where , prmval , prmtype : String ; stm : TStringStream);
var x:txds;
  s,v : String;
  st : TStringStream;
  i : integer;
  fldname : String;
begin
  if assigned(stm) then
  begin
    FreeAndNil(stm);
    stm := TStringStream.Create('',TEncoding.UTF8);
    stm.Position := 0;
  end;
  if (table<>'tstructs') and (table<>'axpertreports') and (Connection.MsDBverno ='Above 2012') then fldname := 'cast(' + fname + ' as text) as ' +  fname
  else fldname := fname;
  x:=getxds(nil);
  i := 1;
  x.sqltext:='select '+fldname+' from '+table+' where '+where+' order by blobno';
  gf.dodebug.Msg('Sql : ' + x.sqltext);
  gf.dodebug.Msg('Paramval : ' + prmval);
  gf.dodebug.Msg('ParamTYpe : ' + prmtype);
  gf.dodebug.Msg('Param List : ' + x.GetParamNames.Text);
  if pos(',',prmval) > 0 then
  begin
    while True do
    begin
       v := gf.GetNthString(prmval,i);
       if v = '' then break;
       if prmtype[i] = 'c' then
          x.parambyname(x.GetParamNames.Strings[i-1]).AsString := v
       else if prmtype[i] = 'n' then
          x.parambyname(x.GetParamNames.Strings[i-1]).AsFloat := strtofloat(v)
       else
          x.parambyname(x.GetParamNames.Strings[i-1]).AsDateTime := strtodatetime(v);
       i := i + 1;
    end;
  end else
  begin
     if prmtype[i] = 'c' then
        x.parambyname(x.GetParamNames.Strings[i-1]).AsString := prmval
     else if  prmtype[i] = 'n' then
        x.parambyname(x.GetParamNames.Strings[i-1]).AsFloat := strtofloat(prmval)
     else
        x.parambyname(x.GetParamNames.Strings[i-1]).AsDateTime := strtodatetime(prmval);
  end;
  x.open;
  if x.isempty then
  begin
    x.close;
    x.Free;
    exit;
  end;
  while not x.eof do begin
    st := TStringStream.Create('',TEncoding.UTF8);
    x.ReadStream(fname,table,st);
    if st.Size > 0 then
    begin
      st.Position := 0;
      stm.CopyFrom(st,st.Size) ;
    end;
    st.Free;
    x.next;
  end;
  x.close;
  x.Free;
end;

procedure TDbManager.ReadMemo(fname, table, where: String; stm : TStringStream);
var x:txds;
  st : TStringStream;
  fldname : String;
begin
  if not ForRapidImport then begin
    if assigned(stm) then
    begin
      FreeAndNil(stm);
      stm := TStringStream.Create('',TEncoding.UTF8);
      stm.Position := 0;
    end;
  end else
    stm.Position := 0;
  x := nil;
  st := nil;
  if Connection.MsDBverno ='Above 2012' then fldname := 'cast(' + fname + ' as text) as ' +  fname
  else fldname := fname;
  x:=getxds(nil);
  x.sqltext:='select '+fldname+' from '+table+' where '+where+' order by blobno';
  x.open;
  if x.isempty then
  begin
    x.close;
    FreeAndNil(x);
    exit;
  end;
  while not x.eof do begin
    st := TStringStream.Create('',TEncoding.UTF8);
    st.Position := 0;
    x.ReadStream(fname,table,st);
    if st.Size > 0 then
    begin
      st.Position := 0;
      stm.CopyFrom(st,st.Size) ;
    end;
    FreeAndNil(st);
    x.next;
  end;
  x.close;
  FreeAndNil(x);
end;


procedure TDbManager.WriteMemo(fname, table, where : String ; stm : TStringStream ; isblob:boolean);
var x:txds;
begin
  x:=getxds(nil);
  x.sqltext:='select '+fname+' from '+table+' where '+where+' order by blobno';
  x.open;
  if x.isempty then
  begin
    closefile(ftarget);
    x.close;
    x.Free;
    exit;
  end;
  x.WriteStream(fname,table,where,stm,isblob);
  x.close;
  x.Free;
end;

procedure TDbManager.WriteCLOB(Fieldnm,Tablenm,Whr,FieldVal:String);
var Stream:TStringStream;
  Errstr :String;
  x1:Txds;
begin
  try
    Errstr :='';
    x1:=getxds(nil);
    x1.close;
    Stream :=TStringStream.Create(FieldVal);
    if Stream.Size>0 then
      x1.WriteStream(Fieldnm,Tablenm,Whr,Stream);

    if Assigned(Stream) then  freeandnil(Stream);
    if Assigned(x1) then begin
      x1.close;
      freeandnil(x1);
    end;
   Except on e:Exception do
    Errstr:=e.Message;
   end;
   if Errstr<>'' then begin
    if Assigned(Stream) then freeandnil(Stream);
    if Assigned(x1) then begin
      x1.close;
      freeandnil(x1);
    end;
    raise Exception.Create(Errstr);
   end;
end;

procedure TDbManager.WriteBlob(fname, table, where, filename: String);
var source, target, x : TXDS;
     wstr, dtype : String;
     i, j : integer;
begin
  blobfiles.clear;
  filesplit(filename, 30000);

  x:=getxds(nil);
  x.sqltext:='delete from '+table+' where '+where+' and blobno>1';
  x.execsql;
  x.sqltext:='update '+table+' set blobno=1 where '+where;
  x.execsql;

  source:=getxds(nil);
  source.buffered := true;
  source.CDS.CommandText:='select * from '+table+' where '+where;
  source.open;

  target:=getxds(nil);
  if blobfiles.count=1 then begin
    wstr := where + ' and blobno=1';
    target.WriteBlob(fname, table, wstr, filename);
    deletefile(pchar(blobfiles[0]));
  end else begin
    for i:=0 to blobfiles.count-1 do begin
      for j:=0 to source.CDS.Fields.Count-1 do begin
        if source.CDS.Fields[j].IsBlob then continue;
        if source.CDS.fields[j].DataType in [ftDateTime, ftTimeStamp, ftDate] then
        dtype := 'd' else dtype:='c';
        x.Submit(source.CDS.fields[j].FieldName, source.CDS.Fields[j].AsString, dtype);
      end;
      x.Submit('blobno', inttostr(i+1), 'n');
      wstr := where + ' and blobno='+inttostr(i+1);
      x.AddOrEdit(table, wstr);
      target.WriteBlob(fname, table, wstr, blobfiles[i]);
      deletefile(pchar(blobfiles[i]));
    end;
  end;
  target.Free;
  source.close;
  source.Free;
  x.Free;
end;

procedure TDbManager.ReadBlob(fname, table, where, filename: String);
var x:txds;
    s : String;
begin
  assignfile(ftarget, filename);
  s := filename + '.tmp';
  rewrite(ftarget);
  x:=getxds(nil);
  x.sqltext:='select '+fname+' from '+table+' where '+where+' order by blobno';
  x.open;
  if x.isempty then
  begin
    closefile(ftarget);
    x.close;
    x.Free;
    exit;
  end;
  while not x.eof do begin
    x.ReadBlob(fname,s);
    assignfile(fsource,s);
    reset(fsource);
    writetofile(30000);
    closefile(fsource);
    x.next;
  end;
  closefile(ftarget);
  if fileExists(s) then sysutils.deleteFile(s);
  x.close;
  x.Free;
end;

function TDbManager.CreateSessionId:String;
var y,m,d,h,mn,s,ms:word;
begin
  result := '';
  decodedatetime(now, y, m, d, h, mn, s, ms);
  result := gf.username;
  result:=result+inttostr(y)+gf.leftpad(inttostr(m),2,'0')+gf.leftpad(inttostr(d),2,'0');
  result:=result+gf.leftpad(inttostr(h),2,'0')+gf.leftpad(inttostr(mn),2,'0');
  result:=result+gf.leftpad(inttostr(s),2,'0');
  result:=result+gf.leftpad(inttostr(ms),3,'0');
end;

function TDBManager.InTransaction: boolean;
begin
  if Connection.Driver = 'ado' then begin
    result:=connection.ado.InTransaction
  end else if connection.driver = 'dbx' then begin
    result:=connection.dbx.InTransaction;
  end;
end;

procedure TDBManager.update_errorlog(sname,errmsg : String) ;
  var q : TXDS;
  sqltext,dbtype,s : String;
begin
  if not assigned(Connection) then exit;
  if gf.Remotelogin then
    dbtype := lowercase(gf.remotedbType)
  else
    dbtype := lowercase(Connection.DbType);
  s := copy(gf.username,1,14);
  if s = '' then s := copy(gf.GetUserFromWindows,1,14);
  errmsg := copy(errmsg,1,249);
  q:=GetXDS(nil);
  q.buffered := true;
  sqltext := 'insert into axerrorlog values(' + quotedstr(s) + ',' + gf.findandreplace(gf.dbdatestring, ':value', gf.ConvertToDBDateTime(dbtype,getserverdatetime)) + ',' + quotedstr(sname) + ',' + quotedstr(gf.execActName) + ',' + quotedstr(errmsg) + ')' ;
  q.CDS.CommandText:=sqltext;
  try
    if gf.Remotelogin then
       q.open
    else q.execsql;
  except on e:exception do
    begin
        if assigned(gf) then begin
         gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\update_errorlog - '+e.Message);
         gf.dodebug.Msg(e.Message);
        end;
    end;
  end;
  q.close;
  q.free;
end;

function TDBManager.ChangeSqlForPagination(orgSql : String ; findCount : boolean) : String ;
  var s,orderby,sql,from,ordfld,s1,col,fld,s2 : String;
  sno, eno ,i,orderbypos : integer;
begin
  result := orgSql;
  if gf.pagination_pageno = 0 then exit;
  if gf.pagination_pageno = -1 then gf.pagination_pageno := 1;
  s := '';
  if lowercase(Connection.DbType) = 'oracle' then
  begin
    if findCount then
    begin
      s := 'select  count(*) recno from (select  a.* , rownum rnum  from ( ' + orgSql + ' )a)' ;
      result := s;
      exit;
    end;
    eno := gf.pagination_pageno * gf.pagination_pagesize;
    sno := eno - gf.pagination_pagesize + 1;
   // s := 'select  *  from (select  a.* , rownum axrnum  from ( ' + orgSql + ' )a  where rownum <= ' + inttostr(eno) + ' ) where axrnum  >= ' + inttostr(sno);
   s := 'select  *  from (select  a.* , rownum axrnum  from ( ' + orgSql + ' )a  ) where axrnum between ' + inttostr(sno) + ' and ' + inttostr(eno);
    result := s;
  end
  else if (lowercase(Connection.DbType) = 'mysql')  or (lowercase(connection.DbType) = 'postgre') then
  begin
    if findCount then
    begin
      s := 'select  count(*) recno from (select  a.*   from ( ' + orgSql + ' )a) aa' ;
      result := s;
      exit;
    end;
    {s:= 'select  * from (select  a.* , @rownum ::=  @rownum +1 as axrnum  from '+
        '( '+orgSql+') a, (SELECT @rownum ::= 0) r ) rr '+
        ' where rr.axrnum  between '+inttostr(sno)+' and '+inttostr(eno); }
    if gf.pagination_pageno = 1 then s:= orgSql + ' LIMIT ' + inttostr(gf.pagination_pagesize)
    else  begin
      eno := gf.pagination_pageno * gf.pagination_pagesize;
      sno := eno - gf.pagination_pagesize;
      s:= orgSql + ' LIMIT ' + inttostr(gf.pagination_pagesize) + ' OFFSET ' + inttostr(sno) ;
    end;
    result := s;
  end else if lowercase(Connection.DbType) = 'ms sql' then
  begin
    s1 := '';
    orgSql := gf.FindAndReplace(orgSql,#$D#$A,' ');
    orgSql := gf.RemoveExtraSpaces(orgSql);
    sql := trim(lowercase(orgSql));
    if pos('order by',sql) > 0 then
    begin
      if pos(') ft',sql) > 0 then
      begin
        orderbypos := pos('order by',sql);
        orderby := copy(sql,orderbypos + 8,length(sql));
        while pos('order by',orderby) > 0 do
        begin
           orderbypos := orderbypos + pos('order by',orderby) + 7;
           orderby := copy(sql,orderbypos + 8,length(sql));
        end;
        orderby := 'order by ' + trim(copy(orderby,1,pos(') ft',orderby)-1));
        delete(orgSql,orderbypos,length(orderby));
        delete(Sql,orderbypos,length(orderby));
      end else
      begin
        orderbypos := pos('order by',sql);
        orderby := copy(sql,orderbypos + 8,length(sql));
        while pos('order by',orderby) > 0 do
        begin
           orderbypos := orderbypos + pos('order by',orderby) + 7;
           orderby := copy(sql,orderbypos + 8,length(sql));
        end;
        delete(orgSql,orderbypos,length(sql));
        delete(Sql,orderbypos,length(sql));
      end;
      ordfld :=  orderby;
      ordfld := trim(copy(ordfld,pos('by',ordfld)+2,length(ordfld)))  ;
      col := '';
      fld := '';
      if pos(',',ordfld) > 0 then
      begin
        s := gf.GetnthString(ordfld,1);
        s := trim(s);
        if pos(' ',s) > 0 then
        begin
          i := 1;
          while true do
          begin
            s := gf.GetnthString(ordfld,i);
            if s = '' then break;
            s2 := '';
            s := trim(s);
            if pos(' ',s) > 0 then
            begin
              s2 := trim(copy(s,pos(' ',s),length(s)));
              s := copy(s,1,pos(' ',s));
            end;
            s := trim(s);
            if not IsNumeric(s) then
               if pos(s,Sql) = 0 then fld := fld + ',' +  s ;
            if pos('.',s) > 0 then
              s := copy(s,pos('.',s)+1,length(s));
            s := s + ' ' + s2;
            col := col +  s + ',';
            i := i + 1;
          end;
          delete(col,length(col),1);
        end else
        begin
          i := 1;
          while true do
          begin
            s := gf.GetnthString(ordfld,i);
            if s = '' then break;
            s := trim(s);
            if pos(' ',s) > 0 then
            begin
              s2 := trim(copy(s,pos(' ',s),length(s)));
              s := copy(s,1,pos(' ',s));
            end;
            s := trim(s);
            if not IsNumeric(s) then
               if pos(s,Sql) = 0 then fld := fld + ',' +  s ;
            if pos('.',s) > 0 then
              s := copy(s,pos('.',s)+1,length(s));
            col := col +  s + ',';
            i := i + 1;
          end;
          delete(col,length(col),1);
          s1 := s2;
        end;
      end else
      begin
        if pos(' ',ordfld) > 0 then
        begin
          s1 := copy(ordfld,pos(' ',ordfld),length(ordfld))  ;
          delete(ordfld,pos(' ',ordfld),length(ordfld));
        end;
        s := ordfld;
        if pos(s,sql) = 0 then fld :=  fld + ',' + s;
        if pos('.',s) > 0 then s := copy(s,pos('.',s)+1,length(s));
        col := s;
      end;
      if (pos(' distinct ',sql) = 0) and (fld <> '') then
      begin
        fld := fld + '  ';
        if pos(':axp_searchval1',sql) > 0 then
        begin
          delete(sql,1,21);
          i := pos(' from ',sql);
          insert(fld,orgSql,i+21);
        end else
        begin
          i := pos(' from ',sql);
          insert(fld,orgSql,i);
        end;
      end;
      col := FindActualColNames(col,Sql);
      if s1 <> '' then  col := col + ' ' + s1;
      orderby := ' order by ' + col;
    end
    else raise exception.Create('Order by clause is must for SQL pagination. Please check the defined SQL');
    if findCount then
    begin
      s := 'select count(*) recno from (select row_number() over ( ' + orderby +' ) as axrnum, * from ( ' + orgSql + ') as abc  ) xy' ;
      result := s;
      exit;
    end;
    eno := gf.pagination_pageno * gf.pagination_pagesize;
    sno := eno - gf.pagination_pagesize + 1;
    s := 'select * from (select *,row_number() over ( ' + orderby +' ) as axrnum from ( ' + orgSql + ') as abc  ) xy  where axrnum between ' + inttostr(sno) + ' and ' + inttostr(eno) + ' order by axrnum' ;
    result := s;
  end;
end;


function TDBManager.FindActualColNames(cols , sqltext : string) : String;
    var i,j : integer;
    s,s1 : String;
begin
    if pos(':axp_searchval1',sqltext) > 0 then
    begin
      delete(sqltext,1,21);
      sqltext := trim(sqltext);
    end else
    begin
      delete(sqltext,1,7);
      delete(sqltext,pos('from',sqltext),length(sqltext));
      sqltext := trim(sqltext);
    end;
    result := '';
    i := 1;
    cols := cols + ',';
    while true do
    begin
      s := gf.GetnthString(cols,i);
      if s = '' then break;
      if IsNumeric(s) then
      begin
         s1 := gf.GetnthString(sqltext,strtoint(s));
         s1 := trim(s1);
         if pos(' ',s1) > 0 then
         begin
            s1 := copy(s1,pos(' ',s1)+1,length(s1));
            if pos(' ',s1) > 0 then s1 := copy(s1,pos(' ',s1)+1,length(s1))
         end else if pos('.',s1) > 0 then
            s1 := copy(s1,pos('.',s1)+1,length(s1));
         result := result + s1 + ',' ;
      end else result := result + s + ',' ;
      i := i + 1;
    end;
    delete(result,length(result),1);
end;

function TDBManager.GetAxpertMsg(ErrMsg:String):String;
var msg,constname : String;
    cpos : integer;
    msgno : Extended;
    mxds : TXDS;
begin
  result := ErrMsg;
  constname := '';
  if connection.DbType = 'oracle' then begin
    if pos('ORA-',ErrMsg) > 0 then begin
      msg := ErrMsg;
      if (gf.OraErrFrom > 0) and (gf.OraErrTo>0) then begin
        cpos := pos('ORA-',msg);
        if cpos > 0 then begin
          msg := copy(msg,cpos+4,Length(msg));
          cpos := pos(':',msg);
          if cpos > 0 then begin
            msg := copy(msg,1,cpos-1);
            if IsNumeric(msg) then begin
              msgno := StrToFloat(msg);
              if (msgno >= gf.OraErrFrom) and (msgno <= gf.OraErrTo) then begin
                cpos := pos(':',ErrMsg);
                msg := copy(ErrMsg,cpos+1,Length(ErrMsg));
                cpos := pos('ORA-',msg);
                if cpos > 0 then
                  msg := copy(msg,1,cpos-1);
                result := msg;
                exit;
              end;
             end;
           end;
         end;
      end;
      if not gf.AxConstraintExist then exit;
      msg := ErrMsg;
      cpos := pos('constraint', msg);
      if cpos > 0  then begin
        msg := Trim(copy(msg,cpos+12,Length(msg)));
        cpos := pos('violated', msg);
        if cpos > 0 then begin
          msg := Trim(copy(msg,1,cpos-3));
          cpos := pos('.', msg);
          if cpos > 0 then begin
            constname := Trim(copy(msg,cpos+1,Length(msg)));
          end;
        end;
    end else begin
      cpos := pos('index', msg);
      if cpos > 0  then begin
        msg := Trim(copy(msg,cpos+6,Length(msg)));
        delete(msg,1,1);
        cpos := pos(' ', msg);
        if cpos > 0 then begin
          constname := Trim(copy(msg,1,cpos-1));
        end else constname := trim(copy(msg,1,length(msg)-1));
      end;
    end;
    end;
  end else if connection.DbType = 'ms sql' then begin
    if not gf.AxConstraintExist then exit;
    msg := ErrMsg;
    cpos := pos('constraint', msg);
    if cpos > 0  then begin
      msg := Trim(copy(msg,cpos+12,Length(msg)));
      cpos := pos('.', msg);
      if cpos > 0 then begin
        constname := Trim(copy(msg,1,cpos-2));
      end;
    end else begin
      cpos := pos('index', msg);
      if cpos > 0  then begin
        msg := Trim(copy(msg,cpos+6,Length(msg)));
        delete(msg,1,1);
        cpos := pos(' ', msg);
        if cpos > 0 then begin
          constname := Trim(copy(msg,1,cpos-1));
        end else constname := trim(copy(msg,1,length(msg)-1));
      end;
    end;
  end else if connection.DbType = 'mysql' then begin
    if not gf.AxConstraintExist then exit;
    msg := ErrMsg;
    cpos := pos('CONSTRAINT', msg);
    if cpos > 0  then begin
      msg := Trim(copy(msg,cpos+12,Length(msg)));
      cpos := pos(' ', msg);
      if cpos > 0 then begin
        constname := Trim(copy(msg,1,cpos-2));
      end;
    end else begin
      cpos := pos('INDEX', msg);
      if cpos > 0  then begin
        msg := Trim(copy(msg,cpos+6,Length(msg)));
        delete(msg,1,1);
        cpos := pos(' ', msg);
        if cpos > 0 then begin
          constname := Trim(copy(msg,1,cpos-1));
        end else constname := trim(copy(msg,1,length(msg)-1));
      end;
    end;
  end else if connection.DbType = 'postgre' then begin
    if not gf.AxConstraintExist then exit;
    msg := lowercase(ErrMsg);
    cpos := pos('constraint', msg);
    if cpos > 0  then begin
      msg := Trim(copy(msg,cpos+12,Length(msg)));
      cpos := pos(' ', msg);
      if cpos > 0 then begin
        constname := Trim(copy(msg,1,cpos-2));
      end;
    end else begin
      cpos := pos('index', msg);
      if cpos > 0  then begin
        msg := Trim(copy(msg,cpos+6,Length(msg)));
        delete(msg,1,1);
        cpos := pos(' ', msg);
        if cpos > 0 then begin
          constname := Trim(copy(msg,1,cpos-1));
        end else constname := trim(copy(msg,1,length(msg)-1));
      end else constname := ErrMsg;
    end;
  end;
  gf.dodebug.Msg('Constraint Name  = '+ constname);
  if constname <> ''  then begin
    mxds := GetXDS(nil);
    mxds.buffered := True;
    mxds.CDS.CommandText := 'select msg from axconstraints where '+gf.sqllower+'(constraint_name) = '+quotedstr(lowercase(constname));
    mxds.open;
    if mxds.CDS.RecordCount > 0 then
      result := mxds.CDS.FieldByName('msg').AsString;
    mxds.close;
    mxds.Free;
    mxds:=nil;
  end;


end;

Procedure TDBManager.SetGF(g:TGeneralFunctions);
begin
  if assigned(gf) then begin
     FreeAndNil(gf);
  end;
  gf := g;
  owngf := false;
end;

procedure TDBManager.CloseAllDS;
begin
  if Connection.Driver = 'ado' then begin
    //connection.ado.committrans;
  end else if connection.driver = 'dbx' then begin
    connection.dbx.CloseDataSets;
  end else begin
    //connection.bde.Commit;
  end;
end;

function TDBManager.ReConnectToDatabase : boolean;
  var firsttry : boolean;
begin
  firsttry :=true;
  while True do
  begin
    if not firsttry then
    begin
      Screen.Cursor := crDefault ;
      if messagedlg('DataBase Connection lost due to Network problem.',mtConfirmation,[mbRetry,mbAbort],0,mbRetry) <> mrRetry then
      begin
        ShowMessage('Please contact Network Administrator.');
        Result := false;
        break;
      end;
    end;
    try
       Screen.Cursor := crHourGlass ;
      if connection.DbType = 'access' then begin
        AccessConnect;
      end else if connection.DbType = 'ms sql' then begin
        connection.Ado.Connected := False;
        MsSqlConnect;
      end else if connection.DbType = 'oracle' then begin
        connection.dbx.Connected := false;
        OracleConnect;
      end else if Connect.connection.DbType = 'mysql' then begin
        connection.dbx.Connected := false;
        MySQLConnect;
      end else if connection.DbType = 'postgre' then begin
        connection.dbx.Connected := false;
        PostGreConnect;
      end;
      Result := true;
      Screen.Cursor := crDefault ;
      break;
    except on e:exception do
      begin
        if assigned(gf) then  gf.DoDebug.Log(gf.Axp_logstr+'\uDBManager\ReConnectToDatabase - '+e.Message);
        firsttry := false;
      end;
    end;
  end;
  if result = false then Application.Terminate;
end;

procedure TDBManager.WriteBlob(fname, table, where, filename: String;HugeBlob:Boolean);
var target, x : TXDS;
     wstr: string;
begin
  target:=getxds(nil);
  target.sqltext:='delete from '+table+' where '+where+' and blobno>1';
  target.execsql;
  target.close;
  target.sqltext:='update '+table+' set blobno=1 where '+where;
  target.execsql;
  wstr := where + ' and blobno=1';
  target.close;
  target.WriteBlob(fname, table, wstr, filename);
  target.close;
  freeandnil(target);
end;

procedure TDBManager.ReadBlob(fname, table, where, filename: String;HugeBlob:boolean);
var x:txds;
    s : String;
     fsource, ftarget : File of byte;
begin
  if FileExists(filename) then DeleteFile(filename);
  x:=GetXDS(nil);
  x.sqltext:='select '+fname+' from '+table+' where '+where+' order by blobno';
  x.open;
  if x.isempty then
  begin
    x.close;
    FreeAndNil(x);
    exit;
  end;
  while not x.eof do begin
    x.ReadBlob(fname,filename);
    x.next;
  end;
  x.close;
  freeandnil(x);
end;

function TDBManager.GetServerId() : string ;
  var s,w,p,cno,s1,cdb,timeid:String;
      stm,cstm : TStringStream;
      q : TXDS;
      dt : TDateTime;
begin
try
  try
    try
      gf.dodebug.Msg('Getting Server ID');
      gf.execActName := 'Login';
      ServerID := '';
      ServerIDConnectNo := '';
      ServerLicIDConnectNo := '';
      licupdatedays := 0;
      almupdatedays := 0;
      sitelicupdatedays := 0;
      liccopieddays := 0;
      gf.LicString := '';
      gf.LicDevString := '';
      gf.LicLocString := '';
      gf.UnlimitedTransIds := '';
      gf.SiteCopy := false;
      timeid := '';
      result := '';
      s :='';
      if gf.clouddb <> '' then
         cdb := gf.clouddb + '.axliccontrol'
      else cdb := 'axliccontrol';
      stm := nil;
      cstm := nil;
      q:= GetXDS(nil);
      q.SqlText := 'SELECT mlicid,alicid,dlicid,llicid,lictrans FROM ' + cdb + ' WHERE licid = ''licstring''';
      q.open;

      //trans control should be there even for site lic
      try
        stm := TStringStream.Create('');
        cstm := TStringStream.Create('');
        stm.Position := 0;
        if Connection.driver = 'dbx' then
          TBlobField(q.dbx.FieldByName('lictrans')).SaveToStream(stm)
        else
          TMemoField(q.ado.FieldByName('lictrans')).SaveToStream(stm);
        if stm.Size<>0 then
        begin
          cstm.Position := 0;
          stm.Position := 0;
          with TCompress.Create do begin
            cstm := DecompressLicStringStream(stm);
            destroy;
          end;
          cstm.Position := 0;
          gf.UnlimitedTransIds := trim(cstm.DataString);
        end;
      except on e:exception do
        begin
          gf.dodebug.Msg('Getting alic ID error : ' + e.Message);
          update_errorlog('lic',e.Message);
          result := 'iderror';
          gf.execActName := '';
          raise;
        end;
      end;
      //---
      stm.Size := 0;
      stm.Position := 0;
      if Connection.driver = 'dbx' then
        TBlobField(q.dbx.FieldByName('mlicid')).SaveToStream(stm)
      else
        TMemoField(q.ado.FieldByName('mlicid')).SaveToStream(stm);
      if stm.Size<>0 then
      begin
        cstm.Size := 0;
        cstm.Position := 0;
        stm.Position := 0;
        with TCompress.Create do begin
          cstm := DecompressStream(stm);
          destroy;
        end;
        cstm.Position := 0;
        GetDecodedSystemId(trim(cstm.DataString));
        gf.dodebug.Msg('Getting Server ID completed');
      end else raise Exception.Create('alm not connected');
    except on e:exception do
      begin
        gf.dodebug.Msg('Getting Server ID error : ' + e.Message);
        update_errorlog('lic',e.Message);
        if copy(e.Message,1,6) = 'copied' then result := 'copied'
        else  result := 'iderror';
        gf.execActName := '';
        if copy(e.Message,1,6) <> 'copied' then raise;
      end;
    end;
    //---
    try
      stm.Size := 0;
      stm.Position := 0;
      if Connection.driver = 'dbx' then
        TBlobField(q.dbx.FieldByName('alicid')).SaveToStream(stm)
      else
        TMemoField(q.ado.FieldByName('alicid')).SaveToStream(stm);
      if stm.Size<>0 then
      begin
        cstm.Size := 0;
        cstm.Position := 0;
        stm.Position := 0;
        with TCompress.Create do begin
          cstm := DecompressLicStringStream(stm);
          destroy;
        end;
        cstm.Position := 0;
        gf.LicString := cstm.DataString;
        s := gf.LicString;
        delete(gf.LicString,1,pos('|',gf.LicString));
        ServerLicIDConnectNo := copy(s,1,pos('~',s)-1);
        if pos('`',ServerLicIDConnectNo) > 0 then
        begin
          timeid := copy(ServerLicIDConnectNo,1,pos('`',ServerLicIDConnectNo)-1);
          delete(ServerLicIDConnectNo,1,pos('`',ServerLicIDConnectNo));
        end;
        delete(s,1,pos('~',s));
        s := copy(s,1,pos('|',s)-1);
        dt := GetTimeId(s);
        licupdatedays := DaysBetween(ServerDateTime,dt);
        if timeid <> '' then
        begin
          dt := GetTimeId(timeid);
          liccopieddays := DaysBetween(ServerDateTime,dt);
        end;
        if ServerIDConnectNo  <> 'zzzzz' then
        begin
           if ServerLicIDConnectNo <> ServerIDConnectNo then
              if (not gf.IsService) and (liccopieddays > 7) then raise Exception.Create('copied'+ ServerLicIDConnectNo + '#' + ServerIDConnectNo)
        end;
      end else raise Exception.Create('not activated');
    except on e:exception do
      begin
        gf.dodebug.Msg('Getting alic ID error : ' + e.Message);
        update_errorlog('lic',e.Message);
        if copy(e.Message,1,6) = 'copied' then result := 'copied'
        else  result := 'licerror';
        gf.execActName := '';
        raise;
      end;
    end;
    //Developer
    if not gf.IsService then
    begin
      try
        stm.Size := 0;
        stm.Position := 0;
      if Connection.driver = 'dbx' then
        TBlobField(q.dbx.FieldByName('dlicid')).SaveToStream(stm)
      else
        TMemoField(q.ado.FieldByName('dlicid')).SaveToStream(stm);
        if stm.Size<>0 then
        begin
          cstm.Size := 0;
          cstm.Position := 0;
          stm.Position := 0;
          with TCompress.Create do begin
            cstm := DecompressLicStringStream(stm);
            destroy;
          end;
          cstm.Position := 0;
          gf.LicDevString := trim(cstm.DataString);
          delete(gf.LicDevString,1,pos('|',gf.LicDevString));
        end;
      except on e:exception do
        begin
          gf.dodebug.Msg('Getting alic ID error : ' + e.Message);
          update_errorlog('lic',e.Message);
          result := 'licerror';
          gf.execActName := '';
          raise;
        end;
      end;
      //Location
      try
        stm.Size := 0;
        stm.Position := 0;
      if Connection.driver = 'dbx' then
        TBlobField(q.dbx.FieldByName('llicid')).SaveToStream(stm)
      else
        TMemoField(q.ado.FieldByName('llicid')).SaveToStream(stm);
        if stm.Size<>0 then
        begin
          cstm.Size := 0;
          cstm.Position := 0;
          stm.Position := 0;
          with TCompress.Create do begin
            cstm := DecompressLicStringStream(stm);
            destroy;
          end;
          cstm.Position := 0;
          gf.LicLocString := trim(cstm.DataString);
          delete(gf.LicLocString,1,pos('|',gf.LicLocString));
          gf.LicLocString := UpdateLicStringWithTStamp(ServerDateTime)+'|'+trim(gf.LicLocString)
        end;
      except on e:exception do
        begin
          gf.dodebug.Msg('Getting alic ID error : ' + e.Message);
          update_errorlog('lic',e.Message);
          result := 'licerror';
          gf.execActName := '';
          raise;
        end;
      end;
    end;
    if result <> 'copied' then result := 'done';
  except
    if (not gf.IsService) and (result <> 'copied') then
    begin
    if (result <> 'done') then
    begin
       if GetLicStringFromDB then
       begin
          licupdatedays := 0;
          almupdatedays := 0;
          ServerId := 'siteedition';
          gf.SiteCopy := true;
          result := 'done';
       end;
    end;
    end;
  end;
finally
  if assigned(q) then
  begin
    q.close;
    FreeAndNil(q);
  end;
  if assigned(stm) then FreeAndNil(stm);
  if assigned(cstm) then FreeAndNil(cstm);
end;
end;

function TDBManager.GetDecodedSystemId(macid : string) : string;
   var i,j : integer;
   cpuid,cno,lcno,lno,cdb : String;
   x : TXds;
   dt : TDateTime;
begin
   result := '';
   x := nil;
   i := strtoint(copy(macid,1,4));
   delete(macid,1,4);
   i := i * 4 ;
   cpuid := copy(macid,1,i);
   delete(macid,1,i);
   cno := macid;

   macid := copy(macid,1,pos('|',macid)-1);
   dt :=GetTimeId(macid);
   almupdatedays := DaysBetween(ServerDateTime,dt);
   i := length(macid);
   delete(macid,i-3,i);
   ServerId := Get_MacId(macid,cpuid);
   result := ServerId;

   delete(cno,1,pos('|',cno));
   ServerIDConnectNo := cno;
   lcno := copy(cno,1,5);
   if lcno <> 'zzzzz' then
   begin
     try
       j := strtoint(lcno);
       if j > 0 then
       begin
         if gf.clouddb <> '' then
            cdb := gf.clouddb + '.connectinfo'
         else cdb := 'connectinfo';
         delete(cno,1,5);
         lno := copy(cno,1,9);
         delete(cno,1,9);
         x := GetXDS(nil);
         x.buffered := true;
         x.CDS.CommandText := 'select lastupdated,lastnumber from ' + cdb + ' where connectno  = ' + inttostr(j);
         x.open;
         if not x.CDS.isempty then lcno := FormatDateTime('ssddnnmmhhyy', x.CDS.fieldbyname('lastupdated').AsDateTime)
         else raise Exception.Create('copiedcinfoempty');
         if cno <> lcno then
         begin
            if x.CDS.fieldbyname('lastnumber').AsInteger > strtoint(lno) then
            begin
               cno := copy(cno,3,2) +  copy(cno,7,2) + copy(cno,11,2);
               lcno := FormatDateTime('ddmmyy', x.CDS.fieldbyname('lastupdated').AsDateTime);
               if cno <> lcno then raise Exception.Create('copiedcnonotmatch');
            end else if x.CDS.fieldbyname('lastnumber').AsInteger < strtoint(lno) then raise Exception.Create('copiedwrongln');
         end;
         x.close;
         FreeAndNil(x);
       end;
     except on e:exception do
       begin
        if gf.IsService then
        begin
          try
          gf.dodebug.Msg('Connectin No error : ' + e.Message);
          update_errorlog('lic',e.Message);
          if assigned(x) then
          begin
            x.close;
            FreeAndNil(x);
          end;
          except
          end;
        end else raise Exception.Create(e.Message);
       end;
     end;
   end;
   if lcno = 'zzzzz' then
   begin
      ServerIDConnectNo := lcno;
      update_errorlog('lic','copiedzzzzz');
   end;
end;

function TDBManager.Get_MacId(dtid,mid : String) : String;
var l,l1, i, k : Integer;
    s,s1,s2,dbid : AnsiString;
begin
  Result := '';
  s := mid;
  l := length(s);
  while s <> '' do
  begin
    s1 := copy(s,1,4);
    k := strtoint(s1);
    s2 := AnsiChar(k);
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
    s := s + Char(ord(dbid[i])-Ord(dtid[i]));
  end;
  result := s;
end;

function TDBManager.GetTimeId(insid : string) : TDatetime   ;
   var s,s1 : string;
   i,j,k : integer;
    dd,mm,yyyy,hh,nn,ss,zz : word;
begin
  i := length(insid);
  delete(insid,i-3,i);
  i := strtoint(copy(insid,1,2))-31;
  s := format('%.2d',[i]);
  j := strtoint(copy(insid,3,2));
  j := j - i - 13;
  s := s +'/' + format('%.2d',[j]);
  k := length(insid);
  s1 := copy(insid,k-8,k);
  delete(insid,k-8,k);
  delete(insid,1,4);
  j := strtoint(insid);
  j := j div i;
  s := s + '/' +format('%.4d',[j]);
  dd := strtoint(copy(s,1,2));
  mm := strtoint(copy(s,4,2));
  yyyy := strtoint(copy(s,7,4));
  hh := strtoint(copy(s1,1,3)) - 100;
  nn := strtoint(copy(s1,4,3)) - 100;
  ss := strtoint(copy(s1,7,3)) - 100;
  zz := 0;
  result := strtodatetime(formatdatetime(gf.ShortDateFormat.ShortDateFormat,EncodeDate(yyyy,mm,dd)) +' '+formatdatetime(gf.ShortDateFormat.LongTimeFormat,EncodeTime(hh,nn,ss,zz)));
end;

function TDBManager.UpdateLicenseInDB(regkey : string;  keycol,act : AnsiString) : string;
   var cstm,stm: TStringStream;
       x : TXDS;
       t,w : ansistring;
begin
  try
    result := '';
    cstm := nil;
    stm := nil;
    x := nil;
    regkey := UpdateLicStringWithTStamp(ServerDateTime)+'|'+trim(regkey);
    regkey := ServerIDConnectNo + '~'+ regkey;
    cstm := TStringStream.Create('');
    cstm.WriteString(regkey);
    cstm.Position := 0;
    with TCompress.Create do begin
      stm := compressStream(cstm);
      destroy;
    end;
      stm.Position := 0;
      if not assigned(x) then x:=GetXDS(nil)
      else x.close;
      t := gf.convertToDBDateTime(connection.dbtype,serverdatetime);
      w:='licid='+quotedstr('licstring');
      x.Submit('licid','licstring','c');
      x.Submit('adt',t,'c');
      x.Submit('blobno', '1', 'n');
      x.AddOrEdit('axliccontrol', w);
      x.Post;
      if (act = 'activated') or (act = 'refreshed') then
      begin
        if keycol = 'dlic' then
        begin
           WriteMemo('dlicid','axliccontrol',w,stm,true);
           gf.LicDevString := regkey;
           delete(gf.LicDevString,1,pos('~',gf.LicDevString));
           delete(gf.LicDevString,1,pos('|',gf.LicDevString));
        end else if keycol = 'llic' then
        begin
           WriteMemo('llicid','axliccontrol',w,stm,true);
           gf.LicLocString := regkey;
           delete(gf.LicLocString,1,pos('~',gf.LicLocString));
           if assigned(gf.SiteLicUpdate) then gf.SiteLicUpdate;
           delete(gf.LicLocString,1,pos('|',gf.LicLocString));
        end else WriteMemo('alicid','axliccontrol',w,stm,true);
        gf.LicString := regkey;
        delete(gf.LicString,1,pos('~',gf.LicString));
        delete(gf.LicString,1,pos('|',gf.LicString));
        licupdatedays := 0;
        if (act = 'activated') then
        begin
          cstm.size := 0;
          if assigned(stm) then FreeAndNil(stm);
          cstm.WriteString('axp_unlimitedtransid');
          cstm.Position := 0;
          with TCompress.Create do begin
            stm := compressStream(cstm);
            destroy;
          end;
          stm.Position := 0;
          WriteMemo('lictrans','axliccontrol',w,stm,true);
        end;
      end else
      begin
        if keycol = 'dlic' then
        begin
           WriteMemo('dlicid','axliccontrol',w,stm,true);
           gf.LicDevString := regkey;
           delete(gf.LicDevString,1,pos('~',gf.LicDevString));
           delete(gf.LicDevString,1,pos('|',gf.LicDevString));
        end else if keycol = 'llic' then
        begin
           WriteMemo('llicid','axliccontrol',w,stm,true);
           gf.LicLocString := regkey;
           delete(gf.LicLocString,1,pos('~',gf.LicLocString));
           if assigned(gf.SiteLicUpdate) then gf.SiteLicUpdate;
           delete(gf.LicLocString,1,pos('|',gf.LicLocString));
        end;
      end;
  except on e:exception do
  begin
      gf.execActName := 'LicActivate';
      update_errorlog('licupdate',e.Message);
      result := e.Message;
      gf.execActName := '';
  end;
  end;
  if assigned(cstm) then FreeAndNil(cstm);
  if assigned(stm) then FreeAndNil(stm);
  if assigned(x) then
  begin
    x.close;
    FreeAndNil(x);
  end;
end;

function TDBManager.UpdateLicStringWithTStamp(dt : TDateTime) : AnsiString   ;
   var dtime, s , s1 : AnsiString;
   i : integer;
begin
  dtime := formatdatetime('ddmmyyyyhhnnss',dt);
  i := strtoint(copy(dtime,1,2));
  s := inttostr( i + 31);
  s := s  + inttostr(strtoint(copy(dtime,3,2))+ i+13);
  s := s + inttostr(strtoint(copy(dtime,5,4)) * i);
  s := s + inttostr(strtoint(copy(dTime,9,2)) + 100) + inttostr(strtoint(copy(dTime,11,2)) + 100) + inttostr(strtoint(copy(dTime,13,2)) + 100);
  i := length(s);
  s1 := format('%.4d',[i]);
  result := s + s1;
end;

function TDBManager.GetLicStringFromDB() : Boolean;
var gxds : TXDS;
    s,w : string;
    dt : TDateTime;
    cstm,stm: TStringStream;
begin
  try
    result := true;
    cstm := nil;
    stm := nil;
    gxds := nil;
    gxds := GetXDS(nil);
    gxds.SqlText := 'select licstring from axlic1 where licname = ''licstring''';
    gxds.open;
    if not gxds.IsEmpty then
    begin
      s := gxds.FieldByName('licstring').AsString;
      if s <> '' then
      begin
        gf.LicString := s;
        delete(gf.LicString,1,pos('|',gf.LicString));
        s := copy(s,1,pos('|',s)-1);
        dt := GetTimeId(s);
        sitelicupdatedays := DaysBetween(ServerDateTime,dt);
        if (gf.UnlimitedTransIds = '') then
        begin
          gxds.close;
          w:='licid='+quotedstr('licstring');
          gxds.Submit('licid','licstring','c');
          gxds.Submit('blobno', '1', 'n');
          gxds.AddOrEdit('axliccontrol', w);
          gxds.Post;
          cstm := TStringStream.Create('');
          cstm.Position := 0;
          cstm.WriteString('axp_unlimitedtransid');
          cstm.Position := 0;
          with TCompress.Create do begin
            stm := compressStream(cstm);
            destroy;
          end;
          stm.Position := 0;
          WriteMemo('lictrans','axliccontrol',w,stm,true);
        end;
      end else result := false;
    end;
  except on e:exception do
    begin
      gf.DoDebug.Msg('Site License Checking error : ' + e.Message);
      result := false;
    end;
  end;
  if assigned(stm) then FreeAndNil(stm);
  if assigned(cstm) then FreeAndNil(cstm);
  if assigned(gxds) then
  begin
    gxds.close;
    FreeAndNil(gxds);
  end;
end;

function TDBManager.GetMariadbVersion: real;
var versqry : TXDS;
  versno, v : string;
  ipos : integer;
begin
  versqry := TXDS.create('versqry', nil, Connection,gf);
  versno := '1';
  try
    versqry.sqltext := ' select substring(version(),1,locate(''-'',version())-1) as vers ';
    versqry.open;
    v := versqry.fieldbyname('vers').AsString;
    ipos := pos('.', v);
    if ipos > 0 then
    begin
      versno := copy(v,1,ipos-1);
      v      := copy(v,ipos+1,20);
      ipos := pos('.', v);
      if ipos > 0 then
        versno := versno+'.'+copy(v,1,ipos-1)
      else
        versno := versno+'.'+v;
    end;
    result := strtofloat(versno);
  finally
    FreeAndNil(versqry);
  end;
end;

procedure TDbManager.WriteBlob(fname, table, where, filename: String;Append:String);
var source, target, x : TXDS;
     wstr, dtype : String;
     i, j : integer;
begin
  blobfiles.clear;
  filesplit(filename, 30000);
  x:=getxds(nil);
  if lowercase(Append) <> 't' then begin
    x.sqltext:='delete from '+table+' where '+where+' and blobno>1';
    x.execsql;
    x.sqltext:='update '+table+' set blobno=1 where '+where;
    x.execsql;
  end;
  x.close;
  source:=getxds(nil);
  source.buffered := true;
  source.CDS.CommandText:='select * from '+table+' where '+where;
  source.open;

  target:=getxds(nil);
  if blobfiles.count=1 then begin
    wstr := where + ' and blobno=1';
    target.WriteBlob(fname, table, wstr, filename);
    deletefile(pchar(blobfiles[0]));
  end else begin
    for i:=0 to blobfiles.count-1 do begin
      for j:=0 to source.CDS.Fields.Count-1 do begin
        if source.CDS.Fields[j].IsBlob then continue;
        if source.CDS.fields[j].DataType in [ftDateTime, ftTimeStamp, ftDate] then
        dtype := 'd' else dtype:='c';
        x.Submit(source.CDS.fields[j].FieldName, source.CDS.Fields[j].AsString, dtype);
      end;
      x.Submit('blobno', inttostr(i+1), 'n');
      wstr := where + ' and blobno='+inttostr(i+1);
      x.AddOrEdit(table, wstr);
      target.WriteBlob(fname, table, wstr, blobfiles[i]);
      deletefile(pchar(blobfiles[i]));
    end;
  end;
  target.Free;
  source.close;
  source.Free;
  x.Free;
end;

end.
