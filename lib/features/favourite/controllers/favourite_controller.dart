import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';

import 'package:sixam_mart/features/order/domain/models/order_model.dart';

class FavouriteController extends GetxController implements GetxService {
  final FavouriteServiceInterface favouriteServiceInterface;
  FavouriteController({required this.favouriteServiceInterface});

  List<Item?>? _wishItemList;
  List<Item?>? get wishItemList => _wishItemList;

  List<Store?>? _wishStoreList;
  List<Store?>? get wishStoreList => _wishStoreList;

  List<int?> _wishItemIdList = [];
  List<int?> get wishItemIdList => _wishItemIdList;

  List<int?> _wishStoreIdList = [];
  List<int?> get wishStoreIdList => _wishStoreIdList;

  List<int> _wishOrderIdList = [];
  List<int> get wishOrderIdList => _wishOrderIdList;

  List<OrderModel>? _wishOrderList;
  List<OrderModel>? get wishOrderList => _wishOrderList;

  bool _isRemoving = false;
  bool get isRemoving => _isRemoving;
  bool _hasError = false;
  bool get hasError => _hasError;

  void addToFavouriteList(Item? product, int? storeID, bool isStore, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();
    if (isStore) {
      _wishStoreList ??= [];
      _wishStoreIdList.add(storeID);
      _wishStoreList!.add(Store());
    } else {
      _wishItemList ??= [];
      _wishItemList!.add(product);
      _wishItemIdList.add(product!.id);
    }
    if (AuthHelper.isLoggedIn()) {
      final ResponseModel responseModel = await favouriteServiceInterface.addFavouriteList(isStore ? storeID : product!.id, isStore);
      if (responseModel.isSuccess) {
        showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
      } else {
        if (isStore) {
          _wishStoreIdList.remove(storeID);
          _wishStoreList!.removeLast();
        } else {
          _wishItemIdList.remove(product!.id);
          _wishItemList!.remove(product);
        }
        if (responseModel.message == 'Unauthenticated') {
          showCustomSnackBar('session_time_out'.tr, getXSnackBar: getXSnackBar);
          Get.find<AuthController>().clearSharedData(removeToken: false);
          removeFavourite();
          Get.offAllNamed<void>(RouteHelper.getInitialRoute());
        } else {
          showCustomSnackBar(responseModel.message, getXSnackBar: getXSnackBar);
        }
      }
    } else {
      showCustomSnackBar('added_successfully'.tr, isError: false, getXSnackBar: getXSnackBar);
    }
    _isRemoving = false;
    update();
  }

  void removeFromFavouriteList(int? id, bool isStore, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();

    int idIndex = -1;
    int? storeId, itemId;
    Store? store;
    Item? item;
    if (isStore) {
      idIndex = _wishStoreIdList.indexOf(id);
      if (idIndex != -1) {
        storeId = id;
        _wishStoreIdList.removeAt(idIndex);
        store = _wishStoreList![idIndex];
        _wishStoreList!.removeAt(idIndex);
      }
    } else {
      idIndex = _wishItemIdList.indexOf(id);
      if (idIndex != -1) {
        itemId = id;
        _wishItemIdList.removeAt(idIndex);
        item = _wishItemList![idIndex];
        _wishItemList!.removeAt(idIndex);
      }
    }
    if (AuthHelper.isLoggedIn()) {
      final ResponseModel responseModel = await favouriteServiceInterface.removeFavouriteList(id, isStore);
      if (responseModel.isSuccess) {
        showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
      } else {
        if (isStore) {
          _wishStoreIdList.add(storeId);
          _wishStoreList!.add(store);
        } else {
          _wishItemIdList.add(itemId);
          _wishItemList!.add(item);
        }
        if (responseModel.message == 'Unauthenticated') {
          showCustomSnackBar('session_time_out'.tr, getXSnackBar: getXSnackBar);
          Get.find<AuthController>().clearSharedData(removeToken: false);
          removeFavourite();
          Get.offAllNamed<void>(RouteHelper.getInitialRoute());
        } else {
          showCustomSnackBar(responseModel.message, getXSnackBar: getXSnackBar);
        }
      }
    } else {
      showCustomSnackBar('successfully_removed'.tr, isError: false, getXSnackBar: getXSnackBar);
    }
    _isRemoving = false;
    update();
  }

  void toggleFavouriteOrder(int orderId, {OrderModel? order, bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();

    bool isFavorite = _wishOrderIdList.contains(orderId);
    if (isFavorite) {
      _wishOrderIdList.remove(orderId);
      _wishOrderList?.removeWhere((element) => element.id == orderId);
      if (AuthHelper.isLoggedIn()) {
        final ResponseModel responseModel = await favouriteServiceInterface.removeFavouriteList(orderId, false, isOrder: true);
        if (responseModel.isSuccess) {
          showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
        } else {
          _wishOrderIdList.add(orderId);
          if (order != null) {
            _wishOrderList?.add(order);
          }
          if (responseModel.message == 'Unauthenticated') {
            showCustomSnackBar('session_time_out'.tr, getXSnackBar: getXSnackBar);
            Get.find<AuthController>().clearSharedData(removeToken: false);
            removeFavourite();
            Get.offAllNamed<void>(RouteHelper.getInitialRoute());
          } else {
            showCustomSnackBar(responseModel.message, getXSnackBar: getXSnackBar);
          }
        }
      } else {
        showCustomSnackBar('successfully_removed'.tr, isError: false, getXSnackBar: getXSnackBar);
      }
    } else {
      _wishOrderIdList.add(orderId);
      if (order != null) {
        _wishOrderList ??= [];
        _wishOrderList!.add(order);
      }
      if (AuthHelper.isLoggedIn()) {
        final ResponseModel responseModel = await favouriteServiceInterface.addFavouriteList(orderId, false, isOrder: true);
        if (responseModel.isSuccess) {
          showCustomSnackBar(responseModel.message, isError: false, getXSnackBar: getXSnackBar);
        } else {
          _wishOrderIdList.remove(orderId);
          _wishOrderList?.removeWhere((element) => element.id == orderId);
          if (responseModel.message == 'Unauthenticated') {
            showCustomSnackBar('session_time_out'.tr, getXSnackBar: getXSnackBar);
            Get.find<AuthController>().clearSharedData(removeToken: false);
            removeFavourite();
            Get.offAllNamed<void>(RouteHelper.getInitialRoute());
          } else {
            showCustomSnackBar(responseModel.message, getXSnackBar: getXSnackBar);
          }
        }
      } else {
        showCustomSnackBar('added_successfully'.tr, isError: false, getXSnackBar: getXSnackBar);
      }
    }

    Get.find<SharedPreferences>()
        .setStringList('favourite_orders', _wishOrderIdList.map((e) => e.toString()).toList());
    _isRemoving = false;
    update();
  }

  void loadFavouriteOrders() {
    final List<String>? savedOrders = Get.find<SharedPreferences>().getStringList('favourite_orders');
    if (savedOrders != null) {
      _wishOrderIdList = savedOrders.map((e) => int.parse(e)).toList();
    }
  }

  Future<void> getFavouriteList() async {
    _wishItemList = null;
    _wishStoreList = null;
    _wishOrderList = null;
    _hasError = false;

    if (!AuthHelper.isLoggedIn()) {
      _wishItemList = <Item>[];
      _wishStoreList = <Store>[];
      _wishOrderList = <OrderModel>[];
      loadFavouriteOrders();
      update();
      return;
    }

    try {
      final Response response = await favouriteServiceInterface.getFavouriteList();
      if (response.statusCode == 401) {
        showCustomSnackBar('session_time_out'.tr);
        Get.find<AuthController>().clearSharedData(removeToken: false);
        removeFavourite();
        Get.offAllNamed<void>(RouteHelper.getInitialRoute());
        return;
      }
      if (response.statusCode == 304) {
        // 304 has no body; keep UI responsive by resolving to empty lists
        _wishItemList = _wishItemList ?? <Item>[];
        _wishStoreList = _wishStoreList ?? <Store>[];
        _wishOrderList = _wishOrderList ?? <OrderModel>[];
        update();
        return;
      }
      if (response.statusCode == 200) {
        _hasError = false;
        update();
        _wishItemList = [];
        _wishStoreList = [];
        _wishStoreIdList = [];
        _wishItemIdList = [];
        _wishOrderIdList = [];
        _wishOrderList = [];
        
        loadFavouriteOrders();

        if ((response.body as Map<String, dynamic>)['item'] != null) {
          final List<dynamic> itemList =
              (response.body as Map<String, dynamic>)['item'] as List;
          for (final dynamic item in itemList) {
            final itemMap = item as Map<String, dynamic>;
            final moduleType = itemMap['module_type'] as String?;
            if (moduleType == null ||
                !(Get.find<SplashController>().getModuleConfig(moduleType).newVariation ?? false) ||
                itemMap['variations'] == null ||
                ((itemMap['variations'] as List?)?.isEmpty ?? true) ||
                ((itemMap['food_variations'] as List?)?.isNotEmpty ?? false)) {
              final Item i = Item.fromJson(itemMap);
              if (Get.find<SplashController>().module == null) {
                _wishItemList!.addAll(favouriteServiceInterface.wishItemList(i));
                _wishItemIdList.addAll(favouriteServiceInterface.wishItemIdList(i));
              } else {
                _wishItemList!.add(i);
                _wishItemIdList.add(i.id);
              }
            }
          }
        }

        final List<dynamic> storeList =
            (response.body as Map<String, dynamic>)['store'] as List;
        for (final dynamic store in storeList) {
          final storeMap = store as Map<String, dynamic>;
          if (Get.find<SplashController>().module == null) {
            _wishStoreList!.addAll(favouriteServiceInterface.wishStoreList(storeMap));
            _wishStoreIdList.addAll(favouriteServiceInterface.wishStoreIdList(storeMap));
          } else {
            Store? s;
            try {
              s = Store.fromJson(storeMap);
            } catch (e) {
              debugPrint('exception create in store list create : $e');
            }
            if (s != null && Get.find<SplashController>().module!.id == s.moduleId) {
              _wishStoreList!.add(s);
              _wishStoreIdList.add(s.id);
            }
          }
        }

        if ((response.body as Map<String, dynamic>)['order'] != null) {
          final List<dynamic> orderList =
              (response.body as Map<String, dynamic>)['order'] as List;
          for (final dynamic order in orderList) {
            final orderMap = order as Map<String, dynamic>;
            final int? orderId = orderMap['id'] as int?;
            if (orderId != null) {
              if (!_wishOrderIdList.contains(orderId)) {
                _wishOrderIdList.add(orderId);
              }
              try {
                final OrderModel o = OrderModel.fromJson(orderMap);
                _wishOrderList!.add(o);
              } catch (e) {
                debugPrint('exception creating order in wishlist: $e');
              }
            }
          }
          Get.find<SharedPreferences>()
              .setStringList('favourite_orders', _wishOrderIdList.map((e) => e.toString()).toList());
        }
      } else {
        _hasError = true;
        _wishItemList = <Item?>[];
        _wishStoreList = <Store?>[];
        _wishOrderList = <OrderModel>[];
      }
    } catch (_) {
      _hasError = true;
      _wishItemList = <Item?>[];
      _wishStoreList = <Store?>[];
      _wishOrderList = <OrderModel>[];
    }
    update();
  }

  void removeFavourite() {
    _wishItemIdList = [];
    _wishStoreIdList = [];
    _wishOrderIdList = [];
    _wishOrderList = [];
  }
}
