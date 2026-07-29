unit uGitAccessToken;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  IdAuthentication,
  Soap.EncdDecd, IdCoder, IdCoder3to4, IdCoderMIME, IdMultipartFormData,
  StrUtils,
  System.IOUtils, System.Types, System.Generics.Collections, DBXJSON, uUtils,
  idUri,IdHTTPServer, IdContext, IdCustomHTTPServer;

type
  TGitAccessToken = class
  public
  //    procedure OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    class procedure StartHTTPServer;
  class procedure HandleAuthorizationRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

implementation

var
  HTTPServer: TIdHTTPServer;
  AuthorizationCode: string;

class procedure TGitAccessToken.HandleAuthorizationRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    Params.Delimiter := '&';
    Params.DelimitedText := ARequestInfo.UnparsedParams;
    AuthorizationCode := Params.Values['code'];
    writeln(AuthorizationCode);
    // Optionally, you can send a response to the client indicating successful receipt of the authorization code.
    AResponseInfo.ContentText := 'Authorization code received successfully.';
    AResponseInfo.ResponseNo := 200;
  finally
    Params.Free;
    AContext.Connection.Disconnect;
  end;
end;

class procedure TGitAccessToken.StartHTTPServer;
begin
  HTTPServer := TIdHTTPServer.Create(nil);
  try
    HTTPServer.DefaultPort := 8088; // Choose a suitable port for your application
    HTTPServer.OnCommandGet := TGitAccessToken.HandleAuthorizationRequest;
    HTTPServer.Active := True;
    Writeln('Server started. Listening on port: ', HTTPServer.DefaultPort);
    Readln;
  except
    on E: Exception do
      Writeln('Exception: ', E.Message);
  end;
end;

begin
  //TGitAccessToken.StartHTTPServer;
end.
