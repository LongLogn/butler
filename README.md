# Butler: trợ lý cá nhân chỉ cần nói chuyện

Bạn kể, hỏi, giao việc. Trợ lý tự ghi chép và sắp xếp vào **kho tri thức riêng của nó**: thư mục `Butler` trên Google Drive.
Kho chia theo từng mảng đời sống của bạn (học tập, công việc, sức khỏe, dự án…), mỗi thư mục có một README.
Kho cũng có một **Sheet bộ nhớ** với 3 danh sách: chuyện gần đây, việc quan trọng, và những gì bạn dặn.
Mỗi phiên mới, trợ lý chỉ đọc 10 mục đầu của mỗi danh sách cùng lịch hôm nay và ngày mai. Khi bạn bàn sâu mảng nào, nó mới đọc sâu vào mảng đó.
Dùng chung được trên máy tính, web và điện thoại, vì trí nhớ nằm trên Drive chứ không nằm trong phiên chat.

Tên trợ lý, các mảng và giọng điệu do bạn chọn lúc khởi tạo. Thư mục kho thì luôn tên là `Butler`. Thiết kế chi tiết xem ở [docs/DESIGN.md](docs/DESIGN.md).

## Bắt đầu

1. **Cài plugin** theo một trong hai cách bên dưới.
2. **Kết nối connector** trên claude.ai:
   - **Google Drive** (bắt buộc): tìm kho, tạo thư mục và file.
   - **Google Docs** (bắt buộc): đọc và **sửa** nội dung ghi chú. Drive chỉ đổi được tên và thư mục của file, không sửa được nội dung.
   - **Google Sheets** (bắt buộc): Sheet bộ nhớ và các bảng dữ liệu như buổi dạy, giấc ngủ.
   - **Google Calendar** (nên có): lịch và nhắc nhở.
3. **Khởi tạo:** gõ `/butler:setup`. Trợ lý sẽ hỏi tên của nó, cách xưng hô và các mảng bạn muốn quản lý, rồi tạo kho.
4. **Dùng hằng ngày:** gõ `/butler:start` hoặc nói chuyện tự nhiên, ví dụ "tuần này thế nào?" hay "hôm qua ngủ 1h–8h".

## Cài đặt

### claude.ai (web, desktop, điện thoại)

```powershell
./build.ps1
```

Lệnh này tạo `dist/butler.zip`. Tải file zip đó lên trang quản lý plugin/skill trên claude.ai.
Sau khi tải lên, plugin có trên mọi thiết bị đăng nhập cùng tài khoản.

### Claude Code: cài thẳng từ repo

```
/plugin marketplace add LongLogn/butler
/plugin install butler@butler
```

Repo: https://github.com/LongLogn/butler. Có thể dùng đường dẫn local thay cho `LongLogn/butler`.

### Cập nhật lên bản mới

- **claude.ai:** build lại zip, tải lên thay bản cũ.
- **Claude Code:** `claude plugin marketplace update butler`, rồi `claude plugin update butler@butler`.

Kho trên Drive giữ nguyên. Bản mới vẫn tìm được kho cũ. Nếu định dạng kho cần nâng cấp, trợ lý sẽ hỏi bạn trước và sao lưu vào `Butler/_backup/`.

## For Claude: installing from a repo link

If a user gives you this repository's link and asks you to install it:
- **Claude Code** (you have a shell): run `claude plugin marketplace add LongLogn/butler`, then
  `claude plugin install butler@butler`. Tell the user to start a new session so the skills load.
  This installs it for Claude Code on this computer only. It does not reach claude.ai or the phone app.
- **claude.ai:** you can't install plugins yourself. If you have a shell, clone the repo and run `build.ps1` (or zip the contents of
  `plugins/butler` so `.claude-plugin/` sits at the zip root). Then give the user the zip and tell them to upload it.
- After installing, check that the Google Drive, Google Docs and Google Sheets connectors are connected (Calendar is
  recommended), then run the `setup` skill (`/butler:setup`).

## Cấu trúc repo

```
.claude-plugin/marketplace.json   danh mục cho Claude Code
plugins/butler/
├── .claude-plugin/plugin.json    tên, phiên bản, mô tả
└── skills/
    ├── setup/SKILL.md            khởi tạo trợ lý và kho tri thức
    └── start/SKILL.md            vận hành hằng ngày: đọc, trả lời, ghi chép
docs/DESIGN.md                    thiết kế
build.ps1                         đóng gói zip để tải lên claude.ai
```
