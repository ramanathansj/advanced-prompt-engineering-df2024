
/**
 * @description       : Gemini PDF extraction Promoting Example
 * @author            : Ramanathan
**/


public with sharing class GeminiPromptHandlerV1 {

    @InvocableMethod(label='Get PDF Data Prompt' description='returns invoice pdf details as JSON' category='InvoiceAI')
    public static PromptResp[] getPDFJSONPrompt(List<sObject> files) {
        System.debug(LoggingLevel.DEBUG, 'files == '+files);
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id = :files[0].Id];
        System.debug('ContentVersion == '+cv);
        String encodedData = EncodingUtil.base64Encode(cv.VersionData);
        List<PromptResp> responses = new List<PromptResp>();
        try {
            String jsonData = gcpPDFPromptCallout(encodedData);
            System.debug(LoggingLevel.DEBUG, 'jsonData == '+jsonData);
            PromptResp resp = new PromptResp();
            resp.invoiceStr = jsonData;
            resp.status = true;
            responses.add(resp);
        } catch (Exception e) {
            System.debug('Exception occured == '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return responses;
    }
       

    public static String gcpPDFPromptCallout(String pdfStr) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String host = GeminiPromptHandlerV1.getHostName();
        req.setEndpoint(host);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String body = JSON.serialize(new Map<String, String>{'api_key' => 'GCP_Pass_9999', 'pdf_string' => pdfStr});
        System.debug(LoggingLevel.DEBUG, 'body === '+body);
        req.setBody(body);
        req.setTimeout(20000);
        res = http.send(req);
        System.debug(LoggingLevel.Debug, 'response == '+res.getBody());
        return res.getBody();
    }

    private  static String getHostName() {
        GCPCallOut__mdt[] gcpSetings = [select Id, Host__c, DeveloperName from GCPCallOut__mdt where DeveloperName = 'gcp_dpf_prompt'];
        return gcpSetings != Null ? gcpSetings[0].Host__c : '';
    }

    public class PromptResp {
        @InvocableVariable public String invoiceStr;
        @InvocableVariable public Boolean status;

        public PromptResp() {
            this.invoiceStr = '';
            this.status = false;
        }
    }
}