import sys, os
import argparse
import traceback, subprocess
import shutil
import re
import pathlib

# Add project root to path for qemu_helper
PROJECT_ROOT = pathlib.Path(__file__).parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

# --- CONFIGURATION FROM INPUT_SCRIPTS ---
SOURCE_FOLDER = './input_scripts' 
FOLDER_ALL_OBF = './every_obf'
FOLDER_XHIDER = './for_xhider_obf'

def clean_lua_code(content):
    """
    Removes trash functions, loops, and comments from Lua code.
    Customize the regex patterns below to match specific junk code.
    """
    
    # 1. Remove Single Line Comments (--)
    content = re.sub(r'--.*', '', content)
    
    # 2. Remove Block Comments (--[[ ... ]])
    content = re.sub(r'--\[\[.*?\]\]', '', content, flags=re.DOTALL)

    # 3. Remove "Trash" Loops (e.g., empty while loops often used as junk)
    # Matches: while true do end
    content = re.sub(r'while\s+true\s+do\s+end', '', content)
    
    # Matches: while wait() do end
    content = re.sub(r'while\s+wait\(\)\s+do\s+end', '', content)

    # 4. Remove specific "Trash" Functions
    # If you know the name of the trash function (e.g., "junk_func"), replace 'junk_func' below.
    # This regex looks for: function junk_func() ... end
    # content = re.sub(r'function\s+junk_func\(\).*?end', '', content, flags=re.DOTALL)

    # 5. Remove Empty Lines (Cleanup)
    lines = [line for line in content.splitlines() if line.strip()]
    return '\n'.join(lines)

def is_xhider_script(content):
    """
    Checks if the script contains patterns specific to Xhider obfuscation.
    """
    if re.search(r'while\s+true\s+do\s+end', content):
        return True
    if re.search(r'while\s+wait\(\)\s+do\s+end', content):
        return True
    return False

def process_input_files():
    # 1. Create Destination Folders
    if not os.path.exists(FOLDER_ALL_OBF):
        os.makedirs(FOLDER_ALL_OBF)
        print(f"[+] Created folder: {FOLDER_ALL_OBF}")
        
    if not os.path.exists(FOLDER_XHIDER):
        os.makedirs(FOLDER_XHIDER)
        print(f"[+] Created folder: {FOLDER_XHIDER}")

    # Check if source exists
    if not os.path.exists(SOURCE_FOLDER):
        os.makedirs(SOURCE_FOLDER)
        print(f"[-] Source folder '{SOURCE_FOLDER}' did not exist. I created it.")
        print("    Please put your script files inside 'input_scripts' and run this script again.")
        return

    # 2. Process Files
    files = os.listdir(SOURCE_FOLDER)
    if not files:
        print("[-] No files found in source folder.")
        return

    print(f"[*] Processing {len(files)} files...")

    for filename in files:
        src_path = os.path.join(SOURCE_FOLDER, filename)
        
        # Skip directories, process only files
        if os.path.isfile(src_path):
            try:
                # --- Step A: Save original to 'every_obf' ---
                dest_all_path = os.path.join(FOLDER_ALL_OBF, filename)
                shutil.copy(src_path, dest_all_path)

                # --- Step B: Clean and save to 'for_xhider_obf' ---
                # Read file
                with open(src_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                # Check if it is Xhider before cleaning
                if is_xhider_script(content):
                    # Clean content
                    cleaned_content = clean_lua_code(content)
                    
                    # Write cleaned file
                    dest_xhider_path = os.path.join(FOLDER_XHIDER, filename)
                    with open(dest_xhider_path, 'w', encoding='utf-8') as f:
                        f.write(cleaned_content)

                    print(f"    [OK] Processed (Xhider): {filename}")
                else:
                    print(f"    [OK] Copied to every_obf (Not Xhider): {filename}")

            except Exception as e:
                print(f"    [ERROR] Could not process {filename}: {e}")

    print("[*] Done! Check your folders.")

def main():
    arg = argparse.ArgumentParser()
    arg.add_argument("-m","--modes", type=str, required=True, help="Obfuscation mode: auto, basic, hard, max, normal, ibs, strong, or prep")
    arg.add_argument("-i", "--input", type=str, required=False, help="Input file path (required for deobfuscation modes)")
    arg.add_argument("-o", "--output", type=str, required=False, help="Output file path (required for deobfuscation modes)")
    args = arg.parse_args()
    
    if args.modes == "prep":
        process_input_files()
    elif args.modes == "auto":
        pass
    elif args.modes == "basic":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./basic_mode/decrypt_basic.py", "-i", args.input, "-o", args.output])
    elif args.modes == "hard":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./hard_mode/decrypt_hard.py", "-i", args.input, "-o", args.output])
    elif args.modes == "max":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./max_security_mode/decrypt_max_v2.py", "-i", args.input, "-o", args.output])
    elif args.modes == "normal":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./normal_mode/decrypt_normal.py", "-i", args.input, "-o", args.output])
    elif args.modes == "ibs":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./ibs_mode/dump_strings_ibs.py", "-i", args.input, "-o", args.output])
    elif args.modes == "strong":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./strong_mode/decrypt_strong.py", "-i", args.input, "-o", args.output])
    elif args.modes == "evil":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run(["python", "./evil_mode/crack_evil_all.py", "-i", args.input, "-o", args.output])
    elif args.modes == "psu":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run([sys.executable, "./psu_mode/dump_payload.py"])
    elif args.modes == "psu_mid":
        if not args.input or not args.output:
            print("Error: -i and -o are required for this mode")
            return
        subprocess.run([sys.executable, "./psu_mid_mode/dump_payload.py"])
    elif args.modes == "psu_max":
        if not args.input:
            print("Error: -i is required for psu_max mode")
            return
        out = args.output or (args.input.rsplit('.', 1)[0] + '.decrypted.lua')
        subprocess.run([sys.executable, "./psu_max_mode/decrypt_psu_max.py", args.input, "--output", out])
    else:
        print("Invalid mode")

if __name__ == "__main__":
    main()