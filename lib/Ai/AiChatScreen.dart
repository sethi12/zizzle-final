import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zizzle/Ai/AiService.dart';

class ZizzleAIChatScreen extends StatefulWidget {
  const ZizzleAIChatScreen({super.key});

  @override
  State<ZizzleAIChatScreen> createState() => _ZizzleAIChatScreenState();
}

class _ZizzleAIChatScreenState extends State<ZizzleAIChatScreen>
    with TickerProviderStateMixin {
  final ZizzleAIService _aiService = ZizzleAIService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  late AnimationController _gradientController;
  final Map<String, String> zizzleFeatureResponses = {
    // Monetization & Earnings
    "earn":
        "💰 You earn by posting reels! Every 1,000 views = 1 CAD. Once you cross 500 followers, your account gets a Monetization Tick ✅ and starts earning.",
    "monetize":
        "📈 To monetize, you need at least 500 followers. After that, you’ll earn 1 CAD for every 1,000 reel views.",
    "money":
        "💵 Posting reels = earnings! With 500+ followers, every 1,000 views gives you 1 CAD.",
    "income":
        "📊 Earn through reels! 500 followers unlock Monetization, then 1 CAD for each 1,000 views.",

    // Boosting
    "boost":
        "🚀 You can boost your reels or posts in 2 ways: \n• Free boost for 15 mins (watching an ad) \n• Paid boost starting at ₹19/day, ₹99/week, ₹249/month.",
    "promote":
        "📢 Want more reach? Use Boost: Free (watch an ad for 15 mins) or Paid (₹19/day, ₹99/week, ₹249/month).",
    "increase views":
        "👀 To increase views, boost your post/reel! Free boost via ad or paid plans for longer duration.",

    // Verification
    "blue tick":
        "✅ You can buy a Blue Tick for ₹199/month. It helps your profile stand out and builds trust with your followers.",
    "verify":
        "🔹 Verified badge (Blue Tick) is available for ₹199/month to make your profile stand out.",
    "verification": "🔹 Want to look official? Buy a Blue Tick for ₹199/month.",

    // Privacy & Security
    "lock chat":
        "🔒 Lock Chat keeps your private conversations secure with PIN or biometric protection.",
    "chat lock":
        "🔐 Secure your chats with a PIN or biometrics using Lock Chat.",
    "secure chat": "🛡️ Use Lock Chat to keep conversations private and safe.",

    // Customization
    "customize":
        "🎨 You can customize your loading bar and other app elements in Settings → Customization.",
    "theme":
        "🌈 Personalize your Zizzle experience with customizable themes and loading bars.",
    "loading bar":
        "⚡ Go to Settings → Customization to style your loading bar!",

    // AI Features
    "ai":
        "🤖 Zizzle AI helps you with smart captions, chat assistance, and even image generation for your posts.",
    "caption":
        "📝 Stuck on captions? Ask Zizzle AI for creative and trending caption suggestions!",
    "image generation":
        "🎨 Use Zizzle AI to generate unique images for your content.",
    "assistant":
        "💡 Zizzle AI is your assistant for chats, captions, content ideas, and images.",

    // Voice Assistant (Coming Soon)
    "hey zizzle":
        "🎤 Coming Soon: Hey Zizzle – your built-in voice assistant! You’ll soon be able to say things like 'Upload post' or 'Boost my reel' and I’ll do it instantly for you.",
    "voice":
        "🎙️ Voice commands are Coming Soon! Soon you’ll control Zizzle hands-free by saying 'Hey Zizzle'.",
    "siri": "📱 Think of Hey Zizzle as Siri but inside Zizzle – Coming Soon!",

    // Posting
    "upload":
        "📤 You can upload posts (images/videos) from the Add Post screen. Voice commands will make this even faster soon!",
    "post":
        "📸 Share posts with your audience directly from the Add Post screen.",
    "reel":
        "🎥 Create and upload reels to grow faster. More reels = more reach + more earnings!",

    // Ads & Plans
    "plans":
        "💳 We offer boosts & verification plans: \n• Boost: ₹19/day, ₹99/week, ₹249/month \n• verified badge: ₹199/month",
    "subscription":
        "🛒 You can subscribe to boosts or Blue Tick inside Zizzle under Plans & Payments.",
    "ads":
        "📺 Watch a rewarded ad to boost your reel/post for free (15 minutes).",

    // General Info
    "name": "🤖 I am Zizzle AI, your smart social assistant here to guide you!",
    "help":
        "🙋 Ask me about anything – earnings, boosts, reels, blue tick, lock chat, or Hey Zizzle!",
    "features":
        "✨ Zizzle offers Monetization, Boosts, Blue Tick, AI assistance, Lock Chat, Customization, and more.",
  };

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _loading = true;
    });
    _controller.clear();

    final lower = userText.toLowerCase();

    // ✅ First check Zizzle predefined responses
    for (final key in zizzleFeatureResponses.keys) {
      if (lower.contains(key)) {
        setState(() {
          _messages.add({
            "role": "zizzle_ai",
            "text": zizzleFeatureResponses[key]!,
          });
          _loading = false;
        });
        return;
      }
    }

    // Existing hard-coded case
    if (lower.contains("are you zizzle ai") ||
        lower.contains("who are you") ||
        lower.contains("your name")) {
      setState(() {
        _messages.add({
          "role": "zizzle_ai",
          "text": "I am Zizzle AI, your smart assistant 🤖"
        });
        _loading = false;
      });
      return;
    }

    // Else fallback to AI
    try {
      final reply = await _aiService.chatWithAI(userText);
      setState(() {
        _messages.add({"role": "zizzle_ai", "text": reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "zizzle_ai",
          "text": "⚠️ Error: $e",
        });
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // Future<void> _sendMessage() async {
  //   if (_controller.text.isEmpty) return;

  //   final userText = _controller.text.trim();
  //   setState(() {
  //     _messages.add({"role": "user", "text": userText});
  //     _loading = true;
  //   });
  //   _controller.clear();

  //   final lower = userText.toLowerCase();
  //   if (lower.contains("are you zizzle ai") ||
  //       lower.contains("who are you") ||
  //       lower.contains("your name")) {
  //     setState(() {
  //       _messages.add({
  //         "role": "zizzle_ai",
  //         "text": "I am Zizzle AI, your smart assistant 🤖"
  //       });
  //       _loading = false;
  //     });
  //     return;
  //   }

  //   try {
  //     final reply = await _aiService.chatWithAI(userText);
  //     setState(() {
  //       _messages.add({"role": "zizzle_ai", "text": reply});
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _messages.add({
  //         "role": "zizzle_ai",
  //         "text": "⚠️ Error: $e",
  //       });
  //     });
  //   } finally {
  //     setState(() => _loading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _gradientController, curve: Curves.linear));

    return Scaffold(
      body: AnimatedBuilder(
        animation: gradientAnimation,
        builder: (context, child) {
          final colors = [
            Color.lerp(Colors.deepPurple.shade900, Colors.blue.shade900,
                gradientAnimation.value)!,
            Color.lerp(Colors.pink.shade900, Colors.teal.shade900,
                gradientAnimation.value)!,
          ];
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            AppBar(
              title: const Text(
                "Zizzle AI 🤖",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                reverse: true, // This makes the ListView start from the bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _messages.length - 1 - index;
                  final msg = _messages[reversedIndex];
                  final isUser = msg["role"] == "user";
                  final sender = isUser ? "You" : "Zizzle AI";

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            sender,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.transparent
                                      : Colors.white.withOpacity(0.15),
                                  gradient: isUser
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF42A5F5),
                                            Color(0xFF1976D2)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isUser
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg["text"] ?? "",
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _LoadingIndicator(),
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 15.0),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int dotCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Zizzle AI is generating your response...",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(dotCount, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final value =
                            (_controller.value + index / dotCount) % 1.0;
                        final scale = 1.0 - (value * 0.5);
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: 1.0 - value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
