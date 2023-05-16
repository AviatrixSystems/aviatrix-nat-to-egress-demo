# # Final Applied Secure Egress FQDN
# resource "aviatrix_fqdn" "allow_egress" {
#   fqdn_tag            = "allow_egress"
#   fqdn_enabled        = true
#   fqdn_mode           = "white"
#   manage_domain_names = false
#   dynamic "gw_filter_tag_list" {
#     for_each = local.avx_egress ? ["gw_name"] : []

#     content {
#       gw_name = aviatrix_spoke_gateway.egress.gw_name
#     }
#   }
# }

# resource "aviatrix_fqdn_tag_rule" "tcp" {
#   for_each      = local.egress_rules.tcp
#   fqdn_tag_name = aviatrix_fqdn.allow_egress.fqdn_tag
#   fqdn          = each.key
#   protocol      = "tcp"
#   port          = each.value
# }

# resource "aviatrix_fqdn_tag_rule" "udp" {
#   for_each      = local.egress_rules.udp
#   fqdn_tag_name = aviatrix_fqdn.allow_egress.fqdn_tag
#   fqdn          = each.key
#   protocol      = "udp"
#   port          = each.value
# }
