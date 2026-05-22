String getMediaType(String mime) {
  if (mime.startsWith("image/")) {
    return "IMAGE";
  }

  if (mime.startsWith("video/")) {
    return "VIDEO";
  }

  if (mime.startsWith("audio/")) {
    return "AUDIO";
  }

  return "FILE";
}
