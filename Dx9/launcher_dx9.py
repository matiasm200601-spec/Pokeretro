import os
import sys
import json
import hashlib
import threading
import subprocess
import urllib.request
import tkinter as tk
from PIL import Image, ImageTk, ImageDraw, ImageFont

GITHUB_USER   = "matiasm200601-spec"
GITHUB_REPO   = "Pokeretro"
GITHUB_BRANCH = "main"
RAW_BASE      = f"https://raw.githubusercontent.com/{GITHUB_USER}/{GITHUB_REPO}/{GITHUB_BRANCH}"
MANIFEST_URL  = f"{RAW_BASE}/manifest.json"
GAME_EXE      = "OTClient DX9.exe"
GAME_FOLDER   = ""
WINDOW_W      = 960
WINDOW_H      = 400
BAR_X         = 40
BAR_Y         = WINDOW_H - 90
BAR_W         = 560
BAR_H         = 22
BAR_RADIUS    = 11
BAR_BORDER    = 3
COLOR_FILL    = "#FFD700"
COLOR_EMPTY   = "#7A6000"
COLOR_BORDER  = "#000000"

_cached_bg_image = None
_cached_bg_path = None
_cached_bg_size = None

def get_launcher_dir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

def get_game_dir():
    base = get_launcher_dir()
    if GAME_FOLDER:
        return os.path.join(base, GAME_FOLDER)
    return base

def md5_file(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()

def get_cache_path(game_dir):
    return os.path.join(game_dir, ".launcher_cache.json")

def load_cache(game_dir):
    try:
        with open(get_cache_path(game_dir), "r") as f:
            return json.load(f)
    except Exception:
        return {}

def save_cache(game_dir, cache):
    try:
        with open(get_cache_path(game_dir), "w") as f:
            json.dump(cache, f)
    except Exception:
        pass

def needs_update(local_path, remote_md5, cache):
    if not os.path.exists(local_path):
        return True
    stat   = os.stat(local_path)
    size   = stat.st_size
    mtime  = stat.st_mtime
    cached = cache.get(local_path)
    if cached and cached.get("mtime") == mtime and cached.get("size") == size:
        return cached.get("md5") != remote_md5
    real_md5 = md5_file(local_path)
    cache[local_path] = {"md5": real_md5, "mtime": mtime, "size": size}
    return real_md5 != remote_md5

def download_file(url, dest_path):
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    urllib.request.urlretrieve(url, dest_path)

def make_title_image(text, font_path, font_size, w, h_img):
    img  = Image.new("RGBA", (w, h_img), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype(font_path, font_size)
    except Exception:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x  = (w - tw) // 2
    y  = (h_img - th) // 2
    # Borde negro al 3% del tamaño del texto
    border_px = max(1, int(th * 0.03))
    for dx in range(-border_px, border_px + 1):
        for dy in range(-border_px, border_px + 1):
            if dx == 0 and dy == 0:
                continue
            draw.text((x+dx, y+dy), text, font=font, fill="#000000")
    draw.text((x, y), text, font=font, fill="#FFD700")
    return ImageTk.PhotoImage(img)

def make_button_image(text, w, h, radius, bg, fg, font_path, font_size):
    scale = 2
    sw, sh, sr = w*scale, h*scale, radius*scale
    img  = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, sw-1, sh-1], radius=sr, fill=bg, outline="#000000", width=3*scale)
    try:
        font = ImageFont.truetype(font_path, font_size*scale)
    except Exception:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0,0), text, font=font)
    tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
    draw.text(((sw-tw)//2, (sh-th)//2), text, font=font, fill=fg)
    img = img.resize((w, h), Image.LANCZOS)
    return ImageTk.PhotoImage(img)

def make_progress_bar(percent, w, h, radius, border, color_fill, color_empty, color_border):
    scale = 2
    sw, sh = w * scale, h * scale
    sr     = radius * scale
    sb     = border * scale
    img  = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, sw-1, sh-1], radius=sr, fill=color_empty, outline=color_border, width=sb)
    fill_w = int((sw - sb*2) * percent / 100)
    if fill_w > 0:
        fill_w = max(fill_w, sr*2)
        fill_w = min(fill_w, sw - sb*2)
        draw.rounded_rectangle([sb, sb, sb + fill_w, sh - sb - 1], radius=max(sr - sb, 2), fill=color_fill)
    img = img.resize((w, h), Image.LANCZOS)
    return ImageTk.PhotoImage(img)

def get_background_image():
    """Obtiene la imagen de fondo con cache para evitar recargar"""
    global _cached_bg_image, _cached_bg_path, _cached_bg_size
    
    launcher_dir = get_launcher_dir()
    bg_path = os.path.join(launcher_dir, "fondolauncher.png")
    if not os.path.exists(bg_path):
        bg_path = os.path.join(launcher_dir, "fondolauncher.jpg")
    
    if not os.path.exists(bg_path):
        return None
    
    if _cached_bg_image is not None and _cached_bg_path == bg_path and _cached_bg_size == (WINDOW_W, WINDOW_H):
        return _cached_bg_image
    
    try:
        img = Image.open(bg_path).resize((WINDOW_W, WINDOW_H), Image.LANCZOS)
        _cached_bg_image = ImageTk.PhotoImage(img)
        _cached_bg_path = bg_path
        _cached_bg_size = (WINDOW_W, WINDOW_H)
        return _cached_bg_image
    except Exception:
        return None

class Launcher:
    def __init__(self, root):
        self.root = root
        self._btn_enabled = False

        # Ventana real del launcher
        self.win = tk.Toplevel(root)
        self.win.title("PokeRetro Launcher Dx9")
        self.win.geometry(f"{WINDOW_W}x{WINDOW_H}")
        self.win.resizable(False, False)
        self.win.overrideredirect(True)
        
        # Establecer icono desde archivo .ico para que aparezca en barra de tareas
        icon_path = os.path.join(get_launcher_dir(), "perfil_icon.ico")
        if os.path.exists(icon_path):
            try:
                self.win.iconbitmap(icon_path)
            except Exception:
                pass

        # Centrar en pantalla
        sw = self.win.winfo_screenwidth()
        sh = self.win.winfo_screenheight()
        x  = (sw - WINDOW_W) // 2
        y  = (sh - WINDOW_H) // 2
        self.win.geometry(f"{WINDOW_W}x{WINDOW_H}+{x}+{y}")

        self._drag_x = 0
        self._drag_y = 0

        self.canvas = tk.Canvas(self.win, width=WINDOW_W, height=WINDOW_H, highlightthickness=0, bd=0)
        self.canvas.place(x=0, y=0)

        # Fondo optimizado con cache
        self.bg_image = get_background_image()
        if self.bg_image:
            self.canvas.create_image(0, 0, anchor="nw", image=self.bg_image)
        else:
            self.canvas.configure(bg="#1a1a2e")

        # Overlay inferior
        self.canvas.create_rectangle(0, WINDOW_H - 155, WINDOW_W, WINDOW_H, fill="#000000", stipple="gray50", outline="")

        # Botón cerrar X
        self.canvas.create_oval(WINDOW_W-36, 8, WINDOW_W-12, 32, fill="#e94560", outline="", tags="btn_close")
        self.canvas.create_text(WINDOW_W-24, 20, text="✕", font=("Arial", 9, "bold"), fill="white", tags="btn_close")
        # Botón minimizar
        self.canvas.create_oval(WINDOW_W-68, 8, WINDOW_W-44, 32, fill="#555555", outline="", tags="btn_min")
        self.canvas.create_text(WINDOW_W-56, 20, text="—", font=("Arial", 9, "bold"), fill="white", tags="btn_min")

        self.canvas.tag_bind("btn_close", "<ButtonRelease-1>", lambda e: self._close())
        self.canvas.tag_bind("btn_min",   "<ButtonRelease-1>", lambda e: self._minimize())
        self.canvas.tag_bind("btn_close", "<Enter>", lambda e: [self.canvas.itemconfig(i, fill="#c73652") for i in self.canvas.find_withtag("btn_close") if self.canvas.type(i)=="oval"])
        self.canvas.tag_bind("btn_close", "<Leave>", lambda e: [self.canvas.itemconfig(i, fill="#e94560") for i in self.canvas.find_withtag("btn_close") if self.canvas.type(i)=="oval"])

        # Arrastrar ventana
        self.canvas.bind("<ButtonPress-1>",    self._drag_start)
        self.canvas.bind("<B1-Motion>",         self._drag_motion)

        # Título Pokémon
        font_path = os.path.join(get_launcher_dir(), "Pokemon Solid.ttf")
        self.title_img = make_title_image("PokeRetro", font_path, 79, WINDOW_W, 110)
        self.canvas.create_image(WINDOW_W // 2, 50, anchor="center", image=self.title_img)

        # Subtítulo
        self.canvas.create_text(WINDOW_W//2+1, 101, text="Dx9", anchor="center", font=("Arial", 11, "bold"), fill="#000000")
        self.canvas.create_text(WINDOW_W//2,   100, text="Dx9", anchor="center", font=("Arial", 11, "bold"), fill="#FFD700")

        # Textos con sombra
        for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            self.canvas.create_text(BAR_X+dx, BAR_Y-18+dy, text="", anchor="w", font=("Arial", 9, "bold"), fill="#000000", tags="txt_left_shadow")
        self.text_left_id = self.canvas.create_text(BAR_X, BAR_Y-18, text="", anchor="w", font=("Arial", 9, "bold"), fill="#FFD700")

        for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            self.canvas.create_text(BAR_X+BAR_W+dx, BAR_Y-18+dy, text="", anchor="e", font=("Arial", 9, "bold"), fill="#000000", tags="txt_right_shadow")
        self.text_right_id = self.canvas.create_text(BAR_X+BAR_W, BAR_Y-18, text="", anchor="e", font=("Arial", 9, "bold"), fill="#FFD700")

        self.bar_img = make_progress_bar(0, BAR_W, BAR_H, BAR_RADIUS, BAR_BORDER, COLOR_FILL, COLOR_EMPTY, COLOR_BORDER)
        self.bar_id  = self.canvas.create_image(BAR_X, BAR_Y, anchor="nw", image=self.bar_img)

        for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            self.canvas.create_text(BAR_X+dx, BAR_Y+BAR_H+8+dy, text="", anchor="w", font=("Arial", 9), fill="#000000", tags="txt_status_shadow")
        self.status_id = self.canvas.create_text(BAR_X, BAR_Y+BAR_H+8, text="Iniciando...", anchor="w", font=("Arial", 9), fill="#ffffff")

        # Botón JUGAR
        btn_w, btn_h, btn_r = 160, 44, 22
        btn_x = WINDOW_W // 2 - btn_w // 2
        btn_y = WINDOW_H - 55
        self._btn_img_off = make_button_image("JUGAR", btn_w, btn_h, btn_r, "#555555", "#aaaaaa", font_path, 13)
        self._btn_img_on  = make_button_image("JUGAR", btn_w, btn_h, btn_r, "#e94560", "#ffffff", font_path, 13)
        self._btn_img_hov = make_button_image("JUGAR", btn_w, btn_h, btn_r, "#c73652", "#ffffff", font_path, 13)
        self.btn_id = self.canvas.create_image(btn_x, btn_y, anchor="nw", image=self._btn_img_off)
        self._btn_rect = (btn_x, btn_y, btn_x+btn_w, btn_y+btn_h)
        self.canvas.bind("<Motion>",          self._on_mouse_move)
        self.canvas.bind("<ButtonRelease-1>", self._on_click)

        self.win.protocol("WM_DELETE_WINDOW", self._close)
        self.root.protocol("WM_DELETE_WINDOW", self._close)

        threading.Thread(target=self.run_update, daemon=True).start()

    def _close(self):
        self.root.destroy()

    def _minimize(self):
        self.win.withdraw()

    def _drag_start(self, event):
        if event.x > WINDOW_W - 80 and event.y < 40:
            return
        self._drag_x = event.x
        self._drag_y = event.y

    def _drag_motion(self, event):
        if event.x > WINDOW_W - 80 and event.y < 40:
            return
        dx = event.x - self._drag_x
        dy = event.y - self._drag_y
        x  = self.win.winfo_x() + dx
        y  = self.win.winfo_y() + dy
        self.win.geometry(f"+{x}+{y}")

    def set_status(self, text):
        def _u():
            for item in self.canvas.find_withtag("txt_status_shadow"): self.canvas.itemconfig(item, text=text)
            self.canvas.itemconfig(self.status_id, text=text)
        self.win.after(0, _u)

    def set_progress(self, percent, downloaded=None, total=None):
        def update():
            self.bar_img = make_progress_bar(percent, BAR_W, BAR_H, BAR_RADIUS, BAR_BORDER, COLOR_FILL, COLOR_EMPTY, COLOR_BORDER)
            self.canvas.itemconfig(self.bar_id, image=self.bar_img)
            if total and total > 0:
                l = f"Descargados: {downloaded} archivos ({percent:.0f}%)"
                r = f"Faltan: {total - downloaded} archivos"
            elif percent >= 100:
                l, r = "Todo actualizado (100%)", "Faltan: 0 archivos"
            else:
                l, r = f"{percent:.0f}%", ""
            for item in self.canvas.find_withtag("txt_left_shadow"):  self.canvas.itemconfig(item, text=l)
            for item in self.canvas.find_withtag("txt_right_shadow"): self.canvas.itemconfig(item, text=r)
            self.canvas.itemconfig(self.text_left_id,  text=l)
            self.canvas.itemconfig(self.text_right_id, text=r)
        self.win.after(0, update)

    def enable_play(self):
        def _e():
            self._btn_enabled = True
            self.canvas.itemconfig(self.btn_id, image=self._btn_img_on)
        self.win.after(0, _e)

    def _in_btn(self, x, y):
        x1, y1, x2, y2 = self._btn_rect
        return x1 <= x <= x2 and y1 <= y <= y2

    def _on_mouse_move(self, event):
        if not self._btn_enabled: return
        if self._in_btn(event.x, event.y):
            self.canvas.itemconfig(self.btn_id, image=self._btn_img_hov)
            self.win.config(cursor="hand2")
        else:
            self.canvas.itemconfig(self.btn_id, image=self._btn_img_on)
            self.win.config(cursor="")

    def _on_click(self, event):
        if self._btn_enabled and self._in_btn(event.x, event.y):
            self.launch_game()

    def run_update(self):
        game_dir = get_game_dir()
        os.makedirs(game_dir, exist_ok=True)
        self.set_status("Verificando actualizaciones...")
        self.set_progress(5)
        try:
            with urllib.request.urlopen(MANIFEST_URL, timeout=15) as r:
                manifest = json.loads(r.read().decode())
        except Exception:
            self.set_status("Sin conexión. Iniciando de todas formas...")
            self.set_progress(100)
            self.enable_play()
            return
        files = manifest.get("files", {})
        if not files:
            self.set_status("No hay archivos en el manifest.")
            self.enable_play()
            return
        cache = load_cache(game_dir)
        to_update = []
        for rel_path, remote_md5 in files.items():
            local_path = os.path.join(game_dir, rel_path.replace("/", os.sep))
            if needs_update(local_path, remote_md5, cache):
                to_update.append(rel_path)
        save_cache(game_dir, cache)
        total = len(to_update)
        if total == 0:
            self.set_status("¡El cliente está actualizado!")
            self.set_progress(100, 0, 0)
            self.enable_play()
            return
        self.set_status(f"Descargando {total} archivo(s) nuevos...")
        for i, rel_path in enumerate(to_update, 1):
            dest = os.path.join(game_dir, rel_path.replace("/", os.sep))
            url  = f"{RAW_BASE}/{rel_path}"
            try:
                download_file(url, dest)
                if os.path.exists(dest):
                    stat = os.stat(dest)
                    cache[dest] = {"md5": files[rel_path], "mtime": stat.st_mtime, "size": stat.st_size}
            except Exception:
                pass
            self.set_progress(10 + int((i / total) * 90), i, total)
        save_cache(game_dir, cache)
        self.set_status("¡Actualización completada!")
        self.set_progress(100, total, total)
        self.enable_play()

    def launch_game(self):
        game_dir = get_game_dir()
        exe_path = os.path.join(game_dir, GAME_EXE)
        if os.path.exists(exe_path):
            subprocess.Popen([exe_path], cwd=game_dir)
            self.win.after(500, self._close)
        else:
            self.set_status(f"No encontrado: {exe_path}")

if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()
    app  = Launcher(root)
    root.mainloop()
