class AppLanguageModel {
  final List<AppLanguages>? languages;

  AppLanguageModel({
    this.languages,
  });

  AppLanguageModel.fromJson(Map<String, dynamic> json)
      : languages = (json['languages'] as List?)
            ?.map(
                (dynamic e) => AppLanguages.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() =>
      {'languages': languages?.map((e) => e.toJson()).toList()};
}

class AppLanguages {
  final String? key;
  final List<Languages>? languages;

  AppLanguages({
    this.key,
    this.languages,
  });

  AppLanguages.fromJson(Map<String, dynamic> json)
      : key = json['key'] as String?,
        languages = (json['languages'] as List?)
            ?.map((dynamic e) => Languages.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() =>
      {'key': key, 'languages': languages?.map((e) => e.toJson()).toList()};
}

class Languages {
  final String? wordKey;
  final String? value;

  Languages({
    this.wordKey,
    this.value,
  });

  Languages.fromJson(Map<String, dynamic> json)
      : wordKey = json['wordKey'] as String?,
        value = json['value'] as String?;

  Map<String, dynamic> toJson() => {
        'wordKey': wordKey,
        'value': value,
      };
}
