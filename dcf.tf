# Distributed firewall
resource "aviatrix_distributed_firewalling_config" "egress" {
  enable_distributed_firewalling = true
}

resource "aviatrix_web_group" "allow_internet_https" {
  name = "allowed-internet-https"
  selector {
    match_expressions {
      snifilter = "azure.microsoft.com"
    }
    match_expressions {
      snifilter = "aws.amazon.com"
    }
    match_expressions {
      snifilter = "*.aviatrix.com"
    }
    match_expressions {
      snifilter = "cloud.google.com"
    }
    match_expressions {
      snifilter = "www.oracle.com"
    }
  }
}

resource "aviatrix_web_group" "allow_internet_http" {
  name = "allowed-internet-http"
  selector {
    match_expressions {
      snifilter = "*.ubuntu.com"
    }
  }
}

resource "aviatrix_smart_group" "private_subnet" {
  name = "private-subnet"
  selector {
    match_expressions {
      cidr = "10.1.16.0/20"
    }
  }
}

resource "aviatrix_distributed_firewalling_policy_list" "egress_watch" {
  count = local.avx_dfw_enforce ? 0 : 1
  policies {
    name     = "allow-internet-http"
    action   = "INTRUSION_DETECTION_PERMIT"
    priority = 0
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 80
    }
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_http.uuid,
    ]
  }
  policies {
    name     = "allow-internet-https"
    action   = "PERMIT"
    priority = 1
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 443
    }
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_https.uuid,
    ]
  }
  policies {
    name     = "deny-internet-all"
    action   = "DENY"
    priority = 2147483646
    protocol = "Any"
    logging  = true
    watch    = true
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
  }
  policies {
    name     = "default-allow-all"
    action   = "PERMIT"
    priority = 2147483647
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
  }
  depends_on = [
    aviatrix_distributed_firewalling_config.egress
  ]
}

resource "aviatrix_distributed_firewalling_policy_list" "egress_enforce" {
  count = local.avx_dfw_enforce ? 1 : 0
  policies {
    name     = "allow-internet-http"
    action   = "PERMIT"
    priority = 0
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 80
    }
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_http.uuid,
    ]
  }
  policies {
    name     = "allow-internet-https"
    action   = "PERMIT"
    priority = 1
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 443
    }
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_https.uuid,
    ]
  }
  policies {
    name     = "deny-internet-all"
    action   = "DENY"
    priority = 2147483646
    protocol = "Any"
    logging  = true
    watch    = false
    port_ranges {
      lo = 1
      hi = 65535
    }
    src_smart_groups = [
      aviatrix_smart_group.private_subnet.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
  }
  policies {
    name     = "default-allow-all"
    action   = "PERMIT"
    priority = 2147483647
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
  }
  depends_on = [
    aviatrix_distributed_firewalling_policy_list.egress_watch,
    aviatrix_distributed_firewalling_config.egress
  ]
}
