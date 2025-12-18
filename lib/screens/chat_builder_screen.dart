import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'reply_screen.dart';

class ChatBuilderScreen extends StatefulWidget {
  const ChatBuilderScreen({super.key});

  @override
  State<ChatBuilderScreen> createState() => _ChatBuilderScreenState();
}

class _ChatBuilderScreenState extends State<ChatBuilderScreen> {
  final TextEditingController _messageController = TextEditingController();
  MessageSender _currentSender = MessageSender.them;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addMessage() {
    if (_messageController.text.trim().isEmpty) return;
    context.read<ChatProvider>().addManualMessage(
          _messageController.text.trim(),
          _currentSender,
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Chat'),
        actions: [
          IconButton(
            onPressed: () => chatProvider.clearMessages(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Dismissible(
                  key: Key('msg_\$index'),
                  onDismissed: (_) => chatProvider.removeMessage(index),
                  background: Container(color: Colors.red.withOpacity(0.2)),
                  child: _ManualChatBubble(message: msg),
                );
              },
            ),
          ),
          _buildInputArea(chatProvider),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: chatProvider.messages.isEmpty
                ? null
                : () async {
                    await chatProvider.generateReplies();
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReplyScreen()),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: chatProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Generate Replies'),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Sender: '),
              ChoiceChip(
                label: const Text('Them'),
                selected: _currentSender == MessageSender.them,
                onSelected: (s) => setState(() => _currentSender = MessageSender.them),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Me'),
                selected: _currentSender == MessageSender.me,
                onSelected: (s) => setState(() => _currentSender = MessageSender.me),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addMessage,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ManualChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == MessageSender.me;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
