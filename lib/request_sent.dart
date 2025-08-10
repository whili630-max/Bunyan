import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'animated_effects.dart';

class RequestSentPage extends StatelessWidget {
  final String? productName;
  final String? requestDetails;

  const RequestSentPage({this.productName, this.requestDetails, super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeSlideInEffect(
          offset: const Offset(0, 30),
          duration: const Duration(milliseconds: 600),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success animation
                  AnimatedEffects.success(size: 200),
                  const SizedBox(height: 24),

                  // Success message
                  FadeInEffect(
                    delay: 500,
                    child: Text(
                      localizations.requestSentSuccessfully,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional details
                  FadeInEffect(
                    delay: 1000,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        '${localizations.yourRequestFor} ${productName ?? localizations.theProduct} ${localizations.hasBeenSent}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Back to dashboard button
                  FadeInEffect(
                    delay: 1500,
                    child: AnimatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/client_dashboard');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          localizations.backToDashboard,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Browse more products button
                  FadeInEffect(
                    delay: 2000,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/products');
                      },
                      child: Text(
                        localizations.browseMoreProducts,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
