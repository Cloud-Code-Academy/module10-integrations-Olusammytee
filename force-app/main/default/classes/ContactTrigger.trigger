/**
 * ContactTrigger
 * 
 * This trigger handles callouts to the DummyJSONCallout class to retrieve/send user data from the Dummy JSON API.
 * 
 * When contacts are inserted:
 * - If DummyJSON_Id__c is null, a random number between 0 and 100 is generated and set as the contact's DummyJSON_Id__c
 * - If DummyJSON_Id__c is less than or equal to 100, the getDummyJSONUserFromId API is called
 * 
 * When contacts are updated:
 * - If DummyJSON_Id__c is greater than 100, the postCreateDummyJSONUser API is called
 * 
 * Note: HTTP callouts cannot be performed in the same transaction as DML operations.
 * This is why we need to use @future methods in the DummyJSONCallout class.
 * 
 * @see DummyJSONCallout
 * 
 * Optional Challenge: Use a trigger handler class to implement the trigger logic.
 */
trigger ContactTrigger on Contact(before insert, after insert, after update) {
    // When a contact is inserted in the before context
    if (Trigger.isBefore && Trigger.isInsert) {
        for (Contact cont : Trigger.new) {
            // If DummyJSON_Id__c is null, generate a random number between 0 and 100 and set this as the contact's DummyJSON_Id__c value
            if (cont.DummyJSON_Id__c == null) {
                // Generate a random number between 0 and 100
                Double randomValue = Math.random() * 100;
                cont.DummyJSON_Id__c = String.valueOf(Math.round(randomValue));
            }
        }
    }
    
    // When a contact is inserted in the after context
    // If DummyJSON_Id__c is less than or equal to 100, call the getDummyJSONUserFromId API
    if (Trigger.isAfter && Trigger.isInsert) {
        for (Contact cont : Trigger.new) {
            if (cont.DummyJSON_Id__c != null && Integer.valueOf(cont.DummyJSON_Id__c) <= 100) {
                DummyJSONCallout.getDummyJSONUserFromId(cont.DummyJSON_Id__c);
            }
        }
    }
    
    // When a contact is updated in the after context
    // If DummyJSON_Id__c is greater than 100, call the postCreateDummyJSONUser API
    if (Trigger.isAfter && Trigger.isUpdate) {
        for (Contact cont : Trigger.new) {
            if (cont.DummyJSON_Id__c != null && Integer.valueOf(cont.DummyJSON_Id__c) > 100) {
                DummyJSONCallout.postCreateDummyJSONUser(cont.Id);
            }
        }
    }
}