{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  # ROCmFPX fork build (Vulkan backend only). The only build that can decode
  # ROCmFP4 tensors. Resolves to the `llama-cpp-vulkan-0.0.0` store path.
  llamaCppRocmFpx = pkgs.callPackage (inputs.rocmfpx + "/.devops/nix/package.nix") {
    useVulkan = true;
    useRocm = false;
    useCuda = false;
    useMetalKit = false;
    useBlas = false;
    useRpc = false;
    useMpi = false;
    useWebUi = false;
  };
  # ROCmFP4 STRIX quantization of Qwen3.8-27B. Needs a separate MTP draft head
  # and a vision projector (not self-contained).
  qwen38-27bSTRIX = pkgs.fetchurl {
    url = "https://huggingface.co/kingjones777/Qwen3.8-27B-ROCmFP4-STRIX-MTP-GGUF/resolve/main/Qwen3.8-27B-Q4_0_ROCMFP4_STRIX.gguf";
    sha256 = "sha256-Z1AQ6fft8ULyAyMIwh/FMzxTjG8dQoclW3dblhcK7lk";
  };
  qwen38-mmproj = pkgs.fetchurl {
    url = "https://huggingface.co/kingjones777/Qwen3.8-27B-ROCmFP4-STRIX-MTP-GGUF/resolve/main/mmproj-Qwen3.8-27B-BF16.gguf";
    sha256 = "sha256-3ipJhmmI6icsQ9wqQ+4mYsJXJacXyluQWepCCpf1P+g=";
  };
  qwen38-mtp_head = pkgs.fetchurl {
    url = "https://huggingface.co/kingjones777/Qwen3.8-27B-ROCmFP4-STRIX-MTP-GGUF/resolve/main/mtp-Qwen3.8-27B-Q4_0.gguf";
    sha256 = "sha256-BRoXZM/4xPPuauiwBZOgNkx1OcZ/pQ/8WPP5ZQn8o44=";
  };
  # Ornith-1.5-35B-A3B ROCmFP4 STRIX_LEAN. The MTP draft heads are integrated
  # into the main GGUF (self-spec), so no separate draft/mmproj files are needed.
  ornith-35bSTRIX = pkgs.fetchurl {
    url = "https://huggingface.co/pugant/Ornith-1.5-35B-ROCmFP4-STRIX_LEAN/resolve/main/Ornith-1.5-35B-ROCmFP4-STRIX_LEAN.gguf";
    sha256 = "sha256-qjUEWqs5FjhRyFhObPjMbzPo/C/+KMpifTQU7GZYRwQ=";
  };
  ornith-mmproj = pkgs.fetchurl {
    url = "https://huggingface.co/pugant/Ornith-1.5-35B-ROCmFP4-STRIX_LEAN/resolve/main/mmproj-Ornith-1.5-35B-BF16.gguf";
    sha256 = "sha256-2c4xAm0csfP41RUuLioBTZ0rMCtsk6fcB7sKBIf1KDc=";
  };
  # Qwen3 Embedding 4B
  qwen3-embedding = pkgs.fetchurl {
    url = "https://huggingface.co/Qwen/Qwen3-Embedding-4B-GGUF/resolve/main/Qwen3-Embedding-4B-Q8_0.gguf";
    sha256 = "sha256-tgrlzi3WoLd/gsrfId7x8xCj4QzeOArQCBsHqdQWlJ0=";
  };

  parallel = 2;
  llamaModels = pkgs.linkFarm "llama-models" [
    {
      name = "qwen3-embedding-8b";
      path = qwen3-embedding;
    }
    {
      name = "qwen3.8-27b:rocmfp4";
      path = qwen38-27bSTRIX;
    }
    {
      name = "ornith-1.5:rocmfp4";
      path = ornith-35bSTRIX;
    }
  ];
in {
  config = {
    services.llama-cpp = {
      enable = true;
      package = llamaCppRocmFpx;

      settings = {
        host = config.sys.bindAddress;
        port = 11404;

        # Must be a string, not a derivation (CLI formatter can't handle attrsets)
        models-dir = "${llamaModels}";

        direct-io = true;
        models-max = 3;
        models-autoload = true;
        parallel = parallel;
        cont-batching = true;
        ctx-checkpoints = 512;
        # checkpoint-every-n-tokens = 512;
        fit = "off";
        flash-attn = "on";
        jinja = true;
        reasoning = "on";
        cache-ram = 16384;
        temperature = 0.2;
        repeat-penalty = 1.0;
        presence-penalty = 0.1;
        frequency-penalty = 0.0;

        models-preset = "${pkgs.writeText "models.ini" ''
          [qwen3-embedding-8b]
          model = ${qwen3-embedding};
          alias = qwen3-embedding;
          ctx-size = ${toString (32000 * parallel)};
          n-gpu-layers = auto;
          cache-type-k = q8_0;
          cache-type-v = q8_0;

          [qwen3.8-27b:rocmfp4]
          model = ${qwen38-27bSTRIX};
          alias = qwen3.8-27b;
          ctx-size = ${toString (262144 * parallel)};
          n-gpu-layers = 999;
          cache-type-k = q4_0;
          cache-type-v = q4_0;
          mmproj = ${qwen38-mmproj};
          spec-type = draft-mtp;
          spec-draft-model = ${qwen38-mtp_head};
          spec-draft-n-max = 4;
          spec-draft-n-min = 0;
          spec-draft-ngl = 99;
          chat-template-kwargs = {"preserve_thinking":true,"reasoning_effort":"medium"};

          [ornith-1.5:rocmfp4]
          model = ${ornith-35bSTRIX};
          alias = ornith-1.5;
          ctx-size = ${toString (262144 * parallel)};
          n-gpu-layers = 999;
          cache-type-k = q4_0;
          cache-type-v = q4_0;
          mmproj = ${ornith-mmproj}
          chat-template-kwargs = {"preserve_thinking":true};
        ''}";
      };
    };
  };
}
