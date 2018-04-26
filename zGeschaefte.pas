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
    procedure Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_geschaefte}')]
    procedure PutItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('{code_geschaefte}')]
    procedure DeleteItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

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
begin
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


