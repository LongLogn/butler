# Thiết kế Butler

## Ý tưởng

Trợ lý cá nhân **chỉ cần nói chuyện**, giống một quản gia thật. Chủ nhân kể, hỏi, giao việc. Trợ lý tự ghi chép,
sắp xếp, tra cứu và đề xuất cách làm thông minh nhất.

- Phiên chat là tạm thời, và phải mở phiên mới thường xuyên để đoạn chat không phình to.
  Trí nhớ lâu dài nằm trên Google Drive, nên dùng chung được cho mọi thiết bị.
- Kho chỉ chứa thứ **trợ lý viết**. Tài liệu của chủ nằm ngoài kho, kho chỉ lưu link tới chúng.
- Tên trợ lý, các mảng, giọng điệu đều do chủ chọn. Plugin dùng được cho bất kỳ ai.

## Thành phần plugin

| Thành phần | Gọi bằng | Việc |
| --- | --- | --- |
| skill `setup` | `/butler:setup` | hỏi tên, các mảng, phong cách → tạo kho; nâng cấp kho cũ |
| skill `start` | `/butler:start` hoặc nói tự nhiên | nạp trí nhớ, trả lời, lập kế hoạch, ghi chép |

Plugin **không** đóng gói MCP. Drive, Docs, Sheets, Calendar là connector cấp tài khoản claude.ai.

## Bài toán: nạp trí nhớ mà không tốn token

Kho càng dùng càng lớn.
- **v1** đọc hết mọi file đầu phiên: hiểu đủ nhưng tốn token.
- **v2** chỉ đọc gốc và một tầng dưới: rẻ nhưng mất ngữ cảnh. Ví dụ lịch dạy nằm ở `Butler/Công việc/Gia sư`, sâu 3 tầng, nên không được đọc.

Lý do là **độ sâu thư mục không phải mức quan trọng**. Vì vậy tách thành hai bài toán:
1. **Đầu phiên** AI nên biết gì → **Sheet bộ nhớ**, kích thước cố định, giống cache.
2. **Giữa phiên**, khi bàn sâu một chủ đề → đào dần **đúng nhánh đó** trong cây thư mục.

## Kho tri thức

```
Butler/
├── 00_README            dòng đầu: phiên bản, vị trí Sheet bộ nhớ; danh sách mảng kèm link
├── Bộ nhớ (Sheet)       3 tab: Gần đây · Quan trọng · Giao thức
├── Công việc/
│   ├── 00_README        thư mục này là gì, đang thế nào, mỗi thư mục/file con làm gì (kèm link)
│   └── Gia sư/
│       ├── 00_README
│       └── Buổi dạy (Sheet)
└── Sức khỏe/00_README
```

- Mỗi thư mục có đúng một `00_README` (Google Doc), gồm: "What this is", `## Now`, `## Contents`, và `## History` ngắn ở cuối.
- README lưu **link** của con. Drive làm việc theo ID chứ không theo đường dẫn, nên có link thì đi thẳng xuống bằng một lệnh, giống con trỏ trong cây.
- **Docs** giữ hiểu biết, **Sheets** giữ dòng và số liệu, **Calendar** giữ mọi thứ có giờ.

### Sheet bộ nhớ

| Tab | Chứa | Thứ tự |
| --- | --- | --- |
| Gần đây | chủ vừa kể gì, vừa làm gì | mới nhất ở đầu (giống LRU) |
| Quan trọng | deadline, cam kết, mục tiêu, thói quen cần sửa | quan trọng nhất ở đầu, có aging |
| Giao thức | dòng ghim (tên, xưng hô, múi giờ), lời dặn, phong cách, tính cách chủ | ghim trước, rồi theo mức ràng buộc |

- **Mã sự kiện** `YYMMDD-HHMM` dùng chung giữa các tab. "Thi thứ 7" vừa nằm ở Gần đây vừa ở Quan trọng.
- **Tab Quan trọng thay đổi hạng theo thời gian:**
  - lên hạng khi hạn tới gần;
  - xuống dần khi tiến độ tăng (Cloud 0% đứng đầu, 90% thì xuống khoảng hạng 5);
  - rơi hẳn khi chủ gác lại;
  - rời tab khi xong.
- **Tab Giao thức:** lời dặn mới của chủ xếp ngay dưới dòng ghim. Lời dặn trùng nhau thì gộp lại.

### Đầu phiên (tự động khi gọi `/butler:start`)

1. Đọc README gốc.
2. Đọc **10 dòng đầu mỗi tab** bằng một lệnh, cộng cột Hạn của các dòng dưới hạng 10 trong tab Quan trọng,
   để việc sắp tới hạn không bị sót.
3. Đọc lịch hôm nay và ngày mai. Lịch cố định, như lịch dạy, nằm trên Calendar.

Chi phí đầu phiên gần như không đổi dù kho lớn đến đâu.

### Ghi

- **Làm luôn rồi báo ngắn:**
  - thêm một dòng vào tab Gần đây;
  - cập nhật README của nút;
  - thêm dòng số liệu vào Sheet;
  - cập nhật tab Quan trọng và tab Giao thức.
- **Hỏi trước:**
  - tạo thư mục, Sheet hoặc Doc mới;
  - đụng tới lịch;
  - xóa hoặc di chuyển;
  - viết lại một đoạn dài.
- **Làm thông minh:** chọn công cụ hợp nhất, đề xuất, rồi xin phép. Ví dụ ghi lịch dạy thì dùng Sheet và Calendar, không dùng Doc.
- Không lưu mật khẩu, số thẻ, giấy tờ tùy thân.

## Phiên bản kho và nâng cấp

- Đầu `00_README` gốc có `butler-root: v2` (định dạng kho) và `written-by: butler X.Y.Z` (bản plugin ghi lần cuối).
- `start` gặp kho cũ thì chỉ đọc, và đề nghị chạy `/butler:setup` để nâng cấp. Setup sao lưu vào `Butler/_backup/` trước khi nâng cấp.
- Kho mới hơn plugin: chỉ đọc, và nhắc chủ cập nhật plugin.
- `build.ps1` dừng lại nếu số phiên bản `butler X.Y.Z` trong skill khác với `plugin.json`.

## Phát hành

```
sửa trong repo → commit → build.ps1 → tải dist/butler.zip lên claude.ai → có trên mọi thiết bị
```
Claude Code cài thẳng từ repo qua marketplace (xem README).
