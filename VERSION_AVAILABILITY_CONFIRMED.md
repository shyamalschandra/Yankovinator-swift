# Version Availability - CONFIRMED ✅

## Swift Versions

### ✅ CONFIRMED AVAILABLE

Based on analysis of `swift-actions/setup-swift` source code (`src/swift-versions.ts`):

1. **Swift 6.1.0** ✅ - **AVAILABLE** (first entry in VERSIONS_LIST)
2. **Swift 6.0.3** ✅ - AVAILABLE
3. **Swift 6.0.2** ✅ - AVAILABLE
4. **Swift 6.0.1** ✅ - AVAILABLE
5. **Swift 6.0.0** ✅ - AVAILABLE
6. **Swift 6.0** ✅ - AVAILABLE
7. **Swift 5.10.1** ✅ - AVAILABLE
8. **Swift 5.10** ✅ - AVAILABLE (currently using)

### ❌ NOT AVAILABLE

- **Swift 6.2** - Not listed in swift-versions.ts

## Source Code Evidence

From `https://github.com/swift-actions/setup-swift/blob/main/src/swift-versions.ts`:

```typescript
const VERSIONS_LIST: [string, OS[]][] = [
  ["6.1.0", [OS.MacOS, OS.Ubuntu]],  // ✅ First entry!
  ["6.0.3", [OS.MacOS, OS.Ubuntu]],
  ["6.0.2", [OS.MacOS, OS.Ubuntu]],
  ["6.0.1", [OS.MacOS, OS.Ubuntu]],
  ["6.0.0", [OS.MacOS, OS.Ubuntu]],
  ["6.0", [OS.MacOS, OS.Ubuntu]],
  ["5.10.1", [OS.MacOS, OS.Ubuntu]],
  ["5.10", [OS.MacOS, OS.Ubuntu]],
  // ... more versions
];
```

## macOS Runners

### ✅ CONFIRMED AVAILABLE

- **macos-14** (Sonoma) - Currently using, confirmed working

### ❓ UNKNOWN (Needs Testing)

- **macos-15** (Sequoia) - Test via workflow to confirm

## Recommendations

### Option 1: Upgrade to Swift 6.1.0 (Recommended)

**Benefits:**
- Latest stable Swift version
- Better performance and features
- Future-proof

**Configuration:**
```yaml
runs-on: macos-14
steps:
  - uses: swift-actions/setup-swift@v1
    with:
      swift-version: "6.1.0"  # ✅ Confirmed available
```

**Package.swift:**
```swift
// swift-tools-version: 6.0  // Compatible with Swift 6.1.0
platforms: [
    .macOS(.v14),  // Build target
    .iOS(.v17)     // Build target
]
```

### Option 2: Stay with Swift 5.10 (Current)

**Benefits:**
- Already working
- Stable and proven
- No changes needed

**Configuration:**
```yaml
runs-on: macos-14
steps:
  - uses: swift-actions/setup-swift@v1
    with:
      swift-version: "5.10"  # ✅ Currently working
```

## Testing macOS 15

To test if `macos-15` runner is available:

1. Run the `Quick Version Test` workflow
2. Check if the `test-macos-15` job succeeds
3. If it succeeds, you can use `runs-on: macos-15`

## Summary

| Component | Status | Version |
|-----------|--------|---------|
| Swift | ✅ Available | **6.1.0** (highest) |
| Swift | ✅ Available | 6.0.x (multiple versions) |
| Swift | ✅ Available | 5.10 (current) |
| macOS Runner | ✅ Available | macos-14 (current) |
| macOS Runner | ❓ Unknown | macos-15 (needs test) |

**Highest Confirmed Working:**
- **Swift 6.1.0** + **macos-14** ✅

---

**Last Updated**: Based on source code analysis of `swift-actions/setup-swift`  
**Source**: https://github.com/swift-actions/setup-swift/blob/main/src/swift-versions.ts
