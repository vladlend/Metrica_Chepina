unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TArrOfString = array of string;

  TfrmMain = class(TForm)
    mmoAnswer: TMemo;
    dlgOpen_File: TOpenDialog;
    mmoSource: TMemo;
    Panel1: TPanel;
    btnOpenFile: TButton;
    btnDecount: TButton;
    lblResult: TLabel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Panel2: TPanel;
    meUnused: TMemo;
    Splitter3: TSplitter;
    meControl: TMemo;
    meMod: TMemo;
    meInfo: TMemo;
    meVars: TMemo;
    procedure btnOpenFileClick(Sender: TObject);
    procedure btnDecountClick(Sender: TObject);
  private
    { Private declarations }
    FCode: TStringList;
    FVars: TStringList;
    FInfoVars: TStringList;
    FModifiedVars: TStringList;
    FControlVars: TStringList;
    FUnusedVars: TStringList;
    FCodeWithoutDecls: TStringList;
    procedure OpenFile;
    procedure DeleteOneComent;
    procedure DeleteMoreComent;
    procedure DeleteText;
    procedure DeleteChars;
    procedure SearchVariables;
    procedure TestVariables;
    procedure Calculate;
    function TestModified(S: string):Boolean;
    function TestControl(S: string):Boolean;
    function TestUnused(S: string):Boolean;
    procedure MakeCodeWithoutDecls;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses StrUtils, Math;

procedure TfrmMain.btnOpenFileClick(Sender: TObject);
begin
  OpenFile;
end;

procedure TfrmMain.btnDecountClick(Sender: TObject);
var
  Code, Operands: TArrOfString;
begin
  FCode := TStringList.Create;
  FCode.Assign(mmoSource.Lines);
  DeleteText;
  DeleteOneComent;
  DeleteMoreComent;
  DeleteChars;
  mmoAnswer.Lines.Assign(FCode);
  FVars := TStringList.Create;
  FInfoVars := TStringList.Create;
  SearchVariables;
  FModifiedVars := TStringList.Create;
  FControlVars := TStringList.Create;
  FUnusedVars := TStringList.Create;
  FCodeWithoutDecls := TStringList.Create;
  MakeCodeWithoutDecls;

  TestVariables;
  Calculate;

  FInfoVars.Free;
  FModifiedVars.Free;
  FControlVars.Free;
  FUnusedVars.Free;
  FVars.Free;
  FCode.Free;
end;

procedure TfrmMain.Calculate;
begin
  lblResult.Caption := Format('Результат = %f',
    [FInfoVars.Count +
     FModifiedVars.Count * 2 +
     FControlVars.Count * 3 +
     FUnusedVars.Count * 0.5]);
end;

procedure TfrmMain.MakeCodeWithoutDecls;
var
  S: string;
  P, T, T1, T2: Integer;
  Offset: Integer;
begin
  FCodeWithoutDecls.Assign(FCode);
  S := FCodeWithoutDecls.Text;
  Offset := 1;
  while True do begin
    P := PosEx('var', S, Offset);
    if P = 0 then
      break;
    T1 := PosEx(';', S, P+4);
    if T1 = 0 then T1 := Length(S);
    T2 := PosEx(#10, S, P+4);
    if T2 = 0 then T2 := Length(S);
    T := Min (T1, T2);
    Delete(S, P, T-P);
    Offset := P+1;
  end;
  FCodeWithoutDecls.Text := S;
  mmoAnswer.Lines.Assign(FCodeWithoutDecls);
end;

procedure TfrmMain.TestVariables;
var
  I: Integer;
begin
  meMod.Lines.Clear;
  meMod.Lines.Add('Список всех модифицируемых:');
  meControl.Lines.Clear;
  meControl.Lines.Add('Список всех управляющих:');
  meUnused.Lines.Clear;
  meUnused.Lines.Add('Список всех неиспользуемых:');
  for I := 0 to FVars.Count-1 do begin
    if TestModified(FVars[i]) then begin
      FModifiedVars.Add(FVars[I]);
      meMod.Lines.Add(FVars[I]);
    end;
    if TestControl(FVars[i]) then begin
      FControlVars.Add(FVars[I]);
      meControl.Lines.Add(FVars[I]);
    end;
    if TestUnused(FVars[i]) then begin
      FUnusedVars.Add(FVars[I]);
      meUnused.Lines.Add(FVars[I]);
    end;
  end;
end;

function TfrmMain.TestModified(S: string):Boolean;
var
  I, Offset: Integer;
  P, F, T1, T2: Integer;
  TempString: string;
begin
  TempString := FCodeWithoutDecls.Text;
  Offset := 1;
  Result := False;
  while True do begin
    F := PosEx(S, TempString, Offset);
    if F > 0 then begin
      I := F+Length(S);
      while (TempString[I] = #32) or (TempString[I] = #8) do
        I := I + 1;
      if TempString[I] = '=' then begin
        Result := True;
      end;
      if TempString[I]+TempString[i+1] = '+=' then begin
        Result := True;
      end;
      if TempString[I]+TempString[i+1] = '-=' then begin
        Result := True;
      end;
      if TempString[I]+TempString[i+1] = '*=' then begin
        Result := True;
      end;
      if TempString[I]+TempString[i+1] = '/=' then begin
        Result := True;
      end;
      if TempString[I]+TempString[i+1] = '%=' then begin
        Result := True;
      end;
    end else
      Break;
    Offset := F + Length(S) + 1;
  end;
end;

function TfrmMain.TestControl(S: string):Boolean;
var
  Count: Integer;
  Offset: Integer;
  P, F, T: Integer;
begin
  Count := 0;
  Offset := 1;
  while True do begin
    F := PosEx('if', FCode.Text, Offset);
    if F = 0 then
      break;
    T := PosEx('{', FCode.Text, F+3);
    if T = 0 then
      break;
    P := Pos(S, Copy(FCode.Text, F+3, T-(F+3)));
    if P > 0 then
      Count := Count + 1;
    Offset := T + 1;
  end;
  if Count > 0 then begin
    Result := True;
    Exit;
  end;
  Offset := 1;
  while True do begin
    F := PosEx('switch', FCode.Text, Offset);
    if F = 0 then
      break;
    T := PosEx('{', FCode.Text, F+7);
    if T = 0 then
      break;
    T := Pos(S, Copy(FCode.Text, F+7, T-(F+7)));
    if T = 0 then
      break;
    Count := Count + 1;
    Offset := T + 1;
  end;
  if Count > 0 then begin
    Result := True;
    Exit;
  end;
  Offset := 1;
  while True do begin
    F := PosEx('while', FCode.Text, Offset);
    if F = 0 then
      break;
    T := PosEx('{', FCode.Text, F+6);
    if T = 0 then
      break;
    T := Pos(S, Copy(FCode.Text, F+6, T-(F+6)));
    if T = 0 then
      break;
    Count := Count + 1;
    Offset := T + 1;
  end;
  if Count > 0 then begin
    Result := True;
    Exit;
  end;
  Offset := 1;
  while True do begin
    F := PosEx('for', FCode.Text, Offset);
    if F = 0 then
      break;
    T := PosEx('{', FCode.Text, F+4);
    if T = 0 then
      break;
    T := Pos(S, Copy(FCode.Text, F+4, T-(F+4)));
    if T = 0 then
      break;
    Count := Count + 1;
    Offset := T + 1;
  end;
  Result := Count > 0;
end;

function TfrmMain.TestUnused(S: string):Boolean;
var
  Count: Integer;
  Offset: Integer;
  P: Integer;
begin
  Count := 0;
  Offset := 1;
  while True do begin
    P := PosEx(S, FCode.Text, Offset);
    if P = 0 then
      break;
    Count := Count + 1;
    Offset := P + 1;
  end;
  Result := Count = 1;
end;

function GetVariable(S: string): string;
var
  I, J: Integer;
  IsFirst: Boolean;
begin
  for I:=1 to Length(S) do
    if (S[I] >= 'a') and (S[I] <= 'z') or (S[I] >= 'A') and (S[I] <= 'Z') then
      break;
  for J:=I to Length(S) do
    if not((S[J] >= 'a') and (S[J] <= 'z') or (S[J] >= 'A') and (S[J] <= 'Z') or (S[J] >= '0') and (S[J] <= '9')) then
      break;
  Result := Copy(S, I, J-I);
end;

procedure TfrmMain.SearchVariables;
var
  S: string;
  P, T, T1, T2, Offset: Integer;
  VarList, VarStr: string;
begin
  meVars.Lines.Clear;
  meVars.Lines.Add('Список всех переменных:');
  meInfo.Lines.Clear;
  meInfo.Lines.Add('Список всех информационных:');
  S := FCode.Text;
  Offset := 1;
  while True do begin
    P := PosEx('var', S, Offset);
    if P = 0 then
      break;
    T1 := PosEx(';', S, P+4);
    if T1 = 0 then T1 := Length(S)+1;
    T2 := PosEx(#10, S, P+4);
    if T2 = 0 then T2 := Length(S)+1;
    T := Min(T1, T2);
    if T = 0 then
      T := Length(S)+1;
    VarList := Copy(S, P+4, T-(P+4));
    repeat
      P := Pos(',', VarList);
      if P = 0 then
        P := Length(VarList)+1;
      VarStr := GetVariable(Copy(VarList, 1, P-1));
      if VarStr <> '' then begin
        FVars.Add(VarStr);
        meVars.Lines.Add(VarStr);
      end;
      VarList := Copy(VarList, P+1, Length(VarList)-P);
    until VarList = '';
    Offset := T;
  end;
  Offset := 1;
  while True do begin
    P := PosEx('let', S, Offset);
    if P = 0 then
      break;
    T1 := PosEx(';', S, P+4);
    if T1 = 0 then T1 := Length(S)+1;
    T2 := PosEx(#10, S, P+4);
    if T2 = 0 then T2 := Length(S)+1;
    T := Min(T1, T2);
    if T = 0 then
      T := Length(S)+1;
    VarList := Copy(S, P+4, T-(P+4));
    repeat
      P := Pos(',', VarList);
      if P = 0 then
        P := Length(VarList)+1;
      VarStr := GetVariable(Copy(VarList, 1, P-1));
      if VarStr <> '' then begin
        FVars.Add(VarStr);
        FInfoVars.Add(VarStr);
        meVars.Lines.Add(VarStr);
        meInfo.Lines.Add(VarStr);
      end;
      VarList := Copy(VarList, P+1, Length(VarList)-P);
    until VarList = '';
    Offset := T;
  end;
end;

procedure TfrmMain.OpenFile;
begin
  if dlgOpen_File.Execute then
  begin
    mmoSource.Clear;
    mmoSource.Lines.LoadFromFile(dlgOpen_File.FileName);
  end;
end;

procedure TfrmMain.DeleteText;
var
  S: String;
  I, Offset: Integer;
  StrBegin: Integer;
begin
  S := FCode.Text;
  Offset := 1;
  while True do begin
    I := PosEx('\"', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 2);
    Offset := I;
  end;

  Offset := 1;
  StrBegin := 0;
  while True do begin
    I := PosEx('"', S, Offset);
    if I = 0 then
      Break;
    if StrBegin = 0 then begin
      StrBegin := I;
      Offset := I + 1;
    end else begin
      Delete(S, StrBegin, I-StrBegin+1);
      StrBegin := 0;
      Offset := StrBegin;
    end;
  end;
  FCode.Text := S;
end;

procedure TfrmMain.DeleteChars;
var
  S: String;
  I, Offset: Integer;
  StrBegin: Integer;
begin
  S := FCode.Text;
  Offset := 1;
  while True do begin
    I := PosEx(''',''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;
  Offset := 1;
  while True do begin
    I := PosEx(''';''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;
  Offset := 1;
  while True do begin
    I := PosEx(''':''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;
  Offset := 1;
  while True do begin
    I := PosEx('''}''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;
  Offset := 1;
  while True do begin
    I := PosEx('''{''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;
  Offset := 1;
  while True do begin
    I := PosEx('''=''', S, Offset);
    if I = 0 then
      Break;
    Delete(S, I, 3);
    Offset := I;
  end;

  FCode.Text := S;
end;

procedure TfrmMain.DeleteOneComent;
var
  S: String;
  I, J, Offset: Integer;
begin
  S := FCode.Text;
  Offset := 1;
  while True do begin
    I := PosEx('//', S, Offset);
    Offset := I+2;
    if I = 0 then
      Break;
    J := PosEx(#13#10, S, Offset);
    if J > 0 then begin
      Delete(S, I, J-I);
      Offset := I;
    end;
  end;
  FCode.Text := S;
end;

procedure TfrmMain.DeleteMoreComent;
var
  S: String;
  I, J, Offset: Integer;
begin
  S := FCode.Text;
  Offset := 1;
  while True do begin
    I := PosEx('/*', S, Offset);
    Offset := I+2;
    if I = 0 then
      Break;
    J := PosEx('*/', S, Offset);
    if J > 0 then begin
      Delete(S, I, J-I+2);
      Offset := I;
    end;
  end;
  FCode.Text := S;
end;

end.
