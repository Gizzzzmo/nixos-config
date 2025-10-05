# NixOS, and home-manager config

## Garbage collection
`nix-store --gc` cleans up parts of the store that are no longer used.
'Used' means being depended upon by some store root.
`nix-store --gc --print-roots` prints all roots. 
These are usually system, or home-manager generations, or they come from cached `nix develop` environments.
