unit SendWhats.Utils.LibUtils;

interface

uses
  System.Classes,
  System.NetEncoding,
  System.SysUtils,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

function Base64ToStream(ABase64: String): TMemoryStream;
procedure Base64ToQrCode(ABase64: String; AImage: TImage);
function FileToBase64(AFileName: String): String;
function PhoneWithWithoutNineDigit(APhone: String): string;

implementation

function Base64ToStream(ABase64: String): TMemoryStream;
var
  Base64 : TBase64Encoding;
  Bytes : TBytes;
begin
  Result := nil;
  Base64 := TBase64Encoding.Create;
  Try
    Bytes  := Base64.DecodeStringToBytes(ABase64);
    Result := TBytesStream.Create(Bytes);
    Result.Seek(0, 0);
  Finally
    FreeAndNil(Base64);
    SetLength(Bytes, 0);
    Base64.Free;
  End;
end;

procedure Base64ToQrCode(ABase64: String; AImage: TImage);
var
  FPNG : TPNGImage;
  FStream : TMemoryStream;
begin
  FPNG := TPngImage.Create;
  Try
    if Pos('data:', ABase64) > 0 then begin
      Delete(ABase64, Pos('data:', ABase64), Pos(',', ABase64));
    end;
    FStream := Base64ToStream(ABase64);
    FPNG.LoadFromStream(FStream);
    AImage.Picture.Bitmap.Assign(FPNG);
  Finally
    FPNG.Free;
    FStream.Free;
  End;
end;

function FileToBase64(AFileName: String): String;
var
  Stream: TMemoryStream;
begin
  Result := '';

  Stream := TStringStream.Create;
  Try
    Stream.LoadFromFile(AFileName);
    Result := TNetEncoding.Base64.EncodeBytesToString(Stream.Memory, Stream.Size);
  Finally
    Stream.Free;
  End;
end;

function PhoneWithWithoutNineDigit(APhone: String): string;
begin
  Result := APhone;
  if (StrToInt(Copy(Aphone, 1, 2)) <= 11) or (StrToInt(Copy(APhone, 1, 2)) > 81) then
  begin
    Delete(APhone, 3, 1);
    Result := APhone;
  end;
end;

end.
