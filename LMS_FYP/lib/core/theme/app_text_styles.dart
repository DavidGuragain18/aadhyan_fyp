import 'package:flutter/material.dart';

import 'app_colors.dart';

final TextStyle btnTextStyle = TextStyle(
    color: neutralWhiteColor, fontSize: 18, fontWeight: FontWeight.bold);
final TextStyle textBtnStyle =
    TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold);

const TextStyle titleTextStyle =  TextStyle(
    // color: secondaryColor,

    overflow: TextOverflow.ellipsis,
    fontSize: 18,
    fontWeight: FontWeight.bold);

const TextStyle pageTitleTextStyle =  TextStyle(
    // color: secondaryColor,
    overflow: TextOverflow.ellipsis,
    fontSize: 16,
    fontWeight: FontWeight.w600);

final TextStyle pagesSubTextStyle = TextStyle(
  color: primaryColor,
  overflow: TextOverflow.ellipsis,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

final TextStyle regularTitleTextStyle = TextStyle(
  color: primaryColor,
  fontWeight: FontWeight.w500,
  overflow: TextOverflow.ellipsis,
);

const TextStyle regularTextStyle =  TextStyle(
  fontSize: 16,
  overflow: TextOverflow.ellipsis,
  fontWeight: FontWeight.w400,
);
final TextStyle regularSubTextStyle = TextStyle(
  color: primaryColor,
  fontSize: 14,
  overflow: TextOverflow.ellipsis,
  fontWeight: FontWeight.w400,
);

final TextStyle alertTextStyle = TextStyle(
  color: alertErrorColor,
  overflow: TextOverflow.ellipsis,
  fontSize: 14,
  fontWeight: FontWeight.w400,
);
final TextStyle alertTextStyle2 = TextStyle(
  color: alertErrorColor,
  overflow: TextOverflow.ellipsis,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);