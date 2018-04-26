unit zGeschaefte;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Moni.Base, FireDAC.Moni.RemoteClient, FireDAC.Stan.StorageJSON,
  FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet;

type
  [ResourceName('zGeschaefte')]
  TzGeschaefteResource = class(TDataModule)
    qryTemp: TFDQuery;
    FDConnection: TFDConnection;
    FDSchemaAdapter: TFDSchemaAdapter;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    FDMoniRemoteClientLink1: TFDMoniRemoteClientLink;
  published
    [ResourceSuffix('{code_geschaefte}')]
    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_geschaefte}')]
    procedure Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_geschaefte}')]
    procedure PutItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_geschaefte}')]
    procedure DeleteItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses uWabstiLib, REST.JSON;

{$R *.dfm}

procedure TzGeschaefteResource.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  aKey, sLfnr, sMode: string;
  LAPI: TEMSInternalAPI;
  LResponse: IEMSResourceResponseContent;
  LModuleName: string;
  LResultArray: TJSONArray;
  LResponseArray: TJSONArray;
  LResultObject: TJSONObject;
  LModuleNames: TArray<string>;
begin
  sLfnr := '';
  if ARequest.Params.Count > 0 then begin
    aKey := ARequest.Params.Pairs[0].Key;
    if aKey = 'lfnr' then begin
      if not ARequest.Params.Values['lfnr'].IsEmpty then
        sLfnr := lowercase(ARequest.Params.Values['lfnr']);
    end;
    if not ARequest.Params.Values['mode'].IsEmpty then
      sMode := lowercase(ARequest.Params.Values['mode']);
  end;
  try
    with qryTemp do begin
      Connection := FDConnection;
      Close;
      Sql.Clear;
      Sql.Add('select lfnr "lfnr", bezhgoffiziell "bezhgoffiziell", zgt.code "codeGeschaefttyp"');
      Sql.Add('from TGeschaefte g, lZZGESCHAEFTSTYPEN zgt');
      Sql.Add('where g.ID_zzGeschaeftsTypen  in (1,2,3)');
      Sql.Add('  and g.Sonntag_zTage = to_date(''11.11.2005'',''dd.mm.yyyy'')');
      Sql.Add('  and zgt.id = g.id_zzgeschaeftstypen');
      if sLfnr <> '' then
        Sql.Add('  and g.lfnr = '+sLfnr);
      Sql.Add('order by g.ID_zzGeschaeftsArten, g.Sort, g.SortSub, g.BezHGUmgang, g.LfNr');
        Open;
      First;
      LResultArray := nil;
      LResultObject := nil;
      if Recordcount > 1 then begin
        try
          LResultArray := TJSONArray.Create;
          while not EOF do begin
            LResultObject := TJSONObject.Create;
            LResultObject.AddPair('lfnr', FieldByName('lfnr').AsString);
            LResultObject.AddPair('bezhgoffiziell', FieldByName('bezhgoffiziell').AsString);
            LResultObject.AddPair('codeGeschTyp', FieldByName('codeGeschaefttyp').AsString);
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
          LResultObject.AddPair('lfnr', FieldByName('lfnr').AsString);
          LResultObject.AddPair('bezhgoffiziell', FieldByName('bezhgoffiziell').AsString);
          LResultObject.AddPair('codeGeschTyp', FieldByName('codeGeschaefttyp').AsString);
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

procedure TzGeschaefteResource.Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var LStream: TStream; LResultArray: TJSONArray; LResponseObject: TJSONObject;
    dataStr, aStr: string; myGeschaeftNew, myGeschaeftOld: TGeschaeft; count, i: integer;
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
    myGeschaeftNew := TGeschaeft.Create;
    myGeschaeftOld := TGeschaeft.Create;
    for i := 0 to count-1 do begin
      dataStr := TJson.JsonEncode(LResultArray.Items[i]);
      if i = 0 then
        myGeschaeftOld := TJson.JsonToObject<TGeschaeft>(dataStr)
      else begin
        myGeschaeftNew := TJson.JsonToObject<TGeschaeft>(dataStr);
        LResponseObject := TJSONObject.ParseJSONValue(dataStr) as TJSONObject;
      end;
    end;

    aSqlStr := TStringList.Create;
    aSqlStr.Clear;
    if myGeschaeftNew.BezHGOffiziell <> myGeschaeftOld.BezHGOffiziell then
      aSqlStr.Add('    ,BezHGOffiziell  = '+HK+myGeschaeftNew.BezHGOffiziell+HK);
    if myGeschaeftNew.CodeGeschaefttyp <> myGeschaeftOld.CodeGeschaefttyp then
      aSqlStr.Add('    ,id_zzgeschaeftstypen  = '+IntToStr(myGeschaeftNew.CodeGeschaefttyp));
    if aSqlStr.Count > 0 then begin
      aStr := aSqlStr[0];
      Delete(aStr,Pos(',',aStr),1);
      aSqlStr[0] := aStr;

      with TFDQuery.Create(nil) do try
        Connection := FDConnection;
        Close;
        Sql.Clear;
        Sql.Add('update TGeschaefte');
        Sql.Add('set');
        for i := 0 to aSqlStr.Count-1 do
          Sql.Add(aSqlStr[i]);
        Sql.Add('where lfnr = '+IntToStr(myGeschaeftOld.Lfnr));
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

procedure TzGeschaefteResource.PutItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  LItem: string;
begin
  LItem := ARequest.Params.Values['item'];
end;

procedure TzGeschaefteResource.DeleteItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  LItem: string;
begin
  LItem := ARequest.Params.Values['item'];
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TzGeschaefteResource));
end;

initialization
  Register;
end.


