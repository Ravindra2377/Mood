import 'package:flutter/material.dart';

import '../../../core/ai/panda_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PandaCompanionSettingsSheet extends StatefulWidget {
  const PandaCompanionSettingsSheet({super.key, required this.preferences});

  final PandaPreferences preferences;

  @override
  State<PandaCompanionSettingsSheet> createState() =>
      _PandaCompanionSettingsSheetState();
}

class _PandaCompanionSettingsSheetState
    extends State<PandaCompanionSettingsSheet> {
  late final TextEditingController _nameController;
  late PandaPersona _selectedPersona;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preferences.name);
    _selectedPersona = widget.preferences.persona;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Personalize your panda',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.darkGrey,
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Give your companion a nickname and choose the vibe that fits you today.',
              style: AppTypography.body2.copyWith(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 24),
            Text(
              'Companion name',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 18,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.white,
                hintText: 'Mochi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.mediumGrey.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPastel,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.pets_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose a vibe',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: PandaPersona.values.map((persona) {
                final isSelected = persona == _selectedPersona;
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (value) {
                    if (!value) return;
                    setState(() => _selectedPersona = persona);
                  },
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.label,
                        style: AppTypography.body2.copyWith(
                          color: isSelected
                              ? AppColors.charcoal
                              : AppColors.darkGrey,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        persona.description,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.charcoal.withOpacity(0.75)
                              : AppColors.darkGrey.withOpacity(0.7),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  avatar: CircleAvatar(
                    backgroundColor:
                        persona.accentColor.withOpacity(0.25),
                    radius: 16,
                    child: Icon(
                      Icons.auto_awesome,
                      color: persona.accentColor,
                      size: 18,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  selectedColor: persona.accentColor.withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? persona.accentColor
                          : AppColors.mediumGrey.withOpacity(0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _handleSave,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primaryPastel,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        'Save companion settings',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await widget.preferences.updateName(_nameController.text);
    await widget.preferences.updatePersona(_selectedPersona);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

