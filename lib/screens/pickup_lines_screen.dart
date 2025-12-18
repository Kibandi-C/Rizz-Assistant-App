import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class PickupLinesScreen extends StatefulWidget {
  const PickupLinesScreen({super.key});

  @override
  State<PickupLinesScreen> createState() => _PickupLinesScreenState();
}

class _PickupLinesScreenState extends State<PickupLinesScreen> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Generate initial lines on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().generatePickupLines();
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final responses = chatProvider.generatedResponses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Lines'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Enter a topic (optional)...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => chatProvider.generatePickupLines(
                    topic: _topicController.text.trim(),
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: chatProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : responses.isEmpty
                      ? const Center(child: Text('No lines generated yet.'))
                      : ListView.builder(
                          itemCount: responses.length,
                          itemBuilder: (context, index) {
                            return _PickupLineCard(text: responses[index]);
                          },
                        ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: chatProvider.isLoading
                    ? null
                    : () => chatProvider.generatePickupLines(
                          topic: _topicController.text.trim(),
                        ),
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupLineCard extends StatelessWidget {
  final String text;
  const _PickupLineCard({required this.text});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(text),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () => _copyToClipboard(context),
        ),
      ),
    );
  }
}
