import '../core/base_model.dart';

final hiscore = Hiscore();

class Hiscore {
  static const int max_name_length = 10;
  static const int number_of_entries = 10;

  final entries = List.generate(number_of_entries, _defaultRank);

  HiscoreRank? latestRank;

  static HiscoreRank _defaultRank(int idx) => HiscoreRank(100000 - idx * 10000, 10 - idx, 'INTENSICODE');

  bool isNewHiscore(int score) => score > entries.first.score;

  bool isHiscoreRank(int score) => score > entries.last.score;

  void insert(int score, int level, String name) {
    final rank = HiscoreRank(score, level, name);
    for (int idx = 0; idx < entries.length; idx++) {
      final check = entries[idx];
      if (score <= check.score) continue;
      if (check == rank) break;
      entries.insert(idx, rank);
      entries.removeLast();
      break;
    }
    latestRank = rank;
  }

  void restore(dynamic json) {
    entries.clear();
    entries.addAll(json.map((rank) => HiscoreRank.from(rank)));
  }

  dynamic store() => entries.map((HiscoreRank rank) => rank.fields).toList();
}

class HiscoreRank with BaseModel {
  final int score;
  final int level;
  final String name;

  HiscoreRank(this.score, this.level, this.name);

  HiscoreRank.from(List fields) : this(fields[0] as int, fields[1] as int, fields[2] as String);

  @override
  List<dynamic> get fields => [score, level, name];
}
