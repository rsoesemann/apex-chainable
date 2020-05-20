public abstract class Chainable implements Database.Batchable<Object>, Database.Stateful {

	private Chainable successor;
	private Boolean synchronouslyInTests = false;


	// ABSTRACT

	protected abstract Iterable<Object> start(Chainable.Context ctx);
	protected abstract void execute(Chainable.Context ctx, Iterable<Object> scope);
	protected abstract void finish(Chainable.Context ctx);


	// PUBLIC

	public Iterable<Object> start(Database.BatchableContext ctx) {
		return start(new Chainable.Context(ctx));
	}


	public void execute(Database.BatchableContext ctx, Iterable<Object> scope) {
		execute(new Chainable.Context(ctx), scope);
	}


	public void finish(Database.BatchableContext ctx) {
		finish(new Chainable.Context(ctx));

		if(successor != null) {
			successor.execute();
		}
	}


	public Chainable then(Chainable batch) {
		if(successor != null) {
			successor.then(batch);
		}
		else {
			successor = batch;
		}

		return this;
	}


	public Chainable synchronouslyInTests() {
		synchronouslyInTests = true;
		return this;
	}


	public void execute() {
		if(Test.isRunningTest() && synchronouslyInTests) {
			executeSynchronously();
		}
		else {
			Database.executeBatch(this, batchSize());
		}
	}


    // PROTECTED

    protected virtual Integer batchSize() {
        return 200;
    }


    protected Iterable<Object> cast(List<SObject> records) {
        return (Iterable<Object>) records;
    }


    protected List<SObject> cast(Iterable<Object> records) {
        return (List<SObject>) records;
    }


	// PRIVATE

	private void executeSynchronously() {
		Context nullCtx = new Context();

		Iterable<Object> fullScope = start(nullCtx);
		if(fullScope.iterator().hasNext()) {
			execute(nullCtx, fullScope);
			finish(nullCtx);
		}

		if(successor != null) {
			successor.synchronouslyInTests = synchronouslyInTests;
			successor.execute();
		}
	}


	// INNER

	public class Context {

		private Id jobId;
		private Id childJobId;

		private Context() {}

		public Context(Database.BatchableContext ctx) {
			jobId = ctx.getJobId();
			childJobId = ctx.getChildJobId();
		}

		public Id getChildJobId() {
			return childJobId;
		}

		public Id getJobId() {
			return jobId;
		}
	}
}
