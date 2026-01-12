# mc-cpu

A bash script that uses Linux cgroups v2 to limit CPU usage for Minecraft processes.

## Overview

mc-cpu controls CPU allocation for Minecraft processes by placing them in a Linux cgroup and setting CPU limits. This allows you to restrict how much CPU time Minecraft can use, preventing it from consuming all available CPU resources.

## Features

- Limits CPU usage from 0% to unlimited
- Pauses and resumes Minecraft processes
- Automatically tracks all Minecraft instances across users
- Supports remote control via SSH

## Installation

Install cgroup-tools, create the cgroup directory, and install the script:

```bash
make all
```

Or install components individually:

```bash
make install      # Install cgroup-tools package
make setup        # Create /sys/fs/cgroup/minecraft cgroup
make install-script # Install mc-cpu to /usr/local/bin
```

Note: Installation requires sudo privileges. The script also requires sudo to modify cgroups and control processes.

## Usage

### Basic CPU Limiting

Set CPU limits using a percentage value where 100% equals one CPU core:

```bash
# Limit to 50% of one core (0.5 cores)
mc-cpu 50

# Limit to 2 full cores (200%)
mc-cpu 200

# Set CPU to 0%
mc-cpu freeze

# Remove CPU limit (unlimited)
mc-cpu normal
# or
mc-cpu max
```

### Process Control

Pause and resume all Minecraft processes:

```bash
# Pause all Minecraft processes (processes remain in memory)
mc-cpu pause

# Resume all Minecraft processes
mc-cpu resume
```

### Re-tracking Processes

If you start Minecraft after setting a CPU limit, the script automatically tracks new processes when you set a new limit. To re-track processes without changing the limit, set the same limit again:

```bash
# Set initial limit
mc-cpu 50

# Start Minecraft later...

# Re-track to add new processes to the cgroup (maintains 50% limit)
mc-cpu 50
```

## Remote Usage

Control Minecraft CPU usage on a remote machine via SSH.

### Setup

#### Step 1: Install on the Target Machine

On the machine where Minecraft runs, install mc-cpu:

```bash
cd /path/to/mc-cpu
make all
```

Ensure SSH access is configured from your control machine.

#### Step 2: Configure Remote Control Function

On your control machine, add the `mc-cpu-r` function to your shell configuration file.

For Bash (add to `~/.bashrc`):

```bash
mc-cpu-r() {
    if [ $# -lt 2 ]; then
        echo "Usage: mc-cpu-r <remote-host> <mc-cpu-arguments...>"
        echo "Example: mc-cpu-r gen1 50"
        return 1
    fi
    remote_host="$1"
    shift
    ssh "$remote_host" mc-cpu "$@"
}
```

For Zsh (add to `~/.zshrc`):

```zsh
mc-cpu-r() {
    if [ $# -lt 2 ]; then
        echo "Usage: mc-cpu-r <remote-host> <mc-cpu-arguments...>"
        echo "Example: mc-cpu-r gen1 50"
        return 1
    fi
    remote_host="$1"
    shift
    ssh "$remote_host" mc-cpu "$@"
}
```

Reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

The `mc-cpu-r` function name avoids conflicts with the local `mc-cpu` script.

### Remote Usage Examples

```bash
# Limit Minecraft to 50% CPU on remote machine "gen1"
mc-cpu-r gen1 50

# Freeze Minecraft on remote machine "gen1"
mc-cpu-r gen1 freeze

# Remove CPU limit on remote machine "gen1"
mc-cpu-r gen1 normal

# Pause all Minecraft processes on remote machine "gen1"
mc-cpu-r gen1 pause

# Resume all Minecraft processes on remote machine "gen1"
mc-cpu-r gen1 resume

# Set limit to 2 full cores on remote machine "gen1"
mc-cpu-r gen1 200
```

The function takes the remote hostname as the first argument and passes remaining arguments to `mc-cpu` on the remote machine via SSH.

Note: Configure SSH key-based authentication to avoid entering passwords for each command.

## How It Works

The script uses Linux cgroups v2 to create a control group for Minecraft processes:

1. **Process Detection**: Finds all processes matching `org.multimc.EntryPoint` (MultiMC's process pattern) using `pgrep`
2. **Cgroup Assignment**: Moves processes into `/sys/fs/cgroup/minecraft` by writing their PIDs to `cgroup.procs`
3. **CPU Limiting**: Converts percentage input to millipercent and writes to `cpu.max` in the format `{millipercent} 100000`, where:
   - The percentage is multiplied by 1000 to get millipercent (e.g., 50% → 50000 millipercent)
   - `100000` is the period (100ms in microseconds)
   - For unlimited CPU, it writes `max 100000`

The conversion formula: `percentage * 1000 = millipercent`. Running `mc-cpu 50` sets 50000 millipercent, meaning 50% of one core over a 100ms period.

## Use Cases

- Run a Minecraft server in the background without consuming all CPU resources
- Play Minecraft while performing other CPU-intensive tasks
- Test Minecraft performance under different CPU constraints
- Reduce thermal output on laptops

## Troubleshooting

**"No Minecraft processes found"**
- Ensure Minecraft is running
- The script searches for `org.multimc.EntryPoint`. If using a different launcher, modify `PROCESS_PATTERN` in the `mc-cpu` script

**"Cgroup does not exist"**
- Run `make setup` to create the cgroup directory
- Ensure cgroup-tools is installed (`make install`)

**"Permission denied"**
- The script requires sudo to modify cgroups and control processes
- Run with appropriate permissions

**"Minecraft is still using 100% CPU"**
- Verify a limit has been set (`mc-cpu 50` or similar)
- Check that processes are in the cgroup: `cat /sys/fs/cgroup/minecraft/cgroup.procs`
- Re-track processes by setting the limit again: `mc-cpu 50` (or your current limit)

## Contributing

Contributions are welcome. Report bugs or suggest features through the project's issue tracker.

## License

This project is provided as-is, without warranty. Use at your own risk.
