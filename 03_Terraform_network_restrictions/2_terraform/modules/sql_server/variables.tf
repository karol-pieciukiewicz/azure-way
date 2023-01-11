variable "db_sku" {
  description = "Specifies the name of the SKU used by the database. For example, GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100. Changing this from the HyperScale service tier to another service tier will force a new resource to be created."
  default     = "S0"
}

variable "collation" {
  description = "Specifies the collation of the database. Changing this forces a new resource to be created."
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the Azure SQL"
}

variable "admin_object_id" {
  description = "The object id of the Azure AD Administrator of this SQL Server."
}

variable "admin_username" {
  description = "The login username of the Azure AD Administrator of this SQL Server."
}

variable "sql_version" {
  description = "Version of the SQL"
  default     = "12.0"
}

variable "pe_subnet_id" {
  description = "Id of subnet for private endpoint"
}

variable "vnet_id" {
  description = "Vnet ID where SQL is created"
}

variable "ado_vnet_id" {
  description = "Vnet ID where ADO agnet is deployed"
}