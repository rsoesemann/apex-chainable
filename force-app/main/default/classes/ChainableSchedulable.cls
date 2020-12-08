public abstract class ChainableSchedulable extends Chainable
                                           implements Schedulable, Database.AllowsCallouts {
    // ABSTRACT

    protected abstract void execute(Context ctx);


    // PUBLIC

    public void execute(SchedulableContext ctx) {
        execute(new Context(ctx));

        executeNext();
    }


    public override void executeAsynchronously() {
        System.schedule(name(), cronExpression(), this);
    }


    public override void executeSynchronously(Context ctx) {
        execute(ctx);
    }


    public virtual String cronExpression() {
        // Note: Every minute
        return '0 1 0 * * ?';
    }


    public virtual String name() {
        // Note: This class name
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
}
