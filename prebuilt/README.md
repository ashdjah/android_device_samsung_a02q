# Prebuilt binaries

Place the following files in `prebuilt/` before building:

| File | Direct Download Link | Source Revision | Required |
|------|---------------------|-----------------|----------|
| `kernel` | https://raw.githubusercontent.com/Ragekill3377/a02q_twrp_tree_omni/main/prebuilt/kernel | Ragekill3377/a02q_twrp_tree_omni @ main | Yes |
| `dtb.img` | https://raw.githubusercontent.com/Ragekill3377/a02q_twrp_tree_omni/main/prebuilt/dtb.img | Ragekill3377/a02q_twrp_tree_omni @ main | Yes |
| `dtbo.img` | https://raw.githubusercontent.com/Ragekill3377/a02q_twrp_tree_omni/main/prebuilt/dtbo.img | Ragekill3377/a02q_twrp_tree_omni @ main | Yes |
| `mkbootimg` | https://raw.githubusercontent.com/Ragekill3377/a02q_twrp_tree_omni/main/prebuilt/mkbootimg | Ragekill3377/a02q_twrp_tree_omni @ main | Yes |

> ⚠️ Without these prebuilt artifacts, `make recoveryimage` will fail. The CI workflow verifies their presence before building.
>
> **Checksums:** Compute SHA-256 locally after downloading to verify integrity:
> ```bash
> sha256sum prebuilt/kernel prebuilt/dtb.img prebuilt/dtbo.img prebuilt/mkbootimg
> ```

License of extracted binaries follows their original source (Ragekill3377/a02q_twrp_tree_omni).