Codeunit 50003 Mailfunktionen
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case rec."Parameter String" of
            'Lieferung':
                begin
                    MailSenden(120);
                end;
            'Verzug':
                begin
                    MailSenden(38);
                end;
            '2':
                begin
                    MailLieferanmahnung();
                end;
        end;
    end;

    procedure MailSenden(TableId_L: Integer)
    var
        MailTabelle: Record "Mail Tabelle";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchaseLine: Record "Purchase Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        L_PurchaseHeader: Record "Purchase Header";
        SMTP: Codeunit EMail;
        MailMsg: Codeunit "EMail Message";
        PosNr: Code[20];
        Recipient: Enum "Email Recipient Type";
        SendFlag: Boolean;
    begin
        SendFlag := false;
        Clear(MailTabelle);
        MailTabelle.SetRange(Sendedatum, CreateDatetime(0D, 0T));
        MailTabelle.SetRange(TableID, TableId_L);
        if MailTabelle.FindSet() then
            repeat
                if (TableId_L = 38) AND (MailTabelle.TableID = TableId_L) then begin
                    MailMsg.Create(
                            MailTabelle."Empfängermail",
                            MailTabelle.Betreff,
                            '',
                            true);
                    if MailTabelle."CC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Cc, MailTabelle."CC Mail");
                    if MailTabelle."BCC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Bcc, MailTabelle."CC Mail");
                    if MailTabelle.Body <> '' then
                        MailMsg.AppendToBody(MailTabelle.Body + '</br>');
                    PosNr := '';
                    Clear(PurchaseLine);
                    PurchaseLine.SetRange("Document Type", PurchaseLine."document type"::Order);
                    PurchaseLine.SetFilter("Document No.", MailTabelle.Key2);
                    PurchaseLine.SetFilter(Type, '%1 | %2', PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account");
                    PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
                    PurchaseLine.SetFilter("No.", '<> %1 | <> %2', '980000', '999900');
                    if PurchaseLine.FindSet then begin
                        /*
                        IF PurchaseLine."Promised Receipt Date" <> 0D THEN
                          SMTP.AppendBody(STRSUBSTNO('<b>Folgende Artikel aus Bestellung %1/%2 wurden am geplanten Lieferdatum %3 ' +
                                                     'nicht geliefert:</b></br></br>',
                                                     PurchaseLine."Job No.",MailTabelle.Key2,FORMAT(PurchaseLine."Promised Receipt Date")))
                        ELSE
                          SMTP.AppendBody(STRSUBSTNO('<b>Folgende Artikel aus Bestellung %1/%2 wurden am geplanten Lieferdatum %3 ' +
                                                     'nicht geliefert:</b></br></br>',
                                                     PurchaseLine."Job No.",MailTabelle.Key2,FORMAT(PurchaseLine."Planned Receipt Date")));
                        */
                        // G-ERP.AG 2021-05-11+ Anfrage# 2310747
                        L_PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                        if (PurchaseLine."Job No." = 'LV') and (L_PurchaseHeader."Job No." <> '') then
                            PurchaseLine."Job No." := L_PurchaseHeader."Job No.";
                        // G-ERP.AG 2021-05-11- Anfrage# 2310747
                        if PurchaseLine."Promised Receipt Date" <> 0D then
                            MailMsg.AppendToBody(StrSubstNo('<b>Bestellung %1/%2, Einkäufercode %3, geplantes Lieferdatum %4.</b></br>',
                                                       PurchaseLine."Job No.", MailTabelle.Key2,
                                                       L_PurchaseHeader."Purchaser Code", Format(PurchaseLine."Promised Receipt Date")))
                        else
                            MailMsg.AppendToBody(StrSubstNo('<b>Bestellung %1/%2, Einkäufercode %3, geplantes Lieferdatum %4.</b></br>',
                                                       PurchaseLine."Job No.", MailTabelle.Key2,
                                                       L_PurchaseHeader."Purchaser Code", Format(PurchaseLine."Planned Receipt Date")));
                        MailMsg.AppendToBody(StrSubstNo('<b>Folgende Artikel wurden nicht geliefert:</b></br></br>'));
                        MailMsg.AppendToBody('<style>* {font-family: "Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;}Table {font-family: Arial, Helvetica, sans-serif;background-color: #FFFFFF;border-collapse: collapse;width: 100%;table-layout: fixed;}Table td, Table th {  border-bottom: 1px solid #333;padding: 3px 12px;}Table th {  font-size: 15px;font-weight: bold;padding-top: 12px;padding-bottom: 12px;padding-left: 12px;text-align: left;background-color: #FFFFFF;}thead tr th:first-child, tbody tr td:first-child {max-width: 20px;pref-width: 20px;}</style>');
                        MailMsg.AppendToBody('<table><tr><th>Beschreibung</th><th>Restmenge</th><th>Einheit</th></tr>'); // 24.07.23 TT CN
                        repeat
                            if PurchaseLine.Pos <> PosNr then begin
                                if PurchaseLine.Pos <> '0' then
                                    // MailMsg.AppendToBody(StrSubstNo('<u>Pos %1</u></br>', PurchaseLine.Pos));
                                    MailMsg.AppendToBody(StrSubstNo('<tr><td><u>Pos %1</u></td><td></td><td></td></tr>', PurchaseLine.Pos)); // 24.07.23 TT CN
                                PosNr := PurchaseLine.Pos;
                            end;
                            // MailMsg.AppendToBody(StrSubstNo('%1 %2 %3 </br>', Format(PurchaseLine."Outstanding Quantity"),
                            //                            PurchaseLine."Unit of Measure", PurchaseLine.Description));
                            MailMsg.AppendToBody(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', PurchaseLine.Description, Format(PurchaseLine."Outstanding Quantity"), PurchaseLine."Unit of Measure")); // 24.07.23 TT CN
                        until PurchaseLine.Next = 0;
                        MailMsg.AppendToBody('</table>'); // 24.07.23 TT CN
                        SendFlag := true;
                    end;
                    if SendFlag then begin
                        SMTP.Send(MailMsg);
                    end;
                    MailTabelle.Sendedatum := CurrentDatetime;
                    MailTabelle.Modify;

                    Commit(); //G-ERP.RS 2021-09-10
                end;

                if (TableId_L = 120) AND (MailTabelle.TableID = TableId_L) then begin
                    MailMsg.Create(
                            MailTabelle."Empfängermail",
                            MailTabelle.Betreff,
                            '',
                            true);
                    if MailTabelle."CC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Cc, MailTabelle."CC Mail");
                    if MailTabelle."BCC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Bcc, MailTabelle."CC Mail");
                    if MailTabelle.Body <> '' then
                        MailMsg.AppendToBody(MailTabelle.Body + '</br>');
                    if PurchRcptHeader.Get(MailTabelle.Key1) then;
                    Clear(PurchRcptLine);
                    PurchRcptLine.SetFilter("Document No.", MailTabelle.Key1);
                    // G-ERP.AG 2020-09-07          PurchRcptLine.SETRANGE(Type,PurchRcptLine.Type::Item);
                    // PurchRcptLine.SetFilter(Type, '%1|%2', PurchRcptLine.Type::Item, PurchRcptLine.Type::"Charge (Item)");    // G-ERP.AG 2020-09-07
                    PurchRcptLine.SetFilter(Type, '%1|%2', PurchRcptLine.Type::Item, PurchRcptLine.Type::"G/L Account");    // TT CN 2023-07-23                                                                                         pe::"G/L Account");    // TT CN 2023-07-23
                    PurchRcptLine.SetFilter(Quantity, '<>%1', 0);
                    if PurchRcptLine.FindSet then begin
                        MailMsg.AppendToBody(StrSubstNo('<b>Folgende Artikel aus Bestellung %1/%2 wurden geliefert:</b></br></br>', PurchRcptLine."Job No.", PurchRcptHeader."Order No."));
                        MailMsg.AppendToBody('<style>* {font-family: "Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;}Table {font-family: Arial, Helvetica, sans-serif;background-color: #FFFFFF;border-collapse: collapse;width: 100%;table-layout: fixed;}Table td, Table th {  border-bottom: 1px solid #333;padding: 3px 12px;}Table th {  font-size: 15px;font-weight: bold;padding-top: 12px;padding-bottom: 12px;padding-left: 12px;text-align: left;background-color: #FFFFFF;}thead tr th:first-child, tbody tr td:first-child {max-width: 20px;pref-width: 20px;}</style>');
                        MailMsg.AppendToBody('<table><tr><th>Beschreibung</th><th>Menge</th><th>Einheit</th></tr>'); // 24.07.23 TT CN
                        repeat
                            if PurchRcptLine.Pos <> PosNr then begin
                                if PurchRcptLine.Pos <> '0' then
                                    // MailMsg.AppendToBody(StrSubstNo('<u>Pos %1</u></br>', PurchaseRcptLine.Pos));
                                    MailMsg.AppendToBody(StrSubstNo('<tr><td><u>Pos %1</u></td><td></td><td></td></tr>', PurchRcptLine.Pos)); // 24.07.23 TT CN
                                PosNr := PurchRcptLine.Pos;
                            end;
                            MailMsg.AppendToBody(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', PurchRcptLine.Description, Format(PurchRcptLine.Quantity), PurchRcptLine."Unit of Measure")); // 24.07.23 TT CN
                        until PurchRcptLine.Next = 0;
                        MailMsg.AppendToBody('</table>');// 24.07.23 TT CN
                        SendFlag := true;
                    end;
                    if PurchRcptHeader.Get(MailTabelle.Key1) then begin
                        PosNr := '';
                        Clear(PurchaseLine);
                        PurchaseLine.SetRange("Document Type", PurchaseLine."document type"::Order);
                        PurchaseLine.SetFilter("Document No.", PurchRcptHeader."Order No.");
                        // G-ERP.AG 2020-09-07            PurchaseLine.SETRANGE(Type,PurchaseLine.Type::Item);
                        // PurchRcptLine.SetFilter(Type, '%1|%2', PurchRcptLine.Type::Item, PurchRcptLine.Type::"Charge (Item)");    // G-ERP.AG 2020-09-07
                        PurchRcptLine.SetFilter(Type, '%1|%2', PurchRcptLine.Type::Item, PurchRcptLine.Type::"G/L Account");     // TT CN 2023-07-23
                        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);  // G-ERP.AG 2021-05-17  Anfrage# 2311352
                        PurchaseLine.SetFilter("No.", '<> %1 & <> %2', '980000', '999900');
                        PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
                        if PurchaseLine.FindSet then begin
                            MailMsg.AppendToBody(StrSubstNo('</br></br><b>Folgende Artikel aus Bestellung %1 wurden nicht geliefert:</b></br></br>', MailTabelle.Key1));
                            MailMsg.AppendToBody('<style>* {font-family: "Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;}Table {font-family: Arial, Helvetica, sans-serif;background-color: #FFFFFF;border-collapse: collapse;width: 100%;table-layout: fixed;}Table td, Table th {  border-bottom: 1px solid #333;padding: 3px 12px;}Table th {  font-size: 15px;font-weight: bold;padding-top: 12px;padding-bottom: 12px;padding-left: 12px;text-align: left;background-color: #FFFFFF;}thead tr th:first-child, tbody tr td:first-child {max-width: 20px;pref-width: 20px;}</style>');
                            MailMsg.AppendToBody('<table><tr><th>Beschreibung</th><th>Restmenge</th><th>Einheit</th></tr>'); // 24.07.23 TT CN
                            repeat
                                if PurchaseLine.Pos <> PosNr then begin
                                    if PurchaseLine.Pos <> '0' then
                                        // MailMsg.AppendToBody(StrSubstNo('<u>Pos %1</u></br>', PurchaseLine.Pos));
                                        MailMsg.AppendToBody(StrSubstNo('<tr><td><u>Pos %1</u></td><td></td><td></td></tr>', PurchaseLine.Pos)); // 24.07.23 TT CN
                                    PosNr := PurchaseLine.Pos;
                                end;
                                MailMsg.AppendToBody(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', PurchaseLine.Description, Format(PurchaseLine."Outstanding Quantity"), PurchaseLine."Unit of Measure")); // 24.07.23 TT CN
                            until PurchaseLine.Next = 0;
                            MailMsg.AppendToBody('</table>');
                            SendFlag := true;
                        end;
                    end;
                    if SendFlag then begin
                        SMTP.Send(MailMsg);
                    end;
                    MailTabelle.Sendedatum := CurrentDatetime;
                    MailTabelle.Modify;

                    Commit(); //G-ERP.RS 2021-09-10
                end;

                if NOT ((TableId_L = 38) OR (TableId_L = 120)) then begin
                    MailMsg.Create(
                            MailTabelle.Empfängermail,
                            MailTabelle.Betreff,
                            '',
                            true);
                    if MailTabelle.Body <> '' then
                        MailMsg.AppendToBody(MailTabelle.Body);
                    /*
                    IF MailTabelle.Body2 <> '' THEN
                      SMTP.AppendBody(MailTabelle.Body2);
                    IF MailTabelle.Body3 <> '' THEN
                      SMTP.AppendBody(MailTabelle.Body3);
                    IF MailTabelle.Body4 <> '' THEN
                      SMTP.AppendBody(MailTabelle.Body4);
                    IF MailTabelle.Body5 <> '' THEN
                      SMTP.AppendBody(MailTabelle.Body5);
                    */
                    if MailTabelle."CC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Cc, MailTabelle."CC Mail");
                    if MailTabelle."BCC Mail" <> '' then
                        MailMsg.SetRecipients(Recipient::Bcc, MailTabelle."CC Mail");
                    //         IF FILE.EXISTS(MailTabelle.Dateiname) THEN
                    //          SMTP.AddAttachment(MailTabelle.Dateiname);
                    SMTP.Send(MailMsg);
                    MailTabelle.Sendedatum := CurrentDatetime;
                    MailTabelle.Modify;
                    Commit(); //G-ERP.RS 2021-09-10
                end;
            until MailTabelle.Next = 0;
    end;


    procedure "MailErstellenEK-Lieferung"(PurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        MailTabelle: Record "Mail Tabelle";
        l_PurchaseLine: Record "Purchase Line";
        l_Resource: Record Resource;
        l_Job: Record Job;
        llfdnr: Integer;
    begin
        if PurchRcptHeader."No." = '' then
            exit;
        if PurchRcptHeader.Leistungsart <> PurchRcptHeader.Leistungsart::Fremdlieferung then
            exit;

        Clear(MailTabelle);
        if MailTabelle.FindLast then
            llfdnr := MailTabelle.Zeilennr
        else
            llfdnr := 0;
        Clear(MailTabelle);
        MailTabelle.Zeilennr := llfdnr + 1;
        MailTabelle.Erstellungsdatum := CurrentDatetime;
        MailTabelle.UserID := UserId;
        if PurchRcptHeader.Besteller <> '' then begin
            l_Resource.Get(PurchRcptHeader.Besteller);
            if l_Resource."E-Mail" <> '' then
                MailTabelle.Empfängermail := l_Resource."E-Mail";
        end;
        if l_Job.Get(PurchRcptHeader."Job No.") then begin
            if l_Job."Person Responsible" <> '' then begin
                l_Resource.Get(l_Job."Person Responsible");
                if l_Resource."E-Mail" <> '' then begin
                    if MailTabelle.Empfängermail = '' then
                        MailTabelle.Empfängermail := l_Resource."E-Mail"
                    else
                        MailTabelle."CC Mail" := l_Resource."E-Mail";
                end;
            end;
        end;

        if MailTabelle.Empfängermail = '' then
            MailTabelle.Empfängermail := 'purchasing@turbotechnik.com'
        else
            if MailTabelle."CC Mail" = '' then
                MailTabelle."CC Mail" := 'purchasing@turbotechnik.com'
            else
                MailTabelle."CC Mail" := MailTabelle."CC Mail" + ';purchasing@turbotechnik.com';
        MailTabelle.Absendermail := 'navision@turbotechnik.com';
        Clear(l_PurchaseLine);
        l_PurchaseLine.SetRange("Document Type", l_PurchaseLine."document type"::Order);
        l_PurchaseLine.SetRange("Document No.", PurchRcptHeader."Order No.");
        l_PurchaseLine.SetRange(Type, l_PurchaseLine.Type::Item);
        l_PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        l_PurchaseLine.SetFilter("No.", '<> %1 | <> %2', '980000', '999900');
        if l_PurchaseLine.FindFirst then
            //  MailTabelle.Betreff := STRSUBSTNO('TEILLIEFERUNG Bestellung %1/%2',PurchRcptHeader."Job No.",PurchRcptHeader."Order No.")
            MailTabelle.Betreff := StrSubstNo('%1 : TEILLIEFERUNG von %2 eingetroffen', PurchRcptHeader."Job No.",
                                            PurchRcptHeader."Buy-from Vendor Name")
        else
            //  MailTabelle.Betreff := STRSUBSTNO('GELIEFERT Bestellung %1/%2',PurchRcptHeader."Job No.",PurchRcptHeader."Order No.");
            MailTabelle.Betreff := StrSubstNo('%1 : LIEFERUNG von %2 eingetroffen', PurchRcptHeader."Job No.",
                                            PurchRcptHeader."Buy-from Vendor Name");
        MailTabelle.TableID := 120;
        MailTabelle.Key1 := PurchRcptHeader."No.";
        MailTabelle.Insert(true);
    end;


    procedure MailLieferanmahnung()
    var
        L_PurchaseHeader: Record "Purchase Header";
        L_PurchaseLine: Record "Purchase Line";
        l_Resource: Record Resource;
        l_Job: Record Job;
        MailTabelle: Record "Mail Tabelle";
        llfdnr: Integer;
    begin
        Clear(MailTabelle);
        if MailTabelle.FindLast then
            llfdnr := MailTabelle.Zeilennr
        else
            llfdnr := 0;
        Clear(MailTabelle);
        MailTabelle.UserID := UserId;
        //MailTabelle.Empfängermail := 'purchasing@turbotechnik.com';
        //MailTabelle."CC Mail" := 'andreas.gerwing@gerwing-erp.de';
        MailTabelle.Absendermail := 'navision@turbotechnik.com';
        Clear(L_PurchaseLine);
        L_PurchaseLine.SetRange("Document Type", L_PurchaseLine."document type"::Order);
        L_PurchaseLine.SetFilter(Type, '%1 | %2', L_PurchaseLine.Type::Item, L_PurchaseLine.Type::"G/L Account");
        L_PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        //L_PurchaseLine.SETFILTER("Promised Receipt Date",'%1..%2',20160101D,CALCDATE('<-1D>',TODAY));
        L_PurchaseLine.SetFilter("Promised Receipt Date", '%1..%2', 20160101D, Today);
        if L_PurchaseLine.FindSet then begin
            repeat
                L_PurchaseLine.SetRange("Document No.", L_PurchaseLine."Document No.");
                L_PurchaseLine.FindLast();
                L_PurchaseLine.SetRange("Document No.");
                L_PurchaseHeader.Get(L_PurchaseLine."Document Type", L_PurchaseLine."Document No.");
                if L_PurchaseHeader.Leistungsart = L_PurchaseHeader.Leistungsart::Fremdlieferung then begin
                    llfdnr += 1;
                    MailTabelle.Empfängermail := '';
                    MailTabelle."CC Mail" := '';
                    if L_PurchaseHeader.Besteller <> '' then begin
                        if (l_Resource.Get(L_PurchaseHeader.Besteller)) and (l_Resource."E-Mail" <> '') then
                            MailTabelle.Empfängermail := l_Resource."E-Mail";
                    end;
                    if l_Job.Get(L_PurchaseHeader."Job No.") then begin
                        if l_Job."Person Responsible" <> '' then begin
                            if (l_Resource.Get(l_Job."Person Responsible")) and (l_Resource."E-Mail" <> '') then begin
                                if MailTabelle.Empfängermail = '' then
                                    MailTabelle.Empfängermail := l_Resource."E-Mail"
                                else
                                    if (MailTabelle.Empfängermail <> l_Resource."E-Mail") then      //G-ERP.FL 2016-07-08
                                        MailTabelle."CC Mail" := l_Resource."E-Mail";
                            end;
                        end;
                    end;

                    if MailTabelle.Empfängermail = '' then
                        MailTabelle.Empfängermail := 'purchasing@turbotechnik.com'
                    else
                        if MailTabelle."CC Mail" = '' then
                            MailTabelle."CC Mail" := 'purchasing@turbotechnik.com'
                        else
                            MailTabelle."CC Mail" := MailTabelle."CC Mail" + ';purchasing@turbotechnik.com';

                    MailTabelle.Erstellungsdatum := CurrentDatetime;
                    MailTabelle.Zeilennr := llfdnr;
                    // G-ERP.AG 2021-05-10+ Anfrage# 2310747
                    if (L_PurchaseLine."Job No." = 'LV') and (L_PurchaseHeader."Job No." <> '') then
                        L_PurchaseLine."Job No." := L_PurchaseHeader."Job No.";
                    // G-ERP.AG 2021-05-10- Anfrage# 2310747
                    MailTabelle.Betreff := StrSubstNo('VERSPÄTET Bestellung %1/%2 von %3', L_PurchaseLine."Job No.",
                                                      L_PurchaseLine."Document No.", L_PurchaseHeader."Buy-from Vendor Name");
                    MailTabelle.TableID := 38;
                    MailTabelle.Key1 := 'Bestellung';
                    MailTabelle.Key2 := L_PurchaseLine."Document No.";
                    MailTabelle.Insert(true);
                end;
            until L_PurchaseLine.Next = 0;
        end;
        Clear(L_PurchaseLine);
        L_PurchaseLine.SetRange("Document Type", L_PurchaseLine."document type"::Order);
        L_PurchaseLine.SetRange(Type, L_PurchaseLine.Type::Item);
        L_PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        L_PurchaseLine.SetRange("Promised Receipt Date", 0D);
        l_PurchaseLine.SetFilter("No.", '<> %1 | <> %2', '980000', '999900');
        // G-ERP.AG 20181107 L_PurchaseLine.SETFILTER("Planned Receipt Date",'%1..%2',20160101D,CALCDATE('<-1D>',TODAY));
        L_PurchaseLine.SetFilter("Planned Receipt Date", '%1..%2', 20160101D, Today);                             // G-ERP.AG 20181107
        if L_PurchaseLine.FindSet then begin
            repeat
                L_PurchaseLine.SetRange("Document No.", L_PurchaseLine."Document No.");
                L_PurchaseLine.FindLast();
                L_PurchaseLine.SetRange("Document No.");
                L_PurchaseHeader.Get(L_PurchaseLine."Document Type", L_PurchaseLine."Document No.");
                if L_PurchaseHeader.Leistungsart = L_PurchaseHeader.Leistungsart::Fremdlieferung then begin
                    llfdnr += 1;
                    MailTabelle.Empfängermail := '';
                    MailTabelle."CC Mail" := '';
                    if L_PurchaseHeader.Besteller <> '' then begin
                        if (l_Resource.Get(L_PurchaseHeader.Besteller)) and (l_Resource."E-Mail" <> '') then
                            MailTabelle.Empfängermail := l_Resource."E-Mail";
                    end;
                    if l_Job.Get(L_PurchaseHeader."Job No.") then begin
                        if l_Job."Person Responsible" <> '' then begin
                            if (l_Resource.Get(l_Job."Person Responsible")) and (l_Resource."E-Mail" <> '') then begin
                                if MailTabelle.Empfängermail = '' then
                                    MailTabelle.Empfängermail := l_Resource."E-Mail"
                                else
                                    if (MailTabelle.Empfängermail <> l_Resource."E-Mail") then        //G-ERP.FL 2016-07-08
                                        MailTabelle."CC Mail" := l_Resource."E-Mail";
                            end;
                        end;
                    end;

                    if MailTabelle.Empfängermail = '' then
                        MailTabelle.Empfängermail := 'purchasing@turbotechnik.com'
                    else
                        if MailTabelle."CC Mail" = '' then
                            MailTabelle."CC Mail" := 'purchasing@turbotechnik.com'
                        else
                            MailTabelle."CC Mail" := MailTabelle."CC Mail" + ';purchasing@turbotechnik.com';
                    MailTabelle.Erstellungsdatum := CurrentDatetime;
                    MailTabelle.Zeilennr := llfdnr;
                    // G-ERP.AG 2021-05-10+ Anfrage# 2310747
                    if (L_PurchaseLine."Job No." = 'LV') and (L_PurchaseHeader."Job No." <> '') then
                        L_PurchaseLine."Job No." := L_PurchaseHeader."Job No.";
                    // G-ERP.AG 2021-05-10- Anfrage# 2310747

                    MailTabelle.Betreff := StrSubstNo('VERSPÄTET Bestellung %1/%2 von %3', L_PurchaseLine."Job No.",
                                                      L_PurchaseLine."Document No.", L_PurchaseHeader."Buy-from Vendor Name");
                    MailTabelle.TableID := 38;
                    MailTabelle.Key1 := 'Bestellung';
                    MailTabelle.Key2 := L_PurchaseLine."Document No.";
                    MailTabelle.Insert(true);
                end;
            until L_PurchaseLine.Next = 0;
        end;
    end;
}

