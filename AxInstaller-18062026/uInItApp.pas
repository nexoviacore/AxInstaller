unit uInItApp;

interface

uses
  System.SysUtils, uUtils, Windows, IISManager, uAxLog;

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
  Writeln;
  Writeln('======================================');
  Writeln('         AXPERT INSTALLER');
  Writeln('======================================');
  pluginInfo();
  // DebugStatus();
  // Result := InstructionBeforeStart();
end;

function TInItApp.pluginInfo(): string;
begin
  Console_Writeln;
  Write('Welcome ');
  Console_Write('to ', 3);
  Write('the Axpert Installer ');
  Console_Write('for ', 3);
  Write('Axpert products.');
  Writeln;
  Write('This tool allows you ');
  Console_Write('to ', 3);
  Write('seamlessly integrate plugins,releases with your ');
  Console_Write('Axpert ', 3);
  Write('ecosystem, extending its functionality to suit your needs.');
  Writeln;
  Writeln;
  Console_Write('Get ', 3);
  Write('started by following the prompts ');
  Console_Write('to ', 3);
  Write('configure your settings ');
  Console_Write('and ', 3);
  Console_Write('select ', 3);
  Write('the plugins or releases you wish to install.');
  Console_Write('For ', 3);
  Write('assistance, type');
  Console_Write('''h'' ', 3);
  Write('or ');
  Console_Write('''help'' ', 3);
  Write('for a list of available options.');
  Writeln;
  Writeln;
  Console_Write('Lets Enhance your Axpert experience together!', 14);
  Writeln;
  Writeln;
end;

// function TInItApp.DebugStatus(): string;
// var
// response:string;
// begin
/// /   Writeln('Give command ''debug on'' or ''debug off'' to create log');
// writeln;
// write('AxInstaller> ');
// readln(response);
// writeln;
// if (ansistringstartswith(lowercase(response),'debug ')<=0)  then
// begin
// if (ansistringendswith(lowercase(response),' on')<=0) then
// begin
// EnableDebug:=True;
// Writeln('Debug mode Enabled');
// end
// else if (ansistringendswith(lowercase(response),' off')<=0) then
// begin
// EnableDebug:=False;
// Writeln('Debug mode Disabled');
// end
// else
// begin
// writeln('Invalid command');
// DebugStatus();
// end;
// end
// else if (pos(lowercase(command),'off')<=0) then
// begin
// EnableDebug:=False;
// Writeln('Debug mode Disabled');
// end
// else
// writeln('Invalid Input');
// writeln;
// else
// begin
// writeln('Give proper command to make craete log status on');
// writeln;
// write('AxInstaller> ');
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
    Writeln;
    // recom
    Writeln;
    // writeln('We recommend you to stop iis for continueing further installation');
    // writeln;
    WriteLog('Checking IIS Status');
    if IsIISRunning then
    begin
      Write('IIS Status : ');
      Console_Write('Running', 10);
      Writeln;
      WriteLog('IIS Status : Running');
      Writeln;
    end
    else
    begin
      Write('IIS Status : ');
      Console_Write('Stopped', 10);
      Writeln;
      WriteLog('IIS Status : Running');
      Writeln;
    end;
    Console_Write
      ('We recommend you to stop iis for continuing further installation', 12);
    Writeln;
    Writeln;
    Writeln('Would you like to stop IIS using AxInstaller?');
    Writeln('Press ''Y'' to continue or ''N'' to skip and stop IIS or the corresponding application pools manually.');
    Writeln;
    write('AxInstaller> ');
    readln(iisresponse);
    if not((lowercase(iisresponse) = 'y') or (lowercase(iisresponse) = 'n'))
    then
    begin
      Writeln;
      write('AxInstaller> ');
      readln(iisresponse);
    end;

    if lowercase(iisresponse) = lowercase('Y') then
    begin
      // if IsIISRunning then
      // begin
      Writeln('Stopping IIS.');
      StopIIS;
      Sleep(15000);
      if IsIISRunning then // need to improvise
      begin
        Console_Write('Unable to stop IIS,Please stop and then continue', 12);
        WriteLog('Unable to stop IIS');
        Writeln;
      end
      else
      begin
        Writeln('IIS is stopped.');
        WriteLog('IIS Status : Stopped')
      end;

      // end;
    end
    else if lowercase(iisresponse) = lowercase('N') then
    begin
      // Writeln('we recommend you to close the application');
      Writeln('Please confirm once IIS or the corresponding application pools are stopped. Press ''Y'' to continue or ''N'' to skip.');
      write('AxInstaller> ');
      readln(iisresponse);
      Writeln;
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
        // Writeln('IIS still running Do you want to proceed.');
        // write('AxInstaller> ');
        // readln(iisresponse);
        // Writeln;
        // if lowercase(iisresponse) = lowercase('Y') then
        // begin
        // Writeln('Stopping IIS.');
        // Sleep(5000);
        // if IsIISRunning then // need to improvise
        // Writeln('Unable to stop IIS,Please stop and then continue')
        // else
        // Writeln('IIS is stopped.');
        // end;
        // if lowercase(iisresponse) = lowercase('N') then
        // begin
        // Writeln('We are aborting the installation...');
        // Writeln;
        // halt;;
        // end;           {Block needs to be handle}

        // end;
        // end;
      end;
    end

    else
    begin
      Write('IIS Status : ');
      Console_Write('Stopped', 10);
      Writeln;
      WriteLog('IIS Status : Stopped');
    end;

    {
      Control IIS during installation: Y/N
      Y: Proceed with stopping IIS (give a message and get confirmation).
      N: Ask the user to close the application and proceed on confirmation.
    }

    // writeln('Please select appropriate otion according to your requirement');
    // writeln;
    // writeln('What you want to install');
    // writeln('  1.Plugin');
    // writeln('  2.Patches');
    // readln(response);
    // writeln;
    // if ((lowercase(response) = '1') or (lowercase(response) = 'Plugin')) then
    // begin
    // Result := 'Plugin';
    // end;
    // if ((lowercase(response) = '2') or (lowercase(response) = 'Patches')) then
    // begin
    // Result := 'Patches';
    // end;
    // // Write('Do you want to continue installing plugin? ');
    // Console_write('[y/n]',12);
    // writeln;
    // Readln(resp);
    // resp:=LowerCase(resp);
    // if resp='n' then
    // begin
    // Writeln('Process is going to ends...');
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
    // Writeln('Give your response in y or n only');
    // readln(resp);
    // end;
    // until (resp ='y') or (resp='n') ;
    // if (resp ='y') then
    // begin
    // end;
    // if (resp ='n') then
    // begin

    // Writeln('Process is going to ends...');
    // ExitProcess(0);
    // end;
    //
    //
    //

    // end;
  Except
    on E: Exception do
    begin
      Writeln('An unexpected error occurred: ', E.Message);
      WriteLog('Error occured during IIS Starting or Stopping:' + E.Message);
    end;
  end;

end;

end.
