import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Helper/Constant.dart';
import '../../Helper/String.dart';

import '../../widgets/ButtonDesing.dart';
import '../../widgets/networkAvailablity.dart';
import '../Language/languageSettings.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class BusinessDetails extends StatefulWidget {
  // String? title;
   BusinessDetails({Key? key,}) : super(key: key);

  @override
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  String? dropdownValue;

  var item = [
    'Manufacturer',
    'Manufacturer'
  ];

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
          (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
                  () {},
            );
          }
        }
      },
    );
  }

  businessTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 20.0,
      ),
      child: Center(
        child: Text(
          getTranslated(context, 'BUSINESS_TXT')!,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontSize: textFontSize30,
            letterSpacing: 0.8,
            fontFamily: 'ubuntu',
          ),
        ),
      ),
    );
  }


  signInSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'INFO_FOR_LOGIN')!,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          // color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
            fontWeight: FontWeight.w500,
            fontFamily: 'ubuntu',
            fontSize: textFontSize20
        ),
      ),
    );
  }
  nextButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 33.0,bottom: 30
      ),
      child:Center(
        child: InkWell(
          onTap: (){
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

          },
          child: Container(
            width: 250,
            // width: btnAnim!.value,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: const BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.all(
                Radius.circular(
                  circularBorderRadius10,
                ),
              ),
            ),
            child:Text(
              getTranslated(context, 'Next_')!,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: colors.whiteTemp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ubuntu',
                  fontSize: textFontSize20
              ),
            ),

          ),
        ),
      )

    );
  }

  logo(){
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Image.asset('assets/images/loginbg.png',fit: BoxFit.fill,),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical:200),
              child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      businessTxt(),
                      ownerName(),
                      email(),
                      address(),
                      gstNumber(),
                      udhyogNumber(),
                      businessCat(),
                      partnername(),
                      state(),
                      city(),
                      ara(),
                      pinCode(),
                      webText(),
                      website(),
                      facebookText(),
                      facebook(),
                      instagramText(),
                      instagram(),
                      linkedinText(),
                      linkdln(),
                      nextButton()
                      // setMobile(),
                      // verifyBtn()
                    ],
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  setMobile(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 30.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        maxLength: 10,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          focusColor: Colors.white,
          counterText: '',
          //add prefix icon
          prefixIcon: Icon(
            Icons.call,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Mobile Number",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  ownerName(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 30.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },

        decoration: InputDecoration(
          focusColor: Colors.white,
          counterText: "",
          //add prefix icon
          prefixIcon: Icon(
            Icons.person,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Company/Business/Shop Name",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  email(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.email,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Email",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  address(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.location_on,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Address",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  ara(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.location_on,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Address",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  webText(){
    return const Padding(
        padding: const EdgeInsetsDirectional.only(
            top: 20.0,start: 35,end: 0
        ),
      child: (
      Text('Website Pag Link   (Optional)')
      ),
    );
  }
  facebookText(){
    return const Padding(
        padding: const EdgeInsetsDirectional.only(
            top: 20.0,start: 35,end: 0
        ),
      child: (
      Text('Facebook Pag Link (Optional)')
      ),
    );
  }
  instagramText(){
    return const Padding(
        padding: const EdgeInsetsDirectional.only(
            top: 20.0,start: 35,end: 0
        ),
      child: (
      Text('Instagram Pag Link  (Optional)')
      ),
    );
  }
  linkedinText(){
    return const Padding(
        padding: const EdgeInsetsDirectional.only(
            top: 20.0,start: 35,end: 0
        ),
      child: (
      Text('Linkedin Pag Link (Optional)')
      ),
    );
  }
  pinCode(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Pin Code",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  website(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 0.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.wordpress,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Enter  Website Link  ",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  facebook(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 10.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: const InputDecoration(
          focusColor: Colors.white,
          //add prefix icon
          prefixIcon: Icon(
            Icons.facebook,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Paste here facebook page Link",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  instagram(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 10.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,
          //add prefix icon
          prefixIcon: Icon(
            Icons.send_to_mobile,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Paste here instgram page link",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  linkdln(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 10.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.link,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Paste here linkedin link",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  gstNumber(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.business,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "GST Number (optional)",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }

  udhyogNumber(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.email,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Udyog Number (optional)",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  partnername(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            fontSize: textFontSize13),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(
          focusColor: Colors.white,

          //add prefix icon
          prefixIcon: Icon(
            Icons.person,
            color: Colors.grey,
          ),
          fillColor: Colors.grey,
          hintText: "Partner Name",
          //make hint text
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),

        ),
      ),
    );
  }
  businessCat(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextField(

        // controller: _controller,
        decoration: InputDecoration(
          hintText: 'Business Category',
          prefixIcon: Icon(Icons.category),
          suffixIcon: PopupMenuButton<String>(

            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (String value) {
              // _controller.text = value;
            },
            itemBuilder: (BuildContext context) {
              return item
                  .map<PopupMenuItem<String>>((String value) {
                return new PopupMenuItem(
                    child: new Text(value), value: value);
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  state(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextField(
        // controller: _controller,

        decoration: InputDecoration(
          hintText: 'State',
          prefixIcon: Icon(Icons.stacked_bar_chart),
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (String value) {
              // _controller.text = value;
            },

            itemBuilder: (BuildContext context) {
              return item
                  .map<PopupMenuItem<String>>((String value) {
                return new PopupMenuItem(
                    child: new Text(value), value: value);
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  city(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0,start: 20,end: 20
      ),
      child: TextField(
        // controller: _controller,
        decoration: InputDecoration(
          hintText: 'City',
          prefixIcon: Icon(Icons.location_city),
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (String value) {
              // _controller.text = value;
            },
            itemBuilder: (BuildContext context) {
              return item
                  .map<PopupMenuItem<String>>((String value) {
                return new PopupMenuItem(
                    child: new Text(value), value: value);
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0,bottom: 20),
      child: Center(
        child: AppBtn(
          // title: widget.title == getTranslated(context, 'Next_')
          //     ? getTranslated(context, 'Next_')
          //     : getTranslated(context, 'Next_'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            // validateAndSubmit();
          },
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              logo(),
            ],
          ),
        ),
      )
          : NoInterNet(
        setStateNoInternate: setStateNoInternate,
        buttonSqueezeanimation: buttonSqueezeanimation,
        buttonController: buttonController,
      ),
    );
  }

}
