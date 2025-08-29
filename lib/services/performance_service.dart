import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  // Memory cache for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache configuration
  static const Duration _memoryCacheExpiry = Duration(minutes: 30);
  static const int _maxMemoryCacheSize = 100;
  
  // Lazy loading configuration
  static const int _defaultPageSize = 20;
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  
  /// Get cached data from memory
  T? getFromCache<T>(String key) {
    if (_memoryCache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _memoryCacheExpiry) {
        return _memoryCache[key] as T?;
      } else {
        // Expired, remove from cache
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }
  
  /// Store data in memory cache
  void setCache(String key, dynamic data) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictOldestCache();
    }
    
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  /// Clear expired cache entries
  void _evictOldestCache() {
    if (_cacheTimestamps.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cacheTimestamps.entries) {
              if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }
    
    if (oldestKey != null) {
      _memoryCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }
  
  /// Clear all caches
  void clearAllCaches() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }
  
  /// Get cached network image with placeholder and error handling
  Widget getCachedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      cacheKey: imageUrl,
      maxWidthDiskCache: width.toInt(),
      maxHeightDiskCache: height.toInt(),
    );
  }
  
  /// Lazy load data with pagination
  Future<List<T>> lazyLoadData<T>({
    required Future<List<T>> Function(int offset, int limit) dataLoader,
    int pageSize = _defaultPageSize,
    int initialOffset = 0,
  }) async {
    try {
      final data = await dataLoader(initialOffset, pageSize);
      return data;
    } catch (e) {
      print('Error in lazy loading: $e');
      return [];
    }
  }
  
  /// Debounced search for better performance
  Timer? _debounceTimer;
  void debouncedSearch(
    String query,
    Function(String) onSearch,
    {Duration delay = _debounceDelay}
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      onSearch(query);
    });
  }
  
  /// Optimize list performance
  ListView optimizedListView({
    required List<Widget> children,
    ScrollController? controller,
    bool addAutomaticKeepAlives = false,
    bool addRepaintBoundaries = true,
  }) {
    return ListView.builder(
      itemCount: children.length,
      controller: controller,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
  
  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    clearAllCaches();
  }
}
