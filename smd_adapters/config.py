import dataclasses
import math
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any

from build123d import Plane


@dataclass(frozen=True, slots=True)
class Config:
    name: str = ""
    clip: tuple[float, float] = (0.0, 0.0)
    chip: tuple[float, float] = (0.0, 0.0)
    board: tuple[float, float] = (0.0, 0.0)
    board_thickness: float = 1.5
    dip_pitch: float = 2.54
    thickness: float = 2.0
    contact_height: float = 0.4
    lock_height: float = 0.4
    foot_width_max: float = 1.5
    seat_width: float = 0.5
    seat_depth: float = 0.6
    angle: float = 45

    def compute_clip_board(self, footprint_clip: tuple[float, float]) -> dict[str, Any]:
        board, clip = self.board, self.clip
        if clip[0] <= 0 or clip[1] <= 0:
            clip = (
                (board[0], board[1] - self.dip_pitch*2) 
                if board[0] > 0 and board[1] > 0 else 
                footprint_clip
            )
        if board[0] <= 0 or board[1] <= 0:
            board = (clip[0], clip[1] + self.dip_pitch*2)
        return { "clip": clip, "board": board }

    def compute_chip(self, footprint_chip: tuple[float, float]) -> tuple[float, float]:
        """Keep an explicitly set chip size, otherwise use the footprint's."""
        if self.chip[0] > 0 and self.chip[1] > 0:
            return self.chip
        return footprint_chip

    @property
    def band_y(self) -> float:
        """Free PCB band on either side of the chip."""
        return (self.clip[1] - self.chip[1]) / 2

    @property
    def taper(self) -> float:
        """Horizontal run of each cavity wall per unit of height."""
        return math.tan(math.radians(self.angle))

    @property
    def board_half(self) -> float:
        return self.board_thickness / 2

    @property
    def top_z(self) -> float:
        """Cavity ceiling, which is also the underside of the bridge."""
        return self.board_half + self.contact_height

    @property
    def bottom_z(self) -> float:
        return -self.board_half - self.lock_height

    @property
    def bridge(self) -> Plane:
        """Bridge underside, normal pointing into the cavity.

        "+" adds a pad downwards, "-" cuts a pocket upwards.
        """
        return Plane(
            origin=(0, 0, self.top_z),
            x_dir=(1, 0, 0),
            z_dir=(0, 0, -1),
        )


class Footprint(ABC):
    @abstractmethod
    def resolve(self, cfg: Config) -> Config:
        ...

    def build(self, cfg: Config | None = None, **overrides: Any) -> Config:
        """Resolve this footprint against a config plus explicit overrides.

        Overrides are applied on both sides of ``resolve``: before, so inputs
        such as ``dip_pitch``, ``clip`` and ``board`` affect the derived
        dimensions, and after, so explicit values always win even if the
        footprint sets the same field unconditionally.
        """
        cfg = cfg if cfg is not None else Config()
        if overrides:
            cfg = dataclasses.replace(cfg, **overrides)
        cfg = self.resolve(cfg)
        if overrides:
            cfg = dataclasses.replace(cfg, **overrides)
        return cfg


@dataclass(frozen=True, slots=True)
class Sot23(Footprint):
    def resolve(self, cfg: Config):
        return dataclasses.replace(cfg, 
            name=cfg.name or "sot23",
            chip=cfg.compute_chip((3.0, 1.7)),
            **cfg.compute_clip_board((3 * cfg.dip_pitch, 2 * cfg.dip_pitch))
        )


@dataclass(frozen=True, slots=True)
class Sop(Footprint):
    pins: int
    pitch: float
    lead_span: float
    board_pitches: int
    body_len: float

    def __init__(self, 
        pins: int, 
        pitch = 1.27, 
        lead_span = 5.1, 
        board_pitches: int | None = None, 
        body_len: int | None = None
    ):
        per_side = pins // 2
        object.__setattr__(self, "pins", pins)
        object.__setattr__(self, "pitch", pitch)
        object.__setattr__(self, "lead_span", lead_span)
        object.__setattr__(self, "board_pitches", 
            board_pitches if board_pitches is not None else max(3, math.ceil(per_side / 2)))
        object.__setattr__(self, "body_len", 
            body_len if body_len is not None else float(round(per_side * self.pitch)))


    def resolve(self, cfg: Config):
        return dataclasses.replace(cfg, 
            name=cfg.name or f"sop{self.pins}",
            chip=cfg.compute_chip((self.body_len, self.lead_span)),
            **cfg.compute_clip_board(((self.pins // 2) * cfg.dip_pitch, self.board_pitches * cfg.dip_pitch))
        )


