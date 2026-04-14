# Template: requirement_spec.md

Đây là cấu trúc chuẩn cho file đặc tả yêu cầu. Mọi section PHẢI có nội dung — không để trống, không "TBD".

---

# [Mã feature] – [Tên feature]
> Phiên bản · Ngày tạo · Ngày cập nhật

---

## 1. Tổng quan

| Thuộc tính | Nội dung |
|---|---|
| Mã yêu cầu | |
| Tên yêu cầu | |
| Mô tả ngắn | 1-2 câu mô tả feature |
| Hệ thống nguồn | Hệ thống cung cấp dữ liệu (nếu có) |
| Hệ thống đích | Ứng dụng nội bộ / module nào |
| Nhóm người dùng | Ai sử dụng feature này |
| Phương thức | VD: CRUD thủ công / Đồng bộ batch / API realtime |
| Phạm vi (Scope) | Những gì NẰM TRONG phạm vi |
| Ngoài phạm vi | Những gì KHÔNG làm trong feature này |
| Ưu tiên | Cao / Trung bình / Thấp |

---

## 2. Bối cảnh nghiệp vụ

### 2.1 Quy trình nghiệp vụ hiện tại
Mô tả quy trình hiện tại mà feature này liên quan. Nếu là quy trình mới, ghi "Chưa có — feature tạo mới".

### 2.2 Vấn đề / Nhu cầu
- Vấn đề 1: [mô tả]
- Vấn đề 2: [mô tả]

### 2.3 Mục tiêu
- Mục tiêu 1: [mô tả] — đo lường bằng [metric]
- Mục tiêu 2: [mô tả]

### 2.4 Giả định
- [Giả định 1]
- [Giả định 2]

### 2.5 Ràng buộc
- [Ràng buộc 1: VD phải tương thích với hệ thống X]
- [Ràng buộc 2]

---

## 3. Yêu cầu chức năng

### 3.x [Mã chức năng] — [Tên chức năng]

> Lặp lại section này cho TỪNG chức năng con. Mỗi chức năng phải có đầy đủ các mục dưới đây.

#### Mô tả
1-3 câu mô tả chức năng.

#### Actors
- Actor chính: [ai thực hiện]
- Actor phụ: [hệ thống/người liên quan]

#### Preconditions
- [Điều kiện 1: VD đã đăng nhập, có quyền X]
- [Điều kiện 2]

#### Luồng chính (Happy Path)
1. Bước 1: [mô tả hành động]
2. Bước 2: [mô tả]
3. ...
4. Kết quả: [mô tả kết quả mong đợi]

#### Luồng ngoại lệ
| Mã | Điều kiện | Xử lý |
|---|---|---|
| EX-01 | [Điều kiện ngoại lệ] | [Cách xử lý] |
| EX-02 | ... | ... |

#### Quy tắc nghiệp vụ (Business Rules)
| Mã | Quy tắc | Ví dụ |
|---|---|---|
| BR-01 | [Mô tả quy tắc] | [Ví dụ cụ thể] |
| BR-02 | ... | ... |

#### Validation
| Trường | Quy tắc | Thông báo lỗi |
|---|---|---|
| [tên trường] | [required / min / max / regex / ...] | [Text thông báo] |

#### Postconditions
- [Trạng thái sau khi hoàn thành]

---

## 4. Mô hình dữ liệu

### 4.1 Bảng DB liên quan

#### Bảng: `tên_bảng`
| STT | Cột | Kiểu | Null | Default | Mô tả |
|---|---|---|---|---|---|
| 1 | `id` | int(11) | NO | AUTO_INCREMENT | Khóa chính |
| 2 | `tên_cột` | varchar(255) | YES | NULL | Mô tả |

**Indexes:**
- PRIMARY: `id`
- UNIQUE: `tên_cột`
- INDEX: `tên_index` (`cột_1`, `cột_2`)

> Lặp lại cho mỗi bảng liên quan.

### 4.2 Quan hệ giữa các bảng

> **Lưu ý:** Database thường KHÔNG có foreign key. Quan hệ được quản lý trong code (entities/models). Suy luận từ quy ước đặt tên cột (`xxx_id`, `xxx_code`) và code docs.

```
bảng_A.cột_x → bảng_B.cột_y  (1:N)  — qua code, không có FK trong DB
bảng_A.cột_z → bảng_C.cột_w  (N:1)
```

Mô tả bằng lời:
- Bảng A có quan hệ 1:N với bảng B qua cột X (join trong code)
- ...

### 4.3 Enum / Danh mục / Mapping

> Lặp lại cho MỖI trường enum/lookup. PHẢI có đầy đủ giá trị, không dùng "..."

#### §4.3.x [Tên danh mục] (`tên_cột`)

| Giá trị DB | Text hiển thị | Ghi chú |
|---|---|---|
| `giá_trị_1` | Text 1 | |
| `giá_trị_2` | Text 2 | |

**Nguồn:** Hardcode / Bảng lookup `tên_bảng` / API bên ngoài
**Xử lý giá trị không tồn tại:** Giữ nguyên raw / Hiển thị "Không xác định" / Ẩn

---

## 5. Thiết kế API

### 5.x [Mã API] — [Mô tả ngắn]

> Lặp lại cho MỖI API endpoint.

| Thuộc tính | Giá trị |
|---|---|
| Method | GET / POST / PUT / DELETE |
| Path | `/api/v1/...` |
| Auth | Yêu cầu token + permission gì |
| Rate limit | Nếu có |

**Query Parameters / Request Body:**

| Param | Kiểu | Bắt buộc | Mô tả | Ví dụ |
|---|---|---|---|---|
| `param_1` | string | Có | Mô tả | `"value"` |
| `param_2` | number | Không | Mô tả | `10` |

**Response — Thành công (200):**

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    // Cấu trúc response cụ thể
  }
}
```

**Response — Phân trang (nếu có):**

```json
{
  "code": 200,
  "data": {
    "items": [],
    "total": 0,
    "page": 1,
    "pageSize": 20
  }
}
```

**Error Responses:**

| HTTP Code | Error Code | Mô tả | Khi nào |
|---|---|---|---|
| 400 | INVALID_PARAM | Tham số không hợp lệ | Thiếu param bắt buộc |
| 403 | FORBIDDEN | Không có quyền | Thiếu permission |
| 500 | INTERNAL_ERROR | Lỗi server | Exception không xử lý được |

---

## 6. Thiết kế giao diện

### 6.x [Mã màn hình] — [Tên màn hình]

> Lặp lại cho MỖI màn hình / dialog / popup.

#### Màn tham chiếu (BẮT BUỘC điền trước)

> **QUAN TRỌNG:** Mọi màn hình PHẢI xác định màn tham chiếu trước khi mô tả layout/component. Ưu tiên tối đa việc xây dựng dựa trên màn có sẵn trong hệ thống.

| Thuộc tính | Nội dung |
|---|---|
| Màn tham chiếu chính | [Tên màn hình có sẵn] hoặc "Thiết kế mới — không có màn tương tự" |
| URL/Path tham chiếu | [URL hoặc route của màn tham chiếu] |
| Mức độ tái sử dụng | (a) Giống 100% — chỉ khác dữ liệu (b) Giống ~80% — khác vài component (c) Giống layout — khác nội dung (d) Thiết kế mới hoàn toàn |
| Điểm khác biệt | [Liệt kê CỤ THỂ những gì khác so với màn tham chiếu. Nếu giống 100% ghi "Không có"] |

#### Layout
Nếu có màn tham chiếu → ghi "Áp dụng layout giống màn [X]" + chỉ mô tả phần KHÁC.
Nếu thiết kế mới → mô tả bố cục tổng quát: header, sidebar, content area, footer.

#### Components

| STT | Component | Loại | Mô tả | Props/Config |
|---|---|---|---|---|
| 1 | Thanh filter | FilterBar | Chứa các bộ lọc | Xem chi tiết filter bên dưới |
| 2 | Bảng dữ liệu | DataTable | Hiển thị danh sách | Columns xem mục 4 |
| 3 | Phân trang | Pagination | Server-side | pageSize: [10,20,50,100,200] |

#### Danh sách cột hiển thị

| STT | Tên cột (UI) | Cột DB | Kiểu filter | Mapping hiển thị | Sortable | Ghi chú |
|---|---|---|---|---|---|---|
| 1 | Tên hiển thị | `tên_cột_db` | contains/dropdown/none | —/CODE→TEXT/... | ✅/❌ | |

#### Filter chi tiết

| Filter | Loại | Nguồn options | Placeholder |
|---|---|---|---|
| Tên filter | text-input / select / multi-select / date-range | DB distinct / Hardcode / API | "Nhập..." |

#### Interaction & States

| Hành động | Trigger | Kết quả | Ghi chú |
|---|---|---|---|
| Click filter | Thay đổi giá trị filter | Gọi API reload danh sách | Debounce 300ms cho text input |
| Click sort | Click header cột | Sort ASC → DESC → none | |
| Chuyển tab | Click tab | Load dữ liệu tab mới | Giữ state filter tab cũ |
| Xuất dữ liệu | Click nút Export | Popup confirm → download xlsx | Xem flow xuất dữ liệu |

#### States

| State | Mô tả | UI |
|---|---|---|
| Loading | Đang tải dữ liệu | Skeleton/spinner trên bảng |
| Empty | Không có dữ liệu | Text "Không có dữ liệu" + icon |
| Error | Lỗi API | Toast thông báo lỗi |
| Success | Thao tác thành công | Toast thông báo thành công |

#### Tham chiếu UI chi tiết

> Nếu đã có màn tham chiếu ở trên, bảng dưới đây liệt kê chi tiết TỪNG thành phần tái sử dụng từ màn đó.

| Thành phần | Tham chiếu từ màn | Giữ nguyên / Thay đổi | Chi tiết thay đổi (nếu có) |
|---|---|---|---|
| Layout tổng | [Tên màn] | Giữ nguyên / Thay đổi | [Mô tả thay đổi] |
| Bảng dữ liệu | [Tên màn] | Thay đổi | Khác cột hiển thị, thêm filter X |
| Popup/Dialog | [Tên màn] | Giữ nguyên | — |
| Filter bar | [Tên màn] | Thay đổi | Thêm filter theo [trường Y] |

---

## 7. Phân quyền

### 7.1 Ma trận quyền

| Hành động | Permission code | Mô tả |
|---|---|---|
| Xem danh sách | `MODULE_VIEW` | Đã đăng nhập + có permission |
| Xuất dữ liệu | `MODULE_EXPORT` | Có permission xuất |
| Cấu hình | `MODULE_CONFIG` | Admin |

### 7.2 Xử lý khi không có quyền
- Không hiển thị menu/nút nếu không có permission
- API trả 403 nếu gọi trực tiếp không có permission

---

## 8. Xử lý lỗi & ngoại lệ

### 8.1 Lỗi hệ thống

| Tình huống | Xử lý | Thông báo user |
|---|---|---|
| API timeout | Retry 1 lần, nếu vẫn lỗi → báo user | "Hệ thống đang bận, vui lòng thử lại sau" |
| DB connection lost | Log error, trả 500 | "Lỗi kết nối, vui lòng thử lại" |
| Lỗi đồng bộ | Giữ dữ liệu cũ, ghi log | Không hiển thị cho user (background) |

### 8.2 Lỗi nghiệp vụ

| Tình huống | Xử lý | Thông báo user |
|---|---|---|
| Dữ liệu không hợp lệ | Reject + log | "Dữ liệu không hợp lệ: [chi tiết]" |
| Export quá lớn | Block + warning | "[Thông báo cụ thể]" |

---

## 9. Kịch bản kiểm thử

### Quy ước mã test case

- `TC-[Mã chức năng]-[STT]`: Test case cho chức năng
- `TC-API-[STT]`: Test case cho API
- `TC-UI-[STT]`: Test case cho UI
- `TC-SEC-[STT]`: Test case bảo mật
- `TC-PERF-[STT]`: Test case hiệu năng

### 9.x [Nhóm test]

| Mã | Tên test case | Precondition | Steps | Expected Result | Priority | Loại |
|---|---|---|---|---|---|---|
| TC-xx-01 | [Tên] | [Điều kiện] | 1. Bước 1 ‣ 2. Bước 2 | [Kết quả mong đợi] | High/Medium/Low | Happy/Edge/Error |

> **QUAN TRỌNG**: Phải có đủ 3 loại test case cho mỗi chức năng:
> - **Happy path**: Luồng chính hoạt động đúng
> - **Edge case**: Boundary values, dữ liệu đặc biệt, concurrent access
> - **Error case**: Input sai, lỗi mạng, lỗi permission, data conflict

---

## 10. Yêu cầu phi chức năng

### 10.1 Hiệu năng
| Metric | Target | Ghi chú |
|---|---|---|
| Thời gian load trang | < X giây | Với Y bản ghi |
| Thời gian export | < X giây | Với Y bản ghi |
| Concurrent users | X users | |

### 10.2 Bảo mật
- Authentication: [Phương thức]
- Authorization: [Cơ chế]
- Data encryption: [Yêu cầu]
- Audit logging: [Yêu cầu]

### 10.3 Khả năng mở rộng
- [Yêu cầu mở rộng nếu có]

### 10.4 Logging & Monitoring
- [Log những gì, level nào]
- [Alert khi nào]

---

## 11. Tích hợp hệ thống (nếu có)

### 11.x Tích hợp với [Tên hệ thống]

| Thuộc tính | Giá trị |
|---|---|
| Hệ thống | [Tên] |
| Phương thức | REST API / Message Queue / DB sync / File transfer |
| Hướng | Inbound / Outbound / Bidirectional |
| Tần suất | Realtime / Batch (interval) |
| Auth | API Key / OAuth / Certificate |

**Quy tắc đồng bộ:**
- Khi thêm mới: [upsert / insert only]
- Khi cập nhật: [overwrite / merge]
- Khi xóa ở nguồn: [soft delete / hard delete / giữ nguyên]
- Khi lỗi: [retry policy, fallback]

---

## 12. Migration & Deployment (nếu có thay đổi DB)

### 12.1 Migration scripts
- [Mô tả migration cần chạy]

### 12.2 Rollback plan
- [Cách rollback nếu có lỗi]

### 12.3 Data seeding
- [Dữ liệu mẫu / dữ liệu khởi tạo cần seed]

---

## 13. Phụ lục

### 13.1 Thuật ngữ / Từ viết tắt

| Từ viết tắt | Giải nghĩa |
|---|---|
| [VD: NIMS] | [Network Information Management System] |

### 13.2 Tài liệu tham chiếu
- [Link / tên tài liệu liên quan]

### 13.3 Lịch sử thay đổi

| Phiên bản | Ngày | Người thay đổi | Nội dung thay đổi |
|---|---|---|---|
| v1.0 | [ngày] | [tên] | Tạo mới |

---

## Hướng dẫn sử dụng template

### Nguyên tắc
1. **Không bỏ section** — nếu không áp dụng, ghi "Không áp dụng cho feature này" kèm lý do
2. **Không để "TBD"** — nếu chưa có thông tin, hỏi BA trong Pha 3
3. **Cross-reference** — mỗi chức năng (§3) phải liên kết đến API (§5), UI (§6), test (§9)
4. **Enum đầy đủ** — liệt kê TẤT CẢ giá trị, không dùng "..." hoặc "v.v."
5. **Ví dụ cụ thể** — mọi business rule phải có ví dụ minh họa
6. **Thông báo lỗi** — viết sẵn text tiếng Việt cho MỌI error case

### Mức độ chi tiết theo loại feature

| Loại feature | Sections cần đặc biệt chi tiết |
|---|---|
| CRUD đơn giản | §3 (validation), §5 (API), §6 (form layout), §9 |
| Danh sách + lọc + export | §3 (filter logic), §4 (enum mapping), §5 (pagination), §6 (table/filter), §9 |
| Đồng bộ dữ liệu | §3 (sync rules), §4 (schema), §8 (error handling), §11 (integration), §9 |
| Quy trình phê duyệt | §3 (state machine), §7 (permission matrix), §6 (action buttons per state), §9 |
| Dashboard / Báo cáo | §3 (aggregation logic), §5 (query optimization), §6 (charts/graphs), §10 (performance) |
