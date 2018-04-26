object MainResource: TMainResource
  OldCreateOrder = False
  Height = 370
  Width = 554
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
    Left = 184
    Top = 192
  end
end
