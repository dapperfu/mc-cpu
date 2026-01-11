# mc-slow: Taming the Minecraft CPU Beast 🎮⚡

> *Because Minecraft thinks your CPU is an all-you-can-eat buffet, and we're here to be the bouncer.*

## What Is This Madness?

Have you ever watched Minecraft casually devour 100% of your CPU while you're just trying to mine some virtual diamonds? Have you felt your laptop transform into a space heater because Mojang's Java masterpiece decided to render every single blade of grass in a 16-chunk radius? 

**mc-slow** is your solution. It's a collection of bash scripts that use Linux cgroups v2 to put Minecraft on a digital leash, preventing it from turning your computer into a toaster oven.

## The Problem We're Solving

Minecraft is like that friend who says "I'll just have one chip" and then eats the entire bag. It's a single-threaded performance monster that will happily consume every CPU cycle you have, leaving your system gasping for air. This project gives you the power to say "No, Minecraft. You get 10% of one core, and you'll like it."

## What It Does

Using the magic of Linux cgroups v2, this project:

- **Limits CPU usage** - Tell Minecraft exactly how much CPU it can have (from 0% to unlimited)
- **Pauses/Resumes processes** - Put Minecraft in timeout when you need your CPU back
- **Tracks processes automatically** - Finds all your Minecraft instances (even across users) and herds them into the cgroup
- **Provides convenient shortcuts** - Because typing `mc-cpu 50` is hard, apparently

## The Scripts (And Their Quirky Names)

We've got a whole menagerie of convenience scripts, each with its own personality:

### The Main Script
- **`mc-cpu`** - The master controller. This is the script that does all the heavy lifting. Feed it a percentage, or one of the special commands below.

### CPU Limit Scripts
- **`mc-slow`** - Sets CPU to 10%. For when you want Minecraft to run like it's stuck in molasses. Perfect for background servers that should exist but not thrive.
- **`mc-15`** - Actually sets CPU to 30%. Yes, the name is a lie. We don't talk about it. (It's like calling a chihuahua "Tiny" when it's actually "Moderately Sized".)
- **`mc-30`** - Actually sets CPU to 55%. The naming convention here is... creative. Think of it as "30% more than you'd expect from mc-15."
- **`mc-fast`** - Sets CPU to 70%. For when you want Minecraft to run reasonably well but still leave some CPU for other things. Like your operating system.
- **`mc-normal`** - Sets CPU to unlimited (max). Releases the beast. Use with caution. Your CPU is now Minecraft's playground.
- **`mc-freeze`** - Sets CPU to 0%. Minecraft is now frozen in time, like a digital popsicle. It exists, but it's not going anywhere.

### Process Control Scripts
- **`mc-on`** - Resumes all paused Minecraft processes. Wake up, sleepy Java processes!
- **`mc-off`** - Pauses all Minecraft processes. Time for a digital nap.
- **`mc-track`** - Re-tracks all Minecraft processes while preserving your current CPU limit. Useful when Minecraft processes spawn after you've set a limit.

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

**Note:** You'll need `sudo` privileges for installation. The scripts themselves also need `sudo` to modify cgroups and control processes. This is normal Linux behavior - we're not trying to hack your system, we're just trying to hack Minecraft's CPU usage.

## Usage Examples

### Basic CPU Limiting

```bash
# Give Minecraft 50% of one core (0.5 cores)
mc-cpu 50

# Give Minecraft 2 full cores (200%)
mc-cpu 200

# Freeze Minecraft completely (0% CPU)
mc-cpu freeze
# Or use the convenience script:
mc-freeze

# Let Minecraft run wild (unlimited CPU)
mc-cpu normal
# Or use the technical term:
mc-cpu max
# Or:
mc-normal
```

### Process Control

```bash
# Pause all Minecraft processes (they're still in memory, just frozen)
mc-off

# Resume all Minecraft processes
mc-on
```

### The Convenience Scripts

```bash
# Run Minecraft at a snail's pace (10% CPU)
mc-slow

# Run Minecraft at a reasonable pace (70% CPU)
mc-fast

# Let Minecraft consume everything (unlimited)
mc-normal
```

### Re-tracking Processes

If you start Minecraft after setting a CPU limit, use `mc-track` to add the new processes to the cgroup:

```bash
# Set a limit first
mc-slow

# Start Minecraft later...

# Re-track to add new processes to the cgroup
mc-track
```

## How It Works (The Technical Part)

Under the hood, this project uses Linux cgroups v2 to create a control group specifically for Minecraft processes. Here's what happens:

1. **Process Detection**: The script finds all processes matching `org.multimc.EntryPoint` (MultiMC's process pattern) using `pgrep`
2. **Cgroup Assignment**: Processes are moved into `/sys/fs/cgroup/minecraft` by writing their PIDs to `cgroup.procs`
3. **CPU Limiting**: The `cpu.max` file is written with a limit in the format `{limit} 100000`, where:
   - `limit` is in "millipercent" (1000 = 1%, 50000 = 50%, 100000 = 100% of one core)
   - `100000` is the period (100ms in microseconds)
   - `max` means unlimited

The math: `percentage * 1000 = millipercent`. So 50% becomes 50000, which means "50% of one core over a 100ms period."

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
- Try re-tracking: `mc-track`

## Contributing

Found a bug? Have an idea for a new convenience script? Want to fix the naming inconsistencies (please do)? Contributions welcome!

Just remember: if you add a new script, make sure it's funnier than the existing ones. We have standards here.

## License

This project is provided as-is, with no warranty that it won't make Minecraft even more confused about CPU usage. Use at your own risk. Your CPU is not our responsibility (but we'll try our best).

## Acknowledgments

- Minecraft, for being a CPU-hungry masterpiece
- Linux cgroups, for giving us the power to be CPU dictators
- MultiMC, for having a process name we can actually grep for
- All the developers who said "surely Minecraft won't use that much CPU" and were wrong

---

*Remember: With great power comes great responsibility. Use this power wisely. Or don't. We're not your CPU's parent.*
