import 'dart:async';

import 'package:fastshop_mobile/bloc_helpers/bloc_provider.dart';
import 'package:fastshop_mobile/models/cart.dart';
import 'package:fastshop_mobile/models/cartItem.dart';
import 'package:fastshop_mobile/models/producto.dart';
import 'package:rxdart/subjects.dart';

class CartAddition {
  Producto product;
  int count;

  CartAddition.clear(this.product, [this.count = 0]);
  CartAddition(this.product, [this.count = 1]);
}

class CartBloc implements BlocBase {
  //list of all items part of the cart
  // Set<Product> _cart = Set<Product>();
  final Cart _cart = Cart();

  final BehaviorSubject<List<CartItem>> _items =
      BehaviorSubject<List<CartItem>>.seeded([]);

  final BehaviorSubject<int> _itemCount = BehaviorSubject<int>.seeded(0);

  final StreamController<double> _itemTotalPrice =
      BehaviorSubject<double>.seeded(0);

  final StreamController<CartAddition> _cartAdditionController =
      StreamController<CartAddition>();

  final StreamController<CartAddition> _cartUpdateController =
      StreamController<CartAddition>();

  CartBloc() {
    _cartAdditionController.stream.listen((addition) {
      int currentCount = _cart.itemCount;
      double currentTotalPrice = _cart.itemTotalPrice;
      _cart.add(addition.product, addition.count);
      _items.add(_cart.items);
      int updatedCount = _cart.itemCount;
      double updatedTotalPrice = _cart.itemTotalPrice;
      if (updatedCount != currentCount ||
          updatedTotalPrice != currentTotalPrice) {
        _itemCount.add(updatedCount);
        _itemTotalPrice.add(updatedTotalPrice);
      }
    });
    _cartUpdateController.stream.listen((addition) {
      int currentCount = _cart.itemCount;
      double currentTotalPrice = _cart.itemTotalPrice;
      _cart.update(addition.product, addition.count);
      _items.add(_cart.items);
      int updatedCount = _cart.itemCount;
      double updatedTotalPrice = _cart.itemTotalPrice;
      if (updatedCount != currentCount ||
          updatedTotalPrice != currentTotalPrice) {
        _itemCount.add(updatedCount);
        _itemTotalPrice.add(updatedTotalPrice);
      }
    });
  }

  Sink<CartAddition> get cartAddition => _cartAdditionController.sink;

  Sink<CartAddition> get cartUpdate => _cartUpdateController.sink;

  Stream<int> get itemCount => _itemCount.stream;

  Stream<double> get itemsTotalPrice => _itemTotalPrice.stream;

  Stream<List<CartItem>> get items => _items.stream;

  @override
  void dispose() {
    _items.close();
    _itemCount.close();
    _itemTotalPrice.close();
    _cartAdditionController.close();
    _cartUpdateController.close();
  }
}

// //size of the cart
// BehaviorSubject<int> _cartSizeController = BehaviorSubject<int>.seeded(0);
// Stream<int> get cartSize => _cartSizeController;

// //total price of the cart
// BehaviorSubject<double> _cartPriceController =
//     BehaviorSubject<double>.seeded(0.0);
// Stream<double> get cartTotalPrice => _cartPriceController;

// //items in the cart
// BehaviorSubject<List<Product>> _cartController =
//     BehaviorSubject<List<Product>>.seeded(<Product>[]);
// Stream<List<Product>> get cart => _cartController;

// @override
// void dispose() {
//   _cartSizeController?.close();
//   _cartPriceController.close();
//   _cartController.close();
// }

// CartBloc();

//   void addToCart(Product item) {
//     if (item.quantity == 0) item.quantity++;
//     _cart.contains(item)
//         //not so sure deberia llamar al item para que lo actualice ahi.
//         //para que no relodee todo el listado deberia solo actualizar
//         //el item que le incumbre (deberia llamar al cart_item_bloc)
//         ? _cart.forEach((Product f) {
//             if (f.id == item.id) {
//               f.quantity++;
//             }
//           })
//         : _cart.add(item);
//     _postActionOnCart();
//   }

//   void updateQuantity(Product item, int quantity) {
//     _cart.forEach((Product f) {
//       if (f.id == item.id) {
//         f = quantity;
//       }
//     });
//     _postActionOnCart();
//   }

//   void _postActionOnCart() {
//     _cartController.sink.add(_cart.toList());
//     _computeTotalSizeAndPrice();
//   }

//   void _computeTotalSizeAndPrice() {
//     double total = 0.0;
//     int quantity = 0;
//     _cart.forEach((Product item) {
//       total += item.price * item.quantity;
//       quantity += item.quantity;
//     });
//     _cartPriceController.sink.add(total);
//     _cartSizeController.sink.add(quantity);
//   }
// }
