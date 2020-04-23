trigger changeOwnerOnZipCode on Account(before update) {
    
    Map<Id,Territory__c> terrSet =new Map<Id,Territory__c>();
    terrSet.putAll([select zip_code__c,owner__c from Territory__c]);
    
    integer i=0;
    
    Set<ID> accId=new Set<ID>();
    for(Account a:Trigger.new)
    {
        accId.add(a.Id);
    }
    
    List<Contact> updateList=new List<Contact>();
    List<Opportunity> updatedOpp=new List<Opportunity>();
    
    for (Account newAcc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(newAcc.Id);
        if (oldAcc.BillingPostalCode!= newAcc.BillingPostalCode) {
            for(Account a:Trigger.new)
            {
                for(Territory__c t: terrSet.values())
                {
                    if(newAcc.BillingPostalCode==t.zip_code__c)
                    {
                        a.OwnerId=t.Owner__c;
                        i=1; 
                        for(Contact c:[select id,ownerid from Contact where accountid in:accId])
                        {
                        	c.ownerid =t.Owner__c;
                            updateList.add(c);
                            
                        }
                        upsert updateList;
                        
                        for(Opportunity opp:[select id,StageName from Opportunity where AccountId in:accId])
                        {
                            if(opp.StageName!='Closed Won' && opp.StageName!='Closed Lost')
                            {
                                opp.ownerid =t.Owner__c;
                            	updatedOpp.add(opp);
                            }                            
                        }
                        if (!updatedOpp.isEmpty()) {
        					update updatedOpp;
   		 				} 
                    } 
                }
                if(i!=1)
                    a.addError('Invalid ZipCode.');  
            }  
        }       
    }   
}