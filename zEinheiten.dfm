object zEinheitenResource: TzEinheitenResource
  OldCreateOrder = False
  Height = 498
  Width = 584
  object qryEinheiten: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      
        'SELECT code, bez, id_zzeinheittypen, code_zzkantone, bfs, sortpo' +
        'litisch'
      '  FROM tzeinheiten'
      '  where code_zzkantone = '#39'ZH'#39
      '    and id_zzeinheittypen = 4'
      '    and code not like '#39'StuRa%'#39' '
      '  order by bfs, code')
    Left = 48
    Top = 184
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=EKOR_THETA_12_DB05.world'
      'User_Name=vrsg2'
      'Password=vrsg2'
      'MonitorBy=Remote'
      'DriverID=Ora')
    ResourceOptions.AssignedValues = [rvAutoConnect]
    LoginPrompt = False
    AfterConnect = FDConnectionAfterConnect
    Left = 32
    Top = 16
  end
  object FDSchemaAdapter: TFDSchemaAdapter
    ResourceOptions.AssignedValues = [rvParamExpand]
    Left = 136
    Top = 16
  end
  object FDStanStorageJSONLink: TFDStanStorageJSONLink
    Left = 256
    Top = 16
  end
  object FDMoniRemoteClientLink1: TFDMoniRemoteClientLink
    EventKinds = [ekConnConnect, ekCmdPrepare, ekCmdExecute, ekCmdDataOut]
    Tracing = True
    Left = 184
    Top = 192
  end
end
