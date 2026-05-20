import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_exception.dart';
import '../widgets/premium_core.dart';


class SmartAnalysisErrorView extends StatefulWidget {
  final AnalysisException exception;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const SmartAnalysisErrorView({
    super.key,
    required this.exception,
    required this.onRetry,
    required this.onBack,
  });

  @override
  State<SmartAnalysisErrorView> createState() => _SmartAnalysisErrorViewState();
}

class _SmartAnalysisErrorViewState extends State<SmartAnalysisErrorView> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildErrorIcon(),
              const SizedBox(height: 32),
              _buildErrorTitle(context),
              const SizedBox(height: 12),
              _buildErrorDescription(context),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                _buildDebugToggle(),
                if (_showDebug) _buildDebugPanel(),
              ],
              const SizedBox(height: 48),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    IconData icon;
    Color color;

    switch (widget.exception.reason) {
      case AnalysisFailureReason.networkError:
        icon = Icons.wifi_off_rounded;
        color = Colors.blueAccent;
        break;
      case AnalysisFailureReason.providerQuotaExceeded:
        icon = Icons.bolt_rounded;
        color = Colors.orangeAccent;
        break;
      case AnalysisFailureReason.providerTimeout:
        icon = Icons.timer_outlined;
        color = Colors.purpleAccent;
        break;
      default:
        icon = Icons.error_outline_rounded;
        color = Colors.redAccent;
    }

    return Animate(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 56, color: color),
      ),
    )
        .scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack)
        .shake(delay: const Duration(milliseconds: 500));
  }

  Widget _buildErrorTitle(BuildContext context) {
    String title;
    switch (widget.exception.reason) {
      case AnalysisFailureReason.networkError:
        title = 'Connection Interrupted';
        break;
      case AnalysisFailureReason.providerQuotaExceeded:
        title = 'AI Servers Busy';
        break;
      case AnalysisFailureReason.providerTimeout:
        title = 'Analysis Timed Out';
        break;
      default:
        title = 'Analysis Encountered a Problem';
    }

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildErrorDescription(BuildContext context) {
    String desc;
    switch (widget.exception.reason) {
      case AnalysisFailureReason.networkError:
        desc =
            'We couldn\'t reach our AI engine. Please check your internet connection and try again.';
        break;
      case AnalysisFailureReason.providerQuotaExceeded:
        desc =
            'High demand is affecting response times. Our system is working to restore full speed.';
        break;
      case AnalysisFailureReason.providerTimeout:
        desc =
            'The screenshot was complex and took longer than expected to process.';
        break;
      default:
        desc =
            'Something unexpected happened while scanning your image. Our engineers have been notified.';
    }

    return Text(
      desc,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.5)
            : Colors.black54,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  Widget _buildDebugToggle() {
    return InkWell(
      onTap: () => setState(() => _showDebug = !_showDebug),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bug_report_rounded,
                size: 14, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 8),
            Text(
              _showDebug ? 'Hide Technical Details' : 'Show Technical Details',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _debugLine('Stage', widget.exception.debugStage ?? 'Unknown'),
          _debugLine('Reason', widget.exception.reason.toString()),
          _debugLine('Summary', widget.exception.diagnosticSummary),
          if (widget.exception.stackTrace != null) ...[
            const Divider(color: Colors.white10),
            const Text('Stack Trace Preview:',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              widget.exception.stackTrace
                  .toString()
                  .split('\n')
                  .take(5)
                  .join('\n'),
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10, fontFamily: 'monospace'),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _debugLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.white70, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PremiumButton(
          onPressed: widget.onRetry,
          child: const Text('Retry Analysis'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onBack,
          child: Text(
            'Return to Home',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black45,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.1, end: 0);
  }
}
