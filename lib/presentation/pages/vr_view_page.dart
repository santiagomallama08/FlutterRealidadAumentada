// lib/presentation/pages/vr_view_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;

class VRViewPage extends StatefulWidget {
  final Uint8List imageBytes;

  const VRViewPage({super.key, required this.imageBytes});

  @override
  State<VRViewPage> createState() => _VRViewPageState();
}

class _VRViewPageState extends State<VRViewPage> {
  // Control de transformación
  final TransformationController _controller = TransformationController();
  
  // Sensor de orientación
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Posición actual basada en sensores
  double _offsetX = 0;
  double _offsetY = 0;
  double _currentScale = 1.0;
  
  // Sensibilidad del giroscopio
  final double _sensitivity = 5.0;
  
  // Modo VR activo
  bool _vrMode = false;
  
  @override
  void initState() {
    super.initState();
    _startGyroscope();
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startGyroscope() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (!_vrMode || !mounted) return;
      
      setState(() {
        // Mover imagen según rotación del teléfono
        _offsetX -= event.y * _sensitivity;
        _offsetY += event.x * _sensitivity;
        
        // Limitar movimiento
        _offsetX = _offsetX.clamp(-200.0, 200.0);
        _offsetY = _offsetY.clamp(-200.0, 200.0);
        
        // Aplicar transformación
        _controller.value = Matrix4.identity()
          ..translate(_offsetX, _offsetY)
          ..scale(_currentScale);
      });
    });
  }

  void _toggleVRMode() {
    setState(() {
      _vrMode = !_vrMode;
      if (!_vrMode) {
        // Resetear posición al salir del modo VR
        _offsetX = 0;
        _offsetY = 0;
        _controller.value = Matrix4.identity()..scale(_currentScale);
      }
    });
  }

  void _resetView() {
    setState(() {
      _offsetX = 0;
      _offsetY = 0;
      _currentScale = 1.0;
      _controller.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale * 1.2).clamp(0.5, 4.0);
      _controller.value = Matrix4.identity()
        ..translate(_offsetX, _offsetY)
        ..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale * 0.8).clamp(0.5, 4.0);
      _controller.value = Matrix4.identity()
        ..translate(_offsetX, _offsetY)
        ..scale(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_vrMode ? "Modo VR Activo 📱" : "Vista Previa"),
        backgroundColor: _vrMode ? Colors.deepPurple : Colors.blueAccent,
        actions: [
          // Indicador de zoom
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${(_currentScale * 100).toInt()}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Botón reset
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetView,
            tooltip: 'Resetear vista',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visor interactivo
          InteractiveViewer(
            transformationController: _controller,
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(50),
            panEnabled: !_vrMode, // Deshabilitar pan manual en modo VR
            scaleEnabled: true,
            onInteractionUpdate: (details) {
              if (!_vrMode) {
                setState(() {
                  _currentScale = _controller.value.getMaxScaleOnAxis();
                });
              }
            },
            child: Center(
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // Instrucciones
          if (!_vrMode)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _InstructionsCard(vrMode: _vrMode),
            ),

          // Indicador modo VR
          if (_vrMode)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_android, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mueve tu teléfono 📱',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón VR Mode
          FloatingActionButton.extended(
            heroTag: 'vr_mode',
            onPressed: _toggleVRMode,
            backgroundColor: _vrMode ? Colors.deepPurple : Colors.blueAccent,
            icon: Icon(_vrMode ? Icons.phonelink_off : Icons.phonelink),
            label: Text(_vrMode ? 'Desactivar VR' : 'Modo VR'),
          ),
          const SizedBox(height: 12),
          // Botón zoom in
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          // Botón zoom out
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}

/// Widget de instrucciones
class _InstructionsCard extends StatefulWidget {
  final bool vrMode;

  const _InstructionsCard({required this.vrMode});

  @override
  State<_InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends State<_InstructionsCard> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // Ocultar después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InstructionRow(
              icon: Icons.touch_app,
              text: 'Pellizca para hacer zoom',
            ),
            const SizedBox(height: 10),
            _InstructionRow(
              icon: Icons.pan_tool,
              text: 'Arrastra para mover',
            ),
            const SizedBox(height: 10),
            _InstructionRow(
              icon: Icons.phonelink,
              text: 'Activa Modo VR para usar sensores',
              color: Colors.deepPurpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InstructionRow({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}