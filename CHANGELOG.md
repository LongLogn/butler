# Changelog

## 2.1.0 — 2026-11-21
- Thêm connector **Google Docs** (bắt buộc): mọi ghi chú `00_README` là Google Doc, đọc bằng `read_doc` và sửa bằng `update_doc`.
  Drive chỉ dùng để tìm, tạo file và thư mục, vì `update_file` của Drive không sửa được nội dung.
- Thêm hướng dẫn sửa Docs an toàn: ghi nhật ký vào cuối file, sửa một dòng bằng `replaceAllText`,
  và dùng `requiredRevisionId` để không ghi đè lên chỉnh sửa của chủ.
- Đổi mẫu ghi chú cho hợp với Docs: nhật ký luôn ở cuối file, bỏ bảng (mỗi mục một dòng, ngăn bằng ` · `),
  mỗi dòng bắt đầu bằng một khóa không trùng.

## 2.0.0 — 2026-11-21
- Trợ lý có kho tri thức riêng (mặc định Google Drive), phân cấp: lớp 0 (danh tính, chủ nhân, bảng các mảng) → các mảng → nút con.
- Đầu phiên chỉ đọc lớp 0; đào sâu khi câu hỏi cần.
- Trợ lý là người ghi: chủ chỉ cần nói, trợ lý tự ghi vào nút sâu nhất rồi tóm tắt ngược lên.
- Thêm skill `setup` (`/jarvis:setup`): hỏi tên trợ lý, các mảng, sở thích → tạo kho; nhập ghi chú cũ.
- Dùng Google Sheets cho dữ liệu dạng bảng, Google Calendar cho lịch (hỏi trước khi đặt lịch).
- Trả lời kèm hình trực quan khi client hỗ trợ.
- Lưu trữ local thay thế khi không có Drive.

## 1.0.0
- Đọc các file `jarvis.md` do người dùng tự viết trong cây thư mục local.
