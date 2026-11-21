# Thiết kế Butler

## Ý tưởng

Trợ lý cá nhân **chỉ cần nói chuyện**. Chủ nhân kể, hỏi, giao việc; trợ lý tự ghi chép,
sắp xếp và tra cứu trong **kho tri thức riêng của nó** (mặc định: một thư mục trên Google Drive).

- Phiên chat là tạm thời. Kho tri thức là trí nhớ lâu dài, dùng chung cho mọi thiết bị
  (máy tính, web, điện thoại).
- Kho chỉ chứa thứ **trợ lý viết**: ghi chú, tóm tắt, nhật ký, bảng dữ liệu. Tài liệu/công việc
  của chủ (repo, bài tập, file gốc) nằm ngoài kho; kho chỉ lưu đường dẫn hoặc link tới chúng.
- Tên trợ lý, các mảng quản lý, giọng điệu đều do chủ chọn lúc khởi tạo. Plugin dùng được cho
  bất kỳ ai.

## Thành phần plugin

| Thành phần | Gọi bằng | Việc |
| --- | --- | --- |
| skill `setup` | `/butler:setup` | Hỏi tên trợ lý, các mảng, sở thích → tạo kho |
| skill `butler` | `/butler:butler` hoặc hỏi tự nhiên | Đọc kho, trả lời, lập kế hoạch, ghi chép |

Plugin **không** đóng gói MCP. Google Drive, Docs, Sheets, Calendar là connector cấp tài khoản
claude.ai (MCP từ xa của Google, OAuth một lần, dùng được trên mọi thiết bị). Skill chỉ hướng
dẫn cách dùng các tool đó. Khi cần một MCP tự viết (vd: tính GPA theo quy chế riêng), mới thêm
`.mcp.json` vào plugin.

## Kho tri thức phân cấp

```
Butler/                          ← gốc kho, luôn tên "Butler" dù trợ lý được đặt tên gì
├── butler-readme                ← LỚP 0: danh tính, chủ nhân, danh sách các mảng, bản đồ dữ liệu
├── Học tập/
│   ├── butler-readme            ← LỚP 1: tổng quan mảng + 1 dòng cho mỗi mục con
│   └── Kỳ 1 năm 3/
│       ├── butler-readme        ← LỚP 2
│       └── Cloud/butler-readme  ← LỚP 3: chi tiết, nhật ký
├── Công việc/
│   ├── butler-readme
│   └── butler-buoi-day (Sheet)  ← dữ liệu dạng bảng
└── Sức khỏe/
    ├── butler-readme
    └── butler-giac-ngu (Sheet)
```

- Mỗi thư mục là một **nút**. Mỗi nút có đúng một `butler-readme` (Google Doc).
- **Mọi file Butler tạo ra đều có tiền tố `butler-`**: ghi chú là `butler-readme`, Sheet là `butler-<chủ đề>`
  (chữ thường, không dấu, nối bằng gạch ngang, vd `butler-buoi-day`). Thư mục thì giữ tên dễ đọc theo ý chủ.
- Phân vai connector: **Drive** tìm kho, tạo thư mục và file. **Docs** đọc và sửa nội dung ghi chú.
  `update_file` của Drive chỉ đổi tên, thư mục, gắn sao, không sửa được nội dung.
- Mẫu ghi chú được thiết kế để sửa bằng Docs an toàn:
  - Phần nhật ký luôn nằm **cuối file**, nên ghi thêm chỉ cần chèn vào cuối.
  - **Không dùng bảng.** Mỗi mục là một dòng, các trường cách nhau bằng ` · `.
  - Mỗi dòng bắt đầu bằng một khóa không trùng, nên `replaceAllText` thay đúng một dòng.
- Dữ liệu lặp lại có số đo (buổi dạy, giấc ngủ, chi tiêu) → Google Sheet trong nút đó.
- Sự kiện có giờ → Google Calendar (lịch riêng mang tên trợ lý).

### Đọc: từ trên xuống, chỉ khi cần

1. Đầu phiên chỉ đọc **lớp 0**. Đủ để biết tên mình, chủ là ai, có những mảng nào,
   mỗi mảng đang thế nào (1 dòng), mốc gần nhất.
2. Câu hỏi chạm mảng nào thì mới mở `butler-readme` của mảng đó, rồi mới xuống tiếp nếu cần.
3. Sheet chỉ đọc khi cần con số.

Nguyên lý: **mỗi lớp trên giữ bản tóm tắt 1 dòng của lớp dưới**, nên phần lớn câu hỏi tổng quan
trả lời được mà không cần đào sâu.

### Ghi: ghi ở dưới cùng, tóm tắt ngược lên trên

1. Ghi vào nút sâu nhất phù hợp (nhật ký có ngày, cập nhật trạng thái).
2. Cập nhật dòng tóm tắt của nút đó ở README cha; nếu mốc/trạng thái của cả mảng đổi
   thì cập nhật bảng ở lớp 0.
3. Không xóa nhật ký cũ. Sửa sai bằng một dòng đính chính có ngày.
4. Hỏi chủ trước khi: thêm/sửa/xóa sự kiện lịch, xóa hoặc di chuyển nút, viết lại lớn.
5. Không lưu mật khẩu, số thẻ, giấy tờ tùy thân.

## Lưu trữ thay thế

Không có connector Google Drive nhưng có quyền đọc ghi file (Claude Code) → kho có thể là
một thư mục local với cấu trúc giống hệt, `butler-readme.md` thay cho Google Doc,
`.csv` thay cho Sheet. Lớp 0 ghi rõ `storage:` để phiên sau biết kho ở đâu.

## Phát hành

```
sửa trong repo → commit → build.ps1 → tải dist/butler.zip lên claude.ai → có trên mọi thiết bị
```
Claude Code còn cài được thẳng từ repo qua marketplace (xem README).
