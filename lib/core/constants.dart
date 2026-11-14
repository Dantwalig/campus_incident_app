class AppConstants {
  /// Cloudinary settings for photo uploads. Replace with your own values.
  /// The upload preset must be set to Unsigned in the Cloudinary dashboard.
  static const cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const cloudinaryUploadPreset = 'YOUR_UNSIGNED_PRESET';

  /// Only these email domains can register and use the app.
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  static const campusLocations = [
    'Student Residence',
    'Block A',
    'Block B',
    'Library',
    'Cafeteria',
    'Sports Field',
    'Parking Lot',
    'Admin Building',
    'Other',
  ];

  static const departments = [
    'Computer Science',
    'Software Engineering',
    'Business',
    'Entrepreneurship',
    'Other',
  ];
}
