// Đây là file "giả" (stub) để code của bạn
// không bị lỗi khi biên dịch trên mobile.
// Nó cung cấp các class rỗng có tên giống hệt
// các class chúng ta dùng trong 'dart:html'.

class Blob {
  Blob(List<Object> parts, [String? type]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  String? href;
  AnchorElement({this.href});
  void setAttribute(String name, String value) {}
  void click() {}
}
