trigger AvoidCreationOfMoreThanThreeSR on Territory__c (before insert) {
	
    List<Territory__c> terrList=new List<Territory__c>([select zip_code__c from Territory__c]);
    integer i=1;
    
    for(Territory__c t:Trigger.new)
    {
        for(Territory__c l:terrList)
        {
            if(t.zip_code__c==l.zip_code__c)
                i=i+1;
        }
        if(i>3)
            t.addError('Limit Exceeds!');
    }
}