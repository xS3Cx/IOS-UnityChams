import sys

# ANSI Colors
BLUE = "\033[94m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
BOLD = "\033[1m"
RESET = "\033[0m"

LOG_PREFIX = f"{CYAN}[MACOS-BUILD]{RESET} "

def log_info(msg):
    print(f"{LOG_PREFIX}{BLUE}{msg}{RESET}")

def log_success(msg):
    print(f"{LOG_PREFIX}{GREEN}{BOLD}✓ {msg}{RESET}")

def log_warning(msg):
    print(f"{LOG_PREFIX}{YELLOW}{BOLD}⚠️  {msg}{RESET}")

def log_error(msg):
    print(f"{LOG_PREFIX}{RED}{BOLD}✖ {msg}{RESET}")

def main():
    if len(sys.argv) < 2:
        return

    command = sys.argv[1]

    if command == "convert":
        log_info("Converting iOS dylib to macCatalyst...")
    elif command == "convert-success":
        log_success("Conversion successful!")
    elif command == "sign":
        log_info("Signing dylib for macOS...")
    elif command == "sign-success":
        log_success("Signing successful!")
    elif command == "copy":
        log_info("Deploying to PlayCover...")
    elif command == "copy-success":
        log_success("Deployment successful!")
    elif command == "check-game":
        log_info("Checking for running CombatMaster instance...")
    elif command == "close-game":
        log_warning("Closing existing CombatMaster process...")
    elif command == "game-closed":
        log_success("Game process closed.")
    elif command == "no-process":
        log_info("No existing process found.")
    elif command == "open-game":
        log_info("Launching CombatMaster...")
    elif command == "game-opened":
        log_success("Game launched successfully!")
    elif command == "error-frameworks":
        log_error("Frameworks directory not found in PlayCover app. Please check your path!")
    elif command == "remove-old":
        log_info("Removing old dylib...")
    elif command == "summary":
        print("\n" + "="*50)
        print(f"{MAGENTA}{BOLD}  MACOS BUILD WORKFLOW COMPLETED!{RESET}")
        print("="*50 + "\n")

if __name__ == "__main__":
    main()
