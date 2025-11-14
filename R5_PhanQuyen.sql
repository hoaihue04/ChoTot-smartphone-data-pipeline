CREATE PROCEDURE CreateRolesAndGrantPermissions
AS
BEGIN
    -- Bước 1: Tạo nhóm các Role
    CREATE ROLE Admin; -- Nhóm quyền Admin
    CREATE ROLE DE;    -- Nhóm quyền Data Engineer
    CREATE ROLE DA;    -- Nhóm quyền Data Analyst

	-- Bước 2: Cấp quyền cho từng Role
    -- Cấp quyền cho Admin (toàn quyền trên cơ sở dữ liệu)
    GRANT ALL ON DATABASE::Chotot TO Admin;

    -- Cấp quyền cho DE (thêm, sửa, xóa, truy vấn dữ liệu, thêm/sửa/xóa thủ tục và hàm)
    GRANT CREATE PROCEDURE, CREATE FUNCTION ON DATABASE::Chotot TO DE; 
	GRANT CONTROL ON SCHEMA::dbo TO DE;                                

    -- Cấp quyền cho DA (chỉ được truy vấn dữ liệu trên bảng)
    GRANT SELECT ON DATABASE::Chotot TO DA;

    -- Bước 3: Tạo Login cho các User
    CREATE LOGIN AdminLogin WITH PASSWORD = 'adminpassword'; -- Login cho Admin
    CREATE LOGIN DELogin    WITH PASSWORD = 'depassword';    -- Login cho DE
    CREATE LOGIN DALogin    WITH PASSWORD = 'dapassword';    -- Login cho DA

    -- Bước 4: Tạo User trong cơ sở dữ liệu
    CREATE USER AdminUser FOR LOGIN AdminLogin; -- User cho Admin
    CREATE USER DEUser    FOR LOGIN DELogin;    -- User cho DE
    CREATE USER DAUser    FOR LOGIN DALogin;    -- User cho DA

    -- Bước 5: Thêm User vào các Role
    ALTER ROLE Admin ADD MEMBER AdminUser; -- Gán AdminUser vào nhóm Admin
    ALTER ROLE DE    ADD MEMBER DEUser;    -- Gán DEUser vào nhóm DE
    ALTER ROLE DA    ADD MEMBER DAUser;    -- Gán DAUser vào nhóm DA

    -- Bước 6: Kiểm tra các Role và quyền đã gán
    SELECT dp.name AS RoleName, mp.name AS MemberName
    FROM sys.database_role_members rm
    JOIN sys.database_principals dp ON rm.role_principal_id = dp.principal_id
    JOIN sys.database_principals mp ON rm.member_principal_id = mp.principal_id;
END;

EXEC CreateRolesAndGrantPermissions;
drop procedure CreateRolesAndGrantPermissions;

----------------------------
-- Tạo thủ tục thu hồi quyền và xóa Role, User, Login
CREATE PROCEDURE RevokePermissionsAndDropRoles
AS
BEGIN
    -- Bước 1: Thu hồi các quyền từ Role
    -- Thu hồi quyền cho Admin
    REVOKE ALL ON DATABASE::Chotot TO Admin;

    -- Thu hồi quyền cho DE
    REVOKE CREATE PROCEDURE, CREATE FUNCTION ON DATABASE::Chotot TO DE;
    REVOKE CONTROL ON SCHEMA::dbo TO DE;

    -- Thu hồi quyền cho DA
    REVOKE SELECT ON DATABASE::Chotot TO DA;

    -- Bước 2: Xóa User khỏi các Role
    ALTER ROLE Admin DROP MEMBER AdminUser;
    ALTER ROLE DE    DROP MEMBER DEUser;
    ALTER ROLE DA    DROP MEMBER DAUser;

    -- Bước 3: Xóa Role
    DROP ROLE Admin;
    DROP ROLE DE;
    DROP ROLE DA;

    -- Bước 4: Xóa User trong cơ sở dữ liệu
    DROP USER AdminUser;
    DROP USER DEUser;
    DROP USER DAUser;

    -- Bước 5: Xóa Login trong hệ thống
    DROP LOGIN AdminLogin;
    DROP LOGIN DELogin;
    DROP LOGIN DALogin;

    -- Bước 6: Kiểm tra và xác minh (tuỳ chọn)
    SELECT name, type_desc FROM sys.database_principals WHERE type IN ('R', 'S');
END;

-- Thực thi thủ tục
EXEC RevokePermissionsAndDropRoles;

-------------------------

SELECT 
    dp.name AS PrincipalName, 
    dp.type_desc AS PrincipalType, 
    p.permission_name
FROM 
    sys.database_permissions p
JOIN 
    sys.database_principals dp 
    ON p.grantee_principal_id = dp.principal_id
WHERE 
    p.class_desc = 'DATABASE'
ORDER BY 
    PrincipalName, 
    permission_name;

