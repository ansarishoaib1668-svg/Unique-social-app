import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ViewRealmScreen extends StatefulWidget {
  final String? videoPath;
  final String? realmId;

  const ViewRealmScreen({super.key, this.videoPath, this.realmId});

  @override
  State<ViewRealmScreen> createState() => _ViewRealmScreenState();
}

class _ViewRealmScreenState extends State<ViewRealmScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late final AnimationController _trailController;
  bool _isReady = false;
  bool _muted = false;
  String _selectedPulse = 'VIEW';
  bool _savingPulse = false;

  final Map<String, int> _pulseReactions = {
    'ENERGY': 0,
    'INSIGHT': 0,
    'FUN': 0,
    'VIBE': 0,
    'CREATIVE': 0,
  };

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _pulseCountsSubscription;

  Future<void> _loadSavedPulse() async {
    final realmId = widget.realmId;
    final user = FirebaseAuth.instance.currentUser;

    if (realmId == null || realmId.isEmpty || user == null) {
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('realms')
          .doc(realmId)
          .collection('pulse_reactions')
          .doc(user.uid)
          .get();

      if (!mounted || !snap.exists) return;

      final data = snap.data();
      final pulse = data?['pulse'];

      if (pulse is String &&
          pulse.isNotEmpty &&
          _pulseReactions.containsKey(pulse)) {
        setState(() {
          _selectedPulse = pulse;
          _pulseReactions[pulse] = 1;
        });
      }
    } catch (_) {
      // Keep the local View Realm usable if loading fails.
    }
  }

  @override
  void initState() {
    super.initState();

    _trailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _loadSavedPulse();
    _loadPulseCounts();
    _listenToPulseCounts();

    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      final path = widget.videoPath!;

      _controller = path.startsWith('http://') || path.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));

      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller!.setLooping(true);
        _controller!.play();
      });
    }
  }

  @override
  void dispose() {
    _pulseCountsSubscription?.cancel();
    _trailController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_isReady) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      _muted = !_muted;
      controller.setVolume(_muted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: _isReady && _controller != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white70,
                      size: 72,
                    ),
                  ),
          ),

          // Top navigation.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _glassButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✦ VIEW REALM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _viewTrail(),
                    ],
                  ),
                  const Spacer(),
                  _glassButton(
                    icon: _muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    onTap: _toggleMute,
                  ),
                ],
              ),
            ),
          ),

          // View Orbit.
          Positioned(
            right: 18,
            top: MediaQuery.of(context).size.height * 0.34,
            child: _orbit(),
          ),

          // Bottom View identity.
          Positioned(left: 18, right: 18, bottom: 28, child: _bottomView()),
        ],
      ),
    );
  }

  Widget _trailDot(double opacity) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        boxShadow: opacity > 0.8
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 7,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _viewTrail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedPulse == 'VIEW'
                ? "VIEW TRAIL"
                : "VIEW TRAIL • $_selectedPulse",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 7),
          AnimatedBuilder(
            animation: _trailController,
            builder: (context, child) {
              final pulseIndex = <String>[
                'ENERGY',
                'INSIGHT',
                'FUN',
                'VIBE',
                'CREATIVE',
              ].indexOf(_selectedPulse);

              final activeIndex = pulseIndex < 0 ? 0 : pulseIndex % 3;
              final glow = 0.35 + (_trailController.value * 0.65);

              return Row(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                    child: _trailDot(
                      index == activeIndex
                          ? glow
                          : (index == (activeIndex + 1) % 3 ? 0.35 : 0.22),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  Widget _orbit() {
    final pulses = [
      ('🔥', 'ENERGY'),
      ('💡', 'INSIGHT'),
      ('😂', 'FUN'),
      ('🌙', 'VIBE'),
      ('🎨', 'CREATIVE'),
    ];

    return Container(
      width: 142,
      height: 142,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _selectedPulse == 'VIEW' ? 48 : 62,
            height: _selectedPulse == 'VIEW' ? 48 : 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Center(
              child: Text(
                _selectedPulse == 'VIEW' ? '◉' : _selectedPulse,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Positioned(
            top: 5,
            child: _pulseButton(emoji: pulses[0].$1, label: pulses[0].$2),
          ),
          Positioned(
            left: 5,
            child: _pulseButton(emoji: pulses[1].$1, label: pulses[1].$2),
          ),
          Positioned(
            right: 5,
            child: _pulseButton(emoji: pulses[2].$1, label: pulses[2].$2),
          ),
          Positioned(
            bottom: 5,
            left: 25,
            child: _pulseButton(emoji: pulses[3].$1, label: pulses[3].$2),
          ),
          Positioned(
            bottom: 5,
            right: 25,
            child: _pulseButton(emoji: pulses[4].$1, label: pulses[4].$2),
          ),
        ],
      ),
    );
  }

  Future<void> _savePulseReaction({
    required String? previousPulse,
    required String? newPulse,
  }) async {
    final realmId = widget.realmId;
    final user = FirebaseAuth.instance.currentUser;

    if (realmId == null || realmId.isEmpty || user == null || _savingPulse) {
      return;
    }

    setState(() => _savingPulse = true);

    try {
      final db = FirebaseFirestore.instance;

      final reactionRef = db
          .collection('realms')
          .doc(realmId)
          .collection('pulse_reactions')
          .doc(user.uid);

      final countRef = db
          .collection('realms')
          .doc(realmId)
          .collection('pulse_counts')
          .doc('totals');

      await db.runTransaction((transaction) async {
        final countSnap = await transaction.get(countRef);
        final data = countSnap.data() ?? <String, dynamic>{};

        int currentCount(String pulse) {
          final value = data[pulse];
          return value is num ? value.toInt() : 0;
        }

        void updateCount(String pulse, int change) {
          final next = (currentCount(pulse) + change).clamp(0, 999999);

          transaction.set(countRef, {
            pulse: next,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        if (previousPulse != null &&
            previousPulse.isNotEmpty &&
            previousPulse != newPulse) {
          updateCount(previousPulse, -1);
        }

        if (newPulse != null && newPulse.isNotEmpty) {
          updateCount(newPulse, 1);

          transaction.set(reactionRef, {
            'pulse': newPulse,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          transaction.delete(reactionRef);
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pulse save nahi ho paya.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingPulse = false);
      }
    }
  }

  void _listenToPulseCounts() {
    final realmId = widget.realmId;

    if (realmId == null || realmId.isEmpty) {
      return;
    }

    _pulseCountsSubscription = FirebaseFirestore.instance
        .collection('realms')
        .doc(realmId)
        .collection('pulse_counts')
        .doc('totals')
        .snapshots()
        .listen((snap) {
          if (!mounted || !snap.exists) return;

          final data = snap.data();
          if (data == null) return;

          setState(() {
            for (final label in _pulseReactions.keys) {
              final value = data[label];

              if (value is num) {
                _pulseReactions[label] = value.toInt().clamp(0, 999999);
              }
            }
          });
        });
  }

  Future<void> _loadPulseCounts() async {
    final realmId = widget.realmId;

    if (realmId == null || realmId.isEmpty) {
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('realms')
          .doc(realmId)
          .collection('pulse_counts')
          .doc('totals')
          .get();

      if (!mounted || !snap.exists) return;

      final data = snap.data();
      if (data == null) return;

      setState(() {
        for (final label in _pulseReactions.keys) {
          final value = data[label];

          if (value is num) {
            _pulseReactions[label] = value.toInt().clamp(0, 999999);
          }
        }
      });
    } catch (_) {
      // Keep local counts if Firestore loading fails.
    }
  }

  Widget _pulseButton({required String emoji, required String label}) {
    final selected = _selectedPulse == label;

    return GestureDetector(
      onTap: () async {
        if (_savingPulse) return;

        final previous = _selectedPulse == 'VIEW' ? null : _selectedPulse;

        final next = selected ? null : label;

        setState(() {
          if (previous != null && _pulseReactions.containsKey(previous)) {
            _pulseReactions[previous] = (_pulseReactions[previous] ?? 0) - 1;
          }

          if (next != null) {
            _pulseReactions[next] = (_pulseReactions[next] ?? 0) + 1;
            _selectedPulse = next;
          } else {
            _selectedPulse = 'VIEW';
          }
        });

        await _savePulseReaction(previousPulse: previous, newPulse: next);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.30),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.16),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.18),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 17)),
            if ((_pulseReactions[label] ?? 0) > 0)
              Text(
                '${_pulseReactions[label]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _viewEcho() {
    final entries = [
      ("🔥", "ENERGY", _pulseReactions["ENERGY"] ?? 0),
      ("🌙", "VIBE", _pulseReactions["VIBE"] ?? 0),
      ("😂", "FUN", _pulseReactions["FUN"] ?? 0),
      ("💡", "INSIGHT", _pulseReactions["INSIGHT"] ?? 0),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "✦ VIEW ECHO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedPulse == "VIEW"
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedPulse == "VIEW" ? "LIVE" : "$_selectedPulse • LIVE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Text(entry.$1, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 7),
                  SizedBox(
                    width: 58,
                    child: Text(
                      entry.$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: (entry.$3 / 100).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  SizedBox(
                    width: 30,
                    child: Text(
                      "${entry.$3}%",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '@view_creator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '✦ Your View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A moment worth seeing.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 13,
          ),
        ),
        _viewEcho(),
        const SizedBox(height: 14),
        Row(
          children: [
            _stat('🔥', 'Energy 42%'),
            const SizedBox(width: 10),
            _stat('🌙', 'Vibe 27%'),
            const SizedBox(width: 10),
            _stat('😂', 'Fun 18%'),
          ],
        ),
      ],
    );
  }

  Widget _stat(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
