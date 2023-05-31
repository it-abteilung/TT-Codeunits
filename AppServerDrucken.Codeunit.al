#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
Codeunit 50004 "AppServer Drucken"
{

    trigger OnRun()
    begin
        Drucken();
        Drucken();
    end;

    local procedure Drucken()
    var
        BerichteDrucker: Record "Berichte Drucker";
    begin
        Clear(BerichteDrucker);
        BerichteDrucker.SetCurrentkey("Auftrag Datum");
        BerichteDrucker.SetRange(Erledigt, false);
        if BerichteDrucker.FindSet then
            repeat
                CreateDruckDokument(BerichteDrucker.ReportID, BerichteDrucker.TableID, BerichteDrucker.RecordKey1, BerichteDrucker.RecordKey2,
                                    BerichteDrucker.RecordKey3, BerichteDrucker.RecordKey4, BerichteDrucker.RecordKey5, BerichteDrucker.Druckername,
                                    BerichteDrucker.Anzahl);
                BerichteDrucker.Erledigt := true;
                BerichteDrucker."Gedruckt Datum" := CurrentDatetime();
                BerichteDrucker.Modify;
            until BerichteDrucker.Next = 0;
        Commit;
    end;

    local procedure CreateDruckDokument(ReportID: Integer; TableID: Integer; DocNo1: Code[20]; DocNo2: Code[20]; DocNo3: Code[20]; DocNo4: Code[20]; DocNo5: Code[20]; Printername: Text[250]; Anzahl: Integer)
    var
        PrinterSelection: Record "Printer Selection";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemRec: Record Item;
    begin
        if not PrinterSelection.Get(UserId, ReportID) then begin
            PrinterSelection."User ID" := UserId;
            PrinterSelection."Report ID" := ReportID;
            PrinterSelection."Printer Name" := Printername;
            PrinterSelection.Insert;
        end
        else begin
            PrinterSelection."Printer Name" := Printername;
            PrinterSelection.Modify;
        end;
        Commit;

        case TableID of
            27:
                begin
                    ItemRec.SetFilter("No.", DocNo1);
                    ItemRec.FindFirst;
                    Report.RunModal(ReportID, false, false, ItemRec);
                end;
            38:
                begin
                    if (DocNo1 <> '') and (DocNo2 <> '') then begin //G-ERP.FL 2018-01-24
                        PurchaseHeader.SetFilter("Document Type", DocNo1);
                        PurchaseHeader.SetRange("No.", DocNo2);
                        PurchaseHeader.FindFirst;
                        Report.RunModal(ReportID, false, false, PurchaseHeader);
                    end;
                end;
            39:
                begin
                    if (DocNo1 <> '') and (DocNo2 <> '') and (DocNo3 <> '') then begin  //G-ERP.FL 2018-01-24
                        Clear(PurchaseLine);
                        PurchaseLine.SetFilter("Document Type", DocNo1);
                        PurchaseLine.SetRange("Document No.", DocNo2);
                        PurchaseLine.SetFilter("Line No.", DocNo3);
                        if PurchaseLine.FindFirst then
                            Report.RunModal(ReportID, false, false, PurchaseLine);
                    end;
                end;
        end;
    end;
}

