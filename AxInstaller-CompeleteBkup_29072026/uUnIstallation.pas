unit uUnIstallation;

interface

// plugininfo.dat
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  IdAuthentication,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, IdMultipartFormData,
  StrUtils,
  System.IOUtils, System.Types, System.Generics.Collections, DBXJSON, uUtils,
  DB, DBClient,uAxLog,
  SimpleDS, Provider, SqlExpr, DBXCommon, DBXOracle, uImportStructures,
  uGitManager, uInstallDbScripts, uInstallRMQClients, uDoCoreAction,
  uAxprovider, uDbManager;

type
  TUnIstallation = class
  private
    function deletestructure(): string;
    function completionmsg(): string; // 2
    function FindFolder(path: string): string;


  public
    function checkplugininfo(nameofplugin: string): boolean;
    function startUninstallation(plugin: string): string;
  end;

implementation

function TUnIstallation.startUninstallation(plugin: string): string; // 1
begin
  writeln('PLUGIN UNINSTALLATION PROCESS');
  writeln('================================');
  writeln;
  writeln;

  checkplugininfo(selectedplugin);

  readln;
end;

function TUnIstallation.deletestructure(): string; // 3
var
  action: TDoCoreAction;
  transid: string;
  JSONText: string;
  PluginJSONArray, sarray: TJSONArray;
  JSONObject, opluginObject, ipluginObject: TJSONObject;
  count, I, J: integer;
  jsonPair: TJSONPair;
  arraystr: TArray<string>;
  Ext: string;
begin
  JSONText := TFile.ReadAllText('plugininfo.dat');
  JSONText := Trim(JSONText);
  JSONText := StringReplace(JSONText, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
  JSONText := StringReplace(JSONText, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
  JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  PluginJSONArray := JSONObject.Get('plugininfo').jsonvalue as TJSONArray;
  count := PluginJSONArray.Size;
  for I := 0 to count - 1 do
  begin
    opluginObject := PluginJSONArray.Get(I) as TJSONObject;
    jsonPair := opluginObject.Get('name');
    if lowercase(jsonPair.jsonvalue.Value) = lowercase(selectedplugin) then
    begin
      ipluginObject := opluginObject.Get(selectedplugin)
        .jsonvalue as TJSONObject;
      sarray := ipluginObject.Get('axpertstructures').jsonvalue as TJSONArray;
      SetLength(arraystr, sarray.Size);
      action := TDoCoreAction.Create(axprovider);
      for J := 0 to sarray.Size - 1 do
      begin
        arraystr[J] := sarray.Get(J).tostring;
        Ext := ExtractFileExt(arraystr[J]);
        if comparestr(Copy(Ext, 1, length(Ext) - 1), '.ivw') = 0 then
        begin // .ivw
          transid := Copy(arraystr[J], 1, length(arraystr[J]) - 5);
          if AnsiStartsText('"', transid) then
            Delete(transid, 1, 1);
          if AnsiEndsText('"', transid) then
            Delete(transid, length(transid), 1);
          action.DeleteIviewDef(transid, True);
        end;
        if comparestr(Copy(Ext, 1, length(Ext) - 1), '.trn') = 0 then
        begin
          transid := Copy(arraystr[J], 1, length(arraystr[J]) - 5);
          if AnsiStartsText('"', transid) then
            Delete(transid, 1, 1);
          if AnsiEndsText('"', transid) then
            Delete(transid, length(transid), 1);
          action.DeleteTStructDef(transid, True);
        end;

      end;

    end;

  end;

end;

function TUnIstallation.completionmsg(): string;
begin
  writeln('3. Plugin UnInstallation Completed Successfully!',3);
  writeln;
  writeln(' UNINSTALLATION SUMMARY');
  writeln('=========================');
  writeln;
  writeln('  -' + selectedplugin + ' uninstallation completed without errors.');
end;

function TUnIstallation.checkplugininfo(nameofplugin: string): boolean;
var
  plugininfopath: string;
  JSONText: string;
  JSONObject: TJSONObject;
  PluginJSONArray: TJSONArray;
  opluginObject {ipluginObject}: TJSONObject;
  jsonPair: TJSONPair;
//  webfilesJSONArray: TJSONArray;
//  rmqclientsJSONArray: TJSONArray;
//  axpertstructures: TJSONArray;
//  plname: string;
  count: integer;
  plugininfo: textfile;
  I, J: integer;
begin
  try

    plugininfopath := {getcurrentdir()} AppDir + '\' + 'plugininfo.dat';
    if FileExists(plugininfopath) then
    begin
      JSONText := TFile.ReadAllText('plugininfo.dat');
      JSONText := Trim(JSONText);
      JSONText := StringReplace(JSONText, '\\', '\',
        [rfReplaceAll, rfIgnoreCase]);
      JSONText := StringReplace(JSONText, '\', '\\',
        [rfReplaceAll, rfIgnoreCase]);
      if length(JSONText) < 10 then
      begin
        console_write('   -' + selectedplugin + 'is not installed..', 10);
        writeln;

      end
      else
      begin

        console_write('1. Starting Plugin UnInstallation:', 3);
        writeln;
        writeln('  - Deleting Webfiles:');
        FindFolder(runwebcodepath);

        console_write('   - Webfiles deleted successfully.', 10);
        writeln;
        writeln;
        writeln('  - Deleting RMQClient Files:');

        FindFolder(rmqclientpath);
        console_write('   - RMQClient Files deleted successfully.', 10);
        writeln;
        writeln;
        writeln('  - Deleting Structures,Reports :');
        deletestructure();
        console_write('   - Structures,Reports deleted successfully.',10);
        JSONObject := TJSONObject.Create;
        JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;

        if JSONObject.Get('plugininfo').jsonvalue.tostring <> '' then
        begin
          PluginJSONArray := JSONObject.Get('plugininfo')
            .jsonvalue as TJSONArray;
          count := PluginJSONArray.Size;
          for I := 0 to count - 1 do
          begin
            for J := 0 to PluginJSONArray.Size - 1 do
            begin
              opluginObject := PluginJSONArray.Get(J) as TJSONObject;
              jsonPair := opluginObject.Get('name');
              if lowercase(jsonPair.jsonvalue.Value) = lowercase(selectedplugin)
              then
              begin
                PluginJSONArray.Remove(J);
                AssignFile(plugininfo, 'plugininfo.dat');
                rewrite(plugininfo);
                writeln(plugininfo, PluginJSONArray.tostring);
                closefile(plugininfo);
              end;
            end;
          end;
        end;
        writeln;
        completionmsg();
      end;
    end
  except
    on E: Exception do
      writeln('An exception occurred: ', E.Message);
  end;
end;

function TUnIstallation.FindFolder(path: string): string;
var
  folderarray, fileArray: TArray<string>;
  foldercount, filecount, I: integer;
  searchpath: String;
begin
  try
    if not directoryExists(path) then
    begin
      writeln;
      path:=StringReplace(path, '\\', '\', [rfReplaceAll]);
      if (path=rmqclientpath)or(path = runwebcodepath) then
      begin
        exit;
      end;
      writeln('  - Webfiles are not available for ' +path+ selectedplugin);
      exit;
    end;

    folderarray := TArray<string>(TDirectory.GetDirectories(path));
    fileArray := TArray<string>(TDirectory.Getfiles(path));
    filecount := length(fileArray);
    foldercount := length(folderarray);

    if filecount > 0 then
    begin
      for I := 0 to filecount - 1 do
      begin
        Tfile.delete(fileArray[I]);
        write('   - ');
        Console_write(Extractfilename(fileArray[I]), 10);
        write(' deleted Successfully...!');
        writeln;
      end;
    end;
    for I := 0 to foldercount - 1 do
    begin
      searchpath := folderarray[I];
      FindFolder(searchpath);
    end;
    if (filecount=0) and (foldercount=0) then
    begin
      path:=ExcludeTrailingPathDelimiter(path);
      path:=StringReplace(path, '\\', '\', [rfReplaceAll]);
      runwebcodepath:= StringReplace(runwebcodepath, '\\', '\', [rfReplaceAll]);
      rmqclientpath:= StringReplace(rmqclientpath, '\\', '\', [rfReplaceAll]);
      if (path=rmqclientpath)or(path = runwebcodepath) then
      begin
        exit;
      end;
      Tdirectory.delete(path);
      exit;
    end;
  except
    on E: Exception do
    begin
      console_write('Error: ' + E.Message, 12);
      writeln;
      readln;
    end;
  end;
end;

end.
