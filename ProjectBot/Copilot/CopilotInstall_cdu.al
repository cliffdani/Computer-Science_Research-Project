codeunit 50200 "Jobs Copilot Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrl: Text;
    begin
        LearnMoreUrl := 'https://learn.microsoft.com/dynamics365/business-central/';

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Jobs Assistant") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"Jobs Assistant",
                LearnMoreUrl
            );
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", OnRegisterCopilotCapability, '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;
}