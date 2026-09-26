import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TagInput extends StatefulWidget {
  const TagInput({
    super.key,
    required this.label,
    required this.tags,
    required this.onChanged,
    this.helperText,
    this.maxTags = 8,
    this.maxTagLength = 24,
  });

  final String label;
  final String? helperText;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final int maxTags;
  final int maxTagLength;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    if (value.length > widget.maxTagLength) return;
    if (widget.tags.length >= widget.maxTags) return;
    final lower = value.toLowerCase();
    if (widget.tags.any((t) => t.toLowerCase() == lower)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.tags, value]);
    _controller.clear();
  }

  void _remove(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final atLimit = widget.tags.length >= widget.maxTags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.tags
                .map((t) => Chip(
                      label: Text(t),
                      onDeleted: () => _remove(t),
                    ))
                .toList(),
          ),
        if (widget.tags.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !atLimit,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.maxTagLength),
          ],
          decoration: InputDecoration(
            hintText: atLimit
                ? 'Maximum ${widget.maxTags} tags'
                : 'Type and press Enter or comma',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: atLimit ? null : () => _commit(_controller.text),
            ),
          ),
          onChanged: (v) {
            if (v.endsWith(',')) {
              _commit(v.substring(0, v.length - 1));
            }
          },
          onSubmitted: (v) {
            _commit(v);
            _focusNode.requestFocus();
          },
        ),
      ],
    );
  }
}
