public abstract class Chainable {

	@TestVisible
    private static final String INVALID_CLASS_MSG = 'Invalid class ';
	
	private Chainable previous;
	private Chainable next;

	private Map<String, Object> sharedVariables = new Map<String, Object>();


	// ABSTRACT

	protected abstract void executeAsynchronously();
	protected abstract void executeSynchronously(Context ctx);

	
	// VIRTUAL

	protected virtual void setDeferredArgs(String serializedArgs) {}

	
	protected virtual void setDeferredShared(String serializedShared) {
		Map<String, Object> hydratedShared = (Map<String, Object>)JSON.deserializeUntyped(serializedShared);
		for(String key : hydratedShared.keySet()) {
			setShared(key, hydratedShared.get(key));
		}
	}
	

	protected virtual String getDeferArgs() {
		return null;
	}


	protected virtual String getDeferShared() {
		return JSON.serialize(sharedVariables);
	}


	private virtual void handleDeferException(Exception e) {
		throw e;
	}

	// PUBLIC


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


	public Chainable then(Chainable successor) {
		if(next != null) {
			next.then(successor);
		}
		else {
			next = successor;
			next.previous = this;
			
			next.sharedVariables = sharedVariables;
		}

		return this;
	}


	public Chainable execute() {
		if(Test.isRunningTest()) {
			executeSynchronously(new Context());
			executeNext();
		}
		else {
			executeAsynchronously();
		}

		return this;
	}


    public Chainable setShared(String key, Object value) {
        sharedVariables.put(key, value);

		return this;
    }


    public Object getShared(String key) {
        return sharedVariables.get(key);
    }


	public Chainable executeDeferred() {

		List<Chainable__e> deferEvents = unlink();

		if(Limits.getLimitDMLStatements() < deferEvents.size()) {
			handleDeferException(new DeferLimitException());
		}

		for(Database.SaveResult publishResult : EventBus.publish(deferEvents)) {
			if(!publishResult.isSuccess()) {
				handleDeferException(new DeferPublishException(publishResult.getErrors()));
			}
		}

		return this;
    }

	@TestVisible
	private List<Chainable__e> unlink() {

		List<Chainable__e> deferEvents = new List<Chainable__e>();

		try {
			deferEvents.add(new Chainable__e(
				InstanceName__c = String.valueOf(this).substringBefore(':'), 
				Arguments__c = getDeferArgs(),
				Shared__c = getDeferShared()
			));
		}
		catch(Exception e) {
			handleDeferException(new DeferUnlinkException(e));
		}
		finally {
			if(next != null) {
				deferEvents.addAll(next.unlink());
			}
		}

		return deferEvents;
	}


	// PROTECTED

	protected void executeNext() {
		if(next != null) {
			next.execute();
		}
	}


	// INNER

	public class Context {

		private Object originalContext;

		public Context() {}

		public Context(Database.BatchableContext ctx) {
			originalContext = ctx;
		}

		public Context(QueueableContext ctx) {
			originalContext = ctx;
		}

		public Context(SchedulableContext ctx) {
			originalContext = ctx;
		}

		public Object get() {
			return originalContext;
		}
	}

	public class DeferredChainLink {

        @InvocableVariable(required=true)
        public Chainable__e deferEvent;

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


	public class DeferLimitException extends Exception {}
	public class DeferUnlinkException extends Exception {}
	public class DeferredIsNotChainableException extends Exception {}
	public class DeferPublishException extends Exception {
		public DeferPublishException(List<Database.Error> publishErrors) {
			List<String> messages = new List<String>();
			for(Database.Error error : publishErrors) {
				messages.add(error.getMessage());
			}

			setMessage(String.join(messages, '\n'));
		}	
	}
}
