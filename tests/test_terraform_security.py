"""Security assertions over the Terraform sources.

Offline static analysis: each test pins a control that the modules must keep
enforcing. If someone relaxes a control, the suite fails before CI does.
"""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
TF = ROOT / "infra" / "terraform"


def read(rel: str) -> str:
    return (TF / rel).read_text()


class StorageOriginHardening(unittest.TestCase):
    """Private origin: storage must not be reachable or writable publicly."""

    def setUp(self):
        self.src = read("modules/static_site_storage/main.tf")

    def test_https_only(self):
        self.assertIn("https_traffic_only_enabled      = true", self.src)

    def test_public_network_access_disabled(self):
        self.assertIn("public_network_access_enabled   = false", self.src)

    def test_minimum_tls_1_2(self):
        self.assertIn('min_tls_version                 = "TLS1_2"', self.src)

    def test_no_public_blob_acl(self):
        self.assertIn("allow_nested_items_to_be_public = false", self.src)

    def test_no_shared_key_auth(self):
        self.assertIn("shared_access_key_enabled       = false", self.src)

    def test_static_website_enabled_as_code(self):
        self.assertIn("staticWebsite", self.src)
        self.assertIn("indexDocument", self.src)


class EdgeDeliveryHardening(unittest.TestCase):
    """HTTPS + WAF enforcement at the Front Door edge."""

    def setUp(self):
        self.src = read("modules/frontdoor_premium/main.tf")

    def test_http_to_https_redirect(self):
        self.assertIn("https_redirect_enabled        = true", self.src)

    def test_https_forwarding_only(self):
        self.assertIn('forwarding_protocol           = "HttpsOnly"', self.src)

    def test_premium_sku_required_for_private_link(self):
        self.assertIn('sku_name            = "Premium_AzureFrontDoor"', self.src)

    def test_origin_certificate_validation(self):
        self.assertIn("certificate_name_check_enabled = true", self.src)

    def test_private_link_origin(self):
        self.assertIn("private_link {", self.src)
        self.assertIn("private_link_target_id = var.origin_private_link_target_id", self.src)

    def test_waf_managed_ruleset(self):
        self.assertIn('"Microsoft_DefaultRuleSet"', self.src)

    def test_waf_mode_defaults_to_prevention(self):
        root_vars = read("variables.tf")
        self.assertIn('default     = "Prevention"', root_vars)

    def test_waf_custom_rule_blocks_unsafe_methods(self):
        self.assertIn("BlockUnsafeMethods", self.src)
        self.assertIn('match_variable = "RequestMethod"', self.src)

    def test_waf_attached_to_endpoint_domain(self):
        self.assertIn("cdn_frontdoor_firewall_policy_id", self.src)
        self.assertIn("cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id", self.src)


class DeploymentIdentityHardening(unittest.TestCase):
    """Safe deployment network: OIDC, branch-pinned, least privilege."""

    def setUp(self):
        self.src = read("modules/github_oidc/main.tf")

    def test_oidc_issuer_is_github(self):
        self.assertIn("https://token.actions.githubusercontent.com", self.src)

    def test_audience_is_azure_token_exchange(self):
        self.assertIn("api://AzureADTokenExchange", self.src)

    def test_subject_pinned_to_main_branch(self):
        self.assertIn(":ref:refs/heads/main", self.src)

    def test_subject_not_wildcard(self):
        self.assertNotIn('subject   = "repo:', self.src.replace(
            'subject   = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"', ""))

    def test_least_privilege_role(self):
        self.assertIn('role_definition_name = "Storage Blob Data Contributor"', self.src)

    def test_role_scoped_to_storage_account_only(self):
        self.assertIn("scope                = var.storage_account_id", self.src)


class SpendGuard(unittest.TestCase):
    """No resources may exist unless deploy_enabled is explicitly set."""

    def test_deploy_disabled_by_default(self):
        src = read("variables.tf")
        self.assertRegex(src, r'"deploy_enabled"\s*\{[^}]*default\s*=\s*false')

    def test_all_modules_gated(self):
        main = read("main.tf")
        self.assertEqual(main.count("var.deploy_enabled ? 1 : 0"), 4,
                         "resource group + 3 modules must all be gated")

    def test_placeholder_subscription_id(self):
        self.assertIn("00000000-0000-0000-0000-000000000000", read("variables.tf"))

    def test_env_file_keeps_deploy_off(self):
        tfvars = (TF / "environments" / "dev.tfvars").read_text()
        self.assertRegex(tfvars, r"deploy_enabled\s*=\s*false")


class CiSafety(unittest.TestCase):
    """Negative test: CI must never mutate cloud state."""

    def test_workflow_has_no_apply(self):
        wf = (ROOT / ".github/workflows/validate.yml").read_text()
        self.assertNotIn("terraform apply", wf)
        self.assertNotIn("terraform destroy", wf)

    def test_workflow_permissions_read_only(self):
        wf = (ROOT / ".github/workflows/validate.yml").read_text()
        self.assertIn("contents: read", wf)


if __name__ == "__main__":
    unittest.main()
