import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/token_model.dart';
import '../services/firestore_service.dart';

class TokenListViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  TokenListViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Heatmap filter: '1year', '6months'
  String _heatmapFilter = '1year';

  // ─── Getters ───
  String get heatmapFilter => _heatmapFilter;

  /// The start date for the heatmap based on the current filter.
  DateTime get heatmapStartDate {
    final now = DateTime.now();
    if (_heatmapFilter == '6months') {
      // Use day 1 to avoid overflow (e.g., Aug 31 - 6 months = Feb 31 crash)
      return DateTime(now.year, now.month - 5, 1);
    }
    // 1 year: go back 11 months + day 1
    return DateTime(now.year - 1, now.month + 1, 1);
  }

  // ─── Actions ───

  void setHeatmapFilter(String filter) {
    _heatmapFilter = filter;
    notifyListeners();
  }

  /// Returns the query field based on user role.
  String _queryField(String role) {
    if (role == 'Travel Agent') return 'agentEmail';
    if (role == 'Hotelier') return 'hotelEmail';
    return 'cabEmail';
  }

  /// Stream of tokens sorted by createdAt descending.
  Stream<List<TokenModel>> getTokensStream(String role, String email) {
    return _firestoreService.getTokensStream(_queryField(role), email);
  }

  /// Builds heatmap data from a list of tokens, filtered by the current heatmap range.
  Map<DateTime, int> buildHeatMapData(List<TokenModel> tokens) {
    final cutoff = heatmapStartDate;
    Map<DateTime, int> data = {};
    for (var token in tokens) {
      if (token.createdAt != null) {
        var date = DateTime(token.createdAt!.year, token.createdAt!.month, token.createdAt!.day);
        if (date.isAfter(cutoff) || date.isAtSameMomentAs(cutoff)) {
          data[date] = (data[date] ?? 0) + 1;
        }
      }
    }
    return data;
  }

  /// Formats a DateTime to a readable string.
  String formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month - 1];
    int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    String minute = date.minute.toString().padLeft(2, '0');
    String amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$day $month ${date.year}, $hour:$minute $amPm';
  }

  /// Opens the mail app with a pre-filled booking confirmation email.
  Future<void> sendEmailLink(String tokenId, String customerEmail) async {
    String webUrl = "https://traveltribe-7ddea.web.app/#/verify?id=$tokenId";
    String subject = Uri.encodeComponent("Booking Confirmation - Travel Trust");
    String body = Uri.encodeComponent("Hello, your booking is confirmed. View details here: \n\n$webUrl");
    final Uri mailUri = Uri.parse("mailto:$customerEmail?subject=$subject&body=$body");
    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    }
  }
}
