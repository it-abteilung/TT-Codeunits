XmlPort 50015 "Payment Import"
{
    Caption = 'Payment Import';
    Direction = Import;
    FieldSeparator = ';';
    Format = VariableText;
    TableSeparator = '<NewLine>';
    TextEncoding = WINDOWS;

    schema
    {
        textelement(root)
        {
            tableelement("Gen. Journal Line"; "Gen. Journal Line")
            {
                AutoUpdate = true;
                XmlName = 'GenJnlLine';
                SourceTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.") where("Journal Template Name" = const('ZAHLUNGSEI'), "Journal Batch Name" = const('STANDARD'));
                textelement(BlankA)
                {
                }
                textelement(BlankB)
                {
                }
                textelement(BlankC)
                {
                }
                textelement(BlankD)
                {
                }
                textelement(BlankE)
                {
                }
                fieldelement(Amount; "Gen. Journal Line".Amount)
                {

                    trigger OnAfterAssignField()
                    begin
                        "Gen. Journal Line".Amount += PmtDisc;
                    end;
                }
                textelement(BlankG)
                {
                }
                textelement(BlankH)
                {
                }
                textelement(BlankI)
                {
                }
                // J
                textelement(AccNo)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        if AccNo = '' then
                            currXMLport.Break;

                        Evaluate(AccNoInt, AccNo);

                        if AccNoInt < 70000 then
                            currXMLport.Break;

                        if AccNo = '72418' then
                            currXMLport.Break;

                        "Gen. Journal Line"."Account Type" := "Gen. Journal Line"."account type"::Vendor;

                        Vendor.SetRange(DATEV, AccNo);
                        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                        if Vendor.FindFirst then
                            "Gen. Journal Line".Validate("Account No.", Vendor."No.");
                    end;
                }
                // K
                textelement(VendInvoiceNo)
                {
                }
                textelement(BlankL)
                {
                }
                // M
                textelement(PostingDate)
                {
                }
                textelement(BlankN)
                {
                }
                // O
                textelement(BalAccNo)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        if StrLen(BalAccNo) = 3 then
                            BalAccNo := '0' + BalAccNo;

                        "Gen. Journal Line".Validate("Bal. Account No.", BalAccNo);
                    end;
                }
                textelement(BlankP)
                {
                }
                textelement(BlankQ)
                {
                }
                textelement(BlankR)
                {
                }
                // S
                textelement(PaymentDiscount)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        if PaymentDiscount = '' then
                            PaymentDiscount := '0';
                        Evaluate(PmtDisc, PaymentDiscount);
                    end;
                }
                // T
                fieldelement(PostingDescription; "Gen. Journal Line".Comment)
                {
                }
                textelement(BlankU)
                {
                }
                textelement(BlankV)
                {
                }
                textelement(BlankW)
                {
                }
                textelement(BlankX)
                {
                }
                textelement(BlankY)
                {
                }
                textelement(BlankZ)
                {
                }
                textelement(BlankAA)
                {
                }
                textelement(BlankAB)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    l_GenJnlLine: Record "Gen. Journal Line";
                begin
                    "Gen. Journal Line"."Journal Template Name" := 'ZAHLUNGSAU';
                    "Gen. Journal Line"."Journal Batch Name" := 'SYSTEM';

                    LineNo += 10000;
                    "Gen. Journal Line"."Line No." := LineNo;
                    if "Gen. Journal Line".Amount > 0 then
                        "Gen. Journal Line"."Document Type" := "Gen. Journal Line"."document type"::Payment
                    else begin
                        "Gen. Journal Line"."Document Type" := "Gen. Journal Line"."document type"::Refund;
                    end;

                    "Gen. Journal Line"."Document No." := StrSubstNo(DocNo, Today);
                    "Gen. Journal Line"."Posting Date" := Today;

                    PurchInvHeader.SetCurrentkey("Vendor Invoice No.", "Posting Date");
                    PurchInvHeader.SetRange("Vendor Invoice No.", VendInvoiceNo);
                    if PurchInvHeader.Findset then begin
                        repeat
                            "Gen. Journal Line"."Line No." := LineNo;
                            "Gen. Journal Line"."Account Type" := "Gen. Journal Line"."account type"::Vendor;
                            if Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then
                                "Gen. Journal Line".Validate("Account No.", PurchInvHeader."Buy-from Vendor No.");
                            "Gen. Journal Line"."Bal. Account Type" := "Gen. Journal Line"."bal. account type"::"G/L Account";
                            "Gen. Journal Line"."Applies-to Doc. Type" := "Gen. Journal Line"."applies-to doc. type"::Invoice;
                            "Gen. Journal Line"."Applies-to Doc. No." := PurchInvHeader."No.";
                            "Gen. Journal Line"."External Document No." := PurchInvHeader."Vendor Invoice No.";
                            "Gen. Journal Line"."Currency Code" := PurchInvHeader."Currency Code";
                            LineNo += 10000;
                            if "Gen. Journal Line"."Payment Discount %" <> 0 then begin
                                PurchInvHeader.Validate("Payment Discount %", "Gen. Journal Line"."Payment Discount %");
                                PurchInvHeader."Pmt. Discount Date" := Today;
                                PurchInvHeader.Modify;
                            end;
                        until PurchInvHeader.Next = 0;
                    end else begin
                        "Gen. Journal Line"."Line No." := LineNo;
                        "Gen. Journal Line"."Account Type" := "Gen. Journal Line"."account type"::Vendor;
                        Vendor.SetRange(DATEV, AccNo);
                        if Vendor.FindFirst() then
                            "Gen. Journal Line".Validate("Account No.", Vendor."No.")
                        else
                            "Gen. Journal Line".Validate("Account No.", AccNo);
                        "Gen. Journal Line"."Bal. Account Type" := "Gen. Journal Line"."bal. account type"::"G/L Account";
                        "Gen. Journal Line"."Applies-to Doc. Type" := "Gen. Journal Line"."applies-to doc. type"::Invoice;
                        "Gen. Journal Line"."Applies-to Doc. No." := '';
                        "Gen. Journal Line"."External Document No." := VendInvoiceNo;
                        LineNo += 10000;
                    end;

                    PurchCrMemoHdr.SetCurrentkey("Vendor Cr. Memo No.", "Posting Date");
                    PurchCrMemoHdr.SetRange("Vendor Cr. Memo No.", VendInvoiceNo);
                    if PurchCrMemoHdr.Findset then begin
                        repeat
                            "Gen. Journal Line"."Line No." := LineNo;
                            "Gen. Journal Line"."Account Type" := "Gen. Journal Line"."account type"::Vendor;
                            if Vendor.Get(PurchCrMemoHdr."Buy-from Vendor No.") then
                                "Gen. Journal Line".Validate("Account No.", PurchCrMemoHdr."Buy-from Vendor No.");
                            "Gen. Journal Line"."Bal. Account Type" := "Gen. Journal Line"."bal. account type"::"G/L Account";
                            "Gen. Journal Line"."Applies-to Doc. Type" := "Gen. Journal Line"."applies-to doc. type"::"Credit Memo";
                            "Gen. Journal Line"."Applies-to Doc. No." := PurchCrMemoHdr."No.";
                            "Gen. Journal Line"."External Document No." := VendInvoiceNo;
                            "Gen. Journal Line".Validate(Amount, ("Gen. Journal Line".Amount * (-1)));
                            "Gen. Journal Line"."Currency Code" := PurchCrMemoHdr."Currency Code";
                            LineNo += 10000;
                        until PurchCrMemoHdr.Next = 0;
                    end else begin
                        "Gen. Journal Line"."Line No." := LineNo;
                        "Gen. Journal Line"."Account Type" := "Gen. Journal Line"."account type"::Vendor;
                        Vendor.SetRange(DATEV, AccNo);
                        if Vendor.FindFirst() then
                            "Gen. Journal Line".Validate("Account No.", Vendor."No.")
                        else
                            "Gen. Journal Line".Validate("Account No.", AccNo);
                        "Gen. Journal Line"."Bal. Account Type" := "Gen. Journal Line"."bal. account type"::"G/L Account";
                        "Gen. Journal Line"."Applies-to Doc. Type" := "Gen. Journal Line"."applies-to doc. type"::"Credit Memo";
                        "Gen. Journal Line"."Applies-to Doc. No." := '';
                        "Gen. Journal Line"."External Document No." := VendInvoiceNo;
                        "Gen. Journal Line".validate(Amount, ("Gen. Journal Line".Amount * (-1)));
                        "Gen. Journal Line"."Currency Code" := PurchCrMemoHdr."Currency Code";
                        LineNo += 10000;
                    end;

                    "Gen. Journal Line"."Bal. Gen. Posting Type" := "Gen. Journal Line"."bal. gen. posting type"::" ";
                    "Gen. Journal Line"."Bal. Gen. Bus. Posting Group" := '';
                    "Gen. Journal Line"."Bal. Gen. Prod. Posting Group" := '';
                    "Gen. Journal Line"."Bal. VAT Bus. Posting Group" := '';
                    "Gen. Journal Line"."Bal. VAT Prod. Posting Group" := '';
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        LineNo: Integer;
        PurchInvHeader: Record "Purch. Inv. Header";
        DocNo: label 'Zahlung %1';
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        Vendor: Record Vendor;
        PmtDisc: Decimal;
        AccNoInt: Integer;
}

