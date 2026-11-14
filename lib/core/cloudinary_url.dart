/// Transformations applied by Cloudinary when an image is delivered.
/// They resize and compress on the server, which saves mobile data.
class CloudinaryTransforms {
  static const thumbnail = 'w_160,h_160,c_fill,q_auto,f_auto';
  static const detail = 'w_1000,q_auto,f_auto';
}

/// Inserts a transformation into a Cloudinary delivery URL. Any other URL is
/// returned unchanged, so older or external links still work.
String cloudinaryTransform(String url, String transformation) {
  const marker = '/upload/';
  final index = url.indexOf(marker);
  if (index == -1 || !url.contains('res.cloudinary.com')) return url;
  final insertAt = index + marker.length;
  return '${url.substring(0, insertAt)}$transformation/${url.substring(insertAt)}';
}
