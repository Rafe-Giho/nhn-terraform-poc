output "load_balancer_ids" {
  description = "Load balancer IDs by key."
  value       = { for key, lb in nhncloud_lb_loadbalancer_v2.this : key => lb.id }
}

output "vip_addresses" {
  description = "Load balancer VIP addresses by key."
  value       = { for key, lb in nhncloud_lb_loadbalancer_v2.this : key => lb.vip_address }
}

output "listener_ids" {
  description = "Listener IDs by key."
  value       = { for key, listener in nhncloud_lb_listener_v2.this : key => listener.id }
}

output "pool_ids" {
  description = "Pool IDs by key."
  value       = { for key, pool in nhncloud_lb_pool_v2.this : key => pool.id }
}

output "monitor_ids" {
  description = "Health monitor IDs by key."
  value       = { for key, monitor in nhncloud_lb_monitor_v2.this : key => monitor.id }
}
