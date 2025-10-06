import 'package:day_night/models/purchase/purchase_models.dart';
import 'package:day_night/models/event_details.dart';

class CheckoutTickets {
  final EventDetails eventDetails;
  final PurchaseBasket basket = PurchaseBasket();

  CheckoutTickets({required this.eventDetails});

  // Get the event information
  EventDetails get event => eventDetails;

  // Get the current basket state
  PurchaseBasket get currentBasket => basket;

  // Check if the basket is ready for checkout
  bool get isReadyForCheckout => basket.isValid();

  // Get total amount to pay
  double get totalAmount => basket.totalPrice;

  // Get total number of tickets
  int get totalTickets => basket.totalQuantity;

  // Reset the basket
  void resetBasket() {
    basket.clear();
  }
}