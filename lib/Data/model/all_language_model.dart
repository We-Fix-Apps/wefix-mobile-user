class AllLanguageModel {
  final List<AppLanguagess>? appLanguages;

  AllLanguageModel({
    this.appLanguages,
  });

  AllLanguageModel.fromJson(Map<String, dynamic> json)
      : appLanguages = (json['appLanguages'] as List?)
            ?.map((dynamic e) =>
                AppLanguagess.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() =>
      {'appLanguages': appLanguages?.map((e) => e.toJson()).toList()};
}

class AppLanguagess {
  final String? name;
  final String? flag;
  final String? code;
  bool? isSelect;
  final dynamic lang;
  final dynamic languages;
  final dynamic key;

  AppLanguagess({
    this.isSelect = false,
    this.name,
    this.flag,
    this.code,
    this.lang,
    this.languages,
    this.key,
  });

  AppLanguagess.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        flag = json['flag'] as String?,
        code = json['code'] as String?,
        isSelect = false,
        lang = json['lang'],
        languages = json['languages'],
        key = json['key'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'flag': flag,
        'code': code,
        'lang': lang,
        'languages': languages,
        'key': key
      };
}
