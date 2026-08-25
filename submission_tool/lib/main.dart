import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:country_picker/country_picker.dart';
import 'package:uuid/uuid.dart';

// firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GlobalNotebookApp());
}

class GlobalNotebookApp extends StatelessWidget {
  const GlobalNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Notebook',
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

  String? _invitationToken;
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
    
    _invitationToken = token;
    
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
        'country': _selectedCountryController.text.isNotEmpty ? _selectedCountryController.text : 'The world',
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submission failed. Please try again.")));
      }
    } finally {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "The Global Notebook",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 16),
          // Placeholder for Hero Collage
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_stories, color: Colors.black38, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.landscape, color: Colors.black38, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people, color: Colors.black38, size: 40),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "We invited you here because what you have to share matters. "
            "This is a private, personalized digital storytelling space. "
            "There is no correct way to participate—only your way.",
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
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
        title: const Text("Handwrite / Draw"),
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
                    child: const Text("Clear"),
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
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _buildBlockToolbar(List<StoryBlock> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: const Icon(Icons.text_fields, size: 16),
            label: const Text("Type"),
            onPressed: () => _addTextBlock(list),
          ),
          ActionChip(
            avatar: const Icon(Icons.camera_alt, size: 16),
            label: const Text("Photo"),
            onPressed: () => _addPhotoBlock(list),
          ),
          ActionChip(
            avatar: const Icon(Icons.edit, size: 16),
            label: const Text("Handwrite"),
            onPressed: () => _addDrawBlock(list),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(StoryBlock block, List<StoryBlock> list) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          if (block.type == BlockType.text)
            TextField(
              controller: block.textController,
              maxLines: null,
              style: const TextStyle(fontSize: 18, height: 1.5),
              decoration: InputDecoration(
                hintText: "Start typing...",
                hintStyle: const TextStyle(color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            )
          else if (block.bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(block.bytes!, fit: BoxFit.contain, width: double.infinity),
            ),
          
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                setState(() {
                  list.remove(block);
                });
                _onFieldChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<StoryBlock> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...list.map((b) => _buildBlock(b, list)),
          if (list.isEmpty)
             const Text("Add a contribution:", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          _buildBlockToolbar(list),
          const Divider(height: 48, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildIdentity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("How would you like to be remembered?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Name *",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountryController.text = country.name;
                    _countryISOCode = country.countryCode;
                  });
                  _onFieldChanged();
                },
              );
            },
            child: IgnorePointer(
              child: TextField(
                controller: _selectedCountryController,
                decoration: InputDecoration(
                  labelText: "Country (Optional)",
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty ? null : _submitStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.redAccent, size: 48),
              SizedBox(height: 24),
              Text(
                "Thank you for sharing with us.",
                style: TextStyle(fontSize: 24, fontFamily: 'Georgia'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                _isSaving ? "Saving..." : "Saved",
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680), // Optimal reading width
          child: ListView(
            children: [
              _buildHero(),
              _buildSection("Words that have stayed with you", _sayingBlocks),
              _buildSection("A story from home", _storyBlocks),
              _buildSection("Anything you'd like to share", _anythingBlocks),
              _buildIdentity(),
            ],
          ),
        ),
      ),
    );
  }
}
