import 'package:flutter/material.dart';
import 'package:project/data/models/booking_summary.dart';
import 'package:project/ui/cart/cart_game_item_card.dart';
import 'package:project/ui/cart/order_summary_card.dart';
import 'package:project/ui/cart/reservation_summary_card.dart';
import 'package:project/ui/checkout/checkout_screen.dart';

import 'package:provider/provider.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/cart_service.dart';
import 'cart_viewmodel.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.bookingId, this.bookingStatus});

  final String? bookingId;
  final BookingStatus? bookingStatus;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final apiClient = ApiClient();
        final viewModel = CartViewModel(
          CartRepository(CartService(apiClient)),
          bookingId: bookingId,
        );

        if (bookingId != null && bookingId!.isNotEmpty) {
          viewModel.fetchCart();
        }

        return viewModel;
      },
      child: _CartView(showCheckout: _canCheckout),
    );
  }

  bool get _canCheckout {
    return bookingStatus == null || bookingStatus == BookingStatus.pending;
  }
}

class _CartView extends StatelessWidget {
  const _CartView({required this.showCheckout});

  final bool showCheckout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cart'),
      ),
      body: Selector<CartViewModel, ({bool isLoading, String? error, bool isEmpty})>(
        selector: (_, vm) => (
          isLoading: vm.isLoading,
          error: vm.error,
          isEmpty: vm.items.isEmpty,
        ),
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: context.read<CartViewModel>().fetchCart,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          return _CartContent(showCheckout: showCheckout);
        },
      ),
    );
  }
}

/// The scrollable cart content. The [ReservationSummaryCard] is built once via
/// [context.read] so it never rebuilds when items change. Only the items list
/// and order summary are wrapped in a [Consumer] so they update in-place.
class _CartContent extends StatelessWidget {
  const _CartContent({required this.showCheckout});

  final bool showCheckout;

  @override
  Widget build(BuildContext context) {
    // Read once – reservation details don't change on quantity edits.
    final vm = context.read<CartViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReservationSummaryCard(
            storeName: vm.storeName,
            storeImage: vm.storeImage,
            slotDate: vm.slotDate,
            startTime: vm.startTime,
            endTime: vm.endTime,
            participants: vm.participants,
            chargeFee: vm.chargeFee,
          ),
          const SizedBox(height: 32),
          // Only this Consumer rebuilds when items / prices change.
          Consumer<CartViewModel>(
            builder: (context, vm, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SelectedGamesHeader(itemCount: vm.items.length),
                  const SizedBox(height: 16),
                  ...List.generate(vm.items.length, (index) {
                    final item = vm.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CartGameItemCard(
                        item: CartGameItem(
                          id: item.id,
                          boardGameId: item.boardGameId,
                          name: item.name,
                          category: item.category,
                          pricePerHour: item.rentalPrice,
                          imageUrl: item.imageUrl,
                          quantity: item.quantity,
                        ),
                        canEdit: showCheckout,
                        onRemove: () => vm.removeItem(item.boardGameId),
                        onDecrement: () {
                          if (item.quantity > 1) {
                            vm.updateQuantity(
                              item.boardGameId,
                              item.quantity - 1,
                            );
                          } else {
                            vm.removeItem(item.boardGameId);
                          }
                        },
                        onIncrement: () {
                          if (item.quantity < 100) {
                            vm.updateQuantity(
                              item.boardGameId,
                              item.quantity + 1,
                            );
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  OrderSummaryCard(
                    roomTotal: vm.chargeFee,
                    gamesTotal: vm.retailPrice,
                    serviceFee: 0,
                    totalAmount: vm.totalPrice,
                    itemCount: vm.items.length,
                    showCheckout: showCheckout,
                    onCheckout: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CheckoutScreen(
                            bookingId: vm.bookingId!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectedGamesHeader extends StatelessWidget {
  const _SelectedGamesHeader({required this.itemCount});

  static Color _borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.outlineVariant
      : const Color(0xFFE0E2EB);

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final bodyTextColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF414753);
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF181C22);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor(context))),
      ),
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Selected Games',
            style: TextStyle(
              color: titleColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          const Spacer(),
          Text(
            '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}',
            style: TextStyle(color: bodyTextColor, fontSize: 14, height: 1.43),
          ),
        ],
      ),
    );
  }
}
