unit uImportDefinition;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Data.DB, DBClient, XmlDoc, XMLIntf, uXDS,
  uDBManager, uAxprovider,uAxLog;

type
  TImportDefinition = class
  private
    x: TXDS;
    function GetFieldType(fldDataType: TFieldType): String;

  public
    function ImportCDS(FileName: string): string;
  end;

implementation

uses uUtils;

function TImportDefinition.ImportCDS(FileName: string): string;
var
  CDS: TClientDataset;
  tablename, fld, datatype: string;
  field: TField;
  fdt: TFieldType;
  Value: string;
  f, v: Integer;
  sqlfieldstr, sqlvaluestr: string;
  sWhrCond, PrimaryIDField, PrimaryIDValue, CondStr: string;
  sqlfield, sqlvalue: tstringlist;
begin
  try
    WriteLog('importCDS function started..');
    CDS := TClientDataset.Create( { TComponent(Self) } nil);
    x := nil;
    x := TXDS.Create('xds' + floattostr(axprovider.dbm.gf.generatenumber), nil,
      axprovider.dbm.Connection, axprovider.dbm.gf);
    sqlfield := tstringlist.Create;
    // FileName := 'C:\Users\paroksh.AGILELABS\Desktop\CDSFile\fastr1.cds';
    tablename := ExtractFileName(ChangeFileExt(FileName, ''));
    CDS.LoadFromFile(FileName);
    x.append(tablename);
    for field in CDS.Fields do
    begin
      sqlfield.Add(field.FieldName);
    end;
    CDS.First;
    while not CDS.Eof do
    begin
      sqlvalue := tstringlist.Create;
      for field in CDS.Fields { sqlfield{.Count-1 } do
      begin
        sqlvalue.Add(field.AsString);
      end;
      for f := 0 to sqlfield.count - 1 do
      begin
        fdt := CDS.Fields[f].datatype;
        datatype := GetFieldType(fdt);
        if ((sqlvalue.Strings[f] = '''''') and (datatype = 'n')) then
        begin
          sqlvalue.Strings[f] := '0';
        end;
        x.Submit(sqlfield.Strings[f], { edName.Text } sqlvalue.Strings[f],
          datatype);
      end;
      PrimaryIDField := tablename + 'id';
      PrimaryIDValue := CDS.Fieldbyname(PrimaryIDField).AsString;
      CondStr := PrimaryIDField + '=' + PrimaryIDValue;
      x.AddorEdit(tablename, CondStr);
      sqlvalue.free;
      CDS.Next;
    end;
    x.close;
    write('   - ');
    Console_write(tablename + '.cds ', 10);
    write('Defination table imported Successfully...!');
    writelog('Defination table for '+tablename+' imported Successfully...!');
    writeln;
    AxStructures.Add(tablename + '.cds');
    writelog('importCDS function ends..');
  except
    on E: Exception do
    begin
      Console_write('   - Error',12);
      //writeln;
      writeln('while inserting into ' + tablename + ' table ' +E.Message);
      writelog('while inserting into ' + tablename + ' table ' +E.Message);
    end;
  end;
end;

function TImportDefinition.GetFieldType(fldDataType: TFieldType): String;
begin
  if (fldDataType in [ftString, ftFixedChar, ftWideString]) then
    Result := 'c'
  else if (fldDataType in [ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency,
    ftBCD, ftBytes, ftVarBytes, ftAutoInc, ftLargeInt, ftFMTBcd]) then
    Result := 'n'
  else if (fldDataType in [ftDate, ftTime, ftDateTime, ftTimeStamp]) then
    Result := 'd'
  else if (fldDataType in [ftMemo, ftFmtMemo, ftOraClob]) then
    Result := 't'
  else if (fldDataType in [ftblob, ftGraphic, ftOraBlob]) then
    Result := 'i'
  else if (fldDataType in [ftBoolean]) then
    Result := 'b'
  else if (fldDataType in [ftunknown, ftVariant, ftInterface, ftParadoxOLE,
    ftDBaseOLE, ftTypedBinary, ftADT, ftArray, ftReference, ftDataSet,
    ftIDispatch, ftGUID, ftCursor]) then
    Result := 'u';
end;

end.
