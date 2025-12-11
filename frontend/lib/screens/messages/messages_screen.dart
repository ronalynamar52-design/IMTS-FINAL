import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:imts_frontend/providers/message_provider.dart';
import 'package:imts_frontend/providers/auth_provider.dart';
import 'package:imts_frontend/widgets/custom_text_field.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageController = TextEditingController();
  late IO.Socket _socket;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _loadMessages();
  }

  void _connectSocket() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _socket = IO.io(
      'http://localhost:5000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'token': authProvider.token})
        .build(),
    );

    _socket.onConnect((_) {
      debugPrint('Connected to WebSocket');
      _socket.emit('join-room', authProvider.user?.id);
    });

    _socket.on('new-message', (data) {
      final provider = Provider.of<MessageProvider>(context, listen: false);
      provider.addMessage(data);
    });

    _socket.onDisconnect((_) => debugPrint('Disconnected'));
  }

  Future<void> _loadMessages() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);
    await provider.loadConversations();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedUserId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final message = {
      'senderId': authProvider.user?.id,
      'receiverId': _selectedUserId,
      'content': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket.emit('send-message', message);
    _messageController.clear();
  }

  @override
  void dispose() {
    _socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildConversationsList() {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        final conversations = provider.conversations;
        
        return Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.message),
                    const SizedBox(width: 8),
                    const Text(
                      'Conversations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadMessages,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final isSelected = conversation['userId'] == _selectedUserId;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(conversation['name'][0]),
                      ),
                      title: Text(conversation['name']),
                      subtitle: Text(
                        conversation['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: conversation['unread'] > 0
                          ? Badge(
                              label: Text(conversation['unread'].toString()),
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedUserId = conversation['userId'];
                        });
                        provider.loadMessages(conversation['userId']);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatArea() {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        final messages = provider.messages;
        final authProvider = Provider.of<AuthProvider>(context);
        final currentUserId = authProvider.user?.id;

        if (_selectedUserId == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Select a conversation to start chatting',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Chat Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        provider.selectedUser?['name'][0] ?? 'U',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedUser?['name'] ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            provider.selectedUser?['role'] ?? '',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        // Show user info
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final isSent = message['senderId'] == currentUserId;
                  
                  return Align(
                    alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Card(
                        color: isSent
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message['content']),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message['timestamp']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Message Input
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        // Attach file
                      },
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: _messageController,
                        labelText: 'Type a message...',
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.pushNamed(context, '/new-conversation');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Conversations List
          SizedBox(
            width: 300,
            child: _buildConversationsList(),
          ),
          
          // Chat Area
          Expanded(
            child: _buildChatArea(),
          ),
        ],
      ),
    );
  }
}
