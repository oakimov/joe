import os
import joefx

class LockTests(joefx.JoeTestBase):
    def lockpath(self, name):
        return os.path.join(self.workdir.path, ".#" + name)

    def waitForLock(self, present):
        return self.joe.expect(lambda: os.path.lexists(self.lockpath("test")) == present)

    def test_lock_clean_exit(self):
        # Lock is created on first edit of a named file and removed on clean exit
        self.workdir.fixtureData("test", "original\n")
        self.startup.args = ("test",)
        self.startJoe()
        self.assertFalse(os.path.lexists(self.lockpath("test")))
        self.write("Hello world")
        self.assertTrue(self.waitForLock(True), "lock not created on first edit")
        self.save()
        self.exitJoe()
        self.assertExited()
        self.assertFalse(os.path.lexists(self.lockpath("test")), "lock survived clean exit")

    def test_lock_removed_on_abort(self):
        # Regression: brm/breplace must unlock the buffer (C parity)
        self.workdir.fixtureData("test", "original\n")
        self.startup.args = ("test",)
        self.startJoe()
        self.assertFalse(os.path.lexists(self.lockpath("test")))
        self.write("Hello world")
        self.assertTrue(self.waitForLock(True), "lock not created on first edit")
        self.cmd("abort")
        self.assertTextAt("Lose changes to this", x=0)
        self.joe.flushin()
        self.write("y")
        self.assertExited()
        self.assertFalse(
            os.path.lexists(self.lockpath("test")),
            "lock symlink survived editor exit after abort")

    def test_lock_kept_on_declined_abort(self):
        # Declining the prompt keeps the editor running with the lock held
        self.workdir.fixtureData("test", "original\n")
        self.startup.args = ("test",)
        self.startJoe()
        self.write("Hello world")
        self.assertTrue(self.waitForLock(True), "lock not created on first edit")
        self.cmd("abort")
        self.assertTextAt("Lose changes to this", x=0)
        self.joe.flushin()
        self.write("n")
        self.assertTrue(os.path.lexists(self.lockpath("test")))
        self.cmd("abort")
        self.joe.flushin()
        self.write("y")
        self.assertExited()
        self.assertFalse(
            os.path.lexists(self.lockpath("test")),
            "lock symlink survived editor exit after abort")
