import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../models/report.dart';
import '../../providers/language_provider.dart';
import '../../theme.dart';
import '../../widgets/location_picker.dart';
import '../../l10n/app_localizations.dart';

class ReportProblemScreen extends StatefulWidget {
  final String problemType;
  const ReportProblemScreen({super.key, required this.problemType});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;
  LatLng? _selectedLocation;
  String? _locationAddress;
  String _severity = 'Medium';

  // Voice recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _showSnack('Voice input not available', AppTheme.danger);
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final localeId = languageProvider.isArabic ? 'ar_EG' : 'en_US';

      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        },
        localeId: localeId,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder:
            (_) => LocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result.latLng;
        _locationAddress = result.address;
      });
    }
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      _showSnack(l10n.pleaseSelectLocation, AppTheme.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId') ?? '';
      final nationalId = prefs.getString('nationalId') ?? '';
      final name = prefs.getString('name') ?? '';

      // Save image to persistent storage first
      String imagePath = '';
      if (_imageFile != null) {
        print('=== SAVING IMAGE FOR REPORT ===');
        final savedPath = await DatabaseService.instance.uploadReportImage(_imageFile!);
        if (savedPath != null) {
          imagePath = savedPath;
          print('✓ Image saved to persistent storage: $imagePath');
        } else {
          print('❌ Failed to save image to persistent storage');
          if (mounted) {
            _showSnack('Failed to save image', AppTheme.warning);
          }
        }
      }

      final result = await DatabaseService.instance.createReport(
        Report(
          uid: uid,
          nationalId: nationalId,
          name: name,
          type: widget.problemType,
          description: _descriptionController.text,
          imagePath: imagePath,
          status: 'Pending',
          severity: _severity,
          createdAt: DateTime.now().toIso8601String(),
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationAddress: _locationAddress,
        ),
      );

      if (!mounted) return;

      if (result != null) {
        _showSnack(l10n.reportSubmittedSuccess, AppTheme.success);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(l10n.errorSubmittingReport, AppTheme.danger);
      }
    } catch (e) {
      print('❌ Error submitting report: $e');
      if (!mounted) return;
      _showSnack(l10n.errorSubmittingReport, AppTheme.danger);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color get _typeColor {
    switch (widget.problemType) {
      case 'Pothole':
        return AppTheme.primary; // Changed to dark blue
      case 'Broken Pipe':
        return AppTheme.primary; // Keep dark blue
      default:
        return AppTheme.primary; // Changed to dark blue for consistency
    }
  }

  IconData get _typeIcon {
    switch (widget.problemType) {
      case 'Pothole':
        return Icons.construction_rounded; // Better icon for pothole
      case 'Broken Pipe':
        return Icons.plumbing_rounded; // Better icon for broken pipe
      default:
        return Icons.report_gmailerrorred_rounded; // Better icon for other
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: _typeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logof.png',
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${l10n.report} ${widget.problemType}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(_typeIcon, color: _typeColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.problemType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _typeColor,
                          ),
                        ),
                        Text(
                          l10n.fillDetails,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photo picker
            _SectionLabel(label: l10n.photo, required: true),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageFile != null ? _typeColor : AppTheme.border,
                    width: _imageFile != null ? 2 : 1,
                  ),
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FutureBuilder<List<int>>(
                            future: _imageFile!.readAsBytes().then(
                              (b) => b.toList(),
                            ),
                            builder: (ctx, snap) {
                              if (!snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    Uint8List.fromList(snap.data!),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Change',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _typeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: _typeColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.tapToUpload,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _typeColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.jpgPngSupported,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Location picker
            _SectionLabel(label: l10n.location, required: true),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _openLocationPicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        _selectedLocation != null
                            ? AppTheme.success
                            : AppTheme.border,
                    width: _selectedLocation != null ? 2 : 1,
                  ),
                ),
                child:
                    _selectedLocation != null
                        ? _LocationPreview(
                          location: _selectedLocation!,
                          address: _locationAddress,
                          onClear:
                              () => setState(() {
                                _selectedLocation = null;
                                _locationAddress = null;
                              }),
                        )
                        : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_location_alt_outlined,
                                color: AppTheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.setLocationOnMap,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.tapToOpenMaps,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Description with voice input button
            _SectionLabel(label: l10n.description, required: true),
            const SizedBox(height: 10),
            Stack(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.describeTheProblem,
                    hintStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 60, 16),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return l10n.descriptionMinLength;
                    }
                    if (v.length < 10) return l10n.descriptionTooShort;
                    return null;
                  },
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              _isListening
                                  ? [
                                    const Color(0xFFEF4444),
                                    const Color(0xFFDC2626),
                                  ]
                                  : [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF4F46E5),
                                  ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF6366F1))
                                .withValues(alpha: 0.3),
                            blurRadius: _isListening ? 12 : 8,
                            spreadRadius: _isListening ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isListening
                  ? '🎤 Recording... Tap again to stop'
                  : 'Tap the microphone to use voice input',
              style: TextStyle(
                fontSize: 12,
                color: _isListening ? AppTheme.danger : AppTheme.textSecondary,
                fontWeight: _isListening ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),

            // Severity
            _SectionLabel(label: l10n.severity, required: true),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _severity,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              items: [
                DropdownMenuItem(value: 'Low', child: Text(l10n.low)),
                DropdownMenuItem(value: 'Medium', child: Text(l10n.medium)),
                DropdownMenuItem(value: 'High', child: Text(l10n.high)),
                DropdownMenuItem(value: 'Critical', child: Text(l10n.critical)),
              ],
              onChanged: (v) => setState(() => _severity = v ?? 'Medium'),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      _isLoading
                          ? null
                          : LinearGradient(
                            colors: [
                              _typeColor,
                              _typeColor.withValues(alpha: 0.75),
                            ],
                          ),
                  color: _isLoading ? AppTheme.border : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                l10n.submitReport,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppTheme.danger,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationPreview extends StatelessWidget {
  final LatLng location;
  final String? address;
  final VoidCallback onClear;
  const _LocationPreview({
    required this.location,
    this.address,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: AppTheme.success,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address != null && address!.isNotEmpty
                    ? address!
                    : 'Location selected',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppTheme.danger,
            ),
          ),
        ),
      ],
    );
  }
}
