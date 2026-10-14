String storeSlugFun(String value) {
  var text = value.trim().toLowerCase();

  const accents = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'õ': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  accents.forEach((from, to) {
    text = text.replaceAll(from, to);
  });

  text = text.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  text = text.replaceAll(RegExp(r'-+'), '-');
  text = text.replaceAll(RegExp(r'^-|-$'), '');

  if (text.isEmpty) {
    return 'loja';
  }

  return text;
}
