{ pkgs, lib, config, mcp-servers-nix, ... }:
let
  # Generate MCP configuration for Claude Desktop
  mcpConfig = mcp-servers-nix.lib.mkConfig pkgs {
    format = "json";
    fileName = "claude_desktop_config.json";
    
    programs = {
      # Web fetching capabilities
      # fetch.enable = true;
      
      # Time utilities
      time.enable = true;

      context7.enable = true;

      # memory.enable = true;
    };
    
    # Add custom MCP servers if needed
    settings.servers = {
      mcp-nixos = {
        command = "nix";
        args = [ "run" "github:utensils/mcp-nixos" "--"];
      };
    };
  };

in {
  # Install MCP server packages
  # home.packages = with mcp-servers-nix.packages.${pkgs.stdenv.hostPlatform.system}; [
  #   mcp-server-time
  #   context7-mcp
  #   mcp-servers-nix
  #   # memory
  #   # fetch
  #   pkgs.nodejs
  #   pkgs.uv
  # ];


  # Create Claude Desktop config directory and file
  home.file.".config/Claude/claude_desktop_config.json" = {
    source = mcpConfig;
  };
  

}
