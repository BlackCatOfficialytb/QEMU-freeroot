import os
import shutil
import re

# --- CONFIGURATION ---
# The folder where your current scripts are located
SOURCE_FOLDER = './input_scripts' 

# The output folders
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

def main():
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

if __name__ == "__main__":
    main()
