"""Blocks every network connection for the current process.

Import this module before any OCR library so that a library trying to download
models or send telemetry fails loudly instead of silently reaching the internet.
"""

import socket


class NetworkBlockedError(RuntimeError):
    pass


def _blocked(*args, **kwargs):
    raise NetworkBlockedError(f"Network access is disabled (attempted: {args[:2]})")


def install() -> None:
    socket.socket.connect = _blocked
    socket.socket.connect_ex = _blocked
    socket.create_connection = _blocked
    socket.getaddrinfo = _blocked
    socket.gethostbyname = _blocked


install()
