// To parse this JSON data, do
// ignore_for_file: camel_case_types, constant_identifier_names

import 'dart:convert';

class CMS_PROMOTION {
  List<Nid>? nid;
  List<ContentTranslationSource>? uuid;
  List<Nid>? vid;
  List<ContentTranslationSource>? langcode;
  List<Type>? type;
  List<Changed>? revisionTimestamp;
  List<FieldCategory>? revisionUid;
  List<dynamic>? revisionLog;
  List<ContentTranslationOutdated>? status;
  List<FieldCategory>? uid;
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
  List<FieldCategory>? fieldCinemas;
  List<dynamic>? body;
  List<FieldCategory>? fieldCategory;
  List<FieldCoverImage>? fieldCoverImage;
  List<Field>? fieldDescription;
  List<ContentTranslationSource>? fieldEndDatetime;
  List<ContentTranslationOutdated>? fieldFeaturedInFront;
  List<ContentTranslationOutdated>? fieldHighlightedInPromo;
  List<dynamic>? fieldImages;
  List<dynamic>? fieldMetatag;
  List<dynamic>? fieldMoviesId;
  List<FieldCategory>? fieldParticipatingOutlet;
  List<ContentTranslationSource>? fieldPreviewHashCode;
  List<ContentTranslationOutdated>? fieldPreviewMode;
  List<FieldPrimaryCta>? fieldPrimaryCta;
  List<Field>? fieldPromotionDetails;
  List<FieldCategory>? fieldPromotionParty;
  List<ContentTranslationSource>? fieldStartDatetime;
  List<ContentTranslationSource>? fieldSubtitle;
  List<dynamic>? fieldTermsAndConditions;
  List<FieldCategory>? fieldUsps;

  CMS_PROMOTION({
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
    this.fieldCinemas,
    this.body,
    this.fieldCategory,
    this.fieldCoverImage,
    this.fieldDescription,
    this.fieldEndDatetime,
    this.fieldFeaturedInFront,
    this.fieldHighlightedInPromo,
    this.fieldImages,
    this.fieldMetatag,
    this.fieldMoviesId,
    this.fieldParticipatingOutlet,
    this.fieldPreviewHashCode,
    this.fieldPreviewMode,
    this.fieldPrimaryCta,
    this.fieldPromotionDetails,
    this.fieldPromotionParty,
    this.fieldStartDatetime,
    this.fieldSubtitle,
    this.fieldTermsAndConditions,
    this.fieldUsps,
  });

  factory CMS_PROMOTION.fromRawJson(String str) =>
      CMS_PROMOTION.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CMS_PROMOTION.fromJson(Map<String, dynamic> json) => CMS_PROMOTION(
        nid: json["nid"] == null
            ? []
            : List<Nid>.from(json["nid"]!.map((x) => Nid.fromJson(x))),
        uuid: json["uuid"] == null
            ? []
            : List<ContentTranslationSource>.from(
                json["uuid"]!.map((x) => ContentTranslationSource.fromJson(x))),
        vid: json["vid"] == null
            ? []
            : List<Nid>.from(json["vid"]!.map((x) => Nid.fromJson(x))),
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
            : List<FieldCategory>.from(
                json["revision_uid"]!.map((x) => FieldCategory.fromJson(x))),
        revisionLog: json["revision_log"] == null
            ? []
            : List<dynamic>.from(json["revision_log"]!.map((x) => x)),
        status: json["status"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["status"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        uid: json["uid"] == null
            ? []
            : List<FieldCategory>.from(
                json["uid"]!.map((x) => FieldCategory.fromJson(x))),
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
        fieldCinemas: json["field_cinemas"] == null
            ? []
            : List<FieldCategory>.from(
                json["field_cinemas"]!.map((x) => FieldCategory.fromJson(x))),
        body: json["body"] == null
            ? []
            : List<dynamic>.from(json["body"]!.map((x) => x)),
        fieldCategory: json["field_category"] == null
            ? []
            : List<FieldCategory>.from(
                json["field_category"]!.map((x) => FieldCategory.fromJson(x))),
        fieldCoverImage: json["field_cover_image"] == null
            ? []
            : List<FieldCoverImage>.from(json["field_cover_image"]!
                .map((x) => FieldCoverImage.fromJson(x))),
        fieldDescription: json["field_description"] == null
            ? []
            : List<Field>.from(
                json["field_description"]!.map((x) => Field.fromJson(x))),
        fieldEndDatetime: json["field_end_datetime"] == null
            ? []
            : List<ContentTranslationSource>.from(json["field_end_datetime"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        fieldFeaturedInFront: json["field_featured_in_front"] == null
            ? []
            : List<ContentTranslationOutdated>.from(
                json["field_featured_in_front"]!
                    .map((x) => ContentTranslationOutdated.fromJson(x))),
        fieldHighlightedInPromo: json["field_highlighted_in_promo"] == null
            ? []
            : List<ContentTranslationOutdated>.from(
                json["field_highlighted_in_promo"]!
                    .map((x) => ContentTranslationOutdated.fromJson(x))),
        fieldImages: json["field_images"] == null
            ? []
            : List<dynamic>.from(json["field_images"]!.map((x) => x)),
        fieldMetatag: json["field_metatag"] == null
            ? []
            : List<dynamic>.from(json["field_metatag"]!.map((x) => x)),
        fieldMoviesId: json["field_movies_id"] == null
            ? []
            : List<dynamic>.from(json["field_movies_id"]!.map((x) => x)),
        fieldParticipatingOutlet: json["field_participating_outlet"] == null
            ? []
            : List<FieldCategory>.from(json["field_participating_outlet"]!
                .map((x) => FieldCategory.fromJson(x))),
        fieldPreviewHashCode: json["field_preview_hash_code"] == null
            ? []
            : List<ContentTranslationSource>.from(
                json["field_preview_hash_code"]!
                    .map((x) => ContentTranslationSource.fromJson(x))),
        fieldPreviewMode: json["field_preview_mode"] == null
            ? []
            : List<ContentTranslationOutdated>.from(json["field_preview_mode"]!
                .map((x) => ContentTranslationOutdated.fromJson(x))),
        fieldPrimaryCta: json["field_primary_cta"] == null
            ? []
            : List<FieldPrimaryCta>.from(json["field_primary_cta"]!
                .map((x) => FieldPrimaryCta.fromJson(x))),
        fieldPromotionDetails: json["field_promotion_details"] == null
            ? []
            : List<Field>.from(
                json["field_promotion_details"]!.map((x) => Field.fromJson(x))),
        fieldPromotionParty: json["field_promotion_party"] == null
            ? []
            : List<FieldCategory>.from(json["field_promotion_party"]!
                .map((x) => FieldCategory.fromJson(x))),
        fieldStartDatetime: json["field_start_datetime"] == null
            ? []
            : List<ContentTranslationSource>.from(json["field_start_datetime"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        fieldSubtitle: json["field_subtitle"] == null
            ? []
            : List<ContentTranslationSource>.from(json["field_subtitle"]!
                .map((x) => ContentTranslationSource.fromJson(x))),
        fieldTermsAndConditions: json["field_terms_and_conditions"] == null
            ? []
            : List<dynamic>.from(
                json["field_terms_and_conditions"]!.map((x) => x)),
        fieldUsps: json["field_usps"] == null
            ? []
            : List<FieldCategory>.from(
                json["field_usps"]!.map((x) => FieldCategory.fromJson(x))),
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
        "field_cinemas": fieldCinemas == null
            ? []
            : List<dynamic>.from(fieldCinemas!.map((x) => x.toJson())),
        "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x)),
        "field_category": fieldCategory == null
            ? []
            : List<dynamic>.from(fieldCategory!.map((x) => x.toJson())),
        "field_cover_image": fieldCoverImage == null
            ? []
            : List<dynamic>.from(fieldCoverImage!.map((x) => x.toJson())),
        "field_description": fieldDescription == null
            ? []
            : List<dynamic>.from(fieldDescription!.map((x) => x.toJson())),
        "field_end_datetime": fieldEndDatetime == null
            ? []
            : List<dynamic>.from(fieldEndDatetime!.map((x) => x.toJson())),
        "field_featured_in_front": fieldFeaturedInFront == null
            ? []
            : List<dynamic>.from(fieldFeaturedInFront!.map((x) => x.toJson())),
        "field_highlighted_in_promo": fieldHighlightedInPromo == null
            ? []
            : List<dynamic>.from(
                fieldHighlightedInPromo!.map((x) => x.toJson())),
        "field_images": fieldImages == null
            ? []
            : List<dynamic>.from(fieldImages!.map((x) => x)),
        "field_metatag": fieldMetatag == null
            ? []
            : List<dynamic>.from(fieldMetatag!.map((x) => x)),
        "field_movies_id": fieldMoviesId == null
            ? []
            : List<dynamic>.from(fieldMoviesId!.map((x) => x)),
        "field_participating_outlet": fieldParticipatingOutlet == null
            ? []
            : List<dynamic>.from(
                fieldParticipatingOutlet!.map((x) => x.toJson())),
        "field_preview_hash_code": fieldPreviewHashCode == null
            ? []
            : List<dynamic>.from(fieldPreviewHashCode!.map((x) => x.toJson())),
        "field_preview_mode": fieldPreviewMode == null
            ? []
            : List<dynamic>.from(fieldPreviewMode!.map((x) => x.toJson())),
        "field_primary_cta": fieldPrimaryCta == null
            ? []
            : List<dynamic>.from(fieldPrimaryCta!.map((x) => x.toJson())),
        "field_promotion_details": fieldPromotionDetails == null
            ? []
            : List<dynamic>.from(fieldPromotionDetails!.map((x) => x.toJson())),
        "field_promotion_party": fieldPromotionParty == null
            ? []
            : List<dynamic>.from(fieldPromotionParty!.map((x) => x.toJson())),
        "field_start_datetime": fieldStartDatetime == null
            ? []
            : List<dynamic>.from(fieldStartDatetime!.map((x) => x.toJson())),
        "field_subtitle": fieldSubtitle == null
            ? []
            : List<dynamic>.from(fieldSubtitle!.map((x) => x.toJson())),
        "field_terms_and_conditions": fieldTermsAndConditions == null
            ? []
            : List<dynamic>.from(fieldTermsAndConditions!.map((x) => x)),
        "field_usps": fieldUsps == null
            ? []
            : List<dynamic>.from(fieldUsps!.map((x) => x.toJson())),
      };
}

class Changed {
  DateTime? value;
  ChangedFormat? format;

  Changed({
    this.value,
    this.format,
  });

  factory Changed.fromRawJson(String str) => Changed.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Changed.fromJson(Map<String, dynamic> json) => Changed(
        value: json["value"] == null ? null : DateTime.parse(json["value"]),
        format: changedFormatValues.map[json["format"]]!,
      );

  Map<String, dynamic> toJson() => {
        "value": value?.toIso8601String(),
        "format": changedFormatValues.reverse[format],
      };
}

enum ChangedFormat { Y_M_D_TH_I_S_P }

final changedFormatValues =
    EnumValues({"Y-m-d\\TH:i:sP": ChangedFormat.Y_M_D_TH_I_S_P});

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

class FieldCategory {
  int? targetId;
  FieldCategoryTargetType? targetType;
  String? targetUuid;
  String? url;

  FieldCategory({
    this.targetId,
    this.targetType,
    this.targetUuid,
    this.url,
  });

  factory FieldCategory.fromRawJson(String str) =>
      FieldCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldCategory.fromJson(Map<String, dynamic> json) => FieldCategory(
        targetId: json["target_id"],
        targetType: fieldCategoryTargetTypeValues.map[json["target_type"]]!,
        targetUuid: json["target_uuid"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "target_id": targetId,
        "target_type": fieldCategoryTargetTypeValues.reverse[targetType],
        "target_uuid": targetUuid,
        "url": url,
      };
}

enum FieldCategoryTargetType { TAXONOMY_TERM, NODE, USER }

final fieldCategoryTargetTypeValues = EnumValues({
  "node": FieldCategoryTargetType.NODE,
  "taxonomy_term": FieldCategoryTargetType.TAXONOMY_TERM,
  "user": FieldCategoryTargetType.USER
});

class FieldCoverImage {
  int? targetId;
  String? alt;
  String? title;
  int? width;
  int? height;
  FieldCoverImageTargetType? targetType;
  String? targetUuid;
  String? url;

  FieldCoverImage({
    this.targetId,
    this.alt,
    this.title,
    this.width,
    this.height,
    this.targetType,
    this.targetUuid,
    this.url,
  });

  factory FieldCoverImage.fromRawJson(String str) =>
      FieldCoverImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldCoverImage.fromJson(Map<String, dynamic> json) =>
      FieldCoverImage(
        targetId: json["target_id"],
        alt: json["alt"],
        title: json["title"],
        width: json["width"],
        height: json["height"],
        targetType: fieldCoverImageTargetTypeValues.map[json["target_type"]]!,
        targetUuid: json["target_uuid"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "target_id": targetId,
        "alt": alt,
        "title": title,
        "width": width,
        "height": height,
        "target_type": fieldCoverImageTargetTypeValues.reverse[targetType],
        "target_uuid": targetUuid,
        "url": url,
      };
}

enum FieldCoverImageTargetType { FILE }

final fieldCoverImageTargetTypeValues =
    EnumValues({"file": FieldCoverImageTargetType.FILE});

class Field {
  String? value;
  FieldDescriptionFormat? format;
  String? processed;

  Field({
    this.value,
    this.format,
    this.processed,
  });

  factory Field.fromRawJson(String str) => Field.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        value: json["value"],
        format: fieldDescriptionFormatValues.map[json["format"]]!,
        processed: json["processed"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "format": fieldDescriptionFormatValues.reverse[format],
        "processed": processed,
      };
}

enum FieldDescriptionFormat { FULL_HTML }

final fieldDescriptionFormatValues =
    EnumValues({"full_html": FieldDescriptionFormat.FULL_HTML});

class FieldPrimaryCta {
  String? uri;
  String? title;
  List<dynamic>? options;

  FieldPrimaryCta({
    this.uri,
    this.title,
    this.options,
  });

  factory FieldPrimaryCta.fromRawJson(String str) =>
      FieldPrimaryCta.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FieldPrimaryCta.fromJson(Map<String, dynamic> json) =>
      FieldPrimaryCta(
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

class Metatag {
  Value? value;

  Metatag({
    this.value,
  });

  factory Metatag.fromRawJson(String str) => Metatag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Metatag.fromJson(Map<String, dynamic> json) => Metatag(
        value: json["value"] == null ? null : Value.fromJson(json["value"]),
      );

  Map<String, dynamic> toJson() => {
        "value": value?.toJson(),
      };
}

class Value {
  String? canonicalUrl;
  String? title;
  String? description;

  Value({
    this.canonicalUrl,
    this.title,
    this.description,
  });

  factory Value.fromRawJson(String str) => Value.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Value.fromJson(Map<String, dynamic> json) => Value(
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

class Nid {
  int? value;

  Nid({
    this.value,
  });

  factory Nid.fromRawJson(String str) => Nid.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Nid.fromJson(Map<String, dynamic> json) => Nid(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
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

enum TargetId { PROMOTION }

final targetIdValues = EnumValues({"promotion": TargetId.PROMOTION});

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
