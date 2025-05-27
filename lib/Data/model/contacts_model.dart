class ContactsModel {
  List<Contactlist>? contactlist;

  ContactsModel({
    this.contactlist,
  });

  ContactsModel.fromJson(Map<String, dynamic> json) {
    contactlist = (json['contactlist'] as List?)
        ?.map((dynamic e) => Contactlist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['contactlist'] = contactlist?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Contactlist {
  int? messageid;
  String? chatid;
  int? contactid;
  String? contactguid;
  String? fullname;
  String? image;
  String? firstchar;
  String? message;
  dynamic readstatus;
  String? type;
  dynamic insertdate;
  dynamic attachment;
  dynamic filename;

  Contactlist({
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

  Contactlist.fromJson(Map<String, dynamic> json) {
    messageid = json['messageid'] as int?;
    chatid = json['chatid'] as String?;
    contactid = json['contactid'] as int?;
    contactguid = json['contactguid'] as String?;
    fullname = json['fullname'] as String?;
    image = json['image'] as String?;
    firstchar = json['firstchar'] as String?;
    message = json['message'] as String?;
    readstatus = json['readstatus'];
    type = json['type'] as String?;
    insertdate = json['insertdate'];
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
