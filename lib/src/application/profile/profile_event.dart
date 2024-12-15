import 'package:map_assignment/src/application/core/base_bloc_event.dart';

class ProfileEvent extends BaseBlocEvent {}

class DateChanged extends ProfileEvent {
  DateTime selectedDate;
  DateChanged(
    this.selectedDate,
  );
}

class LastNameChanged extends ProfileEvent {
  String? lastName;
  LastNameChanged(this.lastName);
}

class FirstNameChanged extends ProfileEvent {
  String? firstName;
  FirstNameChanged(this.firstName);
}

class GetCurrentLocation extends ProfileEvent {}

class CreateProfileButtonTapped extends ProfileEvent {}

class EditButtonClicked extends ProfileEvent {}

class EditProfileButton extends ProfileEvent {}
