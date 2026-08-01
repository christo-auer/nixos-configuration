{ pkgs, claude-desktop, lib, config, ... }: {

  imports = [
    ./mcp.nix
  ];

  programs.opencode = {
      enable = true;

      package = pkgs.opencode;

      settings = {
        mcp = {

          mcp-nixos = {
            command = ["nix" "run" "github:utensils/mcp-nixos" "--"];
            enabled = true;
            type = "local";
          };

        };


        provider = {
          # copilot.disabled = false;
          # anthropic.disabled = false;
          edenai= {
            npm = "@ai-sdk/openai-compatible";
            name = "Eden AI";
            options = {baseURL = "https://api.edenai.run/v3"; };
            models = {
              "amazon/moonshotai.kimi-k2.5" = {};
              "qwen/glm-5.2" = {};
              "qwen/qwen3-max" = {};
              "qwen/qwen3.7-max" = {};
              "qwen/qwen-plus" = {};
              "qwen/qwen-coder-plus" = {};
            };

          };
          ollama = {
            npm =  "@ai-sdk/openai-compatible";
            options =  {
              baseURL =  "http://localhost:11434/v1";
            };
            models =  {
              "qwen3.5:35b" = {};
              "qwen3.5:9b" = {};
            };

          };


        };


      };
  };


}
