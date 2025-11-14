CREATE PROCEDURE XuLyDuLieu
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật dữ liệu trong bảng CuaHang
    UPDATE CuaHang
    SET 
        SoLuotDanhGia = CAST(REPLACE(SoLuotDanhGia, N' đánh giá', '') AS INT),
        DiemDanhGia = COALESCE(DiemDanhGia, 0)
    WHERE 
        SoLuotDanhGia IS NOT NULL 
        OR 
		DiemDanhGia IS NOT NULL;

    -- Cập nhật dữ liệu trong bảng SanPham
    UPDATE SanPham
    SET 
        Gia = CAST(
                REPLACE(REPLACE(REPLACE(Gia, N'đ', ''), ' ', ''), '.', '') 
                AS DECIMAL(10, 0)
            ),
        MauSac = CASE 
                    WHEN MauSac = N'Đang cập nhật' OR MauSac LIKE N'% GB' 
                    THEN N'Màu khác'
                    ELSE MauSac
                 END
    WHERE 
        Gia IS NOT NULL;
END;

-- Thực thi stored procedure
EXEC XuLyDuLieu;
