public class SampleDataBatch extends ChainableDataBatch {

	protected override Database.QueryLocator start(Context ctx) {
		Chainable_Test.log(this);

        return Database.getQueryLocator([SELECT Phone FROM Account]);
	}


	protected override void execute(Context ctx, List<SObject> scope) {
		Chainable_Test.log(this);
	}


	protected override void finish(Context ctx) {
		Chainable_Test.log(this);
	}
}