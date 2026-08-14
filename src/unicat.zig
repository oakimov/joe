//! Unicode category tables — replaces `joe/unicat-17.0.0.c`.
//!
//! Faithful C-ABI Path A port of JOE Unicode interval/category data tables.

const std = @import("std");
const ptrdiff_t = c_long;

pub const struct_interval = extern struct {
    first: c_int = 0,
    last: c_int = 0,
};
pub const struct_unicat = extern struct {
    name: [*c]const u8 = null,
    len: c_int = 0,
    intervals: [*c]const struct_interval = null,
};
pub export const uniblocks: [346]struct_interval = [346]struct_interval{
    struct_interval{
        .first = 0,
        .last = 127,
    },
    struct_interval{
        .first = 128,
        .last = 255,
    },
    struct_interval{
        .first = 256,
        .last = 383,
    },
    struct_interval{
        .first = 384,
        .last = 591,
    },
    struct_interval{
        .first = 592,
        .last = 687,
    },
    struct_interval{
        .first = 688,
        .last = 767,
    },
    struct_interval{
        .first = 768,
        .last = 879,
    },
    struct_interval{
        .first = 880,
        .last = 1023,
    },
    struct_interval{
        .first = 1024,
        .last = 1279,
    },
    struct_interval{
        .first = 1280,
        .last = 1327,
    },
    struct_interval{
        .first = 1328,
        .last = 1423,
    },
    struct_interval{
        .first = 1424,
        .last = 1535,
    },
    struct_interval{
        .first = 1536,
        .last = 1791,
    },
    struct_interval{
        .first = 1792,
        .last = 1871,
    },
    struct_interval{
        .first = 1872,
        .last = 1919,
    },
    struct_interval{
        .first = 1920,
        .last = 1983,
    },
    struct_interval{
        .first = 1984,
        .last = 2047,
    },
    struct_interval{
        .first = 2048,
        .last = 2111,
    },
    struct_interval{
        .first = 2112,
        .last = 2143,
    },
    struct_interval{
        .first = 2144,
        .last = 2159,
    },
    struct_interval{
        .first = 2160,
        .last = 2207,
    },
    struct_interval{
        .first = 2208,
        .last = 2303,
    },
    struct_interval{
        .first = 2304,
        .last = 2431,
    },
    struct_interval{
        .first = 2432,
        .last = 2559,
    },
    struct_interval{
        .first = 2560,
        .last = 2687,
    },
    struct_interval{
        .first = 2688,
        .last = 2815,
    },
    struct_interval{
        .first = 2816,
        .last = 2943,
    },
    struct_interval{
        .first = 2944,
        .last = 3071,
    },
    struct_interval{
        .first = 3072,
        .last = 3199,
    },
    struct_interval{
        .first = 3200,
        .last = 3327,
    },
    struct_interval{
        .first = 3328,
        .last = 3455,
    },
    struct_interval{
        .first = 3456,
        .last = 3583,
    },
    struct_interval{
        .first = 3584,
        .last = 3711,
    },
    struct_interval{
        .first = 3712,
        .last = 3839,
    },
    struct_interval{
        .first = 3840,
        .last = 4095,
    },
    struct_interval{
        .first = 4096,
        .last = 4255,
    },
    struct_interval{
        .first = 4256,
        .last = 4351,
    },
    struct_interval{
        .first = 4352,
        .last = 4607,
    },
    struct_interval{
        .first = 4608,
        .last = 4991,
    },
    struct_interval{
        .first = 4992,
        .last = 5023,
    },
    struct_interval{
        .first = 5024,
        .last = 5119,
    },
    struct_interval{
        .first = 5120,
        .last = 5759,
    },
    struct_interval{
        .first = 5760,
        .last = 5791,
    },
    struct_interval{
        .first = 5792,
        .last = 5887,
    },
    struct_interval{
        .first = 5888,
        .last = 5919,
    },
    struct_interval{
        .first = 5920,
        .last = 5951,
    },
    struct_interval{
        .first = 5952,
        .last = 5983,
    },
    struct_interval{
        .first = 5984,
        .last = 6015,
    },
    struct_interval{
        .first = 6016,
        .last = 6143,
    },
    struct_interval{
        .first = 6144,
        .last = 6319,
    },
    struct_interval{
        .first = 6320,
        .last = 6399,
    },
    struct_interval{
        .first = 6400,
        .last = 6479,
    },
    struct_interval{
        .first = 6480,
        .last = 6527,
    },
    struct_interval{
        .first = 6528,
        .last = 6623,
    },
    struct_interval{
        .first = 6624,
        .last = 6655,
    },
    struct_interval{
        .first = 6656,
        .last = 6687,
    },
    struct_interval{
        .first = 6688,
        .last = 6831,
    },
    struct_interval{
        .first = 6832,
        .last = 6911,
    },
    struct_interval{
        .first = 6912,
        .last = 7039,
    },
    struct_interval{
        .first = 7040,
        .last = 7103,
    },
    struct_interval{
        .first = 7104,
        .last = 7167,
    },
    struct_interval{
        .first = 7168,
        .last = 7247,
    },
    struct_interval{
        .first = 7248,
        .last = 7295,
    },
    struct_interval{
        .first = 7296,
        .last = 7311,
    },
    struct_interval{
        .first = 7312,
        .last = 7359,
    },
    struct_interval{
        .first = 7360,
        .last = 7375,
    },
    struct_interval{
        .first = 7376,
        .last = 7423,
    },
    struct_interval{
        .first = 7424,
        .last = 7551,
    },
    struct_interval{
        .first = 7552,
        .last = 7615,
    },
    struct_interval{
        .first = 7616,
        .last = 7679,
    },
    struct_interval{
        .first = 7680,
        .last = 7935,
    },
    struct_interval{
        .first = 7936,
        .last = 8191,
    },
    struct_interval{
        .first = 8192,
        .last = 8303,
    },
    struct_interval{
        .first = 8304,
        .last = 8351,
    },
    struct_interval{
        .first = 8352,
        .last = 8399,
    },
    struct_interval{
        .first = 8400,
        .last = 8447,
    },
    struct_interval{
        .first = 8448,
        .last = 8527,
    },
    struct_interval{
        .first = 8528,
        .last = 8591,
    },
    struct_interval{
        .first = 8592,
        .last = 8703,
    },
    struct_interval{
        .first = 8704,
        .last = 8959,
    },
    struct_interval{
        .first = 8960,
        .last = 9215,
    },
    struct_interval{
        .first = 9216,
        .last = 9279,
    },
    struct_interval{
        .first = 9280,
        .last = 9311,
    },
    struct_interval{
        .first = 9312,
        .last = 9471,
    },
    struct_interval{
        .first = 9472,
        .last = 9599,
    },
    struct_interval{
        .first = 9600,
        .last = 9631,
    },
    struct_interval{
        .first = 9632,
        .last = 9727,
    },
    struct_interval{
        .first = 9728,
        .last = 9983,
    },
    struct_interval{
        .first = 9984,
        .last = 10175,
    },
    struct_interval{
        .first = 10176,
        .last = 10223,
    },
    struct_interval{
        .first = 10224,
        .last = 10239,
    },
    struct_interval{
        .first = 10240,
        .last = 10495,
    },
    struct_interval{
        .first = 10496,
        .last = 10623,
    },
    struct_interval{
        .first = 10624,
        .last = 10751,
    },
    struct_interval{
        .first = 10752,
        .last = 11007,
    },
    struct_interval{
        .first = 11008,
        .last = 11263,
    },
    struct_interval{
        .first = 11264,
        .last = 11359,
    },
    struct_interval{
        .first = 11360,
        .last = 11391,
    },
    struct_interval{
        .first = 11392,
        .last = 11519,
    },
    struct_interval{
        .first = 11520,
        .last = 11567,
    },
    struct_interval{
        .first = 11568,
        .last = 11647,
    },
    struct_interval{
        .first = 11648,
        .last = 11743,
    },
    struct_interval{
        .first = 11744,
        .last = 11775,
    },
    struct_interval{
        .first = 11776,
        .last = 11903,
    },
    struct_interval{
        .first = 11904,
        .last = 12031,
    },
    struct_interval{
        .first = 12032,
        .last = 12255,
    },
    struct_interval{
        .first = 12272,
        .last = 12287,
    },
    struct_interval{
        .first = 12288,
        .last = 12351,
    },
    struct_interval{
        .first = 12352,
        .last = 12447,
    },
    struct_interval{
        .first = 12448,
        .last = 12543,
    },
    struct_interval{
        .first = 12544,
        .last = 12591,
    },
    struct_interval{
        .first = 12592,
        .last = 12687,
    },
    struct_interval{
        .first = 12688,
        .last = 12703,
    },
    struct_interval{
        .first = 12704,
        .last = 12735,
    },
    struct_interval{
        .first = 12736,
        .last = 12783,
    },
    struct_interval{
        .first = 12784,
        .last = 12799,
    },
    struct_interval{
        .first = 12800,
        .last = 13055,
    },
    struct_interval{
        .first = 13056,
        .last = 13311,
    },
    struct_interval{
        .first = 13312,
        .last = 19903,
    },
    struct_interval{
        .first = 19904,
        .last = 19967,
    },
    struct_interval{
        .first = 19968,
        .last = 40959,
    },
    struct_interval{
        .first = 40960,
        .last = 42127,
    },
    struct_interval{
        .first = 42128,
        .last = 42191,
    },
    struct_interval{
        .first = 42192,
        .last = 42239,
    },
    struct_interval{
        .first = 42240,
        .last = 42559,
    },
    struct_interval{
        .first = 42560,
        .last = 42655,
    },
    struct_interval{
        .first = 42656,
        .last = 42751,
    },
    struct_interval{
        .first = 42752,
        .last = 42783,
    },
    struct_interval{
        .first = 42784,
        .last = 43007,
    },
    struct_interval{
        .first = 43008,
        .last = 43055,
    },
    struct_interval{
        .first = 43056,
        .last = 43071,
    },
    struct_interval{
        .first = 43072,
        .last = 43135,
    },
    struct_interval{
        .first = 43136,
        .last = 43231,
    },
    struct_interval{
        .first = 43232,
        .last = 43263,
    },
    struct_interval{
        .first = 43264,
        .last = 43311,
    },
    struct_interval{
        .first = 43312,
        .last = 43359,
    },
    struct_interval{
        .first = 43360,
        .last = 43391,
    },
    struct_interval{
        .first = 43392,
        .last = 43487,
    },
    struct_interval{
        .first = 43488,
        .last = 43519,
    },
    struct_interval{
        .first = 43520,
        .last = 43615,
    },
    struct_interval{
        .first = 43616,
        .last = 43647,
    },
    struct_interval{
        .first = 43648,
        .last = 43743,
    },
    struct_interval{
        .first = 43744,
        .last = 43775,
    },
    struct_interval{
        .first = 43776,
        .last = 43823,
    },
    struct_interval{
        .first = 43824,
        .last = 43887,
    },
    struct_interval{
        .first = 43888,
        .last = 43967,
    },
    struct_interval{
        .first = 43968,
        .last = 44031,
    },
    struct_interval{
        .first = 44032,
        .last = 55215,
    },
    struct_interval{
        .first = 55216,
        .last = 55295,
    },
    struct_interval{
        .first = 55296,
        .last = 56191,
    },
    struct_interval{
        .first = 56192,
        .last = 56319,
    },
    struct_interval{
        .first = 56320,
        .last = 57343,
    },
    struct_interval{
        .first = 57344,
        .last = 63743,
    },
    struct_interval{
        .first = 63744,
        .last = 64255,
    },
    struct_interval{
        .first = 64256,
        .last = 64335,
    },
    struct_interval{
        .first = 64336,
        .last = 65023,
    },
    struct_interval{
        .first = 65024,
        .last = 65039,
    },
    struct_interval{
        .first = 65040,
        .last = 65055,
    },
    struct_interval{
        .first = 65056,
        .last = 65071,
    },
    struct_interval{
        .first = 65072,
        .last = 65103,
    },
    struct_interval{
        .first = 65104,
        .last = 65135,
    },
    struct_interval{
        .first = 65136,
        .last = 65279,
    },
    struct_interval{
        .first = 65280,
        .last = 65519,
    },
    struct_interval{
        .first = 65520,
        .last = 65535,
    },
    struct_interval{
        .first = 65536,
        .last = 65663,
    },
    struct_interval{
        .first = 65664,
        .last = 65791,
    },
    struct_interval{
        .first = 65792,
        .last = 65855,
    },
    struct_interval{
        .first = 65856,
        .last = 65935,
    },
    struct_interval{
        .first = 65936,
        .last = 65999,
    },
    struct_interval{
        .first = 66000,
        .last = 66047,
    },
    struct_interval{
        .first = 66176,
        .last = 66207,
    },
    struct_interval{
        .first = 66208,
        .last = 66271,
    },
    struct_interval{
        .first = 66272,
        .last = 66303,
    },
    struct_interval{
        .first = 66304,
        .last = 66351,
    },
    struct_interval{
        .first = 66352,
        .last = 66383,
    },
    struct_interval{
        .first = 66384,
        .last = 66431,
    },
    struct_interval{
        .first = 66432,
        .last = 66463,
    },
    struct_interval{
        .first = 66464,
        .last = 66527,
    },
    struct_interval{
        .first = 66560,
        .last = 66639,
    },
    struct_interval{
        .first = 66640,
        .last = 66687,
    },
    struct_interval{
        .first = 66688,
        .last = 66735,
    },
    struct_interval{
        .first = 66736,
        .last = 66815,
    },
    struct_interval{
        .first = 66816,
        .last = 66863,
    },
    struct_interval{
        .first = 66864,
        .last = 66927,
    },
    struct_interval{
        .first = 66928,
        .last = 67007,
    },
    struct_interval{
        .first = 67008,
        .last = 67071,
    },
    struct_interval{
        .first = 67072,
        .last = 67455,
    },
    struct_interval{
        .first = 67456,
        .last = 67519,
    },
    struct_interval{
        .first = 67584,
        .last = 67647,
    },
    struct_interval{
        .first = 67648,
        .last = 67679,
    },
    struct_interval{
        .first = 67680,
        .last = 67711,
    },
    struct_interval{
        .first = 67712,
        .last = 67759,
    },
    struct_interval{
        .first = 67808,
        .last = 67839,
    },
    struct_interval{
        .first = 67840,
        .last = 67871,
    },
    struct_interval{
        .first = 67872,
        .last = 67903,
    },
    struct_interval{
        .first = 67904,
        .last = 67935,
    },
    struct_interval{
        .first = 67968,
        .last = 67999,
    },
    struct_interval{
        .first = 68000,
        .last = 68095,
    },
    struct_interval{
        .first = 68096,
        .last = 68191,
    },
    struct_interval{
        .first = 68192,
        .last = 68223,
    },
    struct_interval{
        .first = 68224,
        .last = 68255,
    },
    struct_interval{
        .first = 68288,
        .last = 68351,
    },
    struct_interval{
        .first = 68352,
        .last = 68415,
    },
    struct_interval{
        .first = 68416,
        .last = 68447,
    },
    struct_interval{
        .first = 68448,
        .last = 68479,
    },
    struct_interval{
        .first = 68480,
        .last = 68527,
    },
    struct_interval{
        .first = 68608,
        .last = 68687,
    },
    struct_interval{
        .first = 68736,
        .last = 68863,
    },
    struct_interval{
        .first = 68864,
        .last = 68927,
    },
    struct_interval{
        .first = 68928,
        .last = 69007,
    },
    struct_interval{
        .first = 69216,
        .last = 69247,
    },
    struct_interval{
        .first = 69248,
        .last = 69311,
    },
    struct_interval{
        .first = 69312,
        .last = 69375,
    },
    struct_interval{
        .first = 69376,
        .last = 69423,
    },
    struct_interval{
        .first = 69424,
        .last = 69487,
    },
    struct_interval{
        .first = 69488,
        .last = 69551,
    },
    struct_interval{
        .first = 69552,
        .last = 69599,
    },
    struct_interval{
        .first = 69600,
        .last = 69631,
    },
    struct_interval{
        .first = 69632,
        .last = 69759,
    },
    struct_interval{
        .first = 69760,
        .last = 69839,
    },
    struct_interval{
        .first = 69840,
        .last = 69887,
    },
    struct_interval{
        .first = 69888,
        .last = 69967,
    },
    struct_interval{
        .first = 69968,
        .last = 70015,
    },
    struct_interval{
        .first = 70016,
        .last = 70111,
    },
    struct_interval{
        .first = 70112,
        .last = 70143,
    },
    struct_interval{
        .first = 70144,
        .last = 70223,
    },
    struct_interval{
        .first = 70272,
        .last = 70319,
    },
    struct_interval{
        .first = 70320,
        .last = 70399,
    },
    struct_interval{
        .first = 70400,
        .last = 70527,
    },
    struct_interval{
        .first = 70528,
        .last = 70655,
    },
    struct_interval{
        .first = 70656,
        .last = 70783,
    },
    struct_interval{
        .first = 70784,
        .last = 70879,
    },
    struct_interval{
        .first = 71040,
        .last = 71167,
    },
    struct_interval{
        .first = 71168,
        .last = 71263,
    },
    struct_interval{
        .first = 71264,
        .last = 71295,
    },
    struct_interval{
        .first = 71296,
        .last = 71375,
    },
    struct_interval{
        .first = 71376,
        .last = 71423,
    },
    struct_interval{
        .first = 71424,
        .last = 71503,
    },
    struct_interval{
        .first = 71680,
        .last = 71759,
    },
    struct_interval{
        .first = 71840,
        .last = 71935,
    },
    struct_interval{
        .first = 71936,
        .last = 72031,
    },
    struct_interval{
        .first = 72096,
        .last = 72191,
    },
    struct_interval{
        .first = 72192,
        .last = 72271,
    },
    struct_interval{
        .first = 72272,
        .last = 72367,
    },
    struct_interval{
        .first = 72368,
        .last = 72383,
    },
    struct_interval{
        .first = 72384,
        .last = 72447,
    },
    struct_interval{
        .first = 72448,
        .last = 72543,
    },
    struct_interval{
        .first = 72544,
        .last = 72575,
    },
    struct_interval{
        .first = 72640,
        .last = 72703,
    },
    struct_interval{
        .first = 72704,
        .last = 72815,
    },
    struct_interval{
        .first = 72816,
        .last = 72895,
    },
    struct_interval{
        .first = 72960,
        .last = 73055,
    },
    struct_interval{
        .first = 73056,
        .last = 73135,
    },
    struct_interval{
        .first = 73136,
        .last = 73199,
    },
    struct_interval{
        .first = 73440,
        .last = 73471,
    },
    struct_interval{
        .first = 73472,
        .last = 73567,
    },
    struct_interval{
        .first = 73648,
        .last = 73663,
    },
    struct_interval{
        .first = 73664,
        .last = 73727,
    },
    struct_interval{
        .first = 73728,
        .last = 74751,
    },
    struct_interval{
        .first = 74752,
        .last = 74879,
    },
    struct_interval{
        .first = 74880,
        .last = 75087,
    },
    struct_interval{
        .first = 77712,
        .last = 77823,
    },
    struct_interval{
        .first = 77824,
        .last = 78895,
    },
    struct_interval{
        .first = 78896,
        .last = 78943,
    },
    struct_interval{
        .first = 78944,
        .last = 82943,
    },
    struct_interval{
        .first = 82944,
        .last = 83583,
    },
    struct_interval{
        .first = 90368,
        .last = 90431,
    },
    struct_interval{
        .first = 92160,
        .last = 92735,
    },
    struct_interval{
        .first = 92736,
        .last = 92783,
    },
    struct_interval{
        .first = 92784,
        .last = 92879,
    },
    struct_interval{
        .first = 92880,
        .last = 92927,
    },
    struct_interval{
        .first = 92928,
        .last = 93071,
    },
    struct_interval{
        .first = 93504,
        .last = 93567,
    },
    struct_interval{
        .first = 93760,
        .last = 93855,
    },
    struct_interval{
        .first = 93856,
        .last = 93919,
    },
    struct_interval{
        .first = 93952,
        .last = 94111,
    },
    struct_interval{
        .first = 94176,
        .last = 94207,
    },
    struct_interval{
        .first = 94208,
        .last = 100351,
    },
    struct_interval{
        .first = 100352,
        .last = 101119,
    },
    struct_interval{
        .first = 101120,
        .last = 101631,
    },
    struct_interval{
        .first = 101632,
        .last = 101759,
    },
    struct_interval{
        .first = 101760,
        .last = 101887,
    },
    struct_interval{
        .first = 110576,
        .last = 110591,
    },
    struct_interval{
        .first = 110592,
        .last = 110847,
    },
    struct_interval{
        .first = 110848,
        .last = 110895,
    },
    struct_interval{
        .first = 110896,
        .last = 110959,
    },
    struct_interval{
        .first = 110960,
        .last = 111359,
    },
    struct_interval{
        .first = 113664,
        .last = 113823,
    },
    struct_interval{
        .first = 113824,
        .last = 113839,
    },
    struct_interval{
        .first = 117760,
        .last = 118463,
    },
    struct_interval{
        .first = 118464,
        .last = 118527,
    },
    struct_interval{
        .first = 118528,
        .last = 118735,
    },
    struct_interval{
        .first = 118784,
        .last = 119039,
    },
    struct_interval{
        .first = 119040,
        .last = 119295,
    },
    struct_interval{
        .first = 119296,
        .last = 119375,
    },
    struct_interval{
        .first = 119488,
        .last = 119519,
    },
    struct_interval{
        .first = 119520,
        .last = 119551,
    },
    struct_interval{
        .first = 119552,
        .last = 119647,
    },
    struct_interval{
        .first = 119648,
        .last = 119679,
    },
    struct_interval{
        .first = 119808,
        .last = 120831,
    },
    struct_interval{
        .first = 120832,
        .last = 121519,
    },
    struct_interval{
        .first = 122624,
        .last = 122879,
    },
    struct_interval{
        .first = 122880,
        .last = 122927,
    },
    struct_interval{
        .first = 122928,
        .last = 123023,
    },
    struct_interval{
        .first = 123136,
        .last = 123215,
    },
    struct_interval{
        .first = 123536,
        .last = 123583,
    },
    struct_interval{
        .first = 123584,
        .last = 123647,
    },
    struct_interval{
        .first = 124112,
        .last = 124159,
    },
    struct_interval{
        .first = 124368,
        .last = 124415,
    },
    struct_interval{
        .first = 124608,
        .last = 124671,
    },
    struct_interval{
        .first = 124896,
        .last = 124927,
    },
    struct_interval{
        .first = 124928,
        .last = 125151,
    },
    struct_interval{
        .first = 125184,
        .last = 125279,
    },
    struct_interval{
        .first = 126064,
        .last = 126143,
    },
    struct_interval{
        .first = 126208,
        .last = 126287,
    },
    struct_interval{
        .first = 126464,
        .last = 126719,
    },
    struct_interval{
        .first = 126976,
        .last = 127023,
    },
    struct_interval{
        .first = 127024,
        .last = 127135,
    },
    struct_interval{
        .first = 127136,
        .last = 127231,
    },
    struct_interval{
        .first = 127232,
        .last = 127487,
    },
    struct_interval{
        .first = 127488,
        .last = 127743,
    },
    struct_interval{
        .first = 127744,
        .last = 128511,
    },
    struct_interval{
        .first = 128512,
        .last = 128591,
    },
    struct_interval{
        .first = 128592,
        .last = 128639,
    },
    struct_interval{
        .first = 128640,
        .last = 128767,
    },
    struct_interval{
        .first = 128768,
        .last = 128895,
    },
    struct_interval{
        .first = 128896,
        .last = 129023,
    },
    struct_interval{
        .first = 129024,
        .last = 129279,
    },
    struct_interval{
        .first = 129280,
        .last = 129535,
    },
    struct_interval{
        .first = 129536,
        .last = 129647,
    },
    struct_interval{
        .first = 129648,
        .last = 129791,
    },
    struct_interval{
        .first = 129792,
        .last = 130047,
    },
    struct_interval{
        .first = 131072,
        .last = 173791,
    },
    struct_interval{
        .first = 173824,
        .last = 177983,
    },
    struct_interval{
        .first = 177984,
        .last = 178207,
    },
    struct_interval{
        .first = 178208,
        .last = 183983,
    },
    struct_interval{
        .first = 183984,
        .last = 191471,
    },
    struct_interval{
        .first = 191472,
        .last = 192095,
    },
    struct_interval{
        .first = 194560,
        .last = 195103,
    },
    struct_interval{
        .first = 196608,
        .last = 201551,
    },
    struct_interval{
        .first = 201552,
        .last = 205743,
    },
    struct_interval{
        .first = 205744,
        .last = 210047,
    },
    struct_interval{
        .first = 917504,
        .last = 917631,
    },
    struct_interval{
        .first = 917760,
        .last = 917999,
    },
    struct_interval{
        .first = 983040,
        .last = 1048575,
    },
    struct_interval{
        .first = 1048576,
        .last = 1114111,
    },
};
pub export const Co_table: [3]struct_interval = [3]struct_interval{
    struct_interval{
        .first = 57344,
        .last = 63743,
    },
    struct_interval{
        .first = 983040,
        .last = 1048573,
    },
    struct_interval{
        .first = 1048576,
        .last = 1114109,
    },
};
pub export const Cs_table: [1]struct_interval = [1]struct_interval{
    struct_interval{
        .first = 55296,
        .last = 57343,
    },
};
pub export const Zp_table: [1]struct_interval = [1]struct_interval{
    struct_interval{
        .first = 8233,
        .last = 8233,
    },
};
pub export const Zl_table: [1]struct_interval = [1]struct_interval{
    struct_interval{
        .first = 8232,
        .last = 8232,
    },
};
pub export const Nl_table: [13]struct_interval = [13]struct_interval{
    struct_interval{
        .first = 5870,
        .last = 5872,
    },
    struct_interval{
        .first = 8544,
        .last = 8578,
    },
    struct_interval{
        .first = 8581,
        .last = 8584,
    },
    struct_interval{
        .first = 12295,
        .last = 12295,
    },
    struct_interval{
        .first = 12321,
        .last = 12329,
    },
    struct_interval{
        .first = 12344,
        .last = 12346,
    },
    struct_interval{
        .first = 42726,
        .last = 42735,
    },
    struct_interval{
        .first = 65856,
        .last = 65908,
    },
    struct_interval{
        .first = 66369,
        .last = 66369,
    },
    struct_interval{
        .first = 66378,
        .last = 66378,
    },
    struct_interval{
        .first = 66513,
        .last = 66517,
    },
    struct_interval{
        .first = 74752,
        .last = 74862,
    },
    struct_interval{
        .first = 94196,
        .last = 94198,
    },
};
pub export const Mc_table: [193]struct_interval = [193]struct_interval{
    struct_interval{
        .first = 2307,
        .last = 2307,
    },
    struct_interval{
        .first = 2363,
        .last = 2363,
    },
    struct_interval{
        .first = 2366,
        .last = 2368,
    },
    struct_interval{
        .first = 2377,
        .last = 2380,
    },
    struct_interval{
        .first = 2382,
        .last = 2383,
    },
    struct_interval{
        .first = 2434,
        .last = 2435,
    },
    struct_interval{
        .first = 2494,
        .last = 2496,
    },
    struct_interval{
        .first = 2503,
        .last = 2504,
    },
    struct_interval{
        .first = 2507,
        .last = 2508,
    },
    struct_interval{
        .first = 2519,
        .last = 2519,
    },
    struct_interval{
        .first = 2563,
        .last = 2563,
    },
    struct_interval{
        .first = 2622,
        .last = 2624,
    },
    struct_interval{
        .first = 2691,
        .last = 2691,
    },
    struct_interval{
        .first = 2750,
        .last = 2752,
    },
    struct_interval{
        .first = 2761,
        .last = 2761,
    },
    struct_interval{
        .first = 2763,
        .last = 2764,
    },
    struct_interval{
        .first = 2818,
        .last = 2819,
    },
    struct_interval{
        .first = 2878,
        .last = 2878,
    },
    struct_interval{
        .first = 2880,
        .last = 2880,
    },
    struct_interval{
        .first = 2887,
        .last = 2888,
    },
    struct_interval{
        .first = 2891,
        .last = 2892,
    },
    struct_interval{
        .first = 2903,
        .last = 2903,
    },
    struct_interval{
        .first = 3006,
        .last = 3007,
    },
    struct_interval{
        .first = 3009,
        .last = 3010,
    },
    struct_interval{
        .first = 3014,
        .last = 3016,
    },
    struct_interval{
        .first = 3018,
        .last = 3020,
    },
    struct_interval{
        .first = 3031,
        .last = 3031,
    },
    struct_interval{
        .first = 3073,
        .last = 3075,
    },
    struct_interval{
        .first = 3137,
        .last = 3140,
    },
    struct_interval{
        .first = 3202,
        .last = 3203,
    },
    struct_interval{
        .first = 3262,
        .last = 3262,
    },
    struct_interval{
        .first = 3264,
        .last = 3268,
    },
    struct_interval{
        .first = 3271,
        .last = 3272,
    },
    struct_interval{
        .first = 3274,
        .last = 3275,
    },
    struct_interval{
        .first = 3285,
        .last = 3286,
    },
    struct_interval{
        .first = 3315,
        .last = 3315,
    },
    struct_interval{
        .first = 3330,
        .last = 3331,
    },
    struct_interval{
        .first = 3390,
        .last = 3392,
    },
    struct_interval{
        .first = 3398,
        .last = 3400,
    },
    struct_interval{
        .first = 3402,
        .last = 3404,
    },
    struct_interval{
        .first = 3415,
        .last = 3415,
    },
    struct_interval{
        .first = 3458,
        .last = 3459,
    },
    struct_interval{
        .first = 3535,
        .last = 3537,
    },
    struct_interval{
        .first = 3544,
        .last = 3551,
    },
    struct_interval{
        .first = 3570,
        .last = 3571,
    },
    struct_interval{
        .first = 3902,
        .last = 3903,
    },
    struct_interval{
        .first = 3967,
        .last = 3967,
    },
    struct_interval{
        .first = 4139,
        .last = 4140,
    },
    struct_interval{
        .first = 4145,
        .last = 4145,
    },
    struct_interval{
        .first = 4152,
        .last = 4152,
    },
    struct_interval{
        .first = 4155,
        .last = 4156,
    },
    struct_interval{
        .first = 4182,
        .last = 4183,
    },
    struct_interval{
        .first = 4194,
        .last = 4196,
    },
    struct_interval{
        .first = 4199,
        .last = 4205,
    },
    struct_interval{
        .first = 4227,
        .last = 4228,
    },
    struct_interval{
        .first = 4231,
        .last = 4236,
    },
    struct_interval{
        .first = 4239,
        .last = 4239,
    },
    struct_interval{
        .first = 4250,
        .last = 4252,
    },
    struct_interval{
        .first = 5909,
        .last = 5909,
    },
    struct_interval{
        .first = 5940,
        .last = 5940,
    },
    struct_interval{
        .first = 6070,
        .last = 6070,
    },
    struct_interval{
        .first = 6078,
        .last = 6085,
    },
    struct_interval{
        .first = 6087,
        .last = 6088,
    },
    struct_interval{
        .first = 6435,
        .last = 6438,
    },
    struct_interval{
        .first = 6441,
        .last = 6443,
    },
    struct_interval{
        .first = 6448,
        .last = 6449,
    },
    struct_interval{
        .first = 6451,
        .last = 6456,
    },
    struct_interval{
        .first = 6681,
        .last = 6682,
    },
    struct_interval{
        .first = 6741,
        .last = 6741,
    },
    struct_interval{
        .first = 6743,
        .last = 6743,
    },
    struct_interval{
        .first = 6753,
        .last = 6753,
    },
    struct_interval{
        .first = 6755,
        .last = 6756,
    },
    struct_interval{
        .first = 6765,
        .last = 6770,
    },
    struct_interval{
        .first = 6916,
        .last = 6916,
    },
    struct_interval{
        .first = 6965,
        .last = 6965,
    },
    struct_interval{
        .first = 6971,
        .last = 6971,
    },
    struct_interval{
        .first = 6973,
        .last = 6977,
    },
    struct_interval{
        .first = 6979,
        .last = 6980,
    },
    struct_interval{
        .first = 7042,
        .last = 7042,
    },
    struct_interval{
        .first = 7073,
        .last = 7073,
    },
    struct_interval{
        .first = 7078,
        .last = 7079,
    },
    struct_interval{
        .first = 7082,
        .last = 7082,
    },
    struct_interval{
        .first = 7143,
        .last = 7143,
    },
    struct_interval{
        .first = 7146,
        .last = 7148,
    },
    struct_interval{
        .first = 7150,
        .last = 7150,
    },
    struct_interval{
        .first = 7154,
        .last = 7155,
    },
    struct_interval{
        .first = 7204,
        .last = 7211,
    },
    struct_interval{
        .first = 7220,
        .last = 7221,
    },
    struct_interval{
        .first = 7393,
        .last = 7393,
    },
    struct_interval{
        .first = 7415,
        .last = 7415,
    },
    struct_interval{
        .first = 12334,
        .last = 12335,
    },
    struct_interval{
        .first = 43043,
        .last = 43044,
    },
    struct_interval{
        .first = 43047,
        .last = 43047,
    },
    struct_interval{
        .first = 43136,
        .last = 43137,
    },
    struct_interval{
        .first = 43188,
        .last = 43203,
    },
    struct_interval{
        .first = 43346,
        .last = 43347,
    },
    struct_interval{
        .first = 43395,
        .last = 43395,
    },
    struct_interval{
        .first = 43444,
        .last = 43445,
    },
    struct_interval{
        .first = 43450,
        .last = 43451,
    },
    struct_interval{
        .first = 43454,
        .last = 43456,
    },
    struct_interval{
        .first = 43567,
        .last = 43568,
    },
    struct_interval{
        .first = 43571,
        .last = 43572,
    },
    struct_interval{
        .first = 43597,
        .last = 43597,
    },
    struct_interval{
        .first = 43643,
        .last = 43643,
    },
    struct_interval{
        .first = 43645,
        .last = 43645,
    },
    struct_interval{
        .first = 43755,
        .last = 43755,
    },
    struct_interval{
        .first = 43758,
        .last = 43759,
    },
    struct_interval{
        .first = 43765,
        .last = 43765,
    },
    struct_interval{
        .first = 44003,
        .last = 44004,
    },
    struct_interval{
        .first = 44006,
        .last = 44007,
    },
    struct_interval{
        .first = 44009,
        .last = 44010,
    },
    struct_interval{
        .first = 44012,
        .last = 44012,
    },
    struct_interval{
        .first = 69632,
        .last = 69632,
    },
    struct_interval{
        .first = 69634,
        .last = 69634,
    },
    struct_interval{
        .first = 69762,
        .last = 69762,
    },
    struct_interval{
        .first = 69808,
        .last = 69810,
    },
    struct_interval{
        .first = 69815,
        .last = 69816,
    },
    struct_interval{
        .first = 69932,
        .last = 69932,
    },
    struct_interval{
        .first = 69957,
        .last = 69958,
    },
    struct_interval{
        .first = 70018,
        .last = 70018,
    },
    struct_interval{
        .first = 70067,
        .last = 70069,
    },
    struct_interval{
        .first = 70079,
        .last = 70080,
    },
    struct_interval{
        .first = 70094,
        .last = 70094,
    },
    struct_interval{
        .first = 70188,
        .last = 70190,
    },
    struct_interval{
        .first = 70194,
        .last = 70195,
    },
    struct_interval{
        .first = 70197,
        .last = 70197,
    },
    struct_interval{
        .first = 70368,
        .last = 70370,
    },
    struct_interval{
        .first = 70402,
        .last = 70403,
    },
    struct_interval{
        .first = 70462,
        .last = 70463,
    },
    struct_interval{
        .first = 70465,
        .last = 70468,
    },
    struct_interval{
        .first = 70471,
        .last = 70472,
    },
    struct_interval{
        .first = 70475,
        .last = 70477,
    },
    struct_interval{
        .first = 70487,
        .last = 70487,
    },
    struct_interval{
        .first = 70498,
        .last = 70499,
    },
    struct_interval{
        .first = 70584,
        .last = 70586,
    },
    struct_interval{
        .first = 70594,
        .last = 70594,
    },
    struct_interval{
        .first = 70597,
        .last = 70597,
    },
    struct_interval{
        .first = 70599,
        .last = 70602,
    },
    struct_interval{
        .first = 70604,
        .last = 70605,
    },
    struct_interval{
        .first = 70607,
        .last = 70607,
    },
    struct_interval{
        .first = 70709,
        .last = 70711,
    },
    struct_interval{
        .first = 70720,
        .last = 70721,
    },
    struct_interval{
        .first = 70725,
        .last = 70725,
    },
    struct_interval{
        .first = 70832,
        .last = 70834,
    },
    struct_interval{
        .first = 70841,
        .last = 70841,
    },
    struct_interval{
        .first = 70843,
        .last = 70846,
    },
    struct_interval{
        .first = 70849,
        .last = 70849,
    },
    struct_interval{
        .first = 71087,
        .last = 71089,
    },
    struct_interval{
        .first = 71096,
        .last = 71099,
    },
    struct_interval{
        .first = 71102,
        .last = 71102,
    },
    struct_interval{
        .first = 71216,
        .last = 71218,
    },
    struct_interval{
        .first = 71227,
        .last = 71228,
    },
    struct_interval{
        .first = 71230,
        .last = 71230,
    },
    struct_interval{
        .first = 71340,
        .last = 71340,
    },
    struct_interval{
        .first = 71342,
        .last = 71343,
    },
    struct_interval{
        .first = 71350,
        .last = 71350,
    },
    struct_interval{
        .first = 71454,
        .last = 71454,
    },
    struct_interval{
        .first = 71456,
        .last = 71457,
    },
    struct_interval{
        .first = 71462,
        .last = 71462,
    },
    struct_interval{
        .first = 71724,
        .last = 71726,
    },
    struct_interval{
        .first = 71736,
        .last = 71736,
    },
    struct_interval{
        .first = 71984,
        .last = 71989,
    },
    struct_interval{
        .first = 71991,
        .last = 71992,
    },
    struct_interval{
        .first = 71997,
        .last = 71997,
    },
    struct_interval{
        .first = 72000,
        .last = 72000,
    },
    struct_interval{
        .first = 72002,
        .last = 72002,
    },
    struct_interval{
        .first = 72145,
        .last = 72147,
    },
    struct_interval{
        .first = 72156,
        .last = 72159,
    },
    struct_interval{
        .first = 72164,
        .last = 72164,
    },
    struct_interval{
        .first = 72249,
        .last = 72249,
    },
    struct_interval{
        .first = 72279,
        .last = 72280,
    },
    struct_interval{
        .first = 72343,
        .last = 72343,
    },
    struct_interval{
        .first = 72545,
        .last = 72545,
    },
    struct_interval{
        .first = 72549,
        .last = 72549,
    },
    struct_interval{
        .first = 72551,
        .last = 72551,
    },
    struct_interval{
        .first = 72751,
        .last = 72751,
    },
    struct_interval{
        .first = 72766,
        .last = 72766,
    },
    struct_interval{
        .first = 72873,
        .last = 72873,
    },
    struct_interval{
        .first = 72881,
        .last = 72881,
    },
    struct_interval{
        .first = 72884,
        .last = 72884,
    },
    struct_interval{
        .first = 73098,
        .last = 73102,
    },
    struct_interval{
        .first = 73107,
        .last = 73108,
    },
    struct_interval{
        .first = 73110,
        .last = 73110,
    },
    struct_interval{
        .first = 73461,
        .last = 73462,
    },
    struct_interval{
        .first = 73475,
        .last = 73475,
    },
    struct_interval{
        .first = 73524,
        .last = 73525,
    },
    struct_interval{
        .first = 73534,
        .last = 73535,
    },
    struct_interval{
        .first = 73537,
        .last = 73537,
    },
    struct_interval{
        .first = 90410,
        .last = 90412,
    },
    struct_interval{
        .first = 94033,
        .last = 94087,
    },
    struct_interval{
        .first = 94192,
        .last = 94193,
    },
    struct_interval{
        .first = 119141,
        .last = 119142,
    },
    struct_interval{
        .first = 119149,
        .last = 119154,
    },
};
pub export const Me_table: [5]struct_interval = [5]struct_interval{
    struct_interval{
        .first = 1160,
        .last = 1161,
    },
    struct_interval{
        .first = 6846,
        .last = 6846,
    },
    struct_interval{
        .first = 8413,
        .last = 8416,
    },
    struct_interval{
        .first = 8418,
        .last = 8420,
    },
    struct_interval{
        .first = 42608,
        .last = 42610,
    },
};
pub export const Mn_table: [365]struct_interval = [365]struct_interval{
    struct_interval{
        .first = 768,
        .last = 879,
    },
    struct_interval{
        .first = 1155,
        .last = 1159,
    },
    struct_interval{
        .first = 1425,
        .last = 1469,
    },
    struct_interval{
        .first = 1471,
        .last = 1471,
    },
    struct_interval{
        .first = 1473,
        .last = 1474,
    },
    struct_interval{
        .first = 1476,
        .last = 1477,
    },
    struct_interval{
        .first = 1479,
        .last = 1479,
    },
    struct_interval{
        .first = 1552,
        .last = 1562,
    },
    struct_interval{
        .first = 1611,
        .last = 1631,
    },
    struct_interval{
        .first = 1648,
        .last = 1648,
    },
    struct_interval{
        .first = 1750,
        .last = 1756,
    },
    struct_interval{
        .first = 1759,
        .last = 1764,
    },
    struct_interval{
        .first = 1767,
        .last = 1768,
    },
    struct_interval{
        .first = 1770,
        .last = 1773,
    },
    struct_interval{
        .first = 1809,
        .last = 1809,
    },
    struct_interval{
        .first = 1840,
        .last = 1866,
    },
    struct_interval{
        .first = 1958,
        .last = 1968,
    },
    struct_interval{
        .first = 2027,
        .last = 2035,
    },
    struct_interval{
        .first = 2045,
        .last = 2045,
    },
    struct_interval{
        .first = 2070,
        .last = 2073,
    },
    struct_interval{
        .first = 2075,
        .last = 2083,
    },
    struct_interval{
        .first = 2085,
        .last = 2087,
    },
    struct_interval{
        .first = 2089,
        .last = 2093,
    },
    struct_interval{
        .first = 2137,
        .last = 2139,
    },
    struct_interval{
        .first = 2199,
        .last = 2207,
    },
    struct_interval{
        .first = 2250,
        .last = 2273,
    },
    struct_interval{
        .first = 2275,
        .last = 2306,
    },
    struct_interval{
        .first = 2362,
        .last = 2362,
    },
    struct_interval{
        .first = 2364,
        .last = 2364,
    },
    struct_interval{
        .first = 2369,
        .last = 2376,
    },
    struct_interval{
        .first = 2381,
        .last = 2381,
    },
    struct_interval{
        .first = 2385,
        .last = 2391,
    },
    struct_interval{
        .first = 2402,
        .last = 2403,
    },
    struct_interval{
        .first = 2433,
        .last = 2433,
    },
    struct_interval{
        .first = 2492,
        .last = 2492,
    },
    struct_interval{
        .first = 2497,
        .last = 2500,
    },
    struct_interval{
        .first = 2509,
        .last = 2509,
    },
    struct_interval{
        .first = 2530,
        .last = 2531,
    },
    struct_interval{
        .first = 2558,
        .last = 2558,
    },
    struct_interval{
        .first = 2561,
        .last = 2562,
    },
    struct_interval{
        .first = 2620,
        .last = 2620,
    },
    struct_interval{
        .first = 2625,
        .last = 2626,
    },
    struct_interval{
        .first = 2631,
        .last = 2632,
    },
    struct_interval{
        .first = 2635,
        .last = 2637,
    },
    struct_interval{
        .first = 2641,
        .last = 2641,
    },
    struct_interval{
        .first = 2672,
        .last = 2673,
    },
    struct_interval{
        .first = 2677,
        .last = 2677,
    },
    struct_interval{
        .first = 2689,
        .last = 2690,
    },
    struct_interval{
        .first = 2748,
        .last = 2748,
    },
    struct_interval{
        .first = 2753,
        .last = 2757,
    },
    struct_interval{
        .first = 2759,
        .last = 2760,
    },
    struct_interval{
        .first = 2765,
        .last = 2765,
    },
    struct_interval{
        .first = 2786,
        .last = 2787,
    },
    struct_interval{
        .first = 2810,
        .last = 2815,
    },
    struct_interval{
        .first = 2817,
        .last = 2817,
    },
    struct_interval{
        .first = 2876,
        .last = 2876,
    },
    struct_interval{
        .first = 2879,
        .last = 2879,
    },
    struct_interval{
        .first = 2881,
        .last = 2884,
    },
    struct_interval{
        .first = 2893,
        .last = 2893,
    },
    struct_interval{
        .first = 2901,
        .last = 2902,
    },
    struct_interval{
        .first = 2914,
        .last = 2915,
    },
    struct_interval{
        .first = 2946,
        .last = 2946,
    },
    struct_interval{
        .first = 3008,
        .last = 3008,
    },
    struct_interval{
        .first = 3021,
        .last = 3021,
    },
    struct_interval{
        .first = 3072,
        .last = 3072,
    },
    struct_interval{
        .first = 3076,
        .last = 3076,
    },
    struct_interval{
        .first = 3132,
        .last = 3132,
    },
    struct_interval{
        .first = 3134,
        .last = 3136,
    },
    struct_interval{
        .first = 3142,
        .last = 3144,
    },
    struct_interval{
        .first = 3146,
        .last = 3149,
    },
    struct_interval{
        .first = 3157,
        .last = 3158,
    },
    struct_interval{
        .first = 3170,
        .last = 3171,
    },
    struct_interval{
        .first = 3201,
        .last = 3201,
    },
    struct_interval{
        .first = 3260,
        .last = 3260,
    },
    struct_interval{
        .first = 3263,
        .last = 3263,
    },
    struct_interval{
        .first = 3270,
        .last = 3270,
    },
    struct_interval{
        .first = 3276,
        .last = 3277,
    },
    struct_interval{
        .first = 3298,
        .last = 3299,
    },
    struct_interval{
        .first = 3328,
        .last = 3329,
    },
    struct_interval{
        .first = 3387,
        .last = 3388,
    },
    struct_interval{
        .first = 3393,
        .last = 3396,
    },
    struct_interval{
        .first = 3405,
        .last = 3405,
    },
    struct_interval{
        .first = 3426,
        .last = 3427,
    },
    struct_interval{
        .first = 3457,
        .last = 3457,
    },
    struct_interval{
        .first = 3530,
        .last = 3530,
    },
    struct_interval{
        .first = 3538,
        .last = 3540,
    },
    struct_interval{
        .first = 3542,
        .last = 3542,
    },
    struct_interval{
        .first = 3633,
        .last = 3633,
    },
    struct_interval{
        .first = 3636,
        .last = 3642,
    },
    struct_interval{
        .first = 3655,
        .last = 3662,
    },
    struct_interval{
        .first = 3761,
        .last = 3761,
    },
    struct_interval{
        .first = 3764,
        .last = 3772,
    },
    struct_interval{
        .first = 3784,
        .last = 3790,
    },
    struct_interval{
        .first = 3864,
        .last = 3865,
    },
    struct_interval{
        .first = 3893,
        .last = 3893,
    },
    struct_interval{
        .first = 3895,
        .last = 3895,
    },
    struct_interval{
        .first = 3897,
        .last = 3897,
    },
    struct_interval{
        .first = 3953,
        .last = 3966,
    },
    struct_interval{
        .first = 3968,
        .last = 3972,
    },
    struct_interval{
        .first = 3974,
        .last = 3975,
    },
    struct_interval{
        .first = 3981,
        .last = 3991,
    },
    struct_interval{
        .first = 3993,
        .last = 4028,
    },
    struct_interval{
        .first = 4038,
        .last = 4038,
    },
    struct_interval{
        .first = 4141,
        .last = 4144,
    },
    struct_interval{
        .first = 4146,
        .last = 4151,
    },
    struct_interval{
        .first = 4153,
        .last = 4154,
    },
    struct_interval{
        .first = 4157,
        .last = 4158,
    },
    struct_interval{
        .first = 4184,
        .last = 4185,
    },
    struct_interval{
        .first = 4190,
        .last = 4192,
    },
    struct_interval{
        .first = 4209,
        .last = 4212,
    },
    struct_interval{
        .first = 4226,
        .last = 4226,
    },
    struct_interval{
        .first = 4229,
        .last = 4230,
    },
    struct_interval{
        .first = 4237,
        .last = 4237,
    },
    struct_interval{
        .first = 4253,
        .last = 4253,
    },
    struct_interval{
        .first = 4957,
        .last = 4959,
    },
    struct_interval{
        .first = 5906,
        .last = 5908,
    },
    struct_interval{
        .first = 5938,
        .last = 5939,
    },
    struct_interval{
        .first = 5970,
        .last = 5971,
    },
    struct_interval{
        .first = 6002,
        .last = 6003,
    },
    struct_interval{
        .first = 6068,
        .last = 6069,
    },
    struct_interval{
        .first = 6071,
        .last = 6077,
    },
    struct_interval{
        .first = 6086,
        .last = 6086,
    },
    struct_interval{
        .first = 6089,
        .last = 6099,
    },
    struct_interval{
        .first = 6109,
        .last = 6109,
    },
    struct_interval{
        .first = 6155,
        .last = 6157,
    },
    struct_interval{
        .first = 6159,
        .last = 6159,
    },
    struct_interval{
        .first = 6277,
        .last = 6278,
    },
    struct_interval{
        .first = 6313,
        .last = 6313,
    },
    struct_interval{
        .first = 6432,
        .last = 6434,
    },
    struct_interval{
        .first = 6439,
        .last = 6440,
    },
    struct_interval{
        .first = 6450,
        .last = 6450,
    },
    struct_interval{
        .first = 6457,
        .last = 6459,
    },
    struct_interval{
        .first = 6679,
        .last = 6680,
    },
    struct_interval{
        .first = 6683,
        .last = 6683,
    },
    struct_interval{
        .first = 6742,
        .last = 6742,
    },
    struct_interval{
        .first = 6744,
        .last = 6750,
    },
    struct_interval{
        .first = 6752,
        .last = 6752,
    },
    struct_interval{
        .first = 6754,
        .last = 6754,
    },
    struct_interval{
        .first = 6757,
        .last = 6764,
    },
    struct_interval{
        .first = 6771,
        .last = 6780,
    },
    struct_interval{
        .first = 6783,
        .last = 6783,
    },
    struct_interval{
        .first = 6832,
        .last = 6845,
    },
    struct_interval{
        .first = 6847,
        .last = 6877,
    },
    struct_interval{
        .first = 6880,
        .last = 6891,
    },
    struct_interval{
        .first = 6912,
        .last = 6915,
    },
    struct_interval{
        .first = 6964,
        .last = 6964,
    },
    struct_interval{
        .first = 6966,
        .last = 6970,
    },
    struct_interval{
        .first = 6972,
        .last = 6972,
    },
    struct_interval{
        .first = 6978,
        .last = 6978,
    },
    struct_interval{
        .first = 7019,
        .last = 7027,
    },
    struct_interval{
        .first = 7040,
        .last = 7041,
    },
    struct_interval{
        .first = 7074,
        .last = 7077,
    },
    struct_interval{
        .first = 7080,
        .last = 7081,
    },
    struct_interval{
        .first = 7083,
        .last = 7085,
    },
    struct_interval{
        .first = 7142,
        .last = 7142,
    },
    struct_interval{
        .first = 7144,
        .last = 7145,
    },
    struct_interval{
        .first = 7149,
        .last = 7149,
    },
    struct_interval{
        .first = 7151,
        .last = 7153,
    },
    struct_interval{
        .first = 7212,
        .last = 7219,
    },
    struct_interval{
        .first = 7222,
        .last = 7223,
    },
    struct_interval{
        .first = 7376,
        .last = 7378,
    },
    struct_interval{
        .first = 7380,
        .last = 7392,
    },
    struct_interval{
        .first = 7394,
        .last = 7400,
    },
    struct_interval{
        .first = 7405,
        .last = 7405,
    },
    struct_interval{
        .first = 7412,
        .last = 7412,
    },
    struct_interval{
        .first = 7416,
        .last = 7417,
    },
    struct_interval{
        .first = 7616,
        .last = 7679,
    },
    struct_interval{
        .first = 8400,
        .last = 8412,
    },
    struct_interval{
        .first = 8417,
        .last = 8417,
    },
    struct_interval{
        .first = 8421,
        .last = 8432,
    },
    struct_interval{
        .first = 11503,
        .last = 11505,
    },
    struct_interval{
        .first = 11647,
        .last = 11647,
    },
    struct_interval{
        .first = 11744,
        .last = 11775,
    },
    struct_interval{
        .first = 12330,
        .last = 12333,
    },
    struct_interval{
        .first = 12441,
        .last = 12442,
    },
    struct_interval{
        .first = 42607,
        .last = 42607,
    },
    struct_interval{
        .first = 42612,
        .last = 42621,
    },
    struct_interval{
        .first = 42654,
        .last = 42655,
    },
    struct_interval{
        .first = 42736,
        .last = 42737,
    },
    struct_interval{
        .first = 43010,
        .last = 43010,
    },
    struct_interval{
        .first = 43014,
        .last = 43014,
    },
    struct_interval{
        .first = 43019,
        .last = 43019,
    },
    struct_interval{
        .first = 43045,
        .last = 43046,
    },
    struct_interval{
        .first = 43052,
        .last = 43052,
    },
    struct_interval{
        .first = 43204,
        .last = 43205,
    },
    struct_interval{
        .first = 43232,
        .last = 43249,
    },
    struct_interval{
        .first = 43263,
        .last = 43263,
    },
    struct_interval{
        .first = 43302,
        .last = 43309,
    },
    struct_interval{
        .first = 43335,
        .last = 43345,
    },
    struct_interval{
        .first = 43392,
        .last = 43394,
    },
    struct_interval{
        .first = 43443,
        .last = 43443,
    },
    struct_interval{
        .first = 43446,
        .last = 43449,
    },
    struct_interval{
        .first = 43452,
        .last = 43453,
    },
    struct_interval{
        .first = 43493,
        .last = 43493,
    },
    struct_interval{
        .first = 43561,
        .last = 43566,
    },
    struct_interval{
        .first = 43569,
        .last = 43570,
    },
    struct_interval{
        .first = 43573,
        .last = 43574,
    },
    struct_interval{
        .first = 43587,
        .last = 43587,
    },
    struct_interval{
        .first = 43596,
        .last = 43596,
    },
    struct_interval{
        .first = 43644,
        .last = 43644,
    },
    struct_interval{
        .first = 43696,
        .last = 43696,
    },
    struct_interval{
        .first = 43698,
        .last = 43700,
    },
    struct_interval{
        .first = 43703,
        .last = 43704,
    },
    struct_interval{
        .first = 43710,
        .last = 43711,
    },
    struct_interval{
        .first = 43713,
        .last = 43713,
    },
    struct_interval{
        .first = 43756,
        .last = 43757,
    },
    struct_interval{
        .first = 43766,
        .last = 43766,
    },
    struct_interval{
        .first = 44005,
        .last = 44005,
    },
    struct_interval{
        .first = 44008,
        .last = 44008,
    },
    struct_interval{
        .first = 44013,
        .last = 44013,
    },
    struct_interval{
        .first = 64286,
        .last = 64286,
    },
    struct_interval{
        .first = 65024,
        .last = 65039,
    },
    struct_interval{
        .first = 65056,
        .last = 65071,
    },
    struct_interval{
        .first = 66045,
        .last = 66045,
    },
    struct_interval{
        .first = 66272,
        .last = 66272,
    },
    struct_interval{
        .first = 66422,
        .last = 66426,
    },
    struct_interval{
        .first = 68097,
        .last = 68099,
    },
    struct_interval{
        .first = 68101,
        .last = 68102,
    },
    struct_interval{
        .first = 68108,
        .last = 68111,
    },
    struct_interval{
        .first = 68152,
        .last = 68154,
    },
    struct_interval{
        .first = 68159,
        .last = 68159,
    },
    struct_interval{
        .first = 68325,
        .last = 68326,
    },
    struct_interval{
        .first = 68900,
        .last = 68903,
    },
    struct_interval{
        .first = 68969,
        .last = 68973,
    },
    struct_interval{
        .first = 69291,
        .last = 69292,
    },
    struct_interval{
        .first = 69370,
        .last = 69375,
    },
    struct_interval{
        .first = 69446,
        .last = 69456,
    },
    struct_interval{
        .first = 69506,
        .last = 69509,
    },
    struct_interval{
        .first = 69633,
        .last = 69633,
    },
    struct_interval{
        .first = 69688,
        .last = 69702,
    },
    struct_interval{
        .first = 69744,
        .last = 69744,
    },
    struct_interval{
        .first = 69747,
        .last = 69748,
    },
    struct_interval{
        .first = 69759,
        .last = 69761,
    },
    struct_interval{
        .first = 69811,
        .last = 69814,
    },
    struct_interval{
        .first = 69817,
        .last = 69818,
    },
    struct_interval{
        .first = 69826,
        .last = 69826,
    },
    struct_interval{
        .first = 69888,
        .last = 69890,
    },
    struct_interval{
        .first = 69927,
        .last = 69931,
    },
    struct_interval{
        .first = 69933,
        .last = 69940,
    },
    struct_interval{
        .first = 70003,
        .last = 70003,
    },
    struct_interval{
        .first = 70016,
        .last = 70017,
    },
    struct_interval{
        .first = 70070,
        .last = 70078,
    },
    struct_interval{
        .first = 70089,
        .last = 70092,
    },
    struct_interval{
        .first = 70095,
        .last = 70095,
    },
    struct_interval{
        .first = 70191,
        .last = 70193,
    },
    struct_interval{
        .first = 70196,
        .last = 70196,
    },
    struct_interval{
        .first = 70198,
        .last = 70199,
    },
    struct_interval{
        .first = 70206,
        .last = 70206,
    },
    struct_interval{
        .first = 70209,
        .last = 70209,
    },
    struct_interval{
        .first = 70367,
        .last = 70367,
    },
    struct_interval{
        .first = 70371,
        .last = 70378,
    },
    struct_interval{
        .first = 70400,
        .last = 70401,
    },
    struct_interval{
        .first = 70459,
        .last = 70460,
    },
    struct_interval{
        .first = 70464,
        .last = 70464,
    },
    struct_interval{
        .first = 70502,
        .last = 70508,
    },
    struct_interval{
        .first = 70512,
        .last = 70516,
    },
    struct_interval{
        .first = 70587,
        .last = 70592,
    },
    struct_interval{
        .first = 70606,
        .last = 70606,
    },
    struct_interval{
        .first = 70608,
        .last = 70608,
    },
    struct_interval{
        .first = 70610,
        .last = 70610,
    },
    struct_interval{
        .first = 70625,
        .last = 70626,
    },
    struct_interval{
        .first = 70712,
        .last = 70719,
    },
    struct_interval{
        .first = 70722,
        .last = 70724,
    },
    struct_interval{
        .first = 70726,
        .last = 70726,
    },
    struct_interval{
        .first = 70750,
        .last = 70750,
    },
    struct_interval{
        .first = 70835,
        .last = 70840,
    },
    struct_interval{
        .first = 70842,
        .last = 70842,
    },
    struct_interval{
        .first = 70847,
        .last = 70848,
    },
    struct_interval{
        .first = 70850,
        .last = 70851,
    },
    struct_interval{
        .first = 71090,
        .last = 71093,
    },
    struct_interval{
        .first = 71100,
        .last = 71101,
    },
    struct_interval{
        .first = 71103,
        .last = 71104,
    },
    struct_interval{
        .first = 71132,
        .last = 71133,
    },
    struct_interval{
        .first = 71219,
        .last = 71226,
    },
    struct_interval{
        .first = 71229,
        .last = 71229,
    },
    struct_interval{
        .first = 71231,
        .last = 71232,
    },
    struct_interval{
        .first = 71339,
        .last = 71339,
    },
    struct_interval{
        .first = 71341,
        .last = 71341,
    },
    struct_interval{
        .first = 71344,
        .last = 71349,
    },
    struct_interval{
        .first = 71351,
        .last = 71351,
    },
    struct_interval{
        .first = 71453,
        .last = 71453,
    },
    struct_interval{
        .first = 71455,
        .last = 71455,
    },
    struct_interval{
        .first = 71458,
        .last = 71461,
    },
    struct_interval{
        .first = 71463,
        .last = 71467,
    },
    struct_interval{
        .first = 71727,
        .last = 71735,
    },
    struct_interval{
        .first = 71737,
        .last = 71738,
    },
    struct_interval{
        .first = 71995,
        .last = 71996,
    },
    struct_interval{
        .first = 71998,
        .last = 71998,
    },
    struct_interval{
        .first = 72003,
        .last = 72003,
    },
    struct_interval{
        .first = 72148,
        .last = 72151,
    },
    struct_interval{
        .first = 72154,
        .last = 72155,
    },
    struct_interval{
        .first = 72160,
        .last = 72160,
    },
    struct_interval{
        .first = 72193,
        .last = 72202,
    },
    struct_interval{
        .first = 72243,
        .last = 72248,
    },
    struct_interval{
        .first = 72251,
        .last = 72254,
    },
    struct_interval{
        .first = 72263,
        .last = 72263,
    },
    struct_interval{
        .first = 72273,
        .last = 72278,
    },
    struct_interval{
        .first = 72281,
        .last = 72283,
    },
    struct_interval{
        .first = 72330,
        .last = 72342,
    },
    struct_interval{
        .first = 72344,
        .last = 72345,
    },
    struct_interval{
        .first = 72544,
        .last = 72544,
    },
    struct_interval{
        .first = 72546,
        .last = 72548,
    },
    struct_interval{
        .first = 72550,
        .last = 72550,
    },
    struct_interval{
        .first = 72752,
        .last = 72758,
    },
    struct_interval{
        .first = 72760,
        .last = 72765,
    },
    struct_interval{
        .first = 72767,
        .last = 72767,
    },
    struct_interval{
        .first = 72850,
        .last = 72871,
    },
    struct_interval{
        .first = 72874,
        .last = 72880,
    },
    struct_interval{
        .first = 72882,
        .last = 72883,
    },
    struct_interval{
        .first = 72885,
        .last = 72886,
    },
    struct_interval{
        .first = 73009,
        .last = 73014,
    },
    struct_interval{
        .first = 73018,
        .last = 73018,
    },
    struct_interval{
        .first = 73020,
        .last = 73021,
    },
    struct_interval{
        .first = 73023,
        .last = 73029,
    },
    struct_interval{
        .first = 73031,
        .last = 73031,
    },
    struct_interval{
        .first = 73104,
        .last = 73105,
    },
    struct_interval{
        .first = 73109,
        .last = 73109,
    },
    struct_interval{
        .first = 73111,
        .last = 73111,
    },
    struct_interval{
        .first = 73459,
        .last = 73460,
    },
    struct_interval{
        .first = 73472,
        .last = 73473,
    },
    struct_interval{
        .first = 73526,
        .last = 73530,
    },
    struct_interval{
        .first = 73536,
        .last = 73536,
    },
    struct_interval{
        .first = 73538,
        .last = 73538,
    },
    struct_interval{
        .first = 73562,
        .last = 73562,
    },
    struct_interval{
        .first = 78912,
        .last = 78912,
    },
    struct_interval{
        .first = 78919,
        .last = 78933,
    },
    struct_interval{
        .first = 90398,
        .last = 90409,
    },
    struct_interval{
        .first = 90413,
        .last = 90415,
    },
    struct_interval{
        .first = 92912,
        .last = 92916,
    },
    struct_interval{
        .first = 92976,
        .last = 92982,
    },
    struct_interval{
        .first = 94031,
        .last = 94031,
    },
    struct_interval{
        .first = 94095,
        .last = 94098,
    },
    struct_interval{
        .first = 94180,
        .last = 94180,
    },
    struct_interval{
        .first = 113821,
        .last = 113822,
    },
    struct_interval{
        .first = 118528,
        .last = 118573,
    },
    struct_interval{
        .first = 118576,
        .last = 118598,
    },
    struct_interval{
        .first = 119143,
        .last = 119145,
    },
    struct_interval{
        .first = 119163,
        .last = 119170,
    },
    struct_interval{
        .first = 119173,
        .last = 119179,
    },
    struct_interval{
        .first = 119210,
        .last = 119213,
    },
    struct_interval{
        .first = 119362,
        .last = 119364,
    },
    struct_interval{
        .first = 121344,
        .last = 121398,
    },
    struct_interval{
        .first = 121403,
        .last = 121452,
    },
    struct_interval{
        .first = 121461,
        .last = 121461,
    },
    struct_interval{
        .first = 121476,
        .last = 121476,
    },
    struct_interval{
        .first = 121499,
        .last = 121503,
    },
    struct_interval{
        .first = 121505,
        .last = 121519,
    },
    struct_interval{
        .first = 122880,
        .last = 122886,
    },
    struct_interval{
        .first = 122888,
        .last = 122904,
    },
    struct_interval{
        .first = 122907,
        .last = 122913,
    },
    struct_interval{
        .first = 122915,
        .last = 122916,
    },
    struct_interval{
        .first = 122918,
        .last = 122922,
    },
    struct_interval{
        .first = 123023,
        .last = 123023,
    },
    struct_interval{
        .first = 123184,
        .last = 123190,
    },
    struct_interval{
        .first = 123566,
        .last = 123566,
    },
    struct_interval{
        .first = 123628,
        .last = 123631,
    },
    struct_interval{
        .first = 124140,
        .last = 124143,
    },
    struct_interval{
        .first = 124398,
        .last = 124399,
    },
    struct_interval{
        .first = 124643,
        .last = 124643,
    },
    struct_interval{
        .first = 124646,
        .last = 124646,
    },
    struct_interval{
        .first = 124654,
        .last = 124655,
    },
    struct_interval{
        .first = 124661,
        .last = 124661,
    },
    struct_interval{
        .first = 125136,
        .last = 125142,
    },
    struct_interval{
        .first = 125252,
        .last = 125258,
    },
    struct_interval{
        .first = 917760,
        .last = 917999,
    },
};
pub export const Lm_table: [79]struct_interval = [79]struct_interval{
    struct_interval{
        .first = 688,
        .last = 705,
    },
    struct_interval{
        .first = 710,
        .last = 721,
    },
    struct_interval{
        .first = 736,
        .last = 740,
    },
    struct_interval{
        .first = 748,
        .last = 748,
    },
    struct_interval{
        .first = 750,
        .last = 750,
    },
    struct_interval{
        .first = 884,
        .last = 884,
    },
    struct_interval{
        .first = 890,
        .last = 890,
    },
    struct_interval{
        .first = 1369,
        .last = 1369,
    },
    struct_interval{
        .first = 1600,
        .last = 1600,
    },
    struct_interval{
        .first = 1765,
        .last = 1766,
    },
    struct_interval{
        .first = 2036,
        .last = 2037,
    },
    struct_interval{
        .first = 2042,
        .last = 2042,
    },
    struct_interval{
        .first = 2074,
        .last = 2074,
    },
    struct_interval{
        .first = 2084,
        .last = 2084,
    },
    struct_interval{
        .first = 2088,
        .last = 2088,
    },
    struct_interval{
        .first = 2249,
        .last = 2249,
    },
    struct_interval{
        .first = 2417,
        .last = 2417,
    },
    struct_interval{
        .first = 3654,
        .last = 3654,
    },
    struct_interval{
        .first = 3782,
        .last = 3782,
    },
    struct_interval{
        .first = 4348,
        .last = 4348,
    },
    struct_interval{
        .first = 6103,
        .last = 6103,
    },
    struct_interval{
        .first = 6211,
        .last = 6211,
    },
    struct_interval{
        .first = 6823,
        .last = 6823,
    },
    struct_interval{
        .first = 7288,
        .last = 7293,
    },
    struct_interval{
        .first = 7468,
        .last = 7530,
    },
    struct_interval{
        .first = 7544,
        .last = 7544,
    },
    struct_interval{
        .first = 7579,
        .last = 7615,
    },
    struct_interval{
        .first = 8305,
        .last = 8305,
    },
    struct_interval{
        .first = 8319,
        .last = 8319,
    },
    struct_interval{
        .first = 8336,
        .last = 8348,
    },
    struct_interval{
        .first = 11388,
        .last = 11389,
    },
    struct_interval{
        .first = 11631,
        .last = 11631,
    },
    struct_interval{
        .first = 11823,
        .last = 11823,
    },
    struct_interval{
        .first = 12293,
        .last = 12293,
    },
    struct_interval{
        .first = 12337,
        .last = 12341,
    },
    struct_interval{
        .first = 12347,
        .last = 12347,
    },
    struct_interval{
        .first = 12445,
        .last = 12446,
    },
    struct_interval{
        .first = 12540,
        .last = 12542,
    },
    struct_interval{
        .first = 40981,
        .last = 40981,
    },
    struct_interval{
        .first = 42232,
        .last = 42237,
    },
    struct_interval{
        .first = 42508,
        .last = 42508,
    },
    struct_interval{
        .first = 42623,
        .last = 42623,
    },
    struct_interval{
        .first = 42652,
        .last = 42653,
    },
    struct_interval{
        .first = 42775,
        .last = 42783,
    },
    struct_interval{
        .first = 42864,
        .last = 42864,
    },
    struct_interval{
        .first = 42888,
        .last = 42888,
    },
    struct_interval{
        .first = 42993,
        .last = 42996,
    },
    struct_interval{
        .first = 43000,
        .last = 43001,
    },
    struct_interval{
        .first = 43471,
        .last = 43471,
    },
    struct_interval{
        .first = 43494,
        .last = 43494,
    },
    struct_interval{
        .first = 43632,
        .last = 43632,
    },
    struct_interval{
        .first = 43741,
        .last = 43741,
    },
    struct_interval{
        .first = 43763,
        .last = 43764,
    },
    struct_interval{
        .first = 43868,
        .last = 43871,
    },
    struct_interval{
        .first = 43881,
        .last = 43881,
    },
    struct_interval{
        .first = 65392,
        .last = 65392,
    },
    struct_interval{
        .first = 65438,
        .last = 65439,
    },
    struct_interval{
        .first = 67456,
        .last = 67461,
    },
    struct_interval{
        .first = 67463,
        .last = 67504,
    },
    struct_interval{
        .first = 67506,
        .last = 67514,
    },
    struct_interval{
        .first = 68942,
        .last = 68942,
    },
    struct_interval{
        .first = 68975,
        .last = 68975,
    },
    struct_interval{
        .first = 69317,
        .last = 69317,
    },
    struct_interval{
        .first = 73177,
        .last = 73177,
    },
    struct_interval{
        .first = 92992,
        .last = 92995,
    },
    struct_interval{
        .first = 93504,
        .last = 93506,
    },
    struct_interval{
        .first = 93547,
        .last = 93548,
    },
    struct_interval{
        .first = 94099,
        .last = 94111,
    },
    struct_interval{
        .first = 94176,
        .last = 94177,
    },
    struct_interval{
        .first = 94179,
        .last = 94179,
    },
    struct_interval{
        .first = 94194,
        .last = 94195,
    },
    struct_interval{
        .first = 110576,
        .last = 110579,
    },
    struct_interval{
        .first = 110581,
        .last = 110587,
    },
    struct_interval{
        .first = 110589,
        .last = 110590,
    },
    struct_interval{
        .first = 122928,
        .last = 122989,
    },
    struct_interval{
        .first = 123191,
        .last = 123197,
    },
    struct_interval{
        .first = 124139,
        .last = 124139,
    },
    struct_interval{
        .first = 124671,
        .last = 124671,
    },
    struct_interval{
        .first = 125259,
        .last = 125259,
    },
};
pub export const Lt_table: [10]struct_interval = [10]struct_interval{
    struct_interval{
        .first = 453,
        .last = 453,
    },
    struct_interval{
        .first = 456,
        .last = 456,
    },
    struct_interval{
        .first = 459,
        .last = 459,
    },
    struct_interval{
        .first = 498,
        .last = 498,
    },
    struct_interval{
        .first = 8072,
        .last = 8079,
    },
    struct_interval{
        .first = 8088,
        .last = 8095,
    },
    struct_interval{
        .first = 8104,
        .last = 8111,
    },
    struct_interval{
        .first = 8124,
        .last = 8124,
    },
    struct_interval{
        .first = 8140,
        .last = 8140,
    },
    struct_interval{
        .first = 8188,
        .last = 8188,
    },
};
pub export const Pf_table: [10]struct_interval = [10]struct_interval{
    struct_interval{
        .first = 187,
        .last = 187,
    },
    struct_interval{
        .first = 8217,
        .last = 8217,
    },
    struct_interval{
        .first = 8221,
        .last = 8221,
    },
    struct_interval{
        .first = 8250,
        .last = 8250,
    },
    struct_interval{
        .first = 11779,
        .last = 11779,
    },
    struct_interval{
        .first = 11781,
        .last = 11781,
    },
    struct_interval{
        .first = 11786,
        .last = 11786,
    },
    struct_interval{
        .first = 11789,
        .last = 11789,
    },
    struct_interval{
        .first = 11805,
        .last = 11805,
    },
    struct_interval{
        .first = 11809,
        .last = 11809,
    },
};
pub export const No_table: [72]struct_interval = [72]struct_interval{
    struct_interval{
        .first = 178,
        .last = 179,
    },
    struct_interval{
        .first = 185,
        .last = 185,
    },
    struct_interval{
        .first = 188,
        .last = 190,
    },
    struct_interval{
        .first = 2548,
        .last = 2553,
    },
    struct_interval{
        .first = 2930,
        .last = 2935,
    },
    struct_interval{
        .first = 3056,
        .last = 3058,
    },
    struct_interval{
        .first = 3192,
        .last = 3198,
    },
    struct_interval{
        .first = 3416,
        .last = 3422,
    },
    struct_interval{
        .first = 3440,
        .last = 3448,
    },
    struct_interval{
        .first = 3882,
        .last = 3891,
    },
    struct_interval{
        .first = 4969,
        .last = 4988,
    },
    struct_interval{
        .first = 6128,
        .last = 6137,
    },
    struct_interval{
        .first = 6618,
        .last = 6618,
    },
    struct_interval{
        .first = 8304,
        .last = 8304,
    },
    struct_interval{
        .first = 8308,
        .last = 8313,
    },
    struct_interval{
        .first = 8320,
        .last = 8329,
    },
    struct_interval{
        .first = 8528,
        .last = 8543,
    },
    struct_interval{
        .first = 8585,
        .last = 8585,
    },
    struct_interval{
        .first = 9312,
        .last = 9371,
    },
    struct_interval{
        .first = 9450,
        .last = 9471,
    },
    struct_interval{
        .first = 10102,
        .last = 10131,
    },
    struct_interval{
        .first = 11517,
        .last = 11517,
    },
    struct_interval{
        .first = 12690,
        .last = 12693,
    },
    struct_interval{
        .first = 12832,
        .last = 12841,
    },
    struct_interval{
        .first = 12872,
        .last = 12879,
    },
    struct_interval{
        .first = 12881,
        .last = 12895,
    },
    struct_interval{
        .first = 12928,
        .last = 12937,
    },
    struct_interval{
        .first = 12977,
        .last = 12991,
    },
    struct_interval{
        .first = 43056,
        .last = 43061,
    },
    struct_interval{
        .first = 65799,
        .last = 65843,
    },
    struct_interval{
        .first = 65909,
        .last = 65912,
    },
    struct_interval{
        .first = 65930,
        .last = 65931,
    },
    struct_interval{
        .first = 66273,
        .last = 66299,
    },
    struct_interval{
        .first = 66336,
        .last = 66339,
    },
    struct_interval{
        .first = 67672,
        .last = 67679,
    },
    struct_interval{
        .first = 67705,
        .last = 67711,
    },
    struct_interval{
        .first = 67751,
        .last = 67759,
    },
    struct_interval{
        .first = 67835,
        .last = 67839,
    },
    struct_interval{
        .first = 67862,
        .last = 67867,
    },
    struct_interval{
        .first = 68028,
        .last = 68029,
    },
    struct_interval{
        .first = 68032,
        .last = 68047,
    },
    struct_interval{
        .first = 68050,
        .last = 68095,
    },
    struct_interval{
        .first = 68160,
        .last = 68168,
    },
    struct_interval{
        .first = 68221,
        .last = 68222,
    },
    struct_interval{
        .first = 68253,
        .last = 68255,
    },
    struct_interval{
        .first = 68331,
        .last = 68335,
    },
    struct_interval{
        .first = 68440,
        .last = 68447,
    },
    struct_interval{
        .first = 68472,
        .last = 68479,
    },
    struct_interval{
        .first = 68521,
        .last = 68527,
    },
    struct_interval{
        .first = 68858,
        .last = 68863,
    },
    struct_interval{
        .first = 69216,
        .last = 69246,
    },
    struct_interval{
        .first = 69405,
        .last = 69414,
    },
    struct_interval{
        .first = 69457,
        .last = 69460,
    },
    struct_interval{
        .first = 69573,
        .last = 69579,
    },
    struct_interval{
        .first = 69714,
        .last = 69733,
    },
    struct_interval{
        .first = 70113,
        .last = 70132,
    },
    struct_interval{
        .first = 71482,
        .last = 71483,
    },
    struct_interval{
        .first = 71914,
        .last = 71922,
    },
    struct_interval{
        .first = 72794,
        .last = 72812,
    },
    struct_interval{
        .first = 73664,
        .last = 73684,
    },
    struct_interval{
        .first = 93019,
        .last = 93025,
    },
    struct_interval{
        .first = 93824,
        .last = 93846,
    },
    struct_interval{
        .first = 119488,
        .last = 119507,
    },
    struct_interval{
        .first = 119520,
        .last = 119539,
    },
    struct_interval{
        .first = 119648,
        .last = 119672,
    },
    struct_interval{
        .first = 125127,
        .last = 125135,
    },
    struct_interval{
        .first = 126065,
        .last = 126123,
    },
    struct_interval{
        .first = 126125,
        .last = 126127,
    },
    struct_interval{
        .first = 126129,
        .last = 126132,
    },
    struct_interval{
        .first = 126209,
        .last = 126253,
    },
    struct_interval{
        .first = 126255,
        .last = 126269,
    },
    struct_interval{
        .first = 127232,
        .last = 127244,
    },
};
pub export const Cf_table: [21]struct_interval = [21]struct_interval{
    struct_interval{
        .first = 173,
        .last = 173,
    },
    struct_interval{
        .first = 1536,
        .last = 1541,
    },
    struct_interval{
        .first = 1564,
        .last = 1564,
    },
    struct_interval{
        .first = 1757,
        .last = 1757,
    },
    struct_interval{
        .first = 1807,
        .last = 1807,
    },
    struct_interval{
        .first = 2192,
        .last = 2193,
    },
    struct_interval{
        .first = 2274,
        .last = 2274,
    },
    struct_interval{
        .first = 6158,
        .last = 6158,
    },
    struct_interval{
        .first = 8203,
        .last = 8207,
    },
    struct_interval{
        .first = 8234,
        .last = 8238,
    },
    struct_interval{
        .first = 8288,
        .last = 8292,
    },
    struct_interval{
        .first = 8294,
        .last = 8303,
    },
    struct_interval{
        .first = 65279,
        .last = 65279,
    },
    struct_interval{
        .first = 65529,
        .last = 65531,
    },
    struct_interval{
        .first = 69821,
        .last = 69821,
    },
    struct_interval{
        .first = 69837,
        .last = 69837,
    },
    struct_interval{
        .first = 78896,
        .last = 78911,
    },
    struct_interval{
        .first = 113824,
        .last = 113827,
    },
    struct_interval{
        .first = 119155,
        .last = 119162,
    },
    struct_interval{
        .first = 917505,
        .last = 917505,
    },
    struct_interval{
        .first = 917536,
        .last = 917631,
    },
};
pub export const Pi_table: [11]struct_interval = [11]struct_interval{
    struct_interval{
        .first = 171,
        .last = 171,
    },
    struct_interval{
        .first = 8216,
        .last = 8216,
    },
    struct_interval{
        .first = 8219,
        .last = 8220,
    },
    struct_interval{
        .first = 8223,
        .last = 8223,
    },
    struct_interval{
        .first = 8249,
        .last = 8249,
    },
    struct_interval{
        .first = 11778,
        .last = 11778,
    },
    struct_interval{
        .first = 11780,
        .last = 11780,
    },
    struct_interval{
        .first = 11785,
        .last = 11785,
    },
    struct_interval{
        .first = 11788,
        .last = 11788,
    },
    struct_interval{
        .first = 11804,
        .last = 11804,
    },
    struct_interval{
        .first = 11808,
        .last = 11808,
    },
};
pub export const Lo_table: [537]struct_interval = [537]struct_interval{
    struct_interval{
        .first = 170,
        .last = 170,
    },
    struct_interval{
        .first = 186,
        .last = 186,
    },
    struct_interval{
        .first = 443,
        .last = 443,
    },
    struct_interval{
        .first = 448,
        .last = 451,
    },
    struct_interval{
        .first = 660,
        .last = 661,
    },
    struct_interval{
        .first = 1488,
        .last = 1514,
    },
    struct_interval{
        .first = 1519,
        .last = 1522,
    },
    struct_interval{
        .first = 1568,
        .last = 1599,
    },
    struct_interval{
        .first = 1601,
        .last = 1610,
    },
    struct_interval{
        .first = 1646,
        .last = 1647,
    },
    struct_interval{
        .first = 1649,
        .last = 1747,
    },
    struct_interval{
        .first = 1749,
        .last = 1749,
    },
    struct_interval{
        .first = 1774,
        .last = 1775,
    },
    struct_interval{
        .first = 1786,
        .last = 1788,
    },
    struct_interval{
        .first = 1791,
        .last = 1791,
    },
    struct_interval{
        .first = 1808,
        .last = 1808,
    },
    struct_interval{
        .first = 1810,
        .last = 1839,
    },
    struct_interval{
        .first = 1869,
        .last = 1957,
    },
    struct_interval{
        .first = 1969,
        .last = 1969,
    },
    struct_interval{
        .first = 1994,
        .last = 2026,
    },
    struct_interval{
        .first = 2048,
        .last = 2069,
    },
    struct_interval{
        .first = 2112,
        .last = 2136,
    },
    struct_interval{
        .first = 2144,
        .last = 2154,
    },
    struct_interval{
        .first = 2160,
        .last = 2183,
    },
    struct_interval{
        .first = 2185,
        .last = 2191,
    },
    struct_interval{
        .first = 2208,
        .last = 2248,
    },
    struct_interval{
        .first = 2308,
        .last = 2361,
    },
    struct_interval{
        .first = 2365,
        .last = 2365,
    },
    struct_interval{
        .first = 2384,
        .last = 2384,
    },
    struct_interval{
        .first = 2392,
        .last = 2401,
    },
    struct_interval{
        .first = 2418,
        .last = 2432,
    },
    struct_interval{
        .first = 2437,
        .last = 2444,
    },
    struct_interval{
        .first = 2447,
        .last = 2448,
    },
    struct_interval{
        .first = 2451,
        .last = 2472,
    },
    struct_interval{
        .first = 2474,
        .last = 2480,
    },
    struct_interval{
        .first = 2482,
        .last = 2482,
    },
    struct_interval{
        .first = 2486,
        .last = 2489,
    },
    struct_interval{
        .first = 2493,
        .last = 2493,
    },
    struct_interval{
        .first = 2510,
        .last = 2510,
    },
    struct_interval{
        .first = 2524,
        .last = 2525,
    },
    struct_interval{
        .first = 2527,
        .last = 2529,
    },
    struct_interval{
        .first = 2544,
        .last = 2545,
    },
    struct_interval{
        .first = 2556,
        .last = 2556,
    },
    struct_interval{
        .first = 2565,
        .last = 2570,
    },
    struct_interval{
        .first = 2575,
        .last = 2576,
    },
    struct_interval{
        .first = 2579,
        .last = 2600,
    },
    struct_interval{
        .first = 2602,
        .last = 2608,
    },
    struct_interval{
        .first = 2610,
        .last = 2611,
    },
    struct_interval{
        .first = 2613,
        .last = 2614,
    },
    struct_interval{
        .first = 2616,
        .last = 2617,
    },
    struct_interval{
        .first = 2649,
        .last = 2652,
    },
    struct_interval{
        .first = 2654,
        .last = 2654,
    },
    struct_interval{
        .first = 2674,
        .last = 2676,
    },
    struct_interval{
        .first = 2693,
        .last = 2701,
    },
    struct_interval{
        .first = 2703,
        .last = 2705,
    },
    struct_interval{
        .first = 2707,
        .last = 2728,
    },
    struct_interval{
        .first = 2730,
        .last = 2736,
    },
    struct_interval{
        .first = 2738,
        .last = 2739,
    },
    struct_interval{
        .first = 2741,
        .last = 2745,
    },
    struct_interval{
        .first = 2749,
        .last = 2749,
    },
    struct_interval{
        .first = 2768,
        .last = 2768,
    },
    struct_interval{
        .first = 2784,
        .last = 2785,
    },
    struct_interval{
        .first = 2809,
        .last = 2809,
    },
    struct_interval{
        .first = 2821,
        .last = 2828,
    },
    struct_interval{
        .first = 2831,
        .last = 2832,
    },
    struct_interval{
        .first = 2835,
        .last = 2856,
    },
    struct_interval{
        .first = 2858,
        .last = 2864,
    },
    struct_interval{
        .first = 2866,
        .last = 2867,
    },
    struct_interval{
        .first = 2869,
        .last = 2873,
    },
    struct_interval{
        .first = 2877,
        .last = 2877,
    },
    struct_interval{
        .first = 2908,
        .last = 2909,
    },
    struct_interval{
        .first = 2911,
        .last = 2913,
    },
    struct_interval{
        .first = 2929,
        .last = 2929,
    },
    struct_interval{
        .first = 2947,
        .last = 2947,
    },
    struct_interval{
        .first = 2949,
        .last = 2954,
    },
    struct_interval{
        .first = 2958,
        .last = 2960,
    },
    struct_interval{
        .first = 2962,
        .last = 2965,
    },
    struct_interval{
        .first = 2969,
        .last = 2970,
    },
    struct_interval{
        .first = 2972,
        .last = 2972,
    },
    struct_interval{
        .first = 2974,
        .last = 2975,
    },
    struct_interval{
        .first = 2979,
        .last = 2980,
    },
    struct_interval{
        .first = 2984,
        .last = 2986,
    },
    struct_interval{
        .first = 2990,
        .last = 3001,
    },
    struct_interval{
        .first = 3024,
        .last = 3024,
    },
    struct_interval{
        .first = 3077,
        .last = 3084,
    },
    struct_interval{
        .first = 3086,
        .last = 3088,
    },
    struct_interval{
        .first = 3090,
        .last = 3112,
    },
    struct_interval{
        .first = 3114,
        .last = 3129,
    },
    struct_interval{
        .first = 3133,
        .last = 3133,
    },
    struct_interval{
        .first = 3160,
        .last = 3162,
    },
    struct_interval{
        .first = 3164,
        .last = 3165,
    },
    struct_interval{
        .first = 3168,
        .last = 3169,
    },
    struct_interval{
        .first = 3200,
        .last = 3200,
    },
    struct_interval{
        .first = 3205,
        .last = 3212,
    },
    struct_interval{
        .first = 3214,
        .last = 3216,
    },
    struct_interval{
        .first = 3218,
        .last = 3240,
    },
    struct_interval{
        .first = 3242,
        .last = 3251,
    },
    struct_interval{
        .first = 3253,
        .last = 3257,
    },
    struct_interval{
        .first = 3261,
        .last = 3261,
    },
    struct_interval{
        .first = 3292,
        .last = 3294,
    },
    struct_interval{
        .first = 3296,
        .last = 3297,
    },
    struct_interval{
        .first = 3313,
        .last = 3314,
    },
    struct_interval{
        .first = 3332,
        .last = 3340,
    },
    struct_interval{
        .first = 3342,
        .last = 3344,
    },
    struct_interval{
        .first = 3346,
        .last = 3386,
    },
    struct_interval{
        .first = 3389,
        .last = 3389,
    },
    struct_interval{
        .first = 3406,
        .last = 3406,
    },
    struct_interval{
        .first = 3412,
        .last = 3414,
    },
    struct_interval{
        .first = 3423,
        .last = 3425,
    },
    struct_interval{
        .first = 3450,
        .last = 3455,
    },
    struct_interval{
        .first = 3461,
        .last = 3478,
    },
    struct_interval{
        .first = 3482,
        .last = 3505,
    },
    struct_interval{
        .first = 3507,
        .last = 3515,
    },
    struct_interval{
        .first = 3517,
        .last = 3517,
    },
    struct_interval{
        .first = 3520,
        .last = 3526,
    },
    struct_interval{
        .first = 3585,
        .last = 3632,
    },
    struct_interval{
        .first = 3634,
        .last = 3635,
    },
    struct_interval{
        .first = 3648,
        .last = 3653,
    },
    struct_interval{
        .first = 3713,
        .last = 3714,
    },
    struct_interval{
        .first = 3716,
        .last = 3716,
    },
    struct_interval{
        .first = 3718,
        .last = 3722,
    },
    struct_interval{
        .first = 3724,
        .last = 3747,
    },
    struct_interval{
        .first = 3749,
        .last = 3749,
    },
    struct_interval{
        .first = 3751,
        .last = 3760,
    },
    struct_interval{
        .first = 3762,
        .last = 3763,
    },
    struct_interval{
        .first = 3773,
        .last = 3773,
    },
    struct_interval{
        .first = 3776,
        .last = 3780,
    },
    struct_interval{
        .first = 3804,
        .last = 3807,
    },
    struct_interval{
        .first = 3840,
        .last = 3840,
    },
    struct_interval{
        .first = 3904,
        .last = 3911,
    },
    struct_interval{
        .first = 3913,
        .last = 3948,
    },
    struct_interval{
        .first = 3976,
        .last = 3980,
    },
    struct_interval{
        .first = 4096,
        .last = 4138,
    },
    struct_interval{
        .first = 4159,
        .last = 4159,
    },
    struct_interval{
        .first = 4176,
        .last = 4181,
    },
    struct_interval{
        .first = 4186,
        .last = 4189,
    },
    struct_interval{
        .first = 4193,
        .last = 4193,
    },
    struct_interval{
        .first = 4197,
        .last = 4198,
    },
    struct_interval{
        .first = 4206,
        .last = 4208,
    },
    struct_interval{
        .first = 4213,
        .last = 4225,
    },
    struct_interval{
        .first = 4238,
        .last = 4238,
    },
    struct_interval{
        .first = 4352,
        .last = 4680,
    },
    struct_interval{
        .first = 4682,
        .last = 4685,
    },
    struct_interval{
        .first = 4688,
        .last = 4694,
    },
    struct_interval{
        .first = 4696,
        .last = 4696,
    },
    struct_interval{
        .first = 4698,
        .last = 4701,
    },
    struct_interval{
        .first = 4704,
        .last = 4744,
    },
    struct_interval{
        .first = 4746,
        .last = 4749,
    },
    struct_interval{
        .first = 4752,
        .last = 4784,
    },
    struct_interval{
        .first = 4786,
        .last = 4789,
    },
    struct_interval{
        .first = 4792,
        .last = 4798,
    },
    struct_interval{
        .first = 4800,
        .last = 4800,
    },
    struct_interval{
        .first = 4802,
        .last = 4805,
    },
    struct_interval{
        .first = 4808,
        .last = 4822,
    },
    struct_interval{
        .first = 4824,
        .last = 4880,
    },
    struct_interval{
        .first = 4882,
        .last = 4885,
    },
    struct_interval{
        .first = 4888,
        .last = 4954,
    },
    struct_interval{
        .first = 4992,
        .last = 5007,
    },
    struct_interval{
        .first = 5121,
        .last = 5740,
    },
    struct_interval{
        .first = 5743,
        .last = 5759,
    },
    struct_interval{
        .first = 5761,
        .last = 5786,
    },
    struct_interval{
        .first = 5792,
        .last = 5866,
    },
    struct_interval{
        .first = 5873,
        .last = 5880,
    },
    struct_interval{
        .first = 5888,
        .last = 5905,
    },
    struct_interval{
        .first = 5919,
        .last = 5937,
    },
    struct_interval{
        .first = 5952,
        .last = 5969,
    },
    struct_interval{
        .first = 5984,
        .last = 5996,
    },
    struct_interval{
        .first = 5998,
        .last = 6000,
    },
    struct_interval{
        .first = 6016,
        .last = 6067,
    },
    struct_interval{
        .first = 6108,
        .last = 6108,
    },
    struct_interval{
        .first = 6176,
        .last = 6210,
    },
    struct_interval{
        .first = 6212,
        .last = 6264,
    },
    struct_interval{
        .first = 6272,
        .last = 6276,
    },
    struct_interval{
        .first = 6279,
        .last = 6312,
    },
    struct_interval{
        .first = 6314,
        .last = 6314,
    },
    struct_interval{
        .first = 6320,
        .last = 6389,
    },
    struct_interval{
        .first = 6400,
        .last = 6430,
    },
    struct_interval{
        .first = 6480,
        .last = 6509,
    },
    struct_interval{
        .first = 6512,
        .last = 6516,
    },
    struct_interval{
        .first = 6528,
        .last = 6571,
    },
    struct_interval{
        .first = 6576,
        .last = 6601,
    },
    struct_interval{
        .first = 6656,
        .last = 6678,
    },
    struct_interval{
        .first = 6688,
        .last = 6740,
    },
    struct_interval{
        .first = 6917,
        .last = 6963,
    },
    struct_interval{
        .first = 6981,
        .last = 6988,
    },
    struct_interval{
        .first = 7043,
        .last = 7072,
    },
    struct_interval{
        .first = 7086,
        .last = 7087,
    },
    struct_interval{
        .first = 7098,
        .last = 7141,
    },
    struct_interval{
        .first = 7168,
        .last = 7203,
    },
    struct_interval{
        .first = 7245,
        .last = 7247,
    },
    struct_interval{
        .first = 7258,
        .last = 7287,
    },
    struct_interval{
        .first = 7401,
        .last = 7404,
    },
    struct_interval{
        .first = 7406,
        .last = 7411,
    },
    struct_interval{
        .first = 7413,
        .last = 7414,
    },
    struct_interval{
        .first = 7418,
        .last = 7418,
    },
    struct_interval{
        .first = 8501,
        .last = 8504,
    },
    struct_interval{
        .first = 11568,
        .last = 11623,
    },
    struct_interval{
        .first = 11648,
        .last = 11670,
    },
    struct_interval{
        .first = 11680,
        .last = 11686,
    },
    struct_interval{
        .first = 11688,
        .last = 11694,
    },
    struct_interval{
        .first = 11696,
        .last = 11702,
    },
    struct_interval{
        .first = 11704,
        .last = 11710,
    },
    struct_interval{
        .first = 11712,
        .last = 11718,
    },
    struct_interval{
        .first = 11720,
        .last = 11726,
    },
    struct_interval{
        .first = 11728,
        .last = 11734,
    },
    struct_interval{
        .first = 11736,
        .last = 11742,
    },
    struct_interval{
        .first = 12294,
        .last = 12294,
    },
    struct_interval{
        .first = 12348,
        .last = 12348,
    },
    struct_interval{
        .first = 12353,
        .last = 12438,
    },
    struct_interval{
        .first = 12447,
        .last = 12447,
    },
    struct_interval{
        .first = 12449,
        .last = 12538,
    },
    struct_interval{
        .first = 12543,
        .last = 12543,
    },
    struct_interval{
        .first = 12549,
        .last = 12591,
    },
    struct_interval{
        .first = 12593,
        .last = 12686,
    },
    struct_interval{
        .first = 12704,
        .last = 12735,
    },
    struct_interval{
        .first = 12784,
        .last = 12799,
    },
    struct_interval{
        .first = 13312,
        .last = 19903,
    },
    struct_interval{
        .first = 19968,
        .last = 40980,
    },
    struct_interval{
        .first = 40982,
        .last = 42124,
    },
    struct_interval{
        .first = 42192,
        .last = 42231,
    },
    struct_interval{
        .first = 42240,
        .last = 42507,
    },
    struct_interval{
        .first = 42512,
        .last = 42527,
    },
    struct_interval{
        .first = 42538,
        .last = 42539,
    },
    struct_interval{
        .first = 42606,
        .last = 42606,
    },
    struct_interval{
        .first = 42656,
        .last = 42725,
    },
    struct_interval{
        .first = 42895,
        .last = 42895,
    },
    struct_interval{
        .first = 42999,
        .last = 42999,
    },
    struct_interval{
        .first = 43003,
        .last = 43009,
    },
    struct_interval{
        .first = 43011,
        .last = 43013,
    },
    struct_interval{
        .first = 43015,
        .last = 43018,
    },
    struct_interval{
        .first = 43020,
        .last = 43042,
    },
    struct_interval{
        .first = 43072,
        .last = 43123,
    },
    struct_interval{
        .first = 43138,
        .last = 43187,
    },
    struct_interval{
        .first = 43250,
        .last = 43255,
    },
    struct_interval{
        .first = 43259,
        .last = 43259,
    },
    struct_interval{
        .first = 43261,
        .last = 43262,
    },
    struct_interval{
        .first = 43274,
        .last = 43301,
    },
    struct_interval{
        .first = 43312,
        .last = 43334,
    },
    struct_interval{
        .first = 43360,
        .last = 43388,
    },
    struct_interval{
        .first = 43396,
        .last = 43442,
    },
    struct_interval{
        .first = 43488,
        .last = 43492,
    },
    struct_interval{
        .first = 43495,
        .last = 43503,
    },
    struct_interval{
        .first = 43514,
        .last = 43518,
    },
    struct_interval{
        .first = 43520,
        .last = 43560,
    },
    struct_interval{
        .first = 43584,
        .last = 43586,
    },
    struct_interval{
        .first = 43588,
        .last = 43595,
    },
    struct_interval{
        .first = 43616,
        .last = 43631,
    },
    struct_interval{
        .first = 43633,
        .last = 43638,
    },
    struct_interval{
        .first = 43642,
        .last = 43642,
    },
    struct_interval{
        .first = 43646,
        .last = 43695,
    },
    struct_interval{
        .first = 43697,
        .last = 43697,
    },
    struct_interval{
        .first = 43701,
        .last = 43702,
    },
    struct_interval{
        .first = 43705,
        .last = 43709,
    },
    struct_interval{
        .first = 43712,
        .last = 43712,
    },
    struct_interval{
        .first = 43714,
        .last = 43714,
    },
    struct_interval{
        .first = 43739,
        .last = 43740,
    },
    struct_interval{
        .first = 43744,
        .last = 43754,
    },
    struct_interval{
        .first = 43762,
        .last = 43762,
    },
    struct_interval{
        .first = 43777,
        .last = 43782,
    },
    struct_interval{
        .first = 43785,
        .last = 43790,
    },
    struct_interval{
        .first = 43793,
        .last = 43798,
    },
    struct_interval{
        .first = 43808,
        .last = 43814,
    },
    struct_interval{
        .first = 43816,
        .last = 43822,
    },
    struct_interval{
        .first = 43968,
        .last = 44002,
    },
    struct_interval{
        .first = 44032,
        .last = 55203,
    },
    struct_interval{
        .first = 55216,
        .last = 55238,
    },
    struct_interval{
        .first = 55243,
        .last = 55291,
    },
    struct_interval{
        .first = 63744,
        .last = 64109,
    },
    struct_interval{
        .first = 64112,
        .last = 64217,
    },
    struct_interval{
        .first = 64285,
        .last = 64285,
    },
    struct_interval{
        .first = 64287,
        .last = 64296,
    },
    struct_interval{
        .first = 64298,
        .last = 64310,
    },
    struct_interval{
        .first = 64312,
        .last = 64316,
    },
    struct_interval{
        .first = 64318,
        .last = 64318,
    },
    struct_interval{
        .first = 64320,
        .last = 64321,
    },
    struct_interval{
        .first = 64323,
        .last = 64324,
    },
    struct_interval{
        .first = 64326,
        .last = 64433,
    },
    struct_interval{
        .first = 64467,
        .last = 64829,
    },
    struct_interval{
        .first = 64848,
        .last = 64911,
    },
    struct_interval{
        .first = 64914,
        .last = 64967,
    },
    struct_interval{
        .first = 65008,
        .last = 65019,
    },
    struct_interval{
        .first = 65136,
        .last = 65140,
    },
    struct_interval{
        .first = 65142,
        .last = 65276,
    },
    struct_interval{
        .first = 65382,
        .last = 65391,
    },
    struct_interval{
        .first = 65393,
        .last = 65437,
    },
    struct_interval{
        .first = 65440,
        .last = 65470,
    },
    struct_interval{
        .first = 65474,
        .last = 65479,
    },
    struct_interval{
        .first = 65482,
        .last = 65487,
    },
    struct_interval{
        .first = 65490,
        .last = 65495,
    },
    struct_interval{
        .first = 65498,
        .last = 65500,
    },
    struct_interval{
        .first = 65536,
        .last = 65547,
    },
    struct_interval{
        .first = 65549,
        .last = 65574,
    },
    struct_interval{
        .first = 65576,
        .last = 65594,
    },
    struct_interval{
        .first = 65596,
        .last = 65597,
    },
    struct_interval{
        .first = 65599,
        .last = 65613,
    },
    struct_interval{
        .first = 65616,
        .last = 65629,
    },
    struct_interval{
        .first = 65664,
        .last = 65786,
    },
    struct_interval{
        .first = 66176,
        .last = 66204,
    },
    struct_interval{
        .first = 66208,
        .last = 66256,
    },
    struct_interval{
        .first = 66304,
        .last = 66335,
    },
    struct_interval{
        .first = 66349,
        .last = 66368,
    },
    struct_interval{
        .first = 66370,
        .last = 66377,
    },
    struct_interval{
        .first = 66384,
        .last = 66421,
    },
    struct_interval{
        .first = 66432,
        .last = 66461,
    },
    struct_interval{
        .first = 66464,
        .last = 66499,
    },
    struct_interval{
        .first = 66504,
        .last = 66511,
    },
    struct_interval{
        .first = 66640,
        .last = 66717,
    },
    struct_interval{
        .first = 66816,
        .last = 66855,
    },
    struct_interval{
        .first = 66864,
        .last = 66915,
    },
    struct_interval{
        .first = 67008,
        .last = 67059,
    },
    struct_interval{
        .first = 67072,
        .last = 67382,
    },
    struct_interval{
        .first = 67392,
        .last = 67413,
    },
    struct_interval{
        .first = 67424,
        .last = 67431,
    },
    struct_interval{
        .first = 67584,
        .last = 67589,
    },
    struct_interval{
        .first = 67592,
        .last = 67592,
    },
    struct_interval{
        .first = 67594,
        .last = 67637,
    },
    struct_interval{
        .first = 67639,
        .last = 67640,
    },
    struct_interval{
        .first = 67644,
        .last = 67644,
    },
    struct_interval{
        .first = 67647,
        .last = 67669,
    },
    struct_interval{
        .first = 67680,
        .last = 67702,
    },
    struct_interval{
        .first = 67712,
        .last = 67742,
    },
    struct_interval{
        .first = 67808,
        .last = 67826,
    },
    struct_interval{
        .first = 67828,
        .last = 67829,
    },
    struct_interval{
        .first = 67840,
        .last = 67861,
    },
    struct_interval{
        .first = 67872,
        .last = 67897,
    },
    struct_interval{
        .first = 67904,
        .last = 67929,
    },
    struct_interval{
        .first = 67968,
        .last = 68023,
    },
    struct_interval{
        .first = 68030,
        .last = 68031,
    },
    struct_interval{
        .first = 68096,
        .last = 68096,
    },
    struct_interval{
        .first = 68112,
        .last = 68115,
    },
    struct_interval{
        .first = 68117,
        .last = 68119,
    },
    struct_interval{
        .first = 68121,
        .last = 68149,
    },
    struct_interval{
        .first = 68192,
        .last = 68220,
    },
    struct_interval{
        .first = 68224,
        .last = 68252,
    },
    struct_interval{
        .first = 68288,
        .last = 68295,
    },
    struct_interval{
        .first = 68297,
        .last = 68324,
    },
    struct_interval{
        .first = 68352,
        .last = 68405,
    },
    struct_interval{
        .first = 68416,
        .last = 68437,
    },
    struct_interval{
        .first = 68448,
        .last = 68466,
    },
    struct_interval{
        .first = 68480,
        .last = 68497,
    },
    struct_interval{
        .first = 68608,
        .last = 68680,
    },
    struct_interval{
        .first = 68864,
        .last = 68899,
    },
    struct_interval{
        .first = 68938,
        .last = 68941,
    },
    struct_interval{
        .first = 68943,
        .last = 68943,
    },
    struct_interval{
        .first = 69248,
        .last = 69289,
    },
    struct_interval{
        .first = 69296,
        .last = 69297,
    },
    struct_interval{
        .first = 69314,
        .last = 69316,
    },
    struct_interval{
        .first = 69318,
        .last = 69319,
    },
    struct_interval{
        .first = 69376,
        .last = 69404,
    },
    struct_interval{
        .first = 69415,
        .last = 69415,
    },
    struct_interval{
        .first = 69424,
        .last = 69445,
    },
    struct_interval{
        .first = 69488,
        .last = 69505,
    },
    struct_interval{
        .first = 69552,
        .last = 69572,
    },
    struct_interval{
        .first = 69600,
        .last = 69622,
    },
    struct_interval{
        .first = 69635,
        .last = 69687,
    },
    struct_interval{
        .first = 69745,
        .last = 69746,
    },
    struct_interval{
        .first = 69749,
        .last = 69749,
    },
    struct_interval{
        .first = 69763,
        .last = 69807,
    },
    struct_interval{
        .first = 69840,
        .last = 69864,
    },
    struct_interval{
        .first = 69891,
        .last = 69926,
    },
    struct_interval{
        .first = 69956,
        .last = 69956,
    },
    struct_interval{
        .first = 69959,
        .last = 69959,
    },
    struct_interval{
        .first = 69968,
        .last = 70002,
    },
    struct_interval{
        .first = 70006,
        .last = 70006,
    },
    struct_interval{
        .first = 70019,
        .last = 70066,
    },
    struct_interval{
        .first = 70081,
        .last = 70084,
    },
    struct_interval{
        .first = 70106,
        .last = 70106,
    },
    struct_interval{
        .first = 70108,
        .last = 70108,
    },
    struct_interval{
        .first = 70144,
        .last = 70161,
    },
    struct_interval{
        .first = 70163,
        .last = 70187,
    },
    struct_interval{
        .first = 70207,
        .last = 70208,
    },
    struct_interval{
        .first = 70272,
        .last = 70278,
    },
    struct_interval{
        .first = 70280,
        .last = 70280,
    },
    struct_interval{
        .first = 70282,
        .last = 70285,
    },
    struct_interval{
        .first = 70287,
        .last = 70301,
    },
    struct_interval{
        .first = 70303,
        .last = 70312,
    },
    struct_interval{
        .first = 70320,
        .last = 70366,
    },
    struct_interval{
        .first = 70405,
        .last = 70412,
    },
    struct_interval{
        .first = 70415,
        .last = 70416,
    },
    struct_interval{
        .first = 70419,
        .last = 70440,
    },
    struct_interval{
        .first = 70442,
        .last = 70448,
    },
    struct_interval{
        .first = 70450,
        .last = 70451,
    },
    struct_interval{
        .first = 70453,
        .last = 70457,
    },
    struct_interval{
        .first = 70461,
        .last = 70461,
    },
    struct_interval{
        .first = 70480,
        .last = 70480,
    },
    struct_interval{
        .first = 70493,
        .last = 70497,
    },
    struct_interval{
        .first = 70528,
        .last = 70537,
    },
    struct_interval{
        .first = 70539,
        .last = 70539,
    },
    struct_interval{
        .first = 70542,
        .last = 70542,
    },
    struct_interval{
        .first = 70544,
        .last = 70581,
    },
    struct_interval{
        .first = 70583,
        .last = 70583,
    },
    struct_interval{
        .first = 70609,
        .last = 70609,
    },
    struct_interval{
        .first = 70611,
        .last = 70611,
    },
    struct_interval{
        .first = 70656,
        .last = 70708,
    },
    struct_interval{
        .first = 70727,
        .last = 70730,
    },
    struct_interval{
        .first = 70751,
        .last = 70753,
    },
    struct_interval{
        .first = 70784,
        .last = 70831,
    },
    struct_interval{
        .first = 70852,
        .last = 70853,
    },
    struct_interval{
        .first = 70855,
        .last = 70855,
    },
    struct_interval{
        .first = 71040,
        .last = 71086,
    },
    struct_interval{
        .first = 71128,
        .last = 71131,
    },
    struct_interval{
        .first = 71168,
        .last = 71215,
    },
    struct_interval{
        .first = 71236,
        .last = 71236,
    },
    struct_interval{
        .first = 71296,
        .last = 71338,
    },
    struct_interval{
        .first = 71352,
        .last = 71352,
    },
    struct_interval{
        .first = 71424,
        .last = 71450,
    },
    struct_interval{
        .first = 71488,
        .last = 71494,
    },
    struct_interval{
        .first = 71680,
        .last = 71723,
    },
    struct_interval{
        .first = 71935,
        .last = 71942,
    },
    struct_interval{
        .first = 71945,
        .last = 71945,
    },
    struct_interval{
        .first = 71948,
        .last = 71955,
    },
    struct_interval{
        .first = 71957,
        .last = 71958,
    },
    struct_interval{
        .first = 71960,
        .last = 71983,
    },
    struct_interval{
        .first = 71999,
        .last = 71999,
    },
    struct_interval{
        .first = 72001,
        .last = 72001,
    },
    struct_interval{
        .first = 72096,
        .last = 72103,
    },
    struct_interval{
        .first = 72106,
        .last = 72144,
    },
    struct_interval{
        .first = 72161,
        .last = 72161,
    },
    struct_interval{
        .first = 72163,
        .last = 72163,
    },
    struct_interval{
        .first = 72192,
        .last = 72192,
    },
    struct_interval{
        .first = 72203,
        .last = 72242,
    },
    struct_interval{
        .first = 72250,
        .last = 72250,
    },
    struct_interval{
        .first = 72272,
        .last = 72272,
    },
    struct_interval{
        .first = 72284,
        .last = 72329,
    },
    struct_interval{
        .first = 72349,
        .last = 72349,
    },
    struct_interval{
        .first = 72368,
        .last = 72440,
    },
    struct_interval{
        .first = 72640,
        .last = 72672,
    },
    struct_interval{
        .first = 72704,
        .last = 72712,
    },
    struct_interval{
        .first = 72714,
        .last = 72750,
    },
    struct_interval{
        .first = 72768,
        .last = 72768,
    },
    struct_interval{
        .first = 72818,
        .last = 72847,
    },
    struct_interval{
        .first = 72960,
        .last = 72966,
    },
    struct_interval{
        .first = 72968,
        .last = 72969,
    },
    struct_interval{
        .first = 72971,
        .last = 73008,
    },
    struct_interval{
        .first = 73030,
        .last = 73030,
    },
    struct_interval{
        .first = 73056,
        .last = 73061,
    },
    struct_interval{
        .first = 73063,
        .last = 73064,
    },
    struct_interval{
        .first = 73066,
        .last = 73097,
    },
    struct_interval{
        .first = 73112,
        .last = 73112,
    },
    struct_interval{
        .first = 73136,
        .last = 73176,
    },
    struct_interval{
        .first = 73178,
        .last = 73179,
    },
    struct_interval{
        .first = 73440,
        .last = 73458,
    },
    struct_interval{
        .first = 73474,
        .last = 73474,
    },
    struct_interval{
        .first = 73476,
        .last = 73488,
    },
    struct_interval{
        .first = 73490,
        .last = 73523,
    },
    struct_interval{
        .first = 73648,
        .last = 73648,
    },
    struct_interval{
        .first = 73728,
        .last = 74649,
    },
    struct_interval{
        .first = 74880,
        .last = 75075,
    },
    struct_interval{
        .first = 77712,
        .last = 77808,
    },
    struct_interval{
        .first = 77824,
        .last = 78895,
    },
    struct_interval{
        .first = 78913,
        .last = 78918,
    },
    struct_interval{
        .first = 78944,
        .last = 82938,
    },
    struct_interval{
        .first = 82944,
        .last = 83526,
    },
    struct_interval{
        .first = 90368,
        .last = 90397,
    },
    struct_interval{
        .first = 92160,
        .last = 92728,
    },
    struct_interval{
        .first = 92736,
        .last = 92766,
    },
    struct_interval{
        .first = 92784,
        .last = 92862,
    },
    struct_interval{
        .first = 92880,
        .last = 92909,
    },
    struct_interval{
        .first = 92928,
        .last = 92975,
    },
    struct_interval{
        .first = 93027,
        .last = 93047,
    },
    struct_interval{
        .first = 93053,
        .last = 93071,
    },
    struct_interval{
        .first = 93507,
        .last = 93546,
    },
    struct_interval{
        .first = 93952,
        .last = 94026,
    },
    struct_interval{
        .first = 94032,
        .last = 94032,
    },
    struct_interval{
        .first = 94208,
        .last = 101589,
    },
    struct_interval{
        .first = 101631,
        .last = 101662,
    },
    struct_interval{
        .first = 101760,
        .last = 101874,
    },
    struct_interval{
        .first = 110592,
        .last = 110882,
    },
    struct_interval{
        .first = 110898,
        .last = 110898,
    },
    struct_interval{
        .first = 110928,
        .last = 110930,
    },
    struct_interval{
        .first = 110933,
        .last = 110933,
    },
    struct_interval{
        .first = 110948,
        .last = 110951,
    },
    struct_interval{
        .first = 110960,
        .last = 111355,
    },
    struct_interval{
        .first = 113664,
        .last = 113770,
    },
    struct_interval{
        .first = 113776,
        .last = 113788,
    },
    struct_interval{
        .first = 113792,
        .last = 113800,
    },
    struct_interval{
        .first = 113808,
        .last = 113817,
    },
    struct_interval{
        .first = 122634,
        .last = 122634,
    },
    struct_interval{
        .first = 123136,
        .last = 123180,
    },
    struct_interval{
        .first = 123214,
        .last = 123214,
    },
    struct_interval{
        .first = 123536,
        .last = 123565,
    },
    struct_interval{
        .first = 123584,
        .last = 123627,
    },
    struct_interval{
        .first = 124112,
        .last = 124138,
    },
    struct_interval{
        .first = 124368,
        .last = 124397,
    },
    struct_interval{
        .first = 124400,
        .last = 124400,
    },
    struct_interval{
        .first = 124608,
        .last = 124638,
    },
    struct_interval{
        .first = 124640,
        .last = 124642,
    },
    struct_interval{
        .first = 124644,
        .last = 124645,
    },
    struct_interval{
        .first = 124647,
        .last = 124653,
    },
    struct_interval{
        .first = 124656,
        .last = 124660,
    },
    struct_interval{
        .first = 124670,
        .last = 124670,
    },
    struct_interval{
        .first = 124896,
        .last = 124902,
    },
    struct_interval{
        .first = 124904,
        .last = 124907,
    },
    struct_interval{
        .first = 124909,
        .last = 124910,
    },
    struct_interval{
        .first = 124912,
        .last = 124926,
    },
    struct_interval{
        .first = 124928,
        .last = 125124,
    },
    struct_interval{
        .first = 126464,
        .last = 126467,
    },
    struct_interval{
        .first = 126469,
        .last = 126495,
    },
    struct_interval{
        .first = 126497,
        .last = 126498,
    },
    struct_interval{
        .first = 126500,
        .last = 126500,
    },
    struct_interval{
        .first = 126503,
        .last = 126503,
    },
    struct_interval{
        .first = 126505,
        .last = 126514,
    },
    struct_interval{
        .first = 126516,
        .last = 126519,
    },
    struct_interval{
        .first = 126521,
        .last = 126521,
    },
    struct_interval{
        .first = 126523,
        .last = 126523,
    },
    struct_interval{
        .first = 126530,
        .last = 126530,
    },
    struct_interval{
        .first = 126535,
        .last = 126535,
    },
    struct_interval{
        .first = 126537,
        .last = 126537,
    },
    struct_interval{
        .first = 126539,
        .last = 126539,
    },
    struct_interval{
        .first = 126541,
        .last = 126543,
    },
    struct_interval{
        .first = 126545,
        .last = 126546,
    },
    struct_interval{
        .first = 126548,
        .last = 126548,
    },
    struct_interval{
        .first = 126551,
        .last = 126551,
    },
    struct_interval{
        .first = 126553,
        .last = 126553,
    },
    struct_interval{
        .first = 126555,
        .last = 126555,
    },
    struct_interval{
        .first = 126557,
        .last = 126557,
    },
    struct_interval{
        .first = 126559,
        .last = 126559,
    },
    struct_interval{
        .first = 126561,
        .last = 126562,
    },
    struct_interval{
        .first = 126564,
        .last = 126564,
    },
    struct_interval{
        .first = 126567,
        .last = 126570,
    },
    struct_interval{
        .first = 126572,
        .last = 126578,
    },
    struct_interval{
        .first = 126580,
        .last = 126583,
    },
    struct_interval{
        .first = 126585,
        .last = 126588,
    },
    struct_interval{
        .first = 126590,
        .last = 126590,
    },
    struct_interval{
        .first = 126592,
        .last = 126601,
    },
    struct_interval{
        .first = 126603,
        .last = 126619,
    },
    struct_interval{
        .first = 126625,
        .last = 126627,
    },
    struct_interval{
        .first = 126629,
        .last = 126633,
    },
    struct_interval{
        .first = 126635,
        .last = 126651,
    },
    struct_interval{
        .first = 131072,
        .last = 173791,
    },
    struct_interval{
        .first = 173824,
        .last = 178205,
    },
    struct_interval{
        .first = 178208,
        .last = 183981,
    },
    struct_interval{
        .first = 183984,
        .last = 191456,
    },
    struct_interval{
        .first = 191472,
        .last = 192093,
    },
    struct_interval{
        .first = 194560,
        .last = 195101,
    },
    struct_interval{
        .first = 196608,
        .last = 201546,
    },
    struct_interval{
        .first = 201552,
        .last = 210041,
    },
};
pub export const So_table: [193]struct_interval = [193]struct_interval{
    struct_interval{
        .first = 166,
        .last = 166,
    },
    struct_interval{
        .first = 169,
        .last = 169,
    },
    struct_interval{
        .first = 174,
        .last = 174,
    },
    struct_interval{
        .first = 176,
        .last = 176,
    },
    struct_interval{
        .first = 1154,
        .last = 1154,
    },
    struct_interval{
        .first = 1421,
        .last = 1422,
    },
    struct_interval{
        .first = 1550,
        .last = 1551,
    },
    struct_interval{
        .first = 1758,
        .last = 1758,
    },
    struct_interval{
        .first = 1769,
        .last = 1769,
    },
    struct_interval{
        .first = 1789,
        .last = 1790,
    },
    struct_interval{
        .first = 2038,
        .last = 2038,
    },
    struct_interval{
        .first = 2554,
        .last = 2554,
    },
    struct_interval{
        .first = 2928,
        .last = 2928,
    },
    struct_interval{
        .first = 3059,
        .last = 3064,
    },
    struct_interval{
        .first = 3066,
        .last = 3066,
    },
    struct_interval{
        .first = 3199,
        .last = 3199,
    },
    struct_interval{
        .first = 3407,
        .last = 3407,
    },
    struct_interval{
        .first = 3449,
        .last = 3449,
    },
    struct_interval{
        .first = 3841,
        .last = 3843,
    },
    struct_interval{
        .first = 3859,
        .last = 3859,
    },
    struct_interval{
        .first = 3861,
        .last = 3863,
    },
    struct_interval{
        .first = 3866,
        .last = 3871,
    },
    struct_interval{
        .first = 3892,
        .last = 3892,
    },
    struct_interval{
        .first = 3894,
        .last = 3894,
    },
    struct_interval{
        .first = 3896,
        .last = 3896,
    },
    struct_interval{
        .first = 4030,
        .last = 4037,
    },
    struct_interval{
        .first = 4039,
        .last = 4044,
    },
    struct_interval{
        .first = 4046,
        .last = 4047,
    },
    struct_interval{
        .first = 4053,
        .last = 4056,
    },
    struct_interval{
        .first = 4254,
        .last = 4255,
    },
    struct_interval{
        .first = 5008,
        .last = 5017,
    },
    struct_interval{
        .first = 5741,
        .last = 5741,
    },
    struct_interval{
        .first = 6464,
        .last = 6464,
    },
    struct_interval{
        .first = 6622,
        .last = 6655,
    },
    struct_interval{
        .first = 7009,
        .last = 7018,
    },
    struct_interval{
        .first = 7028,
        .last = 7036,
    },
    struct_interval{
        .first = 8448,
        .last = 8449,
    },
    struct_interval{
        .first = 8451,
        .last = 8454,
    },
    struct_interval{
        .first = 8456,
        .last = 8457,
    },
    struct_interval{
        .first = 8468,
        .last = 8468,
    },
    struct_interval{
        .first = 8470,
        .last = 8471,
    },
    struct_interval{
        .first = 8478,
        .last = 8483,
    },
    struct_interval{
        .first = 8485,
        .last = 8485,
    },
    struct_interval{
        .first = 8487,
        .last = 8487,
    },
    struct_interval{
        .first = 8489,
        .last = 8489,
    },
    struct_interval{
        .first = 8494,
        .last = 8494,
    },
    struct_interval{
        .first = 8506,
        .last = 8507,
    },
    struct_interval{
        .first = 8522,
        .last = 8522,
    },
    struct_interval{
        .first = 8524,
        .last = 8525,
    },
    struct_interval{
        .first = 8527,
        .last = 8527,
    },
    struct_interval{
        .first = 8586,
        .last = 8587,
    },
    struct_interval{
        .first = 8597,
        .last = 8601,
    },
    struct_interval{
        .first = 8604,
        .last = 8607,
    },
    struct_interval{
        .first = 8609,
        .last = 8610,
    },
    struct_interval{
        .first = 8612,
        .last = 8613,
    },
    struct_interval{
        .first = 8615,
        .last = 8621,
    },
    struct_interval{
        .first = 8623,
        .last = 8653,
    },
    struct_interval{
        .first = 8656,
        .last = 8657,
    },
    struct_interval{
        .first = 8659,
        .last = 8659,
    },
    struct_interval{
        .first = 8661,
        .last = 8691,
    },
    struct_interval{
        .first = 8960,
        .last = 8967,
    },
    struct_interval{
        .first = 8972,
        .last = 8991,
    },
    struct_interval{
        .first = 8994,
        .last = 9000,
    },
    struct_interval{
        .first = 9003,
        .last = 9083,
    },
    struct_interval{
        .first = 9085,
        .last = 9114,
    },
    struct_interval{
        .first = 9140,
        .last = 9179,
    },
    struct_interval{
        .first = 9186,
        .last = 9257,
    },
    struct_interval{
        .first = 9280,
        .last = 9290,
    },
    struct_interval{
        .first = 9372,
        .last = 9449,
    },
    struct_interval{
        .first = 9472,
        .last = 9654,
    },
    struct_interval{
        .first = 9656,
        .last = 9664,
    },
    struct_interval{
        .first = 9666,
        .last = 9719,
    },
    struct_interval{
        .first = 9728,
        .last = 9838,
    },
    struct_interval{
        .first = 9840,
        .last = 10087,
    },
    struct_interval{
        .first = 10132,
        .last = 10175,
    },
    struct_interval{
        .first = 10240,
        .last = 10495,
    },
    struct_interval{
        .first = 11008,
        .last = 11055,
    },
    struct_interval{
        .first = 11077,
        .last = 11078,
    },
    struct_interval{
        .first = 11085,
        .last = 11123,
    },
    struct_interval{
        .first = 11126,
        .last = 11263,
    },
    struct_interval{
        .first = 11493,
        .last = 11498,
    },
    struct_interval{
        .first = 11856,
        .last = 11857,
    },
    struct_interval{
        .first = 11904,
        .last = 11929,
    },
    struct_interval{
        .first = 11931,
        .last = 12019,
    },
    struct_interval{
        .first = 12032,
        .last = 12245,
    },
    struct_interval{
        .first = 12272,
        .last = 12287,
    },
    struct_interval{
        .first = 12292,
        .last = 12292,
    },
    struct_interval{
        .first = 12306,
        .last = 12307,
    },
    struct_interval{
        .first = 12320,
        .last = 12320,
    },
    struct_interval{
        .first = 12342,
        .last = 12343,
    },
    struct_interval{
        .first = 12350,
        .last = 12351,
    },
    struct_interval{
        .first = 12688,
        .last = 12689,
    },
    struct_interval{
        .first = 12694,
        .last = 12703,
    },
    struct_interval{
        .first = 12736,
        .last = 12773,
    },
    struct_interval{
        .first = 12783,
        .last = 12783,
    },
    struct_interval{
        .first = 12800,
        .last = 12830,
    },
    struct_interval{
        .first = 12842,
        .last = 12871,
    },
    struct_interval{
        .first = 12880,
        .last = 12880,
    },
    struct_interval{
        .first = 12896,
        .last = 12927,
    },
    struct_interval{
        .first = 12938,
        .last = 12976,
    },
    struct_interval{
        .first = 12992,
        .last = 13311,
    },
    struct_interval{
        .first = 19904,
        .last = 19967,
    },
    struct_interval{
        .first = 42128,
        .last = 42182,
    },
    struct_interval{
        .first = 43048,
        .last = 43051,
    },
    struct_interval{
        .first = 43062,
        .last = 43063,
    },
    struct_interval{
        .first = 43065,
        .last = 43065,
    },
    struct_interval{
        .first = 43639,
        .last = 43641,
    },
    struct_interval{
        .first = 64451,
        .last = 64466,
    },
    struct_interval{
        .first = 64832,
        .last = 64847,
    },
    struct_interval{
        .first = 64912,
        .last = 64913,
    },
    struct_interval{
        .first = 64968,
        .last = 64975,
    },
    struct_interval{
        .first = 65021,
        .last = 65023,
    },
    struct_interval{
        .first = 65508,
        .last = 65508,
    },
    struct_interval{
        .first = 65512,
        .last = 65512,
    },
    struct_interval{
        .first = 65517,
        .last = 65518,
    },
    struct_interval{
        .first = 65532,
        .last = 65533,
    },
    struct_interval{
        .first = 65847,
        .last = 65855,
    },
    struct_interval{
        .first = 65913,
        .last = 65929,
    },
    struct_interval{
        .first = 65932,
        .last = 65934,
    },
    struct_interval{
        .first = 65936,
        .last = 65948,
    },
    struct_interval{
        .first = 65952,
        .last = 65952,
    },
    struct_interval{
        .first = 66000,
        .last = 66044,
    },
    struct_interval{
        .first = 67703,
        .last = 67704,
    },
    struct_interval{
        .first = 68296,
        .last = 68296,
    },
    struct_interval{
        .first = 69329,
        .last = 69336,
    },
    struct_interval{
        .first = 71487,
        .last = 71487,
    },
    struct_interval{
        .first = 73685,
        .last = 73692,
    },
    struct_interval{
        .first = 73697,
        .last = 73713,
    },
    struct_interval{
        .first = 92988,
        .last = 92991,
    },
    struct_interval{
        .first = 92997,
        .last = 92997,
    },
    struct_interval{
        .first = 113820,
        .last = 113820,
    },
    struct_interval{
        .first = 117760,
        .last = 117999,
    },
    struct_interval{
        .first = 118010,
        .last = 118012,
    },
    struct_interval{
        .first = 118016,
        .last = 118451,
    },
    struct_interval{
        .first = 118458,
        .last = 118480,
    },
    struct_interval{
        .first = 118496,
        .last = 118511,
    },
    struct_interval{
        .first = 118608,
        .last = 118723,
    },
    struct_interval{
        .first = 118784,
        .last = 119029,
    },
    struct_interval{
        .first = 119040,
        .last = 119078,
    },
    struct_interval{
        .first = 119081,
        .last = 119140,
    },
    struct_interval{
        .first = 119146,
        .last = 119148,
    },
    struct_interval{
        .first = 119171,
        .last = 119172,
    },
    struct_interval{
        .first = 119180,
        .last = 119209,
    },
    struct_interval{
        .first = 119214,
        .last = 119274,
    },
    struct_interval{
        .first = 119296,
        .last = 119361,
    },
    struct_interval{
        .first = 119365,
        .last = 119365,
    },
    struct_interval{
        .first = 119552,
        .last = 119638,
    },
    struct_interval{
        .first = 120832,
        .last = 121343,
    },
    struct_interval{
        .first = 121399,
        .last = 121402,
    },
    struct_interval{
        .first = 121453,
        .last = 121460,
    },
    struct_interval{
        .first = 121462,
        .last = 121475,
    },
    struct_interval{
        .first = 121477,
        .last = 121478,
    },
    struct_interval{
        .first = 123215,
        .last = 123215,
    },
    struct_interval{
        .first = 126124,
        .last = 126124,
    },
    struct_interval{
        .first = 126254,
        .last = 126254,
    },
    struct_interval{
        .first = 126976,
        .last = 127019,
    },
    struct_interval{
        .first = 127024,
        .last = 127123,
    },
    struct_interval{
        .first = 127136,
        .last = 127150,
    },
    struct_interval{
        .first = 127153,
        .last = 127167,
    },
    struct_interval{
        .first = 127169,
        .last = 127183,
    },
    struct_interval{
        .first = 127185,
        .last = 127221,
    },
    struct_interval{
        .first = 127245,
        .last = 127405,
    },
    struct_interval{
        .first = 127462,
        .last = 127490,
    },
    struct_interval{
        .first = 127504,
        .last = 127547,
    },
    struct_interval{
        .first = 127552,
        .last = 127560,
    },
    struct_interval{
        .first = 127568,
        .last = 127569,
    },
    struct_interval{
        .first = 127584,
        .last = 127589,
    },
    struct_interval{
        .first = 127744,
        .last = 127994,
    },
    struct_interval{
        .first = 128000,
        .last = 128728,
    },
    struct_interval{
        .first = 128732,
        .last = 128748,
    },
    struct_interval{
        .first = 128752,
        .last = 128764,
    },
    struct_interval{
        .first = 128768,
        .last = 128985,
    },
    struct_interval{
        .first = 128992,
        .last = 129003,
    },
    struct_interval{
        .first = 129008,
        .last = 129008,
    },
    struct_interval{
        .first = 129024,
        .last = 129035,
    },
    struct_interval{
        .first = 129040,
        .last = 129095,
    },
    struct_interval{
        .first = 129104,
        .last = 129113,
    },
    struct_interval{
        .first = 129120,
        .last = 129159,
    },
    struct_interval{
        .first = 129168,
        .last = 129197,
    },
    struct_interval{
        .first = 129200,
        .last = 129211,
    },
    struct_interval{
        .first = 129216,
        .last = 129217,
    },
    struct_interval{
        .first = 129280,
        .last = 129623,
    },
    struct_interval{
        .first = 129632,
        .last = 129645,
    },
    struct_interval{
        .first = 129648,
        .last = 129660,
    },
    struct_interval{
        .first = 129664,
        .last = 129674,
    },
    struct_interval{
        .first = 129678,
        .last = 129734,
    },
    struct_interval{
        .first = 129736,
        .last = 129736,
    },
    struct_interval{
        .first = 129741,
        .last = 129756,
    },
    struct_interval{
        .first = 129759,
        .last = 129770,
    },
    struct_interval{
        .first = 129775,
        .last = 129784,
    },
    struct_interval{
        .first = 129792,
        .last = 129938,
    },
    struct_interval{
        .first = 129940,
        .last = 130031,
    },
    struct_interval{
        .first = 130042,
        .last = 130042,
    },
};
pub export const Ll_table: [664]struct_interval = [664]struct_interval{
    struct_interval{
        .first = 97,
        .last = 122,
    },
    struct_interval{
        .first = 181,
        .last = 181,
    },
    struct_interval{
        .first = 223,
        .last = 246,
    },
    struct_interval{
        .first = 248,
        .last = 255,
    },
    struct_interval{
        .first = 257,
        .last = 257,
    },
    struct_interval{
        .first = 259,
        .last = 259,
    },
    struct_interval{
        .first = 261,
        .last = 261,
    },
    struct_interval{
        .first = 263,
        .last = 263,
    },
    struct_interval{
        .first = 265,
        .last = 265,
    },
    struct_interval{
        .first = 267,
        .last = 267,
    },
    struct_interval{
        .first = 269,
        .last = 269,
    },
    struct_interval{
        .first = 271,
        .last = 271,
    },
    struct_interval{
        .first = 273,
        .last = 273,
    },
    struct_interval{
        .first = 275,
        .last = 275,
    },
    struct_interval{
        .first = 277,
        .last = 277,
    },
    struct_interval{
        .first = 279,
        .last = 279,
    },
    struct_interval{
        .first = 281,
        .last = 281,
    },
    struct_interval{
        .first = 283,
        .last = 283,
    },
    struct_interval{
        .first = 285,
        .last = 285,
    },
    struct_interval{
        .first = 287,
        .last = 287,
    },
    struct_interval{
        .first = 289,
        .last = 289,
    },
    struct_interval{
        .first = 291,
        .last = 291,
    },
    struct_interval{
        .first = 293,
        .last = 293,
    },
    struct_interval{
        .first = 295,
        .last = 295,
    },
    struct_interval{
        .first = 297,
        .last = 297,
    },
    struct_interval{
        .first = 299,
        .last = 299,
    },
    struct_interval{
        .first = 301,
        .last = 301,
    },
    struct_interval{
        .first = 303,
        .last = 303,
    },
    struct_interval{
        .first = 305,
        .last = 305,
    },
    struct_interval{
        .first = 307,
        .last = 307,
    },
    struct_interval{
        .first = 309,
        .last = 309,
    },
    struct_interval{
        .first = 311,
        .last = 312,
    },
    struct_interval{
        .first = 314,
        .last = 314,
    },
    struct_interval{
        .first = 316,
        .last = 316,
    },
    struct_interval{
        .first = 318,
        .last = 318,
    },
    struct_interval{
        .first = 320,
        .last = 320,
    },
    struct_interval{
        .first = 322,
        .last = 322,
    },
    struct_interval{
        .first = 324,
        .last = 324,
    },
    struct_interval{
        .first = 326,
        .last = 326,
    },
    struct_interval{
        .first = 328,
        .last = 329,
    },
    struct_interval{
        .first = 331,
        .last = 331,
    },
    struct_interval{
        .first = 333,
        .last = 333,
    },
    struct_interval{
        .first = 335,
        .last = 335,
    },
    struct_interval{
        .first = 337,
        .last = 337,
    },
    struct_interval{
        .first = 339,
        .last = 339,
    },
    struct_interval{
        .first = 341,
        .last = 341,
    },
    struct_interval{
        .first = 343,
        .last = 343,
    },
    struct_interval{
        .first = 345,
        .last = 345,
    },
    struct_interval{
        .first = 347,
        .last = 347,
    },
    struct_interval{
        .first = 349,
        .last = 349,
    },
    struct_interval{
        .first = 351,
        .last = 351,
    },
    struct_interval{
        .first = 353,
        .last = 353,
    },
    struct_interval{
        .first = 355,
        .last = 355,
    },
    struct_interval{
        .first = 357,
        .last = 357,
    },
    struct_interval{
        .first = 359,
        .last = 359,
    },
    struct_interval{
        .first = 361,
        .last = 361,
    },
    struct_interval{
        .first = 363,
        .last = 363,
    },
    struct_interval{
        .first = 365,
        .last = 365,
    },
    struct_interval{
        .first = 367,
        .last = 367,
    },
    struct_interval{
        .first = 369,
        .last = 369,
    },
    struct_interval{
        .first = 371,
        .last = 371,
    },
    struct_interval{
        .first = 373,
        .last = 373,
    },
    struct_interval{
        .first = 375,
        .last = 375,
    },
    struct_interval{
        .first = 378,
        .last = 378,
    },
    struct_interval{
        .first = 380,
        .last = 380,
    },
    struct_interval{
        .first = 382,
        .last = 384,
    },
    struct_interval{
        .first = 387,
        .last = 387,
    },
    struct_interval{
        .first = 389,
        .last = 389,
    },
    struct_interval{
        .first = 392,
        .last = 392,
    },
    struct_interval{
        .first = 396,
        .last = 397,
    },
    struct_interval{
        .first = 402,
        .last = 402,
    },
    struct_interval{
        .first = 405,
        .last = 405,
    },
    struct_interval{
        .first = 409,
        .last = 411,
    },
    struct_interval{
        .first = 414,
        .last = 414,
    },
    struct_interval{
        .first = 417,
        .last = 417,
    },
    struct_interval{
        .first = 419,
        .last = 419,
    },
    struct_interval{
        .first = 421,
        .last = 421,
    },
    struct_interval{
        .first = 424,
        .last = 424,
    },
    struct_interval{
        .first = 426,
        .last = 427,
    },
    struct_interval{
        .first = 429,
        .last = 429,
    },
    struct_interval{
        .first = 432,
        .last = 432,
    },
    struct_interval{
        .first = 436,
        .last = 436,
    },
    struct_interval{
        .first = 438,
        .last = 438,
    },
    struct_interval{
        .first = 441,
        .last = 442,
    },
    struct_interval{
        .first = 445,
        .last = 447,
    },
    struct_interval{
        .first = 454,
        .last = 454,
    },
    struct_interval{
        .first = 457,
        .last = 457,
    },
    struct_interval{
        .first = 460,
        .last = 460,
    },
    struct_interval{
        .first = 462,
        .last = 462,
    },
    struct_interval{
        .first = 464,
        .last = 464,
    },
    struct_interval{
        .first = 466,
        .last = 466,
    },
    struct_interval{
        .first = 468,
        .last = 468,
    },
    struct_interval{
        .first = 470,
        .last = 470,
    },
    struct_interval{
        .first = 472,
        .last = 472,
    },
    struct_interval{
        .first = 474,
        .last = 474,
    },
    struct_interval{
        .first = 476,
        .last = 477,
    },
    struct_interval{
        .first = 479,
        .last = 479,
    },
    struct_interval{
        .first = 481,
        .last = 481,
    },
    struct_interval{
        .first = 483,
        .last = 483,
    },
    struct_interval{
        .first = 485,
        .last = 485,
    },
    struct_interval{
        .first = 487,
        .last = 487,
    },
    struct_interval{
        .first = 489,
        .last = 489,
    },
    struct_interval{
        .first = 491,
        .last = 491,
    },
    struct_interval{
        .first = 493,
        .last = 493,
    },
    struct_interval{
        .first = 495,
        .last = 496,
    },
    struct_interval{
        .first = 499,
        .last = 499,
    },
    struct_interval{
        .first = 501,
        .last = 501,
    },
    struct_interval{
        .first = 505,
        .last = 505,
    },
    struct_interval{
        .first = 507,
        .last = 507,
    },
    struct_interval{
        .first = 509,
        .last = 509,
    },
    struct_interval{
        .first = 511,
        .last = 511,
    },
    struct_interval{
        .first = 513,
        .last = 513,
    },
    struct_interval{
        .first = 515,
        .last = 515,
    },
    struct_interval{
        .first = 517,
        .last = 517,
    },
    struct_interval{
        .first = 519,
        .last = 519,
    },
    struct_interval{
        .first = 521,
        .last = 521,
    },
    struct_interval{
        .first = 523,
        .last = 523,
    },
    struct_interval{
        .first = 525,
        .last = 525,
    },
    struct_interval{
        .first = 527,
        .last = 527,
    },
    struct_interval{
        .first = 529,
        .last = 529,
    },
    struct_interval{
        .first = 531,
        .last = 531,
    },
    struct_interval{
        .first = 533,
        .last = 533,
    },
    struct_interval{
        .first = 535,
        .last = 535,
    },
    struct_interval{
        .first = 537,
        .last = 537,
    },
    struct_interval{
        .first = 539,
        .last = 539,
    },
    struct_interval{
        .first = 541,
        .last = 541,
    },
    struct_interval{
        .first = 543,
        .last = 543,
    },
    struct_interval{
        .first = 545,
        .last = 545,
    },
    struct_interval{
        .first = 547,
        .last = 547,
    },
    struct_interval{
        .first = 549,
        .last = 549,
    },
    struct_interval{
        .first = 551,
        .last = 551,
    },
    struct_interval{
        .first = 553,
        .last = 553,
    },
    struct_interval{
        .first = 555,
        .last = 555,
    },
    struct_interval{
        .first = 557,
        .last = 557,
    },
    struct_interval{
        .first = 559,
        .last = 559,
    },
    struct_interval{
        .first = 561,
        .last = 561,
    },
    struct_interval{
        .first = 563,
        .last = 569,
    },
    struct_interval{
        .first = 572,
        .last = 572,
    },
    struct_interval{
        .first = 575,
        .last = 576,
    },
    struct_interval{
        .first = 578,
        .last = 578,
    },
    struct_interval{
        .first = 583,
        .last = 583,
    },
    struct_interval{
        .first = 585,
        .last = 585,
    },
    struct_interval{
        .first = 587,
        .last = 587,
    },
    struct_interval{
        .first = 589,
        .last = 589,
    },
    struct_interval{
        .first = 591,
        .last = 659,
    },
    struct_interval{
        .first = 662,
        .last = 687,
    },
    struct_interval{
        .first = 881,
        .last = 881,
    },
    struct_interval{
        .first = 883,
        .last = 883,
    },
    struct_interval{
        .first = 887,
        .last = 887,
    },
    struct_interval{
        .first = 891,
        .last = 893,
    },
    struct_interval{
        .first = 912,
        .last = 912,
    },
    struct_interval{
        .first = 940,
        .last = 974,
    },
    struct_interval{
        .first = 976,
        .last = 977,
    },
    struct_interval{
        .first = 981,
        .last = 983,
    },
    struct_interval{
        .first = 985,
        .last = 985,
    },
    struct_interval{
        .first = 987,
        .last = 987,
    },
    struct_interval{
        .first = 989,
        .last = 989,
    },
    struct_interval{
        .first = 991,
        .last = 991,
    },
    struct_interval{
        .first = 993,
        .last = 993,
    },
    struct_interval{
        .first = 995,
        .last = 995,
    },
    struct_interval{
        .first = 997,
        .last = 997,
    },
    struct_interval{
        .first = 999,
        .last = 999,
    },
    struct_interval{
        .first = 1001,
        .last = 1001,
    },
    struct_interval{
        .first = 1003,
        .last = 1003,
    },
    struct_interval{
        .first = 1005,
        .last = 1005,
    },
    struct_interval{
        .first = 1007,
        .last = 1011,
    },
    struct_interval{
        .first = 1013,
        .last = 1013,
    },
    struct_interval{
        .first = 1016,
        .last = 1016,
    },
    struct_interval{
        .first = 1019,
        .last = 1020,
    },
    struct_interval{
        .first = 1072,
        .last = 1119,
    },
    struct_interval{
        .first = 1121,
        .last = 1121,
    },
    struct_interval{
        .first = 1123,
        .last = 1123,
    },
    struct_interval{
        .first = 1125,
        .last = 1125,
    },
    struct_interval{
        .first = 1127,
        .last = 1127,
    },
    struct_interval{
        .first = 1129,
        .last = 1129,
    },
    struct_interval{
        .first = 1131,
        .last = 1131,
    },
    struct_interval{
        .first = 1133,
        .last = 1133,
    },
    struct_interval{
        .first = 1135,
        .last = 1135,
    },
    struct_interval{
        .first = 1137,
        .last = 1137,
    },
    struct_interval{
        .first = 1139,
        .last = 1139,
    },
    struct_interval{
        .first = 1141,
        .last = 1141,
    },
    struct_interval{
        .first = 1143,
        .last = 1143,
    },
    struct_interval{
        .first = 1145,
        .last = 1145,
    },
    struct_interval{
        .first = 1147,
        .last = 1147,
    },
    struct_interval{
        .first = 1149,
        .last = 1149,
    },
    struct_interval{
        .first = 1151,
        .last = 1151,
    },
    struct_interval{
        .first = 1153,
        .last = 1153,
    },
    struct_interval{
        .first = 1163,
        .last = 1163,
    },
    struct_interval{
        .first = 1165,
        .last = 1165,
    },
    struct_interval{
        .first = 1167,
        .last = 1167,
    },
    struct_interval{
        .first = 1169,
        .last = 1169,
    },
    struct_interval{
        .first = 1171,
        .last = 1171,
    },
    struct_interval{
        .first = 1173,
        .last = 1173,
    },
    struct_interval{
        .first = 1175,
        .last = 1175,
    },
    struct_interval{
        .first = 1177,
        .last = 1177,
    },
    struct_interval{
        .first = 1179,
        .last = 1179,
    },
    struct_interval{
        .first = 1181,
        .last = 1181,
    },
    struct_interval{
        .first = 1183,
        .last = 1183,
    },
    struct_interval{
        .first = 1185,
        .last = 1185,
    },
    struct_interval{
        .first = 1187,
        .last = 1187,
    },
    struct_interval{
        .first = 1189,
        .last = 1189,
    },
    struct_interval{
        .first = 1191,
        .last = 1191,
    },
    struct_interval{
        .first = 1193,
        .last = 1193,
    },
    struct_interval{
        .first = 1195,
        .last = 1195,
    },
    struct_interval{
        .first = 1197,
        .last = 1197,
    },
    struct_interval{
        .first = 1199,
        .last = 1199,
    },
    struct_interval{
        .first = 1201,
        .last = 1201,
    },
    struct_interval{
        .first = 1203,
        .last = 1203,
    },
    struct_interval{
        .first = 1205,
        .last = 1205,
    },
    struct_interval{
        .first = 1207,
        .last = 1207,
    },
    struct_interval{
        .first = 1209,
        .last = 1209,
    },
    struct_interval{
        .first = 1211,
        .last = 1211,
    },
    struct_interval{
        .first = 1213,
        .last = 1213,
    },
    struct_interval{
        .first = 1215,
        .last = 1215,
    },
    struct_interval{
        .first = 1218,
        .last = 1218,
    },
    struct_interval{
        .first = 1220,
        .last = 1220,
    },
    struct_interval{
        .first = 1222,
        .last = 1222,
    },
    struct_interval{
        .first = 1224,
        .last = 1224,
    },
    struct_interval{
        .first = 1226,
        .last = 1226,
    },
    struct_interval{
        .first = 1228,
        .last = 1228,
    },
    struct_interval{
        .first = 1230,
        .last = 1231,
    },
    struct_interval{
        .first = 1233,
        .last = 1233,
    },
    struct_interval{
        .first = 1235,
        .last = 1235,
    },
    struct_interval{
        .first = 1237,
        .last = 1237,
    },
    struct_interval{
        .first = 1239,
        .last = 1239,
    },
    struct_interval{
        .first = 1241,
        .last = 1241,
    },
    struct_interval{
        .first = 1243,
        .last = 1243,
    },
    struct_interval{
        .first = 1245,
        .last = 1245,
    },
    struct_interval{
        .first = 1247,
        .last = 1247,
    },
    struct_interval{
        .first = 1249,
        .last = 1249,
    },
    struct_interval{
        .first = 1251,
        .last = 1251,
    },
    struct_interval{
        .first = 1253,
        .last = 1253,
    },
    struct_interval{
        .first = 1255,
        .last = 1255,
    },
    struct_interval{
        .first = 1257,
        .last = 1257,
    },
    struct_interval{
        .first = 1259,
        .last = 1259,
    },
    struct_interval{
        .first = 1261,
        .last = 1261,
    },
    struct_interval{
        .first = 1263,
        .last = 1263,
    },
    struct_interval{
        .first = 1265,
        .last = 1265,
    },
    struct_interval{
        .first = 1267,
        .last = 1267,
    },
    struct_interval{
        .first = 1269,
        .last = 1269,
    },
    struct_interval{
        .first = 1271,
        .last = 1271,
    },
    struct_interval{
        .first = 1273,
        .last = 1273,
    },
    struct_interval{
        .first = 1275,
        .last = 1275,
    },
    struct_interval{
        .first = 1277,
        .last = 1277,
    },
    struct_interval{
        .first = 1279,
        .last = 1279,
    },
    struct_interval{
        .first = 1281,
        .last = 1281,
    },
    struct_interval{
        .first = 1283,
        .last = 1283,
    },
    struct_interval{
        .first = 1285,
        .last = 1285,
    },
    struct_interval{
        .first = 1287,
        .last = 1287,
    },
    struct_interval{
        .first = 1289,
        .last = 1289,
    },
    struct_interval{
        .first = 1291,
        .last = 1291,
    },
    struct_interval{
        .first = 1293,
        .last = 1293,
    },
    struct_interval{
        .first = 1295,
        .last = 1295,
    },
    struct_interval{
        .first = 1297,
        .last = 1297,
    },
    struct_interval{
        .first = 1299,
        .last = 1299,
    },
    struct_interval{
        .first = 1301,
        .last = 1301,
    },
    struct_interval{
        .first = 1303,
        .last = 1303,
    },
    struct_interval{
        .first = 1305,
        .last = 1305,
    },
    struct_interval{
        .first = 1307,
        .last = 1307,
    },
    struct_interval{
        .first = 1309,
        .last = 1309,
    },
    struct_interval{
        .first = 1311,
        .last = 1311,
    },
    struct_interval{
        .first = 1313,
        .last = 1313,
    },
    struct_interval{
        .first = 1315,
        .last = 1315,
    },
    struct_interval{
        .first = 1317,
        .last = 1317,
    },
    struct_interval{
        .first = 1319,
        .last = 1319,
    },
    struct_interval{
        .first = 1321,
        .last = 1321,
    },
    struct_interval{
        .first = 1323,
        .last = 1323,
    },
    struct_interval{
        .first = 1325,
        .last = 1325,
    },
    struct_interval{
        .first = 1327,
        .last = 1327,
    },
    struct_interval{
        .first = 1376,
        .last = 1416,
    },
    struct_interval{
        .first = 4304,
        .last = 4346,
    },
    struct_interval{
        .first = 4349,
        .last = 4351,
    },
    struct_interval{
        .first = 5112,
        .last = 5117,
    },
    struct_interval{
        .first = 7296,
        .last = 7304,
    },
    struct_interval{
        .first = 7306,
        .last = 7306,
    },
    struct_interval{
        .first = 7424,
        .last = 7467,
    },
    struct_interval{
        .first = 7531,
        .last = 7543,
    },
    struct_interval{
        .first = 7545,
        .last = 7578,
    },
    struct_interval{
        .first = 7681,
        .last = 7681,
    },
    struct_interval{
        .first = 7683,
        .last = 7683,
    },
    struct_interval{
        .first = 7685,
        .last = 7685,
    },
    struct_interval{
        .first = 7687,
        .last = 7687,
    },
    struct_interval{
        .first = 7689,
        .last = 7689,
    },
    struct_interval{
        .first = 7691,
        .last = 7691,
    },
    struct_interval{
        .first = 7693,
        .last = 7693,
    },
    struct_interval{
        .first = 7695,
        .last = 7695,
    },
    struct_interval{
        .first = 7697,
        .last = 7697,
    },
    struct_interval{
        .first = 7699,
        .last = 7699,
    },
    struct_interval{
        .first = 7701,
        .last = 7701,
    },
    struct_interval{
        .first = 7703,
        .last = 7703,
    },
    struct_interval{
        .first = 7705,
        .last = 7705,
    },
    struct_interval{
        .first = 7707,
        .last = 7707,
    },
    struct_interval{
        .first = 7709,
        .last = 7709,
    },
    struct_interval{
        .first = 7711,
        .last = 7711,
    },
    struct_interval{
        .first = 7713,
        .last = 7713,
    },
    struct_interval{
        .first = 7715,
        .last = 7715,
    },
    struct_interval{
        .first = 7717,
        .last = 7717,
    },
    struct_interval{
        .first = 7719,
        .last = 7719,
    },
    struct_interval{
        .first = 7721,
        .last = 7721,
    },
    struct_interval{
        .first = 7723,
        .last = 7723,
    },
    struct_interval{
        .first = 7725,
        .last = 7725,
    },
    struct_interval{
        .first = 7727,
        .last = 7727,
    },
    struct_interval{
        .first = 7729,
        .last = 7729,
    },
    struct_interval{
        .first = 7731,
        .last = 7731,
    },
    struct_interval{
        .first = 7733,
        .last = 7733,
    },
    struct_interval{
        .first = 7735,
        .last = 7735,
    },
    struct_interval{
        .first = 7737,
        .last = 7737,
    },
    struct_interval{
        .first = 7739,
        .last = 7739,
    },
    struct_interval{
        .first = 7741,
        .last = 7741,
    },
    struct_interval{
        .first = 7743,
        .last = 7743,
    },
    struct_interval{
        .first = 7745,
        .last = 7745,
    },
    struct_interval{
        .first = 7747,
        .last = 7747,
    },
    struct_interval{
        .first = 7749,
        .last = 7749,
    },
    struct_interval{
        .first = 7751,
        .last = 7751,
    },
    struct_interval{
        .first = 7753,
        .last = 7753,
    },
    struct_interval{
        .first = 7755,
        .last = 7755,
    },
    struct_interval{
        .first = 7757,
        .last = 7757,
    },
    struct_interval{
        .first = 7759,
        .last = 7759,
    },
    struct_interval{
        .first = 7761,
        .last = 7761,
    },
    struct_interval{
        .first = 7763,
        .last = 7763,
    },
    struct_interval{
        .first = 7765,
        .last = 7765,
    },
    struct_interval{
        .first = 7767,
        .last = 7767,
    },
    struct_interval{
        .first = 7769,
        .last = 7769,
    },
    struct_interval{
        .first = 7771,
        .last = 7771,
    },
    struct_interval{
        .first = 7773,
        .last = 7773,
    },
    struct_interval{
        .first = 7775,
        .last = 7775,
    },
    struct_interval{
        .first = 7777,
        .last = 7777,
    },
    struct_interval{
        .first = 7779,
        .last = 7779,
    },
    struct_interval{
        .first = 7781,
        .last = 7781,
    },
    struct_interval{
        .first = 7783,
        .last = 7783,
    },
    struct_interval{
        .first = 7785,
        .last = 7785,
    },
    struct_interval{
        .first = 7787,
        .last = 7787,
    },
    struct_interval{
        .first = 7789,
        .last = 7789,
    },
    struct_interval{
        .first = 7791,
        .last = 7791,
    },
    struct_interval{
        .first = 7793,
        .last = 7793,
    },
    struct_interval{
        .first = 7795,
        .last = 7795,
    },
    struct_interval{
        .first = 7797,
        .last = 7797,
    },
    struct_interval{
        .first = 7799,
        .last = 7799,
    },
    struct_interval{
        .first = 7801,
        .last = 7801,
    },
    struct_interval{
        .first = 7803,
        .last = 7803,
    },
    struct_interval{
        .first = 7805,
        .last = 7805,
    },
    struct_interval{
        .first = 7807,
        .last = 7807,
    },
    struct_interval{
        .first = 7809,
        .last = 7809,
    },
    struct_interval{
        .first = 7811,
        .last = 7811,
    },
    struct_interval{
        .first = 7813,
        .last = 7813,
    },
    struct_interval{
        .first = 7815,
        .last = 7815,
    },
    struct_interval{
        .first = 7817,
        .last = 7817,
    },
    struct_interval{
        .first = 7819,
        .last = 7819,
    },
    struct_interval{
        .first = 7821,
        .last = 7821,
    },
    struct_interval{
        .first = 7823,
        .last = 7823,
    },
    struct_interval{
        .first = 7825,
        .last = 7825,
    },
    struct_interval{
        .first = 7827,
        .last = 7827,
    },
    struct_interval{
        .first = 7829,
        .last = 7837,
    },
    struct_interval{
        .first = 7839,
        .last = 7839,
    },
    struct_interval{
        .first = 7841,
        .last = 7841,
    },
    struct_interval{
        .first = 7843,
        .last = 7843,
    },
    struct_interval{
        .first = 7845,
        .last = 7845,
    },
    struct_interval{
        .first = 7847,
        .last = 7847,
    },
    struct_interval{
        .first = 7849,
        .last = 7849,
    },
    struct_interval{
        .first = 7851,
        .last = 7851,
    },
    struct_interval{
        .first = 7853,
        .last = 7853,
    },
    struct_interval{
        .first = 7855,
        .last = 7855,
    },
    struct_interval{
        .first = 7857,
        .last = 7857,
    },
    struct_interval{
        .first = 7859,
        .last = 7859,
    },
    struct_interval{
        .first = 7861,
        .last = 7861,
    },
    struct_interval{
        .first = 7863,
        .last = 7863,
    },
    struct_interval{
        .first = 7865,
        .last = 7865,
    },
    struct_interval{
        .first = 7867,
        .last = 7867,
    },
    struct_interval{
        .first = 7869,
        .last = 7869,
    },
    struct_interval{
        .first = 7871,
        .last = 7871,
    },
    struct_interval{
        .first = 7873,
        .last = 7873,
    },
    struct_interval{
        .first = 7875,
        .last = 7875,
    },
    struct_interval{
        .first = 7877,
        .last = 7877,
    },
    struct_interval{
        .first = 7879,
        .last = 7879,
    },
    struct_interval{
        .first = 7881,
        .last = 7881,
    },
    struct_interval{
        .first = 7883,
        .last = 7883,
    },
    struct_interval{
        .first = 7885,
        .last = 7885,
    },
    struct_interval{
        .first = 7887,
        .last = 7887,
    },
    struct_interval{
        .first = 7889,
        .last = 7889,
    },
    struct_interval{
        .first = 7891,
        .last = 7891,
    },
    struct_interval{
        .first = 7893,
        .last = 7893,
    },
    struct_interval{
        .first = 7895,
        .last = 7895,
    },
    struct_interval{
        .first = 7897,
        .last = 7897,
    },
    struct_interval{
        .first = 7899,
        .last = 7899,
    },
    struct_interval{
        .first = 7901,
        .last = 7901,
    },
    struct_interval{
        .first = 7903,
        .last = 7903,
    },
    struct_interval{
        .first = 7905,
        .last = 7905,
    },
    struct_interval{
        .first = 7907,
        .last = 7907,
    },
    struct_interval{
        .first = 7909,
        .last = 7909,
    },
    struct_interval{
        .first = 7911,
        .last = 7911,
    },
    struct_interval{
        .first = 7913,
        .last = 7913,
    },
    struct_interval{
        .first = 7915,
        .last = 7915,
    },
    struct_interval{
        .first = 7917,
        .last = 7917,
    },
    struct_interval{
        .first = 7919,
        .last = 7919,
    },
    struct_interval{
        .first = 7921,
        .last = 7921,
    },
    struct_interval{
        .first = 7923,
        .last = 7923,
    },
    struct_interval{
        .first = 7925,
        .last = 7925,
    },
    struct_interval{
        .first = 7927,
        .last = 7927,
    },
    struct_interval{
        .first = 7929,
        .last = 7929,
    },
    struct_interval{
        .first = 7931,
        .last = 7931,
    },
    struct_interval{
        .first = 7933,
        .last = 7933,
    },
    struct_interval{
        .first = 7935,
        .last = 7943,
    },
    struct_interval{
        .first = 7952,
        .last = 7957,
    },
    struct_interval{
        .first = 7968,
        .last = 7975,
    },
    struct_interval{
        .first = 7984,
        .last = 7991,
    },
    struct_interval{
        .first = 8000,
        .last = 8005,
    },
    struct_interval{
        .first = 8016,
        .last = 8023,
    },
    struct_interval{
        .first = 8032,
        .last = 8039,
    },
    struct_interval{
        .first = 8048,
        .last = 8061,
    },
    struct_interval{
        .first = 8064,
        .last = 8071,
    },
    struct_interval{
        .first = 8080,
        .last = 8087,
    },
    struct_interval{
        .first = 8096,
        .last = 8103,
    },
    struct_interval{
        .first = 8112,
        .last = 8116,
    },
    struct_interval{
        .first = 8118,
        .last = 8119,
    },
    struct_interval{
        .first = 8126,
        .last = 8126,
    },
    struct_interval{
        .first = 8130,
        .last = 8132,
    },
    struct_interval{
        .first = 8134,
        .last = 8135,
    },
    struct_interval{
        .first = 8144,
        .last = 8147,
    },
    struct_interval{
        .first = 8150,
        .last = 8151,
    },
    struct_interval{
        .first = 8160,
        .last = 8167,
    },
    struct_interval{
        .first = 8178,
        .last = 8180,
    },
    struct_interval{
        .first = 8182,
        .last = 8183,
    },
    struct_interval{
        .first = 8458,
        .last = 8458,
    },
    struct_interval{
        .first = 8462,
        .last = 8463,
    },
    struct_interval{
        .first = 8467,
        .last = 8467,
    },
    struct_interval{
        .first = 8495,
        .last = 8495,
    },
    struct_interval{
        .first = 8500,
        .last = 8500,
    },
    struct_interval{
        .first = 8505,
        .last = 8505,
    },
    struct_interval{
        .first = 8508,
        .last = 8509,
    },
    struct_interval{
        .first = 8518,
        .last = 8521,
    },
    struct_interval{
        .first = 8526,
        .last = 8526,
    },
    struct_interval{
        .first = 8580,
        .last = 8580,
    },
    struct_interval{
        .first = 11312,
        .last = 11359,
    },
    struct_interval{
        .first = 11361,
        .last = 11361,
    },
    struct_interval{
        .first = 11365,
        .last = 11366,
    },
    struct_interval{
        .first = 11368,
        .last = 11368,
    },
    struct_interval{
        .first = 11370,
        .last = 11370,
    },
    struct_interval{
        .first = 11372,
        .last = 11372,
    },
    struct_interval{
        .first = 11377,
        .last = 11377,
    },
    struct_interval{
        .first = 11379,
        .last = 11380,
    },
    struct_interval{
        .first = 11382,
        .last = 11387,
    },
    struct_interval{
        .first = 11393,
        .last = 11393,
    },
    struct_interval{
        .first = 11395,
        .last = 11395,
    },
    struct_interval{
        .first = 11397,
        .last = 11397,
    },
    struct_interval{
        .first = 11399,
        .last = 11399,
    },
    struct_interval{
        .first = 11401,
        .last = 11401,
    },
    struct_interval{
        .first = 11403,
        .last = 11403,
    },
    struct_interval{
        .first = 11405,
        .last = 11405,
    },
    struct_interval{
        .first = 11407,
        .last = 11407,
    },
    struct_interval{
        .first = 11409,
        .last = 11409,
    },
    struct_interval{
        .first = 11411,
        .last = 11411,
    },
    struct_interval{
        .first = 11413,
        .last = 11413,
    },
    struct_interval{
        .first = 11415,
        .last = 11415,
    },
    struct_interval{
        .first = 11417,
        .last = 11417,
    },
    struct_interval{
        .first = 11419,
        .last = 11419,
    },
    struct_interval{
        .first = 11421,
        .last = 11421,
    },
    struct_interval{
        .first = 11423,
        .last = 11423,
    },
    struct_interval{
        .first = 11425,
        .last = 11425,
    },
    struct_interval{
        .first = 11427,
        .last = 11427,
    },
    struct_interval{
        .first = 11429,
        .last = 11429,
    },
    struct_interval{
        .first = 11431,
        .last = 11431,
    },
    struct_interval{
        .first = 11433,
        .last = 11433,
    },
    struct_interval{
        .first = 11435,
        .last = 11435,
    },
    struct_interval{
        .first = 11437,
        .last = 11437,
    },
    struct_interval{
        .first = 11439,
        .last = 11439,
    },
    struct_interval{
        .first = 11441,
        .last = 11441,
    },
    struct_interval{
        .first = 11443,
        .last = 11443,
    },
    struct_interval{
        .first = 11445,
        .last = 11445,
    },
    struct_interval{
        .first = 11447,
        .last = 11447,
    },
    struct_interval{
        .first = 11449,
        .last = 11449,
    },
    struct_interval{
        .first = 11451,
        .last = 11451,
    },
    struct_interval{
        .first = 11453,
        .last = 11453,
    },
    struct_interval{
        .first = 11455,
        .last = 11455,
    },
    struct_interval{
        .first = 11457,
        .last = 11457,
    },
    struct_interval{
        .first = 11459,
        .last = 11459,
    },
    struct_interval{
        .first = 11461,
        .last = 11461,
    },
    struct_interval{
        .first = 11463,
        .last = 11463,
    },
    struct_interval{
        .first = 11465,
        .last = 11465,
    },
    struct_interval{
        .first = 11467,
        .last = 11467,
    },
    struct_interval{
        .first = 11469,
        .last = 11469,
    },
    struct_interval{
        .first = 11471,
        .last = 11471,
    },
    struct_interval{
        .first = 11473,
        .last = 11473,
    },
    struct_interval{
        .first = 11475,
        .last = 11475,
    },
    struct_interval{
        .first = 11477,
        .last = 11477,
    },
    struct_interval{
        .first = 11479,
        .last = 11479,
    },
    struct_interval{
        .first = 11481,
        .last = 11481,
    },
    struct_interval{
        .first = 11483,
        .last = 11483,
    },
    struct_interval{
        .first = 11485,
        .last = 11485,
    },
    struct_interval{
        .first = 11487,
        .last = 11487,
    },
    struct_interval{
        .first = 11489,
        .last = 11489,
    },
    struct_interval{
        .first = 11491,
        .last = 11492,
    },
    struct_interval{
        .first = 11500,
        .last = 11500,
    },
    struct_interval{
        .first = 11502,
        .last = 11502,
    },
    struct_interval{
        .first = 11507,
        .last = 11507,
    },
    struct_interval{
        .first = 11520,
        .last = 11557,
    },
    struct_interval{
        .first = 11559,
        .last = 11559,
    },
    struct_interval{
        .first = 11565,
        .last = 11565,
    },
    struct_interval{
        .first = 42561,
        .last = 42561,
    },
    struct_interval{
        .first = 42563,
        .last = 42563,
    },
    struct_interval{
        .first = 42565,
        .last = 42565,
    },
    struct_interval{
        .first = 42567,
        .last = 42567,
    },
    struct_interval{
        .first = 42569,
        .last = 42569,
    },
    struct_interval{
        .first = 42571,
        .last = 42571,
    },
    struct_interval{
        .first = 42573,
        .last = 42573,
    },
    struct_interval{
        .first = 42575,
        .last = 42575,
    },
    struct_interval{
        .first = 42577,
        .last = 42577,
    },
    struct_interval{
        .first = 42579,
        .last = 42579,
    },
    struct_interval{
        .first = 42581,
        .last = 42581,
    },
    struct_interval{
        .first = 42583,
        .last = 42583,
    },
    struct_interval{
        .first = 42585,
        .last = 42585,
    },
    struct_interval{
        .first = 42587,
        .last = 42587,
    },
    struct_interval{
        .first = 42589,
        .last = 42589,
    },
    struct_interval{
        .first = 42591,
        .last = 42591,
    },
    struct_interval{
        .first = 42593,
        .last = 42593,
    },
    struct_interval{
        .first = 42595,
        .last = 42595,
    },
    struct_interval{
        .first = 42597,
        .last = 42597,
    },
    struct_interval{
        .first = 42599,
        .last = 42599,
    },
    struct_interval{
        .first = 42601,
        .last = 42601,
    },
    struct_interval{
        .first = 42603,
        .last = 42603,
    },
    struct_interval{
        .first = 42605,
        .last = 42605,
    },
    struct_interval{
        .first = 42625,
        .last = 42625,
    },
    struct_interval{
        .first = 42627,
        .last = 42627,
    },
    struct_interval{
        .first = 42629,
        .last = 42629,
    },
    struct_interval{
        .first = 42631,
        .last = 42631,
    },
    struct_interval{
        .first = 42633,
        .last = 42633,
    },
    struct_interval{
        .first = 42635,
        .last = 42635,
    },
    struct_interval{
        .first = 42637,
        .last = 42637,
    },
    struct_interval{
        .first = 42639,
        .last = 42639,
    },
    struct_interval{
        .first = 42641,
        .last = 42641,
    },
    struct_interval{
        .first = 42643,
        .last = 42643,
    },
    struct_interval{
        .first = 42645,
        .last = 42645,
    },
    struct_interval{
        .first = 42647,
        .last = 42647,
    },
    struct_interval{
        .first = 42649,
        .last = 42649,
    },
    struct_interval{
        .first = 42651,
        .last = 42651,
    },
    struct_interval{
        .first = 42787,
        .last = 42787,
    },
    struct_interval{
        .first = 42789,
        .last = 42789,
    },
    struct_interval{
        .first = 42791,
        .last = 42791,
    },
    struct_interval{
        .first = 42793,
        .last = 42793,
    },
    struct_interval{
        .first = 42795,
        .last = 42795,
    },
    struct_interval{
        .first = 42797,
        .last = 42797,
    },
    struct_interval{
        .first = 42799,
        .last = 42801,
    },
    struct_interval{
        .first = 42803,
        .last = 42803,
    },
    struct_interval{
        .first = 42805,
        .last = 42805,
    },
    struct_interval{
        .first = 42807,
        .last = 42807,
    },
    struct_interval{
        .first = 42809,
        .last = 42809,
    },
    struct_interval{
        .first = 42811,
        .last = 42811,
    },
    struct_interval{
        .first = 42813,
        .last = 42813,
    },
    struct_interval{
        .first = 42815,
        .last = 42815,
    },
    struct_interval{
        .first = 42817,
        .last = 42817,
    },
    struct_interval{
        .first = 42819,
        .last = 42819,
    },
    struct_interval{
        .first = 42821,
        .last = 42821,
    },
    struct_interval{
        .first = 42823,
        .last = 42823,
    },
    struct_interval{
        .first = 42825,
        .last = 42825,
    },
    struct_interval{
        .first = 42827,
        .last = 42827,
    },
    struct_interval{
        .first = 42829,
        .last = 42829,
    },
    struct_interval{
        .first = 42831,
        .last = 42831,
    },
    struct_interval{
        .first = 42833,
        .last = 42833,
    },
    struct_interval{
        .first = 42835,
        .last = 42835,
    },
    struct_interval{
        .first = 42837,
        .last = 42837,
    },
    struct_interval{
        .first = 42839,
        .last = 42839,
    },
    struct_interval{
        .first = 42841,
        .last = 42841,
    },
    struct_interval{
        .first = 42843,
        .last = 42843,
    },
    struct_interval{
        .first = 42845,
        .last = 42845,
    },
    struct_interval{
        .first = 42847,
        .last = 42847,
    },
    struct_interval{
        .first = 42849,
        .last = 42849,
    },
    struct_interval{
        .first = 42851,
        .last = 42851,
    },
    struct_interval{
        .first = 42853,
        .last = 42853,
    },
    struct_interval{
        .first = 42855,
        .last = 42855,
    },
    struct_interval{
        .first = 42857,
        .last = 42857,
    },
    struct_interval{
        .first = 42859,
        .last = 42859,
    },
    struct_interval{
        .first = 42861,
        .last = 42861,
    },
    struct_interval{
        .first = 42863,
        .last = 42863,
    },
    struct_interval{
        .first = 42865,
        .last = 42872,
    },
    struct_interval{
        .first = 42874,
        .last = 42874,
    },
    struct_interval{
        .first = 42876,
        .last = 42876,
    },
    struct_interval{
        .first = 42879,
        .last = 42879,
    },
    struct_interval{
        .first = 42881,
        .last = 42881,
    },
    struct_interval{
        .first = 42883,
        .last = 42883,
    },
    struct_interval{
        .first = 42885,
        .last = 42885,
    },
    struct_interval{
        .first = 42887,
        .last = 42887,
    },
    struct_interval{
        .first = 42892,
        .last = 42892,
    },
    struct_interval{
        .first = 42894,
        .last = 42894,
    },
    struct_interval{
        .first = 42897,
        .last = 42897,
    },
    struct_interval{
        .first = 42899,
        .last = 42901,
    },
    struct_interval{
        .first = 42903,
        .last = 42903,
    },
    struct_interval{
        .first = 42905,
        .last = 42905,
    },
    struct_interval{
        .first = 42907,
        .last = 42907,
    },
    struct_interval{
        .first = 42909,
        .last = 42909,
    },
    struct_interval{
        .first = 42911,
        .last = 42911,
    },
    struct_interval{
        .first = 42913,
        .last = 42913,
    },
    struct_interval{
        .first = 42915,
        .last = 42915,
    },
    struct_interval{
        .first = 42917,
        .last = 42917,
    },
    struct_interval{
        .first = 42919,
        .last = 42919,
    },
    struct_interval{
        .first = 42921,
        .last = 42921,
    },
    struct_interval{
        .first = 42927,
        .last = 42927,
    },
    struct_interval{
        .first = 42933,
        .last = 42933,
    },
    struct_interval{
        .first = 42935,
        .last = 42935,
    },
    struct_interval{
        .first = 42937,
        .last = 42937,
    },
    struct_interval{
        .first = 42939,
        .last = 42939,
    },
    struct_interval{
        .first = 42941,
        .last = 42941,
    },
    struct_interval{
        .first = 42943,
        .last = 42943,
    },
    struct_interval{
        .first = 42945,
        .last = 42945,
    },
    struct_interval{
        .first = 42947,
        .last = 42947,
    },
    struct_interval{
        .first = 42952,
        .last = 42952,
    },
    struct_interval{
        .first = 42954,
        .last = 42954,
    },
    struct_interval{
        .first = 42957,
        .last = 42957,
    },
    struct_interval{
        .first = 42959,
        .last = 42959,
    },
    struct_interval{
        .first = 42961,
        .last = 42961,
    },
    struct_interval{
        .first = 42963,
        .last = 42963,
    },
    struct_interval{
        .first = 42965,
        .last = 42965,
    },
    struct_interval{
        .first = 42967,
        .last = 42967,
    },
    struct_interval{
        .first = 42969,
        .last = 42969,
    },
    struct_interval{
        .first = 42971,
        .last = 42971,
    },
    struct_interval{
        .first = 42998,
        .last = 42998,
    },
    struct_interval{
        .first = 43002,
        .last = 43002,
    },
    struct_interval{
        .first = 43824,
        .last = 43866,
    },
    struct_interval{
        .first = 43872,
        .last = 43880,
    },
    struct_interval{
        .first = 43888,
        .last = 43967,
    },
    struct_interval{
        .first = 64256,
        .last = 64262,
    },
    struct_interval{
        .first = 64275,
        .last = 64279,
    },
    struct_interval{
        .first = 65345,
        .last = 65370,
    },
    struct_interval{
        .first = 66600,
        .last = 66639,
    },
    struct_interval{
        .first = 66776,
        .last = 66811,
    },
    struct_interval{
        .first = 66967,
        .last = 66977,
    },
    struct_interval{
        .first = 66979,
        .last = 66993,
    },
    struct_interval{
        .first = 66995,
        .last = 67001,
    },
    struct_interval{
        .first = 67003,
        .last = 67004,
    },
    struct_interval{
        .first = 68800,
        .last = 68850,
    },
    struct_interval{
        .first = 68976,
        .last = 68997,
    },
    struct_interval{
        .first = 71872,
        .last = 71903,
    },
    struct_interval{
        .first = 93792,
        .last = 93823,
    },
    struct_interval{
        .first = 93883,
        .last = 93907,
    },
    struct_interval{
        .first = 119834,
        .last = 119859,
    },
    struct_interval{
        .first = 119886,
        .last = 119892,
    },
    struct_interval{
        .first = 119894,
        .last = 119911,
    },
    struct_interval{
        .first = 119938,
        .last = 119963,
    },
    struct_interval{
        .first = 119990,
        .last = 119993,
    },
    struct_interval{
        .first = 119995,
        .last = 119995,
    },
    struct_interval{
        .first = 119997,
        .last = 120003,
    },
    struct_interval{
        .first = 120005,
        .last = 120015,
    },
    struct_interval{
        .first = 120042,
        .last = 120067,
    },
    struct_interval{
        .first = 120094,
        .last = 120119,
    },
    struct_interval{
        .first = 120146,
        .last = 120171,
    },
    struct_interval{
        .first = 120198,
        .last = 120223,
    },
    struct_interval{
        .first = 120250,
        .last = 120275,
    },
    struct_interval{
        .first = 120302,
        .last = 120327,
    },
    struct_interval{
        .first = 120354,
        .last = 120379,
    },
    struct_interval{
        .first = 120406,
        .last = 120431,
    },
    struct_interval{
        .first = 120458,
        .last = 120485,
    },
    struct_interval{
        .first = 120514,
        .last = 120538,
    },
    struct_interval{
        .first = 120540,
        .last = 120545,
    },
    struct_interval{
        .first = 120572,
        .last = 120596,
    },
    struct_interval{
        .first = 120598,
        .last = 120603,
    },
    struct_interval{
        .first = 120630,
        .last = 120654,
    },
    struct_interval{
        .first = 120656,
        .last = 120661,
    },
    struct_interval{
        .first = 120688,
        .last = 120712,
    },
    struct_interval{
        .first = 120714,
        .last = 120719,
    },
    struct_interval{
        .first = 120746,
        .last = 120770,
    },
    struct_interval{
        .first = 120772,
        .last = 120777,
    },
    struct_interval{
        .first = 120779,
        .last = 120779,
    },
    struct_interval{
        .first = 122624,
        .last = 122633,
    },
    struct_interval{
        .first = 122635,
        .last = 122654,
    },
    struct_interval{
        .first = 122661,
        .last = 122666,
    },
    struct_interval{
        .first = 125218,
        .last = 125251,
    },
};
pub export const Pc_table: [6]struct_interval = [6]struct_interval{
    struct_interval{
        .first = 95,
        .last = 95,
    },
    struct_interval{
        .first = 8255,
        .last = 8256,
    },
    struct_interval{
        .first = 8276,
        .last = 8276,
    },
    struct_interval{
        .first = 65075,
        .last = 65076,
    },
    struct_interval{
        .first = 65101,
        .last = 65103,
    },
    struct_interval{
        .first = 65343,
        .last = 65343,
    },
};
pub export const Sk_table: [31]struct_interval = [31]struct_interval{
    struct_interval{
        .first = 94,
        .last = 94,
    },
    struct_interval{
        .first = 96,
        .last = 96,
    },
    struct_interval{
        .first = 168,
        .last = 168,
    },
    struct_interval{
        .first = 175,
        .last = 175,
    },
    struct_interval{
        .first = 180,
        .last = 180,
    },
    struct_interval{
        .first = 184,
        .last = 184,
    },
    struct_interval{
        .first = 706,
        .last = 709,
    },
    struct_interval{
        .first = 722,
        .last = 735,
    },
    struct_interval{
        .first = 741,
        .last = 747,
    },
    struct_interval{
        .first = 749,
        .last = 749,
    },
    struct_interval{
        .first = 751,
        .last = 767,
    },
    struct_interval{
        .first = 885,
        .last = 885,
    },
    struct_interval{
        .first = 900,
        .last = 901,
    },
    struct_interval{
        .first = 2184,
        .last = 2184,
    },
    struct_interval{
        .first = 8125,
        .last = 8125,
    },
    struct_interval{
        .first = 8127,
        .last = 8129,
    },
    struct_interval{
        .first = 8141,
        .last = 8143,
    },
    struct_interval{
        .first = 8157,
        .last = 8159,
    },
    struct_interval{
        .first = 8173,
        .last = 8175,
    },
    struct_interval{
        .first = 8189,
        .last = 8190,
    },
    struct_interval{
        .first = 12443,
        .last = 12444,
    },
    struct_interval{
        .first = 42752,
        .last = 42774,
    },
    struct_interval{
        .first = 42784,
        .last = 42785,
    },
    struct_interval{
        .first = 42889,
        .last = 42890,
    },
    struct_interval{
        .first = 43867,
        .last = 43867,
    },
    struct_interval{
        .first = 43882,
        .last = 43883,
    },
    struct_interval{
        .first = 64434,
        .last = 64450,
    },
    struct_interval{
        .first = 65342,
        .last = 65342,
    },
    struct_interval{
        .first = 65344,
        .last = 65344,
    },
    struct_interval{
        .first = 65507,
        .last = 65507,
    },
    struct_interval{
        .first = 127995,
        .last = 127999,
    },
};
pub export const Lu_table: [655]struct_interval = [655]struct_interval{
    struct_interval{
        .first = 65,
        .last = 90,
    },
    struct_interval{
        .first = 192,
        .last = 214,
    },
    struct_interval{
        .first = 216,
        .last = 222,
    },
    struct_interval{
        .first = 256,
        .last = 256,
    },
    struct_interval{
        .first = 258,
        .last = 258,
    },
    struct_interval{
        .first = 260,
        .last = 260,
    },
    struct_interval{
        .first = 262,
        .last = 262,
    },
    struct_interval{
        .first = 264,
        .last = 264,
    },
    struct_interval{
        .first = 266,
        .last = 266,
    },
    struct_interval{
        .first = 268,
        .last = 268,
    },
    struct_interval{
        .first = 270,
        .last = 270,
    },
    struct_interval{
        .first = 272,
        .last = 272,
    },
    struct_interval{
        .first = 274,
        .last = 274,
    },
    struct_interval{
        .first = 276,
        .last = 276,
    },
    struct_interval{
        .first = 278,
        .last = 278,
    },
    struct_interval{
        .first = 280,
        .last = 280,
    },
    struct_interval{
        .first = 282,
        .last = 282,
    },
    struct_interval{
        .first = 284,
        .last = 284,
    },
    struct_interval{
        .first = 286,
        .last = 286,
    },
    struct_interval{
        .first = 288,
        .last = 288,
    },
    struct_interval{
        .first = 290,
        .last = 290,
    },
    struct_interval{
        .first = 292,
        .last = 292,
    },
    struct_interval{
        .first = 294,
        .last = 294,
    },
    struct_interval{
        .first = 296,
        .last = 296,
    },
    struct_interval{
        .first = 298,
        .last = 298,
    },
    struct_interval{
        .first = 300,
        .last = 300,
    },
    struct_interval{
        .first = 302,
        .last = 302,
    },
    struct_interval{
        .first = 304,
        .last = 304,
    },
    struct_interval{
        .first = 306,
        .last = 306,
    },
    struct_interval{
        .first = 308,
        .last = 308,
    },
    struct_interval{
        .first = 310,
        .last = 310,
    },
    struct_interval{
        .first = 313,
        .last = 313,
    },
    struct_interval{
        .first = 315,
        .last = 315,
    },
    struct_interval{
        .first = 317,
        .last = 317,
    },
    struct_interval{
        .first = 319,
        .last = 319,
    },
    struct_interval{
        .first = 321,
        .last = 321,
    },
    struct_interval{
        .first = 323,
        .last = 323,
    },
    struct_interval{
        .first = 325,
        .last = 325,
    },
    struct_interval{
        .first = 327,
        .last = 327,
    },
    struct_interval{
        .first = 330,
        .last = 330,
    },
    struct_interval{
        .first = 332,
        .last = 332,
    },
    struct_interval{
        .first = 334,
        .last = 334,
    },
    struct_interval{
        .first = 336,
        .last = 336,
    },
    struct_interval{
        .first = 338,
        .last = 338,
    },
    struct_interval{
        .first = 340,
        .last = 340,
    },
    struct_interval{
        .first = 342,
        .last = 342,
    },
    struct_interval{
        .first = 344,
        .last = 344,
    },
    struct_interval{
        .first = 346,
        .last = 346,
    },
    struct_interval{
        .first = 348,
        .last = 348,
    },
    struct_interval{
        .first = 350,
        .last = 350,
    },
    struct_interval{
        .first = 352,
        .last = 352,
    },
    struct_interval{
        .first = 354,
        .last = 354,
    },
    struct_interval{
        .first = 356,
        .last = 356,
    },
    struct_interval{
        .first = 358,
        .last = 358,
    },
    struct_interval{
        .first = 360,
        .last = 360,
    },
    struct_interval{
        .first = 362,
        .last = 362,
    },
    struct_interval{
        .first = 364,
        .last = 364,
    },
    struct_interval{
        .first = 366,
        .last = 366,
    },
    struct_interval{
        .first = 368,
        .last = 368,
    },
    struct_interval{
        .first = 370,
        .last = 370,
    },
    struct_interval{
        .first = 372,
        .last = 372,
    },
    struct_interval{
        .first = 374,
        .last = 374,
    },
    struct_interval{
        .first = 376,
        .last = 377,
    },
    struct_interval{
        .first = 379,
        .last = 379,
    },
    struct_interval{
        .first = 381,
        .last = 381,
    },
    struct_interval{
        .first = 385,
        .last = 386,
    },
    struct_interval{
        .first = 388,
        .last = 388,
    },
    struct_interval{
        .first = 390,
        .last = 391,
    },
    struct_interval{
        .first = 393,
        .last = 395,
    },
    struct_interval{
        .first = 398,
        .last = 401,
    },
    struct_interval{
        .first = 403,
        .last = 404,
    },
    struct_interval{
        .first = 406,
        .last = 408,
    },
    struct_interval{
        .first = 412,
        .last = 413,
    },
    struct_interval{
        .first = 415,
        .last = 416,
    },
    struct_interval{
        .first = 418,
        .last = 418,
    },
    struct_interval{
        .first = 420,
        .last = 420,
    },
    struct_interval{
        .first = 422,
        .last = 423,
    },
    struct_interval{
        .first = 425,
        .last = 425,
    },
    struct_interval{
        .first = 428,
        .last = 428,
    },
    struct_interval{
        .first = 430,
        .last = 431,
    },
    struct_interval{
        .first = 433,
        .last = 435,
    },
    struct_interval{
        .first = 437,
        .last = 437,
    },
    struct_interval{
        .first = 439,
        .last = 440,
    },
    struct_interval{
        .first = 444,
        .last = 444,
    },
    struct_interval{
        .first = 452,
        .last = 452,
    },
    struct_interval{
        .first = 455,
        .last = 455,
    },
    struct_interval{
        .first = 458,
        .last = 458,
    },
    struct_interval{
        .first = 461,
        .last = 461,
    },
    struct_interval{
        .first = 463,
        .last = 463,
    },
    struct_interval{
        .first = 465,
        .last = 465,
    },
    struct_interval{
        .first = 467,
        .last = 467,
    },
    struct_interval{
        .first = 469,
        .last = 469,
    },
    struct_interval{
        .first = 471,
        .last = 471,
    },
    struct_interval{
        .first = 473,
        .last = 473,
    },
    struct_interval{
        .first = 475,
        .last = 475,
    },
    struct_interval{
        .first = 478,
        .last = 478,
    },
    struct_interval{
        .first = 480,
        .last = 480,
    },
    struct_interval{
        .first = 482,
        .last = 482,
    },
    struct_interval{
        .first = 484,
        .last = 484,
    },
    struct_interval{
        .first = 486,
        .last = 486,
    },
    struct_interval{
        .first = 488,
        .last = 488,
    },
    struct_interval{
        .first = 490,
        .last = 490,
    },
    struct_interval{
        .first = 492,
        .last = 492,
    },
    struct_interval{
        .first = 494,
        .last = 494,
    },
    struct_interval{
        .first = 497,
        .last = 497,
    },
    struct_interval{
        .first = 500,
        .last = 500,
    },
    struct_interval{
        .first = 502,
        .last = 504,
    },
    struct_interval{
        .first = 506,
        .last = 506,
    },
    struct_interval{
        .first = 508,
        .last = 508,
    },
    struct_interval{
        .first = 510,
        .last = 510,
    },
    struct_interval{
        .first = 512,
        .last = 512,
    },
    struct_interval{
        .first = 514,
        .last = 514,
    },
    struct_interval{
        .first = 516,
        .last = 516,
    },
    struct_interval{
        .first = 518,
        .last = 518,
    },
    struct_interval{
        .first = 520,
        .last = 520,
    },
    struct_interval{
        .first = 522,
        .last = 522,
    },
    struct_interval{
        .first = 524,
        .last = 524,
    },
    struct_interval{
        .first = 526,
        .last = 526,
    },
    struct_interval{
        .first = 528,
        .last = 528,
    },
    struct_interval{
        .first = 530,
        .last = 530,
    },
    struct_interval{
        .first = 532,
        .last = 532,
    },
    struct_interval{
        .first = 534,
        .last = 534,
    },
    struct_interval{
        .first = 536,
        .last = 536,
    },
    struct_interval{
        .first = 538,
        .last = 538,
    },
    struct_interval{
        .first = 540,
        .last = 540,
    },
    struct_interval{
        .first = 542,
        .last = 542,
    },
    struct_interval{
        .first = 544,
        .last = 544,
    },
    struct_interval{
        .first = 546,
        .last = 546,
    },
    struct_interval{
        .first = 548,
        .last = 548,
    },
    struct_interval{
        .first = 550,
        .last = 550,
    },
    struct_interval{
        .first = 552,
        .last = 552,
    },
    struct_interval{
        .first = 554,
        .last = 554,
    },
    struct_interval{
        .first = 556,
        .last = 556,
    },
    struct_interval{
        .first = 558,
        .last = 558,
    },
    struct_interval{
        .first = 560,
        .last = 560,
    },
    struct_interval{
        .first = 562,
        .last = 562,
    },
    struct_interval{
        .first = 570,
        .last = 571,
    },
    struct_interval{
        .first = 573,
        .last = 574,
    },
    struct_interval{
        .first = 577,
        .last = 577,
    },
    struct_interval{
        .first = 579,
        .last = 582,
    },
    struct_interval{
        .first = 584,
        .last = 584,
    },
    struct_interval{
        .first = 586,
        .last = 586,
    },
    struct_interval{
        .first = 588,
        .last = 588,
    },
    struct_interval{
        .first = 590,
        .last = 590,
    },
    struct_interval{
        .first = 880,
        .last = 880,
    },
    struct_interval{
        .first = 882,
        .last = 882,
    },
    struct_interval{
        .first = 886,
        .last = 886,
    },
    struct_interval{
        .first = 895,
        .last = 895,
    },
    struct_interval{
        .first = 902,
        .last = 902,
    },
    struct_interval{
        .first = 904,
        .last = 906,
    },
    struct_interval{
        .first = 908,
        .last = 908,
    },
    struct_interval{
        .first = 910,
        .last = 911,
    },
    struct_interval{
        .first = 913,
        .last = 929,
    },
    struct_interval{
        .first = 931,
        .last = 939,
    },
    struct_interval{
        .first = 975,
        .last = 975,
    },
    struct_interval{
        .first = 978,
        .last = 980,
    },
    struct_interval{
        .first = 984,
        .last = 984,
    },
    struct_interval{
        .first = 986,
        .last = 986,
    },
    struct_interval{
        .first = 988,
        .last = 988,
    },
    struct_interval{
        .first = 990,
        .last = 990,
    },
    struct_interval{
        .first = 992,
        .last = 992,
    },
    struct_interval{
        .first = 994,
        .last = 994,
    },
    struct_interval{
        .first = 996,
        .last = 996,
    },
    struct_interval{
        .first = 998,
        .last = 998,
    },
    struct_interval{
        .first = 1000,
        .last = 1000,
    },
    struct_interval{
        .first = 1002,
        .last = 1002,
    },
    struct_interval{
        .first = 1004,
        .last = 1004,
    },
    struct_interval{
        .first = 1006,
        .last = 1006,
    },
    struct_interval{
        .first = 1012,
        .last = 1012,
    },
    struct_interval{
        .first = 1015,
        .last = 1015,
    },
    struct_interval{
        .first = 1017,
        .last = 1018,
    },
    struct_interval{
        .first = 1021,
        .last = 1071,
    },
    struct_interval{
        .first = 1120,
        .last = 1120,
    },
    struct_interval{
        .first = 1122,
        .last = 1122,
    },
    struct_interval{
        .first = 1124,
        .last = 1124,
    },
    struct_interval{
        .first = 1126,
        .last = 1126,
    },
    struct_interval{
        .first = 1128,
        .last = 1128,
    },
    struct_interval{
        .first = 1130,
        .last = 1130,
    },
    struct_interval{
        .first = 1132,
        .last = 1132,
    },
    struct_interval{
        .first = 1134,
        .last = 1134,
    },
    struct_interval{
        .first = 1136,
        .last = 1136,
    },
    struct_interval{
        .first = 1138,
        .last = 1138,
    },
    struct_interval{
        .first = 1140,
        .last = 1140,
    },
    struct_interval{
        .first = 1142,
        .last = 1142,
    },
    struct_interval{
        .first = 1144,
        .last = 1144,
    },
    struct_interval{
        .first = 1146,
        .last = 1146,
    },
    struct_interval{
        .first = 1148,
        .last = 1148,
    },
    struct_interval{
        .first = 1150,
        .last = 1150,
    },
    struct_interval{
        .first = 1152,
        .last = 1152,
    },
    struct_interval{
        .first = 1162,
        .last = 1162,
    },
    struct_interval{
        .first = 1164,
        .last = 1164,
    },
    struct_interval{
        .first = 1166,
        .last = 1166,
    },
    struct_interval{
        .first = 1168,
        .last = 1168,
    },
    struct_interval{
        .first = 1170,
        .last = 1170,
    },
    struct_interval{
        .first = 1172,
        .last = 1172,
    },
    struct_interval{
        .first = 1174,
        .last = 1174,
    },
    struct_interval{
        .first = 1176,
        .last = 1176,
    },
    struct_interval{
        .first = 1178,
        .last = 1178,
    },
    struct_interval{
        .first = 1180,
        .last = 1180,
    },
    struct_interval{
        .first = 1182,
        .last = 1182,
    },
    struct_interval{
        .first = 1184,
        .last = 1184,
    },
    struct_interval{
        .first = 1186,
        .last = 1186,
    },
    struct_interval{
        .first = 1188,
        .last = 1188,
    },
    struct_interval{
        .first = 1190,
        .last = 1190,
    },
    struct_interval{
        .first = 1192,
        .last = 1192,
    },
    struct_interval{
        .first = 1194,
        .last = 1194,
    },
    struct_interval{
        .first = 1196,
        .last = 1196,
    },
    struct_interval{
        .first = 1198,
        .last = 1198,
    },
    struct_interval{
        .first = 1200,
        .last = 1200,
    },
    struct_interval{
        .first = 1202,
        .last = 1202,
    },
    struct_interval{
        .first = 1204,
        .last = 1204,
    },
    struct_interval{
        .first = 1206,
        .last = 1206,
    },
    struct_interval{
        .first = 1208,
        .last = 1208,
    },
    struct_interval{
        .first = 1210,
        .last = 1210,
    },
    struct_interval{
        .first = 1212,
        .last = 1212,
    },
    struct_interval{
        .first = 1214,
        .last = 1214,
    },
    struct_interval{
        .first = 1216,
        .last = 1217,
    },
    struct_interval{
        .first = 1219,
        .last = 1219,
    },
    struct_interval{
        .first = 1221,
        .last = 1221,
    },
    struct_interval{
        .first = 1223,
        .last = 1223,
    },
    struct_interval{
        .first = 1225,
        .last = 1225,
    },
    struct_interval{
        .first = 1227,
        .last = 1227,
    },
    struct_interval{
        .first = 1229,
        .last = 1229,
    },
    struct_interval{
        .first = 1232,
        .last = 1232,
    },
    struct_interval{
        .first = 1234,
        .last = 1234,
    },
    struct_interval{
        .first = 1236,
        .last = 1236,
    },
    struct_interval{
        .first = 1238,
        .last = 1238,
    },
    struct_interval{
        .first = 1240,
        .last = 1240,
    },
    struct_interval{
        .first = 1242,
        .last = 1242,
    },
    struct_interval{
        .first = 1244,
        .last = 1244,
    },
    struct_interval{
        .first = 1246,
        .last = 1246,
    },
    struct_interval{
        .first = 1248,
        .last = 1248,
    },
    struct_interval{
        .first = 1250,
        .last = 1250,
    },
    struct_interval{
        .first = 1252,
        .last = 1252,
    },
    struct_interval{
        .first = 1254,
        .last = 1254,
    },
    struct_interval{
        .first = 1256,
        .last = 1256,
    },
    struct_interval{
        .first = 1258,
        .last = 1258,
    },
    struct_interval{
        .first = 1260,
        .last = 1260,
    },
    struct_interval{
        .first = 1262,
        .last = 1262,
    },
    struct_interval{
        .first = 1264,
        .last = 1264,
    },
    struct_interval{
        .first = 1266,
        .last = 1266,
    },
    struct_interval{
        .first = 1268,
        .last = 1268,
    },
    struct_interval{
        .first = 1270,
        .last = 1270,
    },
    struct_interval{
        .first = 1272,
        .last = 1272,
    },
    struct_interval{
        .first = 1274,
        .last = 1274,
    },
    struct_interval{
        .first = 1276,
        .last = 1276,
    },
    struct_interval{
        .first = 1278,
        .last = 1278,
    },
    struct_interval{
        .first = 1280,
        .last = 1280,
    },
    struct_interval{
        .first = 1282,
        .last = 1282,
    },
    struct_interval{
        .first = 1284,
        .last = 1284,
    },
    struct_interval{
        .first = 1286,
        .last = 1286,
    },
    struct_interval{
        .first = 1288,
        .last = 1288,
    },
    struct_interval{
        .first = 1290,
        .last = 1290,
    },
    struct_interval{
        .first = 1292,
        .last = 1292,
    },
    struct_interval{
        .first = 1294,
        .last = 1294,
    },
    struct_interval{
        .first = 1296,
        .last = 1296,
    },
    struct_interval{
        .first = 1298,
        .last = 1298,
    },
    struct_interval{
        .first = 1300,
        .last = 1300,
    },
    struct_interval{
        .first = 1302,
        .last = 1302,
    },
    struct_interval{
        .first = 1304,
        .last = 1304,
    },
    struct_interval{
        .first = 1306,
        .last = 1306,
    },
    struct_interval{
        .first = 1308,
        .last = 1308,
    },
    struct_interval{
        .first = 1310,
        .last = 1310,
    },
    struct_interval{
        .first = 1312,
        .last = 1312,
    },
    struct_interval{
        .first = 1314,
        .last = 1314,
    },
    struct_interval{
        .first = 1316,
        .last = 1316,
    },
    struct_interval{
        .first = 1318,
        .last = 1318,
    },
    struct_interval{
        .first = 1320,
        .last = 1320,
    },
    struct_interval{
        .first = 1322,
        .last = 1322,
    },
    struct_interval{
        .first = 1324,
        .last = 1324,
    },
    struct_interval{
        .first = 1326,
        .last = 1326,
    },
    struct_interval{
        .first = 1329,
        .last = 1366,
    },
    struct_interval{
        .first = 4256,
        .last = 4293,
    },
    struct_interval{
        .first = 4295,
        .last = 4295,
    },
    struct_interval{
        .first = 4301,
        .last = 4301,
    },
    struct_interval{
        .first = 5024,
        .last = 5109,
    },
    struct_interval{
        .first = 7305,
        .last = 7305,
    },
    struct_interval{
        .first = 7312,
        .last = 7354,
    },
    struct_interval{
        .first = 7357,
        .last = 7359,
    },
    struct_interval{
        .first = 7680,
        .last = 7680,
    },
    struct_interval{
        .first = 7682,
        .last = 7682,
    },
    struct_interval{
        .first = 7684,
        .last = 7684,
    },
    struct_interval{
        .first = 7686,
        .last = 7686,
    },
    struct_interval{
        .first = 7688,
        .last = 7688,
    },
    struct_interval{
        .first = 7690,
        .last = 7690,
    },
    struct_interval{
        .first = 7692,
        .last = 7692,
    },
    struct_interval{
        .first = 7694,
        .last = 7694,
    },
    struct_interval{
        .first = 7696,
        .last = 7696,
    },
    struct_interval{
        .first = 7698,
        .last = 7698,
    },
    struct_interval{
        .first = 7700,
        .last = 7700,
    },
    struct_interval{
        .first = 7702,
        .last = 7702,
    },
    struct_interval{
        .first = 7704,
        .last = 7704,
    },
    struct_interval{
        .first = 7706,
        .last = 7706,
    },
    struct_interval{
        .first = 7708,
        .last = 7708,
    },
    struct_interval{
        .first = 7710,
        .last = 7710,
    },
    struct_interval{
        .first = 7712,
        .last = 7712,
    },
    struct_interval{
        .first = 7714,
        .last = 7714,
    },
    struct_interval{
        .first = 7716,
        .last = 7716,
    },
    struct_interval{
        .first = 7718,
        .last = 7718,
    },
    struct_interval{
        .first = 7720,
        .last = 7720,
    },
    struct_interval{
        .first = 7722,
        .last = 7722,
    },
    struct_interval{
        .first = 7724,
        .last = 7724,
    },
    struct_interval{
        .first = 7726,
        .last = 7726,
    },
    struct_interval{
        .first = 7728,
        .last = 7728,
    },
    struct_interval{
        .first = 7730,
        .last = 7730,
    },
    struct_interval{
        .first = 7732,
        .last = 7732,
    },
    struct_interval{
        .first = 7734,
        .last = 7734,
    },
    struct_interval{
        .first = 7736,
        .last = 7736,
    },
    struct_interval{
        .first = 7738,
        .last = 7738,
    },
    struct_interval{
        .first = 7740,
        .last = 7740,
    },
    struct_interval{
        .first = 7742,
        .last = 7742,
    },
    struct_interval{
        .first = 7744,
        .last = 7744,
    },
    struct_interval{
        .first = 7746,
        .last = 7746,
    },
    struct_interval{
        .first = 7748,
        .last = 7748,
    },
    struct_interval{
        .first = 7750,
        .last = 7750,
    },
    struct_interval{
        .first = 7752,
        .last = 7752,
    },
    struct_interval{
        .first = 7754,
        .last = 7754,
    },
    struct_interval{
        .first = 7756,
        .last = 7756,
    },
    struct_interval{
        .first = 7758,
        .last = 7758,
    },
    struct_interval{
        .first = 7760,
        .last = 7760,
    },
    struct_interval{
        .first = 7762,
        .last = 7762,
    },
    struct_interval{
        .first = 7764,
        .last = 7764,
    },
    struct_interval{
        .first = 7766,
        .last = 7766,
    },
    struct_interval{
        .first = 7768,
        .last = 7768,
    },
    struct_interval{
        .first = 7770,
        .last = 7770,
    },
    struct_interval{
        .first = 7772,
        .last = 7772,
    },
    struct_interval{
        .first = 7774,
        .last = 7774,
    },
    struct_interval{
        .first = 7776,
        .last = 7776,
    },
    struct_interval{
        .first = 7778,
        .last = 7778,
    },
    struct_interval{
        .first = 7780,
        .last = 7780,
    },
    struct_interval{
        .first = 7782,
        .last = 7782,
    },
    struct_interval{
        .first = 7784,
        .last = 7784,
    },
    struct_interval{
        .first = 7786,
        .last = 7786,
    },
    struct_interval{
        .first = 7788,
        .last = 7788,
    },
    struct_interval{
        .first = 7790,
        .last = 7790,
    },
    struct_interval{
        .first = 7792,
        .last = 7792,
    },
    struct_interval{
        .first = 7794,
        .last = 7794,
    },
    struct_interval{
        .first = 7796,
        .last = 7796,
    },
    struct_interval{
        .first = 7798,
        .last = 7798,
    },
    struct_interval{
        .first = 7800,
        .last = 7800,
    },
    struct_interval{
        .first = 7802,
        .last = 7802,
    },
    struct_interval{
        .first = 7804,
        .last = 7804,
    },
    struct_interval{
        .first = 7806,
        .last = 7806,
    },
    struct_interval{
        .first = 7808,
        .last = 7808,
    },
    struct_interval{
        .first = 7810,
        .last = 7810,
    },
    struct_interval{
        .first = 7812,
        .last = 7812,
    },
    struct_interval{
        .first = 7814,
        .last = 7814,
    },
    struct_interval{
        .first = 7816,
        .last = 7816,
    },
    struct_interval{
        .first = 7818,
        .last = 7818,
    },
    struct_interval{
        .first = 7820,
        .last = 7820,
    },
    struct_interval{
        .first = 7822,
        .last = 7822,
    },
    struct_interval{
        .first = 7824,
        .last = 7824,
    },
    struct_interval{
        .first = 7826,
        .last = 7826,
    },
    struct_interval{
        .first = 7828,
        .last = 7828,
    },
    struct_interval{
        .first = 7838,
        .last = 7838,
    },
    struct_interval{
        .first = 7840,
        .last = 7840,
    },
    struct_interval{
        .first = 7842,
        .last = 7842,
    },
    struct_interval{
        .first = 7844,
        .last = 7844,
    },
    struct_interval{
        .first = 7846,
        .last = 7846,
    },
    struct_interval{
        .first = 7848,
        .last = 7848,
    },
    struct_interval{
        .first = 7850,
        .last = 7850,
    },
    struct_interval{
        .first = 7852,
        .last = 7852,
    },
    struct_interval{
        .first = 7854,
        .last = 7854,
    },
    struct_interval{
        .first = 7856,
        .last = 7856,
    },
    struct_interval{
        .first = 7858,
        .last = 7858,
    },
    struct_interval{
        .first = 7860,
        .last = 7860,
    },
    struct_interval{
        .first = 7862,
        .last = 7862,
    },
    struct_interval{
        .first = 7864,
        .last = 7864,
    },
    struct_interval{
        .first = 7866,
        .last = 7866,
    },
    struct_interval{
        .first = 7868,
        .last = 7868,
    },
    struct_interval{
        .first = 7870,
        .last = 7870,
    },
    struct_interval{
        .first = 7872,
        .last = 7872,
    },
    struct_interval{
        .first = 7874,
        .last = 7874,
    },
    struct_interval{
        .first = 7876,
        .last = 7876,
    },
    struct_interval{
        .first = 7878,
        .last = 7878,
    },
    struct_interval{
        .first = 7880,
        .last = 7880,
    },
    struct_interval{
        .first = 7882,
        .last = 7882,
    },
    struct_interval{
        .first = 7884,
        .last = 7884,
    },
    struct_interval{
        .first = 7886,
        .last = 7886,
    },
    struct_interval{
        .first = 7888,
        .last = 7888,
    },
    struct_interval{
        .first = 7890,
        .last = 7890,
    },
    struct_interval{
        .first = 7892,
        .last = 7892,
    },
    struct_interval{
        .first = 7894,
        .last = 7894,
    },
    struct_interval{
        .first = 7896,
        .last = 7896,
    },
    struct_interval{
        .first = 7898,
        .last = 7898,
    },
    struct_interval{
        .first = 7900,
        .last = 7900,
    },
    struct_interval{
        .first = 7902,
        .last = 7902,
    },
    struct_interval{
        .first = 7904,
        .last = 7904,
    },
    struct_interval{
        .first = 7906,
        .last = 7906,
    },
    struct_interval{
        .first = 7908,
        .last = 7908,
    },
    struct_interval{
        .first = 7910,
        .last = 7910,
    },
    struct_interval{
        .first = 7912,
        .last = 7912,
    },
    struct_interval{
        .first = 7914,
        .last = 7914,
    },
    struct_interval{
        .first = 7916,
        .last = 7916,
    },
    struct_interval{
        .first = 7918,
        .last = 7918,
    },
    struct_interval{
        .first = 7920,
        .last = 7920,
    },
    struct_interval{
        .first = 7922,
        .last = 7922,
    },
    struct_interval{
        .first = 7924,
        .last = 7924,
    },
    struct_interval{
        .first = 7926,
        .last = 7926,
    },
    struct_interval{
        .first = 7928,
        .last = 7928,
    },
    struct_interval{
        .first = 7930,
        .last = 7930,
    },
    struct_interval{
        .first = 7932,
        .last = 7932,
    },
    struct_interval{
        .first = 7934,
        .last = 7934,
    },
    struct_interval{
        .first = 7944,
        .last = 7951,
    },
    struct_interval{
        .first = 7960,
        .last = 7965,
    },
    struct_interval{
        .first = 7976,
        .last = 7983,
    },
    struct_interval{
        .first = 7992,
        .last = 7999,
    },
    struct_interval{
        .first = 8008,
        .last = 8013,
    },
    struct_interval{
        .first = 8025,
        .last = 8025,
    },
    struct_interval{
        .first = 8027,
        .last = 8027,
    },
    struct_interval{
        .first = 8029,
        .last = 8029,
    },
    struct_interval{
        .first = 8031,
        .last = 8031,
    },
    struct_interval{
        .first = 8040,
        .last = 8047,
    },
    struct_interval{
        .first = 8120,
        .last = 8123,
    },
    struct_interval{
        .first = 8136,
        .last = 8139,
    },
    struct_interval{
        .first = 8152,
        .last = 8155,
    },
    struct_interval{
        .first = 8168,
        .last = 8172,
    },
    struct_interval{
        .first = 8184,
        .last = 8187,
    },
    struct_interval{
        .first = 8450,
        .last = 8450,
    },
    struct_interval{
        .first = 8455,
        .last = 8455,
    },
    struct_interval{
        .first = 8459,
        .last = 8461,
    },
    struct_interval{
        .first = 8464,
        .last = 8466,
    },
    struct_interval{
        .first = 8469,
        .last = 8469,
    },
    struct_interval{
        .first = 8473,
        .last = 8477,
    },
    struct_interval{
        .first = 8484,
        .last = 8484,
    },
    struct_interval{
        .first = 8486,
        .last = 8486,
    },
    struct_interval{
        .first = 8488,
        .last = 8488,
    },
    struct_interval{
        .first = 8490,
        .last = 8493,
    },
    struct_interval{
        .first = 8496,
        .last = 8499,
    },
    struct_interval{
        .first = 8510,
        .last = 8511,
    },
    struct_interval{
        .first = 8517,
        .last = 8517,
    },
    struct_interval{
        .first = 8579,
        .last = 8579,
    },
    struct_interval{
        .first = 11264,
        .last = 11311,
    },
    struct_interval{
        .first = 11360,
        .last = 11360,
    },
    struct_interval{
        .first = 11362,
        .last = 11364,
    },
    struct_interval{
        .first = 11367,
        .last = 11367,
    },
    struct_interval{
        .first = 11369,
        .last = 11369,
    },
    struct_interval{
        .first = 11371,
        .last = 11371,
    },
    struct_interval{
        .first = 11373,
        .last = 11376,
    },
    struct_interval{
        .first = 11378,
        .last = 11378,
    },
    struct_interval{
        .first = 11381,
        .last = 11381,
    },
    struct_interval{
        .first = 11390,
        .last = 11392,
    },
    struct_interval{
        .first = 11394,
        .last = 11394,
    },
    struct_interval{
        .first = 11396,
        .last = 11396,
    },
    struct_interval{
        .first = 11398,
        .last = 11398,
    },
    struct_interval{
        .first = 11400,
        .last = 11400,
    },
    struct_interval{
        .first = 11402,
        .last = 11402,
    },
    struct_interval{
        .first = 11404,
        .last = 11404,
    },
    struct_interval{
        .first = 11406,
        .last = 11406,
    },
    struct_interval{
        .first = 11408,
        .last = 11408,
    },
    struct_interval{
        .first = 11410,
        .last = 11410,
    },
    struct_interval{
        .first = 11412,
        .last = 11412,
    },
    struct_interval{
        .first = 11414,
        .last = 11414,
    },
    struct_interval{
        .first = 11416,
        .last = 11416,
    },
    struct_interval{
        .first = 11418,
        .last = 11418,
    },
    struct_interval{
        .first = 11420,
        .last = 11420,
    },
    struct_interval{
        .first = 11422,
        .last = 11422,
    },
    struct_interval{
        .first = 11424,
        .last = 11424,
    },
    struct_interval{
        .first = 11426,
        .last = 11426,
    },
    struct_interval{
        .first = 11428,
        .last = 11428,
    },
    struct_interval{
        .first = 11430,
        .last = 11430,
    },
    struct_interval{
        .first = 11432,
        .last = 11432,
    },
    struct_interval{
        .first = 11434,
        .last = 11434,
    },
    struct_interval{
        .first = 11436,
        .last = 11436,
    },
    struct_interval{
        .first = 11438,
        .last = 11438,
    },
    struct_interval{
        .first = 11440,
        .last = 11440,
    },
    struct_interval{
        .first = 11442,
        .last = 11442,
    },
    struct_interval{
        .first = 11444,
        .last = 11444,
    },
    struct_interval{
        .first = 11446,
        .last = 11446,
    },
    struct_interval{
        .first = 11448,
        .last = 11448,
    },
    struct_interval{
        .first = 11450,
        .last = 11450,
    },
    struct_interval{
        .first = 11452,
        .last = 11452,
    },
    struct_interval{
        .first = 11454,
        .last = 11454,
    },
    struct_interval{
        .first = 11456,
        .last = 11456,
    },
    struct_interval{
        .first = 11458,
        .last = 11458,
    },
    struct_interval{
        .first = 11460,
        .last = 11460,
    },
    struct_interval{
        .first = 11462,
        .last = 11462,
    },
    struct_interval{
        .first = 11464,
        .last = 11464,
    },
    struct_interval{
        .first = 11466,
        .last = 11466,
    },
    struct_interval{
        .first = 11468,
        .last = 11468,
    },
    struct_interval{
        .first = 11470,
        .last = 11470,
    },
    struct_interval{
        .first = 11472,
        .last = 11472,
    },
    struct_interval{
        .first = 11474,
        .last = 11474,
    },
    struct_interval{
        .first = 11476,
        .last = 11476,
    },
    struct_interval{
        .first = 11478,
        .last = 11478,
    },
    struct_interval{
        .first = 11480,
        .last = 11480,
    },
    struct_interval{
        .first = 11482,
        .last = 11482,
    },
    struct_interval{
        .first = 11484,
        .last = 11484,
    },
    struct_interval{
        .first = 11486,
        .last = 11486,
    },
    struct_interval{
        .first = 11488,
        .last = 11488,
    },
    struct_interval{
        .first = 11490,
        .last = 11490,
    },
    struct_interval{
        .first = 11499,
        .last = 11499,
    },
    struct_interval{
        .first = 11501,
        .last = 11501,
    },
    struct_interval{
        .first = 11506,
        .last = 11506,
    },
    struct_interval{
        .first = 42560,
        .last = 42560,
    },
    struct_interval{
        .first = 42562,
        .last = 42562,
    },
    struct_interval{
        .first = 42564,
        .last = 42564,
    },
    struct_interval{
        .first = 42566,
        .last = 42566,
    },
    struct_interval{
        .first = 42568,
        .last = 42568,
    },
    struct_interval{
        .first = 42570,
        .last = 42570,
    },
    struct_interval{
        .first = 42572,
        .last = 42572,
    },
    struct_interval{
        .first = 42574,
        .last = 42574,
    },
    struct_interval{
        .first = 42576,
        .last = 42576,
    },
    struct_interval{
        .first = 42578,
        .last = 42578,
    },
    struct_interval{
        .first = 42580,
        .last = 42580,
    },
    struct_interval{
        .first = 42582,
        .last = 42582,
    },
    struct_interval{
        .first = 42584,
        .last = 42584,
    },
    struct_interval{
        .first = 42586,
        .last = 42586,
    },
    struct_interval{
        .first = 42588,
        .last = 42588,
    },
    struct_interval{
        .first = 42590,
        .last = 42590,
    },
    struct_interval{
        .first = 42592,
        .last = 42592,
    },
    struct_interval{
        .first = 42594,
        .last = 42594,
    },
    struct_interval{
        .first = 42596,
        .last = 42596,
    },
    struct_interval{
        .first = 42598,
        .last = 42598,
    },
    struct_interval{
        .first = 42600,
        .last = 42600,
    },
    struct_interval{
        .first = 42602,
        .last = 42602,
    },
    struct_interval{
        .first = 42604,
        .last = 42604,
    },
    struct_interval{
        .first = 42624,
        .last = 42624,
    },
    struct_interval{
        .first = 42626,
        .last = 42626,
    },
    struct_interval{
        .first = 42628,
        .last = 42628,
    },
    struct_interval{
        .first = 42630,
        .last = 42630,
    },
    struct_interval{
        .first = 42632,
        .last = 42632,
    },
    struct_interval{
        .first = 42634,
        .last = 42634,
    },
    struct_interval{
        .first = 42636,
        .last = 42636,
    },
    struct_interval{
        .first = 42638,
        .last = 42638,
    },
    struct_interval{
        .first = 42640,
        .last = 42640,
    },
    struct_interval{
        .first = 42642,
        .last = 42642,
    },
    struct_interval{
        .first = 42644,
        .last = 42644,
    },
    struct_interval{
        .first = 42646,
        .last = 42646,
    },
    struct_interval{
        .first = 42648,
        .last = 42648,
    },
    struct_interval{
        .first = 42650,
        .last = 42650,
    },
    struct_interval{
        .first = 42786,
        .last = 42786,
    },
    struct_interval{
        .first = 42788,
        .last = 42788,
    },
    struct_interval{
        .first = 42790,
        .last = 42790,
    },
    struct_interval{
        .first = 42792,
        .last = 42792,
    },
    struct_interval{
        .first = 42794,
        .last = 42794,
    },
    struct_interval{
        .first = 42796,
        .last = 42796,
    },
    struct_interval{
        .first = 42798,
        .last = 42798,
    },
    struct_interval{
        .first = 42802,
        .last = 42802,
    },
    struct_interval{
        .first = 42804,
        .last = 42804,
    },
    struct_interval{
        .first = 42806,
        .last = 42806,
    },
    struct_interval{
        .first = 42808,
        .last = 42808,
    },
    struct_interval{
        .first = 42810,
        .last = 42810,
    },
    struct_interval{
        .first = 42812,
        .last = 42812,
    },
    struct_interval{
        .first = 42814,
        .last = 42814,
    },
    struct_interval{
        .first = 42816,
        .last = 42816,
    },
    struct_interval{
        .first = 42818,
        .last = 42818,
    },
    struct_interval{
        .first = 42820,
        .last = 42820,
    },
    struct_interval{
        .first = 42822,
        .last = 42822,
    },
    struct_interval{
        .first = 42824,
        .last = 42824,
    },
    struct_interval{
        .first = 42826,
        .last = 42826,
    },
    struct_interval{
        .first = 42828,
        .last = 42828,
    },
    struct_interval{
        .first = 42830,
        .last = 42830,
    },
    struct_interval{
        .first = 42832,
        .last = 42832,
    },
    struct_interval{
        .first = 42834,
        .last = 42834,
    },
    struct_interval{
        .first = 42836,
        .last = 42836,
    },
    struct_interval{
        .first = 42838,
        .last = 42838,
    },
    struct_interval{
        .first = 42840,
        .last = 42840,
    },
    struct_interval{
        .first = 42842,
        .last = 42842,
    },
    struct_interval{
        .first = 42844,
        .last = 42844,
    },
    struct_interval{
        .first = 42846,
        .last = 42846,
    },
    struct_interval{
        .first = 42848,
        .last = 42848,
    },
    struct_interval{
        .first = 42850,
        .last = 42850,
    },
    struct_interval{
        .first = 42852,
        .last = 42852,
    },
    struct_interval{
        .first = 42854,
        .last = 42854,
    },
    struct_interval{
        .first = 42856,
        .last = 42856,
    },
    struct_interval{
        .first = 42858,
        .last = 42858,
    },
    struct_interval{
        .first = 42860,
        .last = 42860,
    },
    struct_interval{
        .first = 42862,
        .last = 42862,
    },
    struct_interval{
        .first = 42873,
        .last = 42873,
    },
    struct_interval{
        .first = 42875,
        .last = 42875,
    },
    struct_interval{
        .first = 42877,
        .last = 42878,
    },
    struct_interval{
        .first = 42880,
        .last = 42880,
    },
    struct_interval{
        .first = 42882,
        .last = 42882,
    },
    struct_interval{
        .first = 42884,
        .last = 42884,
    },
    struct_interval{
        .first = 42886,
        .last = 42886,
    },
    struct_interval{
        .first = 42891,
        .last = 42891,
    },
    struct_interval{
        .first = 42893,
        .last = 42893,
    },
    struct_interval{
        .first = 42896,
        .last = 42896,
    },
    struct_interval{
        .first = 42898,
        .last = 42898,
    },
    struct_interval{
        .first = 42902,
        .last = 42902,
    },
    struct_interval{
        .first = 42904,
        .last = 42904,
    },
    struct_interval{
        .first = 42906,
        .last = 42906,
    },
    struct_interval{
        .first = 42908,
        .last = 42908,
    },
    struct_interval{
        .first = 42910,
        .last = 42910,
    },
    struct_interval{
        .first = 42912,
        .last = 42912,
    },
    struct_interval{
        .first = 42914,
        .last = 42914,
    },
    struct_interval{
        .first = 42916,
        .last = 42916,
    },
    struct_interval{
        .first = 42918,
        .last = 42918,
    },
    struct_interval{
        .first = 42920,
        .last = 42920,
    },
    struct_interval{
        .first = 42922,
        .last = 42926,
    },
    struct_interval{
        .first = 42928,
        .last = 42932,
    },
    struct_interval{
        .first = 42934,
        .last = 42934,
    },
    struct_interval{
        .first = 42936,
        .last = 42936,
    },
    struct_interval{
        .first = 42938,
        .last = 42938,
    },
    struct_interval{
        .first = 42940,
        .last = 42940,
    },
    struct_interval{
        .first = 42942,
        .last = 42942,
    },
    struct_interval{
        .first = 42944,
        .last = 42944,
    },
    struct_interval{
        .first = 42946,
        .last = 42946,
    },
    struct_interval{
        .first = 42948,
        .last = 42951,
    },
    struct_interval{
        .first = 42953,
        .last = 42953,
    },
    struct_interval{
        .first = 42955,
        .last = 42956,
    },
    struct_interval{
        .first = 42958,
        .last = 42958,
    },
    struct_interval{
        .first = 42960,
        .last = 42960,
    },
    struct_interval{
        .first = 42962,
        .last = 42962,
    },
    struct_interval{
        .first = 42964,
        .last = 42964,
    },
    struct_interval{
        .first = 42966,
        .last = 42966,
    },
    struct_interval{
        .first = 42968,
        .last = 42968,
    },
    struct_interval{
        .first = 42970,
        .last = 42970,
    },
    struct_interval{
        .first = 42972,
        .last = 42972,
    },
    struct_interval{
        .first = 42997,
        .last = 42997,
    },
    struct_interval{
        .first = 65313,
        .last = 65338,
    },
    struct_interval{
        .first = 66560,
        .last = 66599,
    },
    struct_interval{
        .first = 66736,
        .last = 66771,
    },
    struct_interval{
        .first = 66928,
        .last = 66938,
    },
    struct_interval{
        .first = 66940,
        .last = 66954,
    },
    struct_interval{
        .first = 66956,
        .last = 66962,
    },
    struct_interval{
        .first = 66964,
        .last = 66965,
    },
    struct_interval{
        .first = 68736,
        .last = 68786,
    },
    struct_interval{
        .first = 68944,
        .last = 68965,
    },
    struct_interval{
        .first = 71840,
        .last = 71871,
    },
    struct_interval{
        .first = 93760,
        .last = 93791,
    },
    struct_interval{
        .first = 93856,
        .last = 93880,
    },
    struct_interval{
        .first = 119808,
        .last = 119833,
    },
    struct_interval{
        .first = 119860,
        .last = 119885,
    },
    struct_interval{
        .first = 119912,
        .last = 119937,
    },
    struct_interval{
        .first = 119964,
        .last = 119964,
    },
    struct_interval{
        .first = 119966,
        .last = 119967,
    },
    struct_interval{
        .first = 119970,
        .last = 119970,
    },
    struct_interval{
        .first = 119973,
        .last = 119974,
    },
    struct_interval{
        .first = 119977,
        .last = 119980,
    },
    struct_interval{
        .first = 119982,
        .last = 119989,
    },
    struct_interval{
        .first = 120016,
        .last = 120041,
    },
    struct_interval{
        .first = 120068,
        .last = 120069,
    },
    struct_interval{
        .first = 120071,
        .last = 120074,
    },
    struct_interval{
        .first = 120077,
        .last = 120084,
    },
    struct_interval{
        .first = 120086,
        .last = 120092,
    },
    struct_interval{
        .first = 120120,
        .last = 120121,
    },
    struct_interval{
        .first = 120123,
        .last = 120126,
    },
    struct_interval{
        .first = 120128,
        .last = 120132,
    },
    struct_interval{
        .first = 120134,
        .last = 120134,
    },
    struct_interval{
        .first = 120138,
        .last = 120144,
    },
    struct_interval{
        .first = 120172,
        .last = 120197,
    },
    struct_interval{
        .first = 120224,
        .last = 120249,
    },
    struct_interval{
        .first = 120276,
        .last = 120301,
    },
    struct_interval{
        .first = 120328,
        .last = 120353,
    },
    struct_interval{
        .first = 120380,
        .last = 120405,
    },
    struct_interval{
        .first = 120432,
        .last = 120457,
    },
    struct_interval{
        .first = 120488,
        .last = 120512,
    },
    struct_interval{
        .first = 120546,
        .last = 120570,
    },
    struct_interval{
        .first = 120604,
        .last = 120628,
    },
    struct_interval{
        .first = 120662,
        .last = 120686,
    },
    struct_interval{
        .first = 120720,
        .last = 120744,
    },
    struct_interval{
        .first = 120778,
        .last = 120778,
    },
    struct_interval{
        .first = 125184,
        .last = 125217,
    },
};
pub export const Nd_table: [77]struct_interval = [77]struct_interval{
    struct_interval{
        .first = 48,
        .last = 57,
    },
    struct_interval{
        .first = 1632,
        .last = 1641,
    },
    struct_interval{
        .first = 1776,
        .last = 1785,
    },
    struct_interval{
        .first = 1984,
        .last = 1993,
    },
    struct_interval{
        .first = 2406,
        .last = 2415,
    },
    struct_interval{
        .first = 2534,
        .last = 2543,
    },
    struct_interval{
        .first = 2662,
        .last = 2671,
    },
    struct_interval{
        .first = 2790,
        .last = 2799,
    },
    struct_interval{
        .first = 2918,
        .last = 2927,
    },
    struct_interval{
        .first = 3046,
        .last = 3055,
    },
    struct_interval{
        .first = 3174,
        .last = 3183,
    },
    struct_interval{
        .first = 3302,
        .last = 3311,
    },
    struct_interval{
        .first = 3430,
        .last = 3439,
    },
    struct_interval{
        .first = 3558,
        .last = 3567,
    },
    struct_interval{
        .first = 3664,
        .last = 3673,
    },
    struct_interval{
        .first = 3792,
        .last = 3801,
    },
    struct_interval{
        .first = 3872,
        .last = 3881,
    },
    struct_interval{
        .first = 4160,
        .last = 4169,
    },
    struct_interval{
        .first = 4240,
        .last = 4249,
    },
    struct_interval{
        .first = 6112,
        .last = 6121,
    },
    struct_interval{
        .first = 6160,
        .last = 6169,
    },
    struct_interval{
        .first = 6470,
        .last = 6479,
    },
    struct_interval{
        .first = 6608,
        .last = 6617,
    },
    struct_interval{
        .first = 6784,
        .last = 6793,
    },
    struct_interval{
        .first = 6800,
        .last = 6809,
    },
    struct_interval{
        .first = 6992,
        .last = 7001,
    },
    struct_interval{
        .first = 7088,
        .last = 7097,
    },
    struct_interval{
        .first = 7232,
        .last = 7241,
    },
    struct_interval{
        .first = 7248,
        .last = 7257,
    },
    struct_interval{
        .first = 42528,
        .last = 42537,
    },
    struct_interval{
        .first = 43216,
        .last = 43225,
    },
    struct_interval{
        .first = 43264,
        .last = 43273,
    },
    struct_interval{
        .first = 43472,
        .last = 43481,
    },
    struct_interval{
        .first = 43504,
        .last = 43513,
    },
    struct_interval{
        .first = 43600,
        .last = 43609,
    },
    struct_interval{
        .first = 44016,
        .last = 44025,
    },
    struct_interval{
        .first = 65296,
        .last = 65305,
    },
    struct_interval{
        .first = 66720,
        .last = 66729,
    },
    struct_interval{
        .first = 68912,
        .last = 68921,
    },
    struct_interval{
        .first = 68928,
        .last = 68937,
    },
    struct_interval{
        .first = 69734,
        .last = 69743,
    },
    struct_interval{
        .first = 69872,
        .last = 69881,
    },
    struct_interval{
        .first = 69942,
        .last = 69951,
    },
    struct_interval{
        .first = 70096,
        .last = 70105,
    },
    struct_interval{
        .first = 70384,
        .last = 70393,
    },
    struct_interval{
        .first = 70736,
        .last = 70745,
    },
    struct_interval{
        .first = 70864,
        .last = 70873,
    },
    struct_interval{
        .first = 71248,
        .last = 71257,
    },
    struct_interval{
        .first = 71360,
        .last = 71369,
    },
    struct_interval{
        .first = 71376,
        .last = 71385,
    },
    struct_interval{
        .first = 71386,
        .last = 71395,
    },
    struct_interval{
        .first = 71472,
        .last = 71481,
    },
    struct_interval{
        .first = 71904,
        .last = 71913,
    },
    struct_interval{
        .first = 72016,
        .last = 72025,
    },
    struct_interval{
        .first = 72688,
        .last = 72697,
    },
    struct_interval{
        .first = 72784,
        .last = 72793,
    },
    struct_interval{
        .first = 73040,
        .last = 73049,
    },
    struct_interval{
        .first = 73120,
        .last = 73129,
    },
    struct_interval{
        .first = 73184,
        .last = 73193,
    },
    struct_interval{
        .first = 73552,
        .last = 73561,
    },
    struct_interval{
        .first = 90416,
        .last = 90425,
    },
    struct_interval{
        .first = 92768,
        .last = 92777,
    },
    struct_interval{
        .first = 92864,
        .last = 92873,
    },
    struct_interval{
        .first = 93008,
        .last = 93017,
    },
    struct_interval{
        .first = 93552,
        .last = 93561,
    },
    struct_interval{
        .first = 118000,
        .last = 118009,
    },
    struct_interval{
        .first = 120782,
        .last = 120791,
    },
    struct_interval{
        .first = 120792,
        .last = 120801,
    },
    struct_interval{
        .first = 120802,
        .last = 120811,
    },
    struct_interval{
        .first = 120812,
        .last = 120821,
    },
    struct_interval{
        .first = 120822,
        .last = 120831,
    },
    struct_interval{
        .first = 123200,
        .last = 123209,
    },
    struct_interval{
        .first = 123632,
        .last = 123641,
    },
    struct_interval{
        .first = 124144,
        .last = 124153,
    },
    struct_interval{
        .first = 124401,
        .last = 124410,
    },
    struct_interval{
        .first = 125264,
        .last = 125273,
    },
    struct_interval{
        .first = 130032,
        .last = 130041,
    },
};
pub export const Pd_table: [20]struct_interval = [20]struct_interval{
    struct_interval{
        .first = 45,
        .last = 45,
    },
    struct_interval{
        .first = 1418,
        .last = 1418,
    },
    struct_interval{
        .first = 1470,
        .last = 1470,
    },
    struct_interval{
        .first = 5120,
        .last = 5120,
    },
    struct_interval{
        .first = 6150,
        .last = 6150,
    },
    struct_interval{
        .first = 8208,
        .last = 8213,
    },
    struct_interval{
        .first = 11799,
        .last = 11799,
    },
    struct_interval{
        .first = 11802,
        .last = 11802,
    },
    struct_interval{
        .first = 11834,
        .last = 11835,
    },
    struct_interval{
        .first = 11840,
        .last = 11840,
    },
    struct_interval{
        .first = 11869,
        .last = 11869,
    },
    struct_interval{
        .first = 12316,
        .last = 12316,
    },
    struct_interval{
        .first = 12336,
        .last = 12336,
    },
    struct_interval{
        .first = 12448,
        .last = 12448,
    },
    struct_interval{
        .first = 65073,
        .last = 65074,
    },
    struct_interval{
        .first = 65112,
        .last = 65112,
    },
    struct_interval{
        .first = 65123,
        .last = 65123,
    },
    struct_interval{
        .first = 65293,
        .last = 65293,
    },
    struct_interval{
        .first = 68974,
        .last = 68974,
    },
    struct_interval{
        .first = 69293,
        .last = 69293,
    },
};
pub export const Sm_table: [67]struct_interval = [67]struct_interval{
    struct_interval{
        .first = 43,
        .last = 43,
    },
    struct_interval{
        .first = 60,
        .last = 62,
    },
    struct_interval{
        .first = 124,
        .last = 124,
    },
    struct_interval{
        .first = 126,
        .last = 126,
    },
    struct_interval{
        .first = 172,
        .last = 172,
    },
    struct_interval{
        .first = 177,
        .last = 177,
    },
    struct_interval{
        .first = 215,
        .last = 215,
    },
    struct_interval{
        .first = 247,
        .last = 247,
    },
    struct_interval{
        .first = 1014,
        .last = 1014,
    },
    struct_interval{
        .first = 1542,
        .last = 1544,
    },
    struct_interval{
        .first = 8260,
        .last = 8260,
    },
    struct_interval{
        .first = 8274,
        .last = 8274,
    },
    struct_interval{
        .first = 8314,
        .last = 8316,
    },
    struct_interval{
        .first = 8330,
        .last = 8332,
    },
    struct_interval{
        .first = 8472,
        .last = 8472,
    },
    struct_interval{
        .first = 8512,
        .last = 8516,
    },
    struct_interval{
        .first = 8523,
        .last = 8523,
    },
    struct_interval{
        .first = 8592,
        .last = 8596,
    },
    struct_interval{
        .first = 8602,
        .last = 8603,
    },
    struct_interval{
        .first = 8608,
        .last = 8608,
    },
    struct_interval{
        .first = 8611,
        .last = 8611,
    },
    struct_interval{
        .first = 8614,
        .last = 8614,
    },
    struct_interval{
        .first = 8622,
        .last = 8622,
    },
    struct_interval{
        .first = 8654,
        .last = 8655,
    },
    struct_interval{
        .first = 8658,
        .last = 8658,
    },
    struct_interval{
        .first = 8660,
        .last = 8660,
    },
    struct_interval{
        .first = 8692,
        .last = 8959,
    },
    struct_interval{
        .first = 8992,
        .last = 8993,
    },
    struct_interval{
        .first = 9084,
        .last = 9084,
    },
    struct_interval{
        .first = 9115,
        .last = 9139,
    },
    struct_interval{
        .first = 9180,
        .last = 9185,
    },
    struct_interval{
        .first = 9655,
        .last = 9655,
    },
    struct_interval{
        .first = 9665,
        .last = 9665,
    },
    struct_interval{
        .first = 9720,
        .last = 9727,
    },
    struct_interval{
        .first = 9839,
        .last = 9839,
    },
    struct_interval{
        .first = 10176,
        .last = 10180,
    },
    struct_interval{
        .first = 10183,
        .last = 10213,
    },
    struct_interval{
        .first = 10224,
        .last = 10239,
    },
    struct_interval{
        .first = 10496,
        .last = 10626,
    },
    struct_interval{
        .first = 10649,
        .last = 10711,
    },
    struct_interval{
        .first = 10716,
        .last = 10747,
    },
    struct_interval{
        .first = 10750,
        .last = 11007,
    },
    struct_interval{
        .first = 11056,
        .last = 11076,
    },
    struct_interval{
        .first = 11079,
        .last = 11084,
    },
    struct_interval{
        .first = 64297,
        .last = 64297,
    },
    struct_interval{
        .first = 65122,
        .last = 65122,
    },
    struct_interval{
        .first = 65124,
        .last = 65126,
    },
    struct_interval{
        .first = 65291,
        .last = 65291,
    },
    struct_interval{
        .first = 65308,
        .last = 65310,
    },
    struct_interval{
        .first = 65372,
        .last = 65372,
    },
    struct_interval{
        .first = 65374,
        .last = 65374,
    },
    struct_interval{
        .first = 65506,
        .last = 65506,
    },
    struct_interval{
        .first = 65513,
        .last = 65516,
    },
    struct_interval{
        .first = 69006,
        .last = 69007,
    },
    struct_interval{
        .first = 118512,
        .last = 118512,
    },
    struct_interval{
        .first = 120513,
        .last = 120513,
    },
    struct_interval{
        .first = 120539,
        .last = 120539,
    },
    struct_interval{
        .first = 120571,
        .last = 120571,
    },
    struct_interval{
        .first = 120597,
        .last = 120597,
    },
    struct_interval{
        .first = 120629,
        .last = 120629,
    },
    struct_interval{
        .first = 120655,
        .last = 120655,
    },
    struct_interval{
        .first = 120687,
        .last = 120687,
    },
    struct_interval{
        .first = 120713,
        .last = 120713,
    },
    struct_interval{
        .first = 120745,
        .last = 120745,
    },
    struct_interval{
        .first = 120771,
        .last = 120771,
    },
    struct_interval{
        .first = 126704,
        .last = 126705,
    },
    struct_interval{
        .first = 129232,
        .last = 129240,
    },
};
pub export const Pe_table: [76]struct_interval = [76]struct_interval{
    struct_interval{
        .first = 41,
        .last = 41,
    },
    struct_interval{
        .first = 93,
        .last = 93,
    },
    struct_interval{
        .first = 125,
        .last = 125,
    },
    struct_interval{
        .first = 3899,
        .last = 3899,
    },
    struct_interval{
        .first = 3901,
        .last = 3901,
    },
    struct_interval{
        .first = 5788,
        .last = 5788,
    },
    struct_interval{
        .first = 8262,
        .last = 8262,
    },
    struct_interval{
        .first = 8318,
        .last = 8318,
    },
    struct_interval{
        .first = 8334,
        .last = 8334,
    },
    struct_interval{
        .first = 8969,
        .last = 8969,
    },
    struct_interval{
        .first = 8971,
        .last = 8971,
    },
    struct_interval{
        .first = 9002,
        .last = 9002,
    },
    struct_interval{
        .first = 10089,
        .last = 10089,
    },
    struct_interval{
        .first = 10091,
        .last = 10091,
    },
    struct_interval{
        .first = 10093,
        .last = 10093,
    },
    struct_interval{
        .first = 10095,
        .last = 10095,
    },
    struct_interval{
        .first = 10097,
        .last = 10097,
    },
    struct_interval{
        .first = 10099,
        .last = 10099,
    },
    struct_interval{
        .first = 10101,
        .last = 10101,
    },
    struct_interval{
        .first = 10182,
        .last = 10182,
    },
    struct_interval{
        .first = 10215,
        .last = 10215,
    },
    struct_interval{
        .first = 10217,
        .last = 10217,
    },
    struct_interval{
        .first = 10219,
        .last = 10219,
    },
    struct_interval{
        .first = 10221,
        .last = 10221,
    },
    struct_interval{
        .first = 10223,
        .last = 10223,
    },
    struct_interval{
        .first = 10628,
        .last = 10628,
    },
    struct_interval{
        .first = 10630,
        .last = 10630,
    },
    struct_interval{
        .first = 10632,
        .last = 10632,
    },
    struct_interval{
        .first = 10634,
        .last = 10634,
    },
    struct_interval{
        .first = 10636,
        .last = 10636,
    },
    struct_interval{
        .first = 10638,
        .last = 10638,
    },
    struct_interval{
        .first = 10640,
        .last = 10640,
    },
    struct_interval{
        .first = 10642,
        .last = 10642,
    },
    struct_interval{
        .first = 10644,
        .last = 10644,
    },
    struct_interval{
        .first = 10646,
        .last = 10646,
    },
    struct_interval{
        .first = 10648,
        .last = 10648,
    },
    struct_interval{
        .first = 10713,
        .last = 10713,
    },
    struct_interval{
        .first = 10715,
        .last = 10715,
    },
    struct_interval{
        .first = 10749,
        .last = 10749,
    },
    struct_interval{
        .first = 11811,
        .last = 11811,
    },
    struct_interval{
        .first = 11813,
        .last = 11813,
    },
    struct_interval{
        .first = 11815,
        .last = 11815,
    },
    struct_interval{
        .first = 11817,
        .last = 11817,
    },
    struct_interval{
        .first = 11862,
        .last = 11862,
    },
    struct_interval{
        .first = 11864,
        .last = 11864,
    },
    struct_interval{
        .first = 11866,
        .last = 11866,
    },
    struct_interval{
        .first = 11868,
        .last = 11868,
    },
    struct_interval{
        .first = 12297,
        .last = 12297,
    },
    struct_interval{
        .first = 12299,
        .last = 12299,
    },
    struct_interval{
        .first = 12301,
        .last = 12301,
    },
    struct_interval{
        .first = 12303,
        .last = 12303,
    },
    struct_interval{
        .first = 12305,
        .last = 12305,
    },
    struct_interval{
        .first = 12309,
        .last = 12309,
    },
    struct_interval{
        .first = 12311,
        .last = 12311,
    },
    struct_interval{
        .first = 12313,
        .last = 12313,
    },
    struct_interval{
        .first = 12315,
        .last = 12315,
    },
    struct_interval{
        .first = 12318,
        .last = 12319,
    },
    struct_interval{
        .first = 64830,
        .last = 64830,
    },
    struct_interval{
        .first = 65048,
        .last = 65048,
    },
    struct_interval{
        .first = 65078,
        .last = 65078,
    },
    struct_interval{
        .first = 65080,
        .last = 65080,
    },
    struct_interval{
        .first = 65082,
        .last = 65082,
    },
    struct_interval{
        .first = 65084,
        .last = 65084,
    },
    struct_interval{
        .first = 65086,
        .last = 65086,
    },
    struct_interval{
        .first = 65088,
        .last = 65088,
    },
    struct_interval{
        .first = 65090,
        .last = 65090,
    },
    struct_interval{
        .first = 65092,
        .last = 65092,
    },
    struct_interval{
        .first = 65096,
        .last = 65096,
    },
    struct_interval{
        .first = 65114,
        .last = 65114,
    },
    struct_interval{
        .first = 65116,
        .last = 65116,
    },
    struct_interval{
        .first = 65118,
        .last = 65118,
    },
    struct_interval{
        .first = 65289,
        .last = 65289,
    },
    struct_interval{
        .first = 65341,
        .last = 65341,
    },
    struct_interval{
        .first = 65373,
        .last = 65373,
    },
    struct_interval{
        .first = 65376,
        .last = 65376,
    },
    struct_interval{
        .first = 65379,
        .last = 65379,
    },
};
pub export const Ps_table: [79]struct_interval = [79]struct_interval{
    struct_interval{
        .first = 40,
        .last = 40,
    },
    struct_interval{
        .first = 91,
        .last = 91,
    },
    struct_interval{
        .first = 123,
        .last = 123,
    },
    struct_interval{
        .first = 3898,
        .last = 3898,
    },
    struct_interval{
        .first = 3900,
        .last = 3900,
    },
    struct_interval{
        .first = 5787,
        .last = 5787,
    },
    struct_interval{
        .first = 8218,
        .last = 8218,
    },
    struct_interval{
        .first = 8222,
        .last = 8222,
    },
    struct_interval{
        .first = 8261,
        .last = 8261,
    },
    struct_interval{
        .first = 8317,
        .last = 8317,
    },
    struct_interval{
        .first = 8333,
        .last = 8333,
    },
    struct_interval{
        .first = 8968,
        .last = 8968,
    },
    struct_interval{
        .first = 8970,
        .last = 8970,
    },
    struct_interval{
        .first = 9001,
        .last = 9001,
    },
    struct_interval{
        .first = 10088,
        .last = 10088,
    },
    struct_interval{
        .first = 10090,
        .last = 10090,
    },
    struct_interval{
        .first = 10092,
        .last = 10092,
    },
    struct_interval{
        .first = 10094,
        .last = 10094,
    },
    struct_interval{
        .first = 10096,
        .last = 10096,
    },
    struct_interval{
        .first = 10098,
        .last = 10098,
    },
    struct_interval{
        .first = 10100,
        .last = 10100,
    },
    struct_interval{
        .first = 10181,
        .last = 10181,
    },
    struct_interval{
        .first = 10214,
        .last = 10214,
    },
    struct_interval{
        .first = 10216,
        .last = 10216,
    },
    struct_interval{
        .first = 10218,
        .last = 10218,
    },
    struct_interval{
        .first = 10220,
        .last = 10220,
    },
    struct_interval{
        .first = 10222,
        .last = 10222,
    },
    struct_interval{
        .first = 10627,
        .last = 10627,
    },
    struct_interval{
        .first = 10629,
        .last = 10629,
    },
    struct_interval{
        .first = 10631,
        .last = 10631,
    },
    struct_interval{
        .first = 10633,
        .last = 10633,
    },
    struct_interval{
        .first = 10635,
        .last = 10635,
    },
    struct_interval{
        .first = 10637,
        .last = 10637,
    },
    struct_interval{
        .first = 10639,
        .last = 10639,
    },
    struct_interval{
        .first = 10641,
        .last = 10641,
    },
    struct_interval{
        .first = 10643,
        .last = 10643,
    },
    struct_interval{
        .first = 10645,
        .last = 10645,
    },
    struct_interval{
        .first = 10647,
        .last = 10647,
    },
    struct_interval{
        .first = 10712,
        .last = 10712,
    },
    struct_interval{
        .first = 10714,
        .last = 10714,
    },
    struct_interval{
        .first = 10748,
        .last = 10748,
    },
    struct_interval{
        .first = 11810,
        .last = 11810,
    },
    struct_interval{
        .first = 11812,
        .last = 11812,
    },
    struct_interval{
        .first = 11814,
        .last = 11814,
    },
    struct_interval{
        .first = 11816,
        .last = 11816,
    },
    struct_interval{
        .first = 11842,
        .last = 11842,
    },
    struct_interval{
        .first = 11861,
        .last = 11861,
    },
    struct_interval{
        .first = 11863,
        .last = 11863,
    },
    struct_interval{
        .first = 11865,
        .last = 11865,
    },
    struct_interval{
        .first = 11867,
        .last = 11867,
    },
    struct_interval{
        .first = 12296,
        .last = 12296,
    },
    struct_interval{
        .first = 12298,
        .last = 12298,
    },
    struct_interval{
        .first = 12300,
        .last = 12300,
    },
    struct_interval{
        .first = 12302,
        .last = 12302,
    },
    struct_interval{
        .first = 12304,
        .last = 12304,
    },
    struct_interval{
        .first = 12308,
        .last = 12308,
    },
    struct_interval{
        .first = 12310,
        .last = 12310,
    },
    struct_interval{
        .first = 12312,
        .last = 12312,
    },
    struct_interval{
        .first = 12314,
        .last = 12314,
    },
    struct_interval{
        .first = 12317,
        .last = 12317,
    },
    struct_interval{
        .first = 64831,
        .last = 64831,
    },
    struct_interval{
        .first = 65047,
        .last = 65047,
    },
    struct_interval{
        .first = 65077,
        .last = 65077,
    },
    struct_interval{
        .first = 65079,
        .last = 65079,
    },
    struct_interval{
        .first = 65081,
        .last = 65081,
    },
    struct_interval{
        .first = 65083,
        .last = 65083,
    },
    struct_interval{
        .first = 65085,
        .last = 65085,
    },
    struct_interval{
        .first = 65087,
        .last = 65087,
    },
    struct_interval{
        .first = 65089,
        .last = 65089,
    },
    struct_interval{
        .first = 65091,
        .last = 65091,
    },
    struct_interval{
        .first = 65095,
        .last = 65095,
    },
    struct_interval{
        .first = 65113,
        .last = 65113,
    },
    struct_interval{
        .first = 65115,
        .last = 65115,
    },
    struct_interval{
        .first = 65117,
        .last = 65117,
    },
    struct_interval{
        .first = 65288,
        .last = 65288,
    },
    struct_interval{
        .first = 65339,
        .last = 65339,
    },
    struct_interval{
        .first = 65371,
        .last = 65371,
    },
    struct_interval{
        .first = 65375,
        .last = 65375,
    },
    struct_interval{
        .first = 65378,
        .last = 65378,
    },
};
pub export const Sc_table: [21]struct_interval = [21]struct_interval{
    struct_interval{
        .first = 36,
        .last = 36,
    },
    struct_interval{
        .first = 162,
        .last = 165,
    },
    struct_interval{
        .first = 1423,
        .last = 1423,
    },
    struct_interval{
        .first = 1547,
        .last = 1547,
    },
    struct_interval{
        .first = 2046,
        .last = 2047,
    },
    struct_interval{
        .first = 2546,
        .last = 2547,
    },
    struct_interval{
        .first = 2555,
        .last = 2555,
    },
    struct_interval{
        .first = 2801,
        .last = 2801,
    },
    struct_interval{
        .first = 3065,
        .last = 3065,
    },
    struct_interval{
        .first = 3647,
        .last = 3647,
    },
    struct_interval{
        .first = 6107,
        .last = 6107,
    },
    struct_interval{
        .first = 8352,
        .last = 8385,
    },
    struct_interval{
        .first = 43064,
        .last = 43064,
    },
    struct_interval{
        .first = 65020,
        .last = 65020,
    },
    struct_interval{
        .first = 65129,
        .last = 65129,
    },
    struct_interval{
        .first = 65284,
        .last = 65284,
    },
    struct_interval{
        .first = 65504,
        .last = 65505,
    },
    struct_interval{
        .first = 65509,
        .last = 65510,
    },
    struct_interval{
        .first = 73693,
        .last = 73696,
    },
    struct_interval{
        .first = 123647,
        .last = 123647,
    },
    struct_interval{
        .first = 126128,
        .last = 126128,
    },
};
pub export const Po_table: [194]struct_interval = [194]struct_interval{
    struct_interval{
        .first = 33,
        .last = 35,
    },
    struct_interval{
        .first = 37,
        .last = 39,
    },
    struct_interval{
        .first = 42,
        .last = 42,
    },
    struct_interval{
        .first = 44,
        .last = 44,
    },
    struct_interval{
        .first = 46,
        .last = 47,
    },
    struct_interval{
        .first = 58,
        .last = 59,
    },
    struct_interval{
        .first = 63,
        .last = 64,
    },
    struct_interval{
        .first = 92,
        .last = 92,
    },
    struct_interval{
        .first = 161,
        .last = 161,
    },
    struct_interval{
        .first = 167,
        .last = 167,
    },
    struct_interval{
        .first = 182,
        .last = 183,
    },
    struct_interval{
        .first = 191,
        .last = 191,
    },
    struct_interval{
        .first = 894,
        .last = 894,
    },
    struct_interval{
        .first = 903,
        .last = 903,
    },
    struct_interval{
        .first = 1370,
        .last = 1375,
    },
    struct_interval{
        .first = 1417,
        .last = 1417,
    },
    struct_interval{
        .first = 1472,
        .last = 1472,
    },
    struct_interval{
        .first = 1475,
        .last = 1475,
    },
    struct_interval{
        .first = 1478,
        .last = 1478,
    },
    struct_interval{
        .first = 1523,
        .last = 1524,
    },
    struct_interval{
        .first = 1545,
        .last = 1546,
    },
    struct_interval{
        .first = 1548,
        .last = 1549,
    },
    struct_interval{
        .first = 1563,
        .last = 1563,
    },
    struct_interval{
        .first = 1565,
        .last = 1567,
    },
    struct_interval{
        .first = 1642,
        .last = 1645,
    },
    struct_interval{
        .first = 1748,
        .last = 1748,
    },
    struct_interval{
        .first = 1792,
        .last = 1805,
    },
    struct_interval{
        .first = 2039,
        .last = 2041,
    },
    struct_interval{
        .first = 2096,
        .last = 2110,
    },
    struct_interval{
        .first = 2142,
        .last = 2142,
    },
    struct_interval{
        .first = 2404,
        .last = 2405,
    },
    struct_interval{
        .first = 2416,
        .last = 2416,
    },
    struct_interval{
        .first = 2557,
        .last = 2557,
    },
    struct_interval{
        .first = 2678,
        .last = 2678,
    },
    struct_interval{
        .first = 2800,
        .last = 2800,
    },
    struct_interval{
        .first = 3191,
        .last = 3191,
    },
    struct_interval{
        .first = 3204,
        .last = 3204,
    },
    struct_interval{
        .first = 3572,
        .last = 3572,
    },
    struct_interval{
        .first = 3663,
        .last = 3663,
    },
    struct_interval{
        .first = 3674,
        .last = 3675,
    },
    struct_interval{
        .first = 3844,
        .last = 3858,
    },
    struct_interval{
        .first = 3860,
        .last = 3860,
    },
    struct_interval{
        .first = 3973,
        .last = 3973,
    },
    struct_interval{
        .first = 4048,
        .last = 4052,
    },
    struct_interval{
        .first = 4057,
        .last = 4058,
    },
    struct_interval{
        .first = 4170,
        .last = 4175,
    },
    struct_interval{
        .first = 4347,
        .last = 4347,
    },
    struct_interval{
        .first = 4960,
        .last = 4968,
    },
    struct_interval{
        .first = 5742,
        .last = 5742,
    },
    struct_interval{
        .first = 5867,
        .last = 5869,
    },
    struct_interval{
        .first = 5941,
        .last = 5942,
    },
    struct_interval{
        .first = 6100,
        .last = 6102,
    },
    struct_interval{
        .first = 6104,
        .last = 6106,
    },
    struct_interval{
        .first = 6144,
        .last = 6149,
    },
    struct_interval{
        .first = 6151,
        .last = 6154,
    },
    struct_interval{
        .first = 6468,
        .last = 6469,
    },
    struct_interval{
        .first = 6686,
        .last = 6687,
    },
    struct_interval{
        .first = 6816,
        .last = 6822,
    },
    struct_interval{
        .first = 6824,
        .last = 6829,
    },
    struct_interval{
        .first = 6990,
        .last = 6991,
    },
    struct_interval{
        .first = 7002,
        .last = 7008,
    },
    struct_interval{
        .first = 7037,
        .last = 7039,
    },
    struct_interval{
        .first = 7164,
        .last = 7167,
    },
    struct_interval{
        .first = 7227,
        .last = 7231,
    },
    struct_interval{
        .first = 7294,
        .last = 7295,
    },
    struct_interval{
        .first = 7360,
        .last = 7367,
    },
    struct_interval{
        .first = 7379,
        .last = 7379,
    },
    struct_interval{
        .first = 8214,
        .last = 8215,
    },
    struct_interval{
        .first = 8224,
        .last = 8231,
    },
    struct_interval{
        .first = 8240,
        .last = 8248,
    },
    struct_interval{
        .first = 8251,
        .last = 8254,
    },
    struct_interval{
        .first = 8257,
        .last = 8259,
    },
    struct_interval{
        .first = 8263,
        .last = 8273,
    },
    struct_interval{
        .first = 8275,
        .last = 8275,
    },
    struct_interval{
        .first = 8277,
        .last = 8286,
    },
    struct_interval{
        .first = 11513,
        .last = 11516,
    },
    struct_interval{
        .first = 11518,
        .last = 11519,
    },
    struct_interval{
        .first = 11632,
        .last = 11632,
    },
    struct_interval{
        .first = 11776,
        .last = 11777,
    },
    struct_interval{
        .first = 11782,
        .last = 11784,
    },
    struct_interval{
        .first = 11787,
        .last = 11787,
    },
    struct_interval{
        .first = 11790,
        .last = 11798,
    },
    struct_interval{
        .first = 11800,
        .last = 11801,
    },
    struct_interval{
        .first = 11803,
        .last = 11803,
    },
    struct_interval{
        .first = 11806,
        .last = 11807,
    },
    struct_interval{
        .first = 11818,
        .last = 11822,
    },
    struct_interval{
        .first = 11824,
        .last = 11833,
    },
    struct_interval{
        .first = 11836,
        .last = 11839,
    },
    struct_interval{
        .first = 11841,
        .last = 11841,
    },
    struct_interval{
        .first = 11843,
        .last = 11855,
    },
    struct_interval{
        .first = 11858,
        .last = 11860,
    },
    struct_interval{
        .first = 12289,
        .last = 12291,
    },
    struct_interval{
        .first = 12349,
        .last = 12349,
    },
    struct_interval{
        .first = 12539,
        .last = 12539,
    },
    struct_interval{
        .first = 42238,
        .last = 42239,
    },
    struct_interval{
        .first = 42509,
        .last = 42511,
    },
    struct_interval{
        .first = 42611,
        .last = 42611,
    },
    struct_interval{
        .first = 42622,
        .last = 42622,
    },
    struct_interval{
        .first = 42738,
        .last = 42743,
    },
    struct_interval{
        .first = 43124,
        .last = 43127,
    },
    struct_interval{
        .first = 43214,
        .last = 43215,
    },
    struct_interval{
        .first = 43256,
        .last = 43258,
    },
    struct_interval{
        .first = 43260,
        .last = 43260,
    },
    struct_interval{
        .first = 43310,
        .last = 43311,
    },
    struct_interval{
        .first = 43359,
        .last = 43359,
    },
    struct_interval{
        .first = 43457,
        .last = 43469,
    },
    struct_interval{
        .first = 43486,
        .last = 43487,
    },
    struct_interval{
        .first = 43612,
        .last = 43615,
    },
    struct_interval{
        .first = 43742,
        .last = 43743,
    },
    struct_interval{
        .first = 43760,
        .last = 43761,
    },
    struct_interval{
        .first = 44011,
        .last = 44011,
    },
    struct_interval{
        .first = 65040,
        .last = 65046,
    },
    struct_interval{
        .first = 65049,
        .last = 65049,
    },
    struct_interval{
        .first = 65072,
        .last = 65072,
    },
    struct_interval{
        .first = 65093,
        .last = 65094,
    },
    struct_interval{
        .first = 65097,
        .last = 65100,
    },
    struct_interval{
        .first = 65104,
        .last = 65106,
    },
    struct_interval{
        .first = 65108,
        .last = 65111,
    },
    struct_interval{
        .first = 65119,
        .last = 65121,
    },
    struct_interval{
        .first = 65128,
        .last = 65128,
    },
    struct_interval{
        .first = 65130,
        .last = 65131,
    },
    struct_interval{
        .first = 65281,
        .last = 65283,
    },
    struct_interval{
        .first = 65285,
        .last = 65287,
    },
    struct_interval{
        .first = 65290,
        .last = 65290,
    },
    struct_interval{
        .first = 65292,
        .last = 65292,
    },
    struct_interval{
        .first = 65294,
        .last = 65295,
    },
    struct_interval{
        .first = 65306,
        .last = 65307,
    },
    struct_interval{
        .first = 65311,
        .last = 65312,
    },
    struct_interval{
        .first = 65340,
        .last = 65340,
    },
    struct_interval{
        .first = 65377,
        .last = 65377,
    },
    struct_interval{
        .first = 65380,
        .last = 65381,
    },
    struct_interval{
        .first = 65792,
        .last = 65794,
    },
    struct_interval{
        .first = 66463,
        .last = 66463,
    },
    struct_interval{
        .first = 66512,
        .last = 66512,
    },
    struct_interval{
        .first = 66927,
        .last = 66927,
    },
    struct_interval{
        .first = 67671,
        .last = 67671,
    },
    struct_interval{
        .first = 67871,
        .last = 67871,
    },
    struct_interval{
        .first = 67903,
        .last = 67903,
    },
    struct_interval{
        .first = 68176,
        .last = 68184,
    },
    struct_interval{
        .first = 68223,
        .last = 68223,
    },
    struct_interval{
        .first = 68336,
        .last = 68342,
    },
    struct_interval{
        .first = 68409,
        .last = 68415,
    },
    struct_interval{
        .first = 68505,
        .last = 68508,
    },
    struct_interval{
        .first = 69328,
        .last = 69328,
    },
    struct_interval{
        .first = 69461,
        .last = 69465,
    },
    struct_interval{
        .first = 69510,
        .last = 69513,
    },
    struct_interval{
        .first = 69703,
        .last = 69709,
    },
    struct_interval{
        .first = 69819,
        .last = 69820,
    },
    struct_interval{
        .first = 69822,
        .last = 69825,
    },
    struct_interval{
        .first = 69952,
        .last = 69955,
    },
    struct_interval{
        .first = 70004,
        .last = 70005,
    },
    struct_interval{
        .first = 70085,
        .last = 70088,
    },
    struct_interval{
        .first = 70093,
        .last = 70093,
    },
    struct_interval{
        .first = 70107,
        .last = 70107,
    },
    struct_interval{
        .first = 70109,
        .last = 70111,
    },
    struct_interval{
        .first = 70200,
        .last = 70205,
    },
    struct_interval{
        .first = 70313,
        .last = 70313,
    },
    struct_interval{
        .first = 70612,
        .last = 70613,
    },
    struct_interval{
        .first = 70615,
        .last = 70616,
    },
    struct_interval{
        .first = 70731,
        .last = 70735,
    },
    struct_interval{
        .first = 70746,
        .last = 70747,
    },
    struct_interval{
        .first = 70749,
        .last = 70749,
    },
    struct_interval{
        .first = 70854,
        .last = 70854,
    },
    struct_interval{
        .first = 71105,
        .last = 71127,
    },
    struct_interval{
        .first = 71233,
        .last = 71235,
    },
    struct_interval{
        .first = 71264,
        .last = 71276,
    },
    struct_interval{
        .first = 71353,
        .last = 71353,
    },
    struct_interval{
        .first = 71484,
        .last = 71486,
    },
    struct_interval{
        .first = 71739,
        .last = 71739,
    },
    struct_interval{
        .first = 72004,
        .last = 72006,
    },
    struct_interval{
        .first = 72162,
        .last = 72162,
    },
    struct_interval{
        .first = 72255,
        .last = 72262,
    },
    struct_interval{
        .first = 72346,
        .last = 72348,
    },
    struct_interval{
        .first = 72350,
        .last = 72354,
    },
    struct_interval{
        .first = 72448,
        .last = 72457,
    },
    struct_interval{
        .first = 72673,
        .last = 72673,
    },
    struct_interval{
        .first = 72769,
        .last = 72773,
    },
    struct_interval{
        .first = 72816,
        .last = 72817,
    },
    struct_interval{
        .first = 73463,
        .last = 73464,
    },
    struct_interval{
        .first = 73539,
        .last = 73551,
    },
    struct_interval{
        .first = 73727,
        .last = 73727,
    },
    struct_interval{
        .first = 74864,
        .last = 74868,
    },
    struct_interval{
        .first = 77809,
        .last = 77810,
    },
    struct_interval{
        .first = 92782,
        .last = 92783,
    },
    struct_interval{
        .first = 92917,
        .last = 92917,
    },
    struct_interval{
        .first = 92983,
        .last = 92987,
    },
    struct_interval{
        .first = 92996,
        .last = 92996,
    },
    struct_interval{
        .first = 93549,
        .last = 93551,
    },
    struct_interval{
        .first = 93847,
        .last = 93850,
    },
    struct_interval{
        .first = 94178,
        .last = 94178,
    },
    struct_interval{
        .first = 113823,
        .last = 113823,
    },
    struct_interval{
        .first = 121479,
        .last = 121483,
    },
    struct_interval{
        .first = 124415,
        .last = 124415,
    },
    struct_interval{
        .first = 125278,
        .last = 125279,
    },
};
pub export const Zs_table: [7]struct_interval = [7]struct_interval{
    struct_interval{
        .first = 32,
        .last = 32,
    },
    struct_interval{
        .first = 160,
        .last = 160,
    },
    struct_interval{
        .first = 5760,
        .last = 5760,
    },
    struct_interval{
        .first = 8192,
        .last = 8202,
    },
    struct_interval{
        .first = 8239,
        .last = 8239,
    },
    struct_interval{
        .first = 8287,
        .last = 8287,
    },
    struct_interval{
        .first = 12288,
        .last = 12288,
    },
};
pub export const Cc_table: [2]struct_interval = [2]struct_interval{
    struct_interval{
        .first = 0,
        .last = 31,
    },
    struct_interval{
        .first = 127,
        .last = 159,
    },
};
pub export const toupper_table: [695]struct_interval = [695]struct_interval{
    struct_interval{
        .first = 97,
        .last = 122,
    },
    struct_interval{
        .first = 181,
        .last = 181,
    },
    struct_interval{
        .first = 224,
        .last = 246,
    },
    struct_interval{
        .first = 248,
        .last = 254,
    },
    struct_interval{
        .first = 255,
        .last = 255,
    },
    struct_interval{
        .first = 257,
        .last = 257,
    },
    struct_interval{
        .first = 259,
        .last = 259,
    },
    struct_interval{
        .first = 261,
        .last = 261,
    },
    struct_interval{
        .first = 263,
        .last = 263,
    },
    struct_interval{
        .first = 265,
        .last = 265,
    },
    struct_interval{
        .first = 267,
        .last = 267,
    },
    struct_interval{
        .first = 269,
        .last = 269,
    },
    struct_interval{
        .first = 271,
        .last = 271,
    },
    struct_interval{
        .first = 273,
        .last = 273,
    },
    struct_interval{
        .first = 275,
        .last = 275,
    },
    struct_interval{
        .first = 277,
        .last = 277,
    },
    struct_interval{
        .first = 279,
        .last = 279,
    },
    struct_interval{
        .first = 281,
        .last = 281,
    },
    struct_interval{
        .first = 283,
        .last = 283,
    },
    struct_interval{
        .first = 285,
        .last = 285,
    },
    struct_interval{
        .first = 287,
        .last = 287,
    },
    struct_interval{
        .first = 289,
        .last = 289,
    },
    struct_interval{
        .first = 291,
        .last = 291,
    },
    struct_interval{
        .first = 293,
        .last = 293,
    },
    struct_interval{
        .first = 295,
        .last = 295,
    },
    struct_interval{
        .first = 297,
        .last = 297,
    },
    struct_interval{
        .first = 299,
        .last = 299,
    },
    struct_interval{
        .first = 301,
        .last = 301,
    },
    struct_interval{
        .first = 303,
        .last = 303,
    },
    struct_interval{
        .first = 305,
        .last = 305,
    },
    struct_interval{
        .first = 307,
        .last = 307,
    },
    struct_interval{
        .first = 309,
        .last = 309,
    },
    struct_interval{
        .first = 311,
        .last = 311,
    },
    struct_interval{
        .first = 314,
        .last = 314,
    },
    struct_interval{
        .first = 316,
        .last = 316,
    },
    struct_interval{
        .first = 318,
        .last = 318,
    },
    struct_interval{
        .first = 320,
        .last = 320,
    },
    struct_interval{
        .first = 322,
        .last = 322,
    },
    struct_interval{
        .first = 324,
        .last = 324,
    },
    struct_interval{
        .first = 326,
        .last = 326,
    },
    struct_interval{
        .first = 328,
        .last = 328,
    },
    struct_interval{
        .first = 331,
        .last = 331,
    },
    struct_interval{
        .first = 333,
        .last = 333,
    },
    struct_interval{
        .first = 335,
        .last = 335,
    },
    struct_interval{
        .first = 337,
        .last = 337,
    },
    struct_interval{
        .first = 339,
        .last = 339,
    },
    struct_interval{
        .first = 341,
        .last = 341,
    },
    struct_interval{
        .first = 343,
        .last = 343,
    },
    struct_interval{
        .first = 345,
        .last = 345,
    },
    struct_interval{
        .first = 347,
        .last = 347,
    },
    struct_interval{
        .first = 349,
        .last = 349,
    },
    struct_interval{
        .first = 351,
        .last = 351,
    },
    struct_interval{
        .first = 353,
        .last = 353,
    },
    struct_interval{
        .first = 355,
        .last = 355,
    },
    struct_interval{
        .first = 357,
        .last = 357,
    },
    struct_interval{
        .first = 359,
        .last = 359,
    },
    struct_interval{
        .first = 361,
        .last = 361,
    },
    struct_interval{
        .first = 363,
        .last = 363,
    },
    struct_interval{
        .first = 365,
        .last = 365,
    },
    struct_interval{
        .first = 367,
        .last = 367,
    },
    struct_interval{
        .first = 369,
        .last = 369,
    },
    struct_interval{
        .first = 371,
        .last = 371,
    },
    struct_interval{
        .first = 373,
        .last = 373,
    },
    struct_interval{
        .first = 375,
        .last = 375,
    },
    struct_interval{
        .first = 378,
        .last = 378,
    },
    struct_interval{
        .first = 380,
        .last = 380,
    },
    struct_interval{
        .first = 382,
        .last = 382,
    },
    struct_interval{
        .first = 383,
        .last = 383,
    },
    struct_interval{
        .first = 384,
        .last = 384,
    },
    struct_interval{
        .first = 387,
        .last = 387,
    },
    struct_interval{
        .first = 389,
        .last = 389,
    },
    struct_interval{
        .first = 392,
        .last = 392,
    },
    struct_interval{
        .first = 396,
        .last = 396,
    },
    struct_interval{
        .first = 402,
        .last = 402,
    },
    struct_interval{
        .first = 405,
        .last = 405,
    },
    struct_interval{
        .first = 409,
        .last = 409,
    },
    struct_interval{
        .first = 410,
        .last = 410,
    },
    struct_interval{
        .first = 411,
        .last = 411,
    },
    struct_interval{
        .first = 414,
        .last = 414,
    },
    struct_interval{
        .first = 417,
        .last = 417,
    },
    struct_interval{
        .first = 419,
        .last = 419,
    },
    struct_interval{
        .first = 421,
        .last = 421,
    },
    struct_interval{
        .first = 424,
        .last = 424,
    },
    struct_interval{
        .first = 429,
        .last = 429,
    },
    struct_interval{
        .first = 432,
        .last = 432,
    },
    struct_interval{
        .first = 436,
        .last = 436,
    },
    struct_interval{
        .first = 438,
        .last = 438,
    },
    struct_interval{
        .first = 441,
        .last = 441,
    },
    struct_interval{
        .first = 445,
        .last = 445,
    },
    struct_interval{
        .first = 447,
        .last = 447,
    },
    struct_interval{
        .first = 453,
        .last = 453,
    },
    struct_interval{
        .first = 454,
        .last = 454,
    },
    struct_interval{
        .first = 456,
        .last = 456,
    },
    struct_interval{
        .first = 457,
        .last = 457,
    },
    struct_interval{
        .first = 459,
        .last = 459,
    },
    struct_interval{
        .first = 460,
        .last = 460,
    },
    struct_interval{
        .first = 462,
        .last = 462,
    },
    struct_interval{
        .first = 464,
        .last = 464,
    },
    struct_interval{
        .first = 466,
        .last = 466,
    },
    struct_interval{
        .first = 468,
        .last = 468,
    },
    struct_interval{
        .first = 470,
        .last = 470,
    },
    struct_interval{
        .first = 472,
        .last = 472,
    },
    struct_interval{
        .first = 474,
        .last = 474,
    },
    struct_interval{
        .first = 476,
        .last = 476,
    },
    struct_interval{
        .first = 477,
        .last = 477,
    },
    struct_interval{
        .first = 479,
        .last = 479,
    },
    struct_interval{
        .first = 481,
        .last = 481,
    },
    struct_interval{
        .first = 483,
        .last = 483,
    },
    struct_interval{
        .first = 485,
        .last = 485,
    },
    struct_interval{
        .first = 487,
        .last = 487,
    },
    struct_interval{
        .first = 489,
        .last = 489,
    },
    struct_interval{
        .first = 491,
        .last = 491,
    },
    struct_interval{
        .first = 493,
        .last = 493,
    },
    struct_interval{
        .first = 495,
        .last = 495,
    },
    struct_interval{
        .first = 498,
        .last = 498,
    },
    struct_interval{
        .first = 499,
        .last = 499,
    },
    struct_interval{
        .first = 501,
        .last = 501,
    },
    struct_interval{
        .first = 505,
        .last = 505,
    },
    struct_interval{
        .first = 507,
        .last = 507,
    },
    struct_interval{
        .first = 509,
        .last = 509,
    },
    struct_interval{
        .first = 511,
        .last = 511,
    },
    struct_interval{
        .first = 513,
        .last = 513,
    },
    struct_interval{
        .first = 515,
        .last = 515,
    },
    struct_interval{
        .first = 517,
        .last = 517,
    },
    struct_interval{
        .first = 519,
        .last = 519,
    },
    struct_interval{
        .first = 521,
        .last = 521,
    },
    struct_interval{
        .first = 523,
        .last = 523,
    },
    struct_interval{
        .first = 525,
        .last = 525,
    },
    struct_interval{
        .first = 527,
        .last = 527,
    },
    struct_interval{
        .first = 529,
        .last = 529,
    },
    struct_interval{
        .first = 531,
        .last = 531,
    },
    struct_interval{
        .first = 533,
        .last = 533,
    },
    struct_interval{
        .first = 535,
        .last = 535,
    },
    struct_interval{
        .first = 537,
        .last = 537,
    },
    struct_interval{
        .first = 539,
        .last = 539,
    },
    struct_interval{
        .first = 541,
        .last = 541,
    },
    struct_interval{
        .first = 543,
        .last = 543,
    },
    struct_interval{
        .first = 547,
        .last = 547,
    },
    struct_interval{
        .first = 549,
        .last = 549,
    },
    struct_interval{
        .first = 551,
        .last = 551,
    },
    struct_interval{
        .first = 553,
        .last = 553,
    },
    struct_interval{
        .first = 555,
        .last = 555,
    },
    struct_interval{
        .first = 557,
        .last = 557,
    },
    struct_interval{
        .first = 559,
        .last = 559,
    },
    struct_interval{
        .first = 561,
        .last = 561,
    },
    struct_interval{
        .first = 563,
        .last = 563,
    },
    struct_interval{
        .first = 572,
        .last = 572,
    },
    struct_interval{
        .first = 575,
        .last = 576,
    },
    struct_interval{
        .first = 578,
        .last = 578,
    },
    struct_interval{
        .first = 583,
        .last = 583,
    },
    struct_interval{
        .first = 585,
        .last = 585,
    },
    struct_interval{
        .first = 587,
        .last = 587,
    },
    struct_interval{
        .first = 589,
        .last = 589,
    },
    struct_interval{
        .first = 591,
        .last = 591,
    },
    struct_interval{
        .first = 592,
        .last = 592,
    },
    struct_interval{
        .first = 593,
        .last = 593,
    },
    struct_interval{
        .first = 594,
        .last = 594,
    },
    struct_interval{
        .first = 595,
        .last = 595,
    },
    struct_interval{
        .first = 596,
        .last = 596,
    },
    struct_interval{
        .first = 598,
        .last = 599,
    },
    struct_interval{
        .first = 601,
        .last = 601,
    },
    struct_interval{
        .first = 603,
        .last = 603,
    },
    struct_interval{
        .first = 604,
        .last = 604,
    },
    struct_interval{
        .first = 608,
        .last = 608,
    },
    struct_interval{
        .first = 609,
        .last = 609,
    },
    struct_interval{
        .first = 611,
        .last = 611,
    },
    struct_interval{
        .first = 612,
        .last = 612,
    },
    struct_interval{
        .first = 613,
        .last = 613,
    },
    struct_interval{
        .first = 614,
        .last = 614,
    },
    struct_interval{
        .first = 616,
        .last = 616,
    },
    struct_interval{
        .first = 617,
        .last = 617,
    },
    struct_interval{
        .first = 618,
        .last = 618,
    },
    struct_interval{
        .first = 619,
        .last = 619,
    },
    struct_interval{
        .first = 620,
        .last = 620,
    },
    struct_interval{
        .first = 623,
        .last = 623,
    },
    struct_interval{
        .first = 625,
        .last = 625,
    },
    struct_interval{
        .first = 626,
        .last = 626,
    },
    struct_interval{
        .first = 629,
        .last = 629,
    },
    struct_interval{
        .first = 637,
        .last = 637,
    },
    struct_interval{
        .first = 640,
        .last = 640,
    },
    struct_interval{
        .first = 642,
        .last = 642,
    },
    struct_interval{
        .first = 643,
        .last = 643,
    },
    struct_interval{
        .first = 647,
        .last = 647,
    },
    struct_interval{
        .first = 648,
        .last = 648,
    },
    struct_interval{
        .first = 649,
        .last = 649,
    },
    struct_interval{
        .first = 650,
        .last = 651,
    },
    struct_interval{
        .first = 652,
        .last = 652,
    },
    struct_interval{
        .first = 658,
        .last = 658,
    },
    struct_interval{
        .first = 669,
        .last = 669,
    },
    struct_interval{
        .first = 670,
        .last = 670,
    },
    struct_interval{
        .first = 837,
        .last = 837,
    },
    struct_interval{
        .first = 881,
        .last = 881,
    },
    struct_interval{
        .first = 883,
        .last = 883,
    },
    struct_interval{
        .first = 887,
        .last = 887,
    },
    struct_interval{
        .first = 891,
        .last = 893,
    },
    struct_interval{
        .first = 940,
        .last = 940,
    },
    struct_interval{
        .first = 941,
        .last = 943,
    },
    struct_interval{
        .first = 945,
        .last = 961,
    },
    struct_interval{
        .first = 962,
        .last = 962,
    },
    struct_interval{
        .first = 963,
        .last = 971,
    },
    struct_interval{
        .first = 972,
        .last = 972,
    },
    struct_interval{
        .first = 973,
        .last = 974,
    },
    struct_interval{
        .first = 976,
        .last = 976,
    },
    struct_interval{
        .first = 977,
        .last = 977,
    },
    struct_interval{
        .first = 981,
        .last = 981,
    },
    struct_interval{
        .first = 982,
        .last = 982,
    },
    struct_interval{
        .first = 983,
        .last = 983,
    },
    struct_interval{
        .first = 985,
        .last = 985,
    },
    struct_interval{
        .first = 987,
        .last = 987,
    },
    struct_interval{
        .first = 989,
        .last = 989,
    },
    struct_interval{
        .first = 991,
        .last = 991,
    },
    struct_interval{
        .first = 993,
        .last = 993,
    },
    struct_interval{
        .first = 995,
        .last = 995,
    },
    struct_interval{
        .first = 997,
        .last = 997,
    },
    struct_interval{
        .first = 999,
        .last = 999,
    },
    struct_interval{
        .first = 1001,
        .last = 1001,
    },
    struct_interval{
        .first = 1003,
        .last = 1003,
    },
    struct_interval{
        .first = 1005,
        .last = 1005,
    },
    struct_interval{
        .first = 1007,
        .last = 1007,
    },
    struct_interval{
        .first = 1008,
        .last = 1008,
    },
    struct_interval{
        .first = 1009,
        .last = 1009,
    },
    struct_interval{
        .first = 1010,
        .last = 1010,
    },
    struct_interval{
        .first = 1011,
        .last = 1011,
    },
    struct_interval{
        .first = 1013,
        .last = 1013,
    },
    struct_interval{
        .first = 1016,
        .last = 1016,
    },
    struct_interval{
        .first = 1019,
        .last = 1019,
    },
    struct_interval{
        .first = 1072,
        .last = 1103,
    },
    struct_interval{
        .first = 1104,
        .last = 1119,
    },
    struct_interval{
        .first = 1121,
        .last = 1121,
    },
    struct_interval{
        .first = 1123,
        .last = 1123,
    },
    struct_interval{
        .first = 1125,
        .last = 1125,
    },
    struct_interval{
        .first = 1127,
        .last = 1127,
    },
    struct_interval{
        .first = 1129,
        .last = 1129,
    },
    struct_interval{
        .first = 1131,
        .last = 1131,
    },
    struct_interval{
        .first = 1133,
        .last = 1133,
    },
    struct_interval{
        .first = 1135,
        .last = 1135,
    },
    struct_interval{
        .first = 1137,
        .last = 1137,
    },
    struct_interval{
        .first = 1139,
        .last = 1139,
    },
    struct_interval{
        .first = 1141,
        .last = 1141,
    },
    struct_interval{
        .first = 1143,
        .last = 1143,
    },
    struct_interval{
        .first = 1145,
        .last = 1145,
    },
    struct_interval{
        .first = 1147,
        .last = 1147,
    },
    struct_interval{
        .first = 1149,
        .last = 1149,
    },
    struct_interval{
        .first = 1151,
        .last = 1151,
    },
    struct_interval{
        .first = 1153,
        .last = 1153,
    },
    struct_interval{
        .first = 1163,
        .last = 1163,
    },
    struct_interval{
        .first = 1165,
        .last = 1165,
    },
    struct_interval{
        .first = 1167,
        .last = 1167,
    },
    struct_interval{
        .first = 1169,
        .last = 1169,
    },
    struct_interval{
        .first = 1171,
        .last = 1171,
    },
    struct_interval{
        .first = 1173,
        .last = 1173,
    },
    struct_interval{
        .first = 1175,
        .last = 1175,
    },
    struct_interval{
        .first = 1177,
        .last = 1177,
    },
    struct_interval{
        .first = 1179,
        .last = 1179,
    },
    struct_interval{
        .first = 1181,
        .last = 1181,
    },
    struct_interval{
        .first = 1183,
        .last = 1183,
    },
    struct_interval{
        .first = 1185,
        .last = 1185,
    },
    struct_interval{
        .first = 1187,
        .last = 1187,
    },
    struct_interval{
        .first = 1189,
        .last = 1189,
    },
    struct_interval{
        .first = 1191,
        .last = 1191,
    },
    struct_interval{
        .first = 1193,
        .last = 1193,
    },
    struct_interval{
        .first = 1195,
        .last = 1195,
    },
    struct_interval{
        .first = 1197,
        .last = 1197,
    },
    struct_interval{
        .first = 1199,
        .last = 1199,
    },
    struct_interval{
        .first = 1201,
        .last = 1201,
    },
    struct_interval{
        .first = 1203,
        .last = 1203,
    },
    struct_interval{
        .first = 1205,
        .last = 1205,
    },
    struct_interval{
        .first = 1207,
        .last = 1207,
    },
    struct_interval{
        .first = 1209,
        .last = 1209,
    },
    struct_interval{
        .first = 1211,
        .last = 1211,
    },
    struct_interval{
        .first = 1213,
        .last = 1213,
    },
    struct_interval{
        .first = 1215,
        .last = 1215,
    },
    struct_interval{
        .first = 1218,
        .last = 1218,
    },
    struct_interval{
        .first = 1220,
        .last = 1220,
    },
    struct_interval{
        .first = 1222,
        .last = 1222,
    },
    struct_interval{
        .first = 1224,
        .last = 1224,
    },
    struct_interval{
        .first = 1226,
        .last = 1226,
    },
    struct_interval{
        .first = 1228,
        .last = 1228,
    },
    struct_interval{
        .first = 1230,
        .last = 1230,
    },
    struct_interval{
        .first = 1231,
        .last = 1231,
    },
    struct_interval{
        .first = 1233,
        .last = 1233,
    },
    struct_interval{
        .first = 1235,
        .last = 1235,
    },
    struct_interval{
        .first = 1237,
        .last = 1237,
    },
    struct_interval{
        .first = 1239,
        .last = 1239,
    },
    struct_interval{
        .first = 1241,
        .last = 1241,
    },
    struct_interval{
        .first = 1243,
        .last = 1243,
    },
    struct_interval{
        .first = 1245,
        .last = 1245,
    },
    struct_interval{
        .first = 1247,
        .last = 1247,
    },
    struct_interval{
        .first = 1249,
        .last = 1249,
    },
    struct_interval{
        .first = 1251,
        .last = 1251,
    },
    struct_interval{
        .first = 1253,
        .last = 1253,
    },
    struct_interval{
        .first = 1255,
        .last = 1255,
    },
    struct_interval{
        .first = 1257,
        .last = 1257,
    },
    struct_interval{
        .first = 1259,
        .last = 1259,
    },
    struct_interval{
        .first = 1261,
        .last = 1261,
    },
    struct_interval{
        .first = 1263,
        .last = 1263,
    },
    struct_interval{
        .first = 1265,
        .last = 1265,
    },
    struct_interval{
        .first = 1267,
        .last = 1267,
    },
    struct_interval{
        .first = 1269,
        .last = 1269,
    },
    struct_interval{
        .first = 1271,
        .last = 1271,
    },
    struct_interval{
        .first = 1273,
        .last = 1273,
    },
    struct_interval{
        .first = 1275,
        .last = 1275,
    },
    struct_interval{
        .first = 1277,
        .last = 1277,
    },
    struct_interval{
        .first = 1279,
        .last = 1279,
    },
    struct_interval{
        .first = 1281,
        .last = 1281,
    },
    struct_interval{
        .first = 1283,
        .last = 1283,
    },
    struct_interval{
        .first = 1285,
        .last = 1285,
    },
    struct_interval{
        .first = 1287,
        .last = 1287,
    },
    struct_interval{
        .first = 1289,
        .last = 1289,
    },
    struct_interval{
        .first = 1291,
        .last = 1291,
    },
    struct_interval{
        .first = 1293,
        .last = 1293,
    },
    struct_interval{
        .first = 1295,
        .last = 1295,
    },
    struct_interval{
        .first = 1297,
        .last = 1297,
    },
    struct_interval{
        .first = 1299,
        .last = 1299,
    },
    struct_interval{
        .first = 1301,
        .last = 1301,
    },
    struct_interval{
        .first = 1303,
        .last = 1303,
    },
    struct_interval{
        .first = 1305,
        .last = 1305,
    },
    struct_interval{
        .first = 1307,
        .last = 1307,
    },
    struct_interval{
        .first = 1309,
        .last = 1309,
    },
    struct_interval{
        .first = 1311,
        .last = 1311,
    },
    struct_interval{
        .first = 1313,
        .last = 1313,
    },
    struct_interval{
        .first = 1315,
        .last = 1315,
    },
    struct_interval{
        .first = 1317,
        .last = 1317,
    },
    struct_interval{
        .first = 1319,
        .last = 1319,
    },
    struct_interval{
        .first = 1321,
        .last = 1321,
    },
    struct_interval{
        .first = 1323,
        .last = 1323,
    },
    struct_interval{
        .first = 1325,
        .last = 1325,
    },
    struct_interval{
        .first = 1327,
        .last = 1327,
    },
    struct_interval{
        .first = 1377,
        .last = 1414,
    },
    struct_interval{
        .first = 4304,
        .last = 4346,
    },
    struct_interval{
        .first = 4349,
        .last = 4351,
    },
    struct_interval{
        .first = 5112,
        .last = 5117,
    },
    struct_interval{
        .first = 7296,
        .last = 7296,
    },
    struct_interval{
        .first = 7297,
        .last = 7297,
    },
    struct_interval{
        .first = 7298,
        .last = 7298,
    },
    struct_interval{
        .first = 7299,
        .last = 7300,
    },
    struct_interval{
        .first = 7301,
        .last = 7301,
    },
    struct_interval{
        .first = 7302,
        .last = 7302,
    },
    struct_interval{
        .first = 7303,
        .last = 7303,
    },
    struct_interval{
        .first = 7304,
        .last = 7304,
    },
    struct_interval{
        .first = 7306,
        .last = 7306,
    },
    struct_interval{
        .first = 7545,
        .last = 7545,
    },
    struct_interval{
        .first = 7549,
        .last = 7549,
    },
    struct_interval{
        .first = 7566,
        .last = 7566,
    },
    struct_interval{
        .first = 7681,
        .last = 7681,
    },
    struct_interval{
        .first = 7683,
        .last = 7683,
    },
    struct_interval{
        .first = 7685,
        .last = 7685,
    },
    struct_interval{
        .first = 7687,
        .last = 7687,
    },
    struct_interval{
        .first = 7689,
        .last = 7689,
    },
    struct_interval{
        .first = 7691,
        .last = 7691,
    },
    struct_interval{
        .first = 7693,
        .last = 7693,
    },
    struct_interval{
        .first = 7695,
        .last = 7695,
    },
    struct_interval{
        .first = 7697,
        .last = 7697,
    },
    struct_interval{
        .first = 7699,
        .last = 7699,
    },
    struct_interval{
        .first = 7701,
        .last = 7701,
    },
    struct_interval{
        .first = 7703,
        .last = 7703,
    },
    struct_interval{
        .first = 7705,
        .last = 7705,
    },
    struct_interval{
        .first = 7707,
        .last = 7707,
    },
    struct_interval{
        .first = 7709,
        .last = 7709,
    },
    struct_interval{
        .first = 7711,
        .last = 7711,
    },
    struct_interval{
        .first = 7713,
        .last = 7713,
    },
    struct_interval{
        .first = 7715,
        .last = 7715,
    },
    struct_interval{
        .first = 7717,
        .last = 7717,
    },
    struct_interval{
        .first = 7719,
        .last = 7719,
    },
    struct_interval{
        .first = 7721,
        .last = 7721,
    },
    struct_interval{
        .first = 7723,
        .last = 7723,
    },
    struct_interval{
        .first = 7725,
        .last = 7725,
    },
    struct_interval{
        .first = 7727,
        .last = 7727,
    },
    struct_interval{
        .first = 7729,
        .last = 7729,
    },
    struct_interval{
        .first = 7731,
        .last = 7731,
    },
    struct_interval{
        .first = 7733,
        .last = 7733,
    },
    struct_interval{
        .first = 7735,
        .last = 7735,
    },
    struct_interval{
        .first = 7737,
        .last = 7737,
    },
    struct_interval{
        .first = 7739,
        .last = 7739,
    },
    struct_interval{
        .first = 7741,
        .last = 7741,
    },
    struct_interval{
        .first = 7743,
        .last = 7743,
    },
    struct_interval{
        .first = 7745,
        .last = 7745,
    },
    struct_interval{
        .first = 7747,
        .last = 7747,
    },
    struct_interval{
        .first = 7749,
        .last = 7749,
    },
    struct_interval{
        .first = 7751,
        .last = 7751,
    },
    struct_interval{
        .first = 7753,
        .last = 7753,
    },
    struct_interval{
        .first = 7755,
        .last = 7755,
    },
    struct_interval{
        .first = 7757,
        .last = 7757,
    },
    struct_interval{
        .first = 7759,
        .last = 7759,
    },
    struct_interval{
        .first = 7761,
        .last = 7761,
    },
    struct_interval{
        .first = 7763,
        .last = 7763,
    },
    struct_interval{
        .first = 7765,
        .last = 7765,
    },
    struct_interval{
        .first = 7767,
        .last = 7767,
    },
    struct_interval{
        .first = 7769,
        .last = 7769,
    },
    struct_interval{
        .first = 7771,
        .last = 7771,
    },
    struct_interval{
        .first = 7773,
        .last = 7773,
    },
    struct_interval{
        .first = 7775,
        .last = 7775,
    },
    struct_interval{
        .first = 7777,
        .last = 7777,
    },
    struct_interval{
        .first = 7779,
        .last = 7779,
    },
    struct_interval{
        .first = 7781,
        .last = 7781,
    },
    struct_interval{
        .first = 7783,
        .last = 7783,
    },
    struct_interval{
        .first = 7785,
        .last = 7785,
    },
    struct_interval{
        .first = 7787,
        .last = 7787,
    },
    struct_interval{
        .first = 7789,
        .last = 7789,
    },
    struct_interval{
        .first = 7791,
        .last = 7791,
    },
    struct_interval{
        .first = 7793,
        .last = 7793,
    },
    struct_interval{
        .first = 7795,
        .last = 7795,
    },
    struct_interval{
        .first = 7797,
        .last = 7797,
    },
    struct_interval{
        .first = 7799,
        .last = 7799,
    },
    struct_interval{
        .first = 7801,
        .last = 7801,
    },
    struct_interval{
        .first = 7803,
        .last = 7803,
    },
    struct_interval{
        .first = 7805,
        .last = 7805,
    },
    struct_interval{
        .first = 7807,
        .last = 7807,
    },
    struct_interval{
        .first = 7809,
        .last = 7809,
    },
    struct_interval{
        .first = 7811,
        .last = 7811,
    },
    struct_interval{
        .first = 7813,
        .last = 7813,
    },
    struct_interval{
        .first = 7815,
        .last = 7815,
    },
    struct_interval{
        .first = 7817,
        .last = 7817,
    },
    struct_interval{
        .first = 7819,
        .last = 7819,
    },
    struct_interval{
        .first = 7821,
        .last = 7821,
    },
    struct_interval{
        .first = 7823,
        .last = 7823,
    },
    struct_interval{
        .first = 7825,
        .last = 7825,
    },
    struct_interval{
        .first = 7827,
        .last = 7827,
    },
    struct_interval{
        .first = 7829,
        .last = 7829,
    },
    struct_interval{
        .first = 7835,
        .last = 7835,
    },
    struct_interval{
        .first = 7841,
        .last = 7841,
    },
    struct_interval{
        .first = 7843,
        .last = 7843,
    },
    struct_interval{
        .first = 7845,
        .last = 7845,
    },
    struct_interval{
        .first = 7847,
        .last = 7847,
    },
    struct_interval{
        .first = 7849,
        .last = 7849,
    },
    struct_interval{
        .first = 7851,
        .last = 7851,
    },
    struct_interval{
        .first = 7853,
        .last = 7853,
    },
    struct_interval{
        .first = 7855,
        .last = 7855,
    },
    struct_interval{
        .first = 7857,
        .last = 7857,
    },
    struct_interval{
        .first = 7859,
        .last = 7859,
    },
    struct_interval{
        .first = 7861,
        .last = 7861,
    },
    struct_interval{
        .first = 7863,
        .last = 7863,
    },
    struct_interval{
        .first = 7865,
        .last = 7865,
    },
    struct_interval{
        .first = 7867,
        .last = 7867,
    },
    struct_interval{
        .first = 7869,
        .last = 7869,
    },
    struct_interval{
        .first = 7871,
        .last = 7871,
    },
    struct_interval{
        .first = 7873,
        .last = 7873,
    },
    struct_interval{
        .first = 7875,
        .last = 7875,
    },
    struct_interval{
        .first = 7877,
        .last = 7877,
    },
    struct_interval{
        .first = 7879,
        .last = 7879,
    },
    struct_interval{
        .first = 7881,
        .last = 7881,
    },
    struct_interval{
        .first = 7883,
        .last = 7883,
    },
    struct_interval{
        .first = 7885,
        .last = 7885,
    },
    struct_interval{
        .first = 7887,
        .last = 7887,
    },
    struct_interval{
        .first = 7889,
        .last = 7889,
    },
    struct_interval{
        .first = 7891,
        .last = 7891,
    },
    struct_interval{
        .first = 7893,
        .last = 7893,
    },
    struct_interval{
        .first = 7895,
        .last = 7895,
    },
    struct_interval{
        .first = 7897,
        .last = 7897,
    },
    struct_interval{
        .first = 7899,
        .last = 7899,
    },
    struct_interval{
        .first = 7901,
        .last = 7901,
    },
    struct_interval{
        .first = 7903,
        .last = 7903,
    },
    struct_interval{
        .first = 7905,
        .last = 7905,
    },
    struct_interval{
        .first = 7907,
        .last = 7907,
    },
    struct_interval{
        .first = 7909,
        .last = 7909,
    },
    struct_interval{
        .first = 7911,
        .last = 7911,
    },
    struct_interval{
        .first = 7913,
        .last = 7913,
    },
    struct_interval{
        .first = 7915,
        .last = 7915,
    },
    struct_interval{
        .first = 7917,
        .last = 7917,
    },
    struct_interval{
        .first = 7919,
        .last = 7919,
    },
    struct_interval{
        .first = 7921,
        .last = 7921,
    },
    struct_interval{
        .first = 7923,
        .last = 7923,
    },
    struct_interval{
        .first = 7925,
        .last = 7925,
    },
    struct_interval{
        .first = 7927,
        .last = 7927,
    },
    struct_interval{
        .first = 7929,
        .last = 7929,
    },
    struct_interval{
        .first = 7931,
        .last = 7931,
    },
    struct_interval{
        .first = 7933,
        .last = 7933,
    },
    struct_interval{
        .first = 7935,
        .last = 7935,
    },
    struct_interval{
        .first = 7936,
        .last = 7943,
    },
    struct_interval{
        .first = 7952,
        .last = 7957,
    },
    struct_interval{
        .first = 7968,
        .last = 7975,
    },
    struct_interval{
        .first = 7984,
        .last = 7991,
    },
    struct_interval{
        .first = 8000,
        .last = 8005,
    },
    struct_interval{
        .first = 8017,
        .last = 8017,
    },
    struct_interval{
        .first = 8019,
        .last = 8019,
    },
    struct_interval{
        .first = 8021,
        .last = 8021,
    },
    struct_interval{
        .first = 8023,
        .last = 8023,
    },
    struct_interval{
        .first = 8032,
        .last = 8039,
    },
    struct_interval{
        .first = 8048,
        .last = 8049,
    },
    struct_interval{
        .first = 8050,
        .last = 8053,
    },
    struct_interval{
        .first = 8054,
        .last = 8055,
    },
    struct_interval{
        .first = 8056,
        .last = 8057,
    },
    struct_interval{
        .first = 8058,
        .last = 8059,
    },
    struct_interval{
        .first = 8060,
        .last = 8061,
    },
    struct_interval{
        .first = 8064,
        .last = 8071,
    },
    struct_interval{
        .first = 8080,
        .last = 8087,
    },
    struct_interval{
        .first = 8096,
        .last = 8103,
    },
    struct_interval{
        .first = 8112,
        .last = 8113,
    },
    struct_interval{
        .first = 8115,
        .last = 8115,
    },
    struct_interval{
        .first = 8126,
        .last = 8126,
    },
    struct_interval{
        .first = 8131,
        .last = 8131,
    },
    struct_interval{
        .first = 8144,
        .last = 8145,
    },
    struct_interval{
        .first = 8160,
        .last = 8161,
    },
    struct_interval{
        .first = 8165,
        .last = 8165,
    },
    struct_interval{
        .first = 8179,
        .last = 8179,
    },
    struct_interval{
        .first = 8526,
        .last = 8526,
    },
    struct_interval{
        .first = 8560,
        .last = 8575,
    },
    struct_interval{
        .first = 8580,
        .last = 8580,
    },
    struct_interval{
        .first = 9424,
        .last = 9449,
    },
    struct_interval{
        .first = 11312,
        .last = 11359,
    },
    struct_interval{
        .first = 11361,
        .last = 11361,
    },
    struct_interval{
        .first = 11365,
        .last = 11365,
    },
    struct_interval{
        .first = 11366,
        .last = 11366,
    },
    struct_interval{
        .first = 11368,
        .last = 11368,
    },
    struct_interval{
        .first = 11370,
        .last = 11370,
    },
    struct_interval{
        .first = 11372,
        .last = 11372,
    },
    struct_interval{
        .first = 11379,
        .last = 11379,
    },
    struct_interval{
        .first = 11382,
        .last = 11382,
    },
    struct_interval{
        .first = 11393,
        .last = 11393,
    },
    struct_interval{
        .first = 11395,
        .last = 11395,
    },
    struct_interval{
        .first = 11397,
        .last = 11397,
    },
    struct_interval{
        .first = 11399,
        .last = 11399,
    },
    struct_interval{
        .first = 11401,
        .last = 11401,
    },
    struct_interval{
        .first = 11403,
        .last = 11403,
    },
    struct_interval{
        .first = 11405,
        .last = 11405,
    },
    struct_interval{
        .first = 11407,
        .last = 11407,
    },
    struct_interval{
        .first = 11409,
        .last = 11409,
    },
    struct_interval{
        .first = 11411,
        .last = 11411,
    },
    struct_interval{
        .first = 11413,
        .last = 11413,
    },
    struct_interval{
        .first = 11415,
        .last = 11415,
    },
    struct_interval{
        .first = 11417,
        .last = 11417,
    },
    struct_interval{
        .first = 11419,
        .last = 11419,
    },
    struct_interval{
        .first = 11421,
        .last = 11421,
    },
    struct_interval{
        .first = 11423,
        .last = 11423,
    },
    struct_interval{
        .first = 11425,
        .last = 11425,
    },
    struct_interval{
        .first = 11427,
        .last = 11427,
    },
    struct_interval{
        .first = 11429,
        .last = 11429,
    },
    struct_interval{
        .first = 11431,
        .last = 11431,
    },
    struct_interval{
        .first = 11433,
        .last = 11433,
    },
    struct_interval{
        .first = 11435,
        .last = 11435,
    },
    struct_interval{
        .first = 11437,
        .last = 11437,
    },
    struct_interval{
        .first = 11439,
        .last = 11439,
    },
    struct_interval{
        .first = 11441,
        .last = 11441,
    },
    struct_interval{
        .first = 11443,
        .last = 11443,
    },
    struct_interval{
        .first = 11445,
        .last = 11445,
    },
    struct_interval{
        .first = 11447,
        .last = 11447,
    },
    struct_interval{
        .first = 11449,
        .last = 11449,
    },
    struct_interval{
        .first = 11451,
        .last = 11451,
    },
    struct_interval{
        .first = 11453,
        .last = 11453,
    },
    struct_interval{
        .first = 11455,
        .last = 11455,
    },
    struct_interval{
        .first = 11457,
        .last = 11457,
    },
    struct_interval{
        .first = 11459,
        .last = 11459,
    },
    struct_interval{
        .first = 11461,
        .last = 11461,
    },
    struct_interval{
        .first = 11463,
        .last = 11463,
    },
    struct_interval{
        .first = 11465,
        .last = 11465,
    },
    struct_interval{
        .first = 11467,
        .last = 11467,
    },
    struct_interval{
        .first = 11469,
        .last = 11469,
    },
    struct_interval{
        .first = 11471,
        .last = 11471,
    },
    struct_interval{
        .first = 11473,
        .last = 11473,
    },
    struct_interval{
        .first = 11475,
        .last = 11475,
    },
    struct_interval{
        .first = 11477,
        .last = 11477,
    },
    struct_interval{
        .first = 11479,
        .last = 11479,
    },
    struct_interval{
        .first = 11481,
        .last = 11481,
    },
    struct_interval{
        .first = 11483,
        .last = 11483,
    },
    struct_interval{
        .first = 11485,
        .last = 11485,
    },
    struct_interval{
        .first = 11487,
        .last = 11487,
    },
    struct_interval{
        .first = 11489,
        .last = 11489,
    },
    struct_interval{
        .first = 11491,
        .last = 11491,
    },
    struct_interval{
        .first = 11500,
        .last = 11500,
    },
    struct_interval{
        .first = 11502,
        .last = 11502,
    },
    struct_interval{
        .first = 11507,
        .last = 11507,
    },
    struct_interval{
        .first = 11520,
        .last = 11557,
    },
    struct_interval{
        .first = 11559,
        .last = 11559,
    },
    struct_interval{
        .first = 11565,
        .last = 11565,
    },
    struct_interval{
        .first = 42561,
        .last = 42561,
    },
    struct_interval{
        .first = 42563,
        .last = 42563,
    },
    struct_interval{
        .first = 42565,
        .last = 42565,
    },
    struct_interval{
        .first = 42567,
        .last = 42567,
    },
    struct_interval{
        .first = 42569,
        .last = 42569,
    },
    struct_interval{
        .first = 42571,
        .last = 42571,
    },
    struct_interval{
        .first = 42573,
        .last = 42573,
    },
    struct_interval{
        .first = 42575,
        .last = 42575,
    },
    struct_interval{
        .first = 42577,
        .last = 42577,
    },
    struct_interval{
        .first = 42579,
        .last = 42579,
    },
    struct_interval{
        .first = 42581,
        .last = 42581,
    },
    struct_interval{
        .first = 42583,
        .last = 42583,
    },
    struct_interval{
        .first = 42585,
        .last = 42585,
    },
    struct_interval{
        .first = 42587,
        .last = 42587,
    },
    struct_interval{
        .first = 42589,
        .last = 42589,
    },
    struct_interval{
        .first = 42591,
        .last = 42591,
    },
    struct_interval{
        .first = 42593,
        .last = 42593,
    },
    struct_interval{
        .first = 42595,
        .last = 42595,
    },
    struct_interval{
        .first = 42597,
        .last = 42597,
    },
    struct_interval{
        .first = 42599,
        .last = 42599,
    },
    struct_interval{
        .first = 42601,
        .last = 42601,
    },
    struct_interval{
        .first = 42603,
        .last = 42603,
    },
    struct_interval{
        .first = 42605,
        .last = 42605,
    },
    struct_interval{
        .first = 42625,
        .last = 42625,
    },
    struct_interval{
        .first = 42627,
        .last = 42627,
    },
    struct_interval{
        .first = 42629,
        .last = 42629,
    },
    struct_interval{
        .first = 42631,
        .last = 42631,
    },
    struct_interval{
        .first = 42633,
        .last = 42633,
    },
    struct_interval{
        .first = 42635,
        .last = 42635,
    },
    struct_interval{
        .first = 42637,
        .last = 42637,
    },
    struct_interval{
        .first = 42639,
        .last = 42639,
    },
    struct_interval{
        .first = 42641,
        .last = 42641,
    },
    struct_interval{
        .first = 42643,
        .last = 42643,
    },
    struct_interval{
        .first = 42645,
        .last = 42645,
    },
    struct_interval{
        .first = 42647,
        .last = 42647,
    },
    struct_interval{
        .first = 42649,
        .last = 42649,
    },
    struct_interval{
        .first = 42651,
        .last = 42651,
    },
    struct_interval{
        .first = 42787,
        .last = 42787,
    },
    struct_interval{
        .first = 42789,
        .last = 42789,
    },
    struct_interval{
        .first = 42791,
        .last = 42791,
    },
    struct_interval{
        .first = 42793,
        .last = 42793,
    },
    struct_interval{
        .first = 42795,
        .last = 42795,
    },
    struct_interval{
        .first = 42797,
        .last = 42797,
    },
    struct_interval{
        .first = 42799,
        .last = 42799,
    },
    struct_interval{
        .first = 42803,
        .last = 42803,
    },
    struct_interval{
        .first = 42805,
        .last = 42805,
    },
    struct_interval{
        .first = 42807,
        .last = 42807,
    },
    struct_interval{
        .first = 42809,
        .last = 42809,
    },
    struct_interval{
        .first = 42811,
        .last = 42811,
    },
    struct_interval{
        .first = 42813,
        .last = 42813,
    },
    struct_interval{
        .first = 42815,
        .last = 42815,
    },
    struct_interval{
        .first = 42817,
        .last = 42817,
    },
    struct_interval{
        .first = 42819,
        .last = 42819,
    },
    struct_interval{
        .first = 42821,
        .last = 42821,
    },
    struct_interval{
        .first = 42823,
        .last = 42823,
    },
    struct_interval{
        .first = 42825,
        .last = 42825,
    },
    struct_interval{
        .first = 42827,
        .last = 42827,
    },
    struct_interval{
        .first = 42829,
        .last = 42829,
    },
    struct_interval{
        .first = 42831,
        .last = 42831,
    },
    struct_interval{
        .first = 42833,
        .last = 42833,
    },
    struct_interval{
        .first = 42835,
        .last = 42835,
    },
    struct_interval{
        .first = 42837,
        .last = 42837,
    },
    struct_interval{
        .first = 42839,
        .last = 42839,
    },
    struct_interval{
        .first = 42841,
        .last = 42841,
    },
    struct_interval{
        .first = 42843,
        .last = 42843,
    },
    struct_interval{
        .first = 42845,
        .last = 42845,
    },
    struct_interval{
        .first = 42847,
        .last = 42847,
    },
    struct_interval{
        .first = 42849,
        .last = 42849,
    },
    struct_interval{
        .first = 42851,
        .last = 42851,
    },
    struct_interval{
        .first = 42853,
        .last = 42853,
    },
    struct_interval{
        .first = 42855,
        .last = 42855,
    },
    struct_interval{
        .first = 42857,
        .last = 42857,
    },
    struct_interval{
        .first = 42859,
        .last = 42859,
    },
    struct_interval{
        .first = 42861,
        .last = 42861,
    },
    struct_interval{
        .first = 42863,
        .last = 42863,
    },
    struct_interval{
        .first = 42874,
        .last = 42874,
    },
    struct_interval{
        .first = 42876,
        .last = 42876,
    },
    struct_interval{
        .first = 42879,
        .last = 42879,
    },
    struct_interval{
        .first = 42881,
        .last = 42881,
    },
    struct_interval{
        .first = 42883,
        .last = 42883,
    },
    struct_interval{
        .first = 42885,
        .last = 42885,
    },
    struct_interval{
        .first = 42887,
        .last = 42887,
    },
    struct_interval{
        .first = 42892,
        .last = 42892,
    },
    struct_interval{
        .first = 42897,
        .last = 42897,
    },
    struct_interval{
        .first = 42899,
        .last = 42899,
    },
    struct_interval{
        .first = 42900,
        .last = 42900,
    },
    struct_interval{
        .first = 42903,
        .last = 42903,
    },
    struct_interval{
        .first = 42905,
        .last = 42905,
    },
    struct_interval{
        .first = 42907,
        .last = 42907,
    },
    struct_interval{
        .first = 42909,
        .last = 42909,
    },
    struct_interval{
        .first = 42911,
        .last = 42911,
    },
    struct_interval{
        .first = 42913,
        .last = 42913,
    },
    struct_interval{
        .first = 42915,
        .last = 42915,
    },
    struct_interval{
        .first = 42917,
        .last = 42917,
    },
    struct_interval{
        .first = 42919,
        .last = 42919,
    },
    struct_interval{
        .first = 42921,
        .last = 42921,
    },
    struct_interval{
        .first = 42933,
        .last = 42933,
    },
    struct_interval{
        .first = 42935,
        .last = 42935,
    },
    struct_interval{
        .first = 42937,
        .last = 42937,
    },
    struct_interval{
        .first = 42939,
        .last = 42939,
    },
    struct_interval{
        .first = 42941,
        .last = 42941,
    },
    struct_interval{
        .first = 42943,
        .last = 42943,
    },
    struct_interval{
        .first = 42945,
        .last = 42945,
    },
    struct_interval{
        .first = 42947,
        .last = 42947,
    },
    struct_interval{
        .first = 42952,
        .last = 42952,
    },
    struct_interval{
        .first = 42954,
        .last = 42954,
    },
    struct_interval{
        .first = 42957,
        .last = 42957,
    },
    struct_interval{
        .first = 42959,
        .last = 42959,
    },
    struct_interval{
        .first = 42961,
        .last = 42961,
    },
    struct_interval{
        .first = 42963,
        .last = 42963,
    },
    struct_interval{
        .first = 42965,
        .last = 42965,
    },
    struct_interval{
        .first = 42967,
        .last = 42967,
    },
    struct_interval{
        .first = 42969,
        .last = 42969,
    },
    struct_interval{
        .first = 42971,
        .last = 42971,
    },
    struct_interval{
        .first = 42998,
        .last = 42998,
    },
    struct_interval{
        .first = 43859,
        .last = 43859,
    },
    struct_interval{
        .first = 43888,
        .last = 43967,
    },
    struct_interval{
        .first = 65345,
        .last = 65370,
    },
    struct_interval{
        .first = 66600,
        .last = 66639,
    },
    struct_interval{
        .first = 66776,
        .last = 66811,
    },
    struct_interval{
        .first = 66967,
        .last = 66977,
    },
    struct_interval{
        .first = 66979,
        .last = 66993,
    },
    struct_interval{
        .first = 66995,
        .last = 67001,
    },
    struct_interval{
        .first = 67003,
        .last = 67004,
    },
    struct_interval{
        .first = 68800,
        .last = 68850,
    },
    struct_interval{
        .first = 68976,
        .last = 68997,
    },
    struct_interval{
        .first = 71872,
        .last = 71903,
    },
    struct_interval{
        .first = 93792,
        .last = 93823,
    },
    struct_interval{
        .first = 93883,
        .last = 93907,
    },
    struct_interval{
        .first = 125218,
        .last = 125251,
    },
    struct_interval{
        .first = 0,
        .last = 0,
    },
};
pub export const toupper_cvt: [695]c_int = [695]c_int{
    65,
    924,
    192,
    216,
    376,
    256,
    258,
    260,
    262,
    264,
    266,
    268,
    270,
    272,
    274,
    276,
    278,
    280,
    282,
    284,
    286,
    288,
    290,
    292,
    294,
    296,
    298,
    300,
    302,
    73,
    306,
    308,
    310,
    313,
    315,
    317,
    319,
    321,
    323,
    325,
    327,
    330,
    332,
    334,
    336,
    338,
    340,
    342,
    344,
    346,
    348,
    350,
    352,
    354,
    356,
    358,
    360,
    362,
    364,
    366,
    368,
    370,
    372,
    374,
    377,
    379,
    381,
    83,
    579,
    386,
    388,
    391,
    395,
    401,
    502,
    408,
    573,
    42972,
    544,
    416,
    418,
    420,
    423,
    428,
    431,
    435,
    437,
    440,
    444,
    503,
    452,
    452,
    455,
    455,
    458,
    458,
    461,
    463,
    465,
    467,
    469,
    471,
    473,
    475,
    398,
    478,
    480,
    482,
    484,
    486,
    488,
    490,
    492,
    494,
    497,
    497,
    500,
    504,
    506,
    508,
    510,
    512,
    514,
    516,
    518,
    520,
    522,
    524,
    526,
    528,
    530,
    532,
    534,
    536,
    538,
    540,
    542,
    546,
    548,
    550,
    552,
    554,
    556,
    558,
    560,
    562,
    571,
    11390,
    577,
    582,
    584,
    586,
    588,
    590,
    11375,
    11373,
    11376,
    385,
    390,
    393,
    399,
    400,
    42923,
    403,
    42924,
    404,
    42955,
    42893,
    42922,
    407,
    406,
    42926,
    11362,
    42925,
    412,
    11374,
    413,
    415,
    11364,
    422,
    42949,
    425,
    42929,
    430,
    580,
    433,
    581,
    439,
    42930,
    42928,
    921,
    880,
    882,
    886,
    1021,
    902,
    904,
    913,
    931,
    931,
    908,
    910,
    914,
    920,
    934,
    928,
    975,
    984,
    986,
    988,
    990,
    992,
    994,
    996,
    998,
    1000,
    1002,
    1004,
    1006,
    922,
    929,
    1017,
    895,
    917,
    1015,
    1018,
    1040,
    1024,
    1120,
    1122,
    1124,
    1126,
    1128,
    1130,
    1132,
    1134,
    1136,
    1138,
    1140,
    1142,
    1144,
    1146,
    1148,
    1150,
    1152,
    1162,
    1164,
    1166,
    1168,
    1170,
    1172,
    1174,
    1176,
    1178,
    1180,
    1182,
    1184,
    1186,
    1188,
    1190,
    1192,
    1194,
    1196,
    1198,
    1200,
    1202,
    1204,
    1206,
    1208,
    1210,
    1212,
    1214,
    1217,
    1219,
    1221,
    1223,
    1225,
    1227,
    1229,
    1216,
    1232,
    1234,
    1236,
    1238,
    1240,
    1242,
    1244,
    1246,
    1248,
    1250,
    1252,
    1254,
    1256,
    1258,
    1260,
    1262,
    1264,
    1266,
    1268,
    1270,
    1272,
    1274,
    1276,
    1278,
    1280,
    1282,
    1284,
    1286,
    1288,
    1290,
    1292,
    1294,
    1296,
    1298,
    1300,
    1302,
    1304,
    1306,
    1308,
    1310,
    1312,
    1314,
    1316,
    1318,
    1320,
    1322,
    1324,
    1326,
    1329,
    7312,
    7357,
    5104,
    1042,
    1044,
    1054,
    1057,
    1058,
    1066,
    1122,
    42570,
    7305,
    42877,
    11363,
    42950,
    7680,
    7682,
    7684,
    7686,
    7688,
    7690,
    7692,
    7694,
    7696,
    7698,
    7700,
    7702,
    7704,
    7706,
    7708,
    7710,
    7712,
    7714,
    7716,
    7718,
    7720,
    7722,
    7724,
    7726,
    7728,
    7730,
    7732,
    7734,
    7736,
    7738,
    7740,
    7742,
    7744,
    7746,
    7748,
    7750,
    7752,
    7754,
    7756,
    7758,
    7760,
    7762,
    7764,
    7766,
    7768,
    7770,
    7772,
    7774,
    7776,
    7778,
    7780,
    7782,
    7784,
    7786,
    7788,
    7790,
    7792,
    7794,
    7796,
    7798,
    7800,
    7802,
    7804,
    7806,
    7808,
    7810,
    7812,
    7814,
    7816,
    7818,
    7820,
    7822,
    7824,
    7826,
    7828,
    7776,
    7840,
    7842,
    7844,
    7846,
    7848,
    7850,
    7852,
    7854,
    7856,
    7858,
    7860,
    7862,
    7864,
    7866,
    7868,
    7870,
    7872,
    7874,
    7876,
    7878,
    7880,
    7882,
    7884,
    7886,
    7888,
    7890,
    7892,
    7894,
    7896,
    7898,
    7900,
    7902,
    7904,
    7906,
    7908,
    7910,
    7912,
    7914,
    7916,
    7918,
    7920,
    7922,
    7924,
    7926,
    7928,
    7930,
    7932,
    7934,
    7944,
    7960,
    7976,
    7992,
    8008,
    8025,
    8027,
    8029,
    8031,
    8040,
    8122,
    8136,
    8154,
    8184,
    8170,
    8186,
    8072,
    8088,
    8104,
    8120,
    8124,
    921,
    8140,
    8152,
    8168,
    8172,
    8188,
    8498,
    8544,
    8579,
    9398,
    11264,
    11360,
    570,
    574,
    11367,
    11369,
    11371,
    11378,
    11381,
    11392,
    11394,
    11396,
    11398,
    11400,
    11402,
    11404,
    11406,
    11408,
    11410,
    11412,
    11414,
    11416,
    11418,
    11420,
    11422,
    11424,
    11426,
    11428,
    11430,
    11432,
    11434,
    11436,
    11438,
    11440,
    11442,
    11444,
    11446,
    11448,
    11450,
    11452,
    11454,
    11456,
    11458,
    11460,
    11462,
    11464,
    11466,
    11468,
    11470,
    11472,
    11474,
    11476,
    11478,
    11480,
    11482,
    11484,
    11486,
    11488,
    11490,
    11499,
    11501,
    11506,
    4256,
    4295,
    4301,
    42560,
    42562,
    42564,
    42566,
    42568,
    42570,
    42572,
    42574,
    42576,
    42578,
    42580,
    42582,
    42584,
    42586,
    42588,
    42590,
    42592,
    42594,
    42596,
    42598,
    42600,
    42602,
    42604,
    42624,
    42626,
    42628,
    42630,
    42632,
    42634,
    42636,
    42638,
    42640,
    42642,
    42644,
    42646,
    42648,
    42650,
    42786,
    42788,
    42790,
    42792,
    42794,
    42796,
    42798,
    42802,
    42804,
    42806,
    42808,
    42810,
    42812,
    42814,
    42816,
    42818,
    42820,
    42822,
    42824,
    42826,
    42828,
    42830,
    42832,
    42834,
    42836,
    42838,
    42840,
    42842,
    42844,
    42846,
    42848,
    42850,
    42852,
    42854,
    42856,
    42858,
    42860,
    42862,
    42873,
    42875,
    42878,
    42880,
    42882,
    42884,
    42886,
    42891,
    42896,
    42898,
    42948,
    42902,
    42904,
    42906,
    42908,
    42910,
    42912,
    42914,
    42916,
    42918,
    42920,
    42932,
    42934,
    42936,
    42938,
    42940,
    42942,
    42944,
    42946,
    42951,
    42953,
    42956,
    42958,
    42960,
    42962,
    42964,
    42966,
    42968,
    42970,
    42997,
    42931,
    5024,
    65313,
    66560,
    66736,
    66928,
    66940,
    66956,
    66964,
    68736,
    68944,
    71840,
    93760,
    93856,
    125184,
    0,
};
pub export const tolower_table: [679]struct_interval = [679]struct_interval{
    struct_interval{
        .first = 65,
        .last = 90,
    },
    struct_interval{
        .first = 192,
        .last = 214,
    },
    struct_interval{
        .first = 216,
        .last = 222,
    },
    struct_interval{
        .first = 256,
        .last = 256,
    },
    struct_interval{
        .first = 258,
        .last = 258,
    },
    struct_interval{
        .first = 260,
        .last = 260,
    },
    struct_interval{
        .first = 262,
        .last = 262,
    },
    struct_interval{
        .first = 264,
        .last = 264,
    },
    struct_interval{
        .first = 266,
        .last = 266,
    },
    struct_interval{
        .first = 268,
        .last = 268,
    },
    struct_interval{
        .first = 270,
        .last = 270,
    },
    struct_interval{
        .first = 272,
        .last = 272,
    },
    struct_interval{
        .first = 274,
        .last = 274,
    },
    struct_interval{
        .first = 276,
        .last = 276,
    },
    struct_interval{
        .first = 278,
        .last = 278,
    },
    struct_interval{
        .first = 280,
        .last = 280,
    },
    struct_interval{
        .first = 282,
        .last = 282,
    },
    struct_interval{
        .first = 284,
        .last = 284,
    },
    struct_interval{
        .first = 286,
        .last = 286,
    },
    struct_interval{
        .first = 288,
        .last = 288,
    },
    struct_interval{
        .first = 290,
        .last = 290,
    },
    struct_interval{
        .first = 292,
        .last = 292,
    },
    struct_interval{
        .first = 294,
        .last = 294,
    },
    struct_interval{
        .first = 296,
        .last = 296,
    },
    struct_interval{
        .first = 298,
        .last = 298,
    },
    struct_interval{
        .first = 300,
        .last = 300,
    },
    struct_interval{
        .first = 302,
        .last = 302,
    },
    struct_interval{
        .first = 304,
        .last = 304,
    },
    struct_interval{
        .first = 306,
        .last = 306,
    },
    struct_interval{
        .first = 308,
        .last = 308,
    },
    struct_interval{
        .first = 310,
        .last = 310,
    },
    struct_interval{
        .first = 313,
        .last = 313,
    },
    struct_interval{
        .first = 315,
        .last = 315,
    },
    struct_interval{
        .first = 317,
        .last = 317,
    },
    struct_interval{
        .first = 319,
        .last = 319,
    },
    struct_interval{
        .first = 321,
        .last = 321,
    },
    struct_interval{
        .first = 323,
        .last = 323,
    },
    struct_interval{
        .first = 325,
        .last = 325,
    },
    struct_interval{
        .first = 327,
        .last = 327,
    },
    struct_interval{
        .first = 330,
        .last = 330,
    },
    struct_interval{
        .first = 332,
        .last = 332,
    },
    struct_interval{
        .first = 334,
        .last = 334,
    },
    struct_interval{
        .first = 336,
        .last = 336,
    },
    struct_interval{
        .first = 338,
        .last = 338,
    },
    struct_interval{
        .first = 340,
        .last = 340,
    },
    struct_interval{
        .first = 342,
        .last = 342,
    },
    struct_interval{
        .first = 344,
        .last = 344,
    },
    struct_interval{
        .first = 346,
        .last = 346,
    },
    struct_interval{
        .first = 348,
        .last = 348,
    },
    struct_interval{
        .first = 350,
        .last = 350,
    },
    struct_interval{
        .first = 352,
        .last = 352,
    },
    struct_interval{
        .first = 354,
        .last = 354,
    },
    struct_interval{
        .first = 356,
        .last = 356,
    },
    struct_interval{
        .first = 358,
        .last = 358,
    },
    struct_interval{
        .first = 360,
        .last = 360,
    },
    struct_interval{
        .first = 362,
        .last = 362,
    },
    struct_interval{
        .first = 364,
        .last = 364,
    },
    struct_interval{
        .first = 366,
        .last = 366,
    },
    struct_interval{
        .first = 368,
        .last = 368,
    },
    struct_interval{
        .first = 370,
        .last = 370,
    },
    struct_interval{
        .first = 372,
        .last = 372,
    },
    struct_interval{
        .first = 374,
        .last = 374,
    },
    struct_interval{
        .first = 376,
        .last = 376,
    },
    struct_interval{
        .first = 377,
        .last = 377,
    },
    struct_interval{
        .first = 379,
        .last = 379,
    },
    struct_interval{
        .first = 381,
        .last = 381,
    },
    struct_interval{
        .first = 385,
        .last = 385,
    },
    struct_interval{
        .first = 386,
        .last = 386,
    },
    struct_interval{
        .first = 388,
        .last = 388,
    },
    struct_interval{
        .first = 390,
        .last = 390,
    },
    struct_interval{
        .first = 391,
        .last = 391,
    },
    struct_interval{
        .first = 393,
        .last = 394,
    },
    struct_interval{
        .first = 395,
        .last = 395,
    },
    struct_interval{
        .first = 398,
        .last = 398,
    },
    struct_interval{
        .first = 399,
        .last = 399,
    },
    struct_interval{
        .first = 400,
        .last = 400,
    },
    struct_interval{
        .first = 401,
        .last = 401,
    },
    struct_interval{
        .first = 403,
        .last = 403,
    },
    struct_interval{
        .first = 404,
        .last = 404,
    },
    struct_interval{
        .first = 406,
        .last = 406,
    },
    struct_interval{
        .first = 407,
        .last = 407,
    },
    struct_interval{
        .first = 408,
        .last = 408,
    },
    struct_interval{
        .first = 412,
        .last = 412,
    },
    struct_interval{
        .first = 413,
        .last = 413,
    },
    struct_interval{
        .first = 415,
        .last = 415,
    },
    struct_interval{
        .first = 416,
        .last = 416,
    },
    struct_interval{
        .first = 418,
        .last = 418,
    },
    struct_interval{
        .first = 420,
        .last = 420,
    },
    struct_interval{
        .first = 422,
        .last = 422,
    },
    struct_interval{
        .first = 423,
        .last = 423,
    },
    struct_interval{
        .first = 425,
        .last = 425,
    },
    struct_interval{
        .first = 428,
        .last = 428,
    },
    struct_interval{
        .first = 430,
        .last = 430,
    },
    struct_interval{
        .first = 431,
        .last = 431,
    },
    struct_interval{
        .first = 433,
        .last = 434,
    },
    struct_interval{
        .first = 435,
        .last = 435,
    },
    struct_interval{
        .first = 437,
        .last = 437,
    },
    struct_interval{
        .first = 439,
        .last = 439,
    },
    struct_interval{
        .first = 440,
        .last = 440,
    },
    struct_interval{
        .first = 444,
        .last = 444,
    },
    struct_interval{
        .first = 452,
        .last = 452,
    },
    struct_interval{
        .first = 453,
        .last = 453,
    },
    struct_interval{
        .first = 455,
        .last = 455,
    },
    struct_interval{
        .first = 456,
        .last = 456,
    },
    struct_interval{
        .first = 458,
        .last = 458,
    },
    struct_interval{
        .first = 459,
        .last = 459,
    },
    struct_interval{
        .first = 461,
        .last = 461,
    },
    struct_interval{
        .first = 463,
        .last = 463,
    },
    struct_interval{
        .first = 465,
        .last = 465,
    },
    struct_interval{
        .first = 467,
        .last = 467,
    },
    struct_interval{
        .first = 469,
        .last = 469,
    },
    struct_interval{
        .first = 471,
        .last = 471,
    },
    struct_interval{
        .first = 473,
        .last = 473,
    },
    struct_interval{
        .first = 475,
        .last = 475,
    },
    struct_interval{
        .first = 478,
        .last = 478,
    },
    struct_interval{
        .first = 480,
        .last = 480,
    },
    struct_interval{
        .first = 482,
        .last = 482,
    },
    struct_interval{
        .first = 484,
        .last = 484,
    },
    struct_interval{
        .first = 486,
        .last = 486,
    },
    struct_interval{
        .first = 488,
        .last = 488,
    },
    struct_interval{
        .first = 490,
        .last = 490,
    },
    struct_interval{
        .first = 492,
        .last = 492,
    },
    struct_interval{
        .first = 494,
        .last = 494,
    },
    struct_interval{
        .first = 497,
        .last = 497,
    },
    struct_interval{
        .first = 498,
        .last = 498,
    },
    struct_interval{
        .first = 500,
        .last = 500,
    },
    struct_interval{
        .first = 502,
        .last = 502,
    },
    struct_interval{
        .first = 503,
        .last = 503,
    },
    struct_interval{
        .first = 504,
        .last = 504,
    },
    struct_interval{
        .first = 506,
        .last = 506,
    },
    struct_interval{
        .first = 508,
        .last = 508,
    },
    struct_interval{
        .first = 510,
        .last = 510,
    },
    struct_interval{
        .first = 512,
        .last = 512,
    },
    struct_interval{
        .first = 514,
        .last = 514,
    },
    struct_interval{
        .first = 516,
        .last = 516,
    },
    struct_interval{
        .first = 518,
        .last = 518,
    },
    struct_interval{
        .first = 520,
        .last = 520,
    },
    struct_interval{
        .first = 522,
        .last = 522,
    },
    struct_interval{
        .first = 524,
        .last = 524,
    },
    struct_interval{
        .first = 526,
        .last = 526,
    },
    struct_interval{
        .first = 528,
        .last = 528,
    },
    struct_interval{
        .first = 530,
        .last = 530,
    },
    struct_interval{
        .first = 532,
        .last = 532,
    },
    struct_interval{
        .first = 534,
        .last = 534,
    },
    struct_interval{
        .first = 536,
        .last = 536,
    },
    struct_interval{
        .first = 538,
        .last = 538,
    },
    struct_interval{
        .first = 540,
        .last = 540,
    },
    struct_interval{
        .first = 542,
        .last = 542,
    },
    struct_interval{
        .first = 544,
        .last = 544,
    },
    struct_interval{
        .first = 546,
        .last = 546,
    },
    struct_interval{
        .first = 548,
        .last = 548,
    },
    struct_interval{
        .first = 550,
        .last = 550,
    },
    struct_interval{
        .first = 552,
        .last = 552,
    },
    struct_interval{
        .first = 554,
        .last = 554,
    },
    struct_interval{
        .first = 556,
        .last = 556,
    },
    struct_interval{
        .first = 558,
        .last = 558,
    },
    struct_interval{
        .first = 560,
        .last = 560,
    },
    struct_interval{
        .first = 562,
        .last = 562,
    },
    struct_interval{
        .first = 570,
        .last = 570,
    },
    struct_interval{
        .first = 571,
        .last = 571,
    },
    struct_interval{
        .first = 573,
        .last = 573,
    },
    struct_interval{
        .first = 574,
        .last = 574,
    },
    struct_interval{
        .first = 577,
        .last = 577,
    },
    struct_interval{
        .first = 579,
        .last = 579,
    },
    struct_interval{
        .first = 580,
        .last = 580,
    },
    struct_interval{
        .first = 581,
        .last = 581,
    },
    struct_interval{
        .first = 582,
        .last = 582,
    },
    struct_interval{
        .first = 584,
        .last = 584,
    },
    struct_interval{
        .first = 586,
        .last = 586,
    },
    struct_interval{
        .first = 588,
        .last = 588,
    },
    struct_interval{
        .first = 590,
        .last = 590,
    },
    struct_interval{
        .first = 880,
        .last = 880,
    },
    struct_interval{
        .first = 882,
        .last = 882,
    },
    struct_interval{
        .first = 886,
        .last = 886,
    },
    struct_interval{
        .first = 895,
        .last = 895,
    },
    struct_interval{
        .first = 902,
        .last = 902,
    },
    struct_interval{
        .first = 904,
        .last = 906,
    },
    struct_interval{
        .first = 908,
        .last = 908,
    },
    struct_interval{
        .first = 910,
        .last = 911,
    },
    struct_interval{
        .first = 913,
        .last = 929,
    },
    struct_interval{
        .first = 931,
        .last = 939,
    },
    struct_interval{
        .first = 975,
        .last = 975,
    },
    struct_interval{
        .first = 984,
        .last = 984,
    },
    struct_interval{
        .first = 986,
        .last = 986,
    },
    struct_interval{
        .first = 988,
        .last = 988,
    },
    struct_interval{
        .first = 990,
        .last = 990,
    },
    struct_interval{
        .first = 992,
        .last = 992,
    },
    struct_interval{
        .first = 994,
        .last = 994,
    },
    struct_interval{
        .first = 996,
        .last = 996,
    },
    struct_interval{
        .first = 998,
        .last = 998,
    },
    struct_interval{
        .first = 1000,
        .last = 1000,
    },
    struct_interval{
        .first = 1002,
        .last = 1002,
    },
    struct_interval{
        .first = 1004,
        .last = 1004,
    },
    struct_interval{
        .first = 1006,
        .last = 1006,
    },
    struct_interval{
        .first = 1012,
        .last = 1012,
    },
    struct_interval{
        .first = 1015,
        .last = 1015,
    },
    struct_interval{
        .first = 1017,
        .last = 1017,
    },
    struct_interval{
        .first = 1018,
        .last = 1018,
    },
    struct_interval{
        .first = 1021,
        .last = 1023,
    },
    struct_interval{
        .first = 1024,
        .last = 1039,
    },
    struct_interval{
        .first = 1040,
        .last = 1071,
    },
    struct_interval{
        .first = 1120,
        .last = 1120,
    },
    struct_interval{
        .first = 1122,
        .last = 1122,
    },
    struct_interval{
        .first = 1124,
        .last = 1124,
    },
    struct_interval{
        .first = 1126,
        .last = 1126,
    },
    struct_interval{
        .first = 1128,
        .last = 1128,
    },
    struct_interval{
        .first = 1130,
        .last = 1130,
    },
    struct_interval{
        .first = 1132,
        .last = 1132,
    },
    struct_interval{
        .first = 1134,
        .last = 1134,
    },
    struct_interval{
        .first = 1136,
        .last = 1136,
    },
    struct_interval{
        .first = 1138,
        .last = 1138,
    },
    struct_interval{
        .first = 1140,
        .last = 1140,
    },
    struct_interval{
        .first = 1142,
        .last = 1142,
    },
    struct_interval{
        .first = 1144,
        .last = 1144,
    },
    struct_interval{
        .first = 1146,
        .last = 1146,
    },
    struct_interval{
        .first = 1148,
        .last = 1148,
    },
    struct_interval{
        .first = 1150,
        .last = 1150,
    },
    struct_interval{
        .first = 1152,
        .last = 1152,
    },
    struct_interval{
        .first = 1162,
        .last = 1162,
    },
    struct_interval{
        .first = 1164,
        .last = 1164,
    },
    struct_interval{
        .first = 1166,
        .last = 1166,
    },
    struct_interval{
        .first = 1168,
        .last = 1168,
    },
    struct_interval{
        .first = 1170,
        .last = 1170,
    },
    struct_interval{
        .first = 1172,
        .last = 1172,
    },
    struct_interval{
        .first = 1174,
        .last = 1174,
    },
    struct_interval{
        .first = 1176,
        .last = 1176,
    },
    struct_interval{
        .first = 1178,
        .last = 1178,
    },
    struct_interval{
        .first = 1180,
        .last = 1180,
    },
    struct_interval{
        .first = 1182,
        .last = 1182,
    },
    struct_interval{
        .first = 1184,
        .last = 1184,
    },
    struct_interval{
        .first = 1186,
        .last = 1186,
    },
    struct_interval{
        .first = 1188,
        .last = 1188,
    },
    struct_interval{
        .first = 1190,
        .last = 1190,
    },
    struct_interval{
        .first = 1192,
        .last = 1192,
    },
    struct_interval{
        .first = 1194,
        .last = 1194,
    },
    struct_interval{
        .first = 1196,
        .last = 1196,
    },
    struct_interval{
        .first = 1198,
        .last = 1198,
    },
    struct_interval{
        .first = 1200,
        .last = 1200,
    },
    struct_interval{
        .first = 1202,
        .last = 1202,
    },
    struct_interval{
        .first = 1204,
        .last = 1204,
    },
    struct_interval{
        .first = 1206,
        .last = 1206,
    },
    struct_interval{
        .first = 1208,
        .last = 1208,
    },
    struct_interval{
        .first = 1210,
        .last = 1210,
    },
    struct_interval{
        .first = 1212,
        .last = 1212,
    },
    struct_interval{
        .first = 1214,
        .last = 1214,
    },
    struct_interval{
        .first = 1216,
        .last = 1216,
    },
    struct_interval{
        .first = 1217,
        .last = 1217,
    },
    struct_interval{
        .first = 1219,
        .last = 1219,
    },
    struct_interval{
        .first = 1221,
        .last = 1221,
    },
    struct_interval{
        .first = 1223,
        .last = 1223,
    },
    struct_interval{
        .first = 1225,
        .last = 1225,
    },
    struct_interval{
        .first = 1227,
        .last = 1227,
    },
    struct_interval{
        .first = 1229,
        .last = 1229,
    },
    struct_interval{
        .first = 1232,
        .last = 1232,
    },
    struct_interval{
        .first = 1234,
        .last = 1234,
    },
    struct_interval{
        .first = 1236,
        .last = 1236,
    },
    struct_interval{
        .first = 1238,
        .last = 1238,
    },
    struct_interval{
        .first = 1240,
        .last = 1240,
    },
    struct_interval{
        .first = 1242,
        .last = 1242,
    },
    struct_interval{
        .first = 1244,
        .last = 1244,
    },
    struct_interval{
        .first = 1246,
        .last = 1246,
    },
    struct_interval{
        .first = 1248,
        .last = 1248,
    },
    struct_interval{
        .first = 1250,
        .last = 1250,
    },
    struct_interval{
        .first = 1252,
        .last = 1252,
    },
    struct_interval{
        .first = 1254,
        .last = 1254,
    },
    struct_interval{
        .first = 1256,
        .last = 1256,
    },
    struct_interval{
        .first = 1258,
        .last = 1258,
    },
    struct_interval{
        .first = 1260,
        .last = 1260,
    },
    struct_interval{
        .first = 1262,
        .last = 1262,
    },
    struct_interval{
        .first = 1264,
        .last = 1264,
    },
    struct_interval{
        .first = 1266,
        .last = 1266,
    },
    struct_interval{
        .first = 1268,
        .last = 1268,
    },
    struct_interval{
        .first = 1270,
        .last = 1270,
    },
    struct_interval{
        .first = 1272,
        .last = 1272,
    },
    struct_interval{
        .first = 1274,
        .last = 1274,
    },
    struct_interval{
        .first = 1276,
        .last = 1276,
    },
    struct_interval{
        .first = 1278,
        .last = 1278,
    },
    struct_interval{
        .first = 1280,
        .last = 1280,
    },
    struct_interval{
        .first = 1282,
        .last = 1282,
    },
    struct_interval{
        .first = 1284,
        .last = 1284,
    },
    struct_interval{
        .first = 1286,
        .last = 1286,
    },
    struct_interval{
        .first = 1288,
        .last = 1288,
    },
    struct_interval{
        .first = 1290,
        .last = 1290,
    },
    struct_interval{
        .first = 1292,
        .last = 1292,
    },
    struct_interval{
        .first = 1294,
        .last = 1294,
    },
    struct_interval{
        .first = 1296,
        .last = 1296,
    },
    struct_interval{
        .first = 1298,
        .last = 1298,
    },
    struct_interval{
        .first = 1300,
        .last = 1300,
    },
    struct_interval{
        .first = 1302,
        .last = 1302,
    },
    struct_interval{
        .first = 1304,
        .last = 1304,
    },
    struct_interval{
        .first = 1306,
        .last = 1306,
    },
    struct_interval{
        .first = 1308,
        .last = 1308,
    },
    struct_interval{
        .first = 1310,
        .last = 1310,
    },
    struct_interval{
        .first = 1312,
        .last = 1312,
    },
    struct_interval{
        .first = 1314,
        .last = 1314,
    },
    struct_interval{
        .first = 1316,
        .last = 1316,
    },
    struct_interval{
        .first = 1318,
        .last = 1318,
    },
    struct_interval{
        .first = 1320,
        .last = 1320,
    },
    struct_interval{
        .first = 1322,
        .last = 1322,
    },
    struct_interval{
        .first = 1324,
        .last = 1324,
    },
    struct_interval{
        .first = 1326,
        .last = 1326,
    },
    struct_interval{
        .first = 1329,
        .last = 1366,
    },
    struct_interval{
        .first = 4256,
        .last = 4293,
    },
    struct_interval{
        .first = 4295,
        .last = 4295,
    },
    struct_interval{
        .first = 4301,
        .last = 4301,
    },
    struct_interval{
        .first = 5024,
        .last = 5103,
    },
    struct_interval{
        .first = 5104,
        .last = 5109,
    },
    struct_interval{
        .first = 7305,
        .last = 7305,
    },
    struct_interval{
        .first = 7312,
        .last = 7354,
    },
    struct_interval{
        .first = 7357,
        .last = 7359,
    },
    struct_interval{
        .first = 7680,
        .last = 7680,
    },
    struct_interval{
        .first = 7682,
        .last = 7682,
    },
    struct_interval{
        .first = 7684,
        .last = 7684,
    },
    struct_interval{
        .first = 7686,
        .last = 7686,
    },
    struct_interval{
        .first = 7688,
        .last = 7688,
    },
    struct_interval{
        .first = 7690,
        .last = 7690,
    },
    struct_interval{
        .first = 7692,
        .last = 7692,
    },
    struct_interval{
        .first = 7694,
        .last = 7694,
    },
    struct_interval{
        .first = 7696,
        .last = 7696,
    },
    struct_interval{
        .first = 7698,
        .last = 7698,
    },
    struct_interval{
        .first = 7700,
        .last = 7700,
    },
    struct_interval{
        .first = 7702,
        .last = 7702,
    },
    struct_interval{
        .first = 7704,
        .last = 7704,
    },
    struct_interval{
        .first = 7706,
        .last = 7706,
    },
    struct_interval{
        .first = 7708,
        .last = 7708,
    },
    struct_interval{
        .first = 7710,
        .last = 7710,
    },
    struct_interval{
        .first = 7712,
        .last = 7712,
    },
    struct_interval{
        .first = 7714,
        .last = 7714,
    },
    struct_interval{
        .first = 7716,
        .last = 7716,
    },
    struct_interval{
        .first = 7718,
        .last = 7718,
    },
    struct_interval{
        .first = 7720,
        .last = 7720,
    },
    struct_interval{
        .first = 7722,
        .last = 7722,
    },
    struct_interval{
        .first = 7724,
        .last = 7724,
    },
    struct_interval{
        .first = 7726,
        .last = 7726,
    },
    struct_interval{
        .first = 7728,
        .last = 7728,
    },
    struct_interval{
        .first = 7730,
        .last = 7730,
    },
    struct_interval{
        .first = 7732,
        .last = 7732,
    },
    struct_interval{
        .first = 7734,
        .last = 7734,
    },
    struct_interval{
        .first = 7736,
        .last = 7736,
    },
    struct_interval{
        .first = 7738,
        .last = 7738,
    },
    struct_interval{
        .first = 7740,
        .last = 7740,
    },
    struct_interval{
        .first = 7742,
        .last = 7742,
    },
    struct_interval{
        .first = 7744,
        .last = 7744,
    },
    struct_interval{
        .first = 7746,
        .last = 7746,
    },
    struct_interval{
        .first = 7748,
        .last = 7748,
    },
    struct_interval{
        .first = 7750,
        .last = 7750,
    },
    struct_interval{
        .first = 7752,
        .last = 7752,
    },
    struct_interval{
        .first = 7754,
        .last = 7754,
    },
    struct_interval{
        .first = 7756,
        .last = 7756,
    },
    struct_interval{
        .first = 7758,
        .last = 7758,
    },
    struct_interval{
        .first = 7760,
        .last = 7760,
    },
    struct_interval{
        .first = 7762,
        .last = 7762,
    },
    struct_interval{
        .first = 7764,
        .last = 7764,
    },
    struct_interval{
        .first = 7766,
        .last = 7766,
    },
    struct_interval{
        .first = 7768,
        .last = 7768,
    },
    struct_interval{
        .first = 7770,
        .last = 7770,
    },
    struct_interval{
        .first = 7772,
        .last = 7772,
    },
    struct_interval{
        .first = 7774,
        .last = 7774,
    },
    struct_interval{
        .first = 7776,
        .last = 7776,
    },
    struct_interval{
        .first = 7778,
        .last = 7778,
    },
    struct_interval{
        .first = 7780,
        .last = 7780,
    },
    struct_interval{
        .first = 7782,
        .last = 7782,
    },
    struct_interval{
        .first = 7784,
        .last = 7784,
    },
    struct_interval{
        .first = 7786,
        .last = 7786,
    },
    struct_interval{
        .first = 7788,
        .last = 7788,
    },
    struct_interval{
        .first = 7790,
        .last = 7790,
    },
    struct_interval{
        .first = 7792,
        .last = 7792,
    },
    struct_interval{
        .first = 7794,
        .last = 7794,
    },
    struct_interval{
        .first = 7796,
        .last = 7796,
    },
    struct_interval{
        .first = 7798,
        .last = 7798,
    },
    struct_interval{
        .first = 7800,
        .last = 7800,
    },
    struct_interval{
        .first = 7802,
        .last = 7802,
    },
    struct_interval{
        .first = 7804,
        .last = 7804,
    },
    struct_interval{
        .first = 7806,
        .last = 7806,
    },
    struct_interval{
        .first = 7808,
        .last = 7808,
    },
    struct_interval{
        .first = 7810,
        .last = 7810,
    },
    struct_interval{
        .first = 7812,
        .last = 7812,
    },
    struct_interval{
        .first = 7814,
        .last = 7814,
    },
    struct_interval{
        .first = 7816,
        .last = 7816,
    },
    struct_interval{
        .first = 7818,
        .last = 7818,
    },
    struct_interval{
        .first = 7820,
        .last = 7820,
    },
    struct_interval{
        .first = 7822,
        .last = 7822,
    },
    struct_interval{
        .first = 7824,
        .last = 7824,
    },
    struct_interval{
        .first = 7826,
        .last = 7826,
    },
    struct_interval{
        .first = 7828,
        .last = 7828,
    },
    struct_interval{
        .first = 7838,
        .last = 7838,
    },
    struct_interval{
        .first = 7840,
        .last = 7840,
    },
    struct_interval{
        .first = 7842,
        .last = 7842,
    },
    struct_interval{
        .first = 7844,
        .last = 7844,
    },
    struct_interval{
        .first = 7846,
        .last = 7846,
    },
    struct_interval{
        .first = 7848,
        .last = 7848,
    },
    struct_interval{
        .first = 7850,
        .last = 7850,
    },
    struct_interval{
        .first = 7852,
        .last = 7852,
    },
    struct_interval{
        .first = 7854,
        .last = 7854,
    },
    struct_interval{
        .first = 7856,
        .last = 7856,
    },
    struct_interval{
        .first = 7858,
        .last = 7858,
    },
    struct_interval{
        .first = 7860,
        .last = 7860,
    },
    struct_interval{
        .first = 7862,
        .last = 7862,
    },
    struct_interval{
        .first = 7864,
        .last = 7864,
    },
    struct_interval{
        .first = 7866,
        .last = 7866,
    },
    struct_interval{
        .first = 7868,
        .last = 7868,
    },
    struct_interval{
        .first = 7870,
        .last = 7870,
    },
    struct_interval{
        .first = 7872,
        .last = 7872,
    },
    struct_interval{
        .first = 7874,
        .last = 7874,
    },
    struct_interval{
        .first = 7876,
        .last = 7876,
    },
    struct_interval{
        .first = 7878,
        .last = 7878,
    },
    struct_interval{
        .first = 7880,
        .last = 7880,
    },
    struct_interval{
        .first = 7882,
        .last = 7882,
    },
    struct_interval{
        .first = 7884,
        .last = 7884,
    },
    struct_interval{
        .first = 7886,
        .last = 7886,
    },
    struct_interval{
        .first = 7888,
        .last = 7888,
    },
    struct_interval{
        .first = 7890,
        .last = 7890,
    },
    struct_interval{
        .first = 7892,
        .last = 7892,
    },
    struct_interval{
        .first = 7894,
        .last = 7894,
    },
    struct_interval{
        .first = 7896,
        .last = 7896,
    },
    struct_interval{
        .first = 7898,
        .last = 7898,
    },
    struct_interval{
        .first = 7900,
        .last = 7900,
    },
    struct_interval{
        .first = 7902,
        .last = 7902,
    },
    struct_interval{
        .first = 7904,
        .last = 7904,
    },
    struct_interval{
        .first = 7906,
        .last = 7906,
    },
    struct_interval{
        .first = 7908,
        .last = 7908,
    },
    struct_interval{
        .first = 7910,
        .last = 7910,
    },
    struct_interval{
        .first = 7912,
        .last = 7912,
    },
    struct_interval{
        .first = 7914,
        .last = 7914,
    },
    struct_interval{
        .first = 7916,
        .last = 7916,
    },
    struct_interval{
        .first = 7918,
        .last = 7918,
    },
    struct_interval{
        .first = 7920,
        .last = 7920,
    },
    struct_interval{
        .first = 7922,
        .last = 7922,
    },
    struct_interval{
        .first = 7924,
        .last = 7924,
    },
    struct_interval{
        .first = 7926,
        .last = 7926,
    },
    struct_interval{
        .first = 7928,
        .last = 7928,
    },
    struct_interval{
        .first = 7930,
        .last = 7930,
    },
    struct_interval{
        .first = 7932,
        .last = 7932,
    },
    struct_interval{
        .first = 7934,
        .last = 7934,
    },
    struct_interval{
        .first = 7944,
        .last = 7951,
    },
    struct_interval{
        .first = 7960,
        .last = 7965,
    },
    struct_interval{
        .first = 7976,
        .last = 7983,
    },
    struct_interval{
        .first = 7992,
        .last = 7999,
    },
    struct_interval{
        .first = 8008,
        .last = 8013,
    },
    struct_interval{
        .first = 8025,
        .last = 8025,
    },
    struct_interval{
        .first = 8027,
        .last = 8027,
    },
    struct_interval{
        .first = 8029,
        .last = 8029,
    },
    struct_interval{
        .first = 8031,
        .last = 8031,
    },
    struct_interval{
        .first = 8040,
        .last = 8047,
    },
    struct_interval{
        .first = 8072,
        .last = 8079,
    },
    struct_interval{
        .first = 8088,
        .last = 8095,
    },
    struct_interval{
        .first = 8104,
        .last = 8111,
    },
    struct_interval{
        .first = 8120,
        .last = 8121,
    },
    struct_interval{
        .first = 8122,
        .last = 8123,
    },
    struct_interval{
        .first = 8124,
        .last = 8124,
    },
    struct_interval{
        .first = 8136,
        .last = 8139,
    },
    struct_interval{
        .first = 8140,
        .last = 8140,
    },
    struct_interval{
        .first = 8152,
        .last = 8153,
    },
    struct_interval{
        .first = 8154,
        .last = 8155,
    },
    struct_interval{
        .first = 8168,
        .last = 8169,
    },
    struct_interval{
        .first = 8170,
        .last = 8171,
    },
    struct_interval{
        .first = 8172,
        .last = 8172,
    },
    struct_interval{
        .first = 8184,
        .last = 8185,
    },
    struct_interval{
        .first = 8186,
        .last = 8187,
    },
    struct_interval{
        .first = 8188,
        .last = 8188,
    },
    struct_interval{
        .first = 8486,
        .last = 8486,
    },
    struct_interval{
        .first = 8490,
        .last = 8490,
    },
    struct_interval{
        .first = 8491,
        .last = 8491,
    },
    struct_interval{
        .first = 8498,
        .last = 8498,
    },
    struct_interval{
        .first = 8544,
        .last = 8559,
    },
    struct_interval{
        .first = 8579,
        .last = 8579,
    },
    struct_interval{
        .first = 9398,
        .last = 9423,
    },
    struct_interval{
        .first = 11264,
        .last = 11311,
    },
    struct_interval{
        .first = 11360,
        .last = 11360,
    },
    struct_interval{
        .first = 11362,
        .last = 11362,
    },
    struct_interval{
        .first = 11363,
        .last = 11363,
    },
    struct_interval{
        .first = 11364,
        .last = 11364,
    },
    struct_interval{
        .first = 11367,
        .last = 11367,
    },
    struct_interval{
        .first = 11369,
        .last = 11369,
    },
    struct_interval{
        .first = 11371,
        .last = 11371,
    },
    struct_interval{
        .first = 11373,
        .last = 11373,
    },
    struct_interval{
        .first = 11374,
        .last = 11374,
    },
    struct_interval{
        .first = 11375,
        .last = 11375,
    },
    struct_interval{
        .first = 11376,
        .last = 11376,
    },
    struct_interval{
        .first = 11378,
        .last = 11378,
    },
    struct_interval{
        .first = 11381,
        .last = 11381,
    },
    struct_interval{
        .first = 11390,
        .last = 11391,
    },
    struct_interval{
        .first = 11392,
        .last = 11392,
    },
    struct_interval{
        .first = 11394,
        .last = 11394,
    },
    struct_interval{
        .first = 11396,
        .last = 11396,
    },
    struct_interval{
        .first = 11398,
        .last = 11398,
    },
    struct_interval{
        .first = 11400,
        .last = 11400,
    },
    struct_interval{
        .first = 11402,
        .last = 11402,
    },
    struct_interval{
        .first = 11404,
        .last = 11404,
    },
    struct_interval{
        .first = 11406,
        .last = 11406,
    },
    struct_interval{
        .first = 11408,
        .last = 11408,
    },
    struct_interval{
        .first = 11410,
        .last = 11410,
    },
    struct_interval{
        .first = 11412,
        .last = 11412,
    },
    struct_interval{
        .first = 11414,
        .last = 11414,
    },
    struct_interval{
        .first = 11416,
        .last = 11416,
    },
    struct_interval{
        .first = 11418,
        .last = 11418,
    },
    struct_interval{
        .first = 11420,
        .last = 11420,
    },
    struct_interval{
        .first = 11422,
        .last = 11422,
    },
    struct_interval{
        .first = 11424,
        .last = 11424,
    },
    struct_interval{
        .first = 11426,
        .last = 11426,
    },
    struct_interval{
        .first = 11428,
        .last = 11428,
    },
    struct_interval{
        .first = 11430,
        .last = 11430,
    },
    struct_interval{
        .first = 11432,
        .last = 11432,
    },
    struct_interval{
        .first = 11434,
        .last = 11434,
    },
    struct_interval{
        .first = 11436,
        .last = 11436,
    },
    struct_interval{
        .first = 11438,
        .last = 11438,
    },
    struct_interval{
        .first = 11440,
        .last = 11440,
    },
    struct_interval{
        .first = 11442,
        .last = 11442,
    },
    struct_interval{
        .first = 11444,
        .last = 11444,
    },
    struct_interval{
        .first = 11446,
        .last = 11446,
    },
    struct_interval{
        .first = 11448,
        .last = 11448,
    },
    struct_interval{
        .first = 11450,
        .last = 11450,
    },
    struct_interval{
        .first = 11452,
        .last = 11452,
    },
    struct_interval{
        .first = 11454,
        .last = 11454,
    },
    struct_interval{
        .first = 11456,
        .last = 11456,
    },
    struct_interval{
        .first = 11458,
        .last = 11458,
    },
    struct_interval{
        .first = 11460,
        .last = 11460,
    },
    struct_interval{
        .first = 11462,
        .last = 11462,
    },
    struct_interval{
        .first = 11464,
        .last = 11464,
    },
    struct_interval{
        .first = 11466,
        .last = 11466,
    },
    struct_interval{
        .first = 11468,
        .last = 11468,
    },
    struct_interval{
        .first = 11470,
        .last = 11470,
    },
    struct_interval{
        .first = 11472,
        .last = 11472,
    },
    struct_interval{
        .first = 11474,
        .last = 11474,
    },
    struct_interval{
        .first = 11476,
        .last = 11476,
    },
    struct_interval{
        .first = 11478,
        .last = 11478,
    },
    struct_interval{
        .first = 11480,
        .last = 11480,
    },
    struct_interval{
        .first = 11482,
        .last = 11482,
    },
    struct_interval{
        .first = 11484,
        .last = 11484,
    },
    struct_interval{
        .first = 11486,
        .last = 11486,
    },
    struct_interval{
        .first = 11488,
        .last = 11488,
    },
    struct_interval{
        .first = 11490,
        .last = 11490,
    },
    struct_interval{
        .first = 11499,
        .last = 11499,
    },
    struct_interval{
        .first = 11501,
        .last = 11501,
    },
    struct_interval{
        .first = 11506,
        .last = 11506,
    },
    struct_interval{
        .first = 42560,
        .last = 42560,
    },
    struct_interval{
        .first = 42562,
        .last = 42562,
    },
    struct_interval{
        .first = 42564,
        .last = 42564,
    },
    struct_interval{
        .first = 42566,
        .last = 42566,
    },
    struct_interval{
        .first = 42568,
        .last = 42568,
    },
    struct_interval{
        .first = 42570,
        .last = 42570,
    },
    struct_interval{
        .first = 42572,
        .last = 42572,
    },
    struct_interval{
        .first = 42574,
        .last = 42574,
    },
    struct_interval{
        .first = 42576,
        .last = 42576,
    },
    struct_interval{
        .first = 42578,
        .last = 42578,
    },
    struct_interval{
        .first = 42580,
        .last = 42580,
    },
    struct_interval{
        .first = 42582,
        .last = 42582,
    },
    struct_interval{
        .first = 42584,
        .last = 42584,
    },
    struct_interval{
        .first = 42586,
        .last = 42586,
    },
    struct_interval{
        .first = 42588,
        .last = 42588,
    },
    struct_interval{
        .first = 42590,
        .last = 42590,
    },
    struct_interval{
        .first = 42592,
        .last = 42592,
    },
    struct_interval{
        .first = 42594,
        .last = 42594,
    },
    struct_interval{
        .first = 42596,
        .last = 42596,
    },
    struct_interval{
        .first = 42598,
        .last = 42598,
    },
    struct_interval{
        .first = 42600,
        .last = 42600,
    },
    struct_interval{
        .first = 42602,
        .last = 42602,
    },
    struct_interval{
        .first = 42604,
        .last = 42604,
    },
    struct_interval{
        .first = 42624,
        .last = 42624,
    },
    struct_interval{
        .first = 42626,
        .last = 42626,
    },
    struct_interval{
        .first = 42628,
        .last = 42628,
    },
    struct_interval{
        .first = 42630,
        .last = 42630,
    },
    struct_interval{
        .first = 42632,
        .last = 42632,
    },
    struct_interval{
        .first = 42634,
        .last = 42634,
    },
    struct_interval{
        .first = 42636,
        .last = 42636,
    },
    struct_interval{
        .first = 42638,
        .last = 42638,
    },
    struct_interval{
        .first = 42640,
        .last = 42640,
    },
    struct_interval{
        .first = 42642,
        .last = 42642,
    },
    struct_interval{
        .first = 42644,
        .last = 42644,
    },
    struct_interval{
        .first = 42646,
        .last = 42646,
    },
    struct_interval{
        .first = 42648,
        .last = 42648,
    },
    struct_interval{
        .first = 42650,
        .last = 42650,
    },
    struct_interval{
        .first = 42786,
        .last = 42786,
    },
    struct_interval{
        .first = 42788,
        .last = 42788,
    },
    struct_interval{
        .first = 42790,
        .last = 42790,
    },
    struct_interval{
        .first = 42792,
        .last = 42792,
    },
    struct_interval{
        .first = 42794,
        .last = 42794,
    },
    struct_interval{
        .first = 42796,
        .last = 42796,
    },
    struct_interval{
        .first = 42798,
        .last = 42798,
    },
    struct_interval{
        .first = 42802,
        .last = 42802,
    },
    struct_interval{
        .first = 42804,
        .last = 42804,
    },
    struct_interval{
        .first = 42806,
        .last = 42806,
    },
    struct_interval{
        .first = 42808,
        .last = 42808,
    },
    struct_interval{
        .first = 42810,
        .last = 42810,
    },
    struct_interval{
        .first = 42812,
        .last = 42812,
    },
    struct_interval{
        .first = 42814,
        .last = 42814,
    },
    struct_interval{
        .first = 42816,
        .last = 42816,
    },
    struct_interval{
        .first = 42818,
        .last = 42818,
    },
    struct_interval{
        .first = 42820,
        .last = 42820,
    },
    struct_interval{
        .first = 42822,
        .last = 42822,
    },
    struct_interval{
        .first = 42824,
        .last = 42824,
    },
    struct_interval{
        .first = 42826,
        .last = 42826,
    },
    struct_interval{
        .first = 42828,
        .last = 42828,
    },
    struct_interval{
        .first = 42830,
        .last = 42830,
    },
    struct_interval{
        .first = 42832,
        .last = 42832,
    },
    struct_interval{
        .first = 42834,
        .last = 42834,
    },
    struct_interval{
        .first = 42836,
        .last = 42836,
    },
    struct_interval{
        .first = 42838,
        .last = 42838,
    },
    struct_interval{
        .first = 42840,
        .last = 42840,
    },
    struct_interval{
        .first = 42842,
        .last = 42842,
    },
    struct_interval{
        .first = 42844,
        .last = 42844,
    },
    struct_interval{
        .first = 42846,
        .last = 42846,
    },
    struct_interval{
        .first = 42848,
        .last = 42848,
    },
    struct_interval{
        .first = 42850,
        .last = 42850,
    },
    struct_interval{
        .first = 42852,
        .last = 42852,
    },
    struct_interval{
        .first = 42854,
        .last = 42854,
    },
    struct_interval{
        .first = 42856,
        .last = 42856,
    },
    struct_interval{
        .first = 42858,
        .last = 42858,
    },
    struct_interval{
        .first = 42860,
        .last = 42860,
    },
    struct_interval{
        .first = 42862,
        .last = 42862,
    },
    struct_interval{
        .first = 42873,
        .last = 42873,
    },
    struct_interval{
        .first = 42875,
        .last = 42875,
    },
    struct_interval{
        .first = 42877,
        .last = 42877,
    },
    struct_interval{
        .first = 42878,
        .last = 42878,
    },
    struct_interval{
        .first = 42880,
        .last = 42880,
    },
    struct_interval{
        .first = 42882,
        .last = 42882,
    },
    struct_interval{
        .first = 42884,
        .last = 42884,
    },
    struct_interval{
        .first = 42886,
        .last = 42886,
    },
    struct_interval{
        .first = 42891,
        .last = 42891,
    },
    struct_interval{
        .first = 42893,
        .last = 42893,
    },
    struct_interval{
        .first = 42896,
        .last = 42896,
    },
    struct_interval{
        .first = 42898,
        .last = 42898,
    },
    struct_interval{
        .first = 42902,
        .last = 42902,
    },
    struct_interval{
        .first = 42904,
        .last = 42904,
    },
    struct_interval{
        .first = 42906,
        .last = 42906,
    },
    struct_interval{
        .first = 42908,
        .last = 42908,
    },
    struct_interval{
        .first = 42910,
        .last = 42910,
    },
    struct_interval{
        .first = 42912,
        .last = 42912,
    },
    struct_interval{
        .first = 42914,
        .last = 42914,
    },
    struct_interval{
        .first = 42916,
        .last = 42916,
    },
    struct_interval{
        .first = 42918,
        .last = 42918,
    },
    struct_interval{
        .first = 42920,
        .last = 42920,
    },
    struct_interval{
        .first = 42922,
        .last = 42922,
    },
    struct_interval{
        .first = 42923,
        .last = 42923,
    },
    struct_interval{
        .first = 42924,
        .last = 42924,
    },
    struct_interval{
        .first = 42925,
        .last = 42925,
    },
    struct_interval{
        .first = 42926,
        .last = 42926,
    },
    struct_interval{
        .first = 42928,
        .last = 42928,
    },
    struct_interval{
        .first = 42929,
        .last = 42929,
    },
    struct_interval{
        .first = 42930,
        .last = 42930,
    },
    struct_interval{
        .first = 42931,
        .last = 42931,
    },
    struct_interval{
        .first = 42932,
        .last = 42932,
    },
    struct_interval{
        .first = 42934,
        .last = 42934,
    },
    struct_interval{
        .first = 42936,
        .last = 42936,
    },
    struct_interval{
        .first = 42938,
        .last = 42938,
    },
    struct_interval{
        .first = 42940,
        .last = 42940,
    },
    struct_interval{
        .first = 42942,
        .last = 42942,
    },
    struct_interval{
        .first = 42944,
        .last = 42944,
    },
    struct_interval{
        .first = 42946,
        .last = 42946,
    },
    struct_interval{
        .first = 42948,
        .last = 42948,
    },
    struct_interval{
        .first = 42949,
        .last = 42949,
    },
    struct_interval{
        .first = 42950,
        .last = 42950,
    },
    struct_interval{
        .first = 42951,
        .last = 42951,
    },
    struct_interval{
        .first = 42953,
        .last = 42953,
    },
    struct_interval{
        .first = 42955,
        .last = 42955,
    },
    struct_interval{
        .first = 42956,
        .last = 42956,
    },
    struct_interval{
        .first = 42958,
        .last = 42958,
    },
    struct_interval{
        .first = 42960,
        .last = 42960,
    },
    struct_interval{
        .first = 42962,
        .last = 42962,
    },
    struct_interval{
        .first = 42964,
        .last = 42964,
    },
    struct_interval{
        .first = 42966,
        .last = 42966,
    },
    struct_interval{
        .first = 42968,
        .last = 42968,
    },
    struct_interval{
        .first = 42970,
        .last = 42970,
    },
    struct_interval{
        .first = 42972,
        .last = 42972,
    },
    struct_interval{
        .first = 42997,
        .last = 42997,
    },
    struct_interval{
        .first = 65313,
        .last = 65338,
    },
    struct_interval{
        .first = 66560,
        .last = 66599,
    },
    struct_interval{
        .first = 66736,
        .last = 66771,
    },
    struct_interval{
        .first = 66928,
        .last = 66938,
    },
    struct_interval{
        .first = 66940,
        .last = 66954,
    },
    struct_interval{
        .first = 66956,
        .last = 66962,
    },
    struct_interval{
        .first = 66964,
        .last = 66965,
    },
    struct_interval{
        .first = 68736,
        .last = 68786,
    },
    struct_interval{
        .first = 68944,
        .last = 68965,
    },
    struct_interval{
        .first = 71840,
        .last = 71871,
    },
    struct_interval{
        .first = 93760,
        .last = 93791,
    },
    struct_interval{
        .first = 93856,
        .last = 93880,
    },
    struct_interval{
        .first = 125184,
        .last = 125217,
    },
    struct_interval{
        .first = 0,
        .last = 0,
    },
};
pub export const tolower_cvt: [679]c_int = [679]c_int{
    97,
    224,
    248,
    257,
    259,
    261,
    263,
    265,
    267,
    269,
    271,
    273,
    275,
    277,
    279,
    281,
    283,
    285,
    287,
    289,
    291,
    293,
    295,
    297,
    299,
    301,
    303,
    105,
    307,
    309,
    311,
    314,
    316,
    318,
    320,
    322,
    324,
    326,
    328,
    331,
    333,
    335,
    337,
    339,
    341,
    343,
    345,
    347,
    349,
    351,
    353,
    355,
    357,
    359,
    361,
    363,
    365,
    367,
    369,
    371,
    373,
    375,
    255,
    378,
    380,
    382,
    595,
    387,
    389,
    596,
    392,
    598,
    396,
    477,
    601,
    603,
    402,
    608,
    611,
    617,
    616,
    409,
    623,
    626,
    629,
    417,
    419,
    421,
    640,
    424,
    643,
    429,
    648,
    432,
    650,
    436,
    438,
    658,
    441,
    445,
    454,
    454,
    457,
    457,
    460,
    460,
    462,
    464,
    466,
    468,
    470,
    472,
    474,
    476,
    479,
    481,
    483,
    485,
    487,
    489,
    491,
    493,
    495,
    499,
    499,
    501,
    405,
    447,
    505,
    507,
    509,
    511,
    513,
    515,
    517,
    519,
    521,
    523,
    525,
    527,
    529,
    531,
    533,
    535,
    537,
    539,
    541,
    543,
    414,
    547,
    549,
    551,
    553,
    555,
    557,
    559,
    561,
    563,
    11365,
    572,
    410,
    11366,
    578,
    384,
    649,
    652,
    583,
    585,
    587,
    589,
    591,
    881,
    883,
    887,
    1011,
    940,
    941,
    972,
    973,
    945,
    963,
    983,
    985,
    987,
    989,
    991,
    993,
    995,
    997,
    999,
    1001,
    1003,
    1005,
    1007,
    952,
    1016,
    1010,
    1019,
    891,
    1104,
    1072,
    1121,
    1123,
    1125,
    1127,
    1129,
    1131,
    1133,
    1135,
    1137,
    1139,
    1141,
    1143,
    1145,
    1147,
    1149,
    1151,
    1153,
    1163,
    1165,
    1167,
    1169,
    1171,
    1173,
    1175,
    1177,
    1179,
    1181,
    1183,
    1185,
    1187,
    1189,
    1191,
    1193,
    1195,
    1197,
    1199,
    1201,
    1203,
    1205,
    1207,
    1209,
    1211,
    1213,
    1215,
    1231,
    1218,
    1220,
    1222,
    1224,
    1226,
    1228,
    1230,
    1233,
    1235,
    1237,
    1239,
    1241,
    1243,
    1245,
    1247,
    1249,
    1251,
    1253,
    1255,
    1257,
    1259,
    1261,
    1263,
    1265,
    1267,
    1269,
    1271,
    1273,
    1275,
    1277,
    1279,
    1281,
    1283,
    1285,
    1287,
    1289,
    1291,
    1293,
    1295,
    1297,
    1299,
    1301,
    1303,
    1305,
    1307,
    1309,
    1311,
    1313,
    1315,
    1317,
    1319,
    1321,
    1323,
    1325,
    1327,
    1377,
    11520,
    11559,
    11565,
    43888,
    5112,
    7306,
    4304,
    4349,
    7681,
    7683,
    7685,
    7687,
    7689,
    7691,
    7693,
    7695,
    7697,
    7699,
    7701,
    7703,
    7705,
    7707,
    7709,
    7711,
    7713,
    7715,
    7717,
    7719,
    7721,
    7723,
    7725,
    7727,
    7729,
    7731,
    7733,
    7735,
    7737,
    7739,
    7741,
    7743,
    7745,
    7747,
    7749,
    7751,
    7753,
    7755,
    7757,
    7759,
    7761,
    7763,
    7765,
    7767,
    7769,
    7771,
    7773,
    7775,
    7777,
    7779,
    7781,
    7783,
    7785,
    7787,
    7789,
    7791,
    7793,
    7795,
    7797,
    7799,
    7801,
    7803,
    7805,
    7807,
    7809,
    7811,
    7813,
    7815,
    7817,
    7819,
    7821,
    7823,
    7825,
    7827,
    7829,
    223,
    7841,
    7843,
    7845,
    7847,
    7849,
    7851,
    7853,
    7855,
    7857,
    7859,
    7861,
    7863,
    7865,
    7867,
    7869,
    7871,
    7873,
    7875,
    7877,
    7879,
    7881,
    7883,
    7885,
    7887,
    7889,
    7891,
    7893,
    7895,
    7897,
    7899,
    7901,
    7903,
    7905,
    7907,
    7909,
    7911,
    7913,
    7915,
    7917,
    7919,
    7921,
    7923,
    7925,
    7927,
    7929,
    7931,
    7933,
    7935,
    7936,
    7952,
    7968,
    7984,
    8000,
    8017,
    8019,
    8021,
    8023,
    8032,
    8064,
    8080,
    8096,
    8112,
    8048,
    8115,
    8050,
    8131,
    8144,
    8054,
    8160,
    8058,
    8165,
    8056,
    8060,
    8179,
    969,
    107,
    229,
    8526,
    8560,
    8580,
    9424,
    11312,
    11361,
    619,
    7549,
    637,
    11368,
    11370,
    11372,
    593,
    625,
    592,
    594,
    11379,
    11382,
    575,
    11393,
    11395,
    11397,
    11399,
    11401,
    11403,
    11405,
    11407,
    11409,
    11411,
    11413,
    11415,
    11417,
    11419,
    11421,
    11423,
    11425,
    11427,
    11429,
    11431,
    11433,
    11435,
    11437,
    11439,
    11441,
    11443,
    11445,
    11447,
    11449,
    11451,
    11453,
    11455,
    11457,
    11459,
    11461,
    11463,
    11465,
    11467,
    11469,
    11471,
    11473,
    11475,
    11477,
    11479,
    11481,
    11483,
    11485,
    11487,
    11489,
    11491,
    11500,
    11502,
    11507,
    42561,
    42563,
    42565,
    42567,
    42569,
    42571,
    42573,
    42575,
    42577,
    42579,
    42581,
    42583,
    42585,
    42587,
    42589,
    42591,
    42593,
    42595,
    42597,
    42599,
    42601,
    42603,
    42605,
    42625,
    42627,
    42629,
    42631,
    42633,
    42635,
    42637,
    42639,
    42641,
    42643,
    42645,
    42647,
    42649,
    42651,
    42787,
    42789,
    42791,
    42793,
    42795,
    42797,
    42799,
    42803,
    42805,
    42807,
    42809,
    42811,
    42813,
    42815,
    42817,
    42819,
    42821,
    42823,
    42825,
    42827,
    42829,
    42831,
    42833,
    42835,
    42837,
    42839,
    42841,
    42843,
    42845,
    42847,
    42849,
    42851,
    42853,
    42855,
    42857,
    42859,
    42861,
    42863,
    42874,
    42876,
    7545,
    42879,
    42881,
    42883,
    42885,
    42887,
    42892,
    613,
    42897,
    42899,
    42903,
    42905,
    42907,
    42909,
    42911,
    42913,
    42915,
    42917,
    42919,
    42921,
    614,
    604,
    609,
    620,
    618,
    670,
    647,
    669,
    43859,
    42933,
    42935,
    42937,
    42939,
    42941,
    42943,
    42945,
    42947,
    42900,
    642,
    7566,
    42952,
    42954,
    612,
    42957,
    42959,
    42961,
    42963,
    42965,
    42967,
    42969,
    42971,
    411,
    42998,
    65345,
    66600,
    66776,
    66967,
    66979,
    66995,
    67003,
    68800,
    68976,
    71872,
    93792,
    93883,
    125218,
    0,
};
pub export const totitle_table: [693]struct_interval = [693]struct_interval{
    struct_interval{
        .first = 97,
        .last = 122,
    },
    struct_interval{
        .first = 181,
        .last = 181,
    },
    struct_interval{
        .first = 224,
        .last = 246,
    },
    struct_interval{
        .first = 248,
        .last = 254,
    },
    struct_interval{
        .first = 255,
        .last = 255,
    },
    struct_interval{
        .first = 257,
        .last = 257,
    },
    struct_interval{
        .first = 259,
        .last = 259,
    },
    struct_interval{
        .first = 261,
        .last = 261,
    },
    struct_interval{
        .first = 263,
        .last = 263,
    },
    struct_interval{
        .first = 265,
        .last = 265,
    },
    struct_interval{
        .first = 267,
        .last = 267,
    },
    struct_interval{
        .first = 269,
        .last = 269,
    },
    struct_interval{
        .first = 271,
        .last = 271,
    },
    struct_interval{
        .first = 273,
        .last = 273,
    },
    struct_interval{
        .first = 275,
        .last = 275,
    },
    struct_interval{
        .first = 277,
        .last = 277,
    },
    struct_interval{
        .first = 279,
        .last = 279,
    },
    struct_interval{
        .first = 281,
        .last = 281,
    },
    struct_interval{
        .first = 283,
        .last = 283,
    },
    struct_interval{
        .first = 285,
        .last = 285,
    },
    struct_interval{
        .first = 287,
        .last = 287,
    },
    struct_interval{
        .first = 289,
        .last = 289,
    },
    struct_interval{
        .first = 291,
        .last = 291,
    },
    struct_interval{
        .first = 293,
        .last = 293,
    },
    struct_interval{
        .first = 295,
        .last = 295,
    },
    struct_interval{
        .first = 297,
        .last = 297,
    },
    struct_interval{
        .first = 299,
        .last = 299,
    },
    struct_interval{
        .first = 301,
        .last = 301,
    },
    struct_interval{
        .first = 303,
        .last = 303,
    },
    struct_interval{
        .first = 305,
        .last = 305,
    },
    struct_interval{
        .first = 307,
        .last = 307,
    },
    struct_interval{
        .first = 309,
        .last = 309,
    },
    struct_interval{
        .first = 311,
        .last = 311,
    },
    struct_interval{
        .first = 314,
        .last = 314,
    },
    struct_interval{
        .first = 316,
        .last = 316,
    },
    struct_interval{
        .first = 318,
        .last = 318,
    },
    struct_interval{
        .first = 320,
        .last = 320,
    },
    struct_interval{
        .first = 322,
        .last = 322,
    },
    struct_interval{
        .first = 324,
        .last = 324,
    },
    struct_interval{
        .first = 326,
        .last = 326,
    },
    struct_interval{
        .first = 328,
        .last = 328,
    },
    struct_interval{
        .first = 331,
        .last = 331,
    },
    struct_interval{
        .first = 333,
        .last = 333,
    },
    struct_interval{
        .first = 335,
        .last = 335,
    },
    struct_interval{
        .first = 337,
        .last = 337,
    },
    struct_interval{
        .first = 339,
        .last = 339,
    },
    struct_interval{
        .first = 341,
        .last = 341,
    },
    struct_interval{
        .first = 343,
        .last = 343,
    },
    struct_interval{
        .first = 345,
        .last = 345,
    },
    struct_interval{
        .first = 347,
        .last = 347,
    },
    struct_interval{
        .first = 349,
        .last = 349,
    },
    struct_interval{
        .first = 351,
        .last = 351,
    },
    struct_interval{
        .first = 353,
        .last = 353,
    },
    struct_interval{
        .first = 355,
        .last = 355,
    },
    struct_interval{
        .first = 357,
        .last = 357,
    },
    struct_interval{
        .first = 359,
        .last = 359,
    },
    struct_interval{
        .first = 361,
        .last = 361,
    },
    struct_interval{
        .first = 363,
        .last = 363,
    },
    struct_interval{
        .first = 365,
        .last = 365,
    },
    struct_interval{
        .first = 367,
        .last = 367,
    },
    struct_interval{
        .first = 369,
        .last = 369,
    },
    struct_interval{
        .first = 371,
        .last = 371,
    },
    struct_interval{
        .first = 373,
        .last = 373,
    },
    struct_interval{
        .first = 375,
        .last = 375,
    },
    struct_interval{
        .first = 378,
        .last = 378,
    },
    struct_interval{
        .first = 380,
        .last = 380,
    },
    struct_interval{
        .first = 382,
        .last = 382,
    },
    struct_interval{
        .first = 383,
        .last = 383,
    },
    struct_interval{
        .first = 384,
        .last = 384,
    },
    struct_interval{
        .first = 387,
        .last = 387,
    },
    struct_interval{
        .first = 389,
        .last = 389,
    },
    struct_interval{
        .first = 392,
        .last = 392,
    },
    struct_interval{
        .first = 396,
        .last = 396,
    },
    struct_interval{
        .first = 402,
        .last = 402,
    },
    struct_interval{
        .first = 405,
        .last = 405,
    },
    struct_interval{
        .first = 409,
        .last = 409,
    },
    struct_interval{
        .first = 410,
        .last = 410,
    },
    struct_interval{
        .first = 411,
        .last = 411,
    },
    struct_interval{
        .first = 414,
        .last = 414,
    },
    struct_interval{
        .first = 417,
        .last = 417,
    },
    struct_interval{
        .first = 419,
        .last = 419,
    },
    struct_interval{
        .first = 421,
        .last = 421,
    },
    struct_interval{
        .first = 424,
        .last = 424,
    },
    struct_interval{
        .first = 429,
        .last = 429,
    },
    struct_interval{
        .first = 432,
        .last = 432,
    },
    struct_interval{
        .first = 436,
        .last = 436,
    },
    struct_interval{
        .first = 438,
        .last = 438,
    },
    struct_interval{
        .first = 441,
        .last = 441,
    },
    struct_interval{
        .first = 445,
        .last = 445,
    },
    struct_interval{
        .first = 447,
        .last = 447,
    },
    struct_interval{
        .first = 452,
        .last = 452,
    },
    struct_interval{
        .first = 454,
        .last = 454,
    },
    struct_interval{
        .first = 455,
        .last = 455,
    },
    struct_interval{
        .first = 457,
        .last = 457,
    },
    struct_interval{
        .first = 458,
        .last = 458,
    },
    struct_interval{
        .first = 460,
        .last = 460,
    },
    struct_interval{
        .first = 462,
        .last = 462,
    },
    struct_interval{
        .first = 464,
        .last = 464,
    },
    struct_interval{
        .first = 466,
        .last = 466,
    },
    struct_interval{
        .first = 468,
        .last = 468,
    },
    struct_interval{
        .first = 470,
        .last = 470,
    },
    struct_interval{
        .first = 472,
        .last = 472,
    },
    struct_interval{
        .first = 474,
        .last = 474,
    },
    struct_interval{
        .first = 476,
        .last = 476,
    },
    struct_interval{
        .first = 477,
        .last = 477,
    },
    struct_interval{
        .first = 479,
        .last = 479,
    },
    struct_interval{
        .first = 481,
        .last = 481,
    },
    struct_interval{
        .first = 483,
        .last = 483,
    },
    struct_interval{
        .first = 485,
        .last = 485,
    },
    struct_interval{
        .first = 487,
        .last = 487,
    },
    struct_interval{
        .first = 489,
        .last = 489,
    },
    struct_interval{
        .first = 491,
        .last = 491,
    },
    struct_interval{
        .first = 493,
        .last = 493,
    },
    struct_interval{
        .first = 495,
        .last = 495,
    },
    struct_interval{
        .first = 497,
        .last = 497,
    },
    struct_interval{
        .first = 499,
        .last = 499,
    },
    struct_interval{
        .first = 501,
        .last = 501,
    },
    struct_interval{
        .first = 505,
        .last = 505,
    },
    struct_interval{
        .first = 507,
        .last = 507,
    },
    struct_interval{
        .first = 509,
        .last = 509,
    },
    struct_interval{
        .first = 511,
        .last = 511,
    },
    struct_interval{
        .first = 513,
        .last = 513,
    },
    struct_interval{
        .first = 515,
        .last = 515,
    },
    struct_interval{
        .first = 517,
        .last = 517,
    },
    struct_interval{
        .first = 519,
        .last = 519,
    },
    struct_interval{
        .first = 521,
        .last = 521,
    },
    struct_interval{
        .first = 523,
        .last = 523,
    },
    struct_interval{
        .first = 525,
        .last = 525,
    },
    struct_interval{
        .first = 527,
        .last = 527,
    },
    struct_interval{
        .first = 529,
        .last = 529,
    },
    struct_interval{
        .first = 531,
        .last = 531,
    },
    struct_interval{
        .first = 533,
        .last = 533,
    },
    struct_interval{
        .first = 535,
        .last = 535,
    },
    struct_interval{
        .first = 537,
        .last = 537,
    },
    struct_interval{
        .first = 539,
        .last = 539,
    },
    struct_interval{
        .first = 541,
        .last = 541,
    },
    struct_interval{
        .first = 543,
        .last = 543,
    },
    struct_interval{
        .first = 547,
        .last = 547,
    },
    struct_interval{
        .first = 549,
        .last = 549,
    },
    struct_interval{
        .first = 551,
        .last = 551,
    },
    struct_interval{
        .first = 553,
        .last = 553,
    },
    struct_interval{
        .first = 555,
        .last = 555,
    },
    struct_interval{
        .first = 557,
        .last = 557,
    },
    struct_interval{
        .first = 559,
        .last = 559,
    },
    struct_interval{
        .first = 561,
        .last = 561,
    },
    struct_interval{
        .first = 563,
        .last = 563,
    },
    struct_interval{
        .first = 572,
        .last = 572,
    },
    struct_interval{
        .first = 575,
        .last = 576,
    },
    struct_interval{
        .first = 578,
        .last = 578,
    },
    struct_interval{
        .first = 583,
        .last = 583,
    },
    struct_interval{
        .first = 585,
        .last = 585,
    },
    struct_interval{
        .first = 587,
        .last = 587,
    },
    struct_interval{
        .first = 589,
        .last = 589,
    },
    struct_interval{
        .first = 591,
        .last = 591,
    },
    struct_interval{
        .first = 592,
        .last = 592,
    },
    struct_interval{
        .first = 593,
        .last = 593,
    },
    struct_interval{
        .first = 594,
        .last = 594,
    },
    struct_interval{
        .first = 595,
        .last = 595,
    },
    struct_interval{
        .first = 596,
        .last = 596,
    },
    struct_interval{
        .first = 598,
        .last = 599,
    },
    struct_interval{
        .first = 601,
        .last = 601,
    },
    struct_interval{
        .first = 603,
        .last = 603,
    },
    struct_interval{
        .first = 604,
        .last = 604,
    },
    struct_interval{
        .first = 608,
        .last = 608,
    },
    struct_interval{
        .first = 609,
        .last = 609,
    },
    struct_interval{
        .first = 611,
        .last = 611,
    },
    struct_interval{
        .first = 612,
        .last = 612,
    },
    struct_interval{
        .first = 613,
        .last = 613,
    },
    struct_interval{
        .first = 614,
        .last = 614,
    },
    struct_interval{
        .first = 616,
        .last = 616,
    },
    struct_interval{
        .first = 617,
        .last = 617,
    },
    struct_interval{
        .first = 618,
        .last = 618,
    },
    struct_interval{
        .first = 619,
        .last = 619,
    },
    struct_interval{
        .first = 620,
        .last = 620,
    },
    struct_interval{
        .first = 623,
        .last = 623,
    },
    struct_interval{
        .first = 625,
        .last = 625,
    },
    struct_interval{
        .first = 626,
        .last = 626,
    },
    struct_interval{
        .first = 629,
        .last = 629,
    },
    struct_interval{
        .first = 637,
        .last = 637,
    },
    struct_interval{
        .first = 640,
        .last = 640,
    },
    struct_interval{
        .first = 642,
        .last = 642,
    },
    struct_interval{
        .first = 643,
        .last = 643,
    },
    struct_interval{
        .first = 647,
        .last = 647,
    },
    struct_interval{
        .first = 648,
        .last = 648,
    },
    struct_interval{
        .first = 649,
        .last = 649,
    },
    struct_interval{
        .first = 650,
        .last = 651,
    },
    struct_interval{
        .first = 652,
        .last = 652,
    },
    struct_interval{
        .first = 658,
        .last = 658,
    },
    struct_interval{
        .first = 669,
        .last = 669,
    },
    struct_interval{
        .first = 670,
        .last = 670,
    },
    struct_interval{
        .first = 837,
        .last = 837,
    },
    struct_interval{
        .first = 881,
        .last = 881,
    },
    struct_interval{
        .first = 883,
        .last = 883,
    },
    struct_interval{
        .first = 887,
        .last = 887,
    },
    struct_interval{
        .first = 891,
        .last = 893,
    },
    struct_interval{
        .first = 940,
        .last = 940,
    },
    struct_interval{
        .first = 941,
        .last = 943,
    },
    struct_interval{
        .first = 945,
        .last = 961,
    },
    struct_interval{
        .first = 962,
        .last = 962,
    },
    struct_interval{
        .first = 963,
        .last = 971,
    },
    struct_interval{
        .first = 972,
        .last = 972,
    },
    struct_interval{
        .first = 973,
        .last = 974,
    },
    struct_interval{
        .first = 976,
        .last = 976,
    },
    struct_interval{
        .first = 977,
        .last = 977,
    },
    struct_interval{
        .first = 981,
        .last = 981,
    },
    struct_interval{
        .first = 982,
        .last = 982,
    },
    struct_interval{
        .first = 983,
        .last = 983,
    },
    struct_interval{
        .first = 985,
        .last = 985,
    },
    struct_interval{
        .first = 987,
        .last = 987,
    },
    struct_interval{
        .first = 989,
        .last = 989,
    },
    struct_interval{
        .first = 991,
        .last = 991,
    },
    struct_interval{
        .first = 993,
        .last = 993,
    },
    struct_interval{
        .first = 995,
        .last = 995,
    },
    struct_interval{
        .first = 997,
        .last = 997,
    },
    struct_interval{
        .first = 999,
        .last = 999,
    },
    struct_interval{
        .first = 1001,
        .last = 1001,
    },
    struct_interval{
        .first = 1003,
        .last = 1003,
    },
    struct_interval{
        .first = 1005,
        .last = 1005,
    },
    struct_interval{
        .first = 1007,
        .last = 1007,
    },
    struct_interval{
        .first = 1008,
        .last = 1008,
    },
    struct_interval{
        .first = 1009,
        .last = 1009,
    },
    struct_interval{
        .first = 1010,
        .last = 1010,
    },
    struct_interval{
        .first = 1011,
        .last = 1011,
    },
    struct_interval{
        .first = 1013,
        .last = 1013,
    },
    struct_interval{
        .first = 1016,
        .last = 1016,
    },
    struct_interval{
        .first = 1019,
        .last = 1019,
    },
    struct_interval{
        .first = 1072,
        .last = 1103,
    },
    struct_interval{
        .first = 1104,
        .last = 1119,
    },
    struct_interval{
        .first = 1121,
        .last = 1121,
    },
    struct_interval{
        .first = 1123,
        .last = 1123,
    },
    struct_interval{
        .first = 1125,
        .last = 1125,
    },
    struct_interval{
        .first = 1127,
        .last = 1127,
    },
    struct_interval{
        .first = 1129,
        .last = 1129,
    },
    struct_interval{
        .first = 1131,
        .last = 1131,
    },
    struct_interval{
        .first = 1133,
        .last = 1133,
    },
    struct_interval{
        .first = 1135,
        .last = 1135,
    },
    struct_interval{
        .first = 1137,
        .last = 1137,
    },
    struct_interval{
        .first = 1139,
        .last = 1139,
    },
    struct_interval{
        .first = 1141,
        .last = 1141,
    },
    struct_interval{
        .first = 1143,
        .last = 1143,
    },
    struct_interval{
        .first = 1145,
        .last = 1145,
    },
    struct_interval{
        .first = 1147,
        .last = 1147,
    },
    struct_interval{
        .first = 1149,
        .last = 1149,
    },
    struct_interval{
        .first = 1151,
        .last = 1151,
    },
    struct_interval{
        .first = 1153,
        .last = 1153,
    },
    struct_interval{
        .first = 1163,
        .last = 1163,
    },
    struct_interval{
        .first = 1165,
        .last = 1165,
    },
    struct_interval{
        .first = 1167,
        .last = 1167,
    },
    struct_interval{
        .first = 1169,
        .last = 1169,
    },
    struct_interval{
        .first = 1171,
        .last = 1171,
    },
    struct_interval{
        .first = 1173,
        .last = 1173,
    },
    struct_interval{
        .first = 1175,
        .last = 1175,
    },
    struct_interval{
        .first = 1177,
        .last = 1177,
    },
    struct_interval{
        .first = 1179,
        .last = 1179,
    },
    struct_interval{
        .first = 1181,
        .last = 1181,
    },
    struct_interval{
        .first = 1183,
        .last = 1183,
    },
    struct_interval{
        .first = 1185,
        .last = 1185,
    },
    struct_interval{
        .first = 1187,
        .last = 1187,
    },
    struct_interval{
        .first = 1189,
        .last = 1189,
    },
    struct_interval{
        .first = 1191,
        .last = 1191,
    },
    struct_interval{
        .first = 1193,
        .last = 1193,
    },
    struct_interval{
        .first = 1195,
        .last = 1195,
    },
    struct_interval{
        .first = 1197,
        .last = 1197,
    },
    struct_interval{
        .first = 1199,
        .last = 1199,
    },
    struct_interval{
        .first = 1201,
        .last = 1201,
    },
    struct_interval{
        .first = 1203,
        .last = 1203,
    },
    struct_interval{
        .first = 1205,
        .last = 1205,
    },
    struct_interval{
        .first = 1207,
        .last = 1207,
    },
    struct_interval{
        .first = 1209,
        .last = 1209,
    },
    struct_interval{
        .first = 1211,
        .last = 1211,
    },
    struct_interval{
        .first = 1213,
        .last = 1213,
    },
    struct_interval{
        .first = 1215,
        .last = 1215,
    },
    struct_interval{
        .first = 1218,
        .last = 1218,
    },
    struct_interval{
        .first = 1220,
        .last = 1220,
    },
    struct_interval{
        .first = 1222,
        .last = 1222,
    },
    struct_interval{
        .first = 1224,
        .last = 1224,
    },
    struct_interval{
        .first = 1226,
        .last = 1226,
    },
    struct_interval{
        .first = 1228,
        .last = 1228,
    },
    struct_interval{
        .first = 1230,
        .last = 1230,
    },
    struct_interval{
        .first = 1231,
        .last = 1231,
    },
    struct_interval{
        .first = 1233,
        .last = 1233,
    },
    struct_interval{
        .first = 1235,
        .last = 1235,
    },
    struct_interval{
        .first = 1237,
        .last = 1237,
    },
    struct_interval{
        .first = 1239,
        .last = 1239,
    },
    struct_interval{
        .first = 1241,
        .last = 1241,
    },
    struct_interval{
        .first = 1243,
        .last = 1243,
    },
    struct_interval{
        .first = 1245,
        .last = 1245,
    },
    struct_interval{
        .first = 1247,
        .last = 1247,
    },
    struct_interval{
        .first = 1249,
        .last = 1249,
    },
    struct_interval{
        .first = 1251,
        .last = 1251,
    },
    struct_interval{
        .first = 1253,
        .last = 1253,
    },
    struct_interval{
        .first = 1255,
        .last = 1255,
    },
    struct_interval{
        .first = 1257,
        .last = 1257,
    },
    struct_interval{
        .first = 1259,
        .last = 1259,
    },
    struct_interval{
        .first = 1261,
        .last = 1261,
    },
    struct_interval{
        .first = 1263,
        .last = 1263,
    },
    struct_interval{
        .first = 1265,
        .last = 1265,
    },
    struct_interval{
        .first = 1267,
        .last = 1267,
    },
    struct_interval{
        .first = 1269,
        .last = 1269,
    },
    struct_interval{
        .first = 1271,
        .last = 1271,
    },
    struct_interval{
        .first = 1273,
        .last = 1273,
    },
    struct_interval{
        .first = 1275,
        .last = 1275,
    },
    struct_interval{
        .first = 1277,
        .last = 1277,
    },
    struct_interval{
        .first = 1279,
        .last = 1279,
    },
    struct_interval{
        .first = 1281,
        .last = 1281,
    },
    struct_interval{
        .first = 1283,
        .last = 1283,
    },
    struct_interval{
        .first = 1285,
        .last = 1285,
    },
    struct_interval{
        .first = 1287,
        .last = 1287,
    },
    struct_interval{
        .first = 1289,
        .last = 1289,
    },
    struct_interval{
        .first = 1291,
        .last = 1291,
    },
    struct_interval{
        .first = 1293,
        .last = 1293,
    },
    struct_interval{
        .first = 1295,
        .last = 1295,
    },
    struct_interval{
        .first = 1297,
        .last = 1297,
    },
    struct_interval{
        .first = 1299,
        .last = 1299,
    },
    struct_interval{
        .first = 1301,
        .last = 1301,
    },
    struct_interval{
        .first = 1303,
        .last = 1303,
    },
    struct_interval{
        .first = 1305,
        .last = 1305,
    },
    struct_interval{
        .first = 1307,
        .last = 1307,
    },
    struct_interval{
        .first = 1309,
        .last = 1309,
    },
    struct_interval{
        .first = 1311,
        .last = 1311,
    },
    struct_interval{
        .first = 1313,
        .last = 1313,
    },
    struct_interval{
        .first = 1315,
        .last = 1315,
    },
    struct_interval{
        .first = 1317,
        .last = 1317,
    },
    struct_interval{
        .first = 1319,
        .last = 1319,
    },
    struct_interval{
        .first = 1321,
        .last = 1321,
    },
    struct_interval{
        .first = 1323,
        .last = 1323,
    },
    struct_interval{
        .first = 1325,
        .last = 1325,
    },
    struct_interval{
        .first = 1327,
        .last = 1327,
    },
    struct_interval{
        .first = 1377,
        .last = 1414,
    },
    struct_interval{
        .first = 5112,
        .last = 5117,
    },
    struct_interval{
        .first = 7296,
        .last = 7296,
    },
    struct_interval{
        .first = 7297,
        .last = 7297,
    },
    struct_interval{
        .first = 7298,
        .last = 7298,
    },
    struct_interval{
        .first = 7299,
        .last = 7300,
    },
    struct_interval{
        .first = 7301,
        .last = 7301,
    },
    struct_interval{
        .first = 7302,
        .last = 7302,
    },
    struct_interval{
        .first = 7303,
        .last = 7303,
    },
    struct_interval{
        .first = 7304,
        .last = 7304,
    },
    struct_interval{
        .first = 7306,
        .last = 7306,
    },
    struct_interval{
        .first = 7545,
        .last = 7545,
    },
    struct_interval{
        .first = 7549,
        .last = 7549,
    },
    struct_interval{
        .first = 7566,
        .last = 7566,
    },
    struct_interval{
        .first = 7681,
        .last = 7681,
    },
    struct_interval{
        .first = 7683,
        .last = 7683,
    },
    struct_interval{
        .first = 7685,
        .last = 7685,
    },
    struct_interval{
        .first = 7687,
        .last = 7687,
    },
    struct_interval{
        .first = 7689,
        .last = 7689,
    },
    struct_interval{
        .first = 7691,
        .last = 7691,
    },
    struct_interval{
        .first = 7693,
        .last = 7693,
    },
    struct_interval{
        .first = 7695,
        .last = 7695,
    },
    struct_interval{
        .first = 7697,
        .last = 7697,
    },
    struct_interval{
        .first = 7699,
        .last = 7699,
    },
    struct_interval{
        .first = 7701,
        .last = 7701,
    },
    struct_interval{
        .first = 7703,
        .last = 7703,
    },
    struct_interval{
        .first = 7705,
        .last = 7705,
    },
    struct_interval{
        .first = 7707,
        .last = 7707,
    },
    struct_interval{
        .first = 7709,
        .last = 7709,
    },
    struct_interval{
        .first = 7711,
        .last = 7711,
    },
    struct_interval{
        .first = 7713,
        .last = 7713,
    },
    struct_interval{
        .first = 7715,
        .last = 7715,
    },
    struct_interval{
        .first = 7717,
        .last = 7717,
    },
    struct_interval{
        .first = 7719,
        .last = 7719,
    },
    struct_interval{
        .first = 7721,
        .last = 7721,
    },
    struct_interval{
        .first = 7723,
        .last = 7723,
    },
    struct_interval{
        .first = 7725,
        .last = 7725,
    },
    struct_interval{
        .first = 7727,
        .last = 7727,
    },
    struct_interval{
        .first = 7729,
        .last = 7729,
    },
    struct_interval{
        .first = 7731,
        .last = 7731,
    },
    struct_interval{
        .first = 7733,
        .last = 7733,
    },
    struct_interval{
        .first = 7735,
        .last = 7735,
    },
    struct_interval{
        .first = 7737,
        .last = 7737,
    },
    struct_interval{
        .first = 7739,
        .last = 7739,
    },
    struct_interval{
        .first = 7741,
        .last = 7741,
    },
    struct_interval{
        .first = 7743,
        .last = 7743,
    },
    struct_interval{
        .first = 7745,
        .last = 7745,
    },
    struct_interval{
        .first = 7747,
        .last = 7747,
    },
    struct_interval{
        .first = 7749,
        .last = 7749,
    },
    struct_interval{
        .first = 7751,
        .last = 7751,
    },
    struct_interval{
        .first = 7753,
        .last = 7753,
    },
    struct_interval{
        .first = 7755,
        .last = 7755,
    },
    struct_interval{
        .first = 7757,
        .last = 7757,
    },
    struct_interval{
        .first = 7759,
        .last = 7759,
    },
    struct_interval{
        .first = 7761,
        .last = 7761,
    },
    struct_interval{
        .first = 7763,
        .last = 7763,
    },
    struct_interval{
        .first = 7765,
        .last = 7765,
    },
    struct_interval{
        .first = 7767,
        .last = 7767,
    },
    struct_interval{
        .first = 7769,
        .last = 7769,
    },
    struct_interval{
        .first = 7771,
        .last = 7771,
    },
    struct_interval{
        .first = 7773,
        .last = 7773,
    },
    struct_interval{
        .first = 7775,
        .last = 7775,
    },
    struct_interval{
        .first = 7777,
        .last = 7777,
    },
    struct_interval{
        .first = 7779,
        .last = 7779,
    },
    struct_interval{
        .first = 7781,
        .last = 7781,
    },
    struct_interval{
        .first = 7783,
        .last = 7783,
    },
    struct_interval{
        .first = 7785,
        .last = 7785,
    },
    struct_interval{
        .first = 7787,
        .last = 7787,
    },
    struct_interval{
        .first = 7789,
        .last = 7789,
    },
    struct_interval{
        .first = 7791,
        .last = 7791,
    },
    struct_interval{
        .first = 7793,
        .last = 7793,
    },
    struct_interval{
        .first = 7795,
        .last = 7795,
    },
    struct_interval{
        .first = 7797,
        .last = 7797,
    },
    struct_interval{
        .first = 7799,
        .last = 7799,
    },
    struct_interval{
        .first = 7801,
        .last = 7801,
    },
    struct_interval{
        .first = 7803,
        .last = 7803,
    },
    struct_interval{
        .first = 7805,
        .last = 7805,
    },
    struct_interval{
        .first = 7807,
        .last = 7807,
    },
    struct_interval{
        .first = 7809,
        .last = 7809,
    },
    struct_interval{
        .first = 7811,
        .last = 7811,
    },
    struct_interval{
        .first = 7813,
        .last = 7813,
    },
    struct_interval{
        .first = 7815,
        .last = 7815,
    },
    struct_interval{
        .first = 7817,
        .last = 7817,
    },
    struct_interval{
        .first = 7819,
        .last = 7819,
    },
    struct_interval{
        .first = 7821,
        .last = 7821,
    },
    struct_interval{
        .first = 7823,
        .last = 7823,
    },
    struct_interval{
        .first = 7825,
        .last = 7825,
    },
    struct_interval{
        .first = 7827,
        .last = 7827,
    },
    struct_interval{
        .first = 7829,
        .last = 7829,
    },
    struct_interval{
        .first = 7835,
        .last = 7835,
    },
    struct_interval{
        .first = 7841,
        .last = 7841,
    },
    struct_interval{
        .first = 7843,
        .last = 7843,
    },
    struct_interval{
        .first = 7845,
        .last = 7845,
    },
    struct_interval{
        .first = 7847,
        .last = 7847,
    },
    struct_interval{
        .first = 7849,
        .last = 7849,
    },
    struct_interval{
        .first = 7851,
        .last = 7851,
    },
    struct_interval{
        .first = 7853,
        .last = 7853,
    },
    struct_interval{
        .first = 7855,
        .last = 7855,
    },
    struct_interval{
        .first = 7857,
        .last = 7857,
    },
    struct_interval{
        .first = 7859,
        .last = 7859,
    },
    struct_interval{
        .first = 7861,
        .last = 7861,
    },
    struct_interval{
        .first = 7863,
        .last = 7863,
    },
    struct_interval{
        .first = 7865,
        .last = 7865,
    },
    struct_interval{
        .first = 7867,
        .last = 7867,
    },
    struct_interval{
        .first = 7869,
        .last = 7869,
    },
    struct_interval{
        .first = 7871,
        .last = 7871,
    },
    struct_interval{
        .first = 7873,
        .last = 7873,
    },
    struct_interval{
        .first = 7875,
        .last = 7875,
    },
    struct_interval{
        .first = 7877,
        .last = 7877,
    },
    struct_interval{
        .first = 7879,
        .last = 7879,
    },
    struct_interval{
        .first = 7881,
        .last = 7881,
    },
    struct_interval{
        .first = 7883,
        .last = 7883,
    },
    struct_interval{
        .first = 7885,
        .last = 7885,
    },
    struct_interval{
        .first = 7887,
        .last = 7887,
    },
    struct_interval{
        .first = 7889,
        .last = 7889,
    },
    struct_interval{
        .first = 7891,
        .last = 7891,
    },
    struct_interval{
        .first = 7893,
        .last = 7893,
    },
    struct_interval{
        .first = 7895,
        .last = 7895,
    },
    struct_interval{
        .first = 7897,
        .last = 7897,
    },
    struct_interval{
        .first = 7899,
        .last = 7899,
    },
    struct_interval{
        .first = 7901,
        .last = 7901,
    },
    struct_interval{
        .first = 7903,
        .last = 7903,
    },
    struct_interval{
        .first = 7905,
        .last = 7905,
    },
    struct_interval{
        .first = 7907,
        .last = 7907,
    },
    struct_interval{
        .first = 7909,
        .last = 7909,
    },
    struct_interval{
        .first = 7911,
        .last = 7911,
    },
    struct_interval{
        .first = 7913,
        .last = 7913,
    },
    struct_interval{
        .first = 7915,
        .last = 7915,
    },
    struct_interval{
        .first = 7917,
        .last = 7917,
    },
    struct_interval{
        .first = 7919,
        .last = 7919,
    },
    struct_interval{
        .first = 7921,
        .last = 7921,
    },
    struct_interval{
        .first = 7923,
        .last = 7923,
    },
    struct_interval{
        .first = 7925,
        .last = 7925,
    },
    struct_interval{
        .first = 7927,
        .last = 7927,
    },
    struct_interval{
        .first = 7929,
        .last = 7929,
    },
    struct_interval{
        .first = 7931,
        .last = 7931,
    },
    struct_interval{
        .first = 7933,
        .last = 7933,
    },
    struct_interval{
        .first = 7935,
        .last = 7935,
    },
    struct_interval{
        .first = 7936,
        .last = 7943,
    },
    struct_interval{
        .first = 7952,
        .last = 7957,
    },
    struct_interval{
        .first = 7968,
        .last = 7975,
    },
    struct_interval{
        .first = 7984,
        .last = 7991,
    },
    struct_interval{
        .first = 8000,
        .last = 8005,
    },
    struct_interval{
        .first = 8017,
        .last = 8017,
    },
    struct_interval{
        .first = 8019,
        .last = 8019,
    },
    struct_interval{
        .first = 8021,
        .last = 8021,
    },
    struct_interval{
        .first = 8023,
        .last = 8023,
    },
    struct_interval{
        .first = 8032,
        .last = 8039,
    },
    struct_interval{
        .first = 8048,
        .last = 8049,
    },
    struct_interval{
        .first = 8050,
        .last = 8053,
    },
    struct_interval{
        .first = 8054,
        .last = 8055,
    },
    struct_interval{
        .first = 8056,
        .last = 8057,
    },
    struct_interval{
        .first = 8058,
        .last = 8059,
    },
    struct_interval{
        .first = 8060,
        .last = 8061,
    },
    struct_interval{
        .first = 8064,
        .last = 8071,
    },
    struct_interval{
        .first = 8080,
        .last = 8087,
    },
    struct_interval{
        .first = 8096,
        .last = 8103,
    },
    struct_interval{
        .first = 8112,
        .last = 8113,
    },
    struct_interval{
        .first = 8115,
        .last = 8115,
    },
    struct_interval{
        .first = 8126,
        .last = 8126,
    },
    struct_interval{
        .first = 8131,
        .last = 8131,
    },
    struct_interval{
        .first = 8144,
        .last = 8145,
    },
    struct_interval{
        .first = 8160,
        .last = 8161,
    },
    struct_interval{
        .first = 8165,
        .last = 8165,
    },
    struct_interval{
        .first = 8179,
        .last = 8179,
    },
    struct_interval{
        .first = 8526,
        .last = 8526,
    },
    struct_interval{
        .first = 8560,
        .last = 8575,
    },
    struct_interval{
        .first = 8580,
        .last = 8580,
    },
    struct_interval{
        .first = 9424,
        .last = 9449,
    },
    struct_interval{
        .first = 11312,
        .last = 11359,
    },
    struct_interval{
        .first = 11361,
        .last = 11361,
    },
    struct_interval{
        .first = 11365,
        .last = 11365,
    },
    struct_interval{
        .first = 11366,
        .last = 11366,
    },
    struct_interval{
        .first = 11368,
        .last = 11368,
    },
    struct_interval{
        .first = 11370,
        .last = 11370,
    },
    struct_interval{
        .first = 11372,
        .last = 11372,
    },
    struct_interval{
        .first = 11379,
        .last = 11379,
    },
    struct_interval{
        .first = 11382,
        .last = 11382,
    },
    struct_interval{
        .first = 11393,
        .last = 11393,
    },
    struct_interval{
        .first = 11395,
        .last = 11395,
    },
    struct_interval{
        .first = 11397,
        .last = 11397,
    },
    struct_interval{
        .first = 11399,
        .last = 11399,
    },
    struct_interval{
        .first = 11401,
        .last = 11401,
    },
    struct_interval{
        .first = 11403,
        .last = 11403,
    },
    struct_interval{
        .first = 11405,
        .last = 11405,
    },
    struct_interval{
        .first = 11407,
        .last = 11407,
    },
    struct_interval{
        .first = 11409,
        .last = 11409,
    },
    struct_interval{
        .first = 11411,
        .last = 11411,
    },
    struct_interval{
        .first = 11413,
        .last = 11413,
    },
    struct_interval{
        .first = 11415,
        .last = 11415,
    },
    struct_interval{
        .first = 11417,
        .last = 11417,
    },
    struct_interval{
        .first = 11419,
        .last = 11419,
    },
    struct_interval{
        .first = 11421,
        .last = 11421,
    },
    struct_interval{
        .first = 11423,
        .last = 11423,
    },
    struct_interval{
        .first = 11425,
        .last = 11425,
    },
    struct_interval{
        .first = 11427,
        .last = 11427,
    },
    struct_interval{
        .first = 11429,
        .last = 11429,
    },
    struct_interval{
        .first = 11431,
        .last = 11431,
    },
    struct_interval{
        .first = 11433,
        .last = 11433,
    },
    struct_interval{
        .first = 11435,
        .last = 11435,
    },
    struct_interval{
        .first = 11437,
        .last = 11437,
    },
    struct_interval{
        .first = 11439,
        .last = 11439,
    },
    struct_interval{
        .first = 11441,
        .last = 11441,
    },
    struct_interval{
        .first = 11443,
        .last = 11443,
    },
    struct_interval{
        .first = 11445,
        .last = 11445,
    },
    struct_interval{
        .first = 11447,
        .last = 11447,
    },
    struct_interval{
        .first = 11449,
        .last = 11449,
    },
    struct_interval{
        .first = 11451,
        .last = 11451,
    },
    struct_interval{
        .first = 11453,
        .last = 11453,
    },
    struct_interval{
        .first = 11455,
        .last = 11455,
    },
    struct_interval{
        .first = 11457,
        .last = 11457,
    },
    struct_interval{
        .first = 11459,
        .last = 11459,
    },
    struct_interval{
        .first = 11461,
        .last = 11461,
    },
    struct_interval{
        .first = 11463,
        .last = 11463,
    },
    struct_interval{
        .first = 11465,
        .last = 11465,
    },
    struct_interval{
        .first = 11467,
        .last = 11467,
    },
    struct_interval{
        .first = 11469,
        .last = 11469,
    },
    struct_interval{
        .first = 11471,
        .last = 11471,
    },
    struct_interval{
        .first = 11473,
        .last = 11473,
    },
    struct_interval{
        .first = 11475,
        .last = 11475,
    },
    struct_interval{
        .first = 11477,
        .last = 11477,
    },
    struct_interval{
        .first = 11479,
        .last = 11479,
    },
    struct_interval{
        .first = 11481,
        .last = 11481,
    },
    struct_interval{
        .first = 11483,
        .last = 11483,
    },
    struct_interval{
        .first = 11485,
        .last = 11485,
    },
    struct_interval{
        .first = 11487,
        .last = 11487,
    },
    struct_interval{
        .first = 11489,
        .last = 11489,
    },
    struct_interval{
        .first = 11491,
        .last = 11491,
    },
    struct_interval{
        .first = 11500,
        .last = 11500,
    },
    struct_interval{
        .first = 11502,
        .last = 11502,
    },
    struct_interval{
        .first = 11507,
        .last = 11507,
    },
    struct_interval{
        .first = 11520,
        .last = 11557,
    },
    struct_interval{
        .first = 11559,
        .last = 11559,
    },
    struct_interval{
        .first = 11565,
        .last = 11565,
    },
    struct_interval{
        .first = 42561,
        .last = 42561,
    },
    struct_interval{
        .first = 42563,
        .last = 42563,
    },
    struct_interval{
        .first = 42565,
        .last = 42565,
    },
    struct_interval{
        .first = 42567,
        .last = 42567,
    },
    struct_interval{
        .first = 42569,
        .last = 42569,
    },
    struct_interval{
        .first = 42571,
        .last = 42571,
    },
    struct_interval{
        .first = 42573,
        .last = 42573,
    },
    struct_interval{
        .first = 42575,
        .last = 42575,
    },
    struct_interval{
        .first = 42577,
        .last = 42577,
    },
    struct_interval{
        .first = 42579,
        .last = 42579,
    },
    struct_interval{
        .first = 42581,
        .last = 42581,
    },
    struct_interval{
        .first = 42583,
        .last = 42583,
    },
    struct_interval{
        .first = 42585,
        .last = 42585,
    },
    struct_interval{
        .first = 42587,
        .last = 42587,
    },
    struct_interval{
        .first = 42589,
        .last = 42589,
    },
    struct_interval{
        .first = 42591,
        .last = 42591,
    },
    struct_interval{
        .first = 42593,
        .last = 42593,
    },
    struct_interval{
        .first = 42595,
        .last = 42595,
    },
    struct_interval{
        .first = 42597,
        .last = 42597,
    },
    struct_interval{
        .first = 42599,
        .last = 42599,
    },
    struct_interval{
        .first = 42601,
        .last = 42601,
    },
    struct_interval{
        .first = 42603,
        .last = 42603,
    },
    struct_interval{
        .first = 42605,
        .last = 42605,
    },
    struct_interval{
        .first = 42625,
        .last = 42625,
    },
    struct_interval{
        .first = 42627,
        .last = 42627,
    },
    struct_interval{
        .first = 42629,
        .last = 42629,
    },
    struct_interval{
        .first = 42631,
        .last = 42631,
    },
    struct_interval{
        .first = 42633,
        .last = 42633,
    },
    struct_interval{
        .first = 42635,
        .last = 42635,
    },
    struct_interval{
        .first = 42637,
        .last = 42637,
    },
    struct_interval{
        .first = 42639,
        .last = 42639,
    },
    struct_interval{
        .first = 42641,
        .last = 42641,
    },
    struct_interval{
        .first = 42643,
        .last = 42643,
    },
    struct_interval{
        .first = 42645,
        .last = 42645,
    },
    struct_interval{
        .first = 42647,
        .last = 42647,
    },
    struct_interval{
        .first = 42649,
        .last = 42649,
    },
    struct_interval{
        .first = 42651,
        .last = 42651,
    },
    struct_interval{
        .first = 42787,
        .last = 42787,
    },
    struct_interval{
        .first = 42789,
        .last = 42789,
    },
    struct_interval{
        .first = 42791,
        .last = 42791,
    },
    struct_interval{
        .first = 42793,
        .last = 42793,
    },
    struct_interval{
        .first = 42795,
        .last = 42795,
    },
    struct_interval{
        .first = 42797,
        .last = 42797,
    },
    struct_interval{
        .first = 42799,
        .last = 42799,
    },
    struct_interval{
        .first = 42803,
        .last = 42803,
    },
    struct_interval{
        .first = 42805,
        .last = 42805,
    },
    struct_interval{
        .first = 42807,
        .last = 42807,
    },
    struct_interval{
        .first = 42809,
        .last = 42809,
    },
    struct_interval{
        .first = 42811,
        .last = 42811,
    },
    struct_interval{
        .first = 42813,
        .last = 42813,
    },
    struct_interval{
        .first = 42815,
        .last = 42815,
    },
    struct_interval{
        .first = 42817,
        .last = 42817,
    },
    struct_interval{
        .first = 42819,
        .last = 42819,
    },
    struct_interval{
        .first = 42821,
        .last = 42821,
    },
    struct_interval{
        .first = 42823,
        .last = 42823,
    },
    struct_interval{
        .first = 42825,
        .last = 42825,
    },
    struct_interval{
        .first = 42827,
        .last = 42827,
    },
    struct_interval{
        .first = 42829,
        .last = 42829,
    },
    struct_interval{
        .first = 42831,
        .last = 42831,
    },
    struct_interval{
        .first = 42833,
        .last = 42833,
    },
    struct_interval{
        .first = 42835,
        .last = 42835,
    },
    struct_interval{
        .first = 42837,
        .last = 42837,
    },
    struct_interval{
        .first = 42839,
        .last = 42839,
    },
    struct_interval{
        .first = 42841,
        .last = 42841,
    },
    struct_interval{
        .first = 42843,
        .last = 42843,
    },
    struct_interval{
        .first = 42845,
        .last = 42845,
    },
    struct_interval{
        .first = 42847,
        .last = 42847,
    },
    struct_interval{
        .first = 42849,
        .last = 42849,
    },
    struct_interval{
        .first = 42851,
        .last = 42851,
    },
    struct_interval{
        .first = 42853,
        .last = 42853,
    },
    struct_interval{
        .first = 42855,
        .last = 42855,
    },
    struct_interval{
        .first = 42857,
        .last = 42857,
    },
    struct_interval{
        .first = 42859,
        .last = 42859,
    },
    struct_interval{
        .first = 42861,
        .last = 42861,
    },
    struct_interval{
        .first = 42863,
        .last = 42863,
    },
    struct_interval{
        .first = 42874,
        .last = 42874,
    },
    struct_interval{
        .first = 42876,
        .last = 42876,
    },
    struct_interval{
        .first = 42879,
        .last = 42879,
    },
    struct_interval{
        .first = 42881,
        .last = 42881,
    },
    struct_interval{
        .first = 42883,
        .last = 42883,
    },
    struct_interval{
        .first = 42885,
        .last = 42885,
    },
    struct_interval{
        .first = 42887,
        .last = 42887,
    },
    struct_interval{
        .first = 42892,
        .last = 42892,
    },
    struct_interval{
        .first = 42897,
        .last = 42897,
    },
    struct_interval{
        .first = 42899,
        .last = 42899,
    },
    struct_interval{
        .first = 42900,
        .last = 42900,
    },
    struct_interval{
        .first = 42903,
        .last = 42903,
    },
    struct_interval{
        .first = 42905,
        .last = 42905,
    },
    struct_interval{
        .first = 42907,
        .last = 42907,
    },
    struct_interval{
        .first = 42909,
        .last = 42909,
    },
    struct_interval{
        .first = 42911,
        .last = 42911,
    },
    struct_interval{
        .first = 42913,
        .last = 42913,
    },
    struct_interval{
        .first = 42915,
        .last = 42915,
    },
    struct_interval{
        .first = 42917,
        .last = 42917,
    },
    struct_interval{
        .first = 42919,
        .last = 42919,
    },
    struct_interval{
        .first = 42921,
        .last = 42921,
    },
    struct_interval{
        .first = 42933,
        .last = 42933,
    },
    struct_interval{
        .first = 42935,
        .last = 42935,
    },
    struct_interval{
        .first = 42937,
        .last = 42937,
    },
    struct_interval{
        .first = 42939,
        .last = 42939,
    },
    struct_interval{
        .first = 42941,
        .last = 42941,
    },
    struct_interval{
        .first = 42943,
        .last = 42943,
    },
    struct_interval{
        .first = 42945,
        .last = 42945,
    },
    struct_interval{
        .first = 42947,
        .last = 42947,
    },
    struct_interval{
        .first = 42952,
        .last = 42952,
    },
    struct_interval{
        .first = 42954,
        .last = 42954,
    },
    struct_interval{
        .first = 42957,
        .last = 42957,
    },
    struct_interval{
        .first = 42959,
        .last = 42959,
    },
    struct_interval{
        .first = 42961,
        .last = 42961,
    },
    struct_interval{
        .first = 42963,
        .last = 42963,
    },
    struct_interval{
        .first = 42965,
        .last = 42965,
    },
    struct_interval{
        .first = 42967,
        .last = 42967,
    },
    struct_interval{
        .first = 42969,
        .last = 42969,
    },
    struct_interval{
        .first = 42971,
        .last = 42971,
    },
    struct_interval{
        .first = 42998,
        .last = 42998,
    },
    struct_interval{
        .first = 43859,
        .last = 43859,
    },
    struct_interval{
        .first = 43888,
        .last = 43967,
    },
    struct_interval{
        .first = 65345,
        .last = 65370,
    },
    struct_interval{
        .first = 66600,
        .last = 66639,
    },
    struct_interval{
        .first = 66776,
        .last = 66811,
    },
    struct_interval{
        .first = 66967,
        .last = 66977,
    },
    struct_interval{
        .first = 66979,
        .last = 66993,
    },
    struct_interval{
        .first = 66995,
        .last = 67001,
    },
    struct_interval{
        .first = 67003,
        .last = 67004,
    },
    struct_interval{
        .first = 68800,
        .last = 68850,
    },
    struct_interval{
        .first = 68976,
        .last = 68997,
    },
    struct_interval{
        .first = 71872,
        .last = 71903,
    },
    struct_interval{
        .first = 93792,
        .last = 93823,
    },
    struct_interval{
        .first = 93883,
        .last = 93907,
    },
    struct_interval{
        .first = 125218,
        .last = 125251,
    },
    struct_interval{
        .first = 0,
        .last = 0,
    },
};
pub export const totitle_cvt: [693]c_int = [693]c_int{
    65,
    924,
    192,
    216,
    376,
    256,
    258,
    260,
    262,
    264,
    266,
    268,
    270,
    272,
    274,
    276,
    278,
    280,
    282,
    284,
    286,
    288,
    290,
    292,
    294,
    296,
    298,
    300,
    302,
    73,
    306,
    308,
    310,
    313,
    315,
    317,
    319,
    321,
    323,
    325,
    327,
    330,
    332,
    334,
    336,
    338,
    340,
    342,
    344,
    346,
    348,
    350,
    352,
    354,
    356,
    358,
    360,
    362,
    364,
    366,
    368,
    370,
    372,
    374,
    377,
    379,
    381,
    83,
    579,
    386,
    388,
    391,
    395,
    401,
    502,
    408,
    573,
    42972,
    544,
    416,
    418,
    420,
    423,
    428,
    431,
    435,
    437,
    440,
    444,
    503,
    453,
    453,
    456,
    456,
    459,
    459,
    461,
    463,
    465,
    467,
    469,
    471,
    473,
    475,
    398,
    478,
    480,
    482,
    484,
    486,
    488,
    490,
    492,
    494,
    498,
    498,
    500,
    504,
    506,
    508,
    510,
    512,
    514,
    516,
    518,
    520,
    522,
    524,
    526,
    528,
    530,
    532,
    534,
    536,
    538,
    540,
    542,
    546,
    548,
    550,
    552,
    554,
    556,
    558,
    560,
    562,
    571,
    11390,
    577,
    582,
    584,
    586,
    588,
    590,
    11375,
    11373,
    11376,
    385,
    390,
    393,
    399,
    400,
    42923,
    403,
    42924,
    404,
    42955,
    42893,
    42922,
    407,
    406,
    42926,
    11362,
    42925,
    412,
    11374,
    413,
    415,
    11364,
    422,
    42949,
    425,
    42929,
    430,
    580,
    433,
    581,
    439,
    42930,
    42928,
    921,
    880,
    882,
    886,
    1021,
    902,
    904,
    913,
    931,
    931,
    908,
    910,
    914,
    920,
    934,
    928,
    975,
    984,
    986,
    988,
    990,
    992,
    994,
    996,
    998,
    1000,
    1002,
    1004,
    1006,
    922,
    929,
    1017,
    895,
    917,
    1015,
    1018,
    1040,
    1024,
    1120,
    1122,
    1124,
    1126,
    1128,
    1130,
    1132,
    1134,
    1136,
    1138,
    1140,
    1142,
    1144,
    1146,
    1148,
    1150,
    1152,
    1162,
    1164,
    1166,
    1168,
    1170,
    1172,
    1174,
    1176,
    1178,
    1180,
    1182,
    1184,
    1186,
    1188,
    1190,
    1192,
    1194,
    1196,
    1198,
    1200,
    1202,
    1204,
    1206,
    1208,
    1210,
    1212,
    1214,
    1217,
    1219,
    1221,
    1223,
    1225,
    1227,
    1229,
    1216,
    1232,
    1234,
    1236,
    1238,
    1240,
    1242,
    1244,
    1246,
    1248,
    1250,
    1252,
    1254,
    1256,
    1258,
    1260,
    1262,
    1264,
    1266,
    1268,
    1270,
    1272,
    1274,
    1276,
    1278,
    1280,
    1282,
    1284,
    1286,
    1288,
    1290,
    1292,
    1294,
    1296,
    1298,
    1300,
    1302,
    1304,
    1306,
    1308,
    1310,
    1312,
    1314,
    1316,
    1318,
    1320,
    1322,
    1324,
    1326,
    1329,
    5104,
    1042,
    1044,
    1054,
    1057,
    1058,
    1066,
    1122,
    42570,
    7305,
    42877,
    11363,
    42950,
    7680,
    7682,
    7684,
    7686,
    7688,
    7690,
    7692,
    7694,
    7696,
    7698,
    7700,
    7702,
    7704,
    7706,
    7708,
    7710,
    7712,
    7714,
    7716,
    7718,
    7720,
    7722,
    7724,
    7726,
    7728,
    7730,
    7732,
    7734,
    7736,
    7738,
    7740,
    7742,
    7744,
    7746,
    7748,
    7750,
    7752,
    7754,
    7756,
    7758,
    7760,
    7762,
    7764,
    7766,
    7768,
    7770,
    7772,
    7774,
    7776,
    7778,
    7780,
    7782,
    7784,
    7786,
    7788,
    7790,
    7792,
    7794,
    7796,
    7798,
    7800,
    7802,
    7804,
    7806,
    7808,
    7810,
    7812,
    7814,
    7816,
    7818,
    7820,
    7822,
    7824,
    7826,
    7828,
    7776,
    7840,
    7842,
    7844,
    7846,
    7848,
    7850,
    7852,
    7854,
    7856,
    7858,
    7860,
    7862,
    7864,
    7866,
    7868,
    7870,
    7872,
    7874,
    7876,
    7878,
    7880,
    7882,
    7884,
    7886,
    7888,
    7890,
    7892,
    7894,
    7896,
    7898,
    7900,
    7902,
    7904,
    7906,
    7908,
    7910,
    7912,
    7914,
    7916,
    7918,
    7920,
    7922,
    7924,
    7926,
    7928,
    7930,
    7932,
    7934,
    7944,
    7960,
    7976,
    7992,
    8008,
    8025,
    8027,
    8029,
    8031,
    8040,
    8122,
    8136,
    8154,
    8184,
    8170,
    8186,
    8072,
    8088,
    8104,
    8120,
    8124,
    921,
    8140,
    8152,
    8168,
    8172,
    8188,
    8498,
    8544,
    8579,
    9398,
    11264,
    11360,
    570,
    574,
    11367,
    11369,
    11371,
    11378,
    11381,
    11392,
    11394,
    11396,
    11398,
    11400,
    11402,
    11404,
    11406,
    11408,
    11410,
    11412,
    11414,
    11416,
    11418,
    11420,
    11422,
    11424,
    11426,
    11428,
    11430,
    11432,
    11434,
    11436,
    11438,
    11440,
    11442,
    11444,
    11446,
    11448,
    11450,
    11452,
    11454,
    11456,
    11458,
    11460,
    11462,
    11464,
    11466,
    11468,
    11470,
    11472,
    11474,
    11476,
    11478,
    11480,
    11482,
    11484,
    11486,
    11488,
    11490,
    11499,
    11501,
    11506,
    4256,
    4295,
    4301,
    42560,
    42562,
    42564,
    42566,
    42568,
    42570,
    42572,
    42574,
    42576,
    42578,
    42580,
    42582,
    42584,
    42586,
    42588,
    42590,
    42592,
    42594,
    42596,
    42598,
    42600,
    42602,
    42604,
    42624,
    42626,
    42628,
    42630,
    42632,
    42634,
    42636,
    42638,
    42640,
    42642,
    42644,
    42646,
    42648,
    42650,
    42786,
    42788,
    42790,
    42792,
    42794,
    42796,
    42798,
    42802,
    42804,
    42806,
    42808,
    42810,
    42812,
    42814,
    42816,
    42818,
    42820,
    42822,
    42824,
    42826,
    42828,
    42830,
    42832,
    42834,
    42836,
    42838,
    42840,
    42842,
    42844,
    42846,
    42848,
    42850,
    42852,
    42854,
    42856,
    42858,
    42860,
    42862,
    42873,
    42875,
    42878,
    42880,
    42882,
    42884,
    42886,
    42891,
    42896,
    42898,
    42948,
    42902,
    42904,
    42906,
    42908,
    42910,
    42912,
    42914,
    42916,
    42918,
    42920,
    42932,
    42934,
    42936,
    42938,
    42940,
    42942,
    42944,
    42946,
    42951,
    42953,
    42956,
    42958,
    42960,
    42962,
    42964,
    42966,
    42968,
    42970,
    42997,
    42931,
    5024,
    65313,
    66560,
    66736,
    66928,
    66940,
    66956,
    66964,
    68736,
    68944,
    71840,
    93760,
    93856,
    125184,
    0,
};
pub export const unicat: [376]struct_unicat = [376]struct_unicat{
    struct_unicat{
        .name = "Co",
        .len = 3,
        .intervals = @ptrCast(@alignCast(&Co_table)),
    },
    struct_unicat{
        .name = "Cs",
        .len = 1,
        .intervals = @ptrCast(@alignCast(&Cs_table)),
    },
    struct_unicat{
        .name = "Zp",
        .len = 1,
        .intervals = @ptrCast(@alignCast(&Zp_table)),
    },
    struct_unicat{
        .name = "Zl",
        .len = 1,
        .intervals = @ptrCast(@alignCast(&Zl_table)),
    },
    struct_unicat{
        .name = "Nl",
        .len = 13,
        .intervals = @ptrCast(@alignCast(&Nl_table)),
    },
    struct_unicat{
        .name = "Mc",
        .len = 193,
        .intervals = @ptrCast(@alignCast(&Mc_table)),
    },
    struct_unicat{
        .name = "Me",
        .len = 5,
        .intervals = @ptrCast(@alignCast(&Me_table)),
    },
    struct_unicat{
        .name = "Mn",
        .len = 365,
        .intervals = @ptrCast(@alignCast(&Mn_table)),
    },
    struct_unicat{
        .name = "Lm",
        .len = 79,
        .intervals = @ptrCast(@alignCast(&Lm_table)),
    },
    struct_unicat{
        .name = "Lt",
        .len = 10,
        .intervals = @ptrCast(@alignCast(&Lt_table)),
    },
    struct_unicat{
        .name = "Pf",
        .len = 10,
        .intervals = @ptrCast(@alignCast(&Pf_table)),
    },
    struct_unicat{
        .name = "No",
        .len = 72,
        .intervals = @ptrCast(@alignCast(&No_table)),
    },
    struct_unicat{
        .name = "Cf",
        .len = 21,
        .intervals = @ptrCast(@alignCast(&Cf_table)),
    },
    struct_unicat{
        .name = "Pi",
        .len = 11,
        .intervals = @ptrCast(@alignCast(&Pi_table)),
    },
    struct_unicat{
        .name = "Lo",
        .len = 537,
        .intervals = @ptrCast(@alignCast(&Lo_table)),
    },
    struct_unicat{
        .name = "So",
        .len = 193,
        .intervals = @ptrCast(@alignCast(&So_table)),
    },
    struct_unicat{
        .name = "Ll",
        .len = 664,
        .intervals = @ptrCast(@alignCast(&Ll_table)),
    },
    struct_unicat{
        .name = "Pc",
        .len = 6,
        .intervals = @ptrCast(@alignCast(&Pc_table)),
    },
    struct_unicat{
        .name = "Sk",
        .len = 31,
        .intervals = @ptrCast(@alignCast(&Sk_table)),
    },
    struct_unicat{
        .name = "Lu",
        .len = 655,
        .intervals = @ptrCast(@alignCast(&Lu_table)),
    },
    struct_unicat{
        .name = "Nd",
        .len = 77,
        .intervals = @ptrCast(@alignCast(&Nd_table)),
    },
    struct_unicat{
        .name = "Pd",
        .len = 20,
        .intervals = @ptrCast(@alignCast(&Pd_table)),
    },
    struct_unicat{
        .name = "Sm",
        .len = 67,
        .intervals = @ptrCast(@alignCast(&Sm_table)),
    },
    struct_unicat{
        .name = "Pe",
        .len = 76,
        .intervals = @ptrCast(@alignCast(&Pe_table)),
    },
    struct_unicat{
        .name = "Ps",
        .len = 79,
        .intervals = @ptrCast(@alignCast(&Ps_table)),
    },
    struct_unicat{
        .name = "Sc",
        .len = 21,
        .intervals = @ptrCast(@alignCast(&Sc_table)),
    },
    struct_unicat{
        .name = "Po",
        .len = 194,
        .intervals = @ptrCast(@alignCast(&Po_table)),
    },
    struct_unicat{
        .name = "Zs",
        .len = 7,
        .intervals = @ptrCast(@alignCast(&Zs_table)),
    },
    struct_unicat{
        .name = "Cc",
        .len = 2,
        .intervals = @ptrCast(@alignCast(&Cc_table)),
    },
    struct_unicat{
        .name = "Supplementary Private Use Area-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 345))))),
    },
    struct_unicat{
        .name = "Supplementary Private Use Area-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 344))))),
    },
    struct_unicat{
        .name = "Variation Selectors Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 343))))),
    },
    struct_unicat{
        .name = "Tags",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 342))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension J",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 341))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension H",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 340))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension G",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 339))))),
    },
    struct_unicat{
        .name = "CJK Compatibility Ideographs Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 338))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension I",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 337))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension F",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 336))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension E",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 335))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension D",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 334))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 333))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 332))))),
    },
    struct_unicat{
        .name = "Symbols for Legacy Computing",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 331))))),
    },
    struct_unicat{
        .name = "Symbols and Pictographs Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 330))))),
    },
    struct_unicat{
        .name = "Chess Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 329))))),
    },
    struct_unicat{
        .name = "Supplemental Symbols and Pictographs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 328))))),
    },
    struct_unicat{
        .name = "Supplemental Arrows-C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 327))))),
    },
    struct_unicat{
        .name = "Geometric Shapes Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 326))))),
    },
    struct_unicat{
        .name = "Alchemical Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 325))))),
    },
    struct_unicat{
        .name = "Transport and Map Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 324))))),
    },
    struct_unicat{
        .name = "Ornamental Dingbats",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 323))))),
    },
    struct_unicat{
        .name = "Emoticons",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 322))))),
    },
    struct_unicat{
        .name = "Miscellaneous Symbols and Pictographs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 321))))),
    },
    struct_unicat{
        .name = "Enclosed Ideographic Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 320))))),
    },
    struct_unicat{
        .name = "Enclosed Alphanumeric Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 319))))),
    },
    struct_unicat{
        .name = "Playing Cards",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 318))))),
    },
    struct_unicat{
        .name = "Domino Tiles",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 317))))),
    },
    struct_unicat{
        .name = "Mahjong Tiles",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 316))))),
    },
    struct_unicat{
        .name = "Arabic Mathematical Alphabetic Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 315))))),
    },
    struct_unicat{
        .name = "Ottoman Siyaq Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 314))))),
    },
    struct_unicat{
        .name = "Indic Siyaq Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 313))))),
    },
    struct_unicat{
        .name = "Adlam",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 312))))),
    },
    struct_unicat{
        .name = "Mende Kikakui",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 311))))),
    },
    struct_unicat{
        .name = "Ethiopic Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 310))))),
    },
    struct_unicat{
        .name = "Tai Yo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 309))))),
    },
    struct_unicat{
        .name = "Ol Onal",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 308))))),
    },
    struct_unicat{
        .name = "Nag Mundari",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 307))))),
    },
    struct_unicat{
        .name = "Wancho",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 306))))),
    },
    struct_unicat{
        .name = "Toto",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 305))))),
    },
    struct_unicat{
        .name = "Nyiakeng Puachue Hmong",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 304))))),
    },
    struct_unicat{
        .name = "Cyrillic Extended-D",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 303))))),
    },
    struct_unicat{
        .name = "Glagolitic Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 302))))),
    },
    struct_unicat{
        .name = "Latin Extended-G",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 301))))),
    },
    struct_unicat{
        .name = "Sutton SignWriting",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 300))))),
    },
    struct_unicat{
        .name = "Mathematical Alphanumeric Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 299))))),
    },
    struct_unicat{
        .name = "Counting Rod Numerals",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 298))))),
    },
    struct_unicat{
        .name = "Tai Xuan Jing Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 297))))),
    },
    struct_unicat{
        .name = "Mayan Numerals",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 296))))),
    },
    struct_unicat{
        .name = "Kaktovik Numerals",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 295))))),
    },
    struct_unicat{
        .name = "Ancient Greek Musical Notation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 294))))),
    },
    struct_unicat{
        .name = "Musical Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 293))))),
    },
    struct_unicat{
        .name = "Byzantine Musical Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 292))))),
    },
    struct_unicat{
        .name = "Znamenny Musical Notation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 291))))),
    },
    struct_unicat{
        .name = "Miscellaneous Symbols Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 290))))),
    },
    struct_unicat{
        .name = "Symbols for Legacy Computing Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 289))))),
    },
    struct_unicat{
        .name = "Shorthand Format Controls",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 288))))),
    },
    struct_unicat{
        .name = "Duployan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 287))))),
    },
    struct_unicat{
        .name = "Nushu",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 286))))),
    },
    struct_unicat{
        .name = "Small Kana Extension",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 285))))),
    },
    struct_unicat{
        .name = "Kana Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 284))))),
    },
    struct_unicat{
        .name = "Kana Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 283))))),
    },
    struct_unicat{
        .name = "Kana Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 282))))),
    },
    struct_unicat{
        .name = "Tangut Components Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 281))))),
    },
    struct_unicat{
        .name = "Tangut Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 280))))),
    },
    struct_unicat{
        .name = "Khitan Small Script",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 279))))),
    },
    struct_unicat{
        .name = "Tangut Components",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 278))))),
    },
    struct_unicat{
        .name = "Tangut",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 277))))),
    },
    struct_unicat{
        .name = "Ideographic Symbols and Punctuation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 276))))),
    },
    struct_unicat{
        .name = "Miao",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 275))))),
    },
    struct_unicat{
        .name = "Beria Erfe",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 274))))),
    },
    struct_unicat{
        .name = "Medefaidrin",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 273))))),
    },
    struct_unicat{
        .name = "Kirat Rai",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 272))))),
    },
    struct_unicat{
        .name = "Pahawh Hmong",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 271))))),
    },
    struct_unicat{
        .name = "Bassa Vah",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 270))))),
    },
    struct_unicat{
        .name = "Tangsa",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 269))))),
    },
    struct_unicat{
        .name = "Mro",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 268))))),
    },
    struct_unicat{
        .name = "Bamum Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 267))))),
    },
    struct_unicat{
        .name = "Gurung Khema",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 266))))),
    },
    struct_unicat{
        .name = "Anatolian Hieroglyphs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 265))))),
    },
    struct_unicat{
        .name = "Egyptian Hieroglyphs Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 264))))),
    },
    struct_unicat{
        .name = "Egyptian Hieroglyph Format Controls",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 263))))),
    },
    struct_unicat{
        .name = "Egyptian Hieroglyphs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 262))))),
    },
    struct_unicat{
        .name = "Cypro-Minoan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 261))))),
    },
    struct_unicat{
        .name = "Early Dynastic Cuneiform",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 260))))),
    },
    struct_unicat{
        .name = "Cuneiform Numbers and Punctuation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 259))))),
    },
    struct_unicat{
        .name = "Cuneiform",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 258))))),
    },
    struct_unicat{
        .name = "Tamil Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 257))))),
    },
    struct_unicat{
        .name = "Lisu Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 256))))),
    },
    struct_unicat{
        .name = "Kawi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 255))))),
    },
    struct_unicat{
        .name = "Makasar",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 254))))),
    },
    struct_unicat{
        .name = "Tolong Siki",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 253))))),
    },
    struct_unicat{
        .name = "Gunjala Gondi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 252))))),
    },
    struct_unicat{
        .name = "Masaram Gondi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 251))))),
    },
    struct_unicat{
        .name = "Marchen",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 250))))),
    },
    struct_unicat{
        .name = "Bhaiksuki",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 249))))),
    },
    struct_unicat{
        .name = "Sunuwar",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 248))))),
    },
    struct_unicat{
        .name = "Sharada Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 247))))),
    },
    struct_unicat{
        .name = "Devanagari Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 246))))),
    },
    struct_unicat{
        .name = "Pau Cin Hau",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 245))))),
    },
    struct_unicat{
        .name = "Unified Canadian Aboriginal Syllabics Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 244))))),
    },
    struct_unicat{
        .name = "Soyombo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 243))))),
    },
    struct_unicat{
        .name = "Zanabazar Square",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 242))))),
    },
    struct_unicat{
        .name = "Nandinagari",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 241))))),
    },
    struct_unicat{
        .name = "Dives Akuru",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 240))))),
    },
    struct_unicat{
        .name = "Warang Citi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 239))))),
    },
    struct_unicat{
        .name = "Dogra",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 238))))),
    },
    struct_unicat{
        .name = "Ahom",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 237))))),
    },
    struct_unicat{
        .name = "Myanmar Extended-C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 236))))),
    },
    struct_unicat{
        .name = "Takri",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 235))))),
    },
    struct_unicat{
        .name = "Mongolian Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 234))))),
    },
    struct_unicat{
        .name = "Modi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 233))))),
    },
    struct_unicat{
        .name = "Siddham",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 232))))),
    },
    struct_unicat{
        .name = "Tirhuta",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 231))))),
    },
    struct_unicat{
        .name = "Newa",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 230))))),
    },
    struct_unicat{
        .name = "Tulu-Tigalari",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 229))))),
    },
    struct_unicat{
        .name = "Grantha",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 228))))),
    },
    struct_unicat{
        .name = "Khudawadi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 227))))),
    },
    struct_unicat{
        .name = "Multani",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 226))))),
    },
    struct_unicat{
        .name = "Khojki",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 225))))),
    },
    struct_unicat{
        .name = "Sinhala Archaic Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 224))))),
    },
    struct_unicat{
        .name = "Sharada",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 223))))),
    },
    struct_unicat{
        .name = "Mahajani",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 222))))),
    },
    struct_unicat{
        .name = "Chakma",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 221))))),
    },
    struct_unicat{
        .name = "Sora Sompeng",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 220))))),
    },
    struct_unicat{
        .name = "Kaithi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 219))))),
    },
    struct_unicat{
        .name = "Brahmi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 218))))),
    },
    struct_unicat{
        .name = "Elymaic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 217))))),
    },
    struct_unicat{
        .name = "Chorasmian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 216))))),
    },
    struct_unicat{
        .name = "Old Uyghur",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 215))))),
    },
    struct_unicat{
        .name = "Sogdian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 214))))),
    },
    struct_unicat{
        .name = "Old Sogdian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 213))))),
    },
    struct_unicat{
        .name = "Arabic Extended-C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 212))))),
    },
    struct_unicat{
        .name = "Yezidi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 211))))),
    },
    struct_unicat{
        .name = "Rumi Numeral Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 210))))),
    },
    struct_unicat{
        .name = "Garay",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 209))))),
    },
    struct_unicat{
        .name = "Hanifi Rohingya",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 208))))),
    },
    struct_unicat{
        .name = "Old Hungarian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 207))))),
    },
    struct_unicat{
        .name = "Old Turkic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 206))))),
    },
    struct_unicat{
        .name = "Psalter Pahlavi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 205))))),
    },
    struct_unicat{
        .name = "Inscriptional Pahlavi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 204))))),
    },
    struct_unicat{
        .name = "Inscriptional Parthian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 203))))),
    },
    struct_unicat{
        .name = "Avestan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 202))))),
    },
    struct_unicat{
        .name = "Manichaean",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 201))))),
    },
    struct_unicat{
        .name = "Old North Arabian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 200))))),
    },
    struct_unicat{
        .name = "Old South Arabian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 199))))),
    },
    struct_unicat{
        .name = "Kharoshthi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 198))))),
    },
    struct_unicat{
        .name = "Meroitic Cursive",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 197))))),
    },
    struct_unicat{
        .name = "Meroitic Hieroglyphs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 196))))),
    },
    struct_unicat{
        .name = "Sidetic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 195))))),
    },
    struct_unicat{
        .name = "Lydian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 194))))),
    },
    struct_unicat{
        .name = "Phoenician",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 193))))),
    },
    struct_unicat{
        .name = "Hatran",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 192))))),
    },
    struct_unicat{
        .name = "Nabataean",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 191))))),
    },
    struct_unicat{
        .name = "Palmyrene",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 190))))),
    },
    struct_unicat{
        .name = "Imperial Aramaic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 189))))),
    },
    struct_unicat{
        .name = "Cypriot Syllabary",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 188))))),
    },
    struct_unicat{
        .name = "Latin Extended-F",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 187))))),
    },
    struct_unicat{
        .name = "Linear A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 186))))),
    },
    struct_unicat{
        .name = "Todhri",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 185))))),
    },
    struct_unicat{
        .name = "Vithkuqi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 184))))),
    },
    struct_unicat{
        .name = "Caucasian Albanian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 183))))),
    },
    struct_unicat{
        .name = "Elbasan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 182))))),
    },
    struct_unicat{
        .name = "Osage",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 181))))),
    },
    struct_unicat{
        .name = "Osmanya",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 180))))),
    },
    struct_unicat{
        .name = "Shavian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 179))))),
    },
    struct_unicat{
        .name = "Deseret",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 178))))),
    },
    struct_unicat{
        .name = "Old Persian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 177))))),
    },
    struct_unicat{
        .name = "Ugaritic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 176))))),
    },
    struct_unicat{
        .name = "Old Permic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 175))))),
    },
    struct_unicat{
        .name = "Gothic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 174))))),
    },
    struct_unicat{
        .name = "Old Italic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 173))))),
    },
    struct_unicat{
        .name = "Coptic Epact Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 172))))),
    },
    struct_unicat{
        .name = "Carian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 171))))),
    },
    struct_unicat{
        .name = "Lycian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 170))))),
    },
    struct_unicat{
        .name = "Phaistos Disc",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 169))))),
    },
    struct_unicat{
        .name = "Ancient Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 168))))),
    },
    struct_unicat{
        .name = "Ancient Greek Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 167))))),
    },
    struct_unicat{
        .name = "Aegean Numbers",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 166))))),
    },
    struct_unicat{
        .name = "Linear B Ideograms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 165))))),
    },
    struct_unicat{
        .name = "Linear B Syllabary",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 164))))),
    },
    struct_unicat{
        .name = "Specials",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 163))))),
    },
    struct_unicat{
        .name = "Halfwidth and Fullwidth Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 162))))),
    },
    struct_unicat{
        .name = "Arabic Presentation Forms-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 161))))),
    },
    struct_unicat{
        .name = "Small Form Variants",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 160))))),
    },
    struct_unicat{
        .name = "CJK Compatibility Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 159))))),
    },
    struct_unicat{
        .name = "Combining Half Marks",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 158))))),
    },
    struct_unicat{
        .name = "Vertical Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 157))))),
    },
    struct_unicat{
        .name = "Variation Selectors",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 156))))),
    },
    struct_unicat{
        .name = "Arabic Presentation Forms-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 155))))),
    },
    struct_unicat{
        .name = "Alphabetic Presentation Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 154))))),
    },
    struct_unicat{
        .name = "CJK Compatibility Ideographs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 153))))),
    },
    struct_unicat{
        .name = "Private Use Area",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 152))))),
    },
    struct_unicat{
        .name = "Low Surrogates",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 151))))),
    },
    struct_unicat{
        .name = "High Private Use Surrogates",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 150))))),
    },
    struct_unicat{
        .name = "High Surrogates",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 149))))),
    },
    struct_unicat{
        .name = "Hangul Jamo Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 148))))),
    },
    struct_unicat{
        .name = "Hangul Syllables",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 147))))),
    },
    struct_unicat{
        .name = "Meetei Mayek",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 146))))),
    },
    struct_unicat{
        .name = "Cherokee Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 145))))),
    },
    struct_unicat{
        .name = "Latin Extended-E",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 144))))),
    },
    struct_unicat{
        .name = "Ethiopic Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 143))))),
    },
    struct_unicat{
        .name = "Meetei Mayek Extensions",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 142))))),
    },
    struct_unicat{
        .name = "Tai Viet",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 141))))),
    },
    struct_unicat{
        .name = "Myanmar Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 140))))),
    },
    struct_unicat{
        .name = "Cham",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 139))))),
    },
    struct_unicat{
        .name = "Myanmar Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 138))))),
    },
    struct_unicat{
        .name = "Javanese",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 137))))),
    },
    struct_unicat{
        .name = "Hangul Jamo Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 136))))),
    },
    struct_unicat{
        .name = "Rejang",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 135))))),
    },
    struct_unicat{
        .name = "Kayah Li",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 134))))),
    },
    struct_unicat{
        .name = "Devanagari Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 133))))),
    },
    struct_unicat{
        .name = "Saurashtra",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 132))))),
    },
    struct_unicat{
        .name = "Phags-pa",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 131))))),
    },
    struct_unicat{
        .name = "Common Indic Number Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 130))))),
    },
    struct_unicat{
        .name = "Syloti Nagri",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 129))))),
    },
    struct_unicat{
        .name = "Latin Extended-D",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 128))))),
    },
    struct_unicat{
        .name = "Modifier Tone Letters",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 127))))),
    },
    struct_unicat{
        .name = "Bamum",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 126))))),
    },
    struct_unicat{
        .name = "Cyrillic Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 125))))),
    },
    struct_unicat{
        .name = "Vai",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 124))))),
    },
    struct_unicat{
        .name = "Lisu",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 123))))),
    },
    struct_unicat{
        .name = "Yi Radicals",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 122))))),
    },
    struct_unicat{
        .name = "Yi Syllables",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 121))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 120))))),
    },
    struct_unicat{
        .name = "Yijing Hexagram Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 119))))),
    },
    struct_unicat{
        .name = "CJK Unified Ideographs Extension A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 118))))),
    },
    struct_unicat{
        .name = "CJK Compatibility",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 117))))),
    },
    struct_unicat{
        .name = "Enclosed CJK Letters and Months",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 116))))),
    },
    struct_unicat{
        .name = "Katakana Phonetic Extensions",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 115))))),
    },
    struct_unicat{
        .name = "CJK Strokes",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 114))))),
    },
    struct_unicat{
        .name = "Bopomofo Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 113))))),
    },
    struct_unicat{
        .name = "Kanbun",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 112))))),
    },
    struct_unicat{
        .name = "Hangul Compatibility Jamo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 111))))),
    },
    struct_unicat{
        .name = "Bopomofo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 110))))),
    },
    struct_unicat{
        .name = "Katakana",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 109))))),
    },
    struct_unicat{
        .name = "Hiragana",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 108))))),
    },
    struct_unicat{
        .name = "CJK Symbols and Punctuation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 107))))),
    },
    struct_unicat{
        .name = "Ideographic Description Characters",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 106))))),
    },
    struct_unicat{
        .name = "Kangxi Radicals",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 105))))),
    },
    struct_unicat{
        .name = "CJK Radicals Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 104))))),
    },
    struct_unicat{
        .name = "Supplemental Punctuation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 103))))),
    },
    struct_unicat{
        .name = "Cyrillic Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 102))))),
    },
    struct_unicat{
        .name = "Ethiopic Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 101))))),
    },
    struct_unicat{
        .name = "Tifinagh",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 100))))),
    },
    struct_unicat{
        .name = "Georgian Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 99))))),
    },
    struct_unicat{
        .name = "Coptic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 98))))),
    },
    struct_unicat{
        .name = "Latin Extended-C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 97))))),
    },
    struct_unicat{
        .name = "Glagolitic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 96))))),
    },
    struct_unicat{
        .name = "Miscellaneous Symbols and Arrows",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 95))))),
    },
    struct_unicat{
        .name = "Supplemental Mathematical Operators",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 94))))),
    },
    struct_unicat{
        .name = "Miscellaneous Mathematical Symbols-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 93))))),
    },
    struct_unicat{
        .name = "Supplemental Arrows-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 92))))),
    },
    struct_unicat{
        .name = "Braille Patterns",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 91))))),
    },
    struct_unicat{
        .name = "Supplemental Arrows-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 90))))),
    },
    struct_unicat{
        .name = "Miscellaneous Mathematical Symbols-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 89))))),
    },
    struct_unicat{
        .name = "Dingbats",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 88))))),
    },
    struct_unicat{
        .name = "Miscellaneous Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 87))))),
    },
    struct_unicat{
        .name = "Geometric Shapes",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 86))))),
    },
    struct_unicat{
        .name = "Block Elements",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 85))))),
    },
    struct_unicat{
        .name = "Box Drawing",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 84))))),
    },
    struct_unicat{
        .name = "Enclosed Alphanumerics",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 83))))),
    },
    struct_unicat{
        .name = "Optical Character Recognition",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 82))))),
    },
    struct_unicat{
        .name = "Control Pictures",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 81))))),
    },
    struct_unicat{
        .name = "Miscellaneous Technical",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 80))))),
    },
    struct_unicat{
        .name = "Mathematical Operators",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 79))))),
    },
    struct_unicat{
        .name = "Arrows",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 78))))),
    },
    struct_unicat{
        .name = "Number Forms",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 77))))),
    },
    struct_unicat{
        .name = "Letterlike Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 76))))),
    },
    struct_unicat{
        .name = "Combining Diacritical Marks for Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 75))))),
    },
    struct_unicat{
        .name = "Currency Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 74))))),
    },
    struct_unicat{
        .name = "Superscripts and Subscripts",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 73))))),
    },
    struct_unicat{
        .name = "General Punctuation",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 72))))),
    },
    struct_unicat{
        .name = "Greek Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 71))))),
    },
    struct_unicat{
        .name = "Latin Extended Additional",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 70))))),
    },
    struct_unicat{
        .name = "Combining Diacritical Marks Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 69))))),
    },
    struct_unicat{
        .name = "Phonetic Extensions Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 68))))),
    },
    struct_unicat{
        .name = "Phonetic Extensions",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 67))))),
    },
    struct_unicat{
        .name = "Vedic Extensions",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 66))))),
    },
    struct_unicat{
        .name = "Sundanese Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 65))))),
    },
    struct_unicat{
        .name = "Georgian Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 64))))),
    },
    struct_unicat{
        .name = "Cyrillic Extended-C",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 63))))),
    },
    struct_unicat{
        .name = "Ol Chiki",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 62))))),
    },
    struct_unicat{
        .name = "Lepcha",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 61))))),
    },
    struct_unicat{
        .name = "Batak",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 60))))),
    },
    struct_unicat{
        .name = "Sundanese",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 59))))),
    },
    struct_unicat{
        .name = "Balinese",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 58))))),
    },
    struct_unicat{
        .name = "Combining Diacritical Marks Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 57))))),
    },
    struct_unicat{
        .name = "Tai Tham",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 56))))),
    },
    struct_unicat{
        .name = "Buginese",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 55))))),
    },
    struct_unicat{
        .name = "Khmer Symbols",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 54))))),
    },
    struct_unicat{
        .name = "New Tai Lue",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 53))))),
    },
    struct_unicat{
        .name = "Tai Le",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 52))))),
    },
    struct_unicat{
        .name = "Limbu",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 51))))),
    },
    struct_unicat{
        .name = "Unified Canadian Aboriginal Syllabics Extended",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 50))))),
    },
    struct_unicat{
        .name = "Mongolian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 49))))),
    },
    struct_unicat{
        .name = "Khmer",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 48))))),
    },
    struct_unicat{
        .name = "Tagbanwa",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 47))))),
    },
    struct_unicat{
        .name = "Buhid",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 46))))),
    },
    struct_unicat{
        .name = "Hanunoo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 45))))),
    },
    struct_unicat{
        .name = "Tagalog",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 44))))),
    },
    struct_unicat{
        .name = "Runic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 43))))),
    },
    struct_unicat{
        .name = "Ogham",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 42))))),
    },
    struct_unicat{
        .name = "Unified Canadian Aboriginal Syllabics",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 41))))),
    },
    struct_unicat{
        .name = "Cherokee",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 40))))),
    },
    struct_unicat{
        .name = "Ethiopic Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 39))))),
    },
    struct_unicat{
        .name = "Ethiopic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 38))))),
    },
    struct_unicat{
        .name = "Hangul Jamo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 37))))),
    },
    struct_unicat{
        .name = "Georgian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 36))))),
    },
    struct_unicat{
        .name = "Myanmar",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 35))))),
    },
    struct_unicat{
        .name = "Tibetan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 34))))),
    },
    struct_unicat{
        .name = "Lao",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 33))))),
    },
    struct_unicat{
        .name = "Thai",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 32))))),
    },
    struct_unicat{
        .name = "Sinhala",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 31))))),
    },
    struct_unicat{
        .name = "Malayalam",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 30))))),
    },
    struct_unicat{
        .name = "Kannada",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 29))))),
    },
    struct_unicat{
        .name = "Telugu",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 28))))),
    },
    struct_unicat{
        .name = "Tamil",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 27))))),
    },
    struct_unicat{
        .name = "Oriya",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 26))))),
    },
    struct_unicat{
        .name = "Gujarati",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 25))))),
    },
    struct_unicat{
        .name = "Gurmukhi",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 24))))),
    },
    struct_unicat{
        .name = "Bengali",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 23))))),
    },
    struct_unicat{
        .name = "Devanagari",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 22))))),
    },
    struct_unicat{
        .name = "Arabic Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 21))))),
    },
    struct_unicat{
        .name = "Arabic Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 20))))),
    },
    struct_unicat{
        .name = "Syriac Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 19))))),
    },
    struct_unicat{
        .name = "Mandaic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 18))))),
    },
    struct_unicat{
        .name = "Samaritan",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 17))))),
    },
    struct_unicat{
        .name = "NKo",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 16))))),
    },
    struct_unicat{
        .name = "Thaana",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 15))))),
    },
    struct_unicat{
        .name = "Arabic Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 14))))),
    },
    struct_unicat{
        .name = "Syriac",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 13))))),
    },
    struct_unicat{
        .name = "Arabic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 12))))),
    },
    struct_unicat{
        .name = "Hebrew",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 11))))),
    },
    struct_unicat{
        .name = "Armenian",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 10))))),
    },
    struct_unicat{
        .name = "Cyrillic Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 9))))),
    },
    struct_unicat{
        .name = "Cyrillic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 8))))),
    },
    struct_unicat{
        .name = "Greek and Coptic",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 7))))),
    },
    struct_unicat{
        .name = "Combining Diacritical Marks",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 6))))),
    },
    struct_unicat{
        .name = "Spacing Modifier Letters",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 5))))),
    },
    struct_unicat{
        .name = "IPA Extensions",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 4))))),
    },
    struct_unicat{
        .name = "Latin Extended-B",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3))))),
    },
    struct_unicat{
        .name = "Latin Extended-A",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 2))))),
    },
    struct_unicat{
        .name = "Latin-1 Supplement",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))),
    },
    struct_unicat{
        .name = "Basic Latin",
        .len = 1,
        .intervals = @as([*c]const struct_interval, @ptrCast(@alignCast(&uniblocks))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 0))))),
    },
    struct_unicat{
        .name = null,
        .len = 0,
        .intervals = null,
    },
};
pub export const fold_table: [796]struct_interval = [796]struct_interval{
    struct_interval{
        .first = 65,
        .last = 90,
    },
    struct_interval{
        .first = 181,
        .last = 181,
    },
    struct_interval{
        .first = 192,
        .last = 214,
    },
    struct_interval{
        .first = 216,
        .last = 222,
    },
    struct_interval{
        .first = 223,
        .last = 223,
    },
    struct_interval{
        .first = 256,
        .last = 256,
    },
    struct_interval{
        .first = 258,
        .last = 258,
    },
    struct_interval{
        .first = 260,
        .last = 260,
    },
    struct_interval{
        .first = 262,
        .last = 262,
    },
    struct_interval{
        .first = 264,
        .last = 264,
    },
    struct_interval{
        .first = 266,
        .last = 266,
    },
    struct_interval{
        .first = 268,
        .last = 268,
    },
    struct_interval{
        .first = 270,
        .last = 270,
    },
    struct_interval{
        .first = 272,
        .last = 272,
    },
    struct_interval{
        .first = 274,
        .last = 274,
    },
    struct_interval{
        .first = 276,
        .last = 276,
    },
    struct_interval{
        .first = 278,
        .last = 278,
    },
    struct_interval{
        .first = 280,
        .last = 280,
    },
    struct_interval{
        .first = 282,
        .last = 282,
    },
    struct_interval{
        .first = 284,
        .last = 284,
    },
    struct_interval{
        .first = 286,
        .last = 286,
    },
    struct_interval{
        .first = 288,
        .last = 288,
    },
    struct_interval{
        .first = 290,
        .last = 290,
    },
    struct_interval{
        .first = 292,
        .last = 292,
    },
    struct_interval{
        .first = 294,
        .last = 294,
    },
    struct_interval{
        .first = 296,
        .last = 296,
    },
    struct_interval{
        .first = 298,
        .last = 298,
    },
    struct_interval{
        .first = 300,
        .last = 300,
    },
    struct_interval{
        .first = 302,
        .last = 302,
    },
    struct_interval{
        .first = 304,
        .last = 304,
    },
    struct_interval{
        .first = 306,
        .last = 306,
    },
    struct_interval{
        .first = 308,
        .last = 308,
    },
    struct_interval{
        .first = 310,
        .last = 310,
    },
    struct_interval{
        .first = 313,
        .last = 313,
    },
    struct_interval{
        .first = 315,
        .last = 315,
    },
    struct_interval{
        .first = 317,
        .last = 317,
    },
    struct_interval{
        .first = 319,
        .last = 319,
    },
    struct_interval{
        .first = 321,
        .last = 321,
    },
    struct_interval{
        .first = 323,
        .last = 323,
    },
    struct_interval{
        .first = 325,
        .last = 325,
    },
    struct_interval{
        .first = 327,
        .last = 327,
    },
    struct_interval{
        .first = 329,
        .last = 329,
    },
    struct_interval{
        .first = 330,
        .last = 330,
    },
    struct_interval{
        .first = 332,
        .last = 332,
    },
    struct_interval{
        .first = 334,
        .last = 334,
    },
    struct_interval{
        .first = 336,
        .last = 336,
    },
    struct_interval{
        .first = 338,
        .last = 338,
    },
    struct_interval{
        .first = 340,
        .last = 340,
    },
    struct_interval{
        .first = 342,
        .last = 342,
    },
    struct_interval{
        .first = 344,
        .last = 344,
    },
    struct_interval{
        .first = 346,
        .last = 346,
    },
    struct_interval{
        .first = 348,
        .last = 348,
    },
    struct_interval{
        .first = 350,
        .last = 350,
    },
    struct_interval{
        .first = 352,
        .last = 352,
    },
    struct_interval{
        .first = 354,
        .last = 354,
    },
    struct_interval{
        .first = 356,
        .last = 356,
    },
    struct_interval{
        .first = 358,
        .last = 358,
    },
    struct_interval{
        .first = 360,
        .last = 360,
    },
    struct_interval{
        .first = 362,
        .last = 362,
    },
    struct_interval{
        .first = 364,
        .last = 364,
    },
    struct_interval{
        .first = 366,
        .last = 366,
    },
    struct_interval{
        .first = 368,
        .last = 368,
    },
    struct_interval{
        .first = 370,
        .last = 370,
    },
    struct_interval{
        .first = 372,
        .last = 372,
    },
    struct_interval{
        .first = 374,
        .last = 374,
    },
    struct_interval{
        .first = 376,
        .last = 376,
    },
    struct_interval{
        .first = 377,
        .last = 377,
    },
    struct_interval{
        .first = 379,
        .last = 379,
    },
    struct_interval{
        .first = 381,
        .last = 381,
    },
    struct_interval{
        .first = 383,
        .last = 383,
    },
    struct_interval{
        .first = 385,
        .last = 385,
    },
    struct_interval{
        .first = 386,
        .last = 386,
    },
    struct_interval{
        .first = 388,
        .last = 388,
    },
    struct_interval{
        .first = 390,
        .last = 390,
    },
    struct_interval{
        .first = 391,
        .last = 391,
    },
    struct_interval{
        .first = 393,
        .last = 394,
    },
    struct_interval{
        .first = 395,
        .last = 395,
    },
    struct_interval{
        .first = 398,
        .last = 398,
    },
    struct_interval{
        .first = 399,
        .last = 399,
    },
    struct_interval{
        .first = 400,
        .last = 400,
    },
    struct_interval{
        .first = 401,
        .last = 401,
    },
    struct_interval{
        .first = 403,
        .last = 403,
    },
    struct_interval{
        .first = 404,
        .last = 404,
    },
    struct_interval{
        .first = 406,
        .last = 406,
    },
    struct_interval{
        .first = 407,
        .last = 407,
    },
    struct_interval{
        .first = 408,
        .last = 408,
    },
    struct_interval{
        .first = 412,
        .last = 412,
    },
    struct_interval{
        .first = 413,
        .last = 413,
    },
    struct_interval{
        .first = 415,
        .last = 415,
    },
    struct_interval{
        .first = 416,
        .last = 416,
    },
    struct_interval{
        .first = 418,
        .last = 418,
    },
    struct_interval{
        .first = 420,
        .last = 420,
    },
    struct_interval{
        .first = 422,
        .last = 422,
    },
    struct_interval{
        .first = 423,
        .last = 423,
    },
    struct_interval{
        .first = 425,
        .last = 425,
    },
    struct_interval{
        .first = 428,
        .last = 428,
    },
    struct_interval{
        .first = 430,
        .last = 430,
    },
    struct_interval{
        .first = 431,
        .last = 431,
    },
    struct_interval{
        .first = 433,
        .last = 434,
    },
    struct_interval{
        .first = 435,
        .last = 435,
    },
    struct_interval{
        .first = 437,
        .last = 437,
    },
    struct_interval{
        .first = 439,
        .last = 439,
    },
    struct_interval{
        .first = 440,
        .last = 440,
    },
    struct_interval{
        .first = 444,
        .last = 444,
    },
    struct_interval{
        .first = 452,
        .last = 452,
    },
    struct_interval{
        .first = 453,
        .last = 453,
    },
    struct_interval{
        .first = 455,
        .last = 455,
    },
    struct_interval{
        .first = 456,
        .last = 456,
    },
    struct_interval{
        .first = 458,
        .last = 458,
    },
    struct_interval{
        .first = 459,
        .last = 459,
    },
    struct_interval{
        .first = 461,
        .last = 461,
    },
    struct_interval{
        .first = 463,
        .last = 463,
    },
    struct_interval{
        .first = 465,
        .last = 465,
    },
    struct_interval{
        .first = 467,
        .last = 467,
    },
    struct_interval{
        .first = 469,
        .last = 469,
    },
    struct_interval{
        .first = 471,
        .last = 471,
    },
    struct_interval{
        .first = 473,
        .last = 473,
    },
    struct_interval{
        .first = 475,
        .last = 475,
    },
    struct_interval{
        .first = 478,
        .last = 478,
    },
    struct_interval{
        .first = 480,
        .last = 480,
    },
    struct_interval{
        .first = 482,
        .last = 482,
    },
    struct_interval{
        .first = 484,
        .last = 484,
    },
    struct_interval{
        .first = 486,
        .last = 486,
    },
    struct_interval{
        .first = 488,
        .last = 488,
    },
    struct_interval{
        .first = 490,
        .last = 490,
    },
    struct_interval{
        .first = 492,
        .last = 492,
    },
    struct_interval{
        .first = 494,
        .last = 494,
    },
    struct_interval{
        .first = 496,
        .last = 496,
    },
    struct_interval{
        .first = 497,
        .last = 497,
    },
    struct_interval{
        .first = 498,
        .last = 498,
    },
    struct_interval{
        .first = 500,
        .last = 500,
    },
    struct_interval{
        .first = 502,
        .last = 502,
    },
    struct_interval{
        .first = 503,
        .last = 503,
    },
    struct_interval{
        .first = 504,
        .last = 504,
    },
    struct_interval{
        .first = 506,
        .last = 506,
    },
    struct_interval{
        .first = 508,
        .last = 508,
    },
    struct_interval{
        .first = 510,
        .last = 510,
    },
    struct_interval{
        .first = 512,
        .last = 512,
    },
    struct_interval{
        .first = 514,
        .last = 514,
    },
    struct_interval{
        .first = 516,
        .last = 516,
    },
    struct_interval{
        .first = 518,
        .last = 518,
    },
    struct_interval{
        .first = 520,
        .last = 520,
    },
    struct_interval{
        .first = 522,
        .last = 522,
    },
    struct_interval{
        .first = 524,
        .last = 524,
    },
    struct_interval{
        .first = 526,
        .last = 526,
    },
    struct_interval{
        .first = 528,
        .last = 528,
    },
    struct_interval{
        .first = 530,
        .last = 530,
    },
    struct_interval{
        .first = 532,
        .last = 532,
    },
    struct_interval{
        .first = 534,
        .last = 534,
    },
    struct_interval{
        .first = 536,
        .last = 536,
    },
    struct_interval{
        .first = 538,
        .last = 538,
    },
    struct_interval{
        .first = 540,
        .last = 540,
    },
    struct_interval{
        .first = 542,
        .last = 542,
    },
    struct_interval{
        .first = 544,
        .last = 544,
    },
    struct_interval{
        .first = 546,
        .last = 546,
    },
    struct_interval{
        .first = 548,
        .last = 548,
    },
    struct_interval{
        .first = 550,
        .last = 550,
    },
    struct_interval{
        .first = 552,
        .last = 552,
    },
    struct_interval{
        .first = 554,
        .last = 554,
    },
    struct_interval{
        .first = 556,
        .last = 556,
    },
    struct_interval{
        .first = 558,
        .last = 558,
    },
    struct_interval{
        .first = 560,
        .last = 560,
    },
    struct_interval{
        .first = 562,
        .last = 562,
    },
    struct_interval{
        .first = 570,
        .last = 570,
    },
    struct_interval{
        .first = 571,
        .last = 571,
    },
    struct_interval{
        .first = 573,
        .last = 573,
    },
    struct_interval{
        .first = 574,
        .last = 574,
    },
    struct_interval{
        .first = 577,
        .last = 577,
    },
    struct_interval{
        .first = 579,
        .last = 579,
    },
    struct_interval{
        .first = 580,
        .last = 580,
    },
    struct_interval{
        .first = 581,
        .last = 581,
    },
    struct_interval{
        .first = 582,
        .last = 582,
    },
    struct_interval{
        .first = 584,
        .last = 584,
    },
    struct_interval{
        .first = 586,
        .last = 586,
    },
    struct_interval{
        .first = 588,
        .last = 588,
    },
    struct_interval{
        .first = 590,
        .last = 590,
    },
    struct_interval{
        .first = 837,
        .last = 837,
    },
    struct_interval{
        .first = 880,
        .last = 880,
    },
    struct_interval{
        .first = 882,
        .last = 882,
    },
    struct_interval{
        .first = 886,
        .last = 886,
    },
    struct_interval{
        .first = 895,
        .last = 895,
    },
    struct_interval{
        .first = 902,
        .last = 902,
    },
    struct_interval{
        .first = 904,
        .last = 906,
    },
    struct_interval{
        .first = 908,
        .last = 908,
    },
    struct_interval{
        .first = 910,
        .last = 911,
    },
    struct_interval{
        .first = 912,
        .last = 912,
    },
    struct_interval{
        .first = 913,
        .last = 929,
    },
    struct_interval{
        .first = 931,
        .last = 939,
    },
    struct_interval{
        .first = 944,
        .last = 944,
    },
    struct_interval{
        .first = 962,
        .last = 962,
    },
    struct_interval{
        .first = 975,
        .last = 975,
    },
    struct_interval{
        .first = 976,
        .last = 976,
    },
    struct_interval{
        .first = 977,
        .last = 977,
    },
    struct_interval{
        .first = 981,
        .last = 981,
    },
    struct_interval{
        .first = 982,
        .last = 982,
    },
    struct_interval{
        .first = 984,
        .last = 984,
    },
    struct_interval{
        .first = 986,
        .last = 986,
    },
    struct_interval{
        .first = 988,
        .last = 988,
    },
    struct_interval{
        .first = 990,
        .last = 990,
    },
    struct_interval{
        .first = 992,
        .last = 992,
    },
    struct_interval{
        .first = 994,
        .last = 994,
    },
    struct_interval{
        .first = 996,
        .last = 996,
    },
    struct_interval{
        .first = 998,
        .last = 998,
    },
    struct_interval{
        .first = 1000,
        .last = 1000,
    },
    struct_interval{
        .first = 1002,
        .last = 1002,
    },
    struct_interval{
        .first = 1004,
        .last = 1004,
    },
    struct_interval{
        .first = 1006,
        .last = 1006,
    },
    struct_interval{
        .first = 1008,
        .last = 1008,
    },
    struct_interval{
        .first = 1009,
        .last = 1009,
    },
    struct_interval{
        .first = 1012,
        .last = 1012,
    },
    struct_interval{
        .first = 1013,
        .last = 1013,
    },
    struct_interval{
        .first = 1015,
        .last = 1015,
    },
    struct_interval{
        .first = 1017,
        .last = 1017,
    },
    struct_interval{
        .first = 1018,
        .last = 1018,
    },
    struct_interval{
        .first = 1021,
        .last = 1023,
    },
    struct_interval{
        .first = 1024,
        .last = 1039,
    },
    struct_interval{
        .first = 1040,
        .last = 1071,
    },
    struct_interval{
        .first = 1120,
        .last = 1120,
    },
    struct_interval{
        .first = 1122,
        .last = 1122,
    },
    struct_interval{
        .first = 1124,
        .last = 1124,
    },
    struct_interval{
        .first = 1126,
        .last = 1126,
    },
    struct_interval{
        .first = 1128,
        .last = 1128,
    },
    struct_interval{
        .first = 1130,
        .last = 1130,
    },
    struct_interval{
        .first = 1132,
        .last = 1132,
    },
    struct_interval{
        .first = 1134,
        .last = 1134,
    },
    struct_interval{
        .first = 1136,
        .last = 1136,
    },
    struct_interval{
        .first = 1138,
        .last = 1138,
    },
    struct_interval{
        .first = 1140,
        .last = 1140,
    },
    struct_interval{
        .first = 1142,
        .last = 1142,
    },
    struct_interval{
        .first = 1144,
        .last = 1144,
    },
    struct_interval{
        .first = 1146,
        .last = 1146,
    },
    struct_interval{
        .first = 1148,
        .last = 1148,
    },
    struct_interval{
        .first = 1150,
        .last = 1150,
    },
    struct_interval{
        .first = 1152,
        .last = 1152,
    },
    struct_interval{
        .first = 1162,
        .last = 1162,
    },
    struct_interval{
        .first = 1164,
        .last = 1164,
    },
    struct_interval{
        .first = 1166,
        .last = 1166,
    },
    struct_interval{
        .first = 1168,
        .last = 1168,
    },
    struct_interval{
        .first = 1170,
        .last = 1170,
    },
    struct_interval{
        .first = 1172,
        .last = 1172,
    },
    struct_interval{
        .first = 1174,
        .last = 1174,
    },
    struct_interval{
        .first = 1176,
        .last = 1176,
    },
    struct_interval{
        .first = 1178,
        .last = 1178,
    },
    struct_interval{
        .first = 1180,
        .last = 1180,
    },
    struct_interval{
        .first = 1182,
        .last = 1182,
    },
    struct_interval{
        .first = 1184,
        .last = 1184,
    },
    struct_interval{
        .first = 1186,
        .last = 1186,
    },
    struct_interval{
        .first = 1188,
        .last = 1188,
    },
    struct_interval{
        .first = 1190,
        .last = 1190,
    },
    struct_interval{
        .first = 1192,
        .last = 1192,
    },
    struct_interval{
        .first = 1194,
        .last = 1194,
    },
    struct_interval{
        .first = 1196,
        .last = 1196,
    },
    struct_interval{
        .first = 1198,
        .last = 1198,
    },
    struct_interval{
        .first = 1200,
        .last = 1200,
    },
    struct_interval{
        .first = 1202,
        .last = 1202,
    },
    struct_interval{
        .first = 1204,
        .last = 1204,
    },
    struct_interval{
        .first = 1206,
        .last = 1206,
    },
    struct_interval{
        .first = 1208,
        .last = 1208,
    },
    struct_interval{
        .first = 1210,
        .last = 1210,
    },
    struct_interval{
        .first = 1212,
        .last = 1212,
    },
    struct_interval{
        .first = 1214,
        .last = 1214,
    },
    struct_interval{
        .first = 1216,
        .last = 1216,
    },
    struct_interval{
        .first = 1217,
        .last = 1217,
    },
    struct_interval{
        .first = 1219,
        .last = 1219,
    },
    struct_interval{
        .first = 1221,
        .last = 1221,
    },
    struct_interval{
        .first = 1223,
        .last = 1223,
    },
    struct_interval{
        .first = 1225,
        .last = 1225,
    },
    struct_interval{
        .first = 1227,
        .last = 1227,
    },
    struct_interval{
        .first = 1229,
        .last = 1229,
    },
    struct_interval{
        .first = 1232,
        .last = 1232,
    },
    struct_interval{
        .first = 1234,
        .last = 1234,
    },
    struct_interval{
        .first = 1236,
        .last = 1236,
    },
    struct_interval{
        .first = 1238,
        .last = 1238,
    },
    struct_interval{
        .first = 1240,
        .last = 1240,
    },
    struct_interval{
        .first = 1242,
        .last = 1242,
    },
    struct_interval{
        .first = 1244,
        .last = 1244,
    },
    struct_interval{
        .first = 1246,
        .last = 1246,
    },
    struct_interval{
        .first = 1248,
        .last = 1248,
    },
    struct_interval{
        .first = 1250,
        .last = 1250,
    },
    struct_interval{
        .first = 1252,
        .last = 1252,
    },
    struct_interval{
        .first = 1254,
        .last = 1254,
    },
    struct_interval{
        .first = 1256,
        .last = 1256,
    },
    struct_interval{
        .first = 1258,
        .last = 1258,
    },
    struct_interval{
        .first = 1260,
        .last = 1260,
    },
    struct_interval{
        .first = 1262,
        .last = 1262,
    },
    struct_interval{
        .first = 1264,
        .last = 1264,
    },
    struct_interval{
        .first = 1266,
        .last = 1266,
    },
    struct_interval{
        .first = 1268,
        .last = 1268,
    },
    struct_interval{
        .first = 1270,
        .last = 1270,
    },
    struct_interval{
        .first = 1272,
        .last = 1272,
    },
    struct_interval{
        .first = 1274,
        .last = 1274,
    },
    struct_interval{
        .first = 1276,
        .last = 1276,
    },
    struct_interval{
        .first = 1278,
        .last = 1278,
    },
    struct_interval{
        .first = 1280,
        .last = 1280,
    },
    struct_interval{
        .first = 1282,
        .last = 1282,
    },
    struct_interval{
        .first = 1284,
        .last = 1284,
    },
    struct_interval{
        .first = 1286,
        .last = 1286,
    },
    struct_interval{
        .first = 1288,
        .last = 1288,
    },
    struct_interval{
        .first = 1290,
        .last = 1290,
    },
    struct_interval{
        .first = 1292,
        .last = 1292,
    },
    struct_interval{
        .first = 1294,
        .last = 1294,
    },
    struct_interval{
        .first = 1296,
        .last = 1296,
    },
    struct_interval{
        .first = 1298,
        .last = 1298,
    },
    struct_interval{
        .first = 1300,
        .last = 1300,
    },
    struct_interval{
        .first = 1302,
        .last = 1302,
    },
    struct_interval{
        .first = 1304,
        .last = 1304,
    },
    struct_interval{
        .first = 1306,
        .last = 1306,
    },
    struct_interval{
        .first = 1308,
        .last = 1308,
    },
    struct_interval{
        .first = 1310,
        .last = 1310,
    },
    struct_interval{
        .first = 1312,
        .last = 1312,
    },
    struct_interval{
        .first = 1314,
        .last = 1314,
    },
    struct_interval{
        .first = 1316,
        .last = 1316,
    },
    struct_interval{
        .first = 1318,
        .last = 1318,
    },
    struct_interval{
        .first = 1320,
        .last = 1320,
    },
    struct_interval{
        .first = 1322,
        .last = 1322,
    },
    struct_interval{
        .first = 1324,
        .last = 1324,
    },
    struct_interval{
        .first = 1326,
        .last = 1326,
    },
    struct_interval{
        .first = 1329,
        .last = 1366,
    },
    struct_interval{
        .first = 1415,
        .last = 1415,
    },
    struct_interval{
        .first = 4256,
        .last = 4293,
    },
    struct_interval{
        .first = 4295,
        .last = 4295,
    },
    struct_interval{
        .first = 4301,
        .last = 4301,
    },
    struct_interval{
        .first = 5112,
        .last = 5117,
    },
    struct_interval{
        .first = 7296,
        .last = 7296,
    },
    struct_interval{
        .first = 7297,
        .last = 7297,
    },
    struct_interval{
        .first = 7298,
        .last = 7298,
    },
    struct_interval{
        .first = 7299,
        .last = 7300,
    },
    struct_interval{
        .first = 7301,
        .last = 7301,
    },
    struct_interval{
        .first = 7302,
        .last = 7302,
    },
    struct_interval{
        .first = 7303,
        .last = 7303,
    },
    struct_interval{
        .first = 7304,
        .last = 7304,
    },
    struct_interval{
        .first = 7305,
        .last = 7305,
    },
    struct_interval{
        .first = 7312,
        .last = 7354,
    },
    struct_interval{
        .first = 7357,
        .last = 7359,
    },
    struct_interval{
        .first = 7680,
        .last = 7680,
    },
    struct_interval{
        .first = 7682,
        .last = 7682,
    },
    struct_interval{
        .first = 7684,
        .last = 7684,
    },
    struct_interval{
        .first = 7686,
        .last = 7686,
    },
    struct_interval{
        .first = 7688,
        .last = 7688,
    },
    struct_interval{
        .first = 7690,
        .last = 7690,
    },
    struct_interval{
        .first = 7692,
        .last = 7692,
    },
    struct_interval{
        .first = 7694,
        .last = 7694,
    },
    struct_interval{
        .first = 7696,
        .last = 7696,
    },
    struct_interval{
        .first = 7698,
        .last = 7698,
    },
    struct_interval{
        .first = 7700,
        .last = 7700,
    },
    struct_interval{
        .first = 7702,
        .last = 7702,
    },
    struct_interval{
        .first = 7704,
        .last = 7704,
    },
    struct_interval{
        .first = 7706,
        .last = 7706,
    },
    struct_interval{
        .first = 7708,
        .last = 7708,
    },
    struct_interval{
        .first = 7710,
        .last = 7710,
    },
    struct_interval{
        .first = 7712,
        .last = 7712,
    },
    struct_interval{
        .first = 7714,
        .last = 7714,
    },
    struct_interval{
        .first = 7716,
        .last = 7716,
    },
    struct_interval{
        .first = 7718,
        .last = 7718,
    },
    struct_interval{
        .first = 7720,
        .last = 7720,
    },
    struct_interval{
        .first = 7722,
        .last = 7722,
    },
    struct_interval{
        .first = 7724,
        .last = 7724,
    },
    struct_interval{
        .first = 7726,
        .last = 7726,
    },
    struct_interval{
        .first = 7728,
        .last = 7728,
    },
    struct_interval{
        .first = 7730,
        .last = 7730,
    },
    struct_interval{
        .first = 7732,
        .last = 7732,
    },
    struct_interval{
        .first = 7734,
        .last = 7734,
    },
    struct_interval{
        .first = 7736,
        .last = 7736,
    },
    struct_interval{
        .first = 7738,
        .last = 7738,
    },
    struct_interval{
        .first = 7740,
        .last = 7740,
    },
    struct_interval{
        .first = 7742,
        .last = 7742,
    },
    struct_interval{
        .first = 7744,
        .last = 7744,
    },
    struct_interval{
        .first = 7746,
        .last = 7746,
    },
    struct_interval{
        .first = 7748,
        .last = 7748,
    },
    struct_interval{
        .first = 7750,
        .last = 7750,
    },
    struct_interval{
        .first = 7752,
        .last = 7752,
    },
    struct_interval{
        .first = 7754,
        .last = 7754,
    },
    struct_interval{
        .first = 7756,
        .last = 7756,
    },
    struct_interval{
        .first = 7758,
        .last = 7758,
    },
    struct_interval{
        .first = 7760,
        .last = 7760,
    },
    struct_interval{
        .first = 7762,
        .last = 7762,
    },
    struct_interval{
        .first = 7764,
        .last = 7764,
    },
    struct_interval{
        .first = 7766,
        .last = 7766,
    },
    struct_interval{
        .first = 7768,
        .last = 7768,
    },
    struct_interval{
        .first = 7770,
        .last = 7770,
    },
    struct_interval{
        .first = 7772,
        .last = 7772,
    },
    struct_interval{
        .first = 7774,
        .last = 7774,
    },
    struct_interval{
        .first = 7776,
        .last = 7776,
    },
    struct_interval{
        .first = 7778,
        .last = 7778,
    },
    struct_interval{
        .first = 7780,
        .last = 7780,
    },
    struct_interval{
        .first = 7782,
        .last = 7782,
    },
    struct_interval{
        .first = 7784,
        .last = 7784,
    },
    struct_interval{
        .first = 7786,
        .last = 7786,
    },
    struct_interval{
        .first = 7788,
        .last = 7788,
    },
    struct_interval{
        .first = 7790,
        .last = 7790,
    },
    struct_interval{
        .first = 7792,
        .last = 7792,
    },
    struct_interval{
        .first = 7794,
        .last = 7794,
    },
    struct_interval{
        .first = 7796,
        .last = 7796,
    },
    struct_interval{
        .first = 7798,
        .last = 7798,
    },
    struct_interval{
        .first = 7800,
        .last = 7800,
    },
    struct_interval{
        .first = 7802,
        .last = 7802,
    },
    struct_interval{
        .first = 7804,
        .last = 7804,
    },
    struct_interval{
        .first = 7806,
        .last = 7806,
    },
    struct_interval{
        .first = 7808,
        .last = 7808,
    },
    struct_interval{
        .first = 7810,
        .last = 7810,
    },
    struct_interval{
        .first = 7812,
        .last = 7812,
    },
    struct_interval{
        .first = 7814,
        .last = 7814,
    },
    struct_interval{
        .first = 7816,
        .last = 7816,
    },
    struct_interval{
        .first = 7818,
        .last = 7818,
    },
    struct_interval{
        .first = 7820,
        .last = 7820,
    },
    struct_interval{
        .first = 7822,
        .last = 7822,
    },
    struct_interval{
        .first = 7824,
        .last = 7824,
    },
    struct_interval{
        .first = 7826,
        .last = 7826,
    },
    struct_interval{
        .first = 7828,
        .last = 7828,
    },
    struct_interval{
        .first = 7830,
        .last = 7830,
    },
    struct_interval{
        .first = 7831,
        .last = 7831,
    },
    struct_interval{
        .first = 7832,
        .last = 7832,
    },
    struct_interval{
        .first = 7833,
        .last = 7833,
    },
    struct_interval{
        .first = 7834,
        .last = 7834,
    },
    struct_interval{
        .first = 7835,
        .last = 7835,
    },
    struct_interval{
        .first = 7838,
        .last = 7838,
    },
    struct_interval{
        .first = 7840,
        .last = 7840,
    },
    struct_interval{
        .first = 7842,
        .last = 7842,
    },
    struct_interval{
        .first = 7844,
        .last = 7844,
    },
    struct_interval{
        .first = 7846,
        .last = 7846,
    },
    struct_interval{
        .first = 7848,
        .last = 7848,
    },
    struct_interval{
        .first = 7850,
        .last = 7850,
    },
    struct_interval{
        .first = 7852,
        .last = 7852,
    },
    struct_interval{
        .first = 7854,
        .last = 7854,
    },
    struct_interval{
        .first = 7856,
        .last = 7856,
    },
    struct_interval{
        .first = 7858,
        .last = 7858,
    },
    struct_interval{
        .first = 7860,
        .last = 7860,
    },
    struct_interval{
        .first = 7862,
        .last = 7862,
    },
    struct_interval{
        .first = 7864,
        .last = 7864,
    },
    struct_interval{
        .first = 7866,
        .last = 7866,
    },
    struct_interval{
        .first = 7868,
        .last = 7868,
    },
    struct_interval{
        .first = 7870,
        .last = 7870,
    },
    struct_interval{
        .first = 7872,
        .last = 7872,
    },
    struct_interval{
        .first = 7874,
        .last = 7874,
    },
    struct_interval{
        .first = 7876,
        .last = 7876,
    },
    struct_interval{
        .first = 7878,
        .last = 7878,
    },
    struct_interval{
        .first = 7880,
        .last = 7880,
    },
    struct_interval{
        .first = 7882,
        .last = 7882,
    },
    struct_interval{
        .first = 7884,
        .last = 7884,
    },
    struct_interval{
        .first = 7886,
        .last = 7886,
    },
    struct_interval{
        .first = 7888,
        .last = 7888,
    },
    struct_interval{
        .first = 7890,
        .last = 7890,
    },
    struct_interval{
        .first = 7892,
        .last = 7892,
    },
    struct_interval{
        .first = 7894,
        .last = 7894,
    },
    struct_interval{
        .first = 7896,
        .last = 7896,
    },
    struct_interval{
        .first = 7898,
        .last = 7898,
    },
    struct_interval{
        .first = 7900,
        .last = 7900,
    },
    struct_interval{
        .first = 7902,
        .last = 7902,
    },
    struct_interval{
        .first = 7904,
        .last = 7904,
    },
    struct_interval{
        .first = 7906,
        .last = 7906,
    },
    struct_interval{
        .first = 7908,
        .last = 7908,
    },
    struct_interval{
        .first = 7910,
        .last = 7910,
    },
    struct_interval{
        .first = 7912,
        .last = 7912,
    },
    struct_interval{
        .first = 7914,
        .last = 7914,
    },
    struct_interval{
        .first = 7916,
        .last = 7916,
    },
    struct_interval{
        .first = 7918,
        .last = 7918,
    },
    struct_interval{
        .first = 7920,
        .last = 7920,
    },
    struct_interval{
        .first = 7922,
        .last = 7922,
    },
    struct_interval{
        .first = 7924,
        .last = 7924,
    },
    struct_interval{
        .first = 7926,
        .last = 7926,
    },
    struct_interval{
        .first = 7928,
        .last = 7928,
    },
    struct_interval{
        .first = 7930,
        .last = 7930,
    },
    struct_interval{
        .first = 7932,
        .last = 7932,
    },
    struct_interval{
        .first = 7934,
        .last = 7934,
    },
    struct_interval{
        .first = 7944,
        .last = 7951,
    },
    struct_interval{
        .first = 7960,
        .last = 7965,
    },
    struct_interval{
        .first = 7976,
        .last = 7983,
    },
    struct_interval{
        .first = 7992,
        .last = 7999,
    },
    struct_interval{
        .first = 8008,
        .last = 8013,
    },
    struct_interval{
        .first = 8016,
        .last = 8016,
    },
    struct_interval{
        .first = 8018,
        .last = 8018,
    },
    struct_interval{
        .first = 8020,
        .last = 8020,
    },
    struct_interval{
        .first = 8022,
        .last = 8022,
    },
    struct_interval{
        .first = 8025,
        .last = 8025,
    },
    struct_interval{
        .first = 8027,
        .last = 8027,
    },
    struct_interval{
        .first = 8029,
        .last = 8029,
    },
    struct_interval{
        .first = 8031,
        .last = 8031,
    },
    struct_interval{
        .first = 8040,
        .last = 8047,
    },
    struct_interval{
        .first = 8064,
        .last = 8064,
    },
    struct_interval{
        .first = 8065,
        .last = 8065,
    },
    struct_interval{
        .first = 8066,
        .last = 8066,
    },
    struct_interval{
        .first = 8067,
        .last = 8067,
    },
    struct_interval{
        .first = 8068,
        .last = 8068,
    },
    struct_interval{
        .first = 8069,
        .last = 8069,
    },
    struct_interval{
        .first = 8070,
        .last = 8070,
    },
    struct_interval{
        .first = 8071,
        .last = 8071,
    },
    struct_interval{
        .first = 8072,
        .last = 8072,
    },
    struct_interval{
        .first = 8073,
        .last = 8073,
    },
    struct_interval{
        .first = 8074,
        .last = 8074,
    },
    struct_interval{
        .first = 8075,
        .last = 8075,
    },
    struct_interval{
        .first = 8076,
        .last = 8076,
    },
    struct_interval{
        .first = 8077,
        .last = 8077,
    },
    struct_interval{
        .first = 8078,
        .last = 8078,
    },
    struct_interval{
        .first = 8079,
        .last = 8079,
    },
    struct_interval{
        .first = 8080,
        .last = 8080,
    },
    struct_interval{
        .first = 8081,
        .last = 8081,
    },
    struct_interval{
        .first = 8082,
        .last = 8082,
    },
    struct_interval{
        .first = 8083,
        .last = 8083,
    },
    struct_interval{
        .first = 8084,
        .last = 8084,
    },
    struct_interval{
        .first = 8085,
        .last = 8085,
    },
    struct_interval{
        .first = 8086,
        .last = 8086,
    },
    struct_interval{
        .first = 8087,
        .last = 8087,
    },
    struct_interval{
        .first = 8088,
        .last = 8088,
    },
    struct_interval{
        .first = 8089,
        .last = 8089,
    },
    struct_interval{
        .first = 8090,
        .last = 8090,
    },
    struct_interval{
        .first = 8091,
        .last = 8091,
    },
    struct_interval{
        .first = 8092,
        .last = 8092,
    },
    struct_interval{
        .first = 8093,
        .last = 8093,
    },
    struct_interval{
        .first = 8094,
        .last = 8094,
    },
    struct_interval{
        .first = 8095,
        .last = 8095,
    },
    struct_interval{
        .first = 8096,
        .last = 8096,
    },
    struct_interval{
        .first = 8097,
        .last = 8097,
    },
    struct_interval{
        .first = 8098,
        .last = 8098,
    },
    struct_interval{
        .first = 8099,
        .last = 8099,
    },
    struct_interval{
        .first = 8100,
        .last = 8100,
    },
    struct_interval{
        .first = 8101,
        .last = 8101,
    },
    struct_interval{
        .first = 8102,
        .last = 8102,
    },
    struct_interval{
        .first = 8103,
        .last = 8103,
    },
    struct_interval{
        .first = 8104,
        .last = 8104,
    },
    struct_interval{
        .first = 8105,
        .last = 8105,
    },
    struct_interval{
        .first = 8106,
        .last = 8106,
    },
    struct_interval{
        .first = 8107,
        .last = 8107,
    },
    struct_interval{
        .first = 8108,
        .last = 8108,
    },
    struct_interval{
        .first = 8109,
        .last = 8109,
    },
    struct_interval{
        .first = 8110,
        .last = 8110,
    },
    struct_interval{
        .first = 8111,
        .last = 8111,
    },
    struct_interval{
        .first = 8114,
        .last = 8114,
    },
    struct_interval{
        .first = 8115,
        .last = 8115,
    },
    struct_interval{
        .first = 8116,
        .last = 8116,
    },
    struct_interval{
        .first = 8118,
        .last = 8118,
    },
    struct_interval{
        .first = 8119,
        .last = 8119,
    },
    struct_interval{
        .first = 8120,
        .last = 8121,
    },
    struct_interval{
        .first = 8122,
        .last = 8123,
    },
    struct_interval{
        .first = 8124,
        .last = 8124,
    },
    struct_interval{
        .first = 8126,
        .last = 8126,
    },
    struct_interval{
        .first = 8130,
        .last = 8130,
    },
    struct_interval{
        .first = 8131,
        .last = 8131,
    },
    struct_interval{
        .first = 8132,
        .last = 8132,
    },
    struct_interval{
        .first = 8134,
        .last = 8134,
    },
    struct_interval{
        .first = 8135,
        .last = 8135,
    },
    struct_interval{
        .first = 8136,
        .last = 8139,
    },
    struct_interval{
        .first = 8140,
        .last = 8140,
    },
    struct_interval{
        .first = 8146,
        .last = 8146,
    },
    struct_interval{
        .first = 8147,
        .last = 8147,
    },
    struct_interval{
        .first = 8150,
        .last = 8150,
    },
    struct_interval{
        .first = 8151,
        .last = 8151,
    },
    struct_interval{
        .first = 8152,
        .last = 8153,
    },
    struct_interval{
        .first = 8154,
        .last = 8155,
    },
    struct_interval{
        .first = 8162,
        .last = 8162,
    },
    struct_interval{
        .first = 8163,
        .last = 8163,
    },
    struct_interval{
        .first = 8164,
        .last = 8164,
    },
    struct_interval{
        .first = 8166,
        .last = 8166,
    },
    struct_interval{
        .first = 8167,
        .last = 8167,
    },
    struct_interval{
        .first = 8168,
        .last = 8169,
    },
    struct_interval{
        .first = 8170,
        .last = 8171,
    },
    struct_interval{
        .first = 8172,
        .last = 8172,
    },
    struct_interval{
        .first = 8178,
        .last = 8178,
    },
    struct_interval{
        .first = 8179,
        .last = 8179,
    },
    struct_interval{
        .first = 8180,
        .last = 8180,
    },
    struct_interval{
        .first = 8182,
        .last = 8182,
    },
    struct_interval{
        .first = 8183,
        .last = 8183,
    },
    struct_interval{
        .first = 8184,
        .last = 8185,
    },
    struct_interval{
        .first = 8186,
        .last = 8187,
    },
    struct_interval{
        .first = 8188,
        .last = 8188,
    },
    struct_interval{
        .first = 8486,
        .last = 8486,
    },
    struct_interval{
        .first = 8490,
        .last = 8490,
    },
    struct_interval{
        .first = 8491,
        .last = 8491,
    },
    struct_interval{
        .first = 8498,
        .last = 8498,
    },
    struct_interval{
        .first = 8544,
        .last = 8559,
    },
    struct_interval{
        .first = 8579,
        .last = 8579,
    },
    struct_interval{
        .first = 9398,
        .last = 9423,
    },
    struct_interval{
        .first = 11264,
        .last = 11311,
    },
    struct_interval{
        .first = 11360,
        .last = 11360,
    },
    struct_interval{
        .first = 11362,
        .last = 11362,
    },
    struct_interval{
        .first = 11363,
        .last = 11363,
    },
    struct_interval{
        .first = 11364,
        .last = 11364,
    },
    struct_interval{
        .first = 11367,
        .last = 11367,
    },
    struct_interval{
        .first = 11369,
        .last = 11369,
    },
    struct_interval{
        .first = 11371,
        .last = 11371,
    },
    struct_interval{
        .first = 11373,
        .last = 11373,
    },
    struct_interval{
        .first = 11374,
        .last = 11374,
    },
    struct_interval{
        .first = 11375,
        .last = 11375,
    },
    struct_interval{
        .first = 11376,
        .last = 11376,
    },
    struct_interval{
        .first = 11378,
        .last = 11378,
    },
    struct_interval{
        .first = 11381,
        .last = 11381,
    },
    struct_interval{
        .first = 11390,
        .last = 11391,
    },
    struct_interval{
        .first = 11392,
        .last = 11392,
    },
    struct_interval{
        .first = 11394,
        .last = 11394,
    },
    struct_interval{
        .first = 11396,
        .last = 11396,
    },
    struct_interval{
        .first = 11398,
        .last = 11398,
    },
    struct_interval{
        .first = 11400,
        .last = 11400,
    },
    struct_interval{
        .first = 11402,
        .last = 11402,
    },
    struct_interval{
        .first = 11404,
        .last = 11404,
    },
    struct_interval{
        .first = 11406,
        .last = 11406,
    },
    struct_interval{
        .first = 11408,
        .last = 11408,
    },
    struct_interval{
        .first = 11410,
        .last = 11410,
    },
    struct_interval{
        .first = 11412,
        .last = 11412,
    },
    struct_interval{
        .first = 11414,
        .last = 11414,
    },
    struct_interval{
        .first = 11416,
        .last = 11416,
    },
    struct_interval{
        .first = 11418,
        .last = 11418,
    },
    struct_interval{
        .first = 11420,
        .last = 11420,
    },
    struct_interval{
        .first = 11422,
        .last = 11422,
    },
    struct_interval{
        .first = 11424,
        .last = 11424,
    },
    struct_interval{
        .first = 11426,
        .last = 11426,
    },
    struct_interval{
        .first = 11428,
        .last = 11428,
    },
    struct_interval{
        .first = 11430,
        .last = 11430,
    },
    struct_interval{
        .first = 11432,
        .last = 11432,
    },
    struct_interval{
        .first = 11434,
        .last = 11434,
    },
    struct_interval{
        .first = 11436,
        .last = 11436,
    },
    struct_interval{
        .first = 11438,
        .last = 11438,
    },
    struct_interval{
        .first = 11440,
        .last = 11440,
    },
    struct_interval{
        .first = 11442,
        .last = 11442,
    },
    struct_interval{
        .first = 11444,
        .last = 11444,
    },
    struct_interval{
        .first = 11446,
        .last = 11446,
    },
    struct_interval{
        .first = 11448,
        .last = 11448,
    },
    struct_interval{
        .first = 11450,
        .last = 11450,
    },
    struct_interval{
        .first = 11452,
        .last = 11452,
    },
    struct_interval{
        .first = 11454,
        .last = 11454,
    },
    struct_interval{
        .first = 11456,
        .last = 11456,
    },
    struct_interval{
        .first = 11458,
        .last = 11458,
    },
    struct_interval{
        .first = 11460,
        .last = 11460,
    },
    struct_interval{
        .first = 11462,
        .last = 11462,
    },
    struct_interval{
        .first = 11464,
        .last = 11464,
    },
    struct_interval{
        .first = 11466,
        .last = 11466,
    },
    struct_interval{
        .first = 11468,
        .last = 11468,
    },
    struct_interval{
        .first = 11470,
        .last = 11470,
    },
    struct_interval{
        .first = 11472,
        .last = 11472,
    },
    struct_interval{
        .first = 11474,
        .last = 11474,
    },
    struct_interval{
        .first = 11476,
        .last = 11476,
    },
    struct_interval{
        .first = 11478,
        .last = 11478,
    },
    struct_interval{
        .first = 11480,
        .last = 11480,
    },
    struct_interval{
        .first = 11482,
        .last = 11482,
    },
    struct_interval{
        .first = 11484,
        .last = 11484,
    },
    struct_interval{
        .first = 11486,
        .last = 11486,
    },
    struct_interval{
        .first = 11488,
        .last = 11488,
    },
    struct_interval{
        .first = 11490,
        .last = 11490,
    },
    struct_interval{
        .first = 11499,
        .last = 11499,
    },
    struct_interval{
        .first = 11501,
        .last = 11501,
    },
    struct_interval{
        .first = 11506,
        .last = 11506,
    },
    struct_interval{
        .first = 42560,
        .last = 42560,
    },
    struct_interval{
        .first = 42562,
        .last = 42562,
    },
    struct_interval{
        .first = 42564,
        .last = 42564,
    },
    struct_interval{
        .first = 42566,
        .last = 42566,
    },
    struct_interval{
        .first = 42568,
        .last = 42568,
    },
    struct_interval{
        .first = 42570,
        .last = 42570,
    },
    struct_interval{
        .first = 42572,
        .last = 42572,
    },
    struct_interval{
        .first = 42574,
        .last = 42574,
    },
    struct_interval{
        .first = 42576,
        .last = 42576,
    },
    struct_interval{
        .first = 42578,
        .last = 42578,
    },
    struct_interval{
        .first = 42580,
        .last = 42580,
    },
    struct_interval{
        .first = 42582,
        .last = 42582,
    },
    struct_interval{
        .first = 42584,
        .last = 42584,
    },
    struct_interval{
        .first = 42586,
        .last = 42586,
    },
    struct_interval{
        .first = 42588,
        .last = 42588,
    },
    struct_interval{
        .first = 42590,
        .last = 42590,
    },
    struct_interval{
        .first = 42592,
        .last = 42592,
    },
    struct_interval{
        .first = 42594,
        .last = 42594,
    },
    struct_interval{
        .first = 42596,
        .last = 42596,
    },
    struct_interval{
        .first = 42598,
        .last = 42598,
    },
    struct_interval{
        .first = 42600,
        .last = 42600,
    },
    struct_interval{
        .first = 42602,
        .last = 42602,
    },
    struct_interval{
        .first = 42604,
        .last = 42604,
    },
    struct_interval{
        .first = 42624,
        .last = 42624,
    },
    struct_interval{
        .first = 42626,
        .last = 42626,
    },
    struct_interval{
        .first = 42628,
        .last = 42628,
    },
    struct_interval{
        .first = 42630,
        .last = 42630,
    },
    struct_interval{
        .first = 42632,
        .last = 42632,
    },
    struct_interval{
        .first = 42634,
        .last = 42634,
    },
    struct_interval{
        .first = 42636,
        .last = 42636,
    },
    struct_interval{
        .first = 42638,
        .last = 42638,
    },
    struct_interval{
        .first = 42640,
        .last = 42640,
    },
    struct_interval{
        .first = 42642,
        .last = 42642,
    },
    struct_interval{
        .first = 42644,
        .last = 42644,
    },
    struct_interval{
        .first = 42646,
        .last = 42646,
    },
    struct_interval{
        .first = 42648,
        .last = 42648,
    },
    struct_interval{
        .first = 42650,
        .last = 42650,
    },
    struct_interval{
        .first = 42786,
        .last = 42786,
    },
    struct_interval{
        .first = 42788,
        .last = 42788,
    },
    struct_interval{
        .first = 42790,
        .last = 42790,
    },
    struct_interval{
        .first = 42792,
        .last = 42792,
    },
    struct_interval{
        .first = 42794,
        .last = 42794,
    },
    struct_interval{
        .first = 42796,
        .last = 42796,
    },
    struct_interval{
        .first = 42798,
        .last = 42798,
    },
    struct_interval{
        .first = 42802,
        .last = 42802,
    },
    struct_interval{
        .first = 42804,
        .last = 42804,
    },
    struct_interval{
        .first = 42806,
        .last = 42806,
    },
    struct_interval{
        .first = 42808,
        .last = 42808,
    },
    struct_interval{
        .first = 42810,
        .last = 42810,
    },
    struct_interval{
        .first = 42812,
        .last = 42812,
    },
    struct_interval{
        .first = 42814,
        .last = 42814,
    },
    struct_interval{
        .first = 42816,
        .last = 42816,
    },
    struct_interval{
        .first = 42818,
        .last = 42818,
    },
    struct_interval{
        .first = 42820,
        .last = 42820,
    },
    struct_interval{
        .first = 42822,
        .last = 42822,
    },
    struct_interval{
        .first = 42824,
        .last = 42824,
    },
    struct_interval{
        .first = 42826,
        .last = 42826,
    },
    struct_interval{
        .first = 42828,
        .last = 42828,
    },
    struct_interval{
        .first = 42830,
        .last = 42830,
    },
    struct_interval{
        .first = 42832,
        .last = 42832,
    },
    struct_interval{
        .first = 42834,
        .last = 42834,
    },
    struct_interval{
        .first = 42836,
        .last = 42836,
    },
    struct_interval{
        .first = 42838,
        .last = 42838,
    },
    struct_interval{
        .first = 42840,
        .last = 42840,
    },
    struct_interval{
        .first = 42842,
        .last = 42842,
    },
    struct_interval{
        .first = 42844,
        .last = 42844,
    },
    struct_interval{
        .first = 42846,
        .last = 42846,
    },
    struct_interval{
        .first = 42848,
        .last = 42848,
    },
    struct_interval{
        .first = 42850,
        .last = 42850,
    },
    struct_interval{
        .first = 42852,
        .last = 42852,
    },
    struct_interval{
        .first = 42854,
        .last = 42854,
    },
    struct_interval{
        .first = 42856,
        .last = 42856,
    },
    struct_interval{
        .first = 42858,
        .last = 42858,
    },
    struct_interval{
        .first = 42860,
        .last = 42860,
    },
    struct_interval{
        .first = 42862,
        .last = 42862,
    },
    struct_interval{
        .first = 42873,
        .last = 42873,
    },
    struct_interval{
        .first = 42875,
        .last = 42875,
    },
    struct_interval{
        .first = 42877,
        .last = 42877,
    },
    struct_interval{
        .first = 42878,
        .last = 42878,
    },
    struct_interval{
        .first = 42880,
        .last = 42880,
    },
    struct_interval{
        .first = 42882,
        .last = 42882,
    },
    struct_interval{
        .first = 42884,
        .last = 42884,
    },
    struct_interval{
        .first = 42886,
        .last = 42886,
    },
    struct_interval{
        .first = 42891,
        .last = 42891,
    },
    struct_interval{
        .first = 42893,
        .last = 42893,
    },
    struct_interval{
        .first = 42896,
        .last = 42896,
    },
    struct_interval{
        .first = 42898,
        .last = 42898,
    },
    struct_interval{
        .first = 42902,
        .last = 42902,
    },
    struct_interval{
        .first = 42904,
        .last = 42904,
    },
    struct_interval{
        .first = 42906,
        .last = 42906,
    },
    struct_interval{
        .first = 42908,
        .last = 42908,
    },
    struct_interval{
        .first = 42910,
        .last = 42910,
    },
    struct_interval{
        .first = 42912,
        .last = 42912,
    },
    struct_interval{
        .first = 42914,
        .last = 42914,
    },
    struct_interval{
        .first = 42916,
        .last = 42916,
    },
    struct_interval{
        .first = 42918,
        .last = 42918,
    },
    struct_interval{
        .first = 42920,
        .last = 42920,
    },
    struct_interval{
        .first = 42922,
        .last = 42922,
    },
    struct_interval{
        .first = 42923,
        .last = 42923,
    },
    struct_interval{
        .first = 42924,
        .last = 42924,
    },
    struct_interval{
        .first = 42925,
        .last = 42925,
    },
    struct_interval{
        .first = 42926,
        .last = 42926,
    },
    struct_interval{
        .first = 42928,
        .last = 42928,
    },
    struct_interval{
        .first = 42929,
        .last = 42929,
    },
    struct_interval{
        .first = 42930,
        .last = 42930,
    },
    struct_interval{
        .first = 42931,
        .last = 42931,
    },
    struct_interval{
        .first = 42932,
        .last = 42932,
    },
    struct_interval{
        .first = 42934,
        .last = 42934,
    },
    struct_interval{
        .first = 42936,
        .last = 42936,
    },
    struct_interval{
        .first = 42938,
        .last = 42938,
    },
    struct_interval{
        .first = 42940,
        .last = 42940,
    },
    struct_interval{
        .first = 42942,
        .last = 42942,
    },
    struct_interval{
        .first = 42944,
        .last = 42944,
    },
    struct_interval{
        .first = 42946,
        .last = 42946,
    },
    struct_interval{
        .first = 42948,
        .last = 42948,
    },
    struct_interval{
        .first = 42949,
        .last = 42949,
    },
    struct_interval{
        .first = 42950,
        .last = 42950,
    },
    struct_interval{
        .first = 42951,
        .last = 42951,
    },
    struct_interval{
        .first = 42953,
        .last = 42953,
    },
    struct_interval{
        .first = 42955,
        .last = 42955,
    },
    struct_interval{
        .first = 42956,
        .last = 42956,
    },
    struct_interval{
        .first = 42958,
        .last = 42958,
    },
    struct_interval{
        .first = 42960,
        .last = 42960,
    },
    struct_interval{
        .first = 42962,
        .last = 42962,
    },
    struct_interval{
        .first = 42964,
        .last = 42964,
    },
    struct_interval{
        .first = 42966,
        .last = 42966,
    },
    struct_interval{
        .first = 42968,
        .last = 42968,
    },
    struct_interval{
        .first = 42970,
        .last = 42970,
    },
    struct_interval{
        .first = 42972,
        .last = 42972,
    },
    struct_interval{
        .first = 42997,
        .last = 42997,
    },
    struct_interval{
        .first = 43888,
        .last = 43967,
    },
    struct_interval{
        .first = 64256,
        .last = 64256,
    },
    struct_interval{
        .first = 64257,
        .last = 64257,
    },
    struct_interval{
        .first = 64258,
        .last = 64258,
    },
    struct_interval{
        .first = 64259,
        .last = 64259,
    },
    struct_interval{
        .first = 64260,
        .last = 64260,
    },
    struct_interval{
        .first = 64261,
        .last = 64261,
    },
    struct_interval{
        .first = 64262,
        .last = 64262,
    },
    struct_interval{
        .first = 64275,
        .last = 64275,
    },
    struct_interval{
        .first = 64276,
        .last = 64276,
    },
    struct_interval{
        .first = 64277,
        .last = 64277,
    },
    struct_interval{
        .first = 64278,
        .last = 64278,
    },
    struct_interval{
        .first = 64279,
        .last = 64279,
    },
    struct_interval{
        .first = 65313,
        .last = 65338,
    },
    struct_interval{
        .first = 66560,
        .last = 66599,
    },
    struct_interval{
        .first = 66736,
        .last = 66771,
    },
    struct_interval{
        .first = 66928,
        .last = 66938,
    },
    struct_interval{
        .first = 66940,
        .last = 66954,
    },
    struct_interval{
        .first = 66956,
        .last = 66962,
    },
    struct_interval{
        .first = 66964,
        .last = 66965,
    },
    struct_interval{
        .first = 68736,
        .last = 68786,
    },
    struct_interval{
        .first = 68944,
        .last = 68965,
    },
    struct_interval{
        .first = 71840,
        .last = 71871,
    },
    struct_interval{
        .first = 93760,
        .last = 93791,
    },
    struct_interval{
        .first = 93856,
        .last = 93880,
    },
    struct_interval{
        .first = 125184,
        .last = 125217,
    },
    struct_interval{
        .first = 0,
        .last = 0,
    },
};
pub export const fold_repl: [795][3]c_int = [795][3]c_int{
    [3]c_int{
        97,
        0,
        0,
    },
    [3]c_int{
        956,
        0,
        0,
    },
    [3]c_int{
        224,
        0,
        0,
    },
    [3]c_int{
        248,
        0,
        0,
    },
    [3]c_int{
        115,
        115,
        0,
    },
    [3]c_int{
        257,
        0,
        0,
    },
    [3]c_int{
        259,
        0,
        0,
    },
    [3]c_int{
        261,
        0,
        0,
    },
    [3]c_int{
        263,
        0,
        0,
    },
    [3]c_int{
        265,
        0,
        0,
    },
    [3]c_int{
        267,
        0,
        0,
    },
    [3]c_int{
        269,
        0,
        0,
    },
    [3]c_int{
        271,
        0,
        0,
    },
    [3]c_int{
        273,
        0,
        0,
    },
    [3]c_int{
        275,
        0,
        0,
    },
    [3]c_int{
        277,
        0,
        0,
    },
    [3]c_int{
        279,
        0,
        0,
    },
    [3]c_int{
        281,
        0,
        0,
    },
    [3]c_int{
        283,
        0,
        0,
    },
    [3]c_int{
        285,
        0,
        0,
    },
    [3]c_int{
        287,
        0,
        0,
    },
    [3]c_int{
        289,
        0,
        0,
    },
    [3]c_int{
        291,
        0,
        0,
    },
    [3]c_int{
        293,
        0,
        0,
    },
    [3]c_int{
        295,
        0,
        0,
    },
    [3]c_int{
        297,
        0,
        0,
    },
    [3]c_int{
        299,
        0,
        0,
    },
    [3]c_int{
        301,
        0,
        0,
    },
    [3]c_int{
        303,
        0,
        0,
    },
    [3]c_int{
        105,
        775,
        0,
    },
    [3]c_int{
        307,
        0,
        0,
    },
    [3]c_int{
        309,
        0,
        0,
    },
    [3]c_int{
        311,
        0,
        0,
    },
    [3]c_int{
        314,
        0,
        0,
    },
    [3]c_int{
        316,
        0,
        0,
    },
    [3]c_int{
        318,
        0,
        0,
    },
    [3]c_int{
        320,
        0,
        0,
    },
    [3]c_int{
        322,
        0,
        0,
    },
    [3]c_int{
        324,
        0,
        0,
    },
    [3]c_int{
        326,
        0,
        0,
    },
    [3]c_int{
        328,
        0,
        0,
    },
    [3]c_int{
        700,
        110,
        0,
    },
    [3]c_int{
        331,
        0,
        0,
    },
    [3]c_int{
        333,
        0,
        0,
    },
    [3]c_int{
        335,
        0,
        0,
    },
    [3]c_int{
        337,
        0,
        0,
    },
    [3]c_int{
        339,
        0,
        0,
    },
    [3]c_int{
        341,
        0,
        0,
    },
    [3]c_int{
        343,
        0,
        0,
    },
    [3]c_int{
        345,
        0,
        0,
    },
    [3]c_int{
        347,
        0,
        0,
    },
    [3]c_int{
        349,
        0,
        0,
    },
    [3]c_int{
        351,
        0,
        0,
    },
    [3]c_int{
        353,
        0,
        0,
    },
    [3]c_int{
        355,
        0,
        0,
    },
    [3]c_int{
        357,
        0,
        0,
    },
    [3]c_int{
        359,
        0,
        0,
    },
    [3]c_int{
        361,
        0,
        0,
    },
    [3]c_int{
        363,
        0,
        0,
    },
    [3]c_int{
        365,
        0,
        0,
    },
    [3]c_int{
        367,
        0,
        0,
    },
    [3]c_int{
        369,
        0,
        0,
    },
    [3]c_int{
        371,
        0,
        0,
    },
    [3]c_int{
        373,
        0,
        0,
    },
    [3]c_int{
        375,
        0,
        0,
    },
    [3]c_int{
        255,
        0,
        0,
    },
    [3]c_int{
        378,
        0,
        0,
    },
    [3]c_int{
        380,
        0,
        0,
    },
    [3]c_int{
        382,
        0,
        0,
    },
    [3]c_int{
        115,
        0,
        0,
    },
    [3]c_int{
        595,
        0,
        0,
    },
    [3]c_int{
        387,
        0,
        0,
    },
    [3]c_int{
        389,
        0,
        0,
    },
    [3]c_int{
        596,
        0,
        0,
    },
    [3]c_int{
        392,
        0,
        0,
    },
    [3]c_int{
        598,
        0,
        0,
    },
    [3]c_int{
        396,
        0,
        0,
    },
    [3]c_int{
        477,
        0,
        0,
    },
    [3]c_int{
        601,
        0,
        0,
    },
    [3]c_int{
        603,
        0,
        0,
    },
    [3]c_int{
        402,
        0,
        0,
    },
    [3]c_int{
        608,
        0,
        0,
    },
    [3]c_int{
        611,
        0,
        0,
    },
    [3]c_int{
        617,
        0,
        0,
    },
    [3]c_int{
        616,
        0,
        0,
    },
    [3]c_int{
        409,
        0,
        0,
    },
    [3]c_int{
        623,
        0,
        0,
    },
    [3]c_int{
        626,
        0,
        0,
    },
    [3]c_int{
        629,
        0,
        0,
    },
    [3]c_int{
        417,
        0,
        0,
    },
    [3]c_int{
        419,
        0,
        0,
    },
    [3]c_int{
        421,
        0,
        0,
    },
    [3]c_int{
        640,
        0,
        0,
    },
    [3]c_int{
        424,
        0,
        0,
    },
    [3]c_int{
        643,
        0,
        0,
    },
    [3]c_int{
        429,
        0,
        0,
    },
    [3]c_int{
        648,
        0,
        0,
    },
    [3]c_int{
        432,
        0,
        0,
    },
    [3]c_int{
        650,
        0,
        0,
    },
    [3]c_int{
        436,
        0,
        0,
    },
    [3]c_int{
        438,
        0,
        0,
    },
    [3]c_int{
        658,
        0,
        0,
    },
    [3]c_int{
        441,
        0,
        0,
    },
    [3]c_int{
        445,
        0,
        0,
    },
    [3]c_int{
        454,
        0,
        0,
    },
    [3]c_int{
        454,
        0,
        0,
    },
    [3]c_int{
        457,
        0,
        0,
    },
    [3]c_int{
        457,
        0,
        0,
    },
    [3]c_int{
        460,
        0,
        0,
    },
    [3]c_int{
        460,
        0,
        0,
    },
    [3]c_int{
        462,
        0,
        0,
    },
    [3]c_int{
        464,
        0,
        0,
    },
    [3]c_int{
        466,
        0,
        0,
    },
    [3]c_int{
        468,
        0,
        0,
    },
    [3]c_int{
        470,
        0,
        0,
    },
    [3]c_int{
        472,
        0,
        0,
    },
    [3]c_int{
        474,
        0,
        0,
    },
    [3]c_int{
        476,
        0,
        0,
    },
    [3]c_int{
        479,
        0,
        0,
    },
    [3]c_int{
        481,
        0,
        0,
    },
    [3]c_int{
        483,
        0,
        0,
    },
    [3]c_int{
        485,
        0,
        0,
    },
    [3]c_int{
        487,
        0,
        0,
    },
    [3]c_int{
        489,
        0,
        0,
    },
    [3]c_int{
        491,
        0,
        0,
    },
    [3]c_int{
        493,
        0,
        0,
    },
    [3]c_int{
        495,
        0,
        0,
    },
    [3]c_int{
        106,
        780,
        0,
    },
    [3]c_int{
        499,
        0,
        0,
    },
    [3]c_int{
        499,
        0,
        0,
    },
    [3]c_int{
        501,
        0,
        0,
    },
    [3]c_int{
        405,
        0,
        0,
    },
    [3]c_int{
        447,
        0,
        0,
    },
    [3]c_int{
        505,
        0,
        0,
    },
    [3]c_int{
        507,
        0,
        0,
    },
    [3]c_int{
        509,
        0,
        0,
    },
    [3]c_int{
        511,
        0,
        0,
    },
    [3]c_int{
        513,
        0,
        0,
    },
    [3]c_int{
        515,
        0,
        0,
    },
    [3]c_int{
        517,
        0,
        0,
    },
    [3]c_int{
        519,
        0,
        0,
    },
    [3]c_int{
        521,
        0,
        0,
    },
    [3]c_int{
        523,
        0,
        0,
    },
    [3]c_int{
        525,
        0,
        0,
    },
    [3]c_int{
        527,
        0,
        0,
    },
    [3]c_int{
        529,
        0,
        0,
    },
    [3]c_int{
        531,
        0,
        0,
    },
    [3]c_int{
        533,
        0,
        0,
    },
    [3]c_int{
        535,
        0,
        0,
    },
    [3]c_int{
        537,
        0,
        0,
    },
    [3]c_int{
        539,
        0,
        0,
    },
    [3]c_int{
        541,
        0,
        0,
    },
    [3]c_int{
        543,
        0,
        0,
    },
    [3]c_int{
        414,
        0,
        0,
    },
    [3]c_int{
        547,
        0,
        0,
    },
    [3]c_int{
        549,
        0,
        0,
    },
    [3]c_int{
        551,
        0,
        0,
    },
    [3]c_int{
        553,
        0,
        0,
    },
    [3]c_int{
        555,
        0,
        0,
    },
    [3]c_int{
        557,
        0,
        0,
    },
    [3]c_int{
        559,
        0,
        0,
    },
    [3]c_int{
        561,
        0,
        0,
    },
    [3]c_int{
        563,
        0,
        0,
    },
    [3]c_int{
        11365,
        0,
        0,
    },
    [3]c_int{
        572,
        0,
        0,
    },
    [3]c_int{
        410,
        0,
        0,
    },
    [3]c_int{
        11366,
        0,
        0,
    },
    [3]c_int{
        578,
        0,
        0,
    },
    [3]c_int{
        384,
        0,
        0,
    },
    [3]c_int{
        649,
        0,
        0,
    },
    [3]c_int{
        652,
        0,
        0,
    },
    [3]c_int{
        583,
        0,
        0,
    },
    [3]c_int{
        585,
        0,
        0,
    },
    [3]c_int{
        587,
        0,
        0,
    },
    [3]c_int{
        589,
        0,
        0,
    },
    [3]c_int{
        591,
        0,
        0,
    },
    [3]c_int{
        953,
        0,
        0,
    },
    [3]c_int{
        881,
        0,
        0,
    },
    [3]c_int{
        883,
        0,
        0,
    },
    [3]c_int{
        887,
        0,
        0,
    },
    [3]c_int{
        1011,
        0,
        0,
    },
    [3]c_int{
        940,
        0,
        0,
    },
    [3]c_int{
        941,
        0,
        0,
    },
    [3]c_int{
        972,
        0,
        0,
    },
    [3]c_int{
        973,
        0,
        0,
    },
    [3]c_int{
        953,
        776,
        769,
    },
    [3]c_int{
        945,
        0,
        0,
    },
    [3]c_int{
        963,
        0,
        0,
    },
    [3]c_int{
        965,
        776,
        769,
    },
    [3]c_int{
        963,
        0,
        0,
    },
    [3]c_int{
        983,
        0,
        0,
    },
    [3]c_int{
        946,
        0,
        0,
    },
    [3]c_int{
        952,
        0,
        0,
    },
    [3]c_int{
        966,
        0,
        0,
    },
    [3]c_int{
        960,
        0,
        0,
    },
    [3]c_int{
        985,
        0,
        0,
    },
    [3]c_int{
        987,
        0,
        0,
    },
    [3]c_int{
        989,
        0,
        0,
    },
    [3]c_int{
        991,
        0,
        0,
    },
    [3]c_int{
        993,
        0,
        0,
    },
    [3]c_int{
        995,
        0,
        0,
    },
    [3]c_int{
        997,
        0,
        0,
    },
    [3]c_int{
        999,
        0,
        0,
    },
    [3]c_int{
        1001,
        0,
        0,
    },
    [3]c_int{
        1003,
        0,
        0,
    },
    [3]c_int{
        1005,
        0,
        0,
    },
    [3]c_int{
        1007,
        0,
        0,
    },
    [3]c_int{
        954,
        0,
        0,
    },
    [3]c_int{
        961,
        0,
        0,
    },
    [3]c_int{
        952,
        0,
        0,
    },
    [3]c_int{
        949,
        0,
        0,
    },
    [3]c_int{
        1016,
        0,
        0,
    },
    [3]c_int{
        1010,
        0,
        0,
    },
    [3]c_int{
        1019,
        0,
        0,
    },
    [3]c_int{
        891,
        0,
        0,
    },
    [3]c_int{
        1104,
        0,
        0,
    },
    [3]c_int{
        1072,
        0,
        0,
    },
    [3]c_int{
        1121,
        0,
        0,
    },
    [3]c_int{
        1123,
        0,
        0,
    },
    [3]c_int{
        1125,
        0,
        0,
    },
    [3]c_int{
        1127,
        0,
        0,
    },
    [3]c_int{
        1129,
        0,
        0,
    },
    [3]c_int{
        1131,
        0,
        0,
    },
    [3]c_int{
        1133,
        0,
        0,
    },
    [3]c_int{
        1135,
        0,
        0,
    },
    [3]c_int{
        1137,
        0,
        0,
    },
    [3]c_int{
        1139,
        0,
        0,
    },
    [3]c_int{
        1141,
        0,
        0,
    },
    [3]c_int{
        1143,
        0,
        0,
    },
    [3]c_int{
        1145,
        0,
        0,
    },
    [3]c_int{
        1147,
        0,
        0,
    },
    [3]c_int{
        1149,
        0,
        0,
    },
    [3]c_int{
        1151,
        0,
        0,
    },
    [3]c_int{
        1153,
        0,
        0,
    },
    [3]c_int{
        1163,
        0,
        0,
    },
    [3]c_int{
        1165,
        0,
        0,
    },
    [3]c_int{
        1167,
        0,
        0,
    },
    [3]c_int{
        1169,
        0,
        0,
    },
    [3]c_int{
        1171,
        0,
        0,
    },
    [3]c_int{
        1173,
        0,
        0,
    },
    [3]c_int{
        1175,
        0,
        0,
    },
    [3]c_int{
        1177,
        0,
        0,
    },
    [3]c_int{
        1179,
        0,
        0,
    },
    [3]c_int{
        1181,
        0,
        0,
    },
    [3]c_int{
        1183,
        0,
        0,
    },
    [3]c_int{
        1185,
        0,
        0,
    },
    [3]c_int{
        1187,
        0,
        0,
    },
    [3]c_int{
        1189,
        0,
        0,
    },
    [3]c_int{
        1191,
        0,
        0,
    },
    [3]c_int{
        1193,
        0,
        0,
    },
    [3]c_int{
        1195,
        0,
        0,
    },
    [3]c_int{
        1197,
        0,
        0,
    },
    [3]c_int{
        1199,
        0,
        0,
    },
    [3]c_int{
        1201,
        0,
        0,
    },
    [3]c_int{
        1203,
        0,
        0,
    },
    [3]c_int{
        1205,
        0,
        0,
    },
    [3]c_int{
        1207,
        0,
        0,
    },
    [3]c_int{
        1209,
        0,
        0,
    },
    [3]c_int{
        1211,
        0,
        0,
    },
    [3]c_int{
        1213,
        0,
        0,
    },
    [3]c_int{
        1215,
        0,
        0,
    },
    [3]c_int{
        1231,
        0,
        0,
    },
    [3]c_int{
        1218,
        0,
        0,
    },
    [3]c_int{
        1220,
        0,
        0,
    },
    [3]c_int{
        1222,
        0,
        0,
    },
    [3]c_int{
        1224,
        0,
        0,
    },
    [3]c_int{
        1226,
        0,
        0,
    },
    [3]c_int{
        1228,
        0,
        0,
    },
    [3]c_int{
        1230,
        0,
        0,
    },
    [3]c_int{
        1233,
        0,
        0,
    },
    [3]c_int{
        1235,
        0,
        0,
    },
    [3]c_int{
        1237,
        0,
        0,
    },
    [3]c_int{
        1239,
        0,
        0,
    },
    [3]c_int{
        1241,
        0,
        0,
    },
    [3]c_int{
        1243,
        0,
        0,
    },
    [3]c_int{
        1245,
        0,
        0,
    },
    [3]c_int{
        1247,
        0,
        0,
    },
    [3]c_int{
        1249,
        0,
        0,
    },
    [3]c_int{
        1251,
        0,
        0,
    },
    [3]c_int{
        1253,
        0,
        0,
    },
    [3]c_int{
        1255,
        0,
        0,
    },
    [3]c_int{
        1257,
        0,
        0,
    },
    [3]c_int{
        1259,
        0,
        0,
    },
    [3]c_int{
        1261,
        0,
        0,
    },
    [3]c_int{
        1263,
        0,
        0,
    },
    [3]c_int{
        1265,
        0,
        0,
    },
    [3]c_int{
        1267,
        0,
        0,
    },
    [3]c_int{
        1269,
        0,
        0,
    },
    [3]c_int{
        1271,
        0,
        0,
    },
    [3]c_int{
        1273,
        0,
        0,
    },
    [3]c_int{
        1275,
        0,
        0,
    },
    [3]c_int{
        1277,
        0,
        0,
    },
    [3]c_int{
        1279,
        0,
        0,
    },
    [3]c_int{
        1281,
        0,
        0,
    },
    [3]c_int{
        1283,
        0,
        0,
    },
    [3]c_int{
        1285,
        0,
        0,
    },
    [3]c_int{
        1287,
        0,
        0,
    },
    [3]c_int{
        1289,
        0,
        0,
    },
    [3]c_int{
        1291,
        0,
        0,
    },
    [3]c_int{
        1293,
        0,
        0,
    },
    [3]c_int{
        1295,
        0,
        0,
    },
    [3]c_int{
        1297,
        0,
        0,
    },
    [3]c_int{
        1299,
        0,
        0,
    },
    [3]c_int{
        1301,
        0,
        0,
    },
    [3]c_int{
        1303,
        0,
        0,
    },
    [3]c_int{
        1305,
        0,
        0,
    },
    [3]c_int{
        1307,
        0,
        0,
    },
    [3]c_int{
        1309,
        0,
        0,
    },
    [3]c_int{
        1311,
        0,
        0,
    },
    [3]c_int{
        1313,
        0,
        0,
    },
    [3]c_int{
        1315,
        0,
        0,
    },
    [3]c_int{
        1317,
        0,
        0,
    },
    [3]c_int{
        1319,
        0,
        0,
    },
    [3]c_int{
        1321,
        0,
        0,
    },
    [3]c_int{
        1323,
        0,
        0,
    },
    [3]c_int{
        1325,
        0,
        0,
    },
    [3]c_int{
        1327,
        0,
        0,
    },
    [3]c_int{
        1377,
        0,
        0,
    },
    [3]c_int{
        1381,
        1410,
        0,
    },
    [3]c_int{
        11520,
        0,
        0,
    },
    [3]c_int{
        11559,
        0,
        0,
    },
    [3]c_int{
        11565,
        0,
        0,
    },
    [3]c_int{
        5104,
        0,
        0,
    },
    [3]c_int{
        1074,
        0,
        0,
    },
    [3]c_int{
        1076,
        0,
        0,
    },
    [3]c_int{
        1086,
        0,
        0,
    },
    [3]c_int{
        1089,
        0,
        0,
    },
    [3]c_int{
        1090,
        0,
        0,
    },
    [3]c_int{
        1098,
        0,
        0,
    },
    [3]c_int{
        1123,
        0,
        0,
    },
    [3]c_int{
        42571,
        0,
        0,
    },
    [3]c_int{
        7306,
        0,
        0,
    },
    [3]c_int{
        4304,
        0,
        0,
    },
    [3]c_int{
        4349,
        0,
        0,
    },
    [3]c_int{
        7681,
        0,
        0,
    },
    [3]c_int{
        7683,
        0,
        0,
    },
    [3]c_int{
        7685,
        0,
        0,
    },
    [3]c_int{
        7687,
        0,
        0,
    },
    [3]c_int{
        7689,
        0,
        0,
    },
    [3]c_int{
        7691,
        0,
        0,
    },
    [3]c_int{
        7693,
        0,
        0,
    },
    [3]c_int{
        7695,
        0,
        0,
    },
    [3]c_int{
        7697,
        0,
        0,
    },
    [3]c_int{
        7699,
        0,
        0,
    },
    [3]c_int{
        7701,
        0,
        0,
    },
    [3]c_int{
        7703,
        0,
        0,
    },
    [3]c_int{
        7705,
        0,
        0,
    },
    [3]c_int{
        7707,
        0,
        0,
    },
    [3]c_int{
        7709,
        0,
        0,
    },
    [3]c_int{
        7711,
        0,
        0,
    },
    [3]c_int{
        7713,
        0,
        0,
    },
    [3]c_int{
        7715,
        0,
        0,
    },
    [3]c_int{
        7717,
        0,
        0,
    },
    [3]c_int{
        7719,
        0,
        0,
    },
    [3]c_int{
        7721,
        0,
        0,
    },
    [3]c_int{
        7723,
        0,
        0,
    },
    [3]c_int{
        7725,
        0,
        0,
    },
    [3]c_int{
        7727,
        0,
        0,
    },
    [3]c_int{
        7729,
        0,
        0,
    },
    [3]c_int{
        7731,
        0,
        0,
    },
    [3]c_int{
        7733,
        0,
        0,
    },
    [3]c_int{
        7735,
        0,
        0,
    },
    [3]c_int{
        7737,
        0,
        0,
    },
    [3]c_int{
        7739,
        0,
        0,
    },
    [3]c_int{
        7741,
        0,
        0,
    },
    [3]c_int{
        7743,
        0,
        0,
    },
    [3]c_int{
        7745,
        0,
        0,
    },
    [3]c_int{
        7747,
        0,
        0,
    },
    [3]c_int{
        7749,
        0,
        0,
    },
    [3]c_int{
        7751,
        0,
        0,
    },
    [3]c_int{
        7753,
        0,
        0,
    },
    [3]c_int{
        7755,
        0,
        0,
    },
    [3]c_int{
        7757,
        0,
        0,
    },
    [3]c_int{
        7759,
        0,
        0,
    },
    [3]c_int{
        7761,
        0,
        0,
    },
    [3]c_int{
        7763,
        0,
        0,
    },
    [3]c_int{
        7765,
        0,
        0,
    },
    [3]c_int{
        7767,
        0,
        0,
    },
    [3]c_int{
        7769,
        0,
        0,
    },
    [3]c_int{
        7771,
        0,
        0,
    },
    [3]c_int{
        7773,
        0,
        0,
    },
    [3]c_int{
        7775,
        0,
        0,
    },
    [3]c_int{
        7777,
        0,
        0,
    },
    [3]c_int{
        7779,
        0,
        0,
    },
    [3]c_int{
        7781,
        0,
        0,
    },
    [3]c_int{
        7783,
        0,
        0,
    },
    [3]c_int{
        7785,
        0,
        0,
    },
    [3]c_int{
        7787,
        0,
        0,
    },
    [3]c_int{
        7789,
        0,
        0,
    },
    [3]c_int{
        7791,
        0,
        0,
    },
    [3]c_int{
        7793,
        0,
        0,
    },
    [3]c_int{
        7795,
        0,
        0,
    },
    [3]c_int{
        7797,
        0,
        0,
    },
    [3]c_int{
        7799,
        0,
        0,
    },
    [3]c_int{
        7801,
        0,
        0,
    },
    [3]c_int{
        7803,
        0,
        0,
    },
    [3]c_int{
        7805,
        0,
        0,
    },
    [3]c_int{
        7807,
        0,
        0,
    },
    [3]c_int{
        7809,
        0,
        0,
    },
    [3]c_int{
        7811,
        0,
        0,
    },
    [3]c_int{
        7813,
        0,
        0,
    },
    [3]c_int{
        7815,
        0,
        0,
    },
    [3]c_int{
        7817,
        0,
        0,
    },
    [3]c_int{
        7819,
        0,
        0,
    },
    [3]c_int{
        7821,
        0,
        0,
    },
    [3]c_int{
        7823,
        0,
        0,
    },
    [3]c_int{
        7825,
        0,
        0,
    },
    [3]c_int{
        7827,
        0,
        0,
    },
    [3]c_int{
        7829,
        0,
        0,
    },
    [3]c_int{
        104,
        817,
        0,
    },
    [3]c_int{
        116,
        776,
        0,
    },
    [3]c_int{
        119,
        778,
        0,
    },
    [3]c_int{
        121,
        778,
        0,
    },
    [3]c_int{
        97,
        702,
        0,
    },
    [3]c_int{
        7777,
        0,
        0,
    },
    [3]c_int{
        115,
        115,
        0,
    },
    [3]c_int{
        7841,
        0,
        0,
    },
    [3]c_int{
        7843,
        0,
        0,
    },
    [3]c_int{
        7845,
        0,
        0,
    },
    [3]c_int{
        7847,
        0,
        0,
    },
    [3]c_int{
        7849,
        0,
        0,
    },
    [3]c_int{
        7851,
        0,
        0,
    },
    [3]c_int{
        7853,
        0,
        0,
    },
    [3]c_int{
        7855,
        0,
        0,
    },
    [3]c_int{
        7857,
        0,
        0,
    },
    [3]c_int{
        7859,
        0,
        0,
    },
    [3]c_int{
        7861,
        0,
        0,
    },
    [3]c_int{
        7863,
        0,
        0,
    },
    [3]c_int{
        7865,
        0,
        0,
    },
    [3]c_int{
        7867,
        0,
        0,
    },
    [3]c_int{
        7869,
        0,
        0,
    },
    [3]c_int{
        7871,
        0,
        0,
    },
    [3]c_int{
        7873,
        0,
        0,
    },
    [3]c_int{
        7875,
        0,
        0,
    },
    [3]c_int{
        7877,
        0,
        0,
    },
    [3]c_int{
        7879,
        0,
        0,
    },
    [3]c_int{
        7881,
        0,
        0,
    },
    [3]c_int{
        7883,
        0,
        0,
    },
    [3]c_int{
        7885,
        0,
        0,
    },
    [3]c_int{
        7887,
        0,
        0,
    },
    [3]c_int{
        7889,
        0,
        0,
    },
    [3]c_int{
        7891,
        0,
        0,
    },
    [3]c_int{
        7893,
        0,
        0,
    },
    [3]c_int{
        7895,
        0,
        0,
    },
    [3]c_int{
        7897,
        0,
        0,
    },
    [3]c_int{
        7899,
        0,
        0,
    },
    [3]c_int{
        7901,
        0,
        0,
    },
    [3]c_int{
        7903,
        0,
        0,
    },
    [3]c_int{
        7905,
        0,
        0,
    },
    [3]c_int{
        7907,
        0,
        0,
    },
    [3]c_int{
        7909,
        0,
        0,
    },
    [3]c_int{
        7911,
        0,
        0,
    },
    [3]c_int{
        7913,
        0,
        0,
    },
    [3]c_int{
        7915,
        0,
        0,
    },
    [3]c_int{
        7917,
        0,
        0,
    },
    [3]c_int{
        7919,
        0,
        0,
    },
    [3]c_int{
        7921,
        0,
        0,
    },
    [3]c_int{
        7923,
        0,
        0,
    },
    [3]c_int{
        7925,
        0,
        0,
    },
    [3]c_int{
        7927,
        0,
        0,
    },
    [3]c_int{
        7929,
        0,
        0,
    },
    [3]c_int{
        7931,
        0,
        0,
    },
    [3]c_int{
        7933,
        0,
        0,
    },
    [3]c_int{
        7935,
        0,
        0,
    },
    [3]c_int{
        7936,
        0,
        0,
    },
    [3]c_int{
        7952,
        0,
        0,
    },
    [3]c_int{
        7968,
        0,
        0,
    },
    [3]c_int{
        7984,
        0,
        0,
    },
    [3]c_int{
        8000,
        0,
        0,
    },
    [3]c_int{
        965,
        787,
        0,
    },
    [3]c_int{
        965,
        787,
        768,
    },
    [3]c_int{
        965,
        787,
        769,
    },
    [3]c_int{
        965,
        787,
        834,
    },
    [3]c_int{
        8017,
        0,
        0,
    },
    [3]c_int{
        8019,
        0,
        0,
    },
    [3]c_int{
        8021,
        0,
        0,
    },
    [3]c_int{
        8023,
        0,
        0,
    },
    [3]c_int{
        8032,
        0,
        0,
    },
    [3]c_int{
        7936,
        953,
        0,
    },
    [3]c_int{
        7937,
        953,
        0,
    },
    [3]c_int{
        7938,
        953,
        0,
    },
    [3]c_int{
        7939,
        953,
        0,
    },
    [3]c_int{
        7940,
        953,
        0,
    },
    [3]c_int{
        7941,
        953,
        0,
    },
    [3]c_int{
        7942,
        953,
        0,
    },
    [3]c_int{
        7943,
        953,
        0,
    },
    [3]c_int{
        7936,
        953,
        0,
    },
    [3]c_int{
        7937,
        953,
        0,
    },
    [3]c_int{
        7938,
        953,
        0,
    },
    [3]c_int{
        7939,
        953,
        0,
    },
    [3]c_int{
        7940,
        953,
        0,
    },
    [3]c_int{
        7941,
        953,
        0,
    },
    [3]c_int{
        7942,
        953,
        0,
    },
    [3]c_int{
        7943,
        953,
        0,
    },
    [3]c_int{
        7968,
        953,
        0,
    },
    [3]c_int{
        7969,
        953,
        0,
    },
    [3]c_int{
        7970,
        953,
        0,
    },
    [3]c_int{
        7971,
        953,
        0,
    },
    [3]c_int{
        7972,
        953,
        0,
    },
    [3]c_int{
        7973,
        953,
        0,
    },
    [3]c_int{
        7974,
        953,
        0,
    },
    [3]c_int{
        7975,
        953,
        0,
    },
    [3]c_int{
        7968,
        953,
        0,
    },
    [3]c_int{
        7969,
        953,
        0,
    },
    [3]c_int{
        7970,
        953,
        0,
    },
    [3]c_int{
        7971,
        953,
        0,
    },
    [3]c_int{
        7972,
        953,
        0,
    },
    [3]c_int{
        7973,
        953,
        0,
    },
    [3]c_int{
        7974,
        953,
        0,
    },
    [3]c_int{
        7975,
        953,
        0,
    },
    [3]c_int{
        8032,
        953,
        0,
    },
    [3]c_int{
        8033,
        953,
        0,
    },
    [3]c_int{
        8034,
        953,
        0,
    },
    [3]c_int{
        8035,
        953,
        0,
    },
    [3]c_int{
        8036,
        953,
        0,
    },
    [3]c_int{
        8037,
        953,
        0,
    },
    [3]c_int{
        8038,
        953,
        0,
    },
    [3]c_int{
        8039,
        953,
        0,
    },
    [3]c_int{
        8032,
        953,
        0,
    },
    [3]c_int{
        8033,
        953,
        0,
    },
    [3]c_int{
        8034,
        953,
        0,
    },
    [3]c_int{
        8035,
        953,
        0,
    },
    [3]c_int{
        8036,
        953,
        0,
    },
    [3]c_int{
        8037,
        953,
        0,
    },
    [3]c_int{
        8038,
        953,
        0,
    },
    [3]c_int{
        8039,
        953,
        0,
    },
    [3]c_int{
        8048,
        953,
        0,
    },
    [3]c_int{
        945,
        953,
        0,
    },
    [3]c_int{
        940,
        953,
        0,
    },
    [3]c_int{
        945,
        834,
        0,
    },
    [3]c_int{
        945,
        834,
        953,
    },
    [3]c_int{
        8112,
        0,
        0,
    },
    [3]c_int{
        8048,
        0,
        0,
    },
    [3]c_int{
        945,
        953,
        0,
    },
    [3]c_int{
        953,
        0,
        0,
    },
    [3]c_int{
        8052,
        953,
        0,
    },
    [3]c_int{
        951,
        953,
        0,
    },
    [3]c_int{
        942,
        953,
        0,
    },
    [3]c_int{
        951,
        834,
        0,
    },
    [3]c_int{
        951,
        834,
        953,
    },
    [3]c_int{
        8050,
        0,
        0,
    },
    [3]c_int{
        951,
        953,
        0,
    },
    [3]c_int{
        953,
        776,
        768,
    },
    [3]c_int{
        953,
        776,
        769,
    },
    [3]c_int{
        953,
        834,
        0,
    },
    [3]c_int{
        953,
        776,
        834,
    },
    [3]c_int{
        8144,
        0,
        0,
    },
    [3]c_int{
        8054,
        0,
        0,
    },
    [3]c_int{
        965,
        776,
        768,
    },
    [3]c_int{
        965,
        776,
        769,
    },
    [3]c_int{
        961,
        787,
        0,
    },
    [3]c_int{
        965,
        834,
        0,
    },
    [3]c_int{
        965,
        776,
        834,
    },
    [3]c_int{
        8160,
        0,
        0,
    },
    [3]c_int{
        8058,
        0,
        0,
    },
    [3]c_int{
        8165,
        0,
        0,
    },
    [3]c_int{
        8060,
        953,
        0,
    },
    [3]c_int{
        969,
        953,
        0,
    },
    [3]c_int{
        974,
        953,
        0,
    },
    [3]c_int{
        969,
        834,
        0,
    },
    [3]c_int{
        969,
        834,
        953,
    },
    [3]c_int{
        8056,
        0,
        0,
    },
    [3]c_int{
        8060,
        0,
        0,
    },
    [3]c_int{
        969,
        953,
        0,
    },
    [3]c_int{
        969,
        0,
        0,
    },
    [3]c_int{
        107,
        0,
        0,
    },
    [3]c_int{
        229,
        0,
        0,
    },
    [3]c_int{
        8526,
        0,
        0,
    },
    [3]c_int{
        8560,
        0,
        0,
    },
    [3]c_int{
        8580,
        0,
        0,
    },
    [3]c_int{
        9424,
        0,
        0,
    },
    [3]c_int{
        11312,
        0,
        0,
    },
    [3]c_int{
        11361,
        0,
        0,
    },
    [3]c_int{
        619,
        0,
        0,
    },
    [3]c_int{
        7549,
        0,
        0,
    },
    [3]c_int{
        637,
        0,
        0,
    },
    [3]c_int{
        11368,
        0,
        0,
    },
    [3]c_int{
        11370,
        0,
        0,
    },
    [3]c_int{
        11372,
        0,
        0,
    },
    [3]c_int{
        593,
        0,
        0,
    },
    [3]c_int{
        625,
        0,
        0,
    },
    [3]c_int{
        592,
        0,
        0,
    },
    [3]c_int{
        594,
        0,
        0,
    },
    [3]c_int{
        11379,
        0,
        0,
    },
    [3]c_int{
        11382,
        0,
        0,
    },
    [3]c_int{
        575,
        0,
        0,
    },
    [3]c_int{
        11393,
        0,
        0,
    },
    [3]c_int{
        11395,
        0,
        0,
    },
    [3]c_int{
        11397,
        0,
        0,
    },
    [3]c_int{
        11399,
        0,
        0,
    },
    [3]c_int{
        11401,
        0,
        0,
    },
    [3]c_int{
        11403,
        0,
        0,
    },
    [3]c_int{
        11405,
        0,
        0,
    },
    [3]c_int{
        11407,
        0,
        0,
    },
    [3]c_int{
        11409,
        0,
        0,
    },
    [3]c_int{
        11411,
        0,
        0,
    },
    [3]c_int{
        11413,
        0,
        0,
    },
    [3]c_int{
        11415,
        0,
        0,
    },
    [3]c_int{
        11417,
        0,
        0,
    },
    [3]c_int{
        11419,
        0,
        0,
    },
    [3]c_int{
        11421,
        0,
        0,
    },
    [3]c_int{
        11423,
        0,
        0,
    },
    [3]c_int{
        11425,
        0,
        0,
    },
    [3]c_int{
        11427,
        0,
        0,
    },
    [3]c_int{
        11429,
        0,
        0,
    },
    [3]c_int{
        11431,
        0,
        0,
    },
    [3]c_int{
        11433,
        0,
        0,
    },
    [3]c_int{
        11435,
        0,
        0,
    },
    [3]c_int{
        11437,
        0,
        0,
    },
    [3]c_int{
        11439,
        0,
        0,
    },
    [3]c_int{
        11441,
        0,
        0,
    },
    [3]c_int{
        11443,
        0,
        0,
    },
    [3]c_int{
        11445,
        0,
        0,
    },
    [3]c_int{
        11447,
        0,
        0,
    },
    [3]c_int{
        11449,
        0,
        0,
    },
    [3]c_int{
        11451,
        0,
        0,
    },
    [3]c_int{
        11453,
        0,
        0,
    },
    [3]c_int{
        11455,
        0,
        0,
    },
    [3]c_int{
        11457,
        0,
        0,
    },
    [3]c_int{
        11459,
        0,
        0,
    },
    [3]c_int{
        11461,
        0,
        0,
    },
    [3]c_int{
        11463,
        0,
        0,
    },
    [3]c_int{
        11465,
        0,
        0,
    },
    [3]c_int{
        11467,
        0,
        0,
    },
    [3]c_int{
        11469,
        0,
        0,
    },
    [3]c_int{
        11471,
        0,
        0,
    },
    [3]c_int{
        11473,
        0,
        0,
    },
    [3]c_int{
        11475,
        0,
        0,
    },
    [3]c_int{
        11477,
        0,
        0,
    },
    [3]c_int{
        11479,
        0,
        0,
    },
    [3]c_int{
        11481,
        0,
        0,
    },
    [3]c_int{
        11483,
        0,
        0,
    },
    [3]c_int{
        11485,
        0,
        0,
    },
    [3]c_int{
        11487,
        0,
        0,
    },
    [3]c_int{
        11489,
        0,
        0,
    },
    [3]c_int{
        11491,
        0,
        0,
    },
    [3]c_int{
        11500,
        0,
        0,
    },
    [3]c_int{
        11502,
        0,
        0,
    },
    [3]c_int{
        11507,
        0,
        0,
    },
    [3]c_int{
        42561,
        0,
        0,
    },
    [3]c_int{
        42563,
        0,
        0,
    },
    [3]c_int{
        42565,
        0,
        0,
    },
    [3]c_int{
        42567,
        0,
        0,
    },
    [3]c_int{
        42569,
        0,
        0,
    },
    [3]c_int{
        42571,
        0,
        0,
    },
    [3]c_int{
        42573,
        0,
        0,
    },
    [3]c_int{
        42575,
        0,
        0,
    },
    [3]c_int{
        42577,
        0,
        0,
    },
    [3]c_int{
        42579,
        0,
        0,
    },
    [3]c_int{
        42581,
        0,
        0,
    },
    [3]c_int{
        42583,
        0,
        0,
    },
    [3]c_int{
        42585,
        0,
        0,
    },
    [3]c_int{
        42587,
        0,
        0,
    },
    [3]c_int{
        42589,
        0,
        0,
    },
    [3]c_int{
        42591,
        0,
        0,
    },
    [3]c_int{
        42593,
        0,
        0,
    },
    [3]c_int{
        42595,
        0,
        0,
    },
    [3]c_int{
        42597,
        0,
        0,
    },
    [3]c_int{
        42599,
        0,
        0,
    },
    [3]c_int{
        42601,
        0,
        0,
    },
    [3]c_int{
        42603,
        0,
        0,
    },
    [3]c_int{
        42605,
        0,
        0,
    },
    [3]c_int{
        42625,
        0,
        0,
    },
    [3]c_int{
        42627,
        0,
        0,
    },
    [3]c_int{
        42629,
        0,
        0,
    },
    [3]c_int{
        42631,
        0,
        0,
    },
    [3]c_int{
        42633,
        0,
        0,
    },
    [3]c_int{
        42635,
        0,
        0,
    },
    [3]c_int{
        42637,
        0,
        0,
    },
    [3]c_int{
        42639,
        0,
        0,
    },
    [3]c_int{
        42641,
        0,
        0,
    },
    [3]c_int{
        42643,
        0,
        0,
    },
    [3]c_int{
        42645,
        0,
        0,
    },
    [3]c_int{
        42647,
        0,
        0,
    },
    [3]c_int{
        42649,
        0,
        0,
    },
    [3]c_int{
        42651,
        0,
        0,
    },
    [3]c_int{
        42787,
        0,
        0,
    },
    [3]c_int{
        42789,
        0,
        0,
    },
    [3]c_int{
        42791,
        0,
        0,
    },
    [3]c_int{
        42793,
        0,
        0,
    },
    [3]c_int{
        42795,
        0,
        0,
    },
    [3]c_int{
        42797,
        0,
        0,
    },
    [3]c_int{
        42799,
        0,
        0,
    },
    [3]c_int{
        42803,
        0,
        0,
    },
    [3]c_int{
        42805,
        0,
        0,
    },
    [3]c_int{
        42807,
        0,
        0,
    },
    [3]c_int{
        42809,
        0,
        0,
    },
    [3]c_int{
        42811,
        0,
        0,
    },
    [3]c_int{
        42813,
        0,
        0,
    },
    [3]c_int{
        42815,
        0,
        0,
    },
    [3]c_int{
        42817,
        0,
        0,
    },
    [3]c_int{
        42819,
        0,
        0,
    },
    [3]c_int{
        42821,
        0,
        0,
    },
    [3]c_int{
        42823,
        0,
        0,
    },
    [3]c_int{
        42825,
        0,
        0,
    },
    [3]c_int{
        42827,
        0,
        0,
    },
    [3]c_int{
        42829,
        0,
        0,
    },
    [3]c_int{
        42831,
        0,
        0,
    },
    [3]c_int{
        42833,
        0,
        0,
    },
    [3]c_int{
        42835,
        0,
        0,
    },
    [3]c_int{
        42837,
        0,
        0,
    },
    [3]c_int{
        42839,
        0,
        0,
    },
    [3]c_int{
        42841,
        0,
        0,
    },
    [3]c_int{
        42843,
        0,
        0,
    },
    [3]c_int{
        42845,
        0,
        0,
    },
    [3]c_int{
        42847,
        0,
        0,
    },
    [3]c_int{
        42849,
        0,
        0,
    },
    [3]c_int{
        42851,
        0,
        0,
    },
    [3]c_int{
        42853,
        0,
        0,
    },
    [3]c_int{
        42855,
        0,
        0,
    },
    [3]c_int{
        42857,
        0,
        0,
    },
    [3]c_int{
        42859,
        0,
        0,
    },
    [3]c_int{
        42861,
        0,
        0,
    },
    [3]c_int{
        42863,
        0,
        0,
    },
    [3]c_int{
        42874,
        0,
        0,
    },
    [3]c_int{
        42876,
        0,
        0,
    },
    [3]c_int{
        7545,
        0,
        0,
    },
    [3]c_int{
        42879,
        0,
        0,
    },
    [3]c_int{
        42881,
        0,
        0,
    },
    [3]c_int{
        42883,
        0,
        0,
    },
    [3]c_int{
        42885,
        0,
        0,
    },
    [3]c_int{
        42887,
        0,
        0,
    },
    [3]c_int{
        42892,
        0,
        0,
    },
    [3]c_int{
        613,
        0,
        0,
    },
    [3]c_int{
        42897,
        0,
        0,
    },
    [3]c_int{
        42899,
        0,
        0,
    },
    [3]c_int{
        42903,
        0,
        0,
    },
    [3]c_int{
        42905,
        0,
        0,
    },
    [3]c_int{
        42907,
        0,
        0,
    },
    [3]c_int{
        42909,
        0,
        0,
    },
    [3]c_int{
        42911,
        0,
        0,
    },
    [3]c_int{
        42913,
        0,
        0,
    },
    [3]c_int{
        42915,
        0,
        0,
    },
    [3]c_int{
        42917,
        0,
        0,
    },
    [3]c_int{
        42919,
        0,
        0,
    },
    [3]c_int{
        42921,
        0,
        0,
    },
    [3]c_int{
        614,
        0,
        0,
    },
    [3]c_int{
        604,
        0,
        0,
    },
    [3]c_int{
        609,
        0,
        0,
    },
    [3]c_int{
        620,
        0,
        0,
    },
    [3]c_int{
        618,
        0,
        0,
    },
    [3]c_int{
        670,
        0,
        0,
    },
    [3]c_int{
        647,
        0,
        0,
    },
    [3]c_int{
        669,
        0,
        0,
    },
    [3]c_int{
        43859,
        0,
        0,
    },
    [3]c_int{
        42933,
        0,
        0,
    },
    [3]c_int{
        42935,
        0,
        0,
    },
    [3]c_int{
        42937,
        0,
        0,
    },
    [3]c_int{
        42939,
        0,
        0,
    },
    [3]c_int{
        42941,
        0,
        0,
    },
    [3]c_int{
        42943,
        0,
        0,
    },
    [3]c_int{
        42945,
        0,
        0,
    },
    [3]c_int{
        42947,
        0,
        0,
    },
    [3]c_int{
        42900,
        0,
        0,
    },
    [3]c_int{
        642,
        0,
        0,
    },
    [3]c_int{
        7566,
        0,
        0,
    },
    [3]c_int{
        42952,
        0,
        0,
    },
    [3]c_int{
        42954,
        0,
        0,
    },
    [3]c_int{
        612,
        0,
        0,
    },
    [3]c_int{
        42957,
        0,
        0,
    },
    [3]c_int{
        42959,
        0,
        0,
    },
    [3]c_int{
        42961,
        0,
        0,
    },
    [3]c_int{
        42963,
        0,
        0,
    },
    [3]c_int{
        42965,
        0,
        0,
    },
    [3]c_int{
        42967,
        0,
        0,
    },
    [3]c_int{
        42969,
        0,
        0,
    },
    [3]c_int{
        42971,
        0,
        0,
    },
    [3]c_int{
        411,
        0,
        0,
    },
    [3]c_int{
        42998,
        0,
        0,
    },
    [3]c_int{
        5024,
        0,
        0,
    },
    [3]c_int{
        102,
        102,
        0,
    },
    [3]c_int{
        102,
        105,
        0,
    },
    [3]c_int{
        102,
        108,
        0,
    },
    [3]c_int{
        102,
        102,
        105,
    },
    [3]c_int{
        102,
        102,
        108,
    },
    [3]c_int{
        115,
        116,
        0,
    },
    [3]c_int{
        115,
        116,
        0,
    },
    [3]c_int{
        1396,
        1398,
        0,
    },
    [3]c_int{
        1396,
        1381,
        0,
    },
    [3]c_int{
        1396,
        1387,
        0,
    },
    [3]c_int{
        1406,
        1398,
        0,
    },
    [3]c_int{
        1396,
        1389,
        0,
    },
    [3]c_int{
        65345,
        0,
        0,
    },
    [3]c_int{
        66600,
        0,
        0,
    },
    [3]c_int{
        66776,
        0,
        0,
    },
    [3]c_int{
        66967,
        0,
        0,
    },
    [3]c_int{
        66979,
        0,
        0,
    },
    [3]c_int{
        66995,
        0,
        0,
    },
    [3]c_int{
        67003,
        0,
        0,
    },
    [3]c_int{
        68800,
        0,
        0,
    },
    [3]c_int{
        68976,
        0,
        0,
    },
    [3]c_int{
        71872,
        0,
        0,
    },
    [3]c_int{
        93792,
        0,
        0,
    },
    [3]c_int{
        93883,
        0,
        0,
    },
    [3]c_int{
        125218,
        0,
        0,
    },
};
pub export const width_table: [124]struct_interval = [124]struct_interval{
    struct_interval{
        .first = 4352,
        .last = 4447,
    },
    struct_interval{
        .first = 8986,
        .last = 8987,
    },
    struct_interval{
        .first = 9001,
        .last = 9002,
    },
    struct_interval{
        .first = 9193,
        .last = 9196,
    },
    struct_interval{
        .first = 9200,
        .last = 9200,
    },
    struct_interval{
        .first = 9203,
        .last = 9203,
    },
    struct_interval{
        .first = 9725,
        .last = 9726,
    },
    struct_interval{
        .first = 9748,
        .last = 9749,
    },
    struct_interval{
        .first = 9776,
        .last = 9783,
    },
    struct_interval{
        .first = 9800,
        .last = 9811,
    },
    struct_interval{
        .first = 9855,
        .last = 9855,
    },
    struct_interval{
        .first = 9866,
        .last = 9871,
    },
    struct_interval{
        .first = 9875,
        .last = 9875,
    },
    struct_interval{
        .first = 9889,
        .last = 9889,
    },
    struct_interval{
        .first = 9898,
        .last = 9899,
    },
    struct_interval{
        .first = 9917,
        .last = 9918,
    },
    struct_interval{
        .first = 9924,
        .last = 9925,
    },
    struct_interval{
        .first = 9934,
        .last = 9934,
    },
    struct_interval{
        .first = 9940,
        .last = 9940,
    },
    struct_interval{
        .first = 9962,
        .last = 9962,
    },
    struct_interval{
        .first = 9970,
        .last = 9971,
    },
    struct_interval{
        .first = 9973,
        .last = 9973,
    },
    struct_interval{
        .first = 9978,
        .last = 9978,
    },
    struct_interval{
        .first = 9981,
        .last = 9981,
    },
    struct_interval{
        .first = 9989,
        .last = 9989,
    },
    struct_interval{
        .first = 9994,
        .last = 9995,
    },
    struct_interval{
        .first = 10024,
        .last = 10024,
    },
    struct_interval{
        .first = 10060,
        .last = 10060,
    },
    struct_interval{
        .first = 10062,
        .last = 10062,
    },
    struct_interval{
        .first = 10067,
        .last = 10069,
    },
    struct_interval{
        .first = 10071,
        .last = 10071,
    },
    struct_interval{
        .first = 10133,
        .last = 10135,
    },
    struct_interval{
        .first = 10160,
        .last = 10160,
    },
    struct_interval{
        .first = 10175,
        .last = 10175,
    },
    struct_interval{
        .first = 11035,
        .last = 11036,
    },
    struct_interval{
        .first = 11088,
        .last = 11088,
    },
    struct_interval{
        .first = 11093,
        .last = 11093,
    },
    struct_interval{
        .first = 11904,
        .last = 11929,
    },
    struct_interval{
        .first = 11931,
        .last = 12019,
    },
    struct_interval{
        .first = 12032,
        .last = 12245,
    },
    struct_interval{
        .first = 12272,
        .last = 12350,
    },
    struct_interval{
        .first = 12353,
        .last = 12438,
    },
    struct_interval{
        .first = 12441,
        .last = 12543,
    },
    struct_interval{
        .first = 12549,
        .last = 12591,
    },
    struct_interval{
        .first = 12593,
        .last = 12686,
    },
    struct_interval{
        .first = 12688,
        .last = 12773,
    },
    struct_interval{
        .first = 12783,
        .last = 12830,
    },
    struct_interval{
        .first = 12832,
        .last = 12871,
    },
    struct_interval{
        .first = 12880,
        .last = 42124,
    },
    struct_interval{
        .first = 42128,
        .last = 42182,
    },
    struct_interval{
        .first = 43360,
        .last = 43388,
    },
    struct_interval{
        .first = 44032,
        .last = 55203,
    },
    struct_interval{
        .first = 63744,
        .last = 64255,
    },
    struct_interval{
        .first = 65040,
        .last = 65049,
    },
    struct_interval{
        .first = 65072,
        .last = 65106,
    },
    struct_interval{
        .first = 65108,
        .last = 65126,
    },
    struct_interval{
        .first = 65128,
        .last = 65131,
    },
    struct_interval{
        .first = 65281,
        .last = 65376,
    },
    struct_interval{
        .first = 65504,
        .last = 65510,
    },
    struct_interval{
        .first = 94176,
        .last = 94180,
    },
    struct_interval{
        .first = 94192,
        .last = 94198,
    },
    struct_interval{
        .first = 94208,
        .last = 101589,
    },
    struct_interval{
        .first = 101631,
        .last = 101662,
    },
    struct_interval{
        .first = 101760,
        .last = 101874,
    },
    struct_interval{
        .first = 110576,
        .last = 110579,
    },
    struct_interval{
        .first = 110581,
        .last = 110587,
    },
    struct_interval{
        .first = 110589,
        .last = 110590,
    },
    struct_interval{
        .first = 110592,
        .last = 110882,
    },
    struct_interval{
        .first = 110898,
        .last = 110898,
    },
    struct_interval{
        .first = 110928,
        .last = 110930,
    },
    struct_interval{
        .first = 110933,
        .last = 110933,
    },
    struct_interval{
        .first = 110948,
        .last = 110951,
    },
    struct_interval{
        .first = 110960,
        .last = 111355,
    },
    struct_interval{
        .first = 119552,
        .last = 119638,
    },
    struct_interval{
        .first = 119648,
        .last = 119670,
    },
    struct_interval{
        .first = 126980,
        .last = 126980,
    },
    struct_interval{
        .first = 127183,
        .last = 127183,
    },
    struct_interval{
        .first = 127374,
        .last = 127374,
    },
    struct_interval{
        .first = 127377,
        .last = 127386,
    },
    struct_interval{
        .first = 127488,
        .last = 127490,
    },
    struct_interval{
        .first = 127504,
        .last = 127547,
    },
    struct_interval{
        .first = 127552,
        .last = 127560,
    },
    struct_interval{
        .first = 127568,
        .last = 127569,
    },
    struct_interval{
        .first = 127584,
        .last = 127589,
    },
    struct_interval{
        .first = 127744,
        .last = 127776,
    },
    struct_interval{
        .first = 127789,
        .last = 127797,
    },
    struct_interval{
        .first = 127799,
        .last = 127868,
    },
    struct_interval{
        .first = 127870,
        .last = 127891,
    },
    struct_interval{
        .first = 127904,
        .last = 127946,
    },
    struct_interval{
        .first = 127951,
        .last = 127955,
    },
    struct_interval{
        .first = 127968,
        .last = 127984,
    },
    struct_interval{
        .first = 127988,
        .last = 127988,
    },
    struct_interval{
        .first = 127992,
        .last = 128062,
    },
    struct_interval{
        .first = 128064,
        .last = 128064,
    },
    struct_interval{
        .first = 128066,
        .last = 128252,
    },
    struct_interval{
        .first = 128255,
        .last = 128317,
    },
    struct_interval{
        .first = 128331,
        .last = 128334,
    },
    struct_interval{
        .first = 128336,
        .last = 128359,
    },
    struct_interval{
        .first = 128378,
        .last = 128378,
    },
    struct_interval{
        .first = 128405,
        .last = 128406,
    },
    struct_interval{
        .first = 128420,
        .last = 128420,
    },
    struct_interval{
        .first = 128507,
        .last = 128591,
    },
    struct_interval{
        .first = 128640,
        .last = 128709,
    },
    struct_interval{
        .first = 128716,
        .last = 128716,
    },
    struct_interval{
        .first = 128720,
        .last = 128722,
    },
    struct_interval{
        .first = 128725,
        .last = 128728,
    },
    struct_interval{
        .first = 128732,
        .last = 128735,
    },
    struct_interval{
        .first = 128747,
        .last = 128748,
    },
    struct_interval{
        .first = 128756,
        .last = 128764,
    },
    struct_interval{
        .first = 128992,
        .last = 129003,
    },
    struct_interval{
        .first = 129008,
        .last = 129008,
    },
    struct_interval{
        .first = 129292,
        .last = 129338,
    },
    struct_interval{
        .first = 129340,
        .last = 129349,
    },
    struct_interval{
        .first = 129351,
        .last = 129535,
    },
    struct_interval{
        .first = 129648,
        .last = 129660,
    },
    struct_interval{
        .first = 129664,
        .last = 129674,
    },
    struct_interval{
        .first = 129678,
        .last = 129734,
    },
    struct_interval{
        .first = 129736,
        .last = 129736,
    },
    struct_interval{
        .first = 129741,
        .last = 129756,
    },
    struct_interval{
        .first = 129759,
        .last = 129770,
    },
    struct_interval{
        .first = 129775,
        .last = 129784,
    },
    struct_interval{
        .first = 131072,
        .last = 196605,
    },
    struct_interval{
        .first = 196608,
        .last = 262141,
    },
    struct_interval{
        .first = 0,
        .last = 0,
    },
};
