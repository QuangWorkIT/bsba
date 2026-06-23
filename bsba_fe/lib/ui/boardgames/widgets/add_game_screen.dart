import 'package:flutter/material.dart';
import 'package:project/ui/boardgames/add_game_viewmodel.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddGameViewModel _vm;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPlayersController = TextEditingController(text: '1');
  final _maxPlayersController = TextEditingController(text: '4');
  final _playTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = AddGameViewModel();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _playTimeController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _showImageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final urlController = TextEditingController();
        return ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Cover Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005AB4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose a preset image:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _vm.presetImages.length,
                      itemBuilder: (context, index) {
                        final item = _vm.presetImages[index];
                        return GestureDetector(
                          onTap: () {
                            _vm.setImageUrl(item['url']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    item['url']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                      child: Text(
                                        item['name']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Or enter custom image URL:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (urlController.text.trim().isNotEmpty) {
                          _vm.setImageUrl(urlController.text.trim());
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Use Custom URL'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addNewCategory() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category / Genre'),
          content: TextField(
            controller: catController,
            decoration: const InputDecoration(
              hintText: 'e.g. Bluffing',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = catController.text.trim();
                if (text.isNotEmpty) {
                  _vm.addCategory(text);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _vm.submitGame(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      minPlayersStr: _minPlayersController.text,
      maxPlayersStr: _maxPlayersController.text,
      playTimeStr: _playTimeController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.successMessage ?? 'Game successfully added to your library!'),
          backgroundColor: const Color(0xFF005AB4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // Returns true to notify previous screen to refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.errorMessage ?? 'Failed to add game'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF005AB4);
    const borderGray = Color(0xFFC1C6D5);

    return Scaffold(
      backgroundColor: const Color(0xF9F9FFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xF9F9FFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Game',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Color(0xFF414753)),
            onPressed: null,
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: primaryBlue,
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/booking/profile.png'),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderGray),
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cover Photo Section ──────────────────────────────────
                  GestureDetector(
                    onTap: _showImageSelector,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomPaint(
                        painter: DashedRectPainter(
                          color: borderGray,
                          strokeWidth: 1.5,
                          gap: 6.0,
                        ),
                        child: Center(
                          child: _vm.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    _vm.imageUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: primaryBlue.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Add Cover Photo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF414753),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'High resolution PNG or JPG (Min 800×800)',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Game Title ───────────────────────────────────────────
                  const Text(
                    'Game Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Wingspan',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a game title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Description ──────────────────────────────────────────
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Brief summary of gameplay and mechanics...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Player Count (Min & Max) ─────────────────────────────
                  const Text(
                    'Player Count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minPlayersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: borderGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: borderGray),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (int.tryParse(value) == null) return 'Must be number';
                            return null;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'to',
                          style: TextStyle(color: Color(0xFF414753), fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _maxPlayersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: borderGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: borderGray),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (int.tryParse(value) == null) return 'Must be number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Play Time ────────────────────────────────────────────
                  const Text(
                    'Play Time (mins)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _playTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 60',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      suffixText: 'MINS',
                      suffixStyle: const TextStyle(
                        color: Color(0xFF414753),
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter play time';
                      if (int.tryParse(value) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Age Rating ───────────────────────────────────────────
                  const Text(
                    'Age Rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _vm.selectedAgeRange,
                    hint: Text('Select age range', style: TextStyle(color: Colors.grey[400])),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                    ),
                    items: _vm.ageRanges.map((range) {
                      return DropdownMenuItem<String>(
                        value: range,
                        child: Text(range),
                      );
                    }).toList(),
                    onChanged: _vm.setSelectedAgeRange,
                    validator: (value) {
                      if (value == null) return 'Please select an age rating';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Starting Stock ───────────────────────────────────────
                  const Text(
                    'Starting Stock',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderGray),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _vm.decrementStock,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEEF4),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(9)),
                            ),
                            child: const Icon(Icons.remove, color: Color(0xFF414753)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_vm.startingStock}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF414753),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _vm.incrementStock,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEEF4),
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(9)),
                            ),
                            child: const Icon(Icons.add, color: Color(0xFF414753)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Category / Genre ─────────────────────────────────────
                  const Text(
                    'Category / Genre',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414753),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._vm.categories.map((cat) {
                        final isSelected = _vm.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _vm.setSelectedCategory(cat);
                            }
                          },
                          selectedColor: const Color(0xFFD6E3FF),
                          backgroundColor: Colors.white,
                          checkmarkColor: primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? primaryBlue : const Color(0xFF414753),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryBlue : borderGray,
                            ),
                          ),
                        );
                      }),
                      ActionChip(
                        label: const Text('+ Add New'),
                        onPressed: _addNewCategory,
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ── Submit Button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add Game to Library',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter to draw the dashed border around the cover photo card
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw top
    double x = 0;
    while (x < size.width) {
      path.moveTo(x, 0);
      path.lineTo((x + gap).clamp(0, size.width), 0);
      x += gap * 2;
    }
    // Draw right
    double y = 0;
    while (y < size.height) {
      path.moveTo(size.width, y);
      path.lineTo(size.width, (y + gap).clamp(0, size.height));
      y += gap * 2;
    }
    // Draw bottom
    x = size.width;
    while (x > 0) {
      path.moveTo(x, size.height);
      path.lineTo((x - gap).clamp(0, size.width), size.height);
      x -= gap * 2;
    }
    // Draw left
    y = size.height;
    while (y > 0) {
      path.moveTo(0, y);
      path.lineTo(0, (y - gap).clamp(0, size.height));
      y -= gap * 2;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) => false;
}
