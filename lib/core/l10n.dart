/// Tiny localisation layer. Bulgarian is the main language, English is available in Settings.
class L10n {
  L10n._();

  static String lang = 'bg';

  static const Map<String, List<String>> _s = <String, List<String>>{
    'welcome1': <String>['ДОБРЕ ДОШЛИ В', 'WELCOME TO'],
    'welcomeSub': <String>['Впуснете се в безкрайно космическо приключение с вашата любима котка!', 'Dive into an endless space adventure with your favorite cat!'],
    'start': <String>['СТАРТ!', 'START!'],
    'level': <String>['НИВО', 'LEVEL'],
    'levelWord': <String>['Ниво', 'Level'],
    'playNow': <String>['ИГРАЙ СЕГА!', 'PLAY NOW!'],
    'navLevels': <String>['Нива', 'Levels'],
    'navShop': <String>['Магазин', 'Shop'],
    'navCollection': <String>['Колекция', 'Collection'],
    'navSettings': <String>['Настройки', 'Settings'],
    'levelsTitle': <String>['НИВА', 'LEVELS'],
    'unlocked': <String>['ОТКЛЮЧЕНИ', 'UNLOCKED'],
    'completed': <String>['Завършено', 'Completed'],
    'available': <String>['Налично', 'Available'],
    'lockedLevel': <String>['Заключено', 'Locked'],
    'finishPrev': <String>['Завършете предишното ниво, за да отключите това.', 'Complete the previous level to unlock this one.'],
    'allLevels': <String>['Всички нива', 'All levels'],
    'mySkins': <String>['МОИТЕ СКИНОВЕ', 'MY SKINS'],
    'shopTitle': <String>['МАГАЗИН', 'SKIN SHOP'],
    'owned': <String>['Притежавани', 'Owned'],
    'select': <String>['ИЗБЕРИ', 'SELECT'],
    'equipped': <String>['ИЗБРАН', 'EQUIPPED'],
    'buy': <String>['КУПИ', 'BUY'],
    'starter': <String>['Начален скин', 'Starter skin'],
    'price': <String>['Цена', 'Price'],
    'notEnough': <String>['Нямате достатъчно монети!', 'Not enough coins!'],
    'bought': <String>['Скинът е купен!', 'Skin purchased!'],
    'filterAll': <String>['Всички', 'All'],
    'rarity': <String>['Рядкост', 'Rarity'],
    'r_common': <String>['Обикновен', 'Common'],
    'r_rare': <String>['Рядък', 'Rare'],
    'r_epic': <String>['Епически', 'Epic'],
    'r_mythic': <String>['Митически', 'Mythic'],
    'r_legendary': <String>['Легендарен', 'Legendary'],
    'r_chromatic': <String>['Хроматичен', 'Chromatic'],
    'r_ultra': <String>['Ултра', 'Ultra'],
    'settingsTitle': <String>['НАСТРОЙКИ', 'SETTINGS'],
    'music': <String>['Музика', 'Music'],
    'sound': <String>['Звукови ефекти', 'Sound effects'],
    'musicVol': <String>['Сила на музиката', 'Music volume'],
    'sfxVol': <String>['Сила на ефектите', 'Effects volume'],
    'language': <String>['Език', 'Language'],
    'reset': <String>['Нулиране на прогреса', 'Reset progress'],
    'resetTitle': <String>['Сигурни ли сте?', 'Are you sure?'],
    'resetBody': <String>['Всички монети, нива и скинове ще бъдат изтрити.', 'All coins, levels and skins will be erased.'],
    'cancel': <String>['Отказ', 'Cancel'],
    'confirmReset': <String>['Да, нулирай', 'Yes, reset'],
    'resetDone': <String>['Прогресът е нулиран.', 'Progress has been reset.'],
    'paused': <String>['ПАУЗА', 'PAUSED'],
    'resume': <String>['Продължи', 'Resume'],
    'restart': <String>['Рестарт', 'Restart'],
    'home': <String>['Начало', 'Home'],
    'gameOver': <String>['КРАЙ НА ИГРАТА', 'GAME OVER'],
    'tryAgain': <String>['Опитай пак', 'Try again'],
    'levelComplete': <String>['НИВОТО Е ЗАВЪРШЕНО!', 'LEVEL COMPLETE!'],
    'reward': <String>['Награда', 'Reward'],
    'rewardClaimed': <String>['Наградата за това ниво вече е получена.', 'The reward for this level was already claimed.'],
    'score': <String>['Резултат', 'Score'],
    'collected': <String>['Монети в нивото', 'Coins in level'],
    'next': <String>['Следващо ниво', 'Next level'],
    'dragHint': <String>['Плъзгайте пръста нагоре и надолу', 'Drag your finger up and down'],
    'balance': <String>['Баланс', 'Balance'],
    'coinsWord': <String>['монети', 'coins'],
    'skin': <String>['Скин', 'Skin'],
    'tapToSelect': <String>['Докоснете скин за преглед', 'Tap a skin to preview'],
    'langName': <String>['Български', 'English'],
    'version': <String>['NyanCat6767 • версия 1.0', 'NyanCat6767 • version 1.0'],
    'progress': <String>['Прогрес', 'Progress'],
    'lockedSkin': <String>['Заключен', 'Locked'],
    'goShop': <String>['Купете го в магазина', 'Buy it in the shop'],
  };

  static String t(String key) {
    final List<String>? v = _s[key];
    if (v == null) return key;
    return lang == 'en' ? v[1] : v[0];
  }
}

String tr(String key) => L10n.t(key);
