object AxInstallerWebModule: TAxInstallerWebModule
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      Default = True
      Name = 'ProcessCommandAction'
      PathInfo = '/ProcessCommand'
      OnAction = ActionProcessCommand
    end>
  Height = 150
  Width = 300
end
