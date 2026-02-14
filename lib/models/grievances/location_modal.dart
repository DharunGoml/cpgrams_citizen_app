class LocationModal {
  String villageCityTown;
  String district;
  String state;
  int pincode;

  LocationModal({
    required this.villageCityTown,
    required this.district,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'villageCityTown': villageCityTown,
      'district': district,
      'state': state,
      'pincode': pincode,
    };
  }
}
