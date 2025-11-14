# PHÂN TÍCH VÀ ĐỀ XUẤT ĐIỆN THOẠI CŨ TRÊN SÀN THƯƠNG MẠI CHỢ TỐT
— End-to-End Data Engineering & Machine Learning Pipeline —

## 1. Giới thiệu dự án
Dự án này tập trung khai thác dữ liệu từ các bài đăng mua bán điện thoại đã qua sử dụng trên nền tảng Chợ Tốt, một trong các marketplace lớn nhất tại Việt Nam. Mục tiêu của dự án là xây dựng một pipeline xử lý dữ liệu hoàn chỉnh từ giai đoạn thu thập → lưu trữ → tiền xử lý → phân tích → trực quan → mô hình hóa.
## 2. Lý do chọn đề tài
Trong bối cảnh giá smartphone liên tục tăng, thị trường điện thoại cũ trở thành lựa chọn phổ biến:
- Xu hướng mua sắm điện thoại đã qua sử dụng ngày càng tăng do tiết kiệm chi phí.
- Người mua muốn tối ưu giá trị (giá hợp lý, cấu hình tốt, tình trạng máy rõ ràng).
- Người bán muốn tối ưu hóa doanh thu và định giá hợp lý so với thị trường.
- Doanh nghiệp và sàn thương mại điện tử có thể dùng dữ liệu để:
  - phân tích mức độ quan tâm theo dòng máy
  - dự đoán mức giá tối ưu
  - nâng cao trải nghiệm mua bán
Với dữ liệu lớn từ Chợ Tốt, nhóm thực hiện mong muốn xây dựng một hệ thống giúp phân tích thị trường điện thoại cũ, từ đó đưa ra các insight hữu ích cho cả người mua và người bán.

## 3. Mục tiêu chính của dự án
- R1. Thu thập dữ liệu điện thoại cũ từ Chợ Tốt (≥10.000 dòng).
- R2. Tự động đưa dữ liệu vào SQL Server.
- R3. Xây dựng các module tiền xử lý bằng T-SQL.
- R4. Backup dữ liệu sau khi xử lý.
- R5. Thiết lập phân quyền database đúng chuẩn: Admin – DE – DA.
- R6. Trực quan hóa dữ liệu để tìm xu hướng giá, thương hiệu, tình trạng máy…
- R7. Xây dựng mô hình đề xuất điện thoại.



