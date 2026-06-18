unit uInstallDbScripts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.StdCtrls,
  Data.db, XMLDoc,
  XMLIntf, uxds, uAxProvider, uGeneralFunctions, uProfitEval,
  IdBaseComponent, IdTCPConnection, IdTCPClient, IdFTP, IdComponent,
  Vcl.ComCtrls,
  Rio, SOAPHTTPClient, Vcl.buttons, Vcl.ExtCtrls, shellapi, uIviewXML, uxsmtp,
  uStoreData, uAxLog,
  uStructDef, uPDFPrint, xcallservice, adodb, Vcl.grids, uValidate,
  uAutoPageCreate,
  System.StrUtils, dateutils, uCreateIview, uCreateIviewStructure, uIviewTables,
  uPropsXML, idGlobal, IdSMTP, IdSSLOpenSSL, IdMessage,
  IdExplicitTLSClientServerBase,
  idreplysmtp, MessageDigest_5, uStructInTable, uCreateStructure,
  IdHTTP,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, uDBManager, uConnect,
  uCompress, ZLib, System.Types, System.IOUtils,
{$IF CompilerVersion > 24.0}
  JSON
{$ELSE}
  DBXJson
{$IFEND}
    ;

type
  TInstallDbScripts = class
  private

  public
    procedure ExecuteSQLFile(pSQLFileName: String);
    function ExecuteDBScripts: string;
  end;

implementation

uses uUtils;

function TInstallDbScripts.ExecuteDBScripts(): string;
var
  AxScriptPath: string;
  FileList: TStringDynArray;
  I, filecount: integer;
  fileArray: TArray<string>;
  searchRec: TSearchRec;
  indbs: TInstallDbScripts;
begin
  Console_write('  - Executing DB Scripts:', 5);
  writeln;
  Console_write('   - Finding database scripts to execute.', 10);
  writeln;
  // Console_write('   - Reading and executing database scripts.', 10);
  // writeln;
  // writeln;
  try
    indbs := TInstallDbScripts.create;
    // Decided to removed OfficialReleases , so plugin and patches will be palced
    // directly under repo\root dir   | 14/11/2024
    // AxScriptPath := patchLocalPath +'OfficialReleases\Plugins\'+ selectedPlugin+'\'  + cDBScripts + '\';

    (*
      21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
      here,
    *)
    // AxScriptPath := patchLocalPath +'Plugins\'+ selectedPlugin+'\'  + cDBScripts + '\';

    // AxScriptPath := patchLocalPath + selectedPlugin + '\' + cDBScripts + '\';
    AxScriptPath := { patchLocalPath } pluginLocalPath + selectedPlugin + '\' +
      cAxpertStructures + '\' + databasetype + '\' + cDBScripts + '\';
    if not directoryexists(AxScriptPath) then
    begin
      writelog('files are not available to process at ' + AxScriptPath);
      writeln('    -No files available to process.');
      Exit;
    end;
    writeln;
    Console_write('   - Reading and executing database scripts.', 10);
    writeln;
    // FolderList := TDirectory.GetDirectories(AxScriptPath);
    if FindFirst(AxScriptPath + '*.sql', faAnyFile, searchRec) = 0 then
    begin
      fileArray := TArray<string>(TDirectory.GetFiles(AxScriptPath));
      filecount := length(fileArray);
      for I := 0 to filecount - 1 do
      begin
        indbs.ExecuteSQLFile(fileArray[I]);
      end;

    end;
  except
    on E: Exception do
    begin
      writeln('Error: ' + E.Message);
      readln;
      ReadErrorList(E.Message);
    end;

  end;

  // uExecutedbscript
  // if FindFirst(DefaultFolderName + '*.*', faAnyFile, searchRec) = 0 then
end;

procedure TInstallDbScripts.ExecuteSQLFile(pSQLFileName: String);
var
  tfile, errmsg: String;
  sqlstr: string;
  j: integer;

  slist, sqltext: TStringList;
  qExec_XDS: TXDS;

  Procedure ExecuteSQL(pSQLText: String);
  var
    disp_sqltext: string;
  begin
    try

      if length(pSQLText) > 100 then
      begin
        disp_sqltext := copy(pSQLText, 1, 100) + '...';
      end
      else
      begin

        disp_sqltext := pSQLText;
      end;
      // Replace line feeds and carriage returns with spaces
      disp_sqltext := StringReplace(disp_sqltext, #13#10, ' ', [rfReplaceAll]);
      Write('    - ');
      Console_write('Executing Script: ', 14);
      write(disp_sqltext);
      writeln;
      writelog('Executing Script: ' + disp_sqltext);
      // if ((Lowercase(copy(trim(pSQLText), 1, 7)) = 'create ') or
      // (Lowercase(copy(trim(pSQLText), 1, 7)) = 'declare ')) and
      /// /       ((Lowercase(dbm.Connection.dbtype) = 'oracle')) then
      // ((Lowercase(dbm.Connection.driver) = 'dbx')) then
      // begin
      // qExec_XDS.dbx.SQLConnection.ExecuteDirect(pSQLText);
      //
      // writeln('    - Done.');
      // writeln('');
      // // writeln;
      // end
      // else
      if ((Lowercase(copy(trim(pSQLText), 1, 7)) = 'create ') or
        (Lowercase(copy(trim(pSQLText), 1, 7)) = 'declare ')) and
        ((Lowercase(dbm.Connection.driver) = 'dbx')) then
      begin
        try
          if ((Lowercase(dbm.Connection.dbtype) = 'postgre')) then
          begin
            if dbm.Connection.dbx.InTransaction then
              qExec_XDS.dbx.SQLConnection.ExecuteDirect('savepoint a');
          end;
          qExec_XDS.dbx.SQLConnection.ExecuteDirect(pSQLText);
          writeln('    - Done.');
        except
          On E: Exception do
          begin
            if ((Lowercase(dbm.Connection.dbtype) = 'postgre')) then
            begin
              if dbm.Connection.dbx.InTransaction then
              begin
                qExec_XDS.dbx.SQLConnection.ExecuteDirect('rollback to a');
              end;
            end;
            raise;
          end;
        end;
      end
      else if ((Lowercase(copy(trim(pSQLText), 1, 7)) = 'create ') or
        (Lowercase(copy(trim(pSQLText), 1, 7)) = 'declare ')) and
        ((Lowercase(dbm.Connection.driver) = 'ado')) then
      begin
        qExec_XDS.ado.Connection.Execute(pSQLText);

        writeln('    - Done.');
        writeln('');
      end
      else
      begin
        qExec_XDS.sql.Clear;
        qExec_XDS.sql.text := pSQLText { slist.text };
        qExec_XDS.execsql;
        writeln('    - Done.');
        writelog('query executed successfully..');
      end;
    except
      on E: Exception do
      begin
        errmsg := E.Message;
        writelog(E.Message);
        ReadErrorList(E.Message);
      end;
    end;
    if errmsg <> '' then
    begin
      Write('   - Error occurred while executing the query : ' { + sqltext.Text }
        + #13 + '   - ');
      Console_write('Error : ', 12);
      write(errmsg);
      writeln;
      writelog('Error occurred while executing the query : ' + errmsg);
      errmsg := '';
      ReadErrorList(errmsg);
    end;
  end;

begin
  writelog('ExecuteSQLFile function started..');
  qExec_XDS := nil;
  slist := nil;
  sqltext := nil;
  try
    try
      qExec_XDS := dbm.GetXDS(nil);
      slist := TStringList.create;
      sqltext := TStringList.create;
      tfile := pSQLFileName;
      if fileexists(tfile) then
      begin
        writeln('    - Processing SQL file ' + '' +
          ExtractFilename(pSQLFileName) + '');
        slist.Clear;
        sqltext.Clear;
        slist.LoadFromFile(tfile);

        // If there are no multiple SQLs in the file, then exeucte sqltext directly
        if (pos('<<', slist.text) <= 0) or (pos('>>', slist.text) <= 0) then
        begin
          ExecuteSQL(slist.text);
        end
        else
        begin
          // If there are multiple SQL statements in the file, execute them one by one directly.
          // SQL statements placed between '<<' and '>>' are used to separate multiple SQL statements.
          for j := 0 to slist.count - 1 do
          begin
            if trim(slist[j]) = '<<' then
            begin
              sqltext.Clear;
            end
            else if trim(slist[j]) = '>>' then
            begin
              sqlstr := sqltext.text;
              // if (pos('$D#$A',sqlstr) <> 0) or (pos('#$D#$A',sqlstr)<>0) then
              // begin
              // sqlstr:=stringreplace(sqlstr,'$D#$A','',[rfReplaceAll]);
              // sqlstr:=stringreplace(sqlstr,#$D#$A,' ',[rfReplaceAll,rfIgnoreCase]);
              // end;

              ExecuteSQL(sqlstr);
            end
            else
              sqltext.Add(slist[j]);
          end;
        end;
        Write('    - SQL file ');
        Console_write(ExtractFilename(pSQLFileName), 10);
        write(' processed successfully.');
        writeln;
        writelog(ExtractFilename(pSQLFileName) + ' processed successfully.');
        writeln('');
      end;
    Except
      on E: Exception do
      begin
        writeln('Error while executing ' + ExtractFilename(pSQLFileName));
        writelog('Error while executing ' + ExtractFilename(pSQLFileName));
        writelog('SQL : ' + sqltext.text);
        writelog('Error : ' + E.Message);
        ReadErrorList(E.Message);
      end;
    end;
  finally
    if assigned(qExec_XDS) then
    begin
      if qExec_XDS.Active then
        qExec_XDS.close;
      FreeAndNil(qExec_XDS);
    end;
    if assigned(slist) then
      FreeAndNil(slist);
    if assigned(slist) then
      FreeAndNil(sqltext);
  end;
  writelog('ExecuteSQLFile function ends..');
end;

end.
