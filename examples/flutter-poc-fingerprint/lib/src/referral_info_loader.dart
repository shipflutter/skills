const referralAllowlist = <String>{
  'ref',
  'referral',
  'utm_source',
  'utm_medium',
  'utm_campaign',
  'utm_term',
  'utm_content',
  'click_id',
  'fbclid',
  'gclid',
  'campaign',
};

Map<String, String> loadReferralParams(Uri uri) {
  final result = <String, String>{};

  for (final entry in uri.queryParameters.entries) {
    if (referralAllowlist.contains(entry.key)) {
      result[entry.key] = entry.value;
    }
  }

  return result;
}
