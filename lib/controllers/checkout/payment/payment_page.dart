import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:pay/pay.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/controllers/checkout/payment/promo_code_controller.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/ticket_payment.dart';
import 'package:day_night/models/purchase/participant.dart';
import 'package:day_night/models/event_details.dart';
  
class PaymentPage extends StatefulWidget {
  final CheckoutTickets orderInfo;
  final EventDetails eventDetails;
  final List<(TicketItem, int)> flattenedTickets;

  const PaymentPage({super.key, required this.orderInfo, required this.eventDetails, required this.flattenedTickets});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPromoCodeLoading = false;
  String? _promoCodeError;
  String? _promoCodeSuccess;
  late List<TicketPayment> _ticketPayments;
  
  // Payment related variables
  late final Pay _payClient;
  bool _isPaymentLoading = false;
  bool _isCreditCardExpanded = false;
  
  // Checkbox states
  bool _subscribeToNewsletterFromDayNight = true;
  bool _subscribeToNewsletterFromOrganizer = true;

  double get totalProcessingFee {
    double totalFee = 0.0;
    final processingFeeValue = widget.eventDetails.eventInformation.prcessingFee.toDouble();
    final processingFeeType = widget.eventDetails.eventInformation.prcessingFeeType;
    
    for (final ticketPayment in _ticketPayments) {
      if (processingFeeType == 'percentage') {
        // Apply percentage fee to the total ticket cost
        totalFee += (ticketPayment.ticketPrice * ticketPayment.participantCount) * (processingFeeValue / 100);
      } else {
        // Apply fixed fee per ticket
        totalFee += processingFeeValue * ticketPayment.participantCount;
      }
    }
    
    return totalFee;
  }

  double get totalAmount {
    return _ticketPayments.fold(0.0, (sum, ticketPayment) {
      return sum + ticketPayment.totalAmount;
    });
  }

  double get ticketSubtotal {
    return _ticketPayments.fold(0.0, (sum, ticketPayment) {
      return sum + (ticketPayment.ticketPrice * ticketPayment.participantCount);
    });
  }

  double get finalAmount {
    double subtotal = totalAmount;
    double discount = 0.0;
    bool hasValidCoupon = _promoCodeSuccess != null;
    
    // If there's a valid coupon, apply discount (example: 10% off for DN10OFF)
    if (hasValidCoupon) {
      discount = subtotal * 0.1; // 10% discount
    }
    
    return subtotal - discount + totalProcessingFee;
  }

  bool get _isAppleDevice {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String get _paymentMethodText {
    return _isAppleDevice ? 'Apple Pay' : 'Google Pay';
  }

  IconData get _paymentMethodIcon {
    return _isAppleDevice ? Icons.apple : Icons.android;
  }

  void _handlePaymentMethodTap() async {
    if (_isPaymentLoading) return;
    
    setState(() {
      _isPaymentLoading = true;
    });

    try {
      final paymentConfiguration = await _loadPaymentConfiguration();
      
      if (paymentConfiguration != null) {
        final provider = _isAppleDevice ? PayProvider.apple_pay : PayProvider.google_pay;
        _payClient = Pay({provider: paymentConfiguration});
        await _initiatePayment();
      } else {
        _showPaymentError('Payment configuration not available');
      }
    } catch (e) {
      _showPaymentError('Payment failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isPaymentLoading = false;
        });
      }
    }
  }

  Future<PaymentConfiguration?> _loadPaymentConfiguration() async {
    try {
      final configPath = _isAppleDevice 
          ? 'assets/payment_configs/apple_pay_config.json'
          : 'assets/payment_configs/google_pay_config.json';
      
      final configString = await rootBundle.loadString(configPath);
      return PaymentConfiguration.fromJsonString(configString);
    } catch (e) {
      print('Failed to load payment configuration: $e');
      return null;
    }
  }

  Future<void> _initiatePayment() async {
    final paymentItems = [
      PaymentItem(
        label: 'Tickets',
        amount: ticketSubtotal.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
      if (totalProcessingFee > 0)
        PaymentItem(
          label: 'Processing Fee',
          amount: totalProcessingFee.toStringAsFixed(2),
          status: PaymentItemStatus.final_price,
        ),
      if (_promoCodeSuccess != null)
        PaymentItem(
          label: 'Discount',
          amount: '-${(ticketSubtotal * 0.1).toStringAsFixed(2)}',
          status: PaymentItemStatus.final_price,
        ),
      PaymentItem(
        label: 'Total',
        amount: finalAmount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
      ),
    ];

    try {
      final provider = _isAppleDevice ? PayProvider.apple_pay : PayProvider.google_pay;
      final result = await _payClient.showPaymentSelector(
        provider,
        paymentItems,
      );
      
      await _processPaymentResult(result);
    } catch (e) {
      _showPaymentError('Payment was cancelled or failed');
    }
  }

  Future<void> _processPaymentResult(Map<String, dynamic> paymentResult) async {
    try {
      // Here you would typically send the payment result to your backend
      print('Payment Result: $paymentResult');
      
      // Extract payment token
      final token = paymentResult['paymentData'] ?? paymentResult['token'];
      
      if (token != null) {
        // TODO: Send payment data to your backend API
        await _sendPaymentToBackend(token);
        
        // Show success message
        _showPaymentSuccess();
      } else {
        _showPaymentError('Invalid payment token received');
      }
    } catch (e) {
      _showPaymentError('Failed to process payment: ${e.toString()}');
    }
  }

  Future<void> _sendPaymentToBackend(dynamic paymentToken) async {
    // TODO: Implement actual API call to your backend
    // This should include:
    // - Payment token
    // - Order details (_ticketPayments)
    // - User information
    // - Event details
    
    print('Sending payment to backend...');
    print('Payment Token: $paymentToken');
    print('Tickets: ${_ticketPayments.map((t) => t.toString()).join(', ')}');
    print('Total Amount: \$${finalAmount}');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showPaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! Total: \$${finalAmount.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // TODO: Navigate to success page or back to home
    Navigator.pop(context);
  }

  void _showPaymentError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openTermsAndConditions() {
    // TODO: Navigate to terms and conditions page or open web view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Terms and Conditions...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Navigate to privacy policy page or open web view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Privacy Policy...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPaymentMethodButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _isPaymentLoading ? null : _handlePaymentMethodTap,
          child: Center(
            child: _isPaymentLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _paymentMethodIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _paymentMethodText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTicketPayments();
  }

  void _initializeTicketPayments() {
    _ticketPayments = [];
    
    // Group flattened tickets by ticket ID
    Map<String, List<int>> ticketGroups = {};
    for (int i = 0; i < widget.flattenedTickets.length; i++) {
      final (ticket, _) = widget.flattenedTickets[i];
      if (!ticketGroups.containsKey(ticket.id)) {
        ticketGroups[ticket.id] = [];
      }
      ticketGroups[ticket.id]!.add(i);
    }

    // Create TicketPayment objects for each unique ticket
    ticketGroups.forEach((ticketId, participantIndices) {
      final (ticket, _) = widget.flattenedTickets[participantIndices.first];
      final ticketPrice = double.tryParse(ticket.ticket.price ?? '0') ?? 0.0;
      
      // Get participants for this ticket from the participant info
      List<Participant> ticketParticipants = [];
      final participantsInfo = widget.orderInfo.currentBasket.participantsInfo;
      
      // Get participants by their indices from the flattened tickets
      for (int participantIndex in participantIndices) {
        if (participantsInfo != null && participantIndex < participantsInfo.participants.length) {
          ticketParticipants.add(participantsInfo.participants[participantIndex]);
        } else {
          // Create a placeholder participant if not enough data
          ticketParticipants.add(Participant(
            fullName: 'Participant ${participantIndex + 1}',
            ticketId: ticketId,
          ));
        }
      }

      final ticketPayment = TicketPayment(
        ticketId: ticketId,
        ticketPrice: ticketPrice,
        participants: ticketParticipants,
      );
      
      _ticketPayments.add(ticketPayment);
      
      // Debug print to verify the structure
      print('Created TicketPayment: $ticketPayment');
    });
  }

  void _clearPromoCodeMessages() {
    setState(() {
      _promoCodeError = null;
      _promoCodeSuccess = null;
    });
  }

  /// Process payment using the TicketPayment objects
  void _processPayment() {
    print('Processing payment for ${_ticketPayments.length} ticket types:');
    
    for (final ticketPayment in _ticketPayments) {
      print('- Ticket ID: ${ticketPayment.ticketId}');
      print('  Price per ticket: \$${ticketPayment.ticketPrice}');
      print('  Participants: ${ticketPayment.participantCount}');
      print('  Total for this ticket: \$${ticketPayment.totalAmount}');
      print('  Participants: ${ticketPayment.participants.map((p) => p.fullName).join(', ')}');
    }
    
    print('Grand total: \$${finalAmount}');
    
    // TODO: Implement actual payment processing
  }

  void _handlePromoCodeApplied(String promoCode) async {
    setState(() {
      _isPromoCodeLoading = true;
      _promoCodeError = null;
      _promoCodeSuccess = null;
    });

    try {
      // TODO: Implement actual promo code validation API call
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call
      
      // For now, simulate success for valid promo codes
      if (promoCode.toUpperCase() == 'DN10OFF' || promoCode.toLowerCase() == 'demo') {
        setState(() {
          _promoCodeSuccess = AppLocalizations.of(context).get('coupon-applied-successfully');
          _isPromoCodeLoading = false;
        });
      } else {
        setState(() {
          _promoCodeError = AppLocalizations.of(context).get('invalid-coupon');
          _isPromoCodeLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _promoCodeError = AppLocalizations.of(context).get('invalid-coupon');
        _isPromoCodeLoading = false;
      });
    }
  }

  Widget _buildPaymentSummary() {
    double ticketsSubtotal = ticketSubtotal;
    double processingFeeTotal = totalProcessingFee;
    double discount = 0.0;
    bool hasValidCoupon = _promoCodeSuccess != null;
    
    // If there's a valid coupon, apply discount (example: 10% off for DN10OFF)
    if (hasValidCoupon) {
      discount = ticketsSubtotal * 0.1; // 10% discount on tickets only
    }
    
    double finalTotal = ticketsSubtotal - discount + processingFeeTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).get('order-summary'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ticket items using TicketPayment objects
          ..._ticketPayments.map((ticketPayment) {
            // Find the ticket details from flattened tickets
            final ticketItem = widget.flattenedTickets.firstWhere(
              (item) => item.$1.id == ticketPayment.ticketId,
            );
            final ticket = ticketItem.$1;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.ticket.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (ticketPayment.participantCount > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kBrandPrimary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: kBrandPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ticketPayment.participantCount}',
                                  style: TextStyle(
                                    color: kBrandPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context).get('currency')} ${ticketPayment.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (_ticketPayments.length > 1) ...[
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).get('subtotal'),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context).get('currency')}${ticketsSubtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Coupon discount (if applied)
          if (hasValidCoupon) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).get('discount'),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '-${AppLocalizations.of(context).get('currency')}${discount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
          ],

          // Processing fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).get('processing-fee'),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
              Text(
                '${AppLocalizations.of(context).get('currency')}${processingFeeTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),

          // Final total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).get('total'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${AppLocalizations.of(context).get('currency')}${finalTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Payment Method Button
          _buildPaymentMethodButton(),
        ],
      ),
    );
  }

  Widget _buildCreditCardPayment() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header - always visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _isCreditCardExpanded = !_isCreditCardExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).get('payment-with-credit'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isCreditCardExpanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expandable content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isCreditCardExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  
                  // Secured payment content placeholder
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[700]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Secured Payment Form',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Credit card payment form will be loaded here',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Placeholder payment button
                        SizedBox(
                          width: 200,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Credit card payment would be processed here'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock, size: 18),
                                const SizedBox(width: 8),
                                Text('Pay Securely'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxFields() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 8),
      child: Column(
        children: [
          // Terms and Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _subscribeToNewsletterFromDayNight,
                onChanged: (bool? value) {
                  setState(() {
                    _subscribeToNewsletterFromDayNight = value ?? false;
                  });
                },
                activeColor: kBrandPrimary,
                side: BorderSide(color: Colors.grey[400]!),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    AppLocalizations.of(context).get('subscribe-newsletter-daynight'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Newsletter Subscription Checkbox - Only show if organizer exists
          if (widget.eventDetails.organizer != null) ...[
            const SizedBox(height: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _subscribeToNewsletterFromOrganizer,
                  onChanged: (bool? value) {
                    setState(() {
                      _subscribeToNewsletterFromOrganizer = value ?? false;
                    });
                  },
                  activeColor: kBrandPrimary,
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${AppLocalizations.of(context).get('subscribe-newsletter-organizer')}${widget.eventDetails.organizer!.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CustomAppBar(
                  titleKey: 'buy-tickets',
                  onBackPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 88.0), // Extra bottom padding for the fixed button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Promo Code Field - First field in the page
                        PromoCodeField(
                          onPromoCodeApplied: _handlePromoCodeApplied,
                          onTextChanged: _clearPromoCodeMessages,
                          isLoading: _isPromoCodeLoading,
                          errorMessage: _promoCodeError,
                          successMessage: _promoCodeSuccess,
                        ),
                        const SizedBox(height: 24),
                        // Payment Summary Section
                        _buildPaymentSummary(),
                        const SizedBox(height: 24),
                        // Credit Card Payment Section
                        _buildCreditCardPayment(),
                        const SizedBox(height: 24),
                        // Checkbox Fields Section
                        _buildCheckboxFields(),
                        const SizedBox(height: 16), // Bottom spacing
                      ],
                    ),
                  ),
                ),],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kMainBackgroundColor.withAlpha(0),
                      kMainBackgroundColor.withAlpha(204), // 0.8 * 255 = 204
                      kMainBackgroundColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBrandPrimary,
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: kBrandPrimary,
                              width: 2,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '${AppLocalizations.of(context).get('to-payment-of')} ${AppLocalizations.of(context).get('currency')}${finalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context).get('by-clicking-payment-agree-to'),
                            ),
                            TextSpan(
                              text: ' ${AppLocalizations.of(context).get('terms-and-conditions')}',
                              style: TextStyle(
                                color: kBrandPrimary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _openTermsAndConditions();
                                },
                            ),
                            TextSpan(
                              text: ' ${AppLocalizations.of(context).get('and')} ',
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context).get('privacy-policy'),
                              style: TextStyle(
                                color: kBrandPrimary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _openPrivacyPolicy();
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}