class BrandAssets {
  BrandAssets._();

  static const String _basePath = 'assets/images/brand logo/';

  static const Map<String, String> _brandLogoMap = {
    'acc': '${_basePath}acc-cement.avif',
    'asian_paints': '${_basePath}asian paints.jpg',
    'asian paints': '${_basePath}asian paints.jpg',
    'berger': '${_basePath}berger-paints-vector-logo.png',
    'berger paints': '${_basePath}berger-paints-vector-logo.png',
    'jaquar': '${_basePath}JAQUAR_spirintoise_logo.png',
    'astral': '${_basePath}Astral-Pipes-Logo-PNG-SVG-Vector.png',
    'astral pipes': '${_basePath}Astral-Pipes-Logo-PNG-SVG-Vector.png',
    'ramco': '${_basePath}ramco.jpg',
    'priya': '${_basePath}priya cement.jpg',
    'priya cement': '${_basePath}priya cement.jpg',
    'kcp':
        '${_basePath}the-kcp-ltd-jubilee-hills-hyderabad-cement-distributors-ymiqb1k3ad-250.avif',
    'kcp cement':
        '${_basePath}the-kcp-ltd-jubilee-hills-hyderabad-cement-distributors-ymiqb1k3ad-250.avif',
    'penna': '${_basePath}penna.jpg',
    'penna cement': '${_basePath}penna.jpg',
    'supreme': '${_basePath}supreme pipes.jpg',
    'supreme pipes': '${_basePath}supreme pipes.jpg',
    'ultratech': '${_basePath}Ultratech_Cement_Logo.svg.webp',
    'ambuja': '${_basePath}acc-cement.avif',
    'ambuja cements': '${_basePath}acc-cement.avif',
    'centurydoors': '${_basePath}CenturyDoors.jpg',
    'century doors': '${_basePath}CenturyDoors.jpg',
    'greenply': '${_basePath}Greenply_logo.svg.webp',
    'fenesta': '${_basePath}fenesta-logo-png_seeklogo-549369.png',
    'saint_gobain': '${_basePath}saint gobain.jpg',
    'saint-gobain': '${_basePath}saint gobain.jpg',
    'tata_tiscon': '${_basePath}tata tiscon.jpg',
    'tata tiscon': '${_basePath}tata tiscon.jpg',
    'tata_steel': '${_basePath}tata-steel-logo.png',
    'tata steel': '${_basePath}tata-steel-logo.png',
  };

  /// Returns the local offline asset path for a given brand ID or name, if available.
  static String? getOfflineLogo(String brandId, [String? brandName]) {
    final normalizedId = brandId.trim().toLowerCase().replaceAll('-', '_');
    if (_brandLogoMap.containsKey(normalizedId)) {
      return _brandLogoMap[normalizedId];
    }
    if (brandName != null && brandName.isNotEmpty) {
      final normalizedName = brandName.trim().toLowerCase();
      if (_brandLogoMap.containsKey(normalizedName)) {
        return _brandLogoMap[normalizedName];
      }
      for (final entry in _brandLogoMap.entries) {
        if (normalizedName.contains(entry.key) ||
            entry.key.contains(normalizedName)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  /// Resolves the best available logo URL, prioritizing local offline asset when offline or missing.
  static String resolveLogoUrl(String brandId, String? currentLogoUrl,
      [String? brandName]) {
    final offlineAsset = getOfflineLogo(brandId, brandName);
    if (currentLogoUrl == null || currentLogoUrl.isEmpty) {
      return offlineAsset ?? '';
    }
    // If the URL is already an asset, return it
    if (currentLogoUrl.startsWith('assets/')) {
      return currentLogoUrl;
    }
    // If we have an offline asset available, return the offline asset so it displays reliably without network latency
    if (offlineAsset != null) {
      return offlineAsset;
    }
    return currentLogoUrl;
  }
}
