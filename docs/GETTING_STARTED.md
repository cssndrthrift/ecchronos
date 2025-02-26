
## Repair Agent
ecChronos is an agent that simplifies and automates repairs. Each instance of ecChronos is designed to keep a single Cassandra node repaired.
It first calculates all the ranges that need to be repaired per table and then groups nodes by the ranges they have in common.

One repair is run against a Cassandra node per range as if running repair with -st and -et flags.

A lock table within Cassandra ensures that nodes do not run repairs at the same time. How the locking mechanism behaves
can be configured in [ecc.yml](../application/src/main/resources/ecc.yml).

ecChronos uses repair history saved in Cassandra to know what is and isn't repaired. It ensures that the same thing
will not need to be repaired multiple times per interval by keeping track of the latest repaired time. If a range fails,
it will return to the scheduler to be run at a later time.

Priority is given to every range that needs to be repaired. The priority is based on the number of hours since it has
been last repaired to ensure that the oldest ranges are repaired first. Failing repairs will therefore gain higher and higher
priority with time.

## Configuration

The default settings assume a GC Grace Second setting of 10 days. Repair will be run once on every table every interval which
defaults to 7 days. If 8 days have passed on a range without a repair then a warning will be logged. If 10 days have passed an ERROR is logged.

Tune these parameters to fit your use case in [ecc.yml](../application/src/main/resources/ecc.yml)

## Starting ecChronos

Installation information can be found in [SETUP.md](SETUP.md).

When ecChronos is started, it will assume that a table is repaired if no repair history exists.
If no repair history is found, it will wait the interval and then begin repairing each table.

If more fine grained control is required over which tables and keyspaces will be repaired,
this can be configured in [schedule.yml](../application/src/main/resources/schedule.yml)

If repair history exists, ecChronos will take the last time repair was run and add the interval for the next repair time.


## Ecctool



### Schedules

Running ecctool schedules will give an overview of the current schedules keeping tables updated.


```bash
----------------------------------------------------------------------------------------------------------------------------------------------------
| Id                                   | Keyspace  | Table                   | Status    | Repaired(%) | Completed at        | Next repair         | 
----------------------------------------------------------------------------------------------------------------------------------------------------
| 10f0ea60-3585-11ed-86d2-4fb526f4f28a | repair    | rep486                  | ON_TIME   | 24.22       | 2022-09-20 10:00:35 | 2022-09-20 12:00:33 | 
| 1313a350-3585-11ed-a474-87c1392dbca4 | repair    | rep487                  | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
| 15089580-3585-11ed-8bcb-f1d1bbd61061 | repair    | rep488                  | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
| 16cf72d0-3585-11ed-b921-350e95eb41ad | repair    | rep489                  | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
| a5348710-34ed-11ed-8794-0d445a53d0c8 | repair    | rep49                   | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
| 18e5a8a0-3585-11ed-aaa4-e74f24a4aded | repair    | rep490                  | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
| 1a9be420-3585-11ed-984f-cde131d276a2 | repair    | rep491                  | ON_TIME   | 0.00        | 2022-09-20 10:00:35 | 2022-09-20 12:00:35 | 
```

The status shows COMPLETED when the repair has completed within the interval. If not all ranges are repaired within the interval, the status
shows ON_TIME instead. LATE and OVERDUE will be shown when ranges have not repaired for 8 and 10 days respectively. These late and overdue times can be tuned in ecc.yaml
to fit your use case.

Repaired shows how many ranges are repaired. Note that this value can go up and down as ranges become unrepaired since last interval.

Completed at shows the time when all ranges are repaired. ecChronos assumes a range is repaired if there is no history.

### Repairs

ecctool repairs shows an overview of all manually triggered repairs

### RepairInfo

ecctool repair-info gives you an idea of what has been repaired. Giving your interval can help you determine how many of your ranges have been
repaired during the given time.

For more information on the different commands, see [ECCTOOL.md](ECCTOOL.md).


## Web Server

By default ecChronos starts a web server that can be configured in [application.yml](../application/src/main/resources/application.yml).
The server is based on springboot and most features springboot has are exposed here. More information on the API can be found in [REST.md](REST.md).


## Security

If your use case requires security, the three interfaces ecChronos provides can be secured.
For CQL and JMX, the security options can be found in [security.yml](../application/src/main/resources/security.yml).
For the web server these options can be found in the [application.yml](../application/src/main/resources/application.yml).

| Feature        	| JMX 	| CQL 	| Web 	|
|----------------	|-----	|-----	|-----	|
| TLS            	| Yes 	| Yes 	| Yes 	|
| Authentication 	| Yes 	| Yes 	| No  	|
| Authorization  	| Yes 	| Yes 	| No  	|


## Statistics

Statistics are enabled by default but can be disabled in [ecc.yaml](../application/src/main/resources/ecc.yml). More information on
what metrics to expect can be found in [METRICS.md](METRICS.md). Statistics can also be excluded for more fine grained control on what to save.
Note that something like logrotate is needed to archieve/delete old files.