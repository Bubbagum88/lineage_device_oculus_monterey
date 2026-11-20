#!/usr/bin/env python3
"""Extract one partition from a full-OTA payload.bin (REPLACE, REPLACE_BZ,
REPLACE_XZ, ZERO). Usage: payload_extract.py payload.bin system system.img
With a partition name that doesn't exist, it lists the partitions."""
import sys, struct, bz2, lzma

def varint(b, i):
    r = s = 0
    while True:
        c = b[i]; i += 1
        r |= (c & 0x7f) << s; s += 7
        if c < 0x80: return r, i

def fields(b):
    i = 0; out = []
    while i < len(b):
        k, i = varint(b, i); f, t = k >> 3, k & 7
        if t == 0: v, i = varint(b, i)
        elif t == 1: v = b[i:i+8]; i += 8
        elif t == 5: v = b[i:i+4]; i += 4
        elif t == 2:
            n, i = varint(b, i); v = b[i:i+n]; i += n
        else: raise ValueError("wire type %d" % t)
        out.append((f, v))
    return out

def main():
    path, want, outp = sys.argv[1:4]
    f = open(path, 'rb')
    hdr = f.read(24)
    assert hdr[:4] == b'CrAU', 'not a payload.bin'
    ver, msize, ssize = struct.unpack('>QQI', hdr[4:24])
    assert ver == 2, ver
    man = f.read(msize)
    data_start = 24 + msize + ssize
    bs = 4096; names = []
    parts = [v for fn, v in fields(man) if fn == 13]
    bs = ([v for fn, v in fields(man) if fn == 3] or [4096])[0]
    for p in parts:
        pf = fields(p)
        name = [v for fn, v in pf if fn == 1][0].decode()
        names.append(name)
        if name != want: continue
        ops = [fields(v) for fn, v in pf if fn == 8]
        with open(outp, 'wb') as o:
            for n, op in enumerate(ops):
                d = dict((fn, v) for fn, v in op if fn != 6)
                ext = [dict(fields(v)) for fn, v in op if fn == 6]
                typ = d.get(1, 0)
                if typ in (0, 1, 8):
                    f.seek(data_start + d.get(2, 0)); raw = f.read(d.get(3, 0))
                    if typ == 1: raw = bz2.decompress(raw)
                    elif typ == 8: raw = lzma.decompress(raw)
                elif typ in (6, 7): raw = None
                else: raise SystemExit('op type %d is a delta: not a full OTA' % typ)
                pos = 0
                for e in ext:
                    o.seek(e.get(1, 0) * bs); ln = e.get(2, 0) * bs
                    o.write(raw[pos:pos+ln] if raw is not None else b'\0' * ln)
                    pos += ln
                if n % 200 == 0: print('op', n, '/', len(ops), flush=True)
        print('done', name); return
    print('partitions:', names)

main()
