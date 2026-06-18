unit IISManager;

interface

function StartIIS: Boolean;
function StopIIS: Boolean;
function IsIISRunning: Boolean;

implementation

uses
  SysUtils, WinSvc, Windows;

var
  UserResponse : String;



function IsIISRunning: Boolean;
var
  schm, svc: SC_HANDLE;
  ss: TServiceStatus;
begin
  Result:=False;
  Exit;
  //For timesake we are making this false.later we have to make change like for specific app pool iis should stop
  schm := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if schm = 0 then
    Exit(False);

  svc := OpenService(schm, 'W3SVC', SERVICE_QUERY_STATUS);
  if svc = 0 then
  begin
    CloseServiceHandle(schm);
    Exit(False);
  end;

  if not QueryServiceStatus(svc, ss) then
  begin
    CloseServiceHandle(svc);
    CloseServiceHandle(schm);
    Exit(False);
  end;

  Result := ss.dwCurrentState = SERVICE_RUNNING;

  CloseServiceHandle(svc);
  CloseServiceHandle(schm);
end;


function StartIIS: Boolean;
var
  schm, svc: SC_HANDLE;
  lpServiceArgVectors: array[0..0] of WideChar; // Declare an array of WideChar
  ServiceArgVectors : pWideChar;
begin
  schm := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if schm = 0 then
    Exit(False);

  svc := OpenService(schm, 'W3SVC', SERVICE_START);
  if svc = 0 then
  begin
    CloseServiceHandle(schm);
    Exit(False);
  end;
  ServiceArgVectors := '';
  if not StartService(svc, 0, ServiceArgVectors) then
  begin
    CloseServiceHandle(svc);
    CloseServiceHandle(schm);
    Exit(False);
  end;

  CloseServiceHandle(svc);
  CloseServiceHandle(schm);
  Result := True;
end;

function StopIIS: Boolean;
var
  schm, svc: SC_HANDLE;
  svcStatus: SERVICE_STATUS;
begin
  schm := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if schm = 0 then
    Exit(False);

  svc := OpenService(schm, 'W3SVC', SERVICE_STOP);
  if svc = 0 then
  begin
    CloseServiceHandle(schm);
    Exit(False);
  end;
  //svcStatus := nil;
  //GetMem(svcStatus, SizeOf(SERVICE_STATUS));
  if not ControlService(svc, SERVICE_CONTROL_STOP, svcStatus) then
  begin
    CloseServiceHandle(svc);
    CloseServiceHandle(schm);
    Exit(False);
  end;

  CloseServiceHandle(svc);
  CloseServiceHandle(schm);
  Result := True;
end;


end.

