// To parse this JSON data, do
// ignore_for_file: camel_case_types, constant_identifier_names

import 'dart:convert';

class CMS_EXPERIENCE {
  List<FieldWeightage>? nid;
  List<ContentTranslationSource>? uuid;
  List<FieldWeightage>? vid;
  List<ContentTranslationSource>? langcode;
  List<Type>? type;
  List<Changed>? revisionTimestamp;
  List<FieldDescription>? revisionUid;
  List<dynamic>? revisionLog;
  List<ContentTranslationOutdated>? status;
  List<FieldDescription>? uid;
  List<ContentTranslationSource>? title;
  List<Changed>? created;
  List<Changed>? changed;
  List<ContentTranslationOutdated>? promote;
  List<ContentTranslationOutdated>? sticky;
  List<ContentTranslationOutdated>? defaultLangcode;
  List<ContentTranslationOutdated>? revisionTranslationAffected;
  Metatag? metatag;
  List<Path>? path;
  List<ContentTranslationSource>? contentTranslationSource;
  List<ContentTranslationOutdated>? contentTranslationOutdated;
  List<Field>? fieldImages;
  List<Field>? field1XImage;
  List<Field>? field2XImage;
  List<Field>? field3XImage;
  List<Field>? fieldCoverImage;
  List<FieldDescription>? fieldDescriptions;
  List<dynamic>? fieldFeaturedSize;
  List<FieldDescription>? fieldGallery;
  List<ContentTranslationSource>? fieldGalleryTextTitle;
  List<Field>? fieldLogo;
  List<FieldMetatag>? fieldMetatag;
  List<dynamic>? fieldRemarks;
  List<ContentTranslationSource>? fieldSubtitle;
  List<FieldELink>? fieldWebsiteLink;
  List<FieldWeightage>? fieldWeightage;
  List<FieldELink>? fieldYoutubeLink;

  CMS_EXPERIENCE({
    this.nid,
    this.uuid,
    this.vid,
    this.langcode,
    this.type,
    this.revisionTimestamp,
    this.revisionUid,
    this.revisionLog,
    this.status,
    this.uid,
    this.title,
    this.created,
    this.changed,
    this.promote,
    this.sticky,
    this.defaultLangcode,
    this.revisionTranslationAffected,
    this.metatag,
    this.path,
    this.contentTranslationSource,
    this.contentTranslationOutdated,
    this.fieldImages,
    this.field1XImage,
    this.field2XImage,
    this.field3XImage,
    this.fieldCoverImage,
    this.fieldDescriptions,
    this.fieldFeaturedSize,
    this.fieldGallery,
    this.fieldGalleryTextTitle,
    this.fieldLogo,
    this.fieldMetatag,
    this.fieldRemarks,
    this.fieldSubtitle,
    this.fieldWebsiteLink,
    this.fieldWeightage,
    this.fieldYoutubeLink,
  });

  factory CMS_EXPERIENCE.fromRawJson(String str) =>
      CMS_EXPERIENCE.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CMS_EXPERIENCE.fromJson(Map<String, dynamic> json) => CMS_EXPERIENCE(
        nid: json["nid"] == null
            ? []
            : List<FieldWeightage>.from(
                json["nid"]!.map((x) => FieldWeightage.fromJson(x))),
        uuid: json["uuid"] == null
            ? []
            : List<ContentTranslationSource>.from(
                json["uuid"]!.map((x) => ContentTranslationSource.fromJson(x))),
        vid: json["vid"] == null
            ? []
            : List<FieldWeightage>.from(
                json["vid"]!.map((x) => FieldWeightage.fromJson(x))),
        langcode: json["langcode"] == null
            ? []
            : List<ContentTranslationSource>.from(json["langcode"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        type: json["type"] == null
            ? []
            : List<Type>.from(json["type"]!.map((x) => Type.fromJson(x))),
        revisionTimestamp: json["revision_timestamp"] == null
            ? []
            : List<Changed>.from(
                json["revision_timestamp"]!.map((x) => Changed.fromJson(x))),
        revisionUid: json["revision_uid"] == null
            ? []
            : List<FieldDescription>.from(
                json["revision_uid"]!.map((x) => FieldDescription.fromJson(x))),
        revisionLog: json["revision_log"] == null
            ? []
            : List<dynamic>.from(json["revision_log"]!.map((x) => x)),
        status: json["status"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["status"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        uid: json["uid"] == null
            ? []
            : List<FieldDescription>.from(
                json["uid"]!.map((x) => FieldDescription.fromJson(x))),
        title: json["title"] == null
            ? []
            : List<ContentTranslationSource>.from(json["title"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        created: json["created"] == null
            ? []
            : List<Changed>.from(
                json["created"]!.map((x) => Changed.fromJson(x))),
        changed: json["changed"] == null
            ? []
            : List<Changed>.from(
                json["changed"]!.map((x) => Changed.fromJson(x))),
        promote: json["promote"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["promote"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        sticky: json["sticky"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["sticky"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        defaultLangcode: json["default_langcode"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["default_langcode"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        revisionTranslationAffected:
            json["revision_translation_affected"] == null
                ? []
                : List<ContentTranslationOutdated>.from(
                    json["revision_translation_affected"]!
                        .map((x) => ContentTranslationOutdated.fromJson(x))),
        metatag:
            json["metatag"] == null ? null : Metatag.fromJson(json["metatag"]),
        path: json["path"] == null
            ? []
            : List<Path>.from(json["path"]!.map((x) => Path.fromJson(x))),
        contentTranslationSource: json["content_translation_source"] == null
            ? []
            : List<ContentTranslationSource>.from(
                json["content_translation_source"]!
                    .map((x) => ContentTranslationSource.fromJson(x))),
        contentTranslationOutdated: json["content_translation_outdated"] == null
            ? []
            : List<ContentTranslationOutdated>.from(
                json["content_translation_outdated"]!
                    .map((x) => ContentTranslationOutdated.fromJson(x))),
        fieldImages: json["field_images"] == null
            ? []
            : List<Field>.from(
                json["field_images"]!.map((x) => Field.fromJson(x))),
        field1XImage: json["field_1x_image"] == null
            ? []
            : List<Field>.from(
                json["field_1x_image"]!.map((x) => Field.fromJson(x))),
        field2XImage: json["field_2x_image"] == null
            ? []
            : List<Field>.from(
                json["field_2x_image"]!.map((x) => Field.fromJson(x))),
        field3XImage: json["field_3x_image"] == null
            ? []
            : List<Field>.from(
                json["field_3x_image"]!.map((x) => Field.fromJson(x))),
        fieldCoverImage: json["field_cover_image"] == null
            ? []
            : List<Field>.from(
                json["field_cover_image"]!.map((x) => Field.fromJson(x))),
        fieldDescriptions: json["field_descriptions"] == null
            ? []
            : List<FieldDescription>.from(json["field_descriptions"]!
                .map((x) => FieldDescription.fromJson(x))),
        fieldFeaturedSize: json["field_featured_size"] == null
            ? []
            : List<dynamic>.from(json["field_featured_size"]!.map((x) => x)),
        fieldGallery: json["field_gallery"] == null
            ? []
            : List<FieldDescription>.from(json["field_gallery"]!
                .map((x) => FieldDescription.fromJson(x))),
        fieldGalleryTextTitle: json["field_gallery_text_title"] == null
            ? []
            : List<ContentTranslationSource>.from(
                json["field_gallery_text_title"]!
                    .map((x) => ContentTranslationSource.fromJson(x))),
        fieldLogo: json["field_logo"] == null
            ? []
            : List<Field>.from(
                json["field_logo"]!.map((x) => Field.fromJson(x))),
        fieldMetatag: json["field_metatag"] == null
            ? []
            : List<FieldMetatag>.from(
                json["field_metatag"]!.map((x) => FieldMetatag.fromJson(x))),
        fieldRemarks: json["field_remarks"] == null
            ? []
            : List<dynamic>.from(json["field_remarks"]!.map((x) => x)),
        fieldSubtitle: json["field_subtitle"] == null
            ? []
            : List<ContentTranslationSource>.from(json["field_subtitle"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        fieldWebsiteLink: json["field_website_link"] == null
            ? []
            : List<FieldELink>.from(
                json["field_website_link"]!.map((x) => FieldELink.fromJson(x))),
        fieldWeightage: json["field_weightage"] == null
            ? []
            : List<FieldWeightage>.from(json["field_weightage"]!
                .map((x) => FieldWeightage.fromJson(x))),
        fieldYoutubeLink: json["field_youtube_link"] == null
            ? []
            : List<FieldELink>.from(
                json["field_youtube_link"]!.map((x) => FieldELink.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nid":
            nid == null ? [] : List<dynamic>.from(nid!.map((x) => x.toJson())),
        "uuid": uuid == null
            ? []
            : List<dynamic>.from(uuid!.map((x) => x.toJson())),
        "vid":
            vid == null ? [] : List<dynamic>.from(vid!.map((x) => x.toJson())),
        "langcode": langcode == null
            ? []
            : List<dynamic>.from(langcode!.map((x) => x.toJson())),
        "type": type == null
            ? []
            : List<dynamic>.from(type!.map((x) => x.toJson())),
        "revision_timestamp": revisionTimestamp == null
            ? []
            : List<dynamic>.from(revisionTimestamp!.map((x) => x.toJson())),
        "revision_uid": revisionUid == null
            ? []
            : List<dynamic>.from(revisionUid!.map((x) => x.toJson())),
        "revision_log": revisionLog == null
            ? []
            : List<dynamic>.from(revisionLog!.map((x) => x)),
        "status": status == null
            ? []
            : List<dynamic>.from(status!.map((x) => x.toJson())),
        "uid":
            uid == null ? [] : List<dynamic>.from(uid!.map((x) => x.toJson())),
        "title": title == null
            ? []
            : List<dynamic>.from(title!.map((x) => x.toJson())),
        "created": created == null
            ? []
            : List<dynamic>.from(created!.map((x) => x.toJson())),
        "changed": changed == null
            ? []
            : List<dynamic>.from(changed!.map((x) => x.toJson())),
        "promote": promote == null
            ? []
            : List<dynamic>.from(promote!.map((x) => x.toJson())),
        "sticky": sticky == null
            ? []
            : List<dynamic>.from(sticky!.map((x) => x.toJson())),
        "default_langcode": defaultLangcode == null
            ? []
            : List<dynamic>.from(defaultLangcode!.map((x) => x.toJson())),
        "revision_translation_affected": revisionTranslationAffected == null
            ? []
            : List<dynamic>.from(
                revisionTranslationAffected!.map((x) => x.toJson())),
        "metatag": metatag?.toJson(),
        "path": path == null
            ? []
            : List<dynamic>.from(path!.map((x) => x.toJson())),
        "content_translation_source": contentTranslationSource == null
            ? []
            : List<dynamic>.from(
                contentTranslationSource!.map((x) => x.toJson())),
        "content_translation_outdated": contentTranslationOutdated == null
            ? []
            : List<dynamic>.from(
                contentTranslationOutdated!.map((x) => x.toJson())),
        "field_images": fieldImages == null
            ? []
            : List<dynamic>.from(fieldImages!.map((x) => x.toJson())),
        "field_1x_image": field1XImage == null
            ? []
            : List<dynamic>.from(field1XImage!.map((x) => x.toJson())),
        "field_2x_image": field2XImage == null
            ? []
            : List<dynamic>.from(field2XImage!.map((x) => x.toJson())),
        "field_3x_image": field3XImage == null
            ? []
            : List<dynamic>.from(field3XImage!.map((x) => x.toJson())),
        "field_cover_image": fieldCoverImage == null
            ? []
            : List<dynamic>.from(fieldCoverImage!.map((x) => x.toJson())),
        "field_descriptions": fieldDescriptions == null
            ? []
            : List<dynamic>.from(fieldDescriptions!.map((x) => x.toJson())),
        "field_featured_size": fieldFeaturedSize == null
            ? []
            : List<dynamic>.from(fieldFeaturedSize!.map((x) => x)),
        "field_gallery": fieldGallery == null
            ? []
            : List<dynamic>.from(fieldGallery!.map((x) => x.toJson())),
        "field_gallery_text_title": fieldGalleryTextTitle == null
            ? []
            : List<dynamic>.from(fieldGalleryTextTitle!.map((x) => x.toJson())),
        "field_logo": fieldLogo == null
            ? []
            : List<dynamic>.from(fieldLogo!.map((x) => x.toJson())),
        "field_metatag": fieldMetatag == null
            ? []
            : List<dynamic>.from(fieldMetatag!.map((x) => x.toJson())),
        "field_remarks": fieldRemarks == null
            ? []
            : List<dynamic>.from(fieldRemarks!.map((x) => x)),
        "field_subtitle": fieldSubtitle == null
            ? []
            : List<dynamic>.from(fieldSubtitle!.map((x) => x.toJson())),
        "field_website_link": fieldWebsiteLink == null
            ? []
            : List<dynamic>.from(fieldWebsiteLink!.map((x) => x.toJson())),
        "field_weightage": fieldWeightage == null
            ? []
            : List<dynamic>.from(fieldWeightage!.map((x) => x.toJson())),
        "field_youtube_link": fieldYoutubeLink == null
            ? []
            : List<dynamic>.from(fieldYoutubeLink!.map((x) => x.toJson())),
      };
}

class Changed {
  DateTime? value;
  Format? format;

  Changed({
    this.value,
    this.format,
  });

  factory Changed.fromRawJson(String str) => Changed.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Changed.fromJson(Map<String, dynamic> json) => Changed(
        value: json["value"] == null ? null : DateTime.parse(json["value"]),
        format: formatValues.map[json["format"]]!,
      );

  Map<String, dynamic> toJson() => {
        "value": value?.toIso8601String(),
        "format": formatValues.reverse[format],
      };
}

enum Format { Y_M_D_TH_I_S_P }

final formatValues = EnumValues({"Y-m-d\\TH:i:sP": Format.Y_M_D_TH_I_S_P});

class ContentTranslationOutdated {
  bool? value;

  ContentTranslationOutdated({
    this.value,
  });

  factory ContentTranslationOutdated.fromRawJson(String str) =>
      ContentTranslationOutdated.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContentTranslationOutdated.fromJson(Map<String, dynamic> json) =>
      ContentTranslationOutdated(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class ContentTranslationSource {
  String? value;

  ContentTranslationSource({
    this.value,
  });

  factory ContentTranslationSource.fromRawJson(String str) =>
      ContentTranslationSource.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContentTranslationSource.fromJson(Map<String, dynamic> json) =>
      ContentTranslationSource(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class Field {
  int? targetId;
  String? alt;
  String? title;
  int? width;
  int? height;
  Field1XImageTargetType? targetType;
  String? targetUuid;
  String? url;

  Field({
    this.targetId,
    this.alt,
    this.title,
    this.width,
    this.height,
    this.targetType,
    this.targetUuid,
    this.url,
  });

  factory Field.fromRawJson(String str) => Field.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        targetId: json["target_id"],
        alt: json["alt"],
        title: json["title"],
        width: json["width"],
        height: json["height"],
        targetType: field1XImageTargetTypeValues.map[json["target_type"]]!,
        targetUuid: json["target_uuid"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "target_id": targetId,
        "alt": alt,
        "title": title,
        "width": width,
        "height": height,
        "target_type": field1XImageTargetTypeValues.reverse[targetType],
        "target_uuid": targetUuid,
        "url": url,
      };
}

enum Field1XImageTargetType { FILE }

final field1XImageTargetTypeValues =
    EnumValues({"file": Field1XImageTargetType.FILE});

class FieldDescription {
  int? targetId;
  int? targetRevisionId;
  FieldDescriptionTargetType? targetType;
  String? targetUuid;
  Url? url;

  FieldDescription({
    this.targetId,
    this.targetRevisionId,
    this.targetType,
    this.targetUuid,
    this.url,
  });

  factory FieldDescription.fromRawJson(String str) =>
      FieldDescription.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldDescription.fromJson(Map<String, dynamic> json) =>
      FieldDescription(
        targetId: json["target_id"],
        targetRevisionId: json["target_revision_id"],
        targetType: fieldDescriptionTargetTypeValues.map[json["target_type"]]!,
        targetUuid: json["target_uuid"],
        url: json["url"] != null ? urlValues.map[json["url"]]! : null,
      );

  Map<String, dynamic> toJson() => {
        "target_id": targetId,
        "target_revision_id": targetRevisionId,
        "target_type": fieldDescriptionTargetTypeValues.reverse[targetType],
        "target_uuid": targetUuid,
        "url": urlValues.reverse[url],
      };
}

enum FieldDescriptionTargetType { PARAGRAPH, USER }

final fieldDescriptionTargetTypeValues = EnumValues({
  "paragraph": FieldDescriptionTargetType.PARAGRAPH,
  "user": FieldDescriptionTargetType.USER
});

enum Url { USER_1, USER_7, USER_13, USER_6 }

final urlValues = EnumValues({
  "/user/1": Url.USER_1,
  "/user/13": Url.USER_13,
  "/user/6": Url.USER_6,
  "/user/7": Url.USER_7
});

class FieldMetatag {
  FieldMetatagValue? value;

  FieldMetatag({
    this.value,
  });

  factory FieldMetatag.fromRawJson(String str) =>
      FieldMetatag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldMetatag.fromJson(Map<String, dynamic> json) => FieldMetatag(
        value: json["value"] == null
            ? null
            : FieldMetatagValue.fromJson(json["value"]),
      );

  Map<String, dynamic> toJson() => {
        "value": value?.toJson(),
      };
}

class FieldMetatagValue {
  String? description;
  String? title;

  FieldMetatagValue({
    this.description,
    this.title,
  });

  factory FieldMetatagValue.fromRawJson(String str) =>
      FieldMetatagValue.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldMetatagValue.fromJson(Map<String, dynamic> json) =>
      FieldMetatagValue(
        description: json["description"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "title": title,
      };
}

class FieldELink {
  String? uri;
  String? title;
  List<dynamic>? options;

  FieldELink({
    this.uri,
    this.title,
    this.options,
  });

  factory FieldELink.fromRawJson(String str) =>
      FieldELink.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldELink.fromJson(Map<String, dynamic> json) => FieldELink(
        uri: json["uri"],
        title: json["title"],
        options: json["options"] == null
            ? []
            : List<dynamic>.from(json["options"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "uri": uri,
        "title": title,
        "options":
            options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
      };
}

class FieldWeightage {
  int? value;

  FieldWeightage({
    this.value,
  });

  factory FieldWeightage.fromRawJson(String str) =>
      FieldWeightage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldWeightage.fromJson(Map<String, dynamic> json) => FieldWeightage(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class Metatag {
  MetatagValue? value;

  Metatag({
    this.value,
  });

  factory Metatag.fromRawJson(String str) => Metatag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Metatag.fromJson(Map<String, dynamic> json) => Metatag(
        value:
            json["value"] == null ? null : MetatagValue.fromJson(json["value"]),
      );

  Map<String, dynamic> toJson() => {
        "value": value?.toJson(),
      };
}

class MetatagValue {
  String? canonicalUrl;
  String? title;
  String? description;

  MetatagValue({
    this.canonicalUrl,
    this.title,
    this.description,
  });

  factory MetatagValue.fromRawJson(String str) =>
      MetatagValue.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MetatagValue.fromJson(Map<String, dynamic> json) => MetatagValue(
        canonicalUrl: json["canonical_url"],
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "canonical_url": canonicalUrl,
        "title": title,
        "description": description,
      };
}

class Path {
  String? alias;
  int? pid;
  Langcode? langcode;

  Path({
    this.alias,
    this.pid,
    this.langcode,
  });

  factory Path.fromRawJson(String str) => Path.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        alias: json["alias"],
        pid: json["pid"],
        langcode: langcodeValues.map[json["langcode"]]!,
      );

  Map<String, dynamic> toJson() => {
        "alias": alias,
        "pid": pid,
        "langcode": langcodeValues.reverse[langcode],
      };
}

enum Langcode { EN }

final langcodeValues = EnumValues({"en": Langcode.EN});

class Type {
  TargetId? targetId;
  TypeTargetType? targetType;
  String? targetUuid;

  Type({
    this.targetId,
    this.targetType,
    this.targetUuid,
  });

  factory Type.fromRawJson(String str) => Type.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        targetId: targetIdValues.map[json["target_id"]]!,
        targetType: typeTargetTypeValues.map[json["target_type"]]!,
        targetUuid: json["target_uuid"],
      );

  Map<String, dynamic> toJson() => {
        "target_id": targetIdValues.reverse[targetId],
        "target_type": typeTargetTypeValues.reverse[targetType],
        "target_uuid": targetUuid,
      };
}

enum TargetId { EXPERIENCE }

final targetIdValues = EnumValues({"experience": TargetId.EXPERIENCE});

enum TypeTargetType { NODE_TYPE }

final typeTargetTypeValues =
    EnumValues({"node_type": TypeTargetType.NODE_TYPE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
