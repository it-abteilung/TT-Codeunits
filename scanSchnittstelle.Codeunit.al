// #pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
// Codeunit 50002 scanSchnittstelle
// {

//     trigger OnRun()
//     begin
//         AuslesenMitarbeiter();
//         AuslesenArtikelSeriennr();
//     end;


//     procedure WarenAusgZeileAnlegen(p_Projekt: Code[20];p_Baugruppe: Code[20];p_Artikel: Code[20];p_Menge: Decimal): Code[10]
//     var
//         ProjektRec: Record Job;
//         ProjektZeile: Record "Job Journal Line";
//         Item: Record Item;
//         Zeilennr: Integer;
//     begin
//         //'020001' - 'Projekt nicht gefunden!'
//         //'020002' - 'Artikel nicht gefunden!'
//         //'020003' - 'Menge muss positiv sein.'

//         if (StrLen(p_Projekt) = 6) then
//           p_Projekt := CopyStr(p_Projekt, 1,2) + '-' + CopyStr(p_Projekt, 3);

//         if p_Menge <1 then
//           exit('020003');

//         if ProjektRec.Get(p_Projekt) then begin
//           if not Item.Get(p_Artikel) then
//             exit('020002');
//           Clear(ProjektZeile);
//           ProjektZeile.SetRange("Journal Template Name",'Projekt');
//           ProjektZeile.SetRange("Journal Batch Name",'SCANNER');
//           if ProjektZeile.FindLast then
//             Zeilennr := ProjektZeile."Line No.";
//           Clear(ProjektZeile);
//           Zeilennr += 10000;
//           ProjektZeile.Validate("Journal Template Name",'Projekt');
//           ProjektZeile.Validate("Journal Batch Name",'Scanner');
//           ProjektZeile.Validate("Line No.",Zeilennr);
//           ProjektZeile.Validate("Posting Date",Today);
//           ProjektZeile.Validate("Document No.",'SCANNER');
//           ProjektZeile.Validate("Job No.",p_Projekt);
//           ProjektZeile.Validate(Type,ProjektZeile.Type::Item);
//           ProjektZeile.Validate("No.",p_Artikel);
//           ProjektZeile.Validate(Quantity,p_Menge);
//           ProjektZeile.Insert;
//           exit('');
//         end
//         else begin
//           exit('020001');
//         end;
//     end;


//     procedure WarenAusgZeileStornoAnlegen(p_Projekt: Code[20];p_Baugruppe: Code[20];p_Artikel: Code[20];p_Menge: Decimal): Code[10]
//     var
//         ProjektRec: Record Job;
//         ProjektZeile: Record "Job Journal Line";
//         Item: Record Item;
//         Zeilennr: Integer;
//     begin
//         //'020001' - 'Projekt nicht gefunden!'
//         //'020002' - 'Artikel nicht gefunden!'
//         //'020003' - 'Menge muss positiv sein.'

//         if (StrLen(p_Projekt) = 6) then
//           p_Projekt := CopyStr(p_Projekt, 1,2) + '-' + CopyStr(p_Projekt, 3);

//         if p_Menge <1 then
//           exit('020003');

//         if ProjektRec.Get(p_Projekt) then begin
//           if not Item.Get(p_Artikel) then
//             exit('020002');
//           Clear(ProjektZeile);
//           ProjektZeile.SetRange("Journal Template Name",'Projekt');
//           ProjektZeile.SetRange("Journal Batch Name",'SCANNER');
//           if ProjektZeile.FindLast then
//             Zeilennr := ProjektZeile."Line No.";
//           Clear(ProjektZeile);
//           Zeilennr += 10000;
//           ProjektZeile.Validate("Journal Template Name",'Projekt');
//           ProjektZeile.Validate("Journal Batch Name",'Scanner');
//           ProjektZeile.Validate("Line No.",Zeilennr);
//           ProjektZeile.Validate("Posting Date",Today);
//           ProjektZeile.Validate("Document No.",'SCANNER');
//           ProjektZeile.Validate("Job No.",p_Projekt);
//           ProjektZeile.Validate(Type,ProjektZeile.Type::Item);
//           ProjektZeile.Validate("No.",p_Artikel);
//           ProjektZeile.Validate(Quantity,-p_Menge);
//           ProjektZeile.Insert;
//           exit('');
//         end
//         else
//           exit('020001');
//     end;


//     procedure WarenAusgBuchen(): Code[10]
//     var
//         ProjektZeile: Record "Job Journal Line";
//         JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
//     begin
//         Clear(ProjektZeile);
//         ProjektZeile.SetRange("Journal Template Name",'Projekt');
//         ProjektZeile.SetRange("Journal Batch Name",'SCANNER');
//         if ProjektZeile.FindSet then
//           repeat
//             JobJnlPostLine.Run(ProjektZeile);
//             ProjektZeile.Delete;
//           until ProjektZeile.Next = 0;
//         exit('');
//     end;


//     procedure GeplanterWareneingangOeffnen(p_BestellNr: Code[20]): Code[10]
//     var
//         PurchaseHeader: Record "Purchase Header";
//         PurchaseLine: Record "Purchase Line";
//     begin
//         //'020001' - 'Bestellung nicht gefunden!'

//         if PurchaseHeader.Get(PurchaseHeader."document type"::Order, p_BestellNr) then begin
//           Clear(PurchaseLine);
//           PurchaseLine.SetRange("Document Type",PurchaseHeader."Document Type");
//           PurchaseLine.SetRange("Document No.",PurchaseHeader."No.");
//           PurchaseLine.SetRange(Type,PurchaseLine.Type::Item);
//           if PurchaseLine.FindSet then
//             repeat
//               PurchaseLine.Validate("Qty. to Receive",0);
//               PurchaseLine.Modify;
//             until PurchaseLine.Next = 0;
//           exit('');
//         end
//         else
//           exit('020001');
//     end;


//     procedure GeplanterWareneingang(p_BestellNr: Code[20];p_Barcode: Code[50];p_Menge: Decimal): Code[10]
//     var
//         PurchaseHeader: Record "Purchase Header";
//         PurchaseLine: Record "Purchase Line";
//         Item: Record Item;
//         ItemVariant: Record "Item Variant";
//         LineNo: Integer;
//         EntryNo: Integer;
//         ArtikelNr: Code[20];
//         ArtikelVar: Code[10];
//     begin
//         //Satzart:      WEE
//         //Bezeichnung:  Geplanter Wareneingang mit Bezug zu einer Bestellposition auf Palettenbasis
//         //Beschreibung: Satz wird gesendet, wenn im Lager Ware zugebucht wird, welche als geplanter Wareneingang
//         //              mit einer Bestellposition vereinnahmt wird.

//         //'020001' - 'Artikel nicht gefunden!'
//         //'020004' - 'Artikel stimmt nicht mit Bestellposition überein.';
//         //'020006' - 'Bestellposition nicht gefunden.';
//         //'020007' - 'Bestellung nicht gefunden!';
//         //'020008' - 'Artikel ist gesperrt!';

//         if StrPos(p_Barcode,'.') = 0 then
//           exit('020006');

//         Evaluate(LineNo,CopyStr(p_Barcode,1,StrPos(p_Barcode,'.')-1));
//         ArtikelNr := CopyStr(p_Barcode,StrPos(p_Barcode,'.')+1);

//         if PurchaseHeader.Get(PurchaseHeader."document type"::Order, p_BestellNr) then begin
//           if PurchaseLine.Get(PurchaseLine."document type"::Order,p_BestellNr,LineNo) then begin

//             if not Item.Get(ArtikelNr) then
//               exit('020001');

//             if Item.Blocked then
//               exit('020008');

//             if (PurchaseLine."No." <> ArtikelNr) then
//               exit('020004');

//             if p_Menge < 0 then begin
//               PurchaseLine.Validate("Qty. to Receive",PurchaseLine."Qty. to Receive" - p_Menge);
//               PurchaseLine.Modify;
//               exit('');
//             end
//             else begin
//               if p_Menge > (PurchaseLine.Quantity - PurchaseLine."Quantity Received") then begin
//                 if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
//                   PurchaseHeader.Status := PurchaseHeader.Status::Open;
//                   PurchaseHeader.Modify;
//                 end;
//                 PurchaseLine.Validate(Quantity,p_Menge + PurchaseLine."Quantity Received");
//               end;
//               PurchaseLine.Validate("Qty. to Receive",p_Menge);
//               PurchaseLine.Modify;
//               exit('');
//             end;
//           end
//           else begin
//             exit('020006');
//             end;
//         end
//         else
//           exit('020007');
//     end;


//     procedure GeplanterWareneingangBuchen(p_BestellNr: Code[20]): Code[10]
//     var
//         PurchaseHeader: Record "Purchase Header";
//         PurchaseLine: Record "Purchase Line";
//         PurchPost: Codeunit "Purch.-Post";
//     begin
//         //'020001' - 'Bestellung nicht gefunden!'
//         //'020002' - 'Es gibt nichts zu buchen!'

//         if PurchaseHeader.Get(PurchaseHeader."document type"::Order, p_BestellNr) then begin
//           PurchaseLine.SetRange("Document Type",PurchaseHeader."Document Type");
//           PurchaseLine.SetRange("Document No.",PurchaseHeader."No.");
//           PurchaseLine.SetRange(Type,PurchaseLine.Type::Item);
//           PurchaseLine.SetFilter("Qty. to Receive",'<>%1',0);
//           if not PurchaseLine.FindFirst then
//             exit('020002');
//           PurchaseHeader.Receive := true;
//           PurchPost.Run(PurchaseHeader);
//           exit('');
//         end
//         else
//           exit('020001');
//     end;


//     procedure GeplanterWareneingang_old(p_BestellNr: Code[20];p_LineNo: Code[20];p_ArtikelNr: Code[20];p_Menge: Decimal): Code[10]
//     var
//         PurchaseHeader: Record "Purchase Header";
//         PurchaseLine: Record "Purchase Line";
//         ReservationEntry: Record "Reservation Entry";
//         Item: Record Item;
//         ItemVariant: Record "Item Variant";
//         LineNo: Integer;
//         EntryNo: Integer;
//         ArtikelNr: Code[20];
//         ArtikelVar: Code[10];
//     begin
//         //Satzart:      WEE
//         //Bezeichnung:  Geplanter Wareneingang mit Bezug zu einer Bestellposition auf Palettenbasis
//         //Beschreibung: Satz wird gesendet, wenn im Lager Ware zugebucht wird, welche als geplanter Wareneingang
//         //              mit einer Bestellposition vereinnahmt wird.

//         //'020001' - 'Artikel nicht gefunden!'
//         //'020002' - 'Minusbuchung in Bestellung. Manuell korrigieren! (01)';
//         //'020004' - 'Artikel stimmt nicht mit Bestellposition überein.';
//         //'020006' - 'Bestellposition nicht gefunden.';
//         //'020007' - 'Bestellung nicht gefunden!';
//         //'020008' - 'Artikel ist gesperrt!';

//         ArtikelNr := p_ArtikelNr;

//         if PurchaseHeader.Get(PurchaseHeader."document type"::Order, p_BestellNr) then begin
//           if Evaluate(LineNo, p_LineNo) then
//             if PurchaseLine.Get(PurchaseLine."document type"::Order,p_BestellNr,p_LineNo) then begin

//               if ReservationEntry.FindLast() then
//                 EntryNo := ReservationEntry."Entry No." +1;

//               if not Item.Get(ArtikelNr) then
//                 exit('020001');

//               if Item.Blocked then
//                 exit('020008');

//               if (PurchaseLine."No." <> ArtikelNr) then
//                 exit('020004');

//               if p_Menge < 0 then begin
//                 Clear(ReservationEntry);
//                 ReservationEntry.SetRange("Source Type", 39);
//                 ReservationEntry.SetRange("Source Subtype", 1);
//                 ReservationEntry.SetRange("Source ID", p_BestellNr);
//                 ReservationEntry.SetRange("Source Ref. No.", LineNo);
//                 ReservationEntry.SetRange("Item No.", ArtikelNr);
//                 ReservationEntry.SetRange("Location Code", PurchaseLine."Location Code");
//                 if ReservationEntry.FindSet then begin
//                   if ReservationEntry."Quantity (Base)" = - p_Menge then begin
//                     ReservationEntry.Delete;
//                     exit('');
//                   end
//                   else begin
//                     ReservationEntry.Validate("Quantity (Base)", ReservationEntry."Quantity (Base)" + p_Menge);
//                     ReservationEntry.Modify;
//                     exit('');
//                   end;
//                 end
//                 else begin
//                   exit('020002');
//                 end;
//               end
//               else begin
//                 ReservationEntry.Reset;
//                 ReservationEntry.Init;
//                 ReservationEntry."Entry No." := EntryNo;
//                 ReservationEntry.Validate("Reservation Status", ReservationEntry."reservation status"::Reservation);
//                 ReservationEntry.Validate("Item No.", ArtikelNr);
//                 ReservationEntry.Validate("Location Code", PurchaseLine."Location Code");
//                 ReservationEntry.Validate("Quantity (Base)", p_Menge);
//                 ReservationEntry.Validate("Reservation Status", ReservationEntry."reservation status"::Surplus);
//                 ReservationEntry.Validate("Creation Date", Today);
//                 ReservationEntry.Validate("Source Type", 39);
//                 ReservationEntry.Validate("Source Subtype", 1);
//                 ReservationEntry.Validate("Source ID", p_BestellNr);
//                 ReservationEntry.Validate("Source Ref. No.", LineNo);
//                 ReservationEntry.Validate("Shipment Date", Today);
//                 ReservationEntry."Created By" := UserId;
//                 ReservationEntry.Validate("Qty. per Unit of Measure", PurchaseLine."Qty. per Unit of Measure");
//                 ReservationEntry.Validate(Quantity, (ReservationEntry."Quantity (Base)"
//                           / ReservationEntry."Qty. per Unit of Measure"));

//                 if not ReservationEntry.Insert then
//                   ReservationEntry.Modify;

//                 exit('');
//               end;
//             end
//             else begin
//               exit('020006');
//             end;
//         end
//         else
//           exit('020007');
//     end;


//     procedure AusstattungOeffnen(p_Resource: Code[20]): Code[10]
//     var
//         Resource: Record Resource;
//         AusstattungszeileScanner: Record Job_DefaultFolder;
//         AusstattungspostenScanner: Record "Vendor Segmentation";
//         LineNo: Integer;
//     begin
//         //'020001' - 'Mitarbeiter nicht gefunden!'

//         if not Resource.Get(p_Resource) then
//           exit('020001');

//         AusstattungszeileScanner.DeleteAll;
//         Clear(AusstattungspostenScanner);
//         AusstattungspostenScanner.SetRange("Chargennr Ziel",p_Resource);
//         AusstattungspostenScanner.SetRange("Startnr Palette",true);
//         if AusstattungspostenScanner.FindSet then
//           repeat
//         //    LineNo += 1;
//             AusstattungszeileScanner."Lfd. Nr." := AusstattungspostenScanner.Mandant;
//             AusstattungszeileScanner.Variante := AusstattungspostenScanner.Menge;
//             AusstattungszeileScanner.Herkunftsmenge := AusstattungspostenScanner.Verbrauchsartikelnr;
//             AusstattungszeileScanner.VorgangMengeSaldo := AusstattungspostenScanner.MHD;
//             AusstattungszeileScanner.Vorgangsbetrag := AusstattungspostenScanner.Datum;
//             AusstattungszeileScanner.Mitarbeiter := AusstattungspostenScanner."Chargennr Ziel";
//             AusstattungszeileScanner.Menge := AusstattungspostenScanner.Restmenge;
//             AusstattungszeileScanner.gebucht := true;
//             AusstattungszeileScanner.Insert;
//           until AusstattungspostenScanner.Next = 0;
//     end;


//     procedure AusstattungAnlegen(p_Resource: Code[20];p_Artikel: Code[20];p_Menge: Decimal): Code[10]
//     var
//         Resource: Record Resource;
//         Item: Record Item;
//         AusstattungszeileScanner: Record Job_DefaultFolder;
//         LineNo: Integer;
//     begin
//         //'020001' - 'Mitarbeiter nicht gefunden!'
//         //'020002' - 'Artikel nicht gefunden';

//         if not Resource.Get(p_Resource) then
//           exit('020001');

//         if not Item.Get(p_Artikel) then
//           exit('020002');

//         Clear(AusstattungszeileScanner);
//         if AusstattungszeileScanner.FindLast then
//           LineNo := AusstattungszeileScanner."Lfd. Nr.";

//         LineNo += 1;
//         Clear(AusstattungszeileScanner);
//         AusstattungszeileScanner."Lfd. Nr." := LineNo;
//         AusstattungszeileScanner.Variante := Today;
//         if p_Menge > 0 then
//           AusstattungszeileScanner.Herkunftsmenge := AusstattungszeileScanner.Herkunftsmenge::"0"
//         else
//           AusstattungszeileScanner.Herkunftsmenge := AusstattungszeileScanner.Herkunftsmenge::"1";
//         AusstattungszeileScanner.VorgangMengeSaldo := p_Artikel;
//         AusstattungszeileScanner.Mitarbeiter := p_Resource;
//         AusstattungszeileScanner.Menge := p_Menge;
//         AusstattungszeileScanner.Insert;

//         exit('');
//     end;


//     procedure AusstattungRueckgabe(p_LineNo: Integer): Code[10]
//     var
//         AusstattungszeileScanner: Record Job_DefaultFolder;
//     begin
//         AusstattungszeileScanner.Get(p_LineNo);
//         AusstattungszeileScanner.Rueckgabe := true;
//         AusstattungszeileScanner.Modify;

//         exit('');
//     end;


//     procedure Ausstattungsbuchen(): Code[10]
//     var
//         Resource: Record Resource;
//         AusstattungszeileScanner: Record Job_DefaultFolder;
//         AusstattungspostenScanner: Record "Vendor Segmentation";
//         Mengeoffen: Decimal;
//         LineNo: Integer;
//     begin
//         Clear(AusstattungszeileScanner);
//         AusstattungszeileScanner.SetRange(Rueckgabe,true);
//         if AusstattungszeileScanner.FindSet then
//           repeat
//             if AusstattungspostenScanner.Get(AusstattungszeileScanner."Lfd. Nr.") then begin
//               AusstattungspostenScanner.Restmenge := 0;
//               AusstattungspostenScanner."Startnr Palette" := false;
//               AusstattungspostenScanner.Modify;
//             end;
//             Clear(AusstattungspostenScanner);
//             AusstattungspostenScanner.FindLast;
//             LineNo := AusstattungspostenScanner.Mandant + 1;
//             Clear(AusstattungspostenScanner);
//             AusstattungspostenScanner.Mandant := LineNo;
//             AusstattungspostenScanner.Menge := Today;
//             AusstattungspostenScanner.Verbrauchsartikelnr := AusstattungspostenScanner.Verbrauchsartikelnr::"1";
//             AusstattungspostenScanner.MHD := AusstattungszeileScanner.VorgangMengeSaldo;
//             AusstattungspostenScanner.Datum := AusstattungszeileScanner.Vorgangsbetrag;
//             AusstattungspostenScanner."Chargennr Ziel" := AusstattungszeileScanner.Mitarbeiter;
//             AusstattungspostenScanner."Anzahl Etiketten" := -AusstattungszeileScanner.Menge;
//             AusstattungspostenScanner.Insert;
//           until AusstattungszeileScanner.Next = 0;

//         Clear(AusstattungszeileScanner);
//         AusstattungszeileScanner.SetRange(gebucht,false);
//         if AusstattungszeileScanner.FindSet then
//           repeat
//             if AusstattungszeileScanner.Menge < 0 then begin
//               Mengeoffen := -AusstattungszeileScanner.Menge;
//               Clear(AusstattungspostenScanner);
//               AusstattungspostenScanner.SetRange(MHD,AusstattungszeileScanner.VorgangMengeSaldo);
//               AusstattungspostenScanner.SetRange(Datum,AusstattungszeileScanner.Vorgangsbetrag);
//               AusstattungspostenScanner.SetRange("Chargennr Ziel",AusstattungszeileScanner.Mitarbeiter);
//               AusstattungspostenScanner.SetRange("Startnr Palette",true);
//               if AusstattungspostenScanner.FindFirst then
//                 repeat
//                   if Mengeoffen > AusstattungspostenScanner.Restmenge then begin
//                     Mengeoffen -= AusstattungspostenScanner.Restmenge;
//                     AusstattungspostenScanner.Restmenge := 0;
//                     AusstattungspostenScanner."Startnr Palette" := false;
//                     AusstattungspostenScanner.Modify;
//                   end
//                   else begin
//                     AusstattungspostenScanner.Restmenge -= Mengeoffen;
//                     if AusstattungspostenScanner.Restmenge = 0 then
//                       AusstattungspostenScanner."Startnr Palette" := false;
//                     AusstattungspostenScanner.Modify;
//                     Mengeoffen := 0;
//                   end;
//                 until (AusstattungspostenScanner.Next = 0) or (Mengeoffen <= 0);
//             end;
//             Clear(AusstattungspostenScanner);
//             if AusstattungspostenScanner.FindLast then
//               LineNo := AusstattungspostenScanner.Mandant;
//             LineNo += 1;
//             Clear(AusstattungspostenScanner);
//             AusstattungspostenScanner.Mandant := LineNo;
//             AusstattungspostenScanner.Menge := Today;
//             if AusstattungszeileScanner.Menge < 0 then
//               AusstattungspostenScanner.Verbrauchsartikelnr := AusstattungspostenScanner.Verbrauchsartikelnr::"1"
//             else begin
//               AusstattungspostenScanner.Verbrauchsartikelnr := AusstattungspostenScanner.Verbrauchsartikelnr::"0";
//               AusstattungspostenScanner.Restmenge := AusstattungszeileScanner.Menge;
//               AusstattungspostenScanner."Startnr Palette" := true;
//             end;
//             AusstattungspostenScanner.MHD := AusstattungszeileScanner.VorgangMengeSaldo;
//             AusstattungspostenScanner.Datum := AusstattungszeileScanner.Vorgangsbetrag;
//             AusstattungspostenScanner."Chargennr Ziel" := AusstattungszeileScanner.Mitarbeiter;
//             AusstattungspostenScanner."Anzahl Etiketten" := AusstattungszeileScanner.Menge;
//             AusstattungspostenScanner.Insert;
//           until AusstattungszeileScanner.Next = 0;

//         Clear(AusstattungszeileScanner);
//         AusstattungszeileScanner.DeleteAll;

//         exit('');
//     end;


//     procedure GeraeteOeffnen(p_Projektnr: Code[20];p_Resource: Code[20]): Code[10]
//     var
//         Resource: Record Resource;
//         Job: Record Job;
//         GeraetezeileScanner: Record Bildspeicherung;
//         GeraetepostenScanner: Record "Item Charge Translation";
//         LineNo: Integer;
//     begin
//         //'020001' - 'Mitarbeiter nicht gefunden!'
//         //'020002' - 'Projekt nicht gefunden!'

//         if (StrLen(p_Projektnr) = 6) then
//           p_Projektnr := CopyStr(p_Projektnr, 1,2) + '-' + CopyStr(p_Projektnr, 3);

//         if not Job.Get(p_Projektnr) then
//           exit('020002');

//         if p_Resource <> '' then
//           if not Resource.Get(p_Resource) then
//             exit('020001');

//         GeraetezeileScanner.DeleteAll;
//         Clear(GeraetepostenScanner);
//         GeraetepostenScanner.SetRange(Warenausgangsdatum,p_Resource);
//         GeraetepostenScanner.SetRange(Projektnr,p_Projektnr);
//         GeraetepostenScanner.SetRange(Stückpreis,true);
//         if GeraetepostenScanner.FindSet then
//           repeat
//         //    LineNo += 1;
//             GeraetezeileScanner."Lfd. Nr." := GeraetepostenScanner.Vertriebsplan;
//             GeraetezeileScanner.Amount := GeraetepostenScanner."Artikelnr.";
//             GeraetezeileScanner."Ergebnis für" := GeraetepostenScanner.Projektnr;
//             GeraetezeileScanner.Status := GeraetepostenScanner.Variante;
//             GeraetezeileScanner.Variante := GeraetepostenScanner."Debitorennr.";
//             GeraetezeileScanner.Reserviert := GeraetepostenScanner.Kette;
//             GeraetezeileScanner.Mitarbeiter := GeraetepostenScanner.Warenausgangsdatum;
//             GeraetezeileScanner.Menge := GeraetepostenScanner.Restmenge;
//             GeraetezeileScanner.gebucht := true;
//             GeraetezeileScanner.Insert;
//           until GeraetepostenScanner.Next = 0;
//     end;


//     procedure GeraeteAnlegen(p_Projektnr: Code[20];p_Resource: Code[20];p_Artikel: Code[20];p_SN: Code[20];p_Menge: Decimal;Rueckgabe: Boolean): Code[10]
//     var
//         Resource: Record Resource;
//         Item: Record Item;
//         Job: Record Job;
//         GeraetezeileScanner: Record Bildspeicherung;
//         LineNo: Integer;
//     begin
//         //'020001' - 'Mitarbeiter nicht gefunden!'
//         //'020002' - 'Artikel nicht gefunden';
//         //'020003' - 'Projekt nicht gefunden!'
//         //'020004' - 'Seriennummer schon gescannt'

//         if (StrLen(p_Projektnr) = 6) then
//           p_Projektnr := CopyStr(p_Projektnr, 1,2) + '-' + CopyStr(p_Projektnr, 3);

//         if (StrLen(p_SN) > 20) then
//           p_SN := CopyStr(p_SN, 1, 20);

//         if not Job.Get(p_Projektnr) then
//           exit('020003');

//         if p_Resource <> '' then
//           if not Resource.Get(p_Resource) then
//             exit('020001');

//         if not Item.Get(p_Artikel) then
//           exit('020002');

//         if Rueckgabe then
//           p_Menge := -p_Menge;

//         Clear(GeraetezeileScanner);
//         if GeraetezeileScanner.FindLast then
//           LineNo := GeraetezeileScanner."Lfd. Nr.";

//         LineNo += 1;
//         Clear(GeraetezeileScanner);
//         GeraetezeileScanner."Lfd. Nr." := LineNo;
//         GeraetezeileScanner.Amount := Today;
//         if p_Menge > 0 then
//           GeraetezeileScanner.Status := GeraetezeileScanner.Status::durchsucht
//         else
//           GeraetezeileScanner.Status := GeraetezeileScanner.Status::gefunden;
//         GeraetezeileScanner.Rueckgabe := Rueckgabe;
//         GeraetezeileScanner.Variante := p_Artikel;
//         GeraetezeileScanner.Reserviert := p_SN;
//         GeraetezeileScanner.Beschreibung := Item.Description;
//         GeraetezeileScanner."Ergebnis für" := p_Projektnr;
//         GeraetezeileScanner.Mitarbeiter := p_Resource;
//         GeraetezeileScanner.Menge := p_Menge;
//         GeraetezeileScanner.Insert;

//         exit('');
//     end;


//     procedure GeraeteRueckgabe(p_LineNo: Integer): Code[10]
//     var
//         GeraetezeileScanner: Record Bildspeicherung;
//     begin
//         //Wird nicht verwendet!   //G-ERP.FL 2014-08-21
//         /*
//         GeraetezeileScanner.GET(p_LineNo);
//         GeraetezeileScanner.Rueckgabe := TRUE;
//         GeraetezeileScanner.MODIFY;
//         */
//         exit('');

//     end;


//     procedure Geraetebuchen(): Code[10]
//     var
//         Resource: Record Resource;
//         GeraetezeileScanner: Record Bildspeicherung;
//         GeraetepostenScanner: Record "Item Charge Translation";
//         Mengeoffen: Decimal;
//         LineNo: Integer;
//     begin
//         Clear(GeraetezeileScanner);
//         GeraetezeileScanner.SetRange(gebucht,false);
//         if GeraetezeileScanner.FindSet then
//           repeat
//             //Posten ausgleichen +
//             Mengeoffen := GeraetepostenScanner.Restmenge;
//             GeraetepostenScanner.SetRange(Projektnr, GeraetezeileScanner."Ergebnis für");
//             GeraetepostenScanner.SetRange("Debitorennr.", GeraetezeileScanner.Variante);
//             GeraetepostenScanner.SetRange(Kette, GeraetezeileScanner.Reserviert);
//             GeraetepostenScanner.SetRange(Warenausgangsdatum, GeraetezeileScanner.Mitarbeiter);
//             GeraetepostenScanner.SetRange(Stückpreis, true);
//             if GeraetepostenScanner.FindSet then begin
//               repeat
//                 if GeraetepostenScanner.Restmenge <= Mengeoffen then begin
//                   Mengeoffen := Mengeoffen - GeraetepostenScanner.Restmenge;
//                   GeraetepostenScanner.Restmenge := 0;
//                   GeraetepostenScanner.Stückpreis := false;
//                 end
//                 else begin
//                   Mengeoffen :=0;
//                   GeraetepostenScanner.Restmenge := GeraetepostenScanner.Restmenge - Mengeoffen;
//                 end;
//                 GeraetepostenScanner.Modify;
//               until ((GeraetepostenScanner.Next = 0) or (Mengeoffen = 0))
//             end;
//             //Posten ausgleichen -
//             Clear(GeraetepostenScanner);
//             if GeraetepostenScanner.FindLast then
//               LineNo := GeraetepostenScanner.Vertriebsplan + 1
//             else
//               LineNo := 1;
//             Clear(GeraetepostenScanner);
//             GeraetepostenScanner.Vertriebsplan := LineNo;
//             GeraetepostenScanner."Artikelnr." := Today;
//             GeraetepostenScanner.Variante := GeraetezeileScanner.Status;
//             GeraetepostenScanner.Projektnr := GeraetezeileScanner."Ergebnis für";
//             GeraetepostenScanner."Debitorennr." := GeraetezeileScanner.Variante;
//             GeraetepostenScanner.Kette := GeraetezeileScanner.Reserviert;
//             GeraetepostenScanner.Buchungsdatum := GeraetezeileScanner.Beschreibung;
//             GeraetepostenScanner.Warenausgangsdatum := GeraetezeileScanner.Mitarbeiter;
//             GeraetepostenScanner.Menge := GeraetezeileScanner.Menge;
//             GeraetepostenScanner.Restmenge := Mengeoffen;
//             if (GeraetepostenScanner.Restmenge <> 0) then
//               GeraetepostenScanner.Stückpreis := true;
//             GeraetepostenScanner.Insert;

//             GeraetezeileScanner.gebucht := true;
//             GeraetezeileScanner.Modify;
//           until GeraetezeileScanner.Next = 0;

//         Clear(GeraetezeileScanner);
//         //GeraetezeileScanner.DELETEALL;

//         exit('');
//     end;


//     procedure AuslesenMitarbeiter()
//     var
//         datei: File;
//         out: OutStream;
//         instrea: InStream;
//         ToFile: Variant;
//     begin
//         if ISSERVICETIER then begin
//           datei.CreateTempfile();
//           datei.CreateOutstream(out);

//           Xmlport.Export(50000, out);

//           datei.CreateInstream(instrea);
//           ToFile :='Mitarbeiter.xml';

//           // Tranfer the content from the temporary file on the NAV server to a file on the RoleTailored client.

//           DownloadFromStream(
//                     instrea,
//                     '',
//         //            'Save File to RoleTailored Client',
//                      '\\tt-file1\Company\Daten\NAV\',
//                      'File *.xml| *.xml',
//                      ToFile);

//           // Close the temporary file and delete it from NAV server.

//         end
//         else begin

//           datei.Create('\\tt-file1\Company\Daten\NAV\Mitarbeiter.xml');
//           datei.Open('\\tt-file1\Company\Daten\NAV\Mitarbeiter.xml');
//           datei.CreateOutstream(out);
//           Xmlport.Export(50000, out);
//         end;


//         datei.Close;
//     end;


//     procedure AuslesenArtikelSeriennr()
//     var
//         datei: File;
//         out: OutStream;
//         instrea: InStream;
//         ToFile: Variant;
//     begin
//         if ISSERVICETIER then begin
//           datei.CreateTempfile();
//           datei.CreateOutstream(out);

//           Xmlport.Export(50002, out);

//           datei.CreateInstream(instrea);
//           ToFile :='ArtikelSeriennr.xml';

//           // Tranfer the content from the temporary file on the NAV server to a file on the RoleTailored client.

//           DownloadFromStream(
//                     instrea,
//                     '',
//         //            'Save File to RoleTailored Client',
//                      '\\tt-file1\Company\Daten\NAV\',
//         //             'Text File *.txt| *.txt',
//                      'File *.xml| *.xml',
//                      ToFile);

//           // Close the temporary file and delete it from NAV server.

//         end
//         else begin
//           datei.Create('\\tt-file1\Company\Daten\NAV\ArtikelSeriennr.xml');
//           datei.Open('\\tt-file1\Company\Daten\NAV\ArtikelSeriennr.xml');
//           datei.CreateOutstream(out);

//           Xmlport.Export(50002, out);
//         end;

//         datei.Close;
//     end;
// }

