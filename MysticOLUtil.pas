Program MysticOLUtil;
{$mode objfpc}{$H+}
{$MODESWITCH ADVANCEDRECORDS}

Uses Generics.Collections, StrUtils, SysUtils, Crt, Door, FileUtils;

function GetOnelinerPath: string;
var
  MysticPath: string;
begin
  MysticPath := GetEnvironmentVariable('MYSTICBBS');
  if MysticPath = '' then
    MysticPath := GetCurrentDir;
  if (MysticPath <> '') and (MysticPath[Length(MysticPath)] <> '/') then
    MysticPath := MysticPath + '/';
  GetOnelinerPath := MysticPath + 'data/oneliner.dat';
end;

Type
(* ONELINER.DAT found in the data directory.  This file contains all the
   one-liner data.  It can be any number of records in size. *)

  OneLineRec = Record
    Text : String[79];
    From : String[30];
  End;

procedure PhenomTitle;
begin
DoorWriteln('                   $$sss  s$"                              5m  ');
DoorWriteln('                   $$  $$ $$                                   ');
DoorWriteln('|03                   $$"""" $$""$e $"//  $$""s  $$""$$ $$sssss   |07');
DoorWriteln('|02                   $$     $$  $$ $SSSS $$  $$ $$$$$$ $$ $$ $$  |07');
DoorWriteln;
DoorWriteln('|05                         --- P R O D U C T I O N S ---       |07');
DoorWriteln('|05                                  EST : 2018                 |07');
DoorWriteln;
DoorWriteln;
DoorWriteln('                   |0AMystic One-Liner Utility                    |07');
DoorWriteln('                   By: |0AHayes Zyxel (Baud Games)|07');
end;

procedure ListOneLiners;
var
  OneLinerFullPath: string;
  F: File Of OneLineRec;
  Rec: OneLineRec;
  idx: integer;
  NumRecords: integer;
  ReadSuccess: boolean;
begin
  OneLinerFullPath := GetOnelinerPath;

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin
    DoorWriteln('|04Unable to open ' + OneLinerFullPath + ' for append.|07');
    halt;
  end;

  try
    // Calculate number of records
    NumRecords := FileSize(F) div SizeOf(OneLineRec);

    // Check if file has no records
    if NumRecords = 0 then
    begin
      DoorWriteln('|03No records found in ' + OneLinerFullPath + '|07');
      Exit;
    end;

    DoorWriteln('Num Records: ' + IntToStr(NumRecords));

    idx := 0;
    repeat
      ReadSuccess := true;
      try
        Read(F, Rec);
      except
        on E: EInOutError do
        begin
          ReadSuccess := false;
          DoorWriteln('|04Error reading record at position ' + IntToStr(idx) + '|07');
        end;
      end;

      if ReadSuccess then
      begin
        DoorWriteln('[' + IntToStr(idx) + '] ' + '(' + Rec.From + ') : ' + Rec.Text);
        Inc(idx);
      end;
    until EOF(F) or not ReadSuccess;

  finally
    Close(F);
  end;
end;

procedure DeleteOneLiner;
var
  OneLinerFullPath: string;
  F: File Of OneLineRec;
  Rec: OneLineRec;
  idxRecToDelete, idxRecsToMove, idxCurrRec: integer;
  yn: char;
  onelinerRecs: specialize TList<OneLineRec>;
  NumRecords: integer;
begin
  OneLinerFullPath := GetOnelinerPath;

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin
    DoorWriteln('|04Unable to open ' + OneLinerFullPath + ' for append.|07');
    halt;
  end;

  try
    // Calculate number of records
    NumRecords := FileSize(F) div SizeOf(OneLineRec);

    // Check if file has no records
    if NumRecords = 0 then
    begin
      DoorWriteln('|03No records found in ' + OneLinerFullPath + '|07');
      Exit;
    end;

    Write('Enter the record to delete: (0-' + IntToStr(NumRecords-1) + ') -> ');
    Readln(idxRecToDelete);

    onelinerRecs := specialize TList<OneLineRec>.Create();
    try
      DoorWriteln('|02Num Records:' + IntToStr(NumRecords) + '|07');

      if (idxRecToDelete < 0) or (idxRecToDelete >= NumRecords) then
      begin
        DoorWriteln('|04Invalid record number!|07');
        Exit;
      end;

      Seek(F, SizeOf(OneLineRec)*idxRecToDelete);
      Read(F, Rec);
      DoorWriteln('[' + IntToStr(idxRecToDelete) + '] ' + '(' + Rec.From + ') : ' + Rec.Text);
      DoorWrite('|02Delete this entry (Y/N) -> |07');
      Readln(yn);

      if (UpCase(yn) = 'Y') then
      begin
        (* Read the remaining records *)
        Seek(F, 0);
        idxCurrRec := 0;
        repeat
          Read(F, Rec);
          if (idxCurrRec <> idxRecToDelete) then
            onelinerRecs.Add(Rec);
          Inc(idxCurrRec);
        until EOF(F);
        Close(F);

        (* Rewrite the file with the deleted record removed *)
        if NOT (OpenFileForOverwrite(F, OneLinerFullPath, 2500)) then
        begin
          DoorWriteln('|04Unable to open ' + OneLinerFullPath + ' for overwrite.|07');
          halt;
        end;

        (* Write all records except the deleted one *)
        for idxRecsToMove := 0 to onelinerRecs.Count-1 do
          Write(F, onelinerRecs[idxRecsToMove]);

        DoorWriteln('|02Record successfully deleted.|07');
      end
      else
      begin
        DoorWriteln('|03Deletion cancelled.|07');
      end;
    finally
      FreeAndNil(onelinerRecs);
    end;
  finally
    Close(F);
  end;
end;

procedure Help;
begin
  DoorWriteln;
  DoorWriteln('|02Options|07');
  DoorWriteln('|02-------|07');
  DoorWriteln('|02L|07)ist One-Liners');
  DoorWriteln('|02D|07)elete One-Liner');
  DoorWriteln('|02Q|07)uit');
  DoorWriteln;
end;

{Here the main program block starts}
var
  selection: char;
begin
  ClrScr;
  PhenomTitle;
  repeat
    Help;
    selection:=UpCase(ReadKey);
    case selection of
    '?': Help;
    'L': ListOneLiners;
    'D': DeleteOneLiner;
    end;
  until (selection='Q');
end.
