program ssPainelControle;

uses
  Forms,
  uMenu in 'uMenu.pas' {fMenu},
  uUpdate in 'uUpdate.pas' {frmUpdate},
  uBackUp in 'uBackUp.pas' {frmBackUp},
  uFrmSobre in 'uFrmSobre.pas' {frmSobre},
  uConfigEdit in 'uConfigEdit.pas' {frmConfigEdit},
  uDmDatabase in 'uDmDatabase.pas' {dmDatabase: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SSPainelControle';
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(TfMenu, fMenu);
  Application.Run;
end.
