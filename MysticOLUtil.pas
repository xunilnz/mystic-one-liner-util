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

procedure ExportOneLiners;
var
  OneLinerFullPath: string;
  ExportFileName: string;
  F: File Of OneLineRec;
  ExportFile: Text;
  Rec: OneLineRec;
  idx: integer;
  NumRecords: integer;
  ReadSuccess: boolean;
begin
  // Get the path to the oneliners.dat file
  OneLinerFullPath := GetOnelinerPath;

  // Set the export filename (could make this configurable)
  ExportFileName := 'oneliners.asc';

  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin
    DoorWriteln('|04Unable to open ' + OneLinerFullPath + ' for reading.|07');
    Halt;
  end;

  // Create the export file
  Assign(ExportFile, ExportFileName);
  {$I-}
  Rewrite(ExportFile);
  {$I+}
  if IOResult <> 0 then
  begin
    DoorWriteln('|04Unable to create export file: ' + ExportFileName + '|07');
    Close(F);
    Halt;
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

    DoorWriteln('|11Exporting ' + IntToStr(NumRecords) + ' oneliners to ' + ExportFileName + '|07');

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
        // Write to pipe-code ASCII file
        WriteLn(ExportFile, '|03[|07' + Rec.From + '|03]|07 ' + Rec.Text);
        Inc(idx);

        // Show progress every 10 records
        if (idx mod 10 = 0) then
          DoorWrite('|15.|07');
      end;
    until EOF(F) or not ReadSuccess;

    DoorWriteln('');
    DoorWriteln('|11Successfully exported ' + IntToStr(idx) + ' oneliners to ' + ExportFileName + '|07');

  finally
    Close(F);
    Close(ExportFile);
  end;
end;

procedure EditOneLiner;
var
  OneLinerFullPath: string;
  F: File Of OneLineRec;
  Rec: OneLineRec;
  NewText: string;
  NumRecords: integer;
  ReadSuccess: boolean;
  IndexStr: string;
  Index: Integer;
  ErrorCode: Integer;
begin
  // Get the path to the oneliners.dat file
  OneLinerFullPath := GetOnelinerPath;

  // First open the file to check size
  if NOT (OpenFileForReadWrite(F, OneLinerFullPath, 2500)) then
  begin
    DoorWriteln('|04Unable to open ' + OneLinerFullPath + ' for editing.|07');
    Exit;
  end;

  try
    NumRecords := FileSize(F) div SizeOf(OneLineRec);
    if NumRecords = 0 then
    begin
      DoorWriteln('|03No oneliners found in the database.|07');
      Exit;
    end;

    // Get which oneliner to edit from user
    DoorWrite('|15Enter oneliner number to edit (1-' + IntToStr(NumRecords) + '): |07');
    Readln(IndexStr);
    Val(IndexStr, Index, ErrorCode);

    // Validate input
    if ErrorCode <> 0 then
    begin
      DoorWriteln('|04Error: Please enter a valid number|07');
      Exit;
    end;

    // Convert to 0-based index and validate
    Index := Index - 1;
    if (Index < 0) or (Index >= NumRecords) then
    begin
      DoorWriteln('|04Error: Please enter a number between 1 and ' + IntToStr(NumRecords) + '|07');
      Exit;
    end;

    // Position to the record
    Seek(F, Index);

    // Read the existing record
    ReadSuccess := true;
    try
      Read(F, Rec);
    except
      on E: EInOutError do
      begin
        ReadSuccess := false;
        DoorWriteln('|04Error reading oneliner at position ' + IntToStr(Index + 1) + '|07');
      end;
    end;

    if not ReadSuccess then Exit;

    // Display current oneliner
    DoorWriteln('');
    DoorWriteln('|15Editing oneliner #' + IntToStr(Index + 1) + '|07');
    DoorWriteln('|03From:|07 ' + Rec.From);
    DoorWriteln('|03Text:|07 ' + Rec.Text);
    DoorWriteln('');

    // Get new text from user
    DoorWrite('|11Enter new text (79 chars max, blank to cancel):|07 ');
    Readln(NewText);

    // Check for cancel
    if NewText = '' then
    begin
      DoorWriteln('|03Edit canceled.|07');
      Exit;
    end;

    // Validate length
    if Length(NewText) > 79 then
    begin
      DoorWriteln('|04Error: Text too long (max 79 characters)|07');
      Exit;
    end;

    // Mark as edited if not already marked
    if (Rec.From <> '') and (Rec.From[1] <> '*') then
      Rec.From := '*' + Rec.From;

    // Update the text
    Rec.Text := NewText;

    // Write back to file
    Seek(F, Index);
    Write(F, Rec);

    DoorWriteln('|11Oneliner #' + IntToStr(Index + 1) + ' updated successfully.|07');

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
  DoorWriteLn('|02E|07)dit a One-Liner');
  DoorWriteLn('|07e|02X|07)port One-liners');
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
    'E': EditOneLiner;
    'D': DeleteOneLiner;
    'X': ExportOneLiners;
    end;
  until (selection='Q');
end.
