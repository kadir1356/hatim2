import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';

/// Service for handling donations/sadaqah via Google Play In-App Purchase
/// 
/// This service provides a spiritually appropriate way for users to support
/// the Pocket Khatm project through sadaqah (charitable giving).
class DonationService {
  static final DonationService _instance = DonationService._internal();
  factory DonationService() => _instance;
  DonationService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  
  // Product IDs - These will be configured in Google Play Console
  static const String smallSadaqah = 'sadaqah_small';
  static const String mediumSadaqah = 'sadaqah_medium';
  static const String largeSadaqah = 'sadaqah_large';
  
  static const Set<String> _productIds = {
    smallSadaqah,
    mediumSadaqah,
    largeSadaqah,
  };

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  /// Initialize the donation service
  /// Returns true if In-App Purchase is available on this device
  Future<bool> initialize() async {
    // In-App Purchase is only available on mobile (not web)
    if (kIsWeb) {
      print('[DonationService] In-App Purchase not available on web');
      return false;
    }

    // Check if platform supports In-App Purchase
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('[DonationService] In-App Purchase only available on Android/iOS');
      return false;
    }

    try {
      // Check if IAP is available
      _isAvailable = await _iap.isAvailable();
      
      if (!_isAvailable) {
        print('[DonationService] In-App Purchase not available on this device');
        return false;
      }

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => print('[DonationService] Purchase stream error: $error'),
      );

      // Load products
      await _loadProducts();

      print('[DonationService] Initialized successfully with ${_products.length} products');
      return true;
    } catch (e) {
      print('[DonationService] Initialization error: $e');
      return false;
    }
  }

  /// Load available donation products from the store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      
      if (response.error != null) {
        print('[DonationService] Error loading products: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('[DonationService] Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      
      // Sort by price (ascending)
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      
      print('[DonationService] Loaded ${_products.length} products');
      for (var product in _products) {
        print('  - ${product.id}: ${product.price}');
      }
    } catch (e) {
      print('[DonationService] Error loading products: $e');
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      print('[DonationService] Purchase update: ${purchase.productID} - ${purchase.status}');
      
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify and complete the purchase
        _verifyAndCompletePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        print('[DonationService] Purchase error: ${purchase.error}');
      }

      // Always complete pending purchases
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify and complete a purchase
  Future<void> _verifyAndCompletePurchase(PurchaseDetails purchase) async {
    try {
      // In a production app, you would verify the purchase with your backend here
      // For now, we just acknowledge it
      
      print('[DonationService] ✅ Sadaqah received: ${purchase.productID}');
      print('[DonationService] Thank you for supporting Pocket Khatm!');
      
      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } catch (e) {
      print('[DonationService] Error completing purchase: $e');
    }
  }

  /// Initiate a donation purchase
  /// 
  /// [productId] should be one of: smallSadaqah, mediumSadaqah, largeSadaqah
  Future<bool> makeDonation(String productId) async {
    if (!_isAvailable) {
      print('[DonationService] In-App Purchase not available');
      return false;
    }

    try {
      // Find the product
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      // Initiate the purchase
      print('[DonationService] Initiating purchase: ${product.id}');
      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      print('[DonationService] Error making donation: $e');
      return false;
    }
  }

  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _subscription?.cancel();
  }
}
