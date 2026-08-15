/* Unicode character-class / rtree globals.
 *
 * Kept in a dedicated Mach-O section so they cannot overlap Zig/LLVM
 * GlobalMerge BSS (which on Darwin ReleaseFast can be under-sized by
 * dead-strip when MergedGlobals has size 0 in the symbol table).
 */
#include "types.h"

#define JOE_UCLS __attribute__((section("__DATA,__joe_ucls")))

struct Cclass JOE_UCLS cclass_upper[1] = {{0}};
struct Cclass JOE_UCLS cclass_lower[1] = {{0}};
struct Cclass JOE_UCLS cclass_alpha[1] = {{0}};
struct Cclass JOE_UCLS cclass_alpha_[1] = {{0}};
struct Cclass JOE_UCLS cclass_notalpha_[1] = {{0}};
struct Cclass JOE_UCLS cclass_alnum[1] = {{0}};
struct Cclass JOE_UCLS cclass_alnum_[1] = {{0}};
struct Cclass JOE_UCLS cclass_notalnum_[1] = {{0}};
struct Cclass JOE_UCLS cclass_digit[1] = {{0}};
struct Cclass JOE_UCLS cclass_notdigit[1] = {{0}};
struct Cclass JOE_UCLS cclass_xdigit[1] = {{0}};
struct Cclass JOE_UCLS cclass_punct[1] = {{0}};
struct Cclass JOE_UCLS cclass_space[1] = {{0}};
struct Cclass JOE_UCLS cclass_notspace[1] = {{0}};
struct Cclass JOE_UCLS cclass_blank[1] = {{0}};
struct Cclass JOE_UCLS cclass_ctrl[1] = {{0}};
struct Cclass JOE_UCLS cclass_graph[1] = {{0}};
struct Cclass JOE_UCLS cclass_print[1] = {{0}};
struct Cclass JOE_UCLS cclass_word[1] = {{0}};
struct Cclass JOE_UCLS cclass_notword[1] = {{0}};
struct Cclass JOE_UCLS cclass_combining[1] = {{0}};
struct Cclass JOE_UCLS cclass_double[1] = {{0}};

struct Rtree JOE_UCLS rtree_tolower[1] = {{0}};
struct Rtree JOE_UCLS rtree_toupper[1] = {{0}};
struct Rtree JOE_UCLS rtree_fold[1] = {{0}};

struct Hash * JOE_UCLS unicat_hash = 0;
