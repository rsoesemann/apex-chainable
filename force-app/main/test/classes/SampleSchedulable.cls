public class SampleSchedulable extends ChainableSchedulable {

    protected override void execute(Context ctx) {
        for(CronTrigger cron : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :name()]) {
            System.abortJob(cron.Id);
        }

        Chainable_Test.log(this);
    }
}