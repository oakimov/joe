import os
import sys
import joefx

# Total-path target: comfortably past the old 1024-byte static buffer the C
# dequote() copied into (the overflow this guards), while staying under the
# OS PATH_MAX so open()/symlink() still succeed.
if sys.platform == "linux":
    LONG_PATH_TARGET = 3800
else:
    LONG_PATH_TARGET = 950  # macOS PATH_MAX is 1024; get close, not over

class LongPathLockTests(joefx.JoeTestBase):
    def waitForLock(self, present, d):
        return self.joe.expect(lambda: os.path.lexists(os.path.join(d, ".#leaf")) == present)

    def savedContentStartsWith(self, path, prefix):
        with open(path) as f:
            return f.read().startswith(prefix)

    def makeLongDir(self):
        # Build a directory tree whose total path approaches PATH_MAX.
        # Built AFTER startJoe: FixtureDir.setup() deletes unregistered
        # files/dirs.
        comp = "d" * 200
        cur = self.workdir.path
        while len(os.path.join(cur, comp, "leaf").encode()) < LONG_PATH_TARGET:
            nxt = os.path.join(cur, comp)
            os.makedirs(nxt, exist_ok=True)
            cur = nxt
        return cur

    def test_edit_save_over_1k_path(self):
        # Exercises dequote()/lock_it()/bsave() with a path longer than the
        # 1024-byte static buffer the C original used (stack overflow risk in
        # the Zig port before the heap-vary rewrite).
        self.startJoe()
        d = self.makeLongDir()
        path = os.path.join(d, "leaf")
        with open(path, "w") as f:
            f.write("original\n")
        rel = os.path.relpath(path, self.workdir.path)
        self.cmd("edit")
        self.assertTextAt("Name of file to edit", x=0)
        self.write(rel)
        self.rtn()
        self.cmd("dellin")
        self.write("Hello world\r")
        self.assertTrue(self.waitForLock(True, d), "lock not created on >1k path")
        # Direct ^K D save: the base save() helper asserts the "Name of file
        # to save" prompt prefix, which scrolls off-screen for >1KB names.
        self.writectl("^KD")
        self.rtn()
        self.assertTrue(
            self.joe.expect(lambda: self.savedContentStartsWith(path, "Hello")),
            "file content not saved on >1k path")
        self.exitJoe()
        with open(path) as f:
            self.assertEqual(f.read(), "Hello world\n")
