// To parse this JSON data, do
//
//     final transactionsModel = transactionsModelFromJson(jsonString);

import 'dart:convert';

TransactionsModel transactionsModelFromJson(String str) =>
    TransactionsModel.fromJson(json.decode(str));

String transactionsModelToJson(TransactionsModel data) =>
    json.encode(data.toJson());

class TransactionsModel {
  List<Transaction> transactions;
  double wallet;

  TransactionsModel({
    required this.transactions,
    required this.wallet,
  });

  factory TransactionsModel.fromJson(Map<String, dynamic> json) =>
      TransactionsModel(
        transactions: List<Transaction>.from(
            json["transactions"].map((x) => Transaction.fromJson(x))),
        wallet: (json["wallet"] as num).toDouble(), // ✅ Fixed here
      );

  Map<String, dynamic> toJson() => {
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
        "wallet": wallet,
      };
}

class Transaction {
  int customerId;
  double amount;
  String type;
  DateTime createdDate;
  String status;
  String statusAr;

  Transaction({
    required this.customerId,
    required this.amount,
    required this.type,
    required this.statusAr,
    required this.createdDate,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        customerId: json["customerId"],
        amount: (json["amount"] as num).toDouble(), // ✅ Fixed here
        type: json["type"],
        statusAr: json["statusAr"],
        createdDate: DateTime.parse(json["createdDate"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "customerId": customerId,
        "amount": amount,
        "statusAr": statusAr,
        "type": type,
        "createdDate": createdDate.toIso8601String(),
        "status": status,
      };
}
