# Changelog

## 4.2.0 — 2026-11-22
Chuyển đổi dữ liệu cũ **buộc phải theo cấu trúc mới**, tránh bị neo theo bố cục cũ:
- Dữ liệu cũ chỉ là nguồn thông tin, không phải khuôn. Không mang sang mục cũ, bố cục cũ hay thói quen cũ.
- Bước kế hoạch cho chủ xem trước một thư mục mẫu, đặt README cũ cạnh README mới.
- README mới được viết lại từ đầu theo mẫu rồi thay toàn bộ nội dung file cũ, không sửa dần bản cũ.
- Thêm bước kiểm tra "đúng kiểu":
  - chỉ có các mục trong mẫu, không còn dấu vết cũ;
  - deadline nằm trong tab Quan trọng, số liệu nằm trong Sheet;
  - `## Now` và `## History` gọn;
  - tab Giao thức không bị bỏ trống.

## 4.1.0 — 2026-11-22
- **README mỗi thư mục là "người quản lý" của thư mục đó:** thêm mục `## How it works` ghi cái gì để ở đâu và vì sao
  (ví dụ buổi dạy ghi vào Sheet vì cần cộng tiền theo tháng). Khi chủ đồng ý một cách tổ chức mới, Butler tự ghi vào đây,
  nên mọi phiên sau làm giống nhau.
- **Setup chỉ xây và bàn giao:** cuối cùng báo kết quả (link, số lượng, phần bỏ sót, bản sao lưu) rồi bảo mở phiên mới
  và chạy `/butler:start`. Không nhập vai, không nạp trí nhớ.
- **Chuyển đổi dữ liệu cũ thành một quy trình chung, theo ý nghĩa thay vì theo kịch bản:**
  giải thích → kiểm kê → kế hoạch → sao lưu → chuyển → kiểm tra.
  Dùng cho kho Butler đời cũ lẫn ghi chú ngoài (như các file `jarvis.md`). Có bảng "What changed between formats" để nhận ra bố cục cũ.
- Định dạng kho vẫn là v2, không cần nâng cấp.

## 4.0.0 — 2026-11-22
Cơ chế nạp trí nhớ mới, lấy ý tưởng từ cache trong hệ điều hành. Kho định dạng **v2**.
- **Sheet bộ nhớ** có 3 tab, đầu phiên chỉ đọc 10 dòng đầu mỗi tab dù tab dài đến đâu:
  - **Gần đây:** xếp theo thời gian, mới nhất ở đầu.
  - **Quan trọng:** xếp theo mức quan trọng; việc lên hạng, xuống dần theo tiến độ, rơi hẳn hoặc rời tab khi xong.
  - **Giao thức:** tên trợ lý, xưng hô, múi giờ ghim cố định ở đầu; sau đó là lời dặn, phong cách, tính cách của chủ.
  - Một sự kiện dùng chung một mã ở mọi tab.
- **Đầu phiên** còn đọc cột Hạn của các việc dưới hạng 10 (việc sắp tới hạn được kéo lên) và lịch hôm nay, ngày mai.
- **Giữa phiên** chỉ đào sâu nhánh đang bàn. README lưu link tới thư mục và file con để đi thẳng.
- **Làm thông minh:** chọn công cụ hợp nhất (Sheet cho lịch dạy, Calendar cho nhắc nhở), đề xuất rồi xin phép.
- README mỗi thư mục giữ trạng thái hiện tại, danh sách con và mục `## History` ngắn ở cuối.
- **Google Sheets thành bắt buộc.**
- Nâng cấp kho v1 chuyển sang `/butler:setup`, có sao lưu.
- Sửa theo công cụ Google thật: đọc 3 tab bằng một lệnh, thêm dòng Gần đây bằng một lệnh, đọc ghi chú dạng chữ thường, tìm trùng lịch bằng `list_events`.

## 3.3.0 — 2026-11-21
Bản sửa sau khi hai agent đánh giá: một agent xem độ bền, một agent xem độ đơn giản.
- **Phiên bản kho:** đầu `00_README` gốc có `butler-root: v1` và `written-by: butler X.Y.Z`. `/butler:start` so sánh hai số này:
  kho cũ thì hỏi rồi nâng cấp (có sao lưu vào `_backup/`), kho mới hơn plugin thì chỉ đọc.
  Các bước nâng cấp nằm trong mục "KB upgrades" của skill. `build.ps1` dừng lại nếu số phiên bản trong skill lệch với `plugin.json`.
- **Tìm kho chắc hơn:** tìm theo nội dung `butler-root:`, bỏ qua bản sao lưu, phát hiện thư mục bị đổi tên,
  và tiếp tục được bước setup từng thất bại giữa chừng.
- **Sửa Docs đúng hơn:**
  - các dòng đầu file cách nhau dòng trống, để không bị gộp khi chuyển từ markdown;
  - nhật ký là dòng thường `YYYY-MM-DD · nội dung`, vì dòng thêm vào kế thừa kiểu chữ của dòng trước;
  - `replaceAllText` lấy chữ từ `read_doc` và kiểm tra `occurrencesChanged`;
  - khi viết lại một đoạn thì dùng `requiredRevisionId`.
- **Tránh trùng lặp:** tìm trước khi tạo thư mục, ghi chú hay Sheet. Thêm quy tắc cho Sheets (tên tab, dòng tiêu đề) và Calendar
  (tìm trước khi tạo, xem trước khi sửa hoặc xóa, nêu múi giờ, hỏi với sự kiện lặp lại).
- **Gọn hơn:**
  - bỏ bản lưu ở máy và dòng `storage:`;
  - bỏ công thức tính điểm ưu tiên;
  - bỏ mục Conventions và dòng `Path:` trong mẫu;
  - chỉ cập nhật lớp trên khi trạng thái hoặc mốc đổi;
  - gõ `/butler:start` không kèm câu hỏi thì nhận một bản tóm tắt 3 dòng;
  - câu hỏi setup giảm từ 8 xuống 7.

## 3.2.0 — 2026-11-21
- Đổi tên skill chính từ `butler` thành `start`: lệnh dùng hằng ngày giờ là **`/butler:start`** (trước là `/butler:butler`).

## 3.1.1 — 2026-11-21
- Bỏ quy tắc thêm tiền tố `butler-` cho mọi file của bản 3.1.0. Ghi chú mỗi thư mục quay lại tên `00_README`, Sheet đặt tên theo chủ đề.
- Bỏ chữ "jarvis" còn sót trong câu hỏi nhập ghi chú cũ ở bước setup.

## 3.0.0 — 2026-11-21
- Đổi tên plugin từ `jarvis` thành **`butler`**. Lệnh mới là `/butler:setup` và `/butler:butler`. Repo đổi thành `LongLogn/butler`.
- Thư mục gốc của kho trên Drive **luôn tên là `Butler`**, không theo tên trợ lý nữa. Lúc setup vẫn hỏi tên và phong cách.
- Dòng đánh dấu gốc kho đổi từ `assistant-root: v2` thành `butler-root: v1`. Tên mặc định của trợ lý là Butler.

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
