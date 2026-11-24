import os
import sys
import time
import webbrowser
import subprocess

def main():
    print("===================================================================")
    print("  DPC Platform: Drug Price Comparison & Healthcare Assistant")
    print("===================================================================")
    
    python_exe = sys.executable
    project_dir = os.path.dirname(os.path.abspath(__file__))
    manage_py = os.path.join(project_dir, 'backend', 'manage.py')
    
    print(f"Using Python: {python_exe}")
    print(f"Project root: {project_dir}")
    print("\nStarting Django server at http://127.0.0.1:8000/ ...")
    
    # Open browser in a separate thread after 1.5 seconds
    import threading
    def open_browser():
        time.sleep(1.5)
        webbrowser.open('http://127.0.0.1:8000/')
    
    threading.Thread(target=open_browser, daemon=True).start()
    
    # Run server
    try:
        subprocess.run([python_exe, manage_py, "runserver", "127.0.0.1:8000"])
    except KeyboardInterrupt:
        print("\nServer stopped cleanly.")

if __name__ == '__main__':
    main()
