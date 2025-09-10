# Copilot Instructions for MVPStars SourcePawn Plugin

## Repository Overview
This repository contains the **MVPStars** plugin for SourceMod, specifically designed for Zombie Reloaded (ZR) servers. The plugin automatically awards MVP stars to human players who survive rounds and help their team win against zombies. It integrates with the Zombie Reloaded plugin to track player states and awards visual recognition in the scoreboard.

### Key Features
- Tracks human/zombie states through ZR events
- Awards MVP stars to surviving humans when CT team wins
- Integrates seamlessly with Zombie Reloaded gameplay mechanics
- Provides visual feedback in the game scoreboard

## Technical Environment

### Core Technologies
- **Language**: SourcePawn (latest syntax with `#pragma newdecls required`)
- **Platform**: SourceMod 1.11.0+ (currently using 1.11.0-git6917)
- **Game Engine**: Source Engine (Counter-Strike: Source/Global Offensive)
- **Build System**: SourceKnight 0.1 (not direct spcomp compilation)

### Dependencies
- **SourceMod**: 1.11.0-git6917 (minimum 1.11.0)
- **Zombie Reloaded Plugin**: Required for human/zombie state tracking
  - Repository: `https://github.com/srcdslab/sm-plugin-zombiereloaded`
  - Include files needed for compilation

## Project Structure

```
├── .github/
│   ├── workflows/ci.yml          # CI/CD pipeline
│   └── copilot-instructions.md   # This file
├── addons/sourcemod/scripting/
│   └── MVPStars.sp              # Main plugin source code
├── sourceknight.yaml           # Build configuration
└── .gitignore                  # Git ignore rules
```

### Standard SourceMod Directory Structure (when deployed)
- `addons/sourcemod/plugins/` - Compiled plugins (.smx files)
- `addons/sourcemod/scripting/` - Source code (.sp files)
- `addons/sourcemod/scripting/include/` - Include files (.inc)

## Build & Development Process

### Build System: SourceKnight
This project uses **SourceKnight** instead of direct spcomp compilation:

```yaml
# sourceknight.yaml configuration
project:
  sourceknight: 0.1
  name: MVPStars
  dependencies:
    - sourcemod (1.11.0-git6917)
    - zombiereloaded (include files)
  targets:
    - MVPStars
```

### Development Workflow
1. **Local Development**: Modify `.sp` files in `addons/sourcemod/scripting/`
2. **Build**: Use SourceKnight commands (handled by CI)
3. **Testing**: Deploy to development server with SourceMod + ZR
4. **CI/CD**: Automatic build, test, and release via GitHub Actions

### CI/CD Pipeline
- **Trigger**: Push, PR, or manual dispatch
- **Build**: SourceKnight compilation via `maxime1907/action-sourceknight@v1`
- **Package**: Creates deployment-ready package
- **Release**: Automatic tagging and release on main/master branch

## Code Standards & Best Practices

### SourcePawn Style Guidelines
```sourcepawn
// Required pragmas
#pragma newdecls required
#pragma semicolon 1

// Variable naming conventions
bool G_bIsHuman[MAXPLAYERS + 1];    // Global variables: G_ prefix + PascalCase
int localVariable;                   // Local variables: camelCase
char szPlayerName[MAX_NAME_LENGTH];  // String variables: sz prefix

// Function naming
public void OnPluginStart()          // Public functions: PascalCase
void MyHelperFunction()              // Private functions: PascalCase
```

### Memory Management
```sourcepawn
// Use delete directly without null checks
delete myHandle;
myHandle = null;

// Prefer StringMap/ArrayList over arrays
StringMap playerData = new StringMap();
ArrayList playerList = new ArrayList();

// Avoid .Clear() - use delete and recreate instead
delete playerData;
playerData = new StringMap();
```

### Event-Based Programming
```sourcepawn
// Hook events in OnPluginStart
HookEvent("round_start", Event_RoundStart);
HookEvent("round_end", Event_RoundEnd);

// Use ZR forwards for zombie/human state tracking
public void ZR_OnClientInfected(int client, int attacker, bool motherinfect, bool respawnoverride, bool respawn)
public void ZR_OnClientHumanPost(int client, bool respawn, bool protect)
```

## Plugin-Specific Implementation Details

### Core Functionality
The MVPStars plugin tracks player states and awards MVP points:

1. **State Tracking**: Uses global boolean arrays to track human/zombie status
2. **Event Handling**: Responds to round events and ZR state changes
3. **MVP Award Logic**: Awards stars only to surviving humans when CT team wins
4. **Timer Usage**: Uses short delay timer to ensure proper state synchronization

### Key Functions
- `OnPluginStart()`: Initialize event hooks
- `ZR_OnClientInfected()`: Track zombie infections
- `ZR_OnClientHumanPost()`: Track human spawns/cures
- `Event_RoundEnd()`: Detect round winners
- `OnHumansWin()`: Award MVP stars to surviving humans

### Performance Considerations
- Minimal timer usage (single 0.2s timer per round)
- Efficient boolean array lookups (O(1) complexity)
- Event-driven updates instead of polling
- Proper client validation before state changes

## Testing & Validation

### Development Testing
1. **Server Setup**: Requires SourceMod + Zombie Reloaded test server
2. **Test Scenarios**:
   - Humans win round with survivors → MVP stars awarded
   - Zombies win round → No MVP stars awarded
   - Mixed scenarios with infections during round
   - Client connect/disconnect during rounds

### Validation Checklist
- [ ] Plugin compiles without errors/warnings
- [ ] No memory leaks (check with SourceMod profiler)
- [ ] Proper client validation in all functions
- [ ] MVP stars only awarded to valid surviving humans
- [ ] No interference with other ZR functionality

### Common Testing Commands
```sourcepawn
// Debug player states
sm_cvar developer 1
sm_cvar sv_cheats 1

// Force round end for testing
mp_restartgame 1
mp_roundtime 0.1
```

## Dependencies & Integration

### Required Includes
```sourcepawn
#include <sourcemod>
#include <cstrike>      // For CS_SetMVPCount, CS_GetMVPCount
#include <zombiereloaded> // For ZR events and state tracking
```

### Zombie Reloaded Integration
- **State Events**: Responds to infection and cure events
- **Round Logic**: Integrates with ZR round mechanics
- **Team Handling**: Uses ZR's human/zombie team concepts
- **Compatibility**: Designed for ZR's event-driven architecture

## Common Development Tasks

### Adding New Features
1. **New Event Hooks**: Add in `OnPluginStart()`
2. **State Tracking**: Extend global arrays if needed
3. **Configuration**: Consider ConVars for customization
4. **Translation**: Add to translation files for user messages

### Modifying MVP Logic
- **Award Conditions**: Modify `OnHumansWin()` function
- **Point Values**: Adjust MVP increment logic
- **Timing**: Modify timer delay if synchronization issues occur
- **Filtering**: Add additional client validation as needed

### Performance Optimization
- **Loop Optimization**: Minimize operations in client loops
- **Event Efficiency**: Avoid unnecessary event processing
- **Memory Usage**: Monitor handle creation/destruction
- **Timer Management**: Use appropriate timer flags

## Debugging & Troubleshooting

### Common Issues
1. **MVP Not Awarded**: Check client validation and team states
2. **State Sync Issues**: Verify ZR event handling and timing
3. **Memory Leaks**: Ensure proper handle cleanup
4. **Build Failures**: Check SourceKnight configuration and dependencies

### Debug Techniques
```sourcepawn
// Add debug logging
LogMessage("[MVPStars] Client %d - Human: %b, Zombie: %b", client, G_bIsHuman[client], G_bIsZombie[client]);

// Validate client states
if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
```

### SourceMod Console Commands
```
sm plugins list          // List loaded plugins
sm plugins reload MVPStars // Reload plugin for testing
sm_dump_handles          // Check for handle leaks
```

## Deployment & Release

### Release Process
1. **Code Changes**: Make modifications to `.sp` files
2. **Testing**: Validate on development server
3. **Version Update**: Update version in plugin info
4. **Commit**: Push changes to trigger CI/CD
5. **Release**: Automatic packaging and release via GitHub Actions

### Version Management
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `myinfo` structure
- Tag releases correspond to plugin versions
- Maintain changelog for significant updates

## Best Practices Summary

### Code Quality
- Use descriptive variable and function names
- Implement proper error handling for all API calls
- Follow SourcePawn coding standards consistently
- Document complex logic with inline comments

### Performance
- Minimize operations in frequently called functions
- Cache expensive calculations when possible
- Use appropriate data structures (StringMap vs arrays)
- Monitor server performance impact

### Maintainability
- Keep functions focused and single-purpose
- Use consistent naming conventions
- Maintain clear separation between ZR integration and MVP logic
- Regular testing with various ZR configurations

---

*This file helps Copilot understand the MVPStars plugin structure, build process, and development practices for efficient code assistance.*