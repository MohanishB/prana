import '../../../core/models/json_readers.dart';
import '../../consult/data/consult_models.dart';
import '../../gut_reset/data/gut_reset_models.dart';
import '../../masterclass/data/masterclass_models.dart';
import '../../masterclass/data/masterclass_offer_models.dart';
import '../../workshops/data/workshop_models.dart';

class CatalogCurrency {
  const CatalogCurrency({
    required this.code,
    required this.symbol,
    required this.countryCode,
  });

  final String code;
  final String symbol;
  final String countryCode;

  factory CatalogCurrency.fromJson(Object? value) {
    final json = jsonMap(value);
    return CatalogCurrency(
      code: jsonString(json['code']),
      symbol: jsonString(json['symbol']),
      countryCode: jsonString(json['country_code']),
    );
  }
}

/// Everything the Home screen needs in one response.
/// For a guest the "running programs" and "booked masterclasses" lists are empty.
class HomeData {
  const HomeData({
    required this.currency,
    required this.runningPrograms,
    required this.gutResetOffers,
    required this.bookedCourses,
    required this.masterclasses,
    required this.consultations,
  });

  final CatalogCurrency currency;
  final List<WorkshopProgram> runningPrograms;
  final List<GutResetOffer> gutResetOffers;
  final List<MasterclassCourse> bookedCourses;
  final List<MasterclassOffer> masterclasses;
  final List<ConsultationOffer> consultations;

  /// Programs the visitor may book now (hides a type that is upcoming/running).
  List<GutResetOffer> get bookableGutReset =>
      gutResetOffers.where((offer) => offer.canBook).toList(growable: false);

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        currency: CatalogCurrency.fromJson(json['currency']),
        runningPrograms:
            jsonList(json['gut_reset_programs'], WorkshopProgram.fromJson),
        gutResetOffers:
            jsonList(json['gut_reset_bookable'], GutResetOffer.fromJson),
        bookedCourses:
            jsonList(json['booked_masterclasses'], MasterclassCourse.fromJson),
        masterclasses:
            jsonList(json['masterclasses'], MasterclassOffer.fromJson),
        consultations:
            jsonList(json['consultations'], ConsultationOffer.fromJson),
      );
}
