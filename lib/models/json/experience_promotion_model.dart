// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:gsc_app/models/json/cms_experience_model.dart';

import 'cms_promotion_model.dart';

class ExpNPromoResponse {
  List<Promotion>? promotions;
  List<Experience>? experiences;

  ExpNPromoResponse({
    this.promotions,
    this.experiences,
  });

  factory ExpNPromoResponse.fromRawJson(String str) =>
      ExpNPromoResponse.fromJson(json.decode(str));

  factory ExpNPromoResponse.fromJson(Map<String, dynamic> json) =>
      ExpNPromoResponse(
        promotions: json["promotions"] == null
            ? []
            : List<Promotion>.from(
                json["promotions"]!.map((x) => Promotion.fromJson(x))),
        experiences: json["experiences"] == null
            ? []
            : List<Experience>.from(
                json["experiences"]!.map((x) => Experience.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "promotions": promotions == null
            ? []
            : List<dynamic>.from(promotions!.map((x) => x.toJson())),
        "experiences": experiences == null
            ? []
            : List<dynamic>.from(experiences!.map((x) => x.toJson())),
      };
}

class CMSExpNPromoResponse {
  List<CMS_PROMOTION>? cms_promotions;
  List<CMS_EXPERIENCE>? cms_experiences;
  CMSExpNPromoResponse({this.cms_experiences, this.cms_promotions});

  factory CMSExpNPromoResponse.fromRawJson(String str) =>
      CMSExpNPromoResponse.fromJson(json.decode(str));

  factory CMSExpNPromoResponse.fromJson(json) => CMSExpNPromoResponse(
        cms_promotions: json == null
            ? []
            : List<CMS_PROMOTION>.from(
                json!.map((x) => CMS_PROMOTION.fromJson(x))),
        //Welcome.fromJson(json.decode(str))
        cms_experiences: json["experiences"] == null
            ? []
            : List<CMS_EXPERIENCE>.from(
                json!.map((x) => CMS_EXPERIENCE.fromJson(x))),
      );
}

class Experience {
  int? nid;
  String? uuid;
  String? langcode;
  String? type;
  String? title;
  Metatag? metatag;
  String? slug;
  CoverImage? coverImage;
  ComposedBackgroundCoverImage? composedBackgroundCoverImage;
  String? featuredSize;
  CoverImage? featuredImage;
  List<CoverImage>? moreImages;
  List<ExperienceDescription>? descriptions;
  List<Gallery>? gallery;
  String? gallerySectionTitle;
  CoverImage? logo;
  String? remarks;
  String? subtitle;
  dynamic websiteLink;
  int? weightage;
  dynamic youtubeLink;
  String? buyLink;

  Experience({
    this.nid,
    this.uuid,
    this.langcode,
    this.type,
    this.title,
    this.metatag,
    this.slug,
    this.coverImage,
    this.composedBackgroundCoverImage,
    this.featuredSize,
    this.featuredImage,
    this.moreImages,
    this.descriptions,
    this.gallery,
    this.gallerySectionTitle,
    this.logo,
    this.remarks,
    this.subtitle,
    this.websiteLink,
    this.weightage,
    this.youtubeLink,
    this.buyLink,
  });

  factory Experience.fromRawJson(String str) =>
      Experience.fromJson(json.decode(str));

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        nid: json["nid"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        title: json["title"],
        metatag:
            json["metatag"] == null ? null : Metatag.fromJson(json["metatag"]),
        slug: json["slug"],
        coverImage: json["cover_image"] == null
            ? null
            : CoverImage.fromJson(json["cover_image"]),
        composedBackgroundCoverImage:
            json["composed_background_cover_image"] == null
                ? null
                : ComposedBackgroundCoverImage.fromJson(
                    json["composed_background_cover_image"]),
        featuredSize: json["featured_size"],
        featuredImage: json["featured_image"] == null
            ? null
            : CoverImage.fromJson(json["featured_image"]),
        moreImages: json["more_images"] == null
            ? []
            : List<CoverImage>.from(
                json["more_images"]!.map((x) => CoverImage.fromJson(x))),
        descriptions: json["descriptions"] == null
            ? []
            : List<ExperienceDescription>.from(json["descriptions"]!
                .map((x) => ExperienceDescription.fromJson(x))),
        gallery: json["gallery"] == null
            ? []
            : List<Gallery>.from(
                json["gallery"]!.map((x) => Gallery.fromJson(x))),
        gallerySectionTitle: json["gallery_section_title"],
        logo: json["logo"] == null ? null : CoverImage.fromJson(json["logo"]),
        remarks: json["remarks"],
        subtitle: json["subtitle"],
        websiteLink: json["website_link"],
        weightage: json["weightage"],
        youtubeLink: json["youtube_link"],
        buyLink: json["buy_link"],
      );

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "title": title,
        "metatag": metatag?.toJson(),
        "slug": slug,
        "cover_image": coverImage?.toJson(),
        "composed_background_cover_image":
            composedBackgroundCoverImage?.toJson(),
        "featured_size": featuredSize,
        "featured_image": featuredImage?.toJson(),
        "more_images": moreImages == null
            ? []
            : List<dynamic>.from(moreImages!.map((x) => x.toJson())),
        "descriptions": descriptions == null
            ? []
            : List<dynamic>.from(descriptions!.map((x) => x.toJson())),
        "gallery": gallery == null
            ? []
            : List<dynamic>.from(gallery!.map((x) => x.toJson())),
        "gallery_section_title": gallerySectionTitle,
        "logo": logo?.toJson(),
        "remarks": remarks,
        "subtitle": subtitle,
        "website_link": websiteLink,
        "weightage": weightage,
        "youtube_link": youtubeLink,
        "buy_link": buyLink,
      };
}

class ComposedBackgroundCoverImage {
  String? backgroundImage;

  ComposedBackgroundCoverImage({
    this.backgroundImage,
  });

  factory ComposedBackgroundCoverImage.fromRawJson(String str) =>
      ComposedBackgroundCoverImage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ComposedBackgroundCoverImage.fromJson(Map<String, dynamic> json) =>
      ComposedBackgroundCoverImage(
        backgroundImage: json["backgroundImage"],
      );

  Map<String, dynamic> toJson() => {
        "backgroundImage": backgroundImage,
      };
}

class CoverImage {
  String? alt;
  String? title;
  int? width;
  int? height;
  String? url;

  CoverImage({
    this.alt,
    this.title,
    this.width,
    this.height,
    this.url,
  });

  factory CoverImage.fromRawJson(String str) =>
      CoverImage.fromJson(json.decode(str));

  factory CoverImage.fromJson(Map<String, dynamic> json) => CoverImage(
        alt: json["alt"],
        title: json["title"],
        width: json["width"],
        height: json["height"],
        url: json["url"],
      );
  Map<String, dynamic> toJson() => {
        "alt": alt,
        "title": title,
        "width": width,
        "height": height,
        "url": url,
      };
}

class ExperienceDescription {
  int? id;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  String? backgroundImage;
  bool? fullWidth;
  String? content;
  String? cssClass;
  dynamic cta;
  dynamic image;
  String? title;
  String? video;
  BackgroundColor? backgroundColor;
  List<dynamic>? slideshow;
  List<dynamic>? links;
  String? secondContent;
  dynamic secondImage;
  List<dynamic>? secondSlideshow;
  String? secondTitle;
  String? secondVideo;
  List<dynamic>? secondLinks;
  bool? switchPosition;

  ExperienceDescription({
    this.id,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.backgroundImage,
    this.fullWidth,
    this.content,
    this.cssClass,
    this.cta,
    this.image,
    this.title,
    this.video,
    this.backgroundColor,
    this.slideshow,
    this.links,
    this.secondContent,
    this.secondImage,
    this.secondSlideshow,
    this.secondTitle,
    this.secondVideo,
    this.secondLinks,
    this.switchPosition,
  });

  factory ExperienceDescription.fromRawJson(String str) =>
      ExperienceDescription.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExperienceDescription.fromJson(Map<String, dynamic> json) =>
      ExperienceDescription(
        id: json["id"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        status: json["status"],
        backgroundImage: json["backgroundImage"],
        fullWidth: json["full_width"],
        content: json["content"],
        cssClass: json["cssClass"],
        cta: json["cta"],
        image: json["image"],
        title: json["title"],
        video: json["video"],
        backgroundColor: json["backgroundColor"] == null
            ? null
            : BackgroundColor.fromJson(json["backgroundColor"]),
        slideshow: json["slideshow"] == null
            ? []
            : List<dynamic>.from(json["slideshow"]!.map((x) => x)),
        links: json["links"] == null
            ? []
            : List<dynamic>.from(json["links"]!.map((x) => x)),
        secondContent: json["second_content"],
        secondImage: json["second_image"],
        secondSlideshow: json["second_slideshow"] == null
            ? []
            : List<dynamic>.from(json["second_slideshow"]!.map((x) => x)),
        secondTitle: json["second_title"],
        secondVideo: json["second_video"],
        secondLinks: json["second_links"] == null
            ? []
            : List<dynamic>.from(json["second_links"]!.map((x) => x)),
        switchPosition: json["switch_position"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "backgroundImage": backgroundImage,
        "full_width": fullWidth,
        "content": content,
        "cssClass": cssClass,
        "cta": cta,
        "image": image,
        "title": title,
        "video": video,
        "backgroundColor": backgroundColor?.toJson(),
        "slideshow": slideshow == null
            ? []
            : List<dynamic>.from(slideshow!.map((x) => x)),
        "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x)),
        "second_content": secondContent,
        "second_image": secondImage,
        "second_slideshow": secondSlideshow == null
            ? []
            : List<dynamic>.from(secondSlideshow!.map((x) => x)),
        "second_title": secondTitle,
        "second_video": secondVideo,
        "second_links": secondLinks == null
            ? []
            : List<dynamic>.from(secondLinks!.map((x) => x)),
        "switch_position": switchPosition,
      };
}

class BackgroundColor {
  String? color;
  double? opacity;

  BackgroundColor({
    this.color,
    this.opacity,
  });

  factory BackgroundColor.fromRawJson(String str) =>
      BackgroundColor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BackgroundColor.fromJson(Map<String, dynamic> json) =>
      BackgroundColor(
        color: json["color"],
        opacity: json["opacity"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "color": color,
        "opacity": opacity,
      };
}

class WebsiteLinkElement {
  String? title;
  String? uri;

  WebsiteLinkElement({
    this.title,
    this.uri,
  });

  factory WebsiteLinkElement.fromRawJson(String str) =>
      WebsiteLinkElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WebsiteLinkElement.fromJson(Map<String, dynamic> json) =>
      WebsiteLinkElement(
        title: json["title"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "uri": uri,
      };
}

class Gallery {
  int? id;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  String? content;
  CoverImage? image;
  String? title;
  String? video;
  List<dynamic>? categories;

  Gallery({
    this.id,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.content,
    this.image,
    this.title,
    this.video,
    this.categories,
  });

  factory Gallery.fromRawJson(String str) => Gallery.fromJson(json.decode(str));

  factory Gallery.fromJson(Map<String, dynamic> json) => Gallery(
        id: json["id"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        status: json["status"],
        content: json["content"],
        image:
            json["image"] == null ? null : CoverImage.fromJson(json["image"]),
        title: json["title"],
        video: json["video"],
        categories: json["categories"] == null
            ? []
            : List<dynamic>.from(json["categories"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "content": content,
        "image": image?.toJson(),
        "title": title,
        "video": video,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x)),
      };
}

class Metatag {
  String? title;
  String? description;

  Metatag({
    this.title,
    this.description,
  });

  factory Metatag.fromRawJson(String str) => Metatag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Metatag.fromJson(Map<String, dynamic> json) => Metatag(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}

class Promotion {
  int? nid;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  String? title;
  Metatag? metatag;
  String? slug;
  String? body;
  dynamic category;
  CoverImage? coverImage;
  ComposedBackgroundCoverImage? composedBackgroundCoverImage;
  String? description;
  DateTime? endDatetime;
  bool? featuredInFront;
  bool? highlightedInPromo;
  List<dynamic>? images;
  List<dynamic>? movies;
  List<ParticipatingOutlet>? participatingOutlets;
  String? previewHashCode;
  bool? previewMode;
  String? promotionDetails;
  DateTime? startDatetime;
  String? subtitle;
  String? termsAndConditions;
  String? buyLink;
  dynamic primaryCta;
  CategoryClass? promotionParty;

  Promotion({
    this.nid,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.title,
    this.metatag,
    this.slug,
    this.body,
    this.category,
    this.coverImage,
    this.composedBackgroundCoverImage,
    this.description,
    this.endDatetime,
    this.featuredInFront,
    this.highlightedInPromo,
    this.images,
    this.movies,
    this.participatingOutlets,
    this.previewHashCode,
    this.previewMode,
    this.promotionDetails,
    this.startDatetime,
    this.subtitle,
    this.termsAndConditions,
    this.buyLink,
    this.primaryCta,
    this.promotionParty,
  });

  factory Promotion.fromRawJson(String str) =>
      Promotion.fromJson(json.decode(str));

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        nid: json["nid"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"]!,
        status: json["status"],
        title: json["title"],
        metatag:
            json["metatag"] == null ? null : Metatag.fromJson(json["metatag"]),
        slug: json["slug"],
        body: json["body"],
        category: json["category"],
        coverImage: json["cover_image"] == null
            ? null
            : CoverImage.fromJson(json["cover_image"]),
        composedBackgroundCoverImage:
            json["composed_background_cover_image"] == null
                ? null
                : ComposedBackgroundCoverImage.fromJson(
                    json["composed_background_cover_image"]),
        description: json["description"],
        endDatetime: json["end_datetime"] == null
            ? null
            : DateTime.parse(json["end_datetime"]),
        featuredInFront: json["featured_in_front"],
        highlightedInPromo: json["highlighted_in_promo"],
        images: json["images"] == null
            ? []
            : List<dynamic>.from(json["images"]!.map((x) => x)),
        movies: json["movies"] == null
            ? []
            : List<dynamic>.from(json["movies"]!.map((x) => x)),
        participatingOutlets: json["participating_outlets"] == null
            ? []
            : List<ParticipatingOutlet>.from(json["participating_outlets"]!
                .map((x) => ParticipatingOutlet.fromJson(x))),
        previewHashCode: json["preview_hash_code"],
        previewMode: json["preview_mode"],
        promotionDetails: json["promotion_details"],
        startDatetime: json["start_datetime"] == null
            ? null
            : DateTime.parse(json["start_datetime"]),
        subtitle: json["subtitle"],
        termsAndConditions: json["terms_and_conditions"],
        buyLink: json["buy_link"],
        primaryCta: json["primary_cta"],
        promotionParty: json["promotion_party"] == null
            ? null
            : CategoryClass.fromJson(json["promotion_party"]),
      );

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "title": title,
        "metatag": metatag?.toJson(),
        "slug": slug,
        "body": body,
        "category": category,
        "cover_image": coverImage?.toJson(),
        "composed_background_cover_image":
            composedBackgroundCoverImage?.toJson(),
        "description": description,
        "end_datetime": endDatetime?.toIso8601String(),
        "featured_in_front": featuredInFront,
        "highlighted_in_promo": highlightedInPromo,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "movies":
            movies == null ? [] : List<dynamic>.from(movies!.map((x) => x)),
        "participating_outlets": participatingOutlets == null
            ? []
            : List<dynamic>.from(participatingOutlets!.map((x) => x.toJson())),
        "preview_hash_code": previewHashCode,
        "preview_mode": previewMode,
        "promotion_details": promotionDetails,
        "start_datetime": startDatetime?.toIso8601String(),
        "subtitle": subtitle,
        "terms_and_conditions": termsAndConditions,
        "buy_link": buyLink,
        "primary_cta": primaryCta,
        "promotion_party": promotionParty?.toJson(),
      };
}

class CategoryClass {
  int? tid;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  String? name;
  String? description;
  int? weight;
  Metatag? metatag;
  String? slug;
  CoverImage? icon;

  CategoryClass({
    this.tid,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.name,
    this.description,
    this.weight,
    this.metatag,
    this.slug,
    this.icon,
  });

  factory CategoryClass.fromRawJson(String str) =>
      CategoryClass.fromJson(json.decode(str));

  factory CategoryClass.fromJson(Map<String, dynamic> json) => CategoryClass(
        tid: json["tid"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        status: json["status"],
        name: json["name"],
        description: json["description"],
        weight: json["weight"],
        metatag:
            json["metatag"] == null ? null : Metatag.fromJson(json["metatag"]),
        slug: json["slug"],
        icon: json["icon"] == null ? null : CoverImage.fromJson(json["icon"]),
      );
  Map<String, dynamic> toJson() => {
        "tid": tid,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "name": name,
        "description": description,
        "weight": weight,
        "metatag": metatag?.toJson(),
        "slug": slug,
        "icon": icon?.toJson(),
      };
}

class ParticipatingOutlet {
  int? nid;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  String? title;
  Metatag? metatag;
  String? slug;
  String? body;
  CoverImage? coverImage;
  ComposedBackgroundCoverImage? composedBackgroundCoverImage;
  List<WebsiteLinkElement>? ctas;
  List<ParticipatingOutletDescription>? descriptions;
  List<dynamic>? gallery;
  String? gallerySectionTitle;
  dynamic primaryCta;
  int? weightage;
  String? buyLink;

  ParticipatingOutlet({
    this.nid,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.title,
    this.metatag,
    this.slug,
    this.body,
    this.coverImage,
    this.composedBackgroundCoverImage,
    this.ctas,
    this.descriptions,
    this.gallery,
    this.gallerySectionTitle,
    this.primaryCta,
    this.weightage,
    this.buyLink,
  });

  factory ParticipatingOutlet.fromRawJson(String str) =>
      ParticipatingOutlet.fromJson(json.decode(str));

  factory ParticipatingOutlet.fromJson(Map<String, dynamic> json) =>
      ParticipatingOutlet(
        nid: json["nid"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        status: json["status"],
        title: json["title"],
        metatag:
            json["metatag"] == null ? null : Metatag.fromJson(json["metatag"]),
        slug: json["slug"],
        body: json["body"],
        coverImage: json["cover_image"] == null
            ? null
            : CoverImage.fromJson(json["cover_image"]),
        composedBackgroundCoverImage:
            json["composed_background_cover_image"] == null
                ? null
                : ComposedBackgroundCoverImage.fromJson(
                    json["composed_background_cover_image"]),
        ctas: json["ctas"] == null
            ? []
            : List<WebsiteLinkElement>.from(
                json["ctas"]!.map((x) => WebsiteLinkElement.fromJson(x))),
        descriptions: json["descriptions"] == null
            ? []
            : List<ParticipatingOutletDescription>.from(json["descriptions"]!
                .map((x) => ParticipatingOutletDescription.fromJson(x))),
        gallery: json["gallery"] == null
            ? []
            : List<dynamic>.from(json["gallery"]!.map((x) => x)),
        gallerySectionTitle: json["gallery_section_title"],
        primaryCta: json["primary_cta"],
        weightage: json["weightage"],
        buyLink: json["buy_link"],
      );

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "title": title,
        "metatag": metatag?.toJson(),
        "slug": slug,
        "body": body,
        "cover_image": coverImage?.toJson(),
        "composed_background_cover_image":
            composedBackgroundCoverImage?.toJson(),
        "ctas": ctas == null
            ? []
            : List<dynamic>.from(ctas!.map((x) => x.toJson())),
        "descriptions": descriptions == null
            ? []
            : List<dynamic>.from(descriptions!.map((x) => x.toJson())),
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "gallery_section_title": gallerySectionTitle,
        "primary_cta": primaryCta,
        "weightage": weightage,
        "buy_link": buyLink,
      };
}

class ParticipatingOutletDescription {
  int? id;
  String? uuid;
  String? langcode;
  String? type;
  bool? status;
  BackgroundColor? backgroundColor;
  String? backgroundImage;
  String? cssClass;
  String? cta;
  bool? fullWidth;
  String? content;
  dynamic image;
  List<dynamic>? slideshow;
  String? title;
  String? video;
  List<dynamic>? links;
  String? secondContent;
  dynamic secondImage;
  List<dynamic>? secondSlideshow;
  String? secondTitle;
  String? secondVideo;
  List<dynamic>? secondLinks;
  bool? switchPosition;

  ParticipatingOutletDescription({
    this.id,
    this.uuid,
    this.langcode,
    this.type,
    this.status,
    this.backgroundColor,
    this.backgroundImage,
    this.cssClass,
    this.cta,
    this.fullWidth,
    this.content,
    this.image,
    this.slideshow,
    this.title,
    this.video,
    this.links,
    this.secondContent,
    this.secondImage,
    this.secondSlideshow,
    this.secondTitle,
    this.secondVideo,
    this.secondLinks,
    this.switchPosition,
  });

  factory ParticipatingOutletDescription.fromRawJson(String str) =>
      ParticipatingOutletDescription.fromJson(json.decode(str));

  factory ParticipatingOutletDescription.fromJson(Map<String, dynamic> json) =>
      ParticipatingOutletDescription(
        id: json["id"],
        uuid: json["uuid"],
        langcode: json["langcode"],
        type: json["type"],
        status: json["status"],
        backgroundColor: json["backgroundColor"] == null
            ? null
            : BackgroundColor.fromJson(json["backgroundColor"]),
        backgroundImage: json["backgroundImage"],
        cssClass: json["cssClass"],
        cta: json["cta"],
        fullWidth: json["full_width"],
        content: json["content"],
        image: json["image"],
        slideshow: json["slideshow"] == null
            ? []
            : List<dynamic>.from(json["slideshow"]!.map((x) => x)),
        title: json["title"],
        video: json["video"],
        links: json["links"] == null
            ? []
            : List<dynamic>.from(json["links"]!.map((x) => x)),
        secondContent: json["second_content"],
        secondImage: json["second_image"],
        secondSlideshow: json["second_slideshow"] == null
            ? []
            : List<dynamic>.from(json["second_slideshow"]!.map((x) => x)),
        secondTitle: json["second_title"],
        secondVideo: json["second_video"],
        secondLinks: json["second_links"] == null
            ? []
            : List<dynamic>.from(json["second_links"]!.map((x) => x)),
        switchPosition: json["switch_position"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "langcode": langcode,
        "type": type,
        "status": status,
        "backgroundColor": backgroundColor?.toJson(),
        "backgroundImage": backgroundImage,
        "cssClass": cssClass,
        "cta": cta,
        "full_width": fullWidth,
        "content": content,
        "image": image,
        "slideshow": slideshow == null
            ? []
            : List<dynamic>.from(slideshow!.map((x) => x)),
        "title": title,
        "video": video,
        "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x)),
        "second_content": secondContent,
        "second_image": secondImage,
        "second_slideshow": secondSlideshow == null
            ? []
            : List<dynamic>.from(secondSlideshow!.map((x) => x)),
        "second_title": secondTitle,
        "second_video": secondVideo,
        "second_links": secondLinks == null
            ? []
            : List<dynamic>.from(secondLinks!.map((x) => x)),
        "switch_position": switchPosition,
      };
}
