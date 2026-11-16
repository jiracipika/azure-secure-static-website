"""Accessibility and responsiveness checks for the demo website."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"


class Pages(unittest.TestCase):
    def setUp(self):
        self.index = (APP / "index.html").read_text()
        self.error = (APP / "error.html").read_text()

    def test_language_declared(self):
        self.assertIn('lang="en"', self.index)
        self.assertIn('lang="en"', self.error)

    def test_viewport_meta(self):
        self.assertIn('name="viewport"', self.index)
        self.assertIn('name="viewport"', self.error)

    def test_skip_link_targets_main(self):
        self.assertIn('href="#main"', self.index)
        self.assertIn('id="main"', self.index)

    def test_title_present(self):
        self.assertIn("<title>", self.index)
        self.assertIn("<title>", self.error)

    def test_no_insecure_external_assets(self):
        for page in (self.index, self.error):
            self.assertNotIn('src="http://', page)
            self.assertNotIn('href="http://', page)

    def test_custom_404_document_exists(self):
        # Front Door/storage errorDocument404Path points at error.html
        self.assertTrue((APP / "error.html").exists())


class Styles(unittest.TestCase):
    def setUp(self):
        self.css = (APP / "styles.css").read_text()

    def test_responsive_media_query(self):
        self.assertIn("@media (max-width: 600px)", self.css)

    def test_reduced_motion_respected(self):
        self.assertIn("@media (prefers-reduced-motion: reduce)", self.css)

    def test_visible_focus_outline(self):
        self.assertIn("a:focus-visible", self.css)

    def test_fluid_type_scale(self):
        self.assertIn("clamp(", self.css)


if __name__ == "__main__":
    unittest.main()
