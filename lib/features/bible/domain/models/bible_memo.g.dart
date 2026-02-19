// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_memo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BibleMemoAdapter extends TypeAdapter<BibleMemo> {
  @override
  final int typeId = 1;

  @override
  BibleMemo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BibleMemo(
      id: fields[0] as String,
      bookId: fields[1] as String,
      bookKoName: fields[2] as String,
      chapter: fields[3] as int,
      verse: fields[4] as int,
      content: fields[5] as String,
      createdAt: fields[6] as DateTime,
      highlightColorValue: fields[7] as int,
      startVerse: fields[8] as int,
      endVerse: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BibleMemo obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.bookKoName)
      ..writeByte(3)
      ..write(obj.chapter)
      ..writeByte(4)
      ..write(obj.verse)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.highlightColorValue)
      ..writeByte(8)
      ..write(obj.startVerse)
      ..writeByte(9)
      ..write(obj.endVerse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleMemoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
