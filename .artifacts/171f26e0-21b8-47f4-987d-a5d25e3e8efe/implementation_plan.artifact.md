# Implementation Plan: Connect Users to API and Show More Users

This plan aims to make users more visible throughout the application and fix the incorrect "shown" count in the user list.

## User Review Required

> [!IMPORTANT]
> I will be adding a "Top Users" horizontal list to the **Home Screen** to make users more discoverable. I will also be fixing the pagination display in the **User Screen** so it correctly shows the total number of users from the API.

## Proposed Changes

### Service & Repository Layers

#### [MODIFY] [api_service.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/service/api_service.dart)
- Update `getUsers` to support `limit` or `size` parameters so we can fetch a small set for the home screen.

#### [MODIFY] [user_repository.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/repository/user_repository.dart)
- Update `getUsers` to pass through the new limit/size parameters.

### Controller Layer

#### [MODIFY] [home_controller.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/controller/home_controller.dart)
- Add a new `users` list (`RxList<User>`).
- Update `loadHome` to fetch users from the `UserRepository`.

#### [MODIFY] [user_controller.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/controller/user_controller.dart)
- Ensure it fetches the latest user data correctly.

### UI Layer

#### [MODIFY] [home_screen.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/screen/home/home_screen.dart)
- Add a horizontal list of users between the Banners and the Latest Posts section.
- Each user will show their avatar and nickname.

#### [MODIFY] [user_screen.dart](file:///C:/Users/93%20Computer/Downloads/pro_23_g_6/pro_23_g_6/pro_23_g_6/lib/screen/user/user_screen.dart)
- Fix the count text to use `controller.userData.value?.pagination?.total` instead of hardcoding `users.length` for both values.

## Verification Plan

### Manual Verification
- Open the Home screen and verify that a "Top Users" section appears.
- Navigate to the User screen and verify that the "X of Y shown" text correctly reflects the total number of users in the system.
