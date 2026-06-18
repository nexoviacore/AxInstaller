(*
  This object is for Publishing DWB structures.
*)
unit uDWBPublish;
{Copied from Axpert9-XE3\Ver 11.1}

interface

uses classes, windows, StdCtrls, Dialogs, Messages, ExtCtrls, Sysutils,
  StrUtils, Variants, Data.DB, uAxProvider, uXDS, DBXJSON, IdcoderMIME,
  system.Types, DBClient, XMLDoc, XMLIntf, uDoCoreAction,uCompress;

type
  TDWBPublish = class

  Private
    // List to maintain list published structures
    slProcessedStructures,slRuntimeDefStructs,slBackupStructList: TStringList;
    dbObjXDS : TXDS;
    sTargetSchemaName,sCurrentPublishTransId : String;

    procedure Init;
    procedure AddRecordToTargetPublishTable(sPublishTable, sPrimaryField,
      sPrimaryFieldValue: String; dsCDS: TClientDataSet);
    procedure ClearRecordFromTable(sPublishTable, sPrimaryField,
      sPrimaryFieldValue: String);
    procedure CloneTable(pExistingTbl, pNewTbl: String);
    procedure CopyDataFromTable(pSourceTable, pTargetTable, pPrimaryField,
      pPrimaryFieldValue: String);
    procedure DoBackUpTableBeforePublish(sPublishTable, sPrimaryField,
      sPrimaryFieldValue: String);
    function DoPublishFromCDS(pCDSFilename, pPublishTable, pPublishPrimaryField,
      pPublishedUserName: String): String;

    procedure UpdatePublishDetailsInDetailsTable(pTransid,pTranstype, pPublishno,
      pRemarks: String);
    procedure DoUpdateCoreStructureTables(pslPublishedStructures: TStringList);
    procedure UpdatePublishError(pTransid,pErrMsg: String);
    procedure DisableTriggers;
    procedure EnableTriggers;
    procedure CopyTableData(pSourceTable, pTargetTable, pPrimaryField,
      pPrimaryFieldValue, pBackUpSQLText: String);
    procedure BackUpAndDeleteIviewDef(sTransid: string; bIsAppSchema: boolean);
    procedure BackUpAndDeleteTStructDef(sTransid: string; bIsAppSchema: boolean);
    procedure DoBackUpAndCleanTables(pPublishRunTimeDef: Boolean; pExportType,
      pTransId: String);
    procedure DoBackUpTable(sPublishTable, sPrimaryField, sPrimaryFieldValue,
      sBackUpSQLText: String);
    procedure WriteStream(fname, table, where: String; stm: TStringStream);

  Public
    AxProvider: TAxProvider;
    iPublishNo: Integer;

    // list to maintain structures which got failed to publish
    slErrStructs: TStringList;
    sComments : String;

    bPublishRunTimeDef,bExportDBObjects,bPublishAppSchema,bPublishDesignTimeDefinition : Boolean;
    sPublishStructXML : String;
    sPublish_SourceSchema,sPublish_DropQuery : String;

    constructor create(pAxpro: TAxProvider);
    destructor destroy; override;

    procedure CreateDWBPublishTables;
    function GetMaxofPublishNoFromPublishTable: Integer;
    function ProcessPublishStructure(pListOfExportedStrcutFileNames: String;
      pExportedFilePath: String = ''): TStringList;
    function ReadCDSFileandPushtoDB(pCDSFilename: String): String;

  end;

Const
  cSeparator = '#';

implementation

// Constructor
Constructor TDWBPublish.create(pAxpro: TAxProvider);
var
  sStartPath: String;
begin
  AxProvider := pAxpro;
  AxProvider.dbm.gf.dodebug.Msg('Constructor create starts.');
  Init;
  AxProvider.dbm.gf.dodebug.Msg('Constructor create ends.');
end;

// Destructor
Destructor TDWBPublish.destroy;
begin
  AxProvider.dbm.gf.dodebug.Msg('Destructor destroy starts.');
  if Assigned(dbObjXDS) then
    FreeAndNil(dbObjXDS);
  if Assigned(slProcessedStructures) then
    FreeAndNil(slProcessedStructures);
  if Assigned(slRuntimeDefStructs) then
    FreeAndNil(slRuntimeDefStructs);
  if Assigned(slErrStructs) then
    FreeAndNil(slErrStructs);
  if Assigned(slBackupStructList) then
    FreeAndNil(slBackupStructList);
  AxProvider.dbm.gf.dodebug.Msg('Destructor destroy ends.');
end;

// Init - Initialization of objects
Procedure TDWBPublish.Init;
var
  iIdx : Integer;
begin
  dbObjXDS := nil;
  slProcessedStructures := nil;
  slProcessedStructures := TStringList.create;
  slProcessedStructures.StrictDelimiter := True;

  slRuntimeDefStructs := nil;
  slRuntimeDefStructs := TStringList.create;
  slRuntimeDefStructs.StrictDelimiter := True;

  slErrStructs := nil;
  slErrStructs := TStringList.create;
  slErrStructs.StrictDelimiter := True;

  slBackupStructList := nil;
  slBackupStructList := TStringList.Create;

  CreateDWBPublishTables;
  iPublishNo := GetMaxofPublishNoFromPublishTable;

  sTargetSchemaName := AxProvider.dbm.Connection.ProjectName;
  iIdx := pos('\',sTargetSchemaName);
  if iIdx > 0 then
    sTargetSchemaName := copy(sTargetSchemaName,1,iIdx-1);
  bPublishAppSchema := False;
  bPublishDesignTimeDefinition := False;

  sCurrentPublishTransId := '';
end;


// PUBLISH functionalities starts here
// ***********************************//

// Method to clone the table
(*
  This method will clone the given table without data.
*)
Procedure TDWBPublish.CloneTable(pExistingTbl, pNewTbl: String);
var
  sTableScript, sAlterScript: String;
  xdsExecute: TXDS;
begin
  AxProvider.dbm.gf.dodebug.Msg('CloneTable starts.');
  sTableScript := '';
  if AxProvider.dbm.connection.dbtype = 'oracle' then
  begin
    sTableScript := 'CREATE TABLE ' + pNewTbl + ' AS' + ' SELECT * FROM ' +
      pExistingTbl + ' WHERE 1=0';
    sAlterScript := 'ALTER TABLE ' + pNewTbl + ' ADD publishno numeric(6)';
  end
  else if AxProvider.dbm.connection.dbtype = 'ms sql' then
  begin
    sTableScript := 'SELECT * INTO ' + pNewTbl + ' FROM ' + pExistingTbl +
      ' WHERE 1=2';
    sAlterScript := 'ALTER TABLE ' + pNewTbl +
      ' ADD COLUMN publishno numeric(6)';
  end
  else if AxProvider.dbm.connection.dbtype = 'mysql' then
  begin
    //sTableScript := 'CREATE TABLE ' + pNewTbl + ' LIKE ' + pExistingTbl;
    sTableScript := 'CREATE TABLE '+pNewTbl+
                    ' SELECT * FROM '+pExistingTbl+' LIMIT 0';
    sAlterScript := 'ALTER TABLE ' + pNewTbl +
      ' ADD COLUMN publishno numeric(6)';
  end
  else if Lowercase(AxProvider.dbm.connection.dbtype) = 'postgre' then
  begin
    sTableScript := 'CREATE TABLE ' + pNewTbl + ' AS' + ' TABLE ' + pExistingTbl
      + ' WITH NO DATA';
    sAlterScript := 'ALTER TABLE ' + pNewTbl +
      ' ADD COLUMN publishno numeric(6)';
  end;
  if sTableScript = '' then
    Exit;
  xdsExecute := nil;
  xdsExecute := AxProvider.dbm.GetXDS(nil);
  xdsExecute.buffered := True;
  try
    try
      AxProvider.dbm.gf.dodebug.Msg('CloneTable create script ' + sTableScript);
      xdsExecute.sqltext := sTableScript;
      xdsExecute.execsql;

      AxProvider.dbm.gf.dodebug.Msg('CloneTable alter script ' + sAlterScript);
      xdsExecute.sqltext := sAlterScript;
      xdsExecute.execsql;
    Except
      on E: Exception do
        AxProvider.dbm.gf.dodebug.Msg('Error in CloneTable : ' + E.Message);
    end;
  finally
    if Assigned(xdsExecute) then
      FreeAndNil(xdsExecute);
  end;
  AxProvider.dbm.gf.dodebug.Msg('CloneTable ends.');
end;

// CopyDataFromTable
(*
  this method is to copy data from one table to another table.
*)
Procedure TDWBPublish.CopyDataFromTable(pSourceTable, pTargetTable,
  pPrimaryField, pPrimaryFieldValue: String);
var
  xdsSource, xdsTarget: TXDS;
  sSQLtext, sFieldName, sFieldValue, sFieldType: String;
  sWhrCond,sTableIdCond,sFilterCondition : String;
  iRecIdx, iColIdx: Integer;
  fField: TField;

  sTempFile,sLOBFieldName,sLOBFieldType : String;
  bIsUpdateLOBField : Boolean;
  strmLOBData : TMemoryStream;
begin
  AxProvider.dbm.gf.dodebug.Msg('CopyDataFromTable starts.');
  try
    xdsSource := nil;
    xdsTarget := nil;
    strmLOBData := nil;
    try
      xdsSource := AxProvider.dbm.GetXDS(nil);
      xdsTarget := AxProvider.dbm.GetXDS(nil);

      xdsSource.buffered := True;
      // xdsTarget.buffered := True;

      pPrimaryFieldValue := Lowercase(pPrimaryFieldValue);
      sSQLtext := 'SELECT * FROM ' + pSourceTable;

      //SQL Lower() not added in the where condition , when the field is ID field.
      if lowercase(pPrimaryField) = lowercase(pSourceTable+'id') then
      begin
         sWhrCond :=  pPrimaryField + ' = ' +
          QuotedStr(pPrimaryFieldValue);
      end
      else
      begin
        sWhrCond :=
          AxProvider.dbm.gf.SQLLower + '(' + pPrimaryField + ') = ' +
          QuotedStr(pPrimaryFieldValue);
      end;

      sSQLtext := sSQLtext + ' WHERE '+ sWhrCond;

      xdsSource.CDS.CommandText := sSQLtext;
      xdsSource.open;

      if (xdsSource.CDS.RecordCount > 0) then
      begin
        AxProvider.dbm.gf.dodebug.Msg
          ('Delete record from backup table if the record exists for ' +
          pPrimaryField);
        ClearRecordFromTable(pTargetTable, pPrimaryField, pPrimaryFieldValue);
        AxProvider.dbm.gf.dodebug.Msg('Copying data from ' + pSourceTable +
          ' to ' + pTargetTable);
        xdsSource.first;
        for iRecIdx := 0 to xdsSource.CDS.RecordCount - 1 do
        begin
          (*
          When adding record to Target table AddorEdit called instead of Append.
          The reason is, due to foreign key constraints data may not delete from Primary tables when calling ClearRecordFromTable.
          In that case, AddorEdit will update the records in Target table if it exists.
          ref : xdsTarget.AddorEdit
        *)
          xdsTarget.close;
          //xdsTarget.Append(pTargetTable);

          for iColIdx := 0 to xdsSource.Fields.Count - 1 do
          begin
            fField := xdsSource.CDS.Fields[iColIdx];
            sFieldType := AxProvider.dbm.gf.GetFieldType(fField.DataType);

            if (sFieldType = 't') or (sFieldType = 'i') then
            begin
              // on 30-04-2021 , code added to handle Memo and blob fields.
              sLOBFieldName := fField.FieldName;
              sLOBFieldType := sFieldType;
              if Not Assigned(strmLOBData) then
                strmLOBData := TMemoryStream.Create;
              if sLOBFieldType = 'i' then //blob
                TBlobField(fField).SaveToStream(strmLOBData)
              else //sLOBFieldType = 't'  //clob
                TMemoField(fField).SaveToStream(strmLOBData);
              bIsUpdateLOBField := True;
            end
            else
            begin
              sFieldName := fField.FieldName;
              sFieldValue := VartoStr(fField.Value);
              xdsTarget.Submit(sFieldName, sFieldValue, sFieldType);
            end;
          end;
          // Update PublishNo
          //xdsTarget.Submit('Publishno', InttoStr(iPublishNo), 'c');
          xdsTarget.Submit('Publishno', InttoStr(iPublishNo), 'n');

          // slPublishNo.Add(pPrimaryFieldValue + '=' + InttoStr(iPublishNo));
          // Inc(iPublishNo);

          // xdsTarget.Post;
          (*
           To update record , we called AddorEdit with where condition.
           Where condition was framed with primary fieldname , but it was overwriting when Inserting TStruct / Iview field records.

           Online definition table, we are maintaining as TStructs so all table will have tableid field.
           To Fix overwrite issue, we added tableid condition also .
          *)
          sTableIdCond := '';
          sFilterCondition := sWhrCond;

          (*
          For tables which are having primary field other than transid -
          Most of the core tables having transid field as primary field but some table like axtoolbar  has duplcated transid values since it has key as
          primary field value.
          *)

          if LowerCase(pSourceTable) = 'axtoolbar' then  //For axtoolbar
          begin
            //If it's a toolbar then it has to be updated based on key and name (transid)
            //here we already considering transid since CopyDataFromTable takes transid as primary field
            sTableIdCond := 'key'+'='+QuotedStr(VartoStr(xdsSource.CDS.FieldValues['key']));
            if sFilterCondition <> '' then
              sFilterCondition := sFilterCondition + ' and '+ sTableIdCond
            else
              sFilterCondition := sTableIdCond;
          end
          else if Assigned(xdsSource.FindField(pSourceTable+'id')) and (VartoStr(xdsSource.CDS.FieldValues[pSourceTable+'id']) <> '') then
          begin
            sTableIdCond := pSourceTable+'id'+'='+VartoStr(xdsSource.CDS.FieldValues[pSourceTable+'id']);
            if sFilterCondition <> '' then
              sFilterCondition := sFilterCondition + ' and '+ sTableIdCond
            else
              sFilterCondition := sTableIdCond;
          end;

          xdsTarget.AddorEdit(pTargetTable,{sWhrCond}sFilterCondition);  //iPublishNo may need to be added to keep all records

          //Update LOB field data  (Memo and blob fields handled here)
          if (bIsUpdateLOBField) and (Assigned(strmLOBData)) then
          begin
            sTempFile :=AxProvider.dbm.gf.startpath+'\temp\LOBdata'+AxProvider.dbm.gf.getnumber;
            if Not DirectoryExists(AxProvider.dbm.gf.startpath+'\temp') then
              ForceDirectories(AxProvider.dbm.gf.startpath+'\temp');

            strmLOBData.Position := 0;
            //Save stream to temporary file
            strmLOBData.SaveToFile(sTempFile);

            if sLOBFieldType = 'i' then //if Blob
              //Call writblob to update blob data in table
              AxProvider.dbm.WriteBlob(sLOBFieldName,pTargetTable,sFilterCondition{sWhrCond},sTempFile)
            else //sLOBFieldType = 't' //Clob
              //Call writmemo to update clob data in table
              AxProvider.dbm.WriteMemo(sLOBFieldName,pTargetTable,sFilterCondition{sWhrCond},sTempFile);

            //delete temporary file
            deletefile(sTempFile);
            //Reset values
            sTempFile := '';
            sLOBFieldName := '';
            sLOBFieldType := '';
            bIsUpdateLOBField := False;
            FreeAndNil(strmLOBData);
          end;
          xdsSource.CDS.Next;
        end;
      end;
    Except
      on E: Exception do
        AxProvider.dbm.gf.dodebug.Msg('Error in CopyDataFromTable ' +
          E.Message);
    end;

  finally
    if Assigned(xdsSource) then
      FreeAndNil(xdsSource);
    if Assigned(xdsTarget) then
      FreeAndNil(xdsTarget);
    if Assigned(strmLOBData) then
      FreeAndNil(strmLOBData);
  end;
  AxProvider.dbm.gf.dodebug.Msg('CopyDataFromTable ends.');
end;

// Do backup before publish
(*
  This method is to take backup of publish record from the target table (only if data exist for particular publish structure)
*)
Procedure TDWBPublish.DoBackUpTableBeforePublish(sPublishTable, sPrimaryField,
  sPrimaryFieldValue: String);
var
  sBackUpTable: String;
begin
  AxProvider.dbm.gf.dodebug.Msg('DoBackUpTableBeforePublish starts.');
  try
    sBackUpTable := 'AxPublishBackup_' + sPublishTable;
    if Not AxProvider.TableFound(sBackUpTable) then
      // Calling clone tbale
      CloneTable(sPublishTable, sBackUpTable);
    // Calling copy data from table
    CopyDataFromTable(sPublishTable, sBackUpTable, sPrimaryField,
      sPrimaryFieldValue);
  Except
    on E: Exception do
      AxProvider.dbm.gf.dodebug.Msg('Error in DoBackUpTableBeforePublish ' +
        E.Message);
  end;
  AxProvider.dbm.gf.dodebug.Msg('DoBackUpTableBeforePublish ends.');
end;


// Clear existing data from publish table for the particular primary field value
Procedure TDWBPublish.ClearRecordFromTable(sPublishTable, sPrimaryField,
  sPrimaryFieldValue: String);
var
  clrXDS: TXDS;
  sMainSQLQuery,sSqlQuery,sWhrCond: String;
begin
  AxProvider.dbm.gf.dodebug.Msg('ClearRecordFromTable starts.');
  try
    try
      clrXDS := nil;
      clrXDS := AxProvider.dbm.GetXDS(nil);
      clrXDS.close;
      sMainSQLQuery := 'delete from ' + sPublishTable;

       //SQL Lower() not added in the where condition , when the field is ID field.
      (*
      When handling detail table , Primary field and IDfield may diff , needs to be checked.
      Now its handled in exception.
      *)
      if lowercase(sPrimaryField) = lowercase(sPublishTable+'id') then
      begin
         sWhrCond := sPrimaryField + ' = ' +
          QuotedStr(Lowercase(sPrimaryFieldValue));
      end
      else
      begin
        sWhrCond :=
          AxProvider.dbm.gf.SQLLower + '(' + sPrimaryField + ') = ' +
          QuotedStr(Lowercase(sPrimaryFieldValue));
      end;

      sSqlQuery := sMainSQLQuery + ' WHERE '+sWhrCond;

      AxProvider.dbm.gf.dodebug.Msg('SQL query : ' + sSqlQuery);
      clrXDS.sqltext := sSqlQuery;

      clrXDS.execsql;
    Except
      on E: Exception do
      begin
        AxProvider.dbm.gf.dodebug.Msg('Error in ClearRecordFromTable ' +
          E.Message);
        //Retry without lower function when err with function lower(numeric) comes
        if pos('function lower(numeric) does not exist',E.Message) > 0 then
        begin
          sWhrCond := sPrimaryField + ' = ' +QuotedStr(Lowercase(sPrimaryFieldValue));
          sSqlQuery := sMainSQLQuery + ' WHERE '+sWhrCond;
          clrXDS.sqltext := sSqlQuery;
          clrXDS.execsql;
        end;
        //raise Exception.create(E.Message);
      end;
    end;
  finally
    if Assigned(clrXDS) then
      FreeAndNil(clrXDS);
  end;
  AxProvider.dbm.gf.dodebug.Msg('ClearRecordFromTable ends.');
end;

// Add record to publish table
(*
  This method is to add new record to definition table
*)
Procedure TDWBPublish.AddRecordToTargetPublishTable(sPublishTable,
  sPrimaryField, sPrimaryFieldValue: String; dsCDS: TClientDataSet);
var
  InsUpdXDS: TXDS;
  sWhrCond,sTableIdCond,sFilterCondition : String;
  iRowIdx, iColIdx: Integer;

  fField: TField;
  ftFieldType: TFieldType;
  sFieldType, sFieldName, sFieldValue: String;

  sTempFile,sLOBFieldName,sLOBFieldType : String;
  bIsUpdateLOBField,bIsAxpertDefTable : Boolean;
  strmLOBData : TMemoryStream;
  stsStream : TStringStream;

  function MemoryStreamToString(M: TMemoryStream): string;
  begin
    SetString(Result, PChar(M.Memory), M.Size div SizeOf(Char));
  end;

  function IsAxpertDefTable(pPublishTable : String):Boolean;
  begin
    Result := False;
    pPublishTable := Lowercase(pPublishTable);
    if (pPublishTable = 'tstructs') or (pPublishTable='iviews')
       or (pPublishTable='lviews') or (pPublishTable='axpages')
       or (pPublishTable='axpertreports') then
      Result := True;
  end;
begin
  AxProvider.dbm.gf.dodebug.Msg('AddRecordToTargetPublishTable starts.');
  try
    try
      InsUpdXDS := nil;
      strmLOBData := nil;
      stsStream := nil;
      bIsUpdateLOBField := False;
      bIsAxpertDefTable := False;
      sWhrCond := '';
      sLOBFieldName := '';
      sLOBFieldType := '';
      if (sPrimaryField <> '') and (sPrimaryFieldValue <> '') then
        sWhrCond := sPrimaryField + '=' + QuotedStr(sPrimaryFieldValue);

      InsUpdXDS := AxProvider.dbm.GetXDS(Nil);
      dsCDS.first;
      for iRowIdx := 0 to dsCDS.RecordCount - 1 do
      begin
        (*
          When adding record to Target table AddorEdit called instead of Append.
          The reason is, due to foreign key constraints data may not delete from Primary tables when calling ClearRecordFromTable.
          In that case, AddorEdit will update the records in Target table if it exists.
          ref : InsUpdXDS.AddorEdit
        *)

        InsUpdXDS.close;
        //InsUpdXDS.Append(sPublishTable);
        for iColIdx := 0 to dsCDS.Fields.Count - 1 do
        begin
          fField := dsCDS.Fields[iColIdx];
          // We brought primary field to first place and the same field will be there in
          // SQL also ,when reading it  may come two times and the name will come with suffix _1 when it occurs secondtime
          // To Skip that field we added below condition.
          if (fField.FieldName = sPrimaryField + '_1') then
            Continue;
          (*
          Earlier ftWideMemo was not handled , due to that ftFieldType was taken wrongly and failed to update data some cases.
          Now we handled it in gf.GetFieldType but the problem is when the table having two or nore blob/clob fields then
          the below logic will fail to update all the clob / blob fields.  Since as of now we have written code to handle single clob/ blob fields.

          Our Defchema always run on Postgres and the postgres having capablity to handle clob with normal insert.(no need of writememo).
          As of now we are handling with Normal insert (xds.submit)   | For postgres
          Appschema table doesn't have more than one blob/ clob fields as of now. This may need to be handled in future.

          As of now we have problem with dwb_iviewsqls.

          When Run schema's publish related tables have more than one clob/blob then this will cause issue.As of now we do not have any table like that.
          *)
          ftFieldType := fField.DataType;
          if (ftFieldType = ftWideMemo) and (Lowercase(AxProvider.dbm.connection.dbtype) = 'postgre') then
            sFieldType := 'c'
          else
            sFieldType := AxProvider.dbm.gf.GetFieldType(ftFieldType);
          if (sFieldType = 't') or (sFieldType = 'i') then
          begin
            // on 30-04-2021 , code added to handle Memo and blob fields.
            sLOBFieldName := fField.FieldName;
            sLOBFieldType := sFieldType;
            if Not Assigned(strmLOBData) then
              strmLOBData := TMemoryStream.Create;
            if sLOBFieldType = 'i' then //blob
              TBlobField(fField).SaveToStream(strmLOBData)
            else //sLOBFieldType = 't'  //clob
              TMemoField(fField).SaveToStream(strmLOBData);
            bIsUpdateLOBField := True;
          end
          else
          begin
            sFieldName := fField.FieldName;
            //When reading datetime value , if we use .value then its converting to local datetime format , so we used .AsString
            sFieldValue := fField.AsString;//VartoStr(fField.Value);
            InsUpdXDS.Submit(sFieldName, sFieldValue, sFieldType);
          end;

        end;

        //InsUpdXDS.Post;
        (*
         To update record , we called AddorEdit with where condition.
         Where condition was framed with primary fieldname , but it was overwriting when Inserting TStruct / Iview field records.

         Online definition table, we are maintaining as TStructs so all table will have tableid field.
         To Fix overwrite issue, we added tableid condition also .
        *)
        sTableIdCond := '';
        sFilterCondition := sWhrCond;
        bIsAxpertDefTable := IsAxpertDefTable(sPublishTable);
        if Assigned(dsCDS.FindField(sPublishTable+'id')) and (VartoStr(dsCDS.FieldValues[sPublishTable+'id']) <> '')then
        begin
          sTableIdCond := sPublishTable+'id'+'='+VartoStr(dsCDS.FieldValues[sPublishTable+'id']);
          (*When TableID field exists, then we no need to merge primaryfield condition, since primary field
          value may change in some cases, (like for cards, card name cane be renamed , in that case , this may failed to
          work. To bhandle this we will use only TableID filter.
          [Future when its required then it can be enabled.]*)

          {
          if sFilterCondition <> '' then
            sFilterCondition := sFilterCondition + ' and '+ sTableIdCond
          else
            sFilterCondition := sTableIdCond;
          }
          sFilterCondition := sTableIdCond;

        end
        //if the table is tstructs/iviews/lviews then it may contain multiple blobs to handle that below code added
        else if bIsAxpertDefTable then
        begin
          sFilterCondition := sFilterCondition+' and blobno = '+VartoStr(dsCDS.FieldValues['blobno']);
        end
        //Most probably this scenarion comes only to axtoolbar table
        //so adding table check condition in if block , but this will work without that check also
        //When its required , we can remove that tabke check condition and make it as generic
        else if (lowercase(sPublishTable) = 'axtoolbar') and (sPrimaryField <> '') and  Assigned(dsCDS.FindField(sPrimaryField)) then
        begin
          //If it's a toolbar then it has to be updated based on key and name (transid)
          //When its axtoolbar primary field is key (can check this export axtoolbar since we considered first field as primary field)
          sPrimaryFieldValue := VartoStr(dsCDS.FieldValues[sPrimaryField]);
          sFilterCondition := sPrimaryField + '=' + QuotedStr(sPrimaryFieldValue) +' and name = '+QuotedStr(sCurrentPublishTransId);
        end;

        InsUpdXDS.AddorEdit(sPublishTable,{sWhrCond}sFilterCondition);

        //Update LOB field data  (Memo and blob fields handled here)
        if (bIsUpdateLOBField) and (Assigned(strmLOBData)) then
        begin
          sTempFile :=AxProvider.dbm.gf.startpath+'\temp\LOBdata'+AxProvider.dbm.gf.getnumber;
          if Not DirectoryExists(AxProvider.dbm.gf.startpath+'\temp') then
            ForceDirectories(AxProvider.dbm.gf.startpath+'\temp');

          strmLOBData.Position := 0;
          //if it has blob field then do following
          if bIsAxpertDefTable and (Assigned(dsCDS.Fields.FindField('blobno'))) then
          begin
            if sLOBFieldType = 'i' then //if Blob
            begin
              //Save stream to temporary file
              strmLOBData.SaveToFile(sTempFile);
              //Call writblob to update blob data in table
              AxProvider.dbm.WriteBlob(sLOBFieldName,sPublishTable,sFilterCondition{sWhrCond},sTempFile);
            end
            else //sLOBFieldType = 't' //Clob
            begin
              stsStream := TStringStream.Create(MemoryStreamToString(strmLOBData));
              stsStream.Position := 0;
              //Call writmemo to update clob data in table
              AxProvider.dbm.WriteMemo(sLOBFieldName,sPublishTable,sFilterCondition{sWhrCond},{sTempFile}stsStream);
              FreeAndNil(stsStream);
            end;
          end
          else
          begin
           //esle if no blob filed the do below stuf
           //Same to be applied where we used writeblob/wrietmemo
           stsStream := TStringStream.Create(MemoryStreamToString(strmLOBData));
           //stsStream.LoadFromStream(strmLOBData);
           //stsStream.CopyFrom(strmLOBData,0); // No need to position at 0 nor provide size
           stsStream.Position := 0;
            if stsStream.Size > 0 then
              WriteStream(sLOBFieldName,sPublishTable,sFilterCondition,stsStream); //dbm.WriteMemo('DIsplayContent','AxProcessDef',sWhereCond,stm);
            FreeAndNil(stsStream);
          end;


          //delete temporary file
          deletefile(sTempFile);
          //Reset values
          sTempFile := '';
          sLOBFieldName := '';
          sLOBFieldType := '';
          bIsUpdateLOBField := False;
          FreeAndNil(strmLOBData);
        end;

        dsCDS.Next;//dsCDS.CDS.Next;
      end;
    Except
      on E: Exception do
      begin
        AxProvider.dbm.gf.dodebug.Log(AxProvider.dbm.gf.Axp_logstr +
          '\uASBDefineObj\AddRecordToTargetPublishTable - ' + E.Message);
        AxProvider.dbm.gf.dodebug.Msg
          ('Error in AddRecordToTargetPublishTable : ' + E.Message);
        raise Exception.create(E.Message);
      end;
    end;
  finally
    if Assigned(InsUpdXDS) then
      FreeAndNil(InsUpdXDS);
    if Assigned(strmLOBData) then
      FreeAndNil(strmLOBData);
  end;
  AxProvider.dbm.gf.dodebug.Msg('AddRecordToTargetPublishTable ends.');
end;

// Update publish details to table
(*
  This method is to update publish details to publish history table (on success).
  We are maintaining Publishno for future purpose , with this ref we can do revert the particular publish .
*)
Procedure TDWBPublish.UpdatePublishDetailsInDetailsTable(pTransid,PTransType, pPublishno,
  pRemarks: String);
var
  qryXDS: TXDS;
begin
  AxProvider.dbm.gf.dodebug.Msg('UpdatePublishDetailsInDetailsTable starts.');
  qryXDS := nil;
  try
    try
      qryXDS := AxProvider.dbm.GetXDS(nil);
      qryXDS.close;
      qryXDS.Append('AxPublishHistory');
      qryXDS.Submit('Transid', pTransid, 'c');
      qryXDS.Submit('Transtype', pTransType, 'c');
      qryXDS.Submit('Publishedon',
        (datetimetostr(AxProvider.dbm.getserverdatetime)), 'd');
      qryXDS.Submit('Publishedby',
        AxProvider.dbm.gf.username { pPublishedby } , 'c');
      //qryXDS.Submit('Publishno', pPublishno, 'c');
      qryXDS.Submit('Publishno', pPublishno, 'n');
      qryXDS.Submit('Remarks', pRemarks, 'c');
      qryXDS.Post;
    Except
      on E: Exception do
        AxProvider.dbm.gf.dodebug.Msg
          ('Error in UpdatePublishDetailsInDetailsTable ' + E.Message);
    end;
  finally
    if Assigned(qryXDS) then
      FreeAndNil(qryXDS);
  end;
  AxProvider.dbm.gf.dodebug.Msg('UpdatePublishDetailsInDetailsTable ends.');
end;


// Do publish from cds  //returns primary field value
(*
  This method is to update target definition tables .
  NEW  data will be read from CDS file.
*)
Function TDWBPublish.DoPublishFromCDS(pCDSFilename, pPublishTable,
  pPublishPrimaryField, pPublishedUserName: String): String;
var
  dsCliendataSet: TClientDataSet;
  sExportStructType, sExportedTablename: String;
  sPrimaryFieldName, sPrimaryFieldValue: String;
  sStructXMLFieldName, sStructXMLFieldValue: String;
  fPrimaryField, fStructXMLField: TField;
  stm: TStringStream;

  sDBObjDDLScript,sExportTransId: String;
  fDBObjFld: TField;

  structXML : IXMLDocument;
Const
  sDBObjName = 'name';
  sDBObjScript = 'script';
begin
  AxProvider.dbm.gf.dodebug.Msg('DoPublishFromCDS starts.');
  try
    try
      result := '';
      structXML := nil;
      sCurrentPublishTransId := '';
      stm := nil;
      dsCliendataSet := nil;
      fPrimaryField := nil;
      fStructXMLField := nil;
      // We were receiving primaryfieldvalue , this has to be changed if it requires
      // sPrimaryFieldName := pPublishPrimaryField;
      dsCliendataSet := TClientDataSet.create(nil);
      dsCliendataSet.LoadFromFile(pCDSFilename);
      if (dsCliendataSet.RecordCount > 0) then
      begin
        sPublish_SourceSchema := '';
        sPublish_DropQuery := '';
        dsCliendataSet.first;
        if sPrimaryFieldName = '' then
          sPrimaryFieldName := dsCliendataSet.Fields[0].FieldName; //First field will be primary field , this is handled in uDWBExport
        fPrimaryField := dsCliendataSet.FindField(sPrimaryFieldName);
        bPublishRunTimeDef :=
          (dsCliendataSet.GetOptionalParam('runtimedefinition') = 'true');
        bPublishDesignTimeDefinition := (dsCliendataSet.GetOptionalParam('designtimedefinition') = 'true');

        (*
        If it is a AppSchema publish and the CDS belongs to designtimedefinition then skip
        or
        if it is a defschema publish and the cds belong to runtimedefinition then skip
        Since we are doing export and publish at signletime for both app and def schema , to avoid unnecessary updates
        in the defschema/appschema we have added the below condition.
        *)
        if ((bPublishAppSchema) and (bPublishDesignTimeDefinition)) or
           ((Not bPublishAppSchema) and (Not bPublishDesignTimeDefinition))
           then
          Exit;

        bExportDBObjects := (dsCliendataSet.GetOptionalParam('dbobjects')
          = 'true');

        sExportStructType :=
          Lowercase(AxProvider.dbm.gf.GetNthString
          (ExtractFileName(pCDSFilename), 1, cSeparator));
        sExportedTablename :=
          Lowercase(AxProvider.dbm.gf.GetNthString
          (ExtractFileName(pCDSFilename), 3, cSeparator));
        sPublishStructXML := '';
        (*
          To handle DBObjects ,

          Raw table data can be pushed in to target table directly , But for DB objects DDL query needs to be executed.
        *)
        if bExportDBObjects then // if DBobjects
        begin
          sDBObjDDLScript := '';
          // dsCliendataSet.FindField(sDBObjName);
          // Create / ALter scripts to be handled.

          fDBObjFld := dsCliendataSet.FindField(sDBObjScript);
          if Not Assigned(fDBObjFld) then
            raise Exception.create(sDBObjScript + ' field doesn''t exists in ' +
              pCDSFilename);

          (*
            //Mssql widememo cannot be read directly  //for Above 2012 Cast is required in SQL query
            if (AxProvider.dbm.connection.dbtype = 'ms sql') and (fDBObjFld.DataType = ftWideMemo) then
            begin
            //ReadMemo
            try
            stm := TStringStream.Create('');
            stm.Position := 0;
            TMemoField(fDBObjFld).SaveToStream(stm);

            if stm.Size<>0 then
            begin
            stm.Position := 0;
            sDBObjDDLScript := trim(stm.DataString);
            end;
            finally
            if Assigned(stm) then
            FreeAndNil(stm);
            end;

            end
            else
          *)
          sDBObjDDLScript := fDBObjFld.AsString;

          sPublish_SourceSchema := dsCliendataSet.GetOptionalParam
            ('sourceschema');
          sPublish_DropQuery := dsCliendataSet.GetOptionalParam('dropquery');

          // replace source schema name with target schema name in the DBObject scripts
          if AxProvider.dbm.Connection.dbtype = 'oracle' then
          // Oracle is case sensitive and use UPPERCASE for DB OBJECTS
            sDBObjDDLScript := StringReplace(sDBObjDDLScript,
              sPublish_SourceSchema, UPPERCASE(sTargetSchemaName),
              [rfReplaceAll, rfIgnoreCase])
          else
            sDBObjDDLScript := StringReplace(sDBObjDDLScript,
              sPublish_SourceSchema, sTargetSchemaName,
              [rfReplaceAll, rfIgnoreCase]);

          if sPublish_DropQuery <> '' then
          begin
            try
              AxProvider.execsql(sPublish_DropQuery, '', '', False);
            except

            end;
          end;
          try
            if Not Assigned(dbObjXDS) then
              dbObjXDS := AxProvider.dbm.GetXDS(nil);
            dbObjXDS.close;
            dbObjXDS.buffered := True;
            dbObjXDS.CDS.CommandText := sDBObjDDLScript;

            if ((AxProvider.dbm.Connection.dbtype = 'oracle') or
              (AxProvider.dbm.Connection.dbtype = 'mysql') or
              (AxProvider.dbm.Connection.dbtype = 'postgre')) then
            begin
              if { Pos('alter',lowercase(sDBObjDDLScript)) > 0 } AnsiStartsStr
                ('alter', Lowercase(trim(sDBObjDDLScript))) then
                dbObjXDS.execsql
              else
                dbObjXDS.Dbx.SQLConnection.ExecuteDirect(sDBObjDDLScript);
            end
            else if (AxProvider.dbm.Connection.dbtype = 'ms sql') then
            begin
              dbObjXDS.Ado.Connection.Execute(sDBObjDDLScript);
            end;
          Except
            on E: Exception do
            begin
              AxProvider.dbm.gf.dodebug.Msg
                ('Error while executing script in DoPublishFromCDS.');
              AxProvider.dbm.gf.dodebug.Msg('Script ' + sDBObjDDLScript);
              AxProvider.dbm.gf.dodebug.Msg('Error ' + E.Message);
              raise Exception.create(E.Message);
            end;
          end;
        end
        else
        begin
           sExportTransId := dsCliendataSet.GetOptionalParam('transid');
           sCurrentPublishTransId := sExportTransId;
           if slBackupStructList.IndexOf(sExportStructType+sExportTransId) < 0 then
           begin
             DoBackUpAndCleanTables(bPublishRunTimeDef,sExportStructType,sExportTransId);
             slBackupStructList.Add(sExportStructType+sExportTransId);
           end;
          (*
            Old Comment :

            To handle runtime definitions ,

            Iview data can be updated directly to the tables , but tstruct needs to be pushed through
            import object since for tstructs transaction tables needs to be updated.

            New comment :
            20/10/2023

            Decided to call WriteIviewdef, since that will update iviews table and creates axpages
            Other data update also can be done through this on AppSchema.

            Enabling the commented lines,
            or (sExportStructType='iv')
            or (sExportedTablename='iviews')

            ***
            Note : Reading from stm gives improper data, so let this update in actual table the lets read from that table
            using geyt structure.
            //The same can be done for Tstructs table also | when mutiblobs involves this needs to be verified.

          *)
          if ((sExportStructType = 'ts')  {or (sExportStructType='iv')}  ) and
            ((sExportedTablename = 'tstructs')
             {or (sExportedTablename='iviews')}  ) and (bPublishRunTimeDef or bPublishDesignTimeDefinition) then
          begin
            if Assigned(fPrimaryField) then
            begin
              sPrimaryFieldValue := VartoStr(fPrimaryField.Value);
              // Calling DoBackUpTableBeforePublish
              //Commented since its handled in DoBackUpAndCleanTables
              //DoBackUpTableBeforePublish(pPublishTable, sPrimaryFieldName,
              //  sPrimaryFieldValue);
            end;

            sStructXMLFieldName := 'props';
            fStructXMLField := dsCliendataSet.FindField(sStructXMLFieldName);
            if Not Assigned(fStructXMLField) then
              raise Exception.create('props field doesn''t exists in ' +
                pCDSFilename);

            stm := TStringStream.create('');
            stm.Position := 0;
            if (sExportStructType = 'ts') then
              TBlobField(fStructXMLField).SaveToStream(stm)
            else
              TMemoField(fStructXMLField).SaveToStream(stm);

            if stm.Size <> 0 then
            begin
              stm.Position := 0;
              if (sExportStructType = 'ts') then
              begin
                with TCompress.create do
                begin
                  stm := DecompressLicStringStream(stm);
                  destroy;
                end;
                stm.Position := 0;
              end;
              sPublishStructXML := trim(stm.DataString);
              if Assigned(fPrimaryField) then
              begin
                sPrimaryFieldValue := VartoStr(fPrimaryField.Value);
                result := sPrimaryFieldValue;
              end;
            end;
          end
          else
          begin
            (*
            if (bPublishAppSchema) and
              ((Not bPublishRunTimeDef) and ((sExportStructType = 'ts') or
              (sExportStructType = 'iv'))) then
            begin
              // Skip
              AxProvider.dbm.gf.dodebug.Msg
                ('App schema does not require definition related updates.');
            end
            else
            *)
            begin
              if Assigned(fPrimaryField) then
              begin
                sPrimaryFieldValue := VartoStr(fPrimaryField.Value);
                //Commented since its handled in DoBackUpAndCleanTables
                (*
                // Calling DoBackUpTableBeforePublish
                DoBackUpTableBeforePublish(pPublishTable, sPrimaryFieldName,
                  sPrimaryFieldValue);
                // Calling ClearRecordFromTargetPublishTable
                ClearRecordFromTable(pPublishTable, sPrimaryFieldName,
                  sPrimaryFieldValue);
                *)
                // Calling AddRecordToTargetPublishTable
                AddRecordToTargetPublishTable(pPublishTable, sPrimaryFieldName,
                  sPrimaryFieldValue, dsCliendataSet);

                //Adding newly get XML after storing in the target schema
                //This is only for iviews, the same can be done for tstructs if required.

                if (sExportStructType='iv') and (sExportedTablename='iviews')
                  and (bPublishRunTimeDef) then
                begin
                  AxProvider.dbm.gf.dodebug.Msg('Reading Iview XML (Runtime)...');
                  structXML := AxProvider.GetStructure('iviews',sExportTransId,'','');
                  if Assigned(structXML) then
                  begin
                    sPublishStructXML := structXML.XML.Text;
                  end
                  else
                    AxProvider.dbm.gf.dodebug.Msg('Iview XML not found.');
                end;



                result := sPrimaryFieldValue;
              end
              else
                AxProvider.dbm.gf.dodebug.Msg
                  ('Primary field ' + sPrimaryFieldName + ' not found in ' +
                  pCDSFilename);
            end;
          end;
        end;
      end;
    Except
      on E: Exception do
      begin
        AxProvider.dbm.gf.dodebug.Msg('Error in DoPublishFromCDS ' + E.Message);
        raise Exception.create(E.Message);
      end;
    end;
  finally
    if Assigned(stm) then
      FreeAndNil(stm);
  end;
  AxProvider.dbm.gf.dodebug.Msg('DoPublishFromCDS ends.');
end;

// Read cds file and push to db //returns processed structure type and it's name

(*
  read required information from CDS file name and calls DoPublishFromCDS to Import recrods.
*)
Function TDWBPublish.ReadCDSFileandPushtoDB(pCDSFilename: String): String;
var
  sCDSFileName: String;
  sExportedPrimaryField, sExportedTablename, sExportUser,
    sExportStructType: String;
  sPublishedTblPrimaryFieldValue: String;
  // ExportFileName format will be - sExportStructType+'#'+ExportStructName+'#'+sExportTableName+'#'+sExportUser+'#'+ Nowstring
begin
  AxProvider.dbm.gf.dodebug.Msg('ReadCDSFileandPushtoDB starts.');
  result := '';
  if pCDSFilename = '' then
    Exit;
  try
    sPublishedTblPrimaryFieldValue := '';
    sCDSFileName := ExtractFileName(pCDSFilename);

    sExportStructType := AxProvider.dbm.gf.GetNthString(sCDSFileName, 1,cSeparator);
    // We were receiving primaryfieldvalue instead of Primaryfieldname, this has to be changed if it requires
    // Usually this holds the transid
    sExportedPrimaryField := AxProvider.dbm.gf.GetNthString(sCDSFileName, 2,cSeparator);
    //UniqueValue | In Publish case it will be transid value
    sExportedTablename := AxProvider.dbm.gf.GetNthString(sCDSFileName, 3,cSeparator);
    sExportUser := AxProvider.dbm.gf.GetNthString(sCDSFileName, 4,cSeparator);
    // We are not getting username from client side , so we read from the exported files ,
    // Exoprted files will have the current user, so that can be used here.A
    if AxProvider.dbm.gf.username = '' then
      AxProvider.dbm.gf.username := sExportUser;

    (*
    Handling Backup and Cleaning definition tables here before starting the publishing.
    This will be executed for each Structures (Only once / For the first time). to handled that we used slProcessedStructures list.

    Earlier This was handled in the DoPublishFromCDS, But it failed to clear tables some cases.
    Ex :
    If structure having genmap and published to target. Later for some reason we removed genmap in source and published that structure.
    In that case  genmap details failed to delete in the target.
    This is due to we are deleting table based on the publish files we received. When there is no data in the source then that
    particular table will not be received.
    *)

    sPublishedTblPrimaryFieldValue :=
      DoPublishFromCDS(pCDSFilename { sCDSFileName } , sExportedTablename,
      sExportedPrimaryField, sExportUser);

    (*
    We were getting published structure name from DoPublishFromCDS method,
    but DoPublishFromCDS results primary field value from CDS , it wont be structure name all the time.

    Publish StructureName we are passing in filename , so we can take published structure name
    from the file.

    As per the above mentioned design modifying the code ,
    *)

    (*
    if (sExportStructType <> '') and (sPublishedTblPrimaryFieldValue <> '') then
      result := sExportStructType + cSeparator +
        sPublishedTblPrimaryFieldValue;
    *)
    if sExportedPrimaryField = '' then
      sExportedPrimaryField := sPublishedTblPrimaryFieldValue;
    if (sExportStructType <> '') and (sExportedPrimaryField <> '') then
      result := sExportStructType + cSeparator +
        sExportedPrimaryField;

  Except
    on E: Exception do
    begin
      AxProvider.dbm.gf.dodebug.Msg('Error in ReadCDSFileandPushtoDB ' +
        E.Message);
      UpdatePublishError(sExportStructType + cSeparator +sExportedPrimaryField{sExportedPrimaryField},E.Message);
      //slPublishedErrStructs.Add(sExportedPrimaryField + '=' + E.Message);
      // raise Exception.Create(E.Message);
    end;
  end;

  AxProvider.dbm.gf.dodebug.Msg('ReadCDSFileandPushtoDB ends.');
end;

//Procedure to update error message in PublisErr string list
Procedure TDWBPublish.UpdatePublishError(pTransid,pErrMsg : String);
begin
  if slErrStructs.IndexOfName(pTransid) < 0 then
    slErrStructs.Add(pTransid+'='+pErrMsg)
  else
    slErrStructs.Values[pTransid] := pErrMsg;
end;

// DoSaveCoreStructures - update core structure tables
(*
  This method is to update core structure tables.
  Definition table data will be read , new strtcure xml will be generated and then the data will be pushed to core structure table.
*)
Procedure TDWBPublish.DoUpdateCoreStructureTables(pslPublishedStructures
  : TStringList);
var
  i: Integer;
  sPublishedStructType, sPublishedStruct, tmpPublishNo: String;
  bStructPublished: boolean;
  objDoCoreAct: TDoCoreAction;

  xmlStruct : IXMLDocument;
  inode : IXMLNode;
begin
  AxProvider.dbm.gf.dodebug.Msg('Saving published structures');
  if not Assigned(pslPublishedStructures) then
    Exit;
  try
    objDoCoreAct := nil;
    objDoCoreAct := TDoCoreAction.create(AxProvider);
    for i := 0 to pslPublishedStructures.Count - 1 do
    begin
      // bStructPublished := False;

      sPublishedStruct := pslPublishedStructures[i];
      sPublishedStructType :=
        Lowercase(AxProvider.dbm.gf.GetNthString(sPublishedStruct, 1,
        cSeparator));
      sPublishedStruct := AxProvider.dbm.gf.GetNthString(sPublishedStruct, 2,
        cSeparator);

      try
        //if its runtime publish then skip createstruct/saveiview
        (*
        This function will be used for both runtime and def structs publish
        *)
        //if structure is runtimedefinition then do not call savetstruct / saveiview , else based on structtype
        //save tstruct / iview can be called.

        if slRuntimeDefStructs.IndexOfName(sPublishedStruct)(*IndexOf(sPublishedStruct)*) < 0 then
        begin
          if bPublishAppSchema then Exit; //Do not process this for AppSchema
          (*
          Comment on :20/10/2023
          Calling CreateTStruct & SaveIview may not be required on Defschema - It needs to be checked.
          This might be old, and we might not have removed it.

          because we update required defschema tables during publish itself. So this may not be require.
          *)

          if (sPublishedStructType = 'ts') then
          begin
            // Call Save Tstruct
            AxProvider.dbm.gf.dodebug.Msg('Calling CreateTStruct...');
            objDoCoreAct.CoreParser.RegisterVar('publishtransid', 'c',
              sPublishedStruct);
            objDoCoreAct.bSkipLviewCreationONPublish := True;
            objDoCoreAct.CreateTStruct('publishtransid' { sPublishedStruct } );
            // bStructPublished := True;
          end
          else if (sPublishedStructType = 'iv') then
          begin
            (*
              Comment on : 20102023

            Commenting call SaveIview.
            Updating Iview-related tables that are used in versions prior to 11.x
            is not required, especially in the Definition schema,
            as we copy and update all the required tables during the publish.
            If there's a specific need for this,
            we can recheck and enable the necessary part.

            *)

            (*
            // Call Save Iview
            AxProvider.dbm.gf.dodebug.Msg('Calling SaveIview...');
            objDoCoreAct.MainXML := LoadXMLData('<root></root>');
            objDoCoreAct.SaveIview(sPublishedStruct, 'true');
            // bStructPublished := True;
            *)
          end;
        end
        else //if runtimedefinition save
        begin
          if (sPublishedStructType = 'ts') then
          begin
            // Call WriteTStructDef
            AxProvider.dbm.gf.dodebug.Msg('Calling WriteTStructDef...');
            try
              xmlStruct := nil;
              sPublishStructXML := slRuntimeDefStructs.Values[sPublishedStruct];
              if sPublishStructXML <> '' then
                xmlStruct := LoadXMLData(sPublishStructXML);
              //Load structure XML from tstructs table
              //xmlStruct := AxProvider.GetStructure('tstructs',sPublishedStruct,'','');
              if Not Assigned(xmlStruct) then
                raise Exception.Create('Structure xml not found for transid '+sPublishedStruct);

              //Clearing iframaes child nodes , since it will be recreated when saving / importing the structure
              inode := xmlStruct.DocumentElement.ChildNodes.FindNode('iframes');
              if Assigned(inode) then
                 inode.ChildNodes.Clear; //Clear child nodes

              objDoCoreAct.bIsPublishStructure := True;
              (*
              Call writeTStructDef to ImportStructure so that requured transaction tables will
              get created.
              *)
              objDoCoreAct.WriteTStructDef(sPublishedStruct,xmlStruct.XML.Text);
              sPublishStructXML := '';
              objDoCoreAct.bIsPublishStructure := False;
            except
            end;
          end
          else if (sPublishedStructType = 'iv') then
          begin
            (*
            Commented on : 20/10/2023
            Earlier, the 'Save Iview' call was commented out.
            Now, we're enabling it to handle creating pages and updating menus at the runschema.
            Even though we update the Iviews table directly, 'WriteIviewDef' updates the required table again.
            *)
            // Call WriteIviewDef

            AxProvider.dbm.gf.dodebug.Msg('Calling SaveIviewDef...');
            try
              xmlStruct := nil;
              sPublishStructXML := slRuntimeDefStructs.Values[sPublishedStruct];
              if sPublishStructXML <> '' then
                xmlStruct := LoadXMLData(sPublishStructXML);
              //Load structure XML from tstructs table
              //xmlStruct := AxProvider.GetStructure('tstructs',sPublishedStruct,'','');
              if Not Assigned(xmlStruct) then
                raise Exception.Create('Structure xml not found for transid '+sPublishedStruct);

              objDoCoreAct.bIsPublishStructure := True;
              {
              Call WriteIviewDef so that required tables will get updated.
              }
              objDoCoreAct.WriteIviewDef(sPublishedStruct,'',xmlStruct.XML.Text);
              sPublishStructXML := '';
              objDoCoreAct.bIsPublishStructure := False;
            except
            end;


            //Old commented code is below
            // Call Save Iview
            (*
            AxProvider.dbm.gf.dodebug.Msg('Calling SaveIviewDef...');
            try
              xmlStruct := nil;
              sPublishStructXML := slRuntimeDefStructs.Values[sPublishedStruct];
              xmlStruct := LoadXMLData(sPublishStructXML);
              //Load structure XML from tstructs table
              //xmlStruct := AxProvider.GetStructure('tstructs',sPublishedStruct,'','');
              if Not Assigned(xmlStruct) then
                raise Exception.Create('Structure xml not found for transid '+sPublishedStruct);

              objDoCoreAct.bIsPublishStructure := True;
              {
              Call writeTStructDef to ImportStructure so that required transaction tables will
              get created.
              }
              objDoCoreAct.WriteIviewDef(sPublishedStruct,'',xmlStruct.XML.Text);
              sPublishStructXML := '';
              objDoCoreAct.bIsPublishStructure := False;
            except
            end;
            *)
          end;
        end;

        // Calling UpdatePublishDetailsInDetailsTable to update summary
        // if bStructPublished then
        // Need to update all type of structs (scripts,users etc.,) so removing the boolean flag
        // tmpPublishNo := slPublishNo.Values[sPublishedStruct];
        tmpPublishNo := InttoStr(iPublishNo);
        UpdatePublishDetailsInDetailsTable(sPublishedStruct,sPublishedStructType, tmpPublishNo, sComments);
      Except
        on E: Exception do
        begin
          AxProvider.dbm.gf.dodebug.Msg('Error while saving structure : ' +
            E.Message);
          UpdatePublishError(sPublishedStructType+cSeparator+sPublishedStruct,E.Message);
          raise Exception.Create('Error while saving structure : ' +
            E.Message);
        end;
      end;
    end;
  finally
    if Assigned(objDoCoreAct) then
      FreeAndNil(objDoCoreAct);
    xmlStruct := nil;
    inode := nil;
  end;
  AxProvider.dbm.gf.dodebug.Msg('Saving published structures ends.');
end;


//Disable triggers   - To avoid trigger execution at the time of inserting data.
Procedure TDWBPublish.DisableTriggers;
var
  sErrMsg: String;
  sSqlQuery: String;

  slistSQL: TStringList;
  i: Integer;
begin
  try
    sErrMsg := '';
    slistSQL := nil;
    AxProvider.dbm.gf.dodebug.Msg('DisableTriggers starts.');

    slistSQL := TStringList.create;
    if AxProvider.dbm.connection.dbtype = 'postgre' then
    begin
      sSQLQuery := 'ALTER TABLE coretstructhdr DISABLE TRIGGER coretstructhdr_t1';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_tstruct DISABLE TRIGGER insert_toolbar';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE dwb_iviews DISABLE TRIGGER insert_ivtoolbar';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar DISABLE TRIGGER trg_axpdef_toolbar';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar DISABLE TRIGGER trg_upd_axpdef_toolbar';
      slistSQL.Add(sSQLQuery);

      //Added on 20/10/2023 - to control uder defined button triggers , since we uppdate axtoolbar table during publish
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_buttons DISABLE TRIGGER trg_ins_axpdef_toolbar_btn';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_buttons DISABLE TRIGGER trg_upd_axpdef_toolbar_btn';
      slistSQL.Add(sSQLQuery);

      sSQLQuery := 'ALTER TABLE axpdef_toolbar_groups DISABLE TRIGGER trg_ins_axpdef_toolbar_grp';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_groups DISABLE TRIGGER trg_upd_axpdef_toolbar_grp';
      slistSQL.Add(sSQLQuery);
    end
    else //For other DB needs to be handled
    begin

    end;

      AxProvider.dbm.gf.dodebug.Msg('Executing DisableTriggers scripts');
      for i := 0 to slistSQL.Count - 1 do
      begin
        try
          AxProvider.ExecuteSQL(slistSQL[i]); //execsql(slistSQL[i], '', '', False);
        Except
          on E: Exception do
          begin
            sErrMsg := E.Message;
            AxProvider.dbm.gf.dodebug.Msg('Error in DisableTriggers ' + sErrMsg);
            //raise Exception.create(sErrMsg);
          end;
        end;
      end;

  finally
    if Assigned(slistSQL) then
      FreeAndNil(slistSQL);
  end;
  AxProvider.dbm.gf.dodebug.Msg('DisableTriggers ends.');
end;

//Enable Triggers
Procedure TDWBPublish.EnableTriggers;
var
  sErrMsg: String;
  sSqlQuery: String;

  slistSQL: TStringList;
  i: Integer;
begin
  try
    sErrMsg := '';
    slistSQL := nil;
    AxProvider.dbm.gf.dodebug.Msg('EnableTriggers starts.');

    slistSQL := TStringList.create;
    if AxProvider.dbm.connection.dbtype = 'postgre' then
    begin
      sSQLQuery := 'ALTER TABLE coretstructhdr ENABLE TRIGGER coretstructhdr_t1';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_tstruct ENABLE TRIGGER insert_toolbar';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE dwb_iviews ENABLE TRIGGER insert_ivtoolbar';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar ENABLE TRIGGER trg_axpdef_toolbar';
      slistSQL.Add(sSQLQuery);

      sSQLQuery := 'ALTER TABLE axpdef_toolbar ENABLE TRIGGER trg_upd_axpdef_toolbar';
      slistSQL.Add(sSQLQuery);

      //Added on 20/10/2023 - to control uder defined button triggers , since we uppdate axtoolbar table during publish
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_buttons ENABLE TRIGGER trg_ins_axpdef_toolbar_btn';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_buttons ENABLE TRIGGER trg_upd_axpdef_toolbar_btn';
      slistSQL.Add(sSQLQuery);

      sSQLQuery := 'ALTER TABLE axpdef_toolbar_groups ENABLE TRIGGER trg_ins_axpdef_toolbar_grp';
      slistSQL.Add(sSQLQuery);
      sSQLQuery := 'ALTER TABLE axpdef_toolbar_groups ENABLE TRIGGER trg_upd_axpdef_toolbar_grp';
      slistSQL.Add(sSQLQuery);
    end
    else //For other DB needs to be handled
    begin

    end;

      AxProvider.dbm.gf.dodebug.Msg('Executing EnableTriggers scripts');
      for i := 0 to slistSQL.Count - 1 do
      begin
        try
          AxProvider.ExecuteSQL(slistSQL[i]); //execsql(slistSQL[i], '', '', False);
        Except
          on E: Exception do
          begin
            sErrMsg := E.Message;
            AxProvider.dbm.gf.dodebug.Msg('Error in EnableTriggers ' + sErrMsg);
            //raise Exception.create(sErrMsg);
          end;
        end;
      end;

  finally
    if Assigned(slistSQL) then
      FreeAndNil(slistSQL);
  end;
  AxProvider.dbm.gf.dodebug.Msg('EnableTriggers ends.');
end;


// Process publish structure
(*
  Calls ReadCDSFileandPushtoDB to push core definition table data from CDS to Table
*)
Function TDWBPublish.ProcessPublishStructure(pListOfExportedStrcutFileNames
  : String; pExportedFilePath: String = ''): TStringList;
var
  sPublishFilePath, sPublishFileName: String;
  sPublishFileNamWithPath: String;
  iIdx: Integer;
  sPublishedStruct: String;

  bStructPublished: boolean;
begin
  AxProvider.dbm.gf.dodebug.Msg('ProcessPublishStructure starts ');
  try
    //Disable Triggers
    DisableTriggers;
    result := slProcessedStructures;

    // slPublishedStructures declared  in public scope and created on Create of TDWBPublish object.
    slProcessedStructures.Clear;
    slRuntimeDefStructs.Clear;
    slBackupStructList.Clear;
    AxProvider.dbm.gf.dodebug.Msg('Export file path '+pExportedFilePath);
    if pExportedFilePath = '' then
      pExportedFilePath := {AxProvider.dbm.gf.startpath}IncludeTrailingBackslash(ExtractFilePath(GetModuleName(HInstance))) + 'Publish\';
    sPublishFilePath := IncludeTrailingBackslash(pExportedFilePath);
    sPublishFilePath := Trim(ReplaceStr(sPublishFilePath, '\\?\', ''));
    AxProvider.dbm.gf.dodebug.Msg('Publish file path '+sPublishFilePath);
    iIdx := 1;
    sPublishFileName := AxProvider.dbm.gf.GetNthString
      (pListOfExportedStrcutFileNames, iIdx);
    while sPublishFileName <> '' do
    begin
      sPublishFileNamWithPath := sPublishFilePath + sPublishFileName;
      AxProvider.dbm.gf.dodebug.Msg('Processing File ' +
        sPublishFileNamWithPath);
      if fileexists(sPublishFileNamWithPath) then
      begin
        bPublishRunTimeDef := False;
        // Calling ReadCDSFileandPushtoDB   //it will return published structure type and primary field value
        sPublishedStruct := ReadCDSFileandPushtoDB(sPublishFileNamWithPath);
        if sPublishedStruct <> '' then
        begin
          // Adding published structre to the stringlist.
          if slProcessedStructures.IndexOf(sPublishedStruct) < 0 then
          begin
            slProcessedStructures.Add(sPublishedStruct);
//            if (bPublishRunTimeDef) and (sPublishStructXML <> '') then
//              slRuntimeDefStructs.Add(AxProvider.dbm.gf.GetNthString(sPublishedStruct, 2,cSeparator)+'='+sPublishStructXML);
          end;
          if (bPublishRunTimeDef) and (Trim(sPublishStructXML) <> '') then
              slRuntimeDefStructs.Add(AxProvider.dbm.gf.GetNthString(sPublishedStruct, 2,cSeparator)+'='+sPublishStructXML);
        end;
        bPublishRunTimeDef := False;
        // After processing the file delete it from the folder /  it has to moved to another folder
        //deletefile(sPublishFileNamWithPath); // Handled in the main function - ASBPublishRestObj\ImportToTarget
      end
      else
      begin
        UpdatePublishError(AxProvider.dbm.gf.GetNthString(sPublishFileName,1,cSeparator)+cSeparator+AxProvider.dbm.gf.GetNthString(sPublishFileName,2,cSeparator),//read transid
        'Publish file deosn''t exist. '+sPublishFileNamWithPath);
        AxProvider.dbm.gf.dodebug.Msg
          ('Publish file deosn''t exist . FileName : ' +
          sPublishFileNamWithPath);
      end;
      Inc(iIdx);
      sPublishFileName := AxProvider.dbm.gf.GetNthString
        (pListOfExportedStrcutFileNames, iIdx);
    end;
    // Save Core structure tables
    DoUpdateCoreStructureTables(slProcessedStructures);
    result := slProcessedStructures;
  finally
    //Enable Triggers
    EnableTriggers;
    AxProvider.dbm.gf.dodebug.Msg('ProcessPublishStructure ends.');
  end;
end;

// get Max Publishno
(*
  This will return next publishno .
  Max(publioshno)+1 from AxPublishHistory table will be next publishno.

  This (Publish no generation) logic can be modified when its required.
*)
Function TDWBPublish.GetMaxofPublishNoFromPublishTable: Integer;
var
  qXDSobj: TXDS;
  sSqlQuery: String;
begin
  AxProvider.dbm.gf.dodebug.Msg('GetMaxofPublishNoFromPublishTable starts.');
  result := 0;
  try
    sSqlQuery := '';
    if AxProvider.dbm.connection.dbtype = 'oracle' then
    begin
      sSqlQuery :=
        'select max(Publishno) as maxpublishno from AxPublishHistory';
    end
    else if AxProvider.dbm.connection.dbtype = 'ms sql' then
    begin
      sSqlQuery :=
        'select max(Publishno) as maxpublishno from AxPublishHistory';
    end
    else if AxProvider.dbm.connection.dbtype = 'mysql' then
    begin
      sSqlQuery :=
        'select max(Publishno) as maxpublishno from AxPublishHistory';
    end
    else if Lowercase(AxProvider.dbm.connection.dbtype) = 'postgre' then
    begin
      sSqlQuery :=
        'select max(Publishno) as maxpublishno from AxPublishHistory';
    end;

    qXDSobj := nil;
    qXDSobj := AxProvider.dbm.GetXDS(nil);
    qXDSobj.buffered := True;

    qXDSobj.CDS.CommandText := sSqlQuery;
    qXDSobj.open;
    if qXDSobj.eof then
      result := 0
    else
      result := qXDSobj.fieldbyname('maxpublishno').asinteger;
    qXDSobj.close;
  finally
    if Assigned(qXDSobj) then
      FreeAndNil(qXDSobj);
    Inc(result); //Increass version no by 1
  end;
  AxProvider.dbm.gf.dodebug.Msg('GetMaxofPublishNoFromPublishTable ends.');
end;

// Create DWB Publish tables
(*
  this method creates DWB depndency tables
*)
procedure TDWBPublish.CreateDWBPublishTables;
var
  dbtype: string;
  slQueries: TStringList;
  i: Integer;

  bCreateStructDiffTbl, bCreatePublishHistoryTbl: boolean;
Begin
  try
    (*
    AxPublishedStructDiff table not needed now,

    *)
    slQueries := nil;
    //bCreateStructDiffTbl := Not AxProvider.TableFound('AxPublishedStructDiff');
    bCreatePublishHistoryTbl := Not AxProvider.TableFound('AxPublishHistory');

    if {(Not bCreateStructDiffTbl) and} (Not bCreatePublishHistoryTbl) then
      Exit;

    if AxProvider.dbm.gf.remotelogin then
      dbtype := Lowercase(AxProvider.dbm.gf.remotedbType)
    else
      dbtype := Lowercase(AxProvider.dbm.connection.dbtype);
    AxProvider.dbm.gf.dodebug.Msg('Creating DWBPublish table');
    slQueries := TStringList.create;
    if dbtype = 'oracle' then
    begin
      (*
      if bCreateStructDiffTbl then
        slQueries.Add
          ('Create table AxPublishedStructDiff(Transid varchar2(8),Name varchar2(100),Type varchar2(10),'
          + 'Status varchar2(200),Property varchar2(30),Oldvalue varchar2(4000),NewValue varchar2(4000))');

      if bCreatePublishHistoryTbl then
      *)
        slQueries.Add
          ('Create table AxPublishHistory(Transid varchar2(30),Transtype varchar2(2),publishedon varchar2(25),publishedby varchar2(30),'
          + 'publishno numeric(6),remarks varchar2(4000))');
    end
    else if dbtype = 'ms sql' then
    begin
      (*
      if bCreateStructDiffTbl then
        slQueries.Add
          ('Create table AxPublishedStructDiff(Transid varchar(8),Name varchar(100),Type varchar(10),'
          + 'Status varchar(200),Property varchar(30),Oldvalue varchar(4000),NewValue varchar(4000))');
      if bCreatePublishHistoryTbl then
      *)
        slQueries.Add
          ('Create table AxPublishHistory(Transid varchar(30),Transtype varchar(2),publishedon varchar(25),publishedby varchar(30),'
          + 'publishno numeric(6),remarks varchar(4000))');
    end
    else //mysql , postgres
    begin
      (*
      if bCreateStructDiffTbl then
        slQueries.Add
          ('Create table AxPublishedStructDiff(Transid varchar(8),Name varchar(100),Type varchar(10),'
          + 'Status varchar(200),Property varchar(30),Oldvalue varchar(4000),NewValue varchar(4000))');
      if bCreatePublishHistoryTbl then
      *)
        slQueries.Add
          ('Create table AxPublishHistory(Transid varchar(30),Transtype varchar(2),publishedon varchar(25),publishedby varchar(30),'
          + 'publishno numeric(6),remarks varchar(4000))');
    end;
    for i := 0 to slQueries.Count - 1 do
    begin
      try
        AxProvider.execsql(slQueries[i], '', '', False);
      Except
        on E: Exception do
          AxProvider.dbm.gf.dodebug.Msg('Error in CreateDWBPublishTables : ' +
            E.Message);
      end;
    end;
  finally
    if Assigned(slQueries) then
      FreeAndNil(slQueries);
  end;
end;


//DoBackUpAndCleanTables
Procedure TDWBPublish.DoBackUpAndCleanTables(pPublishRunTimeDef:Boolean;pExportType,pTransId:String);
begin
  AxProvider.dbm.gf.DoDebug.msg('DoBackUpAndCleanTables starts.');
  if LowerCase(pExportType) = 'ts' then
    BackUpAndDeleteTStructDef(pTransId,pPublishRunTimeDef)
  else if LowerCase(pExportType) = 'iv' then
    BackUpAndDeleteIviewDef(pTransId,pPublishRunTimeDef)
  else
    Exit;
  AxProvider.dbm.gf.DoDebug.msg('DoBackUpAndCleanTables ends.');
end;


Procedure TDWBPublish.BackUpAndDeleteTStructDef(sTransid: string; bIsAppSchema: boolean);
var
  s : String;
  iIdx : Integer;
  slSQLList : TStringList;
begin
  Try
    AxProvider.dbm.gf.DoDebug.msg('BackUpAndDeleteTStructDef starts.');
    slSQLList := nil;
    if sTransid = '' then
    begin
      AxProvider.dbm.gf.DoDebug.msg('Transid cannot be left Empty...!');
      Exit;
    end;
  try
    slSQLList := TStringList.Create;
    sTransid := Lowercase(sTransid);
    DoBackUpTableBeforePublish('tstructs','name',sTransid);
    slSQLList.Add('delete from tstructs where lower(name) = ' + quotedstr(sTransid));
    DoBackUpTableBeforePublish('lviews','name',sTransid);
    slSQLList.Add('delete from lviews where lower(name) = ' + quotedstr(sTransid));

    //Commenting axpage publish related updates - this may affect if same ordno exists in the target
    //So let this create automatically and updated if it exists nexttime - Testing | 13102023

    //DoBackUpTableBeforePublish('axpages','name','PageTs'+sTransid);
    //slSQLList.Add('delete from axpages where lower(name) = ' + quotedstr('pagets'+sTransid));
    DoBackUpTableBeforePublish('axtoolbar','name',sTransid);
    slSQLList.Add('delete from axtoolbar where stype = ''tstruct'' and lower(name) = ' + quotedstr(sTransid));

    if bIsAppSchema then // AppSchema
    begin
      //AxProvider.DeleteStructure('tstructs', sTransid);
      DoBackUpTableBeforePublish('ax_layoutdesign','transid',sTransid);
      slSQLList.Add('delete from ax_layoutdesign where lower(transid) = ' + quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_tstruct','ntransid',sTransid);
      slSQLList.Add('delete from axpdef_tstruct where lower(ntransid) = ' + quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpflds','tstruct',sTransid);
      slSQLList.Add('delete from axpflds where lower(tstruct) = ' + quotedstr(sTransid));
    end
    else // DefSchema
    begin
      DoBackUpTableBeforePublish('tstruct_mst_details','mastertransid',sTransid);
      slSQLList.Add('delete from tstruct_mst_details s where lower(s.mastertransid) = ' +
        quotedstr(sTransid));
      DoBackUpTable('axpdef_fillgriddtl','axpdef_fillgridid','','select * from axpdef_fillgriddtl a where a.axpdef_fillgridid in (select a.axpdef_fillgridid from axpdef_fillgrid a where lower(a.stransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from axpdef_fillgriddtl a where a.axpdef_fillgridid in (select a.axpdef_fillgridid from axpdef_fillgrid a where lower(a.stransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTableBeforePublish('axpdef_fillgrid','stransid',sTransid);
      slSQLList.Add('delete from axpdef_fillgrid where lower(stransid) = ' +
        quotedstr(sTransid));
      DoBackUpTable('axpdef_genmapdtl','axpdef_genmapid','','select * from axpdef_genmapdtl a where a.axpdef_genmapid in (select axpdef_genmapid from axpdef_genmap where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from axpdef_genmapdtl a where a.axpdef_genmapid in (select axpdef_genmapid from axpdef_genmap where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTable('axpdef_genmaprowctrl','axpdef_genmapid','','select *  from axpdef_genmaprowctrl a where a.axpdef_genmapid in (select axpdef_genmapid from axpdef_genmap where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from axpdef_genmaprowctrl a where a.axpdef_genmapid in (select axpdef_genmapid from axpdef_genmap where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTableBeforePublish('axpdef_genmap','stransid',sTransid);
      slSQLList.Add('delete from axpdef_genmap where lower(stransid) = ' + quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_mdmap','stransid',sTransid);
      slSQLList.Add('delete  from axpdef_mdmap a where lower(a.STRANSID) = ' +
        quotedstr(sTransid));
      DoBackUpTable('coretstructdtls','CORETSTRUCTHDRID','','select *  from coretstructdtls d where d.CORETSTRUCTHDRID in (select coretstructhdrid from coretstructhdr where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from coretstructdtls d where d.CORETSTRUCTHDRID in (select coretstructhdrid from coretstructhdr where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTable('coretstructdtlsauto','CORETSTRUCTHDRID','','select * from coretstructdtlsauto a where a.CORETSTRUCTHDRID in (select coretstructhdrid from coretstructhdr where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from coretstructdtlsauto a where a.CORETSTRUCTHDRID in (select coretstructhdrid from coretstructhdr where lower(stransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTableBeforePublish('coretstructhdr','stransid',sTransid);
      slSQLList.Add('delete  from coretstructhdr where lower(stransid) = ' +
        quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_dc','stransid',sTransid);
      slSQLList.Add('delete from axpdef_dc where lower(stransid) = ' + quotedstr(sTransid));
      DoBackUpTable('axpdef_tstructfdtl','axpdef_tstructid','','select * from  axpdef_tstructfdtl a where a.axpdef_tstructid in (select b.axpdef_tstructid from axpdef_tstruct b where lower(b.ntransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from  axpdef_tstructfdtl a where a.axpdef_tstructid in (select b.axpdef_tstructid from axpdef_tstruct b where lower(b.ntransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTable('axpdef_tstructudtl','axpdef_tstructid','','select * from axpdef_tstructudtl a where a.axpdef_tstructid in (select b.axpdef_tstructid from axpdef_tstruct b where lower(b.ntransid) = '
        + quotedstr(sTransid) + ')');
      slSQLList.Add('delete from axpdef_tstructudtl a where a.axpdef_tstructid in (select b.axpdef_tstructid from axpdef_tstruct b where lower(b.ntransid) = '
        + quotedstr(sTransid) + ')');
      DoBackUpTableBeforePublish('axpdef_tstruct','ntransid',sTransid);
      slSQLList.Add('delete from axpdef_tstruct where lower(ntransid) = ' + quotedstr(sTransid));
      //slSQLList.Add('delete from axtoolbar where stype = ''tstruct'' and lower(name) = ' + quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_script','stransid',sTransid);
      slSQLList.Add('delete from axpdef_script where lower(stransid) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('axdef_newfield','stransid',sTransid);
      slSQLList.Add('delete from axdef_newfield where lower(stransid) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_toolbar_groups','stransid',sTransid);
      slSQLList.Add('delete from axpdef_toolbar_groups where lower(stransid) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_toolbar_buttons','gtransid',sTransid);
      slSQLList.Add('delete from axpdef_toolbar_buttons where lower(gtransid) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('axpdef_toolbar','stransid',sTransid);
      slSQLList.Add('delete from axpdef_toolbar where lower(stransid) = '+quotedstr(sTransid));
    end;

    AxProvider.dbm.gf.dodebug.Msg('Executing BackUpAndDeleteTStructDef scripts');
    for iIdx := 0 to slSQLList.Count - 1 do
    begin
      try
        AxProvider.ExecuteSQL(slSQLList[iIdx]);
      Except
        on E: Exception do
        begin
          AxProvider.dbm.gf.dodebug.Msg('Error in BackUpAndDeleteTStructDef script ' + E.Message);
        end;
      end;
    end;

  except
    on e: exception do
    begin
      AxProvider.dbm.gf.DoDebug.msg('Error in BackUpAndDeleteTStructDef '+ e.Message);
      raise exception.Create(e.Message);
    end;
  End;
  Finally
    if Assigned(slSQLList) then
      FreeAndNil(slSQLList);
  End;
end;

//DeleteIviewDef
Procedure TDWBPublish.BackUpAndDeleteIviewDef(sTransid: string; bIsAppSchema: boolean);
var
  s : String;
  iIdx : integer;
  slSQLList : TStringList;
begin
  AxProvider.dbm.gf.DoDebug.msg('BackUpAndDeleteIviewDef method starts');
  try
    slSQLList := nil;
    if sTransid = '' then
    begin
      AxProvider.dbm.gf.DoDebug.msg('Transid cannot be left Empty...!');
      Exit;
    end;
  try
    slSQLList := TStringList.Create;
    sTransid := Lowercase(sTransid);
    DoBackUpTableBeforePublish('iviews','name',sTransid);
    slSQLList.Add('delete from iviews where lower(name) = ' + quotedstr(sTransid));

    //Commenting axpage publish related updates - this may affect if same ordno exists in the target
    //So let this create automatically and updated if it exists nexttime - Testing | 13102023

    //DoBackUpTableBeforePublish('axpages','name','PageIv'+sTransid);
    //slSQLList.Add('delete from axpages where lower(name) = ' + quotedstr('pageiv'+sTransid));
    DoBackUpTableBeforePublish('axtoolbar','name',sTransid);
    slSQLList.Add('delete from axtoolbar where stype = ''iview'' and lower(name) = ' + quotedstr(sTransid));

    if bIsAppSchema then // AppSchema
    begin
      DoBackUpTableBeforePublish('dwb_iviews','name',sTransid);
      slSQLList.Add('delete from dwb_iviews where lower(name) = '+quotedstr(sTransid));
      //slSQLList.Add('delete from templates where type=''Iview'' and lower(iviewid) = ' + quotedstr(sTransid));
      //slSQLList.Add('delete from axp_smartviews_config where (username = ' + quotedstr('all') + ' or username = ' + quotedstr(Axprovider.dbm.gf.username) + ') and lower(ivname) = ' + quotedstr(sTransid);
    end
    else // DefSchema
    begin
      DoBackUpTableBeforePublish('dwb_iviewbuttons','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewbuttons where lower(iname)  = '+quotedstr(sTransid));
      //DoBackUpTable('dwb_iviewcformatdtl','dwb_iviewcformatid','','select * from dwb_iviewcformatdtl where dwb_iviewcformatid  in (select dwb_iviewcformatid from dwb_iviewcformat where lower(iname) = '+quotedstr(sTransid)+')');
      //slSQLList.Add(('delete from dwb_iviewcformatdtl where dwb_iviewcformatid  in (select dwb_iviewcformatid from dwb_iviewcformat where lower(iname) = '+quotedstr(sTransid)+')'));
      //DoBackUpTableBeforePublish('dwb_iviewcformat','iname',sTransid);
      //slSQLList.Add('delete from dwb_iviewcformat where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewcols','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewcols where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewcomps','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewcomps where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewhypparval','hiname',sTransid);
      slSQLList.Add('delete from dwb_iviewhypparval where lower(hiname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewhyplink','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewhyplink where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewmain','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewmain where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewparams','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewparams where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviews','name',sTransid);
      slSQLList.Add('delete from dwb_iviews where lower(name) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewsql','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewsql where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewsubtotals','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewsubtotals where lower(iname) = '+quotedstr(sTransid));
      //slSQLList.Add('delete from axtoolbar where stype = ''iview'' and lower(name) = ' + quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewscripts','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewscripts where lower(iname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewsubtotalshdrs','hiname',sTransid);
      slSQLList.Add('delete from dwb_iviewsubtotalshdrs where lower(hiname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewcformatdtl','hiname',sTransid);
      slSQLList.Add('delete from dwb_iviewcformatdtl where lower(hiname) = '+quotedstr(sTransid));
      DoBackUpTableBeforePublish('dwb_iviewcformat','iname',sTransid);
      slSQLList.Add('delete from dwb_iviewcformat where lower(iname) = '+quotedstr(sTransid));
    end;

    AxProvider.dbm.gf.dodebug.Msg('Executing BackUpAndDeleteTStructDef scripts');
    for iIdx := 0 to slSQLList.Count - 1 do
    begin
      try
        AxProvider.ExecuteSQL(slSQLList[iIdx]);
      Except
        on E: Exception do
        begin
          AxProvider.dbm.gf.dodebug.Msg('Error in BackUpAndDeleteTStructDef script ' + E.Message);
        end;
      end;
    end;


  Except
    On e: exception do
    begin
      AxProvider.dbm.gf.DoDebug.msg('Error in BackUpAndDeleteIviewDef '+ e.Message);
      raise exception.Create(e.Message);
    end;
  end;
  finally
    if Assigned(slSQLList) then
      FreeAndNil(slSQLList);
  end;
  AxProvider.dbm.gf.DoDebug.msg('BackUpAndDeleteIviewDef method ends');
end;

//DoBackUpTable
Procedure TDWBPublish.DoBackUpTable(sPublishTable,sPrimaryField, sPrimaryFieldValue, sBackUpSQLText: String);
var
  sBackUpTable: String;
begin
  AxProvider.dbm.gf.dodebug.Msg('DoBackUpTable starts.');
  try
    sBackUpTable := 'AxPublishBackup_' + sPublishTable;
    if Not AxProvider.TableFound(sBackUpTable) then
      // Calling clone tbale
      CloneTable(sPublishTable, sBackUpTable);
    // Calling copy data from table
    CopyTableData(sPublishTable, sBackUpTable,sPrimaryField, sPrimaryFieldValue, sBackUpSQLText);
  Except
    on E: Exception do
      AxProvider.dbm.gf.dodebug.Msg('Error in DoBackUpTable ' +
        E.Message);
  end;
  AxProvider.dbm.gf.dodebug.Msg('DoBackUpTable ends.');
end;


//CopyTableData
Procedure TDWBPublish.CopyTableData(pSourceTable, pTargetTable,
  pPrimaryField, pPrimaryFieldValue,pBackUpSQLText: String);
var
  xdsSource, xdsTarget: TXDS;
  sSQLtext, sFieldName, sFieldValue, sFieldType: String;
  sWhrCond,sTableIdCond,sFilterCondition : String;
  iRecIdx, iColIdx: Integer;
  fField: TField;

  sTempFile,sLOBFieldName,sLOBFieldType : String;
  bIsUpdateLOBField : Boolean;
  strmLOBData : TMemoryStream;
begin
  AxProvider.dbm.gf.dodebug.Msg('CopyTableData starts.');
  try
    xdsSource := nil;
    xdsTarget := nil;
    strmLOBData := nil;
    try
      xdsSource := AxProvider.dbm.GetXDS(nil);
      xdsTarget := AxProvider.dbm.GetXDS(nil);

      xdsSource.buffered := True;
      // xdsTarget.buffered := True;
      (*
      pPrimaryFieldValue := Lowercase(pPrimaryFieldValue);
      sSQLtext := 'SELECT * FROM ' + pSourceTable;

      //SQL Lower() not added in the where condition , when the field is ID field.
      if lowercase(pPrimaryField) = lowercase(pSourceTable+'id') then
      begin
         sWhrCond :=  pPrimaryField + ' = ' +
          QuotedStr(pPrimaryFieldValue);
      end
      else
      begin
        sWhrCond :=
          AxProvider.dbm.gf.SQLLower + '(' + pPrimaryField + ') = ' +
          QuotedStr(pPrimaryFieldValue);
      end;

      sSQLtext := sSQLtext + ' WHERE '+ sWhrCond;
      *)
      sSQLtext := pBackUpSQLText;
      xdsSource.CDS.CommandText := sSQLtext;
      xdsSource.open;

      if (xdsSource.CDS.RecordCount > 0) then
      begin
        AxProvider.dbm.gf.dodebug.Msg
          ('Delete record from backup table if the record exists for ' +
          pPrimaryField);
        try
          if pPrimaryFieldValue = '' then
          begin
            pPrimaryFieldValue := xdsSource.CDS.FieldByName(pPrimaryField).AsString;
          end;
        except

        end;
        ClearRecordFromTable(pTargetTable, pPrimaryField, pPrimaryFieldValue);
        AxProvider.dbm.gf.dodebug.Msg('Copying data from ' + pSourceTable +
          ' to ' + pTargetTable);
        xdsSource.first;
        for iRecIdx := 0 to xdsSource.CDS.RecordCount - 1 do
        begin
          (*
          When adding record to Target table AddorEdit called instead of Append.
          The reason is, due to foreign key constraints data may not delete from Primary tables when calling ClearRecordFromTable.
          In that case, AddorEdit will update the records in Target table if it exists.
          ref : xdsTarget.AddorEdit
        *)
          xdsTarget.close;
          //xdsTarget.Append(pTargetTable);

          for iColIdx := 0 to xdsSource.Fields.Count - 1 do
          begin
            fField := xdsSource.CDS.Fields[iColIdx];
            sFieldType := AxProvider.dbm.gf.GetFieldType(fField.DataType);

            if (sFieldType = 't') or (sFieldType = 'i') then
            begin
              // on 30-04-2021 , code added to handle Memo and blob fields.
              sLOBFieldName := fField.FieldName;
              sLOBFieldType := sFieldType;
              if Not Assigned(strmLOBData) then
                strmLOBData := TMemoryStream.Create;
              if sLOBFieldType = 'i' then //blob
                TBlobField(fField).SaveToStream(strmLOBData)
              else //sLOBFieldType = 't'  //clob
                TMemoField(fField).SaveToStream(strmLOBData);
              bIsUpdateLOBField := True;
            end
            else
            begin
              sFieldName := fField.FieldName;
              sFieldValue := VartoStr(fField.Value);
              xdsTarget.Submit(sFieldName, sFieldValue, sFieldType);
            end;
          end;
          // Update PublishNo
          //xdsTarget.Submit('Publishno', InttoStr(iPublishNo), 'c');
          xdsTarget.Submit('Publishno', InttoStr(iPublishNo), 'n');

          // slPublishNo.Add(pPrimaryFieldValue + '=' + InttoStr(iPublishNo));
          // Inc(iPublishNo);

          // xdsTarget.Post;
          (*
           To update record , we called AddorEdit with where condition.
           Where condition was framed with primary fieldname , but it was overwriting when Inserting TStruct / Iview field records.

           Online definition table, we are maintaining as TStructs so all table will have tableid field.
           To Fix overwrite issue, we added tableid condition also .
          *)
          sTableIdCond := '';
          sFilterCondition := sWhrCond;
          if Assigned(xdsSource.FindField(pSourceTable+'id')) and (VartoStr(xdsSource.CDS.FieldValues[pSourceTable+'id']) <> '') then
          begin
            sTableIdCond := pSourceTable+'id'+'='+VartoStr(xdsSource.CDS.FieldValues[pSourceTable+'id']);
            if sFilterCondition <> '' then
              sFilterCondition := sFilterCondition + ' and '+ sTableIdCond
            else
              sFilterCondition := sTableIdCond;
          end;

          xdsTarget.AddorEdit(pTargetTable,{sWhrCond}sFilterCondition);

          //Update LOB field data  (Memo and blob fields handled here)
          if (bIsUpdateLOBField) and (Assigned(strmLOBData)) then
          begin
            sTempFile :=AxProvider.dbm.gf.startpath+'\temp\LOBdata'+AxProvider.dbm.gf.getnumber;
            if Not DirectoryExists(AxProvider.dbm.gf.startpath+'\temp') then
              ForceDirectories(AxProvider.dbm.gf.startpath+'\temp');

            strmLOBData.Position := 0;
            //Save stream to temporary file
            strmLOBData.SaveToFile(sTempFile);

            if sLOBFieldType = 'i' then //if Blob
              //Call writblob to update blob data in table
              AxProvider.dbm.WriteBlob(sLOBFieldName,pTargetTable,sFilterCondition{sWhrCond},sTempFile)
            else //sLOBFieldType = 't' //Clob
              //Call writmemo to update clob data in table
              AxProvider.dbm.WriteMemo(sLOBFieldName,pTargetTable,sFilterCondition{sWhrCond},sTempFile);

            //delete temporary file
            deletefile(sTempFile);
            //Reset values
            sTempFile := '';
            sLOBFieldName := '';
            sLOBFieldType := '';
            bIsUpdateLOBField := False;
            FreeAndNil(strmLOBData);
          end;
          xdsSource.CDS.Next;//xdsSource.Next;
        end;
      end;
    Except
      on E: Exception do
        AxProvider.dbm.gf.dodebug.Msg('Error in CopyTableData ' +
          E.Message);
    end;

  finally
    if Assigned(xdsSource) then
      FreeAndNil(xdsSource);
    if Assigned(xdsTarget) then
      FreeAndNil(xdsTarget);
    if Assigned(strmLOBData) then
      FreeAndNil(strmLOBData);
  end;
  AxProvider.dbm.gf.dodebug.Msg('CopyTableData ends.');
end;


//WriteStream
procedure TDWBPublish.WriteStream(fname, table, where: String; stm: TStringStream);
var
  csql : String;
  myParams: TParams;
  updXDS : TXDS;
begin
  try
    updXDS := nil;
    myParams := nil;
    updXDS := Axprovider.dbm.GetXDS(nil);
    updXDS.buffered := True;
    csql := 'UPDATE '+table+' SET '+fname+' = :MemoParam WHERE '+where;
    myParams := TParams.Create;
    myParams.Clear;
    myParams.CreateParam(ftMemo, 'MemoParam', ptInput);
    myparams.ParamByName('memoparam').AsString := stm.DataString;
    Axprovider.dbm.gf.DoDebug.msg(csql);
    updXDS.CDS.CommandText := csql;
    updXDS.CDS.Params.Assign(myParams);
    updXDS.CDS.Execute;
  finally
    if Assigned(myParams) then
      FreeAndNil(myParams);
    if Assigned(updXDS) then
      FreeAndNil(updXDS);
  end;
end;


end.
