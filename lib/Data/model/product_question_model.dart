class ProductQuestionModel {
  List<Productquestion>? productquestion;

  ProductQuestionModel({
    this.productquestion,
  });

  ProductQuestionModel.fromJson(Map<String, dynamic> json) {
    productquestion = (json['productquestion'] as List?)
        ?.map(
            (dynamic e) => Productquestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productquestion'] = productquestion?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Productquestion {
  int? productQAId;
  int? productId;
  int? profileId;
  String? question;
  String? image;
  String? name;
  String? insertDate;
  bool? isActive;
  List<QuestionsAnwers>? questionsAnwers;

  Productquestion({
    this.productQAId,
    this.productId,
    this.profileId,
    this.question,
    this.image,
    this.name,
    this.insertDate,
    this.isActive,
    this.questionsAnwers,
  });

  Productquestion.fromJson(Map<String, dynamic> json) {
    productQAId = json['productQAId'] as int?;
    productId = json['productId'] as int?;
    profileId = json['profileId'] as int?;
    question = json['question'] as String?;
    image = json['image'] as String?;
    name = json['name'] as String?;
    insertDate = json['insertDate'] as String?;
    isActive = json['isActive'] as bool?;
    questionsAnwers = (json['questionsAnwers'] as List?)
        ?.map(
            (dynamic e) => QuestionsAnwers.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productQAId'] = productQAId;
    json['productId'] = productId;
    json['profileId'] = profileId;
    json['question'] = question;
    json['image'] = image;
    json['name'] = name;
    json['insertDate'] = insertDate;
    json['isActive'] = isActive;
    json['questionsAnwers'] = questionsAnwers?.map((e) => e.toJson()).toList();
    return json;
  }
}

class QuestionsAnwers {
  int? productAnswerId;
  int? productQAId;
  int? profileId;
  String? qAnswer;
  String? insertDate;
  bool? isActive;
  String? image;
  String? name;

  QuestionsAnwers({
    this.productAnswerId,
    this.productQAId,
    this.profileId,
    this.qAnswer,
    this.insertDate,
    this.isActive,
    this.image,
    this.name,
  });

  QuestionsAnwers.fromJson(Map<String, dynamic> json) {
    productAnswerId = json['productAnswerId'] as int?;
    productQAId = json['productQAId'] as int?;
    profileId = json['profileId'] as int?;
    qAnswer = json['qAnswer'] as String?;
    insertDate = json['insertDate'] as String?;
    isActive = json['isActive'] as bool?;
    image = json['image'] as String?;
    name = json['name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productAnswerId'] = productAnswerId;
    json['productQAId'] = productQAId;
    json['profileId'] = profileId;
    json['qAnswer'] = qAnswer;
    json['insertDate'] = insertDate;
    json['isActive'] = isActive;
    json['image'] = image;
    json['name'] = name;
    return json;
  }
}
