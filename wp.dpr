program wp;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, RegularExpressions, System.Types, IdHTTP, UrlMon,
  ActiveX, System.StrUtils, System.Classes;

const
  RES = '1680x1050';
  // UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2837.0 Safari/537.36';

var
  CoResult, i: Integer;
  HTTP: TIdHTTP;
  Query: String;
  regexpr: TRegEx;
  match: TMatch;
  token: TStringDynArray;

function Occurrences(const Substring, Text: string): Integer;
var
  offset: Integer;
begin
  result := 0;
  offset := PosEx(Substring, Text, 1);
  while offset <> 0 do
  begin
    inc(result);
    offset := PosEx(Substring, Text, offset + length(Substring));
  end;
end;

function wallpaper_get_url(AWp_id, ABase, ARes: string): String;
begin
  result := Format('http://interfacelift.com/wallpaper/7yz4ma1/%s_%s_%s.jpg',
    [AWp_id, ABase, ARes]);
end;

function grab_page(AIndex: Integer): String;
begin
  Query := Format
    ('https://interfacelift.com/wallpaper/downloads/date/any/index%d.html', [AIndex]);

  CoResult := CoInitializeEx(nil, COINIT_MULTITHREADED);

  if not((CoResult = S_OK) or (CoResult = S_FALSE)) then
  begin
    Writeln('Failed to initialize COM library.');
    Exit;
  end;

  HTTP := TIdHTTP.Create;

  result := HTTP.Get(Query);
end;

procedure download_file(AUrl: String);
var
  Path: String;
  FileName: String;
  List: TStringDynArray;
  IdHTTP1: TIdHTTP;
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
