import 'package:flutter/material.dart';

class ViewstaIcon extends StatelessWidget {
  final ViewstaIconType type;
  final double size;
  final Color color;
  final double stroke;
  final bool filled;
  final Color? fillColor;

  const ViewstaIcon({
    super.key,
    required this.type,
    this.size = 30,
    this.color = Colors.black,
    this.stroke = 2.4,
    this.filled = false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ViewstaIconPainter(
        type: type,
        color: color,
        stroke: stroke,
        filled: filled,
        fillColor: fillColor,
      ),
    );
  }
}

enum ViewstaIconType {
  create,
  activity,
  chat,
  like,
  comment,
  share,
  save,
  home,
  search,
  reels,
  discover,
  profile,
}

class _ViewstaIconPainter extends CustomPainter {
  final ViewstaIconType type;
  final Color color;
  final double stroke;
  final bool filled;
  final Color? fillColor;

  _ViewstaIconPainter({
    required this.type,
    required this.color,
    required this.stroke,
    required this.filled,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = fillColor ?? color
      ..style = PaintingStyle.fill;

    switch (type) {
      case ViewstaIconType.create:
        _create(canvas, paint);
        break;

      case ViewstaIconType.activity:
        _heart(canvas, paint, fill);
        break;

      case ViewstaIconType.chat:
        _chat(canvas, paint);
        break;

      case ViewstaIconType.like:
        _heart(canvas, paint, fill);
        break;

      case ViewstaIconType.comment:
        _comment(canvas, paint);
        break;

      case ViewstaIconType.share:
        _share(canvas, paint);
        break;

      case ViewstaIconType.save:
        _save(canvas, paint, fill);
        break;

      case ViewstaIconType.home:
        _home(canvas, paint, fill);
        break;

      case ViewstaIconType.search:
        _search(canvas, paint);
        break;

      case ViewstaIconType.reels:
        _reels(canvas, paint);
        break;

      case ViewstaIconType.discover:
        _discover(canvas, paint);
        break;

      case ViewstaIconType.profile:
        _profile(canvas, paint);
        break;
    }

    canvas.restore();
  }

  void _create(Canvas canvas, Paint paint) {
    final r = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 5, 22, 22),
      const Radius.circular(5),
    );

    canvas.drawRRect(r, paint);
    canvas.drawLine(
      const Offset(16, 10),
      const Offset(16, 22),
      paint,
    );
    canvas.drawLine(
      const Offset(10, 16),
      const Offset(22, 16),
      paint,
    );
  }

  void _heart(Canvas canvas, Paint paint, Paint fill) {
    final path = Path();

    path.moveTo(16, 27);
    path.cubicTo(14.8, 25.8, 5, 20.0, 5, 12.3);
    path.cubicTo(5, 8.2, 7.8, 5.2, 11.3, 5.2);
    path.cubicTo(13.5, 5.2, 15.1, 6.5, 16, 8.2);
    path.cubicTo(16.9, 6.5, 18.5, 5.2, 20.7, 5.2);
    path.cubicTo(24.2, 5.2, 27, 8.2, 27, 12.3);
    path.cubicTo(27, 20.0, 17.2, 25.8, 16, 27);
    path.close();

    if (filled) {
      canvas.drawPath(path, fill);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _chat(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(6, 7);
    path.quadraticBezierTo(6, 5, 8, 5);
    path.lineTo(25, 5);
    path.quadraticBezierTo(27, 5, 27, 7);
    path.lineTo(27, 18);
    path.quadraticBezierTo(27, 20, 25, 20);
    path.lineTo(13, 20);
    path.lineTo(8, 25);
    path.lineTo(9, 20);
    path.lineTo(8, 20);
    path.quadraticBezierTo(6, 20, 6, 18);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _comment(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(5, 7);
    path.quadraticBezierTo(5, 5, 7, 5);
    path.lineTo(25, 5);
    path.quadraticBezierTo(27, 5, 27, 7);
    path.lineTo(27, 18);
    path.quadraticBezierTo(27, 20, 25, 20);
    path.lineTo(13, 20);
    path.lineTo(7, 25);
    path.lineTo(8, 20);
    path.quadraticBezierTo(5, 20, 5, 18);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _share(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(5, 15);
    path.lineTo(27, 5);
    path.lineTo(19, 27);
    path.lineTo(15, 17);
    path.close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      const Offset(15, 17),
      const Offset(27, 5),
      paint,
    );
  }

  void _save(Canvas canvas, Paint paint, Paint fill) {
    final path = Path();

    path.moveTo(8, 5);
    path.lineTo(24, 5);
    path.lineTo(24, 27);
    path.lineTo(16, 21);
    path.lineTo(8, 27);
    path.close();

    if (filled) {
      canvas.drawPath(path, fill);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _home(Canvas canvas, Paint paint, Paint fill) {
    final path = Path();

    path.moveTo(4, 14);
    path.lineTo(16, 4);
    path.lineTo(28, 14);
    path.lineTo(26, 14);
    path.lineTo(26, 27);
    path.lineTo(19, 27);
    path.lineTo(19, 19);
    path.lineTo(13, 19);
    path.lineTo(13, 27);
    path.lineTo(6, 27);
    path.lineTo(6, 14);
    path.close();

    if (filled) {
      canvas.drawPath(path, fill);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _search(Canvas canvas, Paint paint) {
    canvas.drawCircle(
      const Offset(14, 14),
      8,
      paint,
    );

    canvas.drawLine(
      const Offset(20, 20),
      const Offset(27, 27),
      paint,
    );
  }

  void _reels(Canvas canvas, Paint paint) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 7, 22, 20),
      const Radius.circular(5),
    );

    canvas.drawRRect(body, paint);

    canvas.drawLine(
      const Offset(6, 12),
      const Offset(26, 12),
      paint,
    );

    canvas.drawLine(
      const Offset(10, 7),
      const Offset(14, 12),
      paint,
    );

    canvas.drawLine(
      const Offset(17, 7),
      const Offset(21, 12),
      paint,
    );

    final play = Path();
    play.moveTo(14, 16);
    play.lineTo(14, 23);
    play.lineTo(21, 19.5);
    play.close();

    canvas.drawPath(play, paint);
  }

  void _discover(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(16, 3);
    path.lineTo(18.5, 13.5);
    path.lineTo(29, 16);
    path.lineTo(18.5, 18.5);
    path.lineTo(16, 29);
    path.lineTo(13.5, 18.5);
    path.lineTo(3, 16);
    path.lineTo(13.5, 13.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _profile(Canvas canvas, Paint paint) {
    canvas.drawCircle(
      const Offset(16, 9),
      5,
      paint,
    );

    final path = Path();
    path.moveTo(6, 27);
    path.cubicTo(6, 20, 10, 17, 16, 17);
    path.cubicTo(22, 17, 26, 20, 26, 27);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewstaIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.stroke != stroke ||
        oldDelegate.filled != filled ||
        oldDelegate.fillColor != fillColor;
  }
}
