import 'package:day_night/models/ticket_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TicketNotifier extends Notifier<List<TicketItem>> {
  @override
  List<TicketItem> build() => [];

  void addItem(TicketItem item) => state = [...state, item];

  void removeItem(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  void updateQuantity(int index, int quantity) {
    final newState = [...state];
    newState[index].quantity = quantity;
    state = newState;
  }

  void clear() => state = [];
}

final ticketProvider = NotifierProvider<TicketNotifier, List<TicketItem>>(
  () => TicketNotifier(),
);