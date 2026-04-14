# Ngân hàng câu hỏi BA — Phân loại theo nhóm

Ngân hàng câu hỏi mẫu theo nhóm. Customize dựa trên context thu thập được.

---

## 1. Nghiệp vụ tổng quát

**Mục tiêu:** Hiểu bức tranh toàn cảnh, scope, actors.

Câu hỏi mẫu:
- "Mục tiêu chính của feature này là gì? (a) Quản lý dữ liệu CRUD (b) Hiển thị/báo cáo read-only (c) Tích hợp/đồng bộ từ hệ thống khác (d) Khác"
- "Ai là người dùng chính? Họ thuộc phòng ban/vai trò nào?"
- "Feature này thay thế quy trình thủ công nào? Hay là quy trình hoàn toàn mới?"
- "Phạm vi feature gồm những chức năng nào? (chọn nhiều)"
- "Có chức năng nào KHÔNG nằm trong phạm vi mà dễ nhầm lẫn không?"

**Gợi ý từ context:**
- Nếu survey đề cập hệ thống nguồn → hỏi xác nhận phương thức tích hợp
- Nếu schema có bảng `sync_schedule` → gợi ý "Có phải là đồng bộ batch?"

---

## 2. Chức năng chi tiết

**Mục tiêu:** Hiểu TỪNG chức năng con — luồng xử lý, business rules, edge cases.

Câu hỏi mẫu:
- "Với chức năng [X], luồng xử lý chính gồm những bước nào?"
- "Khi [tình huống Y] xảy ra, hệ thống xử lý thế nào? (a) Báo lỗi (b) Bỏ qua (c) Retry (d) Khác"
- "Dữ liệu sau khi [action] có cho phép chỉnh sửa không? (a) Read-only (b) Chỉnh sửa một số trường (c) Chỉnh sửa toàn bộ"
- "Có cần hiển thị lịch sử thay đổi không?"
- "Khi xóa dữ liệu, dùng (a) Xóa cứng (b) Xóa mềm (soft delete) (c) Không cho xóa"

**Gợi ý từ context:**
- Từ schema: liệt kê các cột → hỏi "Cột [X] dùng để hiển thị hay chỉ lưu nội bộ?"
- Từ code docs: nếu đã có pattern tương tự → hỏi "Áp dụng giống module [Y]?"

---

## 3. Dữ liệu

**Mục tiêu:** Xác định rõ nguồn dữ liệu, mapping, validation.

Câu hỏi mẫu:
- "Dữ liệu bảng [X] đến từ đâu? (a) User nhập tay (b) Đồng bộ từ hệ thống [Y] (c) Tính toán từ bảng khác (d) Seed sẵn"
- "Cột [X] lưu giá trị code, cần mapping sang text hiển thị không? Nếu có, bảng mapping nào?"
- "Giá trị code [X] không có trong bảng mapping → xử lý thế nào? (a) Giữ nguyên raw (b) Hiển thị 'Không xác định' (c) Ẩn dòng"
- "Có validation nào đặc biệt cho cột [X] không? (VD: regex, giá trị min/max, phụ thuộc cột khác)"
- "Khi đồng bộ, nếu bản ghi bị xóa ở nguồn → xử lý thế nào?"

**Gợi ý từ context:**
- Từ schema: type `tinyint` / `int` cho cột status → hỏi bảng mapping int→text
- Từ schema: cột `varchar` lưu boolean → hỏi "Giá trị 'Có'/'Không' hay '1'/'0'?"
- Từ data-contracts.md: kiểm tra enum đã có hay chưa

---

## 4. Giao diện (UI) — ƯU TIÊN MÀN CÓ SẴN

**Mục tiêu:** Xác định layout, components, interaction patterns. **NGUYÊN TẮC SỐ 1: Luôn hỏi màn tham chiếu TRƯỚC, chỉ hỏi chi tiết layout/component SAU.**

### 4.0 Câu hỏi BẮT BUỘC hỏi TRƯỚC TIÊN (cho MỖI màn hình)

> **QUAN TRỌNG:** Với MỖI màn hình/dialog/popup trong feature, PHẢI hỏi câu này TRƯỚC KHI hỏi bất kỳ chi tiết nào khác về giao diện.

- "Màn hình [X] này xây theo màn nào CÓ SẴN trong hệ thống? (a) [Tên màn A — mô tả ngắn] (b) [Tên màn B — mô tả ngắn] (c) Không có màn tương tự — cần thiết kế mới"
  - Nếu BA chọn (a) hoặc (b) → hỏi tiếp: "Giống bao nhiêu phần trăm? Điểm nào KHÁC so với màn tham chiếu?"
  - Nếu BA chọn (c) → mới hỏi chi tiết layout/component từ đầu

### 4.1 Câu hỏi khi CÓ màn tham chiếu (chỉ hỏi điểm KHÁC)

- "So với màn [X], phần nào cần THAY ĐỔI? (a) Cột hiển thị (b) Bộ lọc (c) Nút hành động (d) Layout tổng (e) Không đổi gì — chỉ khác dữ liệu"
- "Cột nào cần THÊM so với màn tham chiếu? Cột nào cần BỎ?"
- "Filter nào cần THÊM/BỎ/SỬA so với màn tham chiếu?"
- "Popup/dialog nào dùng lại từ màn tham chiếu? Cái nào cần mới?"

### 4.2 Câu hỏi khi KHÔNG có màn tham chiếu (thiết kế mới)

Câu hỏi mẫu:
- "Bảng dữ liệu có bao nhiêu tab? Mỗi tab hiển thị dữ liệu từ bảng nào?"
- "Cột nào hiển thị trên bảng? Cột nào ẩn mặc định?"
- "Cần filter cho những cột nào? Loại filter: (a) Text contains (b) Dropdown đơn (c) Multi-select (d) Date range"
- "Có nút hành động nào trên mỗi dòng không? (VD: xem chi tiết, sửa, xóa)"
- "Phân trang: (a) Server-side (b) Client-side — Số bản ghi/trang mặc định?"
- "Cần chức năng export không? Format gì? Tên file quy ước thế nào?"
- "Khi không có dữ liệu, hiển thị gì?"

**Gợi ý từ context:**
- Từ components.md: liệt kê component có sẵn → hỏi "Dùng component [X] có sẵn?"
- Từ patterns.md: nếu có pattern table/filter → gợi ý áp dụng
- Từ docs code: quét danh sách màn hình hiện có → gợi ý làm options cho câu hỏi 4.0

---

## 5. Tích hợp hệ thống

**Mục tiêu:** Xác định rõ cách tích hợp với hệ thống bên ngoài.

Câu hỏi mẫu:
- "Hệ thống nguồn [X] cung cấp dữ liệu qua (a) REST API (b) Database trực tiếp (c) File (d) Message queue"
- "Tần suất đồng bộ: (a) Realtime (b) Mỗi giờ (c) Mỗi ngày (d) Cấu hình được"
- "Cần authentication gì khi gọi API nguồn? (a) API Key (b) OAuth (c) Certificate (d) Không cần"
- "Nếu hệ thống nguồn không phản hồi, xử lý thế nào?"
- "Dữ liệu đồng bộ có cần transform/mapping trước khi lưu không?"

---

## 6. Phân quyền

**Mục tiêu:** Xác định role matrix, permission checks.

Câu hỏi mẫu:
- "Những role nào được truy cập feature này?"
- "Có phân biệt quyền xem vs quyền export không?"
- "Admin có quyền gì đặc biệt mà user thường không có?"
- "Nếu user không có quyền, ẩn menu hay hiển thị nhưng disable?"
- "Có cần phân quyền theo khu vực/tỉnh không? (VD: user tỉnh A chỉ xem dữ liệu tỉnh A)"

**Gợi ý từ context:**
- Từ auth.md: xác nhận cơ chế RBAC hiện tại
- Từ schema: bảng `roles`, `role_permission`, `user_role`

---

## 7. Xử lý lỗi

**Mục tiêu:** Cover mọi error scenario.

Câu hỏi mẫu:
- "Khi API lỗi (500), hiển thị thông báo gì cho user?"
- "Khi export file quá lớn, giới hạn bao nhiêu bản ghi? Thông báo gì?"
- "Khi đồng bộ thất bại liên tiếp, cần alert/notify ai?"
- "Dữ liệu không hợp lệ từ nguồn (VD: tọa độ sai format) → bỏ qua hay reject toàn bộ batch?"
- "Có cần retry tự động không? Bao nhiêu lần? Interval?"

---

## 8. Phi chức năng

**Mục tiêu:** Performance, security, logging.

Câu hỏi mẫu:
- "Dự kiến số lượng bản ghi tối đa trong mỗi bảng?"
- "Số user truy cập đồng thời dự kiến?"
- "Thời gian load trang chấp nhận được: (a) < 1s (b) < 3s (c) < 5s"
- "Cần log những hành động nào? (a) Chỉ lỗi (b) Tất cả thao tác (c) Chỉ thay đổi dữ liệu"
- "Có yêu cầu audit trail (ai làm gì, lúc nào) không?"

---

## Chiến lược hỏi

### Nguyên tắc SKIP
Không hỏi nếu:
- Schema DB đã cho thấy rõ ràng (VD: cột có FK → quan hệ đã rõ)
- Code docs đã mô tả pattern (VD: auth.md đã nêu cơ chế RBAC)
- Survey đã trả lời cụ thể

### Nguyên tắc CONFIRM
Hỏi xác nhận (không hỏi từ đầu) nếu:
- Schema gợi ý nhưng chưa chắc (VD: cột `status` kiểu int → "mapping int→text là gì?")
- Code docs có pattern nhưng chưa biết có áp dụng (VD: "Áp dụng pattern phân trang giống module Y?")

### Nguyên tắc DEEP-DIVE
Hỏi chi tiết nếu:
- Survey chỉ nêu ý chính, thiếu chi tiết
- Business rule phức tạp, nhiều điều kiện
- Edge case chưa được cover

### Kết thúc mỗi nhóm
Sau mỗi nhóm câu hỏi, tóm tắt ngắn gọn những gì đã thu thập và hỏi:
> "Phần [X] tôi đã ghi nhận: [tóm tắt]. Còn điều gì cần bổ sung không?"
