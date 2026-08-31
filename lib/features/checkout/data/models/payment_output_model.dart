import '../../domain/entities/payment_output_entity.dart';

class PaymentOutputModel {
  const PaymentOutputModel({this.customerId = ''});

  factory PaymentOutputModel.fromEntity(PaymentOutputEntity entity) =>
      PaymentOutputModel(customerId: entity.customerId);

  final String customerId;

  PaymentOutputEntity toEntity() => PaymentOutputEntity(customerId: customerId);
}
