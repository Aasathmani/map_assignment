import 'package:map_assignment/src/application/core/base_bloc_state.dart';

class ProfileState extends BaseBlocState {
  String? selectedDate;
  String? currentLocation;
  String? firstName;
  String? lastName;
  String? firstNameErr;
  String? lastNameErr;
  bool? profileCreatedStatus;
  bool? editStatus;
  bool? editProfileStatus;

  ProfileState({
    this.selectedDate = "",
    this.currentLocation,
    this.firstName,
    this.lastName,
    this.firstNameErr,
    this.lastNameErr,
    this.profileCreatedStatus = false,
    this.editStatus = false,
    this.editProfileStatus = false,
  });

  @override
  ProfileState copyWith({
    String? selectedDate,
    String? currentLocation,
    String? firstName,
    String? lastName,
    String? firstNameErr,
    String? lastNameErr,
    bool? profileCreatedStatus,
    bool? editStatus,
    bool? editProfileStatus,
  }) {
    return ProfileState(
      selectedDate: selectedDate ?? this.selectedDate,
      currentLocation: currentLocation ?? this.currentLocation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      lastNameErr: lastNameErr ?? this.lastNameErr,
      firstNameErr: firstNameErr ?? this.firstNameErr,
      profileCreatedStatus: profileCreatedStatus ?? this.profileCreatedStatus,
      editStatus: editStatus ?? this.editStatus,
      editProfileStatus: editProfileStatus ?? this.editProfileStatus,
    )..processState = processState;
  }
}
