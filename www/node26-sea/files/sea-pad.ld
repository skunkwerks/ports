/*
 * Reserve spare Elf64_Phdr slots for "node --build-sea".
 *
 * Injecting a single executable application blob adds a PT_LOAD and a PT_NOTE
 * to the program header table. FreeBSD's image activator requires that table
 * to stay within the first page (__elfN(phdr_in_zero_page) in
 * sys/kern/imgact_elf.c) and rejects executables whose table was relocated to
 * the end of the file, which is what a general purpose ELF rewriter has to do
 * once the table no longer fits in place.
 *
 * Reserving room here keeps injection append-only: the entries are written
 * into this zero filled gap, the table never moves, and nothing else in the
 * binary shifts. 448 bytes are 8 Elf64_Phdr slots, of which the injector uses
 * two.
 *
 * INSERT BEFORE augments the linker's default script rather than replacing it,
 * so the rest of the layout is untouched. The gap lands immediately after the
 * program header table, inside the first PT_LOAD, in page zero.
 */
SECTIONS
{
  .sea.phdr.pad : { . += 448; }
} INSERT BEFORE .interp;
