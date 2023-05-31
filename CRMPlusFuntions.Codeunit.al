codeunit 82002 "CRMPlus Functions"
{
    procedure insertPerson(Contact: Record Contact; var ContactNew: Record Contact)
    var
        ChangeLogManagement: Codeunit "Change Log Management";
        recref: RecordRef;
    begin
        Contactnew.INIT;
        Contactnew."No." := '';
        Contactnew.INSERT(TRUE);
        recref.GETTABLE(Contactnew);
        ChangeLogManagement.LogInsertion(recref);
        Contactnew.VALIDATE(Type, Contact.Type::Person);
        Contactnew.VALIDATE("Company No.", Contact."Company No.");
        Contactnew.MODIFY(TRUE);
    end;

    procedure DeletePerson(Contact: Record Contact)
    begin
        Contact.Canceled := TRUE;
        Contact.MODIFY(TRUE);
    end;

    procedure markRed(Contact: Record Contact) Result: Boolean
    var
        Red: Record "Red Adress";
        BusRelation: Record "Contact Business Relation";
    begin
        Result := FALSE;
        Red.SETRANGE(Table, Red.Table::"Business Condition");
        IF Red.FIND('-') THEN
            REPEAT
                IF Contact."Business Condition" = Red.Code THEN
                    Result := TRUE;
            UNTIL Red.NEXT = 0;
        IF Result THEN
            EXIT;
        BusRelation.SETRANGE("Contact No.", Contact."Company No.");
        Red.SETRANGE(Table, Red.Table::"Business Relation");
        IF BusRelation.FIND('-') THEN
            REPEAT
                IF Red.FIND('-') THEN
                    REPEAT
                        IF Contact."Business Relations" = Red.Code THEN
                            Result := TRUE;
                    UNTIL Red.NEXT = 0;
            UNTIL BusRelation.NEXT = 0;
    end;

    procedure generatePhoneNo(Contact: Record Contact) CompletePhoneNo: Text[30]
    begin
        IF Contact.Type = Contact.Type::Company THEN BEGIN
            CompletePhoneNo := Contact."Dialing Code" + Contact."Phone No."
        END ELSE BEGIN
            IF Contact."Extension No." = '' THEN
                CompletePhoneNo := Contact."Dialing Code" + Contact."Phone No."
            ELSE
                IF STRPOS(Contact."Dialing Code", '-') = 0 THEN
                    CompletePhoneNo := Contact."Dialing Code" + Contact."Phone No."
                ELSE
                    CompletePhoneNo := Contact."Dialing Code" + COPYSTR(Contact."Phone No.", 1, STRPOS(Contact."Dialing Code", '-')) + Contact."Phone No.";
        END;
    end;

    procedure CreateTodo(Contact: Record Contact)
    var
        Todo: Record "To-do";
        TodoTemp: Record "To-do" temporary;
    begin
        Todo.RESET;
        Todo.SETRANGE("Contact No.", Contact."No.");
        TodoTEMP.CreateTaskFromTask(Todo);
    end;
}