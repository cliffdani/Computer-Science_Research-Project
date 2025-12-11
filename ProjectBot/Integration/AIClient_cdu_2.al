codeunit 50202 "Azure AI Client 2"
{
    procedure SendChatMessage(UserMessage: Text; JobContext: Text): Text
    var
        Setup: Record "Jobs Copilot Setup";
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        RequestBody: Text;
        ResponseText: Text;
        EndpointUrl: Text;
    begin
        if not Setup.GetSetup() then
            Error('Jobs Copilot is not configured. Please go to Jobs Copilot Setup page first.');

        RequestBody := BuildRequestBody(UserMessage, JobContext);

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        EndpointUrl := BuildEndpointUrl(Setup);

        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(EndpointUrl);
        HttpRequest.Content := HttpContent;

        HttpRequest.GetHeaders(RequestHeaders);
        RequestHeaders.Add('api-key', Setup."API Key");

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('Failed to connect to Azure AI. Check your endpoint URL: %1', EndpointUrl);

        HttpResponse.Content.ReadAs(ResponseText);

        if not HttpResponse.IsSuccessStatusCode() then
            Error('Azure AI Error (HTTP %1): %2',
                HttpResponse.HttpStatusCode(),
                ResponseText);

        exit(ParseResponse(ResponseText));
    end;

    local procedure BuildEndpointUrl(Setup: Record "Jobs Copilot Setup"): Text
    var
        BaseUrl: Text;
    begin
        BaseUrl := Setup."Azure AI Endpoint";

        if not BaseUrl.EndsWith('/') then
            BaseUrl := BaseUrl + '/';

        exit(StrSubstNo('%1openai/deployments/%2/chat/completions?api-version=2024-08-01-preview',
            BaseUrl,
            Setup."Deployment Name"));
    end;

    local procedure BuildRequestBody(UserMessage: Text; JobContext: Text): Text
    var
        RequestJson: JsonObject;
        MessagesArray: JsonArray;
        SystemMessage: JsonObject;
        UserMsg: JsonObject;
        ResultText: Text;
    begin
        SystemMessage.Add('role', 'system');
        SystemMessage.Add('content', GetSystemPrompt(JobContext));
        MessagesArray.Add(SystemMessage);

        UserMsg.Add('role', 'user');
        UserMsg.Add('content', UserMessage);
        MessagesArray.Add(UserMsg);
        RequestJson.Add('messages', MessagesArray);
        RequestJson.Add('max_completion_tokens', 16000);
        // Removed temperature - not supported by gpt-5-nano

        RequestJson.WriteTo(ResultText);
        exit(ResultText);
    end;

    local procedure GetSystemPrompt(JobContext: Text): Text
    begin
        exit(
            'You are a helpful assistant for Microsoft Dynamics 365 Business Central Jobs module. ' +
            'Help users manage Job Tasks and Job Planning Lines. Be concise and helpful. ' +
            'Context: ' + JobContext
        );
    end;

    local procedure ParseResponse(ResponseText: Text): Text
    var
        JsonResponse: JsonObject;
        ChoicesArray: JsonArray;
        ChoiceToken: JsonToken;
        MessageToken: JsonToken;
        ContentToken: JsonToken;
    begin
        /*Message('Raw AI Response: %1', CopyStr(ResponseText, 1, 1000));*/

        if not JsonResponse.ReadFrom(ResponseText) then
            exit('Error: Could not parse AI response.');

        if not JsonResponse.Get('choices', ChoiceToken) then
            exit('Error: No choices in response.');

        ChoicesArray := ChoiceToken.AsArray();

        if ChoicesArray.Count() = 0 then
            exit('Error: Empty response.');

        ChoicesArray.Get(0, ChoiceToken);

        if not ChoiceToken.AsObject().Get('message', MessageToken) then
            exit('Error: No message found.');

        if not MessageToken.AsObject().Get('content', ContentToken) then
            exit('Error: No content found.');

        /*Message('Extracted content: %1', ContentToken.AsValue().AsText());*/

        exit(ContentToken.AsValue().AsText());
    end;
}