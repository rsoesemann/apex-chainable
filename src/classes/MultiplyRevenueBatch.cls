@IsTest
public class MultiplyRevenueBatch extends Chainable {

	private Decimal multiplier;

	public MultiplyRevenueBatch(Decimal multiplier) {
		this.multiplier = multiplier;
	}

	protected override Iterable<SObject> start(Chainable.Context ctx) {
		return [SELECT AnnualRevenue FROM Account];
	}

	protected override void execute(Chainable.Context ctx, Iterable<SObject> scope) {
		List<Account> accounts = (List<Account>) scope;

		for(Account a : accounts) {
			a.AnnualRevenue *= multiplier;
		}

		update accounts;
	}

	protected override void finish(Chainable.Context ctx) {}
}