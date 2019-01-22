public abstract class Chainable implements Database.Batchable<SObject>, Database.Stateful {

	private Chainable successor;
	private Boolean synchronouslyInTests = false;


	// ABSTRACT

	protected abstract Iterable<SObject> start(Chainable.Context ctx);
	protected abstract void execute(Chainable.Context ctx, Iterable<SObject> scope);
	protected abstract void finish(Chainable.Context ctx);


	// PUBLIC

	public virtual Integer batchSize() {
		return 200;
	}


	public Iterable<SObject> start(Database.BatchableContext ctx) {
		return start(new Chainable.Context(ctx));
	}


	public void execute(Database.BatchableContext ctx, Iterable<SObject> scope) {
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


	// PRIVATE


	private void executeSynchronously() {
		Context nullCtx = new Context();

		Iterable<SObject> fullScope = start(nullCtx);
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
