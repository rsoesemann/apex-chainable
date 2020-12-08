public class SampleSchedulable extends ChainableSchedulable {

    public static Integer methodCalls = 0;

    protected override void execute(Chainable.Context ctx) {
        System.abortJob([SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :name].Id);

        methodCalls++;
    }
}