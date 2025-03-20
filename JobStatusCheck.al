codeunit 50020 "Job Status Check"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'SendJobStatusMail':
                begin
                    SendJobStatusMail();
                end;
        end;
    end;

    procedure SendJobStatusMail()
    var
        Job_L: Record Job;
        Resource_L: Record Resource;
        User_L: Record User;
        EMail_C: Codeunit EMail;
        EMailMessage_C: Codeunit "EMail Message";
        EmailRecipientType_E: Enum "Email Recipient Type";
        Date_L: Date;
        Position_L: Integer;

        ToRecipent: Text[250];
    begin
        Clear(User_L);
        if User_L.FindSet() then
            repeat
                Resource_L.SetRange("User ID", User_L."User Name");
                if Resource_L.FindFirst() then begin
                    Job_L.SetLoadFields("No.", Description, "Person Responsible", Status);
                    Job_L.SetRange("Person Responsible", Resource_L."No.");
                    Job_L.SetFilter("Status Modify Date", '<> %1', 0D);
                    Job_L.SetFilter(Status, '%1 | %2 | %3 | %4', Job_L.Status::Quote, Job_L.Status::Open, Job_L.Status::Invoiced, Job_L.Status::"Gewährleistung");

                    if Job_L.FindSet() then begin
                        // Add E-Mail Header
                        EMailMessage_C.Create(User_L."Contact Email", 'Offene Projekte - Statusübersicht', '', true);
                        // Add E-Mail Body Part 1
                        EMailMessage_C.AppendToBody('<style>* {font-family: "Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important;font-weight: normal !important;font-style: normal !important;text-transform: none !important;}Table {font-family: Arial, Helvetica, sans-serif;background-color: #FFFFFF;border-collapse: collapse;width: 100%;table-layout: fixed;}Table td, Table th {  border-bottom: 1px solid #333;padding: 3px 12px;}Table th {  font-size: 15px;font-weight: bold;padding-top: 12px;padding-bottom: 12px;padding-left: 12px;text-align: left;background-color: #FFFFFF;}thead tr th:first-child, tbody tr td:first-child {max-width: 20px;pref-width: 20px;}</style>');

                        EMailMessage_C.AppendToBody('Auflistung aller Projekte, diese seit mindestens 3 Wochen keine Statusänderung erhalten haben. </br></br>');
                        EMailMessage_C.AppendToBody('<table><tr><th>Position</th><th>Projektnr.</th><th>Beschreibung</th><th>Status</th><th>Letzte Statusänderung</th></tr>');

                        Position_L := 1;
                        repeat
                            Date_L := CalcDate('+0W', Job_L."Status Modify Date");
                            if Today >= Date_L then begin
                                EMailMessage_C.AppendToBody(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td></tr>', Position_L, Job_L."No.", Job_L.Description, Job_L.Status, Job_L."Status Modify Date"));
                                Position_L += 1;
                            end;
                        until Job_L.Next() = 0;

                        EMail_C.Send(EMailMessage_C);

                        Commit();
                    end;


                end;
            until User_L.Next() = 0;
    end;
}