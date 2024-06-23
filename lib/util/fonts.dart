import 'dart:ui';

import 'package:flame/cache.dart';

import '../core/common.dart';
import 'bitmap_font.dart';

const textColor = Color(0xFFffcc80);
const successColor = Color(0xFF20ff10);
const errorColor = Color(0xFFff2010);

late BitmapFont fancyFont;
late BitmapFont menuFont;
late BitmapFont miniFont;
late BitmapFont smallFont;
late BitmapFont textFont;

loadFonts(AssetsCache assets) async {
  fancyFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/font_fancy.png',
    columns: 16,
    rows: 8,
  );
  menuFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/font_menu.png',
    columns: 16,
    rows: 8,
  );
  miniFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/font_mini.png',
    columns: 16,
    rows: 8,
  );
  smallFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/font_small.png',
    columns: 16,
    rows: 8,
  );
  textFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/font_text.png',
    columns: 16,
    rows: 8,
  );
}
