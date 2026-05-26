variable "image_url" {
  description = <<-EOT
    Address of RockyLinux (or compatible) image to use. If null then an image
    must already exist on the cloud.
  EOT
  type        = string
  default     = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base-9.6-20250531.0.x86_64.qcow2"
}

variable "image_format" {
  description = <<-EOT
    Format for downloaded image. Default is to use use extension from image_url.
  EOT
  type = string
  default = null
}

variable "image_name" {
  description = <<-EOT
    Name of image in the cloud. Default takes it from image URL.
  EOT
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Name of instance"
  type = string
  default = "jumphost"
}

variable "ssh_user" {
  description = "SSH user to create and jump through as"
  type        = string
  default     = "ansible"
}

variable "authorised_keys" {
  description = "List of SSH public keys allowed through jumphost as var.ssh_user"
  type        = list(string)
}

variable "debug" {
  description = "Set true to create the distro's default (rocky) user, e.g. to allow debugging and locally template cloud-init userdata"
  type        = bool
  default     = false
}

variable "default_key_pair" {
  description = "Name of keypair for default (rocky) user, only used in debug mode"
  type        = string
  default     = null
}

variable "floating_ip" {
  description = "IP to use for floating IP, must already be allocated to the project"
  type        = string
}

variable "flavor" {
  description = "Name of instance flavor"
  type        = string
}

variable "network" {
  description = "Name of network"
  type        = string
}

variable "security_group_names" {
  description = "Name of pre-existing security groups to apply"
  type        = list(string)
  default     = ["default", "SSH"]
}

variable "fail2ban_enable" {
  description = "Whether to enable fail2ban or not"
  type = bool
  default = false
}

variable "bantime" {
  description = <<-EOT
    Time (s) to ban users repeatedly failing to authenticate. Only relevant
    if fail2ban_enable
  EOT
  default = 3600
}

locals {
  # Blocked to mitigate copy-fail and dirty-frag CVEs
  denylisted_modules_default = ["algif_aead", "esp4", "esp6", "rxrpc"]
  denylisted_modules_list = concat(local.denylisted_modules_default, var.denylisted_modules)
  sysctl_options_default = [
  # Mitigation for ssh-keysign-pwn CVE
  {
    name = "kernel.yama.ptrace_scope"
    value = "3"
  }
  ]
  sysctl_options_list = concat(local.sysctl_options_default, var.sysctl_options)
}
variable "denylisted_modules" {
  description = "Kernel modules to denylist during cloud-init"
  type = list(string)
  default = []
}

variable "sysctl_options" {
  description = <<-EOT
    List of dicts representing sysctl options to create drop-in files for.
    Each item is in the format:
      name: Name of sysctl options
      value: Value to set for it
  EOT
  type = list(map(string))
  default = []
}

variable "block_new_kernel_modules" {
  description = "If enabled, will block loading any new kernel modules excluding those listed in allowlisted_modules"
  type = bool
  default = true
}

variable "allowlisted_modules" {
  description = <<-EOT
    Kernel modules which are allowed to be loaded even if block_new_kernel_modules is enabled. Note that the denylisted_modules list takes
    precendence over this list. Defaults to modules loaded on boot by default for Rocky Linux 9.6
  EOT
  type = list(string)
  default = [
    "8250",
    "acpi",
    "acpiphp",
    "acpi_x86",
    "ata_generic",
    "ata_piix",
    "battery",
    "blk_cgroup",
    "block",
    "button",
    "clocksource",
    "configfs",
    "cpufreq",
    "cpuidle",
    "cpuidle_haltpoll",
    "crc32c_intel",
    "crc32_pclmul",
    "crc64_rocksoft",
    "crc_t10dif",
    "crct10dif_pclmul",
    "cryptomgr",
    "damon_reclaim",
    "debug_core",
    "device_hmem",
    "dm_log",
    "dm_mirror",
    "dm_mod",
    "dm_region_hash",
    "drm",
    "drm_client_lib",
    "drm_kms_helper",
    "drm_shmem_helper",
    "dynamic_debug",
    "edac_core",
    "efi_pstore",
    "efivars",
    "ehci_hcd",
    "failover",
    "fat",
    "fb",
    "firmware_class",
    "fscrypto",
    "fuse",
    "ghash_clmulni_intel",
    "gpiolib_acpi",
    "haltpoll",
    "hid",
    "hid_magicmouse",
    "hid_ntrig",
    "i8042",
    "ima",
    "intel_idle",
    "intel_rapl_common",
    "intel_rapl_msr",
    "ipv6",
    "joydev",
    "kdb",
    "kernel",
    "keyboard",
    "kfence",
    "kgdboc",
    "kgdbts",
    "libata",
    "libcrc32c",
    "md_mod",
    "memory_hotplug",
    "microcode",
    "module",
    "mousedev",
    "msr",
    "net_failover",
    "netpoll",
    "nf_conntrack",
    "nf_defrag_ipv4",
    "nf_defrag_ipv6",
    "nf_nat",
    "nfnetlink",
    "nf_reject_ipv4",
    "nf_reject_ipv6",
    "nf_tables",
    "nft_chain_nat",
    "nft_ct",
    "nft_fib",
    "nft_fib_inet",
    "nft_fib_ipv4",
    "nft_fib_ipv6",
    "nft_reject",
    "nft_reject_inet",
    "nmi_backtrace",
    "page_alloc",
    "page_reporting",
    "pcie_aspm",
    "pciehp",
    "pci_hotplug",
    "pcmcia_core",
    "pcspkr",
    "printk",
    "processor",
    "psmouse",
    "pstore",
    "random",
    "rcupdate",
    "rcutree",
    "rfkill",
    "rng_core",
    "rtc_cmos",
    "scsi_dh_alua",
    "scsi_dh_rdac",
    "scsi_mod",
    "secretmem",
    "serio_raw",
    "shpchp",
    "spurious",
    "srcutree",
    "sunrpc",
    "suspend",
    "sysrq",
    "tcp_cubic",
    "thermal",
    "thunderbolt",
    "tls",
    "tpm",
    "tpm_crb",
    "tpm_tis",
    "tpm_tis_core",
    "udmabuf",
    "uhci_hcd",
    "usbcore",
    "usbhid",
    "uv_nmi",
    "vfat",
    "virtio_balloon",
    "virtio_blk",
    "virtio_dma_buf",
    "virtio_net",
    "virtio_pci",
    "virtio_pci_legacy_dev",
    "virtio_pci_modern_dev",
    "vmd",
    "vt",
    "watchdog",
    "workqueue",
    "xen",
    "xfs",
    "xhci_hcd",
    "xz_dec",
    "zswap"
  ]
}
