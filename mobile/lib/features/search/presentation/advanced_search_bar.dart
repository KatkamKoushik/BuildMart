import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSearchBar extends StatefulWidget {
  const AdvancedSearchBar({super.key});

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  List<String> _suggestions = [];
  static const String _recentSearchesKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suggestions = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveSearchTerm(String term) async {
    if (term.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_recentSearchesKey) ?? [];

    // Remove if exists to move to top
    searches.removeWhere((s) => s.toLowerCase() == term.toLowerCase());

    // Add to top
    searches.insert(0, term.trim());

    // Keep only last 10
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await prefs.setStringList(_recentSearchesKey, searches);
    if (mounted) {
      setState(() {
        _suggestions = searches;
      });
    }
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _searchController.text = result.recognizedWords;
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      _showAIAnalysisOverlay(image.name);
    }
  }

  void _showAIAnalysisOverlay(String imageName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.aiVisionSearchTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.aiVisionAnalyzing(imageName)),
          ],
        ),
      ),
    );

    // Simulate AI delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        context.push('/products?q=Scanned Product');
      }
    });
  }

  void _openBarcodeScanner() {
    context.push('/barcode-scanner');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _suggestions.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        _searchController.text = selection;
                        _saveSearchTerm(selection);
                        context.push('/products?q=$selection');
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        // Sync controller
                        if (_searchController.text != controller.text) {
                          controller.text = _searchController.text;
                        }
                        controller.addListener(() {
                          _searchController.text = controller.text;
                        });

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchHint,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _saveSearchTerm(value);
                              context.push('/products?q=$value');
                            }
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200,
                                maxWidth: MediaQuery.of(context).size.width -
                                    32 -
                                    100, // Approximate width
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.history,
                                              size: 16,
                                              color: AppColors.textLight),
                                          const SizedBox(width: 8),
                                          Text(option),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner,
                        color: AppColors.textLight),
                    onPressed: _openBarcodeScanner,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.textLight),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening
                            ? AppColors.primary
                            : AppColors.textLight),
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
