public abstract class ChainableSchedulable extends Chainable implements Schedulable {

    protected String cronExpression = '0 0 12 * * ?';
    protected String name = thisClassName();


    // ABSTRACT

    protected abstract void execute(Chainable.Context ctx);


    // PUBLIC

    public ChainableSchedulable cron(String value) {
        cronExpression = value;
        return this;
    }


    public ChainableSchedulable name(String value) {
        name = value;
        return this;
    }


    public void execute(SchedulableContext ctx) {
        execute(new Chainable.Context(ctx));

        executeNext();
    }


    public override void executeAsynchronously() {
        System.schedule(name, cronExpression, this);
    }


    public override void executeSynchronously() {
        execute(new Chainable.Context());
    }


    // PRIVATE

    private String thisClassName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
}
