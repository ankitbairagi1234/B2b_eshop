import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/MostLikeSection.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/homePageDialog.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/horizontalCategoryList.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/section.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:version/version.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/Favourite/FavoriteProvider.dart';
import '../../Provider/homePageProvider.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var db = DatabaseHelper();
  final ScrollController _scrollBottomBarController = ScrollController();
  DateTime? currentBackPressTime;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  int count = 1;

  @override
  bool get wantKeepAlive => true;
  bool _isToggled = false;


  setStateNow() {
    setState(() {});
  }

  setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 6)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
            getTranslated(context,
                'One of the product is out of stock, We are not able To Add In Cart')!,
            context,
          );
        }
      },
    );
  }

  List<Map<String, dynamic>> catList = [
    {"image": "assets/images/Manufacturer.png", "title": "Manufacturer",},
    {"image": "assets/images/Wholesaler.png", "title": "Wholesaler",},
    {"image": "assets/images/Retailers.png", "title": "Retailers",},
    {"image": "assets/images/Import - Export.png", "title": "Import / Export",},
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserProvider user = Provider.of<UserProvider>(context, listen: false);

      SettingProvider setting =
          Provider.of<SettingProvider>(context, listen: false);
      user.setMobile(setting.mobile);
      user.setName(setting.userName);
      user.setEmail(setting.email);
      user.setProfilePic(setting.profileUrl);
      //setUserData();
      Future.delayed(Duration.zero).then(
        (value) {
          callApi();
        },
      );

      buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      buttonSqueezeanimation = Tween(
        begin: deviceWidth! * 0.7,
        end: 50.0,
      ).animate(
        CurvedAnimation(
          parent: buttonController,
          curve: const Interval(
            0.0,
            0.150,
          ),
        ),
      );
      setSnackBarFunctionForCartMessage();
      Future.delayed(Duration.zero).then(
        (value) {
          hideAppbarAndBottomBarOnScroll(
            _scrollBottomBarController,
            context,
          );
        },
      );
    });
    super.initState();
  }

  categoryCard(int i){
    return InkWell(
      onTap: (){
        if(i == 0) {

        }else if(i ==1){

        }
        else if(i == 2){

        }
        else if(i == 3){

        }
        else {

        }
      },
      child: SizedBox(
        width: 200,
        child: Card(
            margin: EdgeInsets.all(0.6),
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                      children:[
                        Image.asset('${catList[i]['image']}',fit: BoxFit.fill,),
                      ]
                  ),
                  SizedBox(height: 5,),
                  Text("${catList[i]['title']}",textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),)
                ],
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor:  colors.primary,
        elevation: 0,
        title: Text('Hi Ankit'),
        actions: [
          Row(children: const [
            Text('General'),
            SwitchExample()
          ],)
        ],

      ),
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        child: Icon(Icons.calendar_view_month_sharp),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20.0)), //this right here
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 380,
                              child: GridView.builder(
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 40,
                                  crossAxisSpacing: 40,
                                  childAspectRatio: 0.8
                                ),
                                itemCount: catList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return  Center(
                                    child: categoryCard(index)
                                  );
                                },

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });

        },),
      body: WillPopScope(
        onWillPop: onWillPopScope,
        child: SafeArea(
          child: isNetworkAvail
              ? RefreshIndicator(
                  color: colors.primary,
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollBottomBarController,
                    slivers: [
                      SliverPersistentHeader(
                        floating: false,
                        pinned: true,
                        delegate: SearchBarHeaderDelegate(),

                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children:  [
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height/11,
                            //   child: Container(
                            //     height:MediaQuery.of(context).size.height/0.0,
                            //     width:MediaQuery.of(context).size.width,
                            //     decoration: BoxDecoration(
                            //         color:colors.primary,
                            //         borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),
                            //             bottomRight:Radius.circular(20))),
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(horizontal: 13.0),
                            //       child: Row(
                            //         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Container(
                            //             width: 100,
                            //             child: TextField(
                            //               style: TextStyle(
                            //                 color: Theme.of(context).colorScheme.fontColor,
                            //                 fontWeight: FontWeight.normal,
                            //               ),
                            //               enabled: false,
                            //               textAlign: TextAlign.left,
                            //               decoration: InputDecoration(
                            //                 focusedBorder: OutlineInputBorder(
                            //                   borderSide: BorderSide(
                            //                     color: Theme.of(context).colorScheme.lightWhite,
                            //                   ),
                            //                   borderRadius: const BorderRadius.all(
                            //                     Radius.circular(circularBorderRadius10),
                            //                   ),
                            //                 ),
                            //                 enabledBorder: const OutlineInputBorder(
                            //                   borderSide: BorderSide(color: Colors.transparent),
                            //                   borderRadius: BorderRadius.all(
                            //                     Radius.circular(circularBorderRadius10),
                            //                   ),
                            //                 ),
                            //                 contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                            //                 border: const OutlineInputBorder(
                            //                   borderSide: BorderSide(color: Colors.transparent),
                            //                   borderRadius: BorderRadius.all(
                            //                     Radius.circular(circularBorderRadius10),
                            //                   ),
                            //                 ),
                            //                 isDense: true,
                            //                 hintText: getTranslated(context, 'searchHint'),
                            //                 hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            //                   color: Theme.of(context).colorScheme.fontColor,
                            //                   fontSize: textFontSize12,
                            //                   fontWeight: FontWeight.w400,
                            //                   fontStyle: FontStyle.normal,
                            //                 ),
                            //                 prefixIcon: Padding(
                            //                   padding: const EdgeInsets.all(15.0),
                            //                   child: SvgPicture.asset(
                            //                     DesignConfiguration.setSvgPath('homepage_search'),
                            //                     height: 15,
                            //                     width: 15,
                            //                   ),
                            //                 ),
                            //                 suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                            //                   selector: (_, themeProvider) =>
                            //                       themeProvider.getThemeMode(),
                            //                   builder: (context, data, child) {
                            //                     return Padding(
                            //                       padding: const EdgeInsets.all(10.0),
                            //                       child: (data == ThemeMode.system &&
                            //                           MediaQuery.of(context).platformBrightness ==
                            //                               Brightness.light) ||
                            //                           data == ThemeMode.light
                            //                           ? SvgPicture.asset(
                            //                         DesignConfiguration.setSvgPath('voice_search'),
                            //                         height: 15,
                            //                         width: 15,
                            //                       )
                            //                           : SvgPicture.asset(
                            //                         DesignConfiguration.setSvgPath(
                            //                             'voice_search_white'),
                            //                         height: 15,
                            //                         width: 15,
                            //                       ),
                            //                     );
                            //                   },
                            //                 ),
                            //                 fillColor: Theme.of(context).colorScheme.white,
                            //                 filled: true,
                            //               ),
                            //             ),
                            //           ),
                            //           SizedBox(width: 10,),
                            //           GestureDetector(
                            //             onTap: () async {
                            //               Routes.navigateToSearchScreen(context);
                            //             },
                            //             child: Container(
                            //               width: 221,
                            //               child: TextField(
                            //                 style: TextStyle(
                            //                   color: Theme.of(context).colorScheme.fontColor,
                            //                   fontWeight: FontWeight.normal,
                            //                 ),
                            //                 enabled: false,
                            //                 textAlign: TextAlign.left,
                            //                 decoration: InputDecoration(
                            //                   focusedBorder: OutlineInputBorder(
                            //                     borderSide: BorderSide(
                            //                       color: Theme.of(context).colorScheme.lightWhite,
                            //                     ),
                            //                     borderRadius: const BorderRadius.all(
                            //                       Radius.circular(circularBorderRadius10),
                            //                     ),
                            //                   ),
                            //                   enabledBorder: const OutlineInputBorder(
                            //                     borderSide: BorderSide(color: Colors.transparent),
                            //                     borderRadius: BorderRadius.all(
                            //                       Radius.circular(circularBorderRadius10),
                            //                     ),
                            //                   ),
                            //                   contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                            //                   border: const OutlineInputBorder(
                            //                     borderSide: BorderSide(color: Colors.transparent),
                            //                     borderRadius: BorderRadius.all(
                            //                       Radius.circular(circularBorderRadius10),
                            //                     ),
                            //                   ),
                            //                   isDense: true,
                            //                   hintText: getTranslated(context, 'searchHint'),
                            //                   hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            //                     color: Theme.of(context).colorScheme.fontColor,
                            //                     fontSize: textFontSize12,
                            //                     fontWeight: FontWeight.w400,
                            //                     fontStyle: FontStyle.normal,
                            //                   ),
                            //                   prefixIcon: Padding(
                            //                     padding: const EdgeInsets.all(15.0),
                            //                     child: SvgPicture.asset(
                            //                       DesignConfiguration.setSvgPath('homepage_search'),
                            //                       height: 15,
                            //                       width: 15,
                            //                     ),
                            //                   ),
                            //                   suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                            //                     selector: (_, themeProvider) =>
                            //                         themeProvider.getThemeMode(),
                            //                     builder: (context, data, child) {
                            //                       return Padding(
                            //                         padding: const EdgeInsets.all(10.0),
                            //                         child: (data == ThemeMode.system &&
                            //                             MediaQuery.of(context).platformBrightness ==
                            //                                 Brightness.light) ||
                            //                             data == ThemeMode.light
                            //                             ? SvgPicture.asset(
                            //                           DesignConfiguration.setSvgPath('voice_search'),
                            //                           height: 15,
                            //                           width: 15,
                            //                         )
                            //                             : SvgPicture.asset(
                            //                           DesignConfiguration.setSvgPath(
                            //                               'voice_search_white'),
                            //                           height: 15,
                            //                           width: 15,
                            //                         ),
                            //                       );
                            //                     },
                            //                   ),
                            //                   fillColor: Theme.of(context).colorScheme.white,
                            //                   filled: true,
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20,),
                            CustomSlider(),
                            HorizontalCategoryList(),
                            Section(),
                            MostLikeSection(),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : NoInterNet(
                  buttonController: buttonController,
                  buttonSqueezeanimation: buttonSqueezeanimation,
                  setStateNoInternate: setStateNoInternate,
                ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().proIds.clear();
    context.read<HomePageProvider>().sliderList.clear();
    context.read<HomePageProvider>().offerImagesList.clear();
    context.read<CategoryProvider>().setCurSelected(0);
    context.read<HomePageProvider>().sectionList.clear();
    return callApi();
  }

  Future<void> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      getSetting();
      context.read<HomePageProvider>().getSliderImages();
      context.read<HomePageProvider>().getCategories(context);
      context.read<HomePageProvider>().getOfferImages();
      context.read<HomePageProvider>().getSections();
      context.read<HomePageProvider>().getMostLikeProducts();
      context.read<HomePageProvider>().getMostFavouriteProducts();
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
    return;
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    context.read<SystemProvider>().getSystemSettings(userID: CUR_USERID).then(
      (systemConfigData) async {
        if (!systemConfigData['error']) {
          //
          //Tag list from system API
          if (systemConfigData['tagList'] != null) {
            context.read<SearchProvider>().tagList =
                systemConfigData['tagList'];
          }
          //check whether app is under maintenance
          if (systemConfigData['isAppUnderMaintenance'] == '1') {
            HomePageDialog.showUnderMaintenanceDialog(context);
          }

          if (CUR_USERID != null) {
            context
                .read<UserProvider>()
                .setCartCount(systemConfigData['cartCount']);
            context
                .read<UserProvider>()
                .setBalance(systemConfigData['userBalance']);
            context
                .read<UserProvider>()
                .setPincode(systemConfigData['pinCode']);

            if (systemConfigData['referCode'] == null ||
                systemConfigData['referCode'] == '' ||
                systemConfigData['referCode']!.isEmpty) {
              generateReferral();
            }

            context.read<HomePageProvider>().getFav(context, setStateNow);
            context.read<CartProvider>().getUserCart(save: '0');
            _getOffFav();
            context.read<CartProvider>().getUserOfflineCart();
          }
          if (systemConfigData['isVersionSystemOn'] == '1') {
            String? androidVersion = systemConfigData['androidVersion'];
            String? iOSVersion = systemConfigData['iOSVersion'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(androidVersion!);
            final Version latestVersionIos = Version.parse(iOSVersion!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              HomePageDialog.showAppUpdateDialog(context);
            }
          }
          setState(() {});
        } else {
          setSnackbar(systemConfigData['message']!, context);
        }
      },
    ).onError(
      (error, stackTrace) {
        setSnackbar(error.toString(), context);
      },
    );
  }

/*  Future<void>? getDialogForClearCart() {
    HomePageDialog.clearYouCartDialog(context);
    return null;
  }*/

  Future<void> _getOffFav() async {
    if (CUR_USERID == null || CUR_USERID == '') {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        isNetworkAvail = await isNetworkAvailable();

        if (isNetworkAvail) {
          try {
            var parameter = {'product_ids': proIds.join(',')};

            Response response =
                await post(getProductApi, body: parameter, headers: headers)
                    .timeout(const Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            bool error = getdata['error'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<FavoriteProvider>().setLoading(false);
              });
            }
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then(
      (getdata) {
        bool error = getdata['error'];
        if (!error) {
          REFER_CODE = refer;

          Map parameter = {
            USER_ID: CUR_USERID,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomePageProvider>().secLoading = false;
      },
      onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomePageProvider>().secLoading = false;
      },
    );
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            HorizontalCategoryList.catLoading(context),
            sliderLoading(),
            Section.sectionLoadingShimmer(context),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.white,
      ),
    );
  }

  setStateNoInternate() async {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = true;
              },
            );
          }
          callApi();
        } else {
          await buttonController.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  Future<bool> onWillPopScope() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(getTranslated(context, 'Press back again to Exit')!, context);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(15),bottomLeft: Radius.circular(15))
      ),
      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 0),
      // EdgeInsets.fromLTRB(
      //   10,
      //   context.watch<HomePageProvider>().getBars ? 10 : 30,
      //   10,
      //   0,
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                width: MediaQuery.of(context).size.width/4,
                height: 40,
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                  ),
                  enabled: false,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.lightWhite,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    isDense: true,
                    hintText: getTranslated(context, 'searchHint'),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: textFontSize12,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.location_on,size: 20,)
                    ),
                    // suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                    //   selector: (_, themeProvider) =>
                    //       themeProvider.getThemeMode(),
                    //   builder: (context, data, child) {
                    //     return Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: (data == ThemeMode.system &&
                    //           MediaQuery.of(context).platformBrightness ==
                    //               Brightness.light) ||
                    //           data == ThemeMode.light
                    //           ? SvgPicture.asset(
                    //         DesignConfiguration.setSvgPath('voice_search'),
                    //         height: 15,
                    //         width: 15,
                    //       )
                    //           : SvgPicture.asset(
                    //         DesignConfiguration.setSvgPath(
                    //             'voice_search_white'),
                    //         height: 15,
                    //         width: 15,
                    //       ),
                    //     );
                    //   },
                    // ),
                    fillColor: Theme.of(context).colorScheme.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            onTap: () async {
              // Routes.navigateToSearchScreen(context);
            },
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                width: MediaQuery.of(context).size.width/1.6,

                height: 40,
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                  ),
                  enabled: false,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.lightWhite,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    isDense: true,
                    hintText: getTranslated(context, 'searchHint'),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize12,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('homepage_search'),
                        height: 15,
                        width: 15,
                      ),
                    ),
                    suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                      selector: (_, themeProvider) =>
                          themeProvider.getThemeMode(),
                      builder: (context, data, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: (data == ThemeMode.system &&
                                      MediaQuery.of(context).platformBrightness ==
                                          Brightness.light) ||
                                  data == ThemeMode.light
                              ? SvgPicture.asset(
                                  DesignConfiguration.setSvgPath('voice_search'),
                                  height: 15,
                                  width: 15,
                                )
                              : SvgPicture.asset(
                                  DesignConfiguration.setSvgPath(
                                      'voice_search_white'),
                                  height: 15,
                                  width: 15,
                                ),
                        );
                      },
                    ),
                    fillColor: Theme.of(context).colorScheme.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            onTap: () async {
              Routes.navigateToSearchScreen(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 75;

  @override
  double get minExtent => 75;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: colors.primary,
      activeTrackColor: Colors.white,

      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}
