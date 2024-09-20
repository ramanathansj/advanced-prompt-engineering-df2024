
/**
 * @description       : FewShot Promoting Example
 * @author            : Ramanathan
**/

public with sharing class FewShotPromptV1 {

    @InvocableMethod(CapabilityType='FlexTemplate://Few_Shot_Prompt_V1')
    public static Response[] encodeJSONData(List<Request> reqs) {
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id = :reqs[0].FileData.Id];
        String encodedData = EncodingUtil.base64Encode(cv.VersionData);
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = encodedData;
        responses.add(res);
        return responses;
    }
       
    public class Request {
        @InvocableVariable
        public ContentVersion FileData;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}