from pathlib import Path
import re
import unittest

root = Path(__file__).resolve().parents[1]


class Tests(unittest.TestCase):
    def test_agent_docs(self):
        self.assertTrue((root / "AGENTS.md").exists())
        self.assertTrue((root / "docs/GLM_TASKS.md").exists())

    def test_safety_gate(self):
        self.assertRegex(
            (root / "infra/terraform/variables.tf").read_text(),
            r'"deploy_enabled"\s*\{[^}]*default\s*=\s*false',
        )
        self.assertNotIn("terraform apply", (root / ".github/workflows/validate.yml").read_text())

    def test_architecture(self):
        self.assertIn("flowchart", (root / "diagrams/architecture.mmd").read_text())
