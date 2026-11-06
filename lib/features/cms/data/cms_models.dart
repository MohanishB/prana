import '../../../core/models/json_readers.dart';

/// The pages an admin can edit under Admin > CMS.
enum CmsPageKey {
  contactSupport('contact_support'),
  termsPrivacy('terms_privacy');

  const CmsPageKey(this.apiValue);

  final String apiValue;
}

class CmsContact {
  const CmsContact({
    required this.email,
    required this.mobile,
    required this.website,
    required this.whatsappNumber,
  });

  final String email;
  final String mobile;
  final String website;
  final String whatsappNumber;

  bool get isEmpty =>
      email.isEmpty &&
      mobile.isEmpty &&
      website.isEmpty &&
      whatsappNumber.isEmpty;

  String get emailLink => 'mailto:$email';
  String get phoneLink => 'tel:$mobile';

  /// wa.me wants the number with the country code and no + or spaces.
  String get whatsappLink =>
      'https://wa.me/${whatsappNumber.replaceAll(RegExp(r'\D'), '')}';

  factory CmsContact.fromJson(Map<String, dynamic> json) => CmsContact(
        email: jsonString(json['email']).trim(),
        mobile: jsonString(json['mobile']).trim(),
        website: jsonString(json['website']).trim(),
        whatsappNumber: jsonString(json['whatsapp_number']).trim(),
      );
}

/// The platforms the admin can pick for a social link. [other] has no logo.
enum SocialPlatform {
  instagram,
  facebook,
  youtube,
  x,
  linkedin,
  telegram,
  pinterest,
  other;

  static SocialPlatform fromKey(String key) => SocialPlatform.values.firstWhere(
        (platform) => platform.name == key,
        orElse: () => SocialPlatform.other,
      );

  /// White logo on a transparent background; null for [other].
  String? get logoAsset =>
      this == SocialPlatform.other ? null : 'assets/images/social_$name.png';
}

class SocialLink {
  const SocialLink({
    required this.platform,
    required this.label,
    required this.url,
  });

  final SocialPlatform platform;
  final String label;
  final String url;

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        platform: SocialPlatform.fromKey(jsonString(json['platform']).trim()),
        label: jsonString(json['label']).trim(),
        url: jsonString(json['url']).trim(),
      );
}

class CmsPage {
  const CmsPage({
    required this.heading,
    required this.contentHtml,
    this.contact,
    this.socialLinks = const [],
  });

  final String heading;
  final String contentHtml;

  /// Only the Contact support page has contact details.
  final CmsContact? contact;
  final List<SocialLink> socialLinks;

  bool get hasContent =>
      heading.isNotEmpty ||
      contentHtml.trim().isNotEmpty ||
      !(contact?.isEmpty ?? true) ||
      socialLinks.isNotEmpty;

  factory CmsPage.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'];
    return CmsPage(
      heading: jsonString(json['heading']).trim(),
      contentHtml: jsonString(json['content_html']),
      contact: contact is Map<String, dynamic>
          ? CmsContact.fromJson(contact)
          : null,
      socialLinks: jsonList(json['social_links'], SocialLink.fromJson)
          .where((link) => link.url.isNotEmpty)
          .toList(growable: false),
    );
  }
}
