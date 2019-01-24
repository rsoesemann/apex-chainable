# Apex Chainable Batch [![Codacy Badge](https://api.codacy.com/project/badge/Grade/43edbab28bc1480b948d5659383ee802)](https://www.codacy.com/app/rsoesemann/apex-chainable-batch?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=rsoesemann/apex-chainable-batch&amp;utm_campaign=Badge_Grade)

<a href="https://githubsfdeploy.herokuapp.com?owner=rsoesemann&repo=apex-chainable-batch">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Apex Batches can be chained by calling the successor batch from the `finish()` method of the previous batch. But such hardcoding makes this model inflexible. It's hard to build the chain from outside, neighter from a central class nor on runtime dependant on business logic.

## With `Chainable`

The `Chainable` wrapper class of this repository overcomes those drawbacks.

 - No need to hardcode successor batch in `finish()` method
 - Created batch chains of arbitrary length without changing existing Batch classes
 - Allows asynchronous and synchronous testing of Batch chains

```java
      new SecondBatch()
            .then(FirstBatch())
            .then(ThirdBatch())
            ...
            .execute();
```

## Without `Chainable`

```java
class FirstBatch implements Batchable<SObject> {
    Iterator<SObject> start(BatchableContext ctx) { ... }

    void execute(BatchableContext ctx, List<Account> scope) { ... }

    void finish(BatchableContext ctx) {
        Database.enqueueBatch(new SecondBatch()); 
    }
}
```

```java
class SecondBatch implements Batchable<SObject> {
    Iterator<SObject> start(BatchableContext ctx) { ... }

    void execute(BatchableContext ctx, List<Account> scope) { ... }

    void finish(BatchableContext ctx) {
        Database.enqueueBatch(new ThirdBatch()); 
    }
}
```




