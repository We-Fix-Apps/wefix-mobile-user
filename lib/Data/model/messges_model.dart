class MassegesModel {
  List<Messgelist>? messgelist;

  MassegesModel({
    this.messgelist,
  });

  MassegesModel.fromJson(Map<String, dynamic> json) {
    messgelist = (json['messgelist'] as List?)
        ?.map((dynamic e) => Messgelist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['messgelist'] = messgelist?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Messgelist {
  int? messageid;
  String? chatid;
  int? contactid;
  String? contactguid;
  String? fullname;
  String? image;
  String? firstchar;
  String? message;
  String? readstatus;
  String? type;
  String? insertdate;
  dynamic attachment;
  dynamic filename;

  Messgelist({
    this.messageid,
    this.chatid,
    this.contactid,
    this.contactguid,
    this.fullname,
    this.image,
    this.firstchar,
    this.message,
    this.readstatus,
    this.type,
    this.insertdate,
    this.attachment,
    this.filename,
  });

  Messgelist.fromJson(Map<String, dynamic> json) {
    messageid = json['messageid'] as int?;
    chatid = json['chatid'] as String?;
    contactid = json['contactid'] as int?;
    contactguid = json['contactguid'] as String?;
    fullname = json['fullname'] as String?;
    image = json['image'] as String?;
    firstchar = json['firstchar'] as String?;
    message = json['message'] as String?;
    readstatus = json['readstatus'] as String?;
    type = json['type'] as String?;
    insertdate = json['insertdate'] as String?;
    attachment = json['attachment'];
    filename = json['filename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['messageid'] = messageid;
    json['chatid'] = chatid;
    json['contactid'] = contactid;
    json['contactguid'] = contactguid;
    json['fullname'] = fullname;
    json['image'] = image;
    json['firstchar'] = firstchar;
    json['message'] = message;
    json['readstatus'] = readstatus;
    json['type'] = type;
    json['insertdate'] = insertdate;
    json['attachment'] = attachment;
    json['filename'] = filename;
    return json;
  }
}
