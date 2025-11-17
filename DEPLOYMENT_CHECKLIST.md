# Deployment Checklist for v2.0.0

## Pre-Release Checklist

### ✅ Code Complete
- [x] All code migrated to Foundation Models
- [x] All tests passing (15 tests, 0 failures)
- [x] All executables building successfully
- [x] All documentation updated

### ✅ Build Verification
- [x] Debug build: SUCCESS
- [x] Release build: SUCCESS
- [x] All executables verified working

### ✅ Git Status
- [x] All changes committed
- [x] Changes pushed to repository

## Release Steps

### 1. Create Release Tag
```bash
git tag -a v2.0.0 -m "Release v2.0.0 - Foundation Models Migration

Major Changes:
- Migrated from Ollama to Apple Foundation Models
- Removed external dependencies
- Added benchmarking system
- Updated platform requirements to macOS 15.0+ / iOS 18.0+

See RELEASE_NOTES_v2.0.0.md for details."

git push origin v2.0.0
```

### 2. GitHub Actions Release
The release workflow will automatically:
- Build universal binaries for x86_64 and arm64
- Create universal binaries using lipo
- Upload to GitHub Releases
- Generate SHA256 checksums

### 3. Update Homebrew Formula
After the release is created:

1. Download the universal binary from GitHub Releases
2. Calculate SHA256:
   ```bash
   shasum -a 256 yankovinator-universal.tar.gz
   ```
3. Update `Formula/yankovinator-swift.rb`:
   - Update version to `2.0.0`
   - Update SHA256 checksum
   - Commit to Homebrew tap repository

### 4. Verify Release
- [ ] Check GitHub Releases page
- [ ] Verify all binaries uploaded
- [ ] Verify checksums present
- [ ] Test binary download and extraction
- [ ] Test Homebrew installation (if tap updated)

## Post-Release

### Testing
- [ ] Test on macOS 15.0+ system
- [ ] Verify Foundation Models works correctly
- [ ] Run benchmarks
- [ ] Test all CLI tools
- [ ] Verify error handling

### Documentation
- [ ] Verify README is accurate
- [ ] Check all documentation links work
- [ ] Update any external references

### Communication
- [ ] Announce release
- [ ] Update any external documentation
- [ ] Notify users of breaking changes

## Rollback Plan

If issues are found:
1. Tag previous version as latest
2. Revert Homebrew formula if needed
3. Document issues in GitHub Issues
4. Plan hotfix release

## Success Criteria

- [x] Code compiles successfully
- [x] All tests pass
- [x] All executables work
- [x] Documentation complete
- [ ] Release created and binaries uploaded
- [ ] Homebrew formula updated
- [ ] Runtime testing on macOS 15.0+

## Notes

- Foundation Models requires macOS 15.0+ (Sequoia) or iOS 18.0+
- The framework's availability annotation says macOS 26.0+, but this appears to be a future-version marker
- Code should work on macOS 15.0+ at runtime
- All Foundation Models tests gracefully skip when framework unavailable
