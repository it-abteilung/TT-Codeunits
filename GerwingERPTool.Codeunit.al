#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
Codeunit 50001 "Gerwing ERP Tool"
{
    // &personalization=88&bookmark=224;pwAAAACJ/zEyLTAwMw==&mode=Create


    trigger OnRun()
    begin
        //NotesCreate('TP12-002','Neues Projekt');
        DeleteDublicates;
    end;

    var
        TXT_NAVMapsNeeded: label 'Auf dieser Serviceschicht muss "NAVMaps.msi" installiert werden.';
        TXT_UpdateAllCustomers: label 'Möchten Sie wirklich für alle Debitoren die Breiten- und Längengradangaben aktualisieren?';
        TXT_GeoCodeErrors: label 'Für %1 Debitoren konnte kein geogr. Ccode bestimmt werden.';
        TXT_SetupDone: label 'Einrichtung der Demo für Virtual Earth abgeschlossen.';


    procedure NotesCreate(PJobNo: Code[20]; PText: Text[1024]; PNotes: Code[20])
    var
        JobRec: Record Job;
        RecRef: RecordRef;
        RecordLink: Record "Record Link";
        MultiTable: Record "Multi Table";
        OutStream1: OutStream;
        Text: Text[250];
        NewId: Integer;
        LenChar: Char;
    begin
        Text := PText;
        LenChar := StrLen(Text);

        Text := Format(LenChar) + Text;

        JobRec.Get(PJobNo);
        RecRef.Open(167);
        RecRef.GetTable(JobRec);
        //RecRef.SETPOSITION(JobRec.GETPOSITION);

        Clear(MultiTable);
        //MultiTable.SETRANGE(Primärschlüssel,PNotes); //G-ERP.KBS 2017-07-26
        MultiTable.SetRange(Kennzeichen, PNotes);
        MultiTable.SetFilter("User ID", '<>%1', '');
        if MultiTable.FindSet then
            repeat

                NewId := RecRef.AddLink('dynamicsnav://TT-nav1:7046/DynamicsNAV/Turbo Technik/runpage?page=88&' +
                                        'bookmark=' + Format(RecRef.RecordId, 0, 10) + '&mode=View',
                                        JobRec."No." + ' ' + JobRec.Description);

                RecordLink.Get(NewId);

                RecordLink.CalcFields(Note);
                RecordLink.Note.CreateOutstream(OutStream1);
                OutStream1.Write(Text);


                RecordLink.Type := RecordLink.Type::Note;
                RecordLink.Notify := true;
                RecordLink."To User ID" := MultiTable."User ID";

                RecordLink.Modify;
            until MultiTable.Next = 0;
    end;


    procedure EditInExcel(Name: Text[40]; View: Text[250]; PageID: Integer)
    begin
        /*//G-ERP.KBS 2017-07-26 +
        Name := DELCHR(Name, '=', ' ');
        Name := DELCHR(Name, '=', '.');
        //WebServiceHelper.RegisterWebService(TRUE, PageID, Name, TRUE);
        IF ISCLEAR(NAVEditInExcel) THEN
        BEGIN
          WHILE NOT CREATE(NAVEditInExcel, TRUE, TRUE) DO
          BEGIN
            IF NOT ComponentHelper.AskAndInstallCOMComponent('NAV Edit In Excel', 'NAVEditInExcelR2.msi') THEN
              EXIT;
          END;
        END;
        IF ComponentHelper.GetWebServiceURL(WebServiceURL) THEN
          NAVEditInExcel.EditInExcel(WebServiceURL.Projektnr, COMPANYNAME, Name, View)
        *///G-ERP.KBS 2017-07-26 -

    end;


    procedure GetCustomersWithin(latitude1: Decimal; latitude2: Decimal; longitude1: Decimal; longitude2: Decimal)
    var
        customers: Record Customer;
    begin
        /*//G-ERP.KBS 2017-07-26 +
        customers.SETRANGE(Latitude, latitude1, latitude2);
        customers.SETRANGE(Longitude, longitude1, longitude2);
        result.SETTABLEVIEW(customers);
        *///G-ERP.KBS 2017-07-26 -

    end;


    procedure GetDefaultCOMPANY(): Text[30]
    var
        UserPers: Record "User Personalization";
    begin
        /*//G-ERP.KBS 2017-07-26 +
        Session.SETRANGE("My Session",TRUE);
        Session.FINDFIRST;
        WindowsLogin.SETRANGE(ID,Session."User ID");
        WindowsLogin.FINDFIRST;
        UserPers.SETRANGE("User SID",WindowsLogin.SID);
        IF (UserPers.FINDFIRST) THEN
          EXIT(UserPers.Company);*///G-ERP.KBS 2017-07-26 -
        exit(COMPANYNAME);

    end;


    procedure UpdateLatitudeAndLongitude(var cust: Record Customer) error: Text[1024]
    var
        "query": Text[250];
        country: Record "Country/Region";
    begin
        /*//G-ERP.KBS 2017-07-26 +
        IF NOT CREATE(NavMaps, TRUE, FALSE) THEN
        BEGIN
          MESSAGE(TXT_NAVMapsNeeded);
          EXIT;
        END;
        IF cust."Country/Region Code" = '' THEN
          cust."Country/Region Code" := 'DE';
        IF country.GET(cust."Country/Region Code") THEN
        BEGIN
          query := cust.Address+', '+cust."Address 2"+', '+cust.City+', '+', '+cust."Post Code"+', '+country.Name;
          error := NavMaps.GetLocation(query, 2, cust.Latitude, cust.Longitude);
          IF (error = '') THEN
          BEGIN
            cust.MODIFY();
          END ELSE
          BEGIN
            query := cust.City + ', ' + country.Name;
            error := NavMaps.GetLocation(query, 0, cust.Latitude, cust.Longitude);
            IF (error = '') THEN
            BEGIN
              cust.MODIFY();
            END;
          END;
        END;
        *///G-ERP.KBS 2017-07-26 -

    end;


    procedure UpdateLatitudeAndLongitudeVend(var Vend: Record Vendor) error: Text[1024]
    var
        "query": Text[250];
        country: Record "Country/Region";
    begin
        /*//G-ERP.KBS 2017-07-26 +
        IF NOT CREATE(NavMaps, TRUE, FALSE) THEN
        BEGIN
          MESSAGE(TXT_NAVMapsNeeded);
          EXIT;
        END;
        IF Vend."Country/Region Code" = '' THEN
          Vend."Country/Region Code" := 'DE';
        IF country.GET(Vend."Country/Region Code") THEN
        BEGIN
          query := Vend.Address+', '+Vend."Address 2"+', '+Vend.City+', '+', '+Vend."Post Code"+', '+country.Name;
          error := NavMaps.GetLocation(query, 2, Vend.Latitude, Vend.Longitude);
          IF (error = '') THEN
          BEGIN
            Vend.MODIFY();
          END ELSE
          BEGIN
            query := Vend.City + ', ' + country.Name;
            error := NavMaps.GetLocation(query, 0, Vend.Latitude, Vend.Longitude);
            IF (error = '') THEN
            BEGIN
              Vend.MODIFY();
            END;
          END;
        END;
        *///G-ERP.KBS 2017-07-26 -

    end;


    procedure OpenCustomerMAPInBrowser(customer: Record Customer)
    begin
        /*//G-ERP.KBS 2017-07-26 +
        IF ComponentHelper.GetWebServiceURL(WebServiceURL) THEN
          IF WebServiceURL.Unterprojektnr <> '' THEN
            HYPERLINK(WebServiceURL.Unterprojektnr + 'MAP/Default.htm?baseURL='+ComponentHelper.EscapeDataString(WebServiceURL.Projektnr)+
                      '&company='+ComponentHelper.EscapeDataString(COMPANYNAME)+
                      '&latitude='+FORMAT(customer.Latitude,0,9)+
                      '&longitude='+FORMAT(customer.Longitude,0,9)+
                      '&zoom=10');
        *///G-ERP.KBS 2017-07-26 -

    end;


    procedure OpenVendorMAPInBrowser(Vendor: Record Vendor)
    begin
        /*//G-ERP.KBS 2017-07-26 +
        IF ComponentHelper.GetWebServiceURL(WebServiceURL) THEN
          IF WebServiceURL.Unterprojektnr <> '' THEN
            HYPERLINK(WebServiceURL.Unterprojektnr + 'MAP/Default.htm?baseURL='+ComponentHelper.EscapeDataString(WebServiceURL.Projektnr)+
                      '&company='+ComponentHelper.EscapeDataString(COMPANYNAME)+
                      '&latitude='+FORMAT(Vendor.Latitude,0,9)+
                      '&longitude='+FORMAT(Vendor.Longitude,0,9)+
                      '&zoom=10');
        *///G-ERP.KBS 2017-07-26 -

    end;


    // procedure DownloadToClientFileName(ServerFileName: Text[250];ToFile: Text[250]): Text[250]
    // var
    //     ClientFileName: Text[250];
    //     objScript: Automation ScriptControl;
    //     CR: Text[1];
    // begin


    //     ClientFileName := ToFile;
    //     if not Download(ServerFileName, '', '<TEMP>','', ClientFileName) then
    //       exit('');
    //     if Create(objScript,true,true) then
    //     begin
    //       CR := ' '; CR[1] := 13;
    //       objScript.Language := 'VBScript';
    //       objScript.AddCode(
    //       'function RenameTempFile(fromFile, toFile)'+CR+
    //       'set fso = createobject("Scripting.FileSystemObject")'+CR+
    //       'set x = createobject("Scriptlet.TypeLib")'+CR+
    //       'path = fso.getparentfoldername(fromFile)'+CR+
    //       'toPath = path+"\"+left(x.GUID,38)'+CR+
    //       'fso.CreateFolder toPath'+CR+
    //       'fso.MoveFile fromFile, toPath+"\"+toFile'+CR+
    //       'RenameTempFile = toPath'+CR+
    //       'end function');
    //       ClientFileName := objScript.Eval('RenameTempFile("'+ClientFileName+'","'+ToFile+'")');
    //       ClientFileName := ClientFileName+'\'+ToFile;
    //     end;
    //     exit(ClientFileName);
    // end;


    // procedure DoSearch(searchstring: Text[40];var result: BigText)
    // var
    //     rec: RecordRef;
    //     "field": FieldRef;
    //     XMLDoc: Automation ;
    //     TopNode: Automation ;
    //     TableNode: Automation ;
    //     MatchNode: Automation ;
    //     ValueNode: Automation ;
    //     TableAttribute: Automation ;
    //     MatchAttribute: Automation ;
    //     ValueTextNode: Automation ;
    //     currentTable: Text[40];
    // begin
    /*//G-ERP.KBS 2017-07-26 +
    CLEAR(result);
    results.DELETEALL;
    IF searchtable.FIND('-') THEN
    BEGIN
      REPEAT
        rec.OPEN(searchtable.Code);
        searchfield.SETRANGE(searchfield."PC-Code", searchtable.Code);
        IF searchfield.FIND('-') THEN
        BEGIN
          REPEAT
            rec.RESET();
            field := rec.FIELD(searchfield.Kostenträger);
            field.SETFILTER('@*' + searchstring + '*');
            IF rec.FIND('-') THEN
            BEGIN
              REPEAT
                results.SETRANGE(results.S1, FORMAT(rec.RECORDID,0,10));
                IF NOT results.FIND('-') THEN
                BEGIN
                  results.INIT();
                  results.S1 := FORMAT(rec.RECORDID,0,10);
                  results.A1 := rec.FIELD(searchtable."Id Field No").VALUE;
                  results.S2 := rec.FIELD(searchtable."Name Field No").VALUE;
                  results.A2 := searchtable.Zeilennummer;
                  results.Position := rec.CAPTION;
                  results.INSERT();
                END;
              UNTIL rec.NEXT = 0;
            END;
            field.SETFILTER('');
          UNTIL searchfield.NEXT =0;
        END;
        rec.CLOSE;
        searchfield.SETRANGE(searchfield."PC-Code");
      UNTIL searchtable.NEXT = 0;
    END;

    results.RESET;
    results.SETCURRENTKEY(results.Position, results.A1);
    IF results.FIND('-') THEN
    BEGIN
      CREATE(XMLDoc, FALSE, FALSE);
      XMLDoc.async(FALSE);
      TopNode := XMLDoc.createNode(1,'SEARCHRESULT','');
      XMLDoc.appendChild(TopNode);
      currentTable := '';
      REPEAT
        IF results.Position <> currentTable THEN
        BEGIN
          currentTable := results.Position;
          TableNode := XMLDoc.createNode(1,'TABLE','');
          TableAttribute := XMLDoc.createAttribute('NAME');
          TableAttribute.value := currentTable;
          TableNode.attributes.setNamedItem(TableAttribute);
          TopNode.appendChild(TableNode);
        END;
        MatchNode := XMLDoc.createNode(1,'MATCH','');
        MatchAttribute := XMLDoc.createAttribute('PAGE');
        MatchAttribute.value := results.A2;
        MatchNode.attributes.setNamedItem(MatchAttribute);
        ValueNode := XMLDoc.createNode(1,'BOOKMARK','');
        ValueTextNode := XMLDoc.createTextNode(results.S1);
        ValueNode.appendChild(ValueTextNode);
        MatchNode.appendChild(ValueNode);
        ValueNode := XMLDoc.createNode(1,'ID','');
        ValueTextNode := XMLDoc.createTextNode(results.A1);
        ValueNode.appendChild(ValueTextNode);
        MatchNode.appendChild(ValueNode);
        ValueNode := XMLDoc.createNode(1,'NAME','');
        ValueTextNode := XMLDoc.createTextNode(results.S2);
        ValueNode.appendChild(ValueTextNode);
        MatchNode.appendChild(ValueNode);
        TableNode.appendChild(MatchNode);
      UNTIL results.NEXT = 0;
      result.ADDTEXT(XMLDoc.xml);
    END;
    *///G-ERP.KBS 2017-07-26 -

    // end;


    procedure DruckerTabelleFuellen(PBerichtID: Integer; PTableID: Integer; PRecordKey1: Code[20]; PRecordKey2: Code[20]; PRecordKey3: Code[20]; PRecordKey4: Code[20]; PRecordKey5: Code[20]; pDruckerVorgabe: Code[50]; pAnzahlAusdrucke: Integer)
    var
        BerichteDrucker: Record "Berichte Drucker";
        PrinterSelection: Record "Printer Selection";
        JobQueueEntry: Record "Job Queue Entry";
        pause: Integer;
    begin
        BerichteDrucker.ReportID := PBerichtID;
        BerichteDrucker.TableID := PTableID;
        BerichteDrucker.RecordKey1 := PRecordKey1;
        BerichteDrucker.RecordKey2 := PRecordKey2;
        BerichteDrucker.RecordKey3 := PRecordKey3;
        BerichteDrucker.RecordKey4 := PRecordKey4;
        BerichteDrucker.RecordKey5 := PRecordKey5;
        BerichteDrucker."Auftrag Datum" := CurrentDatetime();
        BerichteDrucker."Auftrag UserId" := UserId;
        BerichteDrucker.Anzahl := pAnzahlAusdrucke;

        if pDruckerVorgabe = '' then begin
            if PrinterSelection.Get(UserId, PBerichtID) then begin
                BerichteDrucker.Druckername := PrinterSelection."Printer Name";
                BerichteDrucker.Erledigt := false;
                if not BerichteDrucker.Insert then
                    BerichteDrucker.Modify;
            end
            else begin
                Error('Kein Drucker für den Benutzer ' + UserId + ' hinterlegt.');
            end;
        end
        else begin
            BerichteDrucker.Druckername := pDruckerVorgabe;
            BerichteDrucker.Erledigt := false;
            if not BerichteDrucker.Insert then
                BerichteDrucker.Modify;
        end;

        pause := 60000;
        pause := 5000;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."object type to run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", 50004);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        if JobQueueEntry.FindSet then begin
            JobQueueEntry.Validate("Earliest Start Date/Time", CurrentDatetime() + pause);
            JobQueueEntry.Modify;
        end;
    end;


    procedure Scanergebnis(P_Scan: Text): Text
    var
        L_Artikel: Record Item;
        Artikelnr: Code[20];
    begin
        Artikelnr := '';

        if P_Scan <> '' then begin
            Artikelnr := CopyStr(P_Scan, 1, 6);
            L_Artikel.Get(Artikelnr);
        end;

        exit(Artikelnr);
    end;


    procedure ArtikelErgebnis(P_Artikelnr: Code[20]): Text
    var
        L_Artikel: Record Item;
        Artikelnr: Code[20];
    begin
        Artikelnr := '';

        if P_Artikelnr <> '' then begin
            Artikelnr := P_Artikelnr;
            L_Artikel.Get(Artikelnr);
        end;

        exit(Artikelnr);
    end;


    procedure ArtikelBeschreibung(P_Artikelnr: Code[20]): Text
    var
        L_Artikel: Record Item;
        ArtikelBeschr: Text;
    begin
        ArtikelBeschr := '';

        if P_Artikelnr <> '' then begin
            L_Artikel.Get(P_Artikelnr);
            ArtikelBeschr := L_Artikel.Description;
        end;

        exit(ArtikelBeschr);
    end;


    procedure ArtikelSeriennr(P_Scan: Text): Text
    var
        Seriennr: Text;
    begin
        Seriennr := '';

        if P_Scan <> '' then
            if CopyStr(P_Scan, 7) <> '' then
                Seriennr := CopyStr(P_Scan, 7);

        exit(Seriennr);
    end;


    procedure ArtikelEinheit(P_Artikelnr: Code[20]; P_i: Integer): Text
    var
        L_Artikel: Record Item;
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        Einheit: Code[10];
        i: Integer;
    begin
        Einheit := '';
        if P_Artikelnr <> '' then begin
            L_Artikel.Get(P_Artikelnr);
            Clear(L_ItemUnitofMeasure);
            if P_i = 1 then begin
                Einheit := L_Artikel."Base Unit of Measure";
            end
            else begin
                i := 1;
                L_ItemUnitofMeasure.SetRange("Item No.", P_Artikelnr);
                L_ItemUnitofMeasure.SetFilter(Code, '<>%1', L_Artikel."Base Unit of Measure");
                if L_ItemUnitofMeasure.FindSet then
                    repeat
                        i += 1;
                        if i = P_i then
                            Einheit := L_ItemUnitofMeasure.Code;
                    until L_ItemUnitofMeasure.Next = 0;
            end;
        end;

        exit(Einheit);
    end;


    procedure ArtikelSerienrPflichtig(P_ItemNo: Code[20]): Boolean
    var
        L_Item: Record Item;
    begin
        L_Item.Get(P_ItemNo);
        exit(L_Item."Seriennr. pflichtig");
    end;


    procedure ArtikelInventurBuchung(P_ItemNo: Code[20]; P_Serienr: Code[20]; P_Menge: Decimal; P_Einheit: Code[20]): Boolean
    var
        AusstattungPosten: Record Ausstattung_Posten;
        AusstattungPosten2: Record Ausstattung_Posten;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine: Record "Item Journal Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
        LfdNrBuchen: Integer;
        LineNo: Integer;
    begin
        if (P_ItemNo = '') or (P_Menge = 0) then
            exit(false);
        if (P_Serienr <> '') and (P_Menge <> 1) then
            Error('Menge darf bei Eingabe Seriennr. nur 1 sein!');
        L_Item.Get(P_ItemNo);
        if (L_Item."Seriennr. pflichtig") and (P_Serienr = '') then
            Error('Artikel ist Serienrpflichtig!');

        if (P_Serienr = '') and (P_Einheit <> '') then begin
            ItemUnitofMeasure.Get(P_ItemNo, P_Einheit);
            P_Menge := ROUND((P_Menge / ItemUnitofMeasure."Qty. per Unit of Measure"), 0.0001);
        end;

        if P_Serienr <> '' then begin
            Clear(AusstattungPosten2);
            AusstattungPosten2.SetRange("Artikel Nr", P_ItemNo);
            AusstattungPosten2.SetRange(Seriennummer, P_Serienr);
            AusstattungPosten2.SetRange(Offen, true);
            if AusstattungPosten2.FindFirst then begin
                Clear(AusstattungPosten);
                if AusstattungPosten.FindLast then
                    LfdNrBuchen := AusstattungPosten."Lfd Nr"
                else
                    LfdNrBuchen := 0;
                LfdNrBuchen += 1;
                Clear(AusstattungPosten);
                AusstattungPosten := AusstattungPosten2;
                AusstattungPosten."Lfd Nr" := LfdNrBuchen;
                AusstattungPosten.Offen := false;
                AusstattungPosten.Postenart := 'RÜCKGABE';
                AusstattungPosten.Menge := -AusstattungPosten2.Menge;
                AusstattungPosten.Restmenge := 0;
                AusstattungPosten.Buchungsdatum := CurrentDatetime;
                AusstattungPosten.Insert;
            end;
        end;


        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", 'ARTIKEL');
        ItemJournalLine.SetRange("Journal Batch Name", 'Inv');
        if ItemJournalLine.FindLast then
            LineNo := ItemJournalLine."Line No.";
        LineNo += 10000;
        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Item No.", P_ItemNo);
        ItemLedgerEntry.SetRange("Serial No.", P_Serienr);
        ItemLedgerEntry.SetRange(Open, true);
        if ItemLedgerEntry.FindSet then begin
            repeat
                Clear(ItemJournalLine);
                ItemJournalLine."Journal Template Name" := 'ARTIKEL';
                ItemJournalLine."Journal Batch Name" := 'Inv';
                ItemJournalLine.Validate("Line No.", LineNo);
                ItemJournalLine.Validate("Posting Date", Today);
                ItemJournalLine.Validate("Entry Type", ItemJournalLine."entry type"::"Negative Adjmt.");
                if ItemLedgerEntry."Location Code" = 'WHV' then
                    ItemJournalLine.Validate("Document No.", ItemLedgerEntry."Location Code")
                else
                    ItemJournalLine.Validate("Document No.", ItemLedgerEntry."Document No.");
                ItemJournalLine.Validate("Item No.", P_ItemNo);
                ItemJournalLine.Validate("Location Code", ItemLedgerEntry."Location Code");
                ItemJournalLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                if P_Serienr <> '' then
                    ItemJournalLine.Validate("Serial No.", P_Serienr);
                ItemJournalLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                ItemJournalLine.Insert(true);
                LineNo += 10000;
            until ItemLedgerEntry.Next = 0;
        end;
        Clear(ItemJournalLine);
        ItemJournalLine."Journal Template Name" := 'ARTIKEL';
        ItemJournalLine."Journal Batch Name" := 'Inv';
        ItemJournalLine.Validate("Line No.", LineNo);
        ItemJournalLine.Validate("Posting Date", Today);
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."entry type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", 'Inventur');
        ItemJournalLine.Validate("Item No.", P_ItemNo);
        ItemJournalLine.Validate("Location Code", 'WHV');
        ItemJournalLine.Validate(Quantity, P_Menge);
        if P_Serienr <> '' then
            ItemJournalLine.Validate("Serial No.", P_Serienr);
        ItemJournalLine.Insert(true);
        //CODEUNIT.RUN(23,ItemJournalLine);                     // G-ERP.AG 20181107

        exit(true);
    end;


    procedure ArtikelZugangBuchen(P_ItemNo: Code[20]; P_Serienr: Code[20]; P_Menge: Decimal; P_Einheit: Code[20]): Boolean
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
        LineNo: Integer;
    begin
        if (P_ItemNo = '') or (P_Menge = 0) then
            exit(false);
        if (P_Serienr <> '') and (P_Menge <> 1) then
            Error('Menge darf bei Eingabe Seriennr. nur 1 sein!');
        L_Item.Get(P_ItemNo);
        if (L_Item."Seriennr. pflichtig") and (P_Serienr = '') then
            Error('Artikel ist Serienrpflichtig!');

        if (P_Serienr = '') and (P_Einheit <> '') then begin
            ItemUnitofMeasure.Get(P_ItemNo, P_Einheit);
            P_Menge := P_Menge * ItemUnitofMeasure."Qty. per Unit of Measure";
        end;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", 'ARTIKEL');
        ItemJournalLine.SetRange("Journal Batch Name", 'Inv');
        if ItemJournalLine.FindLast then
            LineNo := ItemJournalLine."Line No.";
        LineNo += 10000;

        Clear(ItemJournalLine);
        ItemJournalLine."Journal Template Name" := 'ARTIKEL';
        ItemJournalLine."Journal Batch Name" := 'Inv';
        ItemJournalLine.Validate("Line No.", LineNo);
        ItemJournalLine.Validate("Posting Date", Today);
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."entry type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", 'Zugang');
        ItemJournalLine.Validate("Item No.", P_ItemNo);
        ItemJournalLine.Validate("Location Code", 'WHV');
        ItemJournalLine.Validate(Quantity, P_Menge);
        if P_Serienr <> '' then
            ItemJournalLine.Validate("Serial No.", P_Serienr);
        ItemJournalLine.Insert(true);
        //CODEUNIT.RUN(23,ItemJournalLine);                     // G-ERP.AG 20181107

        exit(true);
    end;

    local procedure DeleteDublicates()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Window: Dialog;
        Factor: Decimal;
        Counter: Decimal;
        DoDelete: Boolean;
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
    begin
        if Confirm('Sollen Dublikate gelöscht werden?') then begin

            Window.Open(
              '#1############################\\' +
              'Dublikate löschen #2###### @3@@@@@@@@@');

            Window.Update(1, 'Dublikate werden gelöscht.');

            DoDelete := false;
            PurchInvHeader.SetCurrentkey("Vendor Invoice No.", "Posting Date");
            if PurchInvHeader.Count > 0 then
                Factor := 9999 / PurchInvHeader.Count;
            if PurchInvHeader.FindSet then
                repeat
                    PurchInvHeader.CalcFields(Amount);
                    Counter += 1;
                    Window.Update(2, PurchInvHeader."No.");
                    Window.Update(3, (Counter * Factor) DIV 1);
                    PurchaseHeader.SetRange("Vendor Invoice No.", PurchInvHeader."Vendor Invoice No.");
                    if PurchaseHeader.FindFirst then begin
                        PurchaseHeader.CalcFields(Amount);
                        if PurchaseHeader."Buy-from Vendor No." = PurchInvHeader."Buy-from Vendor No." then
                            if PurchaseHeader.Amount = PurchInvHeader.Amount then begin
                                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                                DoDelete := true;
                                if PurchaseLine.FindSet then
                                    repeat
                                        if PurchaseLine."Qty. Rcd. Not Invoiced" <> 0 then
                                            DoDelete := false;
                                        if WhseValidateSourceLine.WhseLinesExist(Database::"Purchase Line",
                                             PurchaseLine."Document Type",
                                             PurchaseLine."Document No.",
                                             PurchaseLine."Line No.",
                                             0,
                                             PurchaseLine.Quantity) then
                                            DoDelete := false;
                                    until PurchaseLine.Next = 0;
                                if DoDelete then begin
                                    PurchaseHeader."Posting No." := '';
                                    PurchaseHeader.Delete(true);
                                end;
                            end;
                    end;
                until PurchInvHeader.Next = 0;

            Window.Close;
        end;
    end;
}

