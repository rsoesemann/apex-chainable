public with sharing class DeferredChainableBuilder {
    
    @TestVisible
    private static final String INVALID_CLASS_MSG = 'Invalid class ';

    @InvocableMethod(label='Rebuild chain from deferred chainables and execute')
    public static List<DeferRebuildResult> rebuildAndExecuteChain(List<DeferredChainLink> deferredLinks) {
        Chainable chain;
        Chainable iteratingInstance;

        List<DeferRebuildResult> results = new List<DeferRebuildResult>();

        for(DeferredChainLink deferredLink : deferredLinks) {

            try {
                iteratingInstance = deferredLink.getLinkableInstance();
                
                if(chain == null) {
                    chain = iteratingInstance;
                } 
                else {
                    chain.then(iteratingInstance);
                }
                results.add(new DeferRebuildResult());
            }
            catch(Exception e) {
                results.add(new DeferRebuildResult(e.getMessage()));
            }
        }

        chain?.execute();

        return results;
    }

    public class DeferredChainLink {

        @InvocableVariable(required=true)
        public ChainableDeferredEvent__e deferEvent;

        public Chainable getLinkableInstance() {
            Chainable linkableInstance;

            Type jobType = Type.forName(deferEvent.InstanceName__c);

            if(jobType != null && Chainable.class.isAssignableFrom(jobType)) {
                
                linkableInstance = (Chainable)jobType.newInstance();
                linkableInstance.setDeferredShared(deferEvent.Shared__c);
                if(String.isNotBlank(deferEvent.Arguments__c)) {
                    linkableInstance.setDeferredArgs(deferEvent.Arguments__c);
                }
            }
            else {
                throw new DeferredIsNotChainableException(INVALID_CLASS_MSG + deferEvent.InstanceName__c);
            }

            return linkableInstance;
        }
    }

    public class DeferRebuildResult {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String error;

        public DeferRebuildResult() {
            success = true;
        }

        public DeferRebuildResult(String errorDetail) {
            success = false;
            error = errorDetail;
        }
    }

    public class DeferredIsNotChainableException extends Exception {}
}