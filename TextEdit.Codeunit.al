// #pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
Codeunit 60000 TextEdit
{ }
// {
//     // B.i.TEAM GmbH
//     // Lfd.Nr.  Version  Datum       User   Beschreibung
//     // ===========================================================================
//     // 1.00     TXT6.00    04.01.2009  HR082  Fließtexteditor
//     // 2.00     TXT6.00.01 25.01.2010  HR082  Bearbeitung temporärer Records implementiert


//     trigger OnRun()
//     begin
//     end;

//     var
//         Text1000000000: label 'Please select the entry you want to edit!';
//         Text1000000001: label 'The text box is already visible!';
//         Text1000000002: label 'Edit purchse line text';
//         Text1000000003: label 'Inserting lines\\Number of inserted lines: #1##########';
//         Text1000000004: label 'Additional %1 lines should be entered but there is only room for ';
//         Text1000000005: label '%2 additional lines.\\Add only %2 additional lines?';
//         Text1000000006: label 'Entry of text cancelled!';
//         Text1000000007: label 'There is no more room for additional lines, entry of text cancelled!';
//         Text1000000008: label 'The comment line has to be assigned to an object!';
//         Text1000000009: label 'Edit comments';
//         Text1000000010: label 'The comment line has to be assigened to a document!';
//         Text1000000011: label 'Edit sales comments';
//         Text1000000012: label 'Edit purchase comments';
//         Text1000000013: label 'Edit reminder comments';
//         Text1000000014: label 'Edit finance charge memo comments';
//         Text1000000015: label 'Edit employee comments';
//         Text1000000016: label 'Edit confidential info comments';
//         Text1000000017: label 'Edit extended text lines';
//         Text1000000018: label 'Edit reminder text';
//         Text1000000019: label 'Edit financial charge memo text';
//         TextFIN: Automation ;
//         Window: Dialog;
//         Text1000000020: label 'Edit Sales Lines';
//         Text1000000021: label 'Edit purchase lines';
//         Language: Record Language;
//         Text1000000022: label 'Edit contact comments';
//         Text1000000023: label 'Edit warehouse comments';
//         Text1000000024: label 'Edit service comments';
//         Text1000000025: label 'Edit inventory comments';
//         Text1000000026: label 'Edit manufacturing comments';
//         Text1000000027: label 'Edit production order comments';
//         Text1000000028: label 'Edit setup checklist comments';
//         Text1000000029: label 'Edit stockkeeping unit comments';
//         Text1000000030: label 'Edit item tracking comments';
//         Text1000000031: label 'Edit routing comments';
//         Text1000000032: label 'Edit production order comments';
//         Text1000000033: label 'Edit Production order routing comment';
//         Text1000000034: label 'Edit production order bill of materials comment';
//         Text1000000035: label 'Edit XBRL comment';
//         Text1000000036: label 'Edit Commerce Portal comment line';
//         Text1000000037: label 'Edit BizTalk comment lines';
//         Text2000000000: label 'Missing field-parameters in continuous text editor!';
//         Text2000000001: label 'Conflicting field-parameters in continuous text editor!';
//         Text2000000002: label 'Last field in Primary Key of table %1 or in the provided selection fields must be of one of these types: %2';
//         Text2000000003: label 'Integer, BigInteger, GUID, Decimal';
//         Text2000000004: label 'Missing selection-/filter-fields in continuous text editor!';
//         Text2000000005: label 'Error locating field ''%1'' in table ''%2''!';
//         Text2000000006: label 'Field to edit not provided in continuous text editor!';
//         Text2000000007: label 'Edit %1';
//         Text2000000008: label 'Error location table ID %1';
//         Text2000000009: label 'Error in retrieving lines by attached to.\Fields %1 and %2 are both empty!';
//         Text2000000010: label 'Integer';
//         Text2000000011: label 'BigInteger';
//         Text2000000012: label 'Decimal';
//         Text2000000013: label 'GUID';
//         Text2000000014: label 'There is no more room for additional lines, entry of text cancelled!';


//     procedure EditTextLines(SourceRec: RecordRef;TextField: Text[30];SelectBy: Text[1024];DistinguishBy: Text[1024];AttachedToField: Text[30];AttachmentField: Text[30];CopyAllFields: Boolean;CopyFields: Text[1024];EditWindowTitle: Text[50]) Changed: Boolean
//     var
//         WorkRec: RecordRef;
//         CompareRec: RecordRef;
//         FirstRec: RecordRef;
//         LastRec: RecordRef;
//         WorkFld: FieldRef;
//         WorkStr: Text[1024];
//         TextEdit: Automation ;
//         LanguageID: Integer;
//         Lauf: Integer;
//         WorkField: FieldRef;
//         SourceField: FieldRef;
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       02.05.2003
//         // Parameters: SourceRec        RecordRef on Record to be edited
//         //             TextField        Name of field to be edited
//         //             SelectBy         Comma separated list of fields to select affected records
//         //                              IF empty, Primary Key is used
//         //                              In either way, last field must be AutoSplitKeyField
//         //             DistinguishBy    Comma separated list of fields to identify text blocks
//         //                              Empty if Record uses the "attached to" logic
//         //             AttachedToField  If the Record uses the "attached to" logic, name of field to which
//         //                              the subsequent lines are related
//         //             AttachmentField  If the Record uses the "attached to" logic, name of field where the
//         //                              attachment information in the subsequent lines is stored
//         //             CopyAllFields    If TRUE, all fields from the last existing record are copied in
//         //                              added record. Ff FALSE only Primary Key fields and, if appropriate, the
//         //                              "Attached To" value and the fields in the "CopyFields" parameter are
//         //                              copied
//         //             CopyFields       If CopyAllFields = FALSE, list of fields to be copied from last existing
//         //                              record to eventual new records
//         //             EditWindowTitle  Title of Text Edit Window
//         // Result:     True if changed, false if unchanged
//         // Purpose:    Text editing of all kind of lines
//         // Annotation: Last field of primary key must be "Autosplitkey"-enabled: Integer, BigInteger, GUID or decimal

//         //Open new RecordRef
//         //2.00 B
//         if SourceRec.IsTemporary then
//           WorkRec.Open(SourceRec.Number, true)
//         else
//           WorkRec.Open(SourceRec.Number);
//         //2.00 E

//         //Set Filter
//         SelectRecords(WorkRec, SourceRec, SelectBy);

//         // Check field parameters
//         TextField := TRIM(TextField);
//         if TextField = '' then
//           Error(Text2000000006);

//         DistinguishBy := TRIM(DistinguishBy);
//         AttachedToField := TRIM(AttachedToField);
//         AttachmentField := TRIM(AttachmentField);

//         if (DistinguishBy = '') and ((AttachedToField = '') or (AttachmentField = '')) then
//           Error(Text2000000000);

//         if (DistinguishBy <> '') and ((AttachedToField <> '') and (AttachmentField <> '')) then
//           Error(Text2000000001);

//         //Set title
//         EditWindowTitle := TRIM(EditWindowTitle);
//         if EditWindowTitle = '' then
//           EditWindowTitle := StrSubstNo(Text2000000007, SourceRec.Caption);

//         //Set comparision record
//         CompareRec := SourceRec;

//         FindFirstLast(CompareRec, WorkRec, FirstRec, LastRec, DistinguishBy, AttachmentField, AttachedToField);

//         if ISCLEAR(TextFIN) then
//           Create(TextFIN,true,true);
//         TextFIN.Title := EditWindowTitle;
//         LanguageID := GlobalLanguage;
//         TextFIN.Language(LanguageID);

//         WorkRec.SetPosition(FirstRec.GetPosition);
//         ReadText(FirstRec, LastRec, WorkRec, TextField);
//         TextFIN.Show;
//         repeat
//           Sleep(500);
//         until not TextFIN.Visible;

//         if TextFIN.Cancel then
//           Changed := false
//         else begin
//           WriteText(FirstRec, LastRec, WorkRec, TextField, CopyAllFields, CopyFields, AttachedToField, AttachmentField);
//         //2.00 B
//           if SourceRec.IsTemporary then begin
//             WorkStr := SourceRec.GetPosition();
//             SourceRec.DeleteAll;
//             WorkRec.FindFirst;
//             repeat
//                 SourceRec.Init;
//                 for Lauf := 1 to SourceRec.FieldCount do
//                   begin
//                     WorkField := WorkRec.FieldIndex(Lauf);
//                     SourceField := SourceRec.FieldIndex(Lauf);
//                     SourceField.Value := WorkField.Value;
//                   end;
//                   SourceRec.Insert;
//               until WorkRec.Next <> 1;
//               SourceRec.SetPosition(WorkStr);
//           end;
//         //2.00 E
//           Changed := true;
//         end;

//         Clear(TextFIN);
//     end;


//     procedure SelectRecords(var WorkRec: RecordRef;SourceRec: RecordRef;SelectFields: Text[1024])
//     var
//         PK: KeyRef;
//         WorkField: FieldRef;
//         FilterField: FieldRef;
//         WorkStr: Text[30];
//         Counter: Integer;
//         Pos: Integer;
//         FieldNo: Integer;
//         debug_count: Integer;
//         Lauf: Integer;
//         SourcePos: Text[1024];
//         SourceField: FieldRef;
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       02.05.2003
//         // Parameters: WorkRec          RecordRef on Record to be filtered
//         //             SourceRec        RecordRef on Record to be edited
//         //             SelectFields     Comma separated list of fields to select affected records
//         //                              IF empty, Primary Key except last field (Autosplitkey) is used
//         // Result:     None, on error, state of WorkRec is undefined
//         // Purpose:    Set filter on WorkRec according to actual record in SourceRec and Fields in SelectFields or,
//         //             if SelectFields is empty, on Primary Key except last field
//         // Annotation:

//         //Delete existing filters
//         WorkRec.Reset;

//         //2.00 B
//         //If temporary, copy records
//         if WorkRec.IsTemporary then begin
//           WorkRec.DeleteAll;
//           SourcePos := SourceRec.GetPosition;
//           SourceRec.FindFirst;
//           repeat
//               for Lauf := 1 to SourceRec.FieldCount do
//                 begin
//                   WorkField := WorkRec.FieldIndex(Lauf);
//                   SourceField := SourceRec.FieldIndex(Lauf);
//                   WorkField.Value := SourceField.Value;
//                 end;
//                 WorkRec.Insert;
//             until SourceRec.Next <> 1;
//             SourceRec.SetPosition(SourcePos);
//             WorkRec.SetPosition(SourcePos);
//         end else begin
//         //2.00 E

//           //If no SelectionFields provided, use Primary Key
//           if SelectFields = '' then begin
//             PK := SourceRec.KeyIndex(1);
//             for Counter := 1 to PK.FieldCount do begin
//               WorkField := PK.FieldIndex(Counter);
//               if StrLen(SelectFields) > 0 then
//                 SelectFields := SelectFields + ',';
//               SelectFields := SelectFields + WorkField.Name;
//             end;
//           end;

//           //Selection fields found?
//           if StrLen(SelectFields) = 0 then
//             Error(Text2000000004);

//           //Build filter string
//           repeat
//             //Get next field name
//             Pos := StrPos(SelectFields, ',');
//             if Pos > 0 then begin
//               WorkStr := CopyStr(SelectFields, 1, Pos - 1);
//               if StrLen(SelectFields) > Pos then
//                 SelectFields := CopyStr(SelectFields, Pos + 1)
//               else
//                 SelectFields := '';
//             end else begin
//               WorkStr := SelectFields;
//               SelectFields := '';
//             end;

//             //Get field number for that field
//             FieldNo := GetFieldNoByName(SourceRec.Number, WorkStr);

//             //Set FieldRefs
//             WorkField := SourceRec.Field(FieldNo);
//             FilterField := WorkRec.Field(FieldNo);

//             //Set Filter
//             FilterField.SetRange(WorkField.Value);

//           until StrLen(SelectFields) = 0;

//           //Check last field (must be autosplitkey-able) and remove filter
//           WorkStr := Format(FilterField.Type);
//           if StrPos(Text2000000003, WorkStr) = 0 then
//             Error(Text2000000002, SourceRec.Caption, Text2000000003)
//           else
//             FilterField.SetRange();

//         //2.00 B
//         end;
//         //2.00 E
//     end;


//     procedure TRIM(ToTrim: Text[1024]) Result: Text[1024]
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       05.05.2003
//         // Parameters: ToTrim           String to be trimmed
//         // Result:     Trimmed String
//         // Purpose:    Removes leading and trailing spaces
//         // Annotation:

//         Result := DelChr(ToTrim, '<', ' ');
//         Result := DelChr(Result, '>', ' ');
//     end;


//     procedure ISEmpty(VarValue: Variant) Empty: Boolean
//     var
//         IntVar: Integer;
//         DecVar: Decimal;
//         CharVar: Char;
//         TextVar: Text[1024];
//         CodeVar: Code[1024];
//         DateVar: Date;
//         TimeVar: Time;
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       05.05.2003
//         // Parameters: VarValue   Variant to be checked
//         // Result:     True if empty, false if not
//         // Purpose:    Checks if a variant of a simple data type (Integer, Decimal
//         //             Char, Text, Code, Date, Time) is empty
//         //             Numeric variants (Integer, Decimal) are empty when they are equal 0
//         //             Char variant is empty when equal ' '
//         //             String variants (Text, Code) are empty when they are equal ''
//         //             Date variants are empty when they are equal 0D
//         //             Time variants are empty when they are equal 0T
//         // Annotation: Works for listed datatypes only, if different datatype is provided
//         //             result is always "False"

//         Empty := false;

//         if VarValue.Isinteger then begin
//           IntVar := VarValue;
//           if IntVar = 0 then
//              Empty := true;
//         end;

//         if VarValue.IsDecimal then begin
//           DecVar := VarValue;
//           if DecVar = 0 then
//              Empty := true;
//         end;

//         if VarValue.ISCHAR then begin
//           CharVar := VarValue;
//           if CharVar = ' ' then
//              Empty := true;
//         end;

//         if VarValue.IsText then begin
//           TextVar := VarValue;
//           if TextVar = '' then
//              Empty := true;
//         end;

//         if VarValue.ISCODE then begin
//           CodeVar := VarValue;
//           if CodeVar = '' then
//              Empty := true;
//         end;

//         if VarValue.IsDate then begin
//           DateVar := VarValue;
//           if DateVar = 0D then
//              Empty := true;
//         end;

//         if VarValue.IsTime then begin
//           TimeVar := VarValue;
//           if TimeVar = 0T then
//              Empty := true;
//         end;
//     end;


//     procedure GetFieldNoByName(TableNo: Integer;FieldName: Text[30]) FieldNo: Integer
//     var
//         FieldTab: Record "Field";
//         TableTab: Record "Table Information";
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       05.05.2003
//         // Parameters: TableNo           Number of table
//         //             FieldName         Name of field
//         // Result:     Number of field as integer
//         // Purpose:    Retrieves a field number by table number and field name
//         // Annotation:

//         FieldTab.Reset;
//         FieldTab.SetRange(TableNo, TableNo);
//         FieldTab.SetRange(FieldName, FieldName);
//         if not FieldTab.Find('-') then begin
//             TableTab.Reset;
//             TableTab.SetRange("Table No.", TableNo);
//             if not TableTab.Find('-') then
//               Error(Text2000000008, TableNo)
//             else
//               Error(Text2000000005, FieldName, TableTab."Table Name");
//         end else
//           FieldNo := FieldTab."No.";
//     end;


//     procedure FindFirstLast(Akt: RecordRef;Work: RecordRef;var First: RecordRef;var Last: RecordRef;Dist: Text[1024];Att: Text[30];AttTo: Text[30])
//     var
//         WorkFld: FieldRef;
//         CompFld: array [20] of FieldRef;
//         FirstFld: FieldRef;
//         LastFld: FieldRef;
//         Attached: Boolean;
//         WorkStr: Text[1024];
//         WorkDist: Text[1024];
//         FieldNoAtt: Integer;
//         FieldNoAttTo: Integer;
//         FieldCount: Integer;
//         Lauf: Integer;
//         Pos: Integer;
//         Found: Boolean;
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       05.05.2003
//         // Parameters: Akt              RecordRef on actual record
//         //             First            RecordRef to return first record
//         //             Last             RecordRef to return last record
//         //             Dist             Comma separated list of fields to identify text blocks
//         //             Att              Field attached
//         //             AttTo            Field attached to
//         // Result:     None, on error, state of WorkRec is undefined
//         // Purpose:    Set filter on WorkRec according to actual record in SourceRec and Fields in SelectFields or,
//         //             if SelectFields is empty, on Primary Key except last field
//         // Annotation:

//         //Determine method
//         if Dist <> '' then
//           Attached := false
//         else
//           Attached := true;

//         //Get RecordRefs
//         //2.00 B
//         if Work.IsTemporary then
//           begin
//             First.Open(Akt.Number,true);
//             Last.Open(Akt.Number,true);

//             //Copy Content of Work RecRef in First and Last
//             WorkStr := Work.GetPosition;
//             Work.FindFirst;
//             repeat
//               First.Init;
//               Last.Init;
//               for Lauf := 1 to Work.FieldCount do
//                 begin
//                   FirstFld := First.FieldIndex(Lauf);
//                   LastFld := Last.FieldIndex(Lauf);
//                   WorkFld := Work.FieldIndex(Lauf);
//                   FirstFld.Value := WorkFld.Value;
//                   LastFld.Value := WorkFld.Value;
//                 end;
//                 First.Insert;
//                 Last.Insert;
//             until Work.Next <> 1;
//             Work.SetPosition(WorkStr);
//           end
//         else
//           begin
//             First.Open(Akt.Number);
//             Last.Open(Akt.Number);
//           end;
//         //2.00 E

//         //Set Filter
//         First.SetView(Work.GetView);
//         Last.SetView(Work.GetView);

//         //Set Position
//         First.SetPosition(Akt.GetPosition);
//         Last.SetPosition(Akt.GetPosition);

//         //Attached to method
//         if Attached then begin

//           Clear(CompFld);

//           CompFld[1] := Akt.Field(GetFieldNoByName(Akt.Number, AttTo));
//           CompFld[2] := Akt.Field(GetFieldNoByName(Akt.Number, Att));

//           FieldNoAttTo := CompFld[1].Number;
//           FieldNoAtt   := CompFld[2].Number;

//           //Fields OK?
//           if ISEmpty(CompFld[1].Value) and ISEmpty(CompFld[2].Value) then
//             Error(Text2000000009, CompFld[1].Caption, CompFld[2].Caption);

//           //Find first record (only if not already first record)
//           if ((CompFld[1].Value <> CompFld[2].Value) and not (ISEmpty(CompFld[2].Value))) then begin
//             Found := false;
//             repeat
//               if First.Next(-1) <> -1 then
//                 Found := true
//               else begin
//                 WorkFld := First.Field(FieldNoAttTo);
//                 if (WorkFld.Value = CompFld[2].Value) then
//                   Found := true;
//               end;
//             until Found;
//           end;

//           //Find last record with AttTo from first record
//           Clear(CompFld[3]);
//           CompFld[3] := First.Field(FieldNoAttTo);

//           Found := false;
//           repeat
//             if Last.Next <> 1 then
//               Found := true
//             else begin
//               WorkFld := Last.Field(FieldNoAtt);
//               if WorkFld.Value <> CompFld[3].Value then begin
//                 Last.Next(-1);
//                 Found := true;
//               end;
//             end;
//           until Found;

//         //Distinguish by method
//         end else begin

//           //Get Comparision values
//           Clear(CompFld);
//           Lauf := 0;
//           WorkDist := Dist;

//           repeat

//             //Get next field name
//             Pos := StrPos(WorkDist, ',');
//             if Pos > 0 then begin
//               WorkStr := CopyStr(WorkDist, 1, Pos - 1);
//               if StrLen(WorkDist) > Pos then
//                 WorkDist := CopyStr(WorkDist, Pos + 1)
//               else
//                 WorkDist := '';
//             end else begin
//               WorkStr := WorkDist;
//               WorkDist := '';
//             end;

//             if WorkStr <> '' then begin
//               Lauf := Lauf + 1;
//               CompFld[Lauf] := Akt.Field(GetFieldNoByName(Akt.Number, WorkStr));
//             end;
//           until WorkDist = '';

//           FieldCount := Lauf;

//           //Find first Record
//           Found := false;

//           repeat
//             if First.Next(-1) <> -1 then
//               Found := true
//             else begin
//               for Lauf := 1 to FieldCount do begin
//                 Clear(WorkFld);
//                 WorkFld := First.Field(CompFld[Lauf].Number);
//                 if WorkFld.Value <> CompFld[Lauf].Value then begin
//                   if (not ISEmpty(CompFld[Lauf].Value)) then
//                     First.Next;
//                   Found := true;
//                   Lauf := FieldCount;
//                 end;
//               end;
//             end;
//           until Found;

//           //Find last Record
//           Found := false;

//           repeat
//             if Last.Next <> 1 then
//               Found := true
//             else begin
//               for Lauf := 1 to FieldCount do begin
//                 Clear(WorkFld);
//                 WorkFld := Last.Field(CompFld[Lauf].Number);
//                 if ((WorkFld.Value <> CompFld[Lauf].Value) and not (ISEmpty(WorkFld.Value))) then begin
//                   if (not ISEmpty(WorkFld.Value)) then
//                     Last.Next(-1);
//                   Found := true;
//                   Lauf := FieldCount;
//                 end;
//               end;
//             end;
//           until Found;

//         end;
//     end;


//     procedure ReadText(First: RecordRef;Last: RecordRef;Work: RecordRef;TextField: Text[30])
//     var
//         CompFld: array [20] of FieldRef;
//         WorkFld: FieldRef;
//         PK: KeyRef;
//         Counter: Integer;
//         LastFound: Boolean;
//         TextValue: Text[1024];
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       12.05.2003
//         // Parameters: First            RecordRef on first Record to be edited
//         //             Last             RecordRef on last Record to be edited
//         //             TextField        Name of field to be edited
//         // Result:     None
//         // Purpose:    Transfer text to be edited to TextFIN DLL
//         // Annotation:


//         //Get Compare field numbers from Primary Key
//         PK := First.KeyIndex(1);
//         for Counter := 1 to PK.FieldCount do
//           CompFld[Counter] := Last.Field(PK.FieldIndex(Counter).Number);

//         //Compare Record to find last at set text
//         LastFound := false;

//         Work.SetPosition(First.GetPosition);
//         Work.Find;

//         repeat

//           for Counter := 1 to PK.FieldCount do begin
//             Clear(WorkFld);
//             WorkFld := Work.Field(CompFld[Counter].Number);
//             LastFound := true;
//         //2.00 B
//           if WorkFld.Value <> CompFld[Counter].Value then
//         //2.00 E
//               LastFound := false;
//           end;

//           WorkFld := Work.Field(GetFieldNoByName(Work.Number, TextField));
//           TextValue := WorkFld.Value;
//           TextFIN.AddLine(TextValue);
//           TextFIN.MaxLineLen := WorkFld.Length;

//           if Work.Next <> 1 then
//             LastFound := true;

//         until LastFound;
//     end;


//     procedure WriteText(First: RecordRef;Last: RecordRef;Work: RecordRef;TextField: Text[30];CopyAllFields: Boolean;CopyFields: Text[1024];AttachedToField: Text[30];AttachmentField: Text[30])
//     var
//         CompFld: array [20] of FieldRef;
//         CopyFld: array [1024] of FieldRef;
//         WorkFld: FieldRef;
//         WorkFld2: FieldRef;
//         PK: KeyRef;
//         Counter: Integer;
//         LineCount: Integer;
//         CopyFieldCounter: Integer;
//         CopyFieldPos: Integer;
//         LastFound: Boolean;
//         Following: Boolean;
//         TextValue: Text[1024];
//         WorkStr: Text[1024];
//         WorkInt: Integer;
//         WorkBigInt: BigInteger;
//         WorkDec: Decimal;
//         WorkGuid: Guid;
//         VarType: Option "Integer",BigInteger,Guid,Decimal;
//         LineOffsetInt: Integer;
//         LineOffsetBigInt: BigInteger;
//         LineOffsetDec: Decimal;
//     begin
//         // Project:    Continuous Text Editor for Microsoft Business Solutions Navision
//         // Author:     Roger Hamann, B.i.Team Softwareberatung GmbH
//         // Date:       12.05.2003
//         // Parameters: First            RecordRef on first Record to be edited
//         //             Last             RecordRef on last Record to be edited
//         //             TextField        Name of field to be edited
//         // Result:     None
//         // Purpose:    Transfer text from TextFIN DLL to table
//         // Annotation:


//         Last.Find;
//         First.Find;

//         //Get Compare field numbers from Primary Key
//         PK := First.KeyIndex(1);
//         for Counter := 1 to PK.FieldCount do
//           CompFld[Counter] := Last.Field(PK.FieldIndex(Counter).Number);

//         //Compare Record to find last at set text
//         LastFound := false;
//         Work.SetPosition(First.GetPosition);
//         Work.Find;

//         LineCount := 0;
//         Following := true;

//         // Write existing lines
//         repeat

//           LineCount := LineCount + 1;

//           for Counter := 1 to PK.FieldCount do begin
//             Clear(WorkFld);
//             WorkFld := Work.Field(CompFld[Counter].Number);
//             LastFound := true;
//             if WorkFld.Value <> CompFld[Counter].Value then
//               LastFound := false;
//           end;

//           if LineCount <= TextFIN.Lines then begin
//             WorkFld := Work.Field(GetFieldNoByName(Work.Number, TextField));
//             WorkFld.Value := TextFIN.GetLine(LineCount);
//             Work.Modify;
//           end else
//             if CheckLine(Work) then
//               Work.Delete
//             else begin
//               WorkFld := Work.Field(GetFieldNoByName(Work.Number, TextField));
//               WorkFld.Value := '';
//               Work.Modify;
//             end;

//           if Work.Next <> 1 then begin
//             LastFound := true;
//             Following := false;
//           end;

//         until LastFound;

//         //More lines
//         if LineCount < TextFIN.Lines then begin

//           //Calculate offset
//           case Format(CompFld[PK.FieldCount].Type) of

//             //Integer
//             Text2000000010:
//             if Following then begin
//               WorkFld := Work.Field(CompFld[PK.FieldCount].Number);
//               LineOffsetInt := WorkFld.Value;
//               WorkFld := Last.Field(CompFld[PK.FieldCount].Number);
//               WorkInt := WorkFld.Value;
//               LineOffsetInt := LineOffsetInt - WorkInt;
//               LineOffsetInt := ROUND(LineOffsetInt / ((TextFIN.Lines - LineCount) + 1), 1, '<');
//               VarType := Vartype::Integer;
//             end else
//               LineOffsetInt := 10000;

//             //BigInteger
//             Text2000000011:
//             if Following then begin
//               WorkFld := Work.Field(CompFld[PK.FieldCount].Number);
//               LineOffsetBigInt := WorkFld.Value;
//               WorkFld := Last.Field(CompFld[PK.FieldCount].Number);
//               WorkBigInt := WorkFld.Value;
//               LineOffsetBigInt := LineOffsetBigInt - WorkBigInt;
//               LineOffsetBigInt := ROUND(LineOffsetBigInt / ((TextFIN.Lines - LineCount) + 1), 1, '<');
//               VarType := Vartype::BigInteger;
//             end else
//               LineOffsetBigInt := 10000;

//             //Decimal
//             Text2000000012:
//             if Following then begin
//               WorkFld := Work.Field(CompFld[PK.FieldCount].Number);
//               LineOffsetDec := WorkFld.Value;
//               WorkFld := Last.Field(CompFld[PK.FieldCount].Number);
//               WorkDec := WorkFld.Value;
//               LineOffsetDec := LineOffsetDec - WorkDec;
//               LineOffsetDec := ROUND(LineOffsetDec / ((TextFIN.Lines - LineCount) + 1), 0.00001, '<');
//               VarType := Vartype::BigInteger;
//             end else
//               LineOffsetDec := 10000;

//             //Decimal
//             Text2000000013:
//               VarType := Vartype::Guid;

//             //Unknown
//             else
//               Error(Text2000000002);

//           end;

//           //Check Offset - Enough room?
//           case VarType of
//             Vartype::Integer:
//               if LineOffsetInt = 0 then Error(Text2000000014);
//             Vartype::BigInteger:
//               if LineOffsetBigInt = 0 then Error(Text2000000014);
//             Vartype::Decimal:
//               if LineOffsetDec = 0 then Error(Text2000000014);
//           end;

//           if Following then
//             Work.Next(-1);

//           if not CopyAllFields then begin
//             Clear(CopyFld);
//             if StrLen(TRIM(CopyFields)) > 0 then begin
//               CopyFieldCounter := 0;

//               repeat
//                 //Get next field name
//                 CopyFieldPos := StrPos(CopyFields, ',');
//                 if CopyFieldPos > 0 then begin
//                   WorkStr := CopyStr(CopyFields, 1, CopyFieldPos - 1);
//                   if StrLen(CopyFields) > CopyFieldPos then
//                     CopyFields := CopyStr(CopyFields, CopyFieldPos + 1)
//                   else
//                     CopyFields := '';
//                 end else begin
//                   WorkStr := CopyFields;
//                   CopyFields := '';
//                 end;

//                 CopyFieldCounter := CopyFieldCounter + 1;
//                 CopyFld[CopyFieldCounter] := First.Field(GetFieldNoByName(First.Number, WorkStr));

//               until StrLen(CopyFields) = 0;
//             end;
//           end;

//           //Insert lines
//           repeat
//             if not CopyAllFields then begin
//               Work.Init;
//               for WorkInt := 1 to CopyFieldCounter do begin
//                  WorkFld := Work.Field(CopyFld[WorkInt].Number);
//                  WorkFld.Value := CopyFld[WorkInt].Value;
//               end
//             end;

//             LineCount := LineCount + 1;
//             WorkFld := Work.Field(CompFld[PK.FieldCount].Number);

//             case VarType of
//               Vartype::Integer:
//                 begin
//                   WorkInt := WorkFld.Value;
//                   WorkFld.Value := WorkInt + LineOffsetInt;
//                 end;
//               Vartype::BigInteger:
//                 begin
//                   WorkBigInt := WorkFld.Value;
//                   WorkFld.Value := WorkBigInt + LineOffsetBigInt;
//                 end;
//               Vartype::Decimal:
//                 begin
//                   WorkDec := WorkFld.Value;
//                   WorkFld.Value := WorkDec + LineOffsetDec;
//                 end;
//               Vartype::Guid:
//                 WorkFld.Value := CreateGuid;
//             end;

//             WorkFld := Work.Field(GetFieldNoByName(Work.Number, TextField));
//             WorkFld.Value := TextFIN.GetLine(LineCount);

//             if StrLen(TRIM(AttachmentField)) > 0 then begin
//               WorkFld := Work.Field(GetFieldNoByName(Work.Number, AttachmentField));
//               WorkFld2 := First.Field(GetFieldNoByName(First.Number, AttachedToField));
//               WorkFld.Value := WorkFld2.Value;
//             end;

//             Work.Insert;

//           until LineCount >= TextFIN.Lines;

//         end;
//     end;


//     procedure CheckLine(RecRef: RecordRef) ResultOK: Boolean
//     var
//         L_FieldRef: FieldRef;
//         L_IntWert: Integer;
//     begin
//         ResultOK := true;

//         case RecRef.Name of
//           'Sales Line':                        //1. Zeile nicht löschen
//             begin
//               L_FieldRef := RecRef.Field(80);  //Attached to Line No.
//               Evaluate(L_IntWert, Format(L_FieldRef.Value()));
//               if L_IntWert = 0 then
//                  ResultOK := false;
//            end;
//           'Purchase Line':                     //1. Zeile nicht löschen
//             begin
//               L_FieldRef := RecRef.Field(80);  //Attached to Line No.
//               Evaluate(L_IntWert, Format(L_FieldRef.Value()));
//               if L_IntWert = 0 then
//                  ResultOK := false;
//            end;
//         end;
//     end;
// }

