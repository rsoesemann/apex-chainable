public abstract class ChainableBatch implements Database.Batchable<SObject>, Database.Stateful {

	private ChainableBatch successorBatch;
	private static final Id EMPTY_CTX = null;


	// ABSTRACT

	protected abstract Iterable<SObject> start(Id batchId);
	protected abstract void execute(Iterable<SObject> scope, Id batchId);
	protected abstract void finish(Id batchId);


	// PUBLIC

	public virtual Integer batchSize() {
		return 200;
	}

	public Iterable<SObject> start(Database.BatchableContext ctx) {
		return start(ctx.getJobId());
	}


	public void execute(Database.BatchableContext ctx, Iterable<SObject> scope) {
		execute(scope, ctx.getJobId());
	}


	public void finish(Database.BatchableContext ctx) {
		finish(ctx.getJobId());

		if(successorBatch != null) {
			successorBatch.execute();
		}
	}


	public ChainableBatch andThen(ChainableBatch batch) {
		if(successorBatch != null) {
			successorBatch.andThen(batch);
		}
		else {
			successorBatch = batch;
		}

		return this;
	}


	public void execute() {
		if(Test.isRunningTest()) {
			Iterable<SObject> fullScope = start(EMPTY_CTX);

			if(fullScope.iterator().hasNext()) {
				execute(fullScope, EMPTY_CTX);
				finish(EMPTY_CTX);

				if (successorBatch != null) {
					successorBatch.execute();
 				}
			}
			else if(successorBatch != null) {
				successorBatch.execute();
			}
		}
		else {
			Database.executeBatch(this, batchSize());
		}
	}
}
