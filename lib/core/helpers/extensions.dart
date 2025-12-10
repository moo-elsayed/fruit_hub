import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import '../../features/checkout/domain/entities/address_entity.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      this,
      rootNavigator: rootNavigator,
    ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
}

extension AddressFormatter on AddressEntity {
  String get formattedLocation =>
      "$streetName, ${"building".tr()} $buildingNumber, ${"floor".tr()} $floorNumber, ${"apartment".tr()} $apartmentNumber, $city";
}
