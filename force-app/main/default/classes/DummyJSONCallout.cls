/**
 * DummyJSONCallout class
 * 
 * The purpose of this class is to implement callouts to the Dummy JSON API to retrieve and send user data.
 * This class will be called from the ContactTrigger.trigger when a contact is created or updated.
 * 
 * Documentation References:
 * - API callouts: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts.htm
 * - Named Credentials: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials.htm
 * - Integration Patterns: https://developer.salesforce.com/docs/atlas.en-us.integration_patterns_and_practices.meta/integration_patterns_and_practices/integ_pat_intro_overview.htm
 * - Future Methods: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
 * - HTTP Classes: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http.htm
 * - HttpRequest Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
 */

public with sharing class DummyJSONCallout {

	/* 
	 * Question 1
	 * Calls DummyJSON API to retrieve a user record by ID.
	 * If the HTTP response code is successful, parse the JSON response and update/insert the contact.
	 * 
	 * Documentation References:
	 * - Future Methods: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
	 * - HTTP Classes: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http.htm
	 * - HttpRequest Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
	 * 
     * @param dummyUserId The ID of the user in the external system to fetch data for.
     */
    @future(callout=true)
	public static void getDummyJSONUserFromId(String dummyUserId) {
		// Create HTTP request to send.
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
		// Set the endpoint URL. Use direct URL or for best practices use Named Credential.
        request.setEndpoint('callout:DummyJsonUser/' + dummyUserId);
        
		// Set the HTTP method to GET.
        request.setMethod('GET');
        
        try {
            // Send the HTTP request and get the response.
            HttpResponse response = http.send(request);
            
            // If the HTTP response code is successful, parse the JSON response and update the contact.
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                Contact cont = createContactFromJson(response.getBody());
                cont.DummyJSON_Id__c = dummyUserId;
                upsert cont DummyJSON_Id__c; //insert/update from the JSON response using the external id (dummyUserId)
            } else {
                System.debug('HTTP request failed with status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred during callout: ' + e.getMessage());
        }
	}

	/* 
	 * Question 2
	 * Create a contact from the JSON response.
	 * 
	 * Documentation References:
	 * - JSON Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm
	 * - JSON Parsing: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_json_overview.htm
	 * 
	 * @param jsonResponse The JSON response from the DummyJSON API.
	 * @return A Contact object created from the JSON response.
	 */
	@TestVisible // Allows test class to see this method. Since it is private, it would not be visible otherwise.
	public static Contact createContactFromJson(String jsonResponse) {
		// Deserialize the JSON string into map of primitive data types.
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        
		// Create a new contact from the JSON response.
        Contact cont = new Contact();
        
		// Set the contact fields from the JSON response.
        cont.Email = (String)jsonData.get('email');
        cont.Phone = (String)jsonData.get('phone');
        
        // Add firstName and lastName fields
        if (jsonData.containsKey('firstName')) {
            cont.FirstName = (String)jsonData.get('firstName');
        }
        if (jsonData.containsKey('lastName')) {
            cont.LastName = (String)jsonData.get('lastName');
        }
        
        // Parse the birthdate string to a Date
        if (jsonData.containsKey('birthDate')) {
            String birthDateStr = (String)jsonData.get('birthDate');
            cont.Birthdate = Date.valueOf(birthDateStr);
        }
        
		// Deserialize the address from the JSON response.
        if (jsonData.containsKey('address')) {
            Map<String, Object> addressData = (Map<String, Object>)jsonData.get('address');
            
		    // Set the address fields on the contact.
            if (addressData.containsKey('address')) {
                cont.MailingStreet = (String)addressData.get('address');
            }
            if (addressData.containsKey('city')) {
                cont.MailingCity = (String)addressData.get('city');
            }
            if (addressData.containsKey('postalCode')) {
                cont.MailingPostalCode = (String)addressData.get('postalCode');
            }
            if (addressData.containsKey('state')) {
                cont.MailingState = (String)addressData.get('state');
            }
            if (addressData.containsKey('country')) {
                cont.MailingCountry = (String)addressData.get('country');
            }
        }

		return cont;
	}

	/* 
	 * Question 3
	 * Calls DummyJSON API with POST method to create a user in the external system.
	 * Use the generateDummyJsonUserPayload method to generate the JSON payload.
	 * If the HTTP response code is successful, update the contact with updated DummyJSON_Last_Updated__c datetime.
	 * 
	 * Documentation References:
	 * - Future Methods: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
	 * - HTTP Classes: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http.htm
	 * - HttpRequest Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
	 * 
     * @param contactId The Salesforce Contact ID used to generate the JSON payload for the external system.
     */
	@future(callout=true)
	public static void postCreateDummyJSONUser(String contactId) {
		// Create HTTP request to send.
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
		// Set the endpoint URL. Use direct URL or for best practices use Named Credential.
        request.setEndpoint('callout:DummyJsonUser/add');
        
		// Set the HTTP method to POST.
        request.setMethod('POST');
        
        // Set content type header
        request.setHeader('Content-Type', 'application/json');
        
        try {
            // Set the body using generateDummyJsonUserPayload method.
            String jsonPayload = generateDummyJsonUserPayload(contactId);
            request.setBody(jsonPayload);
            
            // Send the HTTP request and get the response.
            HttpResponse response = http.send(request);
            
            // If the HTTP response code is successful, update the contact.
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                Contact cont = new Contact(
                    Id = contactId,
                    DummyJSON_Last_Updated__c = Datetime.now()
                );
                update cont;
            } else {
                System.debug('HTTP request failed with status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred during callout: ' + e.getMessage());
        }
	}

	/*
	 * Question 4
	 * Generate a JSON payload for the DummyJSON API from the Salesforce Contact.
	 * 
	 * Documentation References:
	 * - JSON Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm
	 * - JSON Generation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_json_overview.htm
	 * 
	 * @param contactId The Salesforce Contact ID used to generate the JSON payload for the external system.
	 * @return A JSON string to send to the DummyJSON API.
	 */
	@TestVisible // Allows test class to see this method. Since it is private, it would not be visible otherwise.
	public static String generateDummyJsonUserPayload(String contactId) {
		// Query the contact to get the field values to generate the JSON payload.
        Contact cont = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :contactId LIMIT 1];
        
		// Create a map of the field values.
        Map<String, Object> payloadMap = new Map<String, Object>();
        
		// Serialize the map into a JSON string.
		// Make sure to check that required contacts fields have a value. Default the value to unknown if it does not exists.
		// Integration data can change over time. It is a best practice to add safeguards/validation to ensure the integration does not break.
        payloadMap.put('salesforceId', cont.Id);
        payloadMap.put('firstName', String.isBlank(cont.FirstName) ? 'Unknown' : cont.FirstName);
        payloadMap.put('lastName', String.isBlank(cont.LastName) ? 'Unknown' : cont.LastName);
        payloadMap.put('email', String.isBlank(cont.Email) ? 'unknown@example.com' : cont.Email);
        payloadMap.put('phone', String.isBlank(cont.Phone) ? '0000000000' : cont.Phone);
        
        return JSON.serialize(payloadMap);
	}
}