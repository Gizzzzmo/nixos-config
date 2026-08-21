{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  mellum-base-4b = pkgs.fetchurl {
    url = "https://huggingface.co/JetBrains/Mellum-4b-base-gguf/resolve/main/mellum-4b-base.Q8_0.gguf";
    sha256 = "sha256-+Kiuj4sCzZknFuiEn+BCQYS8eibCuCkTHtVYVnMHxbI=";
  };
  qwen36-35b_q8_k_xl = pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf";
    sha256 = "sha256-bGuBZTerrZCyUKCXKzRUZgKNhh3f4xbV8N4xymRA94E=";
  };
  qwen38-28b_q8 = pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/Qwen3.8-27B-UD-Q8_K_XL.gguf";
    sha256 = "sha256-rzbstrXbFAeVM0W3RsFKyT8GV92kE5ELQ0hoOi2ZA3c=";
  };
  # Separate MTP draft heads for Qwen3.8-27B (unsloth). Required for
  # speculation; the 27B-UD Q8 model baked in the draft heads is unusable on
  # the ROCm backend (see llama.cpp #24177 / #25618) so we serve it with the
  # Vulkan backend + explicit separate draft file via --spec-draft-model.
  qwen38-27b_mtp = pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/MTP/mtp-Qwen3.8-27B-Q4_0.gguf";
    sha256 = "sha256-UNnOWm2jgbvPsxBhz3PflKkOb6+O/t3uN5qcuPFQHG4=";
  };
  qwen3Embedding = pkgs.linkFarm "qwen3Embedding" [
    {
      name = "model-00001-of-00004.safetensors";
      path = pkgs.fetchurl {
        url = "https://huggingface.co/Qwen/Qwen3-Embedding-8B/resolve/main/model-00001-of-00004.safetensors";
        sha256 = "sha256-mbNDWX/oQHBhRhRGmai5GI3TOH5D62H68CMbcLJJ1FE=";
      };
    }
    {
      name = "model-00002-of-00004.safetensors";
      path = pkgs.fetchurl {
        url = "https://huggingface.co/Qwen/Qwen3-Embedding-8B/resolve/main/model-00002-of-00004.safetensors";
        sha256 = "sha256-3/Y1sPbbuq0qLWM+8DfsCjm8FlzBgGxxL71vy8tFJsA=";
      };
    }
    {
      name = "model-00003-of-00004.safetensors";
      path = pkgs.fetchurl {
        url = "https://huggingface.co/Qwen/Qwen3-Embedding-8B/resolve/main/model-00003-of-00004.safetensors";
        sha256 = "sha256-MLHUxT2E6wGPZCytezc/Cqv3lpmHLYcCwfOFd8Clmi8=";
      };
    }
    {
      name = "model-00004-of-00004.safetensors";
      path = pkgs.fetchurl {
        url = "https://huggingface.co/Qwen/Qwen3-Embedding-8B/resolve/main/model-00004-of-00004.safetensors";
        sha256 = "sha256-NsvJxgN1aTYp8ldDwed+uxckr1jmcbI3ZGMZPH/SHvY=";
      };
    }
  ];
  parallel = 2;
  llamaModels = pkgs.linkFarm "llama-models" [
    {
      name = "mellum-4b-base:q8_0";
      path = mellum-base-4b;
    }
    {
      name = "qwen3.6-35b-a3b-it:q8_k_xl";
      path = qwen36-35b_q8_k_xl;
    }
    {
      name = "qwen3-embedding-8b";
      path = qwen3Embedding;
    }
  ];
in {
  options.services.llama-cpp.enableRocmFp4 = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Serve the ROCmFP4 STRIX_LEAN model on port 11405 (requires the rocmfpx input).";
  };

  config = {
    services.llama-cpp = {
      enable = true;
      # Upstream nixpkgs Vulkan build. ROCmFP4 models are served separately by
      # the dedicated llama-cpp-rocmfp4 service (this build can't decode them).
      package = pkgs.llama-cpp-vulkan;

      settings = {
        host = config.sys.bindAddress;
        port = 11404;

        # Must be a string, not a derivation (CLI formatter can't handle attrsets)
        models-dir = "${llamaModels}";

        mmap = true;
        models-max = 4;
        models-autoload = true;
        parallel = parallel;
        cont-batching = false;
        ctx-checkpoints = false;
        fit = "on";
        flash-attn = "on";
        cache-ram = 16384;
        temperature = 0.2;
        repeat-penalty = 1.0;
        presence-penalty = 0.1;
        frequency-penalty = 0.0;

        models-preset = "${pkgs.writeText "models.ini" ''
          [mellum-4b-base:q8_0]
          model = ${mellum-base-4b};
          alias = mellum-4b-base;
          n-predict = 64;
          ctx-size = ${toString (8192 * parallel)};
          n-gpu-layers = auto;
          cache-type-k = q8_0;
          cache-type-v = q8_0;

          [qwen3.6-35b-a3b-it:q8_k_xl]
          model = ${qwen36-35b_q8_k_xl};
          alias = qwen3.6-35b_q8;
          ctx-size = ${toString (262144 * parallel)};
          n-gpu-layers = auto;
          cache-type-k = q8_0;
          cache-type-v = q8_0;
          chat-template-kwargs = {"preserve_thinking":true};

          [qwen3.8-27b:q8]
          model = ${qwen38-28b_q8};
          alias = qwen3.8-27b;
          ctx-size = ${toString (262144 * parallel)};
          n-gpu-layers = auto;
          cache-type-k = q8_0;
          cache-type-v = q8_0;
          spec-type = draft-mtp;
          spec-draft-model = ${qwen38-27b_mtp};
          spec-draft-n-max = 5;
          spec-draft-ngl = auto;
          chat-template-kwargs = {"preserve_thinking":true,"reasoning_effort":"medium"};

          [qwen3-embedding-8b]
          model = ${qwen3Embedding}/model-00001-of-00004.safetensors;
          alias = qwen3-embedding;
          ctx-size = ${toString (262144 * parallel)};
          n-gpu-layers = auto;
          cache-type-k = q8_0;
          cache-type-v = q8_0;
        ''}";
      };
    };

    # Dedicated server for the ROCmFP4 STRIX_LEAN qwen3.6-35B (bare single model,
    # MTP self-spec). Uses the ROCmFPX fork (only build that decodes ROCmFP4
    # tensors). Runs on its own port so the upstream llama-cpp service stays on
    # the standard Vulkan build.
    systemd.services.llama-cpp-rocmfp4 = lib.mkIf config.services.llama-cpp.enableRocmFp4 (
      let
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
        # ROCmFP4 STRIX_AI quantization of Qwen3.6-35B-A3B (BF16 + imatrix
        # derived, gsrunion). ~18 GiB.
        qwen36-35bSTRIX = pkgs.fetchurl {
          url = "https://huggingface.co/gsrunion/Qwen3.6-35B-A3B-ROCmFP4-STRIX_LEAN-GGUF/resolve/main/Qwen3.6-35B-A3B-Q4_0_ROCMFP4_STRIX_LEAN.gguf";
          sha256 = "sha256-cDoOSvjy0enstQ8cNQfXNEGJoOtdurR5b/aSYaR8sDs=";
        };
      in {
        description = "llama.cpp ROCmFP4 server (qwen3.6-35B STRIX_LEAN + MTP)";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        restartIfChanged = true;
        serviceConfig = {
          Type = "simple";
          User = "llama-cpp";
          DynamicUser = true;
          ExecStart =
            "${llamaCppRocmFpx}/bin/llama-server "
            + "--host ${config.sys.bindAddress} "
            + "--port 11405 "
            + "--model ${qwen36-35bSTRIX} "
            + "--ctx-size 262144 "
            + "--alias qwen3.6-35b_q4 "
            + "--n-gpu-layers auto "
            + "--cache-type-k q4_0 "
            + "--cache-type-v q4_0 "
            + "--flash-attn on "
            + "--no-cont-batching "
            + "--parallel 1 "
            + "--fit on "
            + "--cache-ram 8192 "
            + "--mmap "
            + "--jinja "
            + "--reasoning on "
            + "--spec-type draft-mtp "
            + "--spec-draft-n-max 4 "
            + "--spec-draft-p-min 0.55 "
            + "--chat-template-kwargs '{\"preserve_thinking\":true}'";
          Restart = "on-failure";
          RestartSec = "5s";
          StandardOutput = "journal";
          StandardError = "journal";
          SyslogIdentifier = "llama-cpp-rocmfp4";
        };
      }
    );
  };
}
