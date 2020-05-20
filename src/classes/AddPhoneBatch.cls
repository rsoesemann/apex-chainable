public class AddPhoneBatch extends Chainable {

	protected override Iterable<Object> start(Chainable.Context ctx) {
        return cast( [SELECT Phone FROM Account] );
	}

	protected override void execute(Chainable.Context ctx, Iterable<Object> scope) {
		List<Account> accounts = (List<Account>) scope;

		for(Account a : accounts) {
			a.Phone = '12435667574321';
		}

		update accounts;
	}

	protected override void finish(Chainable.Context ctx) {}
}