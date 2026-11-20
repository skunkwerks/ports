--- src/node_sea_bin.cc.orig	2026-08-05 09:31:13 UTC
+++ src/node_sea_bin.cc
@@ -13,6 +13,14 @@
 #endif  // defined(DEBUG)
 #endif  // HAVE_LIEF
 
+// Without LIEF, single executable applications are still supported on FreeBSD:
+// the ELF injector below is append-only and fills program header slots that
+// were reserved at link time, so it needs no binary rewriting library.
+#if !defined(HAVE_LIEF) && defined(__FreeBSD__) && \
+    !defined(DISABLE_SINGLE_EXECUTABLE_APPLICATION)
+#define HAVE_NATIVE_ELF_SEA 1
+#endif
+
 #include "debug_utils-inl.h"
 #include "env-inl.h"
 #include "node_exit_code.h"
@@ -20,6 +28,8 @@
 #include "util-inl.h"
 
 #include <algorithm>
+#include <cstdint>
+#include <cstring>
 #include <memory>
 #include <string>
 #include <string_view>
@@ -73,7 +83,7 @@ bool IsSingleExecutable() {
   return postject_has_resource();
 }
 
-#ifdef HAVE_LIEF
+#if defined(HAVE_LIEF) || defined(HAVE_NATIVE_ELF_SEA)
 static constexpr const char* kSEAResourceName = "NODE_SEA_BLOB";
 static constexpr const char* kELFSectionName = ".note.node.sea";
 static constexpr const char* kMachoSegmentName = "NODE_SEA";
@@ -92,6 +102,7 @@ static void DebugLog(const char* format, Args&&... arg
   per_process::Debug(DebugCategory::SEA, format, std::forward<Args>(args)...);
 }
 
+#ifdef HAVE_LIEF
 InjectOutput InjectIntoELF(const std::vector<uint8_t>& executable,
                            const std::string& note_name,
                            const std::vector<uint8_t>& data) {
@@ -292,6 +303,282 @@ InjectOutput InjectIntoPE(const std::vector<uint8_t>& 
   return InjectOutput{InjectResult::kSuccess, builder.get_build(), ""};
 }
 
+#else  // HAVE_LIEF
+
+// Native, LIEF-free ELF injector.
+//
+// Injection here is strictly append-only. The executable is linked with spare
+// Elf64_Phdr slots immediately after its program header table (see the port's
+// files/sea-pad.ld), so the blob can be added without moving that table:
+// FreeBSD's image activator requires the program header table to stay within
+// the first page (__elfN(phdr_in_zero_page), sys/kern/imgact_elf.c) and
+// rejects executables whose table was relocated to the end of the file.
+//
+// The blob is appended as a PT_NOTE with owner NODE_SEA_BLOB, covered by a new
+// PT_LOAD so that it is mapped at run time. That is exactly what
+// postject_find_resource() walks to via dl_iterate_phdr().
+
+namespace {
+
+constexpr size_t kElfHeaderSize = 64;
+constexpr size_t kPhdrEntSize = 56;
+constexpr uint32_t kPtLoad = 1;
+constexpr uint32_t kPtNote = 4;
+constexpr uint32_t kPtPhdr = 6;
+constexpr uint32_t kPfRead = 4;
+constexpr uint64_t kPageSize = 4096;
+// One PT_LOAD to map the appended note, one PT_NOTE to describe it.
+constexpr size_t kNeededPhdrSlots = 2;
+
+// Field offsets within Elf64_Ehdr and Elf64_Phdr.
+constexpr size_t kEhdrPhoff = 0x20;
+constexpr size_t kEhdrPhentsize = 0x36;
+constexpr size_t kEhdrPhnum = 0x38;
+constexpr size_t kPhdrType = 0x00;
+constexpr size_t kPhdrFlags = 0x04;
+constexpr size_t kPhdrOffset = 0x08;
+constexpr size_t kPhdrVaddr = 0x10;
+constexpr size_t kPhdrPaddr = 0x18;
+constexpr size_t kPhdrFilesz = 0x20;
+constexpr size_t kPhdrMemsz = 0x28;
+constexpr size_t kPhdrAlign = 0x30;
+
+uint16_t ReadU16(const std::vector<uint8_t>& d, size_t off) {
+  return static_cast<uint16_t>(d[off]) |
+         static_cast<uint16_t>(static_cast<uint16_t>(d[off + 1]) << 8);
+}
+
+uint32_t ReadU32(const std::vector<uint8_t>& d, size_t off) {
+  return static_cast<uint32_t>(ReadU16(d, off)) |
+         (static_cast<uint32_t>(ReadU16(d, off + 2)) << 16);
+}
+
+uint64_t ReadU64(const std::vector<uint8_t>& d, size_t off) {
+  return static_cast<uint64_t>(ReadU32(d, off)) |
+         (static_cast<uint64_t>(ReadU32(d, off + 4)) << 32);
+}
+
+void WriteU16(std::vector<uint8_t>* d, size_t off, uint16_t v) {
+  (*d)[off] = static_cast<uint8_t>(v & 0xff);
+  (*d)[off + 1] = static_cast<uint8_t>((v >> 8) & 0xff);
+}
+
+void WriteU32(std::vector<uint8_t>* d, size_t off, uint32_t v) {
+  WriteU16(d, off, static_cast<uint16_t>(v & 0xffff));
+  WriteU16(d, off + 2, static_cast<uint16_t>(v >> 16));
+}
+
+void WriteU64(std::vector<uint8_t>* d, size_t off, uint64_t v) {
+  WriteU32(d, off, static_cast<uint32_t>(v & 0xffffffff));
+  WriteU32(d, off + 4, static_cast<uint32_t>(v >> 32));
+}
+
+constexpr uint64_t AlignUp(uint64_t value, uint64_t alignment) {
+  return (value + alignment - 1) & ~(alignment - 1);
+}
+
+bool IsELF64LE(const std::vector<uint8_t>& exe) {
+  return exe.size() >= kElfHeaderSize && exe[0] == 0x7f && exe[1] == 'E' &&
+         exe[2] == 'L' && exe[3] == 'F' && exe[4] == 2 /* ELFCLASS64 */ &&
+         exe[5] == 1 /* ELFDATA2LSB */;
+}
+
+// Writes one Elf64_Phdr into d at off.
+void WritePhdr(std::vector<uint8_t>* d,
+               size_t off,
+               uint32_t type,
+               uint32_t flags,
+               uint64_t offset,
+               uint64_t vaddr,
+               uint64_t size,
+               uint64_t align) {
+  WriteU32(d, off + kPhdrType, type);
+  WriteU32(d, off + kPhdrFlags, flags);
+  WriteU64(d, off + kPhdrOffset, offset);
+  WriteU64(d, off + kPhdrVaddr, vaddr);
+  WriteU64(d, off + kPhdrPaddr, vaddr);
+  WriteU64(d, off + kPhdrFilesz, size);
+  WriteU64(d, off + kPhdrMemsz, size);
+  WriteU64(d, off + kPhdrAlign, align);
+}
+
+// Returns true if any note in the PT_NOTE segment at [offset, offset + size)
+// has the given owner name.
+bool SegmentHasNote(const std::vector<uint8_t>& exe,
+                    uint64_t offset,
+                    uint64_t size,
+                    const std::string& note_name) {
+  if (offset > exe.size() || size > exe.size() - offset) return false;
+  uint64_t pos = 0;
+  while (pos + 12 <= size) {
+    const uint32_t namesz = ReadU32(exe, offset + pos);
+    const uint32_t descsz = ReadU32(exe, offset + pos + 4);
+    const uint64_t name_padded = AlignUp(namesz, 4);
+    const uint64_t desc_padded = AlignUp(descsz, 4);
+    if (pos + 12 + name_padded + desc_padded > size) break;
+    if (namesz > 0) {
+      // The stored name may or may not include a trailing NUL; compare only
+      // as many bytes as the searched name has.
+      const char* name =
+          reinterpret_cast<const char*>(exe.data() + offset + pos + 12);
+      if (namesz >= note_name.size() &&
+          memcmp(name, note_name.data(), note_name.size()) == 0) {
+        return true;
+      }
+    }
+    pos += 12 + name_padded + desc_padded;
+  }
+  return false;
+}
+
+}  // anonymous namespace
+
+InjectOutput InjectIntoELF(const std::vector<uint8_t>& executable,
+                           const std::string& note_name,
+                           const std::vector<uint8_t>& data) {
+  DebugLog("Parsing ELF binary for injection...\n");
+  if (!IsELF64LE(executable)) {
+    return {InjectResult::kError,
+            {},
+            "Only 64-bit little-endian ELF executables are supported"};
+  }
+
+  const uint64_t e_phoff = ReadU64(executable, kEhdrPhoff);
+  const uint16_t e_phentsize = ReadU16(executable, kEhdrPhentsize);
+  const uint16_t e_phnum = ReadU16(executable, kEhdrPhnum);
+  if (e_phentsize != kPhdrEntSize || e_phnum == 0 ||
+      e_phoff + static_cast<uint64_t>(e_phnum) * e_phentsize >
+          executable.size()) {
+    return {InjectResult::kError, {}, "Malformed ELF program header table"};
+  }
+
+  // Walk the program headers to find PT_PHDR, the highest mapped address, the
+  // PT_LOAD that must keep covering the grown table, and any existing blob.
+  size_t phdr_slot = SIZE_MAX;
+  uint64_t max_vaddr_end = 0;
+  bool table_covered = false;
+  const uint64_t new_table_end =
+      e_phoff + (static_cast<uint64_t>(e_phnum) + kNeededPhdrSlots) *
+                    kPhdrEntSize;
+
+  DebugLog("Searching for existing note '%s'\n", note_name);
+  for (uint16_t i = 0; i < e_phnum; i++) {
+    const size_t ph = e_phoff + static_cast<size_t>(i) * kPhdrEntSize;
+    const uint32_t p_type = ReadU32(executable, ph + kPhdrType);
+    const uint64_t p_offset = ReadU64(executable, ph + kPhdrOffset);
+    const uint64_t p_vaddr = ReadU64(executable, ph + kPhdrVaddr);
+    const uint64_t p_filesz = ReadU64(executable, ph + kPhdrFilesz);
+    const uint64_t p_memsz = ReadU64(executable, ph + kPhdrMemsz);
+
+    if (p_type == kPtPhdr) {
+      phdr_slot = ph;
+    } else if (p_type == kPtLoad) {
+      max_vaddr_end = std::max(max_vaddr_end, p_vaddr + p_memsz);
+      if (p_offset <= e_phoff && new_table_end <= p_offset + p_filesz) {
+        table_covered = true;
+      }
+    } else if (p_type == kPtNote) {
+      if (SegmentHasNote(executable, p_offset, p_filesz, note_name)) {
+        DebugLog("Found existing note %s\n", note_name);
+        return {InjectResult::kAlreadyExists,
+                {},
+                SPrintF("note section %s already exists in the ELF executable",
+                        note_name)};
+      }
+    }
+  }
+
+  DebugLog("No existing note found. Proceeding to add new note.\n");
+
+  // The spare slots must exist, be unused, and leave the program header table
+  // inside the first page, which is where FreeBSD's image activator requires
+  // it. lld reserves and zero-fills them via the port's sea-pad.ld script.
+  const size_t table_end =
+      e_phoff + static_cast<size_t>(e_phnum) * kPhdrEntSize;
+  const size_t spare_bytes = kNeededPhdrSlots * kPhdrEntSize;
+  if (new_table_end > kPageSize) {
+    return {InjectResult::kError,
+            {},
+            "No room for the SEA program headers in the first page"};
+  }
+  if (table_end + spare_bytes > executable.size() ||
+      std::any_of(executable.begin() + table_end,
+                  executable.begin() + table_end + spare_bytes,
+                  [](uint8_t b) { return b != 0; })) {
+    return {InjectResult::kError,
+            {},
+            "Executable has no reserved program header slots: it must be "
+            "linked with the sea-pad.ld linker script"};
+  }
+  if (!table_covered) {
+    return {InjectResult::kError,
+            {},
+            "Reserved program header slots are not covered by a PT_LOAD"};
+  }
+  if (phdr_slot == SIZE_MAX) {
+    return {InjectResult::kError, {}, "Executable has no PT_PHDR segment"};
+  }
+
+  // Serialize the note: Elf64_Nhdr followed by the padded owner name and the
+  // padded blob.
+  const std::string owner = note_name;
+  const uint32_t namesz = static_cast<uint32_t>(owner.size() + 1);
+  const uint32_t descsz = static_cast<uint32_t>(data.size());
+  std::vector<uint8_t> note(12);
+  WriteU32(&note, 0, namesz);
+  WriteU32(&note, 4, descsz);
+  WriteU32(&note, 8, 0);  // n_type
+  note.insert(note.end(), owner.begin(), owner.end());
+  note.resize(12 + AlignUp(namesz, 4), 0);
+  note.insert(note.end(), data.begin(), data.end());
+  note.resize(AlignUp(note.size(), 4), 0);
+
+  // Append the note on a page boundary so that the new PT_LOAD satisfies
+  // p_offset % page == p_vaddr % page.
+  std::vector<uint8_t> out(executable);
+  out.resize(AlignUp(out.size(), kPageSize), 0);
+  const uint64_t note_offset = out.size();
+  const uint64_t note_vaddr = AlignUp(max_vaddr_end, kPageSize);
+  out.insert(out.end(), note.begin(), note.end());
+
+  DebugLog("Appending %zu byte note at offset %llu, vaddr %llu\n",
+           note.size(),
+           static_cast<unsigned long long>(note_offset),
+           static_cast<unsigned long long>(note_vaddr));
+
+  // Fill the reserved slots: PT_LOAD maps the note, PT_NOTE describes it.
+  WritePhdr(&out,
+            table_end,
+            kPtLoad,
+            kPfRead,
+            note_offset,
+            note_vaddr,
+            note.size(),
+            kPageSize);
+  WritePhdr(&out,
+            table_end + kPhdrEntSize,
+            kPtNote,
+            kPfRead,
+            note_offset,
+            note_vaddr,
+            note.size(),
+            4);
+
+  // Publish the new entries and grow PT_PHDR to cover them.
+  WriteU16(&out, kEhdrPhnum, static_cast<uint16_t>(e_phnum + kNeededPhdrSlots));
+  WriteU64(&out,
+           phdr_slot + kPhdrFilesz,
+           ReadU64(out, phdr_slot + kPhdrFilesz) + spare_bytes);
+  WriteU64(&out,
+           phdr_slot + kPhdrMemsz,
+           ReadU64(out, phdr_slot + kPhdrMemsz) + spare_bytes);
+
+  DebugLog("Built modified ELF binary with new note.\n");
+  return InjectOutput{InjectResult::kSuccess, std::move(out), ""};
+}
+
+#endif  // HAVE_LIEF
+
 void MarkSentinel(InjectOutput* output, const std::string& sentinel_fuse) {
   if (output == nullptr || output->result != InjectResult::kSuccess) return;
   std::string_view fuse(sentinel_fuse);
@@ -355,6 +642,12 @@ InjectOutput InjectResource(const std::vector<uint8_t>
                             const std::string& resource_name,
                             const std::vector<uint8_t>& res,
                             const std::string& macho_segment_name) {
+#ifndef HAVE_LIEF
+  (void)macho_segment_name;
+  if (IsELF64LE(exe)) {
+    return InjectIntoELF(exe, resource_name, res);
+  }
+#else
   if (LIEF::ELF::is_elf(exe)) {
     return InjectIntoELF(exe, resource_name, res);
   } else if (LIEF::MachO::is_macho(exe)) {
@@ -371,6 +664,7 @@ InjectOutput InjectResource(const std::vector<uint8_t>
                    [](unsigned char c) { return std::toupper(c); });
     return InjectIntoPE(exe, upper_name, res);
   }
+#endif  // HAVE_LIEF
 
   return {InjectResult::kUnknownFormat,
           {},
@@ -478,7 +772,7 @@ ExitCode BuildSingleExecutable(const std::string& sea_
       " single executable applications.\n");
   return ExitCode::kGenericUserError;
 }
-#endif  // HAVE_LIEF
+#endif  // defined(HAVE_LIEF) || defined(HAVE_NATIVE_ELF_SEA)
 
 }  // namespace sea
 }  // namespace node
