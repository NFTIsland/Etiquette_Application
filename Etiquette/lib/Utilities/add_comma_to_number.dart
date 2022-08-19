RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
String Function(Match) mathFunc = (Match match) => '${match[1]},';

// 사용법
// text = "100234";
// text.replaceAllMapped(reg, mathFunc);