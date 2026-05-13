import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../localization/localization_extension.dart';

class ProblemDescriptionInput extends StatefulWidget {
  final Function(String) onSubmitted;
  final String? initialValue;
  final String? buttonText;
  final String? hintText;

  const ProblemDescriptionInput({
    super.key,
    required this.onSubmitted,
    this.initialValue,
    this.buttonText,
    this.hintText,
  });


  @override
  State<ProblemDescriptionInput> createState() => _ProblemDescriptionInputState();
}

class _ProblemDescriptionInputState extends State<ProblemDescriptionInput> {
  late TextEditingController _controller;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addSuggestion(String suggestion) {
    setState(() {
      _controller.text = suggestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.explainProblemTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),


          ],
        ),
        const SizedBox(height: 16),
        
        // Premium Input Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isFocused ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 3,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? context.l10n.describeProblemHint,
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),

                        border: InputBorder.none,
                        suffixIcon: _controller.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () => setState(() => _controller.clear()),
                            ) 
                          : null,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic_none_rounded, size: 18, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(width: 8),
                              Text(
                                '${_controller.text.length} ${context.l10n.characters}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.5)),
                              ),
                            ],
                          ),
                          const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.blue),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Suggestion Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _SuggestionChip(label: context.l10n.loginProblem, onTap: () => _addSuggestion(context.l10n.loginProblem)),
              _SuggestionChip(label: context.l10n.appCrashing, onTap: () => _addSuggestion(context.l10n.appCrashing)),
              _SuggestionChip(label: context.l10n.paymentIssue, onTap: () => _addSuggestion(context.l10n.paymentIssue)),
              _SuggestionChip(label: context.l10n.accountBlocked, onTap: () => _addSuggestion(context.l10n.accountBlocked)),
              _SuggestionChip(label: context.l10n.verificationIssue, onTap: () => _addSuggestion(context.l10n.verificationIssue)),
              _SuggestionChip(label: context.l10n.slowPerformance, onTap: () => _addSuggestion(context.l10n.slowPerformance)),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => widget.onSubmitted(_controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: theme.primaryColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.buttonText ?? context.l10n.startAnalysis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),

                const SizedBox(width: 12),
                const Icon(Icons.bolt_rounded),
              ],
            ),
          ),
        ).animate(target: _controller.text.isNotEmpty ? 1 : 0.8)
         .scale(duration: 200.ms)
         .shimmer(delay: 1.seconds, duration: 2.seconds),
      ],
    ).animate().fadeIn(duration: 500.ms).moveY(begin: 30, end: 0);
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey.withOpacity(0.05),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        labelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
