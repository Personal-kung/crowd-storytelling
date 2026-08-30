import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:country_picker/country_picker.dart';
import 'package:uuid/uuid.dart';

// firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'services/localization_service.dart';
import 'services/story_service.dart';
import 'models/story_cover_image.dart';

import 'widgets/notebook_header.dart';
import 'widgets/story_section.dart';
import 'widgets/identity_section.dart';
import 'widgets/notebook_submit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalizationService().init();
  runApp(const GlobalNotebookApp());
}

class GlobalNotebookApp extends StatelessWidget {
  const GlobalNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: LocalizationService().t('app.title'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF9F6), // Warm editorial off-white
        fontFamily: 'Georgia', // Using a default serif font for editorial feel
      ),
      home: const SubmissionPlatform(),
    );
  }
}

enum BlockType { text, image, drawing }

class StoryBlock {
  final String id;
  BlockType type;
  String content;
  Uint8List? bytes;
  String? storageUrl;
  TextEditingController? textController;

  StoryBlock({
    required this.id,
    required this.type,
    this.content = '',
    this.bytes,
    this.storageUrl,
  }) {
    if (type == BlockType.text) {
      textController = TextEditingController(text: content);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'content': type == BlockType.text ? textController?.text ?? '' : content,
      'storageUrl': storageUrl,
    };
  }
}

class SubmissionPlatform extends StatefulWidget {
  const SubmissionPlatform({super.key});

  @override
  State<SubmissionPlatform> createState() => _SubmissionPlatformState();
}

class _SubmissionPlatformState extends State<SubmissionPlatform> {
  // Required Identifiers to preserve compatibility
  final TextEditingController _storyController = TextEditingController(); 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _selectedCountryController = TextEditingController();
  XFile? _pickedImage;

  String _countryISOCode = '';
  
  // Sections
  final List<StoryBlock> _sayingBlocks = [];
  final List<StoryBlock> _storyBlocks = [];
  final List<StoryBlock> _anythingBlocks = [];

  String? _draftId;
  Timer? _autosaveTimer;
  bool _isSaving = false;
  bool _submitted = false;
  bool _isLoadingDraft = true;

  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _parseInvitationAndLoadDraft();
    
    // Autosave triggers
    _nameController.addListener(_onFieldChanged);
    _selectedCountryController.addListener(_onFieldChanged);
    _storyController.addListener(_onFieldChanged);
  }

  void _parseInvitationAndLoadDraft() async {
    String? token;
    try {
      token = Uri.base.queryParameters['invitation'];
    } catch (e) {
      debugPrint("Not running on web or URI parsing failed");
    }
    
    if (token == null || token.isEmpty) {
      token = 'default-invite-v1'; // Fallback for local testing
    }
    
    
    try {
      var qs = await FirebaseFirestore.instance
          .collection('stories')
          .where('invitationToken', isEqualTo: token)
          .limit(1)
          .get();
          
      if (qs.docs.isNotEmpty) {
        var doc = qs.docs.first;
        _draftId = doc.id;
        var data = doc.data();
        
        if (data['status'] == 'pending') {
           _submitted = true;
        }

        _nameController.text = data['name'] ?? '';
        _selectedCountryController.text = data['country'] ?? '';
        _countryISOCode = data['countryISOCode'] ?? '';
        
        // Note: For V1, we could deserialize existing blocks from data['sections'] 
        // if they exist. Leaving it out for simplicity of the initial flow,
        // but text_content is preserved.
      } else {
        var ref = await FirebaseFirestore.instance.collection('stories').add({
          'invitationToken': token,
          'status': 'draft',
          'timestamp': FieldValue.serverTimestamp(),
        });
        _draftId = ref.id;
      }
    } catch (e) {
      debugPrint("Error loading draft: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingDraft = false;
      });
    }
  }

  void _onFieldChanged() {
    if (_autosaveTimer?.isActive ?? false) _autosaveTimer!.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (_draftId == null || _submitted) return;
    setState(() => _isSaving = true);
    
    try {
      await FirebaseFirestore.instance.collection('stories').doc(_draftId).update({
        'name': _nameController.text,
        'country': _selectedCountryController.text,
        'countryISOCode': _countryISOCode,
        'lastUpdated': FieldValue.serverTimestamp(),
        // Real block synchronization would happen here for a full persistence model
      });
    } catch (e) {
      debugPrint("Autosave error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _submitStory() async {
    if (_draftId == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<String> uploadedPages = []; 
      String allText = _storyController.text; // fallback compatibility
      
      Future<List<Map<String,dynamic>>> processBlocks(List<StoryBlock> blocks) async {
        List<Map<String,dynamic>> res = [];
        for (var b in blocks) {
          if (b.type == BlockType.text) {
            String txt = b.textController?.text ?? '';
            if (txt.isNotEmpty) {
              allText += "\n\n$txt";
            }
            res.add(b.toMap());
          } else if (b.bytes != null) {
            try {
              final ref = FirebaseStorage.instance.ref().child('stories/$_draftId/${b.id}.jpg');
              await ref.putData(b.bytes!);
              final url = await ref.getDownloadURL();
              b.storageUrl = url;
              uploadedPages.add(url);
              res.add(b.toMap());
            } catch (e) {
              debugPrint("Upload error for block ${b.id}: $e");
            }
          }
        }
        return res;
      }
      
      var sayingData = await processBlocks(_sayingBlocks);
      var storyData = await processBlocks(_storyBlocks);
      var anythingData = await processBlocks(_anythingBlocks);
      
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        final ref = FirebaseStorage.instance.ref().child('stories/$_draftId/picked_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putData(bytes);
        final url = await ref.getDownloadURL();
        uploadedPages.add(url);
      }

      await FirebaseFirestore.instance.collection('stories').doc(_draftId).update({
        'name': _nameController.text,
        'country': _selectedCountryController.text.isNotEmpty ? _selectedCountryController.text : LocalizationService().t('fallback.country'),
        'countryISOCode': _countryISOCode,
        'contact': _contactController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': uploadedPages.isNotEmpty ? 'photo' : 'text',
        'pages': uploadedPages,
        'text_content': allText.trim(),
        'status': 'pending',
        'sections': {
          'saying': sayingData,
          'story': storyData,
          'anything': anythingData,
        }
      });

      setState(() {
        _submitted = true;
      });
      
    } catch (e) {
      debugPrint("Submit Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LocalizationService().t('submission.error'))));
      }
    } finally {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }


  void _addTextBlock(List<StoryBlock> list) {
    setState(() {
      var block = StoryBlock(id: _uuid.v4(), type: BlockType.text);
      block.textController?.addListener(_onFieldChanged);
      list.add(block);
    });
  }

  Future<void> _addPhotoBlock(List<StoryBlock> list) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        list.add(StoryBlock(id: _uuid.v4(), type: BlockType.image, bytes: bytes));
      });
      _onFieldChanged();
    }
  }

  Future<void> _addDrawBlock(List<StoryBlock> list) async {
    final SignatureController sigController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService().t("dialog.handwrite.title")),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Signature(
                    controller: sigController,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => sigController.clear(),
                    child: Text(LocalizationService().t("actions.clear")),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (sigController.isNotEmpty) {
                        final bytes = await sigController.toPngBytes();
                        if (bytes != null) {
                          setState(() {
                            list.add(StoryBlock(id: _uuid.v4(), type: BlockType.drawing, bytes: bytes));
                          });
                          _onFieldChanged();
                        }
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(LocalizationService().t("actions.save")),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDraft) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    if (_submitted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 48),
              const SizedBox(height: 24),
              Text(
                LocalizationService().t("submission.thankYou"),
                style: const TextStyle(fontSize: 24, fontFamily: 'Georgia'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680), // Optimal reading width
          child: CustomScrollView(
            slivers: [
              // Use a SliverAppBar or just a normal box inside sliver list for the status
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 24.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      _isSaving ? LocalizationService().t("status.saving") : LocalizationService().t("status.saved"),
                      style: const TextStyle(color: Colors.black38, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const NotebookHeader(),
                  StorySection(
                    chapterNumber: "01",
                    title: LocalizationService().t("sections.saying") ?? "Saying",
                    blocks: _sayingBlocks,
                    onAddText: () => _addTextBlock(_sayingBlocks),
                    onAddPhoto: () => _addPhotoBlock(_sayingBlocks),
                    onAddDraw: () => _addDrawBlock(_sayingBlocks),
                    onRemoveBlock: (b) {
                      setState(() => _sayingBlocks.remove(b));
                      _onFieldChanged();
                    },
                    onChanged: _onFieldChanged,
                  ),
                  StorySection(
                    chapterNumber: "02",
                    title: LocalizationService().t("sections.story") ?? "Story",
                    blocks: _storyBlocks,
                    onAddText: () => _addTextBlock(_storyBlocks),
                    onAddPhoto: () => _addPhotoBlock(_storyBlocks),
                    onAddDraw: () => _addDrawBlock(_storyBlocks),
                    onRemoveBlock: (b) {
                      setState(() => _storyBlocks.remove(b));
                      _onFieldChanged();
                    },
                    onChanged: _onFieldChanged,
                  ),
                  StorySection(
                    chapterNumber: "03",
                    title: LocalizationService().t("sections.anything") ?? "Anything",
                    blocks: _anythingBlocks,
                    onAddText: () => _addTextBlock(_anythingBlocks),
                    onAddPhoto: () => _addPhotoBlock(_anythingBlocks),
                    onAddDraw: () => _addDrawBlock(_anythingBlocks),
                    onRemoveBlock: (b) {
                      setState(() => _anythingBlocks.remove(b));
                      _onFieldChanged();
                    },
                    onChanged: _onFieldChanged,
                  ),
                  IdentitySection(
                    nameController: _nameController,
                    countryController: _selectedCountryController,
                    onCountrySelected: (Country country) {
                      setState(() {
                        _selectedCountryController.text = country.name;
                        _countryISOCode = country.countryCode;
                      });
                      _onFieldChanged();
                    },
                  ),
                  NotebookSubmit(
                    isReady: _nameController.text.trim().isNotEmpty,
                    onSubmit: _submitStory,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
