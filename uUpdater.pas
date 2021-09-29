unit uUpdater;

interface

type
  // TApp
  TApp = class
    Name: string;
    Version: string;
    FileSize: integer;
    BlockSize: integer;
  end;

  // TFragment
  TFragment = class
    Part: string;
    Hash: string;
  end;

  // TJSON
  TJSON = class
    App: TApp;
    Fragments: array of TFragment;
  end;

  // TErrorEvent
  TErrorEvent = procedure(Error: string) of object;

  TUpdater = class
    constructor Create(Version: string);
    procedure Initialize;
    function IsUpToDate(): Boolean;
    function IsValidFragment(Fragment: TFragment): Boolean;
    procedure DownloadUpdate();
  private
    FVersion: string;
    FUpdate: TJSON;
    FOnError: TErrorEvent;
    FDownloadDir: string;
  public
    property Update: TJSON read FUpdate;
    property OnError: TErrorEvent read FOnError write FOnError;
  end;

implementation

uses IdHTTP, System.Classes, System.SysUtils, JSON, System.Generics.Collections,
  IdHashMessageDigest, idHash;

constructor TUpdater.Create(Version: string);
begin
  FVersion := Version;
end;

procedure TUpdater.Initialize;
var
  IDHTTP: TIdHTTP;
  MS: TMemoryStream;
  JSONResponse: string;
  JSONObject: TJSONObject;
  JSONApp: TJSONObject;
  JSONFragments: TJSONArray;
  JSONFragment: TJSONObject;
  i: integer;
begin
  IdHTTP := TIdHTTP.Create(nil);
  MS := TMemoryStream.Create;
  FUpdate := TJSON.Create;
  try
    try
      IdHTTP.Get('http://updater.to/HASH-HASH-HASH-HASH-HASH/update.json', MS);
      SetString(JSONResponse, PAnsiChar(MS.Memory), MS.Size);
      JSONObject := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
      // App
      JSONApp := JSONObject.GetValue('app') as TJSONObject;
      FUpdate.App := TApp.Create;
      FUpdate.App.Name := JSONApp.GetValue('name').Value;
      FUpdate.App.Version := JSONApp.GetValue('version').Value;
      FUpdate.App.FileSize := StrToInt(JSONApp.GetValue('fileSize').Value);
      FUpdate.App.BlockSize := StrToInt(JSONApp.GetValue('blockSize').Value);
      // Fragments
      JSONFragments := JSONObject.GetValue('fragments') as TJSONArray;
      SetLength(FUpdate.Fragments, JSONFragments.Count);
      for i := 0 to JSONFragments.Count - 1 do
      begin
        JSONFragment := JSONFragments.items[i] as TJSONObject;
        FUpdate.Fragments[i] := TFragment.Create;
        FUpdate.Fragments[i].Part := JSONFragment.GetValue('part').Value;
        FUpdate.Fragments[i].Hash := JSONFragment.GetValue('hash').Value;
      end;
      FDownloadDir := GetEnvironmentVariable('APPDATA') + '\' + FUpdate.App.Name;
      ForceDirectories(FDownloadDir);
    except on E: Exception do
      if Assigned(FOnError) then
       FOnError(E.Message);
    end;
  finally
    IdHTTP.Free;
    MS.Free;
  end;
end;

function TUpdater.IsUpToDate(): Boolean;
begin
  Result := false;
  if FVersion = FUpdate.App.Version then Result := true;
end;

function Tupdater.IsValidFragment(Fragment: TFragment): Boolean;
var
  FilePath: string;
function MD5(const path: String): String;
var
  idmd5: TIdHashMessageDigest5;
  fs: TFileStream;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  fs := TFileStream.Create(path, fmOpenRead OR fmShareDenyWrite);
  try
    result := idmd5.HashStreamAsHex(fs);
  finally
    idmd5.Free;
    fs.Free;
  end;
end;
begin
  Result := False;
  FilePath := FDownloadDir + '\' + Fragment.Part + '.frag';
  if FileExists(FilePath) then
  begin
    if MD5(FilePath) = Fragment.Hash then Result := True;
  end;
end;

procedure TUpdater.DownloadUpdate();
var
  i: Integer;
begin
  for i := 0 to Length(FUpdate.Fragments) - 1 do
  begin
//    downloadFragment((JSONObj.GetValue('fragments') as TJSONArray).items[i] as TJSONObject);
  end;
end;

end.
