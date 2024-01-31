codeunit 50007 "Job Subscriber"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnBeforeThrowAssociatedEntriesExistError', '', false, false)]
    local procedure BeforeThrowAssociatedEntriesExistError(var Job: Record Job; xJob: Record Job; CallingFieldNo: Integer; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}