// To parse this JSON data, do
//
//     final questionsModel = questionsModelFromJson(jsonString);

import 'dart:convert';

QuestionsModel questionsModelFromJson(String str) =>
    QuestionsModel.fromJson(json.decode(str));

String questionsModelToJson(QuestionsModel data) => json.encode(data.toJson());

class QuestionsModel {
  List<Question> questions;

  QuestionsModel({
    required this.questions,
  });

  factory QuestionsModel.fromJson(Map<String, dynamic> json) => QuestionsModel(
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}

class Question {
  int id;
  String title;
  String titleAr;
  DateTime createdDate;

  Question({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.createdDate,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        createdDate: DateTime.parse(json["createdDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "titleAr": titleAr,
        "createdDate": createdDate.toIso8601String(),
      };
}
