import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CloudDemoScreen extends StatefulWidget {
  const CloudDemoScreen({super.key});

  @override
  State<CloudDemoScreen> createState() => _CloudDemoScreenState();
}

class _CloudDemoScreenState extends State<CloudDemoScreen> {
  bool _isTestingApi = false;
  String? _apiTestResult;
  int? _latencyMs;

  Future<void> _simulateCloudApiCall() async {
    setState(() {
      _isTestingApi = true;
      _apiTestResult = null;
    });

    final stopwatch = Stopwatch()..start();
    // Simulate AWS API Gateway + Lambda roundtrip
    await Future.delayed(const Duration(milliseconds: 320));
    stopwatch.stop();

    setState(() {
      _isTestingApi = false;
      _latencyMs = stopwatch.elapsedMilliseconds;
      _apiTestResult = r'''
HTTP/1.1 200 OK
Content-Type: application/json
x-amzn-RequestId: c784f1a2-938b-49ef-b049-92bb3f13904a
x-amz-apigw-id: I9F0aE5ioAMEfPA=
X-Amzn-Trace-Id: Root=1-6543b8a1-34e8f01b2a992bc

{
  "status": "success",
  "auth": "Cognito JWT Validated (sub: demo_user_1)",
  "database": "DynamoDB (Table: FoodScannerHistory, latency: 12ms)",
  "monitoring": "CloudWatch Logs Stream: /aws/lambda/FoodScannerBackend",
  "billingTier": "AWS Always-Free Tier ($0.00 billed)"
}''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Architecture & Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Cloud Computing Project Architecture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Demonstrating Serverless Compute, Managed Auth, NoSQL Storage, and Telemetry on Amazon Web Services (AWS).',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Architecture Components
            const Text(
              'AWS Cloud Service Stack',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildComponentCard(
              title: 'Amazon Cognito',
              role: 'Authentication & Multi-Tenant Identity',
              desc:
                  'Issues secure JWT tokens. The unique user sub claim isolates profiles and scan history per user.',
              icon: Icons.vpn_key_outlined,
              color: const Color(0xFFE11D48),
            ),
            _buildComponentCard(
              title: 'Amazon API Gateway (HTTP API v2)',
              role: 'Managed API & JWT Authorizer',
              desc:
                  'Exposes low-latency HTTP endpoints with native JWT token validation, CORS, and request routing.',
              icon: Icons.alt_route_rounded,
              color: const Color(0xFF2563EB),
            ),
            _buildComponentCard(
              title: 'AWS Lambda (Python 3.11)',
              role: 'Serverless Backend Compute',
              desc:
                  'Stateless execution of personalized assessment logic and database CRUD operations without permanently running servers.',
              icon: Icons.code,
              color: const Color(0xFFD97706),
            ),
            _buildComponentCard(
              title: 'Amazon DynamoDB',
              role: 'NoSQL Multi-Tenant Persistence',
              desc:
                  'FoodScannerProfiles (PK: userId) and FoodScannerHistory (PK: userId, SK: scanId). Millisecond latency at scale.',
              icon: Icons.storage,
              color: const Color(0xFF0D9488),
            ),
            _buildComponentCard(
              title: 'Amazon CloudWatch',
              role: 'Logging & Metrics Telemetry',
              desc:
                  'Collects invocation counts, error rates, and API duration graphs for operational visibility.',
              icon: Icons.insights,
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 20),

            // Section 2: Interactive Cloud API Live Test
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Serverless Endpoint Test',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_latencyMs != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.suitableGreenBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_latencyMs ms Latency',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.suitableGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulates an authenticated HTTPS call to API Gateway /assess route to demonstrate cloud request handling.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTestingApi ? null : _simulateCloudApiCall,
                      icon: _isTestingApi
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(_isTestingApi
                          ? 'Invoking Cloud Endpoint...'
                          : 'Test Cloud API Invocation'),
                    ),
                  ),
                  if (_apiTestResult != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _apiTestResult!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Free-Tier Cost Justification Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AWS Free-Tier Student Cost Analysis',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Cognito: 50,000 Monthly Active Users (Always Free)\n'
                    '• API Gateway: 1,000,000 requests/month (Free Tier)\n'
                    '• AWS Lambda: 1,000,000 requests & 3.2M sec compute/month (Always Free)\n'
                    '• DynamoDB: 25 GB storage & 25 WCU/RCU (Always Free)\n'
                    '• On-Device ML Kit OCR: 100% Free on device (no cloud vision billing)\n\n'
                    'Total Monthly Cost for Project Demo: \$0.00 / Month',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCard({
    required String title,
    required String role,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
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
