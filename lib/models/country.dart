/// The two markets FINER currently supports. A user's transactions can mix
/// both currencies (the dual-currency KG+KZ segment is the product's core
/// differentiator — see FINER_Strategic_Analysis_V2, section 6.1, option C).
enum AppCountry {
  kg,
  kz;

  String get code => this == AppCountry.kg ? 'KG' : 'KZ';

  String get currencyCode => this == AppCountry.kg ? 'KGS' : 'KZT';

  String get currencySymbol => this == AppCountry.kg ? 'сом' : '₸';

  String get displayName =>
      this == AppCountry.kg ? 'Кыргызстан' : 'Казахстан';

  String get flag => this == AppCountry.kg ? '🇰🇬' : '🇰🇿';

  static AppCountry fromCode(String? code) {
    return code == 'KG' ? AppCountry.kg : AppCountry.kz;
  }
}
