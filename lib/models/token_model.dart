import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  final String id;
  final String agentEmail;
  final String? agentBusiness;
  final String? agentPhone;
  final String hotelEmail;
  final String? hotelBusiness;
  final String? hotelPhone;
  final String? hotelType;
  final String hotelStatus;
  final String cabEmail;
  final String? cabBusiness;
  final String? cabPhone;
  final String? cabType;
  final String cabStatus;
  final String? bookingDate;
  final String? expiryDate;
  final String overallStatus;
  final DateTime? createdAt;

  TokenModel({
    required this.id,
    required this.agentEmail,
    this.agentBusiness,
    this.agentPhone,
    required this.hotelEmail,
    this.hotelBusiness,
    this.hotelPhone,
    this.hotelType,
    required this.hotelStatus,
    required this.cabEmail,
    this.cabBusiness,
    this.cabPhone,
    this.cabType,
    required this.cabStatus,
    this.bookingDate,
    this.expiryDate,
    required this.overallStatus,
    this.createdAt,
  });

  factory TokenModel.fromDoc(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    Timestamp? ts = data['createdAt'];
    return TokenModel(
      id: doc.id,
      agentEmail: data['agentEmail'] ?? '',
      agentBusiness: data['agentBusiness'],
      agentPhone: data['agentPhone'],
      hotelEmail: data['hotelEmail'] ?? '',
      hotelBusiness: data['hotelBusiness'],
      hotelPhone: data['hotelPhone'],
      hotelType: data['hotelType'],
      hotelStatus: data['hotelStatus'] ?? 'Pending',
      cabEmail: data['cabEmail'] ?? '',
      cabBusiness: data['cabBusiness'],
      cabPhone: data['cabPhone'],
      cabType: data['cabType'],
      cabStatus: data['cabStatus'] ?? 'Pending',
      bookingDate: data['bookingDate'],
      expiryDate: data['expiryDate'],
      overallStatus: data['overallStatus'] ?? 'Pending',
      createdAt: ts?.toDate(),
    );
  }

  /// Returns true if both hotel and cab have approved.
  bool get isFullyApproved => hotelStatus == 'Approved' && cabStatus == 'Approved';
}
