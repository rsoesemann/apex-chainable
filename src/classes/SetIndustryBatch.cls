public class SetIndustryBatch extends Chainable {

	String value;

	public SetIndustryBatch(String value) {
		this.value = value;
	}

	protected override Iterable<Object> start(Chainable.Context ctx) {
		return cast( [SELECT Industry FROM Account] );
	}

	protected override void execute(Chainable.Context ctx, Iterable<SObject> scope) {
		List<Account> accounts = (List<Account>) scope;

		for(Account a : accounts) {
			a.Industry = value;
		}

		update accounts;
	}

	protected override void finish(Chainable.Context ctx) {}
}