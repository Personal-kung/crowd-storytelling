import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_flip_builder/page_flip_builder.dart';
import 'dart:convert';

class VirtualNotebookScreen extends StatefulWidget {
  const VirtualNotebookScreen({super.key});

  @override
  State<VirtualNotebookScreen> createState() => _VirtualNotebookScreenState();
}

class _VirtualNotebookScreenState extends State<VirtualNotebookScreen> {
  final _flipKey = GlobalKey<PageFlipBuilderState>();
  
  // We keep a single unified index to track the current logical page.
  int _logicalIndex = 0;
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50], // Paper/warm background
      appBar: AppBar(
        title: const Text("The Global Notebook", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stories').where('status', isEqualTo: 'approved').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(fontFamily: 'serif')));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No approved stories yet. Wait for the curator!", style: TextStyle(fontSize: 18, fontFamily: 'serif')));

          // Safety guard in case docs are deleted
          if (_logicalIndex >= docs.length) {
             _logicalIndex = docs.length - 1;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  // We use a custom widget key so that PageFlipBuilder naturally resets when logical index changes via buttons.
                  // However, we want the flip animation!
                  child: PageFlipBuilder(
                    key: _flipKey,
                    flipAxis: Axis.horizontal,
                    frontBuilder: (context) => _buildPageCard(docs, _isFront ? _logicalIndex : _logicalIndex - 1, true),
                    backBuilder: (context) => _buildPageCard(docs, !_isFront ? _logicalIndex : _logicalIndex + 1, false),
                    onFlipComplete: (isFront) {
                      setState(() {
                         _isFront = isFront;
                         // If they dragged the flip, update the logical index based on orientation 
                         if (isFront && _logicalIndex > 0) {
                            _logicalIndex--;
                         } else if (!isFront && _logicalIndex < docs.length - 1) {
                            _logicalIndex++;
                         }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Manual navigation controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Previous Story"),
                      onPressed: _logicalIndex > 0 ? () {
                         setState(() { _logicalIndex--; _isFront = !_isFront; });
                      } : null,
                   ),
                   const SizedBox(width: 32),
                   Text("Page ${_logicalIndex + 1} of ${docs.length}", style: const TextStyle(fontFamily: 'serif', fontSize: 18)),
                   const SizedBox(width: 32),
                   ElevatedButton.icon(
                      label: const Text("Next Story"),
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _logicalIndex < docs.length - 1 ? () {
                         setState(() { _logicalIndex++; _isFront = !_isFront; });
                      } : null,
                   ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPageCard(List<QueryDocumentSnapshot> docs, int renderIndex, bool isFrontSide) {
     if (renderIndex < 0 || renderIndex >= docs.length) {
        // Blank page for out-of-bounds (during flip transitions or end of book)
        return Card(
           elevation: 4,
           margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           child: Container(
              height: 600,
              alignment: Alignment.center,
              color: Colors.white,
              child: const Icon(Icons.menu_book, color: Colors.grey, size: 64),
           ),
        );
     }

     final doc = docs[renderIndex].data() as Map<String, dynamic>;
     final String name = doc['name'] ?? "Anonymous";
     final String country = doc['country'] ?? "The world";
     final List<dynamic> pages = doc['pages'] ?? [];
     final String type = doc['type'] ?? 'text';
     final String textContent = doc['text_content'] ?? "";
     
     // Unicode flag extraction mapping
     final Map<String, String> flagMap = {
        'Japan': '🇯🇵', 'USA': '🇺🇸', 'United States': '🇺🇸',
        'UK': '🇬🇧', 'United Kingdom': '🇬🇧', 'France': '🇫🇷',
        'Germany': '🇩🇪', 'Canada': '🇨🇦', 'Mexico': '🇲🇽',
        'Brazil': '🇧🇷', 'China': '🇨🇳', 'India': '🇮🇳',
        'Australia': '🇦🇺', 'Italy': '🇮🇹', 'Spain': '🇪🇸',
     };
     final flag = flagMap[country] ?? '🏳️';

     return Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 600, // Fixed physical proportions
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             image: const DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/cream-paper.png'), // Subtle paper texture
                fit: BoxFit.cover,
                opacity: 0.5,
             ),
          ),
          child: Row(
            textDirection: isFrontSide ? TextDirection.ltr : TextDirection.rtl, // Mirror flip for the back side
            children: [
               // VERTICAL EDGE
               Container(
                 width: 80,
                 decoration: BoxDecoration(
                    color: Colors.brown[800],
                    borderRadius: BorderRadius.only(
                       topLeft: Radius.circular(isFrontSide ? 12 : 0),
                       bottomLeft: Radius.circular(isFrontSide ? 12 : 0),
                       topRight: Radius.circular(!isFrontSide ? 12 : 0),
                       bottomRight: Radius.circular(!isFrontSide ? 12 : 0),
                    ),
                 ),
                 child: Stack(
                   children: [
                      // Flag at the top
                      Positioned(
                         top: 24,
                         left: 0,
                         right: 0,
                         child: Center(child: Text(flag, style: const TextStyle(fontSize: 40))),
                      ),
                      // Name and Country Rotated
                      Positioned.fill(
                         child: Center(
                            child: RotatedBox(
                               quarterTurns: 3,
                               child: Text(
                                  "$name  •  $country",
                                  style: const TextStyle(
                                     fontFamily: 'serif',
                                     fontSize: 20,
                                     letterSpacing: 3,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.white70,
                                  )
                               ),
                            ),
                         ),
                      ),
                   ],
                 ),
               ),
               
               // PAGE CONTENT
               Expanded(
                 child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                       crossAxisAlignment: isFrontSide ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                       children: [
                          Text("Entry ${renderIndex + 1}", style: TextStyle(color: Colors.brown[300], fontFamily: 'serif', fontSize: 18)),
                          const Divider(color: Colors.brown),
                          const SizedBox(height: 24),
                          Expanded(
                             child: SingleChildScrollView(
                                child: type == 'photo' && pages.isNotEmpty
                                   ? Column(
                                       children: pages.map((base64Str) => Image.memory(base64Decode(base64Str))).toList(),
                                     )
                                   : Text(
                                       textContent,
                                       style: const TextStyle(fontFamily: 'serif', fontSize: 22, height: 1.8, color: Colors.black87),
                                       textAlign: isFrontSide ? TextAlign.left : TextAlign.right,
                                     ),
                             ),
                          ),
                       ],
                    ),
                 ),
               ),
            ],
          ),
        )
     );
  }
}
