import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';

class TicketTypeModel {
  String name;
  double price;
  int quantity;
  String description;

  TicketTypeModel({
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
  });
}

class NewEventStep3 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const NewEventStep3({
    super.key,
    required this.eventData,
    required this.onDataChanged,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  State<NewEventStep3> createState() => _NewEventStep3State();
}

class _NewEventStep3State extends State<NewEventStep3> {
  final _formKey = GlobalKey<FormState>();
  List<TicketTypeModel> _ticketTypes = [];
  bool _isFreeEvent = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    _isFreeEvent = widget.eventData['isFreeEvent'] ?? false;
    
    // Initialize ticket types from saved data or create default one
    final savedTickets = widget.eventData['ticketTypes'] as List<TicketTypeModel>?;
    if (savedTickets != null && savedTickets.isNotEmpty) {
      _ticketTypes = savedTickets;
    } else if (!_isFreeEvent) {
      _addTicketType();
    }
  }

  bool _isFormValid() {
    if (_isFreeEvent) return true;
    
    return _ticketTypes.isNotEmpty && 
           _ticketTypes.every((ticket) => 
               ticket.name.isNotEmpty && 
               ticket.quantity > 0);
  }

  void _addTicketType() {
    setState(() {
      _ticketTypes.add(TicketTypeModel(
        name: '',
        price: 0.0,
        quantity: 1,
        description: '',
      ));
    });
  }

  void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }

  void _saveAndComplete() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('isFreeEvent', _isFreeEvent);
      widget.onDataChanged('ticketTypes', _ticketTypes);
      
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kMainBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Free Event Toggle
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).get('free-event'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).get('free-event-description'),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        value: _isFreeEvent,
                        onChanged: (bool value) {
                          setState(() {
                            _isFreeEvent = value;
                            if (value) {
                              _ticketTypes.clear();
                            } else if (_ticketTypes.isEmpty) {
                              _addTicketType();
                            }
                          });
                        },
                        activeColor: kBrandPrimary,
                      ),
                    ),
                    
                    if (!_isFreeEvent) ...[
                      const SizedBox(height: 24),
                      
                      // Ticket Types Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).get('ticket-types'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _addTicketType,
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                            ),
                            tooltip: AppLocalizations.of(context).get('add-ticket-type'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Ticket Types List
                      ..._ticketTypes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ticket = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with delete button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context).get('ticket-type')} ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_ticketTypes.length > 1)
                                    IconButton(
                                      onPressed: () => _removeTicketType(index),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Ticket Name
                              TextFormField(
                                initialValue: ticket.name,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).get('ticket-name'),
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                  hintText: AppLocalizations.of(context).get('enter-ticket-name'),
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context).get('ticket-name-required');
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  ticket.name = value;
                                  setState(() {});
                                },
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Price and Quantity Row
                              Row(
                                children: [
                                  // Price
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: ticket.price.toString(),
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context).get('price'),
                                        labelStyle: TextStyle(color: Colors.grey[400]),
                                        hintText: '0.00',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: Colors.grey[800],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        suffixText: '₪',
                                        suffixStyle: TextStyle(color: Colors.grey[400]),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context).get('price-required');
                                        }
                                        if (double.tryParse(value) == null) {
                                          return AppLocalizations.of(context).get('price-must-be-number');
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        ticket.price = double.tryParse(value) ?? 0.0;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // Quantity
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: ticket.quantity.toString(),
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context).get('quantity'),
                                        labelStyle: TextStyle(color: Colors.grey[400]),
                                        hintText: '1',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        filled: true,
                                        fillColor: Colors.grey[800],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context).get('quantity-required');
                                        }
                                        final qty = int.tryParse(value);
                                        if (qty == null || qty <= 0) {
                                          return AppLocalizations.of(context).get('quantity-must-be-positive');
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        ticket.quantity = int.tryParse(value) ?? 1;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Description
                              TextFormField(
                                initialValue: ticket.description,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).get('description-optional'),
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                  hintText: AppLocalizations.of(context).get('enter-ticket-description'),
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  ticket.description = value;
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      if (_ticketTypes.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                color: Colors.grey[400],
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).get('no-ticket-types'),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _addTicketType,
                                icon: const Icon(Icons.add),
                                label: Text(AppLocalizations.of(context).get('add-first-ticket-type')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kBrandPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Back Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.of(context).get('back')),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Create Event Button
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    onPressed: _saveAndComplete,
                    textKey: 'create-event',
                    disabled: !_isFormValid(),
                    trailingIcon: Icons.check,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}