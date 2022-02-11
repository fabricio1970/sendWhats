unit SendWhats.Model.TextMessage;

interface

uses
  Bcl.Json.Attributes;

type
  TTextMessageModel = class
  type
  private
    [JsonPropertyAttribute('phone')]
    FPhone: String;
    [JsonPropertyAttribute('message')]
    FMessage_: String;
    [JsonPropertyAttribute('isGroup')]
    FIsGroup: Boolean;

    procedure SetIsGroup(const Value: Boolean);
    procedure SetMessage_(const Value: String);
    procedure SetPhone(const Value: String);
  public
    property Phone: String read FPhone write SetPhone;
    property Message_: String read FMessage_ write SetMessage_;
    property IsGroup: Boolean read FIsGroup write SetIsGroup;
  end;

implementation

{ TTextMessageModel }

procedure TTextMessageModel.SetPhone(const Value: String);
begin
  FPhone := Value;
end;

procedure TTextMessageModel.SetMessage_(const Value: String);
begin
  FMessage_ := Value;
end;

procedure TTextMessageModel.SetIsGroup(const Value: Boolean);
begin
  FIsGroup := Value;
end;

end.
