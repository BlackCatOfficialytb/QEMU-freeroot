import os
# # Ép Playwright dùng trình duyệt ở ổ E
# os.environ["PLAYWRIGHT_BROWSERS_PATH"] = r"E:\ms-playwright"

from playwright.sync_api import sync_playwright
import requests
import json
import sys

def create_user_agent(roblox_type:str = "global", more_camouflage:bool = False, customs_roblox_version:str = None, **kwargs):
    roblox_version = None
    if customs_roblox_version is None:
        try:
            weao_headers = {'User-Agent': 'WEAO-3PService'}
            response = requests.get("https://weao.xyz/api/versions/current", headers=weao_headers, timeout=5)
            roblox_version = response.json().get("Android")
        except:
            roblox_version = "2.717.985"
    else: 
        roblox_version = customs_roblox_version

    if more_camouflage:
        keyword_args = kwargs.copy()
        custom_mem = keyword_args.get("mem", "1993MB")
        native_res = keyword_args.get("native_res", "1280x720")
        viewport_res = keyword_args.get("viewport_res", native_res)
        gui_scaling = keyword_args.get("gui_scaling", "853x480")
        android_model = keyword_args.get("android_model", "Samsung SM-A5560")
        android_ver = keyword_args.get("android_ver", "12")
        hardware_camouflage = f" ({custom_mem}; {native_res}; {viewport_res}; {gui_scaling}; {android_model}; {android_ver}) "
    else:
        hardware_camouflage = " "

    if roblox_type.lower() == "global":
        dist = "GlobalDist"
    elif roblox_type.lower() in ["vn", "vng"]:
        dist = "VNGGamesDist"
    else: 
        raise ValueError("Invalid roblox type: global, vn, or vng")

    return f"Mozilla/5.0{hardware_camouflage}AppleWebKit/537.36 (KHTML, like Gecko)  ROBLOX Android App {roblox_version} Phone Hybrid()  GooglePlayStore RobloxApp/{roblox_version} ({dist}; GooglePlayStore)"

def run_playwright_bypass(url, roblox_type="global", more_camouflage=False, customs_roblox_version=None):
    with sync_playwright() as p:
        # Launch browser - Thêm slow_mo nếu bị Cloudflare soi quá kỹ
        browser = p.chromium.launch(headless=False) 
        
        my_ua = create_user_agent(
            roblox_type=roblox_type, 
            more_camouflage=more_camouflage,
            customs_roblox_version=customs_roblox_version
        )
        
        print(f"\n[+] Sử dụng UA: {my_ua}")

        # Logic chọn Package Name chuẩn cho từng bản
        package_name = "com.roblox.client"
        if roblox_type.lower() in ["vn", "vng"]:
            package_name = "com.roblox.client.vnggames"

        context = browser.new_context(
            user_agent=my_ua,
            extra_http_headers={
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
                "Cache-Control": "no-cache",
                "Origin": "https://www.roblox.com",
                "X-Requested-With": package_name,
            }
        )

        page = context.new_page()
        
        try:
            print(f"[+] Connecting to: {url}")
            # Tăng timeout lên 60s vì trycloudflare đôi khi khá chậm
            response = page.goto(url, wait_until="networkidle", timeout=60000)
            
            print(f"[+] Status Code: {response.status}")
            
            if response.status == 200:
                print("\n--- Script Content ---")
                print(page.content())
                print("-----------------------\n")
            
            print("Press Enter to exit or Ctrl+C...")
            input()
        except KeyboardInterrupt:
            print("\n[!] Đang đóng...")
        except Exception as e:
            print(f"[!] Lỗi: {e}")
        finally:
            browser.close()

def main():
    print("=== TOOL DOWNLOAD SCRIPT (ROBLOX CAMOUFLAGE) ===")
    
    r_type = input("Roblox Type (global/vng) [global]: ").strip().lower() or "global"
    
    cam_input = input("More Camouflaging? (Y/n): ").strip().lower()
    more_cam = False if cam_input == 'n' else True
    
    c_version = input("Custom Roblox Version (Leave blank for Auto): ").strip()
    c_version = c_version if len(c_version) > 0 else None
    
    target_url = input("Type URL you want to download: ").strip()
    if not target_url:
        print("URL MUST NOT BE BLANK!")
        return

    run_playwright_bypass(
        url=target_url, 
        roblox_type=r_type, 
        more_camouflage=more_cam, 
        customs_roblox_version=c_version
    )
    print("Exited code 0")

if __name__ == '__main__':
    main()