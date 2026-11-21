"""Custom-domain milestone assertions.

Regex-based on purpose: `terraform fmt` realigns whitespace, so exact-string
assertions rot. Each test pins one control of the custom-domain milestone
(Azure DNS zone + Front Door custom domain + managed TLS).

Wiring note: modules/custom_domain is called NESTED from frontdoor_premium.
A root-level two-way wiring (route <- custom domain <- frontdoor outputs) is
a Terraform module-graph Cycle even though the resource graph is acyclic —
found the hard way on 2026-11-21; these tests pin the acyclic shape.
"""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
TF = ROOT / "infra" / "terraform"


def read(rel: str) -> str:
    return (TF / rel).read_text()


DOTALL = re.DOTALL


class CustomDomainModule(unittest.TestCase):
    """Azure DNS zone + AFD custom domain with managed TLS."""

    def setUp(self):
        self.src = read("modules/custom_domain/main.tf")

    def test_module_declares_azurerm_provider(self):
        self.assertRegex(
            read("modules/custom_domain/versions.tf"),
            r'source\s*=\s*"hashicorp/azurerm"',
        )

    def test_dns_zone_created(self):
        self.assertRegex(self.src, r'resource\s+"azurerm_dns_zone"\s+"this"')

    def test_ownership_txt_uses_validation_token(self):
        self.assertRegex(
            self.src,
            re.compile(
                r'azurerm_dns_txt_record"\s+"afdverify".*?'
                r"record\s*\{[^}]*value\s*=\s*"
                r"azurerm_cdn_frontdoor_custom_domain\.this\.validation_token",
                DOTALL,
            ),
        )

    def test_cname_targets_frontdoor_endpoint(self):
        self.assertRegex(
            self.src,
            r'azurerm_dns_cname_record"\s+"site"[^}]*record\s*=\s*var\.frontdoor_endpoint_fqdn',
        )

    def test_custom_domain_hostname_composed_from_zone(self):
        self.assertRegex(
            self.src,
            r'host_name\s*=\s*"\$\{var\.subdomain\}\.\$\{var\.dns_zone_name\}"',
        )

    def test_validation_via_azure_dns_zone_id(self):
        self.assertRegex(
            self.src,
            r"dns_zone_id\s*=\s*azurerm_dns_zone\.this\.id",
        )

    def test_managed_certificate(self):
        self.assertRegex(
            self.src,
            r'certificate_type\s*=\s*"ManagedCertificate"',
        )

    def test_minimum_tls_1_2(self):
        # minimum_tls_version is deprecated in azurerm; the future-proof attr
        # is minimum_version (both exist in 4.81.0 schema).
        self.assertRegex(
            self.src,
            r'minimum_version\s*=\s*"TLS12"',
        )


class RouteAssociation(unittest.TestCase):
    """The route must actually serve the custom domain — without cycles."""

    def test_route_accepts_custom_domain_ids(self):
        self.assertRegex(
            read("modules/frontdoor_premium/main.tf"),
            r"cdn_frontdoor_custom_domain_ids\s*=\s*one\(module\.custom_domain\[\*\]\.custom_domain_id\)",
        )

    def test_custom_domain_is_nested_module_call(self):
        self.assertRegex(
            read("modules/frontdoor_premium/main.tf"),
            re.compile(
                r'module\s+"custom_domain"\s*\{[^}]*'
                r'source\s*=\s*"\.\./custom_domain"',
                DOTALL,
            ),
        )

    def test_nested_module_gated_on_zone_presence(self):
        self.assertRegex(
            read("modules/frontdoor_premium/main.tf"),
            re.compile(
                r'module\s+"custom_domain"\s*\{[^}]*'
                r'count\s*=\s*var\.dns_zone_name\s*!=\s*""\s*\?\s*1\s*:\s*0',
                DOTALL,
            ),
        )

    def test_root_passes_dns_zone_to_frontdoor(self):
        self.assertRegex(
            read("main.tf"),
            re.compile(
                r'module\s+"frontdoor"\s*\{[^}]*dns_zone_name\s*=\s*var\.dns_zone_name',
                DOTALL,
            ),
        )

    def test_no_root_level_custom_domain_module(self):
        # The root-level block caused Cycle errors; it must stay removed.
        self.assertNotRegex(
            read("main.tf"),
            r'module\s+"custom_domain"',
        )


class RootGating(unittest.TestCase):
    """The whole milestone stays deploy-gated and inert by default."""

    def test_dns_zone_disabled_by_default(self):
        # Empty string disables the custom-domain wiring entirely.
        self.assertRegex(
            read("variables.tf"),
            r'"dns_zone_name"\s*\{[^}]*default\s*=\s*""',
        )

    def test_custom_domain_output_routed_through_frontdoor(self):
        self.assertRegex(
            read("outputs.tf"),
            r'output\s+"custom_domain_fqdn"[^}]*one\(module\.frontdoor\[\*\]\.custom_domain_fqdn\)',
        )


class DeployWorkflowDraft(unittest.TestCase):
    """The manual deploy workflow exists only as an inert draft."""

    def test_draft_is_workflow_dispatch_only(self):
        draft = (ROOT / "examples" / "workflows" / "deploy-manual.yml.example").read_text()
        self.assertIn("workflow_dispatch", draft)
        self.assertNotIn("push:", draft)

    def test_draft_lives_outside_github_workflows(self):
        self.assertFalse((ROOT / ".github" / "workflows" / "deploy-manual.yml").exists())

    def test_ci_still_has_no_apply(self):
        self.assertNotIn("terraform apply", (ROOT / ".github" / "workflows" / "validate.yml").read_text())
