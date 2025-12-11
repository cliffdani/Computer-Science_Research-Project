pageextension 50200 "Job Card Copilot Ext" extends "Job Card"
{
    actions
    {
        addlast(Processing)
        {
            action(OpenJobsCopilot)
            {
                ApplicationArea = All;
                Caption = 'Ask Copilot';
                ToolTip = 'Open AI assistant for help with this job';
                Image = SparkleFilled;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    JobsCopilotChat: Page "Jobs Copilot Chat";
                begin
                    JobsCopilotChat.SetJobContext(Rec."No.");
                    JobsCopilotChat.RunModal();
                end;
            }
        }
    }
}
