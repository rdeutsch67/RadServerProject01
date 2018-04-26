unit uDM;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.IB, FireDAC.Phys.IBDef, FireDAC.ConsoleUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Stan.StorageJSON, FireDAC.VCLUI.Wait,
  FireDAC.Moni.Base, FireDAC.Moni.RemoteClient, FireDAC.Moni.Custom;

type
  [ResourceName('mainRessource')]
  TMainResource = class(TDataModule)
    FDConnection: TFDConnection;
    FDSchemaAdapter: TFDSchemaAdapter;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    FDMoniRemoteClientLink1: TFDMoniRemoteClientLink;
  private
  published
  end;

implementation

uses uWabstiLib;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure Register;
begin
  RegisterResource(TypeInfo(TMainResource));
end;

initialization
  Register;
end.


