unit zEinheiten;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDM, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Moni.Base, FireDAC.Moni.RemoteClient, FireDAC.Stan.StorageJSON;

type
  [ResourceName('zEinheiten')]
  TzEinheitenResource = class(TDataModule)
    qryEinheiten: TFDQuery;
    FDConnection: TFDConnection;
    FDSchemaAdapter: TFDSchemaAdapter;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    FDMoniRemoteClientLink1: TFDMoniRemoteClientLink;
    procedure FDConnectionAfterConnect(Sender: TObject);
  published
    [ResourceSuffix('{code_einheiten}')]
    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_einheiten}')]
    //procedure GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    procedure Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_einheiten}')]
    procedure PutItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_einheiten}')]
    procedure DeleteItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses uWabstiLib, REST.JSON;


{$R *.dfm}

procedure TzEinheitenResource.FDConnectionAfterConnect(Sender: TObject);
begin
  FDConnection.ConnectionIntf.Tracing := True;
end;

procedure TzEinheitenResource.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  sCode, sMode: string;
  LAPI: TEMSInternalAPI;
  LResponse: IEMSResourceResponseContent;
  LModuleName: string;
  LResultArray: TJSONArray;
  LResponseArray: TJSONArray;
  LResultObject: TJSONObject;
  LModuleNames: TArray<string>;
begin
  if ARequest.Params.Count > 0 then begin
    if not ARequest.Params.Values['code'].IsEmpty then
      sCode := lowercase(ARequest.Params.Values['code']);
    if not ARequest.Params.Values['mode'].IsEmpty then
      sMode := lowercase(ARequest.Params.Values['mode']);
  end;
  try
    with qryEinheiten do begin
      Connection := FDConnection;
      Close;
      Sql.Clear;
      Sql.Add('SELECT code "code", bez "bez", bfs "bfs", code_zzkantone "code_zzkantone"');
      Sql.Add('  FROM TzEinheiten');
      Sql.Add('  where code_zzkantone = '+HK+'ZH'+HK);
      if sCode <> '' then begin
        if sMode = 'all' then begin
          if Pos('%',sCode) > 0 then sCode := StringReplace(sCode,'%','',[rfReplaceAll]);
          sCode := '%'+sCode+'%';
          Sql.Add('    and lower(code) like '+HK+sCode+HK)
        end
        else begin
          Sql.Add('    and lower(code) = '+HK+sCode+HK);
        end;
      end;
      Sql.Add('  order by bfs, code');
      Open;
      First;
      LResultArray := nil;
      LResultObject := nil;
      if Recordcount > 1 then begin
        try
          LResultArray := TJSONArray.Create;
          while not EOF do begin
            LResultObject := TJSONObject.Create;
            LResultObject.AddPair('code', FieldByName('code').AsString);
            LResultObject.AddPair('bez', FieldByName('bez').AsString);
            LResultObject.AddPair('bfs', FieldByName('bfs').AsString);
            LResultObject.AddPair('code_zzkantone', FieldByName('code_zzkantone').AsString);
            LResultArray.AddElement(LResultObject);
            LResultObject := nil;
            Next;
          end;
          AResponse.Body.SetValue(LResultArray, True);
          LResultArray := nil;

        finally
          LResultArray.Free;
          LResultObject.Free;
        end;
      end
      else begin   // wenn nur ein Datensatz gefunden wird, dann ein Objekt zurückgeben - nicht ein Array!!!!
        try
          LResultObject := TJSONObject.Create;
          LResultObject.AddPair('code', FieldByName('code').AsString);
          LResultObject.AddPair('bez', FieldByName('bez').AsString);
          LResultObject.AddPair('bfs', FieldByName('bfs').AsString);
          LResultObject.AddPair('code_zzkantone', FieldByName('code_zzkantone').AsString);
          AResponse.Body.SetValue(LResultObject, True);
          LResultObject := nil;
          LResultArray := nil;
        finally
          LResultArray.Free;
          LResultObject.Free;
        end;
      end;
    end;
  except
    raise
  end;
end;

//procedure TzEinheitenResource.GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
//var
//  LItem: string;
//begin
//  LItem := ARequest.Params.Values['item'];
//  // Sample code
//  AResponse.Body.SetValue(TJSONString.Create('zEinheiten ' + LItem), True)
//end;

procedure TzEinheitenResource.Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var LStream: TStream; LResultArray: TJSONArray; LResponseObject: TJSONObject;
    dataStr, aStr: string; myEinheitNew, myEinheitOld: TEinheit; count, i: integer;
    aSqlStr: TStrings;
begin
  if not SameText(ARequest.Body.ContentType, 'application/json') then
    AResponse.RaiseBadRequest('content type');
  if not ARequest.Body.TryGetStream(LStream) then
    AResponse.RaiseBadRequest('no stream');

  LResultArray  := TJSONArray.Create;
  LResponseObject := TJSONObject.Create;
  try
    LResultArray := ARequest.Body.GetArray;

    count := LResultArray.Count;
    myEinheitNew := TEinheit.Create;
    myEinheitOld := TEinheit.Create;
    for i := 0 to count-1 do begin
      dataStr := TJson.JsonEncode(LResultArray.Items[i]);
      if i = 0 then
        myEinheitOld := TJson.JsonToObject<TEinheit>(dataStr)
      else begin
        myEinheitNew := TJson.JsonToObject<TEinheit>(dataStr);
        LResponseObject := TJSONObject.ParseJSONValue(dataStr) as TJSONObject;
      end;
    end;

    aSqlStr := TStringList.Create;
    aSqlStr.Clear;
    if myEinheitNew.Code <> myEinheitOld.Code then
      aSqlStr.Add('    ,code = '+HK+myEinheitNew.Code+HK);
    if myEinheitNew.Bez <> myEinheitOld.Bez then
      aSqlStr.Add('    ,bez  = '+HK+myEinheitNew.Bez+HK);
    if myEinheitNew.BFS <> myEinheitOld.BFS then
      aSqlStr.Add('    ,bfs  = '+IntToStr(myEinheitNew.BFS));
    if aSqlStr.Count > 0 then begin
      aStr := aSqlStr[0];
      Delete(aStr,Pos(',',aStr),1);
      aSqlStr[0] := aStr;

      with TFDQuery.Create(nil) do try
        Connection := FDConnection;
        Close;
        Sql.Clear;
        Sql.Add('update TzEinheiten');
        Sql.Add('set');
        for i := 0 to aSqlStr.Count-1 do
          Sql.Add(aSqlStr[i]);
        Sql.Add('where code = '+HK+myEinheitOld.Code+HK);
        Sql.Add('  and code_zzkantone = '+HK+myEinheitOld.Code_zzkantone+HK);
        ExecSQL;
      finally
        Free;
      end;
    end;

    AResponse.Body.SetValue(LResponseObject, True);
  finally
    LResultArray := nil;
    LResultArray.Free;
  end;
end;
procedure TzEinheitenResource.PutItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var LStream: TStream; LResultObject, LResponseObject: TJSONObject;
    dataStr, aStr: string; myEinheitNew, myEinheitOld: TEinheit; count, i: integer;
    aSqlStr: TStrings;
begin
  //LItem := ARequest.Params.Values['item'];
  if not SameText(ARequest.Body.ContentType, 'application/json') then
    AResponse.RaiseBadRequest('content type');
  if not ARequest.Body.TryGetStream(LStream) then
    AResponse.RaiseBadRequest('no stream');

  LResultObject := TJSONObject.Create;
  try
    LResultObject := ARequest.Body.GetObject;
    myEinheitNew := TEinheit.Create;
    dataStr := TJson.JsonEncode(LResultObject);
    myEinheitNew := TJson.JsonToObject<TEinheit>(dataStr);
    LResponseObject := TJSONObject.ParseJSONValue(dataStr) as TJSONObject;

    with TFDQuery.Create(nil) do try
      Connection := FDConnection;
      Close;
      Sql.Clear;
      Sql.Add('Insert Into TZEINHEITEN');
      Sql.Add(' (BEZ,CODE,SORTPOLITISCH,BFS,SORTBFS,SORTHISTORISCH,CODE_ZZKANTONE,ID_ZZEINHEITTYPEN)');
      Sql.Add(' Values');
      Sql.Add(' ( '+HK+myEinheitNew.Bez+HK+', '+HK+myEinheitNew.Code+HK+', '+myEinheitNew.BFS.ToString+', '+myEinheitNew.BFS.ToString+', '+myEinheitNew.BFS.ToString+', '+myEinheitNew.BFS.ToString+', '+HK+'ZH'+HK+', 4)');
      ExecSQL;
    finally
      Free;
    end;
    AResponse.Body.SetValue(LResponseObject, True);
  finally
  end;
end;

procedure TzEinheitenResource.DeleteItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var LStream: TStream; LResultObject, LResponseObject: TJSONObject;
    dataStr, aStr: string; myEinheit: TEinheit; count, i: integer;
    aSqlStr: TStrings;
    delCode: string; myhttpResp: THttpResponse;
begin
  //LItem := ARequest.Params.Values['item'];
  if not SameText(ARequest.Body.ContentType, 'application/json') then
    AResponse.RaiseBadRequest('content type');
  delCode := ARequest.Params.Values['code'];
  myhttpResp := THttpResponse.Create;
  try
    with TFDQuery.Create(nil) do try
      Connection := FDConnection;
      Close;
      Sql.Clear;
      Sql.Add('Delete from TZEINHEITEN');
      Sql.Add('where code = '+HK+delCode+HK);
      //Sql.Add('  and code_zzkantone = '+HK+myEinheit.Code_zzkantone+HK);
      ExecSQL;
      myhttpResp.Text := 'Data deleted';
      LResponseObject := TJson.ObjectToJsonObject(myhttpResp,[]);
    finally
      Free;
    end;
    //myhttpResp.Text := 'DelDataOK';
    AResponse.Body.SetValue(LResponseObject, True);
  finally
  end;
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TzEinheitenResource));
end;

initialization
  Register;
end.


