import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/recent_analysis_card.dart';
import '../localization/localization_extension.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisProvider>(context);
    final history = provider.history.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.meaning.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.history),
        actions: [
          if (provider.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _confirmClear(context, provider),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: context.l10n.searchAnalyses,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: history.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        provider.deleteAnalysis(item.id);
                      },
                      child: RecentAnalysisCard(result: item),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? context.l10n.noHistoryYet : context.l10n.noResultsFound,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.clearHistoryTitle),
        content: Text(context.l10n.clearHistoryMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: Text(context.l10n.clearAll, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
