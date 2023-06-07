import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Auth/SendOtp.dart';

class MyProfileDialog {
  static showLogoutDialog(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  circularBorderRadius5,
                ),
              ),
            ),
            content: Text(
              getTranslated(context, 'LOGOUTTXT')!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  getTranslated(context, 'NO')!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  getTranslated(context, 'YES')!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SettingProvider settingProvider =
                      Provider.of<SettingProvider>(context, listen: false);
                  if (context.read<UserProvider>().loginType != PHONE_TYPE) {
                    if (context.read<UserProvider>().loginType == GOOGLE_TYPE) {
                      googleSignIn.signOut();
                    } else {
                      firebaseAuth.signOut();
                    }
                  }
                  settingProvider.clearUserSession(context);

                  context.read<FavoriteProvider>().setFavlist([]);

                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) => const Dashboard(),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

  static showDeleteAccountDialog(BuildContext cxt) async {
    await DesignConfiguration.dialogAnimate(
      cxt,
      StatefulBuilder(
        builder: (BuildContext context, setState) {
          return DeleteAccountDialog(
            cxt: cxt,
          );
        },
      ),
    );
  }

  static showDeleteWarningAccountDialog(BuildContext parentcontext) async {
    await DesignConfiguration.dialogAnimate(
      parentcontext,
      StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(circularBorderRadius5),
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'DeleteAccount')!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  getTranslated(
                    context,
                    'DELETE_ACCOUNT_WARNING',
                  )!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(),
                )
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      getTranslated(context, 'NO')!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(
                      getTranslated(context, 'YES')!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      if (context.read<UserProvider>().loginType ==
                          PHONE_TYPE) {
                        Routes.pop(context);
                        MyProfileDialog.showDeleteAccountDialog(parentcontext);
                      } else {
                        User? currentUser = FirebaseAuth.instance.currentUser;
                        print('currentUser is:$currentUser');
                        if (currentUser != null) {
                          currentUser.delete().then((value) async {
                            Routes.pop(context);

                            context
                                .read<UserProvider>()
                                .deleteSocialUserAccount(userId: CUR_USERID!)
                                .then(
                              (value) {
                                if (!value!['error']) {
                                  SettingProvider settingProvider =
                                      Provider.of<SettingProvider>(context,
                                          listen: false);
                                  settingProvider.clearUserSession(context);

                                  context
                                      .read<FavoriteProvider>()
                                      .setFavlist([]);
                                  Future.delayed(Duration.zero, () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/login',
                                            (Route<dynamic> route) => false);
                                  });
                                } else {
                                  setSnackbar(value['message'], context);
                                }
                              },
                            );
                          });
                        } else {
                          Navigator.of(context, rootNavigator: true).pop(true);
                          setSnackbar(
                              getTranslated(context, 'RELOGIN_REQ')!, context);
                        }
                      }
                    },
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  BuildContext cxt;

  DeleteAccountDialog({
    Key? key,
    required this.cxt,
  }) : super(key: key);

  final passwordController = TextEditingController();
  String? verifyPassword;
  FocusNode? passFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(circularBorderRadius5),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated(context, 'Please Verify Password')!,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            height: 53,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightWhite,
              borderRadius: BorderRadius.circular(circularBorderRadius10),
            ),
            alignment: Alignment.center,
            child: Form(
              key: formKey,
              child: TextFormField(
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize13),
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passFocus);
                },
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: passwordController,
                focusNode: passFocus,
                textInputAction: TextInputAction.next,
                onChanged: (String? value) {
                  verifyPassword = value;
                },
                onSaved: (String? value) {
                  verifyPassword = value;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[ ]')),
                ],
                validator: (val) => StringValidation.validatePass(
                    val!,
                    getTranslated(context, 'PWD_REQUIRED'),
                    getTranslated(context, 'PASSWORD_VALIDATION')),
                decoration: InputDecoration(
                  errorMaxLines: 2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 5,
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 40, maxHeight: 20),
                  hintText: getTranslated(context, 'PASSHINT_LBL')!,
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      fontSize: textFontSize13),
                  fillColor: Theme.of(context).colorScheme.lightWhite,
                  border: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        Selector<UserProvider, String>(
          selector: (_, provider) => provider.mob,
          builder: (context, userMobile, child) {
            return TextButton(
              child: Text(
                getTranslated(context, 'DELETE_NOW')!,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onPressed: () async {
                final form = formKey.currentState!;
                form.save();
                if (form.validate()) {
                  Routes.pop(context);
                  cxt
                      .read<UserProvider>()
                      .deleteUserAccount(
                          userId: CUR_USERID!,
                          mobileNumber: userMobile,
                          password: verifyPassword!)
                      .then(
                    (value) {
                      if (!value!['error']) {
                        verifyPassword = '';
                        SettingProvider settingProvider =
                            Provider.of<SettingProvider>(cxt, listen: false);
                        settingProvider.clearUserSession(cxt);

                        cxt.read<FavoriteProvider>().setFavlist([]);
                        Navigator.pushReplacement(
                          cxt,
                          CupertinoPageRoute(
                            builder: (BuildContext cxt) => SendOtp(
                              title: getTranslated(cxt, 'SEND_OTP_TITLE'),
                            ),
                          ),
                        );
                      } else {
                        verifyPassword = '';
                        setSnackbar(value['message'], cxt);
                      }
                    },
                  );
                }
              },
            );
          },
        )
      ],
    );
  }
}
