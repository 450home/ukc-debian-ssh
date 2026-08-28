#!/usr/bin/env python3
# 纯标准库 WebSocket -> TCP 代理 (替代 websockify, 零依赖)
# 用法: pyws.py --web /opt/novnc 0.0.0.0:6080 localhost:5901
import sys, os, socket, struct, base64, hashlib, threading, argparse

def handshake(conn, web_root):
    req = b""
    while b"\r\n\r\n" not in req:
        req += conn.recv(1)
    headers = {}
    for line in req.split(b"\r\n")[1:]:
        if b":" in line:
            k, v = line.split(b":", 1)
            headers[k.strip().lower()] = v.strip()
    key = headers.get(b"sec-websocket-key", b"").decode()
    accept = base64.b64encode(hashlib.sha1(key.encode() + b"258EAFA5-E914-47DA-95CA-C5AB0DC85B11").digest()).decode()
    resp = (
        "HTTP/1.1 101 Switching Protocols\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        f"Sec-WebSocket-Accept: {accept}\r\n"
    )
    # 若请求 /vnc.html 等静态文件, 返回文件内容
    first = req.split(b"\r\n")[0].decode()
    path = first.split(" ")[1] if " " in first else "/"
    if web_root and path != "/" and not path.startswith("/websockify"):
        fpath = os.path.normpath(os.path.join(web_root, path.lstrip("/")))
        if os.path.isfile(fpath):
            resp += "Content-Type: text/html\r\n\r\n"
            conn.send(resp.encode())
            with open(fpath, "rb") as f:
                conn.send(f.read())
            return None
    resp += "\r\n"
    conn.send(resp.encode())
    return conn

def decode_frame(conn):
    h = conn.recv(2)
    if len(h) < 2:
        return None, None
    opcode = h[0] & 0x0F
    ln = h[1] & 0x7F
    if ln == 126:
        ln = struct.unpack("!H", conn.recv(2))[0]
    elif ln == 127:
        ln = struct.unpack("!Q", conn.recv(8))[0]
    mask = conn.recv(4)
    data = conn.recv(ln)
    if len(data) < ln:
        data += conn.recv(ln - len(data))
    un = bytes(b ^ mask[i % 4] for i, b in enumerate(data))
    return opcode, un

def encode_frame(data):
    out = bytearray(b"\x82\x80" if len(data) < 126 else b"\x82\x7e")
    if len(data) < 126:
        out[1] = len(data)
    else:
        out += struct.pack("!H", len(data))
    return bytes(out) + data

def pipe(ws, tcp):
    try:
        while True:
            opcode, data = decode_frame(ws)
            if opcode is None or opcode == 8:
                break
            if data:
                tcp.sendall(data)
    except: pass
    finally:
        try: tcp.close()
        except: pass

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--web", default="/opt/novnc")
    ap.add_argument("listen")
    ap.add_argument("target")
    a = ap.parse_args()
    lhost, lport = a.listen.rsplit(":", 1)
    thost, tport = a.target.rsplit(":", 1)
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((lhost, int(lport)))
    srv.listen(5)
    print(f"pyws listening on {a.listen} -> {a.target}")
    while True:
        conn, _ = srv.accept()
        ws = handshake(conn, a.web)
        if ws is None:
            continue
        tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tcp.connect((thost, int(tport)))
        threading.Thread(target=pipe, args=(ws, tcp), daemon=True).start()
        threading.Thread(target=lambda: [tcp.sendall(d) for d in iter(lambda: ws.recv(4096), b"")] if False else None).start()
        # 反向: tcp -> ws
        def rev(tcp, ws):
            try:
                while True:
                    d = tcp.recv(4096)
                    if not d: break
                    ws.sendall(encode_frame(d))
            except: pass
        threading.Thread(target=rev, args=(tcp, ws), daemon=True).start()

if __name__ == "__main__":
    main()
