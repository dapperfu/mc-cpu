# mc-cpu: Taming the Minecraft CPU Beast 🎮⚡

> *Because Minecraft thinks your CPU is an all-you-can-eat buffet, and we're here to be the bouncer.*

## What Is This Madness?

Have you ever watched Minecraft casually devour 100% of your CPU while you're just trying to mine some virtual diamonds? Have you felt your laptop transform into a space heater because Mojang's Java masterpiece decided to render every single blade of grass in a 16-chunk radius? 

**mc-cpu** is your solution. It's a bash script that uses Linux cgroups v2 to put Minecraft on a digital leash, preventing it from turning your computer into a toaster oven.

## The Problem We're Solving

Minecraft is like that friend who says "I'll just have one chip" and then eats the entire bag. It's a single-threaded performance monster that will happily consume every CPU cycle you have, leaving your system gasping for air. This project gives you the power to say "No, Minecraft. You get 10% of one core, and you'll like it."

## What It Does

Using the magic of Linux cgroups v2, this project:

- **Limits CPU usage** - Tell Minecraft exactly how much CPU it can have (from 0% to unlimited)
- **Pauses/Resumes processes** - Put Minecraft in timeout when you need your CPU back
- **Tracks processes automatically** - Finds all your Minecraft instances (even across users) and herds them into the cgroup

## The Script

**`mc-cpu`** - The master controller. This is the script that does all the heavy lifting. Feed it a percentage, or one of the special commands: `freeze`, `normal`/`max`, `pause`, or `resume`.

## Installation

First, make sure you have `cgroup-tools` installed and the cgroup directory set up. The Makefile does all the heavy lifting:

```bash
# Install everything (cgroup-tools, setup cgroup, install script)
make all

# Or do it step by step if you're feeling fancy:
make install      # Install cgroup-tools package
make setup        # Create /sys/fs/cgroup/minecraft cgroup
make install-script # Install mc-cpu to /usr/local/bin
```

**Note:** You'll need `sudo` privileges for installation. The script itself also needs `sudo` to modify cgroups and control processes. This is normal Linux behavior - we're not trying to hack your system, we're just trying to hack Minecraft's CPU usage.

## Usage Examples

### Basic CPU Limiting

```bash
# Give Minecraft 50% of one core (0.5 cores)
mc-cpu 50

# Give Minecraft 2 full cores (200%)
mc-cpu 200

# Freeze Minecraft completely (0% CPU)
mc-cpu freeze

# Let Minecraft run wild (unlimited CPU)
mc-cpu normal
# Or use the technical term:
mc-cpu max
```

### Process Control

```bash
# Pause all Minecraft processes (they're still in memory, just frozen)
mc-cpu pause

# Resume all Minecraft processes
mc-cpu resume
```

### Re-tracking Processes

If you start Minecraft after setting a CPU limit, the script automatically tracks new processes when you set a new limit. If you need to re-track without changing the limit, simply set the same limit again:

```bash
# Set a limit first
mc-cpu 50

# Start Minecraft later...

# Re-track to add new processes to the cgroup (keeps 50% limit)
mc-cpu 50
```

## Remote Usage: Controlling Minecraft from Another Machine 🎮🌐

Sometimes you need to be the CPU dictator from afar. Maybe you're a parent who wants to limit Minecraft CPU usage on your child's gaming machine from the comfort of your own laptop. Or maybe you're just lazy and don't want to walk to the other room. Either way, we've got you covered.

### Setup

#### Step 1: Install mc-cpu on the Gaming Machine

On the machine where Minecraft runs (the "child's gaming machine"), follow the standard installation:

```bash
# On the gaming machine
cd /path/to/mc-slow
make all
```

Make sure SSH access is configured so you can connect from your parental/control machine.

#### Step 2: Install Remote Alias on Parental Machines

On the machine you'll use to control Minecraft remotely (the "parental machine"), add the `mc-cpu-r` function to your shell configuration file:

**For Bash users** (add to `~/.bashrc`):
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

**For Zsh users** (add to `~/.zshrc`):
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

After adding the function, reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

**Why `mc-cpu-r`?** We use `mc-cpu-r` (the "r" stands for "remote") to avoid namespace conflicts with the local `mc-cpu` script. This way you can have both installed without stepping on each other's toes.

### Remote Usage Examples

Once set up, you can control Minecraft on the remote machine just like you would locally:

```bash
# Limit Minecraft to 50% CPU on remote machine "gen1"
mc-cpu-r gen1 50

# Freeze Minecraft completely on remote machine "gen1"
mc-cpu-r gen1 freeze

# Let Minecraft run wild on remote machine "gen1"
mc-cpu-r gen1 normal

# Pause all Minecraft processes on remote machine "gen1"
mc-cpu-r gen1 pause

# Resume all Minecraft processes on remote machine "gen1"
mc-cpu-r gen1 resume

# Give Minecraft 2 full cores on remote machine "gen1"
mc-cpu-r gen1 200
```

The function works by:
1. Taking the remote hostname as the first argument (`gen1` in the examples above)
2. Passing all remaining arguments directly to `mc-cpu` on the remote machine via SSH
3. Executing the command remotely and returning the output

**Note:** Make sure you have SSH key-based authentication set up (or be prepared to enter passwords) for a smooth remote control experience. Nobody wants to type passwords every time they want to freeze Minecraft.

## How It Works (The Technical Part)

Under the hood, this project uses Linux cgroups v2 to create a control group specifically for Minecraft processes. Here's what happens:

1. **Process Detection**: The script finds all processes matching `org.multimc.EntryPoint` (MultiMC's process pattern) using `pgrep`
2. **Cgroup Assignment**: Processes are moved into `/sys/fs/cgroup/minecraft` by writing their PIDs to `cgroup.procs`
3. **CPU Limiting**: The script converts your percentage input to millipercent and writes to `cpu.max` in the format `{millipercent} 100000`, where:
   - The percentage you provide is multiplied by 1000 to get millipercent (e.g., 50% → 50000 millipercent)
   - `100000` is the period (100ms in microseconds)
   - For unlimited CPU, it writes `max 100000`

The math: `percentage * 1000 = millipercent`. So when you run `mc-cpu 50`, it becomes 50000 millipercent, which means "50% of one core over a 100ms period."

## Why This Exists

Because sometimes you want to:
- Run a Minecraft server in the background without it consuming your entire CPU
- Play Minecraft while also doing other things (revolutionary, I know)
- Test how Minecraft performs under different CPU constraints
- Prevent your laptop from achieving liftoff velocity due to thermal output

## Troubleshooting

**"No Minecraft processes found"**
- Make sure Minecraft is actually running
- The script looks for `org.multimc.EntryPoint` - if you're using a different launcher, you might need to modify `PROCESS_PATTERN` in `mc-cpu`

**"Cgroup does not exist"**
- Run `make setup` to create the cgroup directory
- Make sure you have cgroup-tools installed (`make install`)

**"Permission denied"**
- The script needs `sudo` to modify cgroups and control processes
- Make sure you're running with appropriate permissions

**"Minecraft is still using 100% CPU"**
- Make sure you've actually set a limit (`mc-cpu 50` or similar)
- Check that processes are in the cgroup: `cat /sys/fs/cgroup/minecraft/cgroup.procs`
- Try re-tracking by setting the limit again: `mc-cpu 50` (or whatever limit you had set)

## Contributing

Found a bug? Have an idea for a new feature? Contributions welcome!

Just remember: if you add new functionality, make sure it's funnier than the existing code. We have standards here.

## License

This project is provided as-is, with no warranty that it won't make Minecraft even more confused about CPU usage. Use at your own risk. Your CPU is not our responsibility (but we'll try our best).

## Acknowledgments

- Minecraft, for being a CPU-hungry masterpiece
- Linux cgroups, for giving us the power to be CPU dictators
- MultiMC, for having a process name we can actually grep for
- All the developers who said "surely Minecraft won't use that much CPU" and were wrong

---

*Remember: With great power comes great responsibility. Use this power wisely. Or don't. We're not your CPU's parent.*
