variable "cluster_name" {
  type = string
}

variable "addons" {
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
