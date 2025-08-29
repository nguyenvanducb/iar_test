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
