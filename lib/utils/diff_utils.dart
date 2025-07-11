/// Returns a map containing only the fields that differ between [oldData] and [newData].
/// Useful for differential sync: only changed fields are sent to the server.
Map<String, dynamic> generateDiff(
  Map<String, dynamic> oldData,
  Map<String, dynamic> newData,
) {
  final diff = <String, dynamic>{};
  for (final key in newData.keys) {
    if (!oldData.containsKey(key) || oldData[key] != newData[key]) {
      diff[key] = newData[key];
    }
  }
  return diff;
}

/// Returns true if there are any differences between [oldData] and [newData].
bool hasDiff(Map<String, dynamic> oldData, Map<String, dynamic> newData) {
  return generateDiff(oldData, newData).isNotEmpty;
}
