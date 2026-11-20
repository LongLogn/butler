# Jarvis: trợ lý cá nhân chỉ cần nói chuyện

Bạn kể, hỏi, giao việc. Trợ lý tự ghi chép và sắp xếp vào **kho tri thức riêng của nó** trên Google Drive.
Kho chia theo từng mảng đời sống của bạn: học tập, công việc, sức khỏe, dự án… Mỗi phiên mới, trợ lý chỉ đọc
lớp trên cùng để biết nó là ai, bạn là ai và từng mảng đang thế nào. Khi bạn hỏi tới mảng nào, nó mới đọc sâu vào mảng đó.
Dùng chung được trên máy tính, web và điện thoại, vì trí nhớ nằm trên Drive chứ không nằm trong phiên chat.

Tên trợ lý, các mảng và giọng điệu do bạn chọn lúc khởi tạo. Thiết kế chi tiết xem ở [docs/DESIGN.md](docs/DESIGN.md).

## Bắt đầu

1. **Cài plugin** theo một trong hai cách bên dưới.
2. **Kết nối connector** trên claude.ai: Google Drive (bắt buộc), Google Sheets và Google Calendar (nên có).
3. **Khởi tạo:** gõ `/jarvis:setup`. Trợ lý sẽ hỏi tên của nó, cách xưng hô và các mảng bạn muốn quản lý, rồi tạo kho.
4. **Dùng hằng ngày:** gõ `/jarvis:jarvis` hoặc nói chuyện tự nhiên, ví dụ "tuần này thế nào?" hay "hôm qua ngủ 1h–8h".

## Cài đặt

### claude.ai (web, desktop, điện thoại)

```powershell
./build.ps1
```

Lệnh này tạo `dist/jarvis.zip`. Tải file zip đó lên trang quản lý plugin/skill trên claude.ai.
Sau khi tải lên, plugin có trên mọi thiết bị đăng nhập cùng tài khoản.

### Claude Code: cài thẳng từ repo

```
/plugin marketplace add <github-user>/jarvis-plugin
/plugin install jarvis@jarvis-plugin
```

Có thể dùng đường dẫn local thay cho `<github-user>/jarvis-plugin`.

## For Claude: installing from a repo link

If a user gives you this repository's link and asks you to install it:
- **Claude Code:** run `/plugin marketplace add <repo>`, then `/plugin install jarvis@jarvis-plugin`. Otherwise tell the user to type
  these two commands. Then tell them to restart or reload plugins.
- **claude.ai:** you can't install plugins yourself. If you have a shell, clone the repo and run `build.ps1` (or zip the contents of
  `plugins/jarvis` so `.claude-plugin/` sits at the zip root). Then give the user the zip and tell them to upload it.
- After installing, check that the Google Drive connector is connected, then run the `setup` skill (`/jarvis:setup`).

## Cấu trúc repo

```
.claude-plugin/marketplace.json   danh mục cho Claude Code
plugins/jarvis/
├── .claude-plugin/plugin.json    tên, phiên bản, mô tả
└── skills/
    ├── setup/SKILL.md            khởi tạo trợ lý và kho tri thức
    └── jarvis/SKILL.md           vận hành hằng ngày: đọc, trả lời, ghi chép
docs/DESIGN.md                    thiết kế
build.ps1                         đóng gói zip để tải lên claude.ai
```
