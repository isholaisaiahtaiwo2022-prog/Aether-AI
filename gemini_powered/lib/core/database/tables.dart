
import 'package:drift/drift.dart';

class Conversations extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_messages_conversation_id',
  columns: {#conversationId},
)
class Messages extends Table {
  TextColumn get id => text()();

  TextColumn get conversationId => text()
      .named('conversation_id')
      .references(
        Conversations,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get content => text()();

  TextColumn get role => text()();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
