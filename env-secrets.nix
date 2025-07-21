{
  lib,
  pkgs,
  config,
  ...
}:

let
  # Get the configuration for this module.
  cfg = config.services.secret-env;

  # Helper function to generate the shell commands for writing the config files.
  # It takes the output file path and a prefix for each line (e.g., "DefaultEnvironment=").
  mkWriteCommands =
    outFile: linePrefix:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: secretPath:
        # Read secret into a shell variable. Command substitution `$(...)` automatically
        # strips a single trailing newline, which is exactly what we want.
        # Then, printf formats the output, ensuring the value is handled correctly.
        ''
          secret_value=$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg secretPath})
          ${pkgs.coreutils}/bin/printf '%s%s\n' '${linePrefix}${name}=' "$secret_value" >> ${lib.escapeShellArg outFile}
        '') cfg.variables
    );

in
{
  # Define the options that users can set for this module.
  options.services.secret-env = {
    enable = lib.mkEnableOption "a service to set environment variables from files";

    variables = lib.mkOption {
      type = lib.types.attrsOf lib.types.path; # Use `path` type for file paths.
      default = { };
      description = ''
        An attribute set of environment variables to set from secret files.
        The attribute name becomes the environment variable name, and the value
        is the path to the file containing the secret.

        NOTE: The underlying mechanisms (`environment.d` and `systemd.conf.d`)
        require that the secret value be a single line of text. Multi-line
        secrets are not supported and will lead to incorrect behavior.
      '';
      example = lib.literalExpression ''
        {
          # This sets an environment variable MY_API_TOKEN with the
          # content of the file provided by sops-nix.
          MY_API_TOKEN = config.sops.secrets.api_token.path;
        }
      '';
    };
  };

  # The actual configuration is generated only if the module is enabled.
  config = lib.mkIf cfg.enable {

    systemd.services.set-secret-env-vars = {
      description = "Set system-wide environment variables from secret files";

      # This service must run after secrets are available (e.g., via sops-nix).
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];

      # Run before filesystem mounts that might need these variables.
      # Removed "basic.target" to prevent cyclic dependencies during boot.
      before = [ "local-fs.target" ];

      # This service is a fundamental part of the boot process.
      wantedBy = [ "multi-user.target" ];

      # The script content is provided directly as a string.
      script =
        let
          # Define directory and file paths explicitly.
          systemdConfDir = "/run/systemd/system.conf.d";
          envDConfDir = "/run/environment.d";
          systemdConfFile = "${systemdConfDir}/90-secret-env.conf";
          envDConfFile = "${envDConfDir}/90-secret-env.conf";
          # Path to the old, incorrectly placed config file for cleanup.
          oldConfFile = "/etc/systemd/system.conf.d/secret-env.conf";
        in
        ''
          set -euo pipefail

          # Explicitly remove the old, incorrectly placed config file if it exists
          # to prevent conflicts and confusion.
          ${pkgs.coreutils}/bin/rm -f ${lib.escapeShellArg oldConfFile}

          # Ensure the parent directories exist.
          ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg systemdConfDir}
          ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg envDConfDir}

          # Start with clean files each time the service runs. This also handles
          # the case where a variable is removed from the configuration.
          > ${lib.escapeShellArg systemdConfFile}
          > ${lib.escapeShellArg envDConfFile}

          # Generate the content for systemd's DefaultEnvironment.
          # This makes the variables available to all systemd services.
          ${mkWriteCommands systemdConfFile "DefaultEnvironment="}

          # Generate the content for environment.d.
          # This makes the variables available to user sessions (e.g., SSH, graphical).
          ${mkWriteCommands envDConfFile ""}

          # Tell the running systemd instance to re-read all its configuration files.
          ${pkgs.systemd}/bin/systemctl daemon-reload
        '';

      serviceConfig = {
        Type = "oneshot";
        # The changes (setting environment variables) should persist for all
        # units started after this one completes.
        RemainAfterExit = true;
      };
    };
  };
}
