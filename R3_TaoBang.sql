CREATE PROCEDURE TaoBangVaChuyenDuLieu
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo bảng CuaHang
    CREATE TABLE CuaHang 
	(
		CuaHangId			INT PRIMARY KEY IDENTITY(1,1),
		TenCuaHang			NVARCHAR(255),
		DiemDanhGia			FLOAT,
		SoLuotDanhGia		NVARCHAR(255)
	);

    -- Tạo bảng Hang
    CREATE TABLE Hang 
	(
		HangId				INT PRIMARY KEY IDENTITY(1,1),
        TenHang				NVARCHAR(255) UNIQUE
    );

    -- Tạo bảng DongMay
    CREATE TABLE DongMay 
	(
        DongMayId			INT PRIMARY KEY IDENTITY(1,1),
        TenDongMay			NVARCHAR(255),
        HangId				INT,
        FOREIGN KEY			(HangId)	REFERENCES Hang(HangId)
    );

    -- Tạo bảng SanPham
    CREATE TABLE SanPham 
	(
        SanPhamId			INT PRIMARY KEY IDENTITY(1,1),
        TenSanPham			NVARCHAR(255),
        Gia					NVARCHAR(255),
        DongMayId			INT,
        HangId				INT, 
        CuaHangId			INT,
        TinhTrang			NVARCHAR(255),
        ChinhSachBaoHanh	NVARCHAR(255),
        MauSac				NVARCHAR(255),
        Link				NVARCHAR(255),
        FOREIGN KEY			(CuaHangId) REFERENCES CuaHang(CuaHangId),
        FOREIGN KEY			(HangId)	REFERENCES Hang(HangId),
        FOREIGN KEY			(DongMayId) REFERENCES DongMay(DongMayId)
    );



	-- Chèn dữ liệu vào bảng CuaHang
	INSERT INTO CuaHang (TenCuaHang, DiemDanhGia, SoLuotDanhGia)
	SELECT DISTINCT 
		TenCuaHang, 
		DiemDanhGia, 
		SoLuotDanhGia
	FROM 
		datadienthoai_Copy;


    -- Chèn dữ liệu vào bảng Hang
    INSERT INTO Hang (TenHang)
    SELECT DISTINCT
		Hang
    FROM 
		datadienthoai_Copy
    WHERE 
		Hang IS NOT NULL

    -- Chèn dữ liệu vào bảng DongMay
    INSERT INTO DongMay (TenDongMay, HangId)
    SELECT DISTINCT 
		DongMay, 
		Hang.HangId
    FROM 
		datadienthoai_Copy
    JOIN 
		Hang 
	ON 
		datadienthoai_Copy.Hang = Hang.TenHang
    WHERE 
		DongMay IS NOT NULL;

    -- Chèn dữ liệu vào bảng SanPham
    INSERT INTO SanPham (TenSanPham, Gia, DongMayId, HangId, CuaHangId, TinhTrang, ChinhSachBaoHanh, MauSac, Link)
    SELECT 
        TenSanPham,
        Gia,
        DongMay.DongMayId,
        Hang.HangId,
        CuaHang.CuaHangId,
        TinhTrang,
        ChinhSachBaoHanh,
        MauSac,
        Link
    FROM 
        datadienthoai_Copy
    JOIN 
		CuaHang ON datadienthoai_Copy.TenCuaHang	=	CuaHang.TenCuaHang
    JOIN 
		DongMay ON datadienthoai_Copy.DongMay		=	DongMay.TenDongMay
    JOIN 
		Hang	ON datadienthoai_Copy.Hang			=	Hang.TenHang
END;

EXEC TaoBangVaChuyenDuLieu;