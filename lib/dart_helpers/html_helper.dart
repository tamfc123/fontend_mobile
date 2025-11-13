// Dòng này sẽ tự động chọn import 'dart:html' nếu là web,
// hoặc 'html_stub.dart' nếu là mobile/desktop.
export 'html_stub.dart' if (dart.library.html) 'dart:html';
