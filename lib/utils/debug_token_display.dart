import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/user/user_controller.dart';

/// Debug widget to display and copy the full authentication token
/// WARNING: Only use in development! Remove before production.
class DebugTokenDisplay extends StatefulWidget {
  const DebugTokenDisplay({super.key});

  @override
  State<DebugTokenDisplay> createState() => _DebugTokenDisplayState();
}

class _DebugTokenDisplayState extends State<DebugTokenDisplay> {
  String? _token;
  bool _isLoading = false;
  bool _tokenCopied = false;

  Future<void> _loadToken() async {
    setState(() {
      _isLoading = true;
      _tokenCopied = false;
    });

    try {
      final userController = Provider.of<UserController>(context, listen: false);
      // Get token from storage
      final token = await userController.getStoredPhoneNumber(); // This gets phone, we need token
      // Let's use the auth service directly
      final authService = userController;
      
      // Actually, let's just call the debug method
      await userController.showFullTokenInConsole();
      
      setState(() {
        _token = 'Check the console/terminal output above for the full token!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _token = 'Error loading token: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_token != null && !_token!.startsWith('Check')) {
      Clipboard.setData(ClipboardData(text: _token!));
      setState(() {
        _tokenCopied = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DEBUG: Token Display',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'WARNING: Remove this widget before production!',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _loadToken,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isLoading ? 'Loading...' : 'Show Full Token in Console'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          
          if (_token != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Token:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_token!.startsWith('Check'))
                        IconButton(
                          icon: Icon(
                            _tokenCopied ? Icons.check : Icons.copy,
                            color: _tokenCopied ? Colors.green : Colors.white,
                            size: 20,
                          ),
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy to clipboard',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _token!,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Tip: Check your terminal/console output for the complete token to copy!',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
