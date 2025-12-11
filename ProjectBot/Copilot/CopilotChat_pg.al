// src/Copilot/JobsCopilotChat.Page.al
page 50201 "Jobs Copilot Chat"
{
    PageType = PromptDialog;
    ApplicationArea = All;
    Caption = 'Jobs Assistant';
    IsPreview = true;
    Extensible = false;

    layout
    {
        area(Prompt)
        {
            field(UserPrompt; UserPromptText)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
                InstructionalText = 'Ask me about jobs, tasks, or planning lines...';
            }
        }
        area(Content)
        {
            field(AIResponse; AIResponseText)
            {
                ApplicationArea = All;
                Caption = 'Assistant Response';
                MultiLine = true;
                Editable = false;
            }
            group(JobContext)
            {
                Caption = 'Current Job Context';
                Visible = HasJobContext;

                field(JobNo; CurrentJobNo)
                {
                    ApplicationArea = All;
                    Caption = 'Job No.';
                    Editable = false;
                }
                field(JobDescription; CurrentJobDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Ask';
                ToolTip = 'Send your question to the AI assistant';

                trigger OnAction()
                begin
                    SendToAI();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Close';
            }
        }
        area(PromptGuide)
        {
            action(SuggestTasks)
            {
                Caption = 'Suggest tasks for this job';

                trigger OnAction()
                begin
                    UserPromptText := 'Suggest common tasks I should create for this job.';
                end;
            }
            action(ReviewPlanning)
            {
                Caption = 'Review planning lines';

                trigger OnAction()
                begin
                    UserPromptText := 'Review the current planning lines and suggest improvements.';
                end;
            }
            action(EstimateCosts)
            {
                Caption = 'Help estimate costs';

                trigger OnAction()
                begin
                    UserPromptText := 'Help me estimate costs for the remaining tasks.';
                end;
            }
        }
    }

    var
        UserPromptText: Text;
        AIResponseText: Text;
        CurrentJobNo: Code[20];
        CurrentJobDescription: Text[100];
        HasJobContext: Boolean;

    procedure SetJobContext(JobNo: Code[20])
    var
        Job: Record Job;
    begin
        if Job.Get(JobNo) then begin
            CurrentJobNo := Job."No.";
            CurrentJobDescription := Job.Description;
            HasJobContext := true;
        end;
    end;

    local procedure SendToAI()
    var
        AzureAI: Codeunit "Azure AI Client 2";
        ContextText: Text;
        Response: Text;
    begin
        if UserPromptText = '' then begin
            AIResponseText := 'Please enter a question or request.';
            exit;
        end;

        ContextText := BuildJobContext();

        // Debug: Show what we're sending
        Message('Sending prompt: %1', UserPromptText);

        Response := AzureAI.SendChatMessage(UserPromptText, ContextText);

        // Debug: Show what we got back
        Message('Got response: %1', Response);

        AIResponseText := Response;
    end;

    local procedure BuildJobContext(): Text
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ContextBuilder: TextBuilder;
        TaskCount: Integer;
    begin
        if CurrentJobNo = '' then
            exit('No job selected.');

        if Job.Get(CurrentJobNo) then begin
            ContextBuilder.AppendLine('JOB DETAILS:');
            ContextBuilder.AppendLine('- Job No: ' + Job."No.");
            ContextBuilder.AppendLine('- Description: ' + Job.Description);
            ContextBuilder.AppendLine('- Customer: ' + Job."Bill-to Name");
            ContextBuilder.AppendLine('- Status: ' + Format(Job.Status));

            // Count tasks
            JobTask.SetRange("Job No.", Job."No.");
            TaskCount := JobTask.Count();
            ContextBuilder.AppendLine('- Total Tasks: ' + Format(TaskCount));

            // List first few tasks
            ContextBuilder.AppendLine('EXISTING TASKS:');
            JobTask.SetRange("Job No.", Job."No.");
            if JobTask.FindSet() then
                repeat
                    ContextBuilder.AppendLine('  - ' + JobTask."Job Task No." + ': ' + JobTask.Description);
                until (JobTask.Next() = 0) or (JobTask.Count > 5);
        end;

        exit(ContextBuilder.ToText());
    end;
}