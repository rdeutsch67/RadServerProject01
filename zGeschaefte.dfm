object zGeschaefteResource: TzGeschaefteResource
  OldCreateOrder = False
  Height = 370
  Width = 605
  object qryTemp: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      
        'SELECT code, bez, id_zzeinheittypen, code_zzkantone, bfs, sortpo' +
        'litisch'
      '  FROM tzeinheiten'
      '  where code_zzkantone = '#39'ZH'#39
      '    and id_zzeinheittypen = 4'
      '    and code not like '#39'StuRa%'#39' '
      '  order by bfs, code')
    Left = 104
    Top = 120
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
    Left = 472
    Top = 24
  end
end
