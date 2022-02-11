unit SendWhats.Model.FileMessage;

interface

uses
  Bcl.Json.Attributes;

type
  TFileMessageModel = class
  type
  private
    [JsonPropertyAttribute('phone')]
    FPhone: String;
    [JsonPropertyAttribute('base64')]
    FBase64: String;
    [JsonPropertyAttribute('filename')]
    FFileName: String;
    [JsonPropertyAttribute('isGroup')]
    FIsGroup: Boolean;

    procedure SetIsGroup(const Value: Boolean);
    procedure SetBase64(const Value: String);
    procedure SetPhone(const Value: String);
    procedure SetFileName(const Value: String);
  public
    property Phone: String read FPhone write SetPhone;
    property Base64: String read FBase64 write SetBase64;
    property FileName: String read FFileName write SetFileName;
    property IsGroup: Boolean read FIsGroup write SetIsGroup;
  end;

implementation

{ TMessageModel }

procedure TFileMessageModel.SetPhone(const Value: String);
begin
  FPhone := Value;
end;

procedure TFileMessageModel.SetBase64(const Value: String);
begin
  FBase64 := Value;
end;

procedure TFileMessageModel.SetFileName(const Value: String);
begin
  FFileName := Value;
end;

procedure TFileMessageModel.SetIsGroup(const Value: Boolean);
begin
  FIsGroup := Value;
end;

end.

