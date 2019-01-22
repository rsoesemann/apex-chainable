@IsTest
public class AddPhoneBatch extends Chainable {

	protected override Iterable<SObject> start(Chainable.Context ctx) {
		return [SELECT Phone FROM Account];
	}

	protected override void execute(Chainable.Context ctx, Iterable<SObject> scope) {
		List<Account> accounts = (List<Account>) scope;

		for(Account a : accounts) {
			a.Phone = '12435667574321';
		}

		update accounts;
	}

	protected override void finish(Chainable.Context ctx) {}
}