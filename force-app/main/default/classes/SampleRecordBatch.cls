public class SampleRecordBatch extends ChainableBatch {

	public static Integer methodCalls = 0;

	protected override Iterable<Object> start(Chainable.Context ctx) {
		methodCalls++;

        return (Iterable<Object>) [SELECT Phone FROM Account];
	}

	protected override void execute(Chainable.Context ctx, Iterable<Object> scope) {
		methodCalls++;
	}

	protected override void finish(Chainable.Context ctx) {
		methodCalls++;
	}
}