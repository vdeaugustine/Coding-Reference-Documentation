# macOS “System Data” Cleanup: Removing Xcode Simulator Runtimes

## What this solves

macOS may report hundreds of gigabytes as **System Data** even when the files are not macOS system files. Xcode simulator runtimes are a common cause.

One runtime can consume roughly 8–20 GiB. A developer Mac with multiple iOS, watchOS, and tvOS versions—plus duplicate builds—can accumulate hundreds of gigabytes.

This guide removes simulator **runtime disk images** through Apple’s supported `simctl` command. It does not delete project source code, npm packages, Xcode archives, or personal files.

## Important consequence

After cleanup, Xcode cannot boot simulators until at least one runtime is reinstalled. Existing simulator device records may remain, but they become unavailable because their runtime is gone.

Simulator app data is separate from runtime images. This guide does not erase that data.

## 1. Measure first

Check filesystem usage:

~~~bash
df -h /
df -h /System/Volumes/Data
~~~

Check macOS and simulator runtimes:

~~~bash
sw_vers
xcrun simctl runtime list
xcrun simctl list runtimes
~~~

Check mounted runtime volumes:

~~~bash
df -h | grep CoreSimulator
~~~

Sum their reported usage:

~~~bash
df -k | awk '/CoreSimulator/ {
  sum += $3
  count++
  printf "%6.1f GiB  %s\n", $3 / 1048576, $NF
} END {
  printf "TOTAL %d volumes, %.1f GiB\n", count, sum / 1048576
}'
~~~

Many CoreSimulator mounts, especially 8–20 GiB each, strongly indicate runtime accumulation.

## 2. Confirm supported deletion syntax

Inspect the installed command:

~~~bash
xcrun simctl runtime help
~~~

Look for:

~~~text
delete (<identifier>|--notUsedSinceDays <days>|--unusable|--outdated) [--dry-run]
Use the alias 'all' to delete all images.
~~~

If this version does not document `runtime delete all`, stop and use the runtime-management workflow exposed by that Xcode version.

## 3. Check running simulators

~~~bash
xcrun simctl list devices
~~~

If any device shows `(Booted)`, shut down simulator devices:

~~~bash
xcrun simctl shutdown all
~~~

The delete command can also shut down booted simulators, but doing it explicitly makes the operation easier to understand.

## 4. Preview deletion

~~~bash
xcrun simctl runtime delete all --dry-run
~~~

Review the list. It may include iOS, watchOS, and tvOS runtime builds.

## 5. Delete every runtime image

~~~bash
xcrun simctl shutdown all
xcrun simctl runtime delete all
~~~

The command may return while macOS continues deleting in the background. Entries marked `(Deleting)` are expected temporarily.

## 6. Wait for asynchronous deletion

~~~bash
for i in {1..12}; do
  xcrun simctl runtime list | tail -1

  if ! xcrun simctl runtime list | grep -q 'Deleting'; then
    break
  fi

  sleep 5
done
~~~

Large collections can take several minutes. Do not manually remove APFS volumes while this runs.

## 7. Verify success

Runtime images should report zero:

~~~bash
xcrun simctl runtime list
~~~

Expected:

~~~text
== Disk Images ==

Total Disk Images: 0 (0.0G)
~~~

The higher-level list should be empty:

~~~bash
xcrun simctl list runtimes
~~~

Verify that no runtime volumes remain mounted:

~~~bash
mount | grep CoreSimulator || echo none
~~~

Expected:

~~~text
none
~~~

Recheck space:

~~~bash
df -h /
df -h /System/Volumes/Data
~~~

The macOS Storage chart can lag behind actual deletion. A logout or restart may be needed before its System Data number refreshes.

## 8. Understand remaining unavailable devices

After runtime deletion, this may still show devices:

~~~bash
xcrun simctl list devices
~~~

They will appear under an `Unavailable` runtime and may say:

~~~text
runtime profile not found
~~~

That means the device record remains but its runtime image is gone. This is normal and confirms runtime cleanup succeeded.

If the separate goal is removing simulator device data, inspect first:

~~~bash
du -sh "$HOME/Library/Developer/CoreSimulator"
~~~

Then, only if that data is disposable:

~~~bash
xcrun simctl delete unavailable
~~~

This separate command can remove installed apps, local databases, test fixtures, login state, and simulator app data. Do not run it automatically.

## Why System Data hid the files

macOS Storage categories are accounting buckets, not always literal folders. Xcode runtime images are mounted APFS disk images under paths such as:

~~~text
/Library/Developer/CoreSimulator/Volumes/
/Library/Developer/CoreSimulator/Cryptex/Images/bundle/
~~~

They may not appear clearly in Finder or a normal scan of the user home directory. macOS may classify their storage as System Data.

Useful evidence:

~~~bash
xcrun simctl runtime list
df -h | grep CoreSimulator
diskutil apfs list
~~~

The investigation should trust the runtime registry plus mounted-filesystem evidence, not only a Finder folder size.

## What to distinguish

### Runtime images

Reinstallable through Xcode. Main target for this cleanup:

~~~bash
xcrun simctl runtime delete all
~~~

### Simulator device data

Separate state under:

~~~text
~/Library/Developer/CoreSimulator/Devices
~~~

Do not erase automatically.

### Xcode build output

Usually regenerable:

~~~text
~/Library/Developer/Xcode/DerivedData
~~~

### Xcode archives

May be needed for symbolication, distribution records, or historical debugging:

~~~text
~/Library/Developer/Xcode/Archives
~~~

### npm, pnpm, and Yarn storage

Check separately. A project collection may have few or no local `node_modules` directories while using a shared package store:

~~~bash
du -sh "$HOME/.npm" 2>/dev/null
du -sh "$HOME/Library/pnpm" 2>/dev/null
du -sh "$HOME/Library/Caches/pnpm" 2>/dev/null
du -sh "$HOME/.yarn" 2>/dev/null
~~~

These are often much smaller than accumulated simulator runtimes.

## Safe investigation commands

Top-level home directories:

~~~bash
find "$HOME" -mindepth 1 -maxdepth 1 -type d -print0 \
  | xargs -0 -n1 -P10 du -sh 2>/dev/null \
  | sort -h
~~~

Large files:

~~~bash
find "$HOME" -xdev -type f -size +1G -print 2>/dev/null
~~~

Developer storage:

~~~bash
du -sh "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null
du -sh "$HOME/Library/Developer/Xcode/Archives" 2>/dev/null
du -sh "$HOME/Library/Developer/CoreSimulator" 2>/dev/null
~~~

Homebrew cache:

~~~bash
brew --cache
du -sh "$(brew --cache)" 2>/dev/null
~~~

Docker storage, if Docker is running:

~~~bash
docker system df
~~~

Do not run Docker volume pruning blindly. Volumes can contain local databases.

## Commands to avoid

Never use broad destructive commands such as:

~~~bash
sudo rm -rf /System
sudo rm -rf /Library
sudo rm -rf /private/var
~~~

Do not manually delete APFS simulator volumes with `diskutil`. Let `simctl` manage runtime registration, signatures, unmounting, and secure storage.

Do not delete random folders inside:

~~~text
~/Library/Containers
~/Library/Group Containers
~/Library/Application Support
~~~

Identify the owning app first. These folders may contain user databases, project state, or downloaded content rather than disposable cache.

## Short version

For a machine where all simulator runtimes can be removed:

~~~bash
xcrun simctl runtime help
xcrun simctl list runtimes
xcrun simctl shutdown all
xcrun simctl runtime delete all --dry-run
xcrun simctl runtime delete all

# Wait until this reports zero images.
xcrun simctl runtime list

# Confirm no runtime disks remain mounted.
mount | grep CoreSimulator || echo none

# Recheck storage.
df -h /System/Volumes/Data
~~~

The key workflow: **measure, inspect supported syntax, shut down, preview, delete through `simctl`, wait, verify registry and mounts, then recheck storage.**
