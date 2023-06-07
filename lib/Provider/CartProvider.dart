import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/promoCodeProvider.dart';
import 'package:eshop_multivendor/repository/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Model/User.dart';
import '../Screen/Dashboard/Dashboard.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/snackbar.dart';
import 'UserProvider.dart';

class CartProvider extends ChangeNotifier {
  List<File> prescriptionImages = [];
  List<String> productVariantIds = [];
  List<String> productIds = [];
  List<User> addressList = [];
  List<Promo> promoList = [];
  final List<TextEditingController> controller = [];
  TextEditingController noteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController promoC = TextEditingController();
  double totalPrice = 0, oriPrice = 0, deliveryCharge = 0, taxPer = 0;
  int? selectedAddress = 0;
  String? selAddress, payMethod, selTime, selDate, promocode;
  bool? isTimeSlot,
      isPromoValid = false,
      isUseWallet = false,
      isPayLayShow = true;
  int? selectedTime, selectedDate, selectedMethod;
  bool saveLater = false, addCart = false;
  double promoAmt = 0;
  double remWalBal = 0, usedBalance = 0;
  bool isAvailable = true;
  String? razorpayId,
      paystackId,
      stripeId,
      stripeSecret,
      stripeMode = 'test',
      stripeCurCode,
      stripePayId,
      paytmMerId,
      paytmMerKey;
  bool placeOrder = true;

  String? midtransPaymentMode,
      midtransPaymentMethod,
      midtrashClientKey,
      midTranshMerchandId,
      midtransServerKey;

  String? myfatoorahToken,
      myfatoorahPaymentMode,
      myfatoorahSuccessUrl,
      myfatoorahErrorUrl,
      myfatoorahLanguage,
      myfatoorahCountry;
  bool payTesting = true;
  bool isPromoLen = false;
  List<SectionModel> saveLaterList = [];
  List<Model> deliverableList = [];
  StateSetter? checkoutState;
  bool deliverable = false;

  double codDeliverChargesOfShipRocket = 0.0,
      prePaidDeliverChargesOfShipRocket = 0.0;
  bool? isLocalDelCharge;
  bool isShippingDeliveryChargeApplied = false;

  String shipRocketDeliverableDate = '';
  bool? isAddressChange;

  get getprescriptionImages => prescriptionImages;

  setprescriptionImages(List<File> prescriptionImagesList) {
    prescriptionImages = prescriptionImagesList;
    notifyListeners();
  }

  setproVarIds(productVariantIdsValue) {
    productVariantIds = productVariantIdsValue;
    notifyListeners();
  }

  setProductIds(productIdsValue) {
    productIds = productIdsValue;
  }

  setaddressList(addressListValue) {
    addressList = addressListValue;
  }

  setpromoList(promoListValue) {
    promoList = promoListValue;
  }

  settotalPrice(totalPriceValue) {
    totalPrice = totalPriceValue;
  }

  setselectedAddress(selectedAddressValue) {
    selectedAddress = selectedAddressValue;
  }

  List<SectionModel> _cartList = [];

  get cartList => _cartList;
  bool _isProgress = false;

  get cartIdList => _cartList.map((fav) => fav.varientId).toList();

  /* String? qtyList(String id, String vId) {
    SectionModel? tempId =
        _cartList.firstWhereOrNull((cp) => cp.id == id && cp.varientId == vId);
    notifyListeners();
    if (tempId != null) {
      return tempId.qty;
    } else {
      return '0';
    }
  }*/

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  removeCartItem(String id) {
    _cartList.removeWhere((item) => item.varientId == id);
    notifyListeners();
  }

  removeCart() {
    _cartList.clear();
    notifyListeners();
  }

  addCartItem(SectionModel? item) {
    if (item != null) {
      _cartList.add(item);
      notifyListeners();
    }
  }

  updateCartItem(String? id, String qty, int index, String vId) {
    final i = _cartList.indexWhere((cp) => cp.id == id && cp.varientId == vId);

    _cartList[i].qty = qty;
    _cartList[i].productList![0].prVarientList![index].cartCount = qty;

    notifyListeners();
  }

  setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    notifyListeners();
  }

  Future getUserCart({required String save}) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        SAVE_LATER: save,
        ONLY_DEL_CHARGE: '0'
      };

      CartRepository.fetchUserCart(parameter: parameter).then(
        (getData) {
          if (getData['error']) {
            _cartList = (getData['data'] as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();
            // _cartList = value['cartList'];
          }
        },
      );
    } catch (e) {}
  }

  Future getUserOfflineCart() async {
    if (CUR_USERID == null || CUR_USERID == '') {
      DatabaseHelper db = DatabaseHelper();
      List<String>? proIds = (await db.getCart())!;

      if (proIds.isNotEmpty) {
        try {
          var parameter = {'product_variant_ids': proIds.join(',')};
          CartRepository.fetchUserOfflineCart(parameter: parameter).then(
              (offlineCartData) async {
            String? msg = offlineCartData['message'];
            if (!offlineCartData['error']) {
              List<Product> tempList = offlineCartData['offlineCartList'];
              List<SectionModel> cartSecList = [];
              for (int i = 0; i < tempList.length; i++) {
                for (int j = 0; j < tempList[i].prVarientList!.length; j++) {
                  if (proIds.contains(tempList[i].prVarientList![j].id)) {
                    String qty = (await db.checkCartItemExists(
                        tempList[i].id!, tempList[i].prVarientList![j].id!))!;
                    List<Product>? prList = [];
                    prList.add(tempList[i]);
                    cartSecList.add(
                      SectionModel(
                        id: tempList[i].id,
                        varientId: tempList[i].prVarientList![j].id,
                        qty: qty,
                        productList: prList,
                      ),
                    );
                  }
                }
              }
              _cartList = cartSecList;
            }
            _isProgress = false;
          }, onError: (error) {});
        } catch (e) {}
      } else {
        _isProgress = false;
      }
    } else {
      _cartList = [];
      _isProgress = false;
    }
  }

/*  Future<void> checkDeliverable(
      {required int from,
      required BuildContext context,
      required Function update}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);
        String? varientId;

        for (SectionModel sec in cartList) {
          varientId = varientId != null
              ? '$varientId,${sec.varientId!}'
              : sec.varientId;
        }
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: varientId,
          //  ADD_ID: selAddress,
          DEL_PINCODE: addressList[selectedAddress!].pincode
        };
        CartRepository.checkDeliverable(parameter: parameter).then((getData) {
          print("check deliverable getdata***$getData");
          bool error = getData['error'];
          String? msg = getData['message'];
          List data = getData['data'];
          context.read<CartProvider>().setProgress(false);

          if (error) {
            deliverableList =
                (data).map((data) => Model.checkDeliverable(data)).toList();

            checkoutState!(() {
              deliverable = false;
            });

            setSnackbar(msg!, context);
            context.read<CartProvider>().setProgress(false);
          } else {
            print('data****$data');
            if (data.isEmpty) {
              print('data inner');

              deliverable = true;
              update();

              if (checkoutState != null) {
                checkoutState!(() {});
              }
            } else {
              bool isDeliverible = false;
              bool? isShipRocket;
              deliverableList =
                  (data).map((data) => Model.checkDeliverable(data)).toList();

              for (int i = 0; i < deliverableList.length; i++) {
                if (deliverableList[i].isDel == false) {
                  isDeliverible = false;
                  break;
                } else {
                  isDeliverible = true;
                  if (deliverableList[i].delBy == 'standard_shipping') {
                    isShipRocket = true;
                  }
                }
              }
              if (isDeliverible) {
                getShipRocketDeliveryCharge(
                    shipRocket:
                        isShipRocket != null && isShipRocket ? '1' : '0',
                    context: context,
                    update: update);
              }
            }
            context.read<CartProvider>().setProgress(false);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }*/

  Future<void> saveForLater(
      {required Function update,
      required BuildContext context,
      required String? id,
      required String save,
      required String? qty,
      required double price,
      required SectionModel curItem,
      required bool fromSave,
      required String promoCode}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);
        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save
        };

        dynamic result =
            await CartRepository.manageCartAPICall(parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];
          context.read<UserProvider>().setCartCount(
                data['cart_count'],
              );
          if (save == '1') {
            saveLaterList.add(curItem);
            removeCartItem(id!);
            saveLater = false;
            update();
            oriPrice = oriPrice - price;
          } else {
            addCartItem(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            addCart = false;
            update();
            oriPrice = oriPrice + price;
          }

          totalPrice = 0;
          if (IS_SHIPROCKET_ON == '0') {
            if (!ISFLAT_DEL) {
              if (addressList.isNotEmpty &&
                  (oriPrice) <
                      double.parse(addressList[selectedAddress!].freeAmt!)) {
                deliveryCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                deliveryCharge = 0;
              }
            } else {
              if ((oriPrice) < double.parse(MIN_AMT!)) {
                deliveryCharge = double.parse(CUR_DEL_CHR!);
              } else {
                deliveryCharge = 0;
              }
            }
            totalPrice = deliveryCharge + oriPrice;
          } else {
            totalPrice = oriPrice;
          }

          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: false,
                    context: context,
                    promocode: promoCode,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            setProgress(false);
            remWalBal = 0;
            payMethod = null;
            usedBalance = 0;
            isUseWallet = false;
            isPayLayShow = true;
            update();
          } else {
            setProgress(false);
            update();
          }
        } else {
          setSnackbar(msg!, context);
        }
        setProgress(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }

  Future<void> deleteFromCart(
      {required int index,
      required List<SectionModel> cartList,
      required bool move,
      required int selPos,
      required BuildContext context,
      required Function update,
      required String promoCode,
      required int from}) async {
    isNetworkAvail = await isNetworkAvailable();

    if (isNetworkAvail) {
      try {
        setProgress(true);

        String varId;
        if (cartList[index].productList![0].availability == '0') {
          varId = cartList[index].productList![0].prVarientList![selPos].id!;
        } else {
          varId = cartList[index].varientId!;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: CUR_USERID,
        };

        print('cart param****$parameter');
        dynamic result = await CartRepository.deleteProductFromCartAPICall(
            parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];

          if (move == false) {
            /*context.read<UserProvider>().setCartCount(
                (int.parse(context.read<UserProvider>().curCartCount) - 1)
                    .toString());*/
            removeCartItem(cartList[index]
                    .varientId!) /*cartList.removeWhere(
                  (item) => item.varientId == cartList[index].varientId);*/
                ;

            oriPrice = double.parse(data[SUB_TOTAL]);
            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL) {
                if (addressList.isNotEmpty &&
                    (oriPrice) <
                        double.parse(addressList[selectedAddress!].freeAmt!)) {
                  deliveryCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  deliveryCharge = 0;
                }
                update();
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!)) {
                  deliveryCharge = double.parse(CUR_DEL_CHR!);
                } else {
                  deliveryCharge = 0;
                }
              }

              totalPrice = 0;

              totalPrice = deliveryCharge + oriPrice;
            } else {
              totalPrice = oriPrice;
            }

            if (isPromoValid!) {
              await context
                  .read<PromoCodeProvider>()
                  .validatePromocode(
                    check: false,
                    context: context,
                    promocode: promoCode,
                    update: update,
                  )
                  .then(
                (value) {
                  FocusScope.of(context).unfocus();
                  update();
                },
              );
            } else if (isUseWallet!) {
              setProgress(false);

              remWalBal = 0;
              payMethod = null;
              usedBalance = 0;
              isPayLayShow = true;
              isUseWallet = false;
              if (from == 3) {
                checkoutState!(() {});
              }
              update();
            } else {
              setProgress(false);
              if (from == 3) {
                checkoutState!(() {});
              }
              update();
            }
          } else {
            cartList.removeWhere(
                (item) => item.varientId == cartList[index].varientId);
          }
        } else {
          setSnackbar(msg!, context);
        }
        update();
        setProgress(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      isNetworkAvail = false;
      if (from == 3) {
        checkoutState!(() {});
      }
      update();
    }
  }

  Future<void> removeFromCart({
    required int index,
    required bool remove,
    required List<SectionModel> cartList,
    required bool move,
    required int selPos,
    required BuildContext context,
    required Function update,
    required String promoCode,
  }) async {
    isNetworkAvail = await isNetworkAvailable();
    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar(
        "${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
        context,
      );
    } else {
      if (isNetworkAvail) {
        try {
          setProgress(true);
          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;
              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
            }
          }
          String varId;
          if (cartList[index].productList![0].availability == '0') {
            varId = cartList[index].productList![0].prVarientList![selPos].id!;
          } else {
            varId = cartList[index].varientId!;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: varId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          print('cart param****$parameter');
          dynamic result =
              await CartRepository.manageCartAPICall(parameter: parameter);
          bool error = result['error'];
          String? msg = result['message'];
          if (!error) {
            var data = result['data'];
            String? qty = data['total_quantity'];
            context.read<UserProvider>().setCartCount(data['cart_count']);
            if (move == false) {
              if (qty == '0') remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);
              if (IS_SHIPROCKET_ON == '0') {
                if (!ISFLAT_DEL) {
                  if (addressList.isNotEmpty &&
                      (oriPrice) <
                          double.parse(
                              addressList[selectedAddress!].freeAmt!)) {
                    deliveryCharge = double.parse(
                        addressList[selectedAddress!].deliveryCharge!);
                  } else {
                    deliveryCharge = 0;
                  }
                  update();
                } else {
                  if ((oriPrice) < double.parse(MIN_AMT!)) {
                    deliveryCharge = double.parse(CUR_DEL_CHR!);
                  } else {
                    deliveryCharge = 0;
                  }
                }

                totalPrice = 0;

                totalPrice = deliveryCharge + oriPrice;
              } else {
                totalPrice = oriPrice;
              }

              if (isPromoValid!) {
                await context
                    .read<PromoCodeProvider>()
                    .validatePromocode(
                      check: false,
                      context: context,
                      promocode: promoCode,
                      update: update,
                    )
                    .then(
                  (value) {
                    FocusScope.of(context).unfocus();
                    update();
                  },
                );
              } else if (isUseWallet!) {
                setProgress(false);
                remWalBal = 0;
                payMethod = null;
                usedBalance = 0;
                isPayLayShow = true;
                isUseWallet = false;
                update();
              } else {
                setProgress(false);
                update();
              }
            } else {
              if (qty == '0') remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              }
            }
          } else {
            setSnackbar(msg!, context);
          }
          update();
          setProgress(false);
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          setProgress(false);
        }
      } else {
        isNetworkAvail = false;
        update();
      }
    }
  }

  Future<void> addAndRemoveQty({
    required String qty,
    required int from,
    required int totalLen,
    required int index,
    required double price,
    required int selectedPos,
    required double total,
    required List<SectionModel> cartList,
    required int itemCounter,
    required BuildContext context,
    required Function update,
  }) async {
    if (from == 1) {
      if (int.parse(qty) >= totalLen) {
        setSnackbar("${getTranslated(context, 'MAXQTY')!}  $qty", context);
      } else {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          (int.parse(qty) + itemCounter).toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            (int.parse(qty) + itemCounter).toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        oriPrice = (oriPrice + price);
        update();
      }
    } else if (from == 2) {
      if (int.parse(qty) <= cartList[index].productList![0].minOrderQuntity!) {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          itemCounter.toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            itemCounter.toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        update();
      } else {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          (int.parse(qty) - itemCounter).toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            (int.parse(qty) - itemCounter).toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        oriPrice = (oriPrice - price);
        update();
      }
    } else {
      db.updateCart(
        cartList[index].id!,
        cartList[index].productList![0].prVarientList![selectedPos].id!,
        qty,
      );
      updateCartItem(cartList[index].productList![0].id!, qty, selectedPos,
          cartList[index].productList![0].prVarientList![selectedPos].id!);
      oriPrice = (oriPrice - total + (int.parse(qty) * price));
      update();
    }
  }

  Future<void> removeFromCartCheckout({
    required int index,
    required bool remove,
    required List<SectionModel> cartList,
    required String promoCode,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();

    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar('${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}',
          context);
    } else {
      if (isNetworkAvail) {
        try {
          setProgress(true);
          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar(
                "${getTranslated(context, 'MIN_MSG')}$qty",
                context,
              );
            }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          dynamic result = await CartRepository.manageCartAPICall(
            parameter: parameter,
          );

          bool error = result['error'];
          String? msg = result['message'];
          if (!error) {
            var data = result['data'];

            String? qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(
                  data['cart_count'],
                );
            placeOrder = true;
            deliverable = false;
            if (qty == '0') remove = true;

            if (remove) {
              removeCartItem(cartList[index].varientId!);
            } else {
              cartList[index].qty = qty.toString();
            }

            oriPrice = double.parse(data[SUB_TOTAL]);
            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL) {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
                  deliveryCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  deliveryCharge = 0;
                }
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!)) {
                  deliveryCharge = double.parse(CUR_DEL_CHR!);
                } else {
                  deliveryCharge = 0;
                }
              }

              totalPrice = 0;

              totalPrice = deliveryCharge + oriPrice;
            } else {
              totalPrice = deliveryCharge + oriPrice;
            }

            if (isPromoValid!) {
              await context
                  .read<PromoCodeProvider>()
                  .validatePromocode(
                      check: true,
                      context: context,
                      promocode: promoCode,
                      update: update)
                  .then(
                (value) {
                  FocusScope.of(context).unfocus();
                  update();
                },
              );
            } else if (isUseWallet!) {
              checkoutState!(() {
                remWalBal = 0;
                payMethod = null;
                usedBalance = 0;
                isPayLayShow = true;
                isUseWallet = false;
              });

              setProgress(false);
              update();
            } else {
              setProgress(false);

              checkoutState!(() {});
              update();
            }
          } else {
            setSnackbar(msg!, context);
            setProgress(false);
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          setProgress(false);
        }
      } else {
        checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );

        update();
      }
    }
  }

  Future<void> addToCartCheckout({
    required int index,
    required String qty,
    required List<SectionModel> cartList,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        dynamic result =
            await CartRepository.manageCartAPICall(parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];

          String qty = data['total_quantity'];

          context.read<UserProvider>().setCartCount(data['cart_count']);
          cartList[index].qty = qty;

          oriPrice = double.parse(data['sub_total']);
          controller[index].text = qty;
          totalPrice = 0;

          placeOrder = true;
          deliverable = false;

          if (IS_SHIPROCKET_ON == '0') {
            if (!ISFLAT_DEL) {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress!].freeAmt!)) {
                deliveryCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                deliveryCharge = 0;
              }
            } else {
              if ((oriPrice) < double.parse(MIN_AMT!)) {
                deliveryCharge = double.parse(CUR_DEL_CHR!);
              } else {
                deliveryCharge = 0;
              }
            }
            totalPrice = deliveryCharge + oriPrice;
          } else {
            totalPrice = deliveryCharge + oriPrice;
          }
          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: true,
                    context: context,
                    promocode: promoC.text,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            checkoutState!(() {
              remWalBal = 0;
              payMethod = null;
              usedBalance = 0;
              isUseWallet = false;
              isPayLayShow = true;
              selectedMethod = null;
            });

            update();
          } else {
            setProgress(false);
            update();
            checkoutState!(() {});
          }
        } else {
          setSnackbar(msg!, context);
          setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      checkoutState!(() {
        isNetworkAvail = false;
      });

      update();
    }
  }

  Future<void> addToCart({
    required int index,
    required String qty,
    required List<SectionModel> cartList,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();

    if (isNetworkAvail) {
      try {
        setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };
        dynamic result =
            await CartRepository.manageCartAPICall(parameter: parameter);

        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];

          String qty = data['total_quantity'];

          context.read<UserProvider>().setCartCount(data['cart_count']);
          cartList[index].qty = qty;
          oriPrice = double.parse(data['sub_total']);

          controller[index].text = qty;
          totalPrice = 0;

          var cart = result['cart'];
          List<SectionModel> uptcartList = (cart as List)
              .map((cart) => SectionModel.fromCart(cart))
              .toList();
          setCartlist(uptcartList);

          if (IS_SHIPROCKET_ON == '0') {
            if (!ISFLAT_DEL) {
              if (addressList.isEmpty) {
                deliveryCharge = 0;
              } else {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
                  deliveryCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  deliveryCharge = 0;
                }
              }
            } else {
              if (oriPrice < double.parse(MIN_AMT!)) {
                deliveryCharge = double.parse(CUR_DEL_CHR!);
              } else {
                deliveryCharge = 0;
              }
            }
            totalPrice = deliveryCharge + oriPrice;
          } else {
            totalPrice = oriPrice;
          }

          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: false,
                    context: context,
                    promocode: promoC.text,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            setProgress(false);
            remWalBal = 0;
            payMethod = null;
            usedBalance = 0;
            isUseWallet = false;
            isPayLayShow = true;
            selectedMethod = null;
            update();
          } else {
            update();
            setProgress(false);
          }
        } else {
          setSnackbar(msg!, context);
          setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }

/*  Future<bool> checkDeliverable(Function update, BuildContext context) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);

        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: selAddress,
        };
        apiBaseHelper.postAPICall(checkCartDelApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          List data = getdata["data"];
          setProgress(false);

          if (error) {
            deliverableList =
                (data).map((data) => Model.checkDeliverable(data)).toList();

            checkoutState!(() {
              deliverable = false;
              // _placeOrder = true;
            });

            setSnackbar(msg!, context);
            setProgress(false);
            return false;
          } else {
            print("data****$data");
            if (data.isEmpty) {
              print("data inner");

              deliverable = true;
              update();

              if (checkoutState != null) {
                checkoutState!(() {});
              }
              return true;
            } else {
              print("deliverable data*******$data");
              bool isDeliverible = false;
              bool? isShipRocket;
              deliverableList =
                  (data).map((data) => Model.checkDeliverable(data)).toList();

              for (int i = 0; i < deliverableList.length; i++) {
                print("deliverable List****${deliverableList[i].delBy}");
                if (deliverableList[i].isDel == false) {
                  isDeliverible = false;
                  break;
                } else {
                  isDeliverible = true;
                  if (deliverableList[i].delBy == "standard_shipping") {
                    isShipRocket = true;
                  }
                }
              }
              print("isDeliverable*****$isDeliverible*******$isShipRocket");
              if (isDeliverible) {
                getShipRocketDeliveryCharge(
                        shipRocket:
                            isShipRocket != null && isShipRocket ? '1' : '0',
                        context: context,
                        update: update)
                    .then((value) {
                  return true;
                });
              } else {
                return true;
              }
            }
            setProgress(false);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          return false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        return false;
      }
    } else {
      isNetworkAvail = false;
      update();
      return false;
    }
    return false;
  }

  Future<void> getShipRocketDeliveryCharge(
      {required String shipRocket,
      required BuildContext context,
      required Function update}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (addressList.isNotEmpty) {
        try {
          setProgress(true);

          var parameter = {
            USER_ID: CUR_USERID,
            ADD_ID: addressList[selectedAddress!].id,
            ONLY_DEL_CHARGE: shipRocket,
            DEL_PINCODE: addressList[selectedAddress!].pincode
            // SUB_TOTAL: oriPrice.toString()
          };

          CartRepository.fetchUserCart(parameter: parameter).then((getData) {
            print("cart getdata****$getData");
            bool error = getData['error'];
            String? msg = getData['message'];
            var data = getData['data'];

            if (error) {
              setSnackbar(msg.toString(), context);
              deliverable = false;
            } else {
              if (shipRocket == '1') {
                codDeliverChargesOfShipRocket =
                    double.parse(data['delivery_charge_with_cod'].toString());

                prePaidDeliverChargesOfShipRocket = double.parse(
                    data['delivery_charge_without_cod'].toString());
                if (codDeliverChargesOfShipRocket > 0 &&
                    prePaidDeliverChargesOfShipRocket > 0) {
                  isLocalDelCharge = false;
                } else {
                  isLocalDelCharge = true;
                }

                shipRocketDeliverableDate = data['estimate_date'] ?? '';
                if (payMethod == '') {
                  deliveryCharge = codDeliverChargesOfShipRocket;
                  if (isShippingDeliveryChargeApplied == false) {
                    totalPrice = deliveryCharge + oriPrice;
                    isShippingDeliveryChargeApplied = true;
                  }
                } else {
                  if (payMethod == getTranslated(context, 'COD_LBL')) {
                    deliveryCharge = codDeliverChargesOfShipRocket;
                    if (isShippingDeliveryChargeApplied == false) {
                      totalPrice = deliveryCharge + oriPrice;
                      isShippingDeliveryChargeApplied = true;
                    }
                  } else {
                    deliveryCharge = prePaidDeliverChargesOfShipRocket;
                    if (isShippingDeliveryChargeApplied == false) {
                      totalPrice = deliveryCharge + oriPrice;
                      isShippingDeliveryChargeApplied = true;
                    }
                  }
                }
              } else {
                isLocalDelCharge = true;
                deliveryCharge = double.parse(getData[DEL_CHARGE]);
                totalPrice = deliveryCharge + oriPrice;
              }
              deliverable = true;
              // confirmDialog();
            }
            setProgress(false);
            update();

            if (checkoutState != null) {
              checkoutState!(() {});
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        }
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }*/
}
