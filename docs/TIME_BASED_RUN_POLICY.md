# Time based run policy

Time based run policy is used to prevent schedules to run during specific time windows.
The configuration is read from a table `ecchronos.reject_configuration`.

When a schedule is about to run, it's validated against the time based run policy to check if it's allowed to,
if not the schedule will be run after the run policy allows it.

To see if the schedule is blocked check `schedules` using [ecctool](ECCTOOL.md).

## Example configuration

The example below will block all schedules from running between 11:00-11:10.

    INSERT INTO ecchronos.reject_configuration(keyspace_name,table_name,start_hour,start_minute,end_hour,end_minute) VALUES ('*','*',11,0,11,10);

The example below will block schedules for keyspace `exampleks` and table `exampletable` from running between 11:00-11:10.
Schedules for other tables will not be affected.

    INSERT INTO ecchronos.reject_configuration(keyspace_name,table_name,start_hour,start_minute,end_hour,end_minute) VALUES ('exampleks','exampletable',11,0,11,10);

The example below will block all schedules from running forever.

    INSERT INTO ecchronos.reject_configuration(keyspace_name,table_name,start_hour,start_minute,end_hour,end_minute) VALUES ('*','*',0,0,0,0);

