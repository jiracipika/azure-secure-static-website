# Public edge: Front Door Premium (WAF + Private Link origin support).
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor" # Only Premium supports Private Link origins
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = var.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 2
    additional_latency_in_milliseconds = 0
  }

  health_probe {
    protocol            = "Https"
    path                = "/"
    interval_in_seconds = 60
    request_type        = "GET"
  }
}

# Origin reaches the storage static website over Private Link only.
resource "azurerm_cdn_frontdoor_origin" "this" {
  name                           = var.origin_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                        = true
  host_name                      = var.origin_hostname
  certificate_name_check_enabled = true
  weight                         = 1000

  private_link {
    private_link_target_id = var.origin_private_link_target_id
    location               = var.location
    target_type            = "blob"
    request_message        = "Front Door Premium private origin for the portfolio static website"
  }
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = var.route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                       = true
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  https_redirect_enabled        = true # HTTP -> HTTPS at the edge
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  # Custom domains (module/custom_domain) attach here once deployed.
  cdn_frontdoor_custom_domain_ids = one(module.custom_domain[*].custom_domain_id)

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true
    content_types_to_compress = [
      "text/html",
      "text/css",
      "application/javascript",
      "image/svg+xml",
    ]
  }
}

# Optional custom domain (Azure DNS zone + validated AFD custom domain).
# Kept as a nested module so the dependency stays one-directional: wiring this
# at the root on both sides (route <- custom domain <- endpoint outputs) is a
# module-graph Cycle in Terraform even though the resource graph is acyclic.
module "custom_domain" {
  count                   = var.dns_zone_name != "" ? 1 : 0
  source                  = "../custom_domain"
  resource_group_name     = var.resource_group_name
  dns_zone_name           = var.dns_zone_name
  subdomain               = var.custom_domain_subdomain
  frontdoor_profile_id    = azurerm_cdn_frontdoor_profile.this.id
  frontdoor_endpoint_fqdn = azurerm_cdn_frontdoor_endpoint.this.host_name
  tags                    = var.tags
}

# WAF: managed rule sets + a custom deny for unsafe HTTP methods.
resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  enabled             = true
  mode                = var.waf_mode

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  custom_rule {
    name     = "BlockUnsafeMethods"
    enabled  = true
    priority = 10
    type     = "MatchRule"
    action   = "Block"
    match_condition {
      match_variable = "RequestMethod"
      operator       = "Equal"
      match_values   = ["POST", "PUT", "DELETE", "PATCH", "TRACE"]
    }
  }
}

# Attach the WAF policy to the endpoint's default domain.
resource "azurerm_cdn_frontdoor_security_policy" "this" {
  name                     = var.security_policy_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this.id

      association {
        patterns_to_match = ["/*"]

        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id
        }
      }
    }
  }
}
