program wp;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, RegularExpressions,
  HTTPApp,
  IdHTTP,
  XMLDoc,
  XMLIntf,
  ActiveX, System.Classes, System.StrUtils;

const
  RES = '1680x1050';
  UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2837.0 Safari/537.36';

var
  CoResult: Integer;
  HTTP: TIdHTTP;
  Query: String;
  ResultString: String;

function Occurrences(const Substring, Text: string): integer;
var
  offset: integer;
begin
  result := 0;
  offset := PosEx(Substring, Text, 1);
  while offset <> 0 do
  begin
    inc(result);
    offset := PosEx(Substring, Text, offset + length(Substring));
  end;
end;

function wallpaper_get_url(AWp_id, ABase, ARes: string) : String;
begin
  Result := Format('http://interfacelift.com/wallpaper/7yz4ma1/%s_%s_%s.jpg', [AWp_id, ABase, ARes]) ;
end;

function grab_page(AIndex: Integer) : String;
begin
  Query := Format('https://interfacelift.com/wallpaper/downloads/date/any/index%d.html', [AIndex]);

  CoResult := CoInitializeEx(nil, COINIT_MULTITHREADED);

  if not((CoResult = S_OK) or (CoResult = S_FALSE)) then
  begin
    Writeln('Failed to initialize COM library.');
    Exit;
  end;

  HTTP := TIdHTTP.Create;

  Result := HTTP.Get(Query);
end;


begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    ResultString := TRegEx.Match( grab_page(1), 'imgload\(''(.+)?'', this,''(.+)''\)').Value;
    Writeln(ResultString);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
