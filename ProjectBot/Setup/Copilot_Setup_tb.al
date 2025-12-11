// src/Setup/CopilotSetup.Table.al
table 50200 "Jobs Copilot Setup"
{
    Caption = 'Jobs Copilot Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Azure AI Endpoint"; Text[250])
        {
            Caption = 'Azure AI Endpoint';

        }
        field(3; "API Key"; Text[100])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
        field(4; "Deployment Name"; Text[100])
        {
            Caption = 'Deployment Name';

        }
        field(5; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Boolean
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
        exit(Enabled and ("API Key" <> '') and ("Azure AI Endpoint" <> ''));
    end;
}