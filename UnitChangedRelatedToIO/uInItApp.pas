unit uInItApp;

interface

uses
  System.SysUtils, uUtils, Windows, IISManager, uAxLog,uAppIO;

type
  TInItApp = class
  public
    function WelcomeUser: string;
    function pluginInfo(): string;
    function InstructionBeforeStart(): string;
    // function DebugStatus(): string;
  end;

implementation

function TInItApp.WelcomeUser: string;
begin
  AppWriteln;
  AppWriteln('======================================');
  AppWriteln('         AXPERT INSTALLER');
  AppWriteln('======================================');
  pluginInfo();
  // DebugStatus();
  // Result := InstructionBeforeStart();
end;

function TInItApp.pluginInfo(): string;
begin
  Console_Writeln;
  AppWrite('Welcome ');
  Console_Write('to ', 3);
  AppWrite('the Axpert Installer ');
  Console_Write('for ', 3);
  AppWrite('Axpert products.');
  AppWriteln;
  AppWrite('This tool allows you ');
  Console_Write('to ', 3);
  AppWrite('seamlessly integrate plugins,releases with your ');
  Console_Write('Axpert ', 3);
  AppWrite('ecosystem, extending its functionality to suit your needs.');
  AppWriteln;
  AppWriteln;
  Console_Write('Get ', 3);
  AppWrite('started by following the prompts ');
  Console_Write('to ', 3);
  AppWrite('configure your settings ');
  Console_Write('and ', 3);
  Console_Write('select ', 3);
  AppWrite('the plugins or releases you wish to install.');
  Console_Write('For ', 3);
  AppWrite('assistance, type');
  Console_Write('''h'' ', 3);
  AppWrite('or ');
  Console_Write('''help'' ', 3);
  AppWrite('for a list of available options.');
  AppWriteln;
  AppWriteln;
  Console_Write('Lets Enhance your Axpert experience together!', 14);
  AppWriteln;
  AppWriteln;
end;

// function TInItApp.DebugStatus(): string;
// var
// response:string;
// begin
/// /   AppWriteln('Give command ''debug on'' or ''debug off'' to create log');
// AppWriteln;
// AppWrite('AxInstaller> ');
// readln(response);
// AppWriteln;
// if (ansistringstartswith(lowercase(response),'debug ')<=0)  then
// begin
// if (ansistringendswith(lowercase(response),' on')<=0) then
// begin
// EnableDebug:=True;
// AppWriteln('Debug mode Enabled');
// end
// else if (ansistringendswith(lowercase(response),' off')<=0) then
// begin
// EnableDebug:=False;
// AppWriteln('Debug mode Disabled');
// end
// else
// begin
// AppWriteln('Invalid command');
// DebugStatus();
// end;
// end
// else if (pos(lowercase(command),'off')<=0) then
// begin
// EnableDebug:=False;
// AppWriteln('Debug mode Disabled');
// end
// else
// AppWriteln('Invalid Input');
// AppWriteln;
// else
// begin
// AppWriteln('Give proper command to make craete log status on');
// AppWriteln;
// AppWrite('AxInstaller> ');
// readln(response);
// DebugStatus();
// end;
//
// end;

function TInItApp.InstructionBeforeStart(): string;
var
  response: string;
  iisresponse: string;
begin
  try

    Console_Write
      ('This process recommends to stop your web application while installing process',
      12);
    AppWriteln;
    // recom
    AppWriteln;
    // AppWriteln('We recommend you to stop iis for continueing further installation');
    // AppWriteln;
    WriteLog('Checking IIS Status');
    if IsIISRunning then
    begin
      AppWrite('IIS Status : ');
      Console_Write('Running', 10);
      AppWriteln;
      WriteLog('IIS Status : Running');
      AppWriteln;
    end
    else
    begin
      AppWrite('IIS Status : ');
      Console_Write('Stopped', 10);
      AppWriteln;
      WriteLog('IIS Status : Running');
      AppWriteln;
    end;
    Console_Write
      ('We recommend you to stop iis for continuing further installation', 12);
    AppWriteln;
    AppWriteln;
    AppWriteln('Would you like to stop IIS using AxInstaller?');
    AppWriteln('Press ''Y'' to continue or ''N'' to skip and stop IIS or the corresponding application pools manually.');
    AppWriteln;
    AppWrite('AxInstaller> ');
    readln(iisresponse);
    if not((lowercase(iisresponse) = 'y') or (lowercase(iisresponse) = 'n'))
    then
    begin
      AppWriteln;
      AppWrite('AxInstaller> ');
      readln(iisresponse);
    end;

    if lowercase(iisresponse) = lowercase('Y') then
    begin
      // if IsIISRunning then
      // begin
      AppWriteln('Stopping IIS.');
      StopIIS;
      Sleep(15000);
      if IsIISRunning then // need to improvise
      begin
        Console_Write('Unable to stop IIS,Please stop and then continue', 12);
        WriteLog('Unable to stop IIS');
        AppWriteln;
      end
      else
      begin
        AppWriteln('IIS is stopped.');
        WriteLog('IIS Status : Stopped')
      end;

      // end;
    end
    else if lowercase(iisresponse) = lowercase('N') then
    begin
      // AppWriteln('we recommend you to close the application');
      AppWriteln('Please confirm once IIS or the corresponding application pools are stopped. Press ''Y'' to continue or ''N'' to skip.');
      AppWrite('AxInstaller> ');
      readln(iisresponse);
      AppWriteln;
      if lowercase(iisresponse) = lowercase('N') then
      begin
        Console_Write
          ('we cannot procced further and abort the installation process.', 12);
        WriteLog('IIS is still running,can''t proceed further');
        halt;
      end
      else if lowercase(iisresponse) = lowercase('Y') then
      begin
        // if IsIISRunning then
        // begin
        // AppWriteln('IIS still running Do you want to proceed.');
        // AppWrite('AxInstaller> ');
        // readln(iisresponse);
        // AppWriteln;
        // if lowercase(iisresponse) = lowercase('Y') then
        // begin
        // AppWriteln('Stopping IIS.');
        // Sleep(5000);
        // if IsIISRunning then // need to improvise
        // AppWriteln('Unable to stop IIS,Please stop and then continue')
        // else
        // AppWriteln('IIS is stopped.');
        // end;
        // if lowercase(iisresponse) = lowercase('N') then
        // begin
        // AppWriteln('We are aborting the installation...');
        // AppWriteln;
        // halt;;
        // end;           {Block needs to be handle}

        // end;
        // end;
      end;
    end

    else
    begin
      AppWrite('IIS Status : ');
      Console_Write('Stopped', 10);
      AppWriteln;
      WriteLog('IIS Status : Stopped');
    end;

    {
      Control IIS during installation: Y/N
      Y: Proceed with stopping IIS (give a message and get confirmation).
      N: Ask the user to close the application and proceed on confirmation.
    }

    // AppWriteln('Please select appropriate otion according to your requirement');
    // AppWriteln;
    // AppWriteln('What you want to install');
    // AppWriteln('  1.Plugin');
    // AppWriteln('  2.Patches');
    // readln(response);
    // AppWriteln;
    // if ((lowercase(response) = '1') or (lowercase(response) = 'Plugin')) then
    // begin
    // Result := 'Plugin';
    // end;
    // if ((lowercase(response) = '2') or (lowercase(response) = 'Patches')) then
    // begin
    // Result := 'Patches';
    // end;
    // // AppWrite('Do you want to continue installing plugin? ');
    // Console_write('[y/n]',12);
    // AppWriteln;
    // Readln(resp);
    // resp:=LowerCase(resp);
    // if resp='n' then
    // begin
    // AppWriteln('Process is going to ends...');
    // ExitProcess(0);
    // end;
    // if resp='y' then
    // begin
    // isProceedNext:=True;
    // end;
    // if  (resp <>'y') and (resp<>'n') then
    // begin
    // repeat
    // begin
    // AppWriteln('Give your response in y or n only');
    // readln(resp);
    // end;
    // until (resp ='y') or (resp='n') ;
    // if (resp ='y') then
    // begin
    // end;
    // if (resp ='n') then
    // begin

    // AppWriteln('Process is going to ends...');
    // ExitProcess(0);
    // end;
    //
    //
    //

    // end;
  Except
    on E: Exception do
    begin
      AppWriteln('An unexpected error occurred: ', E.Message);
      WriteLog('Error occured during IIS Starting or Stopping:' + E.Message);
    end;
  end;

end;

end.
