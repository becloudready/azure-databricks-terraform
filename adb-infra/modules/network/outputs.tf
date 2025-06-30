output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "public_subnet_name" {
  value = azurerm_subnet.public.name
}

output "private_subnet_name" {
  value = azurerm_subnet.private.name
}

output "public_nsg_assoc_id" {
  value = azurerm_subnet_network_security_group_association.public.id
}

output "private_nsg_assoc_id" {
  value = azurerm_subnet_network_security_group_association.private.id
}
