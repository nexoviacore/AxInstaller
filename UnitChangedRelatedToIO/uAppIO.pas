//unit uAppIO;
//
//interface
//
//uses
//  SysUtils;
//
//procedure AppWriteLn; overload;
//procedure AppWriteLn(const S: string); overload;
//procedure AppWriteLn(const S1, S2: string); overload;
//procedure AppWriteLn(const S1, S2, S3: string); overload;
//procedure AppWriteLn(const S: string; const I: Integer); overload;
//procedure AppWriteLn(var F: Text; const S: string); overload;
//
//procedure AppWrite; overload;
//procedure AppWrite(const S: string); overload;
//procedure AppWrite(const S1, S2: string); overload;
//procedure AppWrite(const S1, S2, S3: string); overload;
//procedure AppWrite(const S: string; const I: Integer); overload;
//procedure AppWrite(var F: Text; const S: string); overload;
//
//procedure AppReadLn; overload;
//procedure AppReadLn(var S: string); overload;
//
//implementation
//
//{$IFDEF CONSOLE_APP}
//
//procedure AppWriteLn;
//begin
//  WriteLn;
//end;
//
//procedure AppWriteLn(const S: string);
//begin
//  WriteLn(S);
//end;
//
//procedure AppWriteLn(const S1, S2: string);
//begin
//  WriteLn(S1 + S2);
//end;
//
//procedure AppWriteLn(const S1, S2, S3: string);
//begin
//  WriteLn(S1 + S2 + S3);
//end;
//
//procedure AppWriteLn(const S: string; const I: Integer);
//begin
//  WriteLn(S + IntToStr(I));
//end;
//
//procedure AppWriteLn(var F: Text; const S: string);
//begin
//  WriteLn(F, S);
//end;
//
//procedure AppWrite;
//begin
//  Write;
//end;
//
//procedure AppWrite(const S: string);
//begin
//  Write(S);
//end;
//
//procedure AppWrite(const S1, S2: string);
//begin
//  Write(S1 + S2);
//end;
//
//procedure AppWrite(const S1, S2, S3: string);
//begin
//  Write(S1 + S2 + S3);
//end;
//
//procedure AppWrite(const S: string; const I: Integer);
//begin
//  Write(S + IntToStr(I));
//end;
//
//procedure AppWrite(var F: Text; const S: string);
//begin
//  Write(F, S);
//end;
//
//procedure AppReadLn;
//begin
//  ReadLn;
//end;
//
//procedure AppReadLn(var S: string);
//begin
//  ReadLn(S);
//end;
//
//{$ELSE}
//
//procedure AppWriteLn;
//begin
//end;
//
//procedure AppWriteLn(const S: string);
//begin
//end;
//
//procedure AppWriteLn(const S1, S2: string);
//begin
//end;
//
//procedure AppWriteLn(const S1, S2, S3: string);
//begin
//end;
//
//procedure AppWriteLn(const S: string; const I: Integer);
//begin
//end;
//
//procedure AppWriteLn(var F: Text; const S: string);
//begin
//  WriteLn(F, S);
//end;
//
//procedure AppWrite;
//begin
//end;
//
//procedure AppWrite(const S: string);
//begin
//
//end;
//
//procedure AppWrite(const S1, S2: string);
//begin
//end;
//
//procedure AppWrite(const S1, S2, S3: string);
//begin
//end;
//
//procedure AppWrite(const S: string; const I: Integer);
//begin
//end;
//
//procedure AppWrite(var F: Text; const S: string);
//begin
//  Write(F, S);
//end;
//
//procedure AppReadLn;
//begin
//end;
//
//procedure AppReadLn(var S: string);
//begin
//  S := '';
//end;
//
//{$ENDIF}
//
//end.

unit uAppIO;

interface

uses
  SysUtils, Classes;

var
  slResponseList: TStringList;

procedure AppWriteLn; overload;
procedure AppWriteLn(const S: string); overload;
procedure AppWriteLn(const S1, S2: string); overload;
procedure AppWriteLn(const S1, S2, S3: string); overload;
procedure AppWriteLn(const S: string; const I: Integer); overload;
procedure AppWriteLn(var F: Text; const S: string); overload;

procedure AppWrite; overload;
procedure AppWrite(const S: string); overload;
procedure AppWrite(const S1, S2: string); overload;
procedure AppWrite(const S1, S2, S3: string); overload;
procedure AppWrite(const S: string; const I: Integer); overload;
procedure AppWrite(var F: Text; const S: string); overload;

procedure AppReadLn; overload;
procedure AppReadLn(var S: string); overload;

implementation

{$IFDEF CONSOLE_APP}

procedure AppWriteLn;
begin
  WriteLn;
end;

procedure AppWriteLn(const S: string);
begin
  WriteLn(S);
end;

procedure AppWriteLn(const S1, S2: string);
begin
  WriteLn(S1 + S2);
end;

procedure AppWriteLn(const S1, S2, S3: string);
begin
  WriteLn(S1 + S2 + S3);
end;

procedure AppWriteLn(const S: string; const I: Integer);
begin
  WriteLn(S + IntToStr(I));
end;

procedure AppWriteLn(var F: Text; const S: string);
begin
  WriteLn(F, S);
end;

procedure AppWrite;
begin
  Write;
end;

procedure AppWrite(const S: string);
begin
  Write(S);
end;

procedure AppWrite(const S1, S2: string);
begin
  Write(S1 + S2);
end;

procedure AppWrite(const S1, S2, S3: string);
begin
  Write(S1 + S2 + S3);
end;

procedure AppWrite(const S: string; const I: Integer);
begin
  Write(S + IntToStr(I));
end;

procedure AppWrite(var F: Text; const S: string);
begin
  Write(F, S);
end;

procedure AppReadLn;
begin
  ReadLn;
end;

procedure AppReadLn(var S: string);
begin
  ReadLn(S);
end;

{$ELSE}

procedure AppWriteLn;
begin
  slResponseList.Add('');
end;

procedure AppWriteLn(const S: string);
begin
  slResponseList.Add(S);
end;

procedure AppWriteLn(const S1, S2: string);
begin
  slResponseList.Add(S1 + S2);
end;

procedure AppWriteLn(const S1, S2, S3: string);
begin
  slResponseList.Add(S1 + S2 + S3);
end;

procedure AppWriteLn(const S: string; const I: Integer);
begin
  slResponseList.Add(S + IntToStr(I));
end;

procedure AppWriteLn(var F: Text; const S: string);
begin
  slResponseList.Add(S);
end;

procedure AppWrite;
begin
  if slResponseList.Count = 0 then
    slResponseList.Add('');
end;

procedure AppWrite(const S: string);
begin
  if slResponseList.Count = 0 then
    slResponseList.Add(S)
  else
    slResponseList[slResponseList.Count - 1] :=
      slResponseList[slResponseList.Count - 1] + S;
end;

procedure AppWrite(const S1, S2: string);
begin
  AppWrite(S1 + S2);
end;

procedure AppWrite(const S1, S2, S3: string);
begin
  AppWrite(S1 + S2 + S3);
end;

procedure AppWrite(const S: string; const I: Integer);
begin
  AppWrite(S + IntToStr(I));
end;

procedure AppWrite(var F: Text; const S: string);
begin
  AppWrite(S);
end;

procedure AppReadLn;
begin
end;

procedure AppReadLn(var S: string);
begin
  S := '';
end;

{$ENDIF}

initialization
  slResponseList := TStringList.Create;

finalization
  FreeAndNil(slResponseList);

end.

