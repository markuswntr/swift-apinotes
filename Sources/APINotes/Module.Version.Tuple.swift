extension Module.Version {
  public struct Tuple {
    /// The major part of the version number
    public var major: Int

    /// The minor part of the version number
    public var minor: Int?

    /// The patch part of the version number
    public var patch: Int?

    /// Creates a new instance from given values
    public init(
      major: Int,
      minor: Int? = nil,
      patch: Int? = nil
    ) {
      self.major = major
      self.minor = minor
      self.patch = patch
    }
  }
}

// MARK: - Conformance to Hashable & Comparable
extension Module.Version.Tuple: Hashable, Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.major == rhs.major &&
    (lhs.minor ?? 0) == (rhs.minor ?? 0) && // Nil implies zero
    (lhs.patch ?? 0) == (rhs.patch ?? 0)    // Nil implies zero
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    // 1. Compare major version
    guard lhs.major == rhs.major else { return lhs.major < rhs.major }
    // 2. Major is equal, compare minor version
    let lhsMinor = lhs.minor ?? 0
    let rhsMinor = rhs.minor ?? 0
    guard lhsMinor == rhsMinor else { return lhsMinor < rhsMinor }
    // 3. Major and minor are equal, compare patch version
    return (lhs.patch ?? 0) < (rhs.patch ?? 0)
  }
}

// MARK: - Conformance to LosslessStringConvertible
extension Module.Version.Tuple: LosslessStringConvertible {
  public var description: String {
    if let minor {
      if let patch {
        "\(major).\(minor).\(patch)"
      } else {
        "\(major).\(minor)"
      }
    } else {
      "\(major)"
    }
  }

  public init?(_ description: String) {
    let stringValues = description.split(separator: ".")
    let values = stringValues.compactMap { Int($0) }
    guard
      stringValues.count == values.count, // Validate decoding
      values.count > 0, values.count < 4  // Validate bounds
    else { return nil }
    self.init(
      major: values[0],
      minor: values.count > 1 ? values[1] : nil,
      patch: values.count > 2 ? values[2] : nil
    )
  }
}

// MARK: - Conformance to Codable
extension Module.Version.Tuple: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let versionString = try container.decode(String.self)
    guard let versionTuple = Self(versionString) else {
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "\(versionString) is not a valid version tuple"
      ))
    }
    self = versionTuple
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}
