---
name: ba-requirement
description: "Phân tích khảo sát BA và sinh tài liệu đặc tả yêu cầu chi tiết (requirement_spec.md). Hỏi đáp tương tác bằng tiếng Việt giữa BA và Claude để thu thập, phân tích và hoàn thiện yêu cầu từ file khảo sát + schema DB + docs code hiện tại. Trigger: 'phân tích khảo sát', 'sinh requirement', 'ba requirement', 'tạo đặc tả yêu cầu'."
argument-hint: "<thư_mục_feature> [--schema <path_schema.sql>] [--docs <thư_mục_gốc>]"
allowed-tools: Read, Glob, Grep, Bash, Agent, AskUserQuestion, Write, Edit, TodoWrite
---

# BA Requirement Builder — Hệ thống phân tích yêu cầu tương tác

Hỗ trợ BA xây dựng tài liệu đặc tả yêu cầu chi tiết (`requirement_spec.md`) thông qua quy trình hỏi đáp tương tác bằng tiếng Việt.

**Input:** File khảo sát khách hàng + schema DB + docs code hiện tại + rules.md (tùy chọn)
**Output:** File `requirement_spec.md` đầy đủ — đủ để developer code, tester test, designer thiết kế UI

## Khi nào dùng skill này

- BA có file khảo sát khách hàng (xlsx/csv/md) và cần sinh requirement_spec.md chi tiết
- Cần bổ sung/hoàn thiện spec hiện có bằng Q&A tương tác
- Muốn kết hợp khảo sát + schema DB + docs code để sinh đặc tả đầy đủ

## Khi nào KHÔNG dùng skill này

- Requirement đã viết đầy đủ, chỉ cần review → dùng `code-review` hoặc `plan-review`
- Không có file khảo sát — cần BA chuẩn bị file khảo sát trước
- Chỉ cần plan implementation từ spec có sẵn → dùng `plan`
- Cần mockup code docs trước → chạy `mockup-fullstack` trước, rồi quay lại skill này

## Quy tắc cốt lõi

1. **Toàn bộ giao tiếp bằng tiếng Việt** — câu hỏi, phân tích, output
2. **Không hardcode đường dẫn** — mọi path lấy từ argument hoặc auto-discover
3. **Hỏi từng câu một** — dùng AskUserQuestion, không dồn nhiều câu
4. **Ưu tiên multiple choice** — options tiếng Việt, gợi ý từ context thu thập được
5. **Spec phải ĐẦY ĐỦ** — không để "TBD", không bỏ sót section nào trong template
6. **Tôn trọng `rules.md`** trong thư mục feature nếu tồn tại

## Phân tích đối số

**Raw arguments:** $ARGUMENTS

Phân tích chuỗi arguments theo format:
```
<thư_mục_feature>                 # Bắt buộc. VD: docs/A3-04
[--schema <path>]                 # Tùy chọn. Mặc định: docs/schema.sql
[--docs <path>]                   # Tùy chọn. Mặc định: thư mục gốc project
```

Trích xuất từ `$ARGUMENTS`:
- Phần tử đầu tiên (không có `--`) → `thư_mục_feature`
- `--schema <path>` → đường dẫn schema.sql
- `--docs <path>` → thư mục gốc chứa .docs/

Auto-discover nếu không truyền:
- Schema: tìm `docs/schema.sql` hoặc `**/schema.sql`
- Code docs: tìm `*/.docs/_index.md` (frontend, backend)

Nếu `$ARGUMENTS` rỗng hoặc thiếu thư mục feature → hỏi BA bằng AskUserQuestion: "Vui lòng cung cấp đường dẫn thư mục feature (VD: docs/A3-04)"

---

## Pha 1: Thu thập ngữ cảnh

Tạo TodoWrite track tiến độ. Chạy song song khi có thể:

### 1.1 Đọc file khảo sát

Tìm trong `<thư_mục_feature>`:
```
Glob: <thư_mục_feature>/**/*.{xlsx,xls,csv,txt,md,docx}
```

**Xử lý theo định dạng:**
- `.xlsx` / `.xls`: dùng Bash + python3:
  ```bash
  python3 -c "
  import openpyxl
  wb = openpyxl.load_workbook('<path>', data_only=True)
  for sheet in wb.sheetnames:
      ws = wb[sheet]
      print(f'=== Sheet: {sheet} ===')
      for row in ws.iter_rows(values_only=True):
          print('\t'.join([str(c) if c is not None else '' for c in row]))
  "
  ```
  Nếu thiếu openpyxl: `pip3 install openpyxl` rồi retry
- `.csv` / `.txt` / `.md`: đọc bằng Read
- `.docx`: dùng `python3 -c "import docx; ..."` hoặc báo BA convert

### 1.2 Đọc schema DB

Đọc file schema.sql đầy đủ. Trích xuất:
- Danh sách bảng, cột (tên, kiểu, constraints, default)
- Indexes, unique constraints

**Quan hệ giữa các bảng:** Database thường KHÔNG có foreign key — quan hệ được định nghĩa trong code (entities/models). Suy luận quan hệ từ:
1. Code docs: `models.md` / entities — nguồn chính xác nhất
2. Quy ước đặt tên cột: `xxx_id`, `xxx_code` gợi ý liên kết đến bảng `xxx`
3. Hỏi BA xác nhận nếu quan hệ không rõ

**Lưu ý:** Schema có thể rất lớn. Đọc toàn bộ nhưng khi phân tích chỉ focus vào bảng liên quan đến feature.

### 1.3 Đọc docs code

```
Glob: */.docs/**/*.md
Glob: .docs/**/*.md
```

Đọc theo thứ tự ưu tiên:
1. `_index.md` — mục lục
2. `data-contracts.md` — enum, constants (QUAN TRỌNG)
3. `api-routes.md` — API endpoints hiện có
4. `models.md` — entities/models
5. `components.md` — components UI
6. `patterns.md` — conventions
7. Các file còn lại

### 1.4 Đọc spec hiện có (nếu có)

```
Glob: <thư_mục_feature>/requirement_spec.md
```

Nếu tồn tại → phân tích: đã có gì, thiếu gì, cần bổ sung gì.

### 1.5 Đọc rules.md của BA (nếu có)

```
Glob: <thư_mục_feature>/rules.md
```

File `rules.md` là file tùy chọn do BA tạo sẵn, chứa thông tin bổ sung theo từng project/feature. Ví dụ:
- Quy tắc nghiệp vụ đặc thù
- Danh sách màn hình tham chiếu
- Quy ước đặt tên, format
- Thông tin tích hợp hệ thống
- Ghi chú từ khách hàng

Nếu tồn tại → đọc và coi như **input ưu tiên cao** (ngang hàng với file khảo sát). Thông tin trong rules.md ghi đè giả định mặc định.

---

## Pha 2: Phân tích & Trình bày

### 2.1 Tóm tắt hiểu biết

Trình bày cho BA:

```markdown
## 📋 Tóm tắt hiểu biết từ ngữ cảnh thu thập

**Feature:** [Mã] — [Tên]
**Mô tả:** [1-2 câu]

### Chức năng chính đã nhận diện
1. [Chức năng A] — [mô tả ngắn]
2. [Chức năng B] — ...

### Bảng DB liên quan
| Bảng | Mô tả | Số cột |
|------|--------|--------|
| ... | ... | ... |

### Code/Module hiện có liên quan
- Backend: [module X, Y]
- Frontend: [component A, B]
```

### 2.2 Phân tích lỗ hổng (Gap Analysis)

Phân loại thông tin theo 3 nhóm:

| Nhóm | Ý nghĩa |
|------|---------|
| ✅ **Đã rõ ràng** | Đủ thông tin implement — liệt kê cụ thể |
| ❓ **Chưa rõ / Mơ hồ** | Có thông tin nhưng thiếu chi tiết hoặc mâu thuẫn — nêu rõ thiếu gì |
| 🚫 **Thiếu thông tin** | Chưa có, cần BA bổ sung — nêu rõ cần gì |

Phân tích theo các chiều:
- Nghiệp vụ & quy trình
- Chức năng chi tiết (từng feature con)
- Dữ liệu & validation
- Giao diện & tương tác
- Tích hợp hệ thống
- Phân quyền
- Xử lý lỗi
- Phi chức năng (performance, security)

**Trình bày gap analysis cho BA và hỏi xác nhận trước khi vào Pha 3.**

---

## Pha 3: Hỏi đáp tương tác

### Nguyên tắc

- Hỏi **TỪNG CÂU MỘT** bằng AskUserQuestion
- **Ưu tiên multiple choice** (2-4 options tiếng Việt)
- Câu hỏi **cụ thể** — gợi ý dựa trên context đã thu thập
- Không hỏi những gì đã RÕ từ khảo sát/schema/docs
- Nếu schema đã có bảng rõ → hỏi xác nhận, không hỏi từ đầu
- Nếu code docs có pattern sẵn → hỏi "áp dụng tương tự?"

### Thứ tự hỏi

Đọc `references/domain-questions.md` để lấy ngân hàng câu hỏi mẫu. Thứ tự:

1. **Nghiệp vụ tổng quát** — scope, mục tiêu, actors
2. **Chức năng chi tiết** — từng chức năng: luồng chính, ngoại lệ, business rules
3. **Dữ liệu** — nguồn, đồng bộ, validation, enum/lookup
4. **Giao diện** — layout, tham chiếu màn có sẵn, interaction states
5. **Tích hợp** — API bên ngoài, authentication
6. **Phân quyền** — roles, permission matrix
7. **Xử lý lỗi** — error scenarios, retry, fallback
8. **Phi chức năng** — performance targets, data volume, concurrent users

### Chiến lược hỏi thông minh

- **Gợi ý từ schema:** "Bảng `X` có cột `Y` kiểu `Z` — đây có phải trường [mô tả] không?"
- **Gợi ý từ code:** "Module hiện tại đã có pattern [X] — có muốn áp dụng tương tự?"
- **Gợi ý từ spec cũ:** "Spec hiện tại ghi [X] — thông tin này còn đúng không?"
- **Hỏi xác nhận batch:** Sau mỗi nhóm, tóm tắt và hỏi "Còn bổ sung gì không?"

### Kết thúc hỏi đáp

Khi đã cover hết các nhóm, tóm tắt thông tin đã thu thập và hỏi BA xác nhận bằng AskUserQuestion:
- Option 1: "Đủ rồi, sinh tài liệu đặc tả"
- Option 2: "Tôi muốn bổ sung thêm"

---

## Pha 4: Sinh tài liệu đặc tả

Đọc `references/spec-template.md` để lấy cấu trúc chuẩn.

### Quy tắc sinh

- **Mọi section trong template PHẢI có nội dung** — không bỏ trống, không "TBD"
- Mọi enum/mapping → bảng tra cụ thể với đầy đủ giá trị
- Mọi API endpoint → method, path, request params/body, response shape, error codes
- Mọi màn hình → layout, danh sách component, interaction, states (loading/empty/error)
- Mọi chức năng → luồng chính + luồng ngoại lệ + business rules + validation
- Kịch bản kiểm thử → happy path + edge cases + error cases + boundary
- **Cross-reference** giữa sections: chức năng X → API Y → bảng Z → test TC-nn
- Dùng tiếng Việt có dấu đầy đủ

### Ghi file

```
Write: <thư_mục_feature>/requirement_spec.md
```

Nếu file đã tồn tại → hỏi BA trước khi ghi đè.

---

## Pha 5: Review & Hoàn thiện

1. Trình bày **tóm tắt** spec đã sinh (danh sách sections + highlights, KHÔNG paste toàn bộ)
2. Thông báo đường dẫn file
3. Hỏi BA review bằng AskUserQuestion với options: "Đồng ý" / "Cần chỉnh sửa (cho biết phần nào)"
4. Nếu BA chọn chỉnh sửa → Edit file theo yêu cầu → quay lại bước 1
5. Nếu BA đồng ý → hiển thị tóm tắt cuối:

```markdown
## ✅ Hoàn thành

- **File:** <path>/requirement_spec.md
- **Sections:** [số] sections, [số] chức năng, [số] API, [số] test cases
- **Sẵn sàng cho:** Development, Testing, UI Design
```
