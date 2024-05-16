public abstract class Chainable {

	private Chainable previous;
	private Chainable next;

	private Map<String, Object> sharedVariables = new Map<String, Object>();


	// ABSTRACT

	protected abstract void executeAsynchronously();
	protected abstract void executeSynchronously(Context ctx);

	
	// VIRTUAL

	public virtual void setDeferredArgs(String serializedArgs) {}

	
	public virtual void setDeferredShared(String serializedShared) {
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


	protected virtual void handleDeferException(Exception e) {
		throw e;
	}

	// PUBLIC

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


	public Chainable defer() {

		List<ChainableDeferredEvent__e> deferEvents = unlink();

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


	public List<ChainableDeferredEvent__e> unlink() {

		List<ChainableDeferredEvent__e> deferEvents = new List<ChainableDeferredEvent__e>();

		try {
			deferEvents.add(new ChainableDeferredEvent__e(
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


	public class DeferLimitException extends Exception {}
	public class DeferUnlinkException extends Exception {}
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
