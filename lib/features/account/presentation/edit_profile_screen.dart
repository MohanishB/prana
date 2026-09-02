import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/edit_profile_cubit.dart';
import '../data/account_models.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final AccountProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _maxPhotoBytes = 5 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _lastName;
  late final TextEditingController _dob;
  late final TextEditingController _city;
  late final TextEditingController _pincode;
  late String _gender;
  late int _countryId;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _firstName = TextEditingController(text: profile.firstName);
    _middleName = TextEditingController(text: profile.middleName);
    _lastName = TextEditingController(text: profile.lastName);
    _dob = TextEditingController(text: profile.dob);
    _city = TextEditingController(text: profile.cityName);
    _pincode = TextEditingController(text: profile.pincode);
    _gender = profile.gender;
    _countryId = profile.countryId;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _city.dispose();
    _pincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = widget.profile;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.editProfile, showBack: true),
      body: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.profileUpdated)),
            );
            context.pop(true);
          }
        },
        child: SingleChildScrollView(
          child: ResponsiveContent(
            maxWidth: AppSizes.compactContentMaxWidth,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<EditProfileCubit, EditProfileState>(
                      buildWhen: (previous, current) =>
                          previous.selectedPhotoPath !=
                          current.selectedPhotoPath,
                      builder: (context, state) => _ProfilePhotoEditor(
                        currentPhotoUrl: profile.photoUrl,
                        selectedPhotoPath: state.selectedPhotoPath,
                        onChangePhoto: _showPhotoSourcePicker,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _firstName,
                      decoration: InputDecoration(labelText: l10n.firstName),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AppValidators.isValidProfileText(value ?? '')
                              ? null
                              : l10n.profileFieldInvalid,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _middleName,
                      decoration: InputDecoration(labelText: l10n.middleName),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AppValidators.isValidOptionalProfileText(value ?? '')
                              ? null
                              : l10n.profileFieldInvalid,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _lastName,
                      decoration: InputDecoration(labelText: l10n.lastName),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AppValidators.isValidProfileText(value ?? '')
                              ? null
                              : l10n.profileFieldInvalid,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _gender == 'MALE' || _gender == 'FEMALE'
                          ? _gender
                          : null,
                      decoration: InputDecoration(labelText: l10n.gender),
                      items: [
                        DropdownMenuItem(
                          value: 'MALE',
                          child: Text(l10n.male),
                        ),
                        DropdownMenuItem(
                          value: 'FEMALE',
                          child: Text(l10n.female),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) _gender = value;
                      },
                      validator: (value) =>
                          value == null ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _dob,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.dateOfBirth,
                        suffixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                      onTap: _pickDate,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<int>(
                      value:
                          profile.countries.any((c) => c.id == _countryId)
                              ? _countryId
                              : null,
                      decoration: InputDecoration(labelText: l10n.country),
                      items: profile.countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country.id,
                              child: Text(
                                country.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) _countryId = value;
                      },
                      validator: (value) =>
                          value == null ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _city,
                      decoration: InputDecoration(labelText: l10n.city),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AppValidators.isValidProfileText(value ?? '')
                              ? null
                              : l10n.profileFieldInvalid,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _pincode,
                      decoration: InputDecoration(labelText: l10n.pincode),
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          AppValidators.isValidProfileText(value ?? '')
                              ? null
                              : l10n.profileFieldInvalid,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      initialValue: profile.email,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        helperText: l10n.readOnlyField,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      initialValue: profile.formattedPhone,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.phone,
                        helperText: l10n.readOnlyField,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BlocBuilder<EditProfileCubit, EditProfileState>(
                      builder: (context, state) {
                        final saving = state is EditProfileSaving;
                        return FilledButton(
                          onPressed: saving ? null : _save,
                          child: saving
                              ? Text(l10n.saving)
                              : Text(l10n.saveChanges),
                        );
                      },
                    ),
                    BlocBuilder<EditProfileCubit, EditProfileState>(
                      builder: (context, state) {
                        if (state case EditProfileFailure(:final error)) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              error.userMessage(context),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPhotoSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.takePhoto),
                  onTap: () => Navigator.of(sheetContext).pop(
                    ImageSource.camera,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () => Navigator.of(sheetContext).pop(
                    ImageSource.gallery,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(l10n.cancel),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    await _pickPhoto(source);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null || !mounted) return;

    final path = picked.path;
    final lowerPath = path.toLowerCase();
    if (!lowerPath.endsWith('.jpg') &&
        !lowerPath.endsWith('.jpeg') &&
        !lowerPath.endsWith('.png')) {
      _showMessage(context.l10n.profilePhotoFormat);
      return;
    }

    final size = await File(path).length();
    if (!mounted) return;
    if (size > _maxPhotoBytes) {
      _showMessage(context.l10n.profilePhotoTooLarge);
      return;
    }

    context.read<EditProfileCubit>().selectPhoto(path);
  }

  Future<void> _pickDate() async {
    final parsed = DateTime.tryParse(_dob.text);
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: parsed ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (selected == null) return;
    _dob.text =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<EditProfileCubit>().save(
          UpdateProfileRequest(
            firstName: _firstName.text,
            middleName: _middleName.text,
            lastName: _lastName.text,
            gender: _gender,
            dob: _dob.text,
            countryId: _countryId,
            cityName: _city.text,
            pincode: _pincode.text,
          ),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProfilePhotoEditor extends StatelessWidget {
  const _ProfilePhotoEditor({
    required this.currentPhotoUrl,
    required this.selectedPhotoPath,
    required this.onChangePhoto,
  });

  final String? currentPhotoUrl;
  final String? selectedPhotoPath;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final selected = selectedPhotoPath;
    final current = currentPhotoUrl;
    final ImageProvider<Object>? imageProvider = selected != null
        ? FileImage(File(selected))
        : current == null
            ? null
            : NetworkImage(current);

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: AppSizes.avatarLarge / 2,
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.white,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              Positioned(
                right: -AppSpacing.xxs,
                bottom: -AppSpacing.xxs,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: onChangePhoto,
                    color: Theme.of(context).colorScheme.onPrimary,
                    icon: const Icon(Icons.photo_camera_outlined),
                    tooltip: context.l10n.changeProfilePhoto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onChangePhoto,
            child: Text(context.l10n.changeProfilePhoto),
          ),
        ],
      ),
    );
  }
}
