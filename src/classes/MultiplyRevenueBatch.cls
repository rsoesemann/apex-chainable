public class MultiplyRevenueBatch extends Chainable {

	private Decimal multiplier;

	public MultiplyRevenueBatch(Decimal multiplier) {
		this.multiplier = multiplier;
	}

	protected override Iterable<Object> start(Chainable.Context ctx) {
		return (Iterable<Object>) [SELECT AnnualRevenue FROM Account];
	}

	protected override void execute(Chainable.Context ctx, Iterable<Object> scope) {
		List<Account> accounts = (List<Account>) scope;

		for(Account a : accounts) {
			a.AnnualRevenue *= multiplier;
		}

		update accounts;
	}

	protected override void finish(Chainable.Context ctx) {}
}