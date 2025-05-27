class ReviewModel {
  List<Review>? review;

  ReviewModel({
    this.review,
  });

  ReviewModel.fromJson(Map<String, dynamic> json) {
    review = (json['review'] as List?)
        ?.map((dynamic e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['review'] = review?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Review {
  String? reviewerType;
  int? reviewerID;
  String? reviewName;
  String? reviewerImage;
  double? starRating;
  double? averageRating;
  String? description;
  String? attachment;
  String? reviewDate;

  Review({
    this.reviewerType,
    this.reviewerID,
    this.reviewName,
    this.reviewerImage,
    this.starRating,
    this.averageRating,
    this.description,
    this.attachment,
    this.reviewDate,
  });

  Review.fromJson(Map<String, dynamic> json) {
    reviewerType = json['reviewerType'] as String?;
    reviewerID = json['reviewerID'] as int?;
    reviewName = json['reviewName'] as String?;
    reviewerImage = json['reviewerImage'] as String?;
    starRating = json['starRating'] as double?;
    averageRating = json['averageRating'] as double?;
    description = json['description'] as String?;
    attachment = json['attachment'] as String?;
    reviewDate = json['reviewDate'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['reviewerType'] = reviewerType;
    json['reviewerID'] = reviewerID;
    json['reviewName'] = reviewName;
    json['reviewerImage'] = reviewerImage;
    json['starRating'] = starRating;
    json['averageRating'] = averageRating;
    json['description'] = description;
    json['attachment'] = attachment;
    json['reviewDate'] = reviewDate;
    return json;
  }
}
