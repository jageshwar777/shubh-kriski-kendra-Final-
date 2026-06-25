import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isProcessing = false;
  String _selectedPaymentMethod = 'upi';
  String _upiId = 'shopowner@okhdfcbank';
  bool _isCodEnabled = true;
  Order? _lastOrder;

  @override
  void initState() {
    super.initState();
    _loadUpiId();
    _loadCodStatus();
  }

  Future<void> _loadUpiId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _upiId = prefs.getString('upi_id') ?? 'shopowner@okhdfcbank';
      });
    }
  }

  Future<void> _loadCodStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isCodEnabled = prefs.getBool('cod_enabled') ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('पता और पेमेंट'),
        backgroundColor: Colors.green[700],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('आपका ऑर्डर',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            ...cartProvider.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          child: Text(
                                              '${item.product.name} x ${item.quantity}')),
                                      Text(
                                          '₹${(item.product.price * item.quantity).toStringAsFixed(0)}'),
                                    ],
                                  ),
                                )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('कुल रकम:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    '₹${cartProvider.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'पूरा नाम *',
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'नाम लिखें' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                          labelText: 'मोबाइल नंबर *',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v!.length != 10 ? '10 अंकों का नंबर' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                          labelText: 'पता *', border: OutlineInputBorder()),
                      maxLines: 2,
                      validator: (v) => v!.isEmpty ? 'पता लिखें' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('पेमेंट का तरीका',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile(
                      value: 'upi',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) =>
                          setState(() => _selectedPaymentMethod = v.toString()),
                      title: const Text('UPI पेमेंट'),
                      subtitle: const Text('PhonePe, GooglePay, Paytm'),
                    ),
                    if (_isCodEnabled)
                      RadioListTile(
                        value: 'cod',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (v) => setState(
                            () => _selectedPaymentMethod = v.toString()),
                        title: const Text('कैश ऑन डिलीवरी (COD)'),
                        subtitle: const Text('सामान मिलने पर पैसे दें'),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _processOrder(cartProvider),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('ऑर्डर कन्फर्म करें'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _processOrder(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final order = Order(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now().toString(),
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      customerAddress: _addressController.text,
      items: cartProvider.items
          .map((item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                price: item.product.price,
                unit: item.product.unit,
              ))
          .toList(),
      totalAmount: cartProvider.totalPrice,
      paymentMethod: _selectedPaymentMethod,
      paymentStatus: _selectedPaymentMethod == 'upi' ? 'Pending' : 'Pending',
      status: _selectedPaymentMethod == 'upi' ? 'Pending' : 'Pending',
      transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerPhone: '919876543210',
    );

    Provider.of<OrderProvider>(context, listen: false).addOrder(order);
    _lastOrder = order;

    if (_selectedPaymentMethod == 'upi') {
      final String upiUrl =
          "upi://pay?pa=$_upiId&pn=Shubh%20Mart&am=${cartProvider.totalPrice.toStringAsFixed(0)}&cu=INR&tn=Order%20Payment";

      try {
        await launchUrl(Uri.parse(upiUrl),
            mode: LaunchMode.externalApplication);
        _showPaymentConfirmationDialog();
      } catch (e) {
        _showQrCodeDialog(upiUrl, cartProvider.totalPrice);
      }
    }

    cartProvider.clearCart();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    _showShareDialog();
  }

  void _showQrCodeDialog(String upiUrl, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📱 UPI QR Code स्कैन करें',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: QrImageView(
                  data: upiUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'कुल रकम: ₹${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text('PhonePe, GooglePay या Paytm से स्कैन करें'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(ctx);
                      },
                      child: const Text('बाद में'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ पेमेंट कन्फर्म!'),
                              backgroundColor: Colors.green),
                        );
                        _showShareDialog();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('पेमेंट कर दिया ✅'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('पेमेंट स्टेटस'),
        content: const Text('क्या आपका पेमेंट सफलतापूर्वक हो गया है?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showShareDialog();
            },
            child: const Text('नहीं, बाद में'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('✅ पेमेंट कन्फर्म!'),
                    backgroundColor: Colors.green),
              );
              _showShareDialog();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('हाँ, हो गया'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ ऑर्डर हो गया!'),
        content: const Text('इनवॉइस कैसे शेयर करना चाहेंगे?'),
        actions: [
          // WhatsApp Direct - Icons.whatsapp से Icons.message बदला (Flutter में whatsapp icon नहीं है)
          ElevatedButton.icon(
            onPressed: () {
              if (_lastOrder != null) {
                _shareOnWhatsApp(_lastOrder!);
              }
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.message, color: Colors.white),
            label: const Text('व्हाट्सएप'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // System Share Sheet (All Apps)
          ElevatedButton.icon(
            onPressed: () {
              if (_lastOrder != null) {
                Share.share(_generateInvoice(_lastOrder!));
              }
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.share),
            label: const Text('सभी ऐप्स'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text('बाद में'),
          ),
        ],
      ),
    );
  }

  void _shareOnWhatsApp(Order order) async {
    String invoice = _generateInvoice(order);
    String phoneNumber = order.ownerPhone;
    String url =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(invoice)}";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Share.share(invoice);
      }
    } catch (e) {
      Share.share(invoice);
    }
  }

  String _generateInvoice(Order order) {
    return """
╔══════════════════════════════════════╗
║         Shubh Mart                   ║
║         === इनवॉइस ===              ║
╠══════════════════════════════════════╣
║ ऑर्डर ID: ${order.orderId}          
║ दिनांक: ${order.date}               
╠══════════════════════════════════════╣
║ ग्राहक जानकारी:                     
║ नाम: ${order.customerName}           
║ मोबाइल: ${order.customerPhone}      
║ पता: ${order.customerAddress}        
╠══════════════════════════════════════╣
║ सामान की जानकारी:                    
${order.items.map((item) => '║ ${item.productName} x ${item.quantity} ${item.unit} = ₹${(item.price * item.quantity).toStringAsFixed(0)}').join('\n')}
╠══════════════════════════════════════╣
║ कुल रकम: ₹${order.totalAmount.toStringAsFixed(0)}        
║ पेमेंट: ${order.paymentMethod}       
║ स्थिति: ${order.paymentStatus}       
╚══════════════════════════════════════╝
    """;
  }
}
