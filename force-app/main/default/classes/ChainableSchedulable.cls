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
        Datetime dt = Datetime.now().addMinutes(1);
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ?';
    }


    public virtual String name() {
        // Note: This class name
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
}
