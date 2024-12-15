import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/src/application/profile/profile_bloc.dart';
import 'package:map_assignment/src/application/profile/profile_event.dart';
import 'package:map_assignment/src/application/profile/profile_state.dart';
import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/presentation/core/app_page.dart';
import 'package:map_assignment/src/presentation/core/base_state.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/core/theme/text_styles.dart';
import 'package:map_assignment/src/presentation/widgets/RequiredTextWidget.dart';
import 'package:map_assignment/src/presentation/widgets/app_button.dart';
import 'package:map_assignment/src/presentation/widgets/bordered_text_field.dart';

class ProfilePage extends StatefulWidget {
  static const String route = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends BaseState<ProfilePage> {
  ProfileBloc? _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<ProfileBloc>(context);
      _bloc!.message.listen((value) {
        showMessage(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        return AppPage(
          retryOnTap: () {},
          processStateStream: _bloc!.stream.map((state) => state.processState),
          title: state.profileCreatedStatus! ? "Profile" : 'Create profile',
          actions: [
            if (state.profileCreatedStatus!) _getEditButton(context),
          ],
          child: body(context, state),
        );
      },
    );
  }

  Widget _getEditButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _bloc!.add(EditButtonClicked());
      },
      child: Padding(
        padding: const EdgeInsets.only(right: Units.kStandardPadding),
        child: Text(
          "Edit",
          style: TextStyles.body1Regular(context)!
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget body(BuildContext context, ProfileState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Units.kXLPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            if (state.editStatus == true) _editMessage(context),
            if (state.profileCreatedStatus! && state.editStatus == false)
              _editInstructionText(context),
            const SizedBox(
              height: Units.kTextBoxHeight,
            ),
            _getFirstNameText(context),
            const SizedBox(height: 8.0),
            _getFirstNameTextField(context, state),
            const SizedBox(
              height: 20,
            ),
            _lastNameText(context),
            const SizedBox(height: 8.0),
            _getLastNameTextField(context, state),
            const SizedBox(
              height: 20,
            ),
            _getDateOfBirthText(context),
            const SizedBox(
              height: 8,
            ),
            _getDateOfBirthTextField(context, state),
            const SizedBox(
              height: 20,
            ),
            _currentLocationText(context),
            const SizedBox(
              height: 8.0,
            ),
            _currentLocationTextField(context, state),
            const SizedBox(height: 40),
            _button(context, state),
          ],
        ),
      ),
    );
  }

  Widget _editMessage(BuildContext context) {
    return Center(
      child: Text(
        "Now You can able to edit the field",
        style: TextStyles.body1Bold(context),
      ),
    );
  }

  Widget _editInstructionText(BuildContext context) {
    return Center(
      child: Text(
        "If you want edit the profile please tap the edit button",
        style: TextStyles.body1Bold(context),
      ),
    );
  }

  Widget _getFirstNameText(BuildContext context) {
    return RequiredTextWidget(
      text: 'First Name ',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: AppColors.black,
      ),
      isRequired: true,
    );
  }

  Widget _getFirstNameTextField(BuildContext context, ProfileState state) {
    return BorderedTextField(
      key: const Key("first-name"),
      backgroundColor: AppColors.white,
      textCapitalization: TextCapitalization.words,
      labelText: 'First name',
      maxLines: 1,
      enabled: !(state.profileCreatedStatus! && state.editStatus == false),
      onTextChanged: (text) {
        _bloc!.add(FirstNameChanged(text.trim()));
      },
      textStream: _bloc!.stream.map((state) => state.firstName),
      errorStream: _bloc!.stream.map((state) => state.firstNameErr),
    );
  }

  Widget _lastNameText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Last Name ',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: AppColors.black,
      ),
      isRequired: true,
    );
  }

  Widget _getLastNameTextField(BuildContext context, ProfileState state) {
    return BorderedTextField(
      key: const Key("last-name"),
      backgroundColor: AppColors.white,
      labelText: 'last name',
      maxLines: 1,
      enabled: !(state.profileCreatedStatus! && state.editStatus == false),
      onTextChanged: (text) {
        _bloc!.add(LastNameChanged(text.trim()));
      },
      textStream: _bloc!.stream.map((state) => state.lastName),
      errorStream: _bloc!.stream.map((state) => state.lastNameErr),
    );
  }

  Widget _getDateOfBirthText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Date of Birth ',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: AppColors.black,
      ),
      isRequired: true,
    );
  }

  Widget _getDateOfBirthTextField(BuildContext context, ProfileState state) {
    return GestureDetector(
      onTap: (state.profileCreatedStatus! && state.editStatus == false)
          ? null
          : () async {
              final selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(1950),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                _bloc!.add(DateChanged(selectedDate));
              }
            },
      child: Container(
        height: Units.kTextBoxHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Units.kTextFieldBorderRadius),
          border: Border.all(
            width: 1.5,
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: Units.kSPadding),
            child: Text(
              state.selectedDate.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyles.h4(context)?.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentLocationText(BuildContext context) {
    return RequiredTextWidget(
      text: 'Current location',
      textStyle: TextStyles.title2Bold(context)?.copyWith(
        color: AppColors.black,
      ),
      isRequired: true,
    );
  }

  Widget _currentLocationTextField(BuildContext context, ProfileState state) {
    return InkWell(
      onTap: (state.profileCreatedStatus! && state.editStatus == false)
          ? null
          : () {
              _bloc!.add(GetCurrentLocation());
              showMessage("Please wait for some seconds to get the location");
            },
      child: Container(
        height: Units.kTextBoxHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
          border: Border.all(
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: Units.kSPadding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(state.currentLocation ?? ""),
          ),
        ),
      ),
    );
  }

  Widget _button(BuildContext context, ProfileState state) {
    return AppButton(
      onTap: () {
        if (state.profileCreatedStatus == false) {
          _bloc!.add(CreateProfileButtonTapped());
        } else if (state.editStatus == true) {
          _bloc!.add(EditProfileButton());
        } else {
          showMessage("The profile already created");
        }
      },
      label: state.profileCreatedStatus!
          ? state.profileCreatedStatus!
              ? (state.profileCreatedStatus! && state.editStatus == false)
                  ? "Completed"
                  : "Edit Profile"
              : "Create Profile".toUpperCase()
          : "Create Profile",
      height: Units.kTextBoxHeight,
      color: AppColors.green,
    );
  }
}
