import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract class ColorsManager {
  Color get primary;
  Color get secondary;
  Color get accent;
  Color get background;
  Color get surface;
  Color get mainText;
  Color get bodyText;
  Color get subText;
  Color get border;
  Color get error;
  Color get success;
  Color get warning;
  Color get info;
  Color get starYellow;
  Color get tagConfirmedBg;
  Color get tagConfirmedText;
  Color get tagInProgressBg;
  Color get tagInProgressText;
}

class LightColors extends ColorsManager {
  @override
  Color get primary => AppPalette.primaryGreen;

  @override
  Color get secondary => AppPalette.secondaryOrange;

  @override
  Color get accent => AppPalette.accentGreen;

  @override
  Color get background => AppPalette.bgLight;

  @override
  Color get surface => AppPalette.surfaceLight;

  @override
  Color get mainText => AppPalette.textMainLight;

  @override
  Color get bodyText => AppPalette.textBodyLight;

  @override
  Color get subText => AppPalette.textSubLight;

  @override
  Color get border => AppPalette.borderLight;

  @override
  Color get error => AppPalette.error;

  @override
  Color get success => AppPalette.success;

  @override
  Color get warning => AppPalette.warning;

  @override
  Color get info => AppPalette.info;

  @override
  Color get starYellow => AppPalette.starYellow;

  @override
  Color get tagConfirmedBg => AppPalette.tagConfirmedBgLight;

  @override
  Color get tagConfirmedText => AppPalette.tagConfirmedTextLight;

  @override
  Color get tagInProgressBg => AppPalette.tagInProgressBgLight;

  @override
  Color get tagInProgressText => AppPalette.tagInProgressTextLight;
}

class DarkColors extends ColorsManager {
  @override
  Color get primary => AppPalette.primaryGreenDark;

  @override
  Color get secondary => AppPalette.secondaryOrange;

  @override
  Color get accent => AppPalette.accentGreen;

  @override
  Color get background => AppPalette.bgDark;

  @override
  Color get surface => AppPalette.surfaceDark;

  @override
  Color get mainText => AppPalette.textMainDark;

  @override
  Color get bodyText => AppPalette.textBodyDark;

  @override
  Color get subText => AppPalette.textSubDark;

  @override
  Color get border => AppPalette.borderDark;

  @override
  Color get error => AppPalette.error;

  @override
  Color get success => AppPalette.success;

  @override
  Color get warning => AppPalette.warning;

  @override
  Color get info => AppPalette.info;

  @override
  Color get starYellow => AppPalette.starYellow;

  @override
  Color get tagConfirmedBg => AppPalette.tagConfirmedBgDark;

  @override
  Color get tagConfirmedText => AppPalette.tagConfirmedTextDark;

  @override
  Color get tagInProgressBg => AppPalette.tagInProgressBgDark;

  @override
  Color get tagInProgressText => AppPalette.tagInProgressTextDark;
}
