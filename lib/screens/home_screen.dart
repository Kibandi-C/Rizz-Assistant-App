import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tone.dart';
import '../providers/chat_provider.dart';
import 'chat_builder_screen.dart';
import 'pickup_lines_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rizz Assistant'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(context, 'Choose Your Vibe'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: Tone.values.map((tone) {
                final isSelected = chatProvider.selectedTone == tone;
                return FilterChip(
                  label: Text(tone.label),
                  selected: isSelected,
                  onSelected: (_) => chatProvider.setSelectedTone(tone),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Risk Level: ${chatProvider.riskLevel.toInt()}'),
            Slider(
              value: chatProvider.riskLevel,
              min: 0,
              max: 100,
              divisions: 10,
              label: chatProvider.riskLevel.round().toString(),
              onChanged: (value) => chatProvider.setRiskLevel(value),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement OCR Upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screenshot upload coming soon!')),
                );
              },
              icon: const Icon(Icons.screenshot_monitor),
              label: const Text('Upload Chat Screenshot'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatBuilderScreen()),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Build Chat Manually'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PickupLinesScreen()),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Pickup Lines'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
