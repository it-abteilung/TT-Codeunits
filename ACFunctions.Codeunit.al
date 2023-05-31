Codeunit 50006 "AC Functions"
{
    Permissions = TableData "Purch. Inv. Header" = rimd;

    trigger OnRun()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
    end;

    local procedure DeleteDublicates()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        Window: Dialog;
    begin
        if Confirm('Sollen Dublikate gelöscht werden?') then begin

            Window.Open(
              '#1############################\\' +
              'Dublikate löschen #2###### @3@@@@@@@@@');

            Window.Update(1, 'Dublikate werden gelöscht.');

            PurchInvHeader.SetCurrentkey("Vendor Invoice No.", "Posting Date");
            if PurchInvHeader.FindSet then
                repeat
                    PurchInvHeader.CalcFields(Amount);
                    PurchaseHeader.SetRange("Vendor Invoice No.", PurchInvHeader."Vendor Invoice No.");
                    if PurchaseHeader.FindFirst then begin
                        PurchaseHeader.CalcFields(Amount);
                        if PurchaseHeader."Buy-from Vendor No." = PurchInvHeader."Buy-from Vendor No." then
                            if PurchaseHeader.Amount = PurchInvHeader.Amount then
                                PurchaseHeader.Delete(true);
                    end;
                until PurchInvHeader.Next = 0;

            Window.Close;
        end;
    end;


    // procedure CreateItemFromTemplate()
    // var
    //     Item: Record Item;
    //     ConfigTempHeader: Record "Config. Template Header";
    //     ConfigTemplateList: Page "Config. Template List";
    //     CreateTxt: label 'Do you wish to create an Item via template?';
    //     ItemTemplate: Record "Item Templ." temporary;
    //     Item2: Record Item;
    //     NoSeriesMgt: Codeunit NoSeriesManagement;
    // begin
    //     if Confirm(CreateTxt) then begin
    //       ConfigTempHeader.SetRange("Table ID",27);
    //       ConfigTemplateList.SetTableview(ConfigTempHeader);
    //       ConfigTemplateList.SetRecord(ConfigTempHeader);
    //       ConfigTemplateList.LookupMode(true);
    //       if ConfigTemplateList.RunModal = Action::LookupOK then
    //         ConfigTemplateList.GetRecord(ConfigTempHeader);

    //       ItemTemplate.InitializeTempRecordFromConfigTemplate(ItemTemplate,ConfigTempHeader);

    //       Item.Init;
    //       Item."No. Series" := ItemTemplate."No. Series";
    //       NoSeriesMgt.InitSeries(ItemTemplate."No. Series",Item."No. Series",0D,Item."No.",Item."No. Series");
    //       Item.Insert;

    //       Item2.Get(Item."No.");
    //       Item2.Validate("Base Unit of Measure",ItemTemplate."Base Unit of Measure");
    //       Item2.Validate("Inventory Posting Group",ItemTemplate."Inventory Posting Group");
    //       Item2.Validate("Item Disc. Group",ItemTemplate."Item Disc. Group");
    //       Item2.Validate("Allow Invoice Disc.",ItemTemplate."Allow Invoice Disc.");
    //       Item2.Validate("Price/Profit Calculation",ItemTemplate."Price/Profit Calculation");
    //       Item2.Validate("Profit %",ItemTemplate."Profit %");
    //       Item2.Validate("Costing Method",ItemTemplate."Costing Method");
    //       Item2.Validate("Indirect Cost %",ItemTemplate."Indirect Cost %");
    //       Item2.Validate("Price Includes VAT",ItemTemplate."Price Includes VAT");
    //       Item2.Validate("Gen. Prod. Posting Group",ItemTemplate."Gen. Prod. Posting Group");
    //       Item2.Validate("Automatic Ext. Texts",ItemTemplate."Automatic Ext. Texts");
    //       Item2.Validate("Tax Group Code",ItemTemplate."Tax Group Code");
    //       Item2.Validate("VAT Prod. Posting Group",ItemTemplate."VAT Prod. Posting Group");
    //       Item2.Validate("Item Category Code",ItemTemplate."Item Category Code");
    //       Item2.Validate("Service Item Group",ItemTemplate."Service Item Group");
    //       Item2.Validate("Warehouse Class Code",ItemTemplate."Warehouse Class Code");
    //       Item2.Validate("Item Tracking Code",ItemTemplate."Item Tracking Code");
    //       Item2.Validate("Product Group Code",ItemTemplate."Product Group Code");
    //       Item2.Modify;

    //       Page.Run(30,Item2);
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure CheckMandatoryOnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        if PurchaseHeader.Invoice then begin
            PurchaseHeader.TestField(Leistungszeitraum);
            PurchaseHeader.TestField(Leistungsart);

            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.SetRange(Type, PurchLine.Type::"Charge (Item)", PurchLine.Type::Resource);
            if PurchLine.FindSet() then
                repeat
                    PurchLine.TestField(Leistungsart);
                    PurchLine.TestField(Leistungszeitraum);
                until PurchLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterInsertEvent', '', false, false)]
    local procedure CreateBinCodeOnAfterInsertJob(var Rec: Record Job; RunTrigger: Boolean)
    var
        Bin: Record Bin;
    begin
        if Rec."No." <> '' then begin
            Bin.Init;
            Bin."Location Code" := 'PROJEKT';
            Bin.Code := Rec."No.";
            if Bin.Insert then;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Description', false, false)]
    local procedure ModifyBinDescriptionOnAfterModifyJob(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        Bin: Record Bin;
    begin
        if Rec.Description <> xRec.Description then begin
            if Bin.Get('PROJEKT', Rec."No.") then begin
                Bin.Description := Rec.Description;
                Bin.Modify;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure CommentMessageOnAfterValidateItemSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        CommentLine: Record "Comment Line";
        CommentTxt: label 'There are comments for this %1!';
    begin
        if Rec.Type = Rec.Type::Item then begin
            CommentLine.SetRange("Table Name", CommentLine."table name"::Item);
            CommentLine.SetRange("No.", Rec."No.");
            if not CommentLine.IsEmpty then
                Message(StrSubstNo(CommentTxt, CommentLine."Table Name"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure CommentMessageOnAfterValidateItemPurchLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        CommentTxt: label 'There are comments for this %1!';
        CommentLine: Record "Comment Line";
    begin
        if Rec.Type = Rec.Type::Item then begin
            CommentLine.SetRange("Table Name", CommentLine."table name"::Item);
            CommentLine.SetRange("No.", Rec."No.");
            if not CommentLine.IsEmpty then
                Message(StrSubstNo(CommentTxt, CommentLine."Table Name"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure CommentMessageOnAfterValidateCustSalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        CommentLine: Record "Comment Line";
        CommentTxt: label 'There are comments for this %1!';
    begin
        CommentLine.SetRange("Table Name", CommentLine."table name"::Vendor);
        CommentLine.SetRange("No.", Rec."Sell-to Customer No.");
        if not CommentLine.IsEmpty then
            Message(StrSubstNo(CommentTxt, CommentLine."Table Name"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Vendor No.', false, false)]
    local procedure CommentMessageOnAfterValidateVendPurchHeader(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        CommentTxt: label 'There are comments for this %1!';
        CommentLine: Record "Comment Line";
    begin
        CommentLine.SetRange("Table Name", CommentLine."table name"::Vendor);
        CommentLine.SetRange("No.", Rec."Buy-from Vendor No.");
        if not CommentLine.IsEmpty then
            Message(StrSubstNo(CommentTxt, CommentLine."Table Name"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure GetItemChargeTranslationsOnAfterValidateChargeNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        ItemChargeTranslation: Record "Item Charge Translation";
        PurchHeader: Record "Purchase Header";
    begin
        if Rec.Type = Rec.Type::"Charge (Item)" then begin
            PurchHeader.Get(Rec."Document Type", Rec."Document No.");
            if ItemChargeTranslation.Get(Rec."No.", PurchHeader."Language Code") then
                Rec.Description := ItemChargeTranslation.Description;
        end;
    end;

    [EventSubscriber(Objecttype::Page, 88, 'OnQueryClosePageEvent', '', false, false)]
    local procedure CheckMandatoryFieldsOnCloseJobCard(var Rec: Record Job; var AllowClose: Boolean)
    begin
        if Rec."Creation Date" > 20220101D then begin
            Rec.TestField(Description);
            Rec.TestField("Bill-to Customer No.");
            Rec.TestField("Job Type");
            Rec.TestField("Person Responsible");
            Rec.TestField(Verfasser);
            Rec.TestField(Reparaturort);
            Rec.TestField("Anfrage von");
            Rec.TestField("Anfrage am");
            Rec.TestField("Angebotsabgabe bis");
            Rec.TestField("Angebotsabgabe durch");
            Rec.TestField("Starting Date");
            Rec.TestField("Ending Date");
            Rec.TestField(Object);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure DoNotChangeUnitCostOnAfterValidateQuantity(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec."Document Type" in [Rec."document type"::Quote, Rec."document type"::Order] then begin
            if xRec.Quantity <> Rec.Quantity then begin
                if xRec."Amount Including VAT" <> Rec."Amount Including VAT" then
                    Rec."Amount Including VAT" := xRec."Amount Including VAT";
                if xRec.Amount <> Rec.Amount then
                    Rec.Amount := xRec.Amount;
                if Rec.Modify then;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterTransferSavedFields', '', false, false)]
    local procedure SetGERPFieldsOnAfterTansferSavedFields(SourcePurchaseLine: Record "Purchase Line"; var DestinationPurchaseLine: Record "Purchase Line")
    begin
        // G-ERP+
        DestinationPurchaseLine."Vendor Item No." := SourcePurchaseLine."Vendor Item No.";
        IF SourcePurchaseLine."Line Discount %" <> 0 THEN
            DestinationPurchaseLine.VALIDATE("Line Discount %", SourcePurchaseLine."Line Discount %");
        DestinationPurchaseLine.VALIDATE(Description, SourcePurchaseLine.Description);
        DestinationPurchaseLine.VALIDATE("Description 2", SourcePurchaseLine."Description 2");
        // G-ERP-
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnUpdatePurchLinesByFieldNoOnBeforeValidateFields', '', false, false)]
    local procedure SetGERPFieldsOnAfterUpdatePurchLinesByFieldNo(var ChangedFieldNo: Integer; var IsHandled: Boolean; var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
    begin
        //G-ERP+
        if not IsHandled then
            case ChangedFieldNo of
                PurchaseHeader.FieldNo("Job No."):
                    IF (PurchaseLine."No." <> '') THEN
                        PurchaseLine.VALIDATE("Job No.", PurchaseHeader."Job No.");
                PurchaseHeader.FIELDNO(Leistungsart):
                    IF (PurchaseLine."No." <> '') THEN
                        PurchaseLine.VALIDATE(Leistungsart, PurchaseHeader.Leistungsart);
                PurchaseHeader.FIELDNO(Leistungszeitraum):
                    IF (PurchaseLine."No." <> '') THEN
                        PurchaseLine.VALIDATE(Leistungszeitraum, PurchaseHeader.Leistungszeitraum);
            //G-ERP-
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLineJob', '', false, false)]
    local procedure SkipJobTaskNoErrorInOnBeforeTestPurchLineJob(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeVerifyLineTypeForJob', '', false, false)]
    local procedure SkipChargeItemforJobErrorInOnBeforeVerifyLineTypeForJob(var IsHandled: Boolean; var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job", 'OnAfterInsertEvent', '', false, false)]
    local procedure CreateJobTaskOnBeforeInsert(RunTrigger: Boolean; var Rec: Record Job)
    var
        JobTask: Record "Job Task";
    begin
        JobTask.Init();
        JobTask."Job No." := rec."No.";
        JobTask."Job Task No." := '';
        JobTask."Job Task Type" := "Job Task Type"::Posting;
        JobTask.Insert(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Post Line", 'OnCheckJobOnBeforeTestJobTaskType', '', false, false)]
    local procedure SkipJobTaskNoErrorOnJnlPostLine(var IsHandled: Boolean; var JobJournalLine: Record "Job Journal Line")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Check Line", 'OnBeforeTestJobJnlLine', '', false, false)]
    local procedure SkipJobTaskNoErrorOnJnlCheckLine(JobJournalLine: Record "Job Journal Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnBeforeDeletePurchQuote', '', false, false)]
    local procedure KeepPurchQuoteAtQuoteToOrder(var IsHandled: Boolean; var OrderPurchHeader: Record "Purchase Header"; var QuotePurchHeader: Record "Purchase Header")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLineJob', '', false, false)]
    local procedure SkipJobTaskNoErrorOnPurchPost(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Post-Line", 'OnBeforePostJobOnPurchaseLine', '', false, false)]
    local procedure SkipJobTaskNoErrorOnJobPostLine(var IsHandled: Boolean; var JobJnlLine: Record "Job Journal Line"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchLine: Record "Purchase Line"; var Sourcecode: Code[10]; var TempJobJournalLine: Record "Job Journal Line"; var TempPurchaseLineJob: Record "Purchase Line")
    var
        Job: Record Job;
        JobTransferLine: Codeunit "Job Transfer Line";
        JobPostLine: Codeunit "Job Post-Line";
        JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
        JobTask: Record "Job Task";
    begin
        IsHandled := true;

        Clear(JobJnlLine);
        PurchLine.TestField("Job No.");
        Job.LockTable();
        Job.Get(PurchLine."Job No.");
        If not JobTask.Get(Job."No.", '') then begin
            JobTask.Init;
            JobTask."Job No." := Job."No.";
            JobTask."Job Task No." := '';
            JobTask.Insert();
        end;
        PurchLine.TestField("Job Currency Code", Job."Currency Code");
        JobTransferLine.FromPurchaseLineToJnlLine(
          PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, Sourcecode, JobJnlLine);
        JobJnlLine."Job Posting Only" := true;

        if PurchLine.Type = PurchLine.Type::"G/L Account" then begin
            TempPurchaseLineJob := PurchLine;
            TempPurchaseLineJob.Insert();
            TempJobJournalLine := JobJnlLine;
            TempJobJournalLine."Line No." := TempPurchaseLineJob."Line No.";
            TempJobJournalLine.insert;
        end else
            JobJnlPostLine.RunWithCheck(JobJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Check Line", 'OnRunCheckOnBeforeTestFieldJobStatus', '', false, false)]
    local procedure SkipJobStatusErrorOnPurchPost(var IsHandled: Boolean; var JobJnlLine: Record "Job Journal Line")
    var
        Job: Record Job;
    begin
        IsHandled := true;

        Job.Get(JobJnlLine."Job No.");
        if job.Blocked = Job.Blocked::All then
            // if JobJnlLine.Type <> JobJnlLine.Type::Resource then
                Job.TestField(Blocked, Job.Blocked::" ", ErrorInfo.Create());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterUpdatePurchLine', '', false, false)]
    local procedure GetDescriptions(FromPurchDocType: Option; RecalculateAmount: Boolean; RecalculateLines: Boolean; var CopyPostedDeferral: Boolean; var CopyThisLine: Boolean; var FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line")
    begin
        ToPurchLine.Description := FromPurchLine.Description;
        ToPurchLine.VALIDATE("Description 2", FromPurchLine."Description 2");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocLineOnAfterSetNextLineNo', '', false, false)]
    local procedure CheckLineNoOnQuote(var FromPurchLine: Record "Purchase Line"; var NextLineNo: Integer; var ToPurchLine: Record "Purchase Line")
    begin
        IF FromPurchLine."Document Type" = FromPurchLine."Document Type"::Quote THEN
            ToPurchLine."Line No." := FromPurchLine."Line No."
        ELSE
            ToPurchLine."Line No." := NextLineNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocLineOnBeforeCopyThisLine', '', false, false)]
    local procedure GerwingChangesCopyDocument(FromPurchDocType: Enum "Purchase Document Type From"; MoveNegLines: Boolean; ToPurchaseHeader: Record "Purchase Header"; var CopyThisLine: Boolean; var FromPurchLine: Record "Purchase Line"; var IsHandled: Boolean; var LinesNotCopied: Integer; var Result: Boolean; var ToPurchLine: Record "Purchase Line")
    begin
        //G-ERP.KBS 2018-07-27 + 
        IF FromPurchLine.HASLINKS THEN
            ToPurchLine.COPYLINKS(FromPurchLine);
        //G-ERP.KBS 2018-07-27 -

        //G-ERP.KBS 2018-07-31 + lt. Urte Stodt Anfrage#230508
        IF FromPurchLine."No." = '1' THEN
            ToPurchLine."Vendor Item No." := FromPurchLine."Vendor Item No.";
        //G-ERP.KBS 2018-07-31 -
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeTestStatusOpen', '', false, false)]
    local procedure SkipTestStatusForUpdate(CallingFieldNo: Integer; sender: Record "Purchase Header"; var PurchHeader: Record "Purchase Header"; xPurchHeader: Record "Purchase Header")
    begin
        PurchHeader.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeUpdateDirectUnitCost', '', false, false)]
    local procedure GERPChangesOnUpdateDirectUnitCost(CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean; var PurchLine: Record "Purchase Line"; xPurchLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
        PriceCalculation: Interface "Price Calculation";
    begin
        Handled := true;
        IF (CurrFieldNo = 15) AND (PurchLine."Prod. Order No." <> '') THEN           // G-ERP 20180903+
            PurchLine.UpdateAmounts;

        IF ((CalledByFieldNo <> CurrFieldNo) AND (CurrFieldNo <> 0)) OR
           (PurchLine."Prod. Order No." <> '')
        THEN
            EXIT;

        PurchLine.GetPriceCalculationHandler(PurchHeader, PriceCalculation);
        IF PurchLine.Type = PurchLine.Type::Item THEN BEGIN
            PurchLine.GetPurchHeader;
            PriceCalculation.ApplyPrice(CalledByFieldNo);
            PriceCalculation.ApplyDiscount();
            PurchLine.VALIDATE("Direct Unit Cost");
        END;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCopyAndCheckItemChargeTempPurchLine', '', false, false)]
    local procedure SkipTestCopyCheckCharge(PurchaseHeader: Record "Purchase Header"; var AssignError: Boolean; var IsHandled: Boolean; var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; var TempPrepmtPurchaseLine: Record "Purchase Line")
    var
        PurchPost: Codeunit "Purch.-Post";
        PurchLine: Record "Purchase Line";
        QtyNeeded: Decimal;
        CannotAssignMoreErr: Label 'You cannot assign more than %1 units in %2 = %3,%4 = %5,%6 = %7.', Comment = '%1 = Quantity, %2/%3 = Document Type, %4/%5 - Document No.,%6/%7 = Line No.';
        CannotAssignInvoicedErr: Label 'You cannot assign item charges to the %1 %2 = %3,%4 = %5, %6 = %7, because it has been invoiced.', Comment = '%1 = Purchase Line, %2/%3 = Document Type, %4/%5 - Document No.,%6/%7 = Line No.';
        MustAssignItemChargeErr: Label 'You must assign item charge %1 if you want to invoice it.', Comment = '%1 = Item Charge No.';
        CannotInvoiceItemChargeErr: Label 'You can not invoice item charge %1 because there is no item ledger entry to assign it to.', Comment = '%1 = Item Charge No.';
    begin
        IsHandled := true;
        if PurchaseHeader.Invoice and
           (TempPrepmtPurchaseLine."Qty. to Receive" + TempPrepmtPurchaseLine."Return Qty. to Ship" <> 0) and
           ((PurchaseHeader.Ship or PurchaseHeader.Receive) or
            (Abs(TempPrepmtPurchaseLine."Qty. to Invoice") >
             Abs(TempPrepmtPurchaseLine."Qty. Rcd. Not Invoiced" + TempPrepmtPurchaseLine."Qty. to Receive") +
             Abs(TempPrepmtPurchaseLine."Ret. Qty. Shpd Not Invd.(Base)" + TempPrepmtPurchaseLine."Return Qty. to Ship")))
        then
            TempPrepmtPurchaseLine.TestField("Line Amount");

        if not PurchaseHeader.Receive then
            TempPrepmtPurchaseLine."Qty. to Receive" := 0;
        if not PurchaseHeader.Ship then
            TempPrepmtPurchaseLine."Return Qty. to Ship" := 0;
        if Abs(TempPrepmtPurchaseLine."Qty. to Invoice") >
           Abs(TempPrepmtPurchaseLine."Quantity Received" + TempPrepmtPurchaseLine."Qty. to Receive" +
             TempPrepmtPurchaseLine."Return Qty. Shipped" + TempPrepmtPurchaseLine."Return Qty. to Ship" -
             TempPrepmtPurchaseLine."Quantity Invoiced")
        then
            TempPrepmtPurchaseLine."Qty. to Invoice" :=
              TempPrepmtPurchaseLine."Quantity Received" + TempPrepmtPurchaseLine."Qty. to Receive" +
              TempPrepmtPurchaseLine."Return Qty. Shipped (Base)" + TempPrepmtPurchaseLine."Return Qty. to Ship (Base)" -
              TempPrepmtPurchaseLine."Quantity Invoiced";

        TempPrepmtPurchaseLine.CalcFields("Qty. to Assign", "Qty. Assigned", "Item Charge Qty. to Handle");
        if Abs(TempPrepmtPurchaseLine."Item Charge Qty. to Handle" + TempPrepmtPurchaseLine."Qty. Assigned") >
           Abs(TempPrepmtPurchaseLine."Qty. to Invoice" + TempPrepmtPurchaseLine."Quantity Invoiced")
        then begin
            AdjustQtyToAssignForPurchLine(TempPrepmtPurchaseLine);

            TempPrepmtPurchaseLine.CalcFields("Qty. to Assign", "Qty. Assigned", "Item Charge Qty. to Handle");
            if Abs(TempPrepmtPurchaseLine."Item Charge Qty. to Handle" + TempPrepmtPurchaseLine."Qty. Assigned") >
               Abs(TempPrepmtPurchaseLine."Qty. to Invoice" + TempPrepmtPurchaseLine."Quantity Invoiced")
            then
                Error(CannotAssignMoreErr,
                  TempPrepmtPurchaseLine."Qty. to Invoice" + TempPrepmtPurchaseLine."Quantity Invoiced" - TempPrepmtPurchaseLine."Qty. Assigned",
                  TempPrepmtPurchaseLine.FieldCaption("Document Type"), TempPrepmtPurchaseLine."Document Type",
                  TempPrepmtPurchaseLine.FieldCaption("Document No."), TempPrepmtPurchaseLine."Document No.",
                  TempPrepmtPurchaseLine.FieldCaption("Line No."), TempPrepmtPurchaseLine."Line No.");

            CopyItemChargeForPurchLine(TempItemChargeAssgntPurch, TempPrepmtPurchaseLine);
        end;
        if TempPrepmtPurchaseLine.Quantity = TempPrepmtPurchaseLine."Qty. to Invoice" + TempPrepmtPurchaseLine."Quantity Invoiced" then begin
            if TempPrepmtPurchaseLine."Item Charge Qty. to Handle" <> 0 then
                if TempPrepmtPurchaseLine.Quantity = TempPrepmtPurchaseLine."Quantity Invoiced" then begin
                    TempItemChargeAssgntPurch.SetRange("Document Line No.", TempPrepmtPurchaseLine."Line No.");
                    TempItemChargeAssgntPurch.SetRange("Applies-to Doc. Type", TempPrepmtPurchaseLine."Document Type");
                    if TempItemChargeAssgntPurch.FindSet() then
                        repeat
                            PurchLine.Get(
                              TempItemChargeAssgntPurch."Applies-to Doc. Type",
                              TempItemChargeAssgntPurch."Applies-to Doc. No.",
                              TempItemChargeAssgntPurch."Applies-to Doc. Line No.");
                            if PurchLine.Quantity = PurchLine."Quantity Invoiced" then
                                Error(CannotAssignInvoicedErr, PurchLine.TableCaption(),
                                  PurchLine.FieldCaption("Document Type"), PurchLine."Document Type",
                                  PurchLine.FieldCaption("Document No."), PurchLine."Document No.",
                                  PurchLine.FieldCaption("Line No."), PurchLine."Line No.");
                        until TempItemChargeAssgntPurch.Next() = 0;
                end;
            if TempPrepmtPurchaseLine.Quantity <> TempPrepmtPurchaseLine."Item Charge Qty. to Handle" + TempPrepmtPurchaseLine."Qty. Assigned" then
                AssignError := true;
        end;

        if (TempPrepmtPurchaseLine."Item Charge Qty. to Handle" + TempPrepmtPurchaseLine."Qty. Assigned") < (TempPrepmtPurchaseLine."Qty. to Invoice" + TempPrepmtPurchaseLine."Quantity Invoiced") then
            Error(MustAssignItemChargeErr, TempPrepmtPurchaseLine."No.");

        // check if all ILEs exist
        QtyNeeded := TempPrepmtPurchaseLine."Item Charge Qty. to Handle";
        TempItemChargeAssgntPurch.SetRange("Document Line No.", TempPrepmtPurchaseLine."Line No.");
        if TempItemChargeAssgntPurch.FindSet() then
            repeat
                if (TempItemChargeAssgntPurch."Applies-to Doc. Type" <> TempPrepmtPurchaseLine."Document Type") or
                   (TempItemChargeAssgntPurch."Applies-to Doc. No." <> TempPrepmtPurchaseLine."Document No.")
                then
                    QtyNeeded := QtyNeeded - TempItemChargeAssgntPurch."Qty. to Handle"
                else begin
                    PurchLine.Get(
                      TempItemChargeAssgntPurch."Applies-to Doc. Type",
                      TempItemChargeAssgntPurch."Applies-to Doc. No.",
                      TempItemChargeAssgntPurch."Applies-to Doc. Line No.");
                    if ItemLedgerEntryExist(PurchLine, PurchaseHeader.Receive or PurchaseHeader.Ship) then
                        QtyNeeded := QtyNeeded - TempItemChargeAssgntPurch."Qty. to Handle";
                end;
            until TempItemChargeAssgntPurch.Next() = 0;

        if QtyNeeded <> 0 then
            Error(CannotInvoiceItemChargeErr, TempPrepmtPurchaseLine."No.");
    end;

    local procedure CopyItemChargeForPurchLine(var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchaseLine: Record "Purchase Line")
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        TempItemChargeAssignmentPurch.Reset();
        TempItemChargeAssignmentPurch.SetRange("Document Type", PurchaseLine."Document Type");
        TempItemChargeAssignmentPurch.SetRange("Document No.", PurchaseLine."Document No.");
        if not TempItemChargeAssignmentPurch.IsEmpty() then
            TempItemChargeAssignmentPurch.DeleteAll();

        ItemChargeAssgntPurch.Reset();
        ItemChargeAssgntPurch.SetRange("Document Type", PurchaseLine."Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.", PurchaseLine."Document No.");
        ItemChargeAssgntPurch.SetFilter("Qty. to Assign", '<>0');
        if ItemChargeAssgntPurch.FindSet() then
            repeat
                TempItemChargeAssignmentPurch.Init();
                TempItemChargeAssignmentPurch := ItemChargeAssgntPurch;
                TempItemChargeAssignmentPurch.Insert();
            until ItemChargeAssgntPurch.Next() = 0;
    end;

    local procedure AdjustQtyToAssignForPurchLine(var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        TempPurchaseLine.CalcFields("Qty. to Assign");

        ItemChargeAssgntPurch.Reset();
        ItemChargeAssgntPurch.SetRange("Document Type", TempPurchaseLine."Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.", TempPurchaseLine."Document No.");
        ItemChargeAssgntPurch.SetRange("Document Line No.", TempPurchaseLine."Line No.");
        ItemChargeAssgntPurch.SetFilter("Qty. to Assign", '<>0');
        if ItemChargeAssgntPurch.FindSet() then
            repeat
                ItemChargeAssgntPurch.Validate("Qty. to Assign",
                  TempPurchaseLine."Qty. to Invoice" * Round(ItemChargeAssgntPurch."Qty. to Assign" / TempPurchaseLine."Qty. to Assign",
                    UOMMgt.QtyRndPrecision()));
                ItemChargeAssgntPurch.Modify();
            until ItemChargeAssgntPurch.Next() = 0;

        TempPurchaseLine.CalcFields("Qty. to Assign");
        if TempPurchaseLine."Qty. to Assign" < TempPurchaseLine."Qty. to Invoice" then begin
            ItemChargeAssgntPurch.Validate("Qty. to Assign",
              ItemChargeAssgntPurch."Qty. to Assign" + Abs(TempPurchaseLine."Qty. to Invoice" - TempPurchaseLine."Qty. to Assign"));
            ItemChargeAssgntPurch.Modify();
        end;

        if TempPurchaseLine."Qty. to Assign" > TempPurchaseLine."Qty. to Invoice" then begin
            ItemChargeAssgntPurch.Validate("Qty. to Assign",
              ItemChargeAssgntPurch."Qty. to Assign" - Abs(TempPurchaseLine."Qty. to Invoice" - TempPurchaseLine."Qty. to Assign"));
            ItemChargeAssgntPurch.Modify();
        end;
    end;

    local procedure ItemLedgerEntryExist(PurchLine2: Record "Purchase Line"; ReceiveOrShip: Boolean): Boolean
    var
        HasItemLedgerEntry: Boolean;
    begin
        if ReceiveOrShip then
            // item ledger entry will be created during posting in this transaction
            HasItemLedgerEntry :=
            ((PurchLine2."Qty. to Receive" + PurchLine2."Quantity Received") <> 0) or
            ((PurchLine2."Qty. to Invoice" + PurchLine2."Quantity Invoiced") <> 0) or
            ((PurchLine2."Return Qty. to Ship" + PurchLine2."Return Qty. Shipped") <> 0)
        else
            // item ledger entry must already exist
            HasItemLedgerEntry :=
            (PurchLine2."Quantity Received" <> 0) or
            (PurchLine2."Return Qty. Shipped" <> 0);

        exit(HasItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLineItemCharge', '', false, false)]
    local procedure SkipJobCheckOnBeforeTestPurchCharge(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        ItemChargeZeroAmountErr: Label 'The amount for item charge %1 cannot be 0.', Comment = '%1 = Item Charge No.';
    begin
        IsHandled := true;
        if (PurchaseLine.Amount = 0) and (PurchaseLine.Quantity <> 0) then
            Error(ErrorInfo.Create(StrSubstNo(ItemChargeZeroAmountErr, PurchaseLine."No."), true, PurchaseLine));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeCheckInvoicedQuantity', '', false, false)]
    local procedure SkipErrorOnBefreoCheckInvoicedQty(ItemLedgEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry"; var IsHandled: Boolean; var ModifyEntry: Boolean)
    begin
        IsHandled := true;
        VerifyInvoicedQty(ItemLedgEntry, ValueEntry);
        ModifyEntry := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnValidateJobNoOnBeforeCheckJob', '', false, false)]
    local procedure SkipOnValidateJobNo(var Customer: Record Customer; var IsHandled: Boolean; var JobJournalLine: Record "Job Journal Line"; xJobJournalLine: Record "Job Journal Line")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Post Line", 'OnBeforeCheckJob', '', false, false)]
    local procedure SkipCheckOnBeforeCheckJob(Job: Record Job; var IsHandled: Boolean; var JobJournalLine: Record "Job Journal Line"; var JobRegister: Record "Job Register"; var NextEntryNo: Integer)
    begin
        IsHandled := true;
    end;

    local procedure VerifyInvoicedQty(ItemLedgerEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry")
    var
        ItemLedgEntry2: Record "Item Ledger Entry";
        ItemApplnEntry: Record "Item Application Entry";
        SalesShipmentHeader: Record "Sales Shipment Header";
        TotalInvoicedQty: Decimal;
        IsHandled: Boolean;
    begin
        if not (ItemLedgerEntry."Drop Shipment" and (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Purchase)) then
            exit;

        ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.", "Outbound Item Entry No.");
        ItemApplnEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntry."Entry No.");
        ItemApplnEntry.SetFilter("Item Ledger Entry No.", '<>%1', ItemLedgerEntry."Entry No.");
        if ItemApplnEntry.FindSet() then begin
            repeat
                ItemLedgEntry2.Get(ItemApplnEntry."Item Ledger Entry No.");
                TotalInvoicedQty += ItemLedgEntry2."Invoiced Quantity";
            until ItemApplnEntry.Next() = 0;
            if ItemLedgerEntry."Invoiced Quantity" > Abs(TotalInvoicedQty) then begin
                SalesShipmentHeader.Get(ItemLedgEntry2."Document No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Post-Line", 'OnBeforeInsertPlLineFromLedgEntry', '', false, false)]
    procedure GerwingChangesOnBeforeInsertPlLine(var IsHandled: Boolean; var JobLedgerEntry: Record "Job Ledger Entry")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineJobConsumption', '', false, false)]
    local procedure SkinPostJobConsumption(ItemJournalLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header"; PurchItemLedgEntryNo: Integer; QtyToBeInvoiced: Decimal; QtyToBeReceived: Decimal; SrcCode: Code[10]; var IsHandled: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchLine: Record "Purchase Line"; var TempPurchReservEntry: Record "Reservation Entry"; var TempTrackingSpecification: Record "Tracking Specification")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Purch. Release", 'OnAfterReleaseSetFilters', '', false, false)]
    local procedure SkipPurchLineFilterOnAfterReleaseSetFilters(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetCurrentKey("Document Type", "Document No.", "Location Code");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("Drop Shipment", false);
        PurchaseLine.SetRange("Work Center No.", '');
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterPurchaseLineOnPreDataItem', '', false, false)]
    local procedure SkipJobFilterOnAfterPurchaseLineOnPreDataItem(OneHeaderCreated: Boolean; var PurchaseLine: Record "Purchase Line"; WhseReceiptHeader: Record "Warehouse Receipt Header"; WhseShptHeader: Record "Warehouse Shipment Header")
    begin
        PurchaseLine.SetRange("Job No.");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseReceiptHeaderInsert', '', false, false)]
    local procedure SetIndivFieldsOnBeforeWhseReceiptHeaderInsert(var WarehouseReceiptHeader: Record "Warehouse Receipt Header"; var WarehouseRequest: Record "Warehouse Request")
    begin
        WarehouseReceiptHeader."Job No" := WarehouseRequest."Job No";   //G-ERP.RS 2019-07-09 Anfrage#233369
        WarehouseReceiptHeader.Ressource := WarehouseRequest.Ressource; //G-ERP.RS 2019-08-15 Anfrage#233369 
    end;

    //[EventSubscriber(ObjectType::Table, Database::"Job", 'OnBeforeTestBlocked', '', false, false)]
    // local procedure SkipTestBlocked(var IsHandled: Boolean; var Job: Record Job)
    // begin
    //     IsHandled := true;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterProcessPurchLines', '', false, false)]
    local procedure SetStatusAndMailFunctionsOnRunPurchPost(CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchLinesProcessed: Boolean; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var ReturnShipmentHeader: Record "Return Shipment Header"; WhseReceive: Boolean; WhseShip: Boolean)
    var
        Mailfunktionen: Codeunit Mailfunktionen;
    begin
        //G-ERP.RS 2019-08-21 Anfrage#233671
        SetStatusPurchase(PurchHeader);

        // G-ERP+ 15.02.2016
        IF PurchHeader.Receive THEN
            Mailfunktionen."MailErstellenEK-Lieferung"(PurchRcptHeader);
        // G-ERP- 15.02.2016
    end;

    procedure SetStatusPurchase(VAR PurchaseHeader_p: Record "Purchase Header")
    var
        PurchaseLine_l: Record "Purchase Line" temporary;
        Complet_Delivered_l: Boolean;
    begin
        //G-ERP.RS 2019-08-21 +++
        //Lieferung
        CLEAR(PurchaseLine_l);
        PurchaseLine_l.SETRANGE(PurchaseLine_l."Document Type", PurchaseHeader_p."Document Type");
        PurchaseLine_l.SETRANGE(PurchaseLine_l."Document No.", PurchaseHeader_p."No.");
        PurchaseLine_l.SETFILTER("Outstanding Quantity", '<>0');
        CASE PurchaseLine_l.ISEMPTY OF
            TRUE:
                Complet_Delivered_l := TRUE;
            FALSE:
                Complet_Delivered_l := FALSE;
        END;

        IF PurchaseHeader_p.Receive THEN BEGIN
            CASE Complet_Delivered_l OF
                TRUE:
                    PurchaseHeader_p."Status Purchase" := PurchaseHeader_p."Status Purchase"::delivered;
                FALSE:
                    PurchaseHeader_p."Status Purchase" := PurchaseHeader_p."Status Purchase"::"partly delivered";
            END;
            PurchaseHeader_p.MODIFY();
        END;

        //Rechnung
        CLEAR(PurchaseLine_l);
        IF PurchaseHeader_p.Invoice THEN BEGIN
            PurchaseLine_l.SETRANGE(PurchaseLine_l."Document Type", PurchaseHeader_p."Document Type");
            PurchaseLine_l.SETRANGE(PurchaseLine_l."Document No.", PurchaseHeader_p."No.");
            PurchaseLine_l.SETFILTER("Amt. Rcd. Not Invoiced", '<>0');

            //Nicht fakt. Lieferbetrag muss ungleich null sein und es muss komplett geliefert sein
            IF (PurchaseLine_l.ISEMPTY) AND Complet_Delivered_l THEN
                PurchaseHeader_p."Status Purchase" := PurchaseHeader_p."Status Purchase"::invoiced
            ELSE
                PurchaseHeader_p."Status Purchase" := PurchaseHeader_p."Status Purchase"::"partly invoiced";
            PurchaseHeader_p.MODIFY();
        END;
        //G-ERP.RS 2019-08-21 ---
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignFieldsForNo', '', true, true)]
    local procedure AssignCustomHeaderFieldsOnValidatePurchLineNo(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var xPurchLine: Record "Purchase Line")
    begin
        PurchLine."Job No." := PurchHeader."Job No.";
        xPurchLine."Job No." := PurchHeader."Job No.";
        PurchLine.Leistungszeitraum := PurchHeader.Leistungszeitraum;
        PurchLine.Leistungsart := PurchHeader.Leistungsart;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', 'Job No.', false, false)]
    local procedure SetDocumentNoOnAfterValidateJobNo(CurrFieldNo: Integer; var Rec: Record "Job Journal Line"; var xRec: Record "Job Journal Line")
    begin
        Rec."Document No." := rec."Job No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnCreatePurchHeaderOnBeforePurchOrderHeaderModify', '', true, true)]
    local procedure SetDatesAfterCreateQuoteToOrder(var PurchOrderHeader: Record "Purchase Header"; var PurchHeader: Record "Purchase Header")
    begin
        PurchOrderHeader."Order Date" := TODAY;
        PurchOrderHeader."Posting Date" := TODAY;
        PurchOrderHeader."Document Date" := TODAY;

        IF PurchHeader.Bestellnummer = '' THEN BEGIN
            PurchHeader.Bestellnummer := PurchOrderHeader."No.";
            PurchHeader.MODIFY();
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure OnAfterValidateNoInPurchLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        PurchaseHeader_l: Record "Purchase Header";
        ItemVendor_l: Record "Item Vendor";
        Item: Record Item;
    begin
        IF Rec.Type = Rec.Type::Item THEN BEGIN
            IF (Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote) THEN BEGIN
                PurchaseHeader_l.GET(Rec."Document Type", Rec."Document No.");
                IF ItemVendor_l.GET(PurchaseHeader_l."Buy-from Vendor No.", Rec."No.", Rec."Variant Code") THEN BEGIN
                    IF (Rec.Description = '') OR (Rec."No." <> xRec."No.") THEN
                        Rec.Description := ItemVendor_l.Description;
                    IF (Rec."Description 2" = '') OR (Rec."No." <> xRec."No.") THEN
                        Rec."Description 2" := ItemVendor_l."Description 2";
                END;
                item.GetItemNo(Rec."No.");
                IF (Rec."Description 3" = '') OR (Rec."No." <> xRec."No.") THEN
                    Rec."Description 3" := Item."Description 3";
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeLookupBuyFromContactNo', '', true, true)]
    local procedure OnBeforeLookupBuyFromContactNo(var IsHandled: Boolean; var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header")
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        IsHandled := true;

        if PurchaseHeader."Buy-from Vendor No." <> '' then
            if Contact.Get(PurchaseHeader."Buy-from Contact No.") then
                Contact.SetRange("Company No.", Contact."Company No.")
            else
                if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Vendor, PurchaseHeader."Buy-from Vendor No.") then
                    Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.")
                else
                    Contact.SetRange("No.", '');

        if PurchaseHeader."Buy-from Contact No." <> '' then
            if Contact.Get(PurchaseHeader."Buy-from Contact No.") then;

        Contact.SETRANGE("Organizational Level Code", 'VERKAUF');
        Contact.SetRange(Type, Contact.Type::Person);
        If Contact.FindSet() then;

        if Page.RunModal(0, Contact) = Action::LookupOK then begin
            xPurchaseHeader := PurchaseHeader;
            PurchaseHeader.Validate("Buy-from Contact No.", Contact."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertPurchHeader(RunTrigger: Boolean; var Rec: Record "Purchase Header")
    var
        Purchaser: Record "Salesperson/Purchaser";
    begin
        CLEAR(Purchaser);
        Purchaser.SETRANGE("User ID", USERID);
        IF Purchaser.FINDFIRST THEN
            Rec."Purchaser Code" := Purchaser.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeOnModify', '', true, true)]
    local procedure DoModifyContact(ContactBeforeModify: Record Contact; var Contact: Record Contact)
    var
        OldCont: Record Contact;
        Cont: Record Contact;
        IsDuplicateCheckNeeded: Boolean;
        UpdateCustVendBank: Codeunit "CustVendBank-Update";
        RMSetup: Record "Marketing Setup";
        ContChanged: Boolean;
    begin
        Contact.SetLastDateTimeModified();

        if (Contact.Type = Contact.Type::Company) and (Contact."No." <> '') then begin
            if IsUpdateNeeded(ContactBeforeModify, Contact) then
                UpdateCustVendBank.Run(Contact);

            RMSetup.Get();
            Cont.Reset();
            Cont.SetCurrentKey("Company No.");
            Cont.SetRange("Company No.", Contact."No.");
            Cont.SetRange(Type, Cont.Type::Person);
            Cont.SetFilter("No.", '<>%1', Contact."No.");
            if Cont.Find('-') then
                repeat
                    ContChanged := false;
                    OldCont := Cont;
                    if Contact.Name <> ContactBeforeModify.Name then begin
                        Cont."Company Name" := Contact.Name;
                        ContChanged := true;
                    end;
                    if RMSetup."Inherit Salesperson Code" and
                       (ContactBeforeModify."Salesperson Code" <> Contact."Salesperson Code") and
                       (ContactBeforeModify."Salesperson Code" = Cont."Salesperson Code")
                    then begin
                        Cont."Salesperson Code" := Contact."Salesperson Code";
                        ContChanged := true;
                    end;
                    if RMSetup."Inherit Territory Code" and
                       (ContactBeforeModify."Territory Code" <> Contact."Territory Code") and
                       (ContactBeforeModify."Territory Code" = Cont."Territory Code")
                    then begin
                        Cont."Territory Code" := Contact."Territory Code";
                        ContChanged := true;
                    end;
                    if RMSetup."Inherit Country/Region Code" and
                       (ContactBeforeModify."Country/Region Code" <> Contact."Country/Region Code") and
                       (ContactBeforeModify."Country/Region Code" = Cont."Country/Region Code")
                    then begin
                        Cont."Country/Region Code" := Contact."Country/Region Code";
                        ContChanged := true;
                    end;
                    if RMSetup."Inherit Language Code" and
                       (ContactBeforeModify."Language Code" <> Contact."Language Code") and
                       (ContactBeforeModify."Language Code" = Cont."Language Code")
                    then begin
                        Cont."Language Code" := Contact."Language Code";
                        ContChanged := true;
                    end;
                    if RMSetup."Inherit Address Details" then
                        if ContactBeforeModify.IdenticalAddress(Cont) then begin
                            if ContactBeforeModify.Address <> Contact.Address then begin
                                Cont.Address := Contact.Address;
                                ContChanged := true;
                            end;
                            if ContactBeforeModify."Address 2" <> Contact."Address 2" then begin
                                Cont."Address 2" := Contact."Address 2";
                                ContChanged := true;
                            end;
                            if ContactBeforeModify."Post Code" <> Contact."Post Code" then begin
                                Cont."Post Code" := Contact."Post Code";
                                ContChanged := true;
                            end;
                            if ContactBeforeModify.City <> Contact.City then begin
                                Cont.City := Contact.City;
                                ContChanged := true;
                            end;
                            if ContactBeforeModify.County <> Contact.County then begin
                                Cont.County := Contact.County;
                                ContChanged := true;
                            end;
                        end;
                    if RMSetup."Inherit Communication Details" then begin
                        if (ContactBeforeModify."Phone No." <> Contact."Phone No.") and (ContactBeforeModify."Phone No." = Cont."Phone No.") then begin
                            Cont."Phone No." := Contact."Phone No.";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Telex No." <> Contact."Telex No.") and (ContactBeforeModify."Telex No." = Cont."Telex No.") then begin
                            Cont."Telex No." := Contact."Telex No.";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Fax No." <> Contact."Fax No.") and (ContactBeforeModify."Fax No." = Cont."Fax No.") then begin
                            Cont."Fax No." := Contact."Fax No.";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Telex Answer Back" <> Contact."Telex Answer Back") and (ContactBeforeModify."Telex Answer Back" = Cont."Telex Answer Back") then begin
                            Cont."Telex Answer Back" := Contact."Telex Answer Back";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."E-Mail" <> Contact."E-Mail") and (ContactBeforeModify."E-Mail" = Cont."E-Mail") then begin
                            Cont.Validate("E-Mail", Contact."E-Mail");
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Home Page" <> Contact."Home Page") and (ContactBeforeModify."Home Page" = Cont."Home Page") then begin
                            Cont."Home Page" := Contact."Home Page";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Extension No." <> Contact."Extension No.") and (ContactBeforeModify."Extension No." = Cont."Extension No.") then begin
                            Cont."Extension No." := Contact."Extension No.";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify."Mobile Phone No." <> Contact."Mobile Phone No.") and (ContactBeforeModify."Mobile Phone No." = Cont."Mobile Phone No.") then begin
                            Cont."Mobile Phone No." := Contact."Mobile Phone No.";
                            ContChanged := true;
                        end;
                        if (ContactBeforeModify.Pager <> Contact.Pager) and (ContactBeforeModify.Pager = Cont.Pager) then begin
                            Cont.Pager := Contact.Pager;
                            ContChanged := true;
                        end;
                    end;

                    if ContChanged then begin
                        Cont.SetHideValidationDialog(true);
                        Cont.DoModify(OldCont);
                        Cont.Modify();
                    end;
                until Cont.Next() = 0;

            IsDuplicateCheckNeeded :=
              (Contact.Name <> ContactBeforeModify.Name) or
              (Contact."Name 2" <> ContactBeforeModify."Name 2") or
              (Contact.Address <> ContactBeforeModify.Address) or
              (Contact."Address 2" <> ContactBeforeModify."Address 2") or
              (Contact.City <> ContactBeforeModify.City) or
              (Contact."Post Code" <> ContactBeforeModify."Post Code") or
              (Contact."VAT Registration No." <> ContactBeforeModify."VAT Registration No.") or
              (Contact."Phone No." <> ContactBeforeModify."Phone No.");

            if IsDuplicateCheckNeeded then
                Contact.CheckDuplicates();
        end;
        Commit();
        exit;
    end;

    local procedure IsUpdateNeeded(ContactBeforeModify: Record Contact; var Rec: Record Contact): Boolean
    var
        UpdateNeeded: Boolean;
    begin
        UpdateNeeded :=
          (Rec.Name <> ContactBeforeModify.Name) or
          (Rec."Search Name" <> ContactBeforeModify."Search Name") or
          (Rec."Name 2" <> ContactBeforeModify."Name 2") or
          (Rec.Address <> ContactBeforeModify.Address) or
          (Rec."Address 2" <> ContactBeforeModify."Address 2") or
          (Rec.City <> ContactBeforeModify.City) or
          (Rec."Phone No." <> ContactBeforeModify."Phone No.") or
          (Rec."Mobile Phone No." <> ContactBeforeModify."Mobile Phone No.") or
          (Rec."Telex No." <> ContactBeforeModify."Telex No.") or
          (Rec."Territory Code" <> ContactBeforeModify."Territory Code") or
          (Rec."Currency Code" <> ContactBeforeModify."Currency Code") or
          (Rec."Language Code" <> ContactBeforeModify."Language Code") or
          (Rec."Salesperson Code" <> ContactBeforeModify."Salesperson Code") or
          (Rec."Country/Region Code" <> ContactBeforeModify."Country/Region Code") or
          (Rec."Fax No." <> ContactBeforeModify."Fax No.") or
          (Rec."Telex Answer Back" <> ContactBeforeModify."Telex Answer Back") or
          (Rec."VAT Registration No." <> ContactBeforeModify."VAT Registration No.") or
          (Rec."Post Code" <> ContactBeforeModify."Post Code") or
          (Rec.County <> ContactBeforeModify.County) or
          (Rec."E-Mail" <> ContactBeforeModify."E-Mail") or
          (Rec."Search E-Mail" <> ContactBeforeModify."Search E-Mail") or
          (Rec."Home Page" <> ContactBeforeModify."Home Page") or
          (Rec.Type <> ContactBeforeModify.Type);

        exit(UpdateNeeded);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeUpdateSearchName', '', true, true)]
    local procedure UpdateSearchName(var Contact: Record Contact; var IsHandled: Boolean; xContact: Record Contact)
    begin
        IsHandled := true;
        if (Contact."Search Name" = UpperCase(xContact.Name)) or (Contact."Search Name" = '') then
            Contact."Search Name" := Contact.Name;
        Commit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnBeforeFillDescription', '', true, true)]
    local procedure SkipFillItemDescription(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterUpdateVendorItemNoFromItemReference', '', true, true)]
    local procedure FindCorrectItemRefNo(var Rec: Record "Purchase Line")
    var
        Item: Record Item;
    begin
        if rec.Type = rec.Type::Item then begin
            if Item.Get(Rec."No.") then begin
                if Rec."Buy-from Vendor No." <> Item."Vendor No." then begin
                    Rec."Item Reference No." := '';
                    rec."Vendor Item No." := '';
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Post-Line", 'OnBeforeCheckItemQuantityPurchCredit', '', true, true)]
    local procedure SuppressJobConsumptionError(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, true)]
    local procedure SetItemLedgEntryOnAfterInit(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        NewItemLedgEntry.Description := ItemJournalLine.Description;
        NewItemLedgEntry."Goods Receiving Date" := ItemJournalLine."Goods Receiving Date";
        NewItemLedgEntry.Employee := ItemJournalLine.Employee;
        NewItemLedgEntry."Employee No." := ItemJournalLine."Employee No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCheckBalance', '', true, true)]
    local procedure SetBalanceZero(CurrentBalance: Decimal)
    begin
        CurrentBalance := 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateUnitOfMeasureCodeOnAfterCalcShouldUpdateItemReference', '', true, true)]
    local procedure SkipUpdateItemReference(var ShouldUpdateItemReference: Boolean)
    begin
        ShouldUpdateItemReference := false;
    end;
}

