import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'main.g.dart';

// 1. Định nghĩa collection
@collection
class Email {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(type: IndexType.value)
  String? title;

  List<Recipient>? recipients;

  @enumerated
  Status status = Status.pending;
}

@embedded
class Recipient {
  String? name;
  String? address;
}

enum Status { draft, pending, sent }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([EmailSchema], directory: dir.path);

  // Thêm dữ liệu
  final email1 = Email()
    ..title = "Hello World"
    ..recipients = [
      Recipient()
        ..name = "Nguyen Duc"
        ..address = "duc@example.com",
    ]
    ..status = Status.draft;

  await isar.writeTxn(() async {
    await isar.emails.put(email1);
  });

  // Truy vấn dữ liệu
  final drafts = await isar.emails
      .filter()
      .statusEqualTo(Status.draft)
      .findAll();

  // Chạy App và truyền dữ liệu
  runApp(MyApp(drafts: drafts));
}

class MyApp extends StatelessWidget {
  final List<Email> drafts;
  const MyApp({super.key, required this.drafts});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Isar Demo')),
        body: ListView.builder(
          itemCount: drafts.length,
          itemBuilder: (context, index) {
            final email = drafts[index];
            return ListTile(
              title: Text(email.title ?? 'No title'),
              subtitle: Text(
                email.recipients?.map((r) => r.name).join(', ') ?? '',
              ),
              trailing: Text(email.status.toString().split('.').last),
            );
          },
        ),
      ),
    );
  }
}


/*
1. @collection
Đây là annotation của Isar, đánh dấu class này là một collection trong cơ sở dữ liệu Isar.
Khi bạn chạy build runner (flutter pub run build_runner build), Isar sẽ tạo ra mã code hỗ trợ CRUD (create, read, update, delete) cho collection này.

2. class Email
Đây là lớp Dart định nghĩa dữ liệu của email, với các thuộc tính: id, title, recipients, status.
Mỗi instance của Email sẽ là một document trong collection emails của Isar.

3. Id id = Isar.autoIncrement;
Id là kiểu định danh duy nhất mà Isar sử dụng cho mỗi document.
Isar.autoIncrement nghĩa là Isar sẽ tự động cấp ID tăng dần khi bạn thêm document mới.
Bạn cũng có thể dùng id = null để auto-increment.
Đây là primary key của document, bắt buộc phải có trong Isar collection.

4. @Index(type: IndexType.value)
@Index là annotation tạo chỉ mục (index) trên trường này.
type: IndexType.value nghĩa là lưu index theo giá trị, giúp tìm kiếm nhanh hơn khi lọc theo title.
String? title nghĩa là title có thể null, kiểu dữ liệu String.

5. List<Recipient>? recipients;
Đây là danh sách các đối tượng nhúng (embedded objects) trong email.
Recipient là class đánh dấu bằng @embedded, nghĩa là dữ liệu nhúng trong document Email, không tạo collection riêng.
List<Recipient>? cho phép email có 0 hoặc nhiều người nhận.

6. @enumerated
@enumerated cho Isar biết trường này là enum.
Isar sẽ lưu enum dưới dạng số nguyên (int) tương ứng với vị trí trong enum.
Status status = Status.pending; nghĩa là giá trị mặc định của status là pending.

7. Tóm tắt logic:
Email = document trong Isar.
id = primary key tự tăng.
title = có index, dùng để tìm kiếm nhanh.
recipients = danh sách đối tượng nhúng.
status = enum, có giá trị mặc định.
*/