import streamlit as st
import pickle
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity


# ========================================
# Đọc Dữ liệu từ Pickle
# ========================================
df_sanpham = pd.read_pickle('df_sanpham.pkl')
# Tải tfidf_matrix và tfidf_vectorizer vào session_state
if 'tfidf_matrix' not in st.session_state:
    with open('tfidf_matrix.pkl', 'rb') as file:
        st.session_state['tfidf_matrix'] = pickle.load(file)

if 'tfidf' not in st.session_state:
    with open('tfidf_vectorizer.pkl', 'rb') as file:
        st.session_state['tfidf'] = pickle.load(file)

# ========================================
# Hàm Đề Xuất Sản Phẩm
# ========================================
def recommend_products(customer_input):
    """
    Hàm này nhận vào mô tả của khách hàng và trả về danh sách 5 sản phẩm tương tự nhất.
    """
    customer_description = (customer_input['Hãng'] + ' ' +
                            customer_input['Dòng Máy'] + ' ' +
                            customer_input['Tình trạng']+ ' ' +
                            customer_input['Chính sách bảo hành']) 
    customer_tfidf          =   st.session_state['tfidf'].transform([customer_description])
    cosine_sim_customer     =   cosine_similarity(customer_tfidf, st.session_state['tfidf_matrix'])
    similar_products_idx    =   cosine_sim_customer.argsort()[0][::-1]
    return [df_sanpham.iloc[idx] for idx in similar_products_idx[:5]]


# ========================================
# Cấu hình trang Streamlit
# ========================================
st.set_page_config(page_title="Phone Recommender System", page_icon="📲", layout="wide", initial_sidebar_state="expanded")

# ========================================
# Tùy chỉnh cho Giao diện
# ========================================
st.markdown("""
    <style>
        .product-title {
            font-size: 16px;
            color: #002147;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .results-container {
            margin-top: 20px;
        }
        .note-text {
            text-align: center;
            margin-top: 30px;
            font-size: 16px;
            color: gray;
        }
    </style>
""", unsafe_allow_html=True)


# ========================================
# Giao Diện Người Dùng
# ========================================
# Tiêu đề chính
st.markdown('<h1 style="text-align:center; color:#002147; margin-bottom: 5px;">Hệ Thống Đề Xuất Điện Thoại</h1>', unsafe_allow_html=True)
st.markdown('<h1 style="text-align:center; color:#FFD700; margin-top: -35px;">Chợ Tốt</h1>', unsafe_allow_html=True)

# Sidebar - Nhập thông tin tìm kiếm
st.sidebar.header("Nhập thông tin tìm kiếm")

# Lựa chọn các tiêu chí tìm kiếm
hang        = st.sidebar.selectbox("Chọn Hãng",     df_sanpham['TenHang'].unique())
dong_may    = st.sidebar.selectbox("Chọn Dòng Máy", df_sanpham[df_sanpham['TenHang'] == hang]['TenDongMay'].unique())
tinh_trang  = st.sidebar.selectbox("Tình trạng", ['Đã sử dụng (chưa sửa chữa)', 'Mới', 'Đã sử dụng (qua sửa chữa)'])
bao_hanh    = st.sidebar.selectbox("Chính sách bảo hành", ['Còn bảo hành', 'Hết bảo hành'])

# Thực hiện đề xuất khi người dùng nhấn nút
if st.sidebar.button("Đề xuất sản phẩm"):
    customer_input = {
        "Hãng":                hang,
        "Dòng Máy":            dong_may,
        "Tình trạng":          tinh_trang,
        "Chính sách bảo hành": bao_hanh
    }

    recommended_products = recommend_products(customer_input)

    # Hiển thị kết quả đề xuất
    st.markdown('<div class="results-container">',                    unsafe_allow_html=True)
    st.markdown('<h3 style="text-align:left;">Sản phẩm đề xuất</h3>', unsafe_allow_html=True)
    
    # Chia kết quả thành 5 cột
    cols = st.columns(5)
    for idx, product in enumerate(recommended_products, start=1):
        with cols[idx - 1]:
            # Hiển thị hộp sản phẩm
            st.markdown('<div class="product-box">', unsafe_allow_html=True)

            # Hiển thị hình ảnh sản phẩm
            image_path = product.get("HinhAnh", "phone.jpg")  # Đường dẫn hình ảnh mặc định
            st.image(image_path, width=150)

            # Hiển thị thông tin sản phẩm
            st.markdown(f'<div class="product-title">{product["TenSanPham"]}</div>', unsafe_allow_html=True)
            st.write(f"- **Giá:** {product['Gia']}")
            st.write(f"- **Tình trạng:** {product['TinhTrang']}")
            st.write(f"- **Bảo hành:** {product['ChinhSachBaoHanh']}")
            st.write(f"- **Màu sắc:** {product['MauSac']}")

            # Liên kết chi tiết sản phẩm
            st.markdown(f'<a href="{product["Link"]}" target="_blank">Xem chi tiết</a>', unsafe_allow_html=True)
            st.markdown('</div>', unsafe_allow_html=True)

    st.markdown('</div>', unsafe_allow_html=True)

    # Thêm ghi chú ở cuối màn hình
    st.markdown("""<div class="note-text">(Hình ảnh chỉ mang tính chất minh họa, nhấn vào sản phẩm để xem chi tiết)</div>""", unsafe_allow_html=True)

else:
    st.info("Hãy nhập thông tin và nhấn đề xuất sản phẩm để xem kết quả.")
