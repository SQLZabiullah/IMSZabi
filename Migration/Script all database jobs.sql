-- Retrieve all jobs and their details
SELECT 
    jobs.job_id AS JobID,
    jobs.name AS JobName,
    jobs.enabled AS IsEnabled,
    jobs.description AS JobDescription,
    CASE 
        WHEN jobactivity.run_requested_date IS NULL AND jobactivity.stop_execution_date IS NULL THEN 'Idle'
        WHEN jobactivity.run_requested_date IS NOT NULL AND jobactivity.stop_execution_date IS NULL THEN 'Running'
        WHEN jobactivity.run_requested_date IS NOT NULL AND jobactivity.stop_execution_date IS NOT NULL THEN 'Completed'
    END AS JobStatus,
    schedules.name AS ScheduleName,
    schedules.enabled AS IsScheduleEnabled,
    schedules.freq_type AS FrequencyType,
    schedules.freq_interval AS FrequencyInterval,
    schedules.freq_subday_type AS SubdayType,
    schedules.freq_subday_interval AS SubdayInterval,
    schedules.active_start_date AS ActiveStartDate,
    schedules.active_end_date AS ActiveEndDate,
    schedules.active_start_time AS ActiveStartTime,
    schedules.active_end_time AS ActiveEndTime
FROM 
    msdb.dbo.sysjobs AS jobs
LEFT JOIN 
    msdb.dbo.sysjobschedules AS jobschedules
    ON jobs.job_id = jobschedules.job_id
LEFT JOIN 
    msdb.dbo.sysschedules AS schedules
    ON jobschedules.schedule_id = schedules.schedule_id
LEFT JOIN 
    msdb.dbo.sysjobactivity AS jobactivity
    ON jobs.job_id = jobactivity.job_id
ORDER BY 
    jobs.name;
