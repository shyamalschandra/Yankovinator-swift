# How to Check Workflow Status

The "Quick Version Test" workflow has been triggered. Here's how to check the results:

## Option 1: GitHub Web UI (Easiest)

1. Go to: https://github.com/shyamalschandra/Yankovinator-swift/actions
2. Click on the latest "Quick Version Test" run
3. Check the results for:
   - **test-swift-6.1.0** job - Should show if Swift 6.1.0 is available
   - **test-macos-15** job - Should show if macOS 15 runner is available

## Option 2: GitHub CLI

```bash
# List recent runs
gh run list --workflow="quick-version-test.yml" --limit 5

# View latest run details
gh run view $(gh run list --workflow="quick-version-test.yml" --limit 1 --json number -q '.[0].number')

# Watch the latest run
gh run watch $(gh run list --workflow="quick-version-test.yml" --limit 1 --json number -q '.[0].number')
```

## Expected Results

### If macOS 15 is Available:
- Job starts successfully
- `sw_vers` shows macOS 15.x
- Output: "✅ macOS 15 runner is AVAILABLE"

### If macOS 15 is NOT Available:
- Job fails immediately
- Error: "The workflow is not valid. macos-15 is not a valid value for runs-on"
- Output: "❌ macOS 15 runner is NOT AVAILABLE"

### Swift 6.1.0 Test:
- Should succeed (we confirmed it's in swift-versions.ts)
- Output: "✅ Swift 6.1.0 is AVAILABLE"
- Shows Swift version number

## Quick Check Command

Run this to see the latest status:

```bash
cd /Users/shyamalchandra/Yankovinator-swift
gh run list --workflow="quick-version-test.yml" --limit 1
```
