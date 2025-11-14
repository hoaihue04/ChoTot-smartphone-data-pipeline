USE [Chotot];
GO

--1======================= LẬP FULL BACKUP HÀNG TUẦN =============================
--Bước 1: Tạo thủ tục sao lưu full dữ liệu trong database

CREATE PROCEDURE sp_BackupFull
AS
BEGIN
    DECLARE @BackupFileName NVARCHAR(255);
    
    -- Tạo tên tệp sao lưu với ngày và giờ
    SET @BackupFileName = N'C:\Backup\Chotot_FullBackup_' + 
                          FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.bak';

    -- Sao lưu Full Backup cơ sở dữ liệu
    BACKUP DATABASE [Chotot]
    TO DISK				= @BackupFileName
    WITH INIT, NAME		= 'Full Backup of Chotot';
END;
GO

-- Bước 2: Tạo thủ tục sao lưu Full Backup hàng tuần
CREATE PROCEDURE sp_WeeklyFullBackupSchedule
AS
BEGIN
        -- Tạo công việc sao lưu Full Backup hàng tuần
        EXEC msdb.dbo.sp_add_job
            @job_name = N'WeeklyFullBackupJob',
            @enabled  = 1;

        -- Tạo bước công việc sao lưu Full Backup
        EXEC msdb.dbo.sp_add_jobstep
            @job_name				= 'WeeklyFullBackupJob',
            @step_name				= 'Step1',
            @subsystem				= 'TSQL',
            @command				= 'EXEC chotot.dbo.sp_BackupFull;',
            @database_name			= 'master',
            @on_success_action		= 1,
            @on_fail_action			= 2;

        -- Lên lịch hàng tuần (00:00 AM Chủ Nhật)
        EXEC msdb.dbo.sp_add_schedule
            @schedule_name          = N'WeeklyFullBackupSchedule',
            @enabled                = 1,
            @freq_type              = 8,         -- Lịch hàng tuần
            @freq_interval          = 1,         
            @freq_recurrence_factor = 1,         -- Chạy mỗi tuần
            @active_start_time      = 000000;    -- Thời gian: 00:00 AM

        -- Gắn lịch vào công việc
        EXEC msdb.dbo.sp_attach_schedule
            @job_name				= N'WeeklyFullBackupJob',
            @schedule_name			= N'WeeklyFullBackupSchedule';

        -- Kích hoạt công việc
        EXEC msdb.dbo.sp_add_jobserver
            @job_name				= N'WeeklyFullBackupJob',
            @server_name			= N'DESKTOP-778PBH1\HOAIHUESQL';
END;
GO


--2======================= LẬP DIFFERENTIAL BACKUP HÀNG NGÀY =============================

--Bước 1: Tạo thủ tục sao lưu differential dữ liệu trong database
CREATE PROCEDURE sp_BackupDifferential
AS
BEGIN
    DECLARE @BackupFileName NVARCHAR(255);
    
    -- Tạo tên tệp sao lưu với ngày và giờ
    SET @BackupFileName = N'C:\Backup\Chotot_DifferentialBackup_' + 
                          FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.bak';

    -- Sao lưu Differential Backup cơ sở dữ liệu
    BACKUP DATABASE [chotot]
    TO DISK = @BackupFileName
    WITH DIFFERENTIAL, 
         NAME = N'Differential Backup of chotot';
END;
GO
-- Bước 2: Tạo thủ tục sao lưu Diff Backup hàng ngày
CREATE PROCEDURE sp_DailyDifferentialBackupSchedule
AS
BEGIN
        -- Tạo công việc sao lưu Differential Backup hàng ngày
        EXEC msdb.dbo.sp_add_job
            @job_name			= N'DailyDifferentialBackupJob',
            @enabled			= 1;

        -- Tạo bước công việc sao lưu Differential Backup
        EXEC msdb.dbo.sp_add_jobstep
            @job_name			= 'DailyDifferentialBackupJob',
            @step_name			= 'Step2',
            @subsystem			= 'TSQL',
            @command			='EXEC chotot.dbo.sp_BackupDifferential;',
            @database_name		= 'master',
            @on_success_action	= 1,
            @on_fail_action		= 2;

        -- Lên lịch hàng ngày (01:00 AM)
        EXEC msdb.dbo.sp_add_schedule
            @schedule_name		= N'DailyDifferentialBackupSchedule',
            @enabled			= 1,
            @freq_type			= 4,         -- Lịch hàng ngày
            @freq_interval		= 1,         -- Mỗi ngày
            @active_start_time	= 010000;    -- Thời gian: 01:00 AM

        -- Gắn lịch vào công việc
        EXEC msdb.dbo.sp_attach_schedule
            @job_name			= N'DailyDifferentialBackupJob',
            @schedule_name		= N'DailyDifferentialBackupSchedule';

        -- Kích hoạt công việc
        EXEC msdb.dbo.sp_add_jobserver
            @job_name			= N'DailyDifferentialBackupJob',
            @server_name		= N'DESKTOP-778PBH1\HOAIHUESQL';
END;
GO
--Thực thi các thủ tục vừa tạo 
EXEC sp_WeeklyFullBackupSchedule;
EXEC sp_DailyDifferentialBackupSchedule;

--3======================= QUẢN LÝ SAO LƯU========================
--  XÓA CÁC TỆP SAO LƯU CŨ 
-- Bước 1: Thủ tục xóa các bản sao lưu cũ theo thời gian quy định
CREATE PROCEDURE sp_DeleteOldBackup
AS
BEGIN
    DECLARE @FullBackupDeleteBeforeDate DATETIME;
    DECLARE @DiffBackupDeleteBeforeDate DATETIME;
    DECLARE @BackupFolder				NVARCHAR(255);

    -- Đặt thời gian xóa cho từng loại sao lưu
    SET @FullBackupDeleteBeforeDate = DATEADD(DAY, -14, GETDATE()); -- Xóa Full Backup cũ hơn 14 ngày
    SET @DiffBackupDeleteBeforeDate = DATEADD(DAY, -7, GETDATE());  -- Xóa Differential Backup cũ hơn 7 ngày

    -- Đặt thư mục sao lưu
    SET @BackupFolder = N'C:\Backup\';

    BEGIN TRY
        -- Xóa các tệp sao lưu Full Backup cũ
        EXEC xp_delete_file 0, @BackupFolder, N'bak', @FullBackupDeleteBeforeDate;

        -- Xóa các tệp sao lưu Differential Backup cũ
        EXEC xp_delete_file 0, @BackupFolder, N'bak', @DiffBackupDeleteBeforeDate;

        PRINT N'Đã xóa thành công các bản sao lưu cũ';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi khi xóa các bản sao lưu cũ: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Bước 2: Tạo công việc xóa sao lưu cũ
CREATE PROCEDURE sp_CreateDeleteOldBackupsJob
AS
BEGIN
    --  Tạo công việc xóa sao lưu cũ
    EXEC msdb.dbo.sp_add_job
        @job_name				= N'DeleteOldBackupsJob',
        @enabled				= 1;
    
    --  Tạo bước công việc xóa sao lưu cũ
    EXEC msdb.dbo.sp_add_jobstep
        @job_name				= N'DeleteOldBackupsJob',
        @step_name				= N'DeleteOldBackupsStep',
        @subsystem				= N'TSQL',
        @command				= N'EXEC chotot.dbo.sp_DeleteOldBackups;',  -- Gọi thủ tục xóa sao lưu cũ
        @database_name			= 'master',
        @on_success_action		= 1,  -- Tiếp tục công việc nếu thành công
        @on_fail_action			= 2;    -- Dừng công việc nếu thất bại
    
    --  Tạo lịch cho công việc xóa sao lưu cũ
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name			= N'WeeklyDeleteOldBackupsSchedule',
        @enabled				= 1,
        @freq_type				= 8,        -- Weekly (hàng tuần)
        @freq_interval			= 1,    -- Chủ nhật
        @freq_recurrence_factor = 1,  -- Lặp lại 1 lần mỗi tuần
        @active_start_time		= 030000;  -- Thời gian bắt đầu 03:00:00
    
    --  Gắn lịch vào công việc
    EXEC msdb.dbo.sp_attach_schedule
        @job_name				= N'DeleteOldBackupsJob',
        @schedule_name			= N'WeeklyDeleteOldBackupsSchedule';
    
    --  Kích hoạt công việc
    EXEC msdb.dbo.sp_add_jobserver
        @job_name				= N'DeleteOldBackupsJob',
        @server_name			= N'DESKTOP-778PBH1\HOAIHUESQL';  -- Đặt tên máy chủ

    PRINT N'Job DeleteOldBackupsJob đã được tạo và cấu hình thành công.';
END;
GO
---Thực thi thủ tục
EXEC sp_CreateDeleteOldBackupsJob;


--TẠO BẢNG VÀ GHI LẠI NHẬT KÝ SAO LƯU

-- Stored procedure để tạo bảng và ghi lại nhật ký sao lưu
CREATE PROCEDURE sp_LogBackupHistory
AS
BEGIN
    -- Kiểm tra xem bảng BackupHistory đã tồn tại chưa, nếu chưa thì tạo mới
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BackupHistory' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        CREATE TABLE dbo.BackupHistory (
            BackupFileName NVARCHAR(255),
            BackupDate DATETIME,
            BackupType NVARCHAR(10)  -- Thêm cột để lưu loại sao lưu
        );
    END;

    DECLARE @BackupFileName NVARCHAR(255);
    DECLARE @BackupDate DATETIME;
    DECLARE @BackupType NVARCHAR(10);
    
    -- Lấy tên tệp sao lưu, ngày sao lưu và loại sao lưu từ bảng backupset và backupmediafamily
    SET @BackupFileName = (SELECT TOP 1 bmf.physical_device_name
                           FROM msdb.dbo.backupset bs
                           INNER JOIN msdb.dbo.backupmediafamily bmf 
                               ON bs.media_set_id = bmf.media_set_id
                           WHERE bs.database_name = 'chotot'
                           AND bs.type IN ('D', 'I')  -- 'D' = Full backup, 'I' = Differential backup
                           ORDER BY bs.backup_finish_date DESC);
    
    -- Lấy loại sao lưu (Full hay Differential)
    SET @BackupType = (SELECT TOP 1 
                       CASE 
                           WHEN bs.type = 'D' THEN 'Full Backup'
                           WHEN bs.type = 'I' THEN 'Differential Backup'
                       END
                       FROM msdb.dbo.backupset bs
                       WHERE bs.database_name = 'chotot'
                       AND bs.type IN ('D', 'I')
                       ORDER BY bs.backup_finish_date DESC);
    
    -- Lấy ngày hiện tại làm ngày sao lưu
    SET @BackupDate = GETDATE();
    
    -- Lưu thông tin sao lưu vào bảng lịch sử sao lưu
    INSERT INTO dbo.BackupHistory (BackupFileName, BackupDate, BackupType)
    VALUES (@BackupFileName, @BackupDate, @BackupType);
    
    PRINT N'Lịch sử sao lưu đã được ghi lại thành công';
END;
GO
EXEC sp_LogBackupHistory;
select * from BackupHistory