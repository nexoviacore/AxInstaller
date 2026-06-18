unit uInstallRMQClients;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.StdCtrls,
  Data.db, XMLDoc,
  XMLIntf, uxds, uAxProvider, uGeneralFunctions, uProfitEval,
  IdBaseComponent, IdTCPConnection, IdTCPClient, IdFTP, IdComponent,
  Vcl.ComCtrls,
  Rio, SOAPHTTPClient, Vcl.buttons, Vcl.ExtCtrls, shellapi, uIviewXML, uxsmtp,
  uStoreData,
  uStructDef, uPDFPrint, xcallservice, adodb, Vcl.grids, uValidate,
  uAutoPageCreate,
  System.StrUtils, dateutils, uCreateIview, uCreateIviewStructure, uIviewTables,
  uPropsXML, idGlobal, IdSMTP, IdSSLOpenSSL, IdMessage,
  IdExplicitTLSClientServerBase,
  idreplysmtp, MessageDigest_5, uStructInTable, uCreateStructure,
  IdHTTP,uAxLog,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, uDBManager, uConnect,
  uCompress, ZLib, System.Types, System.IOUtils,
{$IF CompilerVersion > 24.0}
  JSON
{$ELSE}
  DBXJson
{$IFEND}
    ;

type
  TInstallRMQClients = class
  private
    // procedure ExecuteSQLFile(pSQLFileName: String);
    function FindFile(Sourcepath: string): string;
    function FindFolder(path: string): string;
    function ReadFile(Sourcepath: string; DestPath: string): string;
    function ExtractSubstringFromFifthBackslash(const AString: string): string;

  public
    function InstallRMQClients: string;
    function RemoveLastSegmentFromURL(URL: string): string;

  end;

implementation

uses uUtils;

function TInstallRMQClients.InstallRMQClients: string;
var
  I: integer;
  destinationpath: string;
  LoacalDir: string;
  FolderArray: TArray<string>;
begin
  writelog('InstallRMQClients function started..');
  writeln;
  console_write('  - Installing RMQClients file:',5);
  writeln;
  Console_write('   - Finding RMQ client files to move to their corresponding directory.', 10);
//  Console_write
//    ('   - Copying files to corresponding RMQclient folder from the local plugin directory.',
//    10);
  //writeln;
  writelog('Copying files to corresponding RMQclient folder from the local plugin directory.');
  destinationpath := armservicepath;        {rmqclientpath}
  //writeln;
  writeln;

  // Decided to removed OfficialReleases , so plugin and patches will be palced
  //directly under repo\root dir   | 14/11/2024
//  LoacalDir := patchlocalpath+'OfficialReleases\Plugins\'+selectedplugin + '\' + cRMQ + '\';

  (*
    21/11/2024 -  As decided , we changed the GIT structure accordingly modifying the code
    here,
  *)

//  LoacalDir := patchlocalpath+'Plugins\'+selectedplugin + '\' + cRMQ + '\';

  LoacalDir := patchlocalpath+selectedplugin + '\' + cRMQ + '\';

  if not directoryexists(LoacalDir) then
  begin
    writeln;
    writeln('    -No files available to process.');
    writelog('No ARM files are available to process at '+LoacalDir);
    Exit;
  end;
  writeln;
  Console_write
    ('   - Copying files to corresponding RMQclient folder from the local plugin directory.',
    10);
  writeln;
  FolderArray := TArray<string>(TDirectory.GetDirectories(LoacalDir));
  for I := 0 to length(FolderArray)-1 do
  begin
    ForceDirectories(armservicepath + '\' + extractfilename(FolderArray[I]));
    writelog('Placing all RMQ files to desired path');
    // FindFile(FolderArray[I]);
    FindFolder(FolderArray[I]);
    FindFile(FolderArray[I]);
      writelog('InstallRMQClients function ends..');
  end;
  writeln;
end;

function TInstallRMQClients.FindFile(Sourcepath: string): string;
var
  fileArray, FolderArray: TArray<string>;
  searchRec: TSearchRec;
  filecount, FolderCount, Count, I: integer;
  DestPath, updestinationpath: string;
  FolderName: string;
  subfolders: TStrings;
begin
  try
     //writeln('Sourcepath:='+sourcepath);
    if length(Sourcepath) > 0 then
    begin
      if FindFirst(Sourcepath + '*.*', faAnyFile, searchRec) = 0 then
      begin
        fileArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
      filecount := length(fileArray);
      updestinationpath := Copy(Sourcepath, pos(cRMQ, Sourcepath) +
        length(cRMQ), length(Sourcepath) - pos(cRMQ, Sourcepath) -
        length(cRMQ) + 1);
      // RemoveLastSegmentFromURL(rmqclientpath) + '\\'+updestinationpath;
      DestPath := armservicepath + '\' + updestinationpath;
      // ForceDirectories(DestPath + '\\' + cRMQ + '\\');
      // DestPath := DestPath + '\\' + cRMQ + '\\';
      // if pos(cRMQ, Sourcepath) > 0 then
      // begin
      // updestinationpath := Copy(Sourcepath, pos(cRMQ, Sourcepath) +
      // Length(cRMQ), Length(Sourcepath) - pos(cRMQ, Sourcepath) -
      // Length(cRMQ) + 1);
      // DestPath := DestPath + '\\' + updestinationpath + '\\';
      // // ForceDirectories(updestinationpath);
      // end
      // else
      // begin
      // // ForceDirectories(destinationpath + '\\' + cRMQ + '\\');
      // end;
      // FolderName := extractFileName(Sourcepath);
      for I := 0 to filecount - 1 do
      begin
        if FolderName = '' then
        begin
          // writeln('without folder name');
          ReadFile(fileArray[I], DestPath + '\' +
            extractfilename(fileArray[I]));
        end
        else
        begin
          // writeln('with folder name');
          ReadFile(fileArray[I], DestPath + FolderName + '\\' +
            extractfilename(fileArray[I]));
        end;

    end;
    // if FindFirst(Sourcepath + '\' + '*.*', faDirectory, searchRec) = 0 then
    // begin
    // repeat
    // if (searchRec.attr and faDirectory) = faDirectory then
    // begin
    // if (searchRec.Name <> '.') and (searchRec.Name <> '..') then
    // begin
    // subfolders.Add(searchRec.Name);
    // end;
    // end;
    // until FindNext(searchRec) <> 0;
    // end;
    // finally
    // FindClose(searchRec);
    // end;
    // FolderArray:=subfolders.ToStringArray;
    // SetLength(FolderArray, Count + 1);
    // FolderArray[Count] := Sourcepath+'\'+ searchRec.Name;
    // Inc(Count);
    // end;
    // until FindNext(searchRec) <> 0;
    // FindClose(searchRec);
    // ForceDirectories(Sourcepath + '\\' + cRMQ + '\\');
    // Sourcepath:=Sourcepath+ '\\' + cRMQ + '\\';
    // FolderArray := TArray<string>(TDirectory.GetFiles(Sourcepath));
    // FolderCount := Length(fileArray);
    // DestPath := webcodepath + '\\' + cPlugins + '\\' + selectedPlugin;
    // ForceDirectories(DestPath + '\\' + cRMQ + '\\');
    // DestPath := DestPath + '\\' + cRMQ + '\\';
    // FolderName := extractFileName(Sourcepath);
    // for I := 0 to filecount - 1 do
    // begin
    // if FolderName = '' then
    // begin
    // ReadFile(FolderArray[I], DestPath + extractFileName(FolderArray[I]));
    // end
    // else
    // begin
    // ReadFile(FolderArray[I], DestPath + FolderName + '\\' +
    // extractFileName(FolderArray[I]));
    // end;
    // end;
    end;
  end
  except
    on E: Exception do
    begin
      Console_write('Error from findfile: ' + E.Message, 12);
      writeln;
      writelog('Error from find folder function: ' + E.Message);
      readln;
    end;
  end;
end;

function TInstallRMQClients.FindFolder(path: string): string;
var
  FolderArray: TArray<string>;
  FolderCount, I: integer;
  searchRec: TSearchRec;
  destinationpath, updestinationpath: string;
begin
  try

    // if not directoryExists(path) then
    // begin
    // writeln;
    // writeln('  - RMQfiles are not available for ' + selectedPlugin);
    // exit;
    // end;
    // writeln('path :='+path );
     if length(path) > 0 then
     begin
      FolderArray := TArray<string>(TDirectory.GetDirectories(path));
    updestinationpath := Copy(path, pos(cRMQ, path) + length(cRMQ),
      length(path) - pos(cRMQ, path) - length(cRMQ) + 1);
    updestinationpath := RemoveLastSegmentFromURL(updestinationpath);
    // updestinationpath := destinationpath + '\\' + updestinationpath;
    // ForceDirectories(updestinationpath);
    destinationpath := RemoveLastSegmentFromURL(armservicepath) + '\\' +
      updestinationpath;
    // webcodepath + '\\' + cPlugins + '\\' + selectedPlugin +
    // '\\' + cRMQ
    // if pos(cRMQ, path) > 0 then
    // begin
    // updestinationpath := Copy(path, pos(cRMQ, path) + Length(cRMQ),
    // Length(path) - pos(cRMQ, path) - Length(cRMQ) + 1);
    // updestinationpath := destinationpath + '\\' + updestinationpath;
    // ForceDirectories(updestinationpath);
    // end
    // else
    // begin
    // ForceDirectories(destinationpath + '\\' + cRMQ + '\\');
    // end;
    // destinationpath := destinationpath + '\\' + cRMQ + '\\'+ExtractFileName(path);
    // ForceDirectories(destinationpath + '\\' + cRMQ + '\\'+ExtractFileName(path));
    FolderCount := length(FolderArray);
    for I := 0 to FolderCount - 1 do
    begin
      // writeln(extractFileName(FolderArray[I]));
      ForceDirectories(destinationpath + '\' + extractfilename(FolderArray[I]));
      FindFolder(FolderArray[I]);
      FindFile(FolderArray[I]);
    end;


    // CopyFilesRecursively('D:\Workspace\install_plugin\Win64\Debug\Plugin\Plugin1','C:\Users\paroksh.AGILELABS\Desktop\PluginWeb\Plugin\Plugin1\Webfiles');
    // Readln;
    end;
  except
    on E: Exception do
    begin
      Console_write('Error from find folder: ' + E.Message, 12);
      writeln;
      writelog('Error from find folder function: ' + E.Message);
      readln;
    end;
   end;
end;

function TInstallRMQClients.ReadFile(Sourcepath: string;
  DestPath: string): string;
var
  copiedfile: TextFile;
  FileContent: string;
  displayDestPath,tmpDestPath: string;
begin
  try
    FileContent := TFile.ReadAllText(Sourcepath);
    // writeln(ExtractFileName(Sourcepath)+' getting copied into '+DestPath);
    AssignFile(copiedfile, DestPath);
    Rewrite(copiedfile);
    writeln(copiedfile, FileContent);
    CloseFile(copiedfile);
    displayDestPath := StringReplace(DestPath, '\\', '\', [rfReplaceAll]);
    // displayDestPath := Copy(displayDestPath, pos('AxPlugins', displayDestPath) +
    // Length('AxPlugins'), Length(displayDestPath) - pos('AxPlugins',
    // displayDestPath) - Length('AxPlugins') + 1);
    displayDestPath := StringReplace(displayDestPath, '\\', '\',
      [rfReplaceAll]);
    tmpDestPath:=ExtractSubstringFromFifthBackslash(displayDestPath);
    if Trim(tmpDestPath) <> '' then
       displayDestPath := tmpDestPath
    else if length(displayDestPath) > 100 then
    begin
       try
        displayDestPath := Copy(displayDestPath,Length(displayDestPath)-99,length(displayDestPath));
       except

       end;
    end;

    write('   - Placing file ');
    Console_write(extractfilename(Sourcepath) + ' ', 10);
    write('in ...' + displayDestPath);
    writeln;
  except
    on E: Exception do
    begin
      Console_write('Error from read file: ' + E.Message, 12);
      writeln;
      writelog('Error from read folder function : ' + E.Message);
      readln;
    end;
  end;
end;

function TInstallRMQClients.RemoveLastSegmentFromURL(URL: string): string;
var
  LastSlashPos: integer;
begin
  // Find the last occurrence of '/' in the URL
  LastSlashPos := LastDelimiter('/', URL);

  // If a slash is found, remove everything after it
  if LastSlashPos > 0 then
  begin
    URL := Copy(URL, 1, LastSlashPos - 1);
    LastSlashPos := LastDelimiter('/', URL);
    URL := Copy(URL, 1, LastSlashPos);
    Result := URL;
  end
  else
    Result := URL; // No slash found, return original URL
end;


function TInstallRMQClients.ExtractSubstringFromFifthBackslash(const AString: string): string;
var
  Position, BackslashCount: Integer;
begin
  Result := '';
  BackslashCount := 0;

  // Finding the position of the 5th backslash
  Position := 1;
  while (Position > 0) and (BackslashCount < 5) do
  begin
    Position := PosEx('\', AString, Position + 1);
    if Position > 0 then
      Inc(BackslashCount);
  end;

  // If 5th backslash is found, extract the substring from that position
  if BackslashCount = 5 then
    Result := Copy(AString, Position, Length(AString) - Position + 1);
end;

end.
