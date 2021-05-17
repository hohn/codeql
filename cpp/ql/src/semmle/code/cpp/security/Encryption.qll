/**
 * Provides predicates relating to encryption in C and C++.
 */

import cpp

/**
 * Gets the name of an algorithm that is known to be insecure.
 */
string getAnInsecureAlgorithmName() {
  result =
    [
      "DES", "RC2", "RC4", "RC5", "ARCFOUR" // ARCFOUR is a variant of RC4
    ]
}

/**
 * Gets the name of an algorithm that is known to be secure.
 */
string getASecureAlgorithmName() {
  result = ["RSA", "SHA256", "CCM", "GCM", "AES", "Blowfish", "ECIES"]
}

/**
 * Gets the name of a hash algorithm that is insecure if it is being used for
 * encryption (but it is hard to know when that is happening).
 */
string getAnInsecureHashAlgorithmName() { result = ["SHA1", "MD5"] }

/**
 * Gets the regular expression used for matching strings that look like they
 * contain an algorithm that is known to be insecure.
 *
 * Consider using `isInsecureEncryption` rather than accessing this regular
 * expression directly.
 */
string getInsecureAlgorithmRegex() {
  result =
    // algorithms usually appear in names surrounded by characters that are not
    // alphabetical characters in the same case or numerical digits. This
    // handles the upper case:
    "(^|.*[^A-Z0-9])(" + strictconcat(getAnInsecureAlgorithmName(), "|") + ")([^A-Z0-9].*|$)" + "|" +
      // for lowercase, we want to be careful to avoid being confused by
      //camelCase, hence we require two preceding uppercase letters to be
      // sure of a case switch (or a preceding non-alphabetic, non-numeric
      // character).
      "(^|.*[A-Z]{2}|.*[^a-zA-Z0-9])(" +
      strictconcat(getAnInsecureAlgorithmName().toLowerCase(), "|") + ")([^a-z0-9].*|$)"
}

/**
 * Holds if `name` looks like it might be related to operations with an
 * insecure encyption algorithm.
 */
bindingset[name]
predicate isInsecureEncryption(string name) {
  name.regexpMatch(getInsecureAlgorithmRegex()) and
  // Check for evidence that an otherwise matching name may in fact not be
  // related to insecure encrpytion, e.g. "Triple-DES" is not "DES".
  not name.toUpperCase().regexpMatch(".*TRIPLE.*")
}

/**
 * Holds if there is additional evidence that `name` looks like it might be
 * related to operations with an encyption algorithm, besides the name of a
 * specific algorithm. This can be used in conjuction with
 * `isInsecureEncryption` to produce a stronger heuristic.
 */
bindingset[name]
predicate isEncryptionAdditionalEvidence(string name) {
  name.toUpperCase().matches("%" + ["CRYPT", "CODE", "CODING", "CBC", "KEY"] + "%")
}

/**
 * Gets a regular expression for matching strings that look like they
 * contain an algorithm that is known to be secure.
 */
string getSecureAlgorithmRegex() {
  result =
    // algorithms usually appear in names surrounded by characters that are not
    // alphabetical characters in the same case or numerical digits. This
    // handles the upper case:
    "(^|.*[^A-Z0-9])(" + strictconcat(getASecureAlgorithmName(), "|") + ")([^A-Z0-9].*|$)" + "|" +
      // for lowercase, we want to be careful to avoid being confused by
      //camelCase, hence we require two preceding uppercase letters to be
      // sure of a case switch (or a preceding non-alphabetic, non-numeric
      // character).
      "(^|.*[A-Z]{2}|.*[^a-zA-Z0-9])(" + strictconcat(getASecureAlgorithmName().toLowerCase(), "|") +
      ")([^a-z0-9].*|$)"
}

/**
 * DEPRECATED: Terminology has been updated. Use `getAnInsecureAlgorithmName()`
 * instead.
 */
deprecated string algorithmBlacklist() { result = getAnInsecureAlgorithmName() }

/**
 * DEPRECATED: Terminology has been updated. Use
 * `getAnInsecureHashAlgorithmName()` instead.
 */
deprecated string hashAlgorithmBlacklist() { result = getAnInsecureHashAlgorithmName() }

/**
 * DEPRECATED: Terminology has been updated. Use `getInsecureAlgorithmRegex()` instead.
 */
deprecated string algorithmBlacklistRegex() { result = getInsecureAlgorithmRegex() }

/**
 * DEPRECATED: Terminology has been updated. Use `getASecureAlgorithmName()`
 * instead.
 */
deprecated string algorithmWhitelist() { result = getASecureAlgorithmName() }

/**
 * DEPRECATED: Terminology has been updated. Use `getSecureAlgorithmRegex()` instead.
 */
deprecated string algorithmWhitelistRegex() { result = getSecureAlgorithmRegex() }
