program wp;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, RegularExpressions, System.Types, UrlMon,
  ActiveX, System.StrUtils, System.Classes, WinInet;

const
  RES = '1680x1050';
  // UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2837.0 Safari/537.36';

var
  CoResult, i: Integer;
  Url: String;
  regexpr: TRegEx;
  match: TMatch;
  token: TStringDynArray;

function wallpaper_get_url(AWp_id, ABase, ARes: string): String;
begin
  result := Format('http://interfacelift.com/wallpaper/7yz4ma1/%s_%s_%s.jpg',
    [AWp_id, ABase, ARes]);
end;

function grab_page(AIndex: Integer): String;
  var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1023] of byte;
  BytesRead: dWord;
  StrBuffer: UTF8String;
begin
  Result := '';

  Url := Format
    ('https://interfacelift.com/wallpaper/downloads/date/any/index%d.html', [AIndex]);

  NetHandle := InternetOpen('Delphi 2009', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(NetHandle) then
    try
      UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);
      if Assigned(UrlHandle) then
        try
          repeat
            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
            SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
            Result := Result + StrBuffer;
          until BytesRead = 0;
        finally
          InternetCloseHandle(UrlHandle);
        end
      else
        raise Exception.CreateFmt('Cannot open URL %s', [Url]);
    finally
      InternetCloseHandle(NetHandle);
    end
  else
    raise Exception.Create('Unable to initialize Wininet');
end;

procedure download_file(AUrl: String);
var
  Path: String;
  FileName: String;
  List: TStringDynArray;
  Stream: TMemoryStream;
begin
  Path := (ExtractFilePath(ParamStr(0)) + 'downloads/');

  if not directoryexists(Path) then
    CreateDir(Path);

  List := SplitString(AUrl, '/');
  FileName := List[length(List) - 1];

  URLDownloadToFile(nil, Pchar(AUrl), Pchar(Path + FileName), 0, nil);
end;

begin
  try
    regexpr := TRegEx.Create('imgload\(''(.+)?'', this,''(.+)''\)', [roIgnoreCase, roMultiline]);
    match := regexpr.match(grab_page(1));

    i := 1;
    while match.Success do
    begin
      token := SplitString(match.Value, '''');
      download_file(wallpaper_get_url(token[3], token[1], RES));
      Writeln(format('%d of %d downloaded', [i, 10]));
      match := match.NextMatch;
      Inc(i, 1);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
