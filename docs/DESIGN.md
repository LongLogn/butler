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
| skill `start` | `/butler:start` hoặc hỏi tự nhiên | Đọc kho, trả lời, lập kế hoạch, ghi chép |

Plugin **không** đóng gói MCP. Google Drive, Docs, Sheets, Calendar là connector cấp tài khoản
claude.ai (MCP từ xa của Google, OAuth một lần, dùng được trên mọi thiết bị). Skill chỉ hướng
dẫn cách dùng các tool đó. Khi cần một MCP tự viết (vd: tính GPA theo quy chế riêng), mới thêm
`.mcp.json` vào plugin.

## Kho tri thức phân cấp

```
Butler/                          ← gốc kho, luôn tên "Butler" dù trợ lý được đặt tên gì
├── 00_README                    ← LỚP 0: danh tính, chủ nhân, bảng các mảng, bản đồ dữ liệu
├── Học tập/
│   ├── 00_README                ← LỚP 1: tổng quan mảng + 1 dòng cho mỗi mục con
│   └── Kỳ 1 năm 3/
│       ├── 00_README            ← LỚP 2
│       └── Cloud/00_README      ← LỚP 3: chi tiết, nhật ký
├── Công việc/
│   ├── 00_README
│   └── Buổi dạy (Sheet)         ← dữ liệu dạng bảng
└── Sức khỏe/
    ├── 00_README
    └── Nhật ký sức khỏe (Sheet)
```

- Mỗi thư mục là một **nút**. Mỗi nút có đúng một `00_README` (Google Doc).
- Phân vai connector: **Drive** tìm kho, tạo thư mục và file. **Docs** đọc và sửa nội dung ghi chú.
  `update_file` của Drive chỉ đổi tên, thư mục, gắn sao, không sửa được nội dung.
- Mẫu ghi chú được thiết kế để sửa bằng Docs an toàn:
  - Phần nhật ký luôn nằm **cuối file**, mỗi mục một dòng `YYYY-MM-DD · nội dung`, nên ghi thêm chỉ cần chèn vào cuối.
  - Các dòng đầu file cách nhau một dòng trống, để khi chuyển từ markdown chúng không bị gộp thành một đoạn.
  - **Không dùng bảng.** Mỗi mục là một dòng, các trường cách nhau bằng ` · `.
  - Mỗi dòng bắt đầu bằng một khóa không trùng, nên `replaceAllText` thay đúng một dòng.
- Dữ liệu lặp lại có số đo (buổi dạy, giấc ngủ, chi tiêu) → Google Sheet trong nút đó.
- Sự kiện có giờ → Google Calendar. Dùng lịch mang tên trợ lý nếu chủ đã tạo sẵn, không thì dùng lịch chính
  và thêm tiền tố `[Tên trợ lý]` vào tên sự kiện. Connector không tạo được lịch mới.

### Đọc: từ trên xuống, chỉ khi cần

1. Đầu phiên chỉ đọc **lớp 0**. Đủ để biết tên mình, chủ là ai, có những mảng nào,
   mỗi mảng đang thế nào (1 dòng), mốc gần nhất.
2. Câu hỏi chạm mảng nào thì mới mở `00_README` của mảng đó, rồi mới xuống tiếp nếu cần.
3. Sheet chỉ đọc khi cần con số.

Nguyên lý: **mỗi lớp trên giữ bản tóm tắt 1 dòng của lớp dưới**, nên phần lớn câu hỏi tổng quan
trả lời được mà không cần đào sâu.

### Ghi: ghi ở dưới cùng, tóm tắt ngược lên trên

1. Ghi vào nút sâu nhất phù hợp (nhật ký có ngày, cập nhật trạng thái).
2. Chỉ khi trạng thái, tóm tắt hoặc mốc tiếp theo đổi: cập nhật dòng của nút đó ở README cha, rồi lần lượt
   các lớp trên tới lớp 0. Dừng ngay ở lớp đầu tiên mà dòng không đổi.
3. Không xóa nhật ký cũ. Sửa sai bằng một dòng đính chính có ngày.
4. Hỏi chủ trước khi: thêm/sửa/xóa sự kiện lịch, xóa hoặc di chuyển nút, viết lại lớn.
5. Không lưu mật khẩu, số thẻ, giấy tờ tùy thân.

## Phiên bản kho và nâng cấp

Kho chỉ nằm trên Drive. Bản lưu ở máy đã bị bỏ, vì điện thoại và claude.ai không truy cập được ổ đĩa.

- Hai dòng đầu của `00_README` gốc: `butler-root: v1` là định dạng kho, `written-by: butler X.Y.Z` là bản plugin ghi lần cuối.
- Mỗi phiên, `/butler:start` so sánh định dạng kho với định dạng mà skill hiểu:
  - **Bằng nhau:** làm việc bình thường.
  - **Kho cũ hơn:** nói bản mới thay đổi gì, hỏi chủ rồi mới nâng cấp. Trước khi nâng cấp, sao lưu các file sẽ bị sửa
    vào `Butler/_backup/`, đổi tên bản sao để phiên sau không nhận nhầm là gốc kho.
  - **Kho mới hơn:** chỉ đọc, nhắc chủ cập nhật plugin.
- Các bước nâng cấp nằm ngay trong skill `start`, mục "KB upgrades". Trên claude.ai, skill chỉ đọc được chính nó, không đọc được file khác trong repo.
- Thêm bước nâng cấp chỉ khi đổi cấu trúc kho. Đổi cách trả lời thì không cần nâng định dạng.
- `build.ps1` dừng lại nếu số phiên bản `butler X.Y.Z` trong skill khác với `plugin.json`.

## Phát hành

```
sửa trong repo → commit → build.ps1 → tải dist/butler.zip lên claude.ai → có trên mọi thiết bị
```
Claude Code còn cài được thẳng từ repo qua marketplace (xem README).
