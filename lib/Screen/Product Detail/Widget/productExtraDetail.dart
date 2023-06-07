import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../Model/Section_Model.dart';

extraDesc(Product model) {
  print('model extraDesc****${model.extraDesc}');
  return model.extraDesc != '' && model.extraDesc != null
      ? Card(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: HtmlWidget(
                model.extraDesc!,
              )),
        )
      : Container();
}
