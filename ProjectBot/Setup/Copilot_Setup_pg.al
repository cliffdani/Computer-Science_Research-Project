// src/Setup/CopilotSetupPage.Page.al
page 50200 "Jobs Copilot Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Jobs Copilot Setup";
    Caption = 'Jobs Copilot Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Azure AI Foundry Settings';

                field("Azure AI Endpoint"; Rec."Azure AI Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter your Azure AI Foundry endpoint URL';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter your Azure AI API Key';
                }
                field("Deployment Name"; Rec."Deployment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter your model deployment name';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable or disable the Jobs Copilot';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}