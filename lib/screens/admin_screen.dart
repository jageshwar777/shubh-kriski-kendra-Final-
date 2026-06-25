import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/web_storage_helper.dart';
import '../utils/image_helper.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;

  String _shopName = 'Shubh Krishi Kendra';
  String _shopLogoBase64 = '';
  String _whatsappNumber = '919876543210';
  String _phoneNumber = '+919876543210';
  String _upiId = 'shopowner@okhdfcbank';
  String _email = 'contact@villageshop.com';
  String _shopAddress = 'गाँव की दुकान, मुख्य बाजार';
  String _shopTiming = 'सुबह 8:00 - शाम 8:00';
  bool _isCodEnabled = true;

  String _newsText =
      '🎉 विशेष ऑफर: खाद पर 10% छूट! 🎉 | नए बीज आए | फ्री डिलीवरी';
  String _bannerTitle1 = '🌾 नए बीज आए';
  String _bannerTitle2 = '🧪 खाद पर छूट';
  String _bannerTitle3 = '🚜 कीटनाशक ऑफर';

  String _aboutUsText = '';
  String _privacyPolicyText = '';
  String _termsText = '';

  final Map<String, String> _productImages = {};

  List<String> _availableUnits = [
    'KG',
    'ग्राम',
    'ML',
    'लीटर',
    'पीस',
    'बोरी',
    '250ml',
    '500ml',
    '1KG',
    '2KG',
    '5KG',
    '10KG',
    '20KG',
    '50KG'
  ];

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnits = prefs.getStringList('available_units');
    if (savedUnits != null && savedUnits.isNotEmpty) {
      setState(() {
        _availableUnits = savedUnits;
      });
    }
  }

  Future<void> _addNewUnit() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नई यूनिट जोड़ें'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'यूनिट नाम',
            hintText: 'जैसे: 250ml, 500gm, 1KG, 2KG, 5L',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () async {
              final newUnit = controller.text.trim();
              if (newUnit.isNotEmpty && !_availableUnits.contains(newUnit)) {
                setState(() {
                  _availableUnits.add(newUnit);
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setStringList('available_units', _availableUnits);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text('✅ "$newUnit" यूनिट जुड़ गई!'),
                      backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('जोड़ें'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _shopName = prefs.getString('shop_name') ?? 'Shubh Krishi Kendra';
        _shopLogoBase64 = prefs.getString('shop_logo') ?? '';
        _whatsappNumber = prefs.getString('whatsapp_number') ?? '919876543210';
        _phoneNumber = prefs.getString('phone_number') ?? '+919876543210';
        _upiId = prefs.getString('upi_id') ?? 'shopowner@okhdfcbank';
        _email = prefs.getString('email') ?? 'contact@villageshop.com';
        _shopAddress =
            prefs.getString('shop_address') ?? 'गाँव की दुकान, मुख्य बाजार';
        _shopTiming = prefs.getString('shop_timing') ?? 'सुबह 8:00 - शाम 8:00';
        _isCodEnabled = prefs.getBool('cod_enabled') ?? true;
        _newsText = prefs.getString('news_text') ??
            '🎉 विशेष ऑफर: खाद पर 10% छूट! 🎉 | नए बीज आए | फ्री डिलीवरी';
        _bannerTitle1 = prefs.getString('banner_title_1') ?? '🌾 नए बीज आए';
        _bannerTitle2 = prefs.getString('banner_title_2') ?? '🧪 खाद पर छूट';
        _bannerTitle3 = prefs.getString('banner_title_3') ?? '🚜 कीटनाशक ऑफर';
        _aboutUsText = prefs.getString('about_us_text') ?? _getDefaultAboutUs();
        _privacyPolicyText =
            prefs.getString('privacy_policy_text') ?? _getDefaultPrivacy();
        _termsText = prefs.getString('terms_text') ?? _getDefaultTerms();

        String? imagesJson = prefs.getString('product_images');
        if (imagesJson != null && imagesJson.isNotEmpty) {
          try {
            Map<String, dynamic> decoded = jsonDecode(imagesJson);
            _productImages.clear();
            decoded.forEach((key, value) {
              _productImages[key] = value.toString();
            });
          } catch (e) {
            // Silent fail
          }
        }
      });
    }
  }

  String _getDefaultAboutUs() {
    return "Shubh Krishi Kendra एक डिजिटल पहल है जो गाँव के लोगों को आसानी से कृषि उत्पाद, बीज, खाद और अन्य आवश्यक सामान खरीदने की सुविधा देती है.\n\nहमारा उद्देश्य: गाँव के हर किसान और ग्राहक को सस्ती और सुलभ कीमत पर असली सामान उपलब्ध कराना.\n\n✅ 100% असली उत्पाद\n✅ फ्री डिलीवरी\n✅ UPI और कैश पेमेंट\n✅ 24x7 ग्राहक सहायता";
  }

  String _getDefaultPrivacy() {
    return "हम आपकी निजी जानकारी को सुरक्षित रखते हैं.\n\nहम क्या जानकारी इकट्ठा करते हैं:\n• नाम और पता\n• मोबाइल नंबर\n• ऑर्डर हिस्ट्री\n\nहम आपकी जानकारी का उपयोग कैसे करते हैं:\n• ऑर्डर प्रोसेस करने के लिए\n• डिलीवरी के लिए\n• आपसे संपर्क करने के लिए";
  }

  String _getDefaultTerms() {
    return "📜 नियम और शर्तें\n\n1. सभी उत्पाद 100% असली हैं\n2. डिलीवरी फ्री है\n3. पेमेंट UPI या कैश से कर सकते हैं\n4. सामान मिलने के बाद ही पैसे दें\n5. 7 दिन में बदलने की सुविधा";
  }

  Future<void> _saveAllSettings() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopName);
    await prefs.setString('shop_logo', _shopLogoBase64);
    await prefs.setString('whatsapp_number', _whatsappNumber);
    await prefs.setString('phone_number', _phoneNumber);
    await prefs.setString('upi_id', _upiId);
    await prefs.setString('email', _email);
    await prefs.setString('shop_address', _shopAddress);
    await prefs.setString('shop_timing', _shopTiming);
    await prefs.setBool('cod_enabled', _isCodEnabled);
    await prefs.setString('news_text', _newsText);
    await prefs.setString('banner_title_1', _bannerTitle1);
    await prefs.setString('banner_title_2', _bannerTitle2);
    await prefs.setString('banner_title_3', _bannerTitle3);
    await prefs.setString('about_us_text', _aboutUsText);
    await prefs.setString('privacy_policy_text', _privacyPolicyText);
    await prefs.setString('terms_text', _termsText);
    await prefs.setString('product_images', jsonEncode(_productImages));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ सभी सेटिंग्स सेव हो गईं!'),
            backgroundColor: Colors.green),
      );
    }
  }

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave,
      {int maxLines = 1}) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
              _saveAllSettings();
              if (mounted) setState(() {});
            },
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadShopLogo() async {
    String? base64Image = await ImageHelper.pickAndCompressImage();
    if (base64Image != null) {
      setState(() {
        _shopLogoBase64 = base64Image;
      });
      await _saveAllSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ दुकान का लोगो अपडेट हो गया!'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _changeLoginCredentials() async {
    final currentEmailController = TextEditingController(text: _email);
    final currentPasswordController = TextEditingController();
    final newEmailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('लॉगिन क्रेडेंशियल्स बदलें'),
        content: SizedBox(
          width: 350,
          height: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚠️ पहले अपना मौजूदा पासवर्ड डालें',
                    style: TextStyle(fontSize: 12, color: Colors.orange)),
                const SizedBox(height: 12),
                TextField(
                  controller: currentEmailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'मौजूदा ईमेल (बदला नहीं जा सकता)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'मौजूदा पासवर्ड *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const Divider(height: 24),
                const Text('नई जानकारी भरें',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: newEmailController,
                  decoration: const InputDecoration(
                    labelText: 'नया ईमेल (वैकल्पिक)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'अगर नहीं बदलना तो खाली छोड़ें',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'नया पासवर्ड (वैकल्पिक)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_open),
                    hintText: 'अगर नहीं बदलना तो खाली छोड़ें',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'नया पासवर्ड दोबारा',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                final savedPassword =
                    prefs.getString('admin_password') ?? 'admin123';

                if (currentPasswordController.text != savedPassword) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('❌ मौजूदा पासवर्ड गलत है'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                if (newPasswordController.text.isNotEmpty) {
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('❌ नया पासवर्ड मैच नहीं कर रहा'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (newPasswordController.text.length < 4) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content:
                              Text('❌ पासवर्ड कम से कम 4 अंकों का होना चाहिए'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  await prefs.setString(
                      'admin_password', newPasswordController.text);
                }

                if (newEmailController.text.isNotEmpty) {
                  await prefs.setString('admin_email', newEmailController.text);
                  if (mounted) {
                    setState(() {
                      _email = newEmailController.text;
                    });
                  }
                }

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ लॉगिन क्रेडेंशियल्स बदल गए!'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('❌ गलती: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProduct(Product product) async {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toString());
    final stockCtrl = TextEditingController(text: product.stock.toString());
    String selectedCategory = product.category;
    String selectedUnit = product.unit;
    String? currentImageBase64 = _productImages[product.id];
    bool hasImage = currentImageBase64 != null;
    String? newImageBase64;

    final categories = ['बीज', 'खाद', 'कीटनाशक', 'औजार', 'अन्य'];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text('✏️ ${product.name} एडिट करें'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: hasImage && currentImageBase64 != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(currentImageBase64!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📷 फोटो बदलें',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  String? img =
                                      await ImageHelper.pickAndCompressImage();
                                  if (img != null) {
                                    setState(() {
                                      newImageBase64 = img;
                                      hasImage = true;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('नई फोटो डालें'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                              ),
                              if (hasImage)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      hasImage = false;
                                      currentImageBase64 = null;
                                      newImageBase64 = null;
                                    });
                                  },
                                  child: const Text('फोटो हटाएं',
                                      style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'प्रोडक्ट नाम *',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                          labelText: 'कैटेगरी *', border: OutlineInputBorder()),
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'कीमत (₹) *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'यूनिट',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            items: _availableUnits.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedUnit = v!),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: _addNewUnit,
                          tooltip: 'नई यूनिट जोड़ें',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(
                          labelText: 'स्टॉक *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'यूनिट के लिए आप 250ml, 500gm, 1KG, 2KG, 5L, 10KG, 20KG, 50KG, बोरी, पीस आदि डाल सकते हैं।',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('रद्द करें')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (nameCtrl.text.isEmpty ||
                        priceCtrl.text.isEmpty ||
                        stockCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content: Text('कृपया सभी फील्ड भरें'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final updatedProduct = Product(
                      id: product.id,
                      name: nameCtrl.text,
                      category: selectedCategory,
                      price: double.parse(priceCtrl.text),
                      unit: selectedUnit,
                      stock: int.parse(stockCtrl.text),
                      imageUrl: '',
                    );

                    if (newImageBase64 != null) {
                      _productImages[product.id] = newImageBase64!;
                    } else if (currentImageBase64 == null &&
                        newImageBase64 == null) {
                      _productImages.remove(product.id);
                    }

                    final products = WebStorageHelper.getProducts();
                    final index =
                        products.indexWhere((p) => p.id == product.id);
                    if (index != -1) {
                      products[index] = updatedProduct;
                      await WebStorageHelper.saveProducts();
                      await _saveAllSettings();
                      await WebStorageHelper.reloadProducts();
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ प्रोडक्ट अपडेट हो गया!'),
                              backgroundColor: Colors.green),
                        );
                        setState(() {});
                      }
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                            content: Text('❌ गलती: ${e.toString()}'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('सेव करें'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('प्रोडक्ट डिलीट करें?'),
        content: Text('क्या आप "${product.name}" को डिलीट करना चाहते हैं?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('नहीं')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('हाँ, डिलीट करें'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final products = WebStorageHelper.getProducts();
        products.removeWhere((p) => p.id == product.id);
        _productImages.remove(product.id);
        await WebStorageHelper.saveProducts();
        await _saveAllSettings();
        await WebStorageHelper.reloadProducts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ प्रोडक्ट डिलीट हो गया!'),
                backgroundColor: Colors.green),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ गलती: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _addSingleProduct() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    String selectedCategory = 'बीज';
    String selectedUnit = 'KG';
    String? imageBase64String;
    bool hasImage = false;

    final categories = ['बीज', 'खाद', 'कीटनाशक', 'औजार', 'अन्य'];

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('नया प्रोडक्ट जोड़ें'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? img = await ImageHelper.pickAndCompressImage();
                        if (img != null) {
                          setState(() {
                            imageBase64String = img;
                            hasImage = true;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: hasImage && imageBase64String != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                    base64Decode(imageBase64String!),
                                    fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 40, color: Colors.grey[600]),
                                  const SizedBox(height: 4),
                                  Text('फोटो डालें',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'प्रोडक्ट नाम *',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                          labelText: 'कैटेगरी *', border: OutlineInputBorder()),
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'कीमत (₹) *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'यूनिट',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            items: _availableUnits.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedUnit = v!),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: _addNewUnit,
                          tooltip: 'नई यूनिट जोड़ें',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(
                          labelText: 'स्टॉक *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'यूनिट के लिए आप 250ml, 500gm, 1KG, 2KG, 5L, 10KG, 20KG, 50KG, बोरी, पीस आदि डाल सकते हैं।',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('रद्द करें')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (nameCtrl.text.isEmpty ||
                        priceCtrl.text.isEmpty ||
                        stockCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content: Text('कृपया सभी फील्ड भरें'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final newId =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    if (imageBase64String != null) {
                      _productImages[newId] = imageBase64String!;
                    }

                    final newProduct = Product(
                      id: newId,
                      name: nameCtrl.text,
                      category: selectedCategory,
                      price: double.parse(priceCtrl.text),
                      unit: selectedUnit,
                      stock: int.parse(stockCtrl.text),
                      imageUrl: '',
                    );

                    final products = WebStorageHelper.getProducts();
                    products.add(newProduct);
                    await WebStorageHelper.saveProducts();
                    await _saveAllSettings();
                    await WebStorageHelper.reloadProducts();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ प्रोडक्ट जुड़ गया!'),
                              backgroundColor: Colors.green),
                        );
                        setState(() {});
                      }
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                            content: Text('❌ गलती: ${e.toString()}'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('प्रोडक्ट जोड़ें'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        if (mounted) setState(() => _isLoading = true);
        final jsonFileString =
            await File(result.files.single.path!).readAsString();
        await WebStorageHelper.importProductsFromJson(jsonFileString);
        await WebStorageHelper.reloadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('✅ इम्पोर्ट पूरा!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ गलती: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportJson() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final String jsonExportData =
          await WebStorageHelper.exportProductsToJson();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ एक्सपोर्ट तैयार!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ गलती: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('रीसेट करें?'),
        content: const Text('सारा डेटा हट जाएगा!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('नहीं')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('हाँ')),
        ],
      ),
    );
    if (confirm == true) {
      if (mounted) setState(() => _isLoading = true);
      await WebStorageHelper.loadProducts();
      _productImages.clear();
      await _saveAllSettings();
      await WebStorageHelper.reloadProducts();
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ रीसेट पूरा!')));
      }
    }
  }

  Widget _buildOrdersSummaryCard() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = orderProvider.getOrders();

    if (orders.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('कोई ऑर्डर नहीं')),
        ),
      );
    }

    int totalOrders = orders.length;
    double totalAmount =
        orders.fold(0, (sum, order) => sum + order.totalAmount);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 ऑर्डर समरी',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('कुल ऑर्डर:'),
                Text('$totalOrders',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('कुल रकम:'),
                Text('₹${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('🔄 ऑर्डर देखने के लिए "ऑर्डर" टैब पर जाएं'),
          ],
        ),
      ),
    );
  }

  // ✅ यही वह function है - _buildProductListCard
  Widget _buildProductListCard() {
    final products = WebStorageHelper.getProducts();

    if (products.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('कोई प्रोडक्ट नहीं। पहले प्रोडक्ट जोड़ें।'),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '📋 सभी प्रोडक्ट (${products.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(),
          ...products.map((product) {
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: _productImages[product.id] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_productImages[product.id]!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.shopping_bag,
                                    color: Colors.green[700]);
                              },
                            ),
                          )
                        : Icon(Icons.shopping_bag, color: Colors.green[700]),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '₹${product.price} / ${product.unit} | स्टॉक: ${product.stock}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 20),
                        onPressed: () => _editProduct(product),
                        tooltip: 'एडिट करें',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _deleteProduct(product),
                        tooltip: 'डिलीट करें',
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('दुकानदार पैनल'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAllSettings),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSectionHeader('🏪 दुकान की जानकारी'),
                  _buildShopNameAndLogoCard(),
                  _buildEditableCard('WhatsApp नंबर', _whatsappNumber,
                      (v) => _whatsappNumber = v),
                  _buildEditableCard(
                      'फोन नंबर', _phoneNumber, (v) => _phoneNumber = v),
                  _buildEditableCard('UPI ID', _upiId, (v) => _upiId = v),
                  _buildEditableCard('Email', _email, (v) => _email = v),
                  _buildEditableCard(
                      'दुकान का पता', _shopAddress, (v) => _shopAddress = v),
                  _buildEditableCard(
                      'दुकान का समय', _shopTiming, (v) => _shopTiming = v),
                  _buildCodSwitch(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('📊 ऑर्डर समरी'),
                  _buildOrdersSummaryCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('🔐 सुरक्षा सेटिंग्स'),
                  _buildLoginCredentialsCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('🆕 प्रोडक्ट मैनेजमेंट'),
                  _buildSingleProductCard(),
                  const SizedBox(height: 12),
                  _buildSectionHeader('📋 प्रोडक्ट लिस्ट (एडिट/डिलीट)'),
                  _buildProductListCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('📢 होम पेज कंटेंट'),
                  _buildEditableCard(
                      'न्यूज़ टिकर', _newsText, (v) => _newsText = v,
                      maxLines: 2),
                  _buildEditableCard(
                      'बैनर 1 टाइटल', _bannerTitle1, (v) => _bannerTitle1 = v),
                  _buildEditableCard(
                      'बैनर 2 टाइटल', _bannerTitle2, (v) => _bannerTitle2 = v),
                  _buildEditableCard(
                      'बैनर 3 टाइटल', _bannerTitle3, (v) => _bannerTitle3 = v),
                  const SizedBox(height: 20),
                  _buildSectionHeader('📄 कंटेंट पेज'),
                  _buildEditableCard('📝 हमारे बारे में', _aboutUsText,
                      (v) => _aboutUsText = v,
                      maxLines: 6),
                  _buildEditableCard('🔒 प्राइवेसी पॉलिसी', _privacyPolicyText,
                      (v) => _privacyPolicyText = v,
                      maxLines: 6),
                  _buildEditableCard(
                      '📜 नियम और शर्तें', _termsText, (v) => _termsText = v,
                      maxLines: 6),
                  const SizedBox(height: 20),
                  _buildSectionHeader('📦 डेटा मैनेजमेंट'),
                  _buildDataCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildShopNameAndLogoCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: _shopLogoBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(_shopLogoBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.store,
                            size: 40, color: Colors.green);
                      },
                    )
                  : const Icon(Icons.add_photo_alternate,
                      size: 40, color: Colors.green),
            ),
            title: const Text('दुकान का लोगो',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_shopLogoBase64.isNotEmpty
                ? '✅ लोगो सेट है'
                : '🖼️ टैप करके लोगो लगाएं'),
            trailing: Icon(Icons.camera_alt, color: Colors.green[700]),
            onTap: _uploadShopLogo,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.green),
            title: Text('दुकान का नाम',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_shopName),
            trailing: const Icon(Icons.edit, color: Colors.green),
            onTap: () => _showEditDialog(
                'दुकान का नाम', _shopName, (v) => _shopName = v),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, Function(String) onSave,
      {int maxLines = 1}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            value.length > 50 ? '${value.substring(0, 50)}...' : value,
            maxLines: maxLines > 1 ? maxLines : 2),
        trailing: const Icon(Icons.edit, color: Colors.green),
        onTap: () => _showEditDialog(label, value, onSave, maxLines: maxLines),
      ),
    );
  }

  Widget _buildLoginCredentialsCard() {
    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.security, color: Colors.orange),
        title: const Text('लॉगिन क्रेडेंशियल्स बदलें'),
        subtitle: const Text('ईमेल और पासवर्ड दोनों बदल सकते हैं'),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
        onTap: _changeLoginCredentials,
      ),
    );
  }

  Widget _buildSingleProductCard() {
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        title: const Text('सिंगल प्रोडक्ट जोड़ें',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            const Text('250ml, 500gm, 1KG, 2KG, बोरी, पीस आदि यूनिट के साथ'),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: _addSingleProduct,
      ),
    );
  }

  Widget _buildCodSwitch() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: const Text('कैश ऑन डिलीवरी (COD)'),
        subtitle: Text(_isCodEnabled ? '✅ COD चालू है' : '❌ COD बंद है'),
        value: _isCodEnabled,
        onChanged: (value) {
          setState(() => _isCodEnabled = value);
          _saveAllSettings();
        },
        activeColor: Colors.green,
        secondary: Icon(_isCodEnabled ? Icons.currency_rupee : Icons.block,
            color: _isCodEnabled ? Colors.green : Colors.red),
      ),
    );
  }

  Widget _buildDataCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.blue),
            title: const Text('JSON इम्पोर्ट करें'),
            subtitle: const Text('बल्क अपलोड के लिए'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _importJson,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.green),
            title: const Text('JSON एक्सपोर्ट करें'),
            subtitle: const Text('बैकअप लें'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _exportJson,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: const Text('डिफ़ॉल्ट रीसेट'),
            subtitle: const Text('सारा डेटा रीसेट करें'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _resetToDefault,
          ),
        ],
      ),
    );
  }
}
